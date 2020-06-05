# Installing
We recommend using the pre-packaged VM, available at

```bash
$ wget https://ams-fse.s3.us-east-2.amazonaws.com/ams.ova
```

which can be loaded into your preferred platform (we tested using
  VirtualBox 6.0).

However, these instructions are included for completeness if you would
like to 1) re-install `ams`, or 2) rebuild `ams` (i.e. train
it on the code corpus).

AMS *should* run without issues on Ubuntu and Mac OSX (tested on 10.11.6).
If you have issues running, we suggest using the pre-packaged VM.

### Installation
First, clone the `ams` repository.

```bash
$ git clone git@github.com:josepablocam/ams.git
$ cd ams/
```

If you don't have `conda` already, please install from

https://docs.conda.io/en/latest/miniconda.html

Once you have done so, you can build the conda environment

```bash
$ conda env create -f environment.yml
```

This creates the conda environment `ams-env`.

All scripts/commands should be executed from the root `ams` directory
and with the `ams-env` environment active (i.e. run `conda activate ams-env`
when using AMS).

If you would like to modify the location where data/resources etc are
saved down, you should edit `scripts/folder_setup.sh` accordingly.
These paths are used/referenced throughout the remainder of the setup.

You should then install some additional supporting resources by running

```bash
$ bash scripts/setup.sh
```

This may take some amount of time as it has to download/build multiple
third-party tools.


You can verify that your installation has completed successfully by running

```bash
$ python -m core.generate_search_space --help
```

You should see a help message printed to the console.


### Building AMS
To use AMS, AMS first extracts rules for complementary components,
indexes the API documents, and extracts hyperparameter/value frequency
distributions from the code corpus. To build this, just execute

```bash
$ bash scripts/build_ams.sh
```

This may take some time as AMS traverse the API's module hierarchy
and extracts information from the code corpus. You will see messages such as
`Trying <...>` or `Failed <...>`. These can be safely ignored.

Once you are done with this, you are ready to use AMS and shouldn't need
to tweak anything else.


# Known Latency Issue
Loading the SciSpacy language model takes approximately 30 seconds.

```python
spacy_nlp = spacy.load("en_core_sci_lg")
```
This is a known hurdle for language models in Spacy
(see https://github.com/explosion/spaCy/issues/2679 for a similar example)

This latency is a cost to starting up AMS on each new weak specification.
A simple workaround (that has not yet been implemented), is to run
AMS as a server application, with new weak specifications provided as input
from a client. We eschew this for the current artifact as it may complicate
use of AMS for reviewers.


# Using AMS
If you would like to use AMS to generate search spaces for your weak specs,
you can use the script `scripts/use_ams.sh`.

For example,

```bash
$ (bash scripts/use_ams.sh sklearn.linear_model.LogisticRegression sklearn.preprocessing.MinMaxScaler) > config.json
```

produces a strengthened search space for this weak specification.

```bash
$ cat config.json | jq # note we don't install jq
{
  "sklearn.linear_model.SGDClassifier": {
    "loss": [
      "log",
      "hinge"
    ],
    "penalty": [
      "l2",
      "elasticnet",
      "l1"
    ],
    "alpha": [
      1e-05,
      0.0001
    ]
  },
  "sklearn.linear_model.LogisticRegression": {
    "C": [
      100000,
      7,
      100,
      1
    ],
    "penalty": [
      "l1",
      "l2"
    ],
    "class_weight": [
      "auto",
      "balanced",
      null
    ]
  },
  "sklearn.linear_model.RidgeClassifier": {
    "solver": [
      "sag",
      "auto"
    ],
    "tol": [
      0.01,
      0.001
    ]
  },
  "sklearn.preprocessing.StandardScaler": {
    "copy": [
      true,
      false
    ],
    "with_mean": [
      true,
      false
    ],
    "with_std": [
      true
    ]
  },
  "sklearn.linear_model.Log": {},
  "sklearn.preprocessing.MinMaxScaler": {
    "copy": [
      true
    ]
  },
  "sklearn.preprocessing.RobustScaler": {},
  "sklearn.preprocessing.MaxAbsScaler": {},
  "sklearn.preprocessing.Binarizer": {}
}
```



The script hardcodes various AMS choices, which you can modify as desired.
In particular, the script sets:

```bash
NUM_COMPONENTS=4
NUM_ASSOC_RULES=1
ALPHA_ASSOC_RULES=0.5
NUM_PARAMS=3
NUM_PARAM_VALUES=3
```

`NUM_COMPONENTS` refers to the number of functionally related components
to add (at most) per component in the weak spec. `NUM_ASSOC_RULES` refers
to the number of complementary components to add (at most) per component
in the weak spec. `ALPHA_ASSOC_RULES` combines a rule's normalized-PMI
and support fraction to obtain a single score for an association rule,
we used 0.5 in our evaluations but you can modify if you'd like. Please
see the paper for details. `NUM_PARAMS` is the (max) count of hyperparameters to
include in the search space for each component in the extended specification,
and `NUM_PARAM_VALUES` is the (max) number of possible values (in addition
to the default value) for each hyperparameter in the extended search space.

# Using an AMS generated search space
AMS produces a search space in JSON format. This configuration can be
read in and used directly with TPOT, or with the random search procedure
used for AMS evaluation.

For example, we first generate the search space from the prior example
and dump it into a text file

```bash
$ (bash scripts/use_ams.sh sklearn.linear_model.LogisticRegression sklearn.preprocessing.MinMaxScaler) > config.json
```

We then launch the python interpreter, read in the configuration,
and show how it can be used on a generated dataset

```python
$ python
import json
import tpot
import sklearn.datasets
from core.search import RandomSearch

X, y = sklearn.datasets.make_classification(100, 10)
config = json.load(open("config.json", "r"))

# GP-based search
clf_tpot = tpot.TPOTClassifier(max_time_mins=1, config_dict=config, verbosity=3)

# Random search
clf_rand = RandomSearch(max_time_mins=1, max_depth=3, config_dict=config)


clf_tpot.fit(X, y)
clf_rand.fit(X, y)
```
