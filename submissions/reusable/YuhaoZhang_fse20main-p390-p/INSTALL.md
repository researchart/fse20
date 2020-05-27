# INSTALL

We describe how to install the working environment of DEBAR and how to reproduce the results in the paper.

## Docker

We provide the docker way of reproducing the results. Notice that in the repository we provide another way to run DEBAR if the users wants to run in their working environments.

The first step is to install docker. Please refer to https://www.docker.com/get-started.

The following command can test whether the docker is sucessfully installed. 

```bash
docker run -it hello-world
```

It shall output the following:

```
Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

You may need to add `sudo` to run docker.

## DEBAR

Please clone the repository from Github and `cd` into the directory.

```bash
git clone https://github.com/ForeverZyh/DEBAR
cd DEBAR
```

And start to build DEBAR:

```bash
docker build -t debar .
```

After done, make sure the last line of message is:

```
Successfully tagged debar:latest
```

, which shows that the building process is success.

Next, we start a bash into the image:

```bash
docker run -it debar:latest bash
```

The bash will prompt with `root@[container id]:/usr/src/app#`, where `[container id]` means the container id of the image.

### An example

In the working directory of docker image, you can type the following command to get the result of `Github-IPS-1`.

```bash
python analysis_main.py ./computation_graphs_and_TP_list/computation_graphs/Github-IPS-1.pbtxt
```

Our tool will report the following:

```
(1546, 5052902)
Log Log
warning
Github-IPS-1 , all:  5 	warnings:  1 	safe:  4
```

, which means there are 5 unsafe operations in total. Among them, 1 warning is generated on the operation `Log` with name `Log` and the other 4 unsafe operations are verified to be safe. DEBAR will also output the basic information of the architecture: `(1546, 5052902)` means that there are 1546 operations and 5052902 parameters in the architecture.

### Reproduce the results in the paper

Please type the following command, which is supposed to reproduce the evaluation results in our paper.

```bash
python main.py ./computation_graphs_and_TP_list/computation_graphs/
```

The above command will only report one summary line for each architecture. For example, it will report the following summary line for the architecture `Github-IPS-1`:

```
Github-IPS-1 , all:  5 	warnings:  1 	safe:  4
```

And the full output will be stored at `./results.txt`.

Notice that we manually classify the warnings to true positives and false positives. The result and reason for each warning are reported in `./computation_graphs_and_TP_list/true_positives.csv` (inside the collected datasets).

