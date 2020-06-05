# Baital

Baital is an implementation for the work `Baital: An Adaptive Weighted Sampling Approach for Improved t-wise Coverage` which will appear in FSE2020. We provide a tool that generates a set of testing samples for large configurable systems with higher t-wise coverage than obtained with standard uniform sampling.

The tool takes a set of constaints on features of the configurable system represented as a CNF formula in Dimacs format and provides a set of configurations of a specified size and computes their t-wise coverage.

[![DOI](https://zenodo.org/badge/269304252.svg)](https://zenodo.org/badge/latestdoi/269304252)

## System Requirements

Linux OS with Python 3.6 or higher and pip3. For large benchmarks in our set up to 12Gb of RAM is required.

The tool was tested on: Ubuntu 18.10, Python 3.6.9

## Input data

Input file for Baital must be in Dimacs CNF format. Folder benchmarks includes all the benchmarks on which the tool has been evaluated. [FeatureIDE](https://github.com/FeatureIDE/FeatureIDE/releases/tag/v3.6.0) can be used to generate input files from configurable systems. 

## Running Baital

Run command `python3 baital.py <arguments>` from `src` folder. 

### Arguments

1. Required
    - *cnf_file*.cnf in dimacs format
    
2. Optional

| Argument | Type | Default value | Description | 
| -------- | ---- | ------------- | ----------- |
| --outputdir | string | ../results/ | output directory to store the results |
| --outputfile | string | *cnf_file*.samples | name of the file to store the generated samples; would be placed in *outputdir* |
| --strategy | {1,2,3,4} | 4 | weight generation strategy |
| --twise | int | 2 | t value for t-wise coverage |
| --samples | int | 500 | total number of samples to be generated |
| --rounds | int | 10|  number of rounds to generate samples |
| --combinations | string | | file with pregenerated list of satisfiable feature combinations |
| --no-combinations | | | if set, the list of satisfiable feature combinations and resulted coverage are not computed reducing the computation time; ignored with strategy=1 |
| --seed SEED | int | | random seed |

### Output

The last two lines of console output report the number of distinct feature combinations of size *twise* in the generated samples and their coverage. If `--no-combinations` option is set, coverage is not reported.
In *outputdir*, the following files are generated:
1. *outputfile* - contains the list of generated samples. Each line contains sample index, comma, and a list of space- separated literals. Positive literals correspond to selected features and negative to non-selected. For example, line `2, 1 -2 3` corresponds to a second sample in which variables 1 and 3 are True (selected) and variable 2 is False (non-selected). 
2. *outputfile*.txt - contains the number of distinct feature combinations and their coverage. If `--no-combinations` option is set, only number of feature combinations is included.
3. *cnf_file*_*x*.comb - for *x* in [1, *twise*] contain lists of feature combinations of size *x* that are satisfiable by the input cnf formula. These files can be further reused with `--combinations` argument. Not generated if `--no-combinations` is set. Each line contains a satisfiable combinations of literals.
4. *cnf_file*.count  - generated only if strategy 3 is chosen. This file contains for each literal the number of models of the input cnf formula. Each line contains a literal and the number of models.
    
### Examples of use:

`python3 baital.py ../benchmarks/axtls.cnf --strategy 1 --twise 2 --samples 1000` \
would generate 1000 samples for axtls.cnf with strategy 1 and store them in `../results/axtls.samples`. Resulted t-wise coverage can be found in console output and in `../results/axtls.samples.txt`

`python3 baital.py ../benchmarks/axtls.cnf --strategy 4 --twise 2 --samples 1000 --combintations ../results/axtls_2.comb --outputfile axtls_strategy4.samples` \
would generate another 1000 samples for axtls.cnf with strategy 4 and store them in `../results/axtls_strategy4.samples`. `--combinations` option allows to reuse precomputed list of satisfiable feature combinations.

`python3 baital.py ../benchmarks/financial.cnf --strategy 1 --twise 2 --samples 1000 --rounds 20` \
would generate 1000 samples for financial.cnf with strategy 1 and store them in `../results/financial.samples`. `--rounds` option controls how often weights are regenerated. In this example weights are regenerated after each 1000/20 = 50 samples. 

`python3 baital.py ../benchmarks/embtoolkit.cnf --strategy 2 --twise 2 --samples 1000 --no-combinations`\
would generate 1000 samples for embtoolkit.cnf with strategy 2 and store them in `../results/embtoolkit.samples`. `--no-combinations` option skips the first step of computation and does not generate `.comb` files. In this case only `Number of combinations` is reported.

### Execution Process

The execution consists of three steps:

1. Generate a set of satisfiable feature combinations for a given CNF formula. The results are stored in *cnf_file*_*x*.comb file used in strategy 1 and in the final computation of coverage. If the file have been generated during previous executions, it can be reused with `--combinations` option avoiding recomputation of this step. Option `--no-combinations` allows to skip this step.\
1'. 1'. Strategy 3 also computes the number of models for each literal during this step. The results are stored in *cnf_file*.count
2. Generate a set of samples for a given CNF formula using a specified strategy. The results are stored in *outputfile*.
3. Compute the number of covered feature combintaions and coverage. The result is stored in *outputfile*.txt

Each step can be executed separately by calling the corresponding script: `combinations.py` for step 1, `sampling.py` for step 2, `get_coverage.py` for step 3.


### Strategies

We provide 4 different strategies proposed in the paper to generate weights during the second execution step. 
1. Strategy 1 chooses weights based on the ratio between covered and uncovered feature combinations involving a literal. This is the only strategy that requires the results of execution step 1, therefore it is the most computationnaly expensive.
2. Strategy 2 chooses weights based on the number of covered feature combinations involving a literal. Contrary to strategy 1 it doesn't take into account the number of uncovered feature combintaions, thus allowing to skip step 1. Therefore, the results of execution step 1 are only required to provode the resulted coverage.
3. Strategy 3 chooses weights based on the ratio between number of samples involving a literal among the selected ones and the total number of models involving a literal. This is the only strategy requiring execution step 1'. Unlike the first two strategies it does not compute the covered feature combinations during the weight generation making the execution step 2 faster for `twise > 1` .
4. Strategy 4 chooses weights based on the number of samples that involve a literal among the selected ones. This is the fastest strategy and therefore selected as a default one. 

### Note on execution time

Execution of step 1 depends on the number of variables and  *twise* - size of feature combinations. It takes just a few seconds for the smallest benchmark axtls.cnf, while for larger ones it might require several hours (or days for the largest benchmarks in our set). Therefore, it is recommended to use `--combinations` option if the result is already precomputed. In our experiments for the majority of benchmarks we used strategies 2 and 4 that do not require execution of step 1 using `--no-combinations` option. `combinations` folder contains precomputed results of step 1 for some of the benchmarks.

Execution for `twise > 2` is feasible for small benchmarks only. Indeed with strategies 3 and 4 it is possible to generate a set of samples for any *twise*, however it would be infeasible to compute the number of covered feature combinations. 


## Reproduction of experiments

Experiment 1 (Comparison with uniform sampling) can be reproduced by running the following commands:
For each benchmark in `benchmarks` folder
1. Generate a set of samples with strategy 2 and compute the number of covered feature combinations
`python3 baital.py ../benchmarks/*benchmark_name*.cnf --strategy 2 --twise 2 --samples 1000 --rounds 10 --no-combintations  --outputfile *benchmark_name*_strategy2.samples`
2. Generate a set of samples with strategy 4 and compute the number of covered feature combinations
`python3 baital.py ../benchmarks/*benchmark_name*.cnf --strategy 4 --twise 2 --samples 1000 --rounds 10 --no-combintations  --outputfile *benchmark_name*_strategy4.samples`
3. Generate a set of samples obtained with uniform sampling and compute the number of covered feature combinations
`python3 baital.py ../benchmarks/*benchmark_name*.cnf --twise 2 --samples 1000 --rounds 1 --no-combintations  --outputfile *benchmark_name*_uniform.samples`
(Note that during the first round the weights are corresponding to uniform sampling)

Experiment 2 (Comparison of weight generation strategies) can be reproduced by running Baital on benchmarks `../benchmarks/axtls.cnf`, `../benchmarks/financial.cnf`, and `../benchmarks/embtoolkit.cnf` by fixing `--samples 3000` and varying `--rounds` and `--strategy` arguments.
