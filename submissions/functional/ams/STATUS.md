We submit our artifact to be considered for the *available*,
*functional*, and *reusable* badges. Below our supporting arguments
for each.

### Available Badge
We have made available a public github repository
(https://github.com/josepablocam/ams), a pre-packaged VM
(https://ams-fse.s3.us-east-2.amazonaws.com/ams.ova), and we have uploaded the
pre-packaged VM to Zenodo for a DOI.

The DOI for this artifact is
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3870818.svg)](https://doi.org/10.5281/zenodo.3870818)


### Functional Badge
The pre-packaged VM includes all necessary components to replicate our paper
results, and reviewers are also free to rebuild the codebase from the github
repository.

We have included a scripts folder (`scripts/fse`) to run every experiment in the
paper. We have also pre-packaged the paper results and included these, given the
computational burden of running some of our experiments.

Our README.md maps specific tables/figures in the paper to outputs produced by
our scripts, and we include descriptions of the tasks performed by each script.

### Reusable Badge
We have organized our codebase around the goal of enabling reuse. In particular,
the core tool logic is factored out into its own subdirectory (`core`), with
each file dedicate to a single goal. Code for our empirical evaluation has been
isolated in `experiments` and `analysis/`, and exercising these has been
facilitated by creating a `scripts/` folder with bash scripts where all command
line arguments are specified and clearly identified.

Our README.md provides an overview of every file in our codebase and we believe
this facilitates reuse by future developers and researchers.
