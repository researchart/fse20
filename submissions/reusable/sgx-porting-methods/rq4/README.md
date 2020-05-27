# RQ4: Runtime Performance

### Requirements:-

* Intel 6th generation skylake CPU or later which provide support for intel SGX.

* Ubuntu 16.04 

* Linux 4.4.0-169

* 16 GB Ram(Recommended)

### wrk2
[wrk2](https://github.com/giltene/wrk2) is used to measure runtime performance of H2O webserver.

**Install wrk2**
```
git clone https://github.com/giltene/wrk2.git
cd wrk2
make
./wrk --version
```

The numbers reported in Table 9 of papers in row h2o are output of `wrk` corresponding to `Req/Sec` and `Latency`.

### memtier_benchmark
[memtier_benchmark](https://github.com/RedisLabs/memtier_benchmark) is used to measure performance of Memcached.

**Install memtier_benchmark**
```
git clone https://github.com/RedisLabs/memtier_benchmark.git
cd memtier_benchmark
autoreconf -ivf
mkdir build
cd build
../configure
make
./memtier_benchmark --version
```

The numbers reported in Table 9 of paper in memcached row papers are output of `memtier_benchmark` corresponding to `Latency` and `KB/sec`.

## Graphene-SGX

### openssl
```
cd graphene/LibOS/shim/test/programs/openssl
make SGX=1
./pal_loader openssl.manifest.sgx speed md5 des-cbc aes-256-cbc sha256 rsa2048
```
### Python
```
cd graphene/LibOS/shim/test/programs/python
make SGX=1
sh benchmark_python.sh
```

### Memcached
Start Memcached server
```
sudo apt-get install libevent-dev
cd graphene/LibOS/shim/test/programs/memcached
make SGX=1
./pal_loader memcached.manifest.sgx --user=nobody
```

In another terminal window run the benchmark tool
```
./memtier_benchmark -s localhost -p 11211 -P memcache_binary
```
Here `-s` is server address.

### H2O

Start the web server
```
cd graphene/LibOS/shim/test/programs/h2o
make SGX=1
./pal_loader h2o.manifest.sgx -c examples/h2o/h2o.conf
```

In another terminal, run the benchmark tool wrk2
```
cd wrk2
./wrk -t 2 -c 64 -d 30s -R 10000 http://localhost:8888/index.html
./wrk -t 2 -c 64 -d 30s -R 20000 http://localhost:8888/index.html
./wrk -t 2 -c 64 -d 30s -R 30000 http://localhost:8888/index.html
./wrk -t 2 -c 64 -d 30s -R 40000 http://localhost:8888/index.html
```

Here `-t` denotes number of threads and `-c` denotes number  of connections and `-R` denote rate of requests i.e. `Request/sec`.
## Panoply


### openssl
```
cd case-studies/openssl/topenssl
touch Makefile
make
cp *.a ../src
cd ../src
source /opt/intel/panoply/sgxsdk/environment
make
./app md5 des-cbc aes-256-cbc sha256 rsa2048
```

### H2O
Start the web server
```
cd case-studies/h2o/topenssl
touch Makefile
make
cp *.a ../src
cd ../src
source /opt/intel/panoply/sgxsdk/environment
make
./app -c examples/h2o/h2o.conf
```

In other terminal run benchmark tool
```
cd wrk2
./wrk -t 2 -c 64 -d 30s -R 10000 http://localhost:8080/index.html
./wrk -t 2 -c 64 -d 30s -R 20000 http://localhost:8080/index.html
./wrk -t 2 -c 64 -d 30s -R 30000 http://localhost:8080/index.html
./wrk -t 2 -c 64 -d 30s -R 40000 http://localhost:8080/index.html
```


## Porpoise

### Openssl
```
cd porpoise
make openssl
./openssl speed md5 des-cbc aes-256-cbc sha256 rsa2048
```

### Memcached
Start Memcached Server
```
cd porpoise
make memcached
./memcached -p 11211
```

In other terminal start benchmark tool
```
./memtier_benchmark -s localhost -p 11211 -P memcache_binary
```


### H2O
Start H2O server
```
cd porpoise
make h2o
./h2o -c tests/h2o/examples/h2o/h2o.conf
```

In another terminal, run the benchmark tool wrk2
```
cd wrk2
./wrk -t 2 -c 64 -d 30s -R 10000 http://localhost:8888/index.html
./wrk -t 2 -c 64 -d 30s -R 20000 http://localhost:8888/index.html
./wrk -t 2 -c 64 -d 30s -R 30000 http://localhost:8888/index.html
./wrk -t 2 -c 64 -d 30s -R 40000 http://localhost:8888/index.html
```
### Python

```
cd  porpoise
make python
sh benchmark_python.sh
```

