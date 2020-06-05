import os
import platform
import enum
import time
import re
import subprocess
import multiprocessing
import xlsxwriter
import psutil

class Experiment:
    __experimentName = 'PInferLoopInv Experiment'
    __gitVersion = ''
    __benchmarkDir = ''
    __benchmarkList = []
    __bplPath = {}
    __boogiePath = None
    __learnerPath = None
    __proverPath = None

    def boogieSetting(self,boogiePath):
        if os.path.isfile(boogiePath):
            self.__boogiePath=boogiePath
        else:
            raise Exception('Boogie setting error: File {0} not find.'.format(boogiePath))

    @enum.unique
    class RunMode(enum.Enum):
        Undefined   = 0
        ICE         = 10
        DT_Penalty  = 20
        DT_Entropy  = 21
        IDT         = 30
    __runMode = RunMode.Undefined

    def setRunMode(self,runMode):
        if not type(runMode) == type(Experiment.RunMode.Undefined):
            raise TypeError('RunMode must be the type of PInferLoopInv.RunMode')
        self.__runMode = runMode

    @property
    def runCommandPrefix(self):
        prefix = ('mono ' if not platform.system() == 'Windows' else '') + \
            ((('./' if not platform.system() == 'Windows' else '') + 'Boogie.exe') 
            if self.__boogiePath is None else self.__boogiePath) + ' /nologo /noinfer /contractInfer '
        if self.__runMode == Experiment.RunMode.Undefined:
            raise Exception('Run mode is undefined.')
        elif self.__runMode == Experiment.RunMode.ICE:
            prefix += '/ice /printAssignment '
        elif self.__runMode == Experiment.RunMode.DT_Penalty:
            prefix += '/mlHoudini:dt_penalty '
        elif self.__runMode == Experiment.RunMode.DT_Entropy:
            prefix += '/mlHoudini:dt_entropy '
        elif self.__runMode == Experiment.RunMode.IDT:
            prefix += '/mlHoudini:IDT4Inv '
        else:
            raise Exception('Unknown run mode')
        if self.__learnerPath is not None:
            # prefix += '/trace /printAssignment /mlHoudiniLearnerDir:' + self.__learnerPath + ' '
            prefix += '/mlHoudiniLearnerDir:' + self.__learnerPath + ' '
        if self.__proverPath is not None:
            prefix += '/z3exe:' + self.__proverPath + ' '
        # print(prefix)
        return prefix

    def __init__(self,benchmarkDir,boogiePath = None,learnerPath = None,proverPath = None,experimentName = 'PInferLoopInv Experiment',skipBenchmark=[]):
        __experimentName = experimentName
        if not boogiePath is None:
            self.boogieSetting(boogiePath)
        if not os.path.exists(benchmarkDir):
            raise Exception('PInferLoopInv initializing error: Cannot find path ' + benchmarkDir)
        if not os.path.isdir(benchmarkDir):
            raise Exception('PInferLoopInv initializing error: Path ' + benchmarkDir + ' is not a directory')
        self.__benchmarkDir = benchmarkDir
        self.__learnerPath = learnerPath
        self.__proverPath = proverPath
        benchmarkNameFilePath = os.path.join(benchmarkDir,'BenchmarkName.txt')
        if os.path.exists(benchmarkNameFilePath) and os.path.isfile(benchmarkNameFilePath):
            fopen = open(benchmarkNameFilePath)
            self.__benchmarkList = list(map(lambda x: x.replace('\n',''),fopen.readlines()))
            fopen.close()
        else:
            self.__benchmarkList = list(filter(lambda x: os.path.isdir(os.path.join(self.__benchmarkDir,x)),
                os.listdir(self.__benchmarkDir)))
            # Skip benchmarks
            for skipName in skipBenchmark:
                if skipName in self.__benchmarkList:
                    self.__benchmarkList.remove(skipName)
        self.__fileExistsCheck()
        if boogiePath != None:
            os.chdir(os.path.dirname(boogiePath))
            self.__gitVersion = os.popen('git rev-parse --short HEAD').read().strip()
            print(self.__gitVersion)

    def __fileExistsCheck(self):
        for item in self.__benchmarkList:
            # Skip TimeOut
            itemPath = os.path.join(self.__benchmarkDir,item)
            if not os.path.exists(itemPath):
                raise Exception('PInferLoopInv benchmark check error: Cannot find path ' + itemPath)
            itemFiles = list(filter(lambda x: os.path.isfile(os.path.join(itemPath,x)) 
                and x.split('.')[-1] == 'bpl',os.listdir(itemPath)))
            if len(itemFiles) != 1:
                raise Exception('PInferLoopInv benchmark check error: {0} bpl files found in {1}'
                    .format(len(itemFiles),itemPath))
            bplFilePath = os.path.join(itemPath,itemFiles[0])
            self.__bplPath[item] = bplFilePath
            # if not os.path.exists(bplFilePath+'.names') or not os.path.isfile(bplFilePath+'.names'):
            #     raise Exception('PInferLoopInv benchmark check error: File {0} not found in {1}'
            #         .format(bplFilePath+'.names',itemPath))
            # if not os.path.exists(bplFilePath+'.intervals') or not os.path.isfile(bplFilePath+'.intervals'):
            #     raise Exception('PInferLoopInv benchmark check error: File {0} not found in {1}'
            #         .format(bplFilePath+'.intervals',itemPath))
        
    def experimentOneBpl(self,benchmarkName):
        self.log('Start running benchmark: {0} ...'.format(benchmarkName))
        if not benchmarkName in self.__benchmarkList:
            raise Exception('Run benchmark error: Benchmark {0} not found in {1}'
                    .format(benchmarkName,self.__benchmarkDir))
        result = self.runCommand(benchmarkName)
        stdout = None
        if result is not None:
            stdout = result[0]
            print(stdout.decode(encoding='utf-8'))
        time.sleep(self.experimentSetting.itemSleep)
        return self.resultParser(benchmarkName,stdout)

    def experimentAllBplSerially(self):
        self.log('Start experiment serially.')
        result = {}
        for benchmarkName in self.__benchmarkList:
            itemResult = self.experimentOneBpl(benchmarkName)
            result[benchmarkName] = itemResult
        return result
    
    def experimentAllBplRounds(self,func = experimentAllBplSerially,rounds=1):
        resultRounds = []
        for roundIndex in range(0,rounds):
            self.log('Experiment round #{0} started...'.format(roundIndex))
            result_round = func()
            resultRounds.append(result_round)
            time.sleep(self.experimentSetting.roundSleep)
            self.log('Experiment round #{0} finished.'.format(roundIndex))
        return resultRounds

    def runCommand(self,benchmarkName):
        bplPath = self.__bplPath.get(benchmarkName)
        if bplPath == None:
            raise Exception('Run command error: bpl not found in ' + benchmarkName)
        command = self.runCommandPrefix + bplPath
        if not self.experimentSetting.isShellKiller:
            print(command)
            process = subprocess.Popen(command,shell=True,stdout=subprocess.PIPE)
            # startTime = time.time()
            # while startTime + self.experimentSetting.limitedTime > time.time() and process.returncode == None:
            #     time.sleep(self.experimentSetting.aliveCheckTime)
            # print(x)
            try:
                x = process.communicate(timeout=self.experimentSetting.limitedTime)
                # process.wait(timeout=self.experimentSetting.limitedTime)
            # except subprocess.CalledProcessError:
            #     process.terminate()
            #     self.log('RuntimeError in benchmark {0}'.format(benchmarkName))
            #     # Ensure the subprocesses are all killed!
            #     for proc in psutil.process_iter():
            #         # check whether the process name matches
            #         if proc.name() == "z3" or proc.name() == "boogie" or proc.name() == "z3.exe" or proc.name() == "boogie.exe":
            #             proc.kill()
            #     return None
            except subprocess.TimeoutExpired:
                process.terminate()
                self.log('Timeout >{0} second(s) or RuntimeError in benchmark {1}'.format(self.experimentSetting.limitedTime,benchmarkName))
                # Ensure the subprocesses are all killed!
                for proc in psutil.process_iter():
                    # check whether the process name matches
                    if proc.name() == "z3" or proc.name() == "boogie" or proc.name() == "z3.exe" or proc.name() == "boogie.exe":
                        proc.kill()
                return None
            else:
                return x
                # return process.communicate()

            # if process.poll() == None:
            #     process.terminate()
            #     self.log('Timeout >{0} second(s) in benchmark {1}'.format(self.experimentSetting.limitedTime,benchmarkName))
            #     return None
            # return process.communicate()
        else:
            raise NotImplementedError
        
    def cleanIntermediateResult(self):
        # Based on git previously: [Discard]
        # os.popen('cd ' + self.__benchmarkDir + '; git clean -xfd')
        # Now based on os interfaces:
        for benchName in os.listdir(self.__benchmarkDir):
            innerDir = os.path.join(self.__benchmarkDir,benchName)
            if not os.path.isdir(innerDir):
                continue
            for fileItem in os.listdir(innerDir):
                if fileItem.endswith(".json") or fileItem.endswith(".debug") or fileItem.endswith(".data") \
                        or fileItem.endswith(".tree") or fileItem.endswith(".tmp") or fileItem.endswith(".out") \
                            or fileItem.endswith(".implications") or fileItem.endswith(".names") or fileItem.endswith(".intervals"):
                    os.remove(os.path.join(innerDir, fileItem))

    class ExperimentSetting:
        def __init__(self,limitedTime = 60,itemSleep = 0,roundSleep = 0,poolSize = 1,aliveCheckTime = 0.5,isShellKiller = False):
            self.limitedTime    = limitedTime
            self.itemSleep      = itemSleep
            self.roundSleep     = roundSleep
            self.poolSize       = poolSize
            self.aliveCheckTime = aliveCheckTime
            self.isShellKiller  = isShellKiller
    __experimentSetting = None

    @property
    def experimentSetting(self):
        if self.__experimentSetting == None:
            self.__experimentSetting = Experiment.ExperimentSetting()
        else:
            if not type(self.__experimentSetting) == type(Experiment.ExperimentSetting()):
                raise Exception('Inner Error: __experimentSetting is not PInferLoopInv.ExperimentSetting')
        return self.__experimentSetting

    def setExperiment(self,limitedTime = 60,itemSleep = 0,roundSleep = 0,
        poolSize = 1,aliveCheckTime = 0.5,isShellKiller = False):
        # del(self.__experimentSetting)
        if poolSize > multiprocessing.cpu_count():
            self.log('Warning: processing pool size is large than the cpu cores.')
        self.__experimentSetting = Experiment.ExperimentSetting(
            limitedTime     = limitedTime,
            itemSleep       = itemSleep,
            roundSleep      = roundSleep,
            poolSize        = poolSize,
            aliveCheckTime  = aliveCheckTime,
            isShellKiller   = isShellKiller
            )

    class ExperimentItemResult:
        def __init__(self,benchmarkName,info = '',finishedTime = time.time(),
            time = None,pos = None,neg = None,impl = None,rounds = None,
            proverTime = None,learnerTime = None,verified = None,error = None,
            sat = None,ssat = None,cexPos = 0,cexPos_G = 0,cexNeg = 0,cexNeg_G = 0,
            cexUnk = 0,cexImpl = 0,cexPos_M = 0,cexNeg_M = 0):
            self.benchmarkName  = benchmarkName
            self.info           = info,
            self.finishedTime   = finishedTime
            self.time           = time
            self.pos            = pos
            self.neg            = neg            
            self.impl           = impl
            self.rounds         = rounds
            self.proverTime     = proverTime
            self.learnerTime    = learnerTime
            self.verified       = verified
            self.error          = error
            self.sat            = sat
            self.ssat           = ssat
            self.cexPos         = cexPos
            self.cexPos_G       = cexPos_G            
            self.cexNeg         = cexNeg
            self.cexNeg_G       = cexNeg_G
            self.cexUnk         = cexUnk
            self.cexImpl        = cexImpl
            self.cexPos_M       = cexPos_M
            self.cexNeg_M       = cexNeg_M
        
    def resultParser(self,benchmarkName,content,detailed=True):
        if self.__runMode is Experiment.RunMode.Undefined:
            raise Exception('Result parser error: Undefined run mode.')
        if content is None:
            return Experiment.ExperimentItemResult(benchmarkName,info='Timeout')
        if "Prover error" in content.decode():
            return Experiment.ExperimentItemResult(benchmarkName,info='RE')
        content = content.decode(encoding='utf-8')
        reExpressions = {
            'time'          :r'Total time: (.*)',
            'pos'           :r'Number of positive examples:(.*)' if self.__runMode is Experiment.RunMode.IDT or self.IDTParser == True else 
                            r'Number of examples:(.*)',
            'neg'           :r'Number of negative counter-examples:(.*)' if self.__runMode is Experiment.RunMode.IDT or self.IDTParser == True else 
                            r'Number of counter-examples:(.*)',
            'impl'          :r'Number of implications:(.*)',
            'proverTime'    :r'Prover time = (.*)',
            'learnerTime'   :r'C5 Learner time = (.*)',
            'verified'      :r'Boogie program verifier finished with (.*) verified,',
            'error'         :r'verified, (.*) error',
            # 'sat'           :r'Number of unsat core solver queries :(.*)',
            # 'ssat'          :r'Number of succeed unsat core solver queries :(.*)',
            'rounds'        :r'Number of Z3 Learner queries = (.*)' if self.__runMode is Experiment.RunMode.ICE else 
                            r'Number of C5 Learner queries = (.*)'
        }
        #TODO: check rightness of reResult
        reResult = {key: None if re.search(value,content).group() is None else re.search(value,content).group(1) 
            for key,value in reExpressions.items()}
        funcNoneOtherwiseFunc = lambda x,func: None if x is None else func(x)
        cexPos         = None
        cexPos_G       = None
        cexNeg         = None
        cexNeg_G       = None
        cexUnk         = None
        cexImpl        = None
        cexPos_M    = None
        cexNeg_M    = None
        if detailed:
            if self.__runMode is Experiment.RunMode.IDT or self.IDTParser == True:
                path = os.path.join(self.__benchmarkDir,benchmarkName,benchmarkName + ".data")
                path_G = os.path.join(self.__benchmarkDir,benchmarkName,benchmarkName + ".dup.data")
                path_I = os.path.join(self.__benchmarkDir,benchmarkName,benchmarkName + ".implications")
                cexPos = 0
                cexNeg = 0
                cexPos_G = 0
                cexNeg_G = 0
                cexUnk = 0
                cexImpl = 0
                cexPos_M = 0
                cexNeg_M = 0
                if os.path.exists(path_I):
                    file_I = open(path_I)
                    for line in file_I.readlines():
                        if ' ' in line:
                            cexImpl += 1
                    file_I.close()
                if os.path.exists(path_G):
                    file_G = open(path_G)
                    for line in file_G.readlines():
                        if 'false' in line:
                            cexNeg += 1
                            pairs = re.findall(r"\((.*?),(.*?)\)",line)
                            for pair in pairs:
                                if pair[0] != pair[1]:
                                    cexNeg_G += 1
                                    break
                        elif 'true' in line:
                            cexPos += 1
                            pairs = re.findall(r"\((.*?),(.*?)\)",line)
                            for pair in pairs:
                                if pair[0] != pair[1]:
                                    cexPos_G += 1
                                    break
                        elif '?' in line:
                            cexUnk += 1
                    file_G.close()

                if os.path.exists(path):
                    file_A = open(path)
                    for line in file_A.readlines():
                        if 'false' in line:
                            cexNeg_M += 1
                        elif 'true' in line:
                            cexPos_M += 1
                    file_A.close()
                    cexNeg_M = cexNeg - cexNeg_M
                    cexPos_M = cexPos - cexPos_M
                return Experiment.ExperimentItemResult(benchmarkName,
                    time        = funcNoneOtherwiseFunc(reResult.get('time'),float),
                    pos         = funcNoneOtherwiseFunc(reResult.get('pos'),int),
                    neg         = funcNoneOtherwiseFunc(reResult.get('neg'),int),
                    impl        = funcNoneOtherwiseFunc(reResult.get('impl'),int),
                    rounds      = funcNoneOtherwiseFunc(reResult.get('rounds'),int),
                    proverTime  = funcNoneOtherwiseFunc(reResult.get('proverTime'),float),
                    learnerTime = funcNoneOtherwiseFunc(reResult.get('learnerTime'),float),
                    verified    = funcNoneOtherwiseFunc(reResult.get('verified'),int),
                    error       = funcNoneOtherwiseFunc(reResult.get('error'),int),
                    cexPos = cexPos,
                    cexNeg = cexNeg,
                    cexPos_G = cexPos_G,
                    cexNeg_G = cexNeg_G,
                    cexUnk = cexUnk,
                    cexImpl = cexImpl,
                    cexPos_M = cexPos_M,
                    cexNeg_M = cexNeg_M
                    )

        return Experiment.ExperimentItemResult(benchmarkName,
                time        = funcNoneOtherwiseFunc(reResult.get('time'),float),
                pos         = funcNoneOtherwiseFunc(reResult.get('pos'),int),
                neg         = funcNoneOtherwiseFunc(reResult.get('neg'),int),
                impl        = funcNoneOtherwiseFunc(reResult.get('impl'),int),
                rounds      = funcNoneOtherwiseFunc(reResult.get('rounds'),int),
                proverTime  = funcNoneOtherwiseFunc(reResult.get('proverTime'),float),
                learnerTime = funcNoneOtherwiseFunc(reResult.get('learnerTime'),float),
                verified    = funcNoneOtherwiseFunc(reResult.get('verified'),int),
                error       = funcNoneOtherwiseFunc(reResult.get('error'),int)#,
                # sat         = funcNoneOtherwiseFunc(reResult.get('sat'),int),
                # ssat        = funcNoneOtherwiseFunc(reResult.get('ssat'),int)
                )

    @enum.unique
    class LogMode(enum.Enum):
        StdIO = 0
        Socket = 10
    __logMode = LogMode.StdIO
    __logSocketIP = '127.0.0.1'
    __logSocketPort = 9423

    def setLogMode(self,logMode,ip = '127.0.0.1',port = 9423):
        if not type(logMode) == type(Experiment.LogMode.StdIO):
            raise TypeError('RunMode must be the type of PInferLoopInv.RunMode')
        self.__logMode = logMode
        if logMode == Experiment.LogMode.Socket:
            self.__logSocketIP = ip
            self.__logSocketPort = port

    def log(self,content):
        if self.__logMode is Experiment.LogMode.StdIO:
            print(content)
            return
        elif self.__logMode is Experiment.LogMode.Socket:
            # TODO: 
            raise NotImplementedError
        else:
            raise Exception('Unknown log mode')

    def GenXlsxFromDict(self,outputDir,result,fileNameExtra='',infoExtra='',titleAdd=''):
        timeNow = time.localtime()
        fileName = os.path.join(outputDir,'Expr_{4}_{0}_{1}_{2}_{3}.xlsx'.format(fileNameExtra,time.strftime('%Y-%m-%d-%H-%M-%S',timeNow),self.__gitVersion,self.__runMode,titleAdd))
        workbook = xlsxwriter.Workbook(fileName)
        worksheetInfo = workbook.add_worksheet('Info')
        worksheetInfo.write('A1', 'Experiment time:')
        worksheetInfo.write('B1', time.strftime('%Y-%m-%d %H:%M:%S',timeNow))
        worksheetInfo.write('A2', 'Run mode:')
        worksheetInfo.write('B2', str(self.__runMode).split('.')[-1])
        worksheetInfo.write('A3', 'Boogie path:')
        worksheetInfo.write('B3', './Boogie' if self.__boogiePath is None else self.__boogiePath)
        worksheetInfo.write('A4', 'Benchmark directory:')
        worksheetInfo.write('B4', self.__benchmarkDir)
        worksheetInfo.write('A5', 'OS:')
        worksheetInfo.write('B5', platform.platform())
        worksheetInfo.write('A6', 'Logical CPU Cores:')
        worksheetInfo.write('B6', psutil.cpu_count())
        worksheetInfo.write('A7', 'Physical CPU Cores:')
        worksheetInfo.write('B7', psutil.cpu_count(logical=False))
        worksheetInfo.write('A8', 'Memory:')
        worksheetInfo.write('B8', str(round(psutil.virtual_memory().total / (1024.0 * 1024.0 * 1024.0), 2))+'GB')
        worksheetInfo.write('A9', 'Others:')
        worksheetInfo.write('B9', infoExtra)
        if type(result) is type({}):
            result = [result]
        for roundIndex in range(0,len(result)):
            resultRound = result[roundIndex]
            worksheetRound = workbook.add_worksheet('round_{0}'.format(roundIndex))
            worksheetRound.write('A1', 'Source Name')
            worksheetRound.write('B1', 'Positive Nums')
            worksheetRound.write('C1', 'Negative Nums')
            worksheetRound.write('D1', 'Implication Nums')
            worksheetRound.write('E1', 'Round Nums')
            worksheetRound.write('F1', 'Total Time')
            worksheetRound.write('G1', 'Prover Time')
            worksheetRound.write('H1', 'Learner Time')
            worksheetRound.write('I1', 'Verified')
            worksheetRound.write('J1', 'Errors')
            worksheetRound.write('K1', 'Info')
            worksheetRound.write('L1', 'cexPos')
            worksheetRound.write('M1', 'cexNeg')
            worksheetRound.write('N1', 'cexPos_G')
            worksheetRound.write('O1', 'cexNeg_G')
            worksheetRound.write('P1', 'cexUnk')
            worksheetRound.write('Q1', 'cexImpl')
            worksheetRound.write('R1', 'cexPos_M')
            worksheetRound.write('S1', 'cexNeg_M')
            # worksheetRound.write('K1', 'SAT')
            # worksheetRound.write('L1', 'SSAT')
            lineIndex = 1
            funcEmptyStrIfNoneOtherwiseFunc = lambda x,func: '' if x is None else func(x)
            for key,value in resultRound.items():
                worksheetRound.write(lineIndex, 0,  key)
                worksheetRound.write(lineIndex, 1,  funcEmptyStrIfNoneOtherwiseFunc(value.pos,          int))
                worksheetRound.write(lineIndex, 2,  funcEmptyStrIfNoneOtherwiseFunc(value.neg,          int))
                worksheetRound.write(lineIndex, 3,  funcEmptyStrIfNoneOtherwiseFunc(value.impl,         int))
                worksheetRound.write(lineIndex, 4,  funcEmptyStrIfNoneOtherwiseFunc(value.rounds,       int))
                worksheetRound.write(lineIndex, 5,  funcEmptyStrIfNoneOtherwiseFunc(value.time,         float))
                worksheetRound.write(lineIndex, 6,  funcEmptyStrIfNoneOtherwiseFunc(value.proverTime,   float))
                worksheetRound.write(lineIndex, 7,  funcEmptyStrIfNoneOtherwiseFunc(value.learnerTime,  float))
                worksheetRound.write(lineIndex, 8,  funcEmptyStrIfNoneOtherwiseFunc(value.verified,     int))
                worksheetRound.write(lineIndex, 9,  funcEmptyStrIfNoneOtherwiseFunc(value.error,        int))
                worksheetRound.write(lineIndex, 10, funcEmptyStrIfNoneOtherwiseFunc(value.info[0],      str))
                worksheetRound.write(lineIndex, 11, funcEmptyStrIfNoneOtherwiseFunc(value.cexPos,       int))
                worksheetRound.write(lineIndex, 12, funcEmptyStrIfNoneOtherwiseFunc(value.cexNeg,       int))
                worksheetRound.write(lineIndex, 13, funcEmptyStrIfNoneOtherwiseFunc(value.cexPos_G,     int))
                worksheetRound.write(lineIndex, 14, funcEmptyStrIfNoneOtherwiseFunc(value.cexNeg_G,     int))
                worksheetRound.write(lineIndex, 15, funcEmptyStrIfNoneOtherwiseFunc(value.cexUnk,       int))
                worksheetRound.write(lineIndex, 16, funcEmptyStrIfNoneOtherwiseFunc(value.cexImpl,      int))
                worksheetRound.write(lineIndex, 17, funcEmptyStrIfNoneOtherwiseFunc(value.cexPos_M,     int))
                worksheetRound.write(lineIndex, 18, funcEmptyStrIfNoneOtherwiseFunc(value.cexNeg_M,     int))
                # worksheetRound.write(lineIndex, 10, funcEmptyStrIfNoneOtherwiseFunc(value.sat,          int))
                # worksheetRound.write(lineIndex, 11, funcEmptyStrIfNoneOtherwiseFunc(value.ssat,         int))
                lineIndex += 1
        workbook.close()
        self.log('GenXlsx finished at {0}'.format(fileName))

if __name__ == "__main__":
    print("This is class file, please excute Run.py.")