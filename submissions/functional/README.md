## Getting Started

1. Get the docker image [TODO]()
2. Install docker, for Debian the install instructions are [here](https://docs.docker.com/engine/install/debian/)
3. Load the docker image: `docker load --input artefact.tgz`
4. Run the docker image: `docker run --rm -it klee38pspa bash`

This opens a shell into the docker image with all the sources and benchmarks used for our evaluation. 
Folders of interests:

* `/klee-dsa-benchmarks` - contains the benchmarks used in the evaluation 
* `/src/pspa-master` - Source code for PSPA analysis
* `/src/client-choper` - Chopper on top of PSPA
* `/src/client-resolution` - KLEE with PSPA based object resolution
* `/src/client-wit` - KLEE performing WIT with PSPA:w
* `/src/client-choper-build/bin` - Binaries for Chopper on top of PSPA
* `/src/client-resolution-build/bin` - Binaries for KLEE with PSPA based object resolution
* `/src/client-wit-build/bin` - Binaries  for KLEE performing WIT with PSPA:w


## Running the experiments

TODO

