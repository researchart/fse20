## Getting Started

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

## Running the experiments

TODO
