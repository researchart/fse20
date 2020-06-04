import csv
import random
from functools import partial
from typing import Callable, Optional
from pdb import set_trace as st
import os
import random
import pandas as pd
from typing import Any, Callable, Dict, Iterable, List, Tuple, Union

import numpy as np
import tensorflow as tf
from foolbox.attacks import (
    FGSM,
    Attack,
    DeepFoolAttack,
    IterativeGradientSignAttack,
    SaliencyMapAttack,
)
# from foolbox.criteria import TargetClass
# from foolbox.models import TensorFlowModel
from tensorflow.python.training import saver
from tensorflow.python.training.session_manager import SessionManager
import tensorflow as tf
import numpy as np
import pickle
import sklearn.metrics as metrics
import matplotlib.pyplot as plt
plt.switch_backend('Agg')

from model.config import LENET
from model import LeNet
import nninst_mode as mode
from dataset import mnist
from dataset.config import MNIST_TRAIN, MNIST_PATH
from dataset.mnist_transforms import *
from trace.lenet_mnist_class_trace_v2 import (
    data_config,
)
from trace.common import (
    class_trace,
)
from tf_utils import new_session_config
from nninst_statistics import calc_trace_side_overlap
from nninst_trace import TraceKey
from nninst_utils.numpy import arg_approx
from nninst_utils.ray import ray_init
from nninst_utils.fs import ensure_dir, IOAction, CsvIOAction, abspath

from .common import get_overlay_summary, clean_overlap_ratio, \
                translation_overlap_ratio, attack_overlap_ratio, \
                lenet_mnist_example
from .cw_attack import cw_generate_adversarial_example
from .eval_mnist import  foolbox_generate_adversarial_example
from .cw_attacks import CarliniL2
from nninst_graph import AttrMap, Graph, GraphAttrKey
from nninst_utils.ray import ray_iter
from tf_graph import (
    MaskWeightWithTraceHook,
    model_fn_with_fetch_hook,
)
from trace.common import (
    get_predicted_value,
    get_rank,
    predict,
    reconstruct_class_trace_from_tf,
    reconstruct_trace_from_tf,
    reconstruct_trace_from_tf_brute_force,
)
from .analyse_class_trace import reconstruct_edge

from sklearn import tree
from sklearn.ensemble import RandomForestClassifier
from sklearn.svm import OneClassSVM

threshold = 0.9
dilation_iter = 1

# Model config
model_label = "augmentation"
model_dir = f"result/lenet/model_{model_label}"
# Trace config
trace_dir =  f"{model_dir}/traces"
trace_name = "noop"
class_trace_dir = f"{model_dir}/traces_{threshold}"


data_dir = f"{model_dir}/allrelations/{threshold}_{dilation_iter}/"
# result_dir = f"result/lenet/test"
training_images_per_class = 1000
test_images_per_class = 100

attack_name = "FGSM"

adversarial_label = 1
original_label = -1

attacks = {
    "FGSM": [FGSM],
    "BIM": [IterativeGradientSignAttack],
    "JSMA": [SaliencyMapAttack],
    "DeepFool": [DeepFoolAttack],
    # "DeepFool_full": [DeepFoolAttack, dict(subsample=None)],
    # "CWL2": [CarliniL2],
}



# DeepFool will shutdown when num_gpu<0.2
num_gpus = 0.2

overlap_fn = calc_trace_side_overlap
per_channel = False

lenet_mnist_class_trace = class_trace(
                            trace_name,
                            model_config=LENET,
                            data_config=data_config,
                        )

class_trace_fn=lambda class_id: lenet_mnist_class_trace(
    class_id,
    threshold,
    label=model_label,
    trace_dir = class_trace_dir,
)

def convert_to_one_hot(y, C):
    return np.eye(C)[y.reshape(-1)]

def relation_to_vector(
    data_dir,
    class_id,
    image_id,

):
    path = os.path.join(data_dir, f"{class_id}", f"{image_id}.pkl")
    if not os.path.exists(path):
        return np.array([])
    with open(path, "rb") as f:
        op_to_relations = pickle.load(f)
    channel_relation =  op_to_relations["channel_relation"]
    channel_birelation = op_to_relations["channel_birelation"]
    channel_inter_birelation = op_to_relations["channel_inter_birelation"]
    spatial_relation = op_to_relations["spatial_relation"]




    feature = np.array([])
    for node_name in [
        "conv2d/Relu:0",
        "conv2d_1/Relu:0",
    ]:
        feature = np.concatenate(
            (feature, channel_relation[node_name])
        )


    # feature = np.concatenate(
    #     (feature, inter_conv_relation)
    # )


    for node_name in [
        "conv2d/Relu:0",
        "conv2d_1/Relu:0",
    ]:
        feature = np.concatenate(
            (feature, height_relation[node_name], width_relation[node_name])
        )


    feature = np.concatenate(
        (feature, op_to_relations["conv1_weight"], op_to_relations["conv2_weight"])
    )

    return feature

def load_relations(
    data_dir,
    class_id,
    image_id,
):
    path = os.path.join(data_dir, f"{class_id}", f"{image_id}.pkl")
    if not os.path.exists(path):
        return np.array([])
    with open(path, "rb") as f:
        op_to_relations = pickle.load(f)
    return op_to_relations

def extract_by_key(
    data_dir,
    class_id,
    image_id,
    key,
):
    op_to_relations = load_relations(
        data_dir,
        class_id,
        image_id,
    )
    if len(op_to_relations)==0:
        return [], None
    if key == "channel_relation":
        channel_relation =  op_to_relations[key]
        feature = np.concatenate(
            (channel_relation["conv2d/Relu:0"],
             channel_relation["conv2d_1/Relu:0"],
             )
        )

    elif key == "channel_birelation":
        channel_relation = op_to_relations[key]
        feature = np.concatenate(
            (channel_relation["conv2d/Relu:0"],
             channel_relation["conv2d_1/Relu:0"])
        )
    elif key == "spatial_relation":
        spatial_relation = op_to_relations[key]
        feature = np.concatenate(
            (spatial_relation["conv2d/Relu:0"],
             spatial_relation["conv2d_1/Relu:0"])
        )
    elif key == "weight_relation":
        feature = np.concatenate(
            (op_to_relations["conv1_weight"],
             op_to_relations["conv2_weight"])
        )
    elif key == "channel_weight":
        channel_relation =  op_to_relations["channel_relation"]
        feature = np.concatenate(
            (channel_relation["conv2d/Relu:0"],
             channel_relation["conv2d_1/Relu:0"],
             op_to_relations["conv1_weight"],
              op_to_relations["conv2_weight"],
              )
        )
    elif key == "hieght_width_relation":
        height_relation = op_to_relations["height_relation"]
        width_relation = op_to_relations["width_relation"]
        feature = np.array([])
        for node_name in [
            "conv2d/Relu:0",
            "conv2d_1/Relu:0",
        ]:
            feature = np.concatenate(
                (feature,
                 height_relation[node_name],
                 width_relation[node_name])
            )
    feature[feature>0] = 1
    predict = op_to_relations["predict"]
    return feature, predict

def load_data_and_label(
    data_dir,
    image_per_class,
    key,
):

    data = [
        extract_by_key(
            data_dir,
            class_id,
            image_id,
            key,
        )
        for image_id in range(image_per_class)
        for class_id in range(10)
    ]
    label = [
        class_id
        for image_id in range(image_per_class)
        for class_id in range(10)
    ]
    label = np.array([
        class_id
        for d, class_id in zip(
            data, label
        )
        if len(d[0])>0
    ])
    model_predict = np.array([
        d[1] for d in data if len(d[0])>0
    ])

    data = np.array([
        d[0] for d in data if len(d[0])>0
    ])

    return data, label, model_predict

def train_model_by_key(
    train_dir,
    test_original_dir,
    test_adversarial_dir,
    key,
):
    train_data, train_label, _ = load_data_and_label(
        train_dir,
        training_images_per_class,
        key = key,
    )

    test_original_data, test_original_label, _ = load_data_and_label(
        test_original_dir,
        test_images_per_class,
        key = key,
    )

    clf=tree.DecisionTreeClassifier(
        # max_depth = 10,
        # min_samples_leaf = 20,
    )
    clf=clf.fit(train_data, train_label)
    pred = clf.predict(test_original_data)
    acc = (pred == test_original_label).sum() / len(pred)
    fpr = 1 - acc
    test_adversarial_data, test_adversarial_label, test_adversarial_raw_pred = load_data_and_label(
        test_adversarial_dir,
        test_images_per_class,
        key = key,
    )
    adversarial_pred = clf.predict(test_adversarial_data)
    tpr = (adversarial_pred!=test_adversarial_raw_pred).sum() / len(adversarial_pred)
    roc_tpr = [0, tpr, 1]
    roc_fpr = [0, fpr, 1]
    auc = metrics.auc(roc_fpr, roc_tpr)
    print(f"{key} acc: {acc:.3f} tpr: {tpr:.3f}, fpr: {fpr:.3f}, auc: {auc:.3f}")

    return clf


# data_dir is like
# - per_image_trace_0.9
#     - train
#         - FGSM_noop
#         - original_noop
#     - test
#         - FGSM_noop
#         - original_noop
def decision_tree_classify(
    data_dir: str,
    train_attack_name: str =  "FGSM",
    train_transform_name: str = "noop",
    test_attack_name: str =  "FGSM",
    test_transform_name: str = "noop",
):

    train_dir = os.path.join(data_dir, f"train")
    test_dir = os.path.join(data_dir, f"test")
    train_original_dir = os.path.join(train_dir, f"original_{train_transform_name}")
    train_adversarial_dir = os.path.join(train_dir, f"{train_attack_name}_{train_transform_name}")
    test_original_dir = os.path.join(test_dir, f"original_{test_transform_name}")
    test_adversarial_dir = os.path.join(test_dir, f"{test_attack_name}_{test_transform_name}")

    train_model_by_key_fn = partial(
        train_model_by_key,
        train_original_dir,
        test_original_dir,
        test_adversarial_dir,
    )

    keys = [
        "channel_relation",
        "channel_birelation",
        "spatial_relation",
        "weight_relation",
        "hieght_width_relation",
        "channel_weight",
    ]
    clf_list = []
    train_pred_list = []
    for key in keys:
        clf = train_model_by_key_fn(
            key
        )
        clf_list.append(clf)

        train_original_data, train_original_label, \
        train_original_model_pred = load_data_and_label(
            train_original_dir,
            training_images_per_class,
            key = key,
        )
        if len(train_pred_list)==0:
            train_pred_list.append(
                np.expand_dims(train_original_model_pred, 1)
            )

        train_pred_list.append(
                np.expand_dims(
                    clf.predict(train_original_data),
                1)
        )
    return


    # One class classification based on predictions of each classifier
    pred = np.concatenate(
        train_pred_list, axis=1
    )
    one_class_clf=OneClassSVM(
        # max_depth = 10,
        # min_samples_leaf = 20,
    )
    one_class_clf=one_class_clf.fit(pred)

    test_original_preds = []
    test_adversarial_preds = []
    for clf, key in zip(clf_list, keys):
        test_original_data, test_original_label, _ = load_data_and_label(
            test_original_dir,
            test_images_per_class,
            key = key,
        )
        test_adversarial_data, test_adversarial_label, test_adversarial_pred = load_data_and_label(
            test_adversarial_dir,
            test_images_per_class,
            key = key,
        )
        if len(test_original_preds)==0:
            test_original_preds.append(
                np.expand_dims(test_original_label, 1)
            )
        original_pred = clf.predict(test_original_data)
        original_pred = np.expand_dims(original_pred, 1)
        test_original_preds.append(original_pred)

        if len(test_adversarial_preds)==0:
            test_adversarial_preds.append(
                np.expand_dims(test_adversarial_pred, 1)
            )
        adversarial_pred = clf.predict(test_adversarial_data)
        adversarial_pred = np.expand_dims(adversarial_pred, 1)
        test_adversarial_preds.append(adversarial_pred)

    original_input = np.concatenate(
        test_original_preds, axis=1
    )
    adversarial_input = np.concatenate(
        test_adversarial_preds, axis=1
    )

    original_pred = one_class_clf.predict(original_input)
    adversarial_pred = one_class_clf.predict(adversarial_input)

    acc = (original_pred == 1).sum() / len(original_pred)
    fpr = 1 - acc
    tpr = (adversarial_pred==-1).sum() / len(adversarial_pred)
    roc_tpr = [0, tpr, 1]
    roc_fpr = [0, fpr, 1]
    auc = metrics.auc(roc_fpr, roc_tpr)
    print(f"One class pred tpr: {tpr:.3f}, fpr: {fpr:.3f}, auc: {auc:.3f}")
    # train 1000, test 100, 6 kinds of mode
    # One class pred tpr: 1.000, fpr: 0.876, auc: 0.562


def load_class_point_mask():
    class_traces = [
        class_trace_fn(i).load() for i in range(10)
    ]
    class_masks = []
    for trace in class_traces:
        op_to_point = {}
        for node_name in sorted(trace.nodes):
            if TraceKey.POINT in trace.nodes[node_name]:
                op_to_point[node_name] = reconstruct_point_fn(
                                        node_name = node_name,
                                        trace = trace)
        class_masks.append(op_to_point)
    return class_masks


def extract_relation_mask_by_key(
    data_dir,
    class_id,
    image_id,
    key,
):
    op_to_relations = load_relations(
        data_dir,
        class_id,
        image_id,
    )
    if len(op_to_relations)==0:
        return [], None
    if key == "channel_relation":
        channel_relation =  op_to_relations[key]
        feature = np.concatenate(
            (channel_relation["conv2d/Relu:0"],
             channel_relation["conv2d_1/Relu:0"],
             )
        )
    elif key == "channel_birelation":
        channel_relation = op_to_relations[key]
        feature = np.concatenate(
            (channel_relation["conv2d/Relu:0"],
             channel_relation["conv2d_1/Relu:0"])
        )
    elif key == "spatial_relation":
        spatial_relation = op_to_relations[key]
        feature = np.concatenate(
            (spatial_relation["conv2d/Relu:0"],
             spatial_relation["conv2d_1/Relu:0"])
        )
    elif key == "weight_relation":
        feature = np.concatenate(
            (op_to_relations["conv1_weight"],
             op_to_relations["conv2_weight"])
        )
    elif key == "hieght_width_relation":
        height_relation = op_to_relations["height_relation"]
        width_relation = op_to_relations["width_relation"]
        feature = np.array([])
        for node_name in [
            "conv2d/Relu:0",
            "conv2d_1/Relu:0",
        ]:
            feature = np.concatenate(
                (feature,
                 height_relation[node_name],
                 width_relation[node_name])
            )
    point_mask = op_to_relations["point_mask"]
    pred = op_to_relations["predict"]
    return feature, point_mask, pred

def load_relation_mask_and_label(
    data_dir,
    image_per_class,
    key,
):

    data = [
        extract_relation_mask_by_key(
            data_dir,
            class_id,
            image_id,
            key,
        )
        for image_id in range(image_per_class)
        for class_id in range(10)
    ]
    label = [
        class_id
        for image_id in range(image_per_class)
        for class_id in range(10)
    ]

    label = np.array([
        class_id
        for data, class_id in zip(
            data, label
        )
        if len(data[0])>0
    ])
    model_predict = np.array([
        d[2] for d in data if len(d[0])>0
    ])

    data = [
        (d[0], d[1]) for d in data if len(d[0])>0
    ]
    return data, label, model_predict

def predict_per_image(
    data,
    pred_label,
    clf,
    class_masks,
):
    class_mask_all = class_masks[pred_label]
    image_mask_all = data[1]
    relations = data[0]
    for node_name in [
        "conv2d/Relu:0",
        "conv2d_1/Relu:0",
    ]:
        class_mask = class_mask_all[node_name]
        image_mask = image_mask_all[node_name]

        violation = image_mask[class_mask==0].sum()
        if violation>0:
            return adversarial_label

    feature = np.expand_dims(relations, 0)
    clf_pred = clf.predict(feature)
    if pred_label != clf_pred:
        return adversarial_label


    return original_label

def pred_by_relation_and_trace(
    relation_root_dir,
    attack_name,
    transform_name,
    images_per_class,
    key,
    clf,
    class_masks,
):
    relation_dir = os.path.join(relation_root_dir, f"{attack_name}_{transform_name}")
    data, label, raw_predict = load_relation_mask_and_label(
        relation_dir,
        images_per_class,
        key,
    )

    pred = np.array([
        predict_per_image(
            d, raw_pred, clf, class_masks,
        )
        for d, raw_pred in zip(data, raw_predict)
    ])
    return pred

from .save_relations import reconstruct_point_fn
# data_dir is like
# - per_image_trace_0.9
#     - train
#         - FGSM_noop
#         - original_noop
#     - test
#         - FGSM_noop
#         - original_noop
def NOT_decision_tree_classify(
    data_dir: str,
    train_attack_name: str =  "FGSM",
    train_transform_name: str = "noop",
    test_attack_name: str =  "FGSM",
    test_transform_name: str = "noop",
):

    class_masks = load_class_point_mask()


    train_dir = os.path.join(data_dir, f"train")
    test_dir = os.path.join(data_dir, f"test")
    train_original_dir = os.path.join(train_dir, f"original_{train_transform_name}")
    train_adversarial_dir = os.path.join(train_dir, f"{train_attack_name}_{train_transform_name}")
    test_original_dir = os.path.join(test_dir, f"original_{test_transform_name}")
    test_adversarial_dir = os.path.join(test_dir, f"{test_attack_name}_{test_transform_name}")

    train_model_by_key_fn = partial(
        train_model_by_key,
        train_original_dir,
        test_original_dir,
        test_adversarial_dir,
    )

    relation_key = "channel_relation"
    clf = train_model_by_key_fn(
        relation_key
    )

    pred_by_relation_and_trace_fn = partial(
        pred_by_relation_and_trace,
        relation_root_dir = test_dir,
        transform_name = test_transform_name,
        images_per_class = test_images_per_class,
        key = relation_key,
        clf = clf,
        class_masks = class_masks,
    )
    original_pred = pred_by_relation_and_trace_fn(
        attack_name = "original",
    )
    adversarial_pred = pred_by_relation_and_trace_fn(
        attack_name = test_attack_name
    )

    tpr = (adversarial_pred == adversarial_label).sum() / len(adversarial_pred)
    fpr = (original_pred == adversarial_label).sum() / len(original_pred)
    roc_tpr = [0, tpr, 1]
    roc_fpr = [0, fpr, 1]
    auc = metrics.auc(roc_fpr, roc_tpr)
    print(f"NOT and relation pred tpr: {tpr:.3f}, fpr: {fpr:.3f}, auc: {auc:.3f}")




if __name__=="__main__":
    # NOT_decision_tree_classify(
    decision_tree_classify(
        data_dir = data_dir,
        train_attack_name = attack_name,
        train_transform_name = "noop",
    )
