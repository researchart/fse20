# Installation

To replicate our study's results, one needs to install the following software:

## Java

We require Java for the Kotlin-based analysis scripts, the JMH fork, and the execution of JMH benchmarks.

* JDK 1.8.0_222-b10 for analysis scripts, JMH fork, and 9/10 study subjects (check the paper).
Using JDK + HotSpot VM from [AdoptOpenJDK](https://adoptopenjdk.net/)).
Set JAVA_HOME environment variable correctly.
* JDK 13+33 for log4j2 benchmark executions only with HotSpot VM from [AdoptOpenJDK](https://adoptopenjdk.net/)).

## Python
Our pre-study data anlyses use Python:
* [Python](https://www.python.org/) 3.7.7
* pip 20.0.2
* pipenv 2020.5.28

## R
The remaining data analysis scripts use R

* [R](https://www.r-project.org/) 3.6.1.
* The R scripts only depend on `base` R and `tidyverse` (1.3.0).
* We used [RStudio](https://rstudio.com/) 1.2.5042.

## git

Our pre-study tooling uses [git](https://git-scm.com/).
We used version 2.27.0.

## bencher tool

Our source code parser relies on the open-source library [*bencher*](https://github.com/chrstphlbr/bencher).
As this library is not available on maven central, we need to clone it, perform minor modifications, and publish it to the local maven repository.
For this we need to follow the subsequent steps:

1. Use version with git commit hash `97f859264dcd2005c27c75e0b67fa424defa7b01`

2. Replace the following code in the method `config(bench: Benchmark)` of the class `ch.uzh.ifi.seal.bencher.execution.ConfigBasedConfigurator`

```kotlin
return if (valid(c)) {
    Either.right(c)
} else {
    Either.left("Invalid configuration for benchmark ($bench) and provided default/class/benchmark configurations")
}
```

with

```kotlin
return Either.right(c)
```

3. Run 

```bash
./gradlew publishToMavenLocal
``` 

## Go and *pa*

If you are not using macOS, Linux, or Windows with an amd64 processor architecture, you need to manually compile the *pa* tool and adapt the scripts.
* [Go](https://golang.org/) for compiling the *pa* tool.
We used Go 1.14.3.
* The [*pa*](https://github.com/chrstphlbr/pa) tool for efficient bootstrap confidence interval computations.
*pa* must be installed from source by executing `go build` from the root directed at commit hash `5ae801b4844dc2343325e121b3cbdf524a56ce63`.
* Copy *pa* binary to `jmh-dynamic-reconfiguration/jmh-core/src/main/resources/` and `evaluation/study_kotlin/src/main/resources/`.
* Change method `executableName` in `org.openjdk.jmh.reconfigure.statistics.ci.CIHelper` in both places `jmh-dynamic-reconfiguration/jmh-core/src/main/java/org/openjdk/jmh/reconfigure/statistics/ci/CIHelper.java` and `evaluation/study_kotlin/src/main/java/org/openjdk/jmh/reconfigure/statistics/ci/CIHelper.java`

## JMH Reconfiguration Fork

JMH with dynamic reconfiguration must be installed from source.
To do so, run the following command from your command line (from within `jmh-dynamic-reconfiguration`):

```bash
mvn clean install -DskipTests
```
