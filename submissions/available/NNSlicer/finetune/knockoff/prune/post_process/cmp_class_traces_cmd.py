import os, sys
import numpy as np
from pdb import set_trace as st
import pandas as pd

dir =  f"models/prune/true_false_dist/allconv_weight"

def filter_csv_result(df):
    df = df[df['ratio'] == 0.5]
    posnegweight = df['posnegweight_small']
    return posnegweight

    
path = os.path.join(dir, f"allconv_class_all.csv")
df = pd.read_csv(path, index_col=0)
# print(df)

# auc all
# path = os.path.join(dir, f"allconv_class_auc_all.csv")
# df = pd.read_csv(path, index_col=0)
# df = df[df['ratio'] == 0.5]
# print(df)
# st()

# Compare between class trace and "all" trace on each class
path = os.path.join(dir, f"allconv_class_auc_all.csv")
all_df = pd.read_csv(path, index_col=0)
for class_id in range(10):
    path = os.path.join(dir, f"allconv_class_{class_id}.csv")
    class_df = pd.read_csv(path, index_col=0)
    class_df = class_df[class_df["test_class"] == class_id]
    class_df = class_df[["posnegweight_small", "ratio"]]
    class_df = class_df.rename(columns={"posnegweight_small": "class"})
    all_df_class = all_df[all_df["test_class"] == class_id]
    all_df_class = all_df_class[["posnegweight_small", "ratio"]]
    all_df_class = all_df_class.rename(columns={"posnegweight_small": "all"})
    df = pd.merge(class_df, all_df_class)
    print(class_id)
    print(df)
    print()
st()
    

# Auc between different classes
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
    