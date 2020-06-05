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

dir =  f"models/prune/f1_score/allconv_channel"
modes = [
    "posneg_small",
    "posonly_small",
]

fig_dir = os.path.join(dir, "fig")
os.makedirs(fig_dir, exist_ok=True)
exp_configs = {
    # "conv12": ["conv2d_12"],
    "block4": ["conv2d_10", "conv2d_11", "conv2d_12"],
    # "block4main": ["conv2d_11", "conv2d_12"],
}

def draw_heatmap_expconfig():
    for mode in modes:
        for exp_name in exp_configs.keys():
            for ratio in np.arange(0.5, 0.9, 0.1):
                print(f"{mode} {exp_name} ratio={ratio}")
                interclass_matrix = []
                for class_id in list(range(10))+["all"]:
                    filename = f"allconv_class_{exp_name}_{class_id}.csv"
                    path = os.path.join(dir, filename)
                    df = pd.read_csv(path, index_col=0)
                    df = df[df['ratio'] == round(ratio, 2)]
                    df = df.sort_values(by="test_class", ascending=True)
                    
                    df = df[mode]
                    interclass_matrix.append(df.to_numpy())
                
                interclass_matrix = np.stack(interclass_matrix)
                print(interclass_matrix)
                print()
                
                # plot
                fig_name = f"{mode}_{exp_name}_ratio={round(ratio, 2)}.pdf"
                fig_path = os.path.join(fig_dir, fig_name)
                fig = plt.figure()
                ax = fig.add_subplot(111)
                cax = ax.matshow(
                    interclass_matrix, 
                    interpolation='nearest', cmap='winter',
                    vmin=0.5, vmax=0.95
                )
                fig.colorbar(cax)
                
                tick_spacing = 1
                ax.xaxis.set_major_locator(ticker.MultipleLocator(tick_spacing))
                ax.yaxis.set_major_locator(ticker.MultipleLocator(tick_spacing))
                
                ax.set_xticklabels([''] + list(range(10)))
                ax.set_yticklabels([''] + list(range(10)) + ["All"])
                
                for i in range(11):
                    for j in range(10):
                        text = ax.text(j, i, interclass_matrix[i, j],
                            ha="center", va="center", color="w")
                
                
                plt.savefig(fig_path)
                plt.clf()
                # st()

def draw_heatmap_allconv():
    
    modes = [
        "posnegweight_small",
        # "posonlyweight_small",
    ]
    for mode in modes:
        for ratio in np.arange(0.1, 1.0, 0.1):
            print(f"{mode} ratio={ratio}")
            interclass_matrix = []
            for class_id in list(range(10))+["all"]:
                filename = f"allconv_class_{class_id}.csv"
                path = os.path.join(dir, filename)
                df = pd.read_csv(path, index_col=0)
                df = df[df['ratio'] == round(ratio, 2)]
                df = df.sort_values(by="test_class", ascending=True)
                
                df = df[mode]
                interclass_matrix.append(df.to_numpy())
            
            interclass_matrix = np.stack(interclass_matrix)
            print(interclass_matrix)
            print()
            
            # plot
            fig_name = f"heatmap_ratio={round(ratio, 1)}.pdf"
            fig_path = os.path.join(fig_dir, fig_name)
            fig = plt.figure()
            ax = fig.add_subplot(111)
            cax = ax.matshow(
                interclass_matrix, 
                interpolation='nearest', cmap='winter',
                vmin=0.5, vmax=0.95
            )
            fig.colorbar(cax)
            
            tick_spacing = 1
            ax.xaxis.set_major_locator(ticker.MultipleLocator(tick_spacing))
            ax.yaxis.set_major_locator(ticker.MultipleLocator(tick_spacing))
            
            ax.set_xticklabels([''] + list(range(10)))
            ax.set_yticklabels([''] + list(range(10)) + ["All"])
            
            for i in range(11):
                for j in range(10):
                    text = ax.text(j, i, interclass_matrix[i, j],
                        ha="center", va="center", color="w")
            
            
            plt.savefig(fig_path)
            plt.clf()
            # st()

def extract_auc_cmp():
    modes = [
        "posnegweight_small",
        "posonlyweight_small",
        "edgeweight_small",
    ]
    for ratio in np.arange(0.5, 0.6, 0.1):
        print(f"Ratio = {ratio}")
        ratio_cmp = []
        for class_id in range(10):
            filename = f"allconv_class_{class_id}.csv"
            path = os.path.join(dir, filename)
            df = pd.read_csv(path, index_col=0)
            df = df[df['test_class'] == class_id]
            df = df[df['ratio'] == ratio]
            ratio_cmp.append(df)
        ratio_cmp = pd.concat(ratio_cmp)
        print(ratio_cmp)
        print()
        
def draw_posneg_channel_cmp_hist():
    # All trace on each class
    filename = f"allconv_class_all.csv"
    path = os.path.join(dir, filename)
    all_df = pd.read_csv(path, index_col=0)
    
    for ratio in np.arange(0.01, 0.1, 0.01):
        print(ratio)
        df = all_df[all_df['ratio'] == ratio]
        if len(df) == 0:
            continue
        posneg = df['posneg_small'].to_list()
        weight = df['channelweight_small'].to_list()
        class_ids = df['test_class'].to_list()
        
        fig, ax = plt.subplots(figsize=(8,6))
        width = 0.4
        rects1 = plt.bar(left=class_ids, height=posneg, width=0.4, label="Trace")
        rects2 = plt.bar(left=[i + width for i in class_ids], height=weight, width=0.4, label="Weight")
        
        ax.set_ylabel("F1 Score")
        ax.set_xlabel("Test Class")
        ax.set_title("Pruned Performance")
        ax.set_xticks([p + 0.5 * width for p in class_ids])
        ax.set_xticklabels(class_ids)
        plt.ylim(0, 1)
        
        plt.legend()
        
        fig_name = f"posneg_weight_cmp_hist_alltrace_ratio{round(ratio,2)}.pdf"
        fig_path = os.path.join(fig_dir, fig_name)
        plt.savefig(fig_path)
        plt.clf()
    
    # Class trace on each class
    for ratio in np.arange(0.4, 0.7, 0.1):
        results = []
        for class_id in range(10):
            filename = f"allconv_class_{class_id}.csv"
            path = os.path.join(dir, filename)
            df = pd.read_csv(path, index_col=0) 
            df = df[df['ratio'] == round(ratio, 2)]
            df = df[df['test_class'] == class_id]
            results.append(df)
        class_df = pd.concat(results)
        
        posneg = class_df['posneg_small'].to_list()
        weight = class_df['channelweight_small'].to_list()
        class_ids = class_df['test_class'].to_list()
        
        fig, ax = plt.subplots(figsize=(8,6))
        width = 0.4
        rects1 = plt.bar(left=class_ids, height=posneg, width=0.4, label="Trace")
        rects2 = plt.bar(left=[i + width for i in class_ids], height=weight, width=0.4, label="Weight")
        
        ax.set_ylabel("F1 Score")
        ax.set_xlabel("Test Class")
        ax.set_title("Pruned Performance")
        ax.set_xticks([p + 0.5 * width for p in class_ids])
        ax.set_xticklabels(class_ids)
        plt.ylim(0, 1)
        
        plt.legend()
        
        fig_name = f"posneg_weight_cmp_hist_classtrace_ratio{round(ratio,2)}.pdf"
        fig_path = os.path.join(fig_dir, fig_name)
        plt.savefig(fig_path)
        plt.clf()

draw_posneg_channel_cmp_hist()
# draw_heatmap_allconv()
# extract_auc_cmp()