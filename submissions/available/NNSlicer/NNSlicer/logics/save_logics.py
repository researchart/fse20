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

threshold = 0.9
dilation_iter = 1
dilation_structure = ndimage.generate_binary_structure(2, 2)
# Model config
model_label = "augmentation"
model_dir = f"result/lenet/model_{model_label}"
# Trace config
per_image_trace_dir = (f"{model_dir}/nninst_mu_posneg/"
                    f"per_image_trace_{threshold}_sum0.1")
# Result dir
result_dir = f"{model_dir}/nninst_mu_posneg/logics_{threshold}"
# result_dir = f"result/lenet/test"
train_images_per_class = 1000
test_images_per_class = 100
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

def compute_logics(
    logic_name,
    logic_fn,
    trace_key,
):
    if trace_key == TraceKey.POINT:
        reconstruct_fn = reconstruct_point_fn
    elif trace_key == TraceKey.WEIGHT:
        reconstruct_fn = reconstruct_weight_fn

    def save_logic_per_image(
        class_id,
        image_id,
        transform_name = "noop",
        save_adversarial = True,
        dataset_split="train",
    ):
        original_path = image_trace_path(
            per_image_trace_dir,
            dataset_split,
            "original",
            transform_name,
            class_id,
            image_id,
        )
        adversarial_path = image_trace_path(
            per_image_trace_dir,
            dataset_split,
            attack_name,
            transform_name,
            class_id,
            image_id,
        )
        
        if not os.path.exists(original_path) or \
            (save_adversarial and not os.path.exists(adversarial_path)):
            return {}

        with open(original_path, "rb") as f:
            original_trace = pickle.load(f)

        original_masks = reconstruct_fn(original_trace)
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
        
        if save_adversarial:
            with open(adversarial_path, "rb") as f:
                adversarial_trace = pickle.load(f)
            adversarial_masks = reconstruct_fn(adversarial_trace)
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
        dataset_split="test",
        save_adversarial=True,
        images_per_class=test_images_per_class,
    ):
        save_fn = partial(
            save_logic_per_image,
            dataset_split=dataset_split,
            save_adversarial=save_adversarial,
        )
        params = [
            (
                class_id,
                image_id,
            )
            for class_id in range(10)
            for image_id in range(images_per_class)
        ]
        results = ray_iter(
            save_fn,
            params,
            chunksize=1,
            out_of_order=True,
            huge_task=True,
        )
        results = [result for result in results]

    ray_compute(
        "train",
        False,
        train_images_per_class,
    )
    ray_compute(
        "test",
        True,
        test_images_per_class,
    )

def save_logics_exp():
    for trace_key in [
        TraceKey.POINT,
    ]:
        for name, logic_fn in [
            ("unary", channel_activation),
            # ("binary", intro_binary_logic),
            # ("triadic", intro_triadic_logic),
        ]:
            compute_logics(
                name,
                logic_fn,
                trace_key,
            )

if __name__=="__main__":
    # mode.debug()
    mode.local()

    # ray_init("gpu")
    ray_init(
        log_to_driver=False,
        # num_cpus = 10,
    )

    tf.set_random_seed(3)
    np.random.seed(3)
    random.seed(3)

    save_logics_exp()
