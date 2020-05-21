# Robustness Calculator
This is a prototype implementation for the work *A Behavioral Notion of Robustness for Software Systems* which will appear in FSE 2020. We propose a behavioral notion of software robustness based on labelled transition systems (LTS).

This program takes a system specification *S*, an environment specification *E*, and a safety property *P*, and computes the robustness of the system against the environment *E* and property *P*. This program can also compare the robustness between two designs of a system or the robustness of a system under two properties.

By default, all the specifications should be specified in FSP, the modelling language used by [the LTSA tool](https://www.doc.ic.ac.uk/ltsa/). In addition, the program accepts environment models defined in the Enhanced Operator Function Model ([EOFM](http://fhsl.eng.buffalo.edu/EOFM/)), which is a specification language for modeling human tasks.

## Download Instruction
The latest version of this program can be downloaded from the [GitHub Release](https://github.com/SteveZhangBit/LTSA-Robust/releases) page. Please download the *robustness-calculator.jar* and *models.zip* to complete this instruction.

*robustness-calculator.jar* provides a command-line interface, and *models.zip* includes the models used in the paper.

## Reproduce the results in the paper
### System Requirements
This program requires Java version >= 1.8. The program has been tested under
```
openjdk version "1.8.0_222"
OpenJDK Runtime Environment Corretto-8.222.10.3 (build 1.8.0_222-b10)
OpenJDK 64-Bit Server VM Corretto-8.222.10.3 (build 25.222-b10, mixed mode)
```

After downloading *robustness-calculator.jar* and *models.zip*, change to the download directory, unzip *models.zip*, the download directory should be like:
```
<download directory>
|-- robustness-calculator.jar
|-- models
|   |-- abp
|   |-- coffee
|   |-- theract25
```

Type ```java -jar robustness-calculator.jar -h```, it prints the following help message:
```
usage: [-h] [-v] --compute FILES...


This program calculates the behavioral robustness of a system against a base
environment E and a safety property P. Also, it takes a deviation model D to
generate explanations for the system robustness. In addition, it can compare the
robustness of two systems or a system under different properties.


required arguments:
  --compute,   operation mode
  --compare


optional arguments:
  -h, --help   show this help message and exit

  -v,          enable verbose mode
  --verbose


positional arguments:
  FILES        system description files in JSON

```

**Now, the program is ready to go!**

### Network Protocol Case Study
#### Compute Robustness of the Perfect Channel
```
$ java -jar robustness-calculator.jar --compute models/abp/perfect_channel.json
Environment LTS: 9 states and 24 transitions.
System LTS: 20 states and 67 transitions.
Alphabet for weakest assumption: [send[0], getack[0], getack[1], send[1], rec[0], ack[0], ack[1], rec[1]]
Generating the weakest assumption...
Generating the representation traces...
Number of equivalence classes: 4
Class EquivClass(s=1, a=rec[0]):
        [send[1], rec[0]]
Class EquivClass(s=3, a=getack[0]):
        [send[1], rec[1], ack[1], getack[0]]
Class EquivClass(s=4, a=getack[1]):
        [send[1], rec[1], ack[0], getack[1]]
Class EquivClass(s=5, a=rec[1]):
        [send[0], rec[1]]

Generating the explanations for the representation traces...
Found 4 traces, matched 4/4.
Group by error types:
Group: trans.corrupt, Number of traces: 2
Group: ack.corrupt, Number of traces: 2
```

In ```verbose``` mode, the program will also print the explanation for each representation trace, e.g.,
```
$ java -jar robustness-calculator.jar --compute models/abp/perfect_channel.json -v

...

Generating the explanations for the representation traces...
Matching the representative trace '[send[1], rec[0]]' to the erroneous environment model...
        input
        send[1]
        trans.corrupt
        rec[0]

...
```

#### Compute Robustness of the ABP protocol
```
$ java -jar robustness-calculator.jar --compute models/abp/abp.json
Environment LTS: 9 states and 24 transitions.
System LTS: 30 states and 104 transitions.
Alphabet for weakest assumption: [send[0], getack[0], getack[1], send[1], rec[0], ack[0], rec[1], ack[1]]
Generating the weakest assumption...
Generating the representation traces...
Number of equivalence classes: 107
Class EquivClass(s=0, a=getack[1]):
        [getack[1]]
Class EquivClass(s=1, a=send[0]):
        [send[0], send[0]]

...

Generating the explanations for the representation traces...
Found 107 traces, matched 99/107.
Group by error types:
Group: Unexplained, Number of traces: 8
Group: trans.lose, Number of traces: 23
Group: trans.duplicate, Number of traces: 18
Group: ack.lose, Number of traces: 22
Group: ack.corrupt, Number of traces: 8
Group: ack.duplicate, Number of traces: 14
Group: trans.duplicate,trans.corrupt, Number of traces: 4
Group: trans.corrupt, Number of traces: 8
Group: ack.duplicate,ack.corrupt, Number of traces: 2
```

### Radiation Therapy System
#### Compare Robustness of two designs
```
$ java -jar robustness-calculator.jar --compare models/therac25/therac_robust.json models/therac25/therac.json

...

Generating the representation traces...
Number of equivalence classes: 3
Class EquivClass(s=7, a=hPressB):
        [hPressE, hPressUp, hPressX, hPressEnter, hPressB, hPressB]
Class EquivClass(s=7, a=hPressUp1):
        [hPressE, hPressUp, hPressX, hPressEnter, hPressB, hPressUp1]
Class EquivClass(s=10, a=hPressB):
        [hPressX, hPressUp, hPressE, hPressEnter, hPressB]
```

The program generates three representation traces indicating that the new design is more robust than the old design.

#### Compare Robustness Under Two Properties
```
$ java -jar robustness-calculator.jar --compare models/therac25/therac.json models/therac25/therac_strong_p.json

...

Generating the representation traces...
Number of equivalence classes: 1
Class EquivClass(s=6, a=hPressB):
        [hPressE, hPressUp, hPressX, hPressEnter, hPressB]
```

The program generates one representation trace indicating that the system is considered to be less robust under the stronger property.

## System Description File
In the above examples, the program takes one or more system description files (JSON files) as inputs. This section describes how to define such description files.

A description file is a JSON file in the following format, (e.g., the description for the ABP protocol):
```
{
  "mode": "fsp",                    // should be either "fsp" or "eofm"
  "sys": "models/abp/abp.lts",      // the path to the system model specification
  "env": "models/abp/abp_env.lts",  // the path to the environment model specification
  "prop": "models/abp/p.lts",       // the path to the property model specification
  "deviation": "models/abp/abp_env_lossy.lts" // the path to the deviation model specification. In the "eofm" mode, the deviation model is not required.
}
```

In the *eofm* mode, we need additional descriptions for translating a EOFM model to a LTSA model (however, this is not described in the paper due to the page limit):
```
{
  "mode": "eofm",                     // should be either "fsp" or "eofm"
  "sys": "models/therac25/sys.lts",   // the path to the system model specification
  "env": "models/therac25/therac25_nowait.xml", // the path to the environment model specification in EOFM (a XML file)
  "prop": "models/therac25/p_w.lts",  // the path to the property model specification
  "eofm": {                           // additional description for translating EOFM to LTSA
    "initialValues": {
      "iInterface": "Edit",
      ...
    },
    "world": [
      "when (iInterface == Edit) hPressX -> VAR[ConfirmXray][InPlace][iPowerLevel]",
      ...
    ],
    "relabels": {}
  }
}
```

## Assumptions on the [LTSA](https://www.doc.ic.ac.uk/~jnm/book/) specifications
As a prototype implementation, the program carries the following assumptions:
- The system specification needs to be a process named *SYS*.
- The environment specification needs to be a process named *ENV*.
- The property specification needs to be a process named *P*.
- The constants defined in different specifications need to be distinct.
- The deviation environment specification needs to be a process named *ENV*.
- The deviation environment specification needs to define a menu named *ERR_ACTS* to indicate the error actions in the environment.

## Build instruction

### Import project to IntelliJ IDEA
Import Project -> Select 'LTSA-Robust/robustness-calculator' -> Import project from external model 'Maven' -> Finish

### Add ltsa.jar to project path
File -> Project Structure -> Libraries -> Select '+' and Java -> Select the 'ltsa.jar' -> OK

### Build project!
