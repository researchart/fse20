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
At each iteration, a test suite for a given configuration is appended to a Python list and is pickled as output in the `assets` folder. Each script will create it's own output (e.g. `pgd_results_cifar10_ResNet_2020-05-29.pkl`, `cw_results_mnist_FCNet5_2020-05-29.pkl)`.

More specifically, each output file in the `assets` folder is a list of dictionaries with the following keys:

```
{
	'timestamp'             : the timestamp the test suite was generated
	'attack'                : the type of attack employed: cw or pgd
	'model'                 : the name of the model for which the tests were generated 
	'layer'                 : the layer targeted for diversity regularization 
	'regularization_weight' : the weight given to the diversity component {0, 1, 10, 100, 1000, 10000, 100000, 1000000}
	'confidence'            : the confidence factor {0, 20, 40} (CW only) 
    'epsilon'               : the maximum perturbation limit allowed
	'adversaries'           : the generated test inputs
	'pert_acc'              : the model's accuracy when the adversaries are provided as input
	'orig_acc'              : the model's accuracy when the original inputs are used
	'attack_success_rate'   : the success rate of the adversarial attack with diversity regularization
	'neuron_coverage_000'   : the model's neuron coverage when t=0.00
	'neuron_coverage_020'   : the model's neuron coverage when t=0.20
	'neuron_coverage_050'   : the model's neuron coverage when t=0.50
	'neuron_coverage_075'   : the model's neuron coverage when t=0.75
	'inception_score'       : the inception score of the adversaries
	'fid_score_64'          : the FID score of the original inputs vs. adversaries at dim=64 (not reported in paper)
	'fid_score_2048'        : the FID score of the original inputs vs. adversaries at dim=2048 (standard FID measure)
	'output_impartiality'   : the diversity measure of the adversarial test suite
}
```

## Jupyter Notebook
The results are agregated and visualized in a `jupyter notebook`, which can be viewed directly in GitHub or perused locally:
```
# install
pip install jupyter

# start notebook in working directory
jupyter notebook
```

Lastly, the correlations were extracted into Google Sheets (`pearson_vs_spearman_correlations.pdf`) for formatting purposes. 