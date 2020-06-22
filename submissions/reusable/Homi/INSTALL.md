# Installation

We provide a full VirtualBox image to install HOMI. This image contains 9 benchmark programs, dependencies, and  symbolic executor, KLEE, for comparison as well as our tool, HOMI. 



## Installing a Virtual Machine Image

1. Download and install Oracle VM VirtualBox at [here](https://www.virtualbox.org/wiki/Downloads)
2. Download the VM image: [FSE20_HOMI_artifacts.tar.gz](https://drive.google.com/file/d/1ukvyUtVLJ0ie9knvsJKTe0Ww4K6U92H_/view?usp=sharing) 
3. Install the `.vdi` file with VirtualBox.

*NOTE:*

- The size of the VM image: The size is about 3GB. When decompressing it, you obtain about 20GB `.vdi` file.
- **The experiement setting: In our paper, we conducted all experiments on a Linux machine equipped with two Intel Xeon Processors E5-2630 and 192GB RAM, where it has a total of 16 cores and 32 threads.** 
Therefore, when running Homi by using the virtualbox with the different settings, it may differ from the experimental results on our paper. We recommand to run Homi with **the VM image having 16GB RAM and four virtual processors**.
