import os, sys
import pandas as pd
import numpy as np
from pdb import set_trace as st

model_label = "dropout"
model_dir = f"result/resnet10cifar10/model_{model_label}"
result_dir = os.path.join(model_dir, "nninst_mu_posneg")

feature_path = os.path.join(result_dir, "forward_feature", "result.csv")
feature = pd.read_csv(feature_path, index_col=0)
feature = feature.set_index("name")
# feature = feature.rename(columns={"name": "attack"})
feature = feature.round(2)

posneg_path = os.path.join(
    result_dir, 
    "posneg_edge_0.9/clf/conv2d_12", 
    "detection.csv"
)
posneg = pd.read_csv(posneg_path, index_col=0)
posneg = posneg.drop(columns=["adv_test_acc"])
posneg = posneg.set_index("attack")
posneg = posneg.round(2)

posonly_path = os.path.join(
    result_dir,
    "posonly_edge_0.5/clf/conv2d_12",
    "detection.csv"
)
posonly = pd.read_csv(posonly_path, index_col=0)
posonly = posonly.drop(columns=["adv_test_acc"])
posonly = posonly.set_index("attack")
posonly = posonly.round(2)


result = pd.concat({
    "Feature": feature,
    "NNSlicer": posneg,
    "EffectivePath": posonly,
}, axis=1)

print(result)

st()