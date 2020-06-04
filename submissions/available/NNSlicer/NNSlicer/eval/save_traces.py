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
from nninst_utils.numpy import arg_approx, arg_abs_approx
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
from logics.save_trace_avg import ClassTraceIOAction

# Model config
model_label = "augmentation"
model_dir = f"result/lenet/model_{model_label}"
# Trace config
trace_dir =  f"{model_dir}/traces"
trace_name = "noop"

threshold = 0.9
dataset_mode = "train"
images_per_class = 1000
attack_name = "FGSM"

use_class_trace = True
if use_class_trace:
    sum_precision = 0.1
    threshold_bar_ratio = 0.1
    select_fn = lambda input, output: arg_abs_approx(
        input, 
        output,
        sum_precision=sum_precision,
        threshold_bar_ratio=threshold_bar_ratio,
    )
    result_dir = f"{model_dir}/nninst_mu/per_image_trace_{threshold}/{dataset_mode}"
else:
    select_fn = lambda input: arg_approx(input, threshold)
    result_dir = f"{model_dir}/nninst_mu/per_image_trace_{threshold}_posonly/{dataset_mode}"
    
class_trace_dir = f"{model_dir}/nninst_mu/original_train_gathered_trace"

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

overlap_fn = calc_trace_side_overlap
per_channel = False

class_trace_fn=lambda class_id: lenet_mnist_class_trace(
    class_id,
    threshold,
    label=model_label,
    trace_dir = trace_dir,
)


# Compute the mean overlap ratio of attacked image
def save_trace(
    attack_name: str,
    attack_fn,
    generate_adversarial_fn,
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    overlap_fn: Callable[[AttrMap, AttrMap, str], float],
    per_channel: bool = False,
    per_node: bool = False,
    images_per_class: int = 1,
    num_gpus: float = 0.2,
    # model_dir = "result/lenet/model_augmentation",
    model_dir = model_dir,
    transforms = None,
    transform_name = "noop",
    save_dir = "result/test",
    mnist_dataset_mode = dataset_mode,
    use_class_trace = use_class_trace,
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
            if mnist_dataset_mode == "test":
                dataset = mnist.test
            elif mnist_dataset_mode == "train":
                dataset = mnist.train
            else:
                raise RuntimeError("Dataset invalid")

            predicted_label = predict(
                create_model=create_model,
                # dataset may be train or test, should be consistent with lenet_mnist_example
                input_fn=lambda: dataset(
                    data_dir,
                )
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
                mode = mnist_dataset_mode,
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
            
            if use_class_trace:
                class_trace_avg = ClassTraceIOAction(predicted_label).load()
            else:
                class_trace_avg = None

            trace = reconstruct_trace_from_tf(
                class_id=class_id,
                model_fn=model_fn,
                input_fn=lambda: dataset(
                    data_dir,
                    transforms=transforms,
                )
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
                class_trace=class_trace_avg,
            )[0]

            if trace is None:
                return [{}] if per_node else {}
            path = os.path.join(save_dir, f"original_{transform_name}",
                                f"{class_id}", f"{image_id}.pkl")
            ensure_dir(path)
            with open(path, "wb") as f:
                pickle.dump(trace, f)

            adversarial_trace = reconstruct_trace_from_tf(
                model_fn=model_fn,
                input_fn=lambda: tf.data.Dataset.from_tensors(
                    mnist.normalize(adversarial_example)
                ),
                select_fn=select_fn,
                model_dir=ckpt_dir,
                per_channel=per_channel,
                class_trace=class_trace_avg,
            )[0]

            path = os.path.join(save_dir, f"{attack_name}_{transform_name}",
                                f"{class_id}", f"{image_id}.pkl")
            ensure_dir(path)
            with open(path, "wb") as f:
                pickle.dump(adversarial_trace, f)

            row = {
                "class_id": class_id,
                "image_id": image_id,
                "trace": trace,
                "adversarial_trace": adversarial_trace,
            }
            # row = calc_all_overlap(
            #     class_trace_fn(class_id).load(), adversarial_trace, overlap_fn
            # )
            return row

        traces = ray_iter(
            get_row,
            (
                (class_id, image_id)
                for image_id in range(images_per_class)
                for class_id in range(0, 10)
            ),
            # ((-1, image_id) for image_id in range(mnist_info.test().size)),
            chunksize=1,
            out_of_order=True,
            num_gpus=num_gpus,
        )
        traces = [trace for trace in traces if len(trace) != 0]

        return traces

    return get_overlap_ratio

def save_training_trace(attack_name,
                            transform_name = "noop",
                            transforms = None):

    for transforms, transform_name in [
        [None, "noop"],
        # [Translate(dx=-5,dy=-5), "leftup"],
        # [Translate(dx=5,dy=5), "rightdown"],
        # [Translate(dx=-5), "left"],
        # [Translate(dy=-5), "up"],
    ]:

        # lenet_overlap_ratio = attack_reduced_edge_detection_count_violation(
        save_trace_fn = save_trace(
            attack_name=attack_name,
            attack_fn=attacks[attack_name][0],
            generate_adversarial_fn=cw_generate_adversarial_example
            if attack_name.startswith("CW")
            else foolbox_generate_adversarial_example,
            select_fn=select_fn,
            overlap_fn=overlap_fn,
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
            save_dir = result_dir,
            mnist_dataset_mode = dataset_mode,
            use_class_trace=use_class_trace,
        )

        save_trace_fn()

if __name__=="__main__":
    # mode.debug()
    mode.local()

    # ray_init("gpu")
    ray_init(
        log_to_driver=False
    )

    tf.set_random_seed(3)
    np.random.seed(3)
    random.seed(3)

    save_training_trace(
        attack_name=attack_name
    )
