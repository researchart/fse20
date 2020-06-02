# Reusable

Available + Functional + very carefully documented and well-structured to the extent that reuse and repurposing is facilitated. In particular, norms and standards of the research community for artifacts of this type are strictly adhered to. 

# Compute Time estimate
This artifact reproduces results shown in Tables 2 and 4 in our FSE 2020 submission. The reproduction of our results involves running 16 different scripts. Running these scripts serially takes us a total compute time of about 54 hours on a machine running Ubuntu 16.04 with a Intel(R) Xeon(R) CPU E5-2623 v3 @ 3.00GHz processor and 192 GB of memory. This compute time estimate does not take into account the reproduction of the results from the Java track of SV-COMP 2020 which is presented in Table 5 of the submission. Since this is a long-running artifact, we urge the artifact reviewers to allow about 54 hours of compute time before they collect results to review the artifact. However, we provide a script that allows any-time collections of the current set of generated results.

# Storage estimate
Reproduction of the 

# Reproducing data for Tables 2 and 4

## Run individual benchmarks
1. Build jpf-core and java-ranger using the instructions found in INSTALL.md. Ne
2. cd fse20/submissions/reusable/java-ranger
2. mkdir logs

Next, we run Java Ranger on a benchmark in five different modes. 
- Mode 1 corresponds to turning off path-merging. This mode causes Java Ranger to only run SPF and is used to collect baseline performance of the symbolic executor on the benchmark.
- Mode 2 corresponds to basic path-merging abbreviated as "basic p.m." in Tables 4a and 4b. 
- Mode 3 corresponds to the addition of method inlining to Mode 2. Results of running Java Ranger in this mode are shown in the "+method inlining" column in Tables 4a and 4b.
- Mode 4 corresponds to the addition of single-path cases to Mode 3. Results of running Java Ranger in this mode are shown in the "+single path cases" column in Tables 4a and 4b.
- Mode 5 corresponds to the addition of early-returns summarization to Mode 4. Results of running Java Ranger in this mode are shown in the "+early return summ." column in Tables 4a and 4b.
 
All steps below can be run in parallel to save compute time. The runs of Java Ranger (not SPF) for the WBS, TCAS benchmarks should finish within five minutes at most. Also, the runs of the Schedule benchmark for both SPF and Java Ranger should finish within a minute. All the runs for SPF will take much longer than Java Ranger to complete. Each command below will generate a log file in the fse20/submissions/reusable/java-ranger/logs directory. A run is complete when Java Ranger has completed writing to the log file. 
 
1. cd src/examples/veritesting/wbs/ && ./runWBS-SPF.sh && cd ../../../..
  - runs Java Ranger in mode 1 (same as running SPF) on the WBS benchmark with the step function run for five steps with each step taking 3 new symbolic inputs. 
2. cd src/examples/veritesting/wbs/ && ./runWBS-JR.sh && cd ../../../..
  - runs Java Ranger on the WBS benchmark for 10 steps under modes 2, 3, 4, 5. This run should finish within a couple of minutes.
3. cd src/examples/veritesting/tcas/ && ./runTCAS-SPF.sh && cd ../../../..
 - runs Java Ranger in mode 1 on the TCAS benchmark with the step function run for two steps with each step taking 12 new symbolic inputs.
4. cd src/examples/veritesting/tcas/ && ./runTCAS-JR.sh && cd ../../../..
 - runs Java Ranger in modes 2, 3, 4, 5 on the TCAS benchmark for 10 steps. This run should finish within a couple of minutes.
5. cd src/examples/veritesting/replace/ && ./runReplace.sh && cd ../../../..
 - runs Java Ranger in modes 1, 2, 3, 4, 5 on the replace benchmark. 
6. cd src/examples/veritesting/nanoxml/ && ./runNanoXML-SPF.sh && cd ../../../..
 - runs Java Ranger in mode 1 on the NanoXML benchmark
7. cd src/examples/veritesting/nanoxml/ && ./runNanoXML-JR.sh && cd ../../../..
 - runs Java Ranger in modes 2, 3, 4, 5 on the NanoXML benchmark
8. cd src/examples/veritesting/siena/ && ./runSiena-SPF.sh && cd ../../../..
 - runs Java Ranger in mode 1 on the Siena benchmark 
9. cd src/examples/veritesting/siena/ && ./runSiena-JR.sh && cd ../../../..
 - runs Java Ranger in modes 2, 3, 4, 5 on the Siena benchmark 
10. cd src/examples/veritesting/schedule2_3/ && ./runSchedule.sh && cd ../../../..
 - runs Java Ranger in modes 1, 2, 3, 4, 5 on the Schedule benchmark 
11. cd src/examples/veritesting/printtokens2_3/ && ./runPrintTokens-SPF.sh && cd ../../../..
 - runs Java Ranger in mode 1 on the PrintTokens2 benchmark 
12. cd src/examples/veritesting/printtokens2_3/ && ./runPrintTokens-JR.sh && cd ../../../..
 - runs Java Ranger in modes 2, 3, 4, 5 on the PrintTokens2 benchmark 
13. cd src/examples/veritesting/apachecli/ && ./runApacheCLI-SPF.sh && cd ../../../..
 - runs Java Ranger in mode 1 on the ApacheCLI benchmark. This run consumes "5+1" symbolic inputs. This number of symbolic inputs can be found in the "#sym input" column of Table 2. This run makes the first 5 and last input of ApacheCLI to be symbolic.
 14. cd src/examples/veritesting/apachecli/ && ./runApacheCLI-JR_1.sh && cd ../../../..
  - runs Java Ranger in mode 2, 3, 4, 5, on the ApacheCLI benchmark with the same number of symbolic inputs as mode 1.
15. cd src/MerArbiter-v2/ && ./runMerarbiter-SPF.sh && cd ../../../..
  - runs Java Ranger in mode 1 on the MerArbiter benchmark.
16. cd src/MerArbiter-v2/ && ./runMerarbiter-JR.sh && cd ../../../..
  - runs Java Ranger in modes 2, 3, 4, 5 on the MerArbiter benchmark.

## Collect results
We urge the artifact reviewers to allocate 54 hours of compute time to reproduce results from Tables 2, 4. The below script can be used to collect the current set of results into a CSV format.
1. cd fse20/submissions/reusable/java-ranger
2. perl extract-detailed-results.pl logs/ output.csv
 - this command scans the generated
