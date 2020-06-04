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
batch_size = 1000

    
attacks = {
    "original": [FGSM],
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


# Compute the mean overlap ratio of attacked image
def predict_original_adversarial(
    attack_name: str,
    attack_fn,
    generate_adversarial_fn,
    image_id_index,
    batch_size,
    class_id,
    model_dir = model_dir,
    transforms = None,
    transform_name = "noop",
    graph_dir = "result/test",
    dataset_mode = dataset_mode,
    images_per_class = 1,
    **kwargs,
):
    
    # mode.check(False)
    data_dir = abspath(CIFAR10_PATH)
    model_dir = abspath(model_dir)
    ckpt_dir = f"{model_dir}/ckpts"
    create_model = lambda: partial(
        ResNet10Cifar10(),
        training = False,
    )
    graph = ResNet10Cifar10.graph().load()
    
    batch_size = min(batch_size, images_per_class - image_id_index)
    
    predicted_label = predict_batch(
        create_model=create_model,
        input_fn=lambda: (
            input_fn_for_adversarial_examples(
                is_training= (dataset_mode == "train"),
                data_dir=data_dir,
                num_parallel_batches=1,
                is_shuffle=False,
                transform_fn=None,
            )
            .filter(
                lambda image, label: tf.equal(
                    tf.convert_to_tensor(class_id, dtype=tf.int32), label
                )
            )
            .skip(image_id_index)
            .take(batch_size)
            .batch(batch_size)
            .make_one_shot_iterator()
            .get_next()[0]
        ),
        model_dir=ckpt_dir,
    )
    
    # The shape of each example is (1, 32, 32, 3)
    adversarial_examples = [resnet10_cifar10_example(
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
        for image_id in range(image_id_index, image_id_index + batch_size)
    ]

    adversarial_valid = np.array([
        example is not None
        for example in adversarial_examples
    ])
    adversarial_examples = [
        example if example is not None else np.zeros((1, 32, 32, 3))
        for example in adversarial_examples
    ]
    adversarial_examples = np.squeeze(
        np.array(
            adversarial_examples
        ).astype(np.float32)
        , axis=1
    )
    
    # adversarial_example is [0, 1] of shape (1, 32, 32, 3)
    adversarial_predicted_label = predict_batch(
        create_model=create_model,
        input_fn=lambda: tf.data.Dataset.from_tensors(
            adversarial_examples
        ),
        model_dir=ckpt_dir,
    )
    
    assert predicted_label.shape == adversarial_predicted_label.shape
    original_correct = (predicted_label[adversarial_valid] == class_id).sum()
    adversarial_correct = (adversarial_predicted_label[adversarial_valid] == class_num).sum()
    valid_count = adversarial_valid.sum()
    
    return original_correct, adversarial_correct, valid_count
    


def save_training_trace(
    attack_name,
    images_per_class,
    batch_size,
    dataset_mode,
    cpu_chunksize = 1,
    use_class_trace = False,
    class_dir = None,
):
    original_cnt, adversarial_cnt, valid_cnt = 0, 0, 0
    for class_id in range(class_num):
        for image_id_index in range(0, images_per_class, batch_size):
            original_correct, adversarial_correct, valid = predict_original_adversarial(
                attack_name=attack_name,
                attack_fn=attacks[attack_name][0],
                generate_adversarial_fn=cw_generate_adversarial_example
                if attack_name.startswith("CW")
                else foolbox_generate_adversarial_example,
                image_id_index=image_id_index,
                batch_size=batch_size,
                class_id=class_id,
                preprocessing=(0, 1),
                image_size=32,
                class_num=10,
                data_format="channels_first",
                **(attacks[attack_name][1] if len(attacks[attack_name]) == 2 else {}),
                model_dir=model_dir,
                dataset_mode = dataset_mode,
                images_per_class=images_per_class,
            )
            original_cnt += original_correct
            adversarial_cnt += adversarial_correct
            valid_cnt += valid
            
    original_acc = original_cnt / valid_cnt
    adversarial_acc = adversarial_cnt / valid_cnt
    
    print(f"{attack_name}: acc={original_acc:.2f}({original_cnt}/{valid_cnt}), "
        f"adv acc={adversarial_acc:.2f}({adversarial_cnt}/{valid_cnt})")
            

debug = False


def save_class_avg_trace():
    
    cpu_chunksize = 1
    batch_size = 100
        
    for attack_name in [
        "original",
        # "FGSM_1", "FGSM_2", "FGSM_4", "FGSM_8",
        # "DeepFoolLinf", "DeepFoolL2",
        # "JSMA",
        # "BIM_2", "BIM_4", "BIM_8",
        # "RPGD_2", "RPGD_4", "RPGD_8",
        # "CWL2", "ADef",
        # "SinglePixel", "LocalSearch",
        # "Boundary", "Spatial", "Pointwise", "GaussianBlur",
    ]:
        save_training_trace(
            attack_name = attack_name,
            images_per_class=images_per_class,
            batch_size=batch_size,
            dataset_mode=dataset_mode,
            cpu_chunksize=cpu_chunksize,
        )
        

if __name__=="__main__":
    tf.set_random_seed(3)
    np.random.seed(3)
    random.seed(3)

    if debug:
        mode.debug()
    else:
        mode.local()

    # ray_init("gpu")
    ray_init(
        log_to_driver=False
    )
    
    save_class_avg_trace()
