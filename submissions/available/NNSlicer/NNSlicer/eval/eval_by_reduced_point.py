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
import sklearn.metrics as metrics
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

from .common import get_overlay_summary, clean_overlap_ratio, \
                translation_overlap_ratio, attack_overlap_ratio, \
                lenet_mnist_example
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
    reconstruct_class_trace_from_tf,
    reconstruct_trace_from_tf,
    reconstruct_trace_from_tf_brute_force,
)
from .analyse_class_trace import reconstruct_edge

# Model config
model_label = "augmentation"
model_dir = f"result/lenet/model_{model_label}"
# Trace config
trace_dir =  f"{model_dir}/traces"
trace_name = "noop"
# Result dir
result_name = "test"

key = TraceKey.POINT
# Result dir
key_name = key.split('.')[1]

# reduce_mode includes output, channel, none
reduce_mode = "none"
result_dir = f"{model_dir}/conv_point_NOT/{reduce_mode}_{trace_name}_attack_overlap"
# result_dir = f"result/lenet/test"
images_per_class = 100
attack_name = "FGSM"

attacks = {
    "FGSM": [FGSM],
    "BIM": [IterativeGradientSignAttack],
    "JSMA": [SaliencyMapAttack],
    "DeepFool": [DeepFoolAttack],
    # "DeepFool_full": [DeepFoolAttack, dict(subsample=None)],
    # "CWL2": [CarliniL2],
}

adversarial_label = 1
normal_label = -1

class_trace_fn=lambda class_id: lenet_mnist_class_trace(
    class_id,
    threshold,
    label=model_label,
    trace_dir = trace_dir,
)

lenet_mnist_class_trace = class_trace(
                            trace_name,
                            model_config=LENET,
                            data_config=data_config,
                        )

def reconstruct_point(
    trace,
    graph,
    key,
    node_name,
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
        RuntimeError(f"Key not found")


def filter_point_by_key(
        trace: AttrMap,
        key: str =TraceKey.POINT,
        graph = LENET.network_class.graph().load(),
    ):
    reconstruct_point_fn = partial(
        reconstruct_point,
        trace,
        graph,
        key,
    )
    op_to_mask = {}
    # print(trace.nodes.keys())
    for node_name in sorted(trace.nodes):
        # print(f"{node_name}: {trace.nodes[node_name].keys()}")
        if key in trace.nodes[node_name]:
            op_to_mask[node_name] = reconstruct_point_fn(node_name)
    # for op in op_to_mask:
    #     print(f"{op}: {op_to_mask[op].shape}")
    # st()
    return op_to_mask

def reduce_edge_mask(edge_mask: AttrMap, reduce_mode="none"):
    reduced_edge = {}
    for node_name in edge_mask:
        # shape of edge (Ci, Hk, Wk, Co, Ho, Wo)
        edge = edge_mask[node_name]
        if "conv2d" in node_name:
            if reduce_mode == "channel":
                edge_sum = edge_mask[node_name].sum(0)
                edge_sum[edge_sum>0] = 1
            elif reduce_mode == "output":
                edge_sum = edge_mask[node_name].sum(-1).sum(-1)
                edge_sum[edge_sum>0] = 1
            else:
                edge_sum = edge_mask[node_name]
        else:
            edge_sum = edge
        reduced_edge[node_name] = edge_sum
    return reduced_edge

def detect_by_reduced_edge(class_trace, trace, reduce_mode = "none"):
    class_masks = filter_point_by_key(
                    class_trace,
                    key = key
                )
    sample_masks = filter_point_by_key(
                    trace,
                    key = key
                )
    class_masks = reduce_edge_mask(class_masks, reduce_mode = reduce_mode)
    sample_masks = reduce_edge_mask(sample_masks, reduce_mode = reduce_mode)

    is_adversarial = False
    for node_name in class_masks:
        if "conv2d" not in node_name or "Relu" not in node_name:
            continue
        class_mask = class_masks[node_name]
        sample_mask = sample_masks[node_name]
        class_zero = class_mask==0
        sample_zero_sum = sample_mask[class_zero].sum()
        if sample_zero_sum>0:
            is_adversarial = True
    if is_adversarial:
        return adversarial_label
    else:
        return normal_label


# Compute the mean overlap ratio of attacked image
def attack_reduced_edge_detection(
    attack_name: str,
    attack_fn,
    generate_adversarial_fn,
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    overlap_fn: Callable[[AttrMap, AttrMap, str], float],
    path: str,
    per_channel: bool = False,
    per_node: bool = False,
    images_per_class: int = 1,
    num_gpus: float = 0.2,
    model_dir = "result/lenet/model_augmentation",
    transforms = None,
    transform_name = "noop",
    reduce_mode = "none",
    **kwargs,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            nonlocal model_dir
            mode.check(False)
            data_dir = abspath(MNIST_PATH)
            model_dir = abspath(model_dir)
            ckpt_dir = f"{model_dir}/ckpts"
            create_model = lambda: LeNet(data_format="channels_first")
            graph = LeNet.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook,
                create_model=create_model, graph=graph
            )

            predicted_label = predict(
                create_model=create_model,
                input_fn=lambda: mnist.test(data_dir)
                .filter(
                    lambda image, label: tf.equal(
                        tf.convert_to_tensor(class_id, dtype=tf.int32), label
                    )
                )
                .skip(image_id)
                .take(1)
                .batch(1),
                model_dir=ckpt_dir,
            )
            if predicted_label != class_id:
                return [{}] if per_node else {}

            adversarial_example = lenet_mnist_example(
                attack_name=attack_name,
                attack_fn=attack_fn,
                generate_adversarial_fn=generate_adversarial_fn,
                class_id=class_id,
                image_id=image_id,
                # model_dir not ckpt_dir
                model_dir=model_dir,
                transforms = transforms,
                transform_name = transform_name,
                mode = "test",
            ).load()

            if adversarial_example is None:
                return [{}] if per_node else {}

            adversarial_predicted_label = predict(
                create_model=create_model,
                input_fn=lambda: tf.data.Dataset.from_tensors(
                    mnist.normalize(adversarial_example)
                ),
                model_dir=ckpt_dir,
            )

            if predicted_label == adversarial_predicted_label:
                return [{}] if per_node else {}

            trace = reconstruct_trace_from_tf(
                class_id=class_id,
                model_fn=model_fn,
                input_fn=lambda: mnist.test(data_dir, transforms=transforms)
                .filter(
                    lambda image, label: tf.equal(
                        tf.convert_to_tensor(class_id, dtype=tf.int32), label
                    )
                )
                .skip(image_id)
                .take(1)
                .batch(1),
                select_fn=select_fn,
                model_dir=ckpt_dir,
                per_channel=per_channel,
            )[0]

            if trace is None:
                return [{}] if per_node else {}

            adversarial_trace = reconstruct_trace_from_tf_brute_force(
                model_fn=model_fn,
                input_fn=lambda: tf.data.Dataset.from_tensors(
                    mnist.normalize(adversarial_example)
                ),
                select_fn=select_fn,
                model_dir=ckpt_dir,
                per_channel=per_channel,
            )[0]

            adversarial_label = adversarial_trace.attrs[GraphAttrKey.PREDICT]


            row = {
                "image_id": image_id,
                "class_id": class_id,
                "original.prediction":
                    detect_by_reduced_edge(
                        class_trace_fn(class_id).load(),
                                        trace,
                                        reduce_mode,
                        ),
                "adversarial.prediction":
                    detect_by_reduced_edge(
                        class_trace_fn(adversarial_label).load(),
                                        adversarial_trace,
                                        reduce_mode,
                    ),
            }
            return row

        detections = ray_iter(
            get_row,
            (
                (class_id, image_id)
                for image_id in range(0, images_per_class)
                for class_id in range(0, 10)
            ),
            # ((-1, image_id) for image_id in range(mnist_info.test().size)),
            chunksize=1,
            out_of_order=True,
            num_gpus=num_gpus,
        )
        traces = [detection for detection in detections if len(detection) != 0]
        return pd.DataFrame(traces)

    return CsvIOAction(path, init_fn=get_overlap_ratio)


def attack_transform_overlap(attack_name,
                            transform_name,
                            transforms,
                            reduce_mode = "none",
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

    # print(f"Computing {name}")

    # lenet_overlap_ratio = attack_reduced_edge_detection_count_violation(
    lenet_overlap_ratio = attack_reduced_edge_detection(
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
        reduce_mode = reduce_mode,
    )

    lenet_overlap_ratio.save()

    return lenet_overlap_ratio.load()

def compute_accuracy(trace_frame):
    adversarial_metric = trace_frame["adversarial.prediction"]
    original_metric = trace_frame["original.prediction"]
    predictions = np.concatenate([adversarial_metric, original_metric])
    row_filter = np.isfinite(predictions)
    labels = np.concatenate(
        [
            np.repeat(1, adversarial_metric.shape[0]),
            np.repeat(-1, original_metric.shape[0]),
        ]
    )
    labels = labels[row_filter]
    predictions = predictions[row_filter]
    fpr, tpr, thresholds = metrics.roc_curve(labels, predictions)
    roc_auc = metrics.auc(fpr, tpr)
    return fpr, tpr, roc_auc

def draw_attack_transform_roc(exp_to_roc, save_name, result_dir):

    plt.title('ROC')
    detection_results = {}

    for exp_name, item in exp_to_roc.items():
        fpr, tpr, roc_auc, color = item
        print(f"{exp_name}: fpr={fpr}, tpr={tpr}")
        plt.plot(fpr, tpr,color,label=f"{exp_name}_AUC={roc_auc:.2f}")
        detection_results[exp_name] = [fpr, tpr]

    plt.legend(loc='lower right')
    plt.plot([0,1],[0,1],'r--')
    plt.ylabel('TPR')
    plt.xlabel('FPR')

    path = os.path.join(result_dir, f"{save_name}.png")
    plt.savefig(path)

    path = os.path.join(result_dir, f"{save_name}.txt")
    with open(path, "w") as f:
        for name in detection_results:
            print(f"{exp_name}: fpr={fpr}, tpr={tpr}", file=f)

def attack_exp():
    exp_to_roc = {}

    os.makedirs(result_dir, exist_ok=True)

    for transforms, transform_name, color in [
        [None, "noop", 'b'],
        # [Translate(dx=-5,dy=-5), "leftup", 'g'],
        # [Translate(dx=5,dy=5), "rightdown",  'c'],
        # [Translate(dx=-5), "left", 'y'],
        # [Translate(dy=-5), "up", 'm'],
    ]:
        exp_name = attack_name+"_"+transform_name
        print(f"Computing {exp_name}")
        trace_frame = attack_transform_overlap(attack_name,
                                            transform_name,
                                            transforms,
                                            reduce_mode = reduce_mode,
                                            result_dir=result_dir)
        exp_to_roc[exp_name] = compute_accuracy(trace_frame) + (color,)

    draw_attack_transform_roc(exp_to_roc,
                            save_name=attack_name,
                            result_dir=result_dir)

if __name__ == "__main__":

    # mode.debug()
    mode.local()

    # ray_init("gpu")
    ray_init(
        log_to_driver=False
    )

    tf.set_random_seed(3)
    np.random.seed(3)
    random.seed(3)

    attack_exp()
