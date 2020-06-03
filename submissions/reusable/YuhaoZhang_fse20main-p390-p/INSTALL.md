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

**Inside Dockerfile, we use a `curl` command to download the dataset from google drive. If you stuck at this command, you may comment out this line and manually download and unzip it to the `./DEBAR` directory.**

Next, we start a bash into the image:

```bash
docker run -it debar:latest bash
```

The bash will prompt with `root@[container id]:/usr/src/app#`, where `[container id]` means the container id of the image.

### Example

In the working directory of docker image, you can type the following command to get the result of `TensorFuzz`.

```bash
python analysis_main.py ./computation_graphs_and_TP_list/computation_graphs/TensorFuzz.pbtxt
```

Our tool will report the following:

```
(225, 178110)
Exp Exp
warnings
Exp Exp_1
warnings
RealDiv truediv
warnings
Log Log
warnings
TensorFuzz , all:  4 	warnings:  4 	safe:  0
```

, which means there are 4 unsafe operations in total. DEBAR generates warnings for all of them. DEBAR will output the operation and the name of the node, e.g., `Exp Exp_1` means the operation is `Exp` and the name of the node is `Exp_1`. DEBAR will also output the basic information of the architecture: `(225, 178110)` means that there are 225 operations and 178110 parameters in the architecture.

## Reproduce Evaluation in our Paper

Please type the following command, which is supposed to reproduce the evaluation results in our paper.

```bash
python main.py ./computation_graphs_and_TP_list/computation_graphs/
```

The above command (typically running 30-60mins) will only report one summary line for each architecture. For example, it will report the following summary line for the architecture `TensorFuzz`:

```
TensorFuzz , all:  4 	warnings:  4 	safe:  0	 in time: 2.64
```

And the full output will be stored at `./results.txt`.

The `safe` number corresponds to the column #6 (DEBAR-TN) in Table 1 in our ESEC/FSE2020 paper and the `warnings` number corresponds to the sum of column #5 (TP) and column #7 (DEBAR-FP) in Table 1.

Notice that we manually classify the warnings to true positives and false positives. The result and reason for each warning are reported in `./computation_graphs_and_TP_list/true_positives.csv` (inside the collected datasets).

### Other Results

We have reproduced the results of DEBAR in Table 1 in our ESEC/FSE2020 paper. There are other results `Array smashing` (Table 1), `Sole Interval Abstraction` (Table 1), and `Array Expansion` (Table 3). Because they are different settings from DEBAR, we create 3 individual tags for these results. 

* `Array Smashing` has the tag `smashing-affine`.
  Please checkout to tag `smashing-affine` by the following command. And then build the docker image again.

  ```bash
  git checkout tags/smashing-affine -b smashing-affine
  ```

* `Sole Interval Abstraction` has the tag `partition-wo-affine`.
  Please checkout to tag `partition-wo-affine` by the following command. And then build the docker image again.

  ```bash
  git checkout tags/partition-wo-affine -b partition-wo-affine
  ```

* `Array Expansion` has the tag `expansion-affine`.
  Please checkout to tag `expansion-affine` by the following command. And then build the docker image again.

  ```bash
  git checkout tags/expansion-affine -b expansion-affine
  ```

  Notice that `expansion-affine` needs a 30-mins timeout. Instead, we manually comment out the corresponding model names in the `./parse/specified_ranges.py`. 