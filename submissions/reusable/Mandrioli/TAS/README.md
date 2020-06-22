# TAS case study
In this directory contains the files related to the Tele-Assistance Service case study.

## Directory structure and content
The directory is divided in two subdirectories:
  * *code*: the code directory contains the matlab functions and scripts that implement the simulator.
  * *fig*: the fig directory contains the .tex file generating the paper figure and a makefile scripting the generation process.

## System requirements
The simulation is run in Matlab, and will require the statistics and machine learning toolbox. No specific version of Matlab is required (as long as it is sufficiently recent).

## Instructions for reproducing the results from the paper
Two steps are required to reproduce the results presented in the paper: one runnning the simulation of the TAS system and a second one generating the figure found in the paper. 

 * Open matlab and navigate to the */TAS/code* directory. From there you can run the script MAIN_tests.m . The script will sequentially: **(i)** load testing parameters, **(ii)** perform perform the tests (printing out the progress every 100 tests), **(iii)** generate the file maxima_growth_plot.csv in the /TAS/fig directory, and **(iv)** display two plots sumarizing the results.
 * To generate figure 3 from the paper you can now run the makefile in the directory /TAS/fig (latex and tikz are required). The makefile is run from a termial window with the *make* command. Altrernatively, you can directly insert the following commands from a terminal window (after navigating to the */TAS/fig* directory):
   > pdflatex Fig3.tex \
   > rm Fig3.aux Fig3.log
 
   This requires the file *maxima_growth_plot.csv* so the matlab script has to be run before this step.

## Instructions for reuse
In the file MAIN_tests.m test number and the simulation parameters can be tweaked. 

  * At line 13 and 17 the number of tests can be changed. In the paper we used only one testset but the script allows to run several. The idea is that by comparing different randomly generated testsets we can evaluate the stability of the testing strategy.  Meaning that a testing strategy to be considered stable should provide similar results for different testsets. A number of tests different than one will also change the plots displayed to summarize the results.

  * At lines 20, 21, and 22 can be changed the number of service providers (for each of the services) and two adaptation parameters. The *gain* parameters defines how much the weight of each provider is increased or decreased when the adaptation is run and the *advanced* flag defines if the feature for identifying unavailable services is to be used.

  * At lines 44, and 45 the probability of a request being of different kinds can be changed. In the paper simulations this is randomized to obtain results independent form the specific types of requests received (further explanation can be found in the paper).
  
In the initialize_services.m more simulation parameters for the service providers can be changed:

  * *max_capacity*: this integer defines the number of requests that a provider can process in parallel.
  * *failure_probabilities*: this is a vector of probabilities. When a service is initialized its service rate is sampled randomly from this vector. Using higher probabilities here means that the providers are more likely to be reliable in the simulations. 
  * *down_probabilities*: this is a vector of probabilities. When a service is initialized its probability of becoming unavailable for a period of time is sampled from this vector. Using higher probabilities here means that the providers are more likely to become unavailable.
  * *execution_time*: this integer defines the number of time-steps needed to process one reqsuest by each provider.
