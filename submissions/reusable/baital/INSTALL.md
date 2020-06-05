# Baital

## System Requirements

Linux OS with Python 3.6 or higher and pip3. For large benchmarks 12Gb of RAM is required. 

The tool was tested on: Ubuntu 18.10, Python 3.6.9

## Installation

1. Install additional libraries: `graphviz`, `libgmp-dev`, `libmpfr-dev`, and `libmpc-dev`.
    - On Debian-based systems the command is `sudo apt install graphviz libgmp-dev libmpfr-dev libmpc-dev` 
2. `cd src/`
3. Install additional python libraries
    - `pip3 install -r requirements.txt`
4. `chmod u+x bin/d4`

## Quick Installation Testing

The command `python3 baital.py ../benchmarks/axtls.cnf --seed 1` executed from `src` folder shall generate 500 samples for a small benchmark `axtls.cnf`. The following output is expected:
1. The last 2 lines of console output are:
    - Number of combinations 15818
    - Coverage 0.98
2. A folder ../results/ have been created with 4 files: axtls_1.comb, axtls_2.comb, axtls.samples, axtls.samples.txt  
    
    



