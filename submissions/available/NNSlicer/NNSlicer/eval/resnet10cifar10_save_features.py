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
from model.resnet10cifar10_feature import ResNet10Cifar10_Feature

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
result_dir = f"{model_dir}/nninst_mu_posneg/forward_feature"
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

def forward_propagate_batch_feature(
    create_model,
    input_fn,
    model_dir: str,
    forward_fn: Callable[[tf.Tensor], tf.Tensor] = lambda logits: tf.argmax(logits, axis=1),
    data_format: str = "channels_first",
    parallel: int = 1,
    prediction_hooks = None,
) -> Union[int, float]:

    def model_fn(features, labels, mode, params):
        image = features
        if isinstance(image, dict):
            image = features["image"]

        if mode == tf.estimator.ModeKeys.PREDICT:
            logits, feature = create_model()(image, training=False)
            predictions = {
                "classes": forward_fn(logits),
                "feature": feature,
                }
            return tf.estimator.EstimatorSpec(
                mode=tf.estimator.ModeKeys.PREDICT,
                predictions=predictions,
                prediction_hooks=prediction_hooks,
                export_outputs={
                    "classify": tf.estimator.export.PredictOutput(predictions)
                },
            )

    model_dir = abspath(model_dir)
    model_function = model_fn
    if data_format is None:
        data_format = (
            "channels_first" if tf.test.is_built_with_cuda() else "channels_last"
        )
    estimator_config = tf.estimator.RunConfig(
        session_config=new_session_config(parallel=parallel)
    )
    if not os.path.exists(model_dir):
        raise RuntimeError(f"model directory {model_dir} is not existed")
    classifier = tf.estimator.Estimator(
        model_fn=model_function,
        model_dir=model_dir,
        params={"data_format": data_format},
        config=estimator_config,
    )

    result = list(classifier.predict(input_fn=input_fn))
    prediction = np.array([v["classes"] for v in result])
    feature = np.array([v["feature"] for v in result])
    return prediction, feature

# Compute the mean overlap ratio of attacked image
def save_training_feature_batch(
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
        ResNet10Cifar10_Feature(),
        training = False,
    )
    graph = ResNet10Cifar10_Feature.graph().load()
    
    batch_size = min(batch_size, images_per_class - image_id_index)
    
    prediction, feature = forward_propagate_batch_feature(
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
    
    label = np.repeat([class_id], batch_size)
    return feature, label, prediction
    
    
def save_training_features(
    images_per_class,
    batch_size,
    dataset_mode,
):
    
    features, labels, preds = [], [], []
    for class_id in range(class_num):
        print(f"Saving training features of class {class_id}")
        for image_id_index in range(0, images_per_class, batch_size):
            feature, label, pred = save_training_feature_batch(
                image_id_index=image_id_index,
                batch_size=batch_size,
                class_id=class_id,
                model_dir=model_dir,
                dataset_mode = dataset_mode,
                images_per_class=images_per_class,
            )
            features.append(feature)
            labels.append(label)
            preds.append(pred)

    features = np.concatenate(features)
    labels = np.concatenate(labels)
    preds = np.concatenate(preds)
    data = {
        "features": features,
        "labels": labels,
        "preds": preds,
    }
    
    path = os.path.join(result_dir, "train.pkl")
    with open(path, "wb") as f:
        pickle.dump(data, f)
    
    

# Compute the mean overlap ratio of attacked image
def save_adversarial_feature_batch(
    attack_name,
    image_id_index,
    batch_size,
    class_id,
    model_dir = model_dir,
    graph_dir = "result/test",
    dataset_mode = dataset_mode,
    images_per_class = 1,
    adversarial_dir = "result/test",
    **kwargs,
):
    
    # mode.check(False)
    data_dir = abspath(CIFAR10_PATH)
    model_dir = abspath(model_dir)
    ckpt_dir = f"{model_dir}/ckpts"
    create_model = lambda: partial(
        ResNet10Cifar10_Feature(),
        training = False,
    )
    graph = ResNet10Cifar10_Feature.graph().load()
    
    batch_size = min(batch_size, images_per_class - image_id_index)
    
    adversarial_examples = [
        resnet10_cifar10_example(
            attack_name=attack_name,
            attack_fn=None,
            generate_adversarial_fn=None,
            class_id=class_id,
            image_id=image_id,
            # model_dir not ckpt_dir
            model_dir=model_dir,
            transforms = None,
            transform_name = "noop",
            dataset_mode = dataset_mode,
        ).load()
        for image_id in range(image_id_index, image_id_index + batch_size)
    ]
    adversarial_examples = [v for v in adversarial_examples if v is not None]
    adversarial_examples = np.concatenate(adversarial_examples)
        
    adversarial_prediction, feature = forward_propagate_batch_feature(
        create_model=create_model,
        input_fn=lambda: tf.data.Dataset.from_tensors(
            adversarial_examples
        ),
        model_dir=ckpt_dir,
    )
    
    label = np.repeat([class_id], adversarial_examples.shape[0])
    
    return feature, label, adversarial_prediction
    
def save_adversarial_features(
    images_per_class,
    batch_size,
    dataset_mode,
    
):
    adversarial_dir = os.path.join(model_dir, "attack", "test")
    for attack_name in [
        # "original",
        "FGSM_2", "FGSM_4", "FGSM_8",
        "DeepFoolLinf", "DeepFoolL2",
        "JSMA",
        "RPGD_2", "RPGD_4", "RPGD_8",
        "CWL2", "ADef",
        "SinglePixel", "LocalSearch",
        "Boundary", "Spatial", "Pointwise", "GaussianBlur",
    ]:
        features, labels, preds = [], [], []
        for class_id in range(class_num):
            print(f"Saving training features of attack {attack_name} class {class_id}")
            for image_id_index in range(0, images_per_class, batch_size):
                feature, label, pred = save_adversarial_feature_batch(
                    attack_name=attack_name,
                    image_id_index=image_id_index,
                    batch_size=batch_size,
                    class_id=class_id,
                    model_dir=model_dir,
                    dataset_mode = dataset_mode,
                    images_per_class=images_per_class,
                    adversarial_dir=adversarial_dir,
                )
                features.append(feature)
                labels.append(label)
                preds.append(pred)

        features = np.concatenate(features)
        labels = np.concatenate(labels)
        preds = np.concatenate(preds)
        data = {
            "features": features,
            "labels": labels,
            "preds": preds,
        }
        
        path = os.path.join(result_dir, f"{attack_name}.pkl")
        with open(path, "wb") as f:
            pickle.dump(data, f)


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

    # dataset_mode, images_per_class = "train", 1000
    # batch_size = 200
    # save_training_features(
    #     images_per_class,
    #     batch_size,
    #     dataset_mode,
    # )
    
    dataset_mode, images_per_class = "test", 100
    batch_size = 100
    save_adversarial_features(
        images_per_class,
        batch_size,
        dataset_mode,
    )
