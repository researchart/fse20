# Installation

## Java
The program requires Java version >= 1.8. To check the Java environment, run the following command:
```
java -version
```

We have tested our program on [Amazon Corretto 8](https://docs.aws.amazon.com/corretto/latest/corretto-8-ug/downloads-list.html):
```
openjdk version "1.8.0_222"
OpenJDK Runtime Environment Corretto-8.222.10.3 (build 1.8.0_222-b10)
OpenJDK 64-Bit Server VM Corretto-8.222.10.3 (build 25.222-b10, mixed mode)
```

## Download Instruction
The latest version of this program can be downloaded from the [GitHub Release](https://github.com/SteveZhangBit/LTSA-Robust/releases) page. Please download the *robustness-calculator.jar* and *models.zip* to complete this instruction.

*robustness-calculator.jar* provides a command-line interface, and *models.zip* includes the models used in the paper.

## Try it out!
Change to the download directory, and run the command:
```
java -jar robustness-calculator.jar -h
```
It should print the following help message:
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