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
from sklearn import tree
from sklearn.ensemble import (
    AdaBoostClassifier,
    GradientBoostingClassifier,
    RandomForestClassifier,
)
import scipy.ndimage as ndimage
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

from eval.common import get_overlay_summary, clean_overlap_ratio, \
                translation_overlap_ratio, attack_overlap_ratio, \
                lenet_mnist_example
from eval.cw_attack import cw_generate_adversarial_example
from eval.eval_mnist import  foolbox_generate_adversarial_example
from eval.cw_attacks import CarliniL2
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
from eval.eval_by_reduced_point import reconstruct_point
from nninst_op import *
from nninst_trace import calc_padding

from logics.mask_to_logics import *
from logics.decode_trace import *
from logics.save_logics import *
from logics.logics_eval import *

threshold = 0.9
dilation_iter = 1
dilation_structure = ndimage.generate_binary_structure(2, 2)
# Model config
model_label = "augmentation"
model_dir = f"result/lenet/model_{model_label}"
# Trace config

per_image_trace_dir = f"{model_dir}/nninst_mu_posneg/per_image_trace_{threshold}"

logic_dir = f"{model_dir}/nninst_mu_posneg/logics_{threshold}"
clf_dir = f"{logic_dir}/clf"
train_images_per_class = 1000
logic_filter_thred_ratio = 0.01
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

available_logic_names = [
    "unary",
    "binary",
    "triadic",
]
point_keys = [
    "conv2d/Relu:0",
    "conv2d_1/Relu:0",
]
weight_keys = [
    "conv2d/Conv2D",
    "conv2d_1/Conv2D",
]

def load_logic_data(
    class_thred_logics,
    dataset_split,
    images_per_class,
    data_config,
    attack_name = "original",
):

    def filter_logic_by_class_thred(
        target_logic,
        class_logic,
        layer_names = point_keys,
    ):
        filtered_logic = {}
        for key in layer_names:
            target_mask = target_logic[key].to_tensor()
            class_mask = class_logic[key].to_tensor()
            class_mask = class_mask.astype(np.bool)
            filtered_target = target_mask[class_mask]
            # filtered_target = target_mask.flatten()
            filtered_logic[key] = filtered_target
            # print(key, target_mask.shape, filtered_target.shape)
        return filtered_logic

    def load_logic_data_per_image_config(
        config,
        class_id,
        image_id,
    ):
        trace_key, logic_name, layer_names = config
        path = logic_save_path(
            logic_dir,
            trace_key,
            logic_name,
            dataset_split,
            attack_name,
            "noop",
            class_id,
            image_id,
        )
        if not os.path.exists(path):
            return {}
        with open(path, "rb") as f:
            logic = pickle.load(f)

        # filtered_logic = filter_logic_by_class_thred(
        #     logic,
        #     class_thred_logics[trace_key]["all"][logic_name],
        #     layer_names,
        # )

        logic_data = [data.to_tensor() for data in logic.values()]
        # for d in logic_data:
        #     print(d.shape)

        logic_data = np.concatenate(
            logic_data, axis = 0,
        )
        return logic_data

    def load_logic_data_per_image(
        data_config,
        class_id,
        image_id,
    ):
        image_logic = []
        for config in data_config:
            image_logic.append(
                load_logic_data_per_image_config(
                    config,
                    class_id,
                    image_id,
                )
            )
            if len(image_logic[-1]) == 0:
                return [], -1, -1

        logic_data = np.concatenate(
            [data for data in image_logic],
            axis = 0,
        )
        # logic_data = np.expand_dims(
        #     logic_data, 0
        # )

        raw_prediction = load_raw_prediction(
            class_id,
            image_id,
            dataset_split,
            attack_name,
        )
        return logic_data, class_id, raw_prediction
    
    results = ray_iter(
        load_logic_data_per_image,
        [
            (
                data_config,
                class_id,
                image_id
            )
            for class_id in range(10)
            for image_id in range(images_per_class)
        ],
        chunksize=1,
        out_of_order=True,
        huge_task=True,
    )
    results = [result for result in results if len(result[0]) > 0]

    logic_data = np.array([result[0] for result in results])
    label = np.array([result[1] for result in results])
    raw_prediction = np.array([result[2] for result in results])

    return logic_data, label, raw_prediction




def train_classifier(
    data_config,
    attack_name = attack_name,
):

    # class_thred_logics = load_class_filter_logics(
    #     "logic_filter",
    # )
    class_thred_logics = None
    train_data, train_label, _ = load_logic_data(
        class_thred_logics,
        "train",
        train_images_per_class,
        data_config,
        "original",
    )
    
    clf=tree.DecisionTreeClassifier(
        max_depth = 10,
        min_samples_leaf = 2,
    )
    # clf = RandomForestClassifier(
    #
    # )
    clf = clf.fit(train_data, train_label)
    train_prediction = clf.predict(train_data)
    acc = (train_prediction == train_label).sum() / len(train_label)
    print(f"Train acc: {acc}")

    test_data, test_label, _ = load_logic_data(
        class_thred_logics,
        "test",
        test_images_per_class,
        data_config,
        "original",
    )
    test_prediction = clf.predict(test_data)
    acc = (test_prediction == test_label).sum() / len(test_label)
    fpr = 1 - acc

    test_adversarial_data, test_adversarial_label, test_adversarial_pred = load_logic_data(
        class_thred_logics,
        "test",
        test_images_per_class,
        data_config,
        attack_name,
    )
    test_adversarial_prediction = clf.predict(test_adversarial_data)
    tpr = ( (test_adversarial_prediction != test_adversarial_pred).sum() /
            len(test_adversarial_prediction) )
    roc_tpr = [0, tpr, 1]
    roc_fpr = [0, fpr, 1]
    roc_auc = metrics.auc(roc_fpr, roc_tpr)

    print(f"Auc: {roc_auc:.2f}, tpr: {tpr:.2f}, "
        f"fpr: {fpr:.2f}, acc: {acc:.2f}")

    result = {
        "config": data_config,
        "clf": clf,
        "tpr": tpr,
        "fpr": fpr,
        "auc": roc_auc,
        "acc": acc,
    }
    save_path = os.path.join(
        clf_dir,
        "clf.pkl"
    )
    ensure_dir(save_path)
    with open(save_path, "wb") as f:
        pickle.dump(result, f)


    return clf, test_prediction, test_label


def train_classifier_exp():
    data_config = [
        [TraceKey.POINT, available_logic_names[0], point_keys],
        # [TraceKey.POINT, available_logic_names[1], point_keys],
        # [TraceKey.POINT, available_logic_names[2], point_keys],
        # [TraceKey.WEIGHT, available_logic_names[0], weight_keys],
    ]
    clf, prediction, label = train_classifier(
        data_config = data_config,
    )


def train_classifier_bagging():
    predictions = []
    test_label = []
    for logic_name in available_logic_names:
        clf, prediction, label = train_classifier(
            logic_name,
            point_keys[1],
        )
        predictions.append(prediction)
        test_label.append(label)

    # label = test_label[0]
    # correct = []
    # for prediction in predictions:
    #     correct.append(
    #         (prediction == label).astype(np.uint8)
    #     )
    # correct = np.array(correct)
    # correct = correct.sum(0)
    # vote = correct >= 2
    # acc = vote.sum() / len(vote)
    # print(f"Adaboost acc: {acc}")

if __name__=="__main__":
    mode.debug()
    # mode.local()

    # ray_init("gpu")
    ray_init(
        log_to_driver=False,
        # num_cpus = 10,
    )

    tf.set_random_seed(3)
    np.random.seed(3)
    random.seed(3)

    train_classifier_exp()
