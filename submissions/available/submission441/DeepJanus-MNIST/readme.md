# Test Input Generator for MNIST #

## General Information ##
This folder contains the application of the DeepJanus approach to the handwritten digit classification problem.
This tool is developed in Python on top of the DEAP evolutionary computation framework. It has been tested on a machine featuring an i7 processor, 16 GB of RAM, an Nvidia GeForce 940MX GPU with 2GB of memory and an Ubuntu OS.

## Dependencies ##

### Installing Python Binding to the Potrace library ###
Instructions provided by https://github.com/flupke/pypotrace.

Install system dependencies:

``` 
$ sudo apt-get install build-essential python-dev libagg-dev libpotrace-dev pkg-config 
```

Install pypotrace:

```
$ git clone https://github.com/flupke/pypotrace.git
$ cd pypotrace
$ pip3 install numpy
$ pip3 install .
$ cd .. .
```

### Installing PyCairo and PyGObject ###
Instructions provided by https://pygobject.readthedocs.io/en/latest/getting_started.html#ubuntu-getting-started.

Open a terminal and execute 

```sudo apt-get install python3-gi python3-gi-cairo gir1.2-gtk-3.0```

Open a terminal, enter your virtual environment and execute:

```sudo apt-get install libgirepository1.0-dev gcc libcairo2-dev pkg-config python3-dev gir1.2-gtk-3.0 librsvg2-dev```

To install Pycairo, execute:

```pip3 install pycairo==1.11.1```

To install PyGObject, execute:

```pip3 install PyGObject==3.30.4```


### Installing Other Dependencies ###

This tool has other dependencies such as tensorflow and deap.

To easily install the dependencies with pip, we suggest to create a dedicated virtual environment and run the command:

```pip install -r requirements.txt```

Otherwise, you can manually install each required library listed in the requirements.txt file using pip.

## Usage ##

### Input ###

* A trained model in h5 format. The default one is in the folder models;
* A list of seeds used for the input generation. In this implementation, the seeds are indexes of elements of the MNIST dataset. The default list is in the file _first_generation_five_;
* _properties.py_ containing the configuration of the tool selected by the user.

### Output ###
When the run is finished, the tool produces the following outputs in the folder specified by the user:
* _config.json_ reporting the configuration of the tool;
* _report.json_ containing the final report of the run;
* the folder _archive_ containing the generated inputs (both in array and image format).

### Run the Tool ###
Run the command:
`python main.py`
