# Dynamic Slicing for Deep Neural Networks

## About

This is the source code associated with our FSE paper "Dynamic Slicing for Deep Neural Networks".

NNSlicer is a tool for slicing deep neural networks based on data-flow analysis. The concept is inspired by [program slicing](https://en.wikipedia.org/wiki/Program_slicing) for traditional programs. Given a DNN model and a slicing criterion (defined as a input dataset `I` and a set of output neurons `O`), NNSlicer computes a slice (e.g. a subset of neurons and synapses) that is the most important for the criterion. The importance is computed based on the activation behavior of the neurons (see details in our paper).
NNSlicer is useful for several DNN engineering applications, including adversarial input detection, model pruning, and selective model protection.

This repo contains the source code of NNSlicer and the scripts to reproduce all experiment results in our paper.

## Setup

This repo is developed and tested under Ubuntu 16.04 (OS) and Python 3.6 (version). We think it can also run on other systems and other Python 3 subversions, although not well tested.

To install the required packages, simply run:

```
pip install -r requirements.txt
```

## Steps of slicing a DNN model

### Prepare dataset and model

- Download CIFAR10 dataset from https://www.cs.toronto.edu/~kriz/cifar.html and change the path CIFAR10_PATH in `NNSlicer/config.py` to the dataset path. For example:
```
CIFAR10_PATH = "/home/zzq/Dataset/cifar-10-batches-bin"
```
- Go to NNSlicer subdirectory
```
cd NNSlicer
```
- Train the resnet10 model 
```
python -m train.resnet10cifar10_train
```
- Generate adversarial examples 
```
python -m eval.generate_adv_resnet10cifar10
```
This will save adversarial samples to result/resnet10cifar10/model_dropout/attack

### Perform slicing on the model

- Go to NNSlicer subdirectory
```
cd NNSlicer
```
  - Save the graph of the model
```
python -m model.lenet
python -m model.resnet10cifar10
```
  - Save the average neuron activation
    - This will save average neuron activation to result/resnet10cifar10/model_dropout/nninst_mu_posneg/original_train_gathered_trace and EffectivePath baseline to result/resnet10cifar10/model_dropout/nninst_mu_posneg/per_image_trace_0.5_posonly
```
python -m eval.resnet10cifar10_save_avg_traces
```
  - Save the slicing result
    - This will save per-input slicing to result/resnet10cifar10/model_dropout/nninst_mu_posneg/per_image_trace_0.5_sum0.2_bar0.01
```
python -m eval.resnet10cifar10_save_traces
```
  - Postprocess the slice
    - This will save the decoded slice to result/resnet10cifar10/model_dropout/nninst_mu_posneg/posneg_edge_0.9/trace.weight/unary/raw_logics
```
python -m logics.cifar10.save_weights
python -m logics.cifar10.count_weights
```

## Reproduce the experiment results

In our paper, we described three experiemnts, including adversarial input detection, targeted pruning, and selective protection. Please follow the steps below to reproduce each of the experiments:

### Adversarial input detection
- Train the classifier 
```
python -m logics.cifar10.train_classifier_weights
```
The result will be saved to `result/resnet10cifar10/model_dropout/nninst_mu_posneg/posneg_edge_0.9/clf` directory.

### Targeted pruning
- Go to finetune dir
```
cd finetune
```
- Construct dataset
```
bash construction.sh
```
- Run the finetune experiment and save the results to `results/finetune`
```
bash finetune.sh
```

### Targeted protection
- Go to protection dir
```
cd protection
```
- Construct dataset
```
bash construction.sh
```
- Run the protection exp and save the results to `results/protection`
```
bash protection.sh
```

## Authors
- Ziqi Zhang (Github ID: ziqi-zhang, email: ziqi_zhang@pku.edu.cn)
- Yuanchun Li (Github ID: ylimit, email: pkulyc@gmail.com)
- Yao Guo (email: yaoguo@pku.edu.cn)
- Xiangqun Chen (email: cherry@sei.pku.edu.cn)
- Yunxin Liu (email: yunxin@microsoft.com)

## Acknowledgement
We thank Yuxian Qiu for sharing the code of [Adversarial defense through network profiling based path extraction](http://openaccess.thecvf.com/content_CVPR_2019/papers/Qiu_Adversarial_Defense_Through_Network_Profiling_Based_Path_Extraction_CVPR_2019_paper.pdf).
We also thank Tribhuvanesh Orekondy for sharing the code of [Knockoff Nets](https://github.com/tribhuvanesh/knockoffnets).
