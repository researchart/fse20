import os, sys
import numpy as np
import pickle
import scipy
from pdb import set_trace as st

import sklearn.metrics as metrics
from sklearn import tree
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


def load_neuron(
    attack_name,
    class_id,
    image_id,
):
    dataset_split="test"
    transform_name = "noop"
    
    # path config
    # pos and neg
    per_image_trace_dir = f"{model_dir}/nninst_mu_posneg/per_image_trace_0.5_sum0.2_bar0.01-v1"
    result_dir = f"{model_dir}/nninst_mu_posneg/posneg_full_logics_{threshold}"
    reconstruct_from_trace_fn = reconstruct_point_from_trace_contrib
    mask_to_logic_fn = posneg_channel_activation

    # only pos, raw method
    # per_image_trace_dir = f"{model_dir}/nninst_mu_posneg/per_image_trace_0.5_posonly"
    # result_dir = f"{model_dir}/nninst_mu_posneg/posonly_logics_{threshold}"
    # reconstruct_from_trace_fn = reconstruct_point_from_trace
    # mask_to_logic_fn = pos_channel_activation


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
    # io = IOAction(original_path, None, False, True)
    # original_trace = io.load()
    
    prediction = original_trace.attrs[GraphAttrKey.PREDICT]
    print(f"{attack_name} prediction={prediction}")
    valid_names = filter_valid_names(original_trace)
    original_masks = reconstruct_point_from_trace_contrib(
            original_trace,
            graph,
            "conv2d_11/Conv2D:0",
            TraceKey.POINT,
        )
    
    # mask = original_masks["conv2d_11"]
    
    return original_masks

def load_image(
    attack_name,
    class_id,
    image_id,
):
    path = os.path.join(
        model_dir,
        "attack", "test",
        attack_name,
        str(class_id),
        f"{image_id}.pkl"
    )
    io = IOAction(path, None, False, True)
    img = io.load()

    return img.squeeze()

def load_pair(
    attack_name,
    class_id,
    image_id,
):
    
    feature = load_neuron(
        attack_name, class_id, image_id,
    )
    
    shape = feature.shape
    feature = feature.reshape(shape[0], shape[1]*shape[2]).transpose()
    
    
    # feature = scipy.misc.imresize(feature, (shape[0]*3, shape[1]))
    
    img = load_image(
        attack_name, class_id, image_id,
    )
    return (img, feature, attack_name)

def name_to_figname(name):
    if name=="original":
        return "Normal"
    else:
        return "Adversarial"
def plot_slice(
    attack_names,
    class_id,
    image_id,
    data_config=[[TraceKey.WEIGHT, "unary"]],
):
    
    figs = []
    for name in attack_names:
        pair = load_pair(name, class_id, image_id)
        figs.append(pair)
    
    # ax.tick_params(
    #     axis='x',          # changes apply to the x-axis
    #     which='both',      # both major and minor ticks are affected
    #     bottom=False,      # ticks along the bottom edge are off
    #     top=False,         # ticks along the top edge are off
    #     labelbottom=False) # labels along the bottom edge are off
    fig=plt.figure(figsize=(4,4))
    columns = 12
    rows = len(figs) * 6
    for i, item in enumerate(figs):
        img, feature, attack_name = item
        
        
        ax = plt.subplot2grid((rows, columns), (i*6, 0), rowspan=6, colspan=4)
        ax.set_xticks([], [])
        ax.set_yticks([], [])
        ax.imshow(img)
        # ax.axis('off')
        
        
        # ax.text(-0.1, 0.7, f"{name_to_figname(attack_name)}", ha="center", 
        #         transform=ax.transAxes, rotation=90)
        # if i == len(figs)-1:
        #     ax.text(0.5, -0.2, f"Sample", ha="center", 
        #         transform=ax.transAxes)
        
        j=0
        ax = plt.subplot2grid((rows, columns), (i*6+1, 4), rowspan=2, colspan=8)
        ax.set_xticks([], [])
        ax.set_yticks([], [])
        seg_len = int(feature.shape[1] / 2)
        ax.imshow(feature[:,j*seg_len:(j+1)*seg_len], cmap="seismic", vmin=-1, vmax=1 )
            
        j=1
        ax = plt.subplot2grid((rows, columns), (i*6+3, 4), rowspan=2, colspan=8)
        ax.set_xticks([], [])
        ax.set_yticks([], [])
        seg_len = int(feature.shape[1] / 2)
        ax.imshow(feature[:,j*seg_len:(j+1)*seg_len], cmap="seismic", vmin=-1,vmax=1 )
        # if i == len(figs)-1:
        #     ax.text(0.5, -0.4, f"Slice", ha="center", 
        #         transform=ax.transAxes)
            


    # fig.tight_layout()
    fig.suptitle(f"Slice Visualization of Adversarial Examples")
    fig.subplots_adjust(top=0.88)
    
    # plt.imshow(img)
    path = os.path.join(model_dir, f"cmp_feature.pdf")
    plt.savefig(path)

plot_slice(
    [
        "original", 
        # "FGSM_2",
        "Boundary"
    ],
    0, 1)

plot_slice(
    [
        "original", 
        # "FGSM_2",
        "Boundary"
    ],
    5, 3)
