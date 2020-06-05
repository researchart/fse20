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

dir =  f"models/prune/f1score_avg/allprune_subset_0.05"
modes = [
    "posneg_small",
    "posonly_small",
]

fig_dir = os.path.join(dir, "fig")
os.makedirs(fig_dir, exist_ok=True)

def load_csv(filename):
    path = os.path.join(dir, filename)
    return pd.read_csv(path, index_col=0)

def draw_by_ratio():
    subdir = "ratio_line"
    fig_subdir = os.path.join(fig_dir, subdir)
    os.makedirs(fig_subdir, exist_ok=True)
    
    for combination_number in range(2, 10):
        subset_dir = os.path.join(fig_subdir, f"subset_{combination_number}")
        os.makedirs(subset_dir, exist_ok=True)
        # All trace on each class
        df = load_csv(f"allconv_subset_{combination_number}.csv")
        
        for class_ids in np.unique(df["classes"]):
            exp_df = df[df["classes"] == class_ids]
            
            posneg_all = exp_df["posnegweight_small_all"].to_list()
            posneg_subset = exp_df["posnegweight_small_subset"].to_list()
            edge = exp_df["edgeweight_small"].to_list()
            edge_avg = exp_df["edgeweight_small_avg"].to_list()
            random = exp_df["randomweight_small"].to_list()
            ratio = exp_df["ratio"].to_list()
            index = list(range(len(ratio)))
            
            fig, ax = plt.subplots(figsize=(8,6))
            colormap = plt.cm.Paired
            
            # with plt.style.context('fivethirtyeight'):
                # plt.gca().set_color_cycle([colormap(i) for i in np.linspace(0, 0.9, 5)])
            plt.plot(ratio, posneg_subset, label="NNSlicer (Subset)",
                    marker='*', linestyle='--')
            plt.plot(ratio, posneg_all, label="NNSlicer (All Dataset)",
                    marker='.', linestyle='-')
            plt.plot(ratio, edge, label="Weight",
                    marker='v', linestyle=None)
            plt.plot(ratio, edge_avg, label="Weight (Profiling)",
                    marker='o', linestyle=':')
            plt.plot(ratio, random, label="Random",
                    marker='d', linestyle='-.')
            
            ax.set_ylabel("Accuracy on Subset")
            ax.set_xlabel("Prune Ratio")
            ax.set_title(f"Prune Performance on Subset of class {class_ids}")
            # labels = [f"{r:.1f}" for r in ratio]
            # ax.set_xticklabels(labels)
            plt.ylim(0, 100)
            plt.legend(loc="lower left", ncol=1)
            
            fig_name = f"subset_{class_ids}.pdf"
            fig_path = os.path.join(subset_dir, fig_name)
            plt.savefig(fig_path)
            plt.clf()
            
        
            
def draw_by_subset():
    subdir = "subset_hist"
    fig_subdir = os.path.join(fig_dir, subdir)
    os.makedirs(fig_subdir, exist_ok=True)
    
    for combination_number in range(2, 10):
        # All trace on each class
        df = load_csv(f"allconv_subset_{combination_number}.csv")
        
        for ratio in np.unique(df["ratio"]):
            subset_dir = os.path.join(fig_subdir, f"subset_{combination_number}",
                                    f"ratio={ratio:.2f}")
            os.makedirs(subset_dir, exist_ok=True)
            
            ratio_df = df[df["ratio"] == ratio]
            subsets = np.unique(df["classes"])
            subset_per_image = 10
            for i, idx in enumerate(range(0, len(subsets), subset_per_image)):
                fig_subset = list(subsets[idx:min(len(subsets), idx+subset_per_image)])
                
                fig_df = []
                for classes in fig_subset:
                    fig_df.append( ratio_df[ratio_df["classes"] == classes])
                fig_df = pd.concat(fig_df)
                
                posneg_subset = fig_df["posnegweight_small_subset"].to_list()
                posneg_all = fig_df["posnegweight_small_all"].to_list()
                edge = fig_df["edgeweight_small"].to_list()
                edge_avg = fig_df["edgeweight_small_avg"].to_list()
                random = fig_df["randomweight_small"].to_list()
                ratio = fig_df["ratio"].to_list()
                index = list(range(len(fig_subset)))
                index = [2*j for j in index]
                
                fig, ax = plt.subplots(figsize=(8,6))
                width = 0.3
                posneg_rect = plt.bar(left=index, height=posneg_subset, 
                                    width=width, label="NNSlicer (Subset)")
                weight_rect = plt.bar(left=[i + width for i in index], height=posneg_all, 
                                    width=width, label="NNSlicer (All Dataset)")
                weight_avg_rect = plt.bar(left=[i + 2*width for i in index], height=edge, 
                                        width=width, label="Weight")
                channel_rect = plt.bar(left=[i + 3*width for i in index], height=edge_avg, 
                                    width=width, label="Weight (Profiling)")
                random_rect = plt.bar(left=[i + 4*width for i in index], height=random, 
                                    width=width, label="Random")
                
                ax.set_ylabel("Accuracy on Subset")
                ax.set_xlabel("Subset")
                ax.set_title("Prune Performance on Subset")
                ax.set_xticks([p + 2 * width for p in index])
                labels = fig_subset
                ax.set_xticklabels(labels)
                plt.ylim(0, 100)
                
                plt.legend(loc="lower left", ncol=1)
                
                fig_name = f"subset_acc_{i}.pdf"
                fig_path = os.path.join(subset_dir, fig_name)
                plt.savefig(fig_path)
                plt.clf()

def draw_by_subset_alldataset():
    subdir = "subset_hist"
    fig_subdir = os.path.join(fig_dir, "subset_hist", "subset_mean")
    os.makedirs(fig_subdir, exist_ok=True)
    
    all_df = []
    for combination_number in range(2, 10):
        # All trace on each class
        df = load_csv(f"allconv_subset_{combination_number}.csv")
        df["combination"] = combination_number
        all_df.append(df)
    all_df = pd.concat(all_df)
    
    
    for ratio in np.unique(all_df["ratio"]):
        df = all_df[all_df["ratio"] == ratio]
        
        com_df = []
        for combination_number in np.unique(df["combination"]):
            com_df.append(df[df["combination"] == combination_number].mean().to_frame().transpose())
        com_df = pd.concat(com_df)
        
        posneg_subset = com_df["posnegweight_small_subset"].to_list()
        posneg_all = com_df["posnegweight_small_all"].to_list()
        edge = com_df["edgeweight_small"].to_list()
        edge_avg = com_df["edgeweight_small_avg"].to_list()
        random = com_df["randomweight_small"].to_list()
        subset_size = com_df["combination"].astype(int).to_list()
        index = list(range(len(subset_size)))
        index = [2*j for j in index]
        
        fig, ax = plt.subplots(figsize=(8,6))
        width = 0.3
        posneg_rect = plt.bar(left=index, height=posneg_subset, 
                            width=width, label="NNSlicer (Subset)")
        weight_rect = plt.bar(left=[i + width for i in index], height=posneg_all, 
                            width=width, label="NNSlicer (All Dataset)")
        weight_avg_rect = plt.bar(left=[i + 2*width for i in index], height=edge, 
                                width=width, label="Weight")
        channel_rect = plt.bar(left=[i + 3*width for i in index], height=edge_avg, 
                            width=width, label="Weight (Profiling)")
        random_rect = plt.bar(left=[i + 4*width for i in index], height=random, 
                            width=width, label="Random")
        
        ax.set_ylabel("Mean Accuracy on Subset")
        ax.set_xlabel("Subset Size")
        ax.set_title("Mean Accuracy on Each Subset Size")
        ax.set_xticks([p + 2 * width for p in index])
        labels = subset_size
        ax.set_xticklabels(labels)
        plt.ylim(0, 100)
        
        plt.legend(loc="lower left", ncol=1)
        
        fig_name = f"subset_ratio{ratio:.2f}.pdf"
        fig_path = os.path.join(fig_subdir, fig_name)
        plt.savefig(fig_path)
        plt.clf()
        
        
        
    
draw_by_ratio()
draw_by_subset()
draw_by_subset_alldataset()