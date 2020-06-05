# RQ3: Security Evaluation

We evaluated the amount of trusted code that must execute within the enclave for each of the three frameworks/models. We have used `sloccount` utility to measure the Source Lines Of Code(SLOC).

Install sloccount
```
sudo apt-get install sloccount
```

The numbers reported in `Table 7` are sloccount's output `Total Physical Source Lines of Code (SLOC)`. The numbers may differ slightly due to minor updates. 


## Source Lines of Code for Graphene

Graphene consist of two parts shim layer and glibc. 
```
git clone https://github.com/kripa432/graphene.git
cd graphene
git checkout 99dad080ef77c287e049107f63f14d9605ff7905
make
```
Trusted Code
```
sloccount LibOS/shim/src LibOS/shim/include
sloccount LibOS/glibc-2.27
```

Untrusted Code
```
sloccount Pal/src  Pal/lib
```
## Source Lines of Code for Panoply

```
git clone https://github.com/kripa432/Panoply.git panoply
cd panoply/case-studies/h2o/src
```

Trusted Code
```
cd H2oEnclave
sloccount EnclaveCommunication EnclaveUtil IO LocalAttestationCode Net SysEnvironment Thread TrustedLibrary include
cd ..
```
There are diferent copy of panoply at different locations `panoply/case-studies/openssl/src/`, `panoply/case-studies/freetds/src/` etc. We have reported for one of the copy as the order of amount of code is same.

Untrusted Code
```
sloccount App
```

## Source Lines of Code for Porpoise

```
git clone https://github.com/iisc-cssl/porpoise.git
cd porpoise
```
Trusted Code
```
sloccount enclave/shim_layer/shim_layer.cpp enclave/shim_layer/syscall_wrap.cpp
sloccount enclave/musl
```
Untrusted Code
```
sloccount app/shim_layer
```

## Source Lines of Code for Linux SGX SDK

```
git clone https://github.com/intel/linux-sgx.git
cd linux-sgx
git checkout sgx_2.4
sloccount sdk
```
The amount of source code differs in different releases of SGX SDK. It varies in order of 10,000.
