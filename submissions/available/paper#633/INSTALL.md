Compilation instructions
========================
The sources have the following dependencies:

1. Visual Studio 2012

2. MinGW and MSYS (http://www.mingw.org/).
   Please follow the instructions on the MinGW  website to install and setup both tools. Once setup properly, you should be able to run
   the GNU build tool chain from the MSYS shell.

3. CMake

4. Python 3.7 (If use the experiment script).
    Also, modules xlsxwriter, psutil are needed.


   
Compilation:
------------

Note: For a fair comparison, both decision trees (ICE-DT and ours) 
use same compiler (MinGW).

1) Boogie projects: Open the solution file Boogie\Source\Boogie.sln in Visual Studio and compile the sources. A successful build copies all Binaries
into the Boogie\Binaries\ folder.

2) Decision tree in ICE-DT: Go to the C50 directory and build the sources from MSYS shell using the commands

   make clean; make all

   After a successful compilation, copy the files c5.0.dt_penalty and c5.0.dt_entropy into the folder Boogie\Binaries\.

3) Interval decision tree:

    mkdir build;
    cd build;
    cmake -G "Unix Makefiles" ../;
    make;

Run Experiment
---
Please use the script:

1. Check python3 environment with xlsxwriter, psutil modules
2. Check the paths for Boogie, z3 and the decision tree in python script
3. Check the paths to benchmarks in python script
4. python3 RunXXX.py

Additionally, If you want to run a specified case, please go to Boogie binary folder `Boogie/Binaries`, and execute:

```./boogie.exe /nologo /noinfer /contractInfer /mlHoudini:<arg1> /z3exe:<arg2> /mlHoudiniLearnerDir:<arg3> <Path-To-BPL-File>```

In above command: 

1. `<arg1>` includes 2 choose: `dt_penalty` which is the original decision tree learner by ICE-DT (POPL-16) and `IDT4Inv` which is our decision tree prototype to support interval examples.
2. `<arg2>` provides the path of execution binary for z3. If not being provided, it will try to find one replacement in Boogie binary folder.
3. `<arg3>` provides the path of execution binary for decision tree learner. If not being provided, it will try to find one replacement in Boogie binary folder. 
4. `<Path-To-BPL-File>` provides the specified case path which you want to run. 
