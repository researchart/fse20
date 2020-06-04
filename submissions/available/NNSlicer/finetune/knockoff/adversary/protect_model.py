import argparse
import json
import os
import os.path as osp
import pickle
import math
from datetime import datetime
from pdb import set_trace as st

import numpy as np
import torch
from PIL import Image
from torch.utils.data import Dataset
from torch import optim
from torchvision.datasets.folder import ImageFolder, IMG_EXTENSIONS, default_loader

nninst_dir = "NNSlicing"
posneg_weight_dir = "result/resnet10cifar10/model_dropout/nninst_mu_posneg/posneg_edge_0.9/trace.weight/unary/raw_logics"
posonly_weight_dir = "result/resnet10cifar10/model_dropout/nninst_mu_posneg/posonly_edge_0.5/trace.weight/unary/raw_logics"
posneg_weight_dir = os.path.join(nninst_dir, posneg_weight_dir)
posonly_weight_dir = os.path.join(nninst_dir, posonly_weight_dir)

layer_tf_to_torch = {
    "conv2d": lambda m: m.conv1,
    "conv2d_1": lambda m: m.layer1[0].downsample[0],
    "conv2d_2": lambda m: m.layer1[0].conv1,
    "conv2d_3": lambda m: m.layer1[0].conv2,
    "conv2d_4": lambda m: m.layer2[0].downsample[0],
    "conv2d_5": lambda m: m.layer2[0].conv1,
    "conv2d_6": lambda m: m.layer2[0].conv2,
    "conv2d_7": lambda m: m.layer3[0].downsample[0],
    "conv2d_8": lambda m: m.layer3[0].conv1,
    "conv2d_9": lambda m: m.layer3[0].conv2,
    "conv2d_10": lambda m: m.layer4[0].downsample[0],
    "conv2d_11": lambda m: m.layer4[0].conv1,
    "conv2d_12": lambda m: m.layer4[0].conv2,
    "dense": lambda m: m.fc,
}

layer_to_feature_size = {
    "conv2d": 16,
    "conv2d_1": 16,
    "conv2d_2": 16,
    "conv2d_3": 16,
    "conv2d_4": 32,
    "conv2d_5": 32,
    "conv2d_6": 32,
    "conv2d_7": 64,
    "conv2d_8": 64,
    "conv2d_9": 64,
    "conv2d_10": 128,
    "conv2d_11": 128,
    "conv2d_12": 128,
    "dense": 128,
}

layer_names = layer_tf_to_torch.keys()

def refresh_model_conv(
    model, layer_name, conv
):
    if layer_name == "conv2d":
        model.conv1 = conv
    elif layer_name == "conv2d_1":
        model.layer1[0].downsample[0] = conv
    elif layer_name == "conv2d_2":
        model.layer1[0].conv1 = conv
    elif layer_name == "conv2d_3":
        model.layer1[0].conv2 = conv
    elif layer_name == "conv2d_4":
        model.layer2[0].downsample[0] = conv
    elif layer_name == "conv2d_5":
        model.layer2[0].conv1 = conv
    elif layer_name == "conv2d_6":
        model.layer2[0].conv2 = conv
    elif layer_name == "conv2d_7":
        model.layer3[0].downsample[0] = conv
    elif layer_name == "conv2d_8":
        model.layer3[0].conv1 = conv
    elif layer_name == "conv2d_9":
        model.layer3[0].conv2 = conv
    elif layer_name == "conv2d_10":
        model.layer4[0].downsample[0] = conv
    elif layer_name == "conv2d_11":
        model.layer4[0].conv1 = conv
    elif layer_name == "conv2d_12":
        model.layer4[0].conv2 = conv
    elif layer_name == "dense":
        model.fc = conv
    else:
        raise RuntimeError("Refresh model conv not implement")
    return model

def load_multi_class_logics(
    trace_mode,
    class_ids,
):
    assert isinstance(class_ids, tuple)
    class_logic = load_class_logics(
        trace_mode, 
        class_ids[0],
    )
    
    for class_id in class_ids[1:]:
        new_class_logic = load_class_logics(
            trace_mode, 
            class_id,
        )
        class_logic = {
            k: v + new_class_logic[k]
            for k, v in class_logic.items()
        }
        
    return class_logic
        
        
def load_class_logics(
    trace_mode,
    class_id
):
    if trace_mode == "posnegweight":
        logic_path = os.path.join(posneg_weight_dir, f"{class_id}.pkl")
    elif trace_mode == "posonlyweight":
        logic_path = os.path.join(posonly_weight_dir, f"{class_id}.pkl")
    else:
        raise RuntimeError("Not implement")
    with open(logic_path, 'rb') as f:
        class_logics = pickle.load(f)
    return class_logics
    
def reinit_conv_by_channel(
    conv,
    channel_index,
):
    n = conv.kernel_size[0] * conv.kernel_size[1] * conv.out_channels
    # raw_weight = conv.weight.data.clone()
    conv.weight.data[channel_index] = conv.weight.data[channel_index].normal_(0, math.sqrt(2. / n))
    # diff = raw_weight != conv.weight.data
    return conv

def select_channel(
    class_logics,
    layer_name,
    select_mode = "largest",
    select_number = 0,
):
    assert select_mode in ["largest", "smallest"]
    feature = class_logics[layer_name]
    largest_index = (-feature).argsort()[select_number:]
    smallest_index = feature.argsort()[:select_number]
    if select_mode == "largest":
        return largest_index
    elif select_mode == "smallest":
        return smallest_index
    else:
        raise RuntimeError("Not implement")
    
    
def protect_model(
    model, 
    class_id = "all", 
    layer_name = "conv2d_12",
    select_mode = "largest",
    select_number = 0,
):

    class_logics = load_class_logics("all")
    channel_index = select_channel(
        class_logics,
        layer_name,
        select_number=select_number,
        select_mode=select_mode,
    )
    
    # conv_activation[3] = 0
    # conv_activation[:] = 1
    conv = layer_tf_to_torch[layer_name](model)
    # raw_weight = conv.weight.data.clone()
    conv = reinit_conv_by_channel(
        conv,
        channel_index,
    )
    model = refresh_model_conv(model, layer_name, conv)
    # new_weight = layer_tf_to_torch[layer_name](model).weight.data
    # diff = raw_weight != new_weight
    return model
