import itertools
import traceback
import uuid
from functools import partial, reduce
from typing import Any, Callable, Dict, Iterable, List, Tuple, Union
from pdb import set_trace as st

import numpy as np
import pandas as pd
import os
import tensorflow as tf

from nninst_graph import AttrMap, Graph, GraphAttrKey
import nninst_mode as mode
from dataset import cifar10
from dataset.mnist_transforms import *
from dataset.config import MNIST_PATH, CIFAR10_PATH
# from nninst.backend.tensorflow.dataset import imagenet, imagenet_raw
# from nninst.backend.tensorflow.dataset.imagenet_hierarchy import imagenet_class_tree
# from nninst.backend.tensorflow.dataset.imagenet_preprocessing import (
#     alexnet_preprocess_image,
# )
from tf_graph import (
    MaskWeightWithTraceHook,
    model_fn_with_fetch_hook,
)
from model import LeNet
from model.resnet18cifar10 import ResNet18Cifar10
from model.resnet10cifar10 import ResNet10Cifar10
# from nninst.backend.tensorflow.model import AlexNet, LeNet, ResNet50
from model.config import ModelConfig
# from nninst.backend.tensorflow.model.config import (
#     ALEXNET,
#     RESNET_50,
#     VGG_16,
#     ModelConfig,
# )
from trace.common import (
    get_predicted_value,
    get_rank,
    predict,
    reconstruct_class_trace_from_tf,
    reconstruct_trace_from_tf,
    reconstruct_trace_from_tf_brute_force,
)
from trace.common import (
    reconstruct_stat_from_tf,
    reconstruct_trace_from_tf_v2,
)
# from nninst.dataset.envs import IMAGENET_RAW_DIR
from nninst_op import Conv2dOp
from nninst_path import (
    get_trace_path_in_fc_layers,
    get_trace_path_intersection_in_fc_layers,
)
from nninst_statistics import (
    calc_trace_path_num,
    calc_trace_size,
    calc_trace_size_per_layer,
)
from nninst_trace import (
    TraceKey,
    compact_edge,
    compact_trace,
    merge_compact_trace,
    merge_compact_trace_diff,
    merge_compact_trace_intersect,
)
from nninst_utils import filter_value_not_null, merge_dict
from nninst_utils.fs import CsvIOAction, ImageIOAction, IOAction, abspath
from nninst_utils.numpy import arg_approx, arg_sorted_topk
from nninst_utils.ray import ray_iter

__all__ = [
    "clean_overlap_ratio",
    "overlap_ratio",
    "get_overlay_summary",
    "resnet_50_imagenet_overlap_ratio",
    "alexnet_imagenet_overlap_ratio",
    "resnet_50_imagenet_overlap_ratio_error",
    "get_overlay_summary_one_side",
    "resnet_50_imagenet_overlap_ratio_rand",
    "alexnet_imagenet_overlap_ratio_top5",
    "resnet_50_imagenet_overlap_ratio_top5_rand",
    "resnet_50_imagenet_overlap_ratio_top5",
    "alexnet_imagenet_overlap_ratio_error",
    "alexnet_imagenet_overlap_ratio_rand",
    "alexnet_imagenet_overlap_ratio_top5_rand",
    "alexnet_imagenet_overlap_ratio_top5_diff",
]


def calc_all_overlap(
    class_trace: AttrMap,
    trace: AttrMap,
    overlap_fn: Callable[[AttrMap, AttrMap, str], float],
    node_name: str = None,
    compact: bool = False,
    use_intersect_size: bool = False,
    key: str = TraceKey.EDGE,
) -> Dict[str, float]:
    if node_name is None:
        if use_intersect_size:
            overlap_ratio, intersect_size = overlap_fn(
                class_trace, trace, key, return_size=True
            )
            return {key + "_size": intersect_size, key: overlap_ratio}
        else:
            return {
                **{
                    key + "_size": calc_trace_size(trace, key, compact=compact)
                    for key in [
                        TraceKey.EDGE,
                        TraceKey.POINT,
                        TraceKey.WEIGHT
                    ]
                },
                **{
                    key: overlap_fn(class_trace, trace, key)
                    for key in [
                        TraceKey.EDGE,
                        TraceKey.POINT,
                        TraceKey.WEIGHT
                    ]
                },
            }
    else:
        all_overlap = {
            key: overlap_fn(class_trace, trace, key, node_name)
            for key in [
                TraceKey.EDGE,
                TraceKey.POINT,
                TraceKey.WEIGHT
            ]
        }
        for key in [
            TraceKey.EDGE,
            TraceKey.POINT,
            TraceKey.WEIGHT
        ]:
            if node_name in trace.ops:
                node_trace = trace.ops[node_name]
                if key in node_trace:
                    if compact:
                        all_overlap[key + "_size"] = np.count_nonzero(
                            np.unpackbits(node_trace[key])
                        )
                    else:
                        all_overlap[key + "_size"] = TraceKey.to_array(
                            node_trace[key]
                        ).size
        return all_overlap

# Compute mnist overlap ratio between the traces of clean test images and class traces
def clean_overlap_ratio(
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    overlap_fn: Callable[[AttrMap, AttrMap, str], float],
    path: str,
    per_channel: bool = False,
    per_node: bool = False,
    num_gpus:float = 0.2,
    images_per_class: int = 1,
    **kwargs,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            mode.check(False)
            data_dir = abspath(MNIST_PATH)
            model_dir = abspath("result/lenet/model_dropout")
            create_model = lambda: LeNet(data_format="channels_first")
            graph = LeNet.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook, create_model=create_model, graph=graph
            )

            predicted_label = predict(
                create_model=create_model,
                input_fn=lambda: mnist.test(data_dir)
                .filter(
                    lambda image, label: tf.equal(
                        tf.convert_to_tensor(class_id, dtype=tf.int32), label
                    )
                )
                .skip(image_id)
                .take(1)
                .batch(1),
                model_dir=model_dir,
            )
            # print(class_id, predicted_label)
            # st()
            if predicted_label != class_id:
                return [{}] if per_node else {}

            trace = reconstruct_trace_from_tf(
                class_id=class_id,
                model_fn=model_fn,
                input_fn=lambda: mnist.test(data_dir)
                .filter(
                    lambda image, label: tf.equal(
                        tf.convert_to_tensor(class_id, dtype=tf.int32), label
                    )
                )
                .skip(image_id)
                .take(1)
                .batch(1),
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
            )[0]

            if trace is None:
                return [{}] if per_node else {}

            def map_prefix(map: Dict[str, Any], prefix: str) -> Dict[str, Any]:
                return {f"{prefix}.{key}": value for key, value in map.items()}

            row = {
                "image_id": image_id,
                **map_prefix(
                    calc_all_overlap(
                        class_trace_fn(class_id).load(), trace, overlap_fn
                    ),
                    "original",
                ),
            }
            # st()
            return row

        traces = ray_iter(
            get_row,
            (
                (class_id, image_id)
                for image_id in range(0, images_per_class)
                for class_id in range(0, 10)
            ),
            chunksize=1,
            out_of_order=True,
            num_gpus=0.2,
        )
        traces = [trace for trace in traces if len(trace) != 0]
        return pd.DataFrame(traces)

    return CsvIOAction(path, init_fn=get_overlap_ratio)


# Compute transformed (translation, rotation and scale)
# mnist overlap ratio between the traces of clean test images and class traces
def translation_overlap_ratio(
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    overlap_fn: Callable[[AttrMap, AttrMap, str], float],
    path: str,
    per_channel: bool = False,
    per_node: bool = False,
    images_per_class: int = 1,
    transforms=None,
    name = None,
    num_gpus = 0.2,
    **kwargs,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            mode.check(False)
            data_dir = abspath(MNIST_PATH)
            model_dir = abspath("result/lenet/model_augmentation")
            create_model = lambda: LeNet(data_format="channels_first")
            graph = LeNet.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook, create_model=create_model, graph=graph
            )

            # Check the prediction on clean untransformed image, so don't need
            # transform
            predicted_label = predict(
                create_model=create_model,
                input_fn=lambda: mnist.test(data_dir)
                .filter(
                    lambda image, label: tf.equal(
                        tf.convert_to_tensor(class_id, dtype=tf.int32), label
                    )
                )
                .skip(image_id)
                .take(1)
                .batch(1),
                model_dir=model_dir,
            )
            # print(class_id, predicted_label)
            # st()
            if predicted_label != class_id:
                return [{}] if per_node else {}

            # Reconstruct regardless of the correctness of prediction
            trace = reconstruct_trace_from_tf_brute_force(
                class_id=class_id,
                model_fn=model_fn,
                input_fn=lambda: mnist.test(data_dir, transforms=transforms)
                .filter(
                    lambda image, label: tf.equal(
                        tf.convert_to_tensor(class_id, dtype=tf.int32), label
                    )
                )
                .skip(image_id)
                .take(1)
                .batch(1),
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
            )[0]

            if trace is None:
                return [{}] if per_node else {}

            def map_prefix(map: Dict[str, Any], prefix: str) -> Dict[str, Any]:
                return {f"{prefix}.{key}": value for key, value in map.items()}

            row = calc_all_overlap(
                class_trace_fn(class_id).load(), trace, overlap_fn
            )
            # row = {
            #     "image_id": image_id,
            #     **map_prefix(
            #         calc_all_overlap(
            #             class_trace_fn(class_id).load(), trace, overlap_fn
            #         ),
            #         "original",
            #     ),
            # }
            # st()
            return row

        traces = ray_iter(
            get_row,
            (
                (class_id, image_id)
                # for image_id in range(0, images_per_class)
                for image_id in range(0, images_per_class)
                for class_id in range(0, 10)
            ),
            chunksize=1,
            out_of_order=True,
            num_gpus=num_gpus,
        )
        traces = [trace for trace in traces if len(trace) != 0]
        acc = len(traces) / (images_per_class * 10)
        traces = pd.DataFrame(traces).mean()
        traces.loc['accuracy'] = acc
        traces = traces.to_frame()
        traces.columns = [name]
        return traces

    return CsvIOAction(path, init_fn=get_overlap_ratio)

# Compute the mean overlap ratio of attacked image
def attack_overlap_ratio(
    attack_name: str,
    attack_fn,
    generate_adversarial_fn,
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    overlap_fn: Callable[[AttrMap, AttrMap, str], float],
    path: str,
    per_channel: bool = False,
    per_node: bool = False,
    images_per_class: int = 1,
    num_gpus: float = 0.2,
    model_dir = "result/lenet/model_augmentation",
    transforms = None,
    transform_name = "noop",
    **kwargs,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            nonlocal model_dir
            mode.check(False)
            data_dir = abspath(MNIST_PATH)
            model_dir = abspath(model_dir)
            ckpt_dir = f"{model_dir}/ckpts"
            create_model = lambda: LeNet(data_format="channels_first")
            graph = LeNet.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook,
                create_model=create_model, graph=graph
            )

            predicted_label = predict(
                create_model=create_model,
                input_fn=lambda: mnist.test(data_dir)
                .filter(
                    lambda image, label: tf.equal(
                        tf.convert_to_tensor(class_id, dtype=tf.int32), label
                    )
                )
                .skip(image_id)
                .take(1)
                .batch(1),
                model_dir=ckpt_dir,
            )
            if predicted_label != class_id:
                return [{}] if per_node else {}

            adversarial_example = lenet_mnist_example(
                attack_name=attack_name,
                attack_fn=attack_fn,
                generate_adversarial_fn=generate_adversarial_fn,
                class_id=class_id,
                image_id=image_id,
                # model_dir not ckpt_dir
                model_dir=model_dir,
                transforms = transforms,
                transform_name = transform_name,
                mode = "test",
            ).load()

            if adversarial_example is None:
                return [{}] if per_node else {}

            adversarial_predicted_label = predict(
                create_model=create_model,
                input_fn=lambda: tf.data.Dataset.from_tensors(
                    mnist.normalize(adversarial_example)
                ),
                model_dir=ckpt_dir,
            )

            if predicted_label == adversarial_predicted_label:
                return [{}] if per_node else {}

            trace = reconstruct_trace_from_tf(
                class_id=class_id,
                model_fn=model_fn,
                input_fn=lambda: mnist.test(data_dir, transforms=transforms)
                .filter(
                    lambda image, label: tf.equal(
                        tf.convert_to_tensor(class_id, dtype=tf.int32), label
                    )
                )
                .skip(image_id)
                .take(1)
                .batch(1),
                select_fn=select_fn,
                model_dir=ckpt_dir,
                per_channel=per_channel,
            )[0]

            if trace is None:
                return [{}] if per_node else {}

            adversarial_trace = reconstruct_trace_from_tf_brute_force(
                model_fn=model_fn,
                input_fn=lambda: tf.data.Dataset.from_tensors(
                    mnist.normalize(adversarial_example)
                ),
                select_fn=select_fn,
                model_dir=ckpt_dir,
                per_channel=per_channel,
            )[0]

            adversarial_label = adversarial_trace.attrs[GraphAttrKey.PREDICT]

            def map_prefix(map: Dict[str, Any], prefix: str) -> Dict[str, Any]:
                return {f"{prefix}.{key}": value for key, value in map.items()}

            row = {
                "image_id": image_id,
                "class_id": class_id,
                **map_prefix(
                    calc_all_overlap(
                        class_trace_fn(class_id).load(), trace, overlap_fn
                    ),
                    "original",
                ),
                **map_prefix(
                    calc_all_overlap(
                        class_trace_fn(adversarial_label).load(),
                        adversarial_trace,
                        overlap_fn,
                    ),
                    "adversarial",
                ),
            }
            # row = calc_all_overlap(
            #     class_trace_fn(class_id).load(), adversarial_trace, overlap_fn
            # )
            return row

        traces = ray_iter(
            get_row,
            (
                (class_id, image_id)
                for image_id in range(0, images_per_class)
                for class_id in range(0, 10)
            ),
            # ((-1, image_id) for image_id in range(mnist_info.test().size)),
            chunksize=1,
            out_of_order=True,
            num_gpus=num_gpus,
        )
        traces = [trace for trace in traces if len(trace) != 0]

        # acc = len(traces) / (images_per_class * 10)
        # traces = pd.DataFrame(traces).mean()
        # traces.loc['clean_accuracy'] = acc
        # traces = traces.to_frame()
        # traces.columns = [attack_name]
        # return traces

        return pd.DataFrame(traces)

    return CsvIOAction(path, init_fn=get_overlap_ratio)


def lenet_mnist_example(
    attack_name,
    attack_fn,
    generate_adversarial_fn,
    class_id: int,
    image_id: int,
    model_dir: str,
    mode: str ,
    transform_name: str = "noop",
    transforms: Transforms = None,
    **kwargs,
) -> IOAction[np.ndarray]:
    def get_example() -> np.ndarray:
        data_dir = abspath(MNIST_PATH)
        ckpt_dir = f"{model_dir}/ckpts"
        ckpt_dir = abspath(ckpt_dir)
        create_model = lambda: LeNet(data_format="channels_first")

        if mode == "test":
            dataset = mnist.test
        elif mode == "train":
            dataset = mnist.train
        else:
            raise RuntimeError("Dataset invalid")
        input = dataset(data_dir,
                        normed=False,
                        transforms=transforms,
                        )
        # st()
        # input = input.filter(lambda image, label: tf.equal(tf.convert_to_tensor(class_id, dtype=tf.int32), label))
        adversarial_example = generate_adversarial_fn(
            label=class_id,
            create_model=create_model,
            input_fn=lambda: dataset(data_dir,
                                    normed=False,
                                    transforms=transforms,
                                    )
            .filter(
                lambda image, label: tf.equal(
                    tf.convert_to_tensor(class_id, dtype=tf.int32), label
                )
            )
            .skip(image_id)
            .take(1)
            .batch(1)
            .make_one_shot_iterator()
            .get_next()[0],
            attack_fn=attack_fn,
            model_dir=ckpt_dir,
            **kwargs,
        )
        return adversarial_example

    name = f"{attack_name}_{transform_name}"
    result_dir = f"{model_dir}/attack/{mode}/{name}/{class_id}"
    path = os.path.join(result_dir, f"{image_id}.pkl")
    return IOAction(path, init_fn=get_example, cache=True, compress=True)


def resnet18_cifar10_example(
    attack_name,
    attack_fn,
    generate_adversarial_fn,
    class_id: int,
    image_id: int,
    model_dir: str,
    dataset_mode: str ,
    transform_name: str = "noop",
    transforms: Transforms = None,
    **kwargs,
) -> IOAction[np.ndarray]:
    def get_one_input_from_dataset(dataset):
        input = (dataset
            .filter(
                lambda image, label: tf.equal(
                    tf.convert_to_tensor(class_id, dtype=tf.int32), label
                )
            )
            .skip(image_id)
            .take(1)
            .batch(1)
            .make_one_shot_iterator()
            .get_next()[0]
        )
        return input
        
    def get_example() -> np.ndarray:
        data_dir = abspath(CIFAR10_PATH)
        ckpt_dir = f"{model_dir}/ckpts"
        ckpt_dir = abspath(ckpt_dir)
        # create_model = lambda: LeNet(data_format="channels_first")
        create_model = lambda: partial(
            ResNet18Cifar10(),
            training = False,
        )
        
        from dataset.cifar10_main import input_fn_for_adversarial_examples
        # dataset = input_fn_for_adversarial_examples(
        #     is_training= False,
        #     data_dir=data_dir,
        #     num_parallel_batches=1,
        #     is_shuffle=False,
        #     transform_fn=None,
        # )
        # adversarial_example = generate_adversarial_fn(
        #     label=class_id,
        #     create_model=create_model,
        #     input_fn=lambda: get_one_input_from_dataset(
        #         dataset
        #     ),
        #     attack_fn=attack_fn,
        #     model_dir=ckpt_dir,
        #     **kwargs,
        # )
        
        adversarial_example = generate_adversarial_fn(
            label=class_id,
            create_model=create_model,
            input_fn=lambda: (
                input_fn_for_adversarial_examples(
                    is_training= False,
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
                .skip(image_id)
                .take(1)
                .batch(1)
                .make_one_shot_iterator()
                .get_next()[0]
            ),
            attack_fn=attack_fn,
            model_dir=ckpt_dir,
            **kwargs,
        )

        return adversarial_example

    name = f"{attack_name}_{transform_name}"
    result_dir = f"{model_dir}/attack/{dataset_mode}/{name}/{class_id}"
    path = os.path.join(result_dir, f"{image_id}.pkl")
    return IOAction(path, init_fn=get_example, cache=True, compress=True)

def resnet10_cifar10_example(
    attack_name,
    attack_fn,
    generate_adversarial_fn,
    class_id: int,
    image_id: int,
    model_dir: str,
    dataset_mode: str ,
    transform_name: str = "noop",
    transforms: Transforms = None,
    **kwargs,
) -> IOAction[np.ndarray]:
    def get_one_input_from_dataset(dataset):
        input = (dataset
            .filter(
                lambda image, label: tf.equal(
                    tf.convert_to_tensor(class_id, dtype=tf.int32), label
                )
            )
            .skip(image_id)
            .take(1)
            .batch(1)
            .make_one_shot_iterator()
            .get_next()[0]
        )
        return input
        
    def get_example() -> np.ndarray:
        data_dir = abspath(CIFAR10_PATH)
        ckpt_dir = f"{model_dir}/ckpts"
        ckpt_dir = abspath(ckpt_dir)
        # create_model = lambda: LeNet(data_format="channels_first")
        create_model = lambda: partial(
            ResNet10Cifar10(),
            training = False,
        )
        
        from dataset.cifar10_main import input_fn_for_adversarial_examples

        adversarial_example = generate_adversarial_fn(
            label=class_id,
            create_model=create_model,
            input_fn=lambda: (
                input_fn_for_adversarial_examples(
                    is_training= (dataset_mode=="train"),
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
                .skip(image_id)
                .take(1)
                .batch(1)
                .make_one_shot_iterator()
                .get_next()[0]
            ),
            attack_fn=attack_fn,
            model_dir=ckpt_dir,
            **kwargs,
        )

        return adversarial_example

    name = f"{attack_name}"
    result_dir = f"{model_dir}/attack/{dataset_mode}/{name}/{class_id}"
    path = os.path.join(result_dir, f"{image_id}.pkl")
    return IOAction(path, init_fn=get_example, cache=True, compress=True)

def adversarial_example_image(
    example_io: IOAction[np.ndarray], cache: bool = True
) -> IOAction[np.ndarray]:
    def get_example() -> np.ndarray:
        example = example_io.load()
        if example is None:
            return None
        return (np.squeeze(example, axis=0) * 255).astype(np.uint8)

    path = example_io.path.replace(".pkl", ".png")
    return ImageIOAction(path, init_fn=get_example, cache=cache)

def generate_examples(
    example_fn: Callable[..., IOAction[np.ndarray]],
    class_ids: Iterable[int],
    image_ids: Iterable[int],
    attack_name: str,
    transform_name: str = "noop",
    transforms = None,
    cache: bool = True,
    num_gpus=0.2,
    **kwargs,
):
    def generate_examples_fn(
        class_id: int, image_id: int
    ) -> Union[Tuple[int, int], Tuple[int, int, str]]:
        try:
            class_id = int(class_id)
            image_id = int(image_id)
            example_io = example_fn(
                attack_name=attack_name,
                class_id=class_id,
                image_id=image_id,
                cache=cache,
                transforms = transforms,
                transform_name = transform_name,
                **kwargs,
            )
            example_io.save()
            adversarial_example_image(example_io, cache=cache).save()
            return class_id, image_id
        except Exception:
            return class_id, image_id, traceback.format_exc()

    name = f"{attack_name}_{transform_name}"
    print(f"begin {name}, num_gpu={num_gpus}")
    if len(image_ids) > 99:
        chunksize = 4
    else:
        chunksize = 1
    results = ray_iter(
        generate_examples_fn,
        [(class_id, image_id) for image_id in image_ids for class_id in class_ids],
        chunksize=chunksize,
        out_of_order=True,
        num_gpus=num_gpus,
        # huge_task=True,
    )
    for result in results:
        if len(result) == 3:
            class_id, image_id, tb = result
            print(f"## raise exception from class {class_id}, image {image_id}:")
            print(tb)
        else:
            class_id, image_id = result
            # print(f"finish class {class_id} image {image_id}")
    print(f"finish {name}")


def get_overlay_summary(
    overlap_ratios: pd.DataFrame, trace_key: str, threshold=1
) -> Dict[str, int]:
    condition_positive = len(overlap_ratios)
    if condition_positive == 0:
        return {}
    original_key = f"original.{trace_key}"
    false_positive = np.count_nonzero(overlap_ratios[original_key] < threshold)
    adversarial_key = f"adversarial.{trace_key}"
    true_positive = np.count_nonzero(overlap_ratios[adversarial_key] < threshold)
    predicted_condition_positive = true_positive + false_positive
    recall = (true_positive / condition_positive) if condition_positive != 0 else 0
    precision = (
        (true_positive / predicted_condition_positive)
        if predicted_condition_positive != 0
        else 0
    )
    f1 = (2 / ((1 / recall) + (1 / precision))) if recall != 0 and precision != 0 else 0
    return dict(
        threshold=threshold,
        condition_positive=condition_positive,
        # predicted_condition_positive=predicted_condition_positive,
        original_is_higher=np.count_nonzero(
            (overlap_ratios[original_key] - overlap_ratios[adversarial_key]) > 0
        ),
        # adversarial_is_higher=np.count_nonzero(
        #     (overlap_ratios[adversarial_key] - overlap_ratios[original_key]) > 0),
        true_positive=true_positive,
        false_positive=false_positive,
        recall=recall,
        precision=precision,
        f1=f1,
    )


def overlap_ratio(
    attack_name: str,
    attack_fn,
    generate_adversarial_fn,
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    overlap_fn: Callable[[AttrMap, AttrMap, str], float],
    path: str,
    per_channel: bool = False,
    per_node: bool = False,
    **kwargs,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            mode.check(False)
            data_dir = abspath("/home/yxqiu/data/mnist/raw")
            model_dir = abspath("tf/lenet/model_early")
            create_model = lambda: LeNet(data_format="channels_first")
            graph = LeNet.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook, create_model=create_model, graph=graph
            )

            predicted_label = predict(
                create_model=create_model,
                input_fn=lambda: mnist.test(data_dir)
                .filter(
                    lambda image, label: tf.equal(
                        tf.convert_to_tensor(class_id, dtype=tf.int32), label
                    )
                )
                .skip(image_id)
                .take(1)
                .batch(1),
                model_dir=model_dir,
            )

            if predicted_label != class_id:
                return [{}] if per_node else {}

            # adversarial_example = generate_adversarial_fn(
            #     label=class_id,
            #     create_model=create_model,
            #     input_fn=lambda: mnist.test(data_dir, normed=False)
            #         .filter(lambda image, label:
            #                 tf.equal(
            #                     tf.convert_to_tensor(class_id, dtype=tf.int32),
            #                     label))
            #         .skip(image_id).take(1).batch(1)
            #         .make_one_shot_iterator().get_next()[0],
            #     attack_fn=attack_fn,
            #     model_dir=model_dir,
            #     **kwargs,
            # )

            adversarial_example = lenet_mnist_example(
                attack_name=attack_name,
                attack_fn=attack_fn,
                generate_adversarial_fn=generate_adversarial_fn,
                class_id=class_id,
                image_id=image_id,
            ).load()

            if adversarial_example is None:
                return [{}] if per_node else {}

            adversarial_predicted_label = predict(
                create_model=create_model,
                input_fn=lambda: tf.data.Dataset.from_tensors(
                    mnist.normalize(adversarial_example)
                ),
                model_dir=model_dir,
            )

            if predicted_label == adversarial_predicted_label:
                return [{}] if per_node else {}

            trace = reconstruct_trace_from_tf(
                class_id=class_id,
                model_fn=model_fn,
                input_fn=lambda: mnist.test(data_dir)
                .filter(
                    lambda image, label: tf.equal(
                        tf.convert_to_tensor(class_id, dtype=tf.int32), label
                    )
                )
                .skip(image_id)
                .take(1)
                .batch(1),
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
            )[0]

            # class_id = mnist_info.test().label(image_id)
            #
            # if class_id != trace.attrs[GraphAttrKey.PREDICT]:
            #     return [{}] if per_node else {}

            if trace is None:
                return [{}] if per_node else {}

            # adversarial_example = generate_adversarial_fn(
            #     label=class_id,
            #     create_model=create_model,
            #     input_fn=lambda: mnist.test(data_dir, normed=False)
            #         .filter(lambda image, label:
            #                 tf.equal(
            #                     tf.convert_to_tensor(class_id, dtype=tf.int32),
            #                     label))
            #         .skip(image_id).take(1).batch(1)
            #         .make_one_shot_iterator().get_next()[0],
            #     attack_fn=attack_fn,
            #     model_dir=model_dir,
            #     **kwargs,
            # )
            #
            # if adversarial_example is None:
            #     return [{}] if per_node else {}

            adversarial_trace = reconstruct_trace_from_tf(
                model_fn=model_fn,
                input_fn=lambda: tf.data.Dataset.from_tensors(
                    mnist.normalize(adversarial_example)
                ),
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
            )[0]

            adversarial_label = adversarial_trace.attrs[GraphAttrKey.PREDICT]

            if class_id != adversarial_label:

                def map_prefix(map: Dict[str, Any], prefix: str) -> Dict[str, Any]:
                    return {f"{prefix}.{key}": value for key, value in map.items()}

                row = {
                    "image_id": image_id,
                    **map_prefix(
                        calc_all_overlap(
                            class_trace_fn(class_id).load(), trace, overlap_fn
                        ),
                        "original",
                    ),
                    **map_prefix(
                        calc_all_overlap(
                            class_trace_fn(adversarial_label).load(),
                            adversarial_trace,
                            overlap_fn,
                        ),
                        "adversarial",
                    ),
                }
                return row
            else:
                return {}

        # traces = ray_iter(get_row, (image_id for image_id in range(300, 350)),
        # traces = ray_iter(get_row, (image_id for image_id in range(131, 300)),
        traces = ray_iter(
            get_row,
            (
                (class_id, image_id)
                for image_id in range(0, 100)
                for class_id in range(0, 10)
            ),
            # ((-1, image_id) for image_id in range(mnist_info.test().size)),
            chunksize=1,
            out_of_order=True,
            num_gpus=0,
        )
        # chunksize=1, out_of_order=False, num_gpus=1)
        # count = 0
        # result = []
        # for trace in traces:
        #     result.append(trace)
        #     print(count)
        #     count += 1
        # traces = [trace for trace in result if len(trace) != 0]
        traces = [trace for trace in traces if len(trace) != 0]
        return pd.DataFrame(traces)

    return CsvIOAction(path, init_fn=get_overlap_ratio)


def resnet_50_imagenet_overlap_ratio(
    attack_fn,
    generate_adversarial_fn,
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    overlap_fn: Callable[[AttrMap, AttrMap, str], float],
    path: str,
    per_node: bool = False,
    per_channel: bool = False,
    **kwargs,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            mode.check(False)
            data_dir = IMAGENET_RAW_DIR
            model_dir = abspath("tf/resnet-50-v2/model")
            create_model = lambda: ResNet50()
            graph = ResNet50.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook, create_model=create_model, graph=graph
            )

            trace = reconstruct_class_trace_from_tf(
                class_id,
                model_fn=model_fn,
                input_fn=lambda: imagenet_raw.test(data_dir, class_id, image_id),
                model_dir=model_dir,
                select_fn=select_fn,
                per_channel=per_channel,
            )

            if trace is None:
                return {}

            adversarial_example = generate_adversarial_fn(
                label=class_id,
                create_model=create_model,
                input_fn=lambda: imagenet_raw.test(
                    data_dir, class_id, image_id, normed=False
                )
                .make_one_shot_iterator()
                .get_next()[0],
                attack_fn=attack_fn,
                model_dir=model_dir,
                **kwargs,
            )

            if adversarial_example is None:
                return {}

            adversarial_trace = reconstruct_trace_from_tf(
                model_fn=model_fn,
                input_fn=lambda: tf.data.Dataset.from_tensors(
                    imagenet.normalize(adversarial_example)
                ),
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
            )[0]

            adversarial_label = adversarial_trace.attrs[GraphAttrKey.PREDICT]

            if class_id != adversarial_label:

                def map_prefix(map: Dict[str, Any], prefix: str) -> Dict[str, Any]:
                    return {f"{prefix}.{key}": value for key, value in map.items()}

                class_trace = class_trace_fn(class_id).load()
                adversarial_class_trace = class_trace_fn(adversarial_label).load()
                trace = compact_edge(trace, graph, per_channel=per_channel)
                adversarial_trace = compact_edge(
                    adversarial_trace, graph, per_channel=per_channel
                )
                if per_node:
                    rows = []
                    for node_name in class_trace.nodes:
                        row = {
                            "image_id": image_id,
                            "label": class_id,
                            "adversarial_label": adversarial_label,
                            "node_name": node_name,
                            **map_prefix(
                                calc_all_overlap(
                                    class_trace, trace, overlap_fn, node_name
                                ),
                                "original",
                            ),
                            **map_prefix(
                                calc_all_overlap(
                                    adversarial_class_trace,
                                    adversarial_trace,
                                    overlap_fn,
                                    node_name,
                                ),
                                "adversarial",
                            ),
                        }
                        if (
                            row[f"original.{TraceKey.WEIGHT}"] is not None
                            or row[f"original.{TraceKey.EDGE}"] is not None
                        ):
                            rows.append(row)
                    return rows
                else:
                    row = {
                        "image_id": image_id,
                        "label": class_id,
                        "adversarial_label": adversarial_label,
                        **map_prefix(
                            calc_all_overlap(class_trace, trace, overlap_fn), "original"
                        ),
                        **map_prefix(
                            calc_all_overlap(
                                adversarial_class_trace, adversarial_trace, overlap_fn
                            ),
                            "adversarial",
                        ),
                    }
                    print(row)
                    return row
            else:
                return [{}] if per_node else {}

        # traces = ray_iter(get_row, (image_id for image_id in range(300, 350)),
        # traces = ray_iter(get_row, (image_id for image_id in range(131, 300)),
        traces = ray_iter(
            get_row,
            (
                (class_id, image_id)
                for image_id in range(0, 1)
                # for image_id in range(0, 50)
                for class_id in range(1, 1001)
            ),
            # for class_id in range(1, 2)),
            chunksize=1,
            out_of_order=True,
            num_gpus=0,
        )
        # chunksize=1, out_of_order=False, num_gpus=1)
        # count = 0
        # result = []
        # for trace in traces:
        #     result.append(trace)
        #     print(count)
        #     count += 1
        # traces = [trace for trace in result if len(trace) != 0]
        if per_node:
            traces = list(itertools.chain.from_iterable(traces))
        traces = [trace for trace in traces if len(trace) != 0]
        return pd.DataFrame(traces)

    return CsvIOAction(path, init_fn=get_overlap_ratio)


def resnet_50_imagenet_overlap_ratio_top5(
    attack_fn,
    generate_adversarial_fn,
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    overlap_fn: Callable[[AttrMap, AttrMap, str], float],
    path: str,
    per_node: bool = False,
    per_channel: bool = False,
    **kwargs,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            mode.check(False)
            data_dir = IMAGENET_RAW_DIR
            model_dir = abspath("tf/resnet-50-v2/model")
            create_model = lambda: ResNet50()
            graph = ResNet50.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook, create_model=create_model, graph=graph
            )

            trace = reconstruct_trace_from_tf(
                class_id=class_id,
                model_fn=model_fn,
                input_fn=lambda: imagenet_raw.test(data_dir, class_id, image_id),
                select_fn=select_fn,
                model_dir=model_dir,
                top_5=True,
                per_channel=per_channel,
            )[0]

            if trace is None:
                return {}

            label_top5 = trace.attrs[GraphAttrKey.PREDICT_TOP5]

            adversarial_example = generate_adversarial_fn(
                label=class_id,
                create_model=create_model,
                input_fn=lambda: imagenet_raw.test(
                    data_dir, class_id, image_id, normed=False
                )
                .make_one_shot_iterator()
                .get_next()[0],
                attack_fn=attack_fn,
                model_dir=model_dir,
                **kwargs,
            )

            if adversarial_example is None:
                return {}

            adversarial_trace = reconstruct_trace_from_tf(
                model_fn=model_fn,
                input_fn=lambda: tf.data.Dataset.from_tensors(
                    imagenet.normalize(adversarial_example)
                ),
                select_fn=select_fn,
                model_dir=model_dir,
                top_5=True,
                per_channel=per_channel,
            )[0]

            adversarial_label = adversarial_trace.attrs[GraphAttrKey.PREDICT]
            adversarial_label_top5 = adversarial_trace.attrs[GraphAttrKey.PREDICT_TOP5]

            if adversarial_label not in label_top5:
                # if np.intersect1d(label_top5, adversarial_label_top5).size == 0:
                def map_prefix(map: Dict[str, Any], prefix: str) -> Dict[str, Any]:
                    return {f"{prefix}.{key}": value for key, value in map.items()}

                class_trace = merge_compact_trace(
                    *[class_trace_fn(label).load() for label in label_top5]
                )
                adversarial_class_trace = merge_compact_trace(
                    *[class_trace_fn(label).load() for label in adversarial_label_top5]
                )
                trace = compact_edge(trace, graph, per_channel=per_channel)
                adversarial_trace = compact_edge(
                    adversarial_trace, graph, per_channel=per_channel
                )
                if per_node:
                    rows = []
                    for node_name in class_trace.nodes:
                        row = {
                            "image_id": image_id,
                            "node_name": node_name,
                            "label": class_id,
                            "adversarial_label": adversarial_label,
                            **map_prefix(
                                calc_all_overlap(
                                    class_trace, trace, overlap_fn, node_name
                                ),
                                "original",
                            ),
                            **map_prefix(
                                calc_all_overlap(
                                    adversarial_class_trace,
                                    adversarial_trace,
                                    overlap_fn,
                                    node_name,
                                ),
                                "adversarial",
                            ),
                        }
                        if (
                            row[f"original.{TraceKey.WEIGHT}"] is not None
                            or row[f"original.{TraceKey.EDGE}"] is not None
                        ):
                            rows.append(row)
                    return rows
                else:
                    row = {
                        "image_id": image_id,
                        "label": class_id,
                        "adversarial_label": adversarial_label,
                        "label_top5": label_top5,
                        "adversarial_label_top5": adversarial_label_top5,
                        **map_prefix(
                            calc_all_overlap(class_trace, trace, overlap_fn), "original"
                        ),
                        **map_prefix(
                            calc_all_overlap(
                                adversarial_class_trace, adversarial_trace, overlap_fn
                            ),
                            "adversarial",
                        ),
                    }
                    print(row)
                    return row
            else:
                return [{}] if per_node else {}

        traces = ray_iter(
            get_row,
            (
                (class_id, image_id)
                for image_id in range(0, 1)
                for class_id in range(1, 1001)
            ),
            chunksize=1,
            out_of_order=True,
            num_gpus=0,
        )
        if per_node:
            traces = list(itertools.chain.from_iterable(traces))
        traces = [trace for trace in traces if len(trace) != 0]
        return pd.DataFrame(traces)

    return CsvIOAction(path, init_fn=get_overlap_ratio)


def resnet_50_imagenet_overlap_ratio_error(
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    overlap_fn: Callable[[AttrMap, AttrMap, str], float],
    path: str,
    per_channel: bool = False,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            mode.check(False)
            data_dir = IMAGENET_RAW_DIR
            model_dir = abspath("tf/resnet-50-v2/model")
            create_model = lambda: ResNet50()
            graph = ResNet50.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook, create_model=create_model, graph=graph
            )

            trace = reconstruct_trace_from_tf(
                model_fn=model_fn,
                input_fn=lambda: imagenet_raw.test(data_dir, class_id, image_id),
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
            )[0]

            if class_id == trace.attrs[GraphAttrKey.PREDICT]:
                return {}

            def map_prefix(map: Dict[str, Any], prefix: str) -> Dict[str, Any]:
                return {f"{prefix}.{key}": value for key, value in map.items()}

            class_trace = class_trace_fn(class_id).load()
            trace = compact_edge(trace, graph, per_channel=per_channel)
            row = {
                "image_id": image_id,
                "label": class_id,
                **map_prefix(
                    calc_all_overlap(class_trace, trace, overlap_fn), "original"
                ),
            }
            print(row)
            return row

        traces = ray_iter(
            get_row,
            (
                (class_id, image_id)
                for image_id in range(0, 3)
                for class_id in range(1, 1001)
            ),
            chunksize=1,
            out_of_order=True,
            num_gpus=0,
        )
        traces = [trace for trace in traces if len(trace) != 0]
        return pd.DataFrame(traces)

    return CsvIOAction(path, init_fn=get_overlap_ratio)


def resnet_50_imagenet_overlap_ratio_rand(
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    overlap_fn: Callable[[AttrMap, AttrMap, str], float],
    path: str,
    per_channel: bool = False,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            mode.check(False)
            model_dir = abspath("tf/resnet-50-v2/model")
            create_model = lambda: ResNet50()
            graph = ResNet50.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook, create_model=create_model, graph=graph
            )

            example = np.random.random_sample((1, 224, 224, 3)).astype(np.float32)
            trace = reconstruct_trace_from_tf(
                model_fn=model_fn,
                input_fn=lambda: tf.data.Dataset.from_tensors(
                    imagenet.normalize(example)
                ),
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
            )[0]

            def map_prefix(map: Dict[str, Any], prefix: str) -> Dict[str, Any]:
                return {f"{prefix}.{key}": value for key, value in map.items()}

            class_trace = class_trace_fn(class_id).load()
            trace = compact_edge(trace, graph, per_channel=per_channel)
            row = {
                "image_id": image_id,
                "label": class_id,
                **map_prefix(
                    calc_all_overlap(class_trace, trace, overlap_fn), "original"
                ),
            }
            print(row)
            return row

        traces = ray_iter(
            get_row,
            (
                (class_id, image_id)
                for image_id in range(0, 1)
                for class_id in range(1, 1001)
            ),
            chunksize=1,
            out_of_order=True,
            num_gpus=0,
        )
        traces = [trace for trace in traces if len(trace) != 0]
        return pd.DataFrame(traces)

    return CsvIOAction(path, init_fn=get_overlap_ratio)


def resnet_50_imagenet_overlap_ratio_top5_rand(
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    overlap_fn: Callable[[AttrMap, AttrMap, str], float],
    path: str,
    per_channel: bool = False,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            mode.check(False)
            model_dir = abspath("tf/resnet-50-v2/model")
            create_model = lambda: ResNet50()
            graph = ResNet50.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook, create_model=create_model, graph=graph
            )

            example = np.random.random_sample((1, 224, 224, 3)).astype(np.float32)
            trace = reconstruct_trace_from_tf(
                model_fn=model_fn,
                input_fn=lambda: tf.data.Dataset.from_tensors(
                    imagenet.normalize(example)
                ),
                select_fn=select_fn,
                model_dir=model_dir,
                top_5=True,
                per_channel=per_channel,
            )[0]

            def map_prefix(map: Dict[str, Any], prefix: str) -> Dict[str, Any]:
                return {f"{prefix}.{key}": value for key, value in map.items()}

            class_trace = merge_compact_trace(
                *[
                    class_trace_fn(label).load()
                    for label in trace.attrs[GraphAttrKey.PREDICT_TOP5]
                ]
            )
            trace = compact_edge(trace, graph, per_channel=per_channel)
            row = {
                "image_id": image_id,
                "label": class_id,
                **map_prefix(
                    calc_all_overlap(class_trace, trace, overlap_fn), "original"
                ),
            }
            print(row)
            return row

        traces = ray_iter(
            get_row,
            (
                (class_id, image_id)
                for image_id in range(0, 1)
                for class_id in range(1, 1001)
            ),
            chunksize=1,
            out_of_order=True,
            num_gpus=0,
        )
        traces = [trace for trace in traces if len(trace) != 0]
        return pd.DataFrame(traces)

    return CsvIOAction(path, init_fn=get_overlap_ratio)



def alexnet_imagenet_example(
    attack_name,
    attack_fn,
    generate_adversarial_fn,
    class_id: int,
    image_id: int,
    cache: bool = True,
    **kwargs,
) -> IOAction[np.ndarray]:
    return imagenet_example(
        model_config=ALEXNET.with_model_dir("tf/alexnet/model_import"),
        attack_name=attack_name,
        attack_fn=attack_fn,
        generate_adversarial_fn=generate_adversarial_fn,
        class_id=class_id,
        image_id=image_id,
        cache=cache,
        **kwargs,
    )


# deprecated
def alexnet_imagenet_example_trace_old(
    attack_name: str, class_id: int, image_id: int, threshold: float
) -> IOAction[AttrMap]:
    def get_example() -> AttrMap:
        mode.check(False)
        data_dir = IMAGENET_RAW_DIR
        model_dir = abspath("tf/alexnet/model_import")
        create_model = lambda: AlexNet()
        graph = AlexNet.graph().load()
        model_fn = partial(
            model_fn_with_fetch_hook, create_model=create_model, graph=graph
        )
        input_fn = lambda: imagenet_raw.test(
            data_dir,
            class_id,
            image_id,
            class_from_zero=True,
            preprocessing_fn=alexnet_preprocess_image,
        )
        predicted_label = predict(
            create_model=create_model, input_fn=input_fn, model_dir=model_dir
        )

        if predicted_label != class_id:
            return None

        trace = reconstruct_trace_from_tf(
            class_id=class_id,
            model_fn=model_fn,
            input_fn=input_fn,
            select_fn=lambda input: arg_approx(input, threshold),
            model_dir=model_dir,
        )[0]

        return compact_trace(trace, graph)

    name = "alexnet_imagenet"
    path = f"store/analysis/example_trace/{name}/threshold={threshold:.3f}/{class_id}/{image_id}.pkl"
    return IOAction(path, init_fn=get_example, cache=True, compress=True)


def alexnet_imagenet_example_trace_of_target_class(
    attack_name: str, class_id: int, image_id: int, threshold: float
) -> IOAction[AttrMap]:
    def get_example() -> AttrMap:
        mode.check(False)
        data_dir = IMAGENET_RAW_DIR
        model_dir = abspath("tf/alexnet/model_import")
        create_model = lambda: AlexNet()
        graph = AlexNet.graph().load()
        model_fn = partial(
            model_fn_with_fetch_hook, create_model=create_model, graph=graph
        )
        input_fn = lambda: imagenet_raw.test(
            data_dir,
            class_id,
            image_id,
            class_from_zero=True,
            preprocessing_fn=alexnet_preprocess_image,
        )
        predicted_label = predict(
            create_model=create_model, input_fn=input_fn, model_dir=model_dir
        )

        if predicted_label != class_id:
            return None

        adversarial_example = alexnet_imagenet_example(
            attack_name=attack_name,
            attack_fn=None,
            generate_adversarial_fn=None,
            class_id=class_id,
            image_id=image_id,
        ).load()

        if adversarial_example is None:
            return None

        adversarial_input_fn = lambda: tf.data.Dataset.from_tensors(
            imagenet.normalize_alexnet(adversarial_example)
        )
        adversarial_label = predict(
            create_model=create_model,
            input_fn=adversarial_input_fn,
            model_dir=model_dir,
        )

        trace_of_target_class = reconstruct_trace_from_tf(
            class_id=class_id,
            model_fn=model_fn,
            input_fn=input_fn,
            select_fn=lambda input: arg_approx(input, threshold),
            model_dir=model_dir,
            select_seed_fn=lambda _: np.array([adversarial_label]),
        )[0]

        return compact_trace(trace_of_target_class, graph)

    name = "alexnet_imagenet"
    path = f"store/analysis/example_trace_of_target_class/{name}/attack={attack_name}/threshold={threshold:.3f}/{class_id}/{image_id}.pkl"
    return IOAction(path, init_fn=get_example, cache=True, compress=True)


def alexnet_imagenet_adversarial_example_trace(
    attack_name: str, class_id: int, image_id: int, threshold: float
) -> IOAction[AttrMap]:
    def get_example() -> AttrMap:
        mode.check(False)
        data_dir = IMAGENET_RAW_DIR
        model_dir = abspath("tf/alexnet/model_import")
        create_model = lambda: AlexNet()
        graph = AlexNet.graph().load()
        model_fn = partial(
            model_fn_with_fetch_hook, create_model=create_model, graph=graph
        )
        input_fn = lambda: imagenet_raw.test(
            data_dir,
            class_id,
            image_id,
            class_from_zero=True,
            preprocessing_fn=alexnet_preprocess_image,
        )
        predicted_label = predict(
            create_model=create_model, input_fn=input_fn, model_dir=model_dir
        )

        if predicted_label != class_id:
            return None

        adversarial_example = alexnet_imagenet_example(
            attack_name=attack_name,
            attack_fn=None,
            generate_adversarial_fn=None,
            class_id=class_id,
            image_id=image_id,
        ).load()

        if adversarial_example is None:
            return None

        adversarial_input_fn = lambda: tf.data.Dataset.from_tensors(
            imagenet.normalize_alexnet(adversarial_example)
        )
        adversarial_predicted_label = predict(
            create_model=create_model,
            input_fn=adversarial_input_fn,
            model_dir=model_dir,
        )

        if predicted_label == adversarial_predicted_label:
            return None

        adversarial_trace = reconstruct_trace_from_tf(
            model_fn=model_fn,
            input_fn=adversarial_input_fn,
            select_fn=lambda input: arg_approx(input, threshold),
            model_dir=model_dir,
        )[0]

        return compact_trace(adversarial_trace, graph)

    name = "alexnet_imagenet"
    path = f"store/analysis/adversarial_example_trace/{name}/attack={attack_name}/threshold={threshold:.3f}/{class_id}/{image_id}.pkl"
    return IOAction(path, init_fn=get_example, cache=True, compress=True)


def alexnet_imagenet_adversarial_example_trace_of_original_class(
    attack_name: str, class_id: int, image_id: int, threshold: float
) -> IOAction[AttrMap]:
    def get_example() -> AttrMap:
        mode.check(False)
        data_dir = IMAGENET_RAW_DIR
        model_dir = abspath("tf/alexnet/model_import")
        create_model = lambda: AlexNet()
        graph = AlexNet.graph().load()
        model_fn = partial(
            model_fn_with_fetch_hook, create_model=create_model, graph=graph
        )
        input_fn = lambda: imagenet_raw.test(
            data_dir,
            class_id,
            image_id,
            class_from_zero=True,
            preprocessing_fn=alexnet_preprocess_image,
        )
        predicted_label = predict(
            create_model=create_model, input_fn=input_fn, model_dir=model_dir
        )

        if predicted_label != class_id:
            return None

        adversarial_example = alexnet_imagenet_example(
            attack_name=attack_name,
            attack_fn=None,
            generate_adversarial_fn=None,
            class_id=class_id,
            image_id=image_id,
        ).load()

        if adversarial_example is None:
            return None

        adversarial_input_fn = lambda: tf.data.Dataset.from_tensors(
            imagenet.normalize_alexnet(adversarial_example)
        )
        adversarial_predicted_label = predict(
            create_model=create_model,
            input_fn=adversarial_input_fn,
            model_dir=model_dir,
        )

        if predicted_label == adversarial_predicted_label:
            return None

        adversarial_trace_of_original_class = reconstruct_trace_from_tf(
            model_fn=model_fn,
            input_fn=adversarial_input_fn,
            select_fn=lambda input: arg_approx(input, threshold),
            model_dir=model_dir,
            select_seed_fn=lambda _: np.array([class_id]),
        )[0]

        return compact_trace(adversarial_trace_of_original_class, graph)

    name = "alexnet_imagenet"
    path = f"store/analysis/adversarial_example_trace_of_original_class/{name}/attack={attack_name}/threshold={threshold:.3f}/{class_id}/{image_id}.pkl"
    return IOAction(path, init_fn=get_example, cache=True, compress=True)


def generate_traces(
    trace_fn: Callable[..., IOAction[AttrMap]],
    attack_name: str,
    class_ids: Iterable[int],
    image_ids: Iterable[int],
    **kwargs,
):
    def generate_traces_fn(
        class_id: int, image_id: int
    ) -> Union[Tuple[int, int], Tuple[int, int, str]]:
        try:
            class_id = int(class_id)
            image_id = int(image_id)
            trace_fn(
                attack_name=attack_name, class_id=class_id, image_id=image_id, **kwargs
            ).save()
            return class_id, image_id
        except Exception:
            return class_id, image_id, traceback.format_exc()

    results = ray_iter(
        generate_traces_fn,
        [(class_id, image_id) for image_id in image_ids for class_id in class_ids],
        chunksize=1,
        out_of_order=True,
        num_gpus=0,
        huge_task=True,
    )
    for result in results:
        if len(result) == 3:
            class_id, image_id, tb = result
            print(f"## raise exception from class {class_id}, image {image_id}:")
            print(tb)
        else:
            class_id, image_id = result
            print(f"finish class {class_id} image {image_id}")


def resnet_50_imagenet_example(
    attack_name,
    attack_fn,
    generate_adversarial_fn,
    class_id: int,
    image_id: int,
    cache: bool = True,
    **kwargs,
) -> IOAction[np.ndarray]:
    return imagenet_example(
        model_config=RESNET_50,
        attack_name=attack_name,
        attack_fn=attack_fn,
        generate_adversarial_fn=generate_adversarial_fn,
        class_id=class_id,
        image_id=image_id,
        cache=cache,
        **kwargs,
    )


def vgg_16_imagenet_example(
    attack_name,
    attack_fn,
    generate_adversarial_fn,
    class_id: int,
    image_id: int,
    cache: bool = True,
    **kwargs,
) -> IOAction[np.ndarray]:
    return imagenet_example(
        model_config=VGG_16,
        attack_name=attack_name,
        attack_fn=attack_fn,
        generate_adversarial_fn=generate_adversarial_fn,
        class_id=class_id,
        image_id=image_id,
        cache=cache,
        **kwargs,
    )


def imagenet_example(
    model_config: ModelConfig,
    attack_name,
    attack_fn,
    generate_adversarial_fn,
    class_id: int,
    image_id: int,
    cache: bool = True,
    **kwargs,
) -> IOAction[np.ndarray]:
    def get_example() -> np.ndarray:
        data_dir = IMAGENET_RAW_DIR
        model_dir = abspath(model_config.model_dir)
        create_model = lambda: model_config.network_class()
        adversarial_example = generate_adversarial_fn(
            label=class_id,
            create_model=create_model,
            input_fn=lambda: imagenet_raw.test(
                data_dir,
                class_id,
                image_id,
                normed=False,
                class_from_zero=model_config.class_from_zero,
                preprocessing_fn=model_config.preprocessing_fn,
            )
            .make_one_shot_iterator()
            .get_next()[0],
            attack_fn=attack_fn,
            model_dir=model_dir,
            **kwargs,
        )
        return adversarial_example

    name = f"{model_config.name}_imagenet"
    path = f"store/example/{attack_name}/{name}/{class_id}/{image_id}.pkl"
    return IOAction(path, init_fn=get_example, cache=cache, compress=True)


def alexnet_imagenet_example_stat(
    attack_name,
    attack_fn,
    generate_adversarial_fn,
    class_id: int,
    image_id: int,
    stat_name: str = None,
    cache: bool = True,
    **kwargs,
) -> IOAction[Dict[str, np.ndarray]]:
    return imagenet_example_stat(
        model_config=ALEXNET.with_model_dir("tf/alexnet/model_import"),
        attack_name=attack_name,
        attack_fn=attack_fn,
        generate_adversarial_fn=generate_adversarial_fn,
        class_id=class_id,
        image_id=image_id,
        stat_name=stat_name,
        cache=cache,
        **kwargs,
    )


def resnet_50_imagenet_example_stat(
    attack_name,
    attack_fn,
    generate_adversarial_fn,
    class_id: int,
    image_id: int,
    stat_name: str = None,
    cache: bool = True,
    **kwargs,
) -> IOAction[Dict[str, np.ndarray]]:
    return imagenet_example_stat(
        model_config=RESNET_50,
        attack_name=attack_name,
        attack_fn=attack_fn,
        generate_adversarial_fn=generate_adversarial_fn,
        class_id=class_id,
        image_id=image_id,
        stat_name=stat_name,
        cache=cache,
        **kwargs,
    )


def imagenet_example_trace(
    model_config: ModelConfig,
    attack_name,
    attack_fn,
    generate_adversarial_fn,
    trace_fn,
    class_id: int,
    image_id: int,
    threshold: float,
    per_channel: bool = False,
    cache: bool = True,
    train: bool = False,
    **kwargs,
) -> IOAction[AttrMap]:
    def get_example_trace() -> AttrMap:
        mode.check(False)
        data_dir = IMAGENET_RAW_DIR
        model_dir = abspath(model_config.model_dir)
        create_model = lambda: model_config.network_class()
        graph = model_config.network_class.graph().load()
        model_fn = partial(
            model_fn_with_fetch_hook, create_model=create_model, graph=graph
        )
        input_fn = lambda: (imagenet_raw.train if train else imagenet_raw.test)(
            data_dir,
            class_id,
            image_id,
            class_from_zero=model_config.class_from_zero,
            preprocessing_fn=model_config.preprocessing_fn,
        )
        predicted_label = predict(
            create_model=create_model, input_fn=input_fn, model_dir=model_dir
        )

        if predicted_label != class_id:
            return None

        if attack_name == "original":
            trace = reconstruct_trace_from_tf_v2(
                class_id=class_id,
                model_fn=model_fn,
                input_fn=input_fn,
                trace_fn=partial(
                    trace_fn, select_fn=lambda input: arg_approx(input, threshold)
                ),
                model_dir=model_dir,
            )[0]
            trace = compact_trace(trace, graph, per_channel=per_channel)
            return trace

        adversarial_example = imagenet_example(
            model_config=model_config,
            attack_name=attack_name,
            attack_fn=attack_fn,
            generate_adversarial_fn=generate_adversarial_fn,
            class_id=class_id,
            image_id=image_id,
        ).load()

        if adversarial_example is None:
            return None

        adversarial_input_fn = lambda: tf.data.Dataset.from_tensors(
            model_config.normalize_fn(adversarial_example)
        )
        adversarial_predicted_label = predict(
            create_model=create_model,
            input_fn=adversarial_input_fn,
            model_dir=model_dir,
        )

        if predicted_label == adversarial_predicted_label:
            return None

        adversarial_trace = reconstruct_trace_from_tf_v2(
            model_fn=model_fn,
            input_fn=adversarial_input_fn,
            trace_fn=partial(
                trace_fn, select_fn=lambda input: arg_approx(input, threshold)
            ),
            model_dir=model_dir,
        )[0]
        adversarial_trace = compact_trace(
            adversarial_trace, graph, per_channel=per_channel
        )
        return adversarial_trace

    name = f"{model_config.name}_imagenet"
    if train:
        name = f"{name}_train"
    if per_channel:
        trace_name = "example_channel_trace"
    else:
        trace_name = "example_trace"
    path = f"store/{trace_name}/approx_{threshold:.3f}/{attack_name}/{name}/{class_id}/{image_id}.pkl"
    return IOAction(path, init_fn=get_example_trace, cache=cache, compress=True)


# alexnet_imagenet_example_trace = partial(
#     imagenet_example_trace,
#     model_config=ALEXNET.with_model_dir("tf/alexnet/model_import"),
# )
#
# resnet_50_imagenet_example_trace = partial(
#     imagenet_example_trace, model_config=RESNET_50
# )
#
# vgg_16_imagenet_example_trace = partial(imagenet_example_trace, model_config=VGG_16)


def imagenet_example_stat(
    model_config: ModelConfig,
    attack_name,
    attack_fn,
    generate_adversarial_fn,
    class_id: int,
    image_id: int,
    stat_name: str = "avg",
    cache: bool = True,
    **kwargs,
) -> IOAction[Dict[str, np.ndarray]]:
    def get_example_trace() -> Dict[str, np.ndarray]:
        mode.check(False)
        data_dir = IMAGENET_RAW_DIR
        model_dir = abspath(model_config.model_dir)
        create_model = lambda: model_config.network_class()
        graph = model_config.network_class.graph().load()
        model_fn = partial(
            model_fn_with_fetch_hook, create_model=create_model, graph=graph
        )
        # input_fn = lambda: imagenet_raw.test(data_dir, class_id, image_id,
        input_fn = lambda: imagenet_raw.train(
            data_dir,
            class_id,
            image_id,
            class_from_zero=model_config.class_from_zero,
            preprocessing_fn=model_config.preprocessing_fn,
        )
        predicted_label = predict(
            create_model=create_model, input_fn=input_fn, model_dir=model_dir
        )

        # if predicted_label != class_id:
        #     return None

        if attack_name == "original":
            trace = reconstruct_stat_from_tf(
                class_id=class_id,
                model_fn=model_fn,
                input_fn=input_fn,
                model_dir=model_dir,
                stat_name=stat_name,
            )[0]
            return trace

        adversarial_example = imagenet_example(
            model_config=model_config,
            attack_name=attack_name,
            attack_fn=attack_fn,
            generate_adversarial_fn=generate_adversarial_fn,
            class_id=class_id,
            image_id=image_id,
        ).load()

        if adversarial_example is None:
            return None

        adversarial_input_fn = lambda: tf.data.Dataset.from_tensors(
            model_config.normalize_fn(adversarial_example)
        )
        adversarial_predicted_label = predict(
            create_model=create_model,
            input_fn=adversarial_input_fn,
            model_dir=model_dir,
        )

        if predicted_label == adversarial_predicted_label:
            return None

        adversarial_trace = reconstruct_stat_from_tf(
            model_fn=model_fn,
            input_fn=adversarial_input_fn,
            model_dir=model_dir,
            stat_name=stat_name,
        )[0]
        return adversarial_trace

    name = f"{model_config.name}_imagenet"
    trace_name = "example_stat"
    path = (
        f"store/{trace_name}/{stat_name}/{attack_name}/{name}/{class_id}/{image_id}.pkl"
    )
    return IOAction(path, init_fn=get_example_trace, cache=cache, compress=True)


def generate_example_traces(
    example_trace_fn: Callable[..., IOAction[AttrMap]],
    class_ids: Iterable[int],
    image_ids: Iterable[int],
    attack_name: str,
    attack_fn,
    generate_adversarial_fn,
    threshold: float,
    per_channel: bool = False,
    cache: bool = True,
    select_seed_fn: Callable[[np.ndarray], np.ndarray] = None,
    entry_points: List[int] = None,
    train: bool = False,
    **kwargs,
):
    def generate_examples_fn(
        class_id: int, image_id: int
    ) -> Union[Tuple[int, int], Tuple[int, int, str]]:
        try:
            class_id = int(class_id)
            image_id = int(image_id)
            example_trace_io = example_trace_fn(
                attack_name=attack_name,
                attack_fn=attack_fn,
                generate_adversarial_fn=generate_adversarial_fn,
                class_id=class_id,
                image_id=image_id,
                threshold=threshold,
                per_channel=per_channel,
                cache=cache,
                select_seed_fn=select_seed_fn,
                entry_points=entry_points,
                train=train,
                **kwargs,
            )
            example_trace_io.save()
            return class_id, image_id
        except Exception as e:
            raise e
            # return class_id, image_id, traceback.format_exc()

    print(f"begin {attack_name}")
    results = ray_iter(
        generate_examples_fn,
        [(class_id, image_id) for image_id in image_ids for class_id in class_ids],
        chunksize=1,
        out_of_order=True,
        num_gpus=0,
        huge_task=True,
    )
    for result in results:
        if len(result) == 3:
            class_id, image_id, tb = result
            print(f"## raise exception from class {class_id}, image {image_id}:")
            print(tb)
        else:
            class_id, image_id = result
            # print(f"finish class {class_id} image {image_id}")
    print(f"finish {attack_name}")


def generate_example_stats(
    example_trace_fn: Callable[..., IOAction[Dict[str, np.ndarray]]],
    class_ids: Iterable[int],
    image_ids: Iterable[int],
    attack_name: str,
    attack_fn,
    generate_adversarial_fn,
    stat_name: str = None,
    cache: bool = True,
    **kwargs,
):
    def generate_examples_fn(
        class_id: int, image_id: int
    ) -> Union[Tuple[int, int], Tuple[int, int, str]]:
        try:
            class_id = int(class_id)
            image_id = int(image_id)
            example_trace_io = example_trace_fn(
                attack_name=attack_name,
                attack_fn=attack_fn,
                generate_adversarial_fn=generate_adversarial_fn,
                class_id=class_id,
                image_id=image_id,
                stat_name=stat_name,
                cache=cache,
                **kwargs,
            )
            example_trace_io.save()
            return class_id, image_id
        except Exception as e:
            raise e
            # return class_id, image_id, traceback.format_exc()

    print(f"begin {attack_name}")
    results = ray_iter(
        generate_examples_fn,
        [(class_id, image_id) for image_id in image_ids for class_id in class_ids],
        chunksize=1,
        out_of_order=True,
        num_gpus=0,
        huge_task=True,
    )
    for result in results:
        if len(result) == 3:
            class_id, image_id, tb = result
            print(f"## raise exception from class {class_id}, image {image_id}:")
            print(tb)
        else:
            class_id, image_id = result
            # print(f"finish class {class_id} image {image_id}")
    print(f"finish {attack_name}")


def alexnet_imagenet_overlap_ratio(
    attack_fn,
    generate_adversarial_fn,
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    overlap_fn: Callable[[AttrMap, AttrMap, str], float],
    path: str,
    per_node: bool = False,
    per_channel: bool = False,
    **kwargs,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            mode.check(False)
            data_dir = IMAGENET_RAW_DIR
            model_dir = abspath("tf/alexnet/model_import")
            create_model = lambda: AlexNet()
            graph = AlexNet.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook, create_model=create_model, graph=graph
            )

            trace = reconstruct_class_trace_from_tf(
                class_id,
                model_fn=model_fn,
                input_fn=lambda: imagenet_raw.test(
                    data_dir,
                    class_id,
                    image_id,
                    class_from_zero=True,
                    preprocessing_fn=alexnet_preprocess_image,
                ),
                model_dir=model_dir,
                select_fn=select_fn,
                per_channel=per_channel,
            )

            if trace is None:
                return {}

            adversarial_example = generate_adversarial_fn(
                label=class_id,
                create_model=create_model,
                input_fn=lambda: imagenet_raw.test(
                    data_dir,
                    class_id,
                    image_id,
                    normed=False,
                    class_from_zero=True,
                    preprocessing_fn=alexnet_preprocess_image,
                )
                .make_one_shot_iterator()
                .get_next()[0],
                attack_fn=attack_fn,
                model_dir=model_dir,
                **kwargs,
            )

            if adversarial_example is None:
                return {}

            adversarial_trace = reconstruct_trace_from_tf(
                model_fn=model_fn,
                input_fn=lambda: tf.data.Dataset.from_tensors(
                    imagenet.normalize_alexnet(adversarial_example)
                ),
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
            )[0]

            adversarial_label = adversarial_trace.attrs[GraphAttrKey.PREDICT]

            if class_id != adversarial_label:

                def map_prefix(map: Dict[str, Any], prefix: str) -> Dict[str, Any]:
                    return {f"{prefix}.{key}": value for key, value in map.items()}

                class_trace = class_trace_fn(class_id).load()
                adversarial_class_trace = class_trace_fn(adversarial_label).load()
                trace = compact_edge(trace, graph, per_channel=per_channel)
                adversarial_trace = compact_edge(
                    adversarial_trace, graph, per_channel=per_channel
                )
                if per_node:
                    rows = []
                    for node_name in class_trace.nodes:
                        row = {
                            "image_id": image_id,
                            "node_name": node_name,
                            "label": class_id,
                            "adversarial_label": adversarial_label,
                            **map_prefix(
                                calc_all_overlap(
                                    class_trace, trace, overlap_fn, node_name
                                ),
                                "original",
                            ),
                            **map_prefix(
                                calc_all_overlap(
                                    adversarial_class_trace,
                                    adversarial_trace,
                                    overlap_fn,
                                    node_name,
                                ),
                                "adversarial",
                            ),
                        }
                        if (
                            (
                                f"original.{TraceKey.WEIGHT}" in row
                                and row[f"original.{TraceKey.WEIGHT}"] is not None
                            )
                            or (
                                f"original.{TraceKey.EDGE}" in row
                                and row[f"original.{TraceKey.EDGE}"]
                            )
                            is not None
                        ):
                            rows.append(row)
                    return rows
                else:
                    row = {
                        "image_id": image_id,
                        "label": class_id,
                        "adversarial_label": adversarial_label,
                        **map_prefix(
                            calc_all_overlap(class_trace, trace, overlap_fn), "original"
                        ),
                        **map_prefix(
                            calc_all_overlap(
                                adversarial_class_trace, adversarial_trace, overlap_fn
                            ),
                            "adversarial",
                        ),
                    }
                    print(row)
                    return row
            else:
                return [{}] if per_node else {}

        traces = ray_iter(
            get_row,
            (
                (class_id, image_id)
                for image_id in range(0, 1)
                for class_id in range(0, 1000)
            ),
            chunksize=1,
            out_of_order=True,
            num_gpus=0,
        )
        if per_node:
            traces = list(itertools.chain.from_iterable(traces))
        traces = [trace for trace in traces if len(trace) != 0]
        return pd.DataFrame(traces)

    return CsvIOAction(path, init_fn=get_overlap_ratio)


def get_predicted_value_contribution(
    trace: AttrMap, graph: Graph, class_id: int, create_model, input_fn, model_dir
) -> float:
    # print(calc_density_compact(trace, TraceKey.EDGE))
    return get_predicted_value(
        class_id=class_id,
        create_model=create_model,
        input_fn=input_fn,
        model_dir=model_dir,
        prediction_hooks=[MaskWeightWithTraceHook(graph, trace)],
    )


def alexnet_imagenet_overlap_ratio_top5_diff(
    attack_name: str,
    attack_fn,
    generate_adversarial_fn,
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    overlap_fn: Callable[[AttrMap, AttrMap, str], float],
    path: str,
    per_node: bool = False,
    per_channel: bool = False,
    topk_share_range: int = 5,
    topk_calc_range: int = 5,
    **kwargs,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            mode.check(False)
            data_dir = IMAGENET_RAW_DIR
            model_dir = abspath("tf/alexnet/model_import")
            create_model = lambda: AlexNet()
            graph = AlexNet.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook, create_model=create_model, graph=graph
            )
            input_fn = lambda: imagenet_raw.test(
                data_dir,
                class_id,
                image_id,
                class_from_zero=True,
                preprocessing_fn=alexnet_preprocess_image,
            )
            predicted_label = predict(
                create_model=create_model, input_fn=input_fn, model_dir=model_dir
            )

            if predicted_label != class_id:
                return [{}] if per_node else {}

            # adversarial_example = generate_adversarial_fn(
            #     label=class_id,
            #     create_model=create_model,
            #     input_fn=lambda: imagenet_raw.test(data_dir, class_id, image_id, normed=False,
            #                                        class_from_zero=True, preprocessing_fn=alexnet_preprocess_image)
            #         .make_one_shot_iterator().get_next()[0],
            #     attack_fn=attack_fn,
            #     model_dir=model_dir,
            #     **kwargs,
            # )

            adversarial_example = alexnet_imagenet_example(
                attack_name=attack_name,
                attack_fn=attack_fn,
                generate_adversarial_fn=generate_adversarial_fn,
                class_id=class_id,
                image_id=image_id,
            ).load()

            if adversarial_example is None:
                return [{}] if per_node else {}

            with tf.Session() as sess:
                original_example = sess.run(
                    imagenet_raw.test(
                        data_dir,
                        class_id,
                        image_id,
                        class_from_zero=True,
                        preprocessing_fn=alexnet_preprocess_image,
                        normed=False,
                    )
                    .make_one_shot_iterator()
                    .get_next()[0]
                )

            adversarial_input_fn = lambda: tf.data.Dataset.from_tensors(
                imagenet.normalize_alexnet(adversarial_example)
            )
            adversarial_predicted_label = predict(
                create_model=create_model,
                input_fn=adversarial_input_fn,
                model_dir=model_dir,
            )

            if predicted_label == adversarial_predicted_label:
                return [{}] if per_node else {}

            trace = reconstruct_trace_from_tf(
                class_id=class_id,
                model_fn=model_fn,
                input_fn=input_fn,
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
                topk=topk_share_range,
            )[0]

            assert trace is not None

            label_top5 = trace.attrs[GraphAttrKey.PREDICT_TOP5]
            label_top5_value = trace.attrs[GraphAttrKey.PREDICT_TOP5_VALUE]

            adversarial_trace = reconstruct_trace_from_tf(
                model_fn=model_fn,
                input_fn=adversarial_input_fn,
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
                topk=topk_share_range,
            )[0]

            adversarial_label = adversarial_trace.attrs[GraphAttrKey.PREDICT]
            adversarial_label_top5 = adversarial_trace.attrs[GraphAttrKey.PREDICT_TOP5]
            adversarial_label_top5_value = adversarial_trace.attrs[
                GraphAttrKey.PREDICT_TOP5_VALUE
            ]

            assert class_id != adversarial_label

            def map_prefix(map: Dict[str, Any], prefix: str) -> Dict[str, Any]:
                return {f"{prefix}.{key}": value for key, value in map.items()}

            assert (
                class_id == label_top5[0]
                and adversarial_label == adversarial_label_top5[0]
            )
            trace = compact_trace(trace, graph, per_channel=per_channel)
            adversarial_trace = compact_trace(
                adversarial_trace, graph, per_channel=per_channel
            )

            class_traces = {}

            def get_class_trace(class_id: int) -> AttrMap:
                if class_id not in class_traces:
                    class_traces[class_id] = class_trace_fn(class_id).load()
                return class_traces[class_id]
                # return class_trace_fn(class_id).load()

            def get_overlap(
                base_class_id: int, class_ids: List[int], trace: AttrMap, input_fn
            ):
                rest_class_ids = class_ids.copy()
                rest_class_ids.remove(base_class_id)
                rest_class_trace = merge_compact_trace(
                    *[get_class_trace(class_id) for class_id in rest_class_ids]
                )
                class_trace = get_class_trace(base_class_id)
                class_specific_trace = merge_compact_trace_diff(
                    class_trace, rest_class_trace
                )
                example_specific_trace = merge_compact_trace_diff(
                    trace, rest_class_trace
                )

                example_trace_in_class_in_rest = merge_compact_trace_intersect(
                    class_trace, trace, rest_class_trace
                )
                example_trace_in_class_not_in_rest = merge_compact_trace_intersect(
                    class_specific_trace, example_specific_trace
                )
                example_trace_not_in_class_in_rest = merge_compact_trace_diff(
                    merge_compact_trace_intersect(trace, rest_class_trace), class_trace
                )
                example_trace_not_in_class_not_in_rest = merge_compact_trace_diff(
                    example_specific_trace, class_specific_trace
                )
                example_trace_share = merge_compact_trace_diff(
                    trace, example_trace_not_in_class_not_in_rest
                )
                example_trace_specific = merge_compact_trace_diff(
                    trace, example_trace_not_in_class_in_rest
                )
                predicted_value_contributions = {
                    key: get_predicted_value_contribution(
                        current_trace,
                        graph=graph,
                        class_id=base_class_id,
                        create_model=create_model,
                        input_fn=input_fn,
                        model_dir=model_dir,
                    )
                    for key, current_trace in [
                        ("pvc_total", trace),
                        ("pvc_share", example_trace_share),
                        ("pvc_specific", example_trace_specific),
                        ("pvc_in_class_in_rest", example_trace_in_class_in_rest),
                        (
                            "pvc_in_class_not_in_rest",
                            example_trace_in_class_not_in_rest,
                        ),
                        # ("pvc_not_in_class_in_rest", example_trace_not_in_class_in_rest),
                        # ("pvc_not_in_class_not_in_rest", example_trace_not_in_class_not_in_rest),
                    ]
                }
                overlap_sizes = {
                    key: calc_trace_size(current_trace, compact=True)
                    for key, current_trace in [
                        ("overlap_size_total", trace),
                        (
                            "overlap_size_in_class_in_rest",
                            example_trace_in_class_in_rest,
                        ),
                        (
                            "overlap_size_in_class_not_in_rest",
                            example_trace_in_class_not_in_rest,
                        ),
                        (
                            "overlap_size_not_in_class_in_rest",
                            example_trace_not_in_class_in_rest,
                        ),
                        (
                            "overlap_size_not_in_class_not_in_rest",
                            example_trace_not_in_class_not_in_rest,
                        ),
                    ]
                }
                return {
                    **calc_all_overlap(
                        class_specific_trace,
                        example_specific_trace,
                        overlap_fn,
                        compact=True,
                        use_intersect_size=True,
                    ),
                    **predicted_value_contributions,
                    **overlap_sizes,
                }

            row = {}
            for k, base_class_id in zip(range(1, topk_calc_range + 1), label_top5):
                row = {
                    **row,
                    **map_prefix(
                        get_overlap(base_class_id, label_top5, trace, input_fn),
                        f"original.top{k}",
                    ),
                }
            for k, base_class_id in zip(
                range(1, topk_calc_range + 1), adversarial_label_top5
            ):
                row = {
                    **row,
                    **map_prefix(
                        get_overlap(
                            base_class_id,
                            adversarial_label_top5,
                            adversarial_trace,
                            adversarial_input_fn,
                        ),
                        f"adversarial.top{k}",
                    ),
                }

            if per_node:
                raise RuntimeError()
            else:
                row = {
                    "image_id": image_id,
                    "label": class_id,
                    "adversarial_label": adversarial_label,
                    "label_top5": label_top5,
                    "adversarial_label_top5": adversarial_label_top5,
                    "label_top5_value": label_top5_value,
                    "adversarial_label_top5_value": adversarial_label_top5_value,
                    "label_value": label_top5_value[0],
                    "adversarial_label_value": adversarial_label_top5_value[0],
                    "perturbation": np.linalg.norm(
                        adversarial_example - original_example
                    )
                    / original_example.size,
                    **row,
                }
                print(row)
                return row

        traces = ray_iter(
            get_row,
            (
                (class_id, image_id)
                for image_id in range(0, 1)
                for class_id in range(0, 1000)
            ),
            chunksize=1,
            out_of_order=True,
            num_gpus=0,
        )
        if per_node:
            traces = list(itertools.chain.from_iterable(traces))
        traces = [trace for trace in traces if len(trace) != 0]
        return pd.DataFrame(traces)

    return CsvIOAction(path, init_fn=get_overlap_ratio)


def alexnet_imagenet_overlap_ratio_top5_diff_uint8(
    attack_name: str,
    attack_fn,
    generate_adversarial_fn,
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    overlap_fn: Callable[[AttrMap, AttrMap, str], float],
    path: str,
    per_node: bool = False,
    per_channel: bool = False,
    topk_share_range: int = 5,
    topk_calc_range: int = 5,
    **kwargs,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            mode.check(False)
            data_dir = IMAGENET_RAW_DIR
            model_dir = abspath("tf/alexnet/model_import")
            create_model = lambda: AlexNet()
            graph = AlexNet.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook, create_model=create_model, graph=graph
            )
            input_fn = lambda: imagenet_raw.test(
                data_dir,
                class_id,
                image_id,
                class_from_zero=True,
                preprocessing_fn=alexnet_preprocess_image,
            )
            predicted_label = predict(
                create_model=create_model, input_fn=input_fn, model_dir=model_dir
            )

            if predicted_label != class_id:
                return [{}] if per_node else {}

            # adversarial_example = generate_adversarial_fn(
            #     label=class_id,
            #     create_model=create_model,
            #     input_fn=lambda: imagenet_raw.test(data_dir, class_id, image_id, normed=False,
            #                                        class_from_zero=True, preprocessing_fn=alexnet_preprocess_image)
            #         .make_one_shot_iterator().get_next()[0],
            #     attack_fn=attack_fn,
            #     model_dir=model_dir,
            #     **kwargs,
            # )

            adversarial_example = adversarial_example_image(
                alexnet_imagenet_example(
                    attack_name=attack_name,
                    attack_fn=attack_fn,
                    generate_adversarial_fn=generate_adversarial_fn,
                    class_id=class_id,
                    image_id=image_id,
                )
            ).load()

            if adversarial_example is None:
                return [{}] if per_node else {}

            adversarial_example = (
                np.expand_dims(adversarial_example, axis=0).astype(np.float32) / 255
            )

            with tf.Session() as sess:
                original_example = sess.run(
                    imagenet_raw.test(
                        data_dir,
                        class_id,
                        image_id,
                        class_from_zero=True,
                        preprocessing_fn=alexnet_preprocess_image,
                        normed=False,
                    )
                    .make_one_shot_iterator()
                    .get_next()[0]
                )

            adversarial_input_fn = lambda: tf.data.Dataset.from_tensors(
                imagenet.normalize_alexnet(adversarial_example)
            )
            adversarial_predicted_label = predict(
                create_model=create_model,
                input_fn=adversarial_input_fn,
                model_dir=model_dir,
            )

            if predicted_label == adversarial_predicted_label:
                return [{}] if per_node else {}

            trace = reconstruct_trace_from_tf(
                class_id=class_id,
                model_fn=model_fn,
                input_fn=input_fn,
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
                topk=topk_share_range,
            )[0]

            assert trace is not None

            label_top5 = trace.attrs[GraphAttrKey.PREDICT_TOP5]
            label_top5_value = trace.attrs[GraphAttrKey.PREDICT_TOP5_VALUE]

            adversarial_trace = reconstruct_trace_from_tf(
                model_fn=model_fn,
                input_fn=adversarial_input_fn,
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
                topk=topk_share_range,
            )[0]

            adversarial_label = adversarial_trace.attrs[GraphAttrKey.PREDICT]
            adversarial_label_top5 = adversarial_trace.attrs[GraphAttrKey.PREDICT_TOP5]
            adversarial_label_top5_value = adversarial_trace.attrs[
                GraphAttrKey.PREDICT_TOP5_VALUE
            ]

            assert class_id != adversarial_label

            def map_prefix(map: Dict[str, Any], prefix: str) -> Dict[str, Any]:
                return {f"{prefix}.{key}": value for key, value in map.items()}

            assert (
                class_id == label_top5[0]
                and adversarial_label == adversarial_label_top5[0]
            )
            trace = compact_trace(trace, graph, per_channel=per_channel)
            adversarial_trace = compact_trace(
                adversarial_trace, graph, per_channel=per_channel
            )

            class_traces = {}

            def get_class_trace(class_id: int) -> AttrMap:
                if class_id not in class_traces:
                    class_traces[class_id] = class_trace_fn(class_id).load()
                return class_traces[class_id]
                # return class_trace_fn(class_id).load()

            def get_overlap(
                base_class_id: int, class_ids: List[int], trace: AttrMap, input_fn
            ):
                rest_class_ids = class_ids.copy()
                rest_class_ids.remove(base_class_id)
                rest_class_trace = merge_compact_trace(
                    *[get_class_trace(class_id) for class_id in rest_class_ids]
                )
                class_trace = get_class_trace(base_class_id)
                class_specific_trace = merge_compact_trace_diff(
                    class_trace, rest_class_trace
                )
                example_specific_trace = merge_compact_trace_diff(
                    trace, rest_class_trace
                )

                example_trace_in_class_in_rest = merge_compact_trace_intersect(
                    class_trace, trace, rest_class_trace
                )
                example_trace_in_class_not_in_rest = merge_compact_trace_intersect(
                    class_specific_trace, example_specific_trace
                )
                example_trace_not_in_class_in_rest = merge_compact_trace_diff(
                    merge_compact_trace_intersect(trace, rest_class_trace), class_trace
                )
                example_trace_not_in_class_not_in_rest = merge_compact_trace_diff(
                    example_specific_trace, class_specific_trace
                )
                example_trace_share = merge_compact_trace_diff(
                    trace, example_trace_not_in_class_not_in_rest
                )
                example_trace_specific = merge_compact_trace_diff(
                    trace, example_trace_not_in_class_in_rest
                )
                predicted_value_contributions = {
                    key: get_predicted_value_contribution(
                        current_trace,
                        graph=graph,
                        class_id=base_class_id,
                        create_model=create_model,
                        input_fn=input_fn,
                        model_dir=model_dir,
                    )
                    for key, current_trace in [
                        ("pvc_total", trace),
                        ("pvc_share", example_trace_share),
                        ("pvc_specific", example_trace_specific),
                        ("pvc_in_class_in_rest", example_trace_in_class_in_rest),
                        (
                            "pvc_in_class_not_in_rest",
                            example_trace_in_class_not_in_rest,
                        ),
                        # ("pvc_not_in_class_in_rest", example_trace_not_in_class_in_rest),
                        # ("pvc_not_in_class_not_in_rest", example_trace_not_in_class_not_in_rest),
                    ]
                }
                overlap_sizes = {
                    key: calc_trace_size(current_trace, compact=True)
                    for key, current_trace in [
                        ("overlap_size_total", trace),
                        (
                            "overlap_size_in_class_in_rest",
                            example_trace_in_class_in_rest,
                        ),
                        (
                            "overlap_size_in_class_not_in_rest",
                            example_trace_in_class_not_in_rest,
                        ),
                        (
                            "overlap_size_not_in_class_in_rest",
                            example_trace_not_in_class_in_rest,
                        ),
                        (
                            "overlap_size_not_in_class_not_in_rest",
                            example_trace_not_in_class_not_in_rest,
                        ),
                    ]
                }
                return {
                    **calc_all_overlap(
                        class_specific_trace,
                        example_specific_trace,
                        overlap_fn,
                        compact=True,
                        use_intersect_size=True,
                    ),
                    **predicted_value_contributions,
                    **overlap_sizes,
                }

            row = {}
            for k, base_class_id in zip(range(1, topk_calc_range + 1), label_top5):
                row = {
                    **row,
                    **map_prefix(
                        get_overlap(base_class_id, label_top5, trace, input_fn),
                        f"original.top{k}",
                    ),
                }
            for k, base_class_id in zip(
                range(1, topk_calc_range + 1), adversarial_label_top5
            ):
                row = {
                    **row,
                    **map_prefix(
                        get_overlap(
                            base_class_id,
                            adversarial_label_top5,
                            adversarial_trace,
                            adversarial_input_fn,
                        ),
                        f"adversarial.top{k}",
                    ),
                }

            if per_node:
                raise RuntimeError()
            else:
                row = {
                    "image_id": image_id,
                    "label": class_id,
                    "adversarial_label": adversarial_label,
                    "label_top5": label_top5,
                    "adversarial_label_top5": adversarial_label_top5,
                    "label_top5_value": label_top5_value,
                    "adversarial_label_top5_value": adversarial_label_top5_value,
                    "label_value": label_top5_value[0],
                    "adversarial_label_value": adversarial_label_top5_value[0],
                    "perturbation": np.linalg.norm(
                        adversarial_example - original_example
                    )
                    / original_example.size,
                    **row,
                }
                print(row)
                return row

        traces = ray_iter(
            get_row,
            (
                (class_id, image_id)
                for image_id in range(0, 1)
                for class_id in range(0, 1000)
            ),
            chunksize=1,
            out_of_order=True,
            num_gpus=0,
        )
        if per_node:
            traces = list(itertools.chain.from_iterable(traces))
        traces = [trace for trace in traces if len(trace) != 0]
        return pd.DataFrame(traces)

    return CsvIOAction(path, init_fn=get_overlap_ratio)


def alexnet_imagenet_overlap_ratio_logit_diff(
    attack_name: str,
    attack_fn,
    generate_adversarial_fn,
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    overlap_fn: Callable[[AttrMap, AttrMap, str], float],
    path: str,
    per_node: bool = False,
    per_channel: bool = False,
    topk_share_range: int = 5,
    topk_calc_range: int = 5,
    **kwargs,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            mode.check(False)
            data_dir = IMAGENET_RAW_DIR
            model_dir = abspath("tf/alexnet/model_import")
            create_model = lambda: AlexNet()
            graph = AlexNet.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook, create_model=create_model, graph=graph
            )
            input_fn = lambda: imagenet_raw.test(
                data_dir,
                class_id,
                image_id,
                class_from_zero=True,
                preprocessing_fn=alexnet_preprocess_image,
            )
            predicted_label = predict(
                create_model=create_model, input_fn=input_fn, model_dir=model_dir
            )

            if predicted_label != class_id:
                return [{}] if per_node else {}

            # adversarial_example = generate_adversarial_fn(
            #     label=class_id,
            #     create_model=create_model,
            #     input_fn=lambda: imagenet_raw.test(data_dir, class_id, image_id, normed=False,
            #                                        class_from_zero=True, preprocessing_fn=alexnet_preprocess_image)
            #         .make_one_shot_iterator().get_next()[0],
            #     attack_fn=attack_fn,
            #     model_dir=model_dir,
            #     **kwargs,
            # )

            adversarial_example = alexnet_imagenet_example(
                attack_name=attack_name,
                attack_fn=attack_fn,
                generate_adversarial_fn=generate_adversarial_fn,
                class_id=class_id,
                image_id=image_id,
            ).load()

            if adversarial_example is None:
                return [{}] if per_node else {}

            adversarial_input_fn = lambda: tf.data.Dataset.from_tensors(
                imagenet.normalize_alexnet(adversarial_example)
            )
            adversarial_predicted_label = predict(
                create_model=create_model,
                input_fn=adversarial_input_fn,
                model_dir=model_dir,
            )

            if predicted_label == adversarial_predicted_label:
                return [{}] if per_node else {}

            trace = reconstruct_trace_from_tf(
                class_id=class_id,
                model_fn=model_fn,
                input_fn=input_fn,
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
                topk=topk_share_range,
            )[0]

            assert trace is not None

            label_top5 = trace.attrs[GraphAttrKey.PREDICT_TOP5]
            label_top5_value = trace.attrs[GraphAttrKey.PREDICT_TOP5_VALUE]

            adversarial_trace = reconstruct_trace_from_tf(
                model_fn=model_fn,
                input_fn=adversarial_input_fn,
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
                topk=topk_share_range,
            )[0]

            adversarial_label = adversarial_trace.attrs[GraphAttrKey.PREDICT]
            adversarial_label_top5 = adversarial_trace.attrs[GraphAttrKey.PREDICT_TOP5]
            adversarial_label_top5_value = adversarial_trace.attrs[
                GraphAttrKey.PREDICT_TOP5_VALUE
            ]

            assert class_id != adversarial_label

            def map_prefix(map: Dict[str, Any], prefix: str) -> Dict[str, Any]:
                return {f"{prefix}.{key}": value for key, value in map.items()}

            assert (
                class_id == label_top5[0]
                and adversarial_label == adversarial_label_top5[0]
            )
            trace = compact_trace(trace, graph, per_channel=per_channel)
            adversarial_trace = compact_trace(
                adversarial_trace, graph, per_channel=per_channel
            )

            class_traces = {}

            def get_class_trace(class_id: int) -> AttrMap:
                if class_id not in class_traces:
                    class_traces[class_id] = class_trace_fn(class_id).load()
                return class_traces[class_id]
                # return class_trace_fn(class_id).load()

            def get_overlap(
                base_class_id: int, class_ids: List[int], trace: AttrMap, input_fn
            ):
                rest_class_ids = class_ids.copy()
                if base_class_id in rest_class_ids:
                    rest_class_ids.remove(base_class_id)
                rest_class_trace = merge_compact_trace(
                    *[get_class_trace(class_id) for class_id in rest_class_ids]
                )
                class_trace = get_class_trace(base_class_id)
                class_specific_trace = merge_compact_trace_diff(
                    class_trace, rest_class_trace
                )
                example_specific_trace = merge_compact_trace_diff(
                    trace, rest_class_trace
                )

                example_trace_in_class_in_rest = merge_compact_trace_intersect(
                    class_trace, trace, rest_class_trace
                )
                example_trace_in_class_not_in_rest = merge_compact_trace_intersect(
                    class_specific_trace, example_specific_trace
                )
                example_trace_not_in_class_in_rest = merge_compact_trace_diff(
                    merge_compact_trace_intersect(trace, rest_class_trace), class_trace
                )
                example_trace_not_in_class_not_in_rest = merge_compact_trace_diff(
                    example_specific_trace, class_specific_trace
                )
                example_trace_in_class = merge_compact_trace_intersect(
                    class_trace, trace
                )
                example_trace_share = merge_compact_trace_diff(
                    trace, example_trace_not_in_class_not_in_rest
                )
                example_trace_specific = merge_compact_trace_diff(
                    trace, example_trace_not_in_class_in_rest
                )
                predicted_value_contributions = {
                    key: get_predicted_value_contribution(
                        current_trace,
                        graph=graph,
                        class_id=base_class_id,
                        create_model=create_model,
                        input_fn=input_fn,
                        model_dir=model_dir,
                    )
                    for key, current_trace in [
                        ("pvc_total", trace),
                        ("pvc_share", example_trace_share),
                        ("pvc_specific", example_trace_specific),
                        # ("pvc_in_class_in_rest", example_trace_in_class_in_rest),
                        ("pvc_in_class", example_trace_in_class),
                        (
                            "pvc_in_class_not_in_rest",
                            example_trace_in_class_not_in_rest,
                        ),
                        # ("pvc_not_in_class_in_rest", example_trace_not_in_class_in_rest),
                        # ("pvc_not_in_class_not_in_rest", example_trace_not_in_class_not_in_rest),
                    ]
                }
                overlap_sizes = {
                    key: calc_trace_size(current_trace, compact=True)
                    for key, current_trace in [
                        ("overlap_size_total", trace),
                        (
                            "overlap_size_in_class_in_rest",
                            example_trace_in_class_in_rest,
                        ),
                        (
                            "overlap_size_in_class_not_in_rest",
                            example_trace_in_class_not_in_rest,
                        ),
                        (
                            "overlap_size_not_in_class_in_rest",
                            example_trace_not_in_class_in_rest,
                        ),
                        (
                            "overlap_size_not_in_class_not_in_rest",
                            example_trace_not_in_class_not_in_rest,
                        ),
                    ]
                }
                return {
                    **calc_all_overlap(
                        class_specific_trace,
                        example_specific_trace,
                        overlap_fn,
                        compact=True,
                        use_intersect_size=True,
                    ),
                    **predicted_value_contributions,
                    **overlap_sizes,
                }

            # if (class_id not in adversarial_label_top5) or (adversarial_label not in label_top5):
            #     return [{}] if per_node else {}

            row = {}
            row = {
                **row,
                **map_prefix(
                    get_overlap(class_id, label_top5, trace, input_fn),
                    f"original.origin",
                ),
            }
            trace_target_class = reconstruct_trace_from_tf(
                class_id=class_id,
                model_fn=model_fn,
                input_fn=input_fn,
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
                topk=topk_share_range,
                select_seed_fn=lambda _: np.array([adversarial_label]),
            )[0]
            trace_target_class = compact_trace(
                trace_target_class, graph, per_channel=per_channel
            )
            row = {
                **row,
                **map_prefix(
                    get_overlap(
                        adversarial_label, label_top5, trace_target_class, input_fn
                    ),
                    f"original.target",
                ),
            }
            row = {
                **row,
                **map_prefix(
                    get_overlap(
                        adversarial_label,
                        adversarial_label_top5,
                        adversarial_trace,
                        adversarial_input_fn,
                    ),
                    f"adversarial.target",
                ),
            }
            adversarial_trace_original_class = reconstruct_trace_from_tf(
                model_fn=model_fn,
                input_fn=adversarial_input_fn,
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
                topk=topk_share_range,
                select_seed_fn=lambda _: np.array([class_id]),
            )[0]
            adversarial_trace_original_class = compact_trace(
                adversarial_trace_original_class, graph, per_channel=per_channel
            )
            row = {
                **row,
                **map_prefix(
                    get_overlap(
                        class_id,
                        adversarial_label_top5,
                        adversarial_trace_original_class,
                        adversarial_input_fn,
                    ),
                    f"adversarial.origin",
                ),
            }

            if per_node:
                raise RuntimeError()
            else:
                row = {
                    "image_id": image_id,
                    "label": class_id,
                    "adversarial_label": adversarial_label,
                    "label_top5": label_top5,
                    "adversarial_label_top5": adversarial_label_top5,
                    "label_top5_value": label_top5_value,
                    "adversarial_label_top5_value": adversarial_label_top5_value,
                    "label_value": label_top5_value[0],
                    "adversarial_label_value": adversarial_label_top5_value[0],
                    **row,
                }
                print(row)
                return row

        traces = ray_iter(
            get_row,
            (
                (class_id, image_id)
                for image_id in range(0, 1)
                for class_id in range(0, 1000)
            ),
            chunksize=1,
            out_of_order=True,
            num_gpus=0,
        )
        if per_node:
            traces = list(itertools.chain.from_iterable(traces))
        traces = [trace for trace in traces if len(trace) != 0]
        return pd.DataFrame(traces)

    return CsvIOAction(path, init_fn=get_overlap_ratio)


def alexnet_imagenet_ideal_metrics(
    attack_name: str,
    attack_fn,
    generate_adversarial_fn,
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    overlap_fn: Callable[[AttrMap, AttrMap, str], float],
    path: str,
    per_node: bool = False,
    per_channel: bool = False,
    topk_share_range: int = 5,
    topk_calc_range: int = 5,
    **kwargs,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            mode.check(False)
            data_dir = IMAGENET_RAW_DIR
            model_dir = abspath("tf/alexnet/model_import")
            create_model = lambda: AlexNet()
            graph = AlexNet.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook, create_model=create_model, graph=graph
            )
            input_fn = lambda: imagenet_raw.test(
                data_dir,
                class_id,
                image_id,
                class_from_zero=True,
                preprocessing_fn=alexnet_preprocess_image,
            )
            predicted_label = predict(
                create_model=create_model, input_fn=input_fn, model_dir=model_dir
            )

            if predicted_label != class_id:
                return [{}] if per_node else {}

            # adversarial_example = generate_adversarial_fn(
            #     label=class_id,
            #     create_model=create_model,
            #     input_fn=lambda: imagenet_raw.test(data_dir, class_id, image_id, normed=False,
            #                                        class_from_zero=True, preprocessing_fn=alexnet_preprocess_image)
            #         .make_one_shot_iterator().get_next()[0],
            #     attack_fn=attack_fn,
            #     model_dir=model_dir,
            #     **kwargs,
            # )

            adversarial_example = alexnet_imagenet_example(
                attack_name=attack_name,
                attack_fn=attack_fn,
                generate_adversarial_fn=generate_adversarial_fn,
                class_id=class_id,
                image_id=image_id,
            ).load()

            if adversarial_example is None:
                return [{}] if per_node else {}

            adversarial_input_fn = lambda: tf.data.Dataset.from_tensors(
                imagenet.normalize_alexnet(adversarial_example)
            )
            adversarial_predicted_label = predict(
                create_model=create_model,
                input_fn=adversarial_input_fn,
                model_dir=model_dir,
            )

            if predicted_label == adversarial_predicted_label:
                return [{}] if per_node else {}

            trace = reconstruct_trace_from_tf(
                class_id=class_id,
                model_fn=model_fn,
                input_fn=input_fn,
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
            )[0]

            assert trace is not None

            label_top5 = trace.attrs[GraphAttrKey.PREDICT_TOP5]
            label_top5_value = trace.attrs[GraphAttrKey.PREDICT_TOP5_VALUE]

            adversarial_trace = reconstruct_trace_from_tf(
                model_fn=model_fn,
                input_fn=adversarial_input_fn,
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
            )[0]

            adversarial_label = adversarial_trace.attrs[GraphAttrKey.PREDICT]
            adversarial_label_top5 = adversarial_trace.attrs[GraphAttrKey.PREDICT_TOP5]
            adversarial_label_top5_value = adversarial_trace.attrs[
                GraphAttrKey.PREDICT_TOP5_VALUE
            ]

            assert class_id != adversarial_label

            def map_prefix(map: Dict[str, Any], prefix: str) -> Dict[str, Any]:
                return {f"{prefix}.{key}": value for key, value in map.items()}

            assert (
                class_id == label_top5[0]
                and adversarial_label == adversarial_label_top5[0]
            )
            trace = compact_trace(trace, graph, per_channel=per_channel)
            adversarial_trace = compact_trace(
                adversarial_trace, graph, per_channel=per_channel
            )

            class_traces = {}

            def get_class_trace(class_id: int) -> AttrMap:
                if class_id not in class_traces:
                    class_traces[class_id] = class_trace_fn(class_id).load()
                return class_traces[class_id]
                # return class_trace_fn(class_id).load()

            def get_overlap(
                base_class_id: int, rest_class_id: int, trace: AttrMap, input_fn
            ):
                rest_class_trace = get_class_trace(rest_class_id)
                class_trace = get_class_trace(base_class_id)
                class_specific_trace = merge_compact_trace_diff(
                    class_trace, rest_class_trace
                )
                example_specific_trace = merge_compact_trace_diff(
                    trace, rest_class_trace
                )

                example_trace_in_class_in_rest = merge_compact_trace_intersect(
                    class_trace, trace, rest_class_trace
                )
                example_trace_in_class_not_in_rest = merge_compact_trace_intersect(
                    class_specific_trace, example_specific_trace
                )
                example_trace_not_in_class_in_rest = merge_compact_trace_diff(
                    merge_compact_trace_intersect(trace, rest_class_trace), class_trace
                )
                example_trace_not_in_class_not_in_rest = merge_compact_trace_diff(
                    example_specific_trace, class_specific_trace
                )
                example_trace_in_class = merge_compact_trace_intersect(
                    class_trace, trace
                )
                example_trace_share = merge_compact_trace_diff(
                    trace, example_trace_not_in_class_not_in_rest
                )
                example_trace_specific = merge_compact_trace_diff(
                    trace, example_trace_not_in_class_in_rest
                )
                predicted_value_contributions = {
                    key: get_predicted_value_contribution(
                        current_trace,
                        graph=graph,
                        class_id=base_class_id,
                        create_model=create_model,
                        input_fn=input_fn,
                        model_dir=model_dir,
                    )
                    for key, current_trace in [
                        ("pvc_total", trace),
                        ("pvc_share", example_trace_share),
                        ("pvc_specific", example_trace_specific),
                        # ("pvc_in_class_in_rest", example_trace_in_class_in_rest),
                        ("pvc_in_class", example_trace_in_class),
                        (
                            "pvc_in_class_not_in_rest",
                            example_trace_in_class_not_in_rest,
                        ),
                        # ("pvc_not_in_class_in_rest", example_trace_not_in_class_in_rest),
                        # ("pvc_not_in_class_not_in_rest", example_trace_not_in_class_not_in_rest),
                    ]
                }
                overlap_sizes = {
                    key: calc_trace_size(current_trace, compact=True)
                    for key, current_trace in [
                        ("overlap_size_total", trace),
                        (
                            "overlap_size_in_class_in_rest",
                            example_trace_in_class_in_rest,
                        ),
                        (
                            "overlap_size_in_class_not_in_rest",
                            example_trace_in_class_not_in_rest,
                        ),
                        (
                            "overlap_size_not_in_class_in_rest",
                            example_trace_not_in_class_in_rest,
                        ),
                        (
                            "overlap_size_not_in_class_not_in_rest",
                            example_trace_not_in_class_not_in_rest,
                        ),
                    ]
                }
                return {
                    **calc_all_overlap(
                        class_specific_trace,
                        example_specific_trace,
                        overlap_fn,
                        compact=True,
                        use_intersect_size=True,
                    ),
                    **predicted_value_contributions,
                    **overlap_sizes,
                }

            row = {}
            row = {
                **row,
                **map_prefix(
                    get_overlap(class_id, adversarial_label, trace, input_fn),
                    f"original.origin",
                ),
            }
            trace_target_class = reconstruct_trace_from_tf(
                class_id=class_id,
                model_fn=model_fn,
                input_fn=input_fn,
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
                select_seed_fn=lambda _: np.array([adversarial_label]),
            )[0]
            trace_target_class = compact_trace(
                trace_target_class, graph, per_channel=per_channel
            )
            row = {
                **row,
                **map_prefix(
                    get_overlap(
                        adversarial_label, class_id, trace_target_class, input_fn
                    ),
                    f"original.target",
                ),
            }
            row = {
                **row,
                **map_prefix(
                    get_overlap(
                        adversarial_label,
                        class_id,
                        adversarial_trace,
                        adversarial_input_fn,
                    ),
                    f"adversarial.target",
                ),
            }
            adversarial_trace_original_class = reconstruct_trace_from_tf(
                model_fn=model_fn,
                input_fn=adversarial_input_fn,
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
                select_seed_fn=lambda _: np.array([class_id]),
            )[0]
            adversarial_trace_original_class = compact_trace(
                adversarial_trace_original_class, graph, per_channel=per_channel
            )
            row = {
                **row,
                **map_prefix(
                    get_overlap(
                        class_id,
                        adversarial_label,
                        adversarial_trace_original_class,
                        adversarial_input_fn,
                    ),
                    f"adversarial.origin",
                ),
            }

            if per_node:
                raise RuntimeError()
            else:
                row = {
                    "image_id": image_id,
                    "label": class_id,
                    "adversarial_label": adversarial_label,
                    "label_top5": label_top5,
                    "adversarial_label_top5": adversarial_label_top5,
                    "label_top5_value": label_top5_value,
                    "adversarial_label_top5_value": adversarial_label_top5_value,
                    "label_value": label_top5_value[0],
                    "adversarial_label_value": adversarial_label_top5_value[0],
                    "original_class_rank_in_adversarial_example": get_rank(
                        class_id=class_id,
                        create_model=create_model,
                        input_fn=adversarial_input_fn,
                        model_dir=model_dir,
                    ),
                    "target_class_rank_in_original_example": get_rank(
                        class_id=adversarial_label,
                        create_model=create_model,
                        input_fn=input_fn,
                        model_dir=model_dir,
                    ),
                    **row,
                }
                print(row)
                return row

        traces = ray_iter(
            get_row,
            (
                (class_id, image_id)
                for image_id in range(0, 1)
                for class_id in range(0, 1000)
            ),
            chunksize=1,
            out_of_order=True,
            num_gpus=0,
        )
        if per_node:
            traces = list(itertools.chain.from_iterable(traces))
        traces = [trace for trace in traces if len(trace) != 0]
        return pd.DataFrame(traces)

    return CsvIOAction(path, init_fn=get_overlap_ratio)


def alexnet_imagenet_fc_layer_path_ideal_metrics(
    attack_name: str,
    attack_fn,
    generate_adversarial_fn,
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    overlap_fn: Callable[[AttrMap, AttrMap, str], float],
    path: str,
    per_node: bool = False,
    per_channel: bool = False,
    topk_share_range: int = 5,
    topk_calc_range: int = 5,
    **kwargs,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            mode.check(False)
            data_dir = IMAGENET_RAW_DIR
            model_dir = abspath("tf/alexnet/model_import")
            create_model = lambda: AlexNet()
            graph = AlexNet.graph().load()
            path_layer_name = graph.layers()[-11]
            model_fn = partial(
                model_fn_with_fetch_hook, create_model=create_model, graph=graph
            )
            input_fn = lambda: imagenet_raw.test(
                data_dir,
                class_id,
                image_id,
                class_from_zero=True,
                preprocessing_fn=alexnet_preprocess_image,
            )
            predicted_label = predict(
                create_model=create_model, input_fn=input_fn, model_dir=model_dir
            )

            if predicted_label != class_id:
                return [{}] if per_node else {}

            # adversarial_example = generate_adversarial_fn(
            #     label=class_id,
            #     create_model=create_model,
            #     input_fn=lambda: imagenet_raw.test(data_dir, class_id, image_id, normed=False,
            #                                        class_from_zero=True, preprocessing_fn=alexnet_preprocess_image)
            #         .make_one_shot_iterator().get_next()[0],
            #     attack_fn=attack_fn,
            #     model_dir=model_dir,
            #     **kwargs,
            # )

            adversarial_example = alexnet_imagenet_example(
                attack_name=attack_name,
                attack_fn=attack_fn,
                generate_adversarial_fn=generate_adversarial_fn,
                class_id=class_id,
                image_id=image_id,
            ).load()

            if adversarial_example is None:
                return [{}] if per_node else {}

            adversarial_input_fn = lambda: tf.data.Dataset.from_tensors(
                imagenet.normalize_alexnet(adversarial_example)
            )
            adversarial_predicted_label = predict(
                create_model=create_model,
                input_fn=adversarial_input_fn,
                model_dir=model_dir,
            )

            if predicted_label == adversarial_predicted_label:
                return [{}] if per_node else {}

            trace = reconstruct_trace_from_tf(
                class_id=class_id,
                model_fn=model_fn,
                input_fn=input_fn,
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
            )[0]

            assert trace is not None

            label_top5 = trace.attrs[GraphAttrKey.PREDICT_TOP5]
            label_top5_value = trace.attrs[GraphAttrKey.PREDICT_TOP5_VALUE]

            adversarial_trace = reconstruct_trace_from_tf(
                model_fn=model_fn,
                input_fn=adversarial_input_fn,
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
            )[0]

            adversarial_label = adversarial_trace.attrs[GraphAttrKey.PREDICT]
            adversarial_label_top5 = adversarial_trace.attrs[GraphAttrKey.PREDICT_TOP5]
            adversarial_label_top5_value = adversarial_trace.attrs[
                GraphAttrKey.PREDICT_TOP5_VALUE
            ]

            assert class_id != adversarial_label

            def map_prefix(map: Dict[str, Any], prefix: str) -> Dict[str, Any]:
                return {f"{prefix}.{key}": value for key, value in map.items()}

            assert (
                class_id == label_top5[0]
                and adversarial_label == adversarial_label_top5[0]
            )

            trace_target_class = reconstruct_trace_from_tf(
                class_id=class_id,
                model_fn=model_fn,
                input_fn=input_fn,
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
                select_seed_fn=lambda _: np.array([adversarial_label]),
            )[0]
            adversarial_trace_original_class = reconstruct_trace_from_tf(
                model_fn=model_fn,
                input_fn=adversarial_input_fn,
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
                select_seed_fn=lambda _: np.array([class_id]),
            )[0]

            trace = compact_trace(trace, graph, per_channel=per_channel)
            trace_target_class = compact_trace(
                trace_target_class, graph, per_channel=per_channel
            )
            adversarial_trace = compact_trace(
                adversarial_trace, graph, per_channel=per_channel
            )
            adversarial_trace_original_class = compact_trace(
                adversarial_trace_original_class, graph, per_channel=per_channel
            )

            class_traces = {}

            def get_class_trace(class_id: int) -> AttrMap:
                if class_id not in class_traces:
                    class_traces[class_id] = class_trace_fn(class_id).load()
                return class_traces[class_id]

            class_trace_paths = {}

            def get_class_trace_path(class_id: int) -> AttrMap:
                if class_id not in class_trace_paths:
                    class_trace = get_class_trace(class_id)
                    class_trace_paths[class_id] = get_trace_path_in_fc_layers(
                        graph, class_trace, compact=True
                    )
                return class_trace_paths[class_id]

            def get_overlap(base_class_id: int, trace: AttrMap):
                class_trace = get_class_trace(base_class_id)
                example_trace_path = get_trace_path_in_fc_layers(
                    graph, trace, compact=True
                )
                trace_path_intersection = get_trace_path_intersection_in_fc_layers(
                    trace, class_trace, graph=graph, compact=True
                )
                return {
                    "overlap_size": calc_trace_path_num(
                        trace_path_intersection, path_layer_name
                    ),
                    "trace_path_size": calc_trace_path_num(
                        example_trace_path, path_layer_name
                    ),
                    "class_trace_path_size": calc_trace_path_num(
                        get_class_trace_path(base_class_id), path_layer_name
                    ),
                }

            row = {}
            row = {
                **row,
                **map_prefix(get_overlap(class_id, trace), f"original.origin"),
            }
            row = {
                **row,
                **map_prefix(
                    get_overlap(adversarial_label, adversarial_trace),
                    f"adversarial.target",
                ),
            }
            row = {
                **row,
                **map_prefix(
                    get_overlap(adversarial_label, trace_target_class),
                    f"original.target",
                ),
            }
            row = {
                **row,
                **map_prefix(
                    get_overlap(class_id, adversarial_trace_original_class),
                    f"adversarial.origin",
                ),
            }

            if per_node:
                raise RuntimeError()
            else:
                row = {
                    "image_id": image_id,
                    "label": class_id,
                    "adversarial_label": adversarial_label,
                    "label_top5": label_top5,
                    "adversarial_label_top5": adversarial_label_top5,
                    "label_top5_value": label_top5_value,
                    "adversarial_label_top5_value": adversarial_label_top5_value,
                    "label_value": label_top5_value[0],
                    "adversarial_label_value": adversarial_label_top5_value[0],
                    **row,
                }
                print(row)
                return row

        traces = ray_iter(
            get_row,
            (
                (class_id, image_id)
                for image_id in range(0, 1)
                for class_id in range(0, 1000)
            ),
            chunksize=1,
            out_of_order=True,
            num_gpus=0,
        )
        if per_node:
            traces = list(itertools.chain.from_iterable(traces))
        traces = [trace for trace in traces if len(trace) != 0]
        return pd.DataFrame(traces)

    return CsvIOAction(path, init_fn=get_overlap_ratio)


def alexnet_imagenet_ideal_metrics_per_layer(
    attack_name: str,
    attack_fn,
    generate_adversarial_fn,
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    overlap_fn: Callable[[AttrMap, AttrMap, str], float],
    path: str,
    per_node: bool = False,
    per_channel: bool = False,
    topk_share_range: int = 5,
    topk_calc_range: int = 5,
    **kwargs,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            mode.check(False)
            data_dir = IMAGENET_RAW_DIR
            model_dir = abspath("tf/alexnet/model_import")
            create_model = lambda: AlexNet()
            graph = AlexNet.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook, create_model=create_model, graph=graph
            )
            input_fn = lambda: imagenet_raw.test(
                data_dir,
                class_id,
                image_id,
                class_from_zero=True,
                preprocessing_fn=alexnet_preprocess_image,
            )
            predicted_label = predict(
                create_model=create_model, input_fn=input_fn, model_dir=model_dir
            )

            if predicted_label != class_id:
                return [{}] if per_node else {}

            # adversarial_example = generate_adversarial_fn(
            #     label=class_id,
            #     create_model=create_model,
            #     input_fn=lambda: imagenet_raw.test(data_dir, class_id, image_id, normed=False,
            #                                        class_from_zero=True, preprocessing_fn=alexnet_preprocess_image)
            #         .make_one_shot_iterator().get_next()[0],
            #     attack_fn=attack_fn,
            #     model_dir=model_dir,
            #     **kwargs,
            # )

            adversarial_example = alexnet_imagenet_example(
                attack_name=attack_name,
                attack_fn=attack_fn,
                generate_adversarial_fn=generate_adversarial_fn,
                class_id=class_id,
                image_id=image_id,
            ).load()

            if adversarial_example is None:
                return [{}] if per_node else {}

            adversarial_input_fn = lambda: tf.data.Dataset.from_tensors(
                imagenet.normalize_alexnet(adversarial_example)
            )
            adversarial_predicted_label = predict(
                create_model=create_model,
                input_fn=adversarial_input_fn,
                model_dir=model_dir,
            )

            if predicted_label == adversarial_predicted_label:
                return [{}] if per_node else {}

            trace = reconstruct_trace_from_tf(
                class_id=class_id,
                model_fn=model_fn,
                input_fn=input_fn,
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
            )[0]

            assert trace is not None

            label_top5 = trace.attrs[GraphAttrKey.PREDICT_TOP5]
            label_top5_value = trace.attrs[GraphAttrKey.PREDICT_TOP5_VALUE]

            adversarial_trace = reconstruct_trace_from_tf(
                model_fn=model_fn,
                input_fn=adversarial_input_fn,
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
            )[0]

            adversarial_label = adversarial_trace.attrs[GraphAttrKey.PREDICT]
            adversarial_label_top5 = adversarial_trace.attrs[GraphAttrKey.PREDICT_TOP5]
            adversarial_label_top5_value = adversarial_trace.attrs[
                GraphAttrKey.PREDICT_TOP5_VALUE
            ]

            assert class_id != adversarial_label

            def map_prefix(map: Dict[str, Any], prefix: str) -> Dict[str, Any]:
                return {f"{prefix}.{key}": value for key, value in map.items()}

            assert (
                class_id == label_top5[0]
                and adversarial_label == adversarial_label_top5[0]
            )
            trace = compact_trace(trace, graph, per_channel=per_channel)
            adversarial_trace = compact_trace(
                adversarial_trace, graph, per_channel=per_channel
            )

            class_traces = {}

            def get_class_trace(class_id: int) -> AttrMap:
                if class_id not in class_traces:
                    class_traces[class_id] = class_trace_fn(class_id).load()
                return class_traces[class_id]
                # return class_trace_fn(class_id).load()

            def get_overlap(
                base_class_id: int, rest_class_id: int, trace: AttrMap, input_fn
            ):
                rest_class_trace = get_class_trace(rest_class_id)
                class_trace = get_class_trace(base_class_id)
                class_specific_trace = merge_compact_trace_diff(
                    class_trace, rest_class_trace
                )
                example_specific_trace = merge_compact_trace_diff(
                    trace, rest_class_trace
                )

                example_trace_in_class_in_rest = merge_compact_trace_intersect(
                    class_trace, trace, rest_class_trace
                )
                example_trace_in_class_not_in_rest = merge_compact_trace_intersect(
                    class_specific_trace, example_specific_trace
                )
                example_trace_not_in_class_in_rest = merge_compact_trace_diff(
                    merge_compact_trace_intersect(trace, rest_class_trace), class_trace
                )
                example_trace_not_in_class_not_in_rest = merge_compact_trace_diff(
                    example_specific_trace, class_specific_trace
                )
                overlap_sizes = merge_dict(
                    *[
                        filter_value_not_null(
                            {
                                f"{layer_name}.{key}": calc_trace_size_per_layer(
                                    current_trace, layer_name, compact=True
                                )
                                for key, current_trace in [
                                    ("overlap_size_total", trace),
                                    (
                                        "overlap_size_in_class_in_rest",
                                        example_trace_in_class_in_rest,
                                    ),
                                    (
                                        "overlap_size_in_class_not_in_rest",
                                        example_trace_in_class_not_in_rest,
                                    ),
                                    (
                                        "overlap_size_not_in_class_in_rest",
                                        example_trace_not_in_class_in_rest,
                                    ),
                                    (
                                        "overlap_size_not_in_class_not_in_rest",
                                        example_trace_not_in_class_not_in_rest,
                                    ),
                                ]
                            }
                        )
                        for layer_name in graph.ops_in_layers()
                    ]
                )
                return {
                    **calc_all_overlap(
                        class_specific_trace,
                        example_specific_trace,
                        overlap_fn,
                        compact=True,
                        use_intersect_size=True,
                    ),
                    **overlap_sizes,
                }

            row = {}
            row = {
                **row,
                **map_prefix(
                    get_overlap(class_id, adversarial_label, trace, input_fn),
                    f"original.origin",
                ),
            }
            trace_target_class = reconstruct_trace_from_tf(
                class_id=class_id,
                model_fn=model_fn,
                input_fn=input_fn,
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
                select_seed_fn=lambda _: np.array([adversarial_label]),
            )[0]
            trace_target_class = compact_trace(
                trace_target_class, graph, per_channel=per_channel
            )
            row = {
                **row,
                **map_prefix(
                    get_overlap(
                        adversarial_label, class_id, trace_target_class, input_fn
                    ),
                    f"original.target",
                ),
            }
            row = {
                **row,
                **map_prefix(
                    get_overlap(
                        adversarial_label,
                        class_id,
                        adversarial_trace,
                        adversarial_input_fn,
                    ),
                    f"adversarial.target",
                ),
            }
            row = {
                **row,
                **map_prefix(
                    get_overlap(
                        adversarial_label,
                        class_id,
                        merge_compact_trace_intersect(
                            trace_target_class, adversarial_trace
                        ),
                        adversarial_input_fn,
                    ),
                    f"shared.target",
                ),
            }
            adversarial_trace_original_class = reconstruct_trace_from_tf(
                model_fn=model_fn,
                input_fn=adversarial_input_fn,
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
                select_seed_fn=lambda _: np.array([class_id]),
            )[0]
            adversarial_trace_original_class = compact_trace(
                adversarial_trace_original_class, graph, per_channel=per_channel
            )
            row = {
                **row,
                **map_prefix(
                    get_overlap(
                        class_id,
                        adversarial_label,
                        adversarial_trace_original_class,
                        adversarial_input_fn,
                    ),
                    f"adversarial.origin",
                ),
            }
            row = {
                **row,
                **map_prefix(
                    get_overlap(
                        class_id,
                        adversarial_label,
                        merge_compact_trace_intersect(
                            adversarial_trace_original_class, trace
                        ),
                        adversarial_input_fn,
                    ),
                    f"shared.origin",
                ),
            }

            if per_node:
                raise RuntimeError()
            else:
                row = {
                    "image_id": image_id,
                    "label": class_id,
                    "adversarial_label": adversarial_label,
                    "label_top5": label_top5,
                    "adversarial_label_top5": adversarial_label_top5,
                    "label_top5_value": label_top5_value,
                    "adversarial_label_top5_value": adversarial_label_top5_value,
                    "label_value": label_top5_value[0],
                    "adversarial_label_value": adversarial_label_top5_value[0],
                    **row,
                }
                print(row)
                return row

        traces = ray_iter(
            get_row,
            (
                (class_id, image_id)
                for image_id in range(0, 1)
                for class_id in range(0, 1000)
            ),
            chunksize=1,
            out_of_order=True,
            num_gpus=0,
        )
        if per_node:
            traces = list(itertools.chain.from_iterable(traces))
        traces = [trace for trace in traces if len(trace) != 0]
        return pd.DataFrame(traces)

    return CsvIOAction(path, init_fn=get_overlap_ratio)


def alexnet_imagenet_real_metrics_per_layer(rank: int = None, **kwargs):
    return (
        imagenet_real_metrics_per_layer_per_rank
        if rank
        else imagenet_real_metrics_per_layer_v2
    )(
        model_config=ALEXNET.with_model_dir("tf/alexnet/model_import"),
        rank=rank,
        **kwargs,
    )


def imagenet_real_metrics_per_layer(
    model_config: ModelConfig,
    attack_name: str,
    attack_fn,
    generate_adversarial_fn,
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    path: str,
    select_seed_fn: Callable[[np.ndarray], np.ndarray] = None,
    entry_points: List[int] = None,
    per_node: bool = False,
    per_channel: bool = False,
    use_weight: bool = False,
    support_diff: bool = True,
    **kwargs,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            mode.check(False)
            data_dir = IMAGENET_RAW_DIR
            model_dir = abspath(model_config.model_dir)
            create_model = lambda: model_config.network_class()
            graph = model_config.network_class.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook, create_model=create_model, graph=graph
            )
            input_fn = lambda: imagenet_raw.test(
                data_dir,
                class_id,
                image_id,
                class_from_zero=model_config.class_from_zero,
                preprocessing_fn=model_config.preprocessing_fn,
            )
            predicted_label = predict(
                create_model=create_model, input_fn=input_fn, model_dir=model_dir
            )

            if predicted_label != class_id:
                return [{}] if per_node else {}

            # adversarial_example = generate_adversarial_fn(
            #     label=class_id,
            #     create_model=create_model,
            #     input_fn=lambda: imagenet_raw.test(data_dir, class_id, image_id, normed=False,
            #                                        class_from_zero=model_config.class_from_zero,
            #                                        preprocessing_fn=model_config.preprocessing_fn)
            #         .make_one_shot_iterator().get_next()[0],
            #     attack_fn=attack_fn,
            #     model_dir=model_dir,
            #     **kwargs,
            # )

            adversarial_example = imagenet_example(
                model_config=model_config,
                attack_name=attack_name,
                attack_fn=attack_fn,
                generate_adversarial_fn=generate_adversarial_fn,
                class_id=class_id,
                image_id=image_id,
            ).load()

            if adversarial_example is None:
                return [{}] if per_node else {}

            adversarial_input_fn = lambda: tf.data.Dataset.from_tensors(
                model_config.normalize_fn(adversarial_example)
            )
            adversarial_predicted_label = predict(
                create_model=create_model,
                input_fn=adversarial_input_fn,
                model_dir=model_dir,
            )

            if predicted_label == adversarial_predicted_label:
                return [{}] if per_node else {}

            trace = reconstruct_trace_from_tf(
                class_id=class_id,
                model_fn=model_fn,
                input_fn=input_fn,
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
                select_seed_fn=select_seed_fn,
                entry_points=entry_points,
            )[0]

            assert trace is not None

            label_top5 = trace.attrs[GraphAttrKey.PREDICT_TOP5]
            label_top5_value = trace.attrs[GraphAttrKey.PREDICT_TOP5_VALUE]

            adversarial_trace = reconstruct_trace_from_tf(
                model_fn=model_fn,
                input_fn=adversarial_input_fn,
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
                select_seed_fn=select_seed_fn,
                entry_points=entry_points,
            )[0]

            adversarial_label = adversarial_trace.attrs[GraphAttrKey.PREDICT]
            adversarial_label_top5 = adversarial_trace.attrs[GraphAttrKey.PREDICT_TOP5]
            adversarial_label_top5_value = adversarial_trace.attrs[
                GraphAttrKey.PREDICT_TOP5_VALUE
            ]

            assert class_id != adversarial_label

            def map_prefix(map: Dict[str, Any], prefix: str) -> Dict[str, Any]:
                return {f"{prefix}.{key}": value for key, value in map.items()}

            assert (
                class_id == label_top5[0]
                and adversarial_label == adversarial_label_top5[0]
            )
            trace = compact_trace(trace, graph, per_channel=per_channel)
            adversarial_trace = compact_trace(
                adversarial_trace, graph, per_channel=per_channel
            )

            class_traces = {}

            def get_class_trace(class_id: int) -> AttrMap:
                # if class_id not in class_traces:
                #     class_traces[class_id] = class_trace_fn(class_id).load()
                # return class_traces[class_id]
                return class_trace_fn(class_id).load()

            def get_overlap(base_class_id: int, trace: AttrMap):
                class_trace = get_class_trace(base_class_id)
                example_trace_in_class = merge_compact_trace_intersect(
                    class_trace, trace
                )
                overlap_sizes = merge_dict(
                    *[
                        filter_value_not_null(
                            {
                                f"{layer_name}.{key}": calc_trace_size_per_layer(
                                    current_trace,
                                    layer_name,
                                    compact=True,
                                    key=TraceKey.WEIGHT
                                    if use_weight
                                    else TraceKey.EDGE,
                                )
                                for key, current_trace in [
                                    ("overlap_size_total", trace),
                                    ("overlap_size_in_class", example_trace_in_class),
                                ]
                            }
                        )
                        for layer_name in graph.ops_in_layers()
                    ]
                )
                return overlap_sizes

            row = {}
            row = {
                **row,
                **map_prefix(get_overlap(class_id, trace), f"original.origin"),
            }
            row = {
                **row,
                **map_prefix(
                    get_overlap(adversarial_label, adversarial_trace),
                    f"adversarial.target",
                ),
            }

            if support_diff:
                trace_target_class = reconstruct_trace_from_tf(
                    class_id=class_id,
                    model_fn=model_fn,
                    input_fn=input_fn,
                    select_fn=select_fn,
                    model_dir=model_dir,
                    per_channel=per_channel,
                    select_seed_fn=lambda _: np.array([label_top5[1]]),
                )[0]
                trace_target_class = compact_trace(
                    trace_target_class, graph, per_channel=per_channel
                )
                row = {
                    **row,
                    **map_prefix(
                        get_overlap(label_top5[1], trace_target_class),
                        f"original.target",
                    ),
                }
                adversarial_trace_original_class = reconstruct_trace_from_tf(
                    model_fn=model_fn,
                    input_fn=adversarial_input_fn,
                    select_fn=select_fn,
                    model_dir=model_dir,
                    per_channel=per_channel,
                    select_seed_fn=lambda _: np.array([adversarial_label_top5[1]]),
                )[0]
                adversarial_trace_original_class = compact_trace(
                    adversarial_trace_original_class, graph, per_channel=per_channel
                )
                row = {
                    **row,
                    **map_prefix(
                        get_overlap(
                            adversarial_label_top5[1], adversarial_trace_original_class
                        ),
                        f"adversarial.origin",
                    ),
                }

            if per_node:
                raise RuntimeError()
            else:
                row = {
                    "image_id": image_id,
                    "label": class_id,
                    "adversarial_label": adversarial_label,
                    "label_top5": label_top5,
                    "adversarial_label_top5": adversarial_label_top5,
                    "label_top5_value": label_top5_value,
                    "adversarial_label_top5_value": adversarial_label_top5_value,
                    "label_value": label_top5_value[0],
                    "adversarial_label_value": adversarial_label_top5_value[0],
                    **row,
                }
                print(row)
                return row

        images = (
            (class_id, image_id)
            for image_id in range(0, 1)
            for class_id in range(0, 1000)
        )
        images = map(
            lambda class_with_image: (
                class_with_image[0]
                if model_config.class_from_zero
                else class_with_image[0] + 1,
                class_with_image[1],
            ),
            images,
        )
        traces = ray_iter(get_row, images, chunksize=1, out_of_order=True, num_gpus=0)
        if per_node:
            traces = list(itertools.chain.from_iterable(traces))
        traces = [trace for trace in traces if len(trace) != 0]
        return pd.DataFrame(traces)

    return CsvIOAction(path, init_fn=get_overlap_ratio)


def imagenet_real_metrics_per_layer_v2(
    model_config: ModelConfig,
    attack_name: str,
    attack_fn,
    generate_adversarial_fn,
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    path: str,
    select_seed_fn: Callable[[np.ndarray], np.ndarray] = None,
    entry_points: List[int] = None,
    per_node: bool = False,
    per_channel: bool = False,
    use_weight: bool = False,
    support_diff: bool = True,
    threshold: float = None,
    **kwargs,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            mode.check(False)
            data_dir = IMAGENET_RAW_DIR
            model_dir = abspath(model_config.model_dir)
            create_model = lambda: model_config.network_class()
            graph = model_config.network_class.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook, create_model=create_model, graph=graph
            )

            input_fn = lambda: imagenet_raw.test(
                data_dir,
                class_id,
                image_id,
                class_from_zero=model_config.class_from_zero,
                preprocessing_fn=model_config.preprocessing_fn,
            )

            assert threshold is not None
            trace = imagenet_example_trace(
                model_config=model_config,
                attack_name="original",
                attack_fn=attack_fn,
                generate_adversarial_fn=generate_adversarial_fn,
                class_id=class_id,
                image_id=image_id,
                threshold=threshold,
                per_channel=per_channel,
                select_seed_fn=select_seed_fn,
                entry_points=entry_points,
            ).load()

            if trace is None:
                return [{}] if per_node else {}

            label_top5 = trace.attrs[GraphAttrKey.PREDICT_TOP5]
            label_top5_value = trace.attrs[GraphAttrKey.PREDICT_TOP5_VALUE]

            adversarial_trace = imagenet_example_trace(
                model_config=model_config,
                attack_name=attack_name,
                attack_fn=attack_fn,
                generate_adversarial_fn=generate_adversarial_fn,
                class_id=class_id,
                image_id=image_id,
                threshold=threshold,
                per_channel=per_channel,
                select_seed_fn=select_seed_fn,
                entry_points=entry_points,
            ).load()

            if adversarial_trace is None:
                return [{}] if per_node else {}

            adversarial_example = imagenet_example(
                model_config=model_config,
                attack_name=attack_name,
                attack_fn=attack_fn,
                generate_adversarial_fn=generate_adversarial_fn,
                class_id=class_id,
                image_id=image_id,
            ).load()

            if adversarial_example is None:
                return [{}] if per_node else {}

            adversarial_input_fn = lambda: tf.data.Dataset.from_tensors(
                model_config.normalize_fn(adversarial_example)
            )

            adversarial_label = adversarial_trace.attrs[GraphAttrKey.PREDICT]
            adversarial_label_top5 = adversarial_trace.attrs[GraphAttrKey.PREDICT_TOP5]
            adversarial_label_top5_value = adversarial_trace.attrs[
                GraphAttrKey.PREDICT_TOP5_VALUE
            ]

            assert class_id != adversarial_label

            def map_prefix(map: Dict[str, Any], prefix: str) -> Dict[str, Any]:
                return {f"{prefix}.{key}": value for key, value in map.items()}

            assert (
                class_id == label_top5[0]
                and adversarial_label == adversarial_label_top5[0]
            )

            class_traces = {}

            def get_class_trace(class_id: int) -> AttrMap:
                # if class_id not in class_traces:
                #     class_traces[class_id] = class_trace_fn(class_id).load()
                # return class_traces[class_id]
                return class_trace_fn(class_id).load()

            def get_overlap(base_class_id: int, trace: AttrMap):
                class_trace = get_class_trace(base_class_id)
                example_trace_in_class = merge_compact_trace_intersect(
                    class_trace, trace
                )
                overlap_sizes = merge_dict(
                    *[
                        filter_value_not_null(
                            {
                                f"{layer_name}.{key}": calc_trace_size_per_layer(
                                    current_trace,
                                    layer_name,
                                    compact=True,
                                    key=TraceKey.WEIGHT
                                    if use_weight
                                    else TraceKey.EDGE,
                                )
                                for key, current_trace in [
                                    ("overlap_size_total", trace),
                                    ("overlap_size_in_class", example_trace_in_class),
                                ]
                            }
                        )
                        for layer_name in graph.ops_in_layers()
                    ]
                )
                return overlap_sizes

            row = {}
            row = {
                **row,
                **map_prefix(get_overlap(class_id, trace), f"original.origin"),
            }
            row = {
                **row,
                **map_prefix(
                    get_overlap(adversarial_label, adversarial_trace),
                    f"adversarial.target",
                ),
            }

            if support_diff:
                trace_target_class = reconstruct_trace_from_tf(
                    class_id=class_id,
                    model_fn=model_fn,
                    input_fn=input_fn,
                    select_fn=select_fn,
                    model_dir=model_dir,
                    per_channel=per_channel,
                    select_seed_fn=lambda _: np.array([label_top5[1]]),
                )[0]
                trace_target_class = compact_trace(
                    trace_target_class, graph, per_channel=per_channel
                )
                row = {
                    **row,
                    **map_prefix(
                        get_overlap(label_top5[1], trace_target_class),
                        f"original.target",
                    ),
                }
                adversarial_trace_original_class = reconstruct_trace_from_tf(
                    model_fn=model_fn,
                    input_fn=adversarial_input_fn,
                    select_fn=select_fn,
                    model_dir=model_dir,
                    per_channel=per_channel,
                    select_seed_fn=lambda _: np.array([adversarial_label_top5[1]]),
                )[0]
                adversarial_trace_original_class = compact_trace(
                    adversarial_trace_original_class, graph, per_channel=per_channel
                )
                row = {
                    **row,
                    **map_prefix(
                        get_overlap(
                            adversarial_label_top5[1], adversarial_trace_original_class
                        ),
                        f"adversarial.origin",
                    ),
                }

            if per_node:
                raise RuntimeError()
            else:
                row = {
                    "image_id": image_id,
                    "label": class_id,
                    "adversarial_label": adversarial_label,
                    "label_top5": label_top5,
                    "adversarial_label_top5": adversarial_label_top5,
                    "label_top5_value": label_top5_value,
                    "adversarial_label_top5_value": adversarial_label_top5_value,
                    "label_value": label_top5_value[0],
                    "adversarial_label_value": adversarial_label_top5_value[0],
                    **row,
                }
                print(row)
                return row

        images = (
            (class_id, image_id)
            for image_id in range(0, 1)
            for class_id in range(0, 1000)
        )
        images = map(
            lambda class_with_image: (
                class_with_image[0]
                if model_config.class_from_zero
                else class_with_image[0] + 1,
                class_with_image[1],
            ),
            images,
        )
        traces = ray_iter(get_row, images, chunksize=1, out_of_order=True, num_gpus=0)
        if per_node:
            traces = list(itertools.chain.from_iterable(traces))
        traces = [trace for trace in traces if len(trace) != 0]
        return pd.DataFrame(traces)

    return CsvIOAction(path, init_fn=get_overlap_ratio)


def imagenet_real_metrics_per_layer_per_rank(
    model_config: ModelConfig,
    attack_name: str,
    attack_fn,
    generate_adversarial_fn,
    trace_fn,
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    path: str,
    rank: int,
    use_weight: bool = False,
    threshold: float = None,
    use_point: bool = False,
    per_channel: bool = False,
    **kwargs,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            mode.check(False)
            data_dir = IMAGENET_RAW_DIR
            model_dir = abspath(model_config.model_dir)
            create_model = lambda: model_config.network_class()
            graph = model_config.network_class.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook, create_model=create_model, graph=graph
            )

            input_fn = lambda: imagenet_raw.test(
                data_dir,
                class_id,
                image_id,
                class_from_zero=model_config.class_from_zero,
                preprocessing_fn=model_config.preprocessing_fn,
            )

            assert threshold is not None

            if attack_name == "normal":
                trace = reconstruct_trace_from_tf_v2(
                    class_id=class_id,
                    model_fn=model_fn,
                    input_fn=input_fn,
                    trace_fn=partial(
                        trace_fn,
                        select_seed_fn=lambda output: arg_sorted_topk(output, rank)[
                            rank - 1 : rank
                        ],
                    ),
                    model_dir=model_dir,
                    rank=rank,
                )[0]
            else:
                adversarial_example = imagenet_example(
                    model_config=model_config,
                    attack_name=attack_name,
                    attack_fn=attack_fn,
                    generate_adversarial_fn=generate_adversarial_fn,
                    class_id=class_id,
                    image_id=image_id,
                ).load()

                if adversarial_example is None:
                    return {}

                adversarial_input_fn = lambda: tf.data.Dataset.from_tensors(
                    model_config.normalize_fn(adversarial_example)
                )

                trace = reconstruct_trace_from_tf_v2(
                    model_fn=model_fn,
                    input_fn=adversarial_input_fn,
                    trace_fn=partial(
                        trace_fn,
                        select_seed_fn=lambda output: arg_sorted_topk(output, rank)[
                            rank - 1 : rank
                        ],
                    ),
                    model_dir=model_dir,
                    rank=rank,
                )[0]

            if trace is None:
                return {}

            label = trace.attrs[GraphAttrKey.SEED]

            def get_class_trace(class_id: int) -> AttrMap:
                return class_trace_fn(class_id).load()

            def get_overlap(base_class_id: int, trace: AttrMap):
                class_trace = get_class_trace(base_class_id)
                example_trace_in_class = merge_compact_trace_intersect(
                    class_trace, trace
                )
                if use_point:
                    overlap_sizes = merge_dict(
                        *[
                            filter_value_not_null(
                                {
                                    f"{layer_name}.{key}": calc_trace_size_per_layer(
                                        current_trace,
                                        graph.op(graph.id(layer_name))
                                        .output_nodes[0]
                                        .name,
                                        compact=True,
                                        key=TraceKey.POINT,
                                    )
                                    for key, current_trace in [
                                        ("overlap_size_total", trace),
                                        (
                                            "overlap_size_in_class",
                                            example_trace_in_class,
                                        ),
                                    ]
                                }
                            )
                            for layer_name in graph.ops_in_layers()
                        ]
                    )
                else:
                    overlap_sizes = merge_dict(
                        *[
                            filter_value_not_null(
                                {
                                    f"{layer_name}.{key}": calc_trace_size_per_layer(
                                        current_trace,
                                        layer_name,
                                        compact=True,
                                        key=TraceKey.WEIGHT
                                        if use_weight
                                        else TraceKey.EDGE,
                                    )
                                    for key, current_trace in [
                                        ("overlap_size_total", trace),
                                        (
                                            "overlap_size_in_class",
                                            example_trace_in_class,
                                        ),
                                    ]
                                }
                            )
                            for layer_name in graph.ops_in_layers()
                        ]
                    )
                return overlap_sizes

            trace = compact_trace(trace, graph, per_channel=per_channel)
            row = {}
            row = {**row, **get_overlap(label, trace)}
            row = {"class_id": class_id, "image_id": image_id, "label": label, **row}
            # print(row)
            return row

        images = (
            (class_id, image_id)
            for image_id in range(0, 1)
            for class_id in range(0, 1000)
        )
        images = map(
            lambda class_with_image: (
                class_with_image[0]
                if model_config.class_from_zero
                else class_with_image[0] + 1,
                class_with_image[1],
            ),
            images,
        )
        traces = list(
            ray_iter(get_row, images, chunksize=1, out_of_order=True, num_gpus=0)
        )
        assert len(traces) == 1000
        traces = [trace for trace in traces if len(trace) != 0]
        return pd.DataFrame(traces).sort_values(by=["class_id", "image_id"])

    return CsvIOAction(path, init_fn=get_overlap_ratio)


def resnet_50_imagenet_real_metrics_per_layer(rank: int = None, **kwargs):
    return (
        imagenet_real_metrics_per_layer_per_rank
        if rank
        else imagenet_real_metrics_per_layer_v2
    )(model_config=RESNET_50, rank=rank, **kwargs)


def vgg_16_imagenet_real_metrics_per_layer(rank: int = None, **kwargs):
    return (
        imagenet_real_metrics_per_layer_per_rank
        if rank
        else imagenet_real_metrics_per_layer_v2
    )(model_config=VGG_16, rank=rank, **kwargs)


def alexnet_imagenet_real_metrics_per_layer_targeted(target_class: int):
    def metrics_fn(
        attack_name: str,
        attack_fn,
        generate_adversarial_fn,
        class_trace_fn: Callable[[int], IOAction[AttrMap]],
        select_fn: Callable[[np.ndarray], np.ndarray],
        overlap_fn: Callable[[AttrMap, AttrMap, str], float],
        path: str,
        select_seed_fn: Callable[[np.ndarray], np.ndarray] = None,
        entry_points: List[int] = None,
        per_node: bool = False,
        per_channel: bool = False,
        topk_share_range: int = 5,
        topk_calc_range: int = 5,
        use_weight: bool = False,
        support_diff: bool = True,
        **kwargs,
    ):
        return imagenet_real_metrics_per_layer_targeted(
            target_class=target_class,
            model_config=ALEXNET.with_model_dir("tf/alexnet/model_import"),
            attack_name=attack_name,
            attack_fn=attack_fn,
            generate_adversarial_fn=generate_adversarial_fn,
            class_trace_fn=class_trace_fn,
            select_fn=select_fn,
            path=path,
            select_seed_fn=select_seed_fn,
            entry_points=entry_points,
            per_node=per_node,
            per_channel=per_channel,
            use_weight=use_weight,
            support_diff=support_diff,
            **kwargs,
        )

    return metrics_fn


def resnet_50_imagenet_real_metrics_per_layer_targeted(target_class: int):
    def metrics_fn(
        attack_name: str,
        attack_fn,
        generate_adversarial_fn,
        class_trace_fn: Callable[[int], IOAction[AttrMap]],
        select_fn: Callable[[np.ndarray], np.ndarray],
        overlap_fn: Callable[[AttrMap, AttrMap, str], float],
        path: str,
        select_seed_fn: Callable[[np.ndarray], np.ndarray] = None,
        entry_points: List[int] = None,
        per_node: bool = False,
        per_channel: bool = False,
        topk_share_range: int = 5,
        topk_calc_range: int = 5,
        use_weight: bool = False,
        support_diff: bool = True,
        **kwargs,
    ):
        return imagenet_real_metrics_per_layer_targeted(
            target_class=target_class,
            model_config=RESNET_50,
            attack_name=attack_name,
            attack_fn=attack_fn,
            generate_adversarial_fn=generate_adversarial_fn,
            class_trace_fn=class_trace_fn,
            select_fn=select_fn,
            path=path,
            select_seed_fn=select_seed_fn,
            entry_points=entry_points,
            per_node=per_node,
            per_channel=per_channel,
            use_weight=use_weight,
            support_diff=support_diff,
            **kwargs,
        )

    return metrics_fn


def imagenet_real_metrics_per_layer_targeted(
    target_class: int,
    model_config: ModelConfig,
    attack_name: str,
    attack_fn,
    generate_adversarial_fn,
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    path: str,
    select_seed_fn: Callable[[np.ndarray], np.ndarray] = None,
    entry_points: List[int] = None,
    per_node: bool = False,
    per_channel: bool = False,
    use_weight: bool = False,
    support_diff: bool = True,
    **kwargs,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            mode.check(False)
            data_dir = IMAGENET_RAW_DIR
            model_dir = abspath(model_config.model_dir)
            create_model = lambda: model_config.network_class()
            graph = model_config.network_class.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook, create_model=create_model, graph=graph
            )

            if image_id == -1:
                image_id = 0
                while True:
                    input_fn = lambda: imagenet_raw.test(
                        data_dir,
                        class_id,
                        image_id,
                        class_from_zero=model_config.class_from_zero,
                        preprocessing_fn=model_config.preprocessing_fn,
                    )
                    try:
                        predicted_label = predict(
                            create_model=create_model,
                            input_fn=input_fn,
                            model_dir=model_dir,
                        )
                        if predicted_label != class_id:
                            image_id += 1
                        else:
                            break
                    except IndexError:
                        return [{}] if per_node else {}
            else:
                input_fn = lambda: imagenet_raw.test(
                    data_dir,
                    class_id,
                    image_id,
                    class_from_zero=model_config.class_from_zero,
                    preprocessing_fn=model_config.preprocessing_fn,
                )
                predicted_label = predict(
                    create_model=create_model, input_fn=input_fn, model_dir=model_dir
                )

                if predicted_label != class_id:
                    return [{}] if per_node else {}

            trace = reconstruct_trace_from_tf(
                class_id=class_id,
                model_fn=model_fn,
                input_fn=input_fn,
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
                select_seed_fn=select_seed_fn,
                entry_points=entry_points,
            )[0]

            assert trace is not None

            label_top5 = trace.attrs[GraphAttrKey.PREDICT_TOP5]
            label_top5_value = trace.attrs[GraphAttrKey.PREDICT_TOP5_VALUE]

            def map_prefix(map: Dict[str, Any], prefix: str) -> Dict[str, Any]:
                return {f"{prefix}.{key}": value for key, value in map.items()}

            trace = compact_trace(trace, graph, per_channel=per_channel)

            class_traces = {}

            def get_class_trace(class_id: int) -> AttrMap:
                # if class_id not in class_traces:
                #     class_traces[class_id] = class_trace_fn(class_id).load()
                # return class_traces[class_id]
                return class_trace_fn(class_id).load()

            def get_overlap(base_class_id: int, trace: AttrMap):
                class_trace = get_class_trace(base_class_id)
                example_trace_in_class = merge_compact_trace_intersect(
                    class_trace, trace
                )
                overlap_sizes = merge_dict(
                    *[
                        filter_value_not_null(
                            {
                                f"{layer_name}.{key}": calc_trace_size_per_layer(
                                    current_trace,
                                    layer_name,
                                    compact=True,
                                    key=TraceKey.WEIGHT
                                    if use_weight
                                    else TraceKey.EDGE,
                                )
                                for key, current_trace in [
                                    ("overlap_size_total", trace),
                                    ("overlap_size_in_class", example_trace_in_class),
                                ]
                            }
                        )
                        for layer_name in graph.ops_in_layers()
                    ]
                )
                return overlap_sizes

            row = {}
            row = {
                **row,
                **map_prefix(get_overlap(class_id, trace), f"original.origin"),
            }

            trace_target_class = reconstruct_trace_from_tf(
                class_id=class_id,
                model_fn=model_fn,
                input_fn=input_fn,
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
                select_seed_fn=lambda _: np.array([target_class]),
            )[0]
            trace_target_class = compact_trace(
                trace_target_class, graph, per_channel=per_channel
            )
            row = {
                **row,
                **map_prefix(
                    get_overlap(label_top5[1], trace_target_class), f"original.target"
                ),
            }

            if per_node:
                raise RuntimeError()
            else:
                row = {
                    "image_id": image_id,
                    "label": class_id,
                    "label_top5": label_top5,
                    "label_top5_value": label_top5_value,
                    "label_value": label_top5_value[0],
                    **row,
                }
                print(row)
                return row

        images = [(target_class, image_id) for image_id in range(0, 40)] + [
            (class_id, -1) for class_id in range(0, 1000) if class_id != target_class
        ]
        images = map(
            lambda class_with_image: (
                class_with_image[0]
                if model_config.class_from_zero
                else class_with_image[0] + 1,
                class_with_image[1],
            ),
            images,
        )
        traces = ray_iter(get_row, images, chunksize=1, out_of_order=True, num_gpus=0)
        if per_node:
            traces = list(itertools.chain.from_iterable(traces))
        traces = [trace for trace in traces if len(trace) != 0]
        return pd.DataFrame(traces)

    return CsvIOAction(path, init_fn=get_overlap_ratio)


def alexnet_imagenet_negative_example_ideal_metrics_per_layer(
    attack_name: str,
    attack_fn,
    generate_adversarial_fn,
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    overlap_fn: Callable[[AttrMap, AttrMap, str], float],
    path: str,
    per_node: bool = False,
    per_channel: bool = False,
    topk_share_range: int = 5,
    topk_calc_range: int = 5,
    **kwargs,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            mode.check(False)
            data_dir = IMAGENET_RAW_DIR
            model_dir = abspath("tf/alexnet/model_import")
            create_model = lambda: AlexNet()
            graph = AlexNet.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook, create_model=create_model, graph=graph
            )
            input_fn = lambda: imagenet_raw.test(
                data_dir,
                class_id,
                image_id,
                class_from_zero=True,
                preprocessing_fn=alexnet_preprocess_image,
            )
            predicted_label = predict(
                create_model=create_model, input_fn=input_fn, model_dir=model_dir
            )

            if predicted_label != class_id:
                return [{}] if per_node else {}

            # adversarial_example = generate_adversarial_fn(
            #     label=class_id,
            #     create_model=create_model,
            #     input_fn=lambda: imagenet_raw.test(data_dir, class_id, image_id, normed=False,
            #                                        class_from_zero=True, preprocessing_fn=alexnet_preprocess_image)
            #         .make_one_shot_iterator().get_next()[0],
            #     attack_fn=attack_fn,
            #     model_dir=model_dir,
            #     **kwargs,
            # )

            adversarial_image_id = image_id + 1
            while True:
                adversarial_input_fn = lambda: imagenet_raw.test(
                    data_dir,
                    class_id,
                    adversarial_image_id,
                    class_from_zero=True,
                    preprocessing_fn=alexnet_preprocess_image,
                )
                try:
                    adversarial_predicted_label_rank = get_rank(
                        class_id=predicted_label,
                        create_model=create_model,
                        input_fn=adversarial_input_fn,
                        model_dir=model_dir,
                    )
                except IndexError:
                    return [{}] if per_node else {}
                if adversarial_predicted_label_rank == 0:
                    adversarial_image_id += 1
                else:
                    if attack_name == "negative_example":
                        stop = True
                    elif attack_name == "negative_example_top5":
                        if adversarial_predicted_label_rank < 5:
                            stop = True
                        else:
                            stop = False
                    elif attack_name == "negative_example_out_of_top5":
                        if adversarial_predicted_label_rank >= 5:
                            stop = True
                        else:
                            stop = False
                    else:
                        raise RuntimeError()
                    if stop:
                        break
                    else:
                        adversarial_image_id += 1

            trace = reconstruct_trace_from_tf(
                class_id=class_id,
                model_fn=model_fn,
                input_fn=input_fn,
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
            )[0]

            assert trace is not None

            label_top5 = trace.attrs[GraphAttrKey.PREDICT_TOP5]
            label_top5_value = trace.attrs[GraphAttrKey.PREDICT_TOP5_VALUE]

            adversarial_trace = reconstruct_trace_from_tf(
                model_fn=model_fn,
                input_fn=adversarial_input_fn,
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
            )[0]

            adversarial_label = adversarial_trace.attrs[GraphAttrKey.PREDICT]
            adversarial_label_top5 = adversarial_trace.attrs[GraphAttrKey.PREDICT_TOP5]
            adversarial_label_top5_value = adversarial_trace.attrs[
                GraphAttrKey.PREDICT_TOP5_VALUE
            ]

            assert class_id != adversarial_label

            def map_prefix(map: Dict[str, Any], prefix: str) -> Dict[str, Any]:
                return {f"{prefix}.{key}": value for key, value in map.items()}

            assert (
                class_id == label_top5[0]
                and adversarial_label == adversarial_label_top5[0]
            )
            trace = compact_trace(trace, graph, per_channel=per_channel)
            adversarial_trace = compact_trace(
                adversarial_trace, graph, per_channel=per_channel
            )

            class_traces = {}

            def get_class_trace(class_id: int) -> AttrMap:
                if class_id not in class_traces:
                    class_traces[class_id] = class_trace_fn(class_id).load()
                return class_traces[class_id]
                # return class_trace_fn(class_id).load()

            def get_overlap(
                base_class_id: int, rest_class_id: int, trace: AttrMap, input_fn
            ):
                rest_class_trace = get_class_trace(rest_class_id)
                class_trace = get_class_trace(base_class_id)
                class_specific_trace = merge_compact_trace_diff(
                    class_trace, rest_class_trace
                )
                example_specific_trace = merge_compact_trace_diff(
                    trace, rest_class_trace
                )

                example_trace_in_class_in_rest = merge_compact_trace_intersect(
                    class_trace, trace, rest_class_trace
                )
                example_trace_in_class_not_in_rest = merge_compact_trace_intersect(
                    class_specific_trace, example_specific_trace
                )
                example_trace_not_in_class_in_rest = merge_compact_trace_diff(
                    merge_compact_trace_intersect(trace, rest_class_trace), class_trace
                )
                example_trace_not_in_class_not_in_rest = merge_compact_trace_diff(
                    example_specific_trace, class_specific_trace
                )
                overlap_sizes = merge_dict(
                    *[
                        filter_value_not_null(
                            {
                                f"{layer_name}.{key}": calc_trace_size_per_layer(
                                    current_trace, layer_name, compact=True
                                )
                                for key, current_trace in [
                                    ("overlap_size_total", trace),
                                    (
                                        "overlap_size_in_class_in_rest",
                                        example_trace_in_class_in_rest,
                                    ),
                                    (
                                        "overlap_size_in_class_not_in_rest",
                                        example_trace_in_class_not_in_rest,
                                    ),
                                    (
                                        "overlap_size_not_in_class_in_rest",
                                        example_trace_not_in_class_in_rest,
                                    ),
                                    (
                                        "overlap_size_not_in_class_not_in_rest",
                                        example_trace_not_in_class_not_in_rest,
                                    ),
                                ]
                            }
                        )
                        for layer_name in graph.ops_in_layers()
                    ]
                )
                return {
                    **calc_all_overlap(
                        class_specific_trace,
                        example_specific_trace,
                        overlap_fn,
                        compact=True,
                        use_intersect_size=True,
                    ),
                    **overlap_sizes,
                }

            row = {}
            row = {
                **row,
                **map_prefix(
                    get_overlap(class_id, adversarial_label, trace, input_fn),
                    f"original.origin",
                ),
            }
            trace_target_class = reconstruct_trace_from_tf(
                class_id=class_id,
                model_fn=model_fn,
                input_fn=input_fn,
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
                select_seed_fn=lambda _: np.array([adversarial_label]),
            )[0]
            trace_target_class = compact_trace(
                trace_target_class, graph, per_channel=per_channel
            )
            row = {
                **row,
                **map_prefix(
                    get_overlap(
                        adversarial_label, class_id, trace_target_class, input_fn
                    ),
                    f"original.target",
                ),
            }
            row = {
                **row,
                **map_prefix(
                    get_overlap(
                        adversarial_label,
                        class_id,
                        adversarial_trace,
                        adversarial_input_fn,
                    ),
                    f"adversarial.target",
                ),
            }
            row = {
                **row,
                **map_prefix(
                    get_overlap(
                        adversarial_label,
                        class_id,
                        merge_compact_trace_intersect(
                            trace_target_class, adversarial_trace
                        ),
                        adversarial_input_fn,
                    ),
                    f"shared.target",
                ),
            }
            adversarial_trace_original_class = reconstruct_trace_from_tf(
                model_fn=model_fn,
                input_fn=adversarial_input_fn,
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
                select_seed_fn=lambda _: np.array([class_id]),
            )[0]
            adversarial_trace_original_class = compact_trace(
                adversarial_trace_original_class, graph, per_channel=per_channel
            )
            row = {
                **row,
                **map_prefix(
                    get_overlap(
                        class_id,
                        adversarial_label,
                        adversarial_trace_original_class,
                        adversarial_input_fn,
                    ),
                    f"adversarial.origin",
                ),
            }
            row = {
                **row,
                **map_prefix(
                    get_overlap(
                        class_id,
                        adversarial_label,
                        merge_compact_trace_intersect(
                            adversarial_trace_original_class, trace
                        ),
                        adversarial_input_fn,
                    ),
                    f"shared.origin",
                ),
            }

            if per_node:
                raise RuntimeError()
            else:
                row = {
                    "image_id": image_id,
                    "label": class_id,
                    "adversarial_label": adversarial_label,
                    "label_top5": label_top5,
                    "adversarial_label_top5": adversarial_label_top5,
                    "label_top5_value": label_top5_value,
                    "adversarial_label_top5_value": adversarial_label_top5_value,
                    "label_value": label_top5_value[0],
                    "adversarial_label_value": adversarial_label_top5_value[0],
                    **row,
                }
                print(row)
                return row

        traces = ray_iter(
            get_row,
            (
                (class_id, image_id)
                for image_id in range(0, 1)
                for class_id in range(0, 1000)
            ),
            chunksize=1,
            out_of_order=True,
            num_gpus=0,
        )
        if per_node:
            traces = list(itertools.chain.from_iterable(traces))
        traces = [trace for trace in traces if len(trace) != 0]
        return pd.DataFrame(traces)

    return CsvIOAction(path, init_fn=get_overlap_ratio)


def alexnet_imagenet_overlap_ratio_top5_unique(
    attack_name: str,
    attack_fn,
    generate_adversarial_fn,
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    overlap_fn: Callable[[AttrMap, AttrMap, str], float],
    path: str,
    per_node: bool = False,
    per_channel: bool = False,
    **kwargs,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            mode.check(False)
            data_dir = IMAGENET_RAW_DIR
            model_dir = abspath("tf/alexnet/model_import")
            create_model = lambda: AlexNet()
            graph = AlexNet.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook, create_model=create_model, graph=graph
            )

            predicted_label = predict(
                create_model=create_model,
                # input_fn=lambda: imagenet_raw.test(data_dir, class_id, image_id,
                input_fn=lambda: imagenet_raw.train(
                    data_dir,
                    class_id,
                    image_id,
                    class_from_zero=True,
                    preprocessing_fn=alexnet_preprocess_image,
                ),
                model_dir=model_dir,
            )

            if predicted_label != class_id:
                return [{}] if per_node else {}

            adversarial_example = generate_adversarial_fn(
                label=class_id,
                create_model=create_model,
                # input_fn=lambda: imagenet_raw.test(data_dir, class_id, image_id, normed=False,
                input_fn=lambda: imagenet_raw.train(
                    data_dir,
                    class_id,
                    image_id,
                    normed=False,
                    class_from_zero=True,
                    preprocessing_fn=alexnet_preprocess_image,
                )
                .make_one_shot_iterator()
                .get_next()[0],
                attack_fn=attack_fn,
                model_dir=model_dir,
                **kwargs,
            )

            # adversarial_example = alexnet_imagenet_example(
            #     attack_name=attack_name,
            #     attack_fn=attack_fn,
            #     generate_adversarial_fn=generate_adversarial_fn,
            #     class_id=class_id,
            #     image_id=image_id,
            # ).load()

            if adversarial_example is None:
                return [{}] if per_node else {}

            adversarial_predicted_label = predict(
                create_model=create_model,
                input_fn=lambda: tf.data.Dataset.from_tensors(
                    imagenet.normalize_alexnet(adversarial_example)
                ),
                model_dir=model_dir,
            )

            if predicted_label == adversarial_predicted_label:
                return [{}] if per_node else {}

            trace = reconstruct_trace_from_tf(
                class_id=class_id,
                model_fn=model_fn,
                # input_fn=lambda: imagenet_raw.test(data_dir, class_id, image_id,
                input_fn=lambda: imagenet_raw.train(
                    data_dir,
                    class_id,
                    image_id,
                    class_from_zero=True,
                    preprocessing_fn=alexnet_preprocess_image,
                ),
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
            )[0]

            assert trace is not None

            label_top5 = trace.attrs[GraphAttrKey.PREDICT_TOP5]
            label_top5_value = trace.attrs[GraphAttrKey.PREDICT_TOP5_VALUE]

            adversarial_trace = reconstruct_trace_from_tf(
                model_fn=model_fn,
                input_fn=lambda: tf.data.Dataset.from_tensors(
                    imagenet.normalize_alexnet(adversarial_example)
                ),
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
            )[0]

            adversarial_label = adversarial_trace.attrs[GraphAttrKey.PREDICT]
            adversarial_label_top5 = adversarial_trace.attrs[GraphAttrKey.PREDICT_TOP5]
            adversarial_label_top5_value = adversarial_trace.attrs[
                GraphAttrKey.PREDICT_TOP5_VALUE
            ]

            assert class_id != adversarial_label

            def map_prefix(map: Dict[str, Any], prefix: str) -> Dict[str, Any]:
                return {f"{prefix}.{key}": value for key, value in map.items()}

            assert (
                class_id == label_top5[0]
                and adversarial_label == adversarial_label_top5[0]
            )
            trace = compact_trace(trace, graph, per_channel=per_channel)
            adversarial_trace = compact_trace(
                adversarial_trace, graph, per_channel=per_channel
            )

            class_traces = {}

            def get_class_trace(class_id: int) -> AttrMap:
                if class_id not in class_traces:
                    class_traces[class_id] = class_trace_fn(class_id).load()
                return class_traces[class_id]

            def get_overlap(base_class_id: int, class_ids: List[int], trace: AttrMap):
                class_trace = get_class_trace(base_class_id)
                return calc_all_overlap(
                    trace,
                    class_trace,
                    overlap_fn,
                    compact=True,
                    use_intersect_size=True,
                    key=TraceKey.WEIGHT,
                    # key=TraceKey.EDGE,
                )

            row = {}
            for k, base_class_id in zip(range(1, 6), label_top5):
                row = {
                    **row,
                    **map_prefix(
                        get_overlap(base_class_id, label_top5, trace),
                        f"original.top{k}",
                    ),
                }
            for k, base_class_id in zip(range(1, 6), adversarial_label_top5):
                row = {
                    **row,
                    **map_prefix(
                        get_overlap(
                            base_class_id, adversarial_label_top5, adversarial_trace
                        ),
                        f"adversarial.top{k}",
                    ),
                }

            if per_node:
                raise RuntimeError()
            else:
                row = {
                    "image_id": image_id,
                    "label": class_id,
                    "adversarial_label": adversarial_label,
                    "label_top5": label_top5,
                    "adversarial_label_top5": adversarial_label_top5,
                    "label_top5_value": label_top5_value,
                    "adversarial_label_top5_value": adversarial_label_top5_value,
                    **row,
                }
                print(row)
                return row

        traces = ray_iter(
            get_row,
            (
                (class_id, image_id)
                for image_id in range(0, 1)
                for class_id in range(0, 1000)
            ),
            chunksize=1,
            out_of_order=True,
            num_gpus=0,
        )
        if per_node:
            traces = list(itertools.chain.from_iterable(traces))
        traces = [trace for trace in traces if len(trace) != 0]
        return pd.DataFrame(traces)

    return CsvIOAction(path, init_fn=get_overlap_ratio)


def resnet_50_imagenet_overlap_ratio_top5_diff(
    attack_name: str,
    attack_fn,
    generate_adversarial_fn,
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    overlap_fn: Callable[[AttrMap, AttrMap, str], float],
    path: str,
    per_node: bool = False,
    per_channel: bool = False,
    **kwargs,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            mode.check(False)
            data_dir = IMAGENET_RAW_DIR
            model_dir = abspath("tf/resnet-50-v2/model")
            create_model = lambda: ResNet50()
            graph = ResNet50.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook, create_model=create_model, graph=graph
            )

            predicted_label = predict(
                create_model=create_model,
                input_fn=lambda: imagenet_raw.test(data_dir, class_id, image_id),
                model_dir=model_dir,
            )

            if predicted_label != class_id:
                return [{}] if per_node else {}

            # adversarial_example = generate_adversarial_fn(
            #     label=class_id,
            #     create_model=create_model,
            #     input_fn=lambda: imagenet_raw.test(data_dir, class_id, image_id, normed=False,
            #                                        class_from_zero=True, preprocessing_fn=alexnet_preprocess_image)
            #         .make_one_shot_iterator().get_next()[0],
            #     attack_fn=attack_fn,
            #     model_dir=model_dir,
            #     **kwargs,
            # )

            adversarial_example = resnet_50_imagenet_example(
                attack_name=attack_name,
                attack_fn=attack_fn,
                generate_adversarial_fn=generate_adversarial_fn,
                class_id=class_id,
                image_id=image_id,
            ).load()

            if adversarial_example is None:
                return [{}] if per_node else {}

            adversarial_predicted_label = predict(
                create_model=create_model,
                input_fn=lambda: tf.data.Dataset.from_tensors(
                    imagenet.normalize(adversarial_example)
                ),
                model_dir=model_dir,
            )

            if predicted_label == adversarial_predicted_label:
                return [{}] if per_node else {}

            trace = reconstruct_trace_from_tf(
                class_id=class_id,
                model_fn=model_fn,
                input_fn=lambda: imagenet_raw.test(data_dir, class_id, image_id),
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
            )[0]

            assert trace is not None

            label_top5 = trace.attrs[GraphAttrKey.PREDICT_TOP5]
            label_top5_value = trace.attrs[GraphAttrKey.PREDICT_TOP5_VALUE]

            adversarial_trace = reconstruct_trace_from_tf(
                model_fn=model_fn,
                input_fn=lambda: tf.data.Dataset.from_tensors(
                    imagenet.normalize(adversarial_example)
                ),
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
            )[0]

            adversarial_label = adversarial_trace.attrs[GraphAttrKey.PREDICT]
            adversarial_label_top5 = adversarial_trace.attrs[GraphAttrKey.PREDICT_TOP5]
            adversarial_label_top5_value = adversarial_trace.attrs[
                GraphAttrKey.PREDICT_TOP5_VALUE
            ]

            assert class_id != adversarial_label

            def map_prefix(map: Dict[str, Any], prefix: str) -> Dict[str, Any]:
                return {f"{prefix}.{key}": value for key, value in map.items()}

            assert (
                class_id == label_top5[0]
                and adversarial_label == adversarial_label_top5[0]
            )
            trace = compact_trace(trace, graph, per_channel=per_channel)
            adversarial_trace = compact_trace(
                adversarial_trace, graph, per_channel=per_channel
            )

            def get_overlap(base_class_id: int, class_ids: List[int], trace: AttrMap):
                rest_class_ids = class_ids.copy()
                rest_class_ids.remove(base_class_id)
                rest_class_trace = merge_compact_trace(
                    *[class_trace_fn(class_id).load() for class_id in rest_class_ids]
                )
                class_trace = merge_compact_trace_diff(
                    class_trace_fn(base_class_id).load(), rest_class_trace
                )
                trace = merge_compact_trace_diff(trace, rest_class_trace)
                return calc_all_overlap(
                    class_trace,
                    trace,
                    overlap_fn,
                    compact=True,
                    use_intersect_size=True,
                )

            row = {}
            for k, base_class_id in zip(range(1, 3), label_top5):
                row = {
                    **row,
                    **map_prefix(
                        get_overlap(base_class_id, label_top5, trace),
                        f"original.top{k}",
                    ),
                }
            for k, base_class_id in zip(range(1, 3), adversarial_label_top5):
                row = {
                    **row,
                    **map_prefix(
                        get_overlap(
                            base_class_id, adversarial_label_top5, adversarial_trace
                        ),
                        f"adversarial.top{k}",
                    ),
                }

            if per_node:
                raise RuntimeError()
            else:
                row = {
                    "image_id": image_id,
                    "label": class_id,
                    "adversarial_label": adversarial_label,
                    "label_top5": label_top5,
                    "adversarial_label_top5": adversarial_label_top5,
                    "label_top5_value": label_top5_value,
                    "adversarial_label_top5_value": adversarial_label_top5_value,
                    **row,
                }
                print(row)
                return row

        traces = ray_iter(
            get_row,
            (
                (class_id, image_id)
                for image_id in range(0, 1)
                for class_id in range(1, 1001)
            ),
            chunksize=1,
            out_of_order=True,
            num_gpus=0,
        )
        if per_node:
            traces = list(itertools.chain.from_iterable(traces))
        traces = [trace for trace in traces if len(trace) != 0]
        return pd.DataFrame(traces)

    return CsvIOAction(path, init_fn=get_overlap_ratio)


def lenet_mnist_overlap_ratio_top5_diff(
    attack_name: str,
    attack_fn,
    generate_adversarial_fn,
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    overlap_fn: Callable[[AttrMap, AttrMap, str], float],
    path: str,
    per_node: bool = False,
    per_channel: bool = False,
    **kwargs,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            mode.check(False)
            data_dir = abspath("/home/yxqiu/data/mnist/raw")
            model_dir = abspath("tf/lenet/model_early")
            create_model = lambda: LeNet(data_format="channels_first")
            graph = LeNet.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook, create_model=create_model, graph=graph
            )

            predicted_label = predict(
                create_model=create_model,
                input_fn=lambda: mnist.test(data_dir)
                .filter(
                    lambda image, label: tf.equal(
                        tf.convert_to_tensor(class_id, dtype=tf.int32), label
                    )
                )
                .skip(image_id)
                .take(1)
                .batch(1),
                model_dir=model_dir,
            )

            if predicted_label != class_id:
                return [{}] if per_node else {}

            # adversarial_example = generate_adversarial_fn(
            #     label=class_id,
            #     create_model=create_model,
            #     input_fn=lambda: mnist.test(data_dir, normed=False)
            #         .filter(lambda image, label:
            #                 tf.equal(
            #                     tf.convert_to_tensor(class_id, dtype=tf.int32),
            #                     label)).skip(image_id).take(1).batch(1)
            #         .make_one_shot_iterator().get_next()[0],
            #     attack_fn=attack_fn,
            #     model_dir=model_dir,
            #     **kwargs,
            # )

            adversarial_example = lenet_mnist_example(
                attack_name=attack_name,
                attack_fn=attack_fn,
                generate_adversarial_fn=generate_adversarial_fn,
                class_id=class_id,
                image_id=image_id,
            ).load()

            if adversarial_example is None:
                return [{}] if per_node else {}

            adversarial_predicted_label = predict(
                create_model=create_model,
                input_fn=lambda: tf.data.Dataset.from_tensors(
                    mnist.normalize(adversarial_example)
                ),
                model_dir=model_dir,
            )

            if predicted_label == adversarial_predicted_label:
                return [{}] if per_node else {}

            trace = reconstruct_trace_from_tf(
                class_id=class_id,
                model_fn=model_fn,
                input_fn=lambda: mnist.test(data_dir)
                .filter(
                    lambda image, label: tf.equal(
                        tf.convert_to_tensor(class_id, dtype=tf.int32), label
                    )
                )
                .skip(image_id)
                .take(1)
                .batch(1),
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
            )[0]

            if trace is None:
                return [{}] if per_node else {}

            label_top5 = trace.attrs[GraphAttrKey.PREDICT_TOP5]
            label_top5_value = trace.attrs[GraphAttrKey.PREDICT_TOP5_VALUE]

            adversarial_trace = reconstruct_trace_from_tf(
                model_fn=model_fn,
                input_fn=lambda: tf.data.Dataset.from_tensors(
                    mnist.normalize(adversarial_example)
                ),
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
            )[0]

            adversarial_label = adversarial_trace.attrs[GraphAttrKey.PREDICT]
            adversarial_label_top5 = adversarial_trace.attrs[GraphAttrKey.PREDICT_TOP5]
            adversarial_label_top5_value = adversarial_trace.attrs[
                GraphAttrKey.PREDICT_TOP5_VALUE
            ]

            if class_id == adversarial_label:
                return [{}] if per_node else {}

            def map_prefix(map: Dict[str, Any], prefix: str) -> Dict[str, Any]:
                return {f"{prefix}.{key}": value for key, value in map.items()}

            assert (
                class_id == label_top5[0]
                and adversarial_label == adversarial_label_top5[0]
            )
            trace = compact_trace(trace, graph, per_channel=per_channel)
            adversarial_trace = compact_trace(
                adversarial_trace, graph, per_channel=per_channel
            )

            def get_overlap(base_class_id: int, class_ids: List[int], trace: AttrMap):
                rest_class_ids = class_ids.copy()
                rest_class_ids.remove(base_class_id)
                rest_class_trace = merge_compact_trace(
                    *[class_trace_fn(class_id).load() for class_id in rest_class_ids]
                )
                class_trace = merge_compact_trace_diff(
                    class_trace_fn(base_class_id).load(), rest_class_trace
                )
                trace = merge_compact_trace_diff(trace, rest_class_trace)
                return calc_all_overlap(
                    class_trace,
                    trace,
                    overlap_fn,
                    compact=True,
                    use_intersect_size=True,
                )

            row = {}
            for k, base_class_id in zip(range(1, 3), label_top5):
                row = {
                    **row,
                    **map_prefix(
                        get_overlap(base_class_id, label_top5, trace),
                        f"original.top{k}",
                    ),
                }
            for k, base_class_id in zip(range(1, 3), adversarial_label_top5):
                row = {
                    **row,
                    **map_prefix(
                        get_overlap(
                            base_class_id, adversarial_label_top5, adversarial_trace
                        ),
                        f"adversarial.top{k}",
                    ),
                }

            if per_node:
                raise RuntimeError()
            else:
                row = {
                    "image_id": image_id,
                    "label": class_id,
                    "adversarial_label": adversarial_label,
                    "label_top5": label_top5,
                    "adversarial_label_top5": adversarial_label_top5,
                    "label_top5_value": label_top5_value,
                    "adversarial_label_top5_value": adversarial_label_top5_value,
                    **row,
                }
                print(row)
                return row

        traces = ray_iter(
            get_row,
            (
                (class_id, image_id)
                for image_id in range(0, 100)
                for class_id in range(0, 10)
            ),
            chunksize=1,
            out_of_order=True,
            num_gpus=0,
        )
        if per_node:
            traces = list(itertools.chain.from_iterable(traces))
        traces = [trace for trace in traces if len(trace) != 0]
        return pd.DataFrame(traces)

    return CsvIOAction(path, init_fn=get_overlap_ratio)


def alexnet_imagenet_overlap_ratio_top5(
    attack_fn,
    generate_adversarial_fn,
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    overlap_fn: Callable[[AttrMap, AttrMap, str], float],
    path: str,
    per_node: bool = False,
    per_channel: bool = False,
    **kwargs,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            mode.check(False)
            data_dir = IMAGENET_RAW_DIR
            model_dir = abspath("tf/alexnet/model_import")
            create_model = lambda: AlexNet()
            graph = AlexNet.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook, create_model=create_model, graph=graph
            )

            trace = reconstruct_trace_from_tf(
                class_id=class_id,
                model_fn=model_fn,
                input_fn=lambda: imagenet_raw.test(
                    data_dir,
                    class_id,
                    image_id,
                    class_from_zero=True,
                    preprocessing_fn=alexnet_preprocess_image,
                ),
                select_fn=select_fn,
                model_dir=model_dir,
                top_5=True,
                per_channel=per_channel,
            )[0]

            if trace is None:
                return {}

            label_top5 = trace.attrs[GraphAttrKey.PREDICT_TOP5]

            adversarial_example = generate_adversarial_fn(
                label=class_id,
                create_model=create_model,
                input_fn=lambda: imagenet_raw.test(
                    data_dir,
                    class_id,
                    image_id,
                    normed=False,
                    class_from_zero=True,
                    preprocessing_fn=alexnet_preprocess_image,
                )
                .make_one_shot_iterator()
                .get_next()[0],
                attack_fn=attack_fn,
                model_dir=model_dir,
                **kwargs,
            )

            if adversarial_example is None:
                return {}

            adversarial_trace = reconstruct_trace_from_tf(
                model_fn=model_fn,
                input_fn=lambda: tf.data.Dataset.from_tensors(
                    imagenet.normalize_alexnet(adversarial_example)
                ),
                select_fn=select_fn,
                model_dir=model_dir,
                top_5=True,
                per_channel=per_channel,
            )[0]

            adversarial_label = adversarial_trace.attrs[GraphAttrKey.PREDICT]
            adversarial_label_top5 = adversarial_trace.attrs[GraphAttrKey.PREDICT_TOP5]

            if adversarial_label not in label_top5:
                # if np.intersect1d(label_top5, adversarial_label_top5).size == 0:
                def map_prefix(map: Dict[str, Any], prefix: str) -> Dict[str, Any]:
                    return {f"{prefix}.{key}": value for key, value in map.items()}

                class_trace = merge_compact_trace(
                    *[class_trace_fn(label).load() for label in label_top5]
                )
                adversarial_class_trace = merge_compact_trace(
                    *[class_trace_fn(label).load() for label in adversarial_label_top5]
                )
                trace = compact_edge(trace, graph, per_channel=per_channel)
                adversarial_trace = compact_edge(
                    adversarial_trace, graph, per_channel=per_channel
                )
                if per_node:
                    rows = []
                    for node_name in class_trace.nodes:
                        row = {
                            "image_id": image_id,
                            "node_name": node_name,
                            "label": class_id,
                            "adversarial_label": adversarial_label,
                            **map_prefix(
                                calc_all_overlap(
                                    class_trace, trace, overlap_fn, node_name
                                ),
                                "original",
                            ),
                            **map_prefix(
                                calc_all_overlap(
                                    adversarial_class_trace,
                                    adversarial_trace,
                                    overlap_fn,
                                    node_name,
                                ),
                                "adversarial",
                            ),
                        }
                        if (
                            row[f"original.{TraceKey.WEIGHT}"] is not None
                            or row[f"original.{TraceKey.EDGE}"] is not None
                        ):
                            rows.append(row)
                    return rows
                else:
                    row = {
                        "image_id": image_id,
                        "label": class_id,
                        "adversarial_label": adversarial_label,
                        "label_top5": label_top5,
                        "adversarial_label_top5": adversarial_label_top5,
                        **map_prefix(
                            calc_all_overlap(class_trace, trace, overlap_fn), "original"
                        ),
                        **map_prefix(
                            calc_all_overlap(
                                adversarial_class_trace, adversarial_trace, overlap_fn
                            ),
                            "adversarial",
                        ),
                    }
                    print(row)
                    return row
            else:
                return [{}] if per_node else {}

        traces = ray_iter(
            get_row,
            (
                (class_id, image_id)
                for image_id in range(0, 1)
                for class_id in range(0, 1000)
            ),
            chunksize=1,
            out_of_order=True,
            num_gpus=0,
        )
        if per_node:
            traces = list(itertools.chain.from_iterable(traces))
        traces = [trace for trace in traces if len(trace) != 0]
        return pd.DataFrame(traces)

    return CsvIOAction(path, init_fn=get_overlap_ratio)


def alexnet_imagenet_overlap_ratio_error(
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    overlap_fn: Callable[[AttrMap, AttrMap, str], float],
    path: str,
    per_channel: bool = False,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            mode.check(False)
            data_dir = IMAGENET_RAW_DIR
            model_dir = abspath("tf/alexnet/model_import")
            create_model = lambda: AlexNet()
            graph = AlexNet.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook, create_model=create_model, graph=graph
            )

            trace = reconstruct_trace_from_tf(
                model_fn=model_fn,
                input_fn=lambda: imagenet_raw.test(
                    data_dir,
                    class_id,
                    image_id,
                    class_from_zero=True,
                    preprocessing_fn=alexnet_preprocess_image,
                ),
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
            )[0]

            if class_id == trace.attrs[GraphAttrKey.PREDICT]:
                return {}

            def map_prefix(map: Dict[str, Any], prefix: str) -> Dict[str, Any]:
                return {f"{prefix}.{key}": value for key, value in map.items()}

            class_trace = class_trace_fn(class_id).load()
            trace = compact_edge(trace, graph, per_channel=per_channel)
            row = {
                "image_id": image_id,
                "label": class_id,
                **map_prefix(
                    calc_all_overlap(class_trace, trace, overlap_fn), "original"
                ),
            }
            print(row)
            return row

        traces = ray_iter(
            get_row,
            (
                (class_id, image_id)
                for image_id in range(0, 1)
                for class_id in range(0, 1000)
            ),
            chunksize=1,
            out_of_order=True,
            num_gpus=0,
        )
        traces = [trace for trace in traces if len(trace) != 0]
        return pd.DataFrame(traces)

    return CsvIOAction(path, init_fn=get_overlap_ratio)


def alexnet_imagenet_overlap_ratio_rand(
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    overlap_fn: Callable[[AttrMap, AttrMap, str], float],
    path: str,
    per_channel: bool = False,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            mode.check(False)
            model_dir = abspath("tf/alexnet/model_import")
            create_model = lambda: AlexNet()
            graph = AlexNet.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook, create_model=create_model, graph=graph
            )

            example = np.random.random_sample((1, 224, 224, 3)).astype(np.float32)
            trace = reconstruct_trace_from_tf(
                model_fn=model_fn,
                input_fn=lambda: tf.data.Dataset.from_tensors(
                    imagenet.normalize_alexnet(example)
                ),
                select_fn=select_fn,
                model_dir=model_dir,
                per_channel=per_channel,
            )[0]

            def map_prefix(map: Dict[str, Any], prefix: str) -> Dict[str, Any]:
                return {f"{prefix}.{key}": value for key, value in map.items()}

            class_trace = class_trace_fn(class_id).load()
            trace = compact_edge(trace, graph, per_channel=per_channel)
            row = {
                "image_id": image_id,
                "label": class_id,
                **map_prefix(
                    calc_all_overlap(class_trace, trace, overlap_fn), "original"
                ),
            }
            print(row)
            return row

        traces = ray_iter(
            get_row,
            (
                (class_id, image_id)
                for image_id in range(0, 1)
                for class_id in range(0, 1000)
            ),
            chunksize=1,
            out_of_order=True,
            num_gpus=0,
        )
        traces = [trace for trace in traces if len(trace) != 0]
        return pd.DataFrame(traces)

    return CsvIOAction(path, init_fn=get_overlap_ratio)


def alexnet_imagenet_overlap_ratio_top5_rand(
    class_trace_fn: Callable[[int], IOAction[AttrMap]],
    select_fn: Callable[[np.ndarray], np.ndarray],
    overlap_fn: Callable[[AttrMap, AttrMap, str], float],
    path: str,
    per_channel: bool = False,
):
    def get_overlap_ratio() -> pd.DataFrame:
        def get_row(class_id: int, image_id: int) -> Dict[str, Any]:
            mode.check(False)
            model_dir = abspath("tf/alexnet/model_import")
            create_model = lambda: AlexNet()
            graph = AlexNet.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook, create_model=create_model, graph=graph
            )

            example = np.random.random_sample((1, 224, 224, 3)).astype(np.float32)
            trace = reconstruct_trace_from_tf(
                model_fn=model_fn,
                input_fn=lambda: tf.data.Dataset.from_tensors(
                    imagenet.normalize_alexnet(example)
                ),
                select_fn=select_fn,
                model_dir=model_dir,
                top_5=True,
                per_channel=per_channel,
            )[0]

            def map_prefix(map: Dict[str, Any], prefix: str) -> Dict[str, Any]:
                return {f"{prefix}.{key}": value for key, value in map.items()}

            class_trace = merge_compact_trace(
                *[
                    class_trace_fn(label).load()
                    for label in trace.attrs[GraphAttrKey.PREDICT_TOP5]
                ]
            )
            trace = compact_edge(trace, graph, per_channel=per_channel)
            row = {
                "image_id": image_id,
                "label": class_id,
                **map_prefix(
                    calc_all_overlap(class_trace, trace, overlap_fn), "original"
                ),
            }
            print(row)
            return row

        traces = ray_iter(
            get_row,
            (
                (class_id, image_id)
                for image_id in range(0, 1)
                for class_id in range(0, 1000)
            ),
            chunksize=1,
            out_of_order=True,
            num_gpus=0,
        )
        traces = [trace for trace in traces if len(trace) != 0]
        return pd.DataFrame(traces)

    return CsvIOAction(path, init_fn=get_overlap_ratio)



def get_overlay_summary_top1(
    overlap_ratios: pd.DataFrame, trace_key: str, threshold=1
) -> Dict[str, int]:
    condition_positive = len(overlap_ratios)
    if condition_positive == 0:
        return {}
    original_key = f"original.top1.{trace_key}"
    false_positive = np.count_nonzero(overlap_ratios[original_key] < threshold)
    adversarial_key = f"adversarial.top1.{trace_key}"
    true_positive = np.count_nonzero(overlap_ratios[adversarial_key] < threshold)
    predicted_condition_positive = true_positive + false_positive
    recall = (true_positive / condition_positive) if condition_positive != 0 else 0
    precision = (
        (true_positive / predicted_condition_positive)
        if predicted_condition_positive != 0
        else 0
    )
    f1 = (2 / ((1 / recall) + (1 / precision))) if recall != 0 and precision != 0 else 0
    return dict(
        condition_positive=condition_positive,
        # predicted_condition_positive=predicted_condition_positive,
        original_is_higher=np.count_nonzero(
            (overlap_ratios[original_key] - overlap_ratios[adversarial_key]) > 0
        ),
        # adversarial_is_higher=np.count_nonzero(
        #     (overlap_ratios[adversarial_key] - overlap_ratios[original_key]) > 0),
        true_positive=true_positive,
        false_positive=false_positive,
        recall=recall,
        precision=precision,
        f1=f1,
    )


def get_overlay_summary_compare(
    overlap_ratios: pd.DataFrame, trace_key: str, threshold=0
) -> Dict[str, int]:
    condition_positive = len(overlap_ratios)
    if condition_positive == 0:
        return {}

    def confidence_score(kind: str, key: str) -> np.ndarray:
        current_logits = logits if kind == "original" else adversarial_logits
        return overlap_ratios[f"{kind}.top1.{key}"] * current_logits[:, 0] - np.max(
            [
                overlap_ratios[f"{kind}.top{k}.{key}"] * current_logits[:, k - 1]
                for k in range(2, 3)
            ],
            axis=0,
        )

    logits = np.array(
        list(
            map(
                lambda line: list(map(lambda x: float(x), line[1:-1].split(","))),
                overlap_ratios["label_top5_value"],
            )
        )
    )
    adversarial_logits = np.array(
        list(
            map(
                lambda line: list(map(lambda x: float(x), line[1:-1].split(","))),
                overlap_ratios["adversarial_label_top5_value"],
            )
        )
    )

    false_positive = condition_positive - np.count_nonzero(
        confidence_score("original", trace_key) >= threshold
    )
    true_positive = condition_positive - np.count_nonzero(
        confidence_score("adversarial", trace_key) >= threshold
    )
    # false_positive = (condition_positive -
    #                   np.count_nonzero(reduce(np.logical_and,
    #                                           [(overlap_ratios[f"original.top1.{trace_key}"] -
    #                                             overlap_ratios[f"original.top{k}.{trace_key}"]) >= threshold
    #                                            for k in range(2, 3)])))
    # true_positive = (condition_positive -
    #                  np.count_nonzero(reduce(np.logical_and,
    #                                          [(overlap_ratios[f"adversarial.top1.{trace_key}"] -
    #                                            overlap_ratios[f"adversarial.top{k}.{trace_key}"]) >= threshold
    #                                           for k in range(2, 3)])))
    predicted_condition_positive = true_positive + false_positive
    recall = (true_positive / condition_positive) if condition_positive != 0 else 0
    precision = (
        (true_positive / predicted_condition_positive)
        if predicted_condition_positive != 0
        else 0
    )
    f1 = (2 / ((1 / recall) + (1 / precision))) if recall != 0 and precision != 0 else 0
    return dict(
        threshold=threshold,
        condition_positive=condition_positive,
        true_positive=true_positive,
        false_positive=false_positive,
        recall=recall,
        precision=precision,
        f1=f1,
        diff=true_positive - false_positive,
    )


def get_overlay_summary_compare_detail(
    path: str, overlap_ratios: pd.DataFrame, from_zero: bool = True
) -> CsvIOAction:
    def init_fn() -> pd.DataFrame:
        trace_key = TraceKey.EDGE

        def confidence_score(kind: str, key: str) -> np.ndarray:
            current_logits = logits if kind == "original" else adversarial_logits
            return overlap_ratios[f"{kind}.top1.{key}"] * current_logits[0] - np.max(
                [
                    overlap_ratios[f"{kind}.top{k}.{key}"] * current_logits[k - 1]
                    for k in range(2, 3)
                ],
                axis=0,
            )
            # return overlap_ratios[f"{kind}.top1.{key}"] - overlap_ratios[f"{kind}.top2.{key}"]

        def top1(kind: str, key: str) -> np.ndarray:
            return overlap_ratios[f"{kind}.top1.{key}"]

        logits = np.array(
            list(
                map(
                    lambda line: list(map(lambda x: float(x), line[1:-1].split(","))),
                    overlap_ratios["label_top5_value"],
                )
            )
        ).transpose()
        adversarial_logits = np.array(
            list(
                map(
                    lambda line: list(map(lambda x: float(x), line[1:-1].split(","))),
                    overlap_ratios["adversarial_label_top5_value"],
                )
            )
        ).transpose()
        logit_confidence_score = logits[0] - np.max(logits[1:2], axis=1)
        adversarial_logit_confidence_score = adversarial_logits[0] - np.max(
            adversarial_logits[1:2], axis=1
        )

        # label_top5 = np.array(list(map(lambda line: list(map(lambda x: int(x), line[1:-1].split(","))),
        #                                overlap_ratios["label_top5"])))
        # logit_distance = []
        # logit_distance_mask = []
        # for index in range(len(overlap_ratios)):
        #     adversarial_label = overlap_ratios["adversarial_label"][index]
        #     if adversarial_label in label_top5[index]:
        #         logit_distance_mask.append(True)
        #         logit_distance.append(logits[index][0] -
        #                               logits[index][np.where(label_top5[index] == adversarial_label)][0])
        #     else:
        #         logit_distance_mask.append(False)
        #
        # logit_distance_mask = np.array(logit_distance_mask)
        # logit_distance = np.array(logit_distance)

        label_top5 = np.array(
            list(
                map(
                    lambda line: list(map(lambda x: int(x), line[1:-1].split(","))),
                    overlap_ratios["label_top5"],
                )
            )
        ).transpose()
        # logit_distance_mask = []
        # for index in range(len(overlap_ratios)):
        #     adversarial_label = overlap_ratios["adversarial_label"][index]
        #     if adversarial_label in label_top5[index][:2]:
        #         logit_distance_mask.append(True)
        #     else:
        #         logit_distance_mask.append(False)
        #
        # logit_distance_mask = np.array(logit_distance_mask)

        if from_zero:
            labels = overlap_ratios["label"]
            adversarial_labels = overlap_ratios["adversarial_label"].values
        else:
            labels = overlap_ratios["label"] - 1
            adversarial_labels = overlap_ratios["adversarial_label"].values - 1
            label_top5 = label_top5 - 1

        class_tree = imagenet_class_tree().load()

        distance = np.array(
            [
                class_tree.distance_of(
                    class_tree.imagenet_labels[label],
                    class_tree.imagenet_labels[adversarial_label],
                )
                for label, adversarial_label in zip(labels, adversarial_labels)
            ]
        )

        distance_rank_2 = np.array(
            [
                class_tree.distance_of(
                    class_tree.imagenet_labels[label],
                    class_tree.imagenet_labels[label_rank_2],
                )
                for label, label_rank_2 in zip(label_top5[0], label_top5[1])
            ]
        )
        distance_rank_3 = np.array(
            [
                class_tree.distance_of(
                    class_tree.imagenet_labels[label],
                    class_tree.imagenet_labels[label_rank_3],
                )
                for label, label_rank_3 in zip(label_top5[0], label_top5[2])
            ]
        )
        distance_rank_4 = np.array(
            [
                class_tree.distance_of(
                    class_tree.imagenet_labels[label],
                    class_tree.imagenet_labels[label_rank_4],
                )
                for label, label_rank_4 in zip(label_top5[0], label_top5[3])
            ]
        )
        distance_rank_5 = np.array(
            [
                class_tree.distance_of(
                    class_tree.imagenet_labels[label],
                    class_tree.imagenet_labels[label_rank_5],
                )
                for label, label_rank_5 in zip(label_top5[0], label_top5[4])
            ]
        )
        distance_diff_5 = distance_rank_5 - distance_rank_2
        distance_diff_4 = distance_rank_4 - distance_rank_2
        distance_diff_3 = distance_rank_3 - distance_rank_2

        logits_distance_rank_2 = logits[0] - logits[1]
        logits_distance_rank_5 = logits[0] - logits[4]
        logits_distance_diff = logits_distance_rank_5 - logits_distance_rank_2

        # return pd.DataFrame(dict(
        #     original_overlap=confidence_score("original", trace_key)[logit_distance_mask],
        #     adversarial_overlap=confidence_score("adversarial", trace_key)[logit_distance_mask],
        #     original_size=confidence_score("original", trace_key + "_size")[logit_distance_mask],
        #     adversarial_size=confidence_score("adversarial", trace_key + "_size")[logit_distance_mask],
        #     original_top1=top1("original", trace_key)[logit_distance_mask],
        #     adversarial_top1=top1("adversarial", trace_key)[logit_distance_mask],
        #     # distance=distance[logit_distance_mask],
        #     logit_confidence_score=logit_confidence_score[logit_distance_mask],
        #     adversarial_logit_confidence_score=adversarial_logit_confidence_score[logit_distance_mask],
        #     # logit_distance=logit_distance,
        # ))
        return pd.DataFrame(
            dict(
                original_overlap=confidence_score("original", trace_key),
                adversarial_overlap=confidence_score("adversarial", trace_key),
                original_size=confidence_score("original", trace_key + "_size"),
                adversarial_size=confidence_score("adversarial", trace_key + "_size"),
                original_top1=top1("original", trace_key),
                adversarial_top1=top1("adversarial", trace_key),
                distance=distance,
                distance_rank_2=distance_rank_2,
                distance_rank_5=distance_rank_5,
                logits_distance_rank_2=logits_distance_rank_2,
                logits_distance_rank_5=logits_distance_rank_5,
                distance_diff_3=distance_diff_3,
                distance_diff_4=distance_diff_4,
                distance_diff_5=distance_diff_5,
                logits_distance_diff=logits_distance_diff,
                logit_confidence_score=logit_confidence_score,
                adversarial_logit_confidence_score=adversarial_logit_confidence_score,
            )
        )

    return CsvIOAction(path, init_fn=init_fn)


def get_overlay_summary_compare_filter(
    overlap_ratios: pd.DataFrame, trace_key: str, threshold=0
) -> Dict[str, int]:
    overlap_ratios = overlap_ratios[
        reduce(
            np.logical_and,
            [
                (
                    overlap_ratios[f"original.top1.{trace_key}"]
                    - overlap_ratios[f"original.top{k}.{trace_key}"]
                )
                >= 0
                for k in range(2, 6)
            ],
        )
    ]
    condition_positive = len(overlap_ratios)
    if condition_positive == 0:
        return {}
    false_positive = condition_positive - np.count_nonzero(
        reduce(
            np.logical_and,
            [
                (
                    overlap_ratios[f"original.top1.{trace_key}"]
                    - overlap_ratios[f"original.top{k}.{trace_key}"]
                )
                >= threshold
                for k in range(2, 6)
            ],
        )
    )
    true_positive = condition_positive - np.count_nonzero(
        reduce(
            np.logical_and,
            [
                (
                    overlap_ratios[f"adversarial.top1.{trace_key}"]
                    - overlap_ratios[f"adversarial.top{k}.{trace_key}"]
                )
                >= threshold
                for k in range(2, 6)
            ],
        )
    )
    predicted_condition_positive = true_positive + false_positive
    recall = (true_positive / condition_positive) if condition_positive != 0 else 0
    precision = (
        (true_positive / predicted_condition_positive)
        if predicted_condition_positive != 0
        else 0
    )
    f1 = (2 / ((1 / recall) + (1 / precision))) if recall != 0 and precision != 0 else 0
    return dict(
        condition_positive=condition_positive,
        true_positive=true_positive,
        false_positive=false_positive,
        recall=recall,
        precision=precision,
        f1=f1,
        diff=true_positive - false_positive,
    )


def get_overlay_summary_one_side(
    overlap_ratios: pd.DataFrame, trace_key: str, threshold=1
) -> Dict[str, int]:
    condition_positive = len(overlap_ratios)
    if condition_positive == 0:
        return {}
    original_key = f"original.{trace_key}"
    true_positive = np.count_nonzero(overlap_ratios[original_key] < threshold)
    recall = (true_positive / condition_positive) if condition_positive != 0 else 0
    return dict(
        condition_positive=condition_positive,
        true_positive=true_positive,
        recall=recall,
    )


def benchmark_trace():
    class_id = 1
    image_id = 0
    threshold = 0.5
    per_channel = False
    # model_config = ALEXNET.with_model_dir("tf/alexnet/model_import")
    # model_config = RESNET_50
    model_config = VGG_16
    mode.check(False)
    data_dir = IMAGENET_RAW_DIR
    model_dir = abspath(model_config.model_dir)
    create_model = lambda: model_config.network_class()
    graph = model_config.network_class.graph().load()
    model_fn = partial(model_fn_with_fetch_hook, create_model=create_model, graph=graph)
    input_fn = lambda: imagenet_raw.test(
        data_dir,
        class_id,
        image_id,
        class_from_zero=model_config.class_from_zero,
        preprocessing_fn=model_config.preprocessing_fn,
    )
    # predicted_label = predict(
    #     create_model=create_model,
    #     input_fn=input_fn,
    #     model_dir=model_dir,
    # )
    #
    # if predicted_label != class_id:
    #     return None

    conv_op_count = 0

    def stop_hook(op):
        nonlocal conv_op_count
        if isinstance(op, Conv2dOp):
            conv_op_count += 1
        if conv_op_count >= 2:
            return True
        else:
            return False

    reconstruct_trace_from_tf(
        class_id=class_id,
        model_fn=model_fn,
        input_fn=input_fn,
        select_fn=lambda input: arg_approx(input, threshold),
        model_dir=model_dir,
        per_channel=per_channel,
        stop_hook=stop_hook,
    )


if __name__ == "__main__":
    # with tf.Graph().as_default():
    #     input_dataset = (mnist.test(abspath("/home/yxqiu/data/mnist/raw"))
    #                      .filter(lambda image, label:
    #                              tf.equal(
    #                                  tf.convert_to_tensor(5, dtype=tf.int32),
    #                                  label)).skip(891).make_one_shot_iterator().get_next())
    #     with tf.Session() as sess:
    #         while True:
    #             try:
    #                 result = sess.run(input_dataset)[1]
    #                 print(result)
    #             except tf.errors.OutOfRangeError:
    #                 break

    # print("check")
    # for attack_name in [
    #     "DeepFool",
    #     "FGSM",
    #     "BIM",
    #     "JSMA",
    #     # "DeepFool_full",
    #     # "CWL2",
    # ]:
    #     try:
    #         for class_id in range(1, 1001):
    #             adversarial_example = resnet_50_imagenet_example(
    #                 # adversarial_example = alexnet_imagenet_example(
    #                 attack_name=attack_name,
    #                 attack_fn=None,
    #                 generate_adversarial_fn=None,
    #                 class_id=class_id,
    #                 image_id=0,
    #             ).load()
    #     except:
    #         print(f"attack {attack_name} class {class_id}")

    benchmark_trace()
