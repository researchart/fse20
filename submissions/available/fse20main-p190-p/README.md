<center>
**ESEC/FSE 2020**

Code Recommendation for Exception Handling

Tam The Nguyen, Phong Minh Vu, Tung Thanh Nguyen

Auburn University, Auburn, Alabama, United States
</center>


## The Tool


### Highlight Exception-Prone Methods

![Figure 0](https://bitbucket.org/tamnguyenthe/exassist_repo/raw/master/resources/figures/highlight.png)


The figure above shows a code example in which programmer is writing code to open and get data from a database. While the programmer is writing the code, ExAssist shows the exception risks and color-code its method calls. For example, the calls cursor.moveToFirst and cursor.moveToNext are red-flagged, bookTitles.add is orange-flagged. That makes the programmer aware that the code is dealing with database and calling cursor's methods might cause unchecked exceptions (runtime exceptions) at runtime. (Without ExAssist, the built-in exception checker in Android Studio only supports adding checked exceptions, thus, does not help her to make appropriate action in this case).


### Recommending Exception Types

The figure below shows the usage of ExAssist in Recommending Exception Types. 

![Figure 1](https://bitbucket.org/tamnguyenthe/exassist_repo/raw/master/resources/figures/first_usage.png)

ExAssist aims to support the developer to make decisions whether
or not to add a try-catch block and what type of exception to caught.
The developer invokes ExAssist by first selecting the portion of
code that she wants to check for exception then pressing Ctrl + Alt + R. Figure 1 shows a screenshot of Android Studio with ExAssist
invoked for the portion of code that using the Cursor object for
reading data from database. 

As seen, ExAssist suggests that the code
is likely to throw an unchecked exception. It also displays a ranked
list of unchecked exceptions that could be thrown from the current
selecting code. Each unchecked exception in the ranked list has a
confident score represents how likely the exception will be thrown
from the code. The value for confident scores is between 0 and 1.
The higher the value of the confident score, the higher likelihood
the exception type is thrown. In this example, SQLiteException has
the highest score of 0.80. If the developer chooses that exception
type, the currently selected code will be wrapped in a try-catch
block with SQLiteException in the catch expression.

ExAssist uses the context of current selecting code to infer
whether or not adding exception handling code and the type of
the exception. For example, in the figure below, the context changes as the
developer selects the portion of code for opening and querying on
the SQLiteDatabase object. 

![Figure 2](https://bitbucket.org/tamnguyenthe/exassist_repo/raw/master/resources/figures/second_usage.png)

Thus, ExAssist updates the recommendation
list with SQLException has the highest confident of 0.81,
which is highest among all other exception types.
ExAssist could provide recommendations for a selected portion
of code includes one or multiple method calls. Additionally, ExAssist
could also recommend not to add try-catch block if it infers
that the selected code is very unlikely to throw an unchecked
exception. For example, if the developer selects the statement bookTitles.add(bookname);
and queries ExAssist, the tool will return an
empty list of exceptions as it is very unlikely the selected method
throws exceptions when it is executed.


### Recommending Exception Repairs
Handling exception situations and executing necessary recovery actions are important as 
it could help apps continue to run properly when an exception
occurs. For example, when an app reuses resources such as database
connections or files, the app should release the resources if
an exception is thrown. ExAssist is also designed to recommend
such repairing actions in the exception handling code based on the
context in the try block. The figure below demonstrates an usage of ExAssist in the task. 

![Figure 3](https://bitbucket.org/tamnguyenthe/exassist_repo/raw/master/resources/figures/third_usage.png)

After adding a try-catch block with SQLiteException for the code in the previous scenario, 
the developer wants to perform recovery actions.
To invoke ExAssist, she moves the cursor to the first line of the catch
and presses Ctrl + Alt + H. ExAssist then will analyze the context
of the code and provide repairing actions in the recommendation
windows. In the example, ExAssist detects that the Cursor object
should be closed to release all of its resources and making it invalid
for further usages. It also suggests to set bookTitles equals null to
indicate the error while collecting data from cursor. If the developer
chooses the recommended actions, ExAssist will generate the code
in the catch block as in the Figure above.

### Downloading The Tool

The tool is available to download at: dx.doi.org/10.6084/m9.figshare.12433667

### Reproducing The Result Presented In The Paper

To reproduce the result presented in the paper, we should run ExAssist on the exception bugs and fixes dataset that we also provided here. For each exception bug, we should rebuild the code scenario and invoke ExAssist to highlight exception-prone methods, recommend exceptio types, and recommend the repairing actions. 

## The Dataset

### Description

In this section, we provide the structural description of the dataset. The dataset is composed of three parts: a description file contains details about exception bug fixes, a description file contains information about the projects that we used to extract the bug fixes, and a folder contains code changes in the bug fixes. 

The description file (exceptionbugs.csv) is a table that describes each exception bug fix in detail. Each row of the table represents a bug fix, while each column represents an attribute of the bug fix. The attributes included in the table are:

* Project: The project that contains the bug fix.
	
* Commit ID: The commit id associates with the bug fix.

* Short Message: The commit message of the bug fix.

* File: The file in the project that contains the bug fix. 

* Method: The API method that causes exceptions. We identify such a method if there is only one method in the try block of the bug fix or the programmer explicitly indicates the method that causes the exception. Otherwise, we marked this field as MULTIPLE. We were able to identify the API method that causes exceptions in 424 cases (56.5%)

* Exception: The exception type occurs in the bug.

* Log: This field indicates whether or not the bug fix contains log statements

* Handle Strategy: This field indicates the handling strategy of programmers. We classified the handling strategy into 3 main types including IGNORE, HANDLE, RETHROW. IGNORE means that programmers add catch blocks but did not perform any handling actions on bug fixes. Note that, we separated logging actions from handling actions. RETHROW means that programmers re-throw another exception in the bug fix, and pass the handling responsibility for the called method. HANDLE means that programmers perform at least one handling actions in the bug fixes. 
	
* Handle Type: If the previous field is marked as HANDLE, this field indicates the type of handling actions performed by programmers. RETURN_VALUE means that programmers add a return statement with a default value, e.g. return false;. While, ASSIGN_VALUE means that programmers assign a default value to variables, e.g. var = false;. Otherwise, METHOD_CALL means that the programmers call at least a method in handling code.

* Github Link: This field stores the Github link for the commit associated with the bug fix. Users can view the code changes in the bug fix by opening this link in a web browser. 

The second file (projects.csv) stores the information about the projects that we used to extract the exception bug fixes. The data includes the name of projects and the corresponding Github repository. The file is needed if users want to clone the projects and do further analysis with the exception bug fixes.

The final part of the dataset is the folder (codechanges) that contains code changes in bug fixes. Each bug fix corresponds with a sub-folder labeled by the index of the bug fix in the description file. A sub-folder includes the pre-version (the bug version) and the post-version (the fix version)  of the source file associated with the bug fix.

### Downloading The Dataset

The dataset is available to download at: dx.doi.org/10.6084/m9.figshare.12433667
