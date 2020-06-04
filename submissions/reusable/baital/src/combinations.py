# /***********[combinations.py]
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


import argparse
import pycosat
import os
import bisect
import time

def parse_cnf(cnffile):
    clauses = []
    with open(cnffile) as f:
        lines = f.readlines()
        for line in lines:
            if line.startswith("c"):
                continue
            elif line.startswith("p"):
                nVars = int(line.strip().split(' ')[2])
            else:
                literals = list(map(int, line.strip().split(' ')))
                if len(literals) > 1:
                    clauses.append(literals[:-1])
    return nVars, clauses

def combinations(lst, size, acc, res):
    if size == 1:
        for x in lst:
            newComb = acc[:] + [x]
            res.append(newComb)
    else:
        for i in range(len(lst)- size + 1):
            accI = acc[:] + [lst[i]]
            combinations(lst[i+1:], size -1, accI, res)
            
def get_combinations(nVars, clauses, size, outputfile, combs):
    feasibleCombs = []
    allComb = []
    start = time.time()
    if size == 1:
        allComb = [[x] for x in range(-nVars, 0)] + [[x] for x in range(1, nVars+1)]
    else:
        literals = list(map(lambda x : x[0], combs[0]))
        for precomb in combs[-1]:  # expected to be sorted, add only literals with greater value
            first = bisect.bisect_right(literals, precomb[-1])
            for l in range(first, len(literals)):
                if -(literals[l]) not in precomb: 
                    newComb = precomb[:] + [literals[l]]
                    allComb.append(newComb)
    f = open(outputfile, "w")
    total = len(allComb)
    print("Total combinations to check " + str(total))
    #print("Time to generate combinations to check " + str(time.time() - start))
    curPerc = 0.0
    for i in range(len(allComb)):
        comb = allComb[i]
        cnf = clauses[:] + list(map(lambda x : [x], comb))
        s = pycosat.solve(cnf)
        if s != 'UNSAT':
            f.write(','.join(map(str, comb)) + '\n')
            feasibleCombs.append(comb)
        if i / total > curPerc + 0.05:
            curPerc += 0.05
            print(str(round(100 * curPerc)) + "% done")
    f.close()
    print("Time to get satisfiable combinations " + str(time.time() - start))
    return feasibleCombs


def modelCount(nVars, cnfFile, outputFile):
    tmpCnfFile = 'tmp.cnf'
    tmpFile = "output.tmp"
    
    literals = list(range(-nVars, 0)) + list(range(1, nVars+1))
    res = {}
    cf = open(cnfFile)
    lines = cf.readlines()
    cf.close()
    for i in range(len(lines)):
        if lines[i].startswith('p'):
            spl = lines[i].strip().split(' ')
            spl[-1] = str(1+ int(spl[-1]))
            lines[i] = ' '.join(spl) + '\n'
    
    curPerc = 0.0
    total = len(literals)
    for i in range(len(literals)):
        tcf = open(tmpCnfFile, 'w+')
        tcf.writelines(lines)
        tcf.write(str(literals[i]) + ' 0\n')
        tcf.close()
        cmd = "./bin/d4 " + tmpCnfFile + ' -mc > ' + tmpFile + ' 2>&1'
        os.system(cmd)
        out = open(tmpFile)
        outlines = out.readlines()
        for line in outlines:
            if line.startswith('s'):
                res.update({literals[i]: line.strip().split(' ')[1]})
        out.close()
        os.remove(tmpCnfFile)
        os.remove(tmpFile)
        if i / total > curPerc + 0.05:
            curPerc += 0.05
            print(str(round(100 * curPerc)) + "% done")
    
    resFile = open(outputFile, 'w+')
    for k,v in res.items():
        resFile.write(str(k) + ' ' + v + '\n')
    resFile.close()


def run(dimacscnf, twise, count, outputdir):
    nVars, clauses = parse_cnf(dimacscnf)
    benchmarkName = os.path.basename(dimacscnf).split('.')[0]

    if count:
        print("Computing number of models for each literal")
        modelCount(nVars, dimacscnf, os.path.join(outputdir,  benchmarkName + '.count'))
    else:
        combs = []        
        for i in range(twise):
            print("Generating " + str(i+1) + "-wise combinations")
            combs.append(get_combinations(nVars, clauses, i+1, os.path.join(outputdir, benchmarkName + '_' + str(i+1) + '.comb'), combs))
    

if __name__ == "__main__":
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("--outputdir", type=str, default="results/", help="output directory", dest='outputdir')
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--twise", type=int, help="size of feature combinations. Note all combinations with smaller size would be generated", dest='size')
    group.add_argument("--count", action='store_true', help="counts the number of models with each literal", dest='count')
    parser.add_argument('DIMACSCNF', nargs='?', type=str, default="", help='input cnf file in dimacs format')
    args = parser.parse_args()
    run(args.DIMACSCNF, args.size, args.count, args.outputdir)



