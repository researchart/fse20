#  Copyright 2017 The TensorFlow Authors. All Rights Reserved.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
"""Convolutional Neural Network Estimator for MNIST, built with tf.layers."""

from __future__ import absolute_import, division, print_function
from pdb import set_trace as st
import time
import os
import argparse

import tensorflow as tf

from nninst_graph import AttrMap
import nninst_mode as mode
from dataset import mnist
from dataset.mnist_transforms import *
from dataset.config import MNIST_TRAIN
from model import LeNet
from model.config import LENET
from nninst_statistics import calc_density_compact, calc_space
from nninst_trace import TraceKey, compact_trace
from nninst_utils.fs import IOAction, abspath
from nninst_utils.ray import ray_init

from trace.common import (
    class_trace,
    class_trace_compact,
    full_trace,
    reconstruct_static_trace_from_tf,
    save_class_traces,
    self_similarity,
)

__all__ = [
    "lenet_mnist_class_trace",
    "lenet_mnist_trace",
    "lenet_mnist_self_similarity",
]

threshold = 0.9
# Configs
result_dir = "result/lenet"
# The label of LeNet model
model_label = "augmentation"
model_dir = f"{result_dir}/model_{model_label}"
# Dir to save traces for this model
trace_dir = f"{model_dir}/traces_{threshold}"
# The name of traces for this experiment.
# The final dir to save traces is trace_dir/trace_name.
# Should adapt with transform_list
trace_name = "noop"
# Example number per class to extract trace
example_num = 6000


# Choose transform from args.trace_name
if trace_name == 'noop':
    transforms_list = [None]
elif trace_name == 'left':
    # Left transformation
    transforms_list = [
        Translate(dx=-5)
    ]
elif trace_name == '9translation':
    # 9 transformation
    transforms_list = [
        Translate(dx=dx,dy=dy)
        for dx in (-5,0,5)
        for dy in (-5,0,5)
    ]
else:
    raise Exception("Transform list not implemented")
    exit()

# Transforms means data augmentation such as translation while
# transform_fn means a filter to select data with specific label
def dataset_fn(data_dir, batch_size, transform_fn, transforms):
    dataset = mnist.train(data_dir, transforms=transforms)
    return transform_fn(dataset).batch(batch_size)

data_config = MNIST_TRAIN.copy(dataset_fn=dataset_fn)

# name = "lenet_left"
lenet_mnist_class_trace = class_trace(
                            trace_name,
                            model_config=LENET,
                            data_config=data_config,
                        )

lenet_mnist_class_trace_compact = class_trace_compact(
    lenet_mnist_class_trace,
    name=trace_name,
    model_config=LENET
)

lenet_mnist_trace = full_trace(trace_name, lenet_mnist_class_trace)

threshold_to_density = {0.5: 0.1379723919438787}


def lenet_mnist_static_trace(threshold: float, label: str = None) -> IOAction[AttrMap]:
    def get_trace() -> AttrMap:
        return reconstruct_static_trace_from_tf(
            model_fn=lambda: LeNet(),
            input_fn=lambda: tf.placeholder(tf.float32, shape=(1, 1, 28, 28)),
            model_dir=tf.train.latest_checkpoint(abspath("tf/lenet/model/")),
            density=threshold_to_density[threshold],
        )

    threshold_name = "{0:.3f}".format(threshold)
    if label is None:
        name = "lenet_mnist"
    else:
        name = f"lenet_mnist_{label}"
    path = f"result/static_trace/{name}/approx_{threshold_name}/trace.pkl"
    return IOAction(path, init_fn=get_trace)



lenet_mnist_self_similarity = self_similarity(
    trace_name, lenet_mnist_class_trace, range(0, 10)
)

if __name__ == "__main__":

    # mode.check(False)
    # mode.debug()
    mode.local()
    # mode.distributed()
    ray_init(
        log_to_driver=False,
    )

    # label = "dropout"
    # label = "augmentation"
    # trace_dir = "result/lenet/traces"
    os.makedirs(trace_dir, exist_ok=True)

    print(f"generate class trace for label {model_label}")
    # Compute class trace
    start = time.clock()
    save_class_traces(
        lenet_mnist_class_trace,
        range(10),
        example_num = example_num,
        example_upperbound = example_num,
        threshold=threshold,
        label=model_label,
        batch_size=256,
        chunksize=1,
        num_gpus=0.2,
        transforms_list = transforms_list,
        trace_dir = trace_dir
    )
    elapsed = (time.clock() - start)
    print("Generate class trace time used:",elapsed)

    # Compact class trace
    # save_class_traces(
    #     lenet_mnist_class_trace_compact,
    #     range(1),
    #     example_num = example_num,
    #     example_upperbound = example_num,
    #     threshold=threshold,
    #     label=model_label,
    #     chunksize=1,
    #     num_gpus=0.2,
    #     trace_dir = trace_dir,
    # )
    # print("Compact class trace saved")

    # # lenet_mnist_self_similarity(threshold=threshold, label=label, compress=False).save()
    #
    # # Compute full trace from class trace
    # lenet_mnist_trace(
    #     class_ids=range(0, 10),
    #     threshold=threshold,
    #     label=label,
    #     chunksize = 1,
    #     num_gpus = 0.2
    # ).save()
    # trace = lenet_mnist_trace(threshold, label).load()
    #
    # for key in [TraceKey.POINT, TraceKey.EDGE, TraceKey.WEIGHT]:
    #     print(f"{key}: {calc_density_compact(trace, key)}")
    # for key in [TraceKey.POINT, TraceKey.EDGE, TraceKey.WEIGHT]:
    #     print(f"{key}: {calc_space(trace, key)}")
    # print("Full trace saved")

    # # Compact full trace
    # # Has some problem
    # trace = compact_trace(
    #                     lenet_mnist_trace(threshold, label).load(),
    #                     LeNet.graph().load()
    #                     )
    # for key in [TraceKey.POINT, TraceKey.EDGE, TraceKey.WEIGHT]:
    #     print(f"{key}: {calc_density_compact(trace, key)}")
    # print("Compact full trace saved")


    # dynamic_trace = lenet_mnist_trace(threshold, label).load()

    # lenet_mnist_static_trace(threshold, label).save()

    # static_trace = lenet_mnist_static_trace(threshold, label).load()
    # key = TraceKey.WEIGHT
    # print(f"{key}: {calc_density(static_trace, key)}")

    # print(f"iou(dynamic, static): {calc_iou(dynamic_trace, static_trace, key=TraceKey.WEIGHT)}")

    # for class_id in range(10):
    #     trace = lenet_mnist_class_trace(class_id, threshold, label, compress=False).load()
    #     threshold_name = "{0:.3f}".format(threshold)
    #     trace_name = f"{name}_{label}_compress"
    #     IOAction(f"store/analysis/class_trace/{trace_name}/approx_{threshold_name}/{class_id}.pkl",
    #              init_fn=lambda: trace, compress=True).save()

    # trace = lenet_mnist_trace(threshold=threshold, label=label).load()
    # layers = LeNet.graph().load().layers()
    # for key in [TraceKey.POINT, TraceKey.EDGE, TraceKey.WEIGHT]:
    #     density_per_layer = calc_density_compact_per_layer(trace, layers, key)
    #     density_per_layer.to_csv(abspath(f"lenet_mnist_trace_per_layer.{key}.csv"))
