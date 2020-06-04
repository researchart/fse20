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

dir =  f"models/prune/f1score_avg/lastprune_classf1"
modes = [
    "posneg_small",
    "posonly_small",
]

fig_dir = os.path.join(dir, "fig")
os.makedirs(fig_dir, exist_ok=True)
exp_configs = {
    "fc": ["dense"],
    "block4fc": ["conv2d_10", "conv2d_11", "conv2d_12", "dense"],
    # "conv12": ["conv2d_12"],
    "block4": ["conv2d_10", "conv2d_11", "conv2d_12"],
    # "block4main": ["conv2d_11", "conv2d_12"],
}

def load_csv(filename):
    path = os.path.join(dir, filename)
    return pd.read_csv(path, index_col=0)
    
def draw_posneg_weight_cmp_hist():
    for exp_name in exp_configs.keys():
        # All trace on each class
        all_df = load_csv(f"lastconv_{exp_name}_class_all.csv")
        
        class_df = []
        for class_id in range(10):
            df = load_csv(f"lastconv_{exp_name}_class_{class_id}.csv")
            df["class_id"] = class_id
            class_df.append(df)
            
        class_df = pd.concat(class_df)
        
        
        for ratio in np.unique(all_df['ratio']):
            all_f1 = all_df[all_df['ratio'] == ratio]
            class_f1 = class_df[class_df['class_id'] == class_df['test_class']]
            class_f1 = class_f1[class_f1['ratio'] == ratio]
            
            all_posneg = all_f1["posnegweight_small"].to_list()
            class_posneg = class_f1["posnegweight_small"].to_list()
            weight = all_f1["edgeweight_small"].to_list()
            weight_avg = all_f1["edgeweight_small_avg"].to_list()
            random = all_f1["randomweight_small"].to_list()
            
            ratio_index = range(0, 20, 2)
            fig, ax = plt.subplots(figsize=(8,6))
            width = 0.3
            plt.bar(left=ratio_index, height=all_posneg, 
                    width=width, label="All Trace")
            plt.bar(left=[i + width for i in ratio_index], height=class_posneg, 
                    width=width, label="Per Class Trace")
            plt.bar(left=[i + 2*width for i in ratio_index], height=weight_avg, 
                    width=width, label="Weight Average")
            plt.bar(left=[i + 3*width for i in ratio_index], height=weight, 
                    width=width, label="Weight Prune")
            plt.bar(left=[i + 4*width for i in ratio_index], height=random, 
                    width=width, label="Random Prune")
            
            ax.set_ylabel("F1 Score")
            ax.set_xlabel("Class")
            ax.set_title("Prune Performance on Each Class")
            ax.set_xticks([p + 1.5 * width for p in ratio_index])
            labels = list(range(10))
            ax.set_xticklabels(labels)
            plt.ylim(0, 1)
            
            plt.legend()
            
            fig_name = f"{exp_name}_class_f1score_{ratio:.2f}.pdf"
            fig_path = os.path.join(fig_dir, fig_name)
            plt.savefig(fig_path)
            plt.clf()
        
    
    
draw_posneg_weight_cmp_hist()