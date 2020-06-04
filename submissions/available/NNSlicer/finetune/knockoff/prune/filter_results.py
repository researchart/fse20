import os, sys
import numpy as np
from pdb import set_trace as st
import pandas as pd

dir = f"models/prune/allconv_ratio_weight"

def filter_csv_result(df):
    df = df[df['ratio'] == 0.5]
    posnegweight = df['posnegweight_small']
    return posnegweight

    
path = os.path.join(dir, f"allconv_class_all.csv")
df = pd.read_csv(path, index_col=0)
# print(df)

# auc all
path = os.path.join(dir, f"allconv_class_auc_all.csv")
df = pd.read_csv(path, index_col=0)
df = df[df['ratio'] == 0.5]
print(df)
st()

interclass_matrix = []
for class_id in list(range(10))+["auc_all"]:
    path = os.path.join(dir, f"allconv_class_{class_id}.csv")
    df = pd.read_csv(path, index_col=0)
    df['trace_class'] = class_id
    posnegweight = filter_csv_result(df).to_numpy()
    interclass_matrix.append(posnegweight)

interclass_matrix = np.stack(interclass_matrix)
print(interclass_matrix)
st()
    