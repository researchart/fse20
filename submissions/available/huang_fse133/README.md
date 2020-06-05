# Artifacts for paper#133 - Gender Bias in Code Review
### Investigating Gender Bias and Differences in Code Review using Medical Imaging and Eye-Tracking

**Abstract:** Code review is a critical step in modern software quality assurance, yet it is vulnerable to human biases. Previous studies have clarified the extent of the problem, particularly regarding gender biases, but no consensus of understanding has emerged. Advances in medical imaging are increasingly applied to software engineering, supporting grounded neurobiological explorations of computing activities, including the review, reading, and writing of source code.
In this paper, we present the results of a controlled experiment using both medical imaging and also eye tracking to investigate the neurological correlates of gender bias and differences in code review. We find that men and women conduct code reviews differently, in ways that are measurable and supported by behavioral, eye-tracking and medical imaging data. 
We also find biases in how humans review code as a function of its apparent author, when controlling for code quality. In addition to advancing our fundamental understanding of how cognitive biases relate to the code review process, the results may inform subsequent training and tool design to reduce bias. 

## Replication package
### Stimuli [artifact/stimuli]
Each code review stimulus consists of a loading image that displayed an author profile followed by another image that shows the 
corresponding Pull Request. 
The technical contents of the Pull Requests (e.g., the code change, context, and commit message) were taken from historical GitHub data; the
identifying information (e.g., purported names and faces of developers) was experimentally controlled. 
We have two assigned tasks (i.e., v1 and v2), which consist of the same pull requests with different authors assigned.

### Behavioral data [artifact/behavioral]
1. Raw data [artifact/behavioral/answers+keystrokes]
This folder contains all the raw behavioral data: all the timing information for each run for all participants.
Each participant's data is included in a folder named by his/her Participant ID.

For each participant:
+ answers.txt: contains timestamps of the end time of each stimulus (right before the next fixation appears).
+ keystroke.txt: all raw inputs and corresponding timestamps. A stimulus can have multiple inputs (e.g., if a participant pressed a button more than once). We take the last input received
  as the participant's final response. The fMRI buttons are mapped to numeric keys that correspond to each finger in the left and right hands.  The mapping is below:
  + Left Hand ("acceptance"; buttons correspond to thumb to pinky) : ['54','55','56','57','65']
  + Right Hand ("rejection"; buttons correspond to thumb to pinky) : ['49','50','51','52','53']

2. demo-anon.csv: all the sex and gender information, the assigned task version, and degree-pursuing information for all participants. 
More demographic data is included in the survery_results.csv.

3. post-survey.csv: digitalized post-survey information for all participants.

4. survey_results.csv: all the Psychology surveys and paper-folding test results for all participants

5. IAT-results.csv: all the IAT results for all participants.

### Eye-tracking data [artifact/eye-tracking]
1. Raw data [artifact/eye-tracking/raw-data]
This folder contains all the raw eye-tracking data for each run for all participants. Each participant's data is included in a folder named by Participant ID.
In addition, we reformatted and added the pre-processed data to make the processing easier. The current format can be easily used with free data analysis tools such as Ogama.
For each participant, we have the following data:
  + codereview-[participant id].txt is the raw eye-tracking data containing all eye movements recorded by the eye-tracker.
  + OgamaRT_[participant id].csv contains all fixation data (coordinates and fixation duration).
  + Images_[participant id].txt contains the name of stimuli used for the participant in the assigned order.
  + Trials_[participant id].txt contains the start time of each stimulus. This list matches the one recorded in Images_[participant id].txt.

2. Processed data [artifact/eye-tracking/processed-data]
This folder contains three csv files summarizing a set of eye-tracking metrics (e.g., Fixation Count, Fixation Rate	Avg Fixation Duration,
Fixation Saccade Ratio,	Avg Saccade Length) per participant per stimuli. These files can be used to perform statistical analysis.
  + fixation-stats.csv has all the fixation and saccadic metric data for all participants.
  + aoi-stats.csv has all the fixation and saccadic metric data for all AOIs and all participants.
  + aoi-transition.csv has the total number of transitions between each pair of AOIs per stimulus for all participants.


## Contact Us
For more information or if you have any questions/feedbacks, please contact Westley Weimer (weimerw [at] umich [dot] edu ).


