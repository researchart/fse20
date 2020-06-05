# DENAS: Automated Rule Generation by Knowledge Extraction from Neural Networks

## Descriptions
![](https://github.com/DENAS-GLOBAL/DENAS/blob/master/Picture/explain.png)
Above is an example of rule-based inference: we highlight the rule with yellow. Any input that satisfies the **rule condition** will be classified into a target category. Such **rules** could represent the behavior of the neural networks.  

In our recent paper, we propose an input-independent deep learning interpretation framework. We find the neuron activation probability is an intrinsic property of the neural networks and this property could model the decision boundary of the neural networks withount a specific input. Below is a Figure from our paper, where we show the stability of this intrinsic property (for details, read our paper).

![](https://github.com/DENAS-GLOBAL/DENAS/blob/master/Picture/Snipaste_2019-11-03_21-39-52.png)


Based on this property, we transform the decision mechanism of the neural networks into a series of rule sets without a specific input.
The produced rule set could explain the behavior of the target neural networks.




## File Structure
* **Android_malware** - Derbin Android malware dataset
* **Pdf_malware** - Benign/malicious PDFs captured from VirusTotal/Contagio/Google provided by Mimicus.
* **Binary** - *Function Entry* Identification for Binary Code provided by [ByteWeight ](http://security.ece.cmu.edu/byteweight/) 


## To Run
`source set.sh`
* **Run Android malware dataset:** \
`cd ./Android_malware/Scripts`\
`bash run.sh`
* **Run Pdf malware dataset:** \
`cd ./Pdf_malware/Scripts`\
`bash run.sh`
* **Run ByteWeight dataset:** \
`cd ./Binary/Scripts`\
`bash run.sh`



## Note
The trained models are provided in each directory (if required). The model for Drebin dataset are not part of this repo as they are too large to be hosted on GitHub. Or you could train your model through `train_model.py` in each directory.



