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
from itertools import combinations

import numpy as np
import torch
import torch.nn as nn
from PIL import Image
from torch.utils.data import Dataset
from torch import optim
from torchvision.datasets.folder import ImageFolder, IMG_EXTENSIONS, default_loader
from torch.utils.data import Dataset, DataLoader
import torchvision.models as torch_models

import knockoff.config as cfg
import knockoff.utils.model as model_utils
from knockoff import datasets
import knockoff.models.zoo as zoo
# from knockoff.adversary.protect_model import *
from knockoff.prune.clear_channel import *
from knockoff.utils.model import test_step, test_step_single_class_f1_score
from knockoff.prune.tf_model import *

__author__ = "Tribhuvanesh Orekondy"
__maintainer__ = "Tribhuvanesh Orekondy"
__email__ = "orekondy@mpi-inf.mpg.de"
__status__ = "Development"


def filter_dataset(dataset, class_ids):
    idx = np.zeros(len(dataset.targets)).astype(np.bool)
    for id in class_ids:
        class_idx = np.array(dataset.targets) == id
        idx = np.logical_or(idx, class_idx)
    
    subset = copy.deepcopy(dataset)
    subset.targets = list(np.array(subset.targets)[idx])
    subset.data = subset.data[idx]
    return subset

    
def test_prune_allconv_ratio_subsetacc(
    model, resume, out_path, 
    batch_size=64, criterion_test=None, testset=None,
    device=None, num_workers=10, 
    class_id="all",
    **kwargs
):
    all_class_ids = list(range(10))
    max_combination = 10
    
    for combination_number in [2,3,4,5,6,7,8,9]:

        class_id_combination = list(combinations(all_class_ids, combination_number))
        clean_model = copy.deepcopy(model)
        
        results = []
        # Initialize logging
        log_path = osp.join(out_path, f"allconv_subset_{combination_number}.csv")
        
        test_combination = min(max_combination, len(class_id_combination))
        for cnt, class_ids in enumerate(class_id_combination[:test_combination]):
            
            dataset = filter_dataset(testset, class_ids)
            
            test_loader = DataLoader(dataset, batch_size=batch_size, shuffle=False, num_workers=num_workers)
            test_fn = partial(
                test_step,
                test_loader=test_loader,
                criterion = nn.CrossEntropyLoss(reduction='mean'),
                device=None,
            )
            
            prune_allconv_select_modes = [
                "posonlyweight_small_subset",
                # "posonlyweight_small_all",
                "posnegweight_small_all",
                "posnegweight_small_subset",
                "edgeweight_small",
                # "edgeweight_small_avg",
                # "channelweight_small",
                # "randomweight_small",
                
                
                # "randomchannel_small",
                # "posonlyweight_small",
                # "posonlychannel_small",
            ]
            if kwargs['model_arch'] == "resnet10":
                layer_names = resnet10_protect_model.layer_tf_to_torch.keys()
            elif kwargs['model_arch'] == "resnet18":
                layer_names = resnet18_protect_model.layer_tf_to_torch.keys()
            else:
                raise NotImplementedError

            for ratio in np.arange(0.2, 0.9, 0.1):
            # for ratio in np.arange(0.4, 0.7, 0.1):
                print(f"{class_ids}, {cnt}/{len(class_id_combination)}"
                    f"Conv prune ratio={ratio:.3f}, class {class_id}"
                )
                
                result = {
                    "classes": class_ids,
                    "ratio": round(ratio, 2),
                }
                
                with torch.no_grad():
                    for mode in prune_allconv_select_modes:
                        print(f"{mode}")
                        
                        exp_model = copy.deepcopy(clean_model)
                        if (("posneg" in mode) or 
                            ("avg" in mode) or 
                            ("posonly" in mode)
                        ):
                            exp_model = load_class_avg(exp_model, kwargs['model_arch'])

                        for layer_name in layer_names:
                            # if layer_name == "conv2d_10" and "posonlyweight" in mode:
                            #     replace_mode = "edgeweight_large"
                            # else:
                            replace_mode = mode                            
                            exp_model = clear_model_fc(
                                exp_model, 
                                arch=kwargs["model_arch"],
                                layer_name=layer_name,
                                select_mode=replace_mode,
                                select_ratio=ratio,
                                class_id= (
                                    "all" if (
                                        mode == "posnegweight_small_all" or
                                        mode == "posonlyweight_small_all") 
                                    else class_ids
                                ),
                            )
                        _, acc = test_fn(exp_model)
                        exp_model = exp_model.cpu()
                        del exp_model
                        result[mode] = round(acc, 2)
                results.append(result)
        
        df = pd.DataFrame(results)
        df.to_csv(log_path)


    
def test_prune_lastconv_ratio_classf1(
    model, resume, out_path, 
    batch_size=64, criterion_test=None, testset=None,
    device=None, num_workers=10, 
    class_id="all",
    **kwargs
):
    test_loader = DataLoader(testset, batch_size=batch_size, shuffle=False, num_workers=num_workers)
    clean_model = copy.deepcopy(model)
    
    prune_allconv_select_modes = [
        "posnegweight_small",
        "edgeweight_small",
        "edgeweight_small_avg",
        "randomweight_small",
    ]
    
    exp_configs = {
        "fc": ["dense"],
        "block4fc": ["conv2d_10", "conv2d_11", "conv2d_12", "dense"],
        # "conv12": ["conv2d_12"],
        "block4": ["conv2d_10", "conv2d_11", "conv2d_12"],
        # "block4main": ["conv2d_11", "conv2d_12"],
    }
    
    for exp_name, layer_names in exp_configs.items():
        results = []
        # Initialize logging
        log_path = osp.join(out_path, f"lastconv_{exp_name}_class_{class_id}.csv")
        if class_id == "all":
            test_class_ids = list(range(10))
        else:
            other_class_ids = list(range(10))
            other_class_ids.remove(class_id)
            test_class_ids = [class_id] + other_class_ids
        for test_class_id in test_class_ids:
            test_fn = partial(
                test_step_single_class_f1_score,
                test_loader=test_loader,
                class_id=test_class_id,
                criterion = nn.CrossEntropyLoss(reduction='mean'),
                device=None,
            )
            # for ratio in [0.5]:
            for ratio in np.arange(0.1, 1.0, 0.1):
                print(f"{exp_name} prune ratio={ratio:.3f}, class {class_id}, test {test_class_id}")
                
                result = {
                    "test_class": test_class_id,
                    "ratio": round(ratio, 2),
                }
                
                for mode in prune_allconv_select_modes:
                    print(f"{mode}")
                    exp_model = copy.deepcopy(clean_model)
                    with torch.no_grad():
                        for layer_name in layer_names:
                            exp_model = clear_model_fc(
                                exp_model, 
                                layer_name=layer_name,
                                select_mode=mode,
                                select_ratio=ratio,
                                class_id=class_id,
                            )
                        
                        _, f1, precision, recall = test_fn(exp_model)
                        del exp_model
                        result[mode] = round(f1, 2)
                    
                results.append(result)
            
        df = pd.DataFrame(results)
        df.to_csv(log_path)


def test_class_auc(
    model, resume, out_path, 
    batch_size=64, criterion_test=None, testset=None,
    device=None, num_workers=10, 
    **kwargs
):
    test_loader = DataLoader(testset, batch_size=batch_size, shuffle=False, num_workers=num_workers)
    
    log_path = osp.join(out_path, f"perclass_clean_baseline.csv")
    results = []
    for class_id in range(10):
        
        test_fn = partial(
            test_step_single_class,
            test_loader=test_loader,
            class_id=class_id,
            criterion = nn.CrossEntropyLoss(reduction='mean'),
            device=None,
        )
    
        test_loss, auc, tpr, fpr = test_fn(model)
        result = {
            "class": class_id,
            "auc": round(auc, 2),
            "tpr": round(tpr, 2),
            "fpr": round(fpr, 2),
        }
        results.append(result)
    df = pd.DataFrame(results)
    df.to_csv(log_path)
    

def test(
    model, resume, out_path, 
    batch_size=64, criterion_test=None, testset=None,
    device=None, num_workers=10, 
    **kwargs
):
    test_loader = DataLoader(testset, batch_size=batch_size, shuffle=False, num_workers=num_workers)
    
    test_fn = partial(
        test_step,
        test_loader=test_loader,
        criterion = nn.CrossEntropyLoss(reduction='mean'),
        device=None,
    )
    
    test_loss, test_acc = test_fn(model)

def main():
    parser = argparse.ArgumentParser(description='Train a model')
    # Required arguments
    parser.add_argument('model_dir', metavar='DIR', type=str, help='Directory containing transferset.pickle')
    parser.add_argument('model_arch', metavar='MODEL_ARCH', type=str, help='Model name')
    parser.add_argument('testdataset', metavar='DS_NAME', type=str, help='Name of test')
    parser.add_argument('-o', '--output', type=str, help="Output dir")
    # Optional arguments
    parser.add_argument('-b', '--batch-size', type=int, default=1024, metavar='N',
                        help='input batch size for training (default: 64)')
    parser.add_argument('--resume', default=None, type=str, metavar='PATH',
                        help='path to latest checkpoint (default: none)')
    parser.add_argument('--device_id', default=0, type=int)
    parser.add_argument('-w', '--num_workers', metavar='N', type=int, help='# Worker threads to load data', default=10)
    args = parser.parse_args()
    params = vars(args)

    random.seed(cfg.DEFAULT_SEED)
    np.random.seed(cfg.DEFAULT_SEED)
    torch.cuda.manual_seed(cfg.DEFAULT_SEED)
    torch.manual_seed(cfg.DEFAULT_SEED)
    if params['device_id'] >= 0:
        os.environ["CUDA_VISIBLE_DEVICES"] = str(params['device_id'])
        device = torch.device('cuda')
    else:
        device = torch.device('cpu')
    model_dir = params['model_dir']
    output_dir = params['output']
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    if params['testdataset'] == 'CIFAR10':
        num_classes = 10
    # ----------- Set up testset
    dataset_name = params['testdataset']
    valid_datasets = datasets.__dict__.keys()
    modelfamily = datasets.dataset_to_modelfamily[dataset_name]
    transform = datasets.modelfamily_to_transforms[modelfamily]['test']
    if dataset_name not in valid_datasets:
        raise ValueError('Dataset not found. Valid arguments = {}'.format(valid_datasets))
    dataset = datasets.__dict__[dataset_name]
    testset = dataset(train=False, transform=transform)
    if len(testset.classes) != num_classes:
        raise ValueError('# Transfer classes ({}) != # Testset classes ({})'.format(num_classes, len(testset.classes)))

    # ----------- Set up model
    model_name = params['model_arch']
    # model = model_utils.get_net(model_name, n_output_classes=num_classes, pretrained=pretrained)
    model = zoo.get_net(model_name, modelfamily, False, num_classes=num_classes)
    # model = model.to(device)
    # model = protect_model(model)    
    
    if params['model_arch'] == "resnet10":
        model = get_transferred_pytorch_model_resnet10()
    elif params['model_arch'] == "resnet18":
        model = get_transferred_pytorch_model_resnet18(testset)
    else:
        raise NotImplementedError
    model = model.cuda()
    
    # Test clean tf model accuracy
    # model = load_class_avg(model, arch=params['model_arch'])
    # test(
    #     model=model,
    #     testset=testset,
    #     out_path=output_dir,
    #     **params,
    # )
    # st()
    
    # Test accuracy of each conv
    # for class_id in ["all"] + list(range(10)):
    #     testset = dataset(train=False, transform=transform)
    #     test_prune_per_conv(
    #         model=model, 
    #         testset=testset, 
    #         out_path=output_dir, 
    #         class_id=class_id,
    #         **params
    #     )
    
    # Test allconv pruned model om the whole dataset
    # test_prune_allconv_ratio_all(
    #     model=model, 
    #     testset=testset, 
    #     out_path=output_dir, 
    #     **params
    # )
    
    test_prune_allconv_ratio_subsetacc(
        model=model, 
        testset=testset, 
        out_path=output_dir, 
        **params
    )
    
    # Prune all conv by class trace and test on each class
    # for class_id in ["all"] + list(range(10)):
    # # for class_id in ["all", 0]:
    #     test_prune_allconv_ratio_classf1(
    #             model=model, 
    #             testset=testset, 
    #             out_path=output_dir, 
    #             class_id=class_id,
    #             **params
    #     )

    
    # Test the pruning of last convs
    # for class_id in ["all", 0]:
    # for class_id in ["all"] + list(range(10)):
    #     test_prune_lastconv_ratio_classf1(
    #         model=model, 
    #         testset=testset, 
    #         out_path=output_dir, 
    #         class_id=class_id,
    #         **params
    #     )


if __name__ == '__main__':
    tf.set_random_seed(3)
    np.random.seed(3)
    random.seed(3)
    torch.manual_seed(3)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False
    
    main()
