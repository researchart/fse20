from Experiment import Experiment
import os
exper = Experiment(
    '../Benchmark',
    boogiePath='../Tools/ICE-DT(Baseline)/Boogie/Binaries/Boogie.exe',
    proverPath ='../Tools/z3.exe'
    )


exper.cleanIntermediateResult()
exper.setRunMode(Experiment.RunMode.DT_Penalty)

exper.setExperiment(limitedTime=60,itemSleep=0,roundSleep=0)

result = exper.experimentAllBplSerially()

exper.GenXlsxFromDict('../Results',result,infoExtra='ICEDT',titleAdd='ICEDT')
