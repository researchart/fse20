
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

## Description of the Outputs of EPIcuRus

After performing the steps in the Tutorial, a message will be shown in the Command Window in Matlab indicating that  EPIcuRus finishes running and results are saved under: result/demo/R/IFBT_UR. This folder contains the output of Epicurus.

The output of EPIcuRus is saved under the folder ``result``.  <br/>
Each iteration of EPIcurus generates an assumption. The output of each iteration is saved under the run folder ``result/modelFolder/propertyFolder/policyFolder/RunIndex``. Under this folder:<br/>
- The assumption written in qct is saved in a qct file (.i.e ``demoRIFBT_URiteration_1.qct``). <br/>
- The time required to run the assumption is saved in a text file under the same folder (.i.e ``demoRIFBT_URiteration_1time.txt``). <br/>
- If QVtrace is enabled, if the assumption is checked and QVtrace returns ``No violations exist`` as a response, the assumption is saved in a qct file named as ``validAssumption`` under the same folder.<br/>
- Csv files contain the generated test suite.

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




