# MTFuzz: Fuzzing with a Multi-Task Neural Network

### Framework
![image](https://user-images.githubusercontent.com/57293631/80742593-a34d8100-8ae9-11ea-9f52-a1931d945a5c.png)

### Intro
MTFuzz is a novel neural network assisted fuzzer based on multi-task learning technique. It uses a NN to learn a compact embedding of input file for multiple fuzzing tasks (i.e., predicting different types of code coverage). The compact embedding is used to guide effective mutation by focusing on hot bytes. Our results show MTFuzz uncovers 11 previously unseen bugs and achieves an average of 2x more edge coverage compared with 5 state-of-the-art fuzzers on 10 real-world programs.

### How to reproducing results
To reproduce our main results reported in paper Table.4, please check INSTALL.md and source/programs directory. There are 2 ways to run our tool:

- Run MTFuzz on your local system with a GPU (Nvidia 1080 Ti/Nvidia K80 or higher is recommended). See [here]() for detailed instructions.
- Run MTFuzz on an pre-configured AWS VM with GPU in case reviewers don't have proper GPU resources. We have created an AWS account with a pre-configured vanilla Ubuntu 18.04 with Nvidia K80 on AWS for reviewers. The credential to access the AWS VM have been shared with PC chair and may be requested. Please See [here]() for detailed instructions.

### Prerequisites
Please ensure the following pre-requisits have been met:
- Python 3.7
- Tensorflow-gpu 1.15.0
- Keras 2.2.4
- LLVM 7.0.0 (with Clang) (We recommend building from [source](https://releases.llvm.org/7.0.0/docs/ReleaseNotes.html))

### Build
Our code lives in the [source](https://github.com/Dongdongshe/fse20/tree/master/submissions/reusable/mtfuzz/source) folder.

Enter the source folder and run the following to get started with the instrumentations.
```bash
    cd source
    ./build.sh  # build llvm coverage passes and CMP passes.
```

### Usage 
We provide source code of MTFuzz in source directory. A short usage example of readelf is shown below. For detailed usage, please check [INSTALL.md](https://github.com/Dongdongshe/fse20/blob/master/submissions/reusable/mtfuzz/INSTALL.md). 

1. Compile your test programs with different llvm coverage passes. 
```bash
    cd src_directory/   # go to source directory of your program
    CC=source/ec_pass/afl-clang-fast ./configure && make  # build ec coverage program
    CC=source/ctx_pass/afl-clang-fast ./configure && make # build ctx coverage program
    CC=source/approach_pass/afl-clang-fast ./configure && make # build approach level coverage program
```

2. Compile programs to so as to intercept operands of every CMP instrutions with llvm CMP passes.
```bash
    cd src_directory/
    CC=source/br_pass/afl-clang-fast ./configure && make # instrment every CMP instutions of program 
    CC=source/br_fast_pass/afl-clang-fast ./configure && make # faster version using fork server 
```

3. Now, open two terminal sessions, let's call them session-A and session-B.

4. In terminal session-A, run multi-task nn module as follows:
```bash
    cd source/programs/readelf
    python ./nn.py ./readelf -a 
```

5. In terminal session-B run fuzzing module in the same directory as follows:
```bash
    cd source/programs/readelf
    python ./mtfuzz_wrapper.py -i mtfuzz_in -o seeds -l 7406 ./readelf -a @@
```

