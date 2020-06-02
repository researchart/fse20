#################################
#               RQS             #
#################################

The folder contains two subfolders: RQ1 and RQ2. Each subfolder contains the scripts and data used to get the results in the paper 'Mining Assumptions for Software Components using Machine Learning'. 

------------------------
In both subfolders,
- The scripts to get the results of the research questions RQ1 and RQ2.
- Epicurus results are saved under IP, IP1, IP2.

	* the folder IP contains the data obtained by setting the input signal with one control point (referred by IP in the paper)
	* the folder IP1 contains the data obtained by setting the input signal with two control points (referred by IP’ in the paper)
	* the folder IP2 contains the data obtained by setting the input signal with three control points (referred by IP” in the paper)


Each iteration of EPIcurus generates an assumption. The output of each iteration is saved under IP, IP' or IP" depending on the control points under the path modelFolder/propertyFolder/policyFolder/Run. The output is:

- The assumption written in qct is saved in a qct file (.i.e demoRIFBT_URiteration_1.qct). 

- The time required to run the assumption is saved in a text file under the same folder (.i.e demoRIFBT_URiteration_1time.txt). 

If QVtrace is enabled, if the assumption is checked and QVtrace returns No violations exist as a response, the assumption is saved in a qct file named as validAssumption under the same folder.

- Csv files contain the generated test suite.


The information index results are saved under IPResults , IP1Results and IP2Results:

-IPResults: it contains the results of the information index (INF_INDEX) associated to each policy for IP.
-IP1Results: it contains the results of the information index (INF_INDEX) associated to each policy for IP'.
-IP2Results: it contains the results of the information index (INF_INDEX) associated to each policy for IP".

---------------------



