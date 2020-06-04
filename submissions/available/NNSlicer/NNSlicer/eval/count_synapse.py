import csv
import random
from functools import partial
from typing import Callable, Optional
from pdb import set_trace as st
import os
import random
import pandas as pd
from typing import Any, Callable, Dict, Iterable, List, Tuple, Union
import time, datetime

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
from nninst_utils.fs import (ensure_dir, IOAction, CsvIOAction, abspath, 
                            IOBatchAction, IOObjAction)
from model.resnet18cifar10 import ResNet18Cifar10
from model.resnet10cifar10 import ResNet10Cifar10

from .common import get_overlay_summary, clean_overlap_ratio, \
                translation_overlap_ratio, attack_overlap_ratio, \
                resnet18_cifar10_example
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
    reconstruct_trace_from_tf_to_trace,
    reconstruct_trace_from_tf,
    reconstruct_trace_from_tf_brute_force,
)
from .analyse_class_trace import reconstruct_edge
from eval.lenetmnist_save_traces import ClassTraceIOAction

# Model config
model_label = "dropout"
model_dir = f"result/resnet18cifar10/model_{model_label}"
resnet18_dir = f"result/resnet18cifar10/model_{model_label}"
resnet10_dir = f"result/resnet10cifar10/model_{model_label}"

threshold = 0.9

dataset_mode = "test"
# result_dir = f"{model_dir}/per_image_trace_{threshold}/{dataset_mode}"
# result_dir = f"result/lenet/test"
class_num = 1
images_per_class = 1
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
num_gpus = 0.5

per_channel = False

use_class_trace = True
if use_class_trace:
    sum_precision_error = 0.2
    threshold_bar_ratio = 0.01
    select_fn = lambda input, output: arg_abs_approx(
        input, 
        output,
        sum_precision_error=sum_precision_error,
        threshold_bar_ratio=threshold_bar_ratio,
    )
else:
    select_fn = lambda input: arg_approx(input, threshold)
    

# Compute the mean overlap ratio of attacked image
def save_trace(
    class_id,
    image_id,
    select_fn: Callable[[np.ndarray], np.ndarray],
    class_dir,
    graph_dir,
    create_model,
    graph,
    per_node: bool = False,
    images_per_class: int = 1,
    num_gpus: float = 1,
    model_dir = resnet18_dir,
    transforms = None,
    transform_name = "noop",
    save_dir = "result/test",
    dataset_mode = dataset_mode,
    **kwargs,
):
    
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
            .skip(image_id)
            .take(1)
            .batch(1)
            .make_one_shot_iterator()
            .get_next()[0]
        )
    
    
    mode.check(False)
    data_dir = abspath(CIFAR10_PATH)
    model_dir = abspath(model_dir)
    ckpt_dir = f"{model_dir}/ckpts"
    
    
    start = time.clock()
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
            .skip(image_id)
            .take(1)
            .batch(1)
            .make_one_shot_iterator()
            .get_next()[0]
        ),
        model_dir=ckpt_dir,
    )
    predicted_label = predicted_label[0]
    if predicted_label != class_id:
        return [{}] if per_node else {}
    print(f"prediction {time.clock() - start}s")
    
    
    original_graph_dir = os.path.join(graph_dir, f"original_{transform_name}",
                        f"{class_id}")
    
    original_graph_saver = IOBatchAction(
        dir=original_graph_dir,
        root_index=image_id,
    )
    original_model_fn = partial(
        model_fn_with_fetch_hook,
        create_model=create_model, 
        graph=graph,
        graph_saver=original_graph_saver,
        batch_valid=[1],
    )
    trace = reconstruct_trace_from_tf(
        class_id=class_id,
        model_fn=original_model_fn,
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
            .skip(image_id)
            .take(1)
            .batch(1)
            .make_one_shot_iterator()
            .get_next()[0]
        ),
        select_fn=select_fn,
        model_dir=ckpt_dir,
    )
    print(f"Saved graph")
    
    
    graph_path = os.path.join(graph_dir, f"original_{transform_name}",
                                f"{class_id}", f"{image_id}.pkl")
    if not os.path.exists(graph_path):
        return
    
    single_graph = IOObjAction(
        graph_path
    ).load()
    if use_class_trace:
        class_trace_avg = ClassTraceIOAction(class_dir, predicted_label).load()
        assert class_trace_avg is not None
    else:
        class_trace_avg = None
    
    start = time.clock()
    single_trace = reconstruct_trace_from_tf_to_trace(
                single_graph,
                class_id=(class_id if attack_name=="original" else None),
                select_fn=select_fn,
                class_trace=class_trace_avg,
                debug=False,
            )
    print(f"compute original trace {time.clock() - start}s")



def save_training_trace():

    create_model = lambda: partial(
                    ResNet18Cifar10(),
                    training = False,
                )
    model_dir = resnet18_dir
    graph = ResNet18Cifar10.graph().load()
    
    # create_model = lambda: partial(
    #                 ResNet10Cifar10(),
    #                 training = False,
    #             )
    # model_dir = resnet10_dir
    # graph = ResNet10Cifar10.graph().load()
    
    
    
    class_dir = f"{model_dir}/nninst_mu_posneg/original_train_gathered_trace"
    graph_dir = f"{model_dir}/per_image_graph_{threshold}/{dataset_mode}"
    start = datetime.datetime.now()

    save_trace(
        class_id=0,
        image_id=0,
        select_fn=select_fn,
        class_dir=class_dir,
        graph_dir=graph_dir,
        graph=graph,
        class_num=10,
        model_dir=model_dir,
        create_model=create_model,
        dataset_mode = dataset_mode,
    )

    duration_second = (datetime.datetime.now() - start).seconds
    duration_minute = duration_second / 60
    print(f"Finish in {duration_second}s, {duration_minute:.1f}m")


if __name__=="__main__":
    tf.set_random_seed(3)
    np.random.seed(3)
    random.seed(3)
    os.environ["CUDA_VISIBLE_DEVICES"] = str(1)

    save_training_trace()
