# Replication Package "Dynamically Reconfiguring Software Microbenchmarks: Reducing Execution Time Without Sacrificing Result Quality"

This is the replication package for the ESEC/FSE 2020 paper "Dynamically Reconfiguring Software Microbenchmarks: Reducing Execution Time Without Sacrificing Result Quality" authored by Christoph Laaber, Stefan Würsten, Harald C. Gall, and Philipp Leitner [[Preprint](http://t.uzh.ch/13k)].

The artifact can be downloaded from figshare: [DOI](https://www.doi.org/10.6084/m9.figshare.11944875).
This README is a copy of the README contained in the artifact on figshare.
The whole artifact is 2.4GB (2.2GB compressed) big, hence we do not include it here.
Unpack the articact with `tar -zxvf replication_package_fse20_laaber.tar.gz`.

It consists of three main directories:

1. `evaluation/` contains all data and scripts to replicate the study.
2. `raw-data/` contains the JMH benchmark suite execution results for the ten study subjects.
3. `jmh-dynamic-reconfiguration/` contains the JMH fork implementing the dynamic reconfiguration appoach.

## Installation

See [installation](INSTALL.md) instructions.


## Pre-Study
The folders in `evaluation/` starting with `pre-study_*` and `R_script` are relevent for replicating the results.

Note that the complete replication requires downloading and parsing ~1500 projects from Github.
We also provide intermediate data files where specified so that individual steps can be skipped.

### 0. JMH Projects Github Data Set
The file `pre-study_subjects/pre-study_subjects.csv` (and the same file with a header `pre-study_subjects/pre-study_subjects-header.csv`) is the output of the data set generation as described in the paper in section 3.1.
The scripts for creating this data set are not available anymore and, hence, not part of this replication package.
However, the description in the paper should be sufficient to build a tool that extracts the JMH projects from BigQuery, Github, and Maven Central.

### 1. Setup Evaluation Directory Path
In `pre-study_kotlin`, change variable `p` in `smb.conf.sop.EvaluationPath` to the fully qualified path of the `evaluation` folder.

### 2. Clone JMH Projects
Clone all initial projects for the pre-study (1544 projects) from directory `pre-study_kotlin/`:
```bash
./gradlew runClone -Dargs="pre-study_subjects/pre-study_subjects.csv [projectRepos]"
```

where
* `[projectRepos]` is the path to the directory that should contain all cloned git repositories.

### 3. Parse JMH Benchmarks

This step parses all benchmarks from all projects and extracts source code information, such as the benchmark configuration.
The result of this step are the files in `pre-study_results/current-commit/results/`.


1. Use source code parser in `pre-study_kotlin` to parse the metrics from Java source files:
2. Set up source code parser according to its [instructions](evaluation/pre-study_kotlin/README.md).
3. Then run from directory `pre-study_kotlin/`:
```bash
./gradlew runEvaluation -Dargs="pre-study_subjects/parser-input.csv [projectRepos] pre-study_results/current-commit/results/ error.csv"
```
where

* `pre-study_subjects/parser-input.csv` is the list of 1544 JMH projects from `pre-study_kotlin/pre-study_subjects.csv`
* `[projectRepos]` is the directory with all cloned Github repositories, as populated in the first step
* `pre-study_results/current-commit/results/` is the output folder.
Be aware that running the script will override the existing files.
* `error.csv` is the CSV file (put into `evaluation/`) containing errors during the execution per project


### 4. Merge Project Files

Next, one must merge the files from the previous step (`pre-study_results/current-commit/results/`) into a single file.
A row in this file(s) corresponds to a single benchmark.
This is done in the following three steps:

1. Merge all files with:
```bash
./gradlew runCreateMerged
```

This creates the file `pre-study_results/current-commit/merged.csv`.
Note that the script appends to this file.

2. Filter projects that are "main" repoisitories with:
```bash
./gradlew runCreateMergedIsMain
```

This creates the file `pre-study_results/current-commit/merged-isMain.csv`.

3. Add header to `pre-study_results/current-commit/merged-isMain.csv`.
This was done in a manual step.
The file can be found in `pre-study_results/current-commit/merged-isMain-header.csv` and is used in subsequent analyses.


### 5. Create Analysis Input Data

Run the analysis scripts in `pre-study_kotlin` on top of the created data in the following order:

The following command generates the CSV file `pre-study_results/aggregated/executiontime.csv` with details about every benchmarks' execution time.
```bash
./gradlew runExecutionTime
```

The following command generates the CSV file `pre-study_results/aggregated/features.csv` with statistics about individual benchmarks.
```bash
./gradlew runFeatures
```

The following command generates the CSV file `pre-study_results/aggregated/jmhversion.csv` that shows a histogram of which JMH versions are used by the projects in our data set.
```bash
./gradlew runJMHVersion
```

The following command generates the CSV file `pre-study_results/aggregated/numberofbenchmarks.csv` with the number of benchmarks per project.
```bash
./gradlew runNrBenchmarks
```

### 6. Scripts for Paper Data

To retrieve the data mentioned in the text of the paper, run the python scripts in `pre-study_python`.
The following python scripts take the files created in the previous step as input.

```bash
pipenv run python jmh_version.py
pipenv run python number_of_benchmarks.py
pipenv run python number_of_parameterization.py
pipenv run python execution_time_per_testsuite_all.py
```

### 7. Scripts for Paper Figures

To create the Figures 2a and 2b, run the function `prestudy_execution_time_all` of the R script `prestudy.R` in `R_scripts`.

We used RStudio to execute the scripts, where we set the working directory to `R_scripts`.
On macOS this can be achieved by openening RStudio with `open -a RStudio prestudy.R` from within the directory `R_scripts`




## Empirical Evaluation
To retrieve compute the necessary data and run the analyses for our empirical evaluation, the folders in `evaluation/` starting with `study_*` as well as `executor` and `R_scripts` are relevant.

### 1. Build JMH JARs

We need to build the JMH fat-jars of the ten study subjects first, using their build systems (gradle or maven).
All projects need to be patched to use JMH 1.21, which involves manual changes to the respective build scripts.

We provide the JARs for our study subjects in `study_subjects`:
* byte-buddy: `byte-buddy.jar`
* JCTools: `jctools.jar`
* jdk: `jmh-jdk-microbenchmarks.jar`
* jenetics: `jenetics.jar`
* jmh-core: `jmh-core-benchmarks.jar`
* log4j2: `log4j2.jar`
* protostuff: `protostuff.jar`
* RxJava: `rxjava.jar`
* SquidLib: `squidlib.jar`
* zipkin: `zipkin.jar`

### 2. Setup Evaluation Directory Path
In `study_kotlin`, change variable `p` in `smb.conf.dynreconf.EvaluationPath` to the fully qualified path of the `evaluation` folder.

### 3. Build Benchmark Executor

In order to run the JAR files from above with the configuration used in our paper,
we provide an executor and configuration files.

First, create the executor with the following script:
```bash
cd executor
./gradlew shadowJar
```
The executor far-jar is then located in `executor/build/libs/executor.jar`.

### 4. Create Executor Input Files

We provide the executor input files in `study_subjects`.
The files have the structure `[projectName].csv` where `[projectName]` corresponds to the individual study subject.
Note that we manually excluded the benchmarks listed in `study_subjects/ignored-benchmarks.csv` for the provided reasons.


If you want to create your executor input files from the JAR file, run the following command (this command does not exlude the benchmarks from file `study_subjects/ignored-benchmarks.csv`):
```bash
./gradlew runExecutorInput -Dargs="[projectName] [project.jar] [fqn] [javaPath] [benchmarkConfig] [outFile]"
```

where
* `[projectName]` is the name of the study subject.
* `[project.jar]` is one of the 10 study subject jars above (not the path, just the name as mentioned above)
* `[fqn]` is the fully-qualified prefix path of the study subject (see below for valid FQNs)
* `[javaPath]` is the fully-qualified path to the `java` binary to use for benchmark execution.
Not that all projects except `log4j2` use JDK 1.8; `log4j2` uses JDK 13 (see Required Software section above).
* `[benchmarkConfig]` is the configuration used for all benchmarks.
Our paper uses `'-bm sample -f 5 -i 100 -wi 0 -r 1'`
* `[outFile]` is the output file name.
We provide already created output files in `study_results/[project].csv` where `[project]` is the project name

Our study subjects' FQNs are the following:
* byte-buddy: `net.bytebuddy`
* JCTools: `org.jctools`
* jdk: `org.openjdk.bench`
* jenetics: `io.jenetics`
* jmh-core: `org.openjdk.jmh`
* log4j2: `org.apache.logging.log4j`
* protostuff: `io.protostuff`
* RxJava: `io.reactivex`
* SquidLib: `squidpony`
* zipkin: `zipkin2`


### 4. Execute JMH Benchmarks

Run executor to retrieve benchmark results for each study subject (project), ideally in a controlled environment, such as a bare-metal machine (see paper).
Note that this steps takes many days (see Exec. Time in Table 1 in the paper);
hence, we provide the data coming from this replication step.

```bash
java -jar executor/build/libs/executor.jar study_subjects/[projectName].csv raw-data/json/[projectFolder]
```
where
* `[projectName].csv` corresponds to a study subject CSV file on `study_subjects`.
Adapt the path (`PATH/TO/project.jar`) to the JAR in the CSV files
and
the JDK java binary `PATH/TO/java` to either Java 1.8 or Java 13 (only for log4j2) command.
* `[projectFolder]` corresponds to the folder where the result JSON files (per project) should be saved.

We provide all our measurements in `raw-data/json` packaged and zipped in tar.gz files.
Run `tar -zxvf [projectName].tar.gz` to extract it.

### 5. Transform JMH JSON Files to CSV Files

Run the JMH JSON to CSV converter (in `study_kotlin`) for each study subject (project) with:
```bash
./gradlew runJsonToCsv -Dargs="[jsonFolder] [csvFolder]"
```
where
* `[jsonFolder]` is the directory that contains the JMH JSON foles of a project,
such as ``raw-data/json/[projectName]`
* `[csvFolder]` is the directory where the transformed CSV files should be saved.
This directory needs to exist and should be empty, otherwise the script fails.


### 6. Generate Input Data for Analyses

This step generates the input data for the analyses.
Note that due to the bootstrap technique (statistical simulation), this step takes a long time
(for `byte-buddy`, which is one of the smaller projects, this script runs ~20 minutes on a MacBook Pro with 2.7 GHz Quad-Core Intel Core i7).
Hence, we provide all resulting data per project in `study_results/variability/[projectName]`.

If one wants to generate the data from scratch, run the following command for every study subject (project) with:
```bash
./gradlew runAnalysesData -Dargs="[csvFolder] [projectFolder]"
```

where
* `[csvFolder]` is the directory that contains the JMH CSV files of a project.
* `[projectFolder]` is the output directory where the generated data is saved to.

### 7. Measure Overhead of Stoppage Criteria

Run the executor again for log4j2 and JMH version `1.21-reconfigure` (provided at `study_subjects/log4j2-reconfigure.jar`) to measure the performance overhead of each stoppage criteria.
Again, ideally this execution happens in a controlled environment, such as a bare-metal machine (see paper).

The stoppage criteria are:
* *no*, which is the baseline without dynamic reconfiguration
* *cov*, which corresponds to CV in the paper
* *kld*, which corresponds to KLD in the paper
* *ci*, which corresponds to RCIW in the paper

To measure the overhead run the following command in 4 different configurations, for the baseline and the three stoppage criteria:
```bash
java -jar executor/build/libs/executor.jar study_subjects/[executor.csv] raw-data/overhead/[stoppageCriteria]
```

where
* `[executor.csv]` defines the executor input file (see below for the 4 files to be run)
* `raw-data/overhead/[stoppageCriteria]` is the folder (which must be created) for each stoppage criteria.

Executor input files (`[executor.csv]`):
* *no*: `study_subjects/log4j2-overhead.csv`
* *cov*: `study_subjects/log4j2-overhead-reconfigure-cov.csv`
* *kld*: `study_subjects/log4j2-overhead-reconfigure-kld.csv`
* *ci*: `study_subjects/log4j2-overhead-reconfigure-ci.csv`

Similar to "4. Execute JMH Benchmarks", the executor input files require manual adaption for:
* the path to the JDK java binary `PATH/TO/java`
* the path to the log4j2 JAR with reconfiguration `PATH/TO/log4j2-reconfigure.jar`

The executor generates a CSV file with the execution time of every benchmark named `executionTime.csv`, which is located in `raw-data/overhead/[stoppageCriteria]/`.

We provide the 4 `executionTime.csv` files for the 4 stoppage criteria in `study_results/time/overhead/`.
The file `defaultExecutionTime.csv` corresponds to the *no* stoppage criteria.

#### Overhead Computation for other Projects (not part of the paper)

To compute overheads of other projects, the reconfiguration JMH fork must be published to Maven local and the build script of the project must be patched with JMH version `1.21-reconfigure`.


### 8. Analyses for Paper Data

Run the scripts in `study_kotlin` in the following order to perform all required analyses.

1. The data for **RQ1** *Mean Change Rate* Table 2 A/A Tests (per project) can be optained with the following script:
```bash
./gradlew runRQ1ChangeRateTable
```

We provide the resulting CSV file in `study_results/variability/variability.csv`.

2. The data for **RQ1** *Mean Change Rate* Figure 4 can be optained with the following script:
```bash
./gradlew runRQ1ChangeRateFigure
```
To change between `cov`, `ci`, and `divergence`, one needs to adapt the variable `outputFile` in `smb.conf.dynreconf.analysis.boxplotmeanchangerate.Main.kt` as well as the variable `meanCustom` in the function `eval` of the same file.
The correct values for the two variables are commented out.

We provide the resulting CSV files in `study_results/variability/boxplot_meanchangerate_cov.csv`, `study_results/variability/boxplot_meanchangerate_divergence.csv`, and `study_results/variability/boxplot_meanchangerate_ci.csv`.

3. Create **RQ1** *Mean Change Rate* Figure 4 and Table 2 with `R`

Run the function `rq_1_change_rate_all` R script `rq_1_change_rate.R` in `R_scripts` to create the figures and data for RQ1.
It also prints the data for the *Mean Change Rate* rows of Table 2.

4. Create **RQ2** data and Table 3

The following scripts generates when the benchmarks stop, according to the stoppage criterio, how many forks and iterations are executed, and how long it oberall takes:
```bash
./gradlew runRQ2Data
```

We provide the resulting CSV files in `study_results/time/cov.csv`, `study_results/time/divergence.csv`, and `study_results/time/cv.csv`.

The following script then creates Table 3 from the previous files.
```bash
./gradlew runRQ2Table
```

We provide the resulting CSV file in `study_results/time/projects.csv`.

5. The data in section **RQ2** *Stoppage Criteria Checkpoints* can be computed with:
```bash
./gradlew runRQ2StoppageCriteriaCheckpoints
```

We provide the resulting CSV file in `study_results/variability/avgiterationandforks.csv`.


# JMH 1.21 reconfiguration fork

The fork that implements dynamic reconfiguration in JMH 1.21 can be found in
* the directory `jmh-dynamic-reconfiguration/`
or
* on [Github](https://github.com/sealuzh/jmh).

The changes made compared to JMH 1.21 can be found in the PDF `jmh-dynamic-reconfiguration-1_21-changes.pdf` or alternatively on [Github](https://github.com/sealuzh/jmh/compare/1.21-release...1.21-reconfigure).

Our JMH 1.21 reconfiguration fork requires Java 1.8.
Installation and usage instructions are in the fork's [readme](jmh-dynamic-reconfiguration/README.md).

# Contact

See [contact](CONTACT.md).
