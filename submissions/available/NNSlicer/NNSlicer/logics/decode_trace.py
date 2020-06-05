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

threshold = 0.9
dilation_iter = 1
dilation_structure = ndimage.generate_binary_structure(2, 2)
# Model config
model_label = "augmentation"
model_dir = f"result/lenet/model_{model_label}"
# Trace config
trace_dir =  f"{model_dir}/traces_{threshold}"
trace_name = "noop"
training_trace_dir = f"{model_dir}/per_image_trace_{threshold}/train"
# Result dir
result_name = "test"

result_dir = f"{model_dir}/birelation/{threshold}_{dilation_iter}"
# result_dir = f"result/lenet/test"
images_per_class = 1000
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

overlap_fn = calc_trace_side_overlap
per_channel = False

lenet_mnist_class_trace = class_trace(
                            trace_name,
                            model_config=LENET,
                            data_config=data_config,
                        )

graph = LENET.network_class.graph().load()


def reconstruct_edge_from_trace(
    trace,
    graph,
    node_name,
    key = TraceKey.EDGE,
):
    attrs = trace.nodes[node_name]
    op = graph.op(graph.id(node_name))
    if key not in attrs:
        return None
    else:
        attr = attrs[key]
        edge = TraceKey.to_array(attr)
        return edge


def reconstruct_point_from_trace_contrib(
    trace,
    graph,
    node_name,
    key = TraceKey.POINT,
):

    attrs = trace.nodes[node_name]

    def to_bitmap(shape, attr, contrib):
        mask = np.zeros(np.prod(shape), dtype=np.int8)
        pos_attr = attr[contrib > 0]
        mask[TraceKey.to_array(pos_attr)] = 1
        neg_attr = attr[contrib < 0]
        mask[TraceKey.to_array(neg_attr)] = -1
        return mask.reshape(shape)

    if key in attrs:
        return to_bitmap(attrs[key + "_shape"], attrs[key], attrs[TraceKey.POINT_CONTRIB])
    else:
        for attr_name, attr in attrs.items():
            if attr_name.startswith(TraceKey.POINT + ".") and attr is not None:
                return to_bitmap(attrs[TraceKey.POINT_SHAPE], attr)
        RuntimeError(f"Point key not found in {node_name}")

def reconstruct_point_from_trace(
    trace,
    graph,
    node_name,
    key = TraceKey.POINT,
):

    attrs = trace.nodes[node_name]

    def to_bitmap(shape, attr):
        mask = np.zeros(np.prod(shape), dtype=np.int8)
        mask[TraceKey.to_array(attr)] = 1
        return mask.reshape(shape)

    if key in attrs:
        return to_bitmap(attrs[key + "_shape"], attrs[key])
    else:
        for attr_name, attr in attrs.items():
            if attr_name.startswith(TraceKey.POINT + ".") and attr is not None:
                return to_bitmap(attrs[TraceKey.POINT_SHAPE], attr)
        RuntimeError(f"Point key not found in {node_name}")

def reconstruct_weight_from_trace_contrib(
    trace,
    graph,
    node_name,
    key = TraceKey.WEIGHT,
):
    attrs = trace.nodes[node_name]
    def to_bitmap(shape, attr, contrib):
        mask = np.zeros(np.prod(shape), dtype=np.int8)
        mask[TraceKey.to_array(attr)] = contrib
        return mask.reshape(shape)
    
    if key in attrs:
        return to_bitmap(attrs[key + "_shape"], attrs[key], attrs[TraceKey.WEIGHT_CONTRIB])
    else:
        RuntimeError(f"Weight key not found in {node_name}")

def reconstruct_weight_from_trace(
    trace,
    graph,
    node_name,
    key = TraceKey.WEIGHT,
):
    attrs = trace.nodes[node_name]
    def to_bitmap(shape, attr):
        mask = np.zeros(np.prod(shape), dtype=np.int8)
        mask[TraceKey.to_array(attr)] = 1
        return mask.reshape(shape)
    if key in attrs:
        return to_bitmap(attrs[key + "_shape"], attrs[key])
    else:
        RuntimeError(f"Weight key not found in {node_name}")


def reconstruct_point_fn(
    trace,
):
    node_names = []
    key = TraceKey.POINT
    for attr_name, attr in trace.nodes.items():
        if key in attr:
            node_names.append(attr_name)
    point_dict = {}
    for node_name in [
        "conv2d/Relu:0",
        "conv2d_1/Relu:0",
        "dense/BiasAdd:0",
        "dense_1/BiasAdd:0",
    ]:
        point_dict[node_name] = reconstruct_point_from_trace(
            trace,
            graph,
            node_name,
        )
        # print(node_name, point_dict[node_name].shape)
    return point_dict

def reconstruct_weight_fn(
    trace,
):
    weight_dict = {}
    for node_name in [
        "conv2d/Conv2D",
        "conv2d_1/Conv2D",
    ]:
        weight = reconstruct_weight_from_trace(
            trace,
            graph,
            node_name,
        )
        weight = weight.reshape(-1, weight.shape[-2], weight.shape[-1])
        weight_dict[node_name] = weight
    return weight_dict

reconstruct_edge_fn = partial(
    reconstruct_edge_from_trace,
    graph = graph,
    key = TraceKey.EDGE
)
