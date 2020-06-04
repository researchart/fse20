import csv
import random
from functools import partial
from typing import Callable, Optional
from pdb import set_trace as st
import os, sys
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
model_label = "dropout"
model_dir = f"result/resnet10cifar10/model_{model_label}"


# path config
# pos and neg
per_image_trace_dir = f"{model_dir}/nninst_mu_posneg/per_image_trace_0.5_sum0.2_bar0.01"
logic_dir = f"{model_dir}/nninst_mu_posneg/posneg_edge_{threshold}"
reconstruct_from_trace_fn = reconstruct_point_from_trace_contrib

# only pos, raw method
# per_image_trace_dir = f"{model_dir}/nninst_mu_posneg/per_image_trace_0.5_posonly"
# logic_dir = f"{model_dir}/nninst_mu_posneg/posonly_edge_0.5"
# reconstruct_from_trace_fn = reconstruct_point_from_trace


clf_dir = f"{logic_dir}/clf"
train_images_per_class = 1000
logic_filter_thred_ratio = 0.01
test_images_per_class = 50
attack_name = "FGSM"

adversarial_label = 1
original_label = -1


weight_keys = [
    "conv2d/Conv2D",
    "conv2d_1/Conv2D",
]

exp_target_layers = [

    ['conv2d_11'], 
    ['conv2d_12'], 

]
def load_logic_data(
    class_thred_logics,
    dataset_split,
    images_per_class,
    data_config,
    target_layers,
    attack_name = "original",
):

    def filter_logic_by_class_thred(
        target_logic,
        class_logic,
    ):
        filtered_logic = {}
        for key in target_logic.keys():
            target_mask = target_logic[key].to_tensor()
            class_mask = class_logic[key].to_tensor()
            class_mask = class_mask.astype(np.bool)
            filtered_target = target_mask[class_mask]
            # filtered_target = target_mask.flatten()
            filtered_logic[key] = filtered_target
            # print(key, target_mask.shape, filtered_target.shape)
        return filtered_logic
    
    def filter_logic_by_name(
        target_logic,
    ):
        filtered_logic = {}
        for key in target_logic.keys():
            # if key.find('block_layer4') != -1:
            if key in target_layers:
                target_mask = target_logic[key].to_tensor()
                filtered_logic[key] = target_mask
        return filtered_logic

    def load_logic_data_per_image_config(
        config,
        class_id,
        image_id,
    ):
        trace_key, logic_name = config
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
        
        if len(logic) < 14:
            return {}
        filtered_logic = filter_logic_by_name(
            logic,
        )
        
        filtered_logic = [data for data in filtered_logic.values() 
                        if data is not None]
        if len(filtered_logic) != len(target_layers):
            return {}

        logic_data = [data.flatten() for data in filtered_logic]

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
    target_layers,
):
    data_config = [[TraceKey.WEIGHT, "unary"]]
    
    # class_thred_logics = load_class_filter_logics(
    #     "logic_filter",
    # )
    class_thred_logics = None
    
    train_data, train_label, _ = load_logic_data(
        class_thred_logics,
        "train",
        train_images_per_class,
        data_config,
        target_layers,
        "original",
    )
    test_data, test_label, _ = load_logic_data(
        class_thred_logics,
        "test",
        test_images_per_class,
        data_config,
        target_layers,
        "original",
    )

    clf=tree.DecisionTreeClassifier(
        # max_depth = 40,
        # min_samples_leaf = 2,
    )

    clf = clf.fit(train_data, train_label)
    train_prediction = clf.predict(train_data)
    acc = (train_prediction == train_label).sum() / len(train_label)

    test_prediction = clf.predict(test_data)
    test_original_acc = (test_prediction == test_label).sum() / len(test_label)
    print(f"Train acc: {acc:.2f}, clean test acc: {test_original_acc:.2f}")

    results = {
        "clf": clf,
        "train_acc": acc,
        "clean_test_acc": test_original_acc,
        "detection": [],
    }
    for attack_name in [
        "FGSM_2", "FGSM_4", "FGSM_8",
        "DeepFoolLinf", "DeepFoolL2",
        "JSMA",
        "RPGD_2", "RPGD_4", "RPGD_8",
        "CWL2", "ADef",
        "SinglePixel", "LocalSearch",
        "Boundary", "Spatial", "Pointwise", "GaussianBlur",
    ]:
        test_adversarial_data, test_adversarial_label, test_adversarial_pred = load_logic_data(
            class_thred_logics,
            "test",
            test_images_per_class,
            data_config,
            target_layers,
            attack_name,
        )
        test_adversarial_prediction = clf.predict(test_adversarial_data)
        test_adversarial_acc = ( (test_adversarial_prediction == test_adversarial_label).sum()
                                / len(test_adversarial_label) )
        
        detection_label = np.concatenate((
            np.zeros(test_label.shape[0]),
            np.zeros(test_adversarial_label.shape[0]) + 1
        )).astype(np.int8)
        detection_pred = np.concatenate((
            test_prediction != test_label,
            test_adversarial_prediction != test_adversarial_pred,
        )).astype(np.int8)
        
        true_positive = ( (detection_label == detection_pred) * (1 == detection_label) )
        recall = true_positive.sum() / detection_label.sum()
        precision = true_positive.sum() / detection_pred.sum()
        f1 = 2*precision*recall / (precision + recall)
        
        print(f"{attack_name}: f1={f1:.2f}, recall={recall:.2f}, precision={precision:.2f}")


        results["detection"].append({
            "adv_test_acc": round(test_adversarial_acc, 3),
            "f1": round(f1, 3),
            "recall": round(recall, 3),
            "precision": round(precision, 3),
            "attack": attack_name,
        })
        
    save_dir = os.path.join(
        logic_dir,
        "clf_2", 
        target_layers[0],
    )
    os.makedirs(save_dir, exist_ok=True)
    detection = results["detection"]
    detection = pd.DataFrame(detection)
    detection_path = os.path.join(
        save_dir, "detection.csv"
    )
    detection.to_csv(detection_path)
    
    save_path = os.path.join(
        save_dir,
        f"clf.pkl"
    )
    ensure_dir(save_path)
    with open(save_path, "wb") as f:
        pickle.dump(results, f)


    return clf, test_prediction, test_label


if __name__=="__main__":
    mode.debug()
    # mode.local()

    # ray_init("gpu")
    ray_init(
        # log_to_driver=False,
        # num_cpus = 10,
    )

    tf.set_random_seed(3)
    np.random.seed(3)
    random.seed(3)

    output_path = os.path.join(logic_dir, "layer_exp.txt")
    output_file = open(output_path, 'w')
    # sys.stdout = output_file
    for target_layers in exp_target_layers:
        print(f"="*10, target_layers, f"="*10)
        clf, prediction, label = train_classifier(target_layers)
        print()
