# IoTCheck

## IoTCheck Framework

This artifact is the IoTCheck framework that we have developed to automatically detect conflicts between smart home apps.
To ease the installation process, we have packaged IoTCheck to run on Vagrant. 
Please start from installing Vagrant as explained (in the [README.md](https://github.com/uci-plrg/iotcheck-vagrant/blob/master/README.md)) in the following link.

https://github.com/uci-plrg/iotcheck-vagrant

Then please follow the instructions (in the [README.md](https://github.com/uci-plrg/iotcheck/blob/master/README.md)) for IoTCheck in the following link.

https://github.com/uci-plrg/iotcheck

We have also documented IoTCheck in greater detail in the [IoTCheck Wiki](https://github.com/uci-plrg/iotcheck/wiki).

https://github.com/uci-plrg/iotcheck/wiki

## IoTCheck Supporting Materials

This artifact consists of spreadsheets that capture the statistics we obtained during our manual study and automated experiments with IoTCheck.
To download this artifact please open 

https://github.com/uci-plrg/iotcheck-data.

We have provided more information and instructions about the artifact in the [README.md](https://github.com/uci-plrg/iotcheck-data/blob/master/README.md).

#### Reproducing Our Results

As we have recommended [here](https://github.com/uci-plrg/iotcheck#further-notes), it is better to start running IoTCheck for categories with shorter lists of apps, e.g., `acfanheaterSwitches`, `cameraSwitches`, and `ventfanSwitches`. For example, if we [run IoTCheck for the `acfanheaterSwitches` group](https://github.com/uci-plrg/iotcheck#experiments), we will see log files generated in `iotcheck/logs/acfanheaterSwitches`. All the log files will report conflicts between pairs, except for the pair `its-too-cold.groovy` and `its-too-hot.groovy`: IoTCheck will declare that there is no conflict between the two apps. We can check these results against the tab `Other Switches` of the spreadsheet `Switches.xlsx` stored in [`iotcheck-data/Device Interaction/Automation`](https://github.com/uci-plrg/iotcheck-data/tree/master/Device%20Interaction/Automation).
