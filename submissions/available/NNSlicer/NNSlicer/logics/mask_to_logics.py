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



class SparseMask:
    """
    Store sparse mask by index
    """
    def __init__(self, _mask):
        # self.pos_index = np.where(_mask > 0)
        # self.neg_index = np.where(_mask < 0)
        # self.index = _mask.nonzero()
        # self.shape = _mask.shape
        self.mask = _mask

    def to_tensor(self):
        # _tensor = np.zeros(self.shape).astype(np.int32)
        # _tensor[self.pos_index] = 1
        # _tensor[self.neg_index] = -1
        # return _tensor
        return self.mask

    def __repr__(self):
        info = (f"Sparse mask of shape: {self.mask.shape} ")
        return info


def posneg_channel_activation(
    masks,
):
    def reduce_mask(mask):
        if len(mask.shape) == 1:
            return mask
        elif len(mask.shape) == 3:
            # size = mask.shape[0]
            # channel = np.zeros(size*3)
            # channel[:size] = mask.sum(-1).sum(-1)
            # channel[size:2*size] = (mask<0).sum(-1).sum(-1)
            # channel[2*size:] = (mask>0).sum(-1).sum(-1)
            # channel[channel>0] = 1
            # channel[channel<0] = -1
            
            size = mask.shape[0]
            channel = np.zeros(size*2)
            channel[:size] = (mask<0).sum(-1).sum(-1)
            channel[size:] = (mask>0).sum(-1).sum(-1)
            # channel[channel>0] = 1
            # channel[channel<0] = -1
            return channel


    if isinstance(masks, np.ndarray):
        return reduce_mask(masks)
    elif isinstance(masks, Dict):
        channel_dict = {}
        for key in masks:
            channel = reduce_mask(masks[key])
            channel_dict[key] = SparseMask(channel)
        return channel_dict


def pos_channel_activation(
    masks,
):
    def reduce_mask(mask):
        if len(mask.shape) == 1:
            return mask
        elif len(mask.shape) == 3:

            channel_sum = mask.sum(-1).sum(-1)
            channel_sum[channel_sum>0] = 1
            channel_sum[channel_sum<0] = -1
            
            # channel_sum = mask.sum(-1).sum(-1)
            # channel_sum[channel_sum>0] = 1
            # channel_sum[channel_sum<0] = -1
            
            # mask_pos = mask.copy()
            # mask_pos[mask_pos<0] = 0
            # channel_pos = mask_pos.sum(-1).sum(-1)
            # channel_pos[channel_pos>0] = 1
            
            # mask_neg = mask.copy()
            # mask_neg[mask_neg>0] = 0
            # channel_neg = mask_neg.sum(-1).sum(-1)
            # channel_neg[channel_neg<0] = 1
            
            # channel = np.concatenate(
            #     (channel_pos, channel_neg)
            # )

            return channel_sum
    if isinstance(masks, np.ndarray):
        return reduce_mask(masks)
    elif isinstance(masks, Dict):
        channel_dict = {}
        for key in masks:
            channel = reduce_mask(masks[key])
            channel_dict[key] = SparseMask(channel)
        return channel_dict

def posneg_weight(
    masks,
):
    if isinstance(masks, np.ndarray):
        return masks
    elif isinstance(masks, Dict):
        channel_dict = {}
        for key in masks:
            channel_dict[key] = SparseMask(masks[key])
        return channel_dict

def _dilate_mask_2D(
    mask,
    dilation_iter = 1,
):
    """
    Args:
        mask: numpy ndarray of shape (c, h, w), binary mask of a feature map
    """
    assert (isinstance(mask, np.ndarray) and
            len(mask.shape) == 3)
    c, h, w = mask.shape
    sliced_mask = [
        mask[i] for i in range(c)
    ]
    dilated_slice = [
        ndimage.binary_dilation(
            m,
            # structure = dilation_structure,
            iterations = dilation_iter,
        ).astype(m.dtype)
        for m in sliced_mask
    ]
    dilated_slice = [
        np.expand_dims(m, 0)
        for m in dilated_slice
    ]
    dilated_mask = np.concatenate(
        dilated_slice
    )
    # print("2d dilated mask", dilated_mask)
    return dilated_mask

def intro_binary_logic(
    masks,
):
    """
    Mask to dilated intro-channel binary or-logic.
    Dilate mask -> compute or-logic
    """
    def _mask_or_logic(
        dilated_mask
    ):
        c, h, w = dilated_mask.shape
        or_logic = [
            [
                (
                    (dilated_mask[i]*dilated_mask[j]>0).any() and
                    i != j
                )
                for j in range(c)
            ]
            for i in range(c)
        ]
        or_logic = np.array(or_logic).astype(np.uint8)
        return or_logic

    if isinstance(masks, np.ndarray):
        dilated_mask = _dilate_mask_2D(masks)
        logics = _mask_or_logic(dilated_mask)
        return SparseMask(logics)
    elif isinstance(masks, dict):
        mask_logics = {}
        for k in masks:
            dilated_mask = _dilate_mask_2D(masks[k])
            logics = _mask_or_logic(dilated_mask)
            mask_logics[k] = SparseMask(logics)
        return mask_logics

def _hierarchy_dilate_mask(
    mask,
):
    """
    Args:
        mask: numpy ndarray of shape (c, h, w), binary mask of a feature map

    Returns:
        hierarchy dilated feature of shape (d, c, h, w)
    """
    assert (isinstance(mask, np.ndarray) and
            len(mask.shape) == 3)
    c, h, w = mask.shape
    max_dilation = h+w-1

    sliced_feature = [
        mask[i] for i in range(c)
    ]
    dilated_feature = [
        sliced_feature
    ]
    for d in range(max_dilation):
        new_sliced_feature = [
            ndimage.binary_dilation(
                f,
                # structure = dilation_structure,
                iterations = 1,
            ).astype(f.dtype)
            for f in dilated_feature[-1]
        ]
        dilated_feature.append(
            new_sliced_feature,
        )
    dilated_feature = [
        [
            np.expand_dims(f, 0)
            for f in sliced_feature_list
        ]
        for sliced_feature_list in dilated_feature
    ]
    dilated_feature = [
        np.concatenate(feature_list)
        for feature_list in dilated_feature
    ]
    dilated_feature = [
        np.expand_dims(f, axis=0)
        for f in dilated_feature
    ]
    dilated_feature = np.concatenate(
        dilated_feature
    )

    return dilated_feature

def _compute_channelwise_distance(
    dilated_feature,
):
    """
    Args:
        dilated_feature of shape (d, c, h, w)

    Returns:
        distance array of shape (c, c), [i, j] represents the distance
        between the i_th and j_th mask map of the original mask
    """
    d, c, h, w = dilated_feature.shape
    distance_array = np.zeros((c, c))

    for i in range(c):
        for j in range(c):
            mask1 = dilated_feature[0,i]
            mask2 = dilated_feature[0,j]

            if mask1.sum()==0 or mask2.sum()==0:
                distance_array[i,j] = -1
                continue
            for k in range(d):
                dilated_mask1 = dilated_feature[k, i]
                mask2 = dilated_feature[0, j]
                if (dilated_mask1*mask2).sum()>0:
                    distance_array[i,j] = k
                    break
    # print("Distance array", distance_array)
    return distance_array

def _compute_intro_triadic_logics(
    mask,
):
    """
    Args:
        binary mask of shape (c, h, w)

    Returns:
        triadic logic array of shape (c^3)
    """
    c, h, w = mask.shape
    dilated_feature = _hierarchy_dilate_mask(mask)
    distance_array = _compute_channelwise_distance(dilated_feature)

    triadic_array = np.zeros((c, c, c))
    for i in range(c):
        for j in range(c):
            for k in range(c):
                if (
                    (
                        i != j and i != k and j != k
                    ) and
                    (
                        distance_array[i,j]>-1 and
                        distance_array[i,k]>-1
                    ) and
                    distance_array[i,j] < distance_array[i,k]
                ):
                    triadic_array[i,j,k] = 1

    # print(f"triadic array {triadic_array.sum()}/{triadic_array.size}")
    return triadic_array

def intro_triadic_logic(
    masks,
):
    """
    Mask to dilated intro-channel binary or-logic.
    Dilate mask -> compute triadic logic
    """
    if isinstance(masks, np.ndarray):
        return _compute_intro_triadic_logics(masks)
    elif isinstance(masks, dict):
        mask_logics = {
            k: SparseMask(
                _compute_intro_triadic_logics(masks[k])
            )
            for k in masks
        }
        return mask_logics

def create_test_mask():
    a = np.zeros((4, 5, 5))
    a[0,1,1] = 1
    a[1,4,4] = 1
    a[3,2,2] = 1
    a[3,0,2] = 1
    d = {"k": a}
    print("Test input")
    print(d)
    return d

def test_channel_activation():
    a = create_test_mask()
    channel = channel_activation(a)
    print("Channel")
    print(channel)

def test_intro_binary_logic():
    a = create_test_mask()
    binary_logic = intro_binary_logic(a)
    print("Intro binary logic")
    print(binary_logic)
    print("To tensor")
    for k in binary_logic:
        print(binary_logic[k].to_tensor())

def test_intro_triadic_logic():
    a = create_test_mask()
    triadic_logic = intro_triadic_logic(a)
    print("Triadic logic", triadic_logic)
    for k in triadic_logic:
        print(triadic_logic[k].to_tensor())

if __name__=="__main__":
    test_intro_triadic_logic()
