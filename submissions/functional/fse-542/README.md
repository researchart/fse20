# Robotics Software Engineering: A Perspective from the Service Robotics Domain

This submission contains a replication package for the paper "Robotics Software Engineering: A Perspective from the Service Robotics Domain" (note that the name has been changed from the original "An Empirical Assessment of Robotics Software Engineering" due to the reviewers' feedback).

We provide several artifacts within the same submission, divided into two categories: "Interview material" and "Survey material." The first contains the artifacts related to our interviews, that is, the interviews' guidelines (pdf format). The later contains the artifacts related to our online survey, i.e., the questionnaire (pdf format), the raw (anonymized) data in CSV format, and the R script we used to format, analyze, and represent such data.
The whole package is made available [here](https://figshare.com/articles/Robotics_Software_Engineering_A_Perspective_from_the_Service_Robotics_Domain/12370547), with DOI 10.6084/m9.figshare.12370547.

For more details and questions, please contact us at sergio.garcia@gu.se.

## Interview material

This folder contains the interviews' guidelines, in pdf format (`interview-guide`). The same file contains our research questions, which were used as the basic structure for our semi-structured interviews.

## Survey material

This folder contains all the artifacts related to the online survey we conducted. Concretely, we provide the questionnaire used for the survey, a dataset containing the raw data from the survey, and an analysis script used to format, analyze, and represent the data from the survey.

### Questionnaire (`questionnaire.pdf`)

This pdf file contains a template of the questionnaire used for the survey. It contains a complete list of all the questions our respondents filled in, including mandatory and non-mandatory ones.

### Responses (`Robotics-2019.csv`)

The raw data collected from the survey was stored in this CSV file, each column corresponding to each question, and each row to each respondent. Note that the last two columns were removed to anonymize the results.

### Analysis script (`analysis-script.r`)

This script is used to format, analyze, and represent the data from the survey, and therefore `Robotics-2019.csv` needs to be stored in the same folder as the r script. When executed, the script will automatically generate two folders: `graphs` and `open-ended-answers`. The first will contain graphical representations of the data and the second textual answers to the open-ended questions from the questionnaire. Both folders will contain five subfolders each, corresponding to each of the groups we identified during our study. This categorization helped us during the analysis of our data to synthesize results.

1. `academic`. Will contain data regarding the respondents who lay into the category of academic researchers or scientists.

2. `all`. Data from all groups.

3. `industrial`. Data from industrial practitioners (including leading roles and programmers).

4. `industrial-leading`. Data from one of the subgroups of industrial practitioners, referring to leading roles within the companies.

5. `industrial-programmer`. Data from one of the subgroups of industrial practitioners, referring to programmers within the companies.

The script is mostly realized as a function, which is called several times (one for each role, corresponding to the five points above) to avoid redundancy. To shorten the compilation time a user may comment some of those lines (at the bottom of the script, lines 887-884). The script will also print some useful information related to demographics, like the percentage of respondents for each role or years of experience.
