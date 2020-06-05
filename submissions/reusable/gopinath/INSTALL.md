# INSTALLATION

We assume that you have downloaded the
[mimid.box](https://drive.google.com/open?id=1-v4v6Sz4IB-xpF9tmz1TaqMUPkP-2Fs7)
as described in the README.md

This file is a very basic set of installation instructions. For detailed
information, refer to README.md

First, verify the downloaded box.

```bash
$ du -ksh mimid.box
2.6G mimid.box
```

The _md5_ checksum.

```bash
2bd3966d24ea01c9cbea44d2797c20b3  mimid.box
```

The installation requires [VirtualBox](https://www.virtualbox.org/) and [Vagrant](https://www.vagrantup.com/)
installed. Further, all tests were conducted on a 16GB RAM base box, and the
host needs atleast 10GB RAM. Further, the port `8888` in the host should be
free as it is forwarded from the guest VM.

The downloaded box can be imported as follows:

```bash
$ vagrant box add mimid ./mimid.box
$ vagrant init mimid
$ vagrant up
```

You can verify the box import by the following command, which gets you a shell
in the VM

```bash
vagrant ssh
```

Once in the VM, verify the box as follows 

```bash
vm$ pwd
/home/vagrant
vm$ free -g
              total        used        free      shared  buff/cache   available
Mem:              9           0           9           0           0           9
Swap:             1           0           1
```

It contains the following files

```bash
vm$ ls
mimid
c_tables.sh
py_tables.sh
start_c_tests.sh
start_py_tests.sh
startjupyter.sh
taints
toolchains
```

You can verify the completeness of the installation by invoking Jupyter viewer

```bash
vm$ ./startjupyter.sh
...
     or http://127.0.0.1:8888/?token=ba5e5c480fe4a03d56c358b4a10d7172d2b19ff4537be55e
```

Copy and paste the last line to your host browser to view the Jupyter notebook
