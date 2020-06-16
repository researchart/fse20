
[![DOI](https://zenodo.org/badge/266739012.svg)](https://zenodo.org/badge/latestdoi/266739012)

# Artifact evaluation of 'An Evaluation of Methods to Port Legacy Code to SGX Enclaves'

This repository contains the supporting artifacts for the paper "**An Evaluation of Methods to Port Legacy Code to SGX Enclaves**," (by Kripa Shanker, Arun Joseph, and Vinod Ganapathy), published in Proceedings of ESEC/FSE'20, the 28th ACM Joint European Software Engineering Conference and Symposium on the Foundations of Software Engineering, Sacramento, California, USA, November 2020.

This work depends on three projects Graphene-SGX, Panoply and Porpoise. [Graphene-SGX](https://github.com/oscarlab/graphene) and [Panoply](https://github.com/shwetasshinde24/Panoply) is work of their respective authors.

We have built Porpoise from scratch (since SCONE is not available publicly) and made the source code available at Public repository on Github [https://github.com/iisc-cssl/porpoise](https://github.com/iisc-cssl/porpoise). It is published under GNU General Public License, version 2.

Requirements:-

* Intel 6th generation skylake CPU or later which provide support for intel SGX.

* Ubuntu 16.04 

* Linux 4.4.0-169

* 16 GB Ram(Recommended)

Note:-
* SGX needs to be enabled from bios. 
* It doesn't run on virtual machine.

For installation please refer [INSTALL.md](INSTALL.md)

Kripa Shanker (corresponding author)  
kripashanker@iisc.ac.in  
Github: [kripa432](https://github.com/kripa432)  

Arun Joseph  
arunj@iisc.ac.in  

Vinod Ganapathy  
vg@iisc.ac.in  
Artifacts are arranged by Research Qestions(RQ) in the paper.

## RQ1: Porting effort
[rq1/README.md](rq1/README.md)

## RQ2: Application Re-engineering Effort
[rq2/README.md](rq2/README.md)

## RQ3: Security Evaluation
[rq3/README.md](rq3/README.md)

## RQ4: Runtime Performance
[rq4/README.md](rq4/README.md)


### Porting new application to Intel SGX with Porpoise.

There are three main steps in porting applications to SGX with Porpoise.

1. Compile the application with position independent code.
2. Compile the dependend libraries with position independend/independent code.
3. Link application with Porpoise.

### Porting libjpeg to Porpoise
In this tutorial we will port libjpeg to Intel SGX using Porpoise

1. Obtain the source code of libpeg into `porpoise/enclave/libjpeg` folder.
```
cd porpoise/enclave
mkdir libjpeg
cd libjpeg
wget http://www.ijg.org/files/jpegsrc.v6b.tar.gz
tar -xvf jpegsrc.v6b.tar.gz --strip 1
```
2. Compile libjpeg
```
mkdir build
cd build
../configure CFLAGS="-fPIC"
make cjpeg
./cjpeg -greyscale -dct int -progressive -opt -outfile testoutp.jpg ../testimg.ppm
```
3. Compiling dependencies of libjpeg
```
ldd cjpeg

>	linux-vdso.so.1 =>  (0x00007ffc131e5000)
>       libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fb801dbc000)
>       /lib64/ld-linux-x86-64.so.2 (0x00007fb802186000)
```
cjpeg depends on three shared libraries. Ignore `linux-vdso.so.1` and `ld-linux-x86-64.so.2`. For `libc.so.6`, Porpoise uses musl as libc which is already present in Porpoise at `porpoise/enclave/musl`. For building musl refer to `propoise/enclave/musl/build.sh`.

4. compile Porpoise and link it with cjpeg
	
Create new file Makefile.cjpeg
```
cp Makefile.sample Makefile.cjpeg
```
Update `Makefile.cjpeg` as following
```
application_name := cjpeg
native_application_location := enclave/libjpeg/build
```
 
compile and link Porpoise with cjpeg
```
make -f Makefile.cjpg
./cjpeg -greyscale -dct int -progressive -opt -outfile testoutp.jpg enclave/libjpeg/testimg.ppm
```

### Screencast of porting libjpeg to Intel SGX with porpoise

[![asciicast](https://asciinema.org/a/aa0CqVn4GKz1lPDNjs3WZUvsh.svg)](https://asciinema.org/a/aa0CqVn4GKz1lPDNjs3WZUvsh)

### Here some of the common errors which developers come across when porting an application to Intel SGX with Porpoise.

* undefined reference
```
convert.c:(.text+0x193f): undefined reference to `xstrdup'
```
_solution_: Add the missing library that provide the defination of given symbol.

* multiple reference 
```
enclave/libjpeg/build/djpeg.o: In function `main':
djpeg.c:(.text+0xe9f): multiple definition of `main'
enclave/libjpeg/build/jpegtran.o:jpegtran.c:(.text+0xb66): first defined here
enclave/libjpeg/build/cjpeg.o: In function `main':
cjpeg.c:(.text+0xd0c): multiple definition of `main'
enclave/libjpeg/build/jpegtran.o:jpegtran.c:(.text+0xb66): first defined here
```
_solution_: some time some projects create multiple object files containing the same defination of symbol, especially those build with `libtool` in `.deps` or `.lib` directory. Remove the later object file.

* relocation error; recompile with -fPIC
```
/usr/bin/ld: /usr/lib/gcc/x86_64-linux-gnu/5/../../../x86_64-linux-gnu/libc.a(libc-start.o): relocation R_X86_64_32 against `_dl_starting_up' can not be used when making a shared object; recompile with -fPIC
/usr/lib/gcc/x86_64-linux-gnu/5/../../../x86_64-linux-gnu/libc.a: error adding symbols: Bad value
```
_solution_: compile the depency library with `CFLAGS="-fPIC"` to build position independent code.

Caveat:-
1. Porpoise will work out of the box only for those applications that use the system calls for which we have added support. If it invokes a system call at runtime for which we have not added support, it will not work.
2. Porpoise is build on musl-libc, so if an application uses any symbol from libc which is not present in musl-libc, the application will not link and gives _undefined reference error_
3. Porpoise doesn't support dynamic linking as SGX doesn't support dynamic loading of code.
