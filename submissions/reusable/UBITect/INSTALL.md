## Installation:
### Installation with cmake
```sh
    #change to the code folder
    $cd UBITect
    #build LLVM
    $cd llvm
    #build-llvm.sh has "make -j4 " inside, if there's not enough cores, please modify it to "make"
    $./build-llvm.sh
    #build the qualifer inference
    $cd ..
    $make
    #install the dependencies used by KLEE and z3
    $sudo apt-get install build-essential curl libcap-dev git cmake libncurses5-dev python-minimal python-pip unzip libtcmalloc-minimal4 libgoogle-perftools-dev zlib1g-dev
    #build the KLEE
    $cd KLEE
    $./build-klee.sh
    #install python putils
    $pip install psutil
```
Now the ready to use binaries are path/to/UBITect/build/bin/ubitect and path/to/UBITect/KLEE/klee/build/bin/klee
### Installation with Docker
There're some **make -j4** command in the Dockerfile, if there's less than 4 CPU cores avaiable, please change it to **make**
```sh
    #build with Dockerfile
    $docker build --tag ubitect:1.0 .
    #run docker image
    $docker run -it ubitect:1.0 /bin/bash
```
