Contact information:
====================
Please contact Pranav Garg (garg11@illinois.edu) or Daniel Neider (neider@automata.rwth-aachen.de) if you have any questions.


General Information:
====================
This artefact contains: 
* all benchmarks (both Boogie and C variants) we report in the paper, 
* sources and precompiled binaries for ICE-CS and ICE-DT-* tools, and
* instructions for downloading CPAchecker and running it.
We do not provide sources or binaries for Randomized search based tool for invariant synthesis [53] since it is not otherwise 
freely available.

Our tool requires Microsoft Windows (we tested it on Windows 7 and Windows 10). Since it uses Microsoft Boogie, it also
requires appropriate C# runtime libraries. However, Visual Studio 2012 and later, which is required to compile the sources,
will provide appropriate runtime libraries.


Instructions for running ICE-CS, ICE-DT-entropy and ICE-DT-penalty tools and reproducing their results in Table 1:
==================================================================================================================
We provide precompiled binaries, which are located in the Boogie\Binaries-full directory. The following instructions assume that
the user is using a Microsoft Windows command shell. The ICE-* tools can be invoked by executing the following commands:

* ICE-CS:
    Boogie\Binaries-full> Boogie.exe /nologo /noinfer /contractInfer /ice /printAssignment /trace <.bpl file>

* ICE-DT-entropy:
    Boogie\Binaries-full> Boogie.exe /nologo /noinfer /contractInfer /mlHoudini:dt_entropy /printAssignment /trace <.bpl file>

* ICE-DT-penalty:
    Boogie\Binaries-full> Boogie.exe /nologo /noinfer /contractInfer /mlHoudini:dt_penalty /printAssignment /trace <.bpl file>


Note that /printAssignment and /trace option is for interactive runs and might cause a significant slowdown.

All benchmarks used for the experiments are contained in the benchmarks directory. As an example, to generate results for ICE-DT-penalty
for the program array.bpl, the user runs the following command:

    Boogie\Binaries-full> Boogie.exe /nologo /noinfer /contractInfer /mlHoudini:dt_penalty /printAssignment /trace ..\..\benchmarks\array.bpl

Note that the tool assumes that the command is executed from the Binaries-full directory. Moreover, if you run our tool from MSYS
(see below), remember that options need to be indicated by a dash "-" (without quotes) like in Linux environments instead of a
forward slash "/".

The user might need to first unblock popl16ae.zip file before extracting its contents. If this is not done, the binaries might give a 
security warning on Windows. In case, there are problems with precompiled binaries and they do not work on the user's platform, we are 
providing the sources for our tool and instructions to build them.


Compilation instructions
========================
The sources have the following dependencies:

1. Visual Studio 2012

2. MinGW and MSYS (http://www.mingw.org/).
   Please follow the instructions on the MinGW  website to install and setup both tools. Once setup properly, you should be able to run
   the GNU build tool chain from the MSYS shell.

3. Python
   We have tested our scripts on version 2.7.10. You might also need to install the python module psutil. It can be downloaded for the
   appropriate Python version from https://pypi.python.org/pypi/psutil#downloads

   
Compilation:
------------

1) Open the solution file Boogie\Source\Boogie.sln in Visual Studio and compile the sources. A successful build copies all Binaries
into the Boogie\Binaries\ folder.

2) Go to the C50 directory and build the sources from MSYS shell using the commands

   make clean; make all

   After a successful compilation, copy the files c5.0.dt_penalty and c5.0.dt_entropy into the folder Boogie\Binaries\.

Now ICE-* tools should be ready to run from the Boogie\Binaries directory in the same manner as above.


Regenerating columns for ICE-DT-* in Table 1
============================================
From Boogie\Binaries-full or Boogie\Binaries directory, if you execute the following command:

cmd> python run.py <mode>

where mode = dt_penalty or dt_entropy, the script will run the corresponding ICE-DT tool on all benchmarks and generate the statistics reported in 
Table 1 in a comma-separated file results.mode.txt, i.e., results.dt_entropy.txt or results.dt_penalty.txt


Instructions for running CPAchecker:
====================================
Download the latest version of CPAchecker-- version 1.4 from http://cpachecker.sosy-lab.org/download.php. We compiled the sources on a Linux platform.
But windows binaries are also available on the CPAchecker website. The benchmarks\ directory contains, along with the .bpl files, corresponding C files
for various programs. CPAchecker can be run on the C programs using the following command:

bash$ time ./scripts/cpa.sh -config config/predicateAnalysis-ImpactRefiner-ABEl.properties <.c program> 