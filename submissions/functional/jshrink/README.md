# JShrink Replication Package

This is a replication package for the experiments reported in our paper,
"JShrink: In-depth Investigation into Debloating Modern Java Applications",
by Bobby R. Bruce, Tianyi Zhang, Jaspreet Arora, Guoqing Harry Xu, and Miryung
Kim (ESEC/FSE 2020).

## JShrink artifact

The artifact can be obtained [here](
https://doi.org/10.6084/m9.figshare.12435542).

JShrink is a tool used to reduce the size of (debloat) Java bytecode. The tool
was primarily developed to test previously discussed Java bytecode debloating
techniques, by incorporating them in a single tool (JShrink) and evaluating
their performance on modern Java applications.

The artifact contains the JShrink code, instructions for complilation, scripts
to replicate experiment execution, and documentation where appropriate.

### Directory structure

Listed below is a summary of the artifact directory structure, highlighting
key files and directories.

* `jshrink` : The JShrink code. Written in Java. Compilable using the Maven
build tool.
* `resources` : Resources used by JShrink.
* `experiment_resources` : The resources used to run experiments, including
the scripts used to replicate experiments.
  * `experiment_resources/README.txt` : Outlines how to replicate the
JShrink experiments.
  * `experiment_resources/replicate_experiments.sh` : The script used to
replicate the JShrink experiments. Please consult
`experiment_resourcse/README.txt` for information on how to correctly run
this script.

### Compiling JShrink

Details on compiling JShrink can be found in the `jshrink/README.md` file.

#### Problems compiling

**Exception in thread "main" java.lang.RuntimeException: Error: cannot find
rt.jar.**: This error typically occurs if you ware not using OpenJDK Java-8.
Please ensure the version of Java being used to run JShrink is correct.

### Executing JShrink

Executing:

```
java -Xmx20g -jar jshrink-app/target/jshrink-app-1.0-SNAPSHOT-jar-with-dependencies.jar
```

will produce the following help message:

```
usage: jdebloat.jar [-a <arg>] [-A] [-b] [-c <arg>] [-C] [-ch <arg>] [-e
       <Exception Message>] [-f <TamiFlex Jar>] [-F] [-h] [-i <arg>] [-I]
       [-jm <JMTrace Home Dir>] [-k] [-l <arg>] [-L <arg>] [-m] [-n <arg>]
       [-o] [-p] [-r] [-s] [-S] [-t <arg>] [-T] [-u] [-v]
An application to get the call-graph analysis of an application and to
wipe unused methods
 -a,--app-classpath <arg>                     Specify the application
                                              classpath
 -A,--use-cache                               Use/create caches (warning:
                                              can be dangerous, use
                                              carefully)
 -b,--ignore-libs                             Only prune the app at the
                                              level of the application.
 -c,--custom-entry <arg>                      Specify custom entry points
                                              in syntax of
                                              '<[classname]:[public?]
                                              [static?] [returnType]
                                              [methodName]([args...?])>'
 -C,--class-collapser                         Collapse classes where
                                              appropriate
 -ch,--checkpoint <arg>                       Create checkpoints and
                                              rollback on test failure.
 -e,--include-exception <Exception Message>   Specify if an exception
                                              message should be included
                                              in a wiped method (Optional
                                              argument: the message)
 -f,--tamiflex <TamiFlex Jar>                 Enable TamiFlex
 -F,--remove-fields                           Remove unused field members
                                              of a class.
 -h,--help                                    Help
 -i,--ignore-classes <arg>                    Specify classes that should
                                              not be delete or modified
 -I,--inline                                  Inline methods that are only
                                              called from one location
 -jm,--jmtrace <JMTrace Home Dir>             Enable JMTrace
 -k,--use-spark                               Use Spark call graph
                                              analysis (Uses CHA by
                                              default)
 -l,--lib-classpath <arg>                     Specify the classpath for
                                              libraries
 -L,--log-directory <arg>                     The directory to store
                                              logging information.
 -m,--main-entry                              Include the main method as
                                              an entry point
 -n,--maven-project <arg>                     Instead of targeting using
                                              lib/app/test classpaths, a
                                              Maven project directory may
                                              be specified
 -o,--remove-classes                          Remove unused classes (only
                                              worked with "remove-methods"
                                              flag)
 -p,--prune-app                               Prune the application
                                              classes as well
 -r,--remove-methods                          Remove methods header and
                                              body (by default, the bodies
                                              are wiped)
 -s,--test-entry                              Include the test methods as
                                              entry points
 -S,--baseline                                Use the baseline version of
                                              JShrink.
 -t,--test-classpath <arg>                    Specify the test classpath
 -T,--run-tests                               Run the project tests.
 -u,--public-entry                            Include public methods as
                                              entry points
 -v,--verbose                                 Verbose output
```

As a minimum, a Java Maven project must be targeted with `--maven-project` and
entry points to the program specified (`--public-entry`, `--test-entry`,
`--main-entry`, `--custom-entry`, or any combination of these). This will
wipe unused method bodies in accordance to a Call Graph Analysis executed
on the specified entry points, and the project's JUnit test suite.

## Reproducing paper experiments

The following two subsections outline how to replicate our experiments both
on an Amazon Web Service, where we ran our experiments, or on your local host
system. We strongly recommend running on Amazon Web Services to replicate
our work.

**These experiments will take multiple days to complete execution. We have
thereby provided a subset of experiments to run using JShrink, which should
complete execution in roughly 30 minutes. See Section "Demo" for more
details.**

### On Amazon Web Service (Recommended).

Our experiments were executed on an Amazon Web Service EC2 instance. Therefore,
to reproduce our experiment results, carry out the following steps:

1. Install vagrant and virtual box :  `apt install vagrant virtualbox`.
2. Copy the `jshrink` directory into
`experiment_resources` : `cp -r jshrink experiment_resources/`.
3. In the file `experiment_resources/Vagrantfile` replace the
`aws.access_key_id`, `aws.keypair_name`, and `override.ssh.private_key_path`
to that of your own AWS account.
4. Execute the following with the `experiment_resources` directory within
`experiment_resources`:
    ```
    vagrant plugin install vagrant-aws
    vagrant box add dummy dummy.box
    vagrant up --provider=aws
    ```
5. Enter the created VM using `vagrant ssh`.
6. Move to the `/vagrant` directory : `cd /vagrant`.
7. Replicate the experiments with `./replicate_experiments.sh`.

### On your local system

While our experiments were executed on an Amazon Web Service EC2 instance, the
experiments can be replicated locally. Though, as this is a different
environment **we cannot guarantee exact replication on a local system, as we
can on an Amazon EC2 instance**. If replication on a local system is desirable,
execute the following steps:

1. Install vagrant and virtual box : `apt install vagrant virtualbox`.
2. Copy the `jshrink` directory into
`experiment_resources` : `cp -r jshrink experiment_resources/`.
3. Overwrite the file `experiment_resources/Vagrantfile_local` with
`experiment_resources/Vagrantfile`
4. Execute `vagrant up` in the `experiment_resources` directory.
5. Enter the created VM using `vagrant ssh`.
6. Move to the `/vagrant` directory : `cd /vagrant`.
7. Replicate the experiments using `./replicate_experiments.sh`.

### Experiment data

The experiment data is output to `experiment_resources/size_data.csv` and
`experiment_resources/output_log`.

## Demo

**Running the full suite of experiments will take several hours to complete
execution. Therefore, as a short demo of JShrink, and the JShrink experiments,
we recommend running our demo script.**

To run our demo script, please follow the above steps for reproducing the
paper's experiments but run
`experiment_resources/replicate_experiments_demo.sh` instead.

This will process the `junit-team_junit4` and `pedrovgs_Alorithms` projects,
using both static and dynamic analysis, applying all transformations in the
tool. **This script takes roughly 30 minutes to run on a standard desktop
setup.**
