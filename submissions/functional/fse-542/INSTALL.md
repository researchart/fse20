# Installation instructions

## R

### Download and Install R

As explained in the readme file, our analysis script was developed using R. Therefore, its execution requires the installation of R. Concretely, we used `R v3.6.0`. To install this version or a newer one, please download it and follow the instructions from the [The R Project for Statistical Computing website](https://www.r-project.org). To check the R version running in the PC, please run the following command: 

`R --version`

if using Windows:

`R.exe --version`

### Install Dependencies

Using [RStudio](https://rstudio.com) the dependencies and libraries should be automatically installed, but in case there is any problem related to them, please install the libraries manually using the following command

`install.packages(c("likert","plyr","lattice","ggplot2","dplyr","tidyverse","ggthemes"))`

### Configure environment

R requires the user to the set the working directory, which the user can easily do by uncommenting and editing line 34 of the script

`setwd("path-to-your-folder")

To execute the script and generate the graphs and text files, please navigate to the folder where you stored the R script and execute the command

`Rscript analysis-script.r`