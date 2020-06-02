# Installation

## Install Docker
The install instructions for Debian are [here](https://docs.docker.com/engine/install/debian/).
We used the following version:
- Docker version 18.09.0, build 4d60db4

## Build Image
Build the docker image:
```
git clone git@github.com:srg-imperial/pspa-docker.git
cd pspa-docker
make klee38pspa
```

## Run Image
Run the built docker image:
```
docker run -it --rm klee38pspa bash
```

## Sanity Check
Confirm `klee` is in PATH:
```
klee --version
```
