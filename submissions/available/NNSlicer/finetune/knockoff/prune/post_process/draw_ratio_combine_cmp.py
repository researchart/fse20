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

dir =  f"models/prune/true_false_dist/allconv_weight_combine"
fig_dir = os.path.join(dir, "fig")
os.makedirs(fig_dir, exist_ok=True)

modes = [
    "combine_small",
    "edgeweight_small",
]

def draw_class_trace():
    for class_id in list(range(10)):
        filename = f"allconv_class_{class_id}.csv"
        path = os.path.join(dir, filename)
        df = pd.read_csv(path, index_col=0)
        df = df[df['test_class'] == class_id]

        fig = plt.figure()
        plt.plot(df["combine_small_ratio"], df["combine_small"], 
                label="Combine", marker='o', linestyle='-')
        plt.plot(df["edgeweight_small_ratio"], df["edgeweight_small"],
                label="Weight", marker="*", linestyle='--')
        

        plt.legend(loc='best', fancybox=True, shadow=True)

        fig_filename = f"class{class_id}.pdf"
        fig_path = os.path.join(fig_dir, fig_filename)
        plt.savefig(fig_path)
        plt.clf()
        
def draw_all_trace_test_class():
    filename = f"allconv_class_all.csv"
    path = os.path.join(dir, filename)
    df = pd.read_csv(path, index_col=0)
    
    for class_id in range(10):
        class_df = df[df['test_class'] == class_id]
        fig = plt.figure()
        plt.plot(class_df["combine_small_ratio"], class_df["combine_small"], 
                label="Combine", marker='o', linestyle='-')
        plt.plot(class_df["edgeweight_small_ratio"], class_df["edgeweight_small"],
                label="Weight", marker="*", linestyle='--')

        plt.legend(loc='best', fancybox=True, shadow=True)

        fig_filename = f"classall_test{class_id}.pdf"
        fig_path = os.path.join(fig_dir, fig_filename)
        plt.savefig(fig_path)
        plt.clf()
    
def draw_all_trace_acc():
    filename = f"allconv_allclass_acc.csv"
    path = os.path.join(dir, filename)
    df = pd.read_csv(path, index_col=0)
    
    fig = plt.figure()
    plt.plot(df["combine_small_ratio"], df["combine_small"], 
            label="Combine", marker='o', linestyle='-')
    plt.plot(df["edgeweight_small_ratio"], df["edgeweight_small"],
            label="Weight", marker="*", linestyle='--')
    plt.plot(df["posnegweight_small_ratio"], df["posnegweight_small"],
            label="Trace", marker="x", linestyle='-.')
    plt.legend(loc='best', fancybox=True, shadow=True)
    
    plt.title("The Relation Between Accuracy and Prune Ratio")
    plt.xlabel("Prune Ratio")
    plt.ylabel("Accuracy")
    plt.ylim(0, 100)

    fig_filename = f"class_all_acc.pdf"
    fig_path = os.path.join(fig_dir, fig_filename)
    plt.savefig(fig_path)
    plt.clf()
    

    
# draw_class_trace()
# draw_all_trace_test_class()
draw_all_trace_acc()