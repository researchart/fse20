# Replication package for "Search-Based Adversarial Testing and Improvement of Constrained Credit Scoring Systems", accepted at FSE 2020

This `README` file explains the structure of the package and gives basic guidelines on how to re-execute the experiments. For more detailed instructions on how to install and execute the scripts, please, refer to `INSTALL.md`.

For more information, contact the first author by e-mail: Salah Ghamizi \<salah.ghamizi@uni.lu\>

---
## About
We present CoEva2, a multi-objective search technique to generate adversarial attacks against real-life systems. It uses domain specific constraints and domain specific objectives to craft the attacks. The paper tackles an industrial system and dataset under NDA that we cannot disclose (related to overdraft and credit scoring). In accordance with the Artifact Chair, we are providing a replication study on a public dataset called *Lending Club Loan data*. It shows both how to implement our approach on available datasets and that our results are valid for other contexts. 
See `INSTALL.md` for installation instructions.
## Folder structure:
* ./data: where the study dataset is located.
* ./out: where the experiments results are located, including the random forest model.
* ./experiments: indivdual scripts that cover the research questions of the paper and their visualizations.
* ./configurations: the configuration files (*json*) to customize the experiments without coding.
* ./src/coeva2: the actual implementation of our approach.
## Setup the dataset
Our experiments involve the Lending Club Loan Dataset. You can download the processed version [here](). You can have mon information on the dataset [here](https://www.kaggle.com/wendykan/lending-club-loan-data)
For the FSE review, the dataset is already provided in the folder *./data*
## Setup the model
For the FSE review, we provide a trained Random Forest model in the folder *./out/target_model* You can use the train python script to train your own model.
```shell
python ./train.py
```  
## Experiments
You can either run all the attack experiments or only the analysis.
The available experiments are:
* random: Run a random search (RQ1)
* papernot: Use an iterative papernot attack (RQ1)
* f1f2f3f4: Run a multiobjective search with the 4 objectives f1, f2, f3, f4 (RQ2)
* f1f2f4: Run a multiobjective search with the 3 objectives f1, f2, f3, f4 (RQ2)
* f1f3f4: Run a multiobjective search with the 3 objectives f1, f2, f3, f4 (RQ2)
* retrain: Adversarial training with the f1f2f3f4 adversarial (RQ3)

```shell
# Running the analysis with pre-run experiments
python ./experiments_results.py


# Running the whole experiments and display their results 
# The optional parameter -x allow you to specify only one experiment 
python ./experiments.py [-x random|f1f2f3f4|f1f3f4|f1f2f4|papernot|retrain]
```  

## Customization

### Custom configuration
You can extend or customize the search using the custom.py file 

```shell
# The required parameter -c allows you to specify the json configuration file to use 
# The optional parameter -i allow you to specify a unique ID for the experiment run. 
# The output files will be located in a folder associaed with this ID. 
# If not provided, the current timestamp will be used 
python ./custom.py -c [-i RUN_ID]
``` 

Configuration files are located in the folder **./configurations**, for instance *config_1.json* introduces the main elements of customization:
```json
{
  "experiment_path": ""

}
``` 
