#!/usr/bin/python
"""This is a short description.
Replace this with a more detailed description of what this file contains.
"""
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
import copy

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

__author__ = "Tribhuvanesh Orekondy"
__maintainer__ = "Tribhuvanesh Orekondy"
__email__ = "orekondy@mpi-inf.mpg.de"
__status__ = "Development"


def get_net(model_name, n_output_classes=1000, **kwargs):
    print('=> loading model {} with arguments: {}'.format(model_name, kwargs))
    valid_models = [x for x in torch_models.__dict__.keys() if not x.startswith('__')]
    if model_name not in valid_models:
        raise ValueError('Model not found. Valid arguments = {}...'.format(valid_models))
    model = torch_models.__dict__[model_name](**kwargs)
    # Edit last FC layer to include n_output_classes
    if n_output_classes != 1000:
        if 'squeeze' in model_name:
            model.num_classes = n_output_classes
            model.classifier[1] = nn.Conv2d(512, n_output_classes, kernel_size=(1, 1))
        elif 'alexnet' in model_name:
            model.num_classes = n_output_classes
            num_ftrs = model.classifier[6].in_features
            model.classifier[6] = nn.Linear(num_ftrs, n_output_classes)
        elif 'vgg' in model_name:
            model.num_classes = n_output_classes
            num_ftrs = model.classifier[6].in_features
            model.classifier[6] = nn.Linear(num_ftrs, n_output_classes)
        elif 'dense' in model_name:
            model.num_classes = n_output_classes
            num_ftrs = model.classifier.in_features
            model.classifier = nn.Linear(num_ftrs, n_output_classes)
        else:
            num_ftrs = model.fc.in_features
            model.fc = nn.Linear(num_ftrs, n_output_classes)
    return model


def soft_cross_entropy(pred, soft_targets, weights=None):
    if weights is not None:
        return torch.mean(torch.sum(- soft_targets * F.log_softmax(pred, dim=1) * weights, 1))
    else:
        return torch.mean(torch.sum(- soft_targets * F.log_softmax(pred, dim=1), 1))


def train_step(
    model, 
    train_loader, 
    criterion, 
    optimizer, 
    epoch, 
    device, 
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

        if (batch_idx + 1) % log_interval == 0:
            iter = exact_epoch * len(train_loader) + batch_idx * len(inputs)
            tb_writer.add_scalar('train/loss', train_loss, iter)
            tb_writer.add_scalar('train/acc', acc, iter)
            print('[Train] Epoch: {:.2f}({}) [{}/{} ({:.0f}%)]\tLoss: {:.6f}\tAccuracy: {:.1f} ({}/{})'.format(
                exact_epoch, iter, 
                batch_idx * len(inputs), len(train_loader.dataset), 100. * batch_idx / len(train_loader),
                loss.item(), acc, correct, total
            ))
            

    t_end = time.time()
    t_epoch = int(t_end - t_start)
    acc = 100. * correct / total

    return train_loss_batch, acc


def test_step(
    model, 
    test_loader, 
    criterion, 
    device, 
    epoch=0., 
    silent=False
):
    model.eval()
    test_loss = 0.
    correct = 0
    total = 0
    t_start = time.time()

    with torch.no_grad():
        for batch_idx, (inputs, targets) in enumerate(test_loader):
            # inputs, targets = inputs.to(device), targets.to(device)
            inputs, targets = inputs.cuda(), targets.cuda()
            outputs = model(inputs)
            loss = criterion(outputs, targets)
            nclasses = outputs.size(1)

            test_loss += loss.item()
            _, predicted = outputs.max(1)
            total += targets.size(0)
            correct += predicted.eq(targets).sum().item()

    t_end = time.time()
    t_epoch = int(t_end - t_start)

    acc = 100. * correct / total
    test_loss /= total

    if not silent:
        print('[Test]  Epoch: {}\tLoss: {:.6f}\tAcc: {:.1f}% ({}/{})'.format(epoch, test_loss, acc,
                                                                            correct, total))
    return test_loss, acc

def filter_dataset(dataset, class_ids):
    idx = np.zeros(len(dataset.targets)).astype(np.bool)
    for id in class_ids:
        class_idx = np.array(dataset.targets) == id
        idx = np.logical_or(idx, class_idx)
    
    subset = copy.deepcopy(dataset)
    subset.targets = list(np.array(subset.targets)[idx])
    subset.data = subset.data[idx]
    return subset

def filter_train_dataset(dataset, class_ids):
    idx = np.zeros(len(dataset.targets)).astype(np.bool)
    targets = np.array([gt.numpy().argmax() for gt in dataset.targets])
    for id in class_ids:
        class_idx = targets == id
        idx = np.logical_or(idx, class_idx)
    idx = np.where(idx==True)[0]
    subset = copy.deepcopy(dataset)
    subset.targets = [subset.targets[i] for i in idx]
    # subset.targets = list(subset.targets[idx])
    subset.data = [subset.data[i] for i in idx]
    return subset


def test_dataloader(
    model,
    criterion,
    dataloader,
    log_name,
    epoch,
):
    test_loss = 0.
    correct = 0
    total = 0
    with torch.no_grad():
        for batch_idx, (inputs, targets) in enumerate(dataloader):
            # inputs, targets = inputs.to(device), targets.to(device)
            inputs, targets = inputs.cuda(), targets.cuda()
            outputs = model(inputs)
            loss = criterion(outputs, targets)
            nclasses = outputs.size(1)
            test_loss += loss.item()
            _, predicted = outputs.max(1)
            total += targets.size(0)
            correct += predicted.eq(targets).sum().item()
    t_end = time.time()
    test_acc = 100. * correct / total
    test_loss /= total
    print(f"[{log_name} Test] Epoch: {epoch}\tLoss: {test_loss:.3f}\t"
        f"Acc: {test_acc}% ({correct}/{total})")
    return test_acc
        
def test_step_subset(
    model, 
    testset, 
    criterion, 
    device, 
    class_ids = range(10),
    batch_size=64,
    epoch=0., 
    silent=False
):
    subset = filter_dataset(testset, class_ids)
    subset_loader = DataLoader(subset, batch_size=batch_size, shuffle=False, num_workers=10)
    complement_ids = set(range(10)) - set(class_ids)
    complementset = filter_dataset(testset, complement_ids)
    complementset_loader = DataLoader(complementset, batch_size=batch_size, shuffle=False, num_workers=10)
    testset_loader = DataLoader(testset, batch_size=batch_size, shuffle=False, num_workers=10)
            
    model.eval()
    
    subset_acc = test_dataloader(
        model, 
        criterion,
        subset_loader,
        "Subset",
        epoch,
    )
        
    complementset_acc =  test_dataloader(
        model, 
        criterion,
        complementset_loader,
        "Complementset",
        epoch,
    )
    
    testset_acc =  test_dataloader(
        model, 
        criterion,
        testset_loader,
        "Testset",
        epoch,
    )
    
    
    return subset_acc, complementset_acc, testset_acc


def test_step_single_class(
    model, test_loader, class_id,
    criterion, device, epoch=0., silent=False
):
    model.eval()
    test_loss = 0.
    correct = 0
    total = 0
    true_count = 0
    true_positive = 0
    false_count = 0
    false_positive = 0
    t_start = time.time()

    with torch.no_grad():
        for batch_idx, (inputs, targets) in enumerate(test_loader):
            # inputs, targets = inputs.to(device), targets.to(device)
            inputs, targets = inputs.cuda(), targets.cuda()
            outputs = model(inputs)
            loss = criterion(outputs, targets)
            nclasses = outputs.size(1)

            test_loss += loss.item()
            _, predicted = outputs.max(1)
            total += targets.size(0)
            correct += predicted.eq(targets).sum().item()
            
            true_count += targets.eq(class_id).sum().item()
            true_positive += (targets.eq(class_id) * 
                        predicted.eq(class_id)).sum().item()
            false_count += (targets != class_id).sum().item()
            false_positive +=  ((targets != class_id) * 
                        predicted.eq(class_id)).sum().item()
            

    t_end = time.time()
    t_epoch = int(t_end - t_start)

    tpr = 100. * true_positive / true_count
    fpr = 100. * false_positive / false_count
    auc = metrics.auc([0,fpr/100,1], [0,tpr/100,1])
    test_loss /= total

    if not silent:
        print(f"[Test] auc: {auc:.2f} "
            f"tpr: {tpr:.1f}({true_positive}/{true_count}) "
            f"fpr: {fpr:.1f}({false_positive}/{false_count}) ")

    return test_loss, auc, tpr, fpr


# def train_model(
#     model, trainset, out_path, 
#     batch_size=64, criterion_train=None, criterion_test=None, testset=None,
#     device=None, num_workers=10, resume=None,
#     lr=0.1, momentum=0.5, lr_step=30, lr_gamma=0.1, 
#     epochs=100, log_interval=100, weighted_loss=False, 
#     checkpoint_suffix='', optimizer=None, scheduler=None,
#     **kwargs):
    
#     if device is None:
#         device = torch.device('cuda')
#     if not osp.exists(out_path):
#         knockoff_utils.create_dir(out_path)
#     run_id = str(datetime.now())

#     # Data loaders
#     train_loader = DataLoader(trainset, batch_size=batch_size, shuffle=True, num_workers=num_workers)
#     if testset is not None:
#         test_loader = DataLoader(testset, batch_size=batch_size, shuffle=False, num_workers=num_workers)
#     else:
#         test_loader = None
    
#     if weighted_loss:
#         if not isinstance(trainset.samples[0][1], int):
#             print('Labels in trainset is of type: {}. Expected: {}.'.format(type(trainset.samples[0][1]), int))

#         class_to_count = dd(int)
#         for _, y in trainset.samples:
#             class_to_count[y] += 1
#         class_sample_count = [class_to_count[c] for c, cname in enumerate(trainset.classes)]
#         print('=> counts per class: ', class_sample_count)
#         weight = np.min(class_sample_count) / torch.Tensor(class_sample_count)
#         weight = weight.to(device)
#         print('=> using weights: ', weight)
#     else:
#         weight = None

#     # Optimizer
#     if criterion_train is None:
#         criterion_train = nn.CrossEntropyLoss(reduction='mean', weight=weight)
#     if criterion_test is None:
#         criterion_test = nn.CrossEntropyLoss(reduction='mean', weight=weight)
#     if optimizer is None:
#         optimizer = optim.SGD(model.parameters(), lr=lr, momentum=momentum, weight_decay=5e-4)
#     if scheduler is None:
#         scheduler = optim.lr_scheduler.StepLR(optimizer, step_size=lr_step, gamma=lr_gamma)
#     start_epoch = 1
#     best_train_acc, train_acc = -1., -1.
#     best_test_acc, test_acc, test_loss = -1., -1., -1.

#     # Resume if required
#     if resume is not None:
#         model_path = resume
#         if osp.isfile(model_path):
#             print("=> loading checkpoint '{}'".format(model_path))
#             checkpoint = torch.load(model_path)
#             # start_epoch = checkpoint['epoch']
#             best_test_acc = checkpoint['best_acc']
#             model.load_state_dict(checkpoint['state_dict'])
#             optimizer.load_state_dict(checkpoint['optimizer'])
#             print("=> loaded checkpoint '{}' (epoch {})".format(resume, checkpoint['epoch']))
#         else:
#             print("=> no checkpoint found at '{}'".format(model_path))
    
#     # raw = model.layer4[0].conv2.weight.data.clone()
#     # model = protect_model(model, layer_name="conv2d_12")
#     # model = protect_model(model, layer_name="conv2d_11")
#     # model = protect_model(model, layer_name="conv2d_10")
#     # new = model.layer4[0].conv2.weight.data
#     # diff = raw != new
#     # st()

#     # Initialize logging
#     log_path = osp.join(out_path, 'train{}.log.tsv'.format(checkpoint_suffix))
#     if not osp.exists(log_path):
#         with open(log_path, 'w') as wf:
#             columns = ['run_id', 'epoch', 'split', 'loss', 'accuracy', 'best_accuracy']
#             wf.write('\t'.join(columns) + '\n')
#     tb_dir = osp.join(out_path, "tb_log")
#     if os.path.exists(tb_dir):
#         shutil.rmtree(tb_dir)
#     os.makedirs(tb_dir)
#     tb_writer = SummaryWriter(tb_dir)
    
#     model_out_path = osp.join(out_path, 'checkpoint{}.pth.tar'.format(checkpoint_suffix))
#     for epoch in range(start_epoch, epochs + 1):
#         scheduler.step(epoch)
#         train_loss, train_acc = train_step(model, train_loader, 
#                                         criterion_train, optimizer, epoch, device,
#                                         log_interval=log_interval,
#                                         tb_writer=tb_writer)
#         best_train_acc = max(best_train_acc, train_acc)
#         # train_loss, train_acc = 0, 0
        
        

#         if test_loader is not None:
#             test_loss, test_acc = test_step(model, test_loader, criterion_test, device, epoch=epoch)
#             best_test_acc = max(best_test_acc, test_acc)
#             tb_writer.add_scalar('test/loss', test_loss, epoch)
#             tb_writer.add_scalar('test/acc', test_acc, epoch)

#         # Checkpoint
#         if test_acc >= best_test_acc:
#             state = {
#                 'epoch': epoch,
#                 'arch': model.__class__,
#                 'state_dict': model.state_dict(),
#                 'best_acc': test_acc,
#                 'optimizer': optimizer.state_dict(),
#                 'created_on': str(datetime.now()),
#             }
#             torch.save(state, model_out_path)

#         # Log
#         with open(log_path, 'a') as af:
#             train_cols = [run_id, epoch, 'train', train_loss, train_acc, best_train_acc]
#             af.write('\t'.join([str(c) for c in train_cols]) + '\n')
#             test_cols = [run_id, epoch, 'test', test_loss, test_acc, best_test_acc]
#             af.write('\t'.join([str(c) for c in test_cols]) + '\n')

#     return model
