import csv
import random
from functools import partial
from typing import Callable, Optional
from pdb import set_trace as st
import os
import random
import pandas as pd
from typing import Any, Callable, Dict, Iterable, List, Tuple, Union
import datetime
import shutil
import copy
import argparse

import numpy as np
import tensorflow as tf
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
# from foolbox.criteria import TargetClass
# from foolbox.models import TensorFlowModel
from tensorflow.python.training import saver
from tensorflow.python.training.session_manager import SessionManager
import tensorflow as tf
import numpy as np
import pickle
import sklearn.metrics as metrics
import matplotlib.pyplot as plt
plt.switch_backend('Agg')

from model.config import LENET
import nninst_mode as mode

from dataset.config import MNIST_TRAIN, MNIST_PATH, CIFAR10_PATH
from dataset.cifar10_main import input_fn_for_adversarial_examples
from trace.common import (
    class_trace,
)
from tf_utils import new_session_config
from nninst_statistics import calc_trace_side_overlap
from nninst_trace import TraceKey
from nninst_utils.numpy import arg_approx, arg_abs_approx
from nninst_utils.ray import ray_init
from nninst_utils.fs import (ensure_dir, IOAction, 
                            CsvIOAction, abspath, IOBatchAction,
                            IOObjAction)
from model.resnet10cifar10 import ResNet10Cifar10

from .common import get_overlay_summary, clean_overlap_ratio, \
                translation_overlap_ratio, attack_overlap_ratio, \
                resnet10_cifar10_example
from .cw_attack import cw_generate_adversarial_example
from .cw_attacks import CarliniL2
from .eval_mnist import  foolbox_generate_adversarial_example
from nninst_graph import AttrMap, Graph, GraphAttrKey
from nninst_utils.ray import ray_iter
from tf_graph import (
    MaskWeightWithTraceHook,
    model_fn_with_fetch_hook,
)
from trace.common import (
    get_predicted_value,
    get_rank,
    predict,
    predict_batch,
    reconstruct_class_trace_from_tf,
    reconstruct_trace_from_tf,
    reconstruct_trace_from_tf_to_trace,
    reconstruct_trace_from_tf_brute_force,
)
from .analyse_class_trace import reconstruct_edge
from eval.lenetmnist_save_traces import ClassTraceIOAction

# Model config
model_label = "dropout"
model_dir = f"result/resnet10cifar10/model_{model_label}"

threshold = 0.5

dataset_mode = "test"
# result_dir = f"{model_dir}/per_image_trace_{threshold}/{dataset_mode}"
# result_dir = f"result/lenet/test"
class_num = 10
images_per_class = 1
chunksize = 1
attack_name = "FGSM"
batch_size = 1000

use_class_trace = False
if use_class_trace:
    sum_precision_error = 0.2
    threshold_bar_ratio = 0.01
    select_fn = lambda input, output: arg_abs_approx(
        input, 
        output,
        sum_precision_error=sum_precision_error,
        threshold_bar_ratio=threshold_bar_ratio,
    )
else:
    select_fn = lambda input: arg_approx(input, threshold)
    
attacks = {
    "original": [FGSM],
    "FGSM_1": [FGSM],
    "FGSM_2": [FGSM],
    "FGSM_4": [FGSM],
    "FGSM_8": [FGSM],
    
    "DeepFoolLinf": [DeepFoolLinfinityAttack],
    "DeepFoolL2": [DeepFoolL2Attack],
    
    "JSMA": [SaliencyMapAttack],
    
    "BIM_2": [IterativeGradientSignAttack],
    "BIM_4": [IterativeGradientSignAttack],
    "BIM_8": [IterativeGradientSignAttack],
    
    "RPGD_B": [RandomPGD],
    "RPGD_2": [RandomPGD],
    "RPGD_4": [RandomPGD],
    "RPGD_8": [RandomPGD],
    
    "CWL2": [CarliniWagnerL2Attack],
    "ADef": [ADefAttack],

    "SinglePixel": [SinglePixelAttack],
    "LocalSearch": [LocalSearchAttack],
    
    "Boundary": [BoundaryAttack],
    "Spatial": [SpatialAttack],
    "Pointwise": [PointwiseAttack],
    "GaussianBlur": [GaussianBlurAttack],
}

# DeepFool will shutdown when num_gpu<0.2
num_gpus = 0.5

per_channel = False

def clear_global_vars(init_globals):
    # for key, value in globals().items():
    for key in list(globals().keys()):
        value = globals()[key]
        # if callable(value) or value.__class__.__name__ == "module":
        if key in init_globals:
            continue
        del globals()[key]
        
        
# Compute the mean overlap ratio of attacked image
def save_graph(
    attack_name: str,
    attack_fn,
    generate_adversarial_fn,
    select_fn: Callable[[np.ndarray], np.ndarray],
    image_id_index,
    batch_size,
    class_id,
    # model_dir = "result/lenet/model_augmentation",
    model_dir = model_dir,
    transforms = None,
    transform_name = "noop",
    graph_dir = "result/test",
    dataset_mode = dataset_mode,
    images_per_class = 1,
    compute_adversarial = True,
    **kwargs,
):
    
    # mode.check(False)
    data_dir = abspath(CIFAR10_PATH)
    model_dir = abspath(model_dir)
    ckpt_dir = f"{model_dir}/ckpts"
    create_model = lambda: partial(
        ResNet10Cifar10(),
        training = False,
    )
    graph = ResNet10Cifar10.graph().load()
    
    batch_size = min(batch_size, images_per_class - image_id_index)
    
    predicted_label = predict_batch(
        create_model=create_model,
        input_fn=lambda: (
            input_fn_for_adversarial_examples(
                is_training= (dataset_mode == "train"),
                data_dir=data_dir,
                num_parallel_batches=1,
                is_shuffle=False,
                transform_fn=None,
            )
            .filter(
                lambda image, label: tf.equal(
                    tf.convert_to_tensor(class_id, dtype=tf.int32), label
                )
            )
            .skip(image_id_index)
            .take(batch_size)
            .batch(batch_size)
            .make_one_shot_iterator()
            .get_next()[0]
        ),
        model_dir=ckpt_dir,
    )
    prediction_valid = (predicted_label == class_id)
    if compute_adversarial:
        # The shape of each example is (1, 32, 32, 3)
        adversarial_examples = [resnet10_cifar10_example(
            attack_name=attack_name,
            attack_fn=attack_fn,
            generate_adversarial_fn=generate_adversarial_fn,
            class_id=class_id,
            image_id=image_id,
            # model_dir not ckpt_dir
            model_dir=model_dir,
            transforms = transforms,
            transform_name = transform_name,
            dataset_mode = dataset_mode,
        ).load()
            for image_id in range(image_id_index, image_id_index + batch_size)
        ]

        adversarial_valid = np.array([
            example is not None
            for example in adversarial_examples
        ])
        adversarial_examples = [
            example if example is not None else np.zeros((1, 32, 32, 3))
            for example in adversarial_examples
        ]
        adversarial_examples = np.squeeze(
            np.array(
                adversarial_examples
            ).astype(np.float32)
            , axis=1
        )
        
        # adversarial_example is [0, 1] of shape (1, 32, 32, 3)
        adversarial_predicted_label = predict_batch(
            create_model=create_model,
            input_fn=lambda: tf.data.Dataset.from_tensors(
                adversarial_examples
            ),
            model_dir=ckpt_dir,
        )
        adversarial_prediction_valid = adversarial_predicted_label != class_id
    
    if compute_adversarial:
        batch_valid = (prediction_valid * adversarial_valid *
                    adversarial_prediction_valid)
    else:
        batch_valid = (prediction_valid)
        
    original_graph_dir = os.path.join(graph_dir, f"original_{transform_name}",
                        f"{class_id}")
    original_graph_saver = IOBatchAction(
        dir=original_graph_dir,
        root_index=image_id_index,
    )
    original_model_fn = partial(
        model_fn_with_fetch_hook,
        create_model=create_model, 
        graph=graph,
        graph_saver=original_graph_saver,
        batch_valid=batch_valid,
    )
    
    trace = reconstruct_trace_from_tf(
        class_id=class_id,
        model_fn=original_model_fn,
        input_fn=lambda: (
            input_fn_for_adversarial_examples(
                is_training= (dataset_mode == "train"),
                data_dir=data_dir,
                num_parallel_batches=1,
                is_shuffle=False,
                transform_fn=None,
            )
            .filter(
                lambda image, label: tf.equal(
                    tf.convert_to_tensor(class_id, dtype=tf.int32), label
                )
            )
            .skip(image_id_index)
            .take(batch_size)
            .batch(batch_size)
            .make_one_shot_iterator()
            .get_next()[0]
        ),
        select_fn=select_fn,
        model_dir=ckpt_dir,
    )
    if compute_adversarial:
        adversarial_graph_dir = os.path.join(graph_dir, 
                            f"{attack_name}_{transform_name}",
                            f"{class_id}")
        adversarial_graph_saver = IOBatchAction(
            dir=adversarial_graph_dir,
            root_index=image_id_index,
        )
        adversarial_model_fn = partial(
            model_fn_with_fetch_hook,
            create_model=create_model, 
            graph=graph,
            graph_saver=adversarial_graph_saver,
            batch_valid=batch_valid,
        )
        
        adversarial_trace = reconstruct_trace_from_tf(
            model_fn=adversarial_model_fn,
            input_fn=lambda: tf.data.Dataset.from_tensors(
                adversarial_examples
            ),
            select_fn=select_fn,
            model_dir=ckpt_dir,
        )



def graph_to_trace(
    attack_name,
    image_id_index,
    batch_size,
    class_id,
    save_dir = "result/test",
    graph_dir = "result/test",
    chunksize = 1,
    transform_name = "noop",
    images_per_class = 10,
    compute_adversarial = True,
    use_class_trace = False,
    class_dir = None,
):
    
    def compute_trace(
        class_id, image_id,
    ):
        def compute_trace_per_attack(
            attack_name
        ):
            graph_path = os.path.join(graph_dir, f"{attack_name}_{transform_name}",
                                f"{class_id}", f"{image_id}.pkl")
            if not os.path.exists(graph_path):
                return
            
            single_graph = IOObjAction(
                graph_path
            ).load()
            if use_class_trace:
                logits = single_graph.tensor(single_graph.outputs[0]).value
                predicted_label = np.argmax(logits)
                class_trace_avg = ClassTraceIOAction(class_dir, predicted_label).load()
                assert class_trace_avg is not None
            else:
                class_trace_avg = None
            global debug
            single_trace = reconstruct_trace_from_tf_to_trace(
                single_graph,
                class_id=(class_id if attack_name=="original" else None),
                select_fn=select_fn,
                class_trace=class_trace_avg,
                debug=debug,
            )
            if single_trace is None:
                return
            trace_path = os.path.join(save_dir, f"{attack_name}_{transform_name}",
                                f"{class_id}", f"{image_id}.pkl")
            IOObjAction(
                trace_path
            ).save(single_trace)
            
            del single_graph
            del single_trace
        
        TraceKey.BUG_IMAGEID = image_id
        compute_trace_per_attack("original")

        if compute_adversarial:
            compute_trace_per_attack(attack_name)
        
        
    batch_param = [
        (class_id, image_id)
        for image_id in range(image_id_index, 
                            min(image_id_index+batch_size, images_per_class))
    ]
    results = ray_iter(
        compute_trace,
        batch_param,
        chunksize=chunksize,
        out_of_order=True,
    )
    results = [result for result in results]

def save_training_trace(
    attack_name,
    images_per_class,
    batch_size,
    dataset_mode,
    cpu_chunksize = 1,
    compute_adversarial = False,
    use_class_trace = False,
    class_dir = None,
):
    graph_dir = f"{model_dir}/per_image_graph_{threshold}/{dataset_mode}"
    if use_class_trace:
        result_dir = (f"{model_dir}/nninst_mu_posneg/"
            f"per_image_trace_{threshold}_sum{sum_precision_error}_bar{threshold_bar_ratio}"
            f"/{dataset_mode}")
    else:
        result_dir = (f"{model_dir}/nninst_mu_posneg/"
            f"per_image_trace_{threshold}_posonly/{dataset_mode}")
    print(f"Computing {attack_name} {dataset_mode}")
    init_global_var = globals()
    all_start = datetime.datetime.now()
    for class_id in range(class_num):
        for image_id_index in range(0, images_per_class, batch_size):
            start = datetime.datetime.now()
            save_graph(
                attack_name=attack_name,
                attack_fn=attacks[attack_name][0],
                generate_adversarial_fn=cw_generate_adversarial_example
                if attack_name.startswith("CW")
                else foolbox_generate_adversarial_example,
                select_fn=select_fn,
                image_id_index=image_id_index,
                batch_size=batch_size,
                class_id=class_id,
                preprocessing=(0, 1),
                image_size=32,
                class_num=10,
                data_format="channels_first",
                **(attacks[attack_name][1] if len(attacks[attack_name]) == 2 else {}),
                model_dir=model_dir,
                graph_dir=graph_dir,
                dataset_mode = dataset_mode,
                images_per_class=images_per_class,
                compute_adversarial=compute_adversarial,
            )
            duration_second = (datetime.datetime.now() - start).seconds
            duration_minute = duration_second / 60
            print(f"Finish class {class_id} graph "
                f"from {image_id_index} ",
                f"to {min(images_per_class, image_id_index+batch_size)}, "
                f"time used {duration_second}s, {duration_minute:.1f}m")
            
            start = datetime.datetime.now()
            graph_to_trace(
                attack_name,
                image_id_index=image_id_index,
                batch_size=batch_size,
                class_id=class_id,
                save_dir=result_dir,
                graph_dir=graph_dir,
                chunksize=cpu_chunksize,
                images_per_class=images_per_class,
                compute_adversarial=compute_adversarial,
                use_class_trace=use_class_trace,
                class_dir=class_dir,
            )
            duration_second = (datetime.datetime.now() - start).seconds
            duration_minute = duration_second / 60
            print(f"Finish class {class_id} graph to trace, "
                f"from {image_id_index} to {image_id_index+batch_size}, "
                f"time used {duration_second}s, {duration_minute:.1f}m")
            
            if os.path.exists(graph_dir):
                shutil.rmtree(graph_dir)
                
            clear_global_vars(init_global_var)
    duration_second = (datetime.datetime.now() - all_start).seconds
    duration_minute = duration_second / 60
    print(f"Finish all classes, "
        f"time used {duration_second}s, {duration_minute:.1f}m")

# debug = False

def compute_raw_nninst_trace():
    if debug:
        dataset_mode, images_per_class = "train", 1
        cpu_chunksize = 1
        batch_size = 1
        save_training_trace(
            attack_name = attack_name,
            cpu_chunksize=cpu_chunksize,
            compute_adversarial=True
        )
    else:
        cpu_chunksize = 4
        batch_size = 100
        
        dataset_mode, images_per_class = "train", 1000
        save_training_trace(
            attack_name = attack_name,
            cpu_chunksize=cpu_chunksize,
            compute_adversarial=False,
        )
        dataset_mode, images_per_class = "test", 100
        save_training_trace(
            attack_name = attack_name,
            cpu_chunksize=cpu_chunksize,
            compute_adversarial=True,
        )
        


def save_class_avg_trace():
    def merge_trace(acc_trace, trace2):
        node_names = acc_trace.ops.keys()
        for node_name in node_names:
            if TraceKey.IO_AVG in acc_trace.ops[node_name]:
                acc_point_logger = acc_trace.ops[node_name][TraceKey.IO_AVG]
                if TraceKey.IO_AVG not in trace2.ops[node_name]:
                    st()
                new_point_logger = trace2.ops[node_name][TraceKey.IO_AVG]
                acc_point_logger += new_point_logger
                acc_trace.ops[node_name][TraceKey.IO_AVG] = acc_point_logger
        
    def save_average_traces(class_dir):
        all_traces = []
        result_dir = (f"{model_dir}/nninst_mu_posneg/"
                f"per_image_trace_{threshold}_posonly/{dataset_mode}")
        all_trace = None
        for class_id in range(class_num):
            print(f"class {class_id}")
            trace_dir = trace_path = os.path.join(result_dir, f"original_noop",
                                f"{class_id}")
            file_names = os.listdir(trace_dir)
            path = os.path.join(trace_dir, file_names[0])
            class_trace = IOObjAction(path).load()
            if class_id == 0:
                all_trace = copy.deepcopy(class_trace)
            for i, file_name in enumerate(file_names[1:]):
                path = os.path.join(trace_dir, file_name)
                trace = IOObjAction(path).load()
                merge_trace(class_trace, trace)
                merge_trace(all_trace, trace)
                if i % 100 == 0:
                    print(f"Loading class {class_id} {i}/{len(file_names)}")
            ClassTraceIOAction(class_dir, class_id).save(class_trace)
        ClassTraceIOAction(class_dir, "all").save(all_trace)
        
    
    class_dir = f"{model_dir}/nninst_mu_posneg/original_train_gathered_trace"
    if debug:
        if not use_class_trace:
            dataset_mode, images_per_class = "train", 20
            cpu_chunksize = 1
            batch_size = 1
            
            save_training_trace(
                attack_name = "original",
                images_per_class=images_per_class,
                batch_size=batch_size,
                dataset_mode=dataset_mode,
                cpu_chunksize=cpu_chunksize,
                compute_adversarial=use_class_trace,
                use_class_trace=use_class_trace,
                class_dir=class_dir,
            )
            save_average_traces(class_dir)
            
        else:
            dataset_mode, images_per_class = "train", 1
            cpu_chunksize = 1
            batch_size = 1
            
            # save_training_trace(
            #     attack_name = attack_name,
            #     images_per_class=images_per_class,
            #     batch_size=batch_size,
            #     dataset_mode=dataset_mode,
            #     cpu_chunksize=cpu_chunksize,
            #     use_class_trace=use_class_trace,
            #     compute_adversarial=False,
            #     class_dir=class_dir,
            # )
            
            dataset_mode, images_per_class = "test", 1
            for attack_name in [
                "original",
                # "FGSM_2", "FGSM_4", "FGSM_8",
                # "DeepFoolLinf", "DeepFoolL2",
                # "JSMA",
                # "RPGD_2", 
                # "RPGD_4", "RPGD_8",
                # "CWL2", "ADef",
                # "SinglePixel", "LocalSearch",
                # "Boundary", "Spatial", "Pointwise", "GaussianBlur",
            ]:
                save_training_trace(
                    attack_name = attack_name,
                    images_per_class=images_per_class,
                    batch_size=batch_size,
                    dataset_mode=dataset_mode,
                    cpu_chunksize=cpu_chunksize,
                    use_class_trace=use_class_trace,
                    compute_adversarial=use_class_trace,
                    class_dir=class_dir,
                )
        
    else:
        if not use_class_trace:
            dataset_mode, images_per_class = "train", 1000
            cpu_chunksize = 10
            batch_size = 320
            # dataset_mode, images_per_class = "train", 10
            # cpu_chunksize = 1
            # batch_size = 7
            
            save_training_trace(
                attack_name = "original",
                images_per_class=images_per_class,
                batch_size=batch_size,
                dataset_mode=dataset_mode,
                cpu_chunksize=cpu_chunksize,
                use_class_trace=use_class_trace,
                compute_adversarial=False,
            )
            save_average_traces(class_dir)
            
            # dataset_mode, images_per_class = "test", 10
            # for attack_name in [
            #     "original",
            #     "FGSM_2", "FGSM_4", "FGSM_8",
            #     "DeepFoolLinf", "DeepFoolL2",
            #     "JSMA",
            #     "RPGD_2", 
            #     "RPGD_4", "RPGD_8",
            #     "CWL2", "ADef",
            #     "SinglePixel", "LocalSearch",
            #     "Boundary", "Spatial", "Pointwise", "GaussianBlur",
            # ]:
            #     save_training_trace(
            #         attack_name = attack_name,
            #         images_per_class=images_per_class,
            #         batch_size=batch_size,
            #         dataset_mode=dataset_mode,
            #         cpu_chunksize=cpu_chunksize,
            #         use_class_trace=use_class_trace,
            #         compute_adversarial=True,
            #     )
            
        else:
            dataset_mode, images_per_class = "train", 1000
            cpu_chunksize = 10
            batch_size = 320
            # dataset_mode, images_per_class = "train", 10
            # cpu_chunksize = 1
            # batch_size = 10
            
            # save_training_trace(
            #     attack_name = attack_name,
            #     images_per_class=images_per_class,
            #     batch_size=batch_size,
            #     dataset_mode=dataset_mode,
            #     cpu_chunksize=cpu_chunksize,
            #     use_class_trace=use_class_trace,
            #     compute_adversarial=False,
            #     class_dir=class_dir,
            # )
            
            dataset_mode, images_per_class = "test", 50
            for attack_name in [
                # "original",
                # "FGSM_2", "FGSM_4", "FGSM_8",
                # "DeepFoolLinf", "DeepFoolL2",
                # "JSMA",
                # "RPGD_2", 
                "RPGD_4", "RPGD_8",
                "CWL2", "ADef",
                "SinglePixel", "LocalSearch",
                "Boundary", "Spatial", "Pointwise", "GaussianBlur",
            ]:
                save_training_trace(
                    attack_name = attack_name,
                    images_per_class=images_per_class,
                    batch_size=batch_size,
                    dataset_mode=dataset_mode,
                    cpu_chunksize=cpu_chunksize,
                    use_class_trace=use_class_trace,
                    compute_adversarial=True,
                    class_dir=class_dir,
                )


if __name__=="__main__":
    tf.set_random_seed(3)
    np.random.seed(3)
    random.seed(3)
    
    global debug
    parser = argparse.ArgumentParser(description='Save traces')
    # Required arguments
    parser.add_argument('--debug', action='store_true', default=False)
    args = parser.parse_args()
    
    debug = args.debug

    if debug:
        mode.debug()
    else:
        mode.local()

    # ray_init("gpu")
    ray_init(
        log_to_driver=False
    )
    
    save_class_avg_trace()
