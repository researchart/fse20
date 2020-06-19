# DENAS: Automated Rule Generation by Knowledge Extraction from Neural Networks

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3898178.svg)](https://doi.org/10.5281/zenodo.3898178)

## Descriptions
![](https://github.com/DENAS-GLOBAL/DENAS/blob/master/Picture/explain.png)
Above is an example of rule-based inference: we highlight the rule with yellow. Any input that satisfies the **rule condition** will be classified into a target category. Such **rules** could represent the behavior of the neural networks.  

In our recent paper, we propose an input-independent deep learning interpretation framework. We find the neuron activation probability is an intrinsic property of the neural networks and this property could model the decision boundary of the neural networks withount a specific input. Below is a Figure from our paper, where we show the stability of this intrinsic property (for details, read our paper).

![](https://github.com/DENAS-GLOBAL/DENAS/blob/master/Picture/Snipaste_2019-11-03_21-39-52.png)

Based on this property, we transform the decision mechanism of the neural networks into a series of rule sets without a specific input.
The produced rule set could explain the behavior of the target neural networks.




## File Structure
* **Android_malware** - Derbin Android malware dataset
    * **data** -data for train and test the model
    * **model** -pre-trained model
    * **Scripts** -the python code to generate the rules
    * **RuleSet** -the directory to  store the rule set
    * **Results** -the directory to store the results
* **Pdf_malware** - Benign/malicious PDFs captured from VirusTotal/Contagio/Google provided by Mimicus.
    * **data** -data for train and test the model
    * **model** -pre-trained model
    * **Scripts** -the python code to generate the rules
    * **RuleSet** -the directory to  store the rule set
    * **Results** -the directory to store the results
* **Binary** - *Function Entry* Identification for Binary Code provided by [ByteWeight ](http://security.ece.cmu.edu/byteweight/) 
    * **data** -data for train and test the model
    * **model** -pre-trained model
    * **Scripts** -the python code to generate the rules
    * **RuleSet** -the directory to  store the rule set
    * **Results** -the directory to store the results

## To Run
`source set.sh`
* **Run Android malware dataset:** \
`cd ./Android_malware`\
`unzip data.rar`\
`unzip model.rar`\
`cd ./Scripts`\
`bash run.sh`
* **Run Pdf malware dataset:** \
`cd ./Pdf_malware`\
`unzip data.rar`\
`cd ./Scripts`\
`bash run.sh`
* **Run ByteWeight dataset:** \
`cd ./Binary`\
`unzip data.rar`\
`cd ./Scripts`\
`bash run.sh`



## Note
The trained models are provided in each directory (if required). Or you could train your model through `train_model.py` in each directory.



