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
from .eval_by_reduced_point import reconstruct_point
from nninst_op import *
from nninst_trace import calc_padding

threshold = 0.9
dilation_iter = 1
dilation_structure = ndimage.generate_binary_structure(2, 2)
# Model config
model_label = "augmentation"
model_dir = f"result/lenet/model_{model_label}"
# Trace config
trace_dir =  f"{model_dir}/traces_{threshold}"
trace_name = "noop"
training_trace_dir = f"{model_dir}/per_image_trace_{threshold}/train"
# Result dir
result_name = "test"
# reduce_mode includes kernel, feature, channel, none
reduce_mode = "except_space"
result_dir = f"{model_dir}/birelation/{threshold}_{dilation_iter}"
# result_dir = f"result/lenet/test"
images_per_class = 1000
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

lenet_mnist_class_trace = class_trace(
                            trace_name,
                            model_config=LENET,
                            data_config=data_config,
                        )

key = TraceKey.POINT
graph = LENET.network_class.graph().load()
reconstruct_ratio = 0.01
count_threshold = 800
filter_mode = "ratio"

def get_edge_from_trace(
    trace,
    graph,
    key,
    node_name,

):
    attrs = trace.nodes[node_name]
    op = graph.op(graph.id(node_name))
    if key not in attrs:
        return None
    else:
        attr = attrs[key]
        edge = TraceKey.to_array(attr)

        return edge


reconstruct_point_fn = partial(
                        reconstruct_point,
                        graph = graph,
                        key = key,
                        )

def compute_birelation_class(
    class_id,
    images_per_class = 10,
    relation_op = "and", # and or or
    attack_name = "FGSM",
    transform_name = "noop",
    saved_trace_dir = f"{model_dir}/training_trace",
    result_dir = "result/test",
):

    def compute_relation_per_pair(
        image_id,
        reconstruct_point_fn,
        relation_op,
        # op_to_collective_mask, # filter channels that are never actived for all samples
    ):
        original_dir = os.path.join(
                            saved_trace_dir,
                            f"original_{transform_name}",
                            f"{class_id}",
        )
        adversarial_dir = os.path.join(
                            saved_trace_dir,
                            f"{attack_name}_{transform_name}",
                            f"{class_id}",
        )

        original_path = os.path.join(
                            original_dir,
                            f"{image_id}.pkl",
        )
        adversarial_path = os.path.join(
                            adversarial_dir,
                            f"{image_id}.pkl",
        )
        if not os.path.exists(original_path) or \
            not os.path.exists(adversarial_path):
            return {}
        with open(original_path, "rb") as f:
            original_trace = pickle.load(f)
        with open(adversarial_path, "rb") as f:
            adversarial_trace = pickle.load(f)

        op_to_trace = {}
        for node_name in sorted(original_trace.nodes):
            if key in original_trace.nodes[node_name]:
                op_to_trace[node_name] = reconstruct_point_fn(
                                        node_name = node_name,
                                        trace = original_trace)

        birelation_info = {}
        intro_conv_cmp = {}
        channel_info = {}
        for node_name in [
            "conv2d/Relu:0",
            "conv2d_1/Relu:0",
          ]:
            # collective_mask = op_to_collective_mask[node_name]
            mask = op_to_trace[node_name]
            mask = ndimage.binary_dilation(
                mask,
                # structure = dilation_structure,
                iterations = dilation_iter,
            ).astype(mask.dtype)
            filter_number = mask.shape[0]
            if relation_op == "and":
                cmp_result = [
                    (mask[i]==mask[j]).all() and \
                    (mask[i].sum()>0) and \
                    (mask[j].sum()>0)
                    for i in range(filter_number)
                    for j in range(i+1, filter_number)
                ]
            elif relation_op == "or":
                cmp_result = [
                    (
                        mask[i]*mask[j]>0
                    ).any()
                    for i in range(filter_number)
                    for j in range(i+1, filter_number)
                ]

            cmp_result = np.array(cmp_result).astype(np.uint8)
            intro_conv_cmp[node_name] = cmp_result

            mask = op_to_trace[node_name]
            channel = mask.sum(-1).sum(-1)
            channel[channel>0] = 1
            channel_info[node_name] = channel

        # Compute inter conv
        mask1 = op_to_trace["conv2d/Relu:0"]
        mask2 = op_to_trace["conv2d_1/Relu:0"]
        h, w = mask1.shape[-2:]
        c = mask2.shape[0]
        # use np.resize instead mask.resize
        mask2 = np.resize(mask2, (c, h, w))
        filter_number1 = mask1.shape[0]
        filter_number2 = mask2.shape[0]
        inter_conv_relation = [
            (
                mask1[i]*mask2[j]>0
            ).any()
            for i in range(filter_number1)
            for j in range(filter_number2)
        ]
        inter_conv_relation = np.array(inter_conv_relation).astype(np.uint8)

        del op_to_trace
        birelation_info["Channel"] = channel_info
        birelation_info["IntroConv"] = intro_conv_cmp
        birelation_info["image_id"] = image_id
        birelation_info["InterConv"] = inter_conv_relation
        return birelation_info

    def filter_valid_filter(
        image_id,
        reconstruct_point_fn,
    ):
        original_dir = os.path.join(
                            saved_trace_dir,
                            f"original_{transform_name}",
                            f"{class_id}",
        )
        adversarial_dir = os.path.join(
                            saved_trace_dir,
                            f"{attack_name}_{transform_name}",
                            f"{class_id}",
        )

        original_path = os.path.join(
                            original_dir,
                            f"{image_id}.pkl",
        )
        adversarial_path = os.path.join(
                            adversarial_dir,
                            f"{image_id}.pkl",
        )
        if not os.path.exists(original_path) or \
            not os.path.exists(adversarial_path):
            return {}
        with open(original_path, "rb") as f:
            original_trace = pickle.load(f)
        with open(adversarial_path, "rb") as f:
            adversarial_trace = pickle.load(f)

        op_to_mask = {}
        for node_name in sorted(original_trace.nodes):
            if key in original_trace.nodes[node_name]:
                op_to_mask[node_name] = reconstruct_point_fn(
                                        node_name = node_name,
                                        trace = original_trace)

        op_to_valid_mask = {}
        for node_name in [
            "conv2d/Relu:0",
            "conv2d_1/Relu:0",
          ]:
            mask = op_to_mask[node_name]
            squeezed_mask = mask.sum(-1).sum(-1)
            nonzero_mask = squeezed_mask>0
            op_to_valid_mask[node_name] = nonzero_mask

        # for k in op_to_valid_mask:
        #     print(f"{k}: {op_to_valid_mask[k].shape}")
        return op_to_valid_mask

    ray_params = [
                    (image_id,
                     reconstruct_point_fn,
                     relation_op,
                     # op_to_reduced_mask,
                    )
                     for image_id in range(images_per_class)
                ]

    results = ray_iter(
        compute_relation_per_pair,
        ray_params,
        chunksize=1,
        out_of_order=True,
        huge_task=True,
    )
    results = [result for result in results if len(result)>0]
    print(f"Class {class_id} op {relation_op}: {len(results)}/{images_per_class} valid samples")
    relation_dir = os.path.join(result_dir, relation_op)
    os.makedirs(relation_dir, exist_ok=True)
    relation_path = os.path.join(relation_dir, f"{class_id}.pkl")
    with open(relation_path, "wb") as f:
        pickle.dump(results, f)


def compute_birelation_exp():
    relation_op = "or"
    for relation_op in [
        # "and",
        "or",
    ]:
        for class_id in range(10):
            # print(f"Class {class_id}")
            compute_birelation_class(
                class_id,
                images_per_class = images_per_class,
                relation_op = relation_op,
                result_dir = result_dir,
                saved_trace_dir = training_trace_dir,
            )



def analyse_birelation_exp():

    def analyse_birelation_class(
                                    class_id,
                                    images_per_class = 10,
                                    relation_op = "and", # and or or
                                    attack_name = "FGSM",
                                    transform_name = "noop",
                                    saved_trace_dir = f"{model_dir}/training_trace",
                                    birelation_dir = "result/test"
                                    ):
        path = os.path.join(birelation_dir, relation_op, f"{class_id}.pkl")
        if not os.path.exists(path):
            return
        with open(path, "rb") as f:
            birelation_info = pickle.load(f)

        hist_dir = os.path.join(birelation_dir, "hist")
        os.makedirs(hist_dir, exist_ok=True)

        # Intro conv
        for node_name in [
            "conv2d/Relu:0",
            "conv2d_1/Relu:0",
        ]:
            valid_number = len(birelation_info)
            birelation_op = [v["IntroConv"][node_name] for v in birelation_info]
            birelation_op = np.array(birelation_op).sum(0)
            satisfy_all = (birelation_op==valid_number).sum()
            # st()

            name = f"{relation_op}_{class_id}_{node_name.split('/')[0]}"
            hist_path = os.path.join(hist_dir, f"{name}.png")
            hists = [op for op in birelation_op if op>0]
            print(f"Class:{class_id} relation:{relation_op} node:{node_name} satisfy:{satisfy_all}/{len(hists)}")

            if len(hists)>0:
                bins = max(hists)
                bins = min(bins, 10)
                plt.hist(
                    hists,
                    bins=bins,
                )
                plt.title(f"Total {valid_number}")
                # plt.legend()
                plt.xlabel("Appearance number in training images")
                plt.ylabel("Count")
                plt.savefig(hist_path)
                plt.clf()

        # Inter conv
        inter_conv = [v["InterConv"] for v in birelation_info]
        inter_conv = np.array(inter_conv).sum(0)
        hists = [op for op in inter_conv if op>0]
        name = f"{relation_op}_{class_id}_interconv"
        hist_path = os.path.join(hist_dir, f"{name}.png")
        if len(hists)>0:
            bins = max(hists)
            bins = min(bins, 10)
            plt.hist(
                hists,
                bins=bins,
            )
            plt.title(f"Total {valid_number}")
            # plt.legend()
            plt.xlabel("Appearance number in training images")
            plt.ylabel("Count")
            plt.savefig(hist_path)
            plt.clf()

    for relation_op in [
        # "and",
        "or",
    ]:
        for class_id in range(10):
            # print(f"Class {class_id}")
            analyse_birelation_class(
                class_id,
                images_per_class = images_per_class,
                relation_op = relation_op,
                birelation_dir = result_dir,
                saved_trace_dir = training_trace_dir,
            )


def analyse_channel_info_exp():

    def analyse_channel_per_class(
        class_id,
        images_per_class = 10,
        relation_op = "or", # and or or
        attack_name = "FGSM",
        transform_name = "noop",
        saved_trace_dir = f"{model_dir}/training_trace",
        birelation_dir = "result/test"
    ):
        path = os.path.join(birelation_dir, relation_op, f"{class_id}.pkl")
        if not os.path.exists(path):
            return
        with open(path, "rb") as f:
            birelation_info = pickle.load(f)

        hist_dir = os.path.join(birelation_dir, "channel_hist")
        os.makedirs(hist_dir, exist_ok=True)
        # Intro conv
        for node_name, bins in [
            ("conv2d/Relu:0", 6),
            ("conv2d_1/Relu:0", 16),
        ]:
            valid_number = len(birelation_info)
            channel_op = [v["Channel"][node_name] for v in birelation_info]

            hists = [
                v
                for channel in channel_op
                for v in list(channel.nonzero()[0])
            ]
            name = f"{class_id}_{node_name.split('/')[0]}"
            hist_path = os.path.join(hist_dir, f"{name}.png")

            if len(hists)>0:

                plt.hist(
                    hists,
                    bins=bins,
                )
                plt.title(f"Total {valid_number}")
                # plt.legend()
                plt.xlabel("Channel Index")
                plt.ylabel("Count")
                plt.savefig(hist_path)
                plt.clf()

    def analyse_channel_all_dataset(
        images_per_class = 10,
        relation_op = "or", # and or or
        attack_name = "FGSM",
        transform_name = "noop",
        saved_trace_dir = f"{model_dir}/training_trace",
        birelation_dir = "result/test"
    ):

        total_number = 0
        hist_dir = os.path.join(birelation_dir, "channel_hist")
        os.makedirs(hist_dir, exist_ok=True)
        # Intro conv
        for node_name, bins in [
            ("conv2d/Relu:0", 6),
            ("conv2d_1/Relu:0", 16),
        ]:
            hist_acc = []
            for class_id in range(10):
                path = os.path.join(birelation_dir, relation_op, f"{class_id}.pkl")
                if not os.path.exists(path):
                    return
                with open(path, "rb") as f:
                    birelation_info = pickle.load(f)

                total_number += len(birelation_info)
                channel_op = [v["Channel"][node_name] for v in birelation_info]

                hists = [
                    v
                    for channel in channel_op
                    for v in list(channel.nonzero()[0])
                ]
                hist_acc += hists

            name = f"all_{node_name.split('/')[0]}"
            hist_path = os.path.join(hist_dir, f"{name}.png")

            if len(hists)>0:

                plt.hist(
                    hist_acc,
                    bins=bins,
                )
                plt.title(f"Total {total_number}")
                # plt.legend()
                plt.xlabel("Channel Index")
                plt.ylabel("Count")
                plt.savefig(hist_path)
                plt.clf()


    # for class_id in range(10):
    #     # print(f"Class {class_id}")
    #     analyse_channel_per_class(
    #         class_id,
    #         relation_op = "or",
    #         images_per_class = images_per_class,
    #         birelation_dir = result_dir,
    #         saved_trace_dir = training_trace_dir,
    #     )
    analyse_channel_all_dataset(
        relation_op = "or",
        images_per_class = images_per_class,
        birelation_dir = result_dir,
        saved_trace_dir = training_trace_dir,
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

    # compute_birelation_exp()
    # analyse_birelation_exp()

    # compute_birelation_exp()
    analyse_channel_info_exp()
