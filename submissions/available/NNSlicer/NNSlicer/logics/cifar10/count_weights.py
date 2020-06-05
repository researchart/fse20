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
from logics.save_logics import *

threshold = 0.9
dilation_iter = 1
dilation_structure = ndimage.generate_binary_structure(2, 2)
# Model config
model_label = "dropout"
model_dir = f"result/resnet10cifar10/model_{model_label}"


# path config
# pos and neg
# per_image_trace_dir = f"{model_dir}/nninst_mu_posneg/per_image_trace_0.5_sum0.2_bar0.01"
# logic_dir = f"{model_dir}/nninst_mu_posneg/posneg_edge_{threshold}"
# reconstruct_from_trace_fn = reconstruct_weight_from_trace_contrib
# mask_to_logic_fn = posneg_weight

# only pos, raw method
per_image_trace_dir = f"{model_dir}/nninst_mu_posneg/per_image_trace_0.5_posonly"
logic_dir = f"{model_dir}/nninst_mu_posneg/posonly_edge_{threshold}"
reconstruct_from_trace_fn = reconstruct_weight_from_trace
mask_to_logic_fn = posneg_weight


train_images_per_class = 1000
logic_filter_thred_ratio = 0.1
# test_images_per_class = 500
attack_name = "FGSM"

attacks = {
    "FGSM": [FGSM],
    "BIM": [IterativeGradientSignAttack],
    "JSMA": [SaliencyMapAttack],
    "DeepFool": [DeepFoolAttack],
    # "DeepFool_full": [DeepFoolAttack, dict(subsample=None)],
    # "CWL2": [CarliniL2],
}

logic_filter_thred = {
    "unary": 0.1,
    "binary": 0.1,
    "triadic": 0.05,
}

def print_logic_per_class(logics):
    for key in sorted(logics.keys()):
        print(f"{key}: {logics[key]}")
        
def count_logics(
    logic_name,
    trace_key,
):
    def load_logics(
        class_id,
        image_id,
        transform_name = "noop",
    ):
        dataset_split = "train"
        path = logic_save_path(
            logic_dir,
            trace_key,
            logic_name,
            dataset_split,
            "original",
            transform_name,
            class_id,
            image_id,
        )
        if not os.path.exists(path):
            return {}
        with open(path, "rb") as f:
            logics = pickle.load(f)
        return logics

    def logic_plot_hist_save(
        logics,
        hist_path,
        filter_count,
    ):
        thred_filter = (logics > filter_count).astype(np.uint8)
        sparse_thred_filter = SparseMask(thred_filter)
        # with open(filter_save_path, "wb") as f:
        #     pickle.dump(sparse_logic_filter, f)

        nonzero_filter = (logics > 0).astype(np.uint8)
        sparse_nonzero_filter = SparseMask(nonzero_filter)
        # with open(nonzero_save_path, "wb") as f:
        #     pickle.dump(sparse_nonzero_filter, f)

        hists = logics.flatten().tolist()
        hists = [v for v in hists if v > filter_count]
        nonzero_ratio = len(hists) / logics.size
        zero_ratio = 1 - nonzero_ratio
        nonzero_count = len(hists)
        zero_count = logics.size - nonzero_count
        if len(hists)>0:

            bins = int(max(hists))
            bins = min(bins, 10)
            plt.hist(
                hists,
                bins=bins,
            )
            plt.title(
                f"Total {logics.size}, "
                f"under {filter_count}: {zero_count}({zero_ratio:.2f}), "
                f"above: {nonzero_count}({nonzero_ratio:.2f})"
            )
            # plt.legend()
            plt.xlabel("Appearance number in training images")
            plt.ylabel("Logic Number")
            plt.savefig(hist_path)
            plt.clf()

        return sparse_thred_filter, sparse_nonzero_filter

    hist_dir = os.path.join(
        logic_dir,
        trace_key,
        f"{logic_name}",
        "hists",
    )
    os.makedirs(hist_dir, exist_ok=True)
    thred_dir = os.path.join(
        logic_dir,
        trace_key,
        f"{logic_name}",
        "logic_filter"
    )
    os.makedirs(thred_dir, exist_ok=True)
    nonzero_dir = os.path.join(
        logic_dir,
        trace_key,
        f"{logic_name}",
        "nonzero_filter"
    )
    os.makedirs(nonzero_dir, exist_ok=True)
    raw_dir = os.path.join(
        logic_dir,
        trace_key,
        f"{logic_name}",
        "raw_logics"
    )
    os.makedirs(raw_dir, exist_ok=True)

    node_to_logics = {}
    for class_id in range(10):
        os.makedirs(os.path.join(hist_dir, f"{class_id}"), exist_ok=True)
        params = [
            (
                class_id,
                image_id,
            )
            for image_id in range(train_images_per_class)
        ]
        results = ray_iter(
            load_logics,
            params,
            chunksize=1,
            out_of_order=True,
            huge_task=True,
        )
        results = [result for result in results if len(result)>0]
        
        thred_filter_per_class = {}
        nonzero_filter_per_class = {}
        raw_feature_per_class = {}
        for node_name in results[0].keys():
            shape = results[0][node_name].mask.shape
            logics_acc = np.zeros(shape)
            
            for result in results:
                if len(result) < 14:
                    continue
                # if node_name == "conv2d_10" and node_name not in result:
                #     st()
                logic = result[node_name].to_tensor()
                logics_acc += abs(logic)
            if class_id==0:
                node_to_logics[node_name] = logics_acc.copy()
            else:
                node_to_logics[node_name] += logics_acc

            name = f"{class_id}/{node_name.split(':')[0].split('/')[0]}"
            
            hist_path = os.path.join(
                hist_dir,
                f"{name}.png",
            )

            filter_count = (logic_filter_thred[logic_name] *
                            train_images_per_class)
            
            sparse_thred_filter, sparse_nonzero_filter = logic_plot_hist_save(
                logics_acc,
                hist_path,
                filter_count,
            )
            thred_filter_per_class[node_name] = sparse_thred_filter
            nonzero_filter_per_class[node_name] = sparse_nonzero_filter
            raw_feature_per_class[node_name] = logics_acc
        # print_logic_per_class(thred_filter_per_class)
        # st()

        thred_path = os.path.join(
            thred_dir,
            f"{class_id}.pkl",
        )
        with open(thred_path, "wb") as f:
            pickle.dump(thred_filter_per_class, f)
        nonzero_path = os.path.join(
            nonzero_dir,
            f"{class_id}.pkl"
        )
        with open(nonzero_path, "wb") as f:
            pickle.dump(nonzero_filter_per_class, f)
        raw_path = os.path.join(
            raw_dir,
            f"{class_id}.pkl",
        )
        with open(raw_path, "wb") as f:
            pickle.dump(raw_feature_per_class, f)


    thred_filter_all = {}
    nonzero_filter_all = {}
    os.makedirs(os.path.join(hist_dir, f"all"), exist_ok=True)
    for node_name in results[0].keys():
        name = f"all/{node_name.split(':')[0].split('/')[0]}"
        hist_path = os.path.join(
            hist_dir,
            f"{name}.png",
        )

        filter_count = (logic_filter_thred[logic_name] * 10 *
                        train_images_per_class)
        dataset_logics = node_to_logics[node_name]
        sparse_thred_filter, sparse_nonzero_filter = logic_plot_hist_save(
            dataset_logics,
            hist_path,
            filter_count,
        )
        thred_filter_all[node_name] = sparse_thred_filter
        nonzero_filter_all[node_name] = sparse_nonzero_filter
    thred_path = os.path.join(
        thred_dir,
        f"all.pkl",
    )
    with open(thred_path, "wb") as f:
        pickle.dump(thred_filter_all, f)
    nonzero_path = os.path.join(
        nonzero_dir,
        f"all.pkl",
    )
    with open(nonzero_path, "wb") as f:
        pickle.dump(nonzero_filter_all, f)
    raw_path = os.path.join(
        raw_dir,
        f"all.pkl",
    )
    with open(raw_path, "wb") as f:
        pickle.dump(node_to_logics, f)


def count_logics_exp():

    count_logics(
        logic_name="unary",
        trace_key=TraceKey.WEIGHT,
    )

if __name__=="__main__":
    mode.debug()
    # mode.local()

    # ray_init("gpu")
    ray_init(
        log_to_driver=False,
        # num_cpus = 10,
    )

    tf.set_random_seed(3)
    np.random.seed(3)
    random.seed(3)

    count_logics_exp()
