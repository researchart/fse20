# RQ1: Porting Application

To run application with respective model, issue the commands from respective root folder of model

## Porting application with graphene

### Openssl
```
cd graphene/LibOS/shim/test/programs/version
make SGX=1
./pal_loader openssl.manifest.sgx version

```

### Python
```
cd graphene/LibOS/shim/test/programs/python
make SGX=1
./pal_loader python.manifest.sgx --version
```

### H2O
```
cd graphene/LibOS/shim/test/programs/h2o
make SGX=1
./pal_loader h2o.manifest.sgx --version
```

### Memcached
```
cd graphene/LibOS/shim/test/programs/memcached
make SGX=1
./pal_loader memcached.manifest.sgx -u nobody --version
```

## Porting Applications with Panoply


### Openssl

```
cd panoply/case-studies/openssl/topenssl
touch Makefile
make
cp *.a ../src
cd ../src
source /opt/intel/panoply/sgxsdk
make
./app sha1
```

### H2O

```
cd panoply/case-studies/h2o/src
source /opt/intel/panoply/sgxsdk
make
./app -c h2o.conf
```
Visit [http://localhost:8888](http://localhost:8888)

## Porting Applications with Porpoise
```
cd porpoise
source /opt/intel/porpoise/sgxsdk/environment
make h2o memcached python openssl
./openssl version
./python --version
./memcached --version
./h2o --version
```
