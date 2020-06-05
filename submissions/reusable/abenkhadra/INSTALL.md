
## Experimental environment

The following installation instructions are known to work on Ubuntu 18.04.
We only assume the availability of standard build tools. They can be
installed using the following command,

```bash
sudo apt install build-essential cmake git
```

## Installation

In order to install our tool and its dependencies. You can simply issue:

```bash
git clone https://github.com/abenkhadra/bcov-artifacts
cd bcov-artifacts
bash install.sh
```

The installation script will download and build our tool, `bcov`, together
with its dependencies in the subfolder `packages`. Then, it will install the
the binaries in the subfolder `local`. This means that you should find the
tool in `./local/bin/bcov` and the run-time library in `./local/lib/libbcov-rt.so`.

## Experiment

The subfolder `./sample-binaries` contains original binaries compiled with
`gcc-7.4` in a release build, and a patched version of each binary. In the
following experiment we will:

 - patch the binaries again using the any-node policy.
 - Run a patched perl binary to collect coverage data.
 - Report the coverage of the previous perl execution.

To run this experiment, simply issue the following command,

```bash
bash experiment-01.sh
```

This command assumes the you are still in the `bcov-artifacts` directory.
