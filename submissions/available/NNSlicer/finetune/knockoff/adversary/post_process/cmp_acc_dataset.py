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

dir =  f"models/adversary/allprotection_ratio_weight_maskgrad"
fig_dir = os.path.join(dir, "fig")
os.makedirs(fig_dir, exist_ok=True)

modes = [
    "posnegweight_large",
    "weight_large",
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
    
def draw_budget_acc():
    filename = f"allconv.csv"
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

        fig_filename = f"budget_acc_ratio{ratio}.pdf"
        fig_path = os.path.join(fig_dir, fig_filename)
        plt.savefig(fig_path)
        plt.clf()
    

    
# draw_class_trace()
# draw_all_trace_test_class()
draw_budget_acc()