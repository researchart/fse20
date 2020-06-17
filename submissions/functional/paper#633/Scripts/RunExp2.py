from Experiment import Experiment

exper = Experiment(
    '../Benchmarks',
    boogiePath='../Tools/Ours/Exp2/Boogie/Binaries/Boogie.exe',
    proverPath ='../Tools/z3.exe'
    )

exper.cleanIntermediateResult()
#exper.setRunMode(Experiment.RunMode.IDT)
exper.setRunMode(Experiment.RunMode.DT_Penalty)
exper.IDTParser = True
exper.setExperiment(limitedTime=60,itemSleep=0,roundSleep=0)

result = exper.experimentAllBplSerially()

exper.GenXlsxFromDict('../Results',result,infoExtra='Exp2',titleAdd='Exp2')
