# Installation

## Install Docker
The installation instructions for Debian are [here](https://docs.docker.com/engine/install/debian/).
We used the following version:
- Docker version 18.09.0, build 4d60db4

## Load Image
Download the Docker image [here](https://doi.org/10.6084/m9.figshare.12410231) and load with:
```
docker load < klee38pspa.tar.gz
```

## Run Image
Run the docker image:
```
docker run -it --rm klee38pspa bash
```

## Sanity Check
Check that `klee` is in PATH:
```
klee --version
```
