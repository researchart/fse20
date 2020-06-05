import os, sys
import numpy as np
from pdb import set_trace as st
import pandas as pd

import matplotlib
matplotlib.use('Agg')
from matplotlib import pyplot as plt
from matplotlib import cm
from matplotlib import axes
import matplotlib.ticker as ticker

dir =  f"models/prune/true_false_dist/allconv_allacc"
fig_dir = os.path.join(dir, "fig")
os.makedirs(fig_dir, exist_ok=True)

modes = [
    "posnegweight_small",
    "posonlyweight_small",
    "edgeweight_small",
    # "posneg_small",
    # "posonly_small",
    # "channelweight_small",
    "random",
]

def cmp_acc():
    filename = f"allconv_prune_acc.csv"
    path = os.path.join(dir, filename)
    df = pd.read_csv(path, index_col=0)
    
    for ratio in np.arange(0.1, 1, 0.1):
        ratio_df = df[df["ratio"] == round(ratio, 1)]
        
        labels = ratio_df['trace_class'].to_list()
        acc = ratio_df['posnegweight_small'].to_list()
        
        fig = plt.figure()
        rects1 = plt.bar(left=labels, height=acc)
        
        plt.xlabel("Trace")
        plt.ylabel("Accuracy")
        plt.ylim(0, 100)
        
        fig_filename = f"ratio_{round(ratio,1)}.pdf"
        fig_path = os.path.join(fig_dir, fig_filename)
        plt.savefig(fig_path)
        plt.clf()
        
        
cmp_acc()