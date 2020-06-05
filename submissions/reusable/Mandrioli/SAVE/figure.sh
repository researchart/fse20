#!/bin/bash

if [ "$1" = "precomputed" ]; then
	DIR_RESULTS=final_results
else
	DIR_RESULTS=results/summary
fi

mkdir fig/data

cat $DIR_RESULTS/greedy/*.csv > fig/data/all_greedy.csv
cat $DIR_RESULTS/random/*.csv > fig/data/all_random.csv
cat $DIR_RESULTS/integral/*.csv > fig/data/all_integral.csv
cat $DIR_RESULTS/mpc/*.csv > fig/data/all_mpc.csv

cd fig

pdflatex Fig4.tex
rm *.log *.aux

cd ..

rm -r fig/data

