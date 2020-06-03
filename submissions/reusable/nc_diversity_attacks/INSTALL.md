# INSTALL

## Self-setup

### Pre-requisites
The following steps should be sufficient to get these attacks up and running on most systems running Python 3.7.3+.

```
numpy==1.16.2
pandas==0.24.2
torchvision==0.6.0
torch==1.5.0
tqdm==4.31.1
matplotlib==3.0.3
scipy==1.2.1
```
Note: these are the most recent versions of each library used, lower versions may be acceptable as well. It is also *highly* recommended that you use GPUs to execute the evaluation scripts. If you have access to GPUs, [download](https://pytorch.org/get-started/locally/) the appropriate version of PyTorch for your system instead of using the default above. 

```
pip install -r requirements.txt
```

## VM Instructions

1. [Download](https://www.vmware.com/products/workstation-pro/workstation-pro-evaluation.html) and install VMWare Workstation Pro.
	- NOTE: There is a free trial period so you don't have to pay for anything.
2. Download and unzip the OVF files containing the nc_diversity_attacks VM [here](https://drive.google.com/file/d/15-WtSMWws6x4vAsuACrc-Nq9h2BHraXw/view?usp=sharing)
	- NOTE: The OVF file contains an Ubuntu 20.04 VM and is ~ 8.5GB.
3. Import the VM 
	- Follow instructions [here](https://pubs.vmware.com/workstation-9/index.jsp?topic=%2Fcom.vmware.ws.using.doc%2FGUID-DDCBE9C0-0EC9-4D09-8042-18436DA62F7A.html) or watch YouTube instructions [here](https://youtu.be/WY11A-eyJWY?t=94) (recommended).
4. The password is `password`.
5. Navigate to `home/user/Documents/GitHub/nc_diversity_attacks-master` and open a terminal.
6. Try out one of the evaluation scripts: `python3 _PGD_div_mnist.py`.
	- Observe the growing pickle file in `assets`.
	- NOTE: This VM contains only CPUs. The actual evaluation was run using GPUs on Google Cloud (NVIDIA V100) and on my laptop (GeForce RTX 2060). 