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

import nninst_mode as mode
from dataset.config import (
    CIFAR10_TRAIN,
)
from model.config import RESNET_18_CIFAR10
from nninst_utils.ray import ray_init

from trace.common import (
    class_trace,
    class_trace_compact,
    class_trace_growth,
    full_trace,
    save_class_traces,
    save_class_traces_low_latency,
    save_full_trace_growth,
    self_similarity,
)

__all__ = ["resnet_18_cifar10_class_trace", "resnet_18_cifar10_self_similarity"]

threshold = 0.9
# Configs
result_dir = "result/resnet18cifar10"
# The label of LeNet model
model_label = "dropout"
model_dir = f"{result_dir}/model_{model_label}"
# Dir to save traces for this model
trace_dir = f"{model_dir}/traces_{threshold}"
# The name of traces for this experiment.
# The final dir to save traces is trace_dir/trace_name.
# Should adapt with transform_list
trace_name = "noop"
# Example number per class to extract trace
example_num = 1


resnet_18_cifar10_class_trace = class_trace(
    name=trace_name, 
    model_config=RESNET_18_CIFAR10, 
    data_config=CIFAR10_TRAIN
)

# resnet_18_cifar10_class_trace_growth = class_trace_growth(
#     name=name, model_config=RESNET_18_CIFAR10, data_config=CIFAR10_TRAIN
# )

resnet_18_cifar10_class_trace_compact = class_trace_compact(
    resnet_18_cifar10_class_trace, 
    name=trace_name, 
    model_config=RESNET_18_CIFAR10
)

# save_resnet_18_cifar10_class_traces_low_latency = save_class_traces_low_latency(
#     name=name, model_config=RESNET_18_CIFAR10, data_config=CIFAR10_TRAIN
# )

resnet_18_cifar10_trace = full_trace(
    name=name, 
    class_trace_fn=resnet_18_cifar10_class_trace
)
#
# save_resnet_18_cifar10_trace_growth = save_full_trace_growth(
#     name=name, class_trace_fn=resnet_18_cifar10_class_trace
# )
#
# resnet_18_cifar10_self_similarity = self_similarity(
#     name=name, trace_fn=resnet_18_cifar10_class_trace, class_ids=range(0, 10)
# )

if __name__ == "__main__":
    # mode.check(False)
    # mode.debug()
    mode.local()
    # mode.distributed()
    # ray_init("dell")
    # ray_init("gpu")
    ray_init(
        log_to_driver=False,
    )

    os.makedirs(trace_dir, exist_ok=True)

    print(f"generate class trace for label {model_label}")
    # Compute class trace
    start = time.clock()
    save_class_traces(
        resnet_18_cifar10_class_trace,
        range(10),
        threshold=threshold,
        label=model_label,
        example_num=example_num, 
        example_upperbound=example_num,
        chunksize=1, 
        num_gpus=0.5,
        trace_dir=trace_dir,
        )
    elapsed = (time.clock() - start)
    print("Generate class trace time used:",elapsed)

    # # Compact class trace
    # save_class_traces(
    #     resnet_18_cifar10_class_trace_compact,
    #     range(0, 10),
    #     threshold=threshold,
    #     label=label,
    #     chunksize=3, num_gpus=0.5
    # )

    # save_resnet_18_cifar10_class_traces_low_latency(
    #     range(0, 10), threshold=threshold, label=label, example_num=5000, batch_size=8
    # )

    # resnet_18_cifar10_self_similarity(threshold=threshold, label=label).save()
