import os, sys
import shutil
from pdb import set_trace as st

# Model config
model_label = "dropout"
model_dir = f"result/resnet10cifar10/model_{model_label}"
root = f"{model_dir}/nninst_mu_posneg/per_image_trace_0.5_sum0.2_bar0.01/test"
transform_name = "noop"

for attack_name in [
        "original",
        # "FGSM_2", 
        # "FGSM_4", "FGSM_8",
        # "DeepFoolLinf", "DeepFoolL2",
        # "JSMA",
        # "RPGD_2", "RPGD_4", "RPGD_8",
        # "CWL2", "ADef",
        # "LocalSearch",
        # "Boundary", "Spatial", "Pointwise", "GaussianBlur",
    ]:
        for class_id in range(10):
            for image_id in range(50, 100):
                path = os.path.join(root, f"{attack_name}_{transform_name}", f"{class_id}", f"{image_id}.pkl")
                if os.path.exists(path):
                    os.remove(path)