# CW + Diversity Regularization on MNIST

import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim

import torchvision
import torchvision.transforms as transforms

import numpy as np
import matplotlib.pyplot as plt

import traceback
import warnings
warnings.filterwarnings('ignore')

import datetime
import glob
import os
import pickle

import pandas as pd

from models import *
from div_attacks import *
from neuron_coverage import *
from inception_score import *
from fid_score import *
from utils import *

# check if CUDA is available
device = torch.device("cpu")
use_cuda = False
if torch.cuda.is_available():
    print('CUDA is available!')
    device = torch.device("cuda")
    use_cuda = True
else:
    print('CUDA is not available.')

# Load DeepXplore Data

mnist_dir = r"C:/Users/Fabrice/Documents/GitHub/deepxplore/MNIST/generated_inputs/"

with open(mnist_dir + 'results_MNIST_light.pkl.', 'rb') as handle:
    results_MNIST_light = pickle.load(handle)
    
with open(mnist_dir + 'results_MNIST_occl.pkl.', 'rb') as handle:
    results_MNIST_occl = pickle.load(handle)
    
with open(mnist_dir + 'results_MNIST_blackout.pkl.', 'rb') as handle:
    results_MNIST_blackout = pickle.load(handle)


# # Load Pretrained Models if available

# ## DenseNet5
# fcnet5 = FCNet5().to(device)
# fcnet5 = get_pretrained_weights(fcnet5) 

# ## DenseNet10
# fcnet10 = FCNet10().to(device) 
# fcnet10 = get_pretrained_weights(fcnet10)

# ## Conv1DNet
# conv1dnet = Conv1DNet().to(device)
# conv1dnet = get_pretrained_weights(conv1dnet)

## Conv2DNet
conv2dnet = Conv2DNet().to(device)
conv2dnet = get_pretrained_weights(conv2dnet)

# # Attack Time
def main():

    datasets = [results_MNIST_light, results_MNIST_occl, results_MNIST_blackout]
    models = [conv2dnet] # [fcnet5, fcnet10, conv1dnet, conv2dnet]

    # # attack params
    # search_steps=5
    # targeted=False
    # norm_type='inf'
    # epsilon=100.
    # c_range=(1e-3, 1e10)
    # max_steps=1000
    # abort_early=True
    # optimizer_lr=5e-4
    # init_rand=False
    # log_frequency = 100

    # mean = (0.1307,) # the mean used in inputs normalization
    # std = (0.3081,) # the standard deviation used in inputs normalization
    # box = (min((0 - m) / s for m, s in zip(mean, std)),
    #        max((1 - m) / s for m, s in zip(mean, std)))

    # attack_versions = [cw_div4_attack] # [cw_div1_attack, cw_div2_attack, cw_div3_attack, cw_div4_attack]
    # reg_weights = [0, 1, 10, 100, 1000, 10000, 100000, 1000000]
    # confidences = [0, 20, 40]

    # neuron coverage params
    nc_threshold = 0. # all activations are scaled to (0,1) after relu

    # inception score (is) params
    is_cuda = use_cuda
    is_batch_size = 10
    is_resize = True
    is_splits = 10

    # fréchet inception distance score (fid) params
    real_path = "C:/temp_imgs/mnist/real_dx_mnist/"
    fake_path = "C:/temp_imgs/mnist/fake_dx_mnist/"
    fid_batch_size = 64
    fid_cuda = use_cuda                     

    with open('logs/dx_mnist_error_log_2020.01.27.txt', 'w') as error_log: 

        for model in models:

            for dataset in datasets:

                results = []

                model_name = model.__class__.__name__
                transformation = dataset['transformation']
                inputs = torch.tensor(np.squeeze(dataset['inputs'], -1)).float().to(device)
                targets = torch.tensor(dataset['targets']).long().to(device)

                timestamp = str(datetime.datetime.now()).replace(':','.')

                save_file_path = "assets/dx_results_mnist_" + model_name + '_' + transformation + "_2020.01.27.pkl"   

                # neuron coverage
                covered_neurons, total_neurons, neuron_coverage_000 = eval_nc(model, inputs, 0.00)
                print('neuron_coverage_000:', neuron_coverage_000)
                covered_neurons, total_neurons, neuron_coverage_020 = eval_nc(model, inputs, 0.20)
                print('neuron_coverage_020:', neuron_coverage_020)
                covered_neurons, total_neurons, neuron_coverage_050 = eval_nc(model, inputs, 0.50)
                print('neuron_coverage_050:', neuron_coverage_050)
                covered_neurons, total_neurons, neuron_coverage_075 = eval_nc(model, inputs, 0.75)
                print('neuron_coverage_075:', neuron_coverage_075)
                
                # inception score
                preprocessed_inputs = preprocess_1D_imgs(inputs)
                mean_is, std_is = inception_score(preprocessed_inputs, is_cuda, is_batch_size, is_resize, is_splits)
                print('inception_score:', mean_is)

                init = {'desc': 'Initial inputs and targets.', 
                        'timestamp': timestamp, 
                        'transformation': transformation,
                        # 'attack': attack.__name__, 
                        'model': model_name, 
                        # 'layer': layer_idx, 
                        # 'regularization_weight': rw, 
                        # 'confidence': c, 
                        'adversaries': 'NA',
                        'pert_acc':'NA', 
                        'orig_acc': 'NA',
                        'attack_success_rate': 'NA',
                        'neuron_coverage_000': neuron_coverage_000,
                        'neuron_coverage_020': neuron_coverage_020,
                        'neuron_coverage_050': neuron_coverage_050,
                        'neuron_coverage_075': neuron_coverage_075,
                        'inception_score': mean_is,
                        'fid_score_64': 'NA',
                        'fid_score_2048': 'NA',
                        'output_diversity': 'NA',
                        'output_diversity_pct': 'NA'}
                
                results.append(init) 

                # output diversity
                num_classes = 10 # len(targets.unique())
                max_diversity = torch.ones(num_classes) * (1./num_classes)
                max_entropy = torch.distributions.Categorical(probs=max_diversity).entropy().item()
                # orig_classes, orig_counts = targets.unique(return_counts=True) 
                orig_classes = torch.tensor(np.arange(num_classes)).long().to(device)

                try:
                    
                    attack_detail = ['timestamp', timestamp,
                                     'transformation', transformation]

                    print(*attack_detail, sep=' ')

                    # # adversarial attack 
                    # adversaries = attack(model, module, rw, inputs, targets, device, targeted, norm_type, epsilon,
                    #                      c, c_range, search_steps, max_steps, abort_early, box,
                    #                      optimizer_lr, init_rand, log_frequency)

                    adversaries = torch.tensor(np.expand_dims(dataset['adversaries'], 1)).float().to(device)
                   
                    # evaluate adversary effectiveness
                    pert_acc, orig_acc = eval_performance(model, inputs, adversaries, targets)
                    # sample_1D_images(model, inputs, adversaries, targets)
                    
                    pert_acc = pert_acc.item() / 100.
                    orig_acc = orig_acc.item() / 100.

                    attack_success_rate = 1 - pert_acc
                    
                    # neuron coverage
                    covered_neurons, total_neurons, neuron_coverage_000 = eval_nc(model, adversaries, 0.00)
                    print('neuron_coverage_000:', neuron_coverage_000)
                    covered_neurons, total_neurons, neuron_coverage_020 = eval_nc(model, adversaries, 0.20)
                    print('neuron_coverage_020:', neuron_coverage_020)
                    covered_neurons, total_neurons, neuron_coverage_050 = eval_nc(model, adversaries, 0.50)
                    print('neuron_coverage_050:', neuron_coverage_050)
                    covered_neurons, total_neurons, neuron_coverage_075 = eval_nc(model, adversaries, 0.75)
                    print('neuron_coverage_075:', neuron_coverage_075)
                    
                    # inception score
                    preprocessed_advs = preprocess_1D_imgs(adversaries)
                    mean_is, std_is = inception_score(preprocessed_advs, is_cuda, is_batch_size, is_resize, is_splits)
                    print('inception_score:', mean_is)
                    
                    # fid score 
                    paths = [real_path, fake_path]
                    
                    # dimensionality = 64
                    target_num = 64
                    generate_imgs(inputs, real_path, target_num)
                    generate_imgs(adversaries, fake_path, target_num)
                    fid_score_64 = calculate_fid_given_paths(paths, fid_batch_size, fid_cuda, dims=64)
                    print('fid_score_64:', fid_score_64)
                    
                    # dimensionality = 2048
                    target_num = 2048
                    generate_imgs(inputs, real_path, target_num)
                    generate_imgs(adversaries, fake_path, target_num)
                    fid_score_2048 = calculate_fid_given_paths(paths, fid_batch_size, fid_cuda, dims=2048)
                    print('fid_score_2048:', fid_score_2048)

                    # output diversity
                    pert_output = model(adversaries)
                    pert_pred = torch.argmax(pert_output, dim=1)

                    class_counts = []
                    for i in orig_classes:
                        count = 0
                        for pred in pert_pred:
                            if pred == i:
                                count += 1
                        class_counts.append(count)
                        
                    class_counts = torch.tensor(class_counts, dtype=torch.float) 
                    class_probs = class_counts / class_counts.sum()
                                    
                    output_div = torch.distributions.Categorical(probs=class_probs).entropy().item()
                    print('output_div:', output_div)
                    
                    output_diversity_pct = output_div / max_entropy
                    print('output_diversity_pct:', output_diversity_pct)
                    
                    out = {'desc': 'Adversarial inputs generated by DeepXplore.', 
                           'timestamp': timestamp, 
                           'transformation': transformation,
                           # 'attack': attack.__name__, 
                           'model': model_name, 
                           # 'layer': layer_idx, 
                           # 'regularization_weight': rw, 
                           # 'confidence': c, 
                           'adversaries': adversaries,
                           'pert_acc':pert_acc, 
                           'orig_acc': orig_acc,
                           'attack_success_rate': attack_success_rate,
                           'neuron_coverage_000': neuron_coverage_000,
                           'neuron_coverage_020': neuron_coverage_020,
                           'neuron_coverage_050': neuron_coverage_050,
                           'neuron_coverage_075': neuron_coverage_075,
                           'inception_score': mean_is,
                           'fid_score_64': fid_score_64,
                           'fid_score_2048': fid_score_2048,
                           'output_diversity': output_div,
                           'output_diversity_pct': output_diversity_pct}
                    
                    results.append(out)
                
                    # save incremental outputs
                    with open(save_file_path, 'wb') as handle:
                        pickle.dump(results, handle, protocol=pickle.HIGHEST_PROTOCOL)

                except Exception as e: 

                    print(str(traceback.format_exc()))
                    error_log.write("Failed on attack_detail {0}: {1}\n".format(str(attack_detail), str(traceback.format_exc())))

                finally:

                    pass

if __name__ == '__main__':
    try:
        main()
    except Exception as e: 
        print(traceback.format_exc())