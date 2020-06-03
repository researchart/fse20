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

Seperating the process into two distince phases facilitates easier exploration of the data, specially when the study has to be run over 100+ projects.


## PREREQUISITES
1. JDK 11 + (has been tested to work with JDK 11, 12, 13)
2. maven
3. Python 3+
4. pip 



## SETUP

### Instructions:
1. Clone the project `git clone https://github.com/ameyaKetkar/RunTypeChangeStudy.git`
2. Run: `cd RunTypeChangeMiner`
3. Run: `pip install --user -r requirements.txt`
4. Run: `python Setup.py <Path to setup> <Path to maven>` 
   - Example 1 (Windows): `python Setup.py C:\Users\amketk\Artifact  C:\ProgramData\chocolatey\lib\maven\apache-maven-3.6.3\`
   - Example 2 (MacOS): `python Setup.py /Users/amketk/Artifact /usr/local/Cellar/maven/3.6.3/`
   - To find out `<Path To Maven>` run `mvn --version`, which would output the maven version and the path to it. 
		 
### Expected Outcome: 
1. The console will print the activites that are being performed
2. In the end you should see a folder named `TypeChangeStudy` at the `<Path to Setup>`
   - It contains 3 projects : `SimpleTypeChangeMiner`, `TypeChangeMiner` and `DataAnalysis`
   - A folder named `Corpus`
	 - This will contain a file named `mavenProjectsAll.csv`. It contains the list of projects that will be analyzed.
	 - This file has one entry currently for the project google/Guice. Users can add any Github Java maven projects to this file.
   - Another folder named  `apache-tinkerpop-gremlin-server-3.4.4/bin/gremlin-server.sh`


## STEP 1

### Instructions:
1. Run: `cd <Path To SetUp>/TypeChangeStudy/SimpleTypeChangeMiner`
2. Run: `java -cp "lib/*" Runner`
### Expected Outcome: 
1. The console will print the activities being performed.
2. You should observe the output being populated at 
   - `~/SimpleTypeChangeMiner/Output/ProtosOut`
   - `~/SimpleTypeChangeMiner/Output/dependencies`

**NOTE:** This step takes a while, because it will analyse all the commits in the project `guice`.
   If you are a user, who just wants to check out how the tool works (like artifact evaluators), abort the command after a 3-4 minuts of analysis.


## STEP 2
### Instructions
1. Run: `cd ~/RunTypeChangeStudy`  (This was the repository that you cloned for the setup stage)
2. Run: `python CopyPaste.py`
3. On a seperate terminal: 
   - Run: `cd <Path to setup>/TypeChangeStudy/apache-tinkerpop-gremlin-server-3.4.4/bin`
   - For Linux/Mac:
	 - Run : `./gremlin-server.sh console`
   - For Windows:
	 - Run : `gremplin-server.bat`
   - **NOTE**: Wait for a minute or so, until the server is up on port 8182.  		
3. Run: `cd <Path to Setup>/TypeChangeStudy/TypeChangeMiner`
4. Run: `java -cp "lib/*" org.osu.TypeFactMiner`
    - **NOTE:** This step takes a while, because it will analyse all the commits in the project `guice` that contain a type change.
   If you are a user, who just wants to check out how the tool works (like artifact evaluators), abort the command after a 3-4 minuts of analysis.
5. Run: `java -cp "lib/*" org.osu.AnalyseChangePatterns`
### Expected Outcomes:
1. The console will print the activities being performed.
  


## STEP 3:
### Instructions
1. Run `cd <Path to setup>/TypeChangeStudy/DataAnalysis`
2. Run `pip install --user -r requirements.txt`
3. Run `python ToHtml.py`
### Expected outcomes
1. open `<Path to Setup>/TypeChangeStudy/DataAnalysis/docs/index.html` in the browser.
