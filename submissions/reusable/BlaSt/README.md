# Readme

This artifact consists of a Docker container that can be obtained [here](https://doi.org/10.5281/zenodo.3872848) (alternative, pre-built, [here](https://hub.docker.com/r/mreif/blast)).
The Docker container contains the necessary tools (OPAL, of which BlaSt is part of and DOOP), benchmarks (XCorpus, DoopBenchmarks), scripts to run the tools for the experiments performed in the paper and scripts to clean up the output of these experiments to reproduce the tables from the paper.

After obtaining the Docker container and starting it as explained in __INSTALL.md__, the experiments can be executed as explained below:

## Running the experiments

Execution of the experiments is performed through the __evaluation.sh__ shell script. This script takes two kinds of parameters, a list of all experiments to execute and a number of repetitions to perform (defaulting to 1).
In order to run all experiments with 7 repetitions as performed in the paper, run
```
$ ./evaluation.sh -ex1_purity -ex1_callgraph -ex2 -ex3 -rounds 7
```

> Note: Using 7 repetitions, this may take several days. Also, 128GB of memory is required for the Scala sub-experiment of experiment 3. All other experiments require 32GB of memory. Experiment 2 will execute with up to 128 threads and is, therefore, best suited to a system with 64 cores and SMT.


You can also execute the individual sub-experiments of experiment 3 with individual flags, e.g.
```
$ ./evaluation.sh -ex3_blast -ex3_doop -ex3_scala
```

The command line output of the individual experiments is stored into files named _ex1_purity.log_, etc. Additionally, the individual experiments will produce output in the results directory.

## Cleaning up the data

### Medians

As a first post-processing step, the median of all repetitions should be computed. You can do so by executing __median.sh__ (with the same experiment-parameters as __evaluation.sh__):
```
$ ./median.sh -ex1_purity -ex1_callgraph -ex2 -ex3
```

If necessary, medians for individual _.csv_-files can be computed using the __cleanup-scripts/median_blast.sh__ and __cleanup-scripts/median_doop.sh__ files, respectively, e.g.,
```
$ ./cleanup-scripts/median_blast.sh results/RQ2_purity/hsqldb/purityResults.csv >> results/RQ2_purity/hsqldb/purityResults_median.csv
```

to produce the medians for the RQ2 purity sub-experiment on hsqldb that is presented in Table 2 in the paper.

### Further clean-up

Further scripts exist to extract the csv-columns that are reported in the paper and to remove the raw output files.
This can again be done for all experiments:
```
$ ./cleanup.sh -ex1_purity -ex1_callgraph -ex2 -ex3
```

The result of this are two files for each individual experiment and benchmark project:
__raw-results.csv__, containing the relevant data for all individual repetitions and __aggregated-results.csv__, containing the medians for the relevant data, e.g., 
```
results/RQ2_purity/hsqldb/aggregated-results.csv
```
contains the results presented in Table 2 in the paper (including additional rows omitted from the paper for brevity).

## Reuse

You can reuse the Docker container for other experiments involving BlaSt's purity and call-graph analyses.
For a first impression of how to do so, we suggest you have a look at the scripts in the _experiment-scripts_ directory.
You can also execute
```
$ cd /home/blast-evaluation/opal
$ sbt -J-Xmx32G "; project Tools; runMain org.opalj.support.info.Purity"
$ sbt -J-Xmx32G "; project Tools; runMain org.opalj.support.info.CallGraph -help"
```
in order to get documentation on further parameters for both the purity and call-graph analyses.
The _-J-Xmx_ parameter to _sbt_ sets the amount of available heap space, 32GB is typically enough for most analyses, but if you encounter problems with the heap space, you may want to change this.

You can execute
```
$ cd /home/blast-evaluation/doop
$ ./doop
```
in order to get documentation on how to run Doop's various analyses.