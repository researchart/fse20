# nc_diversity_attacks

## About
Corresponding code to the paper "Is Neuron Coverage a Meaningful Measure for Testing Deep Neural Networks" by Fabrice Harel-Canada *et al.*.

There are two options for replication review:
- Use the preconfigured Ubuntu VM 
- Setup your own environment. 

See `INSTALL.md` for further instructions.

## Data
MNIST and CIFAR10 data are downloaded automatically when running an evaluation script. The Driving data comes from the Udacity [self-driving-car](https://github.com/udacity/self-driving-car) challenge and is included in the `data` folder. 

## Models
We assume that pre-trained models exist in the `pretrained_models` folder. We provide code to do training for the MNIST dataset in `models.py` but use previously existing weights for the CIFAR10 and Driving models. 

## Attacks
There are several versions of the CW Atttack that we experimented with and make available in the off-chance that they proove useful to someone. We ultimately decided to use `cw_div4_attack` and `pgd_attack` for the classification tasks (MNIST, CIFAR10) as well as `cw_div_reg_attack` and `pgd_attack_reg` for the regression task (Driving). Some dimensions are provided below that highlight the main differences between these attack algorithms. 
 
| Version             | Loss Function | Scaling Constant | Regularizer                | Adversary Selection |
| ------------------- | ------------- | ---------------- | -------------------------- | ------------------- |
| `cw_attack`         | CW            | True             | L2/L-inf                   | L2/L-inf            |
| `cw_div1_attack`    | CW            | True             | L2/L-inf, Batch Divergence | Instance Divergence |
| `cw_div2_attack`    | CW            | False            | L2/L-inf, Batch Divergence | Instance Divergence |
| `cw_div3_attack`    | Cross Entropy | False            | L2/L-inf, Batch Divergence | Instance Divergence |
| `cw_div4_attack`    | CW            | True             | L2/L-inf, Batch Divergence | L2/L-inf            |
| `cw_div_reg_attack` | CW + MSE      | True             | L2/L-inf, Batch Divergence | L2/L-inf            |
| `pgd_attack`        | Cross Entropy | NA               | L-inf                      | NA                  |
| `pgd_attack_reg`    | MSE 		  | NA               | L-inf                      | NA                  |

## Execution
To run the evaluation scripts:
```
# PGD
python _PGD_div_mnist.py
python _PGD_div_cifar10.py
python _PGD_div_driving.py

# CW
python _CW_div_mnist.py
python _CW_div_cifar10.py
python _CW_div_driving.py
```
At each iteration, a test suit for a given configuration is appended to a list and is picked as output in the `assets` folder. Each script will create it's own output. 

### Jupyter Notebook
The results are agregated and visualized in a jupyter notebook, which can be viewed directly in GitHub or perused locally:
```
# install
pip install jupyter

# start notebook in working directory
jupyter notebook
```

The correlations were extracted into Google Sheets for formatting purposes. 