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

threshold = 0.9
dilation_iter = 1
dilation_structure = ndimage.generate_binary_structure(2, 2)
# Model config
model_label = "dropout"
model_dir = f"result/resnet10cifar10/model_{model_label}"
# Trace config
trace_dir =  f"{model_dir}/traces_{threshold}"
trace_name = "noop"
per_image_trace_dir = f"{model_dir}/nninst_mu/per_image_trace_{threshold}"

logic_dir = f"{model_dir}/nninst_mu_posneg/logics_{threshold}"
train_images_per_class = 1000
logic_filter_thred_ratio = 0.01
test_images_per_class = 5
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

lenet_mnist_class_trace = class_trace(
                            trace_name,
                            model_config=LENET,
                            data_config=data_config,
                        )

graph = LENET.network_class.graph().load()

available_logic_names = [
    "unary",
    # "binary",
    # "triadic",
]

def load_class_filter_logics(
    filter_name,
):

    def load_class_filter_logics_per_trace_key(
        filter_name,
        trace_key,
        logic_names,
    ):
        assert isinstance(logic_names, list)
        # filter_name is "nonzero_filter" or "logic_filter"
        class_id_range = list(range(10))
        class_id_range.append("all")
        class_load_logics = {}
        for class_id in class_id_range:
            logics_per_class = {}
            for logic_name in logic_names:
                path = os.path.join(
                    logic_dir,
                    trace_key,
                    logic_name,
                    filter_name,
                    f"{class_id}.pkl",
                )
                with open(path, "rb") as f:
                    logic = pickle.load(f)
                logics_per_class[logic_name] = logic
            class_load_logics[class_id] = logics_per_class
        return class_load_logics

    class_logics = {}

    class_logics[TraceKey.POINT] = load_class_filter_logics_per_trace_key(
        filter_name,
        TraceKey.POINT,
        available_logic_names,
    )
    # class_logics[TraceKey.WEIGHT] = load_class_filter_logics_per_trace_key(
    #     filter_name,
    #     TraceKey.WEIGHT,
    #     ["unary"],
    # )
    return class_logics

def predict_by_nonzero_filter(
    target_logics,
    class_logics,
):
    for logic_name in available_logic_names:
        target_logic = target_logics[logic_name]
        class_logic = class_logics[logic_name]
        assert target_logic.keys() == class_logic.keys()
        for key in target_logic:
            target_layer_logic = target_logic[key].to_tensor()
            class_layer_logic = class_logic[key].to_tensor()
            class_zero_mask = (class_layer_logic == 0)
            target_invalid_sum = target_layer_logic[class_zero_mask].sum()
            if target_invalid_sum > 0:
                return adversarial_label
    return original_label

def load_raw_prediction(
    class_id,
    image_id,
    dataset_split,
    attack_name,
):
    path = image_trace_path(
        per_image_trace_dir,
        dataset_split,
        attack_name,
        "noop",
        class_id,
        image_id,
    )
    if not os.path.exists(path):
        return -1
    with open(path, "rb") as f:
        trace = pickle.load(f)
    return trace.attrs[GraphAttrKey.PREDICT]

def evaluate_by_NOT(
    attack_name,
):
    class_nonzero_logics = load_class_filter_logics(
        "nonzero_filter",
    )
    def load_per_image_logics(
        class_id,
        image_id,
        attack_name,
    ):
        per_image_logics = {}
        for logic_name in available_logic_names:
            path = logic_save_path(
                logic_dir,
                logic_name,
                "test",
                attack_name,
                "noop",
                class_id,
                image_id,
            )
            if not os.path.exists(path):
                return {}
            with open(path, "rb") as f:
                per_image_logics[logic_name] = pickle.load(f)
        return per_image_logics



    def count_adversarial_logic_difference(
        original_logics,
        adversarial_logics,
    ):
        logic_diff = {}
        for logic_name in available_logic_names:
            original_per_logic = original_logics[logic_name]
            adversarial_per_logic = adversarial_logics[logic_name]
            for key in original_per_logic:
                original = original_per_logic[key].to_tensor()
                adversarial = adversarial_per_logic[key].to_tensor()
                diff = (original != adversarial).sum()
                logic_diff[f"{logic_name}.{key}"] = diff
        return logic_diff

    def eval_per_image(
        class_id,
        image_id,
    ):
        original_logics = load_per_image_logics(
            class_id,
            image_id,
            "original"
        )
        original_pred = load_raw_prediction(
            class_id,
            image_id,
            "test",
            "original",
        )
        adversarial_logics = load_per_image_logics(
            class_id,
            image_id,
            attack_name,
        )
        adversarial_pred = load_raw_prediction(
            class_id,
            image_id,
            "test",
            attack_name
        )
        if (len(original_logics) == 0 or
            original_pred == -1 or
            len(adversarial_logics) == 0 or
            adversarial_pred == -1):
            return {}

        logic_difference = count_adversarial_logic_difference(
            original_logics,
            adversarial_logics,
        )

        original_detection_label = predict_by_nonzero_filter(
            original_logics,
            class_nonzero_logics[original_pred],
        )
        adversarial_detection_label = predict_by_nonzero_filter(
            adversarial_logics,
            class_nonzero_logics[adversarial_pred],
        )
        info = {
            "class_id": class_id,
            "imageid": image_id,
            "original.prediction": original_pred,
            "adversarial.prediction": adversarial_pred,
            "original.detection": original_detection_label,
            "adversarial.detection": adversarial_detection_label,
        }
        info.update(logic_difference)
        return info

    results = ray_iter(
        eval_per_image,
        [
            (class_id, image_id)
            for class_id in range(10)
            for image_id in range(test_images_per_class)
        ],
        chunksize=1,
        out_of_order=True,
        huge_task=True,
    )
    results = [result for result in results if len(result) > 0]
    results = pd.DataFrame(results)
    st()


def evaluate_by_logics_exp():
    evaluate_attack(
        attack_name
    )

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

    evaluate_by_logics_exp()
