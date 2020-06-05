## Artifact Downloading
The whole artifact could be downloaded from https://doi.org/10.5281/zenodo.3877326 and the github repository https://github.com/xlab-uiuc/cdep-fse.git.

## Building and Running cDep

<div align="left">
  <img src="https://github.com/xlab-uiuc/cdep/blob/master/figure/build.png" width="250">
</div>

### Docker Container Image

We prepare a Docker container image, with which you can directly interact with the pre-built cDep.

The cDep Docker image can be downloaded from: https://hub.docker.com/repository/docker/cdep/cdep/

To run the Docker image, there is one CLI option:

* `-a <arg>`: The supported applications are `hdfs`, `mapreduce`, `yarn`, `hadoop_common`, 
                     `hadoop_tools`, `hbase`, `alluxio`, `zookeeper`, `spark`

One example running command is as follows:
```
$ ./dockerrun.sh -a hdfs,mapreduce
```
Note that multiple applications should be seperated by `,`.

The results will be stored at `/tmp/output/cDep_result.csv`.

**The analysis could take several tens of minutes (so be patient).**

### Build Docker Image Locally

We provide the Dockerfile (under the root directory) as well, with which you could build the docker image locally and run the program.

To build the docker image:
```
$ git clone https://github.com/xlab-uiuc/cdep-fse.git
$ cd cdep
$ docker build -t cdep/cdep:1.0 .
```

Then the running command is same as above. One example running command is:
```
$ ./dockerrun.sh -a hdfs,mapreduce
```

### Building cDep in Your Own Environment

We build cDep using Java(TM) SE Runtime Environment (build 12.0.2+10) and Apache Maven 3.6.1.
We did not guarantee you can build with other Java versions.

First, clone the repository,
```
$ git clone https://github.com/xlab-uiuc/cdep-fse.git
$ cd cdep
```

Second, build cDep (we use Maven as the build tool for cDep)
```
$ mvn compile
```
After compiling, `cDep.class` should be generated at `target/classes/cdep/cDep.class`.

Third, use the script `run.sh`. One example running command is as follows:
```
$ ./run.sh -a hdfs,mapreduce
```

### Output File

The results will be stored at `/tmp/output/cDep_result.csv`.

The `cDep_result.csv` is in the format of:
`["parameter A","parameter B","dependency type","java class","java method","jimple stmt"]`

The output means `parmaeter A` and `parmaeter B` have a `dependency type`. And that dependency relation is identified in the `jimple stmt` of a certain `java method` and `java class`.

The following shows an example of a dependency cDep extracts from MapReduce:

```
(
  'mapreduce.output.fileoutputformat.compress',
  'mapreduce.output.fileoutputformat.compress.type',
  'control dependency',
  'org.apache.hadoop.mapred.MapFileOutputFormat',
  '<org.apache.hadoop.mapred.MapFileOutputFormat:org.apache.hadoop.mapred.RecordWriter getRecordWriter(org.apache.hadoop.fs.FileSystem,org.apache.hadoop.mapred.JobConf,java.lang.String,org.apache.hadoop.util.Progressable)>', 
  'if $z0 == 0 goto $r7 = new org.apache.hadoop.io.MapFile$Writer'
)
```

