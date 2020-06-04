# Community Expectations for Research Artifacts and Evaluation Processes
### Additional Material
#### [Ben Hermann](https://thewhitespace.de/), [Stefan Winter](https://www.stefan-winter.net/), [Janet Siegmund](https://www.tu-chemnitz.de/informatik/ST/professur/professor.php)

The artifact contains the material used in and produced during the study _Community Expectations for Research Artifacts and Evaluation Processes_ accepted at the [ACM Joint European Software Engineering Conference and Symposium on the Foundations of Software Engineering (ESEC/FSE) 2020](https://2020.esec-fse.org/).

## Organization

The artifact is available on Zenodo

[![DOI](https://zenodo.org/badge/203532929.svg) URL: https://zenodo.org/badge/latestdoi/203532929](https://zenodo.org/badge/latestdoi/203532929)

Additionally, for review convenience we supply a Docker container containing our artifact with an installed R runtime that is able to execute our script if R cannot be installed on a reviewer's (or user's) machine. It is available here.

The artifact itself is organized as a web page. It contains data files in Excel or CSV format as well as several R scripts used for analyses. All documentation is provided in HTML format starting with the `index.html` file in the root directory of the artifact. From there each file is linked to and documented. The `index.html` file also contains a guide with sections of the paper relate to which artifact part (data and/or scripts). Furthermore, the methodology of the analysis steps is explained in more detail.

The artifact as well as this folder contain a pre-print version of the paper named `preprint.pdf`. Please note that this is the unblinded version of the review version of the paper. The reviewer's comments have not been addressed so far. They will be addressed together with the comments from the artifact reviewers. Figure 2 is one exception. It has been adjusted for the paper review rebuttal based on a reviewer comment to include the number of responses. The previous version just showed the distribution of invited individuals.

## Reproducing the Results of the Paper

For the analysis of Calls for Artifacts open the file `analysis/calls/analysis.R` and run it completely with the working directory set to the folder of the script.
This can either be achieved in RStudio or with the R REPL console using the `source("analysis.R")` command or on the command line of the operating system using `R < analysis.R --vanilla`.
The different variables the script computes contain the information presented in the results section of Section 3. The variables are best viewed using RStudio, but can also be inspected using the R REPL console.

For the analysis of the survey data open the file `analysis/survey/runall.R` and run it completely with the working directory set to the folder of the script. This can either be achieved in RStudio or with the R REPL console using the `source("runall.R")` command or on the command line of the operating system using `R < runall.R --vanilla`.

This script executes four other scripts: `conferencespread.R`, which computes Figure 1 (and stored automatically in the `analysis/survey/output` folder as `conferencespread.pdf`) from the paper, `participant_stats.R`, which computes Figure 2 and stored automatically in the `analysis/survey/output` folder as `aec_histogram.pdf`), `numericdata.R`, which computes summaries of answers to question types giving numerical output (and stored automatically in the `analysis/survey/output` folder as `numericresults.txt`), and finally `taganalysis.R`, which computes summaries for the data produced by open card sorting (and stored automatically in the `analysis/survey/output` folder as `tagresults.txt`). 

For a full documentation of the scripts and data files please see the documentation inside the artifact.

You can directly compare the output of these scripts to the results presented in the respective sections of the paper.

### Differences to the Paper Preprint

On line 1019 the paper states

> The expectations on code artifacts show a higher number of replies related to reusability (7) than to replicability (4). This is corroborated by open comments on artifact usage, in which 18 respondents indicate reusability as artifact purpose, whereas only 8 indicate replicability.

During the preparation of the artifact we found that there is a typo in reporting of the numbers here. It should read as "[...] in which **14** respondents indicate reusability as artifact purpose, whereas only **6** indicate replicability." We will correct this in the final version of the paper. The overall argument is, however, not affected by this mistake.
