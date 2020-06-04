# MTFuzz: Fuzzing with a Multi-Task Neural Network

### Framework
![image](https://user-images.githubusercontent.com/57293631/80742593-a34d8100-8ae9-11ea-9f52-a1931d945a5c.png)

### Intro
MTFuzz is a novel neural network assisted fuzzer based on multi-task learning technique. It uses a NN to learn a compact embedding of input file for multiple fuzzing tasks (i.e., predicting different types of code coverage). The compact embedding is used to guide effective mutation by focusing on hot bytes. Our results show MTFuzz uncovers 11 previously unseen bugs and achieves an average of 2x more edge coverage compared with 5 state-of-the-art fuzzers on 10 real-world programs.

### Prerequisite
- Python 3.7
- Tensorflow-gpu 1.15.0
- Keras 2.2.4
- LLVM 7.0.0

### Build
```bash
    cd source
    ./build.sh  # build llvm coverage passes and CMP passes.
```
### Usage 
We provide source code of MTFuzz in source directory. A short usage example of readelf is shown below. For detailed usage, please check INSTALL.md. 
1. Compile tested programs with different llvm coverage passes. 
```bash
    cd src_directory/   # go to source directory of tested program
    CC=source/ec_pass/afl-clang-fast ./configure && make  # build ec coverage program
    CC=source/ctx_pass/afl-clang-fast ./configure && make # build ctx coverage program
    CC=source/approach_pass/afl-clang-fast ./configure && make # build approach level coverage program
```
2. Compile programs to intercept operands of every CMP instrutions with llvm CMP passes.
```bash
    cd src_directory/
    CC=source/br_pass/afl-clang-fast ./configure && make # instrment every CMP instutions of program 
    CC=source/br_fast_pass/afl-clang-fast ./configure && make # faster version using fork server 
```
3. Run multi-task nn module.
```bash
    python ./nn.py ./readelf -a 
```
4. Run fuzzing module.
```bash
    python ./mtfuzz_wrapper.py -i mtfuzz_in -o seeds -l 7406 ./readelf -a @@
```

### Reproducing results
To reproduce our main results reported in paper Table.4, please check source/programs directory.
We also provide an AWS GPU instance for reviewer who didn't have proper GPU resources to test our tool. The instruction to access AWS instance is shared in email.
