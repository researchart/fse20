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
TODO: The expected output:

### Coverage
To run the experiments for tables 2 and 3:
```
cd /klee-dsa-benchmarks
./run_coverage.sh
```
To parse the results for table 2:
TODO: ...

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
TODO: ...

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
