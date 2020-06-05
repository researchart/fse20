# Installation

In this document, you will find all the information you need to setup an environment that can execute our artifacts.

## Execute the Artifacts in a Docker Container (Recommended)

In the root of our replication package, you find a `Dockerfile`. This file can be used the build an image that your Docker installation can run.

1. Install [Docker](https://www.docker.com/products/docker-desktop)
2. Open the terminal and set the root folder of the replication package as the working directory.
3. Build the image `docker build --no-cache -t cd-linter-artifacts:v1 .`
4. Run the image `docker run -it cd-linter-artifacts:v1`

## Setup Your Own Environment

If you like, you can build your own environment to execute the artifacts. You need to manually install the following tools and copy the content of our replication package.

* Java 11.0.7
* Maven 3.6.0
* Python 3.7.7
* pip 9.0.1
* R 3.4.4
* R packages: 'likert', 'knitr'
* Python packages specified in `requirements.txt`