# Community Expectations for Research Artifacts and Evaluation Processes
## Installation Guide

The artifact consists of data files in CSV and Excel format and scripts in the R language.
While the data files can be opened with virtually any software processing data files (e.g. Excel, Numbers, Google Sheets, pandas, R, ...) the R scripts require an R runtime present on the machine.

For convenience purposes, we also provide a Docker container that is able to run the scripts if reviewers or users of the artifact hesitate to install R directly on their machine.
In this guide, we present both approaches.

### Installing R on your machine

You can either just install the [R runtime](https://www.r-project.org/) or additionally [RStudio](https://rstudio.com/) to run the scripts included in this artifact. We used R version 3.6.1 (2019-07-05) during our analysis, but the scripts are very likely to be compatible with newer versions of R as well. We developed the scripts using RStudio, but they run from the R runtime on the command line as well.

The scripts will use packages from R's library ecosystem. All scripts will automatically install the necessary packages if not present in the current environment.
However, there were cases in the past when functions were deprecated by the package authors.
During the time of the study we did not experience such a case, but they might appear in the future. Just in case, the artifact also contains a list of packages and package versions used during our analysis.

The [R runtime](https://www.r-project.org/) is available in many package managers for operating systems. For Debian-based Linux distributions the package name is `r-base`. The Homebrew package for MacOS is named `r`. With the source code provided on their website, however, you can always build from source if your wish. [Binary setup files for various Linux distributions, MacOS, and Windows are also available on their website.](https://cran.rstudio.com/) Please choose the option you are most comfortable with.

You can now run our scripts directly from the command line. For instance inside of the artifact directory change into the `analysis/survey` folder and execute
```
R < runAll.R --vanilla
```
in your command line. All scripts for the survey analysis should now run. Warnings may appear.

Installing [RStudio](https://rstudio.com/) in addition to the R runtime may be a more convenient option as it features a nice interface to interact with the scripts. [There are installers for multiple operating systems including Windows, MacOS, and various Linux distributions available on the project's website.](https://rstudio.com/products/rstudio/download/#download) Some of the packages do not even require to install software but just to unzip and run, which might be helpful in managed Windows setups where users do not have the permission to install new software.

In RStudio you can simply open a script file using the menu item. Be sure to set the working directory to the script file location. Select all lines and hit the `Run` button.

### Using our Docker container

To use our Docker container you will first need to install Docker on your machine.
Depending on your operating system, you have multiple options for this.

In a Debian-based Linux distribution a simple:
```
apt-get install docker
```
will do the trick, or on MacOS if you use Homebrew it will be a command on the command line:
```
brew install docker
```
For MacOS or Windows, there is also a [Docker Desktop](https://www.docker.com/products/docker-desktop) application available as well.

After you installed Docker, you can start our container by executing:
```
docker run -ti stwinter/artifact-survey:latest
```

Inside of the container is a copy of the artifact ready to be used. You can start the scripts by executing these two commands:
```
cd artifact-survey/analysis/survey/
R < runall.R --vanilla
```
