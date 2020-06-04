import os, sys
import numpy as np
from pdb import set_trace as st
import pandas as pd

posneg_dir = f"models/prune/lastconv_class_auc_channel_pos+neg"
dir =  f"models/prune/lastconv_class_auc_channel"
result_dir = f"models/prune/lastconv_class_auc_channel_new"
os.makedirs(result_dir, exist_ok=True)

exp_configs = {
    "conv12": ["conv2d_12"],
    "block4": ["conv2d_10", "conv2d_11", "conv2d_12"],
    "block4main": ["conv2d_11", "conv2d_12"],
}

for class_id in ["all"] + list(range(10)):
    for exp_name in exp_configs.keys():
        filename = f"allconv_class_{exp_name}_{class_id}.csv"
        path = os.path.join(posneg_dir, filename)
        posneg_csv = pd.read_csv(path, index_col=0)
        path = os.path.join(dir, filename)
        other_csv = pd.read_csv(path, index_col=0)
        other_csv['posneg_small'] = posneg_csv['posneg_small']
        path = os.path.join(result_dir, filename)
        other_csv.to_csv(path)
        # st()