#!/bin/bash
python ./TreeLearning.py 
python3 ./fidelity.py 
python3 ./ExplainModel.py 
python ./testRuleSet.py 
python ./stability.py | tee ../Results/stability.txt