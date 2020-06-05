# /***********[baital.py]
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

import sampling
import argparse
import sys
import get_coverage
import combinations
import sampling
import os
import math

def run(dimacscnf, strategy, twise, samples, rounds, outputdir, outputfile, nocomb, combinations_file, seed):
    benchmarkName = os.path.basename(dimacscnf).split('.')[0]
    if not outputfile:
        outputfile = benchmarkName + '.samples'
    samplesfile = os.path.join(outputdir, outputfile)
        
    samplesperround = math.ceil(samples / rounds)    
        
    #Compute the list of satisfiable feature combinations of size twise, stored in outputdir/benchmarkName_<twise>.comb
    if (not combinations_file) and (strategy == 1 or not nocomb):
        combinations.run(dimacscnf, twise, False, outputdir)
        combinations_file = os.path.join(outputdir, benchmarkName + '_' + str(twise) + '.comb')
    #Compute the number of model with each literal for strategy 3, stored in outputdir/benchmarkName.count
    if strategy == 3:
        combinations.run(dimacscnf, 0, True, outputdir)
        count_file = os.path.join(outputdir, benchmarkName + '.count')
        
    #Generate samples
    if strategy == 1:
        sampling.run(samplesperround, rounds, dimacscnf, samplesfile, twise, combinations_file, seed=seed)
    elif strategy == 2:
        sampling.run(samplesperround, rounds, dimacscnf, samplesfile, twise, '', seed=seed)
    elif strategy == 3:
        sampling.run(samplesperround, rounds, dimacscnf, samplesfile, 0, count_file, seed=seed)
    else:
        sampling.run(samplesperround, rounds, dimacscnf, samplesfile, 0, '', seed=seed)

    if samples != samplesperround*rounds:
        #remove extra samples in case of non divisible by number of rounds
        with open(samplesfile, 'r') as f:
            generated = f.readlines()
        with open(samplesfile, 'w') as f:
            f.writelines(generated[:samples])

    #Compute coverage
    if not nocomb:  
        combs,coverage = get_coverage.run(samplesfile, combinations_file, twise)
    else: #compute number of distinct feature combinations 
        combs,coverage = get_coverage.run(samplesfile, '', twise)
    with open(samplesfile + '.txt', 'w') as f:
        f.write(str(combs) + '\n')
        if coverage:
            f.write(str(coverage) + '\n')
        

def check_comb_file(combinations_file, twise):
    with open(combinations_file) as f:
        line = f.readline()
        return len(line.split(",")) == twise
    

def main():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("--outputdir", type=str, default="../results/", help="output directory", dest='outputdir')
    parser.add_argument("--outputfile", type=str, default="", help="output file for samples, will be placed in outputdir", dest='outputfile')
    parser.add_argument("--strategy", type=int, default=4, choices=range(1, 5), help="weight generation strategy", dest='strategy')
    parser.add_argument("--twise", type=int, default=2, help="t value for t-wise coverage. Note that for strategies 3 and 4 it does not affect sampling", dest='twise')
    parser.add_argument("--samples", type=int, default=500, help="total number of samples", dest='samples')
    parser.add_argument("--rounds", type=int, default=10, help="number of rounds to generate samples", dest='rounds')
    parser.add_argument("--combinations", type=str, default='', help="file with pregenerated list of satisfiable feature combinations", dest="combinationsfile")
    parser.add_argument("--no-combinations", action='store_true', help="if set, the list of satisfiable feature combinations and resulted coverage are not computed reducing the computation time. Ignored if strategy=1", dest='nocomb')
    parser.add_argument("--seed", type=int, default=None, help="random seed", dest="seed")
    parser.add_argument('DIMACSCNF', type=str, help='input cnf file in dimacs format')
    args = parser.parse_args()
    if args.DIMACSCNF is '':
        parser.print_usage()
        sys.exit(1)
    if args.rounds <= 0:
        print("Number of rounds must be positive")
        sys.exit(1)
    if args.samples<= 0:
        print("Number of samples must be positive")
        sys.exit(1)
    if args.seed and args.seed<= 0:
        print("Random seed must be positive")
        sys.exit(1)
    if args.twise <=0 and args.strategy >2:
        print("Twise must be positive")
        sys.exit(1)
    if args.combinationsfile and not check_comb_file(args.combinationsfile, args.twise):
        print("Combinations file have wrong size of feature combinations")
        sys.exit(1)
    if args.strategy==1 and args.nocomb:
        print("--no-combinations is ignored for strategy 1")
    if not os.path.exists(args.outputdir):
        os.makedirs(args.outputdir)
    
    run(args.DIMACSCNF, args.strategy, args.twise, args.samples, args.rounds, args.outputdir, args.outputfile, args.nocomb, args.combinationsfile, args.seed)

if __name__== "__main__":
    main()
