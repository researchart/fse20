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

dir =  f"models/adversary/lastconv_protection_ratio_weight_maskgrad_2"
fig_dir = os.path.join(dir, "fig")
os.makedirs(fig_dir, exist_ok=True)

modes = [
    "posnegweight_large",
    "weight_large",
]
exp_configs = {
    # "fc": ["dense"],
    "block4fc": ["conv2d_10", "conv2d_11", "conv2d_12", "dense"],
    # "conv12": ["conv2d_12"],
    "block4": ["conv2d_10", "conv2d_11", "conv2d_12"],
    # "block4main": ["conv2d_11", "conv2d_12"],
    # "block3": ["conv2d_7", "conv2d_8", "conv2d_9"],
    # "block2": ["conv2d_4", "conv2d_5", "conv2d_6"],
}

def draw_budget_acc():
    for exp_name in exp_configs.keys():
        filename = f"lastconv_{exp_name}_class_all.csv"
        path = os.path.join(dir, filename)
        all_df = pd.read_csv(path, index_col=0)
        
        for ratio in list(np.unique(all_df["ratio"])):
            df = all_df[all_df["ratio"] == ratio]
            fig = plt.figure()
            plt.plot(df["budget"], df["posnegweight_large"], 
                    label="Trace", marker='o', linestyle='-')
            plt.plot(df["budget"], df["edgeweight_large"],
                    label="Weight", marker="*", linestyle='--')

            plt.legend(loc='best', fancybox=True, shadow=True)
            
            plt.title("The Relation Between Accuracy and Budget")
            plt.xlabel("Budget")
            plt.ylabel("Accuracy")
            # plt.ylim(0, 100)

            fig_filename = f"{exp_name}_budget_acc_ratio{ratio}.pdf"
            fig_path = os.path.join(fig_dir, fig_filename)
            plt.savefig(fig_path)
            plt.clf()
    

    
# draw_class_trace()
# draw_all_trace_test_class()
draw_budget_acc()