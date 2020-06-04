### Install prerequisite
- Make sure your system has python 3.7
- Install tensorflow-gpu 1.15. Note that you need to install proper CUDA, CuDNN before installing tensorflow-gpu.
- Install Keras 2.24
- Install LLVM 7.0.0

### Build MTFuzz
```bash
    cd source
    ./build.sh  # build llvm coverage passes and CMP passes.
```

### Run MTFuzz
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
4. Open a terminal to start NN module.
```bash  
    python nn.py ./size 
```
5. Open another terminal to start fuzzing module.
```bash
    # -l, file len is obtained by maximum file lens in the mtfuzz_in ( ls -lS mtfuzz_in|head )
    python ./mtfuzz_wrapper.py -i mtfuzz_in -o seeds -l 7402 ./size @@
```
The initial data processing will take around 5-10 minutes. If you see the following log in NN module terminal and fuzzing module terminal, then MTFuzz is running correctly.

### Run MTFuzz on your own tested programs
We demonstrate how to set up MTFuzz on your own tested programs with a xml parser expat.
1. Unzip expat source code and move into expat root directory
```bash
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
