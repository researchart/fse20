# /***********[sampling.py]
# Copyright (c) 2020 Eduard Baranov, Axel Legay, Kuldeep Meel
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# ***********/

import time
import os
import waps
import math
import random
import argparse
import sys
import numpy as np

def getTuples_rec(lst, sizeLeft, trieNode, count, comb):
    if sizeLeft == 1:
        for x in lst:
            if x not in trieNode: 
                trieNode[x] = True
                count[x] +=1
                for v in comb:
                    count[v] +=1
    else:
        for i in range(len(lst) - sizeLeft + 1):
            if lst[i] not in trieNode:
                trieNode[lst[i]] = {}
            trieNodeNew = trieNode[lst[i]]
            combNew = comb[:] + [lst[i]]
            getTuples_rec(lst[i+1 :], sizeLeft -1, trieNodeNew, count, combNew)


def weightFormula1(posN, negN, total, i):
    if total[i] == 0:
        return 0
    if total[-i] == 0:
        return 1
    return 0.5 - (0.49 * (posN /total[i] - negN /total[-i]))

def weightFormula2(posN, negN, total, i):
    if total[i] == 0:
        return 0
    if total[-i] == 0:
        return 1
    val = posN /total[i] - negN /total[-i]
    if val >= 0:
        return 0.5 - (0.49 * math.sqrt(val))
    else:
        return 0.5 + (0.49 * math.sqrt(-val))

def weightFormula3(posN, negN, total, i):
    if total[i] == 0:
        return 0
    if total[-i] == 0:
        return 1
    val = posN /total[i] - negN /total[-i]
    if val >= 0:
        return 0.5 - (0.49 * val*val)
    else:
        return 0.5 + (0.49 * val*val)

def weightFormula4(posN, negN, total, i):
    if total[i] == 0:
        return 0
    if total[-i] == 0:
        return 1
    val = posN /total[i] - negN /total[-i]
    if val == 0:
        return 0.5    
    if val > 0:
        return 0.5 - (0.49 * math.e *(math.pow(math.e, -1 /val)))
    else:
        return 0.5 + (0.49 * math.e *(math.pow(math.e, 1 /val)))
    
def weightFormula5(posN, negN, total, i):
    if total[i] == 0:
        return 0
    if total[-i] == 0:
        return 1    
    val = posN /total[i] - negN /total[-i]
    return 0.5 - math.tanh(3*val) /2

def weightFormula6(posN, negN, total, i):
    if total[i] == 0:
        return 0
    if total[-i] == 0:
        return 1    
    val = posN /total[i] - negN /total[-i]
    if val >= 0:
        return 0.5 - (0.49 * math.pow(val, 1/3))
    else:
        return 0.5 + (0.49 * math.pow(-val, 1/3))

def weightFormula7(posN, negN, total, i):
    if total[i] == 0:
        return 0
    if total[-i] == 0:
        return 1
    if posN /total[i] + negN /total[-i] == 0:
        return 0.5
    return 0.5 - (0.49 * (posN /total[i] - negN /total[-i]) / (posN /total[i] + negN /total[-i]))
    
def weightFormulatStrategy3(posN, negN, total, i):
    if (i ==10):
        print(posN)
        print(negN)
    if total[i] == 0:
        return 0
    if total[-i] == 0:
        return 1
    if posN == 0 and negN == 0 : 
        return 0.5
    posP = posN / (posN + negN) 
    negP = math.log(total[i]) / (math.log(total[i]) + math.log(total[-i]))
    val = (posP -negP)
    if val >= 0:
        return (0.5 - (0.49 * math.sqrt(val)))
    else:
        return 0.5 + (0.49 *math.sqrt(-val))
 
def weightFormulaStrategy4(posN, negN):
    if posN + negN ==0:
        return 0.5
    else: 
        return 0.5 - 0.49* ((posN -negN) / (posN + negN)) 
 
#dictionnary of functions for computing weights
weightFunctions = {1: weightFormula1, 2: weightFormula2, 3 : weightFormula3, 4: weightFormula4, 5: weightFormula5, 6: weightFormula6, 7: weightFormula7, 0 : weightFormulatStrategy3}

def generateWeights(count, nvars, maxComb, weightFile, roundNb, funcNumber):
    f = open(weightFile + str(roundNb)  + '.txt', 'w')
    for i in range(nvars):
        if not maxComb: #Strategy 4  
            f.write(str(i+1) + ',' + str(weightFormulaStrategy4(count[i+1], count[-i-1])) + '\n')
        else:
            f.write(str(i+1) + ',' + str(weightFunctions[funcNumber](count[i+1], count[-i-1], maxComb, i+1)) + '\n')
    f.close()

def cnk(n, k):
    res =1
    for i in range(k):
        res *= n-i
    for i in range(k):
        res /= (i+1)
    return res

def countMaxComb(nvars, twise):
    if twise == 1:
        val = 1
    elif twise == 2:
        val = 2*nvars - 2
    elif twise == 3:
        val = (2*nvars - 2) * (2*nvars - 4) / 2
    else:
        val = (2**(twise -1)) * cnk(nvars-1, twise-1)
    res = {i+1 : val for i in range(nvars)}
    res.update({-(i+1) : val for i in range(nvars)})
    return res
    
def loadMaxComb(nvars, twise, combinationsFile):
    res = {i+1 : 0 for i in range(nvars)}
    res.update({-(i+1) : 0 for i in range(nvars)})
    with open(combinationsFile) as f:
        lines = f.readlines()
    try:
        if len(lines[0].split(",")) != twise:
            print("Wrong size of combinations, use strategy 2 instead")
            return countMaxComb(nvars, twise)
        for line in lines:
            comb = map(lambda x: int(x.strip()), line.split(","))
            for val in comb:
                res[val] +=1
        return res
    except:
        print("Wrong format of the file, use strategy 2 instead")
        return countMaxComb(nvars, twise)

def loadModelCount(combinationsFile):
    res = {}
    with open(combinationsFile) as f:
        lines = f.readlines()
    try:
        for line in lines:
            spl = line.strip().split(' ')
            res.update({int(spl[0]): int(spl[1])})
        return res
    except:
        print("Wrong format of the file, use strategy 4 instead")
        return None

def run(samples, rounds, DIMACSCNF, outputFile, twise, combinationsFile, funcNumber=2, seed=None):
    tmpSampleFile = 'samples_temp.txt'
    pickleFile = 'saved.pickle'
    if os.path.exists(tmpSampleFile):
        os.remove(tmpSampleFile)
    output = open(outputFile, 'w+')
    
    start = time.time()
    if seed:
        np.random.seed(seed)
        random.seed(seed)
    nvars = 0
    with open(DIMACSCNF) as cnfFile:
        for line in cnfFile.readlines():
            if line.startswith('p'):
                nvars = int(line.split(' ')[2].strip())
                break
    if twise == 0 and combinationsFile: #Strategy 3
        maxComb = loadModelCount(combinationsFile)
        funcNumber = 0
    elif twise == 0: #Strategy 4 - Independent of t
        maxComb = None
    elif combinationsFile: #Strategy 1 - loading feasible combinations 
        maxComb = loadMaxComb(nvars, twise, combinationsFile)
    else: # Strategy 2
        maxComb = countMaxComb(nvars, twise)

   
    count = {i+1 : 0 for i in range(nvars)}
    count.update({-(i+1) : 0 for i in range(nvars)})
    weightFilePref = 'weights'
    trie = {}
    
    generateWeights(count, nvars, maxComb, weightFilePref, 1, funcNumber)
    roundRes = [0]
    for roundN in range(rounds):
        print("Round "  + str(roundN+1) + ' started...')
        round_start = time.time()
        weightFile = weightFilePref + str(roundN+1)  + '.txt'
        if roundN == 0:
            waps.sample(samples, '', DIMACSCNF, None, weightFile, tmpSampleFile, pickleFile, 1, None, None, None, seed)
        else:
            waps.sample(samples, '', '', pickleFile, weightFile, tmpSampleFile, None, 1, None, None, None, seed)
        ns = open(tmpSampleFile)
        newSamplesLines = ns.readlines()
        for line in newSamplesLines:
            lineParts = line.strip().split(',')
            s = list(map(int, lineParts[1].strip().split(' ')))
            if twise == 0:
                    for val in s:
                        count[val] +=1
            else:
                getTuples_rec(s, twise, trie, count, [])
            sampleNumber = roundN * samples + int(lineParts[0].strip())
            output.write(str(sampleNumber) + ',' + lineParts[1] + '\n')
        ns.close()
        os.remove(tmpSampleFile)
        generateWeights(count, nvars, maxComb, weightFilePref, roundN+2, funcNumber)
        print("The time taken by round " + str(roundN+1) + " :" +  str(time.time()-round_start))
        print("Round " + str(roundN+1) + ' finished...')

    output.close()
    
    print("The time taken by sampling:", time.time()-start)
    if twise != 0:
        print("Total number of sampled combinations " + str(sum(count.values()) / twise) )
    
    #cleanup
    os.remove(pickleFile)
    for roundN in range(rounds+1):
        os.remove(weightFilePref + str(roundN+1)  + '.txt')


def main():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("--outputfile", type=str, default="samples_full.txt", help="output file for samples", dest='outputfile')
    parser.add_argument("--twise", type=int, default=0, help="t value for t-wise coverage, default 0", dest='twise')
    parser.add_argument("--function", type=int, default=2, choices=range(1, 8), help="Function number between 1 and 7 for weight generation, ignored if t-wise set to 0.", dest='funcNumber')
    parser.add_argument("--samples-per-round", type=int, default = 50, help="number of samples per round", dest='samples')
    parser.add_argument("--rounds", type=int, default=20, help="number of rounds to take samples", dest='rounds')
    parser.add_argument("--combinations", type=str, default='', help="file with satisfiable feature combinations for strategy 1 or number of models with each literal for strategy 3", dest="combinationsFile")
    parser.add_argument("--seed", type=int, default=None, help="random seed", dest="seed")
    parser.add_argument('DIMACSCNF', nargs='?', type=str, default="", help='input cnf file')
    args = parser.parse_args()
    if args.DIMACSCNF is '':
        parser.print_usage()
        sys.exit(1)
    run(args.samples, args.rounds, args.DIMACSCNF, args.outputfile, args.twise, args.combinationsFile, args.funcNumber, args.seed)

if __name__== "__main__":
    main()
