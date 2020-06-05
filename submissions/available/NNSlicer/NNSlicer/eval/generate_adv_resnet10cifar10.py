from functools import partial
from pdb import set_trace as st
import tensorflow as tf
import numpy as np
import random

from foolbox.attacks import (
    FGSM,
    DeepFoolAttack,
    DeepFoolLinfinityAttack,
    DeepFoolL2Attack,
    IterativeGradientSignAttack,
    SaliencyMapAttack,
    RandomPGD,
    CarliniWagnerL2Attack,
    ADefAttack,
    SinglePixelAttack,
    LocalSearchAttack,
    ApproximateLBFGSAttack,
    BoundaryAttack,
    SpatialAttack,
    PointwiseAttack,
    GaussianBlurAttack,
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
    resnet10_cifar10_example,
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

class_num = 10
images_per_class = 100
# Use what dataset to generate adv examples
cifar_dataset_mode = "test"

num_gpus = 0.2

model_label = "dropout"
model_dir = f"result/resnet10cifar10/model_{model_label}"


def generate_cifar10_examples():
    
    
    for generate_adversarial_fn, attack_name, attack_fn, attack_params in [
        [foolbox_generate_adversarial_example, "original", None, 
            {}
        ],
        [foolbox_generate_adversarial_example, "FGSM_2", FGSM, 
            {"epsilons": [2/255]}
        ],
        [foolbox_generate_adversarial_example, "FGSM_4", FGSM, 
            {"epsilons": [4/255]}
        ],
        [foolbox_generate_adversarial_example, "FGSM_8", FGSM, 
            {"epsilons": [8/255],}
        ],
        [foolbox_generate_adversarial_example, "FGSM_16", FGSM, 
            {"epsilons": [16/255],}
        ],
        
        [foolbox_generate_adversarial_example, "DeepFoolLinf", DeepFoolLinfinityAttack,
            {}],
        [foolbox_generate_adversarial_example, "DeepFoolL2", DeepFoolL2Attack,
            {}],
        
        [foolbox_generate_adversarial_example, "JSMA", SaliencyMapAttack,
            {"max_iter": 100}],
        
        [foolbox_generate_adversarial_example, "BIM_2", IterativeGradientSignAttack,
            {"epsilons": [2/255], "steps": 10}],
        [foolbox_generate_adversarial_example, "BIM_4", IterativeGradientSignAttack,
            {"epsilons": [4/255], "steps": 10}],
        [foolbox_generate_adversarial_example, "BIM_8", IterativeGradientSignAttack,
            {"epsilons": [8/255], "steps": 10}],
        [foolbox_generate_adversarial_example, "BIM_16", IterativeGradientSignAttack,
            {"epsilons": [16/255], "steps": 10}],
        
        # [foolbox_generate_adversarial_example, "RPGD_2", RandomPGD,
        #     {"iterations": 10, "epsilon": 2/255, "binary_search": False}],
        [foolbox_generate_adversarial_example, "RPGD_4", RandomPGD,
            {"iterations": 10, "epsilon": 4/255, "binary_search": False}],
        [foolbox_generate_adversarial_example, "RPGD_8", RandomPGD,
            {"iterations": 10, "epsilon": 8/255, "binary_search": False}],
        [foolbox_generate_adversarial_example, "RPGD_16", RandomPGD,
            {"iterations": 10, "epsilon": 16/255, "binary_search": False}],
        
        [foolbox_generate_adversarial_example, "CWL2", CarliniWagnerL2Attack, 
            {"max_iterations": 200}],
        [foolbox_generate_adversarial_example, "ADef", ADefAttack, 
            {}],
        
        # [foolbox_generate_adversarial_example, "SinglePixel", SinglePixelAttack, 
        #     {}],
        [foolbox_generate_adversarial_example, "LocalSearch", LocalSearchAttack, 
            {}],
        # Too slow
        # [foolbox_generate_adversarial_example, "ApproxLBFGS", ApproximateLBFGSAttack, 
        #     {}],
        
        [foolbox_generate_adversarial_example, "Boundary", BoundaryAttack, 
            {}],
        [foolbox_generate_adversarial_example, "Spatial", SpatialAttack, 
            {}],
        [foolbox_generate_adversarial_example, "Pointwise", PointwiseAttack, 
            {}],
        [foolbox_generate_adversarial_example, "GaussianBlur", GaussianBlurAttack, 
            {}],
    ]:
        generate_adversarial_fn = partial(
            generate_adversarial_fn,
            attack_params=attack_params,
        )
        example_fn = partial(
            resnet10_cifar10_example,
            model_dir=model_dir,
            dataset_mode = cifar_dataset_mode,
            generate_adversarial_fn=generate_adversarial_fn,
            attack_fn = attack_fn,
        )

        class_ids = range(class_num)
        image_ids = range(images_per_class)
        arch_args = dict(
            channel_axis=3,
            preprocessing=(0, 1),
            bounds=( 0, 1),
            )

        generate_examples(
            example_fn=example_fn,
            class_ids=class_ids,
            image_ids=image_ids,
            attack_name=attack_name,
            transforms = None,
            transform_name = "noop",
            num_gpus=num_gpus,
            **arch_args,
        )


if __name__ == "__main__":
    # mode.debug()
    mode.local()
    ray_init(
        log_to_driver=False
    )

    tf.set_random_seed(3)
    np.random.seed(3)
    random.seed(3)

    # generate_mnist_examples()
    
    # images_per_class, cifar_dataset_mode = 10, "train"
    # generate_cifar10_examples()

    generate_cifar10_examples()
