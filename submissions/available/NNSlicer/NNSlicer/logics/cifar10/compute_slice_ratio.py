import os, sys
import numpy as np
import pickle
import scipy
from pdb import set_trace as st
import sklearn.metrics as metrics
from sklearn import tree
import pydotplus
from sklearn.ensemble import (
    AdaBoostClassifier,
    GradientBoostingClassifier,
    RandomForestClassifier,
)
import scipy.ndimage as ndimage
import matplotlib.pyplot as plt
plt.switch_backend('Agg')

from logics.cifar10.train_classifier_weights import *
from nninst_utils.fs import IOAction

# Model config
model_label = "dropout"
model_dir = f"result/resnet10cifar10/model_{model_label}"





def compute_slice(
    attack_name,
    class_id,
    image_id,
):
    dataset_split="train"
    transform_name = "noop"
    
    # path config
    # pos and neg
    per_image_trace_dir = f"{model_dir}/nninst_mu_posneg/per_image_trace_0.5_sum0.1_bar0.01"
    result_dir = f"{model_dir}/nninst_mu_posneg/posneg_full_logics_{threshold}"
    reconstruct_from_trace_fn = reconstruct_point_from_trace_contrib
    mask_to_logic_fn = posneg_channel_activation

    # only pos, raw method
    # per_image_trace_dir = f"{model_dir}/nninst_mu_posneg/per_image_trace_0.5_posonly"
    # result_dir = f"{model_dir}/nninst_mu_posneg/posonly_logics_{threshold}"
    # reconstruct_from_trace_fn = reconstruct_point_from_trace
    # mask_to_logic_fn = pos_channel_activation
    
    def image_trace_path(
        trace_dir,
        dataset_split,
        attack_name,
        transform_name,
        class_id,
        image_id,
    ):
        path = os.path.join(
            f"{trace_dir}",
            f"{dataset_split}",
            f"{attack_name}_{transform_name}",
            f"{class_id}",
            f"{image_id}.pkl",
        )
        return path

    def reconstruct_point_fn(
        trace,
        valid_names,
    ):
        node_names = []
        key = TraceKey.POINT
        for attr_name, attr in trace.nodes.items():
            if key in attr:
                node_names.append(attr_name)
        
        point_dict = {}
        for node_name in valid_names:
            filtered_name = node_name.split(':')[0].split('/')[0]
            # if filtered_name == "final_dense":
            #     st()
            
            point_dict[filtered_name] = reconstruct_from_trace_fn(
                trace,
                graph,
                node_name,
            )
            # print(node_name, point_dict[node_name].shape)
        return point_dict

    def filter_valid_names(trace):
        point_trace = {}
        for attr_name, attr in trace.nodes.items():
            if TraceKey.POINT in attr:
                point_trace[attr_name] = attr
        point_names = set(point_trace.keys())
        valid_names = []

        valid_names += [
            name for name in point_trace.keys() if name.find('conv') != -1
        ]

        point_names -= set(valid_names)
        return valid_names


    # print(f"Class {class_id} image {image_id}")
    original_path = image_trace_path(
        per_image_trace_dir,
        dataset_split,
        attack_name,
        transform_name,
        class_id,
        image_id,
    )
    
    if ( not os.path.exists(original_path)):
        return {}

    with open(original_path, "rb") as f:
        original_trace = pickle.load(f)
    prediction = original_trace.attrs[GraphAttrKey.PREDICT]
    print(f"{attack_name} prediction={prediction}")
    valid_names = filter_valid_names(original_trace)
    masks = reconstruct_point_fn(
        original_trace,
        valid_names,
    )
    
    all_cnt, slice_cnt = 0, 0
    
    for key in masks.keys():
        m = masks[key]
        slice_cnt += np.count_nonzero(m)
        all_cnt += np.prod(m.shape)
        
    ratio = slice_cnt / all_cnt
    print(f"Ratio {ratio}")
    



compute_slice(
    "original", 
    1, 0
    )
