from Experiment import Experiment
import os
exper = Experiment(
    'D:/CodeRepository/PInferLoopInv/PInferLoopInvBechmark/All',
    boogiePath='D:/CodeRepository/PInferLoopInv/Tools/ICE-DT/Boogie/Binaries/Boogie.exe'
    )

os.chdir('D:/CodeRepository/PInferLoopInv/Tools/ICE-DT/Boogie/Binaries')

exper.cleanIntermediateResult()
exper.setRunMode(Experiment.RunMode.DT_Penalty)

exper.setExperiment(limitedTime=60,itemSleep=0,roundSleep=0)

result = exper.experimentAllBplSerially()

exper.GenXlsxFromDict('D:/CodeRepository/PInferLoopInv/PInferLoopInvExperiments/Results',result,infoExtra='ICEDT',titleAdd='ICEDT')
