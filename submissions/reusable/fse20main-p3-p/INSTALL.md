The source codes and the results are placed in the [repository](https://github.com/rangeetpan/decomposeDNNintoModules).
- To access the result present in the paper, please access the `Result.xlsx` file and go to the corresponding sheet, e.g., if you want to check the results related to the Table 1, then go to `Table 1` sheet or if you want to check the results related to the Table 2 upper half, then go to the `Table2_Up` sheet.
- The source codes are categorized based on the experimental setup. We have proposed six different approaches to decompose a deep neural network (DNN) into modules. The source code of each technique has been carefully placed under the corresponding folder. For example, for `Tangling Identification: Imbalance (TI-I)`, the code is in `Approach 1 (TI-I)`. Within each folder, there are codes for all the datasets, MNIST, EMNIST, FMNIST, and KMNIST. Since, for each dataset, we have used four different structure of the handmade models, e.g., for MNIST, MNIST-1, MNIST-2, MNIST-3, and MNIST-4. A detailed description of the setup can be found in the paper. For each model and dataset, there is a folder with the source code. For experiments with MNIST-1, the source code can be found under `<approach>\MNIST\MNIST-1`. For each such experiment, we have the trained model and the decomposed modules saved in .h5 format. Since the training and decomposing takes significant time, the trained model and the modules can be reused by simply using the corresponding files. For example, MNIST-1 has one file mnist.h5, which the trained model and module0, module1, ..., module9, which are the decomposed modules from the DNN model. To validate the result, one can use the scripts given in the `Scripts` folder. Please use the [requirements](./requirements.txt) to sync with the correct version of the library to execute the code. 
- For installing the requirements, use
  `pip install requirements`
- For reusing the code related to Table 1 in the paper, please use the `Table1.sh` script. For intra and inter reuse and replacement related results, please use the `Table2-3-Reuse.sh` and `Table4-5-Replacement.sh` respectively.
- The experiments related to the [reuse](./Reuse) and the [replacement](./Replacement) are kept under the corresponding directory. To validate the results, one can either check the `Results.xlsx` or the .txt files provided in the folders, where `outputAcc` stores the accuracy of the reusing or replacing the decomposed modules, `outputAccTrain` stores the training accuracy, `outputSequence` stores the sequence in which the reuse/replacement have been done, and `outputSequenceTrain` stores the sequence in which training occurs. Scripts have been provided to validate the results; however, the training accuracy might change as every time a training occurs, the accuracy of a model cannot be exactly the same as the previous one. In the paper, we have reported an instance of the experiments, and the results from that instance have carefully stored in both .txt format and the .xlsx format.
- The current python version is 3.7.1.
## Example 1: Composed Accuracy of the decomposed modules for MNIST with 1 hidden layer:
- Step 1: Go to the `Scripts` folder.
- Step 2: Execute `./Table1.sh` on the terminal. It gives you the below options.
```
(base) user$ ./Table1.sh
Please choose the correct option for the experiment
1- Tangling Identification: Imbalance (TI-I)
2- Tangling Identification: Punish Negative Examples (TI-PN)
3- Tangling Identification: Higher Priority to Negative Examples (TI- HP)
4- Tangling Identification: Strong Negative Edges (TI-SNE)
5- Concern Modularization: Channeling (CM-C)
6- Concern Modularization: Remove Irrelevant Edges (CM-RIE)
```
- Step 3: Choose the right experiments from the list. For example, if we chose `Concern Modularization: Remove Irrelevant Edges (CM-RIE)`, then please insert `6` for that option.
- Step 4: The script will ask for the choice of the dataset and options are as given below
```
Please choose the correct dataset
1- MNIST
2- Extended MNIST (EMNIST)
3- Fashion MNIST (FMNIST)
4- Kuzushiji MNIST (KMNIST)
```
- Step 5: Choose the right options, e.g., in this example, we choose `1` for MNIST.
- Step 6: Once you choose the dataset, the script will ask for the choice of the structure of the neural network.
```
Please choose the correct model structure
1- One hidden layer
2- Two hidden layers
3- Three hidden layers
4- Four hidden layers
```
Once you choose the right option, e.g., `1` for our example, the code will execute for some minutes. At the end of the execution, the accuracy of the modules and the source model will be notified.
```
Modularized Accuracy: 0.949
Model Accuracy: 0.9491
```
## Example 2: MNIST Intra Reuse:
- Step 1: Go to the `Scripts` folder.
- Step 2: Execute `./Table2-3-Reuse.sh` on the terminal. It gives you the below options.
```
(base) user$ ./Table2-3-Reuse.sh
Please choose the correct option for the experiment
1- MNIST Intra Reuse
2- FMNIST Intra Reuse
3- KMNIST Intra Reuse
4- EMNIST Intra Reuse
5- MNIST-EMNIST Inter Reuse
6- MNIST-KMNIST Inter Reuse
```
Once you choose the right option, e.g., `1` for our example, the code will execute for some minutes. At the end of the execution, the accuracy of the modules and the source model will be reported in four files in `Reuse\MNIST` folder.
A detailed description of each has been given in the above discussion.

## Example 3: MNIST Intra Replacement:
- Step 1: Go to the `Scripts` folder.
- Step 2: Execute `./Table4-5-Replacement.sh` on the terminal. It give you the below options.
```
(base) user$ ./Table4-5-Replacement.sh
Please choose the correct option for the experiment
1- MNIST Intra Replacement
2- FMNIST Intra Replacement
3- KMNIST Intra Replacement
4- EMNIST Intra Replacement
5- MNIST-EMNIST Inter Replacement
6- MNIST-KMNIST Inter Replacement
6- MNIST-KMNIST Inter Reuse
```
Once you choose the right option, e.g., `1` for our example, the code will execute for some minutes. At the end of the execution, the accuracy of the modules and the source model will be reported in four files in `Replacement\MNIST` folder.
A detailed description of each has been given in the above discussion.
