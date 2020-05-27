#!/bin/sh
sudo apt-get install -y build-essential autoconf gawk bison libevent-dev libffi6 libffi-dev bzip2
sudo apt-get install -y libprotobuf-c-dev protobuf-c-compiler
sudo apt install python3-pip -y
python3 -m pip install python3-protobuf --user
python3 -m pip install protobuf --user
sudo apt-get install -y python3-pytest
sudo apt-get install libnss-mdns -y

git clone https://github.com/kripa432/graphene.git
cd graphene

git submodule update --init -- Pal/src/host/Linux-SGX/sgx-driver/
openssl genrsa -3 -out enclave-key.pem 3072
mv enclave-key.pem Pal/src/host/Linux-SGX/signer/enclave-key.pem
( cd Pal/src/host/Linux-SGX/sgx-driver; \
printf "sgx-driver\ny\n2.6\n" | make; \
make; \
sudo ./load.sh; \
sudo sysctl vm.mmap_min_addr=0 )
#cd ../../../../..
echo "make"
echo $PWD
sleep 10
make clean

make

make SGX=1
