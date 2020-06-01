### Environment 

We conducted 5 experiments in `LEMON` of which the library and CUDA version information are as described above. In order to facilitate other researchers to reproduce `LEMON`, we provide a `docker`  image for the `E1` experiment. It can be easily obtained by the following command. (**Note: nvidia-docker2 is required!**) 

**Step 0:** Please Install [nvidia-docker2](https://github.com/NVIDIA/nvidia-docker). You can use this [instruction](https://codepyre.com/2019/01/installing-nvidia-docker2-on-ubuntu-18.0.4/) to install it.

**Step 1:** Clone the repository. Download the dataset and models from  [OneDrive](https://1drv.ms/u/s!Aj6dGBsJFcs0jnXVUfAtsEjdUW_T?e=ezo32C). Save the code and unzip datasets and models to `/your/local/path/` , e.g. `/your/local/path/origin_model` and `/your/local/path/dataset`. (`/your/ local/path/` should be the absolute path on your server, e.g. `/home/user_xxx/`)

**Step 2:** Using the following command to pull the docker image we released for `E1` and create a container for it. 

> docker pull yenming1227/lemon:e1
>
> docker run --runtime=nvidia -it -v **/your/local/path/**:/data --name "lemon_exp01" yenming1227/lemon:e1 /bin/bash

Then you will enter a container.(Remember to change `/your/local/path/` to the real path! ^_^)

**Note: If your server is using http proxy, you should configure proxy in the container just as you did in your server before**

**Step 3:** Create five virtual environments as shown below in your docker container.

**Note: Please copy the installation command line by line to prevent some commands from being skipped.**

 ```shell
# tensorflow
conda create -n tensorflow python=3.6
source activate tensorflow
pip install -r lemon_requirements.txt
pip install keras==2.2.4
pip install tensorflow-gpu==1.14.0
source deactivate

# theano
conda create -n theano python=3.6
source activate theano
pip install -r lemon_requirements.txt
conda install pygpu=0.7.6
pip install keras==2.2.4
pip install theano==1.0.4
source deactivate

# cntk
conda create -n cntk python=3.6
source activate cntk
pip install -r lemon_requirements.txt
pip install keras==2.2.4
pip install cntk-gpu==2.7
source deactivate

# mxnet
conda create -n mxnet python=3.6
source activate mxnet
pip install -r lemon_requirements.txt
pip install keras-mxnet==2.2.4.2
pip install mxnet-cu101==1.5.1.post0
source deactivate

# default lemon python
conda create -n lemon python=3.6
source activate lemon
pip install -r lemon_requirements.txt
pip install keras==2.2.4
pip install tensorflow-gpu==1.14.0
source deactivate
 ```

### Redis Startup

LEMON uses redis to store intermediate outputs and exchange data between different processes. We have installed redis in our docker image, you can start it with the following command:

> cd  /root/redis-4.0.8/src
>
> ./redis-server ../redis.conf

### Experiments libraries groups

We used `20` release versions of  `4` widely-used DL `libraries`, i.e., `TensorFlow`, `CNTK`,`Theano`, and `MXNet`, as subjects to constructed five experiments (indexed E1 to E5 in Table) to conduct differential testing.

We share the link of each library and docker image used in LEMON. 

| Experiment ID | Tensorflow                                                | Theano                                          | CNTK                                                         | MXNet                                                      | CUDA                                                         |
| ------------- | --------------------------------------------------------- | ----------------------------------------------- | ------------------------------------------------------------ | ---------------------------------------------------------- | ------------------------------------------------------------ |
| E1            | [1.14.0](https://pypi.org/project/tensorflow-gpu/1.14.0/) | [1.0.4](https://pypi.org/project/Theano/1.0.4/) | [2.7.0](https://pypi.org/project/cntk-gpu/2.7/)              | [1.5.1](https://pypi.org/project/mxnet-cu101/1.5.1.post0/) | [10.1](docker pull nvidia/cuda:10.1-cudnn7-devel-ubuntu16.04) |
| E2            | [1.13.1](https://pypi.org/project/tensorflow-gpu/1.13.1/) | [1.0.3](https://pypi.org/project/Theano/1.0.3/) | [2.6.0](https://pypi.org/project/cntk-gpu/2.6/)              | [1.4.1](https://pypi.org/project/mxnet-cu100/1.4.1/)       | [10.0](docker pull nvidia/cuda:10.0-cudnn7-devel-ubuntu16.04) |
| E3            | [1.12.0](https://pypi.org/project/tensorflow-gpu/1.12.0/) | [1.0.2](https://pypi.org/project/Theano/1.0.2/) | [2.5.1](https://pypi.org/project/cntk-gpu/2.5.1/)            | [1.3.1](https://pypi.org/project/mxnet-cu90/1.3.1/)        | [9.0](docker pull nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04)  |
| E4            | [1.11.0](https://pypi.org/project/tensorflow-gpu/1.11.0/) | [1.0.1](https://pypi.org/project/Theano/1.0.1/) | [2.4.0](https://docs.microsoft.com/en-us/cognitive-toolkit/Setup-Linux-Python?tabs=cntkpy24) | [1.2.1](https://pypi.org/project/mxnet-cu90/1.2.1.post1/)  | [9.0](docker pull nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04)  |
| E5            | [1.10.0](https://pypi.org/project/tensorflow-gpu/1.10.0/) | [1.0.0](https://pypi.org/project/Theano/1.0.0/) | [2.3.1](https://docs.microsoft.com/en-us/cognitive-toolkit/Setup-Linux-Python?tabs=cntkpy231) | [1.1.0](https://pypi.org/project/mxnet-cu90/1.1.0/)        | [9.0](docker pull nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04)  |

\* All libraries should be  `GPU-supported` version