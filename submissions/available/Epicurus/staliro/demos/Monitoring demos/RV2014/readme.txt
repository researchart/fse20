==============
Introduction
==============

This demo is the implementation for the following paper:
Adel Dokhanchi, Bardh Hoxha and Georgios Fainekos, 
On-Line Monitoring for Temporal Logic Robustness, 
Runtime Verification, Toronto, Canada, September 2014 

This paper is available in the following Link:
https://doi.org/10.1007/978-3-319-11164-3_19

The proof of the paper is available in the following Link: 
http://arxiv.org/abs/1408.0045

In the "On-line Monitoring for Temporal Logic Robustness" paper, we reported the 
runtime results of this demo with running 100 number of tests for each formula.


==================
Directory contents
==================
- demo_autotrans_monitoring_2013b.mdl 
	
	A Simulink model that demonstrates the use of the S-Taliro monitoring block.
	Open the model and press the "Run" button. The time robustness will be 
	presented on the scope.
	
	Double click the S-Taliro_Monitor block to change the formula and the atomic
	propositions, or press the Help button to see the help file.
	
- benchmarking_autotrans_monitoring.m
	
	This m-file is benchmarking the S-Taliro monitor.
	It will collect statistics for all the formulas by running "nTest" number of
	tests for each formula.
	
	It does not return the robustness values computed.


