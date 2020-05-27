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


