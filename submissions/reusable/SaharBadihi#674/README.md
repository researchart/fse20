This repository contains the implementation of ARDiff: an equivalence checking framework that allows scaling symbolic-execution-based equivalence checking for cases that consider two subsequent versions of a java method. 

It includes:
* The implementation of ARDiff abstraction-refinement approach ("ARDiff: Scaling Program Equivalence Checking via Iterative Abstraction and Refinement of Common Code", ESEC/FSE, 2020)
* An implementation of DSE -- a baseline equivalence checking technique ("Differential Symbolic Execution", FSE, 2008)
* An implementation of IMP-S -- a baseline equivalence checking technique ("Regression Verification using Impact Summaries", SPIN, 2013)

The framework and the benchmark are provided [online](https://github.com/shrBadihi/ARDiff_Equiv_Checking).

## Framework 
You can find our framework here:
```yaml
/.../path-to-ARDiff_Equiv_Checking-folder/Implementation/
```

## Benchmark 
You can find our dataset here:
```yaml
/.../path-to-ARDiff_Equiv_Checking-folder/benchmarks/
```
## Running ARDiff, DSE, and IMP-S on Our Benchmark
You can run each pair of methods in the benchmark individually (as described above) or run all of them in sequence by running the script we provided.

There are three scripts for running the tool on the benchmark, one for each operating system.

Note, in terms of system requirements, running benchmarks need at least 16 GB memory and the expected runtime is 10-14 hrs. 

- 16GB is a safe bound to ensure symbolic execution and the SMT solver can handle complex examples. This requirement can be easily modified by changing the -Xms parameter in the scripts, however we can not guarantee that you will obtain the same results (as some cases might become UNKNOWN)

For example, the following script is for Linux users:
```yaml
cd /.../path-to-ARDiff_Equiv_Checking-folder/Implementation/
sh RunningBenchmarksOnLinux.sh
```
OSX and Windows users should use RunningBenchmarksOnMac.sh and RunningBenchmarksOnWindows.bat, respectively.

The script runs DSE, IMP-S, and ARDiff on each Equivalent and Non-Equivalent pairs of methods for each benchmark. 


