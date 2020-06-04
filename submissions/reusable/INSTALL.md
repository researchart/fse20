# Installation instructions

## Overview
The installation instructions of Java Ranger are the same as those used for installing [Symbolic PathFinder](https://github.com/SymbolicPathFinder/jpf-symbc). 

## Detailed instructions
These instructions have been tested on the Ubuntu 16.04 and Ubuntu 18.04 operating systems.
1. Install the openjdk-8-jdk package
  - sudo apt install openjdk-8-jdk
2. Install ant
  - sudo apt install ant
3. Install Git, if on a new machine
  - sudo apt install git
4. Clone FSE2020 artifcate repo
  - git clone https://github.com/vaibhavbsharma/fse20.git
4. Install jpf-core as a sibling to java-ranger folder. On Ubuntu, this directory would end up being inside fse20/submissions/reusable/
  - git clone https://github.com/javapathfinder/jpf-core
  - cd fse20/submissions/reusable/jpf-core
  - ./gradlew
  - cd -
5. Build java-ranger
  - cd fse20/submissions/reusable/java-ranger
  - ant

