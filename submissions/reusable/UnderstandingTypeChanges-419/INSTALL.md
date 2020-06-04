# INSTALL

Running this empirical study is a 2 phases process. 

1. A light-weight analysis upon the entire commit history of all the projects in our corpus. 
In this step we :
  * Collect the refactorings performed at each commit and identify the ones where a type change was performed
  * Identify and download the third party dependency required at each commit 
	* Generates an [effective-pom](https://maven.apache.org/plugins/maven-help-plugin/effective-pom-mojo.html) for the maven project at that commit
 * This step has to be executed just once for each project.
 
2. Perform a fine-grained analysis upon each commit where a type change was performed.
   * Uses **TypeFactMiner** to qualify the types involved in the type change
   * Performs analysis on the commit history of a project as whole to detect migrations 
   * Reports the edit patterns performed to apply the type change.

Seperating the process into two distinct phases facilitates easier exploration of the data, specially when studying over 100 projects.


## PREREQUISITES
1. JDK 11 + (has been tested to work with JDK 11, 12, 13 and not to work with 14)
2. maven
3. Python 3+
4. pip 3

### Docker
This environment is also available as a docker container. 

Pull the image from the repository: `docker pull ameyaketkar/typechangeminer`

To run the image: `docker run -d --name mytc -i -t ameyaketkar/typechangeminer`

To shell into the docker container run: `docker exec -it mytc /bin/bash`

**The docker needs atleast 4GB of memory to run the study**

## SETUP

### Instructions:
1. Clone the project `git clone https://github.com/ameyaKetkar/RunTypeChangeStudy.git`. (Skip for docker)
2. Run: `cd RunTypeChangeMiner`. (Skip for docker)
3. Run: `pip install --user -r requirements.txt`. (Skip for docker)
4. Run: `python 0Setup.py <SETUP_PATH> <MAVEN_HOME>`
   - `SETUP_PATH`: The folder where the study should be setup
   - `MAVEN_HOME`: Path to maven
   - **For Docker** : `python 0Setup.py /data /usr/apache-maven-3.5.4`
   - Example 1 (Windows): `python 0Setup.py C:\Users\amketk\Artifact  C:\ProgramData\chocolatey\lib\maven\apache-maven-3.6.3\`
   - Example 2 (MacOS): `python 0Setup.py /Users/amketk/Artifact /usr/local/Cellar/maven/3.6.3/`
   - To find out `<MAVEN_HOME>` run `mvn --version`, which would output the maven version and the path to it. 
		 
### Expected Outcome: 
1. The console will print the activities that are being performed
2. In the end you should see a folder named `TypeChangeStudy` at the `<SETUP_PATH>`
   - It contains 3 projects : `SimpleTypeChangeMiner`, `TypeChangeMiner` and `DataAnalysis`
   - A folder named `Corpus`
	 - This will contain a file named `mavenProjectsAll.csv`. It contains the list of projects that will be analyzed.
	 - This file has one entry currently for the project google/Guice. Users can add any Github Java maven projects to this file. 
	 - The list of all projects used in the study are available [here](https://changetype.s3.us-east-2.amazonaws.com/docs/mavenProjectsAll.csv)
   - Another folder named  `apache-tinkerpop-gremlin-server-3.4.4/`


## STEP 1

### Instructions:
 Working Directory: `~/RunTypeChangeStudy`
 
 Run: `python 1CollectDepsAndTypeChanges.py`
 
### Expected Outcome: 
1. The console will print the activities being performed.
2. You should observe the output being populated at 
   - `<SETUP_PATH>/TypeChangeStudy/SimpleTypeChangeMiner/Output/ProtosOut`
   - `<SETUP_PATH>/TypeChangeStudy/SimpleTypeChangeMiner/Output/dependencies`
   - For docker: /data/TypeChangeStudy/SimpleTypeChangeMiner/Output/

**NOTE:** This step takes a while, because it will analyse all the commits in the project `guice`.
   If you are a user, who just wants to check out how the tool works, abort the command after a 3-4 minutes of analysis.


## STEP 2
### Instructions
1. Working Directory: `~/RunTypeChangeStudy`

   Run: `python 2CopyPaste.py`
   
2. **On a seperate terminal**: 
   
   -  Working Dierctory:`<SETUP_PATH>/TypeChangeStudy/apache-tinkerpop-gremlin-server-3.4.4/bin`
   	- For Linux/Mac 
	    - Run : `./gremlin-server.sh console`
   	- For Windows:
	    - Run : `gremlin-server.bat`
   - For docker :  
	- Use a separate terminal on your host machine to shell into the container with `docker exec -it mytc /bin/bash`
		- `cd /data/TypeChangeStudy/apache-tinkerpop-gremlin-server-3.4.4/bin`
		- `chmod 777 gremlin-server.sh`
		- `./gremlin-server.sh console`
   - **NOTE**: Wait for a minute or so, until the server is up on port 8182.
   
   
   
3. Working Directory: `~/RunTypeChangeStudy` 

   Run: `python 3AnalyseTypeChanges.py`
   
   - **NOTE:** This step takes a while, because it will analyse all the commits in the project `guice` that contain a type change.
   If you are a user, who just wants to check out how the tool works, abort the command after a 3-4 minutes of analysis.
   
5.  Working Directory: `~/RunTypeChangeStudy` 

    Run: `python 4AnalyseChangePatterns.py`
   
### Expected Outcomes:
1. The console will print the activities being performed.
  
## STEP 3:
### Instructions
 Working Directory: `~/RunTypeChangeStudy` 
 
 Run: `python 5_1Visualize.py`
 
 If it throws syntax error, try: 
 
 Run: `python 5Visualize.py`
 

### Expected outcomes
1. open `<SETUP_PATH>/TypeChangeStudy/DataAnalysis/docs/index.html` in the browser.
- If you are using docker `docker cp mytc:/data/TypeChangeStudy/DataAnalysis/docs .` will copy the HTML files generated into the host. 
