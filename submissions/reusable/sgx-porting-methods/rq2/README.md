# RQ2: Application Re-engineering Effort

Re-engineered applicaton are hosted in different gitlab repository

```
git clone https://gitlab.com/kripa432/sample_enclave.git
cd sample_enclave
```

### Application re-engineering for Bzip2
The following command shows the modification in the project for splitting bzip2. The diff shows aproximate changes done to split bzip2.
```
git checkout bzip2_split
git diff 03abf20 5218786
```
The number reported in Table 6 of paper is based on above diff.

### Application re-engineering for OpenSSL
```
git checkout openssl_split
```
File `app/openssl/apps/genrsa.c` Line number 95 is modified and File `app/shim_layer/function_wrapper.cpp` is added to split the openssl genrsa.

### Application re-engineering for Python

The following command show the modifcation done to partition python.

```
git checkout python_split
git diff efdbf8d 282d00a
```
This shows the modification done to split Python at some predefined boundry.
