The JShrink artifact can be obtained [here](
https://doi.org/10.6084/m9.figshare.12435542).

## Prerequisites

JShrink requires the following dependencies to be installed:

* OpenJDK-8
* The Maven build tool
* Make
* GCC

For operating systems utilizing the APT build system:

```
sudo apt install openjdk-8-jdk maven gcc make
```

## Compiling JShrink

Details on compiling JShrink can be found in the `jshrink/README.txt` file.
For most cases the following steps will be sufficient:

1. Navigate to the `jshrink` directory: `cd jshrink`.
2. Compile jshrink using mvn: `mvn compile -pl jshrink-app -am`

The resulting jar can be found in
`jshrink-app/target/jshrink-app-1.0-SHAPSHOT-jar-with-dependencies.jar`.

## Executing JShrink

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
on the specified entry points, and the projects JUnit test suite.

## Troubleshooting

**Exception in thread "main" java.lang.RuntimeException: Error: cannot find
rt.jar.**: This error typically occurs if you ware not using OpenJDK Java-8.
Please ensure the version of Java being used to run JShrink is correct.

### When in doubt, use Vagrant

If problems are encountered when compiling JShrink, we advise utilizing our
Vagrant VM which will provide a stable, proven, environment for execution:

1. Install Vagrant (via APT: `apt install vagrant virtualbox`).
2. Copy the `experiment_resources/Vagrantfile_local` file to
`jshrink/Vagrantfile`
3. Execute `vagrant up`.
4. SSH into the VM: `vagrant ssh`.
5. Move to the `/vagrant` directory: `/vagrant`.
6. Compile JShrink using `mvn compile -pl jshrink-app  -am`.
