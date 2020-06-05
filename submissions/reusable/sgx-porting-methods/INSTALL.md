# Installation

## Requirements:-
* Ubuntu 16.04 LTS Desktop 64bits
* Intel 6th generation or Later CPU which support Intel SGX
* Linux kernel 4.4.0-169 

# Install Linux SGX Driver
Install linux SGX driver 2.5
[https://github.com/intel/linux-sgx-driver/tree/sgx_driver_2.5](https://github.com/intel/linux-sgx-driver/tree/sgx_driver_2.5)

Execute the script `install_linux_sgx_driver.sh` which clone the github repository of linux sgx driver into `linux-sgx-driver` and checkout to version `sgx_driver_2.5` and build and install the driver.
```
sh install_linux_sgx_driver.sh
```
If the above script fails, execute the following commands:-

```
git clone https://github.com/intel/linux-sgx-driver.git
git checkout sgx_driver_2.5
sudo apt-get install linux-headers-$(uname -r)
make
sudo mkdir -p "/lib/modules/"`uname -r`"/kernel/drivers/intel/sgx"
sudo cp isgx.ko "/lib/modules/"`uname -r`"/kernel/drivers/intel/sgx"
sudo sh -c "cat /etc/modules | grep -Fxq isgx || echo isgx >> /etc/modules"
sudo /sbin/depmod
sudo /sbin/modprobe isgx
```

## Install Linux SGX SDK
Install Linux 2.4 Open Source Gold Release
[https://github.com/intel/linux-sgx/tree/sgx_2.4](https://github.com/intel/linux-sgx/tree/sgx_2.4)

Run the following script for installing Linux SGX SDK. It will ask for super user password to install dependencies.
```
sh install_linux_sgx.sh
```

If the script fails execute the following commands:-
```
wget https://github.com/intel/linux-sgx/archive/sgx_2.4.tar.gz
mkdir -p linux-sgx
tar -xvf sgx_2.4.tar.gz -C linux-sgx --strip 1

cd linux-sgx
./download_prebuilt.sh

sudo apt-get install build-essential ocaml automake autoconf libtool wget python libssl-dev -y
sudo apt-get install libssl-dev libcurl4-openssl-dev protobuf-compiler libprotobuf-dev debhelper cmake -y
sudo apt-get install libssl-dev libcurl4-openssl-dev libprotobuf-dev -y
sudo apt-get install build-essential python -y
sudo apt-get install libnss-mdns -y

make sdk
make sdk_install_pkg
./linux/installer/bin/sgx_linux_x64_sdk_*.bin #it will ask for location, accept default by typing "yes" and hit enter when ask for directory name.
make psw
make psw_install_pkg
./linux/installer/bin/sgx_linux_x64_psw_*.bin

```

## Install Porpoise

Execute the script `install_porpise.sh` which clones the project repository and build the build.

```
sh install_porpoise.sh
```
If the above command fails, execute the following commands:-

```
$ git clone https://github.com/iisc-cssl/porpoise.git
$ cd porpoise
$ sh build.sh
$ make all
$ make test
```


## Install Panoply

Execute the scipt `isntall_panoply.sh` which clone the project repository and build the customSDK
```
sh install_panoply.sh
```
If above commands fails, execute the following commands:-
```
git clone https://github.com/kripa432/Panoply.git panoply
cd panoply
git clone https://github.com/intel/linux-sgx.git
cd linux-sgx
git checkout sgx_2.0
make sdk
make sdk_install_pkg
printf "no\n/opt/intel/panoply\n\n" | sudo ./linux/installer/bin/sgx_linux_x64_sdk_*.bin
cd ..
sudo cp sgx_status.h /opt/intel/sgxsdk/include
```

# Install Graphene-SGX
Install Graphene-SGX v1.0.1
[https://github.com/oscarlab/graphene/tree/v1.0.1](https://github.com/oscarlab/graphene/tree/v1.0.1)

Execute the script `isntall_graphene.sh` which clone the project repository, install dependencies, install graphene driver and build the project.

```
sh install_graphene.sh
```
If the above command fails, execute the following commands:-

Install dependencies of graphene
```
sudo apt-get install -y build-essential autoconf gawk bison
sudo apt-get install -y python3-protobuf libprotobuf-c-dev protobuf-c-compiler
sudo apt-get install -y python3-pytest
```

Get the source code of graphene
```
git clone https://github.com/kripa432/graphene.git
```

Build the graphene-driver
```
git submodule update --init -- Pal/src/host/Linux-SGX/sgx-driver/
make
openssl genrsa -3 -out enclave-key.pem 3072
mv enclave-key.pem Pal/src/host/Linux-SGX/signer/enclave-key.pem
cd Pal/src/host/Linux-SGX/sgx-driver
printf "linux-driver\ny\n2.6\n" | make
# The console will be prompted to ask for the path of Intel SGX driver codesudo ./load.sh
sudo sysctl vm.mmap_min_addr = 0
```

Build graphene, by running following command in root directory
```
cd graphene
make clean
make
make SGX=1
```
