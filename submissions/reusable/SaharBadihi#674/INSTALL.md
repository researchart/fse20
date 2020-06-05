
## Installing
Java Runtime Environment version 8 is required. If using JDK 8, you might need to copy tools.jar from jdk_1.8../lib to jdk_1.8../jre/lib if absent.

Clone the repository:
````yaml
git clone https://github.com/shrBadihi/ARDiff_Equiv_Checking.git
````

ARDiff has dependencies on JPF-core, JPF-Symbc Z3-solver. We included all dependencies in the tool. 

### JPF
Pre-built versions of [JPF-Symbc](https://github.com/SymbolicPathFinder/jpf-symbc). and [JPF-core](https://https://github.com/javapathfinder/jpf-core) are included in the project under the folder jpf-git.

You need to create in your home directory a .jpf directory and include inside a file name "site.properties" with the following content:
````yaml
jpf-core = ${user.home}/.../path-to-ARDiff_Equiv_Checking-folder/Implementation/jpf-git/jpf-core
jpf-symbc = ${user.home}/.../path-to-ARDiff_Equiv_Checking-folder/Implementation/jpf-git/jpf-symbc
extensions = ${jpf-core},${jpf-symbc}
````

### Z3
For checking the equivalence of symbolic summaries, the Z3 constraint solver is used. 

The Z3 library files needed by JPF-symbc for Unix and Windows are provided in our Implementation directory (under jpf-git/jpf-symbc/lib) and must be included in the PATH (Windows) or LD_LIBRARY_PATH (Linux) or DYLD_LIBRARY_PATH (OSX) environnment variable. For example:

````yaml
LD_LIBRARY_PATH="/.../path-to-ARDiff_Equiv_Checking-folder/jpf-git/jpf-symbc/lib"
````

You can refer to [Z3](https://github.com/Z3Prover/z3) for more information or to build Z3 yourself.

## Setup

The .jar file running the framework is provided in:
```yaml
/.../path-to-ARDiff_Equiv_Checking-folder/Implementation/target/artifacts/Implementation_jar/Implementation.jar
```

The project can also be open as a Maven project in an IDE in order to change/update the source code. The main class is Runner.Runner

## Usage
You should run the tool from the ARDiff_Equiv_Checking/Implementation folder:
```yaml
cd /.../path-to-ARDiff_Equiv_Checking-folder/Implementation/

java -jar target/artifacts/Implementation_jar/Implementation.jar --path1 path/to/the/first/method --path2 path/to/the/second/method --tool ToolName --t timeout --bound LoopBoundLimit --minint Integer --maxint Integer --mindouble Double --maxdouble Double
```
For OSX/Linux users, if you are running into some issues indicating "no libz3java in java.library.path", 
try adding Z3 directory ("jpf-git/jpf-symbc/lib") to "java.library.path":

```yaml
java -Djava.library.path=jpf-git/jpf-symbc/lib -jar target/artifacts/Implementation_jar/Implementation.jar --path1 path/to/the/first/method --path2 path/to/the/second/method --tool ToolName --t timeout --bound LoopBoundLimit --minint Integer --maxint Integer --mindouble Double --maxdouble Double
```

There are 9 arguments for configuring the framework: --path1 and --path2 are mandatory and the other eight are optional. 

You need to give the paths to two (compilable) Java classes (with different names), each containing one of the target methods.

Note that the signature (i.e the name and the input parameters) and the return type must be the same for the two methods.

If the classes contain more than one method, the first method is considered as the target method for equivalence checking. 

The final result and time are shown in the terminal. Extra information from running the tools will be stored in the directory of --path1.

You can also choose the tool, the bound limit to unroll loops in JPF-symbc and min and max values for integers and doubles. 

You can also choose the timeout in milliseconds. This timeout is for constraint solving in both JPF-symbc and Z3, it is not an overall timeout for the tool. 

If you want to stop the tool after t seconds, for example 5, you can use any timeout mechanism.
On Linux or OSX for instance, the Linux timeout command:  

```yaml
timeout 5 java -jar target/artifacts/Implementation_jar/Implementation.jar --path1 path/to/the/first/method --path2 path/to/the/second/method --tool ToolName  --t timeout --bound LoopBoundLimit --minint Integer --maxint Integer --mindouble Double --maxdouble Double
```
You might need to install first "coreutils". 

For  OSX users :
```yaml
brew install coreutils
```

For  Linux users :
```yaml
apt-get install coreutils
```

On Windows, you can use the  START-TIMEOUT builtins combination or other timeout tools, for example [this one](https://github.com/pshved/timeout).


To obtain the overall time taken by the tool, in addition to the detailed times (in milisecond) we provide, you can also use timing mechanisms such as the Linux time command which gives you the CPU runtime of the process:
```yaml
time java -jar target/artifacts/Implementation_jar/Implementation.jar --path1 path/to/the/first/method --path2 path/to/the/second/method --tool ToolName  --t timeout --bound LoopBoundLimit --minint Integer --maxint Integer --mindouble Double --maxdouble Double
```

## Example
![](/img/eg.png)

## Benchmark 
You can find our dataset here:
```yaml
/.../path-to-ARDiff_Equiv_Checking-folder/benchmarks/
```
## Running ARDiff on Our Benchmark
You can run each pair of methods in the benchmark individually (as described above) or run all of them in sequence by running the script we provided.

There are three scripts for running the tool on the benchmark, one for each operating system.
For example, the following script is for Linux users:
```yaml
cd /.../path-to-ARDiff_Equiv_Checking-folder/Implementation/
sh RunningBenchmarksOnLinux.sh
```
OSX and Windows users should use RunningBenchmarksOnMac.sh and RunningBenchmarksOnWindows.bat, respectively.

The script runs DSE, IMP-S, and ARDiff on each Equivalent and Non-Equivalent pairs of methods for each benchmark. 