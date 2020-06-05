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
from itertools import combinations
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

import knockoff.config as cfg
import knockoff.utils.model as model_utils
from knockoff import datasets
import knockoff.models.zoo as zoo
from knockoff.adversary.protect_model import *
from knockoff.prune.clear_channel import *
from knockoff.utils.model import test_step, test_step_single_class, test_step_subset
from knockoff.prune.tf_model import *
from knockoff.adversary.train_model import *
from knockoff.adversary.train import *

def filter_dataset(dataset, class_ids):
    idx = np.zeros(len(dataset.targets)).astype(np.bool)
    for id in class_ids:
        class_idx = np.array(dataset.targets) == id
        idx = np.logical_or(idx, class_idx)
    
    subset = copy.deepcopy(dataset)
    subset.targets = list(np.array(subset.targets)[idx])
    subset.data = subset.data[idx]
    return subset


def test_prune_allconv_ratio_subset(
    model, train_fn, out_path, transferset_fn,
    batch_size=64, criterion_test=None, testset=None,
    device=None, num_workers=10, 
    **kwargs
):
    all_class_ids = list(range(10))
    
    for combination_number in [2,3,4,5,6,7]:

        class_id_combination = list(combinations(all_class_ids, combination_number))
        clean_model = copy.deepcopy(model)
        
        results = []
        log_dir = os.path.join(
            out_path, 
            f"combin_{combination_number}",
        )
        os.makedirs(log_dir, exist_ok=True)


        max_combination = min(10, len(class_id_combination))
        # for cnt, class_ids in enumerate(class_id_combination[0:1]):
        for cnt, class_ids in enumerate(class_id_combination[:max_combination]):
            log_path = os.path.join(
                log_dir, 
                f"subset_{class_ids}.csv"
            )
                
            test_fn = partial(
                test_step_subset,
                testset = testset,
                class_ids=class_ids,
                criterion = nn.CrossEntropyLoss(reduction='mean'),
                device=None,
            )
            
            prune_allconv_select_modes = [
                "posnegweight_large_all",
                "posnegweight_large_subset",
                "edgeweight_large",
                "randomweight_small",

            ]
            if kwargs['model_arch'] == "resnet10":
                layer_names = resnet10_protect_model.layer_tf_to_torch.keys()
            elif kwargs['model_arch'] == "resnet18":
                layer_names = resnet18_protect_model.layer_tf_to_torch.keys()
            else:
                raise NotImplementedError
            
            # for budget in range(10000, 20000, 10000):
            for budget in range(10000, 30000, 10000):
                transferset = transferset_fn(budget=budget)
                train_fn = partial(
                    train_fn,
                    trainset=transferset,
                )
                # for ratio in np.arange(0.5, 0.6, 0.1):
                for ratio in np.arange(0.1, 1, 0.2):
                    print(f"{class_ids}, {cnt}/{len(class_id_combination)}, "
                        f"budget={budget}, ratio={ratio}")     
                    
                    for mode in prune_allconv_select_modes:
                        print(f"{mode}")
                        result = {
                            "classes": class_ids,
                            "budget": budget,
                            "ratio": ratio,
                            "mode": mode,
                        }
                        exp_model = copy.deepcopy(clean_model)
                        with torch.no_grad():
                            for layer_name in layer_names:
                                replace_mode = mode
                                exp_model = clear_model_fc(
                                    exp_model, 
                                    arch=kwargs["model_arch"],
                                    layer_name=layer_name,
                                    select_mode=replace_mode,
                                    select_ratio = ratio,
                                    class_id= (
                                        "all" if mode == "posnegweight_large_all"
                                        else class_ids
                                    ),
                                )

                        model, best_subset, best_complementset, best_testset, _, _, _ = train_fn(
                            model=exp_model,
                            test_fn=test_fn,
                            class_ids=class_ids,
                        )
                        
                        result["subset"] = best_subset
                        result["complementset"] = best_complementset
                        result["testset"] = best_testset
                        
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
    parser.add_argument('--budget', metavar='N', type=int, help='Size of transfer set to construct',
                        required=True)
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

    # ----------- Set up transferset
    transferset_path = osp.join(model_dir, f"transferset_{params['budget']}.pickle")
    with open(transferset_path, 'rb') as rf:
        transferset_samples = pickle.load(rf)
    num_classes = transferset_samples[0][1].size(0)
    print('=> found transfer set with {} samples, {} classes'.format(len(transferset_samples), num_classes))
    # Must transfer target vector to one-hot vector for resnet10
    new_transferset_samples = []
    print('=> Using argmax labels (instead of posterior probabilities)')
    for i in range(len(transferset_samples)):
        x_i, y_i = transferset_samples[i]
        argmax_k = y_i.argmax()
        y_i_1hot = torch.zeros_like(y_i)
        y_i_1hot[argmax_k] = 1.
        new_transferset_samples.append((x_i, y_i_1hot))
    transferset_samples = new_transferset_samples
    
    
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
    
    # transferset = samples_to_transferset(transferset_samples, budget=params['budget'], transform=transform)
    transferset_fn = partial(
        samples_to_transferset,
        samples=transferset_samples,
        transform=transform,
    )
    
    # ----------- Set up model
    model_name = params['model_arch']
    # model = model_utils.get_net(model_name, n_output_classes=num_classes, pretrained=pretrained)
    model = zoo.get_net(model_name, modelfamily, False, num_classes=num_classes)
    
    if params['model_arch'] == "resnet10":
        model = get_transferred_pytorch_model_resnet10()
    elif params['model_arch'] == "resnet18":
        model = get_transferred_pytorch_model_resnet18(testset)
    else:
        raise NotImplementedError
    model = model.cuda()
    
    
    train_fn = partial(
        train_model,
        epochs=10,
        batch_size=256,
        log_interval=50,
        lr=5e-3,
        momentum=0.5,
        lr_step=30,
        lr_gamma=0.1,
        
    )
    

    # Protect all convs
    test_prune_allconv_ratio_subset(
        model=model, 
        train_fn=train_fn,
        transferset_fn=transferset_fn,
        testset=testset, 
        out_path=output_dir, 
        **params
    )
    

if __name__ == '__main__':
    tf.set_random_seed(3)
    np.random.seed(3)
    random.seed(3)
    torch.manual_seed(3)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False
    
    main()
