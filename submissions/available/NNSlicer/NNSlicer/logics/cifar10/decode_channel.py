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
per_image_trace_dir = f"{model_dir}/per_image_trace_{threshold}"

logic_dir = f"{model_dir}/nninst_mu_posneg/logics_{threshold}"
train_images_per_class = 1000
logic_filter_thred_ratio = 0.1
# test_images_per_class = 500
attack_name = "FGSM"

attacks = {
    "FGSM": [FGSM],
    "BIM": [IterativeGradientSignAttack],
    "JSMA": [SaliencyMapAttack],
    "DeepFool": [DeepFoolAttack],
    # "DeepFool_full": [DeepFoolAttack, dict(subsample=None)],
    # "CWL2": [CarliniL2],
}

logic_filter_thred = {
    "unary": 0.1,
    "binary": 0.1,
    "triadic": 0.05,
}

valid_layers = [
    "conv2d_4",
    "conv2d_7",
    "conv2d_8",
    "conv2d_9",
    "conv2d_11",
    "conv2d_12",
]

def print_logic_per_class(logics):
    for key in valid_layers:
        print(f"{key}: {logics[key].pos_index[0]}")


def count_logics(
    logic_name="unary",
    logic_fn=channel_activation,
    trace_key=TraceKey.POINT,
):
    def load_logics(
        class_id,
        image_id,
        transform_name = "noop",
    ):
        dataset_split = "train"
        path = logic_save_path(
            logic_dir,
            trace_key,
            logic_name,
            dataset_split,
            "original",
            transform_name,
            class_id,
            image_id,
        )
        if not os.path.exists(path):
            return {}
        with open(path, "rb") as f:
            logics = pickle.load(f)
        return logics

    def logic_plot_hist_save(
        logics,
        filter_count,
    ):
        thred_filter = (logics > filter_count).astype(np.uint8)
        sparse_thred_filter = SparseMask(thred_filter)

        nonzero_filter = (logics > 0).astype(np.uint8)
        sparse_nonzero_filter = SparseMask(nonzero_filter)

        return sparse_thred_filter, sparse_nonzero_filter

    node_to_logics = {}
    for class_id in range(10):
        params = [
            (
                class_id,
                image_id,
            )
            for image_id in range(train_images_per_class)
        ]
        results = ray_iter(
            load_logics,
            params,
            chunksize=1,
            out_of_order=True,
            huge_task=True,
        )
        results = [result for result in results if len(result)>0]
        
        thred_filter_per_class = {}
        for node_name in results[0].keys():
            shape = results[0][node_name].shape
            logics_acc = np.zeros(shape)
            for result in results:
                logic = result[node_name].to_tensor()
                logics_acc += abs(logic)
            if class_id==0:
                node_to_logics[node_name] = logics_acc.copy()
            else:
                node_to_logics[node_name] += logics_acc

            name = f"{class_id}/{node_name.split(':')[0].split('/')[0]}"

            filter_count = (logic_filter_thred[logic_name] *
                            train_images_per_class)
            
            sparse_thred_filter, _ = logic_plot_hist_save(
                logics_acc,
                filter_count,
            )
            thred_filter_per_class[node_name] = sparse_thred_filter
        print(f"{class_id}")
        print_logic_per_class(thred_filter_per_class)


    thred_filter_all = {}
    nonzero_filter_all = {}
    for node_name in results[0].keys():
        filter_count = (logic_filter_thred[logic_name] * 10 *
                        train_images_per_class)
        dataset_logics = node_to_logics[node_name]
        sparse_thred_filter, sparse_nonzero_filter = logic_plot_hist_save(
            dataset_logics,
            filter_count,
        )
        thred_filter_all[node_name] = sparse_thred_filter
        nonzero_filter_all[node_name] = sparse_nonzero_filter
    print(f"all")
    print_logic_per_class(thred_filter_all)


def count_logics_exp():

    count_logics()

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

    count_logics_exp()
