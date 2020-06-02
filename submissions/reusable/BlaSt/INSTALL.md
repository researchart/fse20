# Install

Our Artifact is provided via a Docker Container. To install our Artifact you are therefore required to _install_ Docker.

Please find out how to get and install Docker for your system [here](https://docs.docker.com/get-docker/).

Please note that you might have to change your Docker preferences after installation to meet core and memory requirements of our Artifact: [Docker Runtime Options](https://docs.docker.com/config/containers/resource_constraints/)

How to adapt these settings globally can be found here:

- [Windows](https://docs.docker.com/docker-for-windows/#resources)
- [MacOS](https://docs.docker.com/docker-for-mac/#resources)

We give hints in the **README.md** file which settings we recommend for which experiments. However, all experiments require a minimum of 32GB of memory. 
 

1. Get the Artifact from [here](https://doi.org/10.5281/zenodo.3872848).

2. Extract the zip-file to a directory of your choice and find the Dockerfile that was included in the zip-file.

3. Build the Docker Container
	```
	$ cd <path/to/dir/with/Dockerfile>
	$ docker build .
    > Successfully built <ContainerID>
	```

	> Warning: This takes significant amount of time (one hour or more)!

	Alternatively, pull the [pre-built Docker Container](https://hub.docker.com/r/mreif/blast) from DockerHub:
	
	```
	$ docker pull mreif/blast
	```
4. Run the Docker Container

	Self-built container:
    ```
    $ docker run -ti <ContainerID>
    ```
    Container pulled from DockerHub:

	```
	$ docker run -ti mreif/blast
	```
5. If everything went correctly, you should be presented with a command prompt like this:
	```
    $root@containerid:/home/blast-evaluation#
    ```