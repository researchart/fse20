# Replication package for "Cost Measures Matter for Mutation Testing Study Validity", accepted at FSE 2020

This is a replication package for the experiments reported in the paper. The full compressed package can be found and downloaded [here](https://doi.org/10.5522/04/11927208) (DOI: 10.5522/04/11927208).

This `README` file explains the structure of the package and gives basic guidelines on how to re-execute the experiments. For more detailed instructions on how to install and execute the scripts, please, refer to `INSTALL.md`.

For more information, contact the first author by e-mail: Dr. Giovani Guizzo \<g.guizzo@ucl.ac.uk\>

---

## Experimental Configuration

All experiments were executed using `Java v1.8.0_231`, `PIT v1.4.12`, and `R v3.5.1` (data analysis).

The machine used in our study uses `Windows 10 v1903`, and is equipped with an `AMD Threadripper 2950X, 16/32 cores, 3.5GHz` CPU and with 32GB of `3200MHz` RAM.

However, we are aware that Windows is not the most used OS among researchers. In order to make this replication package more accessible to most of the readers, all experimental scripts are in the format of `bash v4`. Therefore, the instructions provided in this replication package (including other files and scripts) will work for UNIX-style systems and have been tested on Ubuntu v20. For Windows users, minor changes must be made, e.g, changing the java classpath delimiters from `:` to `;` in the scripts and running the scripts on Linux Bash Shell for Windows rather than CMD or PowerShell.

---

## "originalprograms" directory

The original programs used in the work of [Offutt et al. (1996)][1].

Those are Java implementations of the same programs, gathered from multiple sources.

---

## "largerprograms" directory

The programs used in the experiments and reported in the paper.

---

## "junit" directory

The [JUnit][2] dependencies used by [PIT][3] to perform the mutation analysis.

---

## "pitest" directory

The whole [PIT][3] repository.

A few source files were modified to allow the storage of execution times in `csv` files using the "CSVTimings" output strategy.

---

## "scripts" directory

This directory contains all the scripts used to run the experiments, treat the resulting data, and then generate the graph shown in the paper.

All scripts must be executed from the parent directory, e.g., `./scripts/experiments-original.sh`.

The files of this directory are:

1. `experiments-original.sh` - Generates a command queue and outputs the experiment commands to a new file `commandqueue.txt`. This set of commands use Java versions of the original programs used by [Offutt et al. (1996)][1]. Each command represents one independent run;
2. `experiments-large.sh` - Generates a command queue and outputs the experiment commands to a new file `commandqueue.txt`. This set of commands use the 10 large Java programs reported in the paper. A few test cases and/or tested classes were excluded from the mutation analysis according to their respective project's `pom.xml` exclusion criteria, or to avoid incompatibilities with [PIT][3]. Each command represents one independent run;
3. `treatment.R` - R script that collects and treats the experimental data contained in the "experiments" directory;
4. `mutationscore.R` - Computes the mutation score of each program using all mutants using the experimental data contained in the "experiments" directory;
5. `graph.R` - Generates the slopegraph reported in the paper using the experimental data contained in the "experiments" directory.

---

## "experiments" directory

This directory contains all the results obtained during the reproduction of the work of [Offutt et al. (1996)][1] to answer RQ4. The directory is structured as follows:

```
experiments/<program>/<strategy>/<run>/
```

Each subdirectory has two files:

1. `mutation.csv` - The result of the mutation testing as outputted by [PIT][3], containing all the details about which mutant was killed by which test case. Each row represents a mutant, whereas each column represents one of the mutant's attribute. The columns of this file are:
    1. Mutated File;
    2. Mutated Class;
    3. Mutation Operator;
    4. Mutated Method;
    5. Mutated Line;
    6. Status;
    7. Number of Test Runs;
    8. Killing Test Case;
2. `mutation-timings.csv` - The execution timings for the strategy. The columns of this file are:
    1. `stage` - Stage of the Mutation;
    2. `timing` - Stage's Execution Time in milliseconds;

`mutations.csv` does not have an embedded heading, whereas `mutation-timings.csv` has. This should not be a problem, since our scripts already cater for the lack of headings in the former file.

Additionally, this directory contains two other files:

1. `slopegraph.png` - The graph depicted in the paper to answer RQ4;
2. `treateddata.csv` - All the experimental data contained in the aforementioned structure, but treated by the "scripts/treatment.R" script. Each row is one measurement for a given experiment. The columns of this file are:
    1. `program` - The program of the experiment;
    2. `strategy` - The strategy of the experiment;
    3. `run` - The independent run of the experiment;
    4. `metric` - The metric measured;
    5. `value` - The value of the metric for that experiment.

These results can be generated and then evaluated using the scripts contained in the `scripts` directory. Bear in mind that if the commands generated by such scripts are executed, the data in the `experiment` directory will be overwritten.

[1]: http://cse.unl.edu/~grother/papers/tosem96apr.pdf
[2]: https://junit.org/junit4/
[3]: http://pitest.org/
