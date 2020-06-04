import csv
import random
from functools import partial
from typing import Callable, Optional
from pdb import set_trace as st
import os
import random
import pandas as pd
from typing import Any, Callable, Dict, Iterable, List, Tuple, Union
import datetime
import shutil
import copy

import numpy as np
import tensorflow as tf
from foolbox.attacks import (
    FGSM,
    DeepFoolAttack,
    DeepFoolLinfinityAttack,
    DeepFoolL2Attack,
    IterativeGradientSignAttack,
    SaliencyMapAttack,
    RandomPGD,
    CarliniWagnerL2Attack,
    ADefAttack,
    SinglePixelAttack,
    LocalSearchAttack,
    ApproximateLBFGSAttack,
    BoundaryAttack,
    SpatialAttack,
    PointwiseAttack,
    GaussianBlurAttack,
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
from dataset.config import MNIST_TRAIN, MNIST_PATH, CIFAR10_PATH
from dataset.cifar10_main import input_fn_for_adversarial_examples
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
from nninst_utils.numpy import arg_approx, arg_abs_approx
from nninst_utils.ray import ray_init
from nninst_utils.fs import (ensure_dir, IOAction, 
                            CsvIOAction, abspath, IOBatchAction,
                            IOObjAction)
from model.resnet10cifar10 import ResNet10Cifar10

from .common import get_overlay_summary, clean_overlap_ratio, \
                translation_overlap_ratio, attack_overlap_ratio, \
                resnet10_cifar10_example
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
    predict_batch,
    reconstruct_class_trace_from_tf,
    reconstruct_trace_from_tf,
    reconstruct_trace_from_tf_to_trace,
    reconstruct_trace_from_tf_brute_force,
)
from .analyse_class_trace import reconstruct_edge
from eval.lenetmnist_save_traces import ClassTraceIOAction

# Model config
model_label = "dropout"
model_dir = f"result/resnet10cifar10/model_{model_label}"

threshold = 0.5

dataset_mode = "test"
# result_dir = f"{model_dir}/per_image_trace_{threshold}/{dataset_mode}"
# result_dir = f"result/lenet/test"
class_num = 10
images_per_class = 100
chunksize = 1
attack_name = "FGSM"
batch_size = 1000

    
attacks = {
    "FGSM_1": [FGSM],
    "FGSM_2": [FGSM],
    "FGSM_4": [FGSM],
    "FGSM_8": [FGSM],
    
    "DeepFoolLinf": [DeepFoolLinfinityAttack],
    "DeepFoolL2": [DeepFoolL2Attack],
    
    "JSMA": [SaliencyMapAttack],
    
    "BIM_2": [IterativeGradientSignAttack],
    "BIM_4": [IterativeGradientSignAttack],
    "BIM_8": [IterativeGradientSignAttack],
    
    "RPGD_B": [RandomPGD],
    "RPGD_2": [RandomPGD],
    "RPGD_4": [RandomPGD],
    "RPGD_8": [RandomPGD],
    
    "CWL2": [CarliniWagnerL2Attack],
    "ADef": [ADefAttack],

    "SinglePixel": [SinglePixelAttack],
    "LocalSearch": [LocalSearchAttack],
    
    "Boundary": [BoundaryAttack],
    "Spatial": [SpatialAttack],
    "Pointwise": [PointwiseAttack],
    "GaussianBlur": [GaussianBlurAttack],
}

# DeepFool will shutdown when num_gpu<0.2
num_gpus = 0.5


def count_adv_per_attack(
    attack_name,
    images_per_class,
):
    generate_adversarial_fn=(cw_generate_adversarial_example
                if attack_name.startswith("CW")
                else foolbox_generate_adversarial_example)
    attack_fn=attacks[attack_name][0]
    transforms = None
    transform_name = "noop"
    
    valid_cnt = 0
    for class_id in range(class_num):
        for image_id in range(images_per_class):
            adv = resnet10_cifar10_example(
                attack_name=attack_name,
                attack_fn=attack_fn,
                generate_adversarial_fn=generate_adversarial_fn,
                class_id=class_id,
                image_id=image_id,
                # model_dir not ckpt_dir
                model_dir=model_dir,
                transforms = transforms,
                transform_name = transform_name,
                dataset_mode = dataset_mode,
            ).load()
            if adv is not None:
                valid_cnt += 1
    print(f"{attack_name}: valid number {valid_cnt}/{class_num*images_per_class}")

def count_valid_adv():
    
    cpu_chunksize = 1
    batch_size = 100
    
    
    for attack_name in [
        "FGSM_1", "FGSM_2", "FGSM_4", "FGSM_8",
        "DeepFoolLinf", "DeepFoolL2",
        "JSMA",
        "BIM_2", "BIM_4", "BIM_8",
        "RPGD_2", "RPGD_4", "RPGD_8",
        "CWL2", "ADef",
        "SinglePixel", "LocalSearch",
        "Boundary", "Spatial", "Pointwise", "GaussianBlur",
    ]:
        count_adv_per_attack(
            attack_name = attack_name,
            images_per_class=images_per_class,
        )
        
debug=True
if __name__=="__main__":
    tf.set_random_seed(3)
    np.random.seed(3)
    random.seed(3)

    
    count_valid_adv()
