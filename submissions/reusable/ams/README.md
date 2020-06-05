# AMS
AMS is a tool to automatically generate AutoML search spaces from
users' weak specifications. A weak specification is defined a set
of API classes to include in the AutoML search space. AMS then
extends this set with complementary classes, functionally-related classes,
and relevant hyperparameters and possible values. This configuration can
then be paired with existing search techniques to generate ML pipelines.
AMS relies on API documentation and corpus of code examples to strengthen
the input weak spec.

# Artifact
You can download a VM (if you are not already using it) from
https://ams-fse.s3.us-east-2.amazonaws.com/ams.ova .

The DOI for this artifact is
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3870818.svg)](https://doi.org/10.5281/zenodo.3870818)


```bash
$ wget https://ams-fse.s3.us-east-2.amazonaws.com/ams.ova
```
The should result in a `.ova` (format version 1.0) that can be imported into
virtualbox or vmware. This image was exported and tested with Virtualbox version 6.0.

Once you load the VM into your preferred platform, you should navigate to
the `ams` folder and activate the `conda` environment.

```bash
$ cd ~/ams/
$ conda activate ams-env
```

If you are interested in seeing the `ams` repository (which
reiterates reproduction steps), please clone as below

```bash
$ git clone git@github.com:josepablocam/ams.git
```

# Reproducing FSE evaluation
You can reproduce FSE experiments and figures by using scripts in
`scripts/fse/`. As others, these should be run from the root AMS directory.
Given that some of the experiments explained below take on the order of days
to run on a well-provisioned machine, we provide a download of our experimental
results. (If you are using the artifact VM, these results have already been
loaded and you can skip the following step).

### Datasets and Internet Connection
Note that running experiments requires access to the internet, in order
to download datasets. Alternatively, you can download all datasets first,
and then (offline) run experiments. *If you are using the artifact VM,
you do not need to download datasets, as they have been downloaded for you*.

You can download the necessary datasets by running

```bash
$ bash scripts/fse/download_datasets.sh
```

### Downloading Results
If you want to download the results, you can run

```bash
$ bash scripts/fse/download_results.sh
```

This will download results from an AWS S3 bucket and will place results in
`$RESULTS` and `$ANALYSIS_DIR`. In particular,

`${RESULTS}` will now contain folders of the form `q[0-9]+`, one for each of
the 15 weak specifications in our experiments. In it, you will find the
weak specification (`simple_config.json`),
the specification with expert-defined hyperparameters (`simple_config_with_params_dict.json`), and the AMS-generated search space
(`gen_config.json`).

The folder `random` contains results (again organized by weak specification
experiment) when using random search, while `tpot` contains results
when using genetic programming (the TPOT tool).

`rule-mining/` has experimental results for the complementary component
experiments.

#### Tables and Figures

The folder `$ANALYSIS_DIR` (`analysis_output` in the VM) holds figures/tables produced in analysis
and used in the paper. In particular,

* Table 2: `rules/roles.tex`
* Figure 3: `rules/precision.pdf`
* Figure 4: `relevance/plot.pdf`
* Figure 5:
    - (a) `hyperparams/num_params_tuned.pdf`
    - (b) `hyperparams/distance_params_tuned.pdf`
    - (c) `hyperparams/num_param_values.pdf`
* Figure 6: `hyperparams/perf.pdf`
* Figure 7: `performance/combined_wins.pdf`
* Figure 8: `tpot-sys-ops/combined.pdf` (includes extended examples)

(Tip: To open PDFs from the terminal in the Ubuntu VM, you can use `xdg-open file.pdf`)

### Scripts
`bash scripts/fse/reproduce_complementary_experiments.sh` reproduces experimental results relating
to extraction of complementary components to add to weak specifications. These
experiments should take on the order of a couple of hours to run.

`bash scripts/fse/reproduce_functional_related_experiments.sh` generates the data used for
manual annotation of functionally related components. We have already included
our manually annotated results as part of the artifact, so running this script
will prompt you to confirm before overwriting those with (unannotated) data.

`bash scripts/fse/reproduce_performance_experiments.sh` generates search space configurations
and evaluates them against our comparison baselines (weak spec, weak spec + search,
and expert + search). Running these experiments from scratch *takes on the order
of 1-2 days on a machine with 30 cores*. Given this computational burden, we have
also included our results in the artifact.

`bash scripts/fse/reproduce_analysis.sh` generates figures from the outputs of the prior
3 scripts and also runs some additional (~ 1 hour execution) experiments to
characterize the hyperparameters found in our code corpus.

The figures/tables are generated and saved to `$ANALYSIS_DIR`
(set to `analysis_output/`, if not modified in `folder_setup.sh`).
Please see the prior section for details on figure/table mappings.



# Codebase Overview
We provide a short overview of the AMS codebase:

* `core/` contains the main tool logic:
  - `extract_sklearn_api.py`: traverse sklearn modules to find classes
  to import and represent with embeddings (also has stuff on default parameters)
  - `nlp.py`: helper functions to parse/embed natural language
  - `code_to_api.py`: takes a code specification and maps it to possibly
  related API components using pre-trained embeddings
  - `extract_kaggle_scripts.py`: filter down meta-kaggle to find useful scripts
  (i.e. those that import target scikit-learn library)
  - `extract_parameters.py`: (light) parse of python scripts from kaggle
  to extract calls to APIs and their parameters
  - `summarize_parameters.py`: tally up frequent parameter names/values
  by API component
  - `generate_search_space.py`: given weak spec (code/nl) generate
  search space dictionary
  - `search.py`: various search strategies and helpers


* `experiments/` contains all code to run experiments:
  - `download_datasets.py`: download benchmark datasets and cache (in case working without internet later on)
  - `generate_experiment.py`: generate experiment configurations based on some predefined components of interest
  - `simple_pipeline.py`: compile weak spec directly into a sklearn pipeline for benchmarking
  - `run_experiment.py`: driver to run different search strategies/configurations

* `analysis/`: contains code to run analysis on experiment outputs and conduct
additional characterization of our data.
  - `annotation_rules_component_relevance.md`: details our annotation guidelines for manually assessing functionally related components
  - `association_rules_analysis.py`: evaluates the rules used to extend specifications with complementary components
  - `combined_wins_plot.py`: is a utility to combine win counts into a single plot
  - `distribution_hyperparameters.py`: characterizes hyperparameters found in our code corpus
  - `frequency_operators.py`: compute distribution of components in pipelines
  - `performance_analysis.py`: compute table/plots of wins from performance experiments data
  - `pipeline_to_tree.py`: convert pipeline from API into a tree (easier to analyze) utility
  - `relevance_markings.py`: create plot of functionally related components' manual annotation results
  - `utils.py`: misc utils
