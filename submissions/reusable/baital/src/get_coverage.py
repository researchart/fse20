# /***********[get_coverage.py]
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
import argparse
import random
import os
import sys

def getTuples_rec(lst, sizeLeft, trieNode, count, comb):
    if sizeLeft == 1:
        for x in lst:
            if x not in trieNode: 
                trieNode[x] = True
                count[0] +=1
    else:
        for i in range(len(lst) - sizeLeft + 1):
            if lst[i] not in trieNode:
                trieNode[lst[i]] = {}
            trieNodeNew = trieNode[lst[i]]
            combNew = comb[:] + [lst[i]]
            getTuples_rec(lst[i+1 :], sizeLeft -1, trieNodeNew, count, combNew)

def check_coverage(samplefile, combfile, size):
    trie = {}
    count = [0]
    aggrCount = []
    with open(samplefile, "r") as f:
        for line in f:
            s = list(map(int, line.strip().split(',')[1].strip().split(' ')))
            getTuples_rec(s, size, trie, count, [])
            aggrCount.append(count[0])
    countRes = count[0]
    print("Number of combinations " + str(countRes))
    if combfile:        
        with open(combfile, "r") as f:
            total = len(f.readlines()) -1
        coverage = countRes / total
        print("Coverage " + str("%.2f" % coverage))
    else:
        coverage = None
    return countRes,coverage


def run(samples, combfile, twise):
    print("Starting to compute number of combintations and/or coverage")
    #start = time.time()
    return check_coverage(samples, combfile, twise)
    #print("Time taken to compute coverage: " + str(time.time() - start))
    

if __name__ == "__main__":
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("--combfile", type=str, default="", help="File with a list of combinations")
    parser.add_argument("--samples", type=str, help='File with samples', required=True)
    parser.add_argument("--twise", type=int, help='The size of combinations', required=True)

    args = parser.parse_args()
    run(args.samples, args.combfile, args.twise)

    
