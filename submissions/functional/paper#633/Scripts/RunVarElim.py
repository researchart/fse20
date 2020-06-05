from Experiment import Experiment

exper = Experiment(
    'D:/CodeRepository/PInferLoopInv/PInferLoopInvBechmark/All',
    boogiePath='D:/CodeRepository/PInferLoopInv/Tools/Ours/VarElim/Boogie/Binaries/Boogie.exe',
    proverPath ='D:/CodeRepository/PInferLoopInv/Tools/z3.exe',
    learnerPath='D:/CodeRepository/PInferLoopInv/Tools/Ours/IDT4Inv/build/',
    )

exper.cleanIntermediateResult()
exper.setRunMode(Experiment.RunMode.IDT)

exper.setExperiment(limitedTime=60,itemSleep=0,roundSleep=0)

result = exper.experimentAllBplSerially()

exper.GenXlsxFromDict('D:/CodeRepository/PInferLoopInv/PInferLoopInvExperiments/Results',result,infoExtra='Elim',titleAdd='Elim')
