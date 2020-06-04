import csv
import random
from functools import partial
from typing import Callable, Optional
from pdb import set_trace as st
import os
import random
import pandas as pd

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
import sklearn.metrics as metrics
import matplotlib.pyplot as plt
plt.switch_backend('Agg')

from model.config import LENET
import nninst_mode as mode
from dataset import mnist
from dataset.config import MNIST_TRAIN
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
from nninst_utils.fs import ensure_dir

from .common import get_overlay_summary, clean_overlap_ratio, \
                translation_overlap_ratio, attack_overlap_ratio
from .cw_attack import cw_generate_adversarial_example
from .cw_attacks import CarliniL2

# Model config
model_label = "augmentation"
model_dir = f"result/lenet/model_{model_label}"
# Trace config
trace_dir =  f"{model_dir}/traces"
trace_name = "noop"
key = TraceKey.EDGE
# Result dir
result_name = key.split('.')[1]
result_dir = f"{model_dir}/detection/{result_name}/{trace_name}_attack_overlap"
# result_dir = f"result/lenet/test"
images_per_class = 5
attack_name = "FGSM"

attacks = {
    "FGSM": [FGSM],
    "BIM": [IterativeGradientSignAttack],
    "JSMA": [SaliencyMapAttack],
    "DeepFool": [DeepFoolAttack],
    # "DeepFool_full": [DeepFoolAttack, dict(subsample=None)],
    # "CWL2": [CarliniL2],
}

def foolbox_generate_adversarial_example(
    label: int,
    create_model,
    input_fn: Callable[[], tf.Tensor],
    attack_fn: Callable[..., Attack],
    model_dir=None,
    checkpoint_path=None,
    preprocessing=(0, 1),
    channel_axis=1,
    bounds=(0, 1),
    **kwargs,
) -> Optional[np.ndarray]:
    # Check that model has been trained.
    if not checkpoint_path:
        checkpoint_path = saver.latest_checkpoint(model_dir)
    if not checkpoint_path:
        raise ValueError(
            "Could not find trained model in model_dir: {}.".format(model_dir)
        )

    with tf.Graph().as_default():
        features = input_fn()
        model = create_model()
        image_tensor = tf.placeholder(features.dtype, features.shape)
        logits = model(image_tensor)
        sm = SessionManager()
        with sm.prepare_session(
            master="",
            saver=tf.train.Saver(),
            checkpoint_filename_with_path=checkpoint_path,
            config=new_session_config(),
        ) as sess:
            image = sess.run(features)[0]
            attack_model = TensorFlowModel(
                image_tensor,
                logits,
                bounds=bounds,
                channel_axis=channel_axis,
                preprocessing=preprocessing,
            )
            attack = attack_fn(attack_model)
            # adversarial_example = attack(image, label=label, **kwargs)
            adversarial_example = attack(image, label=label)
            if adversarial_example is None:
                return None
            else:
                return adversarial_example[np.newaxis]


def attack_transform_overlap(attack_name,
                            transform_name,
                            transforms,
                            result_dir = "result/lenet/9transform_attack_overlap"):

    name = attack_name+'_'+transform_name

    lenet_mnist_class_trace = class_trace(
                                trace_name,
                                model_config=LENET,
                                data_config=data_config,
                            )

    threshold = 0.5

    # DeepFool will shutdown when num_gpu<0.2
    num_gpus = 0.2

    overlap_fn = calc_trace_side_overlap
    per_channel = False

    path = os.path.join(result_dir, f"{name}_overlap.csv")

    print(f"Computing {name}")

    lenet_overlap_ratio = attack_overlap_ratio(
        attack_name=attack_name,
        attack_fn=attacks[attack_name][0],
        generate_adversarial_fn=cw_generate_adversarial_example
        if attack_name.startswith("CW")
        else foolbox_generate_adversarial_example,
        class_trace_fn=lambda class_id: lenet_mnist_class_trace(
            class_id,
            threshold,
            label=model_label,
            trace_dir = trace_dir,
        ),
        select_fn=lambda input: arg_approx(input, threshold),
        overlap_fn=overlap_fn,
        path=path,
        per_channel=per_channel,
        preprocessing=(0.1307, 0.3081),
        image_size=28,
        class_num=10,
        norm_fn=mnist.normalize,
        data_format="channels_first",
        **(attacks[attack_name][1] if len(attacks[attack_name]) == 2 else {}),
        images_per_class=images_per_class,
        model_dir=model_dir,
        num_gpus = num_gpus,
        transforms = transforms,
        transform_name = transform_name,
    )

    lenet_overlap_ratio.save()

    return lenet_overlap_ratio.load()

def compute_roc_auc(trace_frame):

    original_key = "original."+key
    adversarial_key = "adversarial."+key

    normal_example_label = -1
    adversarial_example_label = -normal_example_label

    adversarial_metric = trace_frame[adversarial_key]
    normal_metric = trace_frame[original_key]

    scores = np.concatenate([adversarial_metric, normal_metric])
    row_filter = np.isfinite(scores)
    # row_filter = np.isfinite(scores).all(axis=1)
    labels = np.concatenate(
        [
            np.repeat(adversarial_example_label, adversarial_metric.shape[0]),
            np.repeat(normal_example_label, normal_metric.shape[0]),
        ]
    )
    labels = labels[row_filter]
    scores = scores[row_filter]
    # Adjust to fit the predifined labels that adversarial examples are 1 and
    # normal examples are -1.
    scores = 1 - scores
    
    thred = 0.01
    sample_number = int(len(labels) / 2)
    pred = scores
    pred[pred<thred] = -1
    pred[pred>thred] = 1
    adv_pred = pred[:sample_number]
    tpr = (adv_pred == 1).sum() / sample_number
    ori_pred = pred[sample_number:]
    fpr = (ori_pred == 1).sum() / sample_number
    auc = metrics.auc([0,fpr,1], [0,tpr,1])
    print(f"tpr: {tpr:.2f}, fpr: {fpr:.2f}, auc: {auc:.2f}")


    fpr, tpr, thresholds = metrics.roc_curve(labels, scores)
    roc_auc = metrics.auc(fpr, tpr)
    return fpr, tpr, roc_auc


def draw_attack_transform_roc(exp_to_roc, save_name, result_dir):

    plt.title('ROC')

    for exp_name, item in exp_to_roc.items():
        fpr, tpr, roc_auc, color = item
        plt.plot(fpr, tpr,color,label=f"{exp_name}_AUC={roc_auc:.2f}")

    plt.legend(loc='lower right')
    plt.plot([0,1],[0,1],'r--')
    plt.ylabel('TPR')
    plt.xlabel('FPR')

    path = os.path.join(result_dir, f"{save_name}.png")
    plt.savefig(path)
    print(path)


def attack_exp():
    exp_to_roc = {}


    os.makedirs(result_dir, exist_ok=True)

    for transforms, transform_name, color in [
        [None, "noop", 'b'],
        # [Translate(dx=-5,dy=-5), "leftup", 'g'],
        # [Translate(dx=5,dy=5), "rightdown",  'c'],
        # [Translate(dx=-5), "left", 'y'],
        # [ Translate(dy=-5), "up", 'm'],
    ]:
        exp_name = attack_name+"_"+transform_name
        trace_frame = attack_transform_overlap(attack_name,
                                            transform_name,
                                            transforms,
                                            result_dir=result_dir)
        exp_to_roc[exp_name] = compute_roc_auc(trace_frame) + (color,)

    draw_attack_transform_roc(exp_to_roc,
                            save_name=attack_name,
                            result_dir=result_dir)

if __name__ == "__main__":

    # mode.debug()
    mode.local()
    # mode.distributed()

    # ray_init("gpu")
    ray_init(
        log_to_driver=False
    )

    tf.set_random_seed(3)
    np.random.seed(3)
    random.seed(3)

    # clean_overlap()
    # transform_exp()
    attack_exp()


'''
Compute mnist overlap ratio of traces on clean test images
'''
def clean_overlap():

    label = "dropout"
    result_dir = "result/lenet"

    images_per_class = 1
    num_gpus = 0.2

    threshold = 0.5

    overlap_fn = calc_trace_side_overlap
    # overlap_fn = calc_trace_side_overlap_both_compact
    per_channel = False
    # per_channel = True

    path_template = (
        os.path.join(result_dir, "class_overlap_ratio_{0:.1f}_{1}.csv")
    )

    lenet_overlap_ratio = clean_overlap_ratio(
        class_trace_fn=lambda class_id: lenet_mnist_class_trace(
            class_id, threshold, label=label
        ),
        # class_trace_fn=lambda class_id: lenet_mnist_class_trace(class_id, threshold),
        select_fn=lambda input: arg_approx(input, threshold),
        overlap_fn=overlap_fn,
        path=path_template.format(threshold, label),
        per_channel=per_channel,
        preprocessing=(0.1307, 0.3081),
        image_size=28,
        class_num=10,
        norm_fn=mnist.normalize,
        data_format="channels_first",
        num_gpus = num_gpus,
        images_per_class = images_per_class,
    )

    lenet_overlap_ratio.save()


    summary_mean_path_template = os.path.join(result_dir, "mean_overlap_ratio_summary_{threshold:.1f}.csv")
    key = TraceKey.EDGE
    # key = TraceKey.WEIGHT

    overlay_ratio_mean = lenet_overlap_ratio.load().mean()
    summary_file = summary_mean_path_template.format(
        threshold=threshold,
        label=label,
    )
    overlay_ratio_mean.to_csv(summary_file)

def transform_overlap(name, transforms=None):
    label = "augmentation"
    result_dir = "result/lenet/transform_overlap"
    if not os.path.exists(result_dir):
        os.makedirs(result_dir, exist_ok=True)

    threshold = 0.5

    overlap_fn = calc_trace_side_overlap
    per_channel = False

    path = os.path.join(result_dir, f"{name}_overlap.csv")

    print(f"Computing {name}")

    lenet_overlap_ratio = translation_overlap_ratio(
        class_trace_fn=lambda class_id: lenet_mnist_class_trace(
            class_id, threshold, label=label
        ),
        # class_trace_fn=lambda class_id: lenet_mnist_class_trace(class_id, threshold),
        select_fn=lambda input: arg_approx(input, threshold),
        overlap_fn=overlap_fn,
        path=path,
        per_channel=per_channel,
        preprocessing=(0.1307, 0.3081),
        image_size=28,
        class_num=10,
        norm_fn=mnist.normalize,
        data_format="channels_first",
        transforms=transforms,
        name=name,
        num_gpus = 0.1,
        images_per_class=100
    )

    lenet_overlap_ratio.save(header=1)
    return lenet_overlap_ratio.load(header=0, index_col=0)

def transform_exp():
    name = 'noop'
    result = transform_overlap(name)

    name = 'right'
    transforms = Translate(dx=5)
    one_res = transform_overlap(name, transforms)
    result = pd.concat([result, one_res], axis=1)

    name = 'left'
    transforms = Translate(dx=-5)
    one_res = transform_overlap(name, transforms)
    result = pd.concat([result, one_res], axis=1)

    name = 'up'
    transforms = Translate(dy=-5)
    one_res = transform_overlap(name, transforms)
    result = pd.concat([result, one_res], axis=1)

    name = 'down'
    transforms = Translate(dy=5)
    one_res = transform_overlap(name, transforms)
    result = pd.concat([result, one_res], axis=1)

    name = 'rightdown'
    transforms = Translate(dx=5,dy=5)
    one_res = transform_overlap(name, transforms)
    result = pd.concat([result, one_res], axis=1)

    name = 'rightup'
    transforms = Translate(dx=5,dy=-5)
    one_res = transform_overlap(name, transforms)
    result = pd.concat([result, one_res], axis=1)

    name = 'leftdown'
    transforms = Translate(dx=-5,dy=5)
    one_res = transform_overlap(name, transforms)
    result = pd.concat([result, one_res], axis=1)

    name = 'leftup'
    transforms = Translate(dx=-5,dy=-5)
    one_res = transform_overlap(name, transforms)
    result = pd.concat([result, one_res], axis=1)

    result_dir = "result/lenet/transform_overlap"
    path = os.path.join(result_dir, "overlay_ratio.csv")
    result.to_csv(path)
    print(result)
