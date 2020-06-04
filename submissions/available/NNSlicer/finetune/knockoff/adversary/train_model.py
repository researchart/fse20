import argparse
import os.path as osp
import os
import time
from datetime import datetime
from collections import defaultdict as dd
from pdb import set_trace as st
from tensorboardX import SummaryWriter
import shutil
import sklearn.metrics as metrics

import numpy as np

from tqdm import tqdm

import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
import torchvision.models as torch_models

import knockoff.config as cfg
import knockoff.utils.utils as knockoff_utils
from knockoff.adversary.protect_model import *
import knockoff.utils.model as model_utils


def compute_subset_report(
    class_ids,
    predict,
    targets,
):
    all_cnt, correct_cnt = 0, 0
    for id in class_ids:
        correct = (targets.eq(id) * predict.eq(id)).sum().item()
        cnt = targets.eq(id).sum().item()
        all_cnt += cnt
        correct_cnt += correct
    if all_cnt == 0:
        acc = -1
    else:
        acc = 100 * correct_cnt / all_cnt
    return acc, correct_cnt, all_cnt
        
        
        
def train_step(
    model, 
    train_loader, 
    criterion, 
    optimizer, 
    epoch, 
    device, 
    class_ids,
    log_interval=10,
    tb_writer=None,
):
    model.train()
    train_loss = 0.
    correct = 0
    total = 0
    train_loss_batch = 0
    epoch_size = len(train_loader.dataset)
    t_start = time.time()

    for batch_idx, (inputs, targets) in enumerate(train_loader):
        # inputs, targets = inputs.to(device), targets.to(device)
        inputs, targets = inputs.cuda(), targets.cuda()
        optimizer.zero_grad()
        outputs = model(inputs)
        loss = criterion(outputs, targets)
        loss.backward()
        
        optimizer.step()

        train_loss += loss.item()
        _, predicted = outputs.max(1)
        total += targets.size(0)
        if len(targets.size()) == 2:
            # Labels could be a posterior probability distribution. Use argmax as a proxy.
            target_probs, target_labels = targets.max(1)
        else:
            target_labels = targets
        correct += predicted.eq(target_labels).sum().item()

        prog = total / epoch_size
        exact_epoch = epoch + prog - 1
        acc = 100. * correct / total
        train_loss_batch = train_loss / total
        
        if (batch_idx ) % log_interval == 0:
            iter = exact_epoch * len(train_loader) + batch_idx * len(inputs)
            
            subset_acc, subset_correct, subset_all = compute_subset_report(
                class_ids, predicted, target_labels,
            )
            complement_ids = set(range(10)) - set(class_ids)
            com_acc, com_correct, com_all = compute_subset_report(
                complement_ids, predicted, target_labels,
            )
            print(f"[Train] Epoch: {exact_epoch:.1f}({iter})"
                f"[{batch_idx * len(inputs)}/{len(train_loader.dataset)} {100. * batch_idx / len(train_loader):.0f}%]\t"
                f"Loss: {loss.item():.6f}\t"
                f"Accuracy: {acc:.1f}({correct}/{total})\t"
                f"SubsetAcc: {subset_acc:.1f}({subset_correct}/{subset_all})\t"
                f"CompsetAcc: {com_acc:.1f}({com_correct}/{com_all})\t")
            

    t_end = time.time()
    t_epoch = int(t_end - t_start)
    acc = 100. * correct / total

    return train_loss_batch, acc

def conv_parameters(model):
    for name, param in model.named_parameters():
        if "conv" in name:
            yield param
            
def train_model(
    model, trainset, test_fn, class_ids,
    batch_size=256, criterion_train=None, criterion_test=None, 
    device=None, num_workers=10, resume=None,
    lr=0.1, momentum=0.5, lr_step=30, lr_gamma=0.1, 
    epochs=100, log_interval=1, weighted_loss=False, 
    checkpoint_suffix='', optimizer=None, scheduler=None,
    **kwargs):
    
    device = torch.device('cuda')

    # Data loaders
    train_loader = DataLoader(trainset, batch_size=batch_size, shuffle=True, num_workers=num_workers)
    
    # Optimizer
    if criterion_train is None:
        criterion_train = model_utils.soft_cross_entropy
    if criterion_test is None:
        criterion_test = nn.CrossEntropyLoss(reduction='mean')
        

    conv_params = conv_parameters(model)
    
    if optimizer is None:
        optimizer = optim.SGD(conv_parameters(model), lr=lr, momentum=momentum, weight_decay=5e-4)
    if scheduler is None:
        scheduler = optim.lr_scheduler.StepLR(optimizer, step_size=lr_step, gamma=lr_gamma)
    start_epoch = 1
    best_train_acc, train_acc = -1., -1.
    best_subset_acc, best_complementset_acc, best_testset_acc, test_loss = -1., -1., -1., -1
    
    subset_acc, complementset_acc, testset_acc = test_fn(model)
    subset_acc_all, complementset_acc_all = [subset_acc], [complementset_acc]
    testset_acc_all = [testset_acc]
    for epoch in range(0, epochs):
        scheduler.step(epoch)
        train_loss, train_acc = train_step(model, train_loader, 
                                        criterion_train, optimizer, epoch, device,
                                        class_ids,
                                        log_interval=log_interval)
        best_train_acc = max(best_train_acc, train_acc)
        # train_loss, train_acc = 0, 0
        
        subset_acc, complementset_acc, testset_acc = test_fn(model)
        best_subset_acc = max(best_subset_acc, subset_acc)
        best_complementset_acc = max(best_complementset_acc, complementset_acc)
        best_testset_acc = max(best_testset_acc, testset_acc)
        
        subset_acc_all.append(subset_acc)
        complementset_acc_all.append(complementset_acc)
        testset_acc_all.append(testset_acc_all)
        

    return (model, 
        best_subset_acc, best_complementset_acc, best_testset_acc,
        subset_acc_all, complementset_acc_all, testset_acc_all)
