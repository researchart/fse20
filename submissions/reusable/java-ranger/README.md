# Overview
This artifact accompanies the submission to FSE 2020 titled "". This artifact presents steps to reproduce the results in the FSE 2020 submission. The tool named XYZ is de-anonymized in this submission to a tool named "Java Ranger". 

# Documentation
Documentation for Java Ranger as well as high-level overview for it can be found [here](https://vaibhavbsharma.github.io/java-ranger). 

# Compute Time estimate
This artifact reproduces results shown in Tables 2 and 4 in our FSE 2020 submission. The reproduction of our results involves running 16 different scripts. Running these scripts serially takes us a total compute time of about 54 hours on a machine running Ubuntu 16.04 with a Intel(R) Xeon(R) CPU E5-2623 v3 @ 3.00GHz processor and 192 GB of memory. This compute time estimate does not take into account the reproduction of the results from the Java track of SV-COMP 2020 which is presented in Table 5 of the submission. Since this is a long-running artifact, we urge the artifact reviewers to allow about 54 hours of compute time before they collect results to review the artifact. However, we provide a script that allows any-time collections of the current set of generated results.

## Checking that everything is working
Among all the benchmarks that can be run from instructions below, the ones for the Schedule benchmark will finish the soonest. If you'd like to make sure everything is set up correctly, we recommend first running the Schedule benchmark's instructions and checking results from its run with Java Ranger.

# Reproducing data for Tables 2 and 4

## Run individual benchmarks
1. Build jpf-core and java-ranger using the instructions found in [INSTALL.md](https://github.com/vaibhavbsharma/fse20/blob/master/submissions/reusable/INSTALL.md).
2. Navigate to fse20/submissions/reusable/java-ranger, if not already there.
2. mkdir logs

Next, we run Java Ranger on a benchmark in five different modes. 
- Mode 1 corresponds to turning off path-merging. This mode causes Java Ranger to only run SPF and is used to collect baseline performance of the symbolic executor on the benchmark.
- Mode 2 corresponds to basic path-merging abbreviated as "basic p.m." in Tables 4a and 4b. 
- Mode 3 corresponds to the addition of method inlining to Mode 2. Results of running Java Ranger in this mode are shown in the "+method inlining" column in Tables 4a and 4b.
- Mode 4 corresponds to the addition of single-path cases to Mode 3. Results of running Java Ranger in this mode are shown in the "+single path cases" column in Tables 4a and 4b.
- Mode 5 corresponds to the addition of early-returns summarization to Mode 4. Results of running Java Ranger in this mode are shown in the "+early return summ." column in Tables 4a and 4b.
 
All steps below can be run in parallel to save compute time. The runs of Java Ranger (not SPF) for the WBS, TCAS benchmarks should finish within five minutes at most. Also, the runs of the Schedule benchmark for both SPF and Java Ranger should finish within a minute. All the runs for SPF will take much longer than Java Ranger to complete. Each command below will generate a log file in the fse20/submissions/reusable/java-ranger/logs directory. A run is complete when Java Ranger has completed writing to the log file. 

None of the commands will print anything to stdout/stderr while the command is running. To ensure that each command is doing something productive, run `cd <directory-containing-this-README>/logs; tail -f <LOG FILE NAME>` to check the contents of the log file of each process as they are being updated. We mention the `LOG FILE NAME` for each benchmark below. Please note that many of the below command will produce multiple log files in which case we've provided a comma-separated list of expected log file names. 

1. cd src/examples/veritesting/wbs/ && ./runWBS-SPF.sh && cd ../../../..
  - runs Java Ranger in mode 1 (same as running SPF) on the WBS benchmark with the step function run for five steps with each step taking 3 new symbolic inputs.
  - LOG FILE NAME = wbs.5step.mode1.log
2. cd src/examples/veritesting/wbs/ && ./runWBS-JR.sh && cd ../../../..
  - runs Java Ranger on the WBS benchmark for 10 steps under modes 2, 3, 4, 5. This run should finish within a couple of minutes.
  - LOG FILE NAME = wbs.10step.mode2.log, wbs.10step.mode3.log, wbs.10step.mode4.log, wbs.10step.mode5.log, 
3. cd src/examples/veritesting/tcas/ && ./runTCAS-SPF.sh && cd ../../../..
  - runs Java Ranger in mode 1 on the TCAS benchmark with the step function run for two steps with each step taking 12 new symbolic inputs.
  - LOG FILE NAME = tcas.2step.mode1.log
4. cd src/examples/veritesting/tcas/ && ./runTCAS-JR.sh && cd ../../../..
 - runs Java Ranger in modes 2, 3, 4, 5 on the TCAS benchmark for 10 steps. This run should finish within a couple of minutes.
 - LOG FILE NAME = tcas.10step.mode2.log, tcas.10step.mode3.log, tcas.10step.mode4.log, tcas.10step.mode5.log
5. cd src/examples/veritesting/replace/ && ./runReplace.sh && cd ../../../..
 - runs Java Ranger in modes 1, 2, 3, 4, 5 on the replace benchmark. 
 - LOG FILE NAME = replace.mode1.log, replace.mode2.log, replace.mode3.log, replace.mode4.log, replace.mode5.log, replace11.mode1.log, replace11.mode2.log, replace11.mode3.log, replace11.mode4.log, replace11.mode5.log
6. cd src/examples/veritesting/nanoxml/ && ./runNanoXML-SPF.sh && cd ../../../..
 - runs Java Ranger in mode 1 on the NanoXML benchmark
 - LOG FILE NAME = DumpXML.7sym.mode1.log
7. cd src/examples/veritesting/nanoxml/ && ./runNanoXML-JR.sh && cd ../../../..
 - runs Java Ranger in modes 2, 3, 4, 5 on the NanoXML benchmark
  - LOG FILE NAME = DumpXML.7sym.mode2.log, DumpXML.7sym.mode3.log, DumpXML.7sym.mode4.log, DumpXML.7sym.mode5.log
8. cd src/examples/veritesting/siena/ && ./runSiena-SPF.sh && cd ../../../..
 - runs Java Ranger in mode 1 on the Siena benchmark 
  - LOG FILE NAME = siena.6.mode1.log
9. cd src/examples/veritesting/siena/ && ./runSiena-JR.sh && cd ../../../..
 - runs Java Ranger in modes 2, 3, 4, 5 on the Siena benchmark 
 - LOG FILE NAME = siena.6.mode5.log
10. cd src/examples/veritesting/schedule2_3/ && ./runSchedule.sh && cd ../../../..
 - runs Java Ranger in modes 1, 2, 3, 4, 5 on the Schedule benchmark 
 - LOG FILE NAME = schedule.mode1.log, schedule.mode2.log, schedule.mode3.log, schedule.mode4.log, schedule.mode5.log
11. cd src/examples/veritesting/printtokens2_3/ && ./runPrintTokens-SPF.sh && cd ../../../..
 - runs Java Ranger in mode 1 on the PrintTokens2 benchmark 
 - LOG FILE NAME = printtokens.5sym.mode1.log
12. cd src/examples/veritesting/printtokens2_3/ && ./runPrintTokens-JR.sh && cd ../../../..
 - runs Java Ranger in modes 2, 3, 4, 5 on the PrintTokens2 benchmark 
  - LOG FILE NAME = printtokens.5sym.mode2.log, printtokens.5sym.mode3.log, printtokens.5sym.mode4.log, printtokens.5sym.mode5.log
13. cd src/examples/veritesting/apachecli/ && ./runApacheCLI-SPF.sh && cd ../../../..
 - runs Java Ranger in mode 1 on the ApacheCLI benchmark. This run consumes "5+1" symbolic inputs. This number of symbolic inputs can be found in the "#sym input" column of Table 2. This run makes the first 5 and last input of ApacheCLI to be symbolic.
 - LOG FILE NAME = ApacheCLI.5_1sym.mode1.log
 14. cd src/examples/veritesting/apachecli/ && ./runApacheCLI-JR_1.sh && cd ../../../..
  - runs Java Ranger in mode 2, 3, 4, 5, on the ApacheCLI benchmark with the same number of symbolic inputs as mode 1.
  - LOG FILE NAME = ApacheCLI.5_1sym.mode2.log, ApacheCLI.5_1sym.mode3.log, ApacheCLI.5_1sym.mode4.log, ApacheCLI.5_1sym.mode5.log
15. cd src/MerArbiter-v2/ && ./runMerarbiter-SPF.sh && cd ../../../..
  - runs Java Ranger in mode 1 on the MerArbiter benchmark.
  - LOG FILE NAME = merarbiter.6step.mode1.log
16. cd src/MerArbiter-v2/ && ./runMerarbiter-JR.sh && cd ../../../..
  - runs Java Ranger in modes 2, 3, 4, 5 on the MerArbiter benchmark.
  - LOG FILE NAME = merarbiter.6step.mode2.log, merarbiter.6step.mode3.log, merarbiter.6step.mode4.log, merarbiter.6step.mode5.log

## Collect results
We urge the artifact reviewers to allocate 54 hours of compute time to reproduce results from Tables 2, 4. The below script can be used to collect the current set of results into a CSV format.
1. cd fse20/submissions/reusable/java-ranger
2. perl extract-detailed-results.pl logs/ output.csv
 - this command scans the generated logs and captures data from the log files into the output.csv file. This csv file can be imported into a spreadsheet software like Google Sheets or Microsoft Excel for further examination. 
 
 ## Understanding the results generated for Tables 2, 4
The columns in the generated output.csv can be understood as follows. We do not explain every column, but just the ones needed to understand Tables 2, 4.
-  The first three columns of the results describe the name of the benchmark, its total number of symbolic inputs, and the Java Ranger mode for the results. A mode of 1 means that only the baseline symbolic executor - SPF - was run. 
- The "Total runtime (msec)" column shows the total running time in milliseconds of Java Ranger for the benchmark, given a specific mode. 
  - The numbers in this column for modes 1 and 5 for a given benchmark can be compared with the "total time (msec)" column 
  in Table 2. A similar percentage reduction can be computed to match the reduction seen in the "% red. in time" column in Table 2.
  - Comparing the total running time for modes 2, 3, 4, 5 can derive the data for all benchmarks shown in Table 4a.
- The "static analysis time (msec)" shows the time in milliseconds spent during static analysis by Java Ranger on this run. This time captures how long it took for Java Ranger to construct static summaries for the benchmark. This column is also shown in Table 2.
- The "dynamic symbolic execution runtime (msec)" shows the time spent on the non-static analysis parts. 
  - This time is how long it took Java Ranger to do the symbolic execution with path-merging.
- The "# execution paths" column shows the total number of execution paths explored by Java Ranger on that benchmark in a given mode. 
    - This data is also presented in Table 2 under the "# exec. paths" column. This data can also be used to compute the "%red. in # exec. paths" column in Table 2.
    - Comparing this data for all benchmarks for modes 2, 3, 4, 5 can derive the data shown in Table 4b. 
- The "# queries to solve" column shows the total number of solver queries run by Java Ranger on that benchmark in a specific mode.
    - Comparing this column between modes 1 and 5 will provide the percentage reduction in solver queries shown in the "% red. in # queries" column in Table 2. 
- The "total solver time" captures the total time spent on solving all the queries by the solver used by Java Ranger
- The "# distinct regions that were instantiated and successfully used" column shows the number of instantiated summaries that were used by Java Ranger. 
    - This number should be similar to or the same as the "# summ. used" column in Table 2. 
    
## Sample data for Tables 2, 4
Since it takes a long time to generate the data for Tables 2, 4, we provide a sample of the same data generated by us by following our own instructions in a file named output.csv at fse20/submissions/reusable/java-ranger/.
    
# Reproducing data for Table 3
The data for the rows labeled "SPF" and "XYZ" is already derived by regenerating the data for Table 2. The data for the row labeled "JBMC" can be generated as follows.
1. Install JBMC by following the installation instructions [here](https://github.com/diffblue/cbmc/tree/develop/jbmc)
2. cd "java-ranger-dir"/build/examples
  - The "java-ranger-dir" refers to the fse20/submissions/reusable/java-ranger directory
3. Use the following commands to run JBMC on each benchmark from inside the build/examples directory. Only the WBS and TCAS benchmarks can be expected to complete within a few seconds. All the other benchmarks will take longer than a day to complete. These commands assume that the jbmc binary is available in $PATH.
  - jbmc  --classpath "java-ranger-dir"/build/examples/:$CLASSPATH  jbmc/wbs/WBS_jbmc.class  --unwinding-assertions
  - jbmc  --classpath "java-ranger-dir"/build/examples/:$CLASSPATH  jbmc/tcas/tcas_jbmc.class  --unwinding-assertions
  - jbmc  --classpath "java-ranger-dir"/build/examples/:$CLASSPATH  jbmc/replace/replace11.class --unwind 12 --unwinding-assertions 
   - jbmc  --classpath "java-ranger-dir"/build/examples/:$CLASSPATH  jbmc/nanoxml/DumpXML.class --unwind 10 --unwinding-assertions 
  - jbmc  --classpath "java-ranger-dir"/build/examples/:$CLASSPATH  jbmc/siena/SENPDriver.class --unwind 8  --unwinding-assertions 
  - jbmc  --classpath "java-ranger-dir"/build/examples/:$CLASSPATH  jbmc/printtokens2_3/printTokens2.class --unwind 82  --unwinding-assertions 
  - jbmc  --classpath "java-ranger-dir"/build/examples/:$CLASSPATH  jbmc/schedule2_3/Schedule2.class --unwind 10  --unwinding-assertions 
  - jbmc  --classpath "java-ranger-dir"/build/examples/:$CLASSPATH  jbmc/apachecli/CLI_jbmc.class --unwind 39  --unwinding-assertions
  - jbmc  --classpath "java-ranger-dir"/build/merarbiter-v2/:$CLASSPATH  MerArbiter/MerArbiter.class  --unwinding-assertions
     - This command needs to be run from the "java-ranger-dir"/build/merarbiter-v2 directory.

# Reproducing results shown in Table 5
We elide the details required for reproducing the results in Table 5. These results were taken from Java Ranger's participation in SV-COMP 2020. It is possible to re-create the same setup using for SV-COMP 2020 participation. Installation of this setup requires [following the instructions to install BenchExec](https://github.com/sosy-lab/benchexec/blob/master/doc/INSTALL.md), downloading all the participating tool's archives available from [here](https://gitlab.com/sosy-lab/sv-comp/archives-2020/-/tree/master/2020) and finally running all the participating tools. We consider setting up the SV-COMP infrastructure out of scope for this artifact.
