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

import knockoff.adversary.resnet10_protect_model as resnet10_protect_model
import knockoff.adversary.resnet18_protect_model as resnet18_protect_model

valid_select_modes = [
    "posnegweight_large", "posnegweight_small",
    "posonlyweight_large", "posonlyweight_small",
    "posnegchannel_large", "posnegchannel_small",
    # "posonly_large", "posonly_small",
    "edgeweight_large", "edgeweight_small",
    "channelweight_large", "channelweight_small",
    "randomweight_large", "randomweight_small",
    "randomchannel_large", "randomchannel_small",
    "edgeweight_small_avg",
    "posnegweight_small_all", "posnegweight_large_all",
    "posnegweight_small_subset", "posnegweight_large_subset",
    "posonlyweight_small_subset", "posonlyweight_large_subset",
    "posonlyweight_small_all",
]


def clear_conv(
    conv,
    index,
    select_mode,
):
    if (("posnegweight" in select_mode) or 
        ("edgeweight" in select_mode) or
        ("randomweight" in select_mode) or
        ("posonlyweight" in select_mode)):
        shape = conv.weight.shape
        weight = conv.weight.flatten()
        weight[index] = .0
        weight = weight.reshape(shape)
    if (("posnegchannel" in select_mode) or 
        ("channelweight" in select_mode) or
        ("randomchannel" in select_mode)):
        conv.weight.data[index] = .0
        # conv.weight = weight

    return conv


def select_by_ratio(
    class_logics,
    layer_name,
    target_conv,
    select_mode = "posneg_large",
    select_ratio = 0.1,
):
    assert select_mode in valid_select_modes
 
    if (("posnegweight" in select_mode) or ("posonlyweight" in select_mode)):

        weight_cnt = class_logics[layer_name]
        shape = weight_cnt.shape
        total_num = int(np.prod(shape) * select_ratio)
        largest_index = (-weight_cnt).flatten().argsort()[:total_num]
        smallest_index = weight_cnt.flatten().argsort()[:total_num]
        
        if "large" in select_mode:
            return largest_index
        elif "small" in select_mode:
            return smallest_index
        else:
            raise RuntimeError("Not implement")
        
    if ("posnegchannel" in select_mode):
        feature = class_logics["initial_conv" if layer_name == "conv2d" else layer_name]
        size = feature.shape[0]
        select_number = int(size * select_ratio)
        if "posneg" in select_mode:
            feature = feature[int(size/2):] + feature[:int(size/2)] 
        largest_index = (-feature).argsort()[:select_number]
        smallest_index = feature.argsort()[:select_number]
        
        if "large" in select_mode:
            # print(f"select result {largest_index}")
            return largest_index
        elif "small" in select_mode:
            # print(f"select result {smallest_index}")
            return smallest_index
        else:
            raise RuntimeError("Not implement")
        
    if "channelweight" in select_mode:
        size = target_conv.weight.shape[0]
        select_number = int(size * select_ratio)
        weight_count = target_conv.weight.abs().sum(-1).sum(-1).sum(-1)
        largest_index = (-weight_count).flatten().argsort()[:select_number]
        smallest_index = weight_count.flatten().argsort()[:select_number]
        
        if "large" in select_mode:
            return largest_index
        elif "small" in select_mode:
            return smallest_index
        else:
            raise RuntimeError("Not implement")
    if ("edgeweight" in select_mode):
        weight = target_conv.weight.abs()
        shape = weight.shape
        total_num = int(np.prod(shape) * select_ratio)
        largest_index = (-weight).flatten().argsort()[:total_num]
        smallest_index = weight.flatten().argsort()[:total_num]
        
        if "large" in select_mode:
            return largest_index
        elif "small" in select_mode:
            return smallest_index
        else:
            raise RuntimeError("Not implement")
    if "randomweight" in select_mode:
        weight = target_conv.weight
        shape = weight.shape
        total_num = int(np.prod(shape) * select_ratio)
        # indexes = np.random.choice(weight.flatten().shape[0], total_num)
        index = np.random.choice(np.prod(weight.shape), total_num)
        
        return index
    if "randomchannel" in select_mode:
        weight = target_conv.weight
        shape = weight.shape
        total_num = int(select_ratio * shape[0])
        # indexes = np.random.choice(weight.flatten().shape[0], total_num)
        
        indexes = np.random.choice(shape[0], total_num)
        return indexes
    else:
        raise RuntimeError("Not implement")
    

def clear_model_fc(
    model, 
    arch = "resnet10",
    class_id = "all", 
    layer_name = "fc",
    select_mode = "posnegweight_large",
    select_ratio = 0,
):
    if arch == "resnet10":
        load_class_logics = resnet10_protect_model.load_class_logics
        load_multi_class_logics = resnet10_protect_model.load_multi_class_logics
        layer_tf_to_torch = resnet10_protect_model.layer_tf_to_torch
        refresh_model_conv = resnet10_protect_model.refresh_model_conv
    elif arch == "resnet18":
        load_class_logics = resnet18_protect_model.load_class_logics
        load_multi_class_logics = resnet18_protect_model.load_multi_class_logics
        layer_tf_to_torch = resnet18_protect_model.layer_tf_to_torch
        refresh_model_conv = resnet18_protect_model.refresh_model_conv
    else:
        raise NotImplementedError
        
    if "channel" in select_mode and layer_name == "dense":
        return model
    if "posneg" in select_mode or "posonly" in select_mode:
        if "posnegweight" in select_mode:
            logic_name = "posnegweight"
        elif "posnegchannel" in select_mode:
            logic_name = "posneg"
        elif "posonlyweight" in select_mode:
            logic_name = "posonlyweight"
        else:
            raise RuntimeError("Not Implement")
        if isinstance(class_id, int) or class_id == "all":
            class_logics = load_class_logics(
                logic_name,
                class_id
            )
        elif isinstance(class_id, tuple):
            class_logics = load_multi_class_logics(
                logic_name,
                class_id,
            )
            
    else:
        class_logics = None
    
    conv = layer_tf_to_torch[layer_name](model)
    channel_index = select_by_ratio(
        class_logics,
        layer_name,
        conv,
        select_ratio=select_ratio,
        select_mode=select_mode,
    )
    
    conv = clear_conv(
        conv,
        channel_index,
        select_mode,
    )
    model = refresh_model_conv(model, layer_name, conv)
    # new_weight = layer_tf_to_torch[layer_name](model).weight.data
    # diff = raw_weight != new_weight
    return model