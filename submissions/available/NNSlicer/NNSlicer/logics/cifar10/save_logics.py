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
from model.resnet10cifar10 import ResNet10Cifar10
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

threshold = 0.9
dilation_iter = 1
dilation_structure = ndimage.generate_binary_structure(2, 2)
# Model config
model_label = "dropout"
model_dir = f"result/resnet10cifar10/model_{model_label}"
# Trace config
trace_dir =  f"{model_dir}/traces_{threshold}"

# path config
# pos and neg
per_image_trace_dir = f"{model_dir}/nninst_mu_posneg/per_image_trace_0.5_sum0.2_bar0.01"
result_dir = f"{model_dir}/nninst_mu_posneg/posneg_full_logics_{threshold}"
reconstruct_from_trace_fn = reconstruct_point_from_trace_contrib
mask_to_logic_fn = posneg_channel_activation

# only pos, raw method
# per_image_trace_dir = f"{model_dir}/nninst_mu_posneg/per_image_trace_0.5_posonly"
# result_dir = f"{model_dir}/nninst_mu_posneg/posonly_logics_{threshold}"
# reconstruct_from_trace_fn = reconstruct_point_from_trace
# mask_to_logic_fn = pos_channel_activation


train_images_per_class = 1000
test_images_per_class = 50
chunksize = 10
attack_name = "FGSM"

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

graph = ResNet10Cifar10.graph().load()

def logic_save_path(
    root_dir,
    trace_key,
    logic_name,
    dataset_split,
    attack_name,
    transform_name,
    class_id,
    image_id,
):
    path = os.path.join(
        root_dir,
        f"{trace_key}",
        f"{logic_name}",
        f"{dataset_split}",
        f"{attack_name}_{transform_name}",
        f"{class_id}",
        f"{image_id}.pkl"
    )
    return path

def image_trace_path(
    trace_dir,
    dataset_split,
    attack_name,
    transform_name,
    class_id,
    image_id,
):
    path = os.path.join(
        f"{trace_dir}",
        f"{dataset_split}",
        f"{attack_name}_{transform_name}",
        f"{class_id}",
        f"{image_id}.pkl",
    )
    return path

def reconstruct_point_fn(
    trace,
    valid_names,
):
    node_names = []
    key = TraceKey.POINT
    for attr_name, attr in trace.nodes.items():
        if key in attr:
            node_names.append(attr_name)
    point_dict = {}
    for node_name in valid_names:
        filtered_name = node_name.split(':')[0].split('/')[0]
        # if filtered_name == "final_dense":
        #     st()
        
        point_dict[filtered_name] = reconstruct_from_trace_fn(
            trace,
            graph,
            node_name,
        )
        # print(node_name, point_dict[node_name].shape)
    return point_dict

def filter_valid_names(trace):
    point_trace = {}
    for attr_name, attr in trace.nodes.items():
        if TraceKey.POINT in attr:
            point_trace[attr_name] = attr
    point_names = set(point_trace.keys())
    valid_names = []
    valid_names += [
        name for name in point_trace.keys() if name.find('Relu') != -1
    ]
    valid_names += [
        name for name in point_trace.keys() if name.find('conv') != -1
    ]
    valid_names += [
        name for name in point_trace.keys() if name.find('batch_normalization') != -1
    ]
    valid_names += [
        name for name in point_trace.keys() if name.find('block_layer') != -1
    ]
    valid_names += [
        name for name in point_trace.keys() if name.find('add') != -1
    ]
    # valid_names += [
    #     name for name in point_trace.keys() if name.find('dense') != -1
    # ]
    point_names -= set(valid_names)
    return valid_names


def compute_logics(
    logic_name,
    logic_fn,
    trace_key,
):
    if trace_key == TraceKey.POINT:
        reconstruct_fn = reconstruct_point_fn
    elif trace_key == TraceKey.WEIGHT:
        reconstruct_fn = reconstruct_weight_fn


    def save_training_logics(
        class_id,
        image_id,
    ):
        dataset_split="train"
        transform_name = "noop"
        # print(f"Class {class_id} image {image_id}")
        original_path = image_trace_path(
            per_image_trace_dir,
            dataset_split,
            "original",
            transform_name,
            class_id,
            image_id,
        )
        
        if ( not os.path.exists(original_path)):
            return {}

        with open(original_path, "rb") as f:
            original_trace = pickle.load(f)
        if original_trace is None:
            st()
        valid_names = filter_valid_names(original_trace)
        original_masks = reconstruct_fn(
            original_trace,
            valid_names,
        )
        
        original_logics = logic_fn(original_masks)
        path = logic_save_path(
            result_dir,
            trace_key,
            logic_name,
            dataset_split,
            "original",
            transform_name,
            class_id,
            image_id,
        )
        
        ensure_dir(path)
        with open(path, "wb") as f:
            pickle.dump(original_logics, f)
        
        
    def save_test_logics(
        attack_name,
        class_id,
        image_id,
    ):
        transform_name = "noop"
        dataset_split="test"
        # print(f"Class {class_id} image {image_id}")

        adversarial_path = image_trace_path(
            per_image_trace_dir,
            dataset_split,
            attack_name,
            transform_name,
            class_id,
            image_id,
        )
        
        if (not os.path.exists(adversarial_path)):
            return {}


        with open(adversarial_path, "rb") as f:
            adversarial_trace = pickle.load(f)
        valid_names = filter_valid_names(adversarial_trace)
        adversarial_masks = reconstruct_fn(
            adversarial_trace,
            valid_names,
        )
        adversarial_logics = logic_fn(adversarial_masks)
        path = logic_save_path(
            result_dir,
            trace_key,
            logic_name,
            dataset_split,
            attack_name,
            transform_name,
            class_id,
            image_id,
        )
        ensure_dir(path)
        with open(path, "wb") as f:
            pickle.dump(adversarial_logics, f)
        
        
    def ray_compute(
        save_fn,
        params,
    ):
        
        print(chunksize, images_per_class)
        # results = ray_iter(
        #     save_fn,
        #     params,
        #     chunksize=chunksize,
        #     out_of_order=True,
        #     huge_task=True,
        # )
        # results = [result for result in results]
        for iter, param in enumerate(params):
            save_fn(*param)
            if iter % 100 ==0:
                print(f"{iter}/{len(params)}")

    # params = [
    #     (
    #         class_id,
    #         image_id,
    #     )
    #     for class_id in range(10)
    #     for image_id in range(train_images_per_class)
    # ]
    # ray_compute(
    #     save_training_logics,
    #     params
    # )
    # print("Finish train")
    
    
    for attack_name in [
        "original",
        "FGSM_2", "FGSM_4", "FGSM_8",
        "DeepFoolLinf", "DeepFoolL2",
        "JSMA",
        "RPGD_2", "RPGD_4", "RPGD_8",
        # "CWL2", "ADef",
        # "SinglePixel", "LocalSearch",
        # "Boundary", "Spatial", "Pointwise", "GaussianBlur",
    ]:

        params = [
            (
                attack_name,
                class_id,
                image_id,
            )
            for class_id in range(10)
            for image_id in range(test_images_per_class)
        ]
        ray_compute(
            save_test_logics,
            params
        )
        print(f"Finish test {attack_name}")

    
debug = False
if __name__=="__main__":

    tf.set_random_seed(3)
    np.random.seed(3)
    random.seed(3)
    
    if debug:
        mode.debug()
        train_images_per_class = 10
        test_images_per_class = 5
        chunksize = 1
    else:
        mode.local()

    # ray_init("gpu")
    ray_init(
        log_to_driver=False,
        num_cpus=10,
        # num_gpus=0,
    )


    compute_logics(
        logic_name="unary",
        logic_fn=mask_to_logic_fn,
        trace_key=TraceKey.POINT,
    )
