from Experiment import Experiment

exper = Experiment(
    '../Benchmark',
    boogiePath='../Tools/Ours/Dig/Boogie/Binaries/Boogie.exe',
    proverPath ='../Tools/z3.exe',
    learnerPath='../Tools/Ours/IDT4Inv/build/'
    )

exper.cleanIntermediateResult()
exper.setRunMode(Experiment.RunMode.IDT)

exper.setExperiment(limitedTime=60,itemSleep=0,roundSleep=0)

result = exper.experimentAllBplSerially()

exper.GenXlsxFromDict('../Results',result,infoExtra='Dig',titleAdd='Dig')
