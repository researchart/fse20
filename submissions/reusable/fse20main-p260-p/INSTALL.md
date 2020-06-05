# Installation and Usage

The source code is written in Python 3 and tested using Python 3.6 and Python 3.7.

It is strongly recommended to use a virtual Python environment for this setup, since the package dependencies might conflict with the existing installation of the system.

## Setup environment

Follow the steps to create a virtual environment and run the code.

1. Install Anaconda [[installation guide](https://docs.anaconda.com/anaconda/install/)].

2. Create a new Python environment. Run on command line:
```
conda create --name mlfairness python=3.7
conda activate mlfairness
```
The shell should look like: `(mlfairness) $ `. Now, continue to step 2 and install packages using this shell.
When you are done with the experiments, you can exit this virtual environment by `conda deactivate`.

3. Install TensorFlow (not TensorFlow 2.x).
```
pip install --ignore-installed --upgrade 'tensorflow >= 1.13.1, < 2'
```

4. Clone this ML-Fairness repository. Alternatively, you can download the repository from [![DOI](https://zenodo.org/badge/269506778.svg)](https://zenodo.org/badge/latestdoi/269506778).
```
git clone https://github.com/sumonbis/ML-Fairness.git
```
Except home credit, all other four datasets are already placed inside `ML-Fairness/dataset/`. Since home credit is a large dataset, it has to be downloaded from original source and placed in its directory. The download instruction is placed inside `ML-Fairness/dataset/home-data/README.md`.

5. Install AIF360 package:
  * Clone AIF360 GitHub repo: `git clone https://github.com/IBM/AIF360`.
  * Copy three datasets (adult, bank, german) from the ML-Fairness repository (`ML-Fairness/dataset/`) which is downloaded in step 4 and then place inside cloned AIF360 repository (`AIF360/aif360/data/raw/`).
  * Navigate to the cloned root directory of AIF360 (`AIF360/`) and run:
  ```
  pip install --editable '.[all]'
  ```

6. Install other necessary packages needed to run the models.
```
pip install xgboost imblearn catboost lightgbm
```

## Execution
Navigate to the source code directory of cloned ML-Fairness repository `ML-Fairness/src/` using the command line environment `(mlfairness) $` from setup step 2.

Under each of the 5 tasks (`german`, `adult`, `bank`, `home`, `titanic`), there are separate python scripts to compute fairness.

#### Run a single model
To get fairness result of a specific model run: `./models.sh <task> <id>` (id is an integer between 1 to 8). For example, to run model 1 of titanic: `./models titanic 1`.

#### Run a single task (8 models)
To run all the models for a single task run `./models.sh <task>`. For example, to run all the models of titanic: `./models.sh titanic`

#### Run all the models (40 models, 5 tasks)
To run all the models for all the tasks, run `./models all`.

Note that the running time depends on the machine. In general, this will take more than a day to run all the models on a personal computer.

#### Results
Running each model will produce result into `.csv` file in this location: `ML-Fairness/src/models/<task>/res/`. One model can be executed multiple times.

For collating the experiments and combine all the results, run `python combine-results.py`. This will produce results specific to each task in `ML-Fairness/src/models/<task>/all-model.csv`.

The results are produced both in raw format and accumulated in a structured one to make it reusable.

## Usage example
Some datasets are pretty large. Training all the models can take hours. In our benchmark, titanic is the smallest dataset. Running the 8 titanic models would produce results within a few minutes.

1. Navigate to `ML-Fairness/src/` and run `python titanic-all.py`. This will show success message on the command line.

2. Then run `python combine-results.py`.

3. The task-specific results are stored in `ML-Fairness/src/models/titanic/all-model.csv`. Also, results for all the tasks are collated in `ML-Fairness/src/models/final-result.csv`. This result can be validated using `ML-Fairness/artifact-result.xlsx`.


## Validate result
All the results presented in the paper are stored in multiple sheets of this excel file: `ML-Fairness/artifact-result.xlsx`. After running the models, the results can be validated using the excel file.

Follow the [Execution](#execution) or [Usage example](#usage-example) to generate/update results into `ML-Fairness/src/models/titanic/all-model.csv`. Validate this result in this file with the `all-result` sheet of the excel file. Note that, the results presented in the excel file are produced after running each of the models multiple times. So, result might differ very slightly after decimal point.

All the tables and figures in the paper are generated from the following sheets of the excel file: `all-result`, `table-2`, `figure-3`, `figure-4`, `figure-8`, `figure-9`. The data in the following sheets are obtained from the master sheet `all-result`. 
