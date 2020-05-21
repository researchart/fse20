# Installation and Usage Instructions

## Java

### Download and Install Java

The experiments in this work were executed using `Java JDK v1.8.0_231`. To check your Java version, run the following command:

```bash
java -version
```

If you do not have `Java JDK v1.8.0_231` or a newer version installed, please download the latest version of `Java JDK 8` here [Java SE Development Kit 8 Downloads](https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html), and then install it following the instructions provided by Oracle.

If you have it already installed but the command is not working, then make sure the java executable directory is available in your `$PATH` environment variable.

---

## R

### Download and Install R

The data analysis done in this work was performed using `R v3.5.1`. To check your R version, run the following command:

```bash
R --version
```

or if you are on Windows:

```powershell
R.exe --version
```

If you do not have `R v3.5.1` or a newer version installed, please download the latest version of `R v3` here [The R Project for Statistical Computing](https://www.r-project.org/), and then install it following the instructions provided by The R Foundation.

If you have it already installed but the command is not working, then make sure the R executable directory is available in your `$PATH` environment variable.

### Install R dependencies

Once R is installed, start it using the command line `R` or `R.exe`, or using your preferred method. Then run the following R command to install the needed R packages:

```R
install.packages(c("tidyverse","GGally","MLmetrics","data.table","effsize","pgirmess","hms","lubridate","ggrepel"))
```

Follow the installation instructions. Once the installation is done, close the R session using `q()` and then you are ready to use the R scripts provided in this package.

---

## Preparing the Replication Package

The full compressed package can be found and downloaded [here](https://doi.org/10.5522/04/11927208). When the download is complete, unpack it to a directory of your liking.

If Java and R are installed as previously instructed, then you are ready to use the package. There is no additional installation.

---

## Using the Replication Package

For a full detailed description of each directory included in the package, please refer to `README.md`.

### Running the Experiments

To simplify the examples, we will present them in the form of Linux commands (e.g., using `R /path/to/script.sh` instead of `R.exe C:\path\to\script.cmd`).

To run the experiments, the first step is to go to the unpacked package directory.

```bash
cd Replication-Package
```

We provide two experiment scripts: `./scripts/experiments.sh` and `./scripts/experiments-large.sh`. Both scripts create a file named `commandqueue.txt` containing a list of commands that must be executed in order to reproduce the experiments. The first script generates commands using the toy programs provided in `./originalprograms`, whereas the second script generates commands using the larger Java programs provided in `./largerprograms`. The commands in the command list can be run in parallel from the package's root dir.

Let's try to run experiments with the toy programs. Run the following command:

```bash
./scripts/experiments.sh
```

The content of `commandqueue.txt` should contain lines that look like the very first command line:

```bash
cd "originalprograms/banker"; java -cp "../../pitest/pitest-command-line/target/pitest-command-line-1.4.12-SNAPSHOT.jar;../../pitest/pitest/target/pitest-1.4.12-SNAPSHOT.jar;../../pitest/pitest-entry/target/pitest-entry-1.4.12-SNAPSHOT.jar;../../junit/junit-4.12.jar;../../junit/hamcrest-core-1.3.jar;" org.pitest.mutationtest.commandline.MutationCoverageReport --reportDir "../../experiments/banker/rs/run-1" --targetClasses "banker.*" --sourceDirs "./src/main/java" --classPath "./target/classes,./target/test-classes" --timestampedReports "false" --outputFormats "CSV,CSVTimings" --exportLineCoverage "false" --fullMutationMatrix "false" --mutators "RS_SELECTIVE"
```

Each of these command lines contains two commands: a `cd` to the program subject directory (banker in the example), and the actual `java` command to execute the experiment.

Since we performed **30 independent runs** for each configuration, the command queue file contains 30 almost identical lines only changing the output directory with the run id. Moreover, we used **5 strategies** in the experiments, thus, for each program, the last argument `--mutators` has 5 different values and the output directory differs according to the strategy. Finally, we used **10 programs**, identifying each output directory with the respective program name. Therefore, the command queue file should contain `30 x 5 x 10 = 1500` command lines, one for each combination of independent run id, strategy, and program.

Let's run the very first command from the command queue. The command should be run from the package's root directory:

```bash
cd "originalprograms/banker"; java -cp "../../pitest/pitest-command-line/target/pitest-command-line-1.4.12-SNAPSHOT.jar;../../pitest/pitest/target/pitest-1.4.12-SNAPSHOT.jar;../../pitest/pitest-entry/target/pitest-entry-1.4.12-SNAPSHOT.jar;../../junit/junit-4.12.jar;../../junit/hamcrest-core-1.3.jar;" org.pitest.mutationtest.commandline.MutationCoverageReport --reportDir "../../experiments/banker/rs/run-1" --targetClasses "banker.*" --sourceDirs "./src/main/java" --classPath "./target/classes,./target/test-classes" --timestampedReports "false" --outputFormats "CSV,CSVTimings" --exportLineCoverage "false" --fullMutationMatrix "false" --mutators "RS_SELECTIVE"
```

This command will first move the working directory to `./originalprograms/banker`, and then perform the mutation testing in the first independent run using the RS Selective strategy. The output is redirected to `../../experiments/banker/rs/run-1`, which is `./experiments/banker/rs/run-1` relative to the package's root dir. The full results of our experiments can be found in the `./experiments` directory. 

The execution of the command shown above will overwrite the content of `./experiments/banker/rs/run-1`. If you want to avoid that, change the argument `--reportDir "../../experiments/banker/rs/run-1"` to whatever you prefer.

The output of such command should be the logging of PIT, showing information about the execution of the mutation testing procedure. It should look something like this:

```log
18:14:00 PIT >> INFO : Verbose logging is disabled. If you encounter a problem, please enable it before reporting an issue.
18:14:01 PIT >> INFO : Sending 2 test classes to minion
18:14:01 PIT >> INFO : Sent tests to minion
18:14:01 PIT >> INFO : MINION : 18:14:01 PIT >> INFO : Checking environment
18:14:01 PIT >> INFO : MINION : 18:14:01 PIT >> INFO : Found  14 tests
18:14:01 PIT >> INFO : MINION : 18:14:01 PIT >> INFO : Dependency analysis reduced number of potential tests by 0
18:14:01 PIT >> INFO : MINION : 18:14:01 PIT >> INFO : 14 tests received
18:14:01 PIT >> INFO : MINION : 18:14:01 PIT >> WARNING : More threads at end of test (6) test02(banker.BankerTest) than start. (5)
18:14:01 PIT >> INFO : MINION : 18:14:01 PIT >> WARNING : More threads at end of test (6) test04(banker.BankerTest) than start. (5)
-18:14:01 PIT >> INFO : Calculated coverage in 0 seconds.
18:14:01 PIT >> INFO : Created  1 mutation test units
```

If the logs show `Found  0 tests` or `0 tests received`, then there is something wrong. Probably it is caused by a wrong classpath. It should not happen, but if it does, [contact me](g.guizzo@ucl.ac.uk) and I can help you debug it.

Since mutation testing is expensive, this might take a while. Once it is finished, run the following command to go to the results directory:

```bash
cd ../../experiments/banker/rs/run-1
```

The directory must contain two files: `mutations.csv` and `mutation-timings.csv`. The former contains detailed description about each mutant. Its content should look something like this:

```csv
Banker.java,banker.Banker,org.pitest.mutationtest.engine.gregor.mutators.ConstructorCallMutator,<init>,21,KILLED,1,banker.BankerTest.test10(banker.BankerTest)
Banker.java,banker.Banker,org.pitest.mutationtest.engine.gregor.mutators.InlineConstantMutator,<init>,19,KILLED,1,banker.BankerTest.test04(banker.BankerTest)
Banker.java,banker.Banker,org.pitest.mutationtest.engine.gregor.mutators.InlineConstantMutator,<init>,19,KILLED,2,banker.BankerTest.test06(banker.BankerTest)
Banker.java,banker.Banker,org.pitest.mutationtest.engine.gregor.mutators.InlineConstantMutator,<init>,19,KILLED,1,banker.BankerTest.test06(banker.BankerTest)
Banker.java,banker.Banker,org.pitest.mutationtest.engine.gregor.mutators.InlineConstantMutator,<init>,19,KILLED,1,banker.BankerTest.test06(banker.BankerTest)
Banker.java,banker.Banker,org.pitest.mutationtest.engine.gregor.mutators.InlineConstantMutator,<init>,19,KILLED,1,banker.BankerTest.test06(banker.BankerTest)
```

The second file's content, `mutation-timings.csv`, should look like this:

```csv
stage,timing
buildmutationtests,406
runmutationanalysis,39612
scanclasspath,15
coverageanddependencyanalysis,704
```

More information on how to interpret these results can be found in the `README.md` file.

That is all. If you would like to replicate the results of our experiments exactly as we executed them, run the commands generated by `./scripts/experiments-large.sh`.

### Analysing the Results

After running the experiments, you can find the results in the `./experiments` directory. You can find the full results of our experiments in this directory. Each subdirectory has the following pattern: `./experiments/<program>/<strategy>/<run>`. Let's analyse some results and generate the slopegraph of our paper.

The first step is to treat the raw data with `./scripts/treatment.R`. To do that, run the following command:

```bash
R -f ./scripts/treatment.R
```

This script will take a while to finish, because it is collecting data about all mutants for 30 runs, 5 strategies, and 20 programs (10 toy and 10 larger programs). There are millions of data points to treat. The treated data will be written to `./experiments/treateddata.csv`. It should look something like this:

```csv
program,strategy,run,metric,value
banker,all,1,buildmutationtests,373
banker,all,1,runmutationanalysis,88135
banker,all,1,totaltime,88508
banker,all,1,testruns,1299
banker,all,1,numbermutants,563
banker,all,2,buildmutationtests,363
banker,all,2,runmutationanalysis,95944
banker,all,2,totaltime,96307
banker,all,2,testruns,1382
banker,all,2,numbermutants,563
```

Basically, this file contains the metrics needed to evaluate the execution time and the number of mutants of each strategy. The metrics `buildmutationtests` and `runmutationanalysis` represent the time in milliseconds taken to generate and then run the mutants respectively. `totaltime` is the sum of both. `numbermutants` represents the number of mutants the strategy generated. Finally, `testruns` shows the number of test case that were executed in that specific run to kill the mutants. Depending on the prioritisation of test cases done by PIT, different test subsets might be executed until Partial Mutation is done, thus this number can vary from one run to another.

We can also compute the mutation score of each strategy in each run. To do that, run the following command:

```bash
R -f ./scripts/mutationscore.R
```

This script will iterate over all mutants in all runs to identify the ones that died and the ones that didn't. Then it will compute the ratio between the number of dead mutants to the total number of mutants for that program. This is the expected output:

```R
# A tibble: 20 x 2
   program                 mutationscore
   <chr>                   <chr>
 1 banker                  73%
 2 bub                     52%
 3 cal                     31%
 4 commons-beanutils-1.9.4 85%
 5 commons-codec-1.14      87%
 6 commons-collections-4.4 88%
 7 commons-lang-3.8.1      82%
 8 commons-validator-1.6   83%
 9 euclid                  80%
10 find                    68%
11 insert                  85%
12 jfreechart-1.5.0        75%
13 jgrapht-1.3.1           79%
14 joda-time-2.10.5        80%
15 mid                     73%
16 ognl-3.2.13             90%
17 quad                    92%
18 trityp                  81%
19 warshall                53%
20 wire-2.3.0              88%
```

This information is presented in our Experimental Subject table in the paper.

Now that we have treated the data, we can generate the slopegraph presented in the paper. To do that, run the following command:

```bash
R -f ./scripts/graph.R
```

The graph will be outputted to `./experiments/slopegraph.png`. We have already included the slopegraph we used in our paper. The only difference between the provided graph and the one generated by this script are the red rectangles that we added manually to the figure.

That is all, folks.