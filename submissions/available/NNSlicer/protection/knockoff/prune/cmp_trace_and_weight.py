#!/usr/bin/python
"""This is a short description.
Replace this with a more detailed description of what this file contains.
"""
import argparse
import json
import os
import os.path as osp
import pickle
from datetime import datetime
import random
import pandas as pd
import copy
from functools import partial
from pdb import set_trace as st

import numpy as np
import torch
import torch.nn as nn
from PIL import Image
from torch.utils.data import Dataset
from torch import optim
from torchvision.datasets.folder import ImageFolder, IMG_EXTENSIONS, default_loader
from torch.utils.data import Dataset, DataLoader
import torchvision.models as torch_models

from knockoff.prune.tf_model import *
from knockoff.adversary.protect_model import *

prune_allconv_select_modes = [
    "posnegweight_small",
    "posonlyweight_small",
    # "edgeweight_small",
    # "random",
]


def select_conv_weight_ratio(
    class_logics,
    layer_name,
    model,
    select_mode = "posneg_large",
    ratio = 0,
):
    
    if (("posnegweight" in select_mode) or ("posonlyweight" in select_mode)):
        weight_cnt = class_logics[layer_name]
        shape = weight_cnt.shape
        begin_num = int(np.prod(shape) * ratio)
        end_num = int(np.prod(shape) * (ratio+0.1))
        largest_index = (-weight_cnt).flatten().argsort()[begin_num:end_num]
        smallest_index = weight_cnt.flatten().argsort()[begin_num:end_num]
        
        if "large" in select_mode:
            return largest_index
        elif "small" in select_mode:
            return smallest_index
        else:
            raise RuntimeError("Not implement")
    elif (("edgeweight" in select_mode) ):
        conv = layer_tf_to_torch[layer_name](model)
        weight = conv.weight.abs()
        shape = weight.shape
        begin_num = int(np.prod(shape) * ratio)
        end_num = int(np.prod(shape) * (ratio+0.1))
        largest_index = (-weight).flatten().argsort()[begin_num:end_num]
        smallest_index = weight.flatten().argsort()[begin_num:end_num]
        
        if "large" in select_mode:
            return largest_index.numpy()
        elif "small" in select_mode:
            return smallest_index.numpy()
        else:
            raise RuntimeError("Not implement")
    elif select_mode == "random":
        conv = layer_tf_to_torch[layer_name](model)
        shape = conv.weight.shape
        total_num = np.prod(shape) * 0.1
        # shape = weight.shape
        # total_num = select_number * shape[-1] * shape[-2] * shape[-3]
        # indexes = np.random.choice(weight.flatten().shape[0], total_num)
        
        indexes = np.random.choice(np.prod(shape), total_num)
        return indexes
    else:
        raise RuntimeError("Not implement")
    

    
def cmp_class_trace_and_weight(
    model, class_id, out_path,
):
    for mode in prune_allconv_select_modes:
        class_trace = load_class_logics(
            mode.split('_')[0],
            class_id
        )
        
        for ratio in np.arange(0, 1, 0.1):
            intersections = {}
            for layer_name in layer_names:
                if layer_name == "conv2d_10" and "posonlyweight" in mode:
                    continue
                trace_selected_index = select_conv_weight_ratio(
                    class_logics=class_trace,
                    layer_name=layer_name,
                    model=model,
                    select_mode=mode, 
                    ratio=ratio,
                )
                weight_index = select_conv_weight_ratio(
                    class_logics=class_trace,
                    layer_name=layer_name,
                    model=model,
                    select_mode="edgeweight_small", 
                    ratio=ratio,
                )
                intersection = np.intersect1d(
                    trace_selected_index,
                    weight_index,
                    assume_unique=True,
                )
                intersect_num = intersection.shape[0]
                intersect_ratio = intersect_num / trace_selected_index.shape[0]
                intersections[layer_name] = intersect_ratio
            values = list(intersections.values())
            intersections["amean"] = np.mean(values)
            print(f"class {class_id} {mode} ratio={ratio:.1f} intersect={intersections['amean']:.2f}")
            
                
        
if __name__=="__main__":
    np.random.seed(3)
    random.seed(3)
    torch.manual_seed(3)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False
    
    model = get_transferred_pytorch_model()
    # model = model.cuda()
    
    for class_id in ["all"] + list(range(10)):
        cmp_class_trace_and_weight(
            model,
            class_id=class_id,
            out_path=None,
        )