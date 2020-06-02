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

# Usage Example

# Running the experiments

We provide a script for each of the experiments in our evaluation.
The results of the experiment are written to the `/output` directory.

## Statistics
To run the experiments for Table 1:
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

### Coverage

### CVE

### Termination

## Application: Symbolic Pointers Resolution

## Application: WIT
