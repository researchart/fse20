from functools import partial
from pdb import set_trace as st
import tensorflow as tf
import numpy as np
import random

from foolbox.attacks import (
    FGSM,
    DeepFoolAttack,
    IterativeGradientSignAttack,
    SaliencyMapAttack,
)

import nninst_mode as mode
from dataset import mnist
from dataset.mnist_transforms import *
# from nninst.backend.tensorflow.dataset.imagenet_preprocessing import _CHANNEL_MEANS
from nninst_utils.ray import ray_init

# from .adversarial_patch_attack import (
#     new_patch_generate_adversarial_example,
#     patch_generate_adversarial_example,
# )
from .common import (
    lenet_mnist_example,
    # alexnet_imagenet_example,
    generate_examples,
    # resnet_50_imagenet_example,
    # vgg_16_imagenet_example,
)
from .cw_attack import cw_generate_adversarial_example
from .cw_attacks import CarliniL2
from .foolbox_attack import foolbox_generate_adversarial_example, random_targeted
from .foolbox_attacks.fgsm import TargetedFGSM, TargetedIterativeFGSM
# from .random_attack import RandomAttack, generate_negative_example

class_num = 1
images_per_class = 1

num_gpus = 0.2

model_label = "augmentation"
model_dir = f"result/lenet/model_{model_label}"
# Use what dataset to generate adv examples
mnist_dataset_mode = "test"

def generate_mnist_examples():

    num_gpus = 0.2

    example_fn = partial(
        lenet_mnist_example,
        model_dir=model_dir,
        mode = mnist_dataset_mode,
    )

    for generate_adversarial_fn, attack_name, attack_fn in [
        [foolbox_generate_adversarial_example, "FGSM", FGSM],
        # [foolbox_generate_adversarial_example, "DeepFool", DeepFoolAttack],
        # [foolbox_generate_adversarial_example, "JSMA", SaliencyMapAttack],
        # [foolbox_generate_adversarial_example, "BIM", IterativeGradientSignAttack],
        # [cw_generate_adversarial_example, "CWL2", CarliniL2],
    ]:
        for transforms, transform_name in [
            [None, "noop"],
            # [Translate(dx=5,dy=-5), "rightup"],
            # [Translate(dx=-5,dy=-5), "leftup"],
            # [Translate(dx=-5), "left"],
            # [Translate(dy=5), "down"],
        ]:
            class_ids = range(class_num)
            image_ids = range(images_per_class)
            arch_args = dict(preprocessing=(0.1307, 0.3081),
                 image_size=28,
                 class_num=class_num,
                 norm_fn=mnist.normalize,
                 data_format="channels_first",
                 num_gpus = num_gpus,
                 cache=False
                )

            generate_examples(
                example_fn=example_fn,
                class_ids=class_ids,
                image_ids=image_ids,
                attack_name=attack_name,
                attack_fn=attack_fn,
                generate_adversarial_fn=generate_adversarial_fn,
                transforms = transforms,
                transform_name = transform_name,
                **arch_args,
            )


if __name__ == "__main__":
    mode.debug()
    # mode.local()
    ray_init(
        log_to_driver=False
    )

    tf.set_random_seed(3)
    np.random.seed(3)
    random.seed(3)

    generate_mnist_examples()
