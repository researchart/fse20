## EPIcuRus --- assumPtIon geneRation approach for CPS


<div align="center">
<img src="./epicurusLogo.jpg" alt="EPIcuRus logo" width="96">
</div>

EPIcuRus (assumPtIon geneRation approach for CPS) is an assumption generation approach for CPS. EPIcuRus is a comprehensive solution for the analysis of simulink models. EPIcuRus receives as input a software component and a requirement and automatically infers a set of conditions (i.e , an environment assumption) on the inputs of the model such that the model satisfies the requirement when its inputs are restricted by those conditions).


EPIcuRus combines machine learning and search-based testing to generate an environment assumption.
* Search-based testing (1) is used to automatically generate a set of test cases for exercising requirement such that some test cases are passing and some are failing.
* The machine learning algorithm (2) automatically infers an assumption in the form of a decision tree from the generated test cases and their results.
*  Model checking (3) is used to validate an environment assumption by checking if the model guarantees the satisfaction of the property when it is fed with inputs satisfying assumption.

<div align="center">
<img src="./epicurus.jpg" alt="ARIsTEO" width="396">
</div>

## License

This software is released under GNU GENERAL PUBLIC LICENSE, Version 2. Please refer to the license.txt  <br/>
Copyright by University of Luxembourg 2019-2020.  <br/>
Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg. <br/>
Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg. <br/>
Developed by Shiva Nejati, shiva.nejati@uni.lu University of Luxembourg. <br/>
Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg. <br/>

## DOI

[DOI](https://doi.org/10.5281/zenodo.3872902)

# Publications
- Mining Assumptions for Software Components using Machine Learning <br/>
<i>Gaaloul Khouloud, Menghi Claudio, Nejati Shiva, Lionel Briand, David Wolfe<br/>
European Software Engineering Conference and Symposium on the Foundations of Software Engineering (ESEC/FSE), 2020 <br/>
</i>

## Content description

Scripts:
- ``epicurus.m`` implements the EPIcuRus main loop
- ``genSuite.m``, ``genAssum.m`` and ``modelCheck.m`` respectively implements the components (1), (2) and (3) of the EPIcuRus main loop
- The script for setting EPIcuRus options: ``epicurus_options.m``
- ``qvtrace.py`` is a Python script that is used by EPIcuRus to run QVtrace if the usage of the model checking tool is enabled

Folders
- ``results``: contains the results of the paper ``Mining Assumptions for Software Components using Machine Learning`` and the scripts to process them.
- ``Tutorial``: contains a tutorial that shows how EPIcuRus works on a demo model
- ``staliro``: contains the S-Taliro, the tool that is  used to automatically generate a test suite
- ``utils``: contains side functions

## Prerequisite
- Matlab R2018a
- Matlab System Identification Toolbox
- Matlab Signal Processing Toolbox
- For mac users Xcode should be installed and properly configured (see https://www.mathworks.com/support/compilers )

## Installation instructions
- open the folder ``Epicurus`` with Matlab
- add the folder ``Epicurus`` and all of its subfolders on your classpath (right click on the folder > add to path > selected folder and subfolders)
- set the folder ``staliro`` as the current folder. Double-click the folder to make it the current folder.
- run the command ``setup_staliro``
- Install the Signal Processing Toolbox  to add it "Home > Adds On > Signal Processing Toolbox"

## Tutorial

The script ``tutorial.m`` under the forlder ``Tutorial`` demonstrates the steps to set and run EPIcuRus on our demo model. The model has four inputs, and the property of interest states that the output shall not be grater than 50 for more than 100 time frames.
The goal of the testing activity is to return the assumption on the inputs under which the property is always satisfied.

- Step 1- Open Matlab and add all the subfolders of the folder ``Epicurus`` on your classpath (right click on the folder > add to path > selected folder and subfolders) <br/>
- Step 2- Set the folder ``Tutorial`` as the current folder.<br/>
- Step 3- choose whether you want to enable or disable QVtrace\
 1. To disable QVtrace  set the following option to false: <br/>
``epicurus_opt.qvtraceenabled=false;``<br/>
In Step 4, EPIcuRus stops the iterations when the maximum number of iterations is reached
 2. To enable QVtrace set the following option to true: <br/>
``epicurus_opt.qvtraceenabled=true;``<br/>
 Make sure that the text file ``turn.txt``contains Matlab
 Open a terminal command line, change directory to the folder ``Epicurus``and run the command ``python3 qvtrace.py``
 EPIcuRus stops the iterations when the QVtrace check returns a valid assumption
- Step 4- In the Matlab command, execute the script ``tutorial.m`` by running the command  ``tutorial()`` <br/>
- Step 5- The results of the experiments are saved under``Epicurus/result`` <br/>

By running the these commands, EPIcuRus performs iterations where at each iteration, a test suite is generated and an assumption is learned using decision trees. If the model checking is enabled, this assumption is checked using QVtrace.



## Running EPIcuRus on a Simulink model

To run EPIcuRus on a particular Simulink model, Step 3 should be created as follows: <br/>
Under the folder ``Tutorial``, perform the following steps:<br/>

1. Add the Simulink model (.slx) and the mat file .<br/>
2. If QVtrace is enabled,
- you must also specify the property using QCT query language. The QCT language is a logical predicate language used in QVtrace to specify the property of interest. Here is an example of a simple property specified in QCT:<br/>
 Property (natural language): The output ``yawCmd2`` of the demo model shall be always less than 50<br/>
 Specification (QCT language): ``yawCmd2 < 50;`` <br/>
For more details on how to use QVtrace and on the QCT query language, please contact: [QRA](https://qracorp.com) <br/>
- Add the property specified in QCT language to a QCT. The file name should follow the form:  ``demoRoriginal.qct`` where ``demo`` is the name of the model and ``R`` is the name of the property.<br/>
- Add a copy of the model in .mdl format.  the name of the model should follow the form: ``demoqv`` where ``demo`` is the name of the simulink model.<br/>
3. Create a matlab file under Tutorial with the following commands (see and follow``tutorial.m``): <br/>

% Defines the variables that contains the model information <br/>
```model='demo';```             % the model name  <br/>
```property='R';```             % the property name  <br/>
```input_names={'rollCmd_','yawCmd', 'beta_deg', 'vtas_kts'};```            % a cell array of input names <br/>
```input_range=[0 50;0 50;0 10;0 10];```            % an array of inputs ranges  <br/>
```categorical=[];```           % if categorical inputs exist, specify their index  <br/>
```init_cond = [];```           % default initial conditions of the model  <br/>
```sim_time=1;```           % the simulation Time<br/>

% Defines the property of interest. For more details run ``help tp_taliro`` <br/>
```phi='<>_[0,100](p1)';``` <br/>
```preds(1).str='p1';``` <br/>
```preds(1).A=[1 0]; ```<br/>
```preds(1).b=50; ``` <br/>

% Creates the options of EPIcuRus. For more details see ``epicurus_options.m `` <br/>
```epicurus_opt=epicurus_options();```

```epicurus_opt.assumeRuns=10;```          % the number of total EPIcuRus runs  <br/>
```epicurus_opt.assumeIterations= 30;```            % the maximum number of iterations  <br/>
```epicurus_opt.testSuiteSize=30;```             % the test suite size  <br/>
```epicurus_opt.nbrControlPoints=1;```          % the number of control points <br/>
```epicurus_opt.policy='IFBT_UR';```            % the test suite generation policy  <br/>
```epicurus_opt.qvtraceenabled=true;```            % enable QVtrace checking  <br/>

% Specifies the running script name and results folder name <br/>
```scriptname=[model,property];``` <br/>
```policyFolder=strcat('result',filesep,model,filesep,property,filesep,policy);``` <br/>
```propertyFolder=strcat('result',filesep,model,filesep,property);``` <br/>
```modelFolder=['result',filesep,model]``` <br/>

% Creates the results folders <br/>
```mkdir(modelFolder);``` <br/>
```mkdir(propertyFolder);``` <br/>
```mkdir(policyFolder);``` <br/>

% Runs EPIcuRus <br/>
```epicurus(model,property,init_cond, phi, preds, sim_time,input_names,categorical,input_range,epicurus_opt,scriptname,resultfilename,policyFolder)``` <br/>

## Description of the Outputs of EPIcuRus

The output of EPIcuRus is saved under the folder ``result``.  <br/>
Each iteration of EPIcurus generates an assumption. The output of each iteration is saved under the run folder ``result/modelFolder/propertyFolder/policyFolder/RunIndex``. Under this folder:<br/>
- The assumption written in qct is saved in a qct file (.i.e ``demoRIFBT_URiteration_1.qct``). <br/>
- The time required to run the assumption is saved in a text file under the same folder (.i.e ``demoRIFBT_URiteration_1time.txt``). <br/>
- If QVtrace is enabled, if the assumption is checked and QVtrace returns ``No violations exist`` as a response, the assumption is saved in a qct file named as ``validAssumption`` under the same folder.<br/>
- Csv files contain the generated test suite.


## Epicurus FSE Results

The results of the paper ``Mining Assumptions for Software Components using Machine Learning`` are under the folder ``results``.<br/>

To process the experimental results of the paper ``Mining Assumptions for Software Components using Machine Learning`` for RQ1, open Matlab and set the folder RQ1 as the currect forlder. Then, run the following scripts:<br/>

- ``RQ1.m``: It computes the percentage of requirements in which IFBT-UR and UR identify a v-safe assumption. It also returns The time required to identify a v-safe assumption respectively for IFBT-UR and UR.<br/>

- ``comparison_of_TCgen_policies.m``: It generates a plot for the comparison of the test generation strategies in terms of effectivemess and execution time . Please note that the information indexes are saved in the text files named by the policy name (UR.txt, ART.txt, IFBT_UR.txt, IFBT_ART.txt).<br/>

To process the experimental results for RQ2, open Matlab and set the folder RQ2 as the currect forlder. Then, run the following scripts:<br/>

- ``RQ2.m``: It computes the percentage of requirements in which IFBT-UR identifies a v-safe assumption. It also returns The time required for IFBT-UR to identify a v-safe assumption.<br/>
