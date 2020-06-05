import os, sys
import pickle
import numpy as np
from pdb import set_trace as st

from nninst_utils.fs import ensure_dir, IOAction

images_per_class = 10
model_label = "dropout"
model_dir = f"result/resnet10cifar10/model_{model_label}"
attack_dir = os.path.join(model_dir, "attack", "test")

attack_names = [
    "FGSM_1", "FGSM_2", "FGSM_4", "FGSM_8",
    "DeepFoolLinf", "DeepFoolL2",
    "JSMA_2", "JSMA_4", "JSMA_8",
    "BIM_2", "BIM_4", "BIM_8",
    "RPGD_2", "RPGD_4", "RPGD_8",
    "CWL2", "ADef"
]
def cmp_per_image(
    class_id,
    image_id,
):
    for attack1 in attack_names[9:]:
        for attack2 in attack_names[10:]:
            
            path = os.path.join(attack_dir, attack1, f"{class_id}", f"{image_id}.pkl")
            image1 = IOAction(path, init_fn=None, cache=True, compress=True).load()

            path = os.path.join(attack_dir, attack2, f"{class_id}", f"{image_id}.pkl")
            image2 = IOAction(path, init_fn=None, cache=True, compress=True).load()
            
            if image1 is None or image2 is None:
                print(f"{attack1}, {attack2} has none")
                continue
            diff = np.abs(image1 - image2)*255
            print(f"{attack1}, {attack2}, diff min={diff.min():.3f}, diff max={diff.max():.3f}")
            
    
    
def cmp_adv_diff():
    for class_id in range(1):
        for image_id in range(1):
            cmp_per_image(
                class_id,
                image_id,
            )
            
cmp_adv_diff()