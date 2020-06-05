FROM ubuntu:latest

# I - Dependencies
# Two first lines needed for cmake
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt -y update
RUN apt -y upgrade
RUN apt -y install git build-essential cmake python3 ninja-build

# II - Installation
WORKDIR /
RUN git clone https://github.com/llvm/llvm-project
# At the time of this writing, we are at commit: 92063228f85bfe22a6dfe20bf01c99ffe6ff3130

RUN mkdir /llvm-build
WORKDIR /llvm-build
RUN cmake -DLLVM_ENABLE_PROJECTS="clang;compiler-rt" -DLLVM_PARALLEL_LINK_JOBS=1 \
    -G "Ninja" /llvm-project/llvm
RUN cmake --build .
RUN cmake -DCMAKE_INSTALL_PREFIX=/usr/local -P cmake_install.cmake

# III - Prepare example
RUN git clone https://github.com/google/fuzzer-test-suite /fts
RUN mkdir -p /fuzzers/re2-2014-12-09
WORKDIR /fuzzers/re2-2014-12-09
RUN /fts/re2-2014-12-09/build.sh