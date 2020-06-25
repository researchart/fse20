# Installation and Usage Instructions

This document contains information on how to install the dependencies and how to use the scripts contained in the replication package.

---

## Installation

### Docker Image Setup

If you wish to skip the dependency installation, we highly recommend you to use the Docker image with Ubuntu 20 we provide. This image is already configured with all dependencies and is ready-to-use for this package. The Docker image is hosted at [Docker Hub](https://hub.docker.com/repository/docker/giovaniguizzo/fse20-p533-mutants). If you prefer to use this package outside a container, then you can skip this subsection and start directly from "Java".

In order to use the provided Docker image, first [install Docker](https://www.docker.com/get-started) on your machine. The run the following command to download the image locally:

```bash
docker pull giovaniguizzo/fse20-p533-mutants:latest
```

After the download is done, you can then create a container with the downloaded image with the following command:

```bash
docker create --name MyContainerName -it giovaniguizzo/fse20-p533-mutants:latest
```

Once created, you can start the container with:

```bash
docker start MyContainerName
```

If you use the `-ai` argument for the command above, your system's input and output will be attached automatically to the container. If you don't, then you have to do it manually with the following command:

```bash
docker attach MyContainerName
```

Once your I/O is attached, you will see the Linux bash terminal for your container. You can check the java and R installations (`java -version` and `R --version`) just to be sure.

If you successfully configured the Docker image, then you neither have to install/update Java or R, nor any of their dependencies. Therefore, you can skip the next subsections and go directly to "Preparing the Replication Package".

### Java

#### Download and Install Java

The experiments in this work were executed using `Java JDK v1.8.0_231`. To check your Java version, run the following command:

```bash
java -version
```

If you do not have `Java JDK v1.8.0_231` or a newer version installed, please download the latest version of `Java JDK 8` here [Java SE Development Kit 8 Downloads](https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html), and then install it following the instructions provided by Oracle.

If you have it already installed but the command is not working, then make sure the java executable directory is available in your `PATH` environment variable.

### R

#### Download and Install R

The data analysis done in this work was performed using `R v3.5.1`. To check your R version, run the following command:

```bash
R --version
```

or if you are on Windows:

```powershell
R.exe --version
```

If you do not have `R v3.5.1` or a newer version installed, please download the latest version of `R v3` here [The R Project for Statistical Computing](https://www.r-project.org/), and then install it following the instructions provided by The R Foundation.

If you have it already installed but the command is not working, then make sure the R executable directory is available in your `PATH` environment variable.

#### Install R dependencies

The installation of R packages may fail if you don't have a few required external dependencies installed in your Linux system. In order to avoid the failure and properly install the packages, you must first install the following library programs before installing dependencies using R: `libudunits2-0`, `libudunits2-dev`, `libproj-dev`, and `libgdal-dev`. If you are using Ubuntu, use the following command:

```bash
sudo apt-get install -y libudunits2-0 libudunits2-dev libproj-dev libgdal-dev
```

If you use Windows, these external libraries are not needed.

Once R and the external dependencies are installed, start it using the command line `R`, or using your preferred method. Then run the following R command to install the needed R packages:

```R
install.packages(c("tidyverse","GGally","MLmetrics","data.table","effsize","pgirmess","hms","lubridate","ggrepel"))
```

Follow the installation instructions. Once the installation is done, close the R session using `q()` and then you are ready to use the R scripts provided in this package.

### bash

The bash scripts contained in the package use the command `declare -A` (upper case `A`).
This command is only available on `bash v4.x` or newer.
If you use `macOS`, you bash version is probably outdated.
Please, update your bash terminal and make sure the command `declare -A` works in your environment.

---

## Preparing the Replication Package

The full compressed package can be found and downloaded [here](https://doi.org/10.5522/04/11927208). When the download is complete, unpack it to a directory of your liking.

As mentioned in the `README.md` file, the machine used in our experiments has an `AMD Threadripper 2950X, 16/32 cores, 3.5GHz` CPU and 32GB of `3200MHz` RAM. The expected execution times given in this document are based on that specific machine configuration. Moreover, we recommend at least 4GB of free memory to perform the whole data analysis, at least 1GB of RAM to run each experimental job using the toy programs, an at least 4GB of RAM for each experimental job using the larger programs.

If Java and R are installed as previously instructed, then you are ready to use the package. There is no additional installation.

---

## Running the Experiments

For a full detailed description of each directory included in the package, please refer to `README.md`.

First of all, the mutation testing experiments we performed are computationally expensive. For the 3000 command lines that we executed, it took from 3 to 4 weeks of nonstop execution using 15 cores. Therefore, before proceeding, bear in mind that it will take a lot of computational resources to rerun everything as we did. For this reason, we will provide guidelines on how to run everything, but we will focus on one command at a time.

If you don't want to run the experiments again, we have provided the results of our own experiment in the directory `./experiments`. You can jump to the next section in order to learn how to evaluate the results directly.

To simplify the examples, we will present them in the form of Linux commands (e.g., using `R /path/to/script.sh` instead of `R.exe C:\path\to\script.cmd`). As mentioned earlier, the bash version should be not older than `v4.x`, otherwise some of the commands might not work. Moreover, if you are using Windows, then the classpath's item delimiter changes from `:` to `;`.

To run the experiments, the first step is to go to the unpacked package directory.

```bash
cd Replication-Package
```

We provide two experiment scripts: `./scripts/experiments-original.sh` and `./scripts/experiments-large.sh`. Both scripts create a file named `commandqueue.txt` containing a list of commands that must be executed in order to reproduce the experiments. The first script generates commands using the toy programs provided in `./originalprograms`, whereas the second script generates commands using the larger Java programs provided in `./largerprograms`. The commands in the command list can be run in parallel from the package's root dir.

Let's try to run experiments with the toy programs. Run the following command:

```bash
./scripts/experiments-original.sh
```

The content of `commandqueue.txt` should contain lines that look like the very first command line:

```bash
cd "originalprograms/banker"; java -cp "../../pitest/pitest-command-line/target/pitest-command-line-1.4.12-SNAPSHOT.jar:../../pitest/pitest/target/pitest-1.4.12-SNAPSHOT.jar:../../pitest/pitest-entry/target/pitest-entry-1.4.12-SNAPSHOT.jar:../../junit/junit-4.12.jar:../../junit/hamcrest-core-1.3.jar" org.pitest.mutationtest.commandline.MutationCoverageReport --reportDir "../../experiments/banker/rs/run-1" --targetClasses "banker.*" --sourceDirs "./src/main/java" --classPath "./target/classes,./target/test-classes" --timestampedReports "false" --outputFormats "CSV,CSVTimings" --exportLineCoverage "false" --fullMutationMatrix "false" --mutators "RS_SELECTIVE"
```

Each of these command lines contains two commands: a `cd` to the program subject directory (banker in the example), and the actual `java` command to execute the experiment.

Since we performed **30 independent runs** for each configuration, the command queue file contains 30 almost identical lines only changing the output directory with the run id. Moreover, we used **5 strategies** in the experiments, thus, for each program, the last argument `--mutators` has 5 different values and the output directory differs according to the strategy. Finally, we used **10 programs**, identifying each output directory with the respective program name. Therefore, the command queue file should contain `30 x 5 x 10 = 1500` command lines, one for each combination of independent run id, strategy, and program.

Let's run the very first command from the command queue. The command should be run from the package's root directory:

```bash
cd "originalprograms/banker"; java -cp "../../pitest/pitest-command-line/target/pitest-command-line-1.4.12-SNAPSHOT.jar:../../pitest/pitest/target/pitest-1.4.12-SNAPSHOT.jar:../../pitest/pitest-entry/target/pitest-entry-1.4.12-SNAPSHOT.jar:../../junit/junit-4.12.jar:../../junit/hamcrest-core-1.3.jar" org.pitest.mutationtest.commandline.MutationCoverageReport --reportDir "../../experiments/banker/rs/run-1" --targetClasses "banker.*" --sourceDirs "./src/main/java" --classPath "./target/classes,./target/test-classes" --timestampedReports "false" --outputFormats "CSV,CSVTimings" --exportLineCoverage "false" --fullMutationMatrix "false" --mutators "RS_SELECTIVE"
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

There is a special log generated by PIT that, although looks like an error, it is just an indication that the mutant has died due to timeout:

```log
18:14:02 PM PIT >> WARNING : Minion exited abnormally due to TIMED_OUT
```

If you see this warning, it means that PIT is working as intended by not allowing mutants to run forever. Another similar log will warn about a mutant spawning multiple threads. Again, this warning is normal for test cases or mutants that use multi-threading.

Since mutation testing is expensive, this might take a few minutes (5-10 minutes). For the larger programs however, each command can take up to 18 hours to execute. Once it is finished, run the following command to go to the results directory:

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

### Including new Programs

In order to run the experiments using your own program, you need to follow the steps described in this section.

Firstly, copy the project's directory to the `largerprograms` directory.

Secondly, append the following command line to the end of `experiments-large.sh`:

```bash
for j in "${!strategies[@]}"; do
    for k in $runs; do 
        echo 'cd "largerprograms/<program>"; java -cp "../../pitest/pitest-command-line/target/pitest-command-line-1.4.12-SNAPSHOT.jar:../../pitest/pitest/target/pitest-1.4.12-SNAPSHOT.jar:../../pitest/pitest-entry/target/pitest-entry-1.4.12-SNAPSHOT.jar:../../junit/junit-4.12.jar:../../junit/hamcrest-core-1.3.jar" org.pitest.mutationtest.commandline.MutationCoverageReport --reportDir "../../experiments/<program>/'$j'/run-'$k'" --sourceDirs "<srcDir>" --classPath "<cpItems>" --timestampedReports "false" --outputFormats "CSV,CSVTimings" --exportLineCoverage "false" --targetClasses "<targetClasses>" --targetTests "<targetTests>" --excludedClasses "<excludedClasses>" --excludedTestClasses "<excludedTests>" --mutators "'${strategies[$j]}'"' >> commandqueue.txt
    done
done
```

The command above will make `experiments-large.sh` to append the commands needed to run the experiments to `commandqueue.txt`, which in turn can be used to run the experiments as presented in the previous section. The command above has a few placeholders that must be replaced by the relevant information about the program. Namely:

1. `<program>` - The directory of the program relative to the `largerprograms` directory. For example: `jgrapht-1.3.1` instead of `largerprograms/jgrapht-1.3.1`.
2. `<srcDir>` - The directory with the program's source code relative to `<program>`. For example: `./src/main/java` instead of `largerprograms/jgrapht-1.3.1/src/main/java`.
3. `<cpItems>` - The comma separated list of classpath items needed to run the program. Paths should be relative to `<program>`. For example: `./target/classes,./target/test-classes,./target/lib/commons-io-2.4.jar` instead of `largerprograms/jgrapht-1.3.1/<item>`.
4. `<targetClasses>` - A glob with the classes to be mutated. For example: `org.jgrapht.*` will match all classes in the `org.jgrapht` package and its sub-packages.
5. `<targetTests>` - A glob with the test classes to test the mutants. For example: `org.jgrapht.*Test` will match all classes ending with `Test` in the `org.jgrapht` package and its sub-packages.
6. `<excludedClasses>` - A glob with the classes to exclude from mutation. For example: `*NamedGraphGenerator*` will match all classes with `NamedGraphGenerator` in its fully qualified name (`package.of.my.Class`).
7. `<excludedTests>` - A glob with the test classes to exclude from mutation. For example: `*perf*,*BrownBacktrackColoringTest,*Benchmark*,*Performance*` will match all test classes with `perf`, `Benchmark`, or `Performance` anywhere in its fully qualified name, or ending with `BrownBacktrackColoringTest`.

If any of these do not apply to your program, you can remove the respective argument too. For example, if your program does not have any test exclusion, then you can remove the argument `--excludedTestClasses` and its respective value from the command line.

In fact, these are all arguments used by [PIT](http://pitest.org/) during mutation. If you want to know more about the available arguments in PIT, you can follow [this link](http://pitest.org/quickstart/commandline/). The only arguments that change from the default implementation of PIT are `--outputFormats` and `--mutators`. The former contains `CSVTimings` which outputs running time, and the latter was modified to accept the strategies in the format of mutation operators combinations.

Your bash command should look something similar to this (example for `jgrapht-1.3.1`):

```bash
for j in "${!strategies[@]}"; do
    for k in $runs; do 
        echo 'cd "largerprograms/jgrapht-1.3.1"; java -cp "../../pitest/pitest-command-line/target/pitest-command-line-1.4.12-SNAPSHOT.jar:../../pitest/pitest/target/pitest-1.4.12-SNAPSHOT.jar:../../pitest/pitest-entry/target/pitest-entry-1.4.12-SNAPSHOT.jar:../../junit/junit-4.12.jar:../../junit/hamcrest-core-1.3.jar" org.pitest.mutationtest.commandline.MutationCoverageReport --reportDir "../../experiments/jgrapht-1.3.1/'$j'/run-'$k'" --timestampedReports "false" --outputFormats "CSV,CSVTimings" --exportLineCoverage "false" --sourceDirs "./src/main/java" --classPath "./target/classes,./target/test-classes,./target/lib/commons-io-2.4.jar,./target/lib/commons-math3-3.2.jar,./target/lib/hamcrest-core-1.3.jar,./target/lib/hamcrest-library-1.3.jar,./target/lib/jheaps-0.10.jar,./target/lib/jmh-core-1.21.jar,./target/lib/jmh-generator-annprocess-1.21.jar,./target/lib/jopt-simple-4.6.jar,./target/lib/junit-4.12.jar,./target/lib/junit-toolbox-2.4.jar,./target/lib/mockito-core-1.9.5.jar,./target/lib/objenesis-1.0.jar" --targetClasses "org.jgrapht.*" --targetTests "org.jgrapht.*Test" --excludedClasses "*NamedGraphGenerator*" --excludedTestClasses "*perf*,*BrownBacktrackColoringTest,*Benchmark*,*Performance*" --mutators "'${strategies[$j]}'"' >> commandqueue.txt
    done
done
```

If you wish to change the number of runs or the set of strategies, you can also change the beginning of `experiments-large.sh`:

```bash
declare -A strategies
strategies=(["all"]="ES_SELECTIVE,RS_SELECTIVE,RE_SELECTIVE" ["es"]="ES_SELECTIVE" ["rs"]="RS_SELECTIVE" ["re"]="RE_SELECTIVE" ["e"]="E_SELECTIVE")
runs=$(seq 1 10)
```

Where `strategies` is the set of strategies used in the experiments, and `runs` is a vector of independent run numbers to run. Let us say you want to run only the ES strategy for 40 independent runs, then the beginning of `experiments-large.sh` should look something like this:

```bash
declare -A strategies
strategies=(["es"]="ES_SELECTIVE")
runs=$(seq 1 40)
```

That is all. After running `experiments-large.sh`, the commands to run your experiments should be at the bottom of `commandqueue.txt`.

---

## Analysing the Results

After running the experiments, you can find the results in the `./experiments` directory. If you haven't run the experiments, don't worry, we have provided the full results of our own experiments (as reported in the paper) in this directory. Each subdirectory has the following pattern: `./experiments/<program>/<strategy>/<run>`. Let's analyse some results and generate the slopegraph of our paper.

The first step is to treat the raw data with `./scripts/treatment.R`. To do that, run the following command:

```bash
R -f ./scripts/treatment.R
```

This script will take a few minutes to finish (between 1-3 minutes), because it is collecting data about all mutants for 30 runs, 5 strategies, and 20 programs (10 toy and 10 larger programs). There are millions of data points to treat, thus it is recommended at least 4GB of free memory. The treated data will be written to `./experiments/treateddata.csv`. It should look something like this:

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

This script will iterate over all mutants in all runs to identify the ones that died and the ones that didn't. This script will compute the ratio between the number of dead mutants to the total number of mutants for that program. This is the expected output:

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

It shall also take a bit longer than the previous script to execute (between 3-5 minutes) and might end up using a considerable amount of memory (~4GB). If you don't want to wait or do not have the memory for it, I advise skipping this script, since it is only used to compute the original mutation scores presented in our Experimental Subject table in the paper.

Now that we have treated the data, we can generate the slopegraph presented in the paper. To do that, run the following command:

```bash
R -f ./scripts/graph.R
```

The graph will be outputted to `./experiments/slopegraph.png`. We have already included the slopegraph we used in our paper. The only difference between the provided graph and the one generated by this script are the red rectangles that we added manually to the figure.

### Analysing Results of new Programs

If you have followed the instructions of the `Including new Programs` section and executed experiments with your own programs, there is a few steps you must take to include them in the result analysis scripts.

The first step is to update the treatment script `treatment.R` at `line 76`. You have to include your program's directory in the list of programs. For example, if you ran experiments using `google-guava-29.0`, then your array of programs should look like this:

```R
programs <- c("commons-beanutils-1.9.4",
              "commons-codec-1.14",
              "commons-collections-4.4",
              "commons-lang-3.8.1",
              "commons-validator-1.6",
              "jfreechart-1.5.0",
              "jgrapht-1.3.1",
              "joda-time-2.10.5",
              "ognl-3.2.13",
              "wire-2.3.0",
              "google-guava-29.0")
```

The same should be done at `line 56` of `mutationscore.R`, and `line 28` in `graph.R`.

In `graph.R`, the program directory must be included without the versioning, such as `google-guava`. This was done for better displaying the programs in the graph. 

If you must generate graphs with versions, comment `lines 39, 40, 42` and put the versions in the list of programs at `line 28`. The script should look like this:

```R
programs <- c("commons-beanutils-1.9.4",
              "commons-codec-1.14",
              "commons-collections-4.4",
              "commons-lang-3.8.1",
              "commons-validator-1.6",
              "jfreechart-1.5.0",
              "jgrapht-1.3.1",
              "joda-time-2.10.5",
              "ognl-3.2.13",
              "wire-2.3.0",
              "google-guava-29.0")

# metrics <- metrics %>%
#   mutate(program = str_replace_all(metrics$program, "commons-", ""))
 metrics <- metrics %>%
#   mutate(program = str_replace_all(metrics$program, "-[\\d\\.]+", "")) %>%
  filter(program %in% programs)
```

Feel free to remove from the list of programs any unwanted program in the graph.

Finally, if you ran your experiments with a different set of strategies, you have to update the lists of strategies at `line 7` of `treatment.R`, `line 7` of `mutationscore.R`, and `line 26` of `graph.R`.

That is all, folks.
