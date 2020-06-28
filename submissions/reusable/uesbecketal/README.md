# Polyglot Experiment

This package includes additional information for the paper "A Randomized Controlled Trial on the Effects of Embedded Computer Language Switching". 

The contents will allow you to:
1. review the tasks (see Tasks) and other materials used in the experiment
2. re-run and review the experiment itself is provided
3. 3. 3. review, reuse, and remix the code used to run the experiment

Please keep in mind that running the experiment requires a number of
programmer participants using the website to gather all of the required data.
Additional context regarding running the experiment with participants is
presented in the paper.

This package includes:
* Tasks
* Sample code given to participants
* De-identified data
* The R script used for analysis
* Screenshots of the experiment system including surveys
* The application used to conduct the experiment

## Interest 1: Review Contents
In case you want to review the materials used in this study, the following
parts of this artifact might be interesting for you.

### Tasks
The tasks can be found in the folder `tasks`. There, you'll see a set of folders with the code for each task for each group. This includes the code that is used in the background and tests. The actual task shown to participants can be found in the file "Task<X>.java", where <X> is the number of the task. The code for the different groups is technically the same, the difference between the groups comes from the different sample given. Nevertheless, L1 is hybrid, L2 is string or SQL-based, and lastly, L3 is object-oriented.

Possible solutions for the tasks are available in `tasks/solutions`. For convenience, the files correspond to the tasks and the solutions for the different groups are all represented in the files in different methods.

queryA(): Hybrid
queryB(): String-based
queryC(): Object-oriented

### Samples
Find the samples in folder `samples`. The samples stay the same throughout the experiment. Each group has its own sample. SampleA corresponds to the hybrid group, SampleB corresponds to the string or SQL-based group, SampleC corresponds to the object-oriented group. We apologize for the inconsistent naming of the groups between tasks and samples.

## Screenshots
Information in survey forms is included in the form of screenshots (folder `screenshots`). This also includes some screenshots of the task environment. The files `survey-pre1.png` and `survey-pre2.png` show the pre-experiment survey, the `protocol.png` image shows the experiment protocol. `tasks.png` shows the experiment environment. Finally, `survey-post.png` shows the short post experiment survey.

## Interest 2: Review and Rerun Data Analysis
In case you want to review the data and analysis of data, the following
sections might be interesting to you.

### Data
The data (`summary-deidentified.csv` in the `data` folder) has been de-identified compared to the data that was used in the actual analysis. Due to the de-identification, information on the gender of participants and their age, as well as their primary langauge was excluded from the data to reduce the amount of personally identifiable information and reduce the chance of reconstruction attacks on the data. Technically, more information is available in the database (see surveys), but that information was not used in the analysis for this study and some might require manual review to avoid identifying participants.

The `data` folder also contains the responses to the exit-survey questions in the file `exit-survey-answers.csv`. The data in this file is separated by semicolons because that didn't cause any problems opposed to commas. Column mapping for the questions is as follows:

concepts: "Which of the concepts in the study did you find difficult to understand?"
codeswitch: "Did you feel like you had to switch between languages often and how do you think did this affect your progress while solving the tasks"
design: "Was there anything about the design of the programming languages (not the study itself) that would have made these tasks easier?"
comments: "If you have any other comments or feedback, please type it here:"

### R script
The script (in the `data` folder) reads the csv file and analyzes the data. It also generates the graphs used in the paper. You might have to change the working directory to fit your folder structure. We recommend using RStudio to run the R script. Further information on how to run the script can be found in INSTALL.md.

## Interest 3: Running the Experiment Application
Lastly, if you are interested in running the application, maybe even reusing it
for your own research, check out the following section and the INSTALL.md file.

### Experiment Application
The php application (EPI) used to conduct the experiment is included in the folder `experiment-application` There, you will find instructions on how to start the application. This version of the application uses the correct tasks out-of-the-box and usable with docker to make setup easier. To run the experiment, you will have to recruit programmers to participate (we used flyers in combinations with speeches in front of CS classes, see paper), give them the link of where you have hosted the experiment platform (by default, http://localhost once you have started the Docker containers, you can also host the website on a proper server using the containers) and then wait for the participants to complete the study. 

Once you have collected data, you can access the data using the phpmyadmin Docker container (http://localhost:8080 with default start from Docker-compose) to easily access the database. It comes with a view called `summary_share_filtered`, which can then be exported to a CSV file (make sure to let the system automatically add column headers). You can re-use the analysis script from the `data` folder to complete the same data analysis on these new data.

