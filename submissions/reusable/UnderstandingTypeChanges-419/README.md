# README
## Artifact Description
This artifact contains the data collected for the empirical study **"Understanding Type Changes in Java"**.
It also contains the instruction for using the tools employed by this study. 


### [Website](http://changetype.s3-website.us-east-2.amazonaws.com/docs/index.html "Companion Website")
This website contains all the data collected from the analysis of the source code history of 129 projects.

* *[Project](http://changetype.s3-website.us-east-2.amazonaws.com/docs/P/projects.html):*  In this tab, for each project we provide 2 links:
  * *Commits analyzed:* List of all commits analyzed in this project. Each commits link to a page that provides the following details:
    	* Files (added/removed/modified)
    	* (added/removed/updated) external dependencies
    	* All the refactorings reported by RMiner
	[Example](http://changetype.s3-website.us-east-2.amazonaws.com/docs/P/guacamole-client.html)
  * *Type Changes:* This tab reports all the type changes detected in the projec ([Example](http://changetype.s3-website.us-east-2.amazonaws.com/docs/P/TypeChangeguacamole-client.html)).
  Each type change links to a page that provides additional information about it. 
  This page also lists the edit patterns performed by developers(and the link to the exact line of code on GitHub) when applying the type change.
  [Example](http://changetype.s3-website.us-east-2.amazonaws.com/docs/P/guacamole-client/tci_project0.html)
* *[Popular Type Changes](http://changetype.s3-website.us-east-2.amazonaws.com/docs/P/A/popular.html):* This tabulates the popular type changes that we identified in our study (i.e. performed by atleast 2 projects)
* *[Migration](http://changetype.s3-website.us-east-2.amazonaws.com/docs/P/A/Migrations.html):* This tablutaes the instances of type migrations performed. It also contains the link to the type change and the Github commit

### [Raw Data](https://drive.google.com/drive/folders/1-baLOUKKByhhwj03C7whgVP0FGEc4uTs?usp=sharing)
We collect all the data in [Protocol Buffer](https://developers.google.com/protocol-buffers) format.

#### Data:

* The schema for the collected data is available [here](https://github.com/ameyaKetkar/Models/tree/201416934a47bf8d8b0fa088fba07a32c150648d/src/main/resources/Protos).
* All the refactorings collected on analysing the commit history of the 129 projects is available [here](https://drive.google.com/drive/folders/11ESFhGhH-OFRBiFGPiUvHL-U1-1_7kG3?usp=sharing).
* All the type changes collected are available here [here](https://drive.google.com/drive/folders/1ml3qitz-TLY__tCXqUnlXg4AAptvwpCA?usp=sharing).
* All the edit patterns performed to apply the type changes is available [here](https://drive.google.com/drive/folders/1fSBO89DhbaooMLY5fG4hTKKUp7ymi6Yo?usp=sharing).

#### Utilities: 

* To parse this data, use these [Java parsers](https://github.com/ameyaKetkar/Models/tree/201416934a47bf8d8b0fa088fba07a32c150648d/src/main/java/com/t2r/common/models/refactorings) 
or [Python parsers](https://github.com/ameyaKetkar/Models/tree/201416934a47bf8d8b0fa088fba07a32c150648d/Models).
* Using the protocol buffer commandline, one can generate parsers for this data based on the schema in the programming language of choice. 
* The utilities ([1](https://github.com/ameyaKetkar/Models/blob/201416934a47bf8d8b0fa088fba07a32c150648d/src/main/java/com/t2r/common/utilities/ProtoUtil.java) & [2](https://github.com/ameyaKetkar/DataAnalysis/blob/master/Analysis/RW.py))
provides a easy way to use these parsers.

#### Scripts: 
* The python script employed to perform the analysis and generate the plots showcased in the paper can be found [here](https://github.com/ameyaKetkar/DataAnalysis/blob/master/Analysis/TypeChangeCommitAnalysis.py).


## Tools
Our study employed two tools:

- An extension of **RefactoringMiner**, to mine type changes.
- **TypeFactMiner** to infer the qualified names of the types, without building the Java project.

The extension we created for our study is now a part of RefactoringMiner and is available in the [latest version](https://github.com/tsantalis/RefactoringMiner).
It reports 4 refactorings for type changes, namely 

1. Change Variable Type 
2. Change Parameter Type 
3. Change Return Type
4. Change AttributeType.

Detailed instructions on how to use RefactoringMiner can be found [here](https://github.com/tsantalis/RefactoringMiner/blob/master/README.md).

To reproduce the entire study , it can take upto 2 days (depending on the hardware).
The details for reproducing the entire the study can be found in **INSTALL.md**.
