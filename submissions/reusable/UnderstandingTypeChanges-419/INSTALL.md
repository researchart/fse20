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

Seperating the process into two distince phases facilitates easier exploration of the data.


## PREREQUISITES
1. JDK 8 + (has been tested to work with JDK 11)
2. Maven 3.6 + 
3. Python 3+


## STEP 1

1. Clone the project: `git clone https://github.com/ameyaKetkar/SimpleTypeChangeMiner.git`
2. Update the [property file](https://github.com/ameyaKetkar/SimpleTypeChangeMiner/blob/master/paths.properties)
   
   * *PathToCorpus*: Location where the subject systems could be found or could be cloned at.
   * *InputProjects*: List of the csv file containing the name of the project and its git URL. 
	 * Place this file in the folder *PathToCorpus*
	 * Each entry in this file should be (ProjectName, Git URL).
	 * [Sample](https://github.com/ameyaKetkar/SimpleTypeChangeMiner/blob/master/mavenProjectsAll.csv)
   * *mavenHome*: The path maven executable.
   
3. Run the following commands:
   * `cd ~/SimpleTypeChangeMiner`
   * `mvn clean install`
   * `mkdir Output`
   * `cd Output`
   * `mkdir ProtosOut`
   * `mkdir tmp`
4. Import the project in your favorite IDE and run the main class [Runner.java](https://github.com/ameyaKetkar/SimpleTypeChangeMiner/blob/master/src/main/java/Runner.java)

5. As the projects get analysed the following output is expected: 
   * a file `commits_<project_name>.txt` should appear in `~/SimpleTypeChangeMiner/Output/ProtosOut/`
   * Jars of the third party dependencies required by the project should get downloaded at `~/SimpleTypeChangeMiner/Output/tmp`
   
## STEP 2

1. Clone the project : `git clone https://github.com/ameyaKetkar/TypeChangeMiner.git`
2. Update the [property file](https://github.com/ameyaKetkar/TypeChangeMiner/blob/master/paths.properties)

   * *PathToCorpus*: Location where the subject systems could be found or could be cloned at.
   * *InputProjects*: List of the csv file containing the name of the project and its git URL. 
	 * Place this file in the folder *PathToCorpus*
	 * Each entry in this file should be (ProjectName, Git URL).
	 * [Sample](https://github.com/ameyaKetkar/SimpleTypeChangeMiner/blob/master/mavenProjectsAll.csv)
	 
3. Run the following commands:
   * `cd ~/TypeChangeMiner`
   * `mvn clean install`
   * `mkdir Output`
   * `mkdir Input`
   * `cd Input`
   * Copy the output from *SimpleTypeChangeMiner* (i.e. `~/SimpleTypeChangeMiner/Output`) to input of *TypeChangeMiner* (i.e. `~/TypeChangeMiner/Input`)
   * Rename `~/TypeChangeMiner/Input/tmp` to `~/TypeChangeMiner/Input/dependencies`
   
4. Import the project in your favorite IDE	 

5. Download and unzip this [apache tinkerpop server]().
   * Run the script `apache-tinkerpop-gremlin-server-3.4.4/bin/gremlin-server.sh`
   * It will start a in-memory tinkerpop database that contains all the classes, methods and fields declared in *Java Runtime Environment*
   
6. To collect the detailed type changes (as discussed in the paper), run the main method in the [class](https://github.com/ameyaKetkar/TypeChangeMiner/blob/master/src/main/java/TypeFactMiner.java)

7. To detect type migrations, run the main method in the [class](https://github.com/ameyaKetkar/TypeChangeMiner/blob/master/src/main/java/MineTypeMigrationAgain.java)
