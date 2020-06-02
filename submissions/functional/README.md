# Getting Started

Run the docker image:
`docker run --rm -it klee38pspa bash`

This opens a shell into the docker image with all the sources and benchmarks used for our evaluation. 
Folders of interest:

* `/klee-dsa-benchmarks` - Contains the benchmarks used in the evaluation 
* `/src/SVF-dynamic` - Source code for PSPA analysis
* `/src/client-choper` - Source code for Chopper on top of PSPA
* `/src/client-resolution` - Source code for KLEE with PSPA based object resolution
* `/src/client-wit` - Source code for KLEE performing WIT with PSPA
* `/src/client-choper-build/bin` - Binaries for Chopper on top of PSPA
* `/src/client-resolution-build/bin` - Binaries for KLEE with PSPA based object resolution
* `/src/client-wit-build/bin` - Binaries for KLEE performing WIT with PSPA

# Running the experiments

We provide a script for each of the experiments in our evaluation.
The results of the experiment are written to the `/output` directory.

## Statistics
To run the experiments for table 1:
```
cd /klee-dsa-benchmarks
./run_statistics_experiment.sh
```
To parse the results:
```
python3.5 parse_statistics.py /output/statistics/
```
The expected output:
```
/output/statistics/libosip-mod: 17.788527634865403
/output/statistics/libosip-mod: 2.94666381979289
/output/statistics/libtasn1-mod: 7.357920358822886
/output/statistics/libtasn1-mod: 1.5588283557597638
/output/statistics/libtiff-mod: 140.16058016058017
/output/statistics/libtiff-mod: 12.958559958559958
/output/statistics/libosip-ref: 32.98462950707683
/output/statistics/libosip-ref: 3.684694879788188
/output/statistics/libtasn1-ref: 8.245487364620939
/output/statistics/libtasn1-ref: 1.9454928344820042
/output/statistics/libtiff-ref: 126.63247863247864
/output/statistics/libtiff-ref: 17.44107744107744
```

## Application: Chopped Symbolic Execution

### Recoveries
To run the experiments for figure 4:
```
cd /klee-dsa-benchmarks
./run_modref_experiment.sh
```
To parse the results:
```
python3.5 parse_recoveries.py /output/cse/recoveries/ /out.csv
```
The expected output:
```
benchmark,config,mode,paths,recoveries,snapshots,usage,overhead
libosip,skip_10,static,450747,1012604,631923,0,0.0
libosip,skip_10,symbolic,484435,831105,677439,677439,4.17
libosip,skip_5,static,123327,374093,12523,0,0.0
libosip,skip_5,symbolic,155969,324350,26004,26004,0.52
libosip,skip_2,static,756060,756009,2,0,0.0
libosip,skip_2,symbolic,734785,734734,2,2,0.93
libosip,skip_4,static,182035,574353,110743,0,0.0
libosip,skip_4,symbolic,277670,506769,169877,169877,1.41
libosip,skip_1,static,116742,396563,30988,0,0.0
libosip,skip_1,symbolic,117886,382565,34867,34867,0.49
libosip,skip_3,static,757665,757615,2,0,0.0
libosip,skip_3,symbolic,736741,736691,2,2,0.94
libosip,skip_7,static,747275,747224,2,0,0.0
libosip,skip_7,symbolic,731407,731356,2,2,0.93
libosip,skip_8,static,33697,483091,52531,0,0.0
libosip,skip_8,symbolic,43869,481941,65442,65442,0.65
libosip,skip_9,static,26473,245088,3253,0,0.0
libosip,skip_9,symbolic,24623,228282,3147,3147,0.21
libosip,skip_6,static,471682,1473900,716983,0,0.0
libosip,skip_6,symbolic,479723,1275087,751046,751046,5.4
libtasn1,skip_10,static,360,253932,5042,0,0.0
libtasn1,skip_10,symbolic,1350,255957,15930,14637,1.08
libtasn1,skip_5,static,605,183520,2686,0,0.0
libtasn1,skip_5,symbolic,4057,60724,24674,24674,10.73
libtasn1,skip_2,static,253,525676,3034,0,0.0
libtasn1,skip_2,symbolic,1285,537402,19692,19692,1.76
libtasn1,skip_4,static,261,372451,758,0,0.0
libtasn1,skip_4,symbolic,421,498311,1309,1309,1.08
libtasn1,skip_1,static,582,344230,523,0,0.0
libtasn1,skip_1,symbolic,6397,374246,14099,14099,1.31
libtasn1,skip_3,static,458,238892,589,0,0.0
libtasn1,skip_3,symbolic,2023,32188,2820,2820,0.38
libtasn1,skip_7,static,83,281003,106,0,0.0
libtasn1,skip_7,symbolic,1447,146778,3313,1929,0.59
libtasn1,skip_8,static,450,225546,531,0,0.0
libtasn1,skip_8,symbolic,4032,73837,5863,5863,1.58
libtasn1,skip_9,static,5581,380338,12163,0,0.0
libtasn1,skip_9,symbolic,15732,114801,35292,35292,1.86
libtasn1,skip_6,static,7564,162676,27152,0,0.0
libtasn1,skip_6,symbolic,19343,128583,70911,51631,2.2
libtiff,skip_10,static,252,384599,11,0,0.0
libtiff,skip_10,symbolic,719,1160,14,14,0.41
libtiff,skip_5,static,731,19810,690,0,0.0
libtiff,skip_5,symbolic,731,894,694,694,0.4
libtiff,skip_2,static,731,16101,4,0,0.0
libtiff,skip_2,symbolic,731,14817,4,4,0.14
libtiff,skip_4,static,731,38349,564,0,0.0
libtiff,skip_4,symbolic,1188,1029,934,934,0.32
libtiff,skip_1,static,618,443865,161,0,0.0
libtiff,skip_1,symbolic,636,13451,2506,1917,1.6
libtiff,skip_3,static,5118,293947,6117,0,0.0
libtiff,skip_3,symbolic,5660,23297,6954,6954,2.26
libtiff,skip_7,static,2878,37492,2891,0,0.0
libtiff,skip_7,symbolic,27112,14413,44332,44332,8.22
libtiff,skip_8,static,481,210033,15,0,0.0
libtiff,skip_8,symbolic,497,1265,17,17,0.29
libtiff,skip_9,static,10665,42413,16,0,0.0
libtiff,skip_9,symbolic,139657,20508,5137,5137,0.92
libtiff,skip_6,static,10665,43344,959,0,0.0
libtiff,skip_6,symbolic,130397,10,2245,2245,0.91
```

### Coverage
To run the experiments for tables 2 and 3:
```
cd /klee-dsa-benchmarks
./run_coverage.sh
```
To parse the results for table 2, we use _gcov_ and _lcov_ to compute the line coverage.
For each _benchmark_ (libosip, libtasn1, libtiff), run:
```
cd /klee-dsa-benchmarks/<benchmark>
./compute_coverage.sh /output/cse/coverage/libosip/klee-out-<search>_<mode> && ./gen_report.sh /report
```
where _search_ is one `dfs` or `random-path`, and _mode_ is `static` or `pspa`.
For example, for _libosip_ with _dfs_ and _pspa_, the expected output is:
```
...
...
Overall coverage rate:
  lines......: 10.1% (519 of 5144 lines)
...
...
```

To parse the results for table 3:
```
python3.5 parse_overhead.py /output/cse/coverage/
```
The expected output:
```
/output/cse/coverage/libosip / dfs
        No R: 97.87, R: 6.41, N: 6680404
/output/cse/coverage/libosip / random-path
        No R: 90.18, R: 2.66, N: 919326
/output/cse/coverage/libtasn1 / dfs
        No R: 3.06, R: 2.31, N: 967
/output/cse/coverage/libtasn1 / random-path
        No R: 9.8, R: 3.54, N: 6800
/output/cse/coverage/libtiff / dfs
        No R: 3.24, R: 0.04, N: 401
/output/cse/coverage/libtiff / random-path
        No R: 95.74, R: 0.52, N: 155688
```

### CVE Reproduction
To run the experiments for table 4:
```
cd /klee-dsa-benchmarks/cve/libtasn1/
./run_cve_experiments.sh
```
To parse the results for table 4:
S_PA without chopping-aware heuristic (column 1):
```
python3.5 parse_cve.py /output/cse/cve/static-without-cah/
```

PS_PA without chopping-aware heuristic (column 2):
```
python3.5 parse_cve.py /output/cse/cve/pspa-without-cah/
```

S_PA with chopping-aware heuristic (column 3):
```
python3.5 parse_cve.py /output/cse/cve/static/
```

PS_PA with chopping-aware heuristic (column 4):
```
python3.5 parse_cve.py /output/cse/cve/pspa/
```

### Termination
To run the experiments for table 5:
```
cd /klee-dsa-benchmarks
./run_all_path.sh
```
To parse the results for table 5:
```
python3.5 parse_termination.py /output/cse/termination/
```
The expected output:
```
libosip/vanilla: 00:33:30
libosip/static: 01:00:00
libosip/pspa: 00:04:16
libtasn1/vanilla: 00:41:29
libtasn1/static: 01:00:00
libtasn1/pspa: 00:02:12
libtiff/vanilla: 00:32:40
libtiff/static: 01:00:00
libtiff/pspa: 00:10:02
```

## Application: WIT
To run the experiments for table 6:
```
cd /klee-dsa-benchmarks
./run_wit.sh
```
To parse the results for table 6:
```
python3.5 parse_wit.py /output/wit/
```
The expected output:
```
libosip/static: Colours: 70, Transitions: 108532593
libosip/pspa: Colours: 277, Transitions: 302069717
libtasn1/static: Colours: 157, Transitions: 8848420
libtasn1/pspa: Colours: 645, Transitions: 39456716
libtiff/static: Colours: 1047, Transitions: 1938
libtiff/pspa: Colours: 1101, Transitions: 1938
```

## Application: Symbolic Pointers Resolution
To run the experiments for table 7:
```
cd /klee-dsa-benchmarks
./run_resolution_experiment.sh
```
To parse the results for table 7:
```
python3.5 parse_resolution.py /output/resolution/
```
The expected output:
```
m4/vanilla: Q: 1902, RT: 56%, ET: 00:49:13, SA: 0.0%
m4/static: Q: 1836, RT: 55%, ET: 00:47:08, SA: 0.15%
m4/pspa: Q: 960, RT: 38%, ET: 00:34:46, SA: 0.54%
make/vanilla: Q: 21832, RT: 56%, ET: 01:05:02, SA: 0.0%
make/static: Q: 18872, RT: 52%, ET: 00:59:48, SA: 0.16%
make/pspa: Q: 6222, RT: 30%, ET: 00:41:13, SA: 1.22%
sqlite/vanilla: Q: 7726, RT: 28%, ET: 00:43:19, SA: 0.0%
sqlite/static: Q: 7726, RT: 23%, ET: 00:50:47, SA: 14.23%
sqlite/pspa: Q: 1166, RT: 5%, ET: 00:33:23, SA: 0.51%
```
