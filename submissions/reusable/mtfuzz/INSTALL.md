# MTFUZZ

## Table of contents

**[1. Preconfigured AWS (_Recommended for review, it's easy_)](https://github.com/Dongdongshe/fse20/blob/master/submissions/reusable/mtfuzz/INSTALL.md#1-preconfigured-aws-recommended-for-review-its-easy) (Takes ~20 mins to start fuzzing)**

**[2. Run on a local Machine (_Recommeded to experimentation, this will take time_)](https://github.com/Dongdongshe/fse20/blob/master/submissions/reusable/mtfuzz/INSTALL.md#2-run-on-a-local-machine-recommeded-to-experimentation-this-will-take-time)**

**[3. Use MTFuzz on your own program (_Recommended for exending current method, this will take a lot more time_)](https://github.com/Dongdongshe/fse20/blob/master/submissions/reusable/mtfuzz/INSTALL.md#3-use-mtfuzz-on-your-own-program-recommended-for-exending-current-method-this-will-take-a-lot-more-time)**

# 1. Preconfigured AWS (_Recommended for review, it's easy_)

**NOTE: We have created an AWS account with a pre-configured AWS instance for review. Please request AWS username, password, and `*.pem` file from PC chairs. Follow the instructions below after you have the credentials.**

1. Go to https://aws.amazon.com/console/ and log in with the credentials above

2. Select region "US East (Ohio) us-east-2" as below:
![Screenshot 2020-06-05 06 10 27](https://user-images.githubusercontent.com/1433964/83867347-4734d880-a6f7-11ea-9e9d-0cb59cd6afaf.png)

3. Choose EC2
![Screenshot 2020-06-05 06 21 41](https://user-images.githubusercontent.com/1433964/83867639-c0ccc680-a6f7-11ea-9e99-60050eb9c1cc.png)

4. Go to instances on the left
![Screenshot 2020-06-05 06 22 33](https://user-images.githubusercontent.com/1433964/83867691-d80bb400-a6f7-11ea-82bf-241d20cdfc35.png)

5. Right-click on fse-artifact, go to Instance State, and then start. 
![Screenshot 2020-06-05 06 23 37](https://user-images.githubusercontent.com/1433964/83868100-52d4cf00-a6f8-11ea-8118-99c48f9f62ae.png)

6. After the instance starts running, right-click and select connect
![image](https://user-images.githubusercontent.com/1433964/83868259-94657a00-a6f8-11ea-9cb3-787a2d26876b.png)

7. You'll see the panel below. At this point you must have access the `*.pem` file.
![image](https://user-images.githubusercontent.com/1433964/83868387-c7a80900-a6f8-11ea-8b16-0b3e8df58116.png)

8. `chmod` your pem file
```bash
chmod 400 fse_mtfuzz.pem
```

9. Open a terminal and ssh into the running container
```
$ ssh -i path/to/your/pemfile/fse_mtfuzz.pem ubuntu@ec2-18-...

```

10. Enter the `mtfuzz` directory
```bash 
$ cd mtfuzz
```
![Screenshot 2020-06-05 07 02 02](https://user-images.githubusercontent.com/1433964/83869371-7c8ef580-a6fa-11ea-83e4-e28795a38387.png)

11. Activate the tensorflow virtual environment
```bash
$ source activate tensorflow_p36
```

12. You may now follow instructions from [§2.2](https://github.com/Dongdongshe/fse20/blob/master/submissions/reusable/mtfuzz/INSTALL.md#22-build-mtfuzz) to run MTFuzz.

# 2. Run on a local Machine (_Recommeded to experimentation, this will take time_)

## 2.1 Install prerequisite
- Python 3.7 or more
- Install tensorflow-gpu 1.15 (Note that you need to install proper CUDA, CuDNN drivers before installing tensorflow-gpu. We recommend `conda` package manager for python. In our experience, it has done a good job installing all the dependencies).
- Install Keras 2.24
- Install LLVM 7.0.0 (we recommend building from the source)
- Install Clang 7

## 2.2 Build MTFuzz
```bash
    cd source
    ./build.sh  # build llvm coverage passes and CMP passes.
```

## 2.3 Run MTFuzz
Run MTFuzz on 10 tested programs reported in our paper. We will use program size as an example.

1. Enter size directory
```bash
    cd programs/size
```
2. Install some required libraries.
```bash
    sudo dpkg --add-architecture i386
    sudo apt-get update
    sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1
```
3. Set CPU scaling and core dump notification with root
```bash
    cd /sys/devices/system/cpu
    echo performance | tee cpu*/cpufreq/scaling_governor
    echo core >/proc/sys/kernel/core_pattern
```
4. Open two terminal sessions (let's call them _terminal-A_ and _terminal-B_). _Please Note: if you are on aws, (1) open a new terminal; (2) ssh into the aws container; and (3) cd to the current directory._

5. In terminal-A, start the MTNN module as follows (**Do not exit/close this terminal**)
```bash  
    python nn.py ./size 
```
5. In terminal-B, start fuzzing module (**Do not close/exit this terminal either**)
```bash
    # -l, file len is obtained by maximum file lens in the mtfuzz_in ( ls -lS mtfuzz_in|head )
    python ./mtfuzz_wrapper.py -i mtfuzz_in -o seeds -l 7402 ./size @@
```

_Note: The initial data processing will take around 5-10 minutes. If you see the following log in NN module terminal and fuzzing module terminal, then MTFuzz is running correctly. In fuzzing module terminal, the first red block shows the edge coverage of init seed corpus, then the following lines shows the current edge coverage discovered by MTFuzz. To compute the new edge coverage, users simply need to substrate init edge coverage from current edge coverage._

![image](https://github.com/Dongdongshe/fse20/blob/master/submissions/reusable/mtfuzz/nn_module.png?raw=true)
![image](https://github.com/Dongdongshe/fse20/blob/master/submissions/reusable/mtfuzz/fuzzing_module.png?raw=true)


# 3. Use MTFuzz on your own program (_Recommended for exending current method, this will take a lot more time_)
Here, we demonstrate how to set up MTFuzz on your own programs. Let's use expat, an XML parser, as an example. _Note: in the following instructions, we use some automation bash scripts like `build_expat.sh` or `./setup_mtfuzz_xmlwf.sh`. These are meant to ease the build process, please change them as you see fit for according to the specifics of your program._

1. Go to the programs directory inside [source](https://github.com/Dongdongshe/fse20/tree/master/submissions/reusable/mtfuzz/source) folder. If you are using our AWS, then use:
```bash
cd ~/mtfuzz/source/programs
```

2. Download and unzip expat source code and cd into expat's root directory:
```bash
    wget https://github.com/libexpat/libexpat/releases/download/R_2_2_9/expat-2.2.9.tar.bz2 
    tar -axvf expat-2.2.9.tar.bz2
    cd expat-2.2.9
```
2.  Instrument expat with MTFuzz llvm pass.
```bash
    cp ../build_expat.sh .
    ./build_expat.sh
```
3. Collect init training dataset for MTFuzz. Run afl-fuzz with a single input file on xmlwf for about an hour. To save time, we provide a collected dataset in xmlwf_afl_1hr directory. Set up MTFuzz for xmlwf.
```bash
    cd ..
    ./setup_mtfuzz_xmlwf.sh
```
4. Enter xmlwf directory and start nn module.
```bash
    cd xmlwf
    python ./nn.py ./xmlwf
```
5. Open another terminal and enter same directory and start fuzzing module
```bash
    # -l, file len is obtained by maximum file lens in the mtfuzz_in ( ls -lS mtfuzz_in|head )
    python ./mtfuzz_wrapper.py -i mtfuzz_in/ -o seeds/ -l 7961 ./xmlwf @@
```
You can find the following output log at the two terminals if MTFuzz runs correctly.
![image](https://github.com/Dongdongshe/fse20/blob/master/submissions/reusable/mtfuzz/xmlwf_nn.png?raw=true)
![image](https://github.com/Dongdongshe/fse20/blob/master/submissions/reusable/mtfuzz/xmlwf_fuzz.png?raw=true)
