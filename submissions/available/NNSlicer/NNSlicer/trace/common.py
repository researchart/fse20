import csv
import itertools
import math
import os
import traceback
import zlib
from functools import partial, reduce
from typing import Any, Callable, Dict, Iterable, List, Optional, Tuple, Union
from pdb import set_trace as st
import time
import logging

import numpy as np
import pandas as pd
import tensorflow as tf
from tensorflow.python.training.session_run_hook import SessionRunHook
from tensorflow.python import debug as tf_debug

# from nninst import AttrMap, GraphAttrKey, Operation, mode
from nninst_graph import AttrMap, GraphAttrKey, Operation
import nninst_mode as mode
from dataset.config import DataConfig
from tf_graph import (
    assign_variables,
    build_graph,
    get_variables_from_tf,
    model_fn_with_fetch_hook,
)

# from nninst.backend.tensorflow.model.config import ModelConfig
# from nninst.backend.tensorflow.utils import new_session_config
from model.config import ModelConfig
from tf_utils import new_session_config

from nninst_channel_trace import get_channel_trace
from nninst_statistics import (
    calc_density_compact,
    calc_iou,
    calc_iou_compact,
    calc_iou_compact_per_layer,
    calc_iou_per_layer,
    calc_trace_size,
    self_similarity_matrix_ray,
)
from nninst_trace import (
    TraceKey,
    compact_trace,
    density_name,
    get_trace,
    get_unstructured_trace,
    merge_compact_trace,
    merge_compact_trace_diff,
    merge_compact_trace_intersect,
    merge_trace,
    reconstruct_stat,
    reconstruct_static_trace,
)
from nninst_utils import filter_not_null, grouper
from nninst_utils.fs import CsvIOAction, IOAction, abspath, ensure_dir
from nninst_utils.numpy import arg_approx, arg_sorted_topk
from nninst_utils.ray import ray_iter, ray_map, ray_map_reduce

os.environ["TF_CPP_MIN_LOG_LEVEL"] = "1"


__all__ = [
    "reconstruct_trace_from_tf",
    "reconstruct_class_trace_from_tf",
    "reconstruct_static_trace_from_tf",
    "self_similarity",
    "check_class_traces",
    "class_trace",
    "class_trace_compact",
    "class_trace_growth",
    "full_trace",
    "full_intersect_trace",
    "predict",
    "get_predicted_value",
    "get_rank",
    "class_unique_trace_compact",
    "save_merged_traces",
    "merged_class_trace_compact",
    "save_class_traces",
    "save_class_traces_low_latency",
    "save_full_trace_growth",
    "class_trace_size",
]


def save_class_traces(
    class_trace_fn: Callable[..., IOAction[AttrMap]],
    class_ids: Iterable[int],
    threshold: float,
    label: str = None,
    example_num: int = 0,
    example_upperbound: int = 0,
    merge_fn=merge_trace,
    batch_size: int = 16,
    parallel: int = 1,
    variant: str = None,
    cache: bool = True,
    select_seed_fn: Callable[[np.ndarray], np.ndarray] = None,
    entry_points: List[int] = None,
    is_unstructured: bool = False,
    density: float = None,
    chunksize: int = 1,
    num_gpus:float = 1,
    transforms_list = [None],
    trace_dir: str = "result"
):
    def class_trace(class_id: int) -> Union[int, Tuple[int, str]]:
        try:
            # time.sleep(5)
            class_id = int(class_id)
            # print(class_id)
            class_trace_fn(
                class_id,
                threshold=threshold,
                batch_size=batch_size,
                label=label,
                example_num=example_num,
                example_upperbound=example_upperbound,
                cache=cache,
                compress=True,
                merge_fn=merge_fn,
                parallel=parallel,
                variant=variant,
                select_seed_fn=select_seed_fn,
                entry_points=entry_points,
                is_unstructured=is_unstructured,
                density=density,
                transforms_list = transforms_list,
                trace_dir = trace_dir
            ).save()
            return class_id
        except Exception:
            return class_id, traceback.format_exc()

    # class_trace(class_ids)
    # st()
    results = ray_iter(
        class_trace,
        class_ids,
        chunksize=chunksize,
        num_gpus=num_gpus,
        out_of_order=True,
        huge_task=True,
    )
    for result in results:
        if not isinstance(result, int):
            class_id, tb = result
            print(f"## raise exception from class {class_id}:")
            print(tb)
        else:
            print(f"finish class {result}")
    print("finish")

def class_trace(
    name: str, model_config: ModelConfig, data_config: DataConfig, use_raw: bool = False
):
    def class_trace_fn(
        class_id: int,
        threshold: float,
        trace_fn=get_trace,
        trace_type: str = None,
        trace_parameter: str = None,
        label: str = None,
        example_num: int = 0,
        example_upperbound: int = 0,
        merge_fn=merge_trace,
        cache: bool = True,
        compress: bool = True,
        batch_size: int = 16,
        parallel: int = 1,
        variant: str = None,
        transforms_list = [None],
        trace_dir = "result",
        **kwargs,
    ) -> IOAction[AttrMap]:

        def get_class_trace() -> AttrMap:

            error_detail = ""

            try:
                mode.check(False)
                # mode.check(True)
                data_dir = abspath(data_config.data_dir)
                model_dir = abspath(
                    model_config.model_dir
                    if label is None
                    else f"{model_config.model_dir}_{label}"
                )

                graph = model_config.network_class.graph().load()
                model_fn = partial(
                    model_fn_with_fetch_hook,
                    create_model=lambda: model_config.network_class(),
                    graph=graph,
                )
                new_trace_fn = partial(
                    trace_fn, select_fn=lambda input: arg_approx(input, threshold)
                )

                assert example_upperbound != 0
                class_trace = None
                for transforms in transforms_list:
                    example_count = 0
                    example_index = 0
                    while example_index < example_upperbound:
                        error_detail = f"example_count: {example_count}, example_index: {example_index}"
                        if use_raw:
                            take_num = 1
                            try:
                                next_trace = reconstruct_class_trace_from_tf_v2(
                                    class_id,
                                    model_fn=model_fn,
                                    input_fn=lambda: data_config.dataset_fn(
                                        data_dir, class_id, example_index
                                    ),
                                    trace_fn=new_trace_fn,
                                    model_dir=model_dir,
                                    parallel=parallel,
                                    merge_fn=merge_fn,
                                )
                            except IndexError:
                                break
                        else:
                            rest_example_num = example_num - example_count
                            rest_example_index = example_upperbound - example_index
                            take_num = min(rest_example_num, rest_example_index)

                            next_trace = reconstruct_class_trace_from_tf_v2(
                                class_id,
                                model_fn=model_fn,
                                input_fn=lambda: data_config.dataset_fn(
                                    data_dir,
                                    batch_size,
                                    transform_fn=lambda dataset: dataset.filter(
                                        lambda image, label: tf.equal(
                                            tf.convert_to_tensor(
                                                class_id, dtype=tf.int32
                                            ),
                                            label,
                                        )
                                    )
                                    .skip(example_index)
                                    .take(take_num),
                                    transforms = transforms,
                                ),
                                trace_fn=new_trace_fn,
                                model_dir=model_dir,
                                parallel=parallel,
                                merge_fn=merge_fn,
                            )

                        example_index += take_num
                        if next_trace is not None:
                            example_count += next_trace.attrs[TraceKey.COUNT]
                        class_trace = merge_fn(class_trace, next_trace)
                        # print(calc_density(class_trace, TraceKey.EDGE))
                        if example_count >= example_num:
                            break
                return class_trace
            except Exception as cause:
                raise RuntimeError(
                    f"error when handling class {class_id}, detail: ({error_detail})"
                ) from cause

        trace_path = trace_store_path_v2(
            name=name,
            threshold=threshold,
            label=label,
            variant=variant,
            trace_type=trace_type,
            trace_parameter=trace_parameter,
        )
        path = f"{trace_dir}/{trace_path}/{class_id}.pkl"
        ensure_dir(path)
        return IOAction(path, init_fn=get_class_trace, cache=cache, compress=compress)
    return class_trace_fn


def full_trace(
    name: str,
    class_trace_fn: Callable[..., IOAction[AttrMap]],
    compress: bool = True,
    per_channel: bool = False,
):
    def full_trace_fn(
        threshold: float,
        label: str = None,
        class_ids: Iterable[int] = None,
        is_compact: bool = True,
        variant: str = None,
        chunksize: int = 1,
        num_gpus:float = 1
    ) -> IOAction[AttrMap]:
        def get_trace() -> AttrMap:
            def get_class_trace(class_id):
                if is_compact:
                    trace_label = "compact" if label is None else label + "_compact"
                else:
                    trace_label = label
                try:
                    return class_trace_fn(
                        class_id,
                        threshold=threshold,
                        label=trace_label,
                        compress=compress,
                        variant=variant,
                    ).load()
                except Exception as cause:
                    raise RuntimeError(f"raise from class {class_id}") from cause

            def merge(*class_ids):
                # class_ids is (1,2,3) or (9,)
                print((class_ids))
                return reduce(
                    merge_compact_trace,
                    (get_class_trace(class_id) for class_id in class_ids),
                )

            return reduce(
                merge_compact_trace,
                ray_iter(
                    merge,
                    grouper(int(math.sqrt(len(class_ids))), class_ids),
                    out_of_order=True,
                    huge_task=True,
                    chunksize = chunksize,
                    num_gpus = num_gpus
                ),
            )

        threshold_name = "{0:.3f}".format(threshold)
        if label is not None:
            trace_name = f"{name}_{label}"
        else:
            trace_name = name
        if variant is not None:
            trace_name = f"{trace_name}_{variant}"
        if per_channel:
            trace_type = "channel_trace"
        else:
            trace_type = "trace"
        trace_path = trace_store_path_v2(
            name=name,
            threshold=threshold,
            label=label,
            variant=variant,
            trace_type=trace_type,
        )

        # path = f"result/{trace_type}/{trace_name}/approx_{threshold_name}/trace.pkl"
        dir = f"result/{trace_path}"
        ensure_dir(dir)
        path = f"{dir}/trace.pkl"
        return IOAction(path, init_fn=get_trace, compress=True, cache=True)

    return full_trace_fn

def reconstruct_class_trace_from_tf_v2(
    class_id: int,
    model_fn,
    input_fn,
    trace_fn,
    model_dir: str,
    data_format: str = "channels_first",
    parallel: int = 1,
    merge_fn=merge_trace,
) -> AttrMap:
    model_dir = abspath(model_dir)

    trace = [None]
    image_count = [0]

    # tr = tracker.SummaryTracker()
    ckpt_dir = f"{model_dir}/ckpts"
    def merge_output_fn(out, graph):
        predict = np.argmax(graph.tensor(graph.outputs[0]).value)
        if predict == class_id:
            try:
                new_trace = trace_fn(graph=graph)
                # tr.print_diff()
                if out[0] is None:
                    out[0] = new_trace
                else:
                    out[0] = merge_fn(out[0], new_trace)
            except Exception as cause:
                raise RuntimeError(
                    f"error when handling image {image_count[0]}"
                ) from cause
        image_count[0] += 1

    model_function = partial(model_fn, out=trace, merge_fn=merge_output_fn)

    if data_format is None:
        data_format = (
            "channels_first" if tf.test.is_built_with_cuda() else "channels_last"
        )
    estimator_config = tf.estimator.RunConfig(
        session_config=new_session_config(parallel=parallel)
    )
    if not os.path.exists(model_dir):
        raise RuntimeError(f"model directory {model_dir} is not existed")
    classifier = tf.estimator.Estimator(
        model_fn=model_function,
        model_dir=ckpt_dir,
        warm_start_from=ckpt_dir,
        params={"data_format": data_format},
        config=estimator_config,
    )

    list(classifier.predict(input_fn=input_fn))

    return trace[0]

def reconstruct_trace_from_tf_to_trace(
    graph,
    select_fn,
    class_id = None,
    debug = False,
    top_5 = False,
    topk = 5,
    is_unstructured = False,
    density = None,
    select_seed_fn = None,
    per_channel = False,
    entry_points = None,
    stop_hook = None,
    class_trace = None,
):
    logits = graph.tensor(graph.outputs[0]).value
    predict = np.argmax(logits)
    predict_top5 = list(arg_sorted_topk(logits, topk))
    if predict != predict_top5[0]:
        if predict in predict_top5:
            predict_top5.remove(predict)
            predict_top5 = [predict] + predict_top5
        else:
            predict_top5 = [predict] + predict_top5[:-1]
    predict_top5_value = list(logits[predict_top5])
    if (
        (class_id is None)
        or (top_5 and class_id in predict_top5)
        or (not top_5 and predict == class_id)
    ):
        if is_unstructured:
            trace = get_unstructured_trace(
                graph, density=density, select_fn=select_fn, debug=debug
            )
        else:
            trace = (get_channel_trace if per_channel else get_trace)(
                graph,
                select_fn=select_fn,
                select_seed_fn=select_seed_fn,
                entry_points=entry_points,
                debug=debug,
                stop_hook=stop_hook,
                class_trace=class_trace,
            )
        trace.attrs[GraphAttrKey.PREDICT] = predict
        trace.attrs[GraphAttrKey.PREDICT_TOP5] = predict_top5
        trace.attrs[GraphAttrKey.PREDICT_TOP5_VALUE] = predict_top5_value
        return trace
        # return None
    else:
        return None
        
        
def reconstruct_trace_from_tf(
    model_fn,
    input_fn,
    select_fn: Callable[[np.ndarray], np.ndarray],
    model_dir: str,
    class_id: int = None,
    data_format: str = "channels_first",
    debug: bool = False,
    parallel: int = 1,
    top_5: bool = False,
    topk: int = 5,
    per_channel: bool = False,
    select_seed_fn: Callable[[np.ndarray], np.ndarray] = None,
    entry_points: List[int] = None,
    stop_hook: Callable[[Operation], bool] = None,
    is_unstructured: bool = False,
    density: float = None,
    class_trace=None,
) -> List[AttrMap]:
    model_dir = abspath(model_dir)

    graphs = []

    to_trace = partial(
        reconstruct_trace_from_tf_to_trace,
        select_fn=select_fn,
        class_id=class_id,
        debug=debug,
        top_5=top_5,
        topk=topk,
        is_unstructured=is_unstructured,
        density=density,
        select_seed_fn=select_seed_fn,
        per_channel=per_channel,
        entry_points=entry_points,
        stop_hook=stop_hook,
        class_trace=class_trace,
    )

    if debug:
        def merge_fn(out, graph):
            return out.append((to_trace(graph), graph))
    else:
        def merge_fn(out, graph):
            return out.append(to_trace(graph))

    model_function = partial(model_fn, out=graphs, merge_fn=merge_fn)

    if data_format is None:
        data_format = (
            "channels_first" if tf.test.is_built_with_cuda() else "channels_last"
        )
    estimator_config = tf.estimator.RunConfig(
        session_config=new_session_config(parallel=parallel)
    )
    if not os.path.exists(model_dir):
        raise RuntimeError(f"model directory {model_dir} is not existed")
    classifier = tf.estimator.Estimator(
        model_fn=model_function,
        model_dir=model_dir,
        params={"data_format": data_format},
        config=estimator_config,
    )

    list(classifier.predict(input_fn=input_fn))
    return graphs

'''
Reconstruct trace regardless of the prediction.
The difference between reconstruct_stat_from_tf and reconstruct_trace_from_tf_brute_force
is that reconstruct_stat_from_tf only output traces of correct predictions,
but reconstruct_trace_from_tf_brute_force output traces of correct and wrong
predictions.
'''
def reconstruct_trace_from_tf_brute_force(
    model_fn,
    input_fn,
    select_fn: Callable[[np.ndarray], np.ndarray],
    model_dir: str,
    class_id: int = None,
    data_format: str = "channels_first",
    debug: bool = False,
    parallel: int = 1,
    top_5: bool = False,
    topk: int = 5,
    per_channel: bool = False,
    select_seed_fn: Callable[[np.ndarray], np.ndarray] = None,
    entry_points: List[int] = None,
    stop_hook: Callable[[Operation], bool] = None,
    is_unstructured: bool = False,
    density: float = None,
) -> List[AttrMap]:
    model_dir = abspath(model_dir)

    graphs = []

    def to_trace(graph):
        logits = graph.tensor(graph.outputs[0]).value
        predict = np.argmax(logits)
        predict_top5 = list(arg_sorted_topk(logits, topk))
        if predict != predict_top5[0]:
            if predict in predict_top5:
                predict_top5.remove(predict)
                predict_top5 = [predict] + predict_top5
            else:
                predict_top5 = [predict] + predict_top5[:-1]
        predict_top5_value = list(logits[predict_top5])

        if is_unstructured:
            trace = get_unstructured_trace(
                graph, density=density, select_fn=select_fn, debug=debug
            )
        else:
            trace = (get_channel_trace if per_channel else get_trace)(
                graph,
                select_fn=select_fn,
                select_seed_fn=select_seed_fn,
                entry_points=entry_points,
                debug=debug,
                stop_hook=stop_hook,
            )
        trace.attrs[GraphAttrKey.PREDICT] = predict
        trace.attrs[GraphAttrKey.PREDICT_TOP5] = predict_top5
        trace.attrs[GraphAttrKey.PREDICT_TOP5_VALUE] = predict_top5_value
        return trace
        # return None


    if debug:
        def merge_fn(out, graph):
            return out.append((to_trace(graph), graph))

    else:

        def merge_fn(out, graph):
            return out.append(to_trace(graph))

    model_function = partial(model_fn, out=graphs, merge_fn=merge_fn)

    if data_format is None:
        data_format = (
            "channels_first" if tf.test.is_built_with_cuda() else "channels_last"
        )
    estimator_config = tf.estimator.RunConfig(
        session_config=new_session_config(parallel=parallel)
    )
    if not os.path.exists(model_dir):
        raise RuntimeError(f"model directory {model_dir} is not existed")
    classifier = tf.estimator.Estimator(
        model_fn=model_function,
        model_dir=model_dir,
        params={"data_format": data_format},
        config=estimator_config,
    )

    list(classifier.predict(input_fn=input_fn))

    return graphs


def reconstruct_trace_from_tf_v2(
    model_fn,
    input_fn,
    trace_fn,
    model_dir: str,
    class_id: int = None,
    data_format: str = "channels_first",
    parallel: int = 1,
    rank: int = None,
) -> List[AttrMap]:
    model_dir = abspath(model_dir)

    graphs = []

    def to_trace(graph):
        logits = graph.tensor(graph.outputs[0]).value
        if (class_id is None) or (np.count_nonzero(logits > logits[class_id]) == 0):
            trace = trace_fn(graph=graph)
            trace.attrs[GraphAttrKey.PREDICT] = class_id or int(np.argmax(logits))
            if rank is not None:
                trace.attrs[GraphAttrKey.SEED] = int(
                    arg_sorted_topk(logits, rank)[rank - 1]
                )
            return trace
            # return None
        else:
            return None

    def merge_fn(out, graph):
        return out.append(to_trace(graph))

    model_function = partial(model_fn, out=graphs, merge_fn=merge_fn)

    if data_format is None:
        data_format = (
            "channels_first" if tf.test.is_built_with_cuda() else "channels_last"
        )
    estimator_config = tf.estimator.RunConfig(
        session_config=new_session_config(parallel=parallel)
    )
    if not os.path.exists(model_dir):
        raise RuntimeError(f"model directory {model_dir} is not existed")
    classifier = tf.estimator.Estimator(
        model_fn=model_function,
        model_dir=model_dir,
        params={"data_format": data_format},
        config=estimator_config,
    )

    list(classifier.predict(input_fn=input_fn))

    return graphs


def class_trace_compact(
    class_trace_fn: Callable[..., IOAction[AttrMap]],
    name: str,
    model_config: ModelConfig,
    compress: bool = True,
):
    def class_trace_compact_fn(
        class_id: int,
        threshold: float,
        label: Optional[str],
        variant: str = None,
        trace_type: str = None,
        trace_parameter: str = None,
        trace_dir = "result",
        *args,
        **kwargs,
    ) -> IOAction[AttrMap]:
        def compact():
            # st()
            return compact_trace(
                class_trace_fn(
                    class_id=class_id,
                    threshold=threshold,
                    label=label,
                    compress=compress,
                    variant=variant,
                    trace_type=trace_type,
                    trace_parameter=trace_parameter,
                    trace_dir = trace_dir,
                ).load(),
                model_config.network_class.graph().load(),
                per_channel=(trace_type == "class_channel_trace"),
            )

        trace_path = trace_store_path_v2(
            name=name,
            threshold=threshold,
            label=label,
            variant=variant,
            is_compact=True,
            trace_type=trace_type,
            trace_parameter=trace_parameter,
        )
        path = f"{trace_dir}/{trace_path}/{class_id}.pkl"
        ensure_dir(path)
        return IOAction(path, init_fn=compact, cache=True, compress=True)

    return class_trace_compact_fn

def forward_propagate(
    create_model,
    input_fn,
    forward_fn: Callable[[tf.Tensor], tf.Tensor],
    model_dir: str,
    data_format: str = "channels_first",
    parallel: int = 1,
    prediction_hooks: List[SessionRunHook] = None,
) -> Union[int, float]:

    def model_fn(features, labels, mode, params):
        image = features
        if isinstance(image, dict):
            image = features["image"]

        # Save inputs for visualization in tensorboard
        # nonlocal prediction_hooks
        # feature_trans = tf.transpose(image, perm=[0,2,3,1])
        # image_summary = tf.summary.image("feature", feature_trans, max_outputs=1)
        # eval_summary_hook = tf.train.SummarySaverHook(
        #                     summary_op=image_summary,
        #                     save_steps=1,
        #                     output_dir=model_dir)
        # if prediction_hooks is None:
        #     prediction_hooks = [eval_summary_hook]
        # else:
        #     prediction_hooks.append(eval_summary_hook)

        if mode == tf.estimator.ModeKeys.PREDICT:
            logits = create_model()(image, training=False)
            predictions = {"classes": forward_fn(logits)}
            return tf.estimator.EstimatorSpec(
                mode=tf.estimator.ModeKeys.PREDICT,
                predictions=predictions,
                prediction_hooks=prediction_hooks,
                export_outputs={
                    "classify": tf.estimator.export.PredictOutput(predictions)
                },
            )

    model_dir = abspath(model_dir)
    model_function = model_fn
    if data_format is None:
        data_format = (
            "channels_first" if tf.test.is_built_with_cuda() else "channels_last"
        )
    estimator_config = tf.estimator.RunConfig(
        session_config=new_session_config(parallel=parallel)
    )
    if not os.path.exists(model_dir):
        raise RuntimeError(f"model directory {model_dir} is not existed")
    # st()
    classifier = tf.estimator.Estimator(
        model_fn=model_function,
        model_dir=model_dir,
        params={"data_format": data_format},
        config=estimator_config,
    )
    # hooks = [tf_debug.LocalCLIDebugHook(ui_type="readline")]
    # hooks = [tf_debug.TensorBoardDebugHook('localhost:2345')]
    # result = list(classifier.predict(input_fn=input_fn, hooks=hooks))
    result = list(classifier.predict(input_fn=input_fn))
    return result[0]["classes"]

def predict(
    create_model,
    input_fn,
    model_dir: str,
    data_format: str = "channels_first",
    parallel: int = 1,
    prediction_hooks: List[SessionRunHook] = None,
) -> int:
    return int(
        forward_propagate(
            create_model=create_model,
            input_fn=input_fn,
            forward_fn=lambda logits: tf.argmax(logits, axis=1),
            model_dir=model_dir,
            data_format=data_format,
            parallel=parallel,
            prediction_hooks=prediction_hooks,
        )
    )
    
def forward_propagate_batch(
    create_model,
    input_fn,
    forward_fn: Callable[[tf.Tensor], tf.Tensor],
    model_dir: str,
    data_format: str = "channels_first",
    parallel: int = 1,
    prediction_hooks: List[SessionRunHook] = None,
) -> Union[int, float]:

    def model_fn(features, labels, mode, params):
        image = features
        if isinstance(image, dict):
            image = features["image"]

        # Save inputs for visualization in tensorboard
        # nonlocal prediction_hooks
        # feature_trans = tf.transpose(image, perm=[0,2,3,1])
        # image_summary = tf.summary.image("feature", feature_trans, max_outputs=1)
        # eval_summary_hook = tf.train.SummarySaverHook(
        #                     summary_op=image_summary,
        #                     save_steps=1,
        #                     output_dir=model_dir)
        # if prediction_hooks is None:
        #     prediction_hooks = [eval_summary_hook]
        # else:
        #     prediction_hooks.append(eval_summary_hook)

        if mode == tf.estimator.ModeKeys.PREDICT:
            logits = create_model()(image, training=False)
            predictions = {"classes": forward_fn(logits)}
            return tf.estimator.EstimatorSpec(
                mode=tf.estimator.ModeKeys.PREDICT,
                predictions=predictions,
                prediction_hooks=prediction_hooks,
                export_outputs={
                    "classify": tf.estimator.export.PredictOutput(predictions)
                },
            )

    model_dir = abspath(model_dir)
    model_function = model_fn
    if data_format is None:
        data_format = (
            "channels_first" if tf.test.is_built_with_cuda() else "channels_last"
        )
    estimator_config = tf.estimator.RunConfig(
        session_config=new_session_config(parallel=parallel)
    )
    if not os.path.exists(model_dir):
        raise RuntimeError(f"model directory {model_dir} is not existed")
    classifier = tf.estimator.Estimator(
        model_fn=model_function,
        model_dir=model_dir,
        params={"data_format": data_format},
        config=estimator_config,
    )
    # hooks = [tf_debug.LocalCLIDebugHook(ui_type="readline")]
    # hooks = [tf_debug.TensorBoardDebugHook('localhost:2345')]
    # result = list(classifier.predict(input_fn=input_fn, hooks=hooks))
    result = list(classifier.predict(input_fn=input_fn))
    result = np.array([v["classes"] for v in result])
    return result

def predict_batch(
    create_model,
    input_fn,
    model_dir: str,
    data_format: str = "channels_first",
    parallel: int = 1,
    prediction_hooks: List[SessionRunHook] = None,
) -> np.ndarray:
    return forward_propagate_batch(
            create_model=create_model,
            input_fn=input_fn,
            forward_fn=lambda logits: tf.argmax(logits, axis=1),
            model_dir=model_dir,
            data_format=data_format,
            parallel=parallel,
            prediction_hooks=prediction_hooks,
        )



def get_rank(
    class_id: int,
    create_model,
    input_fn,
    model_dir: str,
    data_format: str = "channels_first",
    parallel: int = 1,
    prediction_hooks: List[SessionRunHook] = None,
) -> int:
    return int(
        forward_propagate(
            create_model=create_model,
            input_fn=input_fn,
            forward_fn=lambda logits: tf.count_nonzero(
                tf.transpose(logits, (1, 0)) > tf.transpose(logits, (1, 0))[class_id],
                axis=0,
            ),
            model_dir=model_dir,
            data_format=data_format,
            parallel=parallel,
            prediction_hooks=prediction_hooks,
        )
    )


def get_predicted_value(
    class_id: int,
    create_model,
    input_fn,
    model_dir: str,
    data_format: str = "channels_first",
    parallel: int = 1,
    prediction_hooks: List[SessionRunHook] = None,
) -> float:
    return forward_propagate(
        create_model=create_model,
        input_fn=input_fn,
        forward_fn=lambda logits: logits[:, class_id],
        model_dir=model_dir,
        data_format=data_format,
        parallel=parallel,
        prediction_hooks=prediction_hooks,
    )



def reconstruct_stat_from_tf(
    model_fn,
    input_fn,
    model_dir: str,
    stat_name: str = None,
    class_id: int = None,
    data_format: str = "channels_first",
    parallel: int = 1,
    top_5: bool = False,
    topk: int = 5,
    stop_hook: Callable[[Operation], bool] = None,
) -> List[AttrMap]:
    model_dir = abspath(model_dir)

    graphs = []

    def to_trace(graph):
        logits = graph.tensor(graph.outputs[0]).value
        predict = np.argmax(logits)
        predict_top5 = list(np.argsort(logits)[::-1][:topk])
        if predict != predict_top5[0]:
            predict_top5.remove(predict)
            predict_top5 = [predict] + predict_top5
        # if ((class_id is None) or
        #     (top_5 and class_id in predict_top5) or
        #     (not top_5 and predict == class_id)):
        #     trace = reconstruct_stat(
        #         graph,
        #         stat_name=stat_name,
        #         data_format=data_format,
        #         stop_hook=stop_hook,
        #     )
        #     return trace
        #     # return None
        # else:
        #     return None
        trace = reconstruct_stat(
            graph, stat_name=stat_name, data_format=data_format, stop_hook=stop_hook
        )
        trace["predict"] = predict
        trace["label"] = class_id
        return trace

    def merge_fn(out, graph):
        return out.append(to_trace(graph))

    model_function = partial(model_fn, out=graphs, merge_fn=merge_fn)

    if data_format is None:
        data_format = (
            "channels_first" if tf.test.is_built_with_cuda() else "channels_last"
        )
    estimator_config = tf.estimator.RunConfig(
        session_config=new_session_config(parallel=parallel)
    )
    if not os.path.exists(model_dir):
        raise RuntimeError(f"model directory {model_dir} is not existed")
    classifier = tf.estimator.Estimator(
        model_fn=model_function,
        model_dir=model_dir,
        params={"data_format": data_format},
        config=estimator_config,
    )

    list(classifier.predict(input_fn=input_fn))

    return graphs


def reconstruct_static_trace_from_tf(
    model_fn,
    input_fn: Callable[[], tf.Tensor],
    model_dir: str,
    density: float,
    input_name: str = "IteratorGetNext:0",
) -> AttrMap:
    input_tensor = input_fn()
    output_tensor = model_fn()(input_tensor)
    with tf.Session() as sess:
        saver = tf.train.Saver()
        saver.restore(sess, abspath(model_dir))
        graph = build_graph([input_tensor], [output_tensor])
        graph.rename(graph.id(input_tensor.name), input_name)
        tf_graph = input_tensor.graph
        assign_variables(graph, get_variables_from_tf(graph, tf_graph, sess))
    reconstruct_static_trace(graph, density)
    return graph.attrs_to_map()


def reconstruct_class_trace_from_tf(
    class_id: int,
    model_fn,
    input_fn,
    model_dir: str,
    select_fn: Callable[[np.ndarray], np.ndarray],
    select_seed_fn: Callable[[np.ndarray], np.ndarray] = None,
    entry_points: List[int] = None,
    data_format: str = "channels_first",
    parallel: int = 1,
    merge_fn=merge_trace,
    per_channel: bool = False,
    is_unstructured: bool = False,
    density: float = None,
) -> AttrMap:
    model_dir = abspath(model_dir)

    trace = [None]
    image_count = [0]

    # tr = tracker.SummaryTracker()

    def merge_output_fn(out, graph):
        predict = np.argmax(graph.tensor(graph.outputs[0]).value)
        if predict == class_id:
            try:
                if per_channel:
                    new_trace = get_channel_trace(graph, select_fn=select_fn)
                else:
                    if is_unstructured:
                        new_trace = get_unstructured_trace(
                            graph, density=density, select_fn=select_fn
                        )
                    else:
                        new_trace = get_trace(
                            graph,
                            select_fn=select_fn,
                            select_seed_fn=select_seed_fn,
                            entry_points=entry_points,
                        )
                # tr.print_diff()
                if out[0] is None:
                    out[0] = new_trace
                else:
                    out[0] = merge_fn(out[0], new_trace)
            except Exception as cause:
                raise RuntimeError(
                    f"error when handling image {image_count[0]}"
                ) from cause
        image_count[0] += 1

    model_function = partial(model_fn, out=trace, merge_fn=merge_output_fn)

    if data_format is None:
        data_format = (
            "channels_first" if tf.test.is_built_with_cuda() else "channels_last"
        )
    estimator_config = tf.estimator.RunConfig(
        session_config=new_session_config(parallel=parallel)
    )
    if not os.path.exists(model_dir):
        raise RuntimeError(f"model directory {model_dir} is not existed")
    classifier = tf.estimator.Estimator(
        model_fn=model_function,
        model_dir=model_dir,
        warm_start_from=model_dir,
        params={"data_format": data_format},
        config=estimator_config,
    )

    list(classifier.predict(input_fn=input_fn))

    return trace[0]

def self_similarity(
    name: str,
    trace_fn,
    class_ids: Iterable[int],
    is_compact: bool = True,
    per_channel: bool = False,
):
    def self_similarity_fn(
        threshold: float,
        label: str = None,
        key: str = TraceKey.EDGE,
        compress: bool = True,
        variant: str = None,
    ) -> IOAction[np.ndarray]:
        def get_self_similarity(partial_path) -> np.ndarray:
            if is_compact:
                similarity_fn = calc_iou_compact
                trace_label = "compact" if label is None else label + "_compact"
            else:
                similarity_fn = calc_iou
                trace_label = label
            return self_similarity_matrix_ray(
                partial_path,
                class_ids,
                trace_fn=lambda class_id: trace_fn(
                    class_id, threshold, trace_label, compress=compress, variant=variant
                ).load(),
                similarity_fn=similarity_fn,
                key=key,
            )

        threshold_name = "{0:.3f}".format(threshold)
        if label is not None:
            trace_name = f"{name}_{label}"
        else:
            trace_name = name
        if variant is not None:
            trace_name = f"{trace_name}_{variant}"
        if per_channel:
            similarity_type = "self_channel_similarity"
        else:
            similarity_type = "self_similarity"
        if key == TraceKey.EDGE:
            prefix = f"store/analysis/{similarity_type}/{trace_name}/approx_{threshold_name}/"
        elif key == TraceKey.WEIGHT:
            prefix = f"store/analysis/{similarity_type}_weight/{trace_name}/approx_{threshold_name}/"
        else:
            raise RuntimeError(f"key {key} is invalid")
        path = f"{prefix}/self_similarity.pkl"
        partial_path = f"{prefix}/partial/"
        return IOAction(
            path, init_fn=lambda: get_self_similarity(partial_path), cache=True
        )

    return self_similarity_fn


def self_similarity_per_layer(
    name: str,
    trace_fn,
    class_ids: Iterable[int],
    is_compact: bool = True,
    per_channel: bool = False,
):
    def self_similarity_fn(
        layer_name: str,
        threshold: float,
        label: str = None,
        key: str = TraceKey.EDGE,
        compress: bool = True,
        variant: str = None,
    ) -> IOAction[np.ndarray]:
        def get_self_similarity() -> np.ndarray:
            if is_compact:
                similarity_fn = partial(
                    calc_iou_compact_per_layer, node_name=layer_name
                )
                trace_label = "compact" if label is None else label + "_compact"
            else:
                similarity_fn = partial(calc_iou_per_layer, node_name=layer_name)
                trace_label = label
            return self_similarity_matrix_ray(
                partial_path,
                class_ids,
                trace_fn=lambda class_id: trace_fn(
                    class_id, threshold, trace_label, compress=compress, variant=variant
                ).load(),
                similarity_fn=similarity_fn,
                key=key,
            )

        threshold_name = "{0:.3f}".format(threshold)
        if label is not None:
            trace_name = f"{name}_{label}"
        else:
            trace_name = name
        if variant is not None:
            trace_name = f"{trace_name}_{variant}"
        if per_channel:
            similarity_type = "self_channel_similarity_per_layer"
        else:
            similarity_type = "self_similarity_per_layer"
        if key == TraceKey.EDGE:
            prefix = f"store/analysis/{similarity_type}/{trace_name}/approx_{threshold_name}/{layer_name}/"
        elif key == TraceKey.WEIGHT:
            prefix = f"store/analysis/{similarity_type}_weight/{trace_name}/approx_{threshold_name}/{layer_name}/"
        else:
            raise RuntimeError(f"key {key} is invalid")
        path = f"{prefix}/self_similarity.pkl"
        partial_path = f"{prefix}/partial/"
        return IOAction(path, init_fn=get_self_similarity, cache=True)

    return self_similarity_fn


def trace_store_path(
    name: str,
    threshold: float,
    label: str = None,
    variant: str = None,
    is_compact: bool = False,
    per_channel: bool = False,
    is_unstructured: bool = False,
    density: float = None,
) -> str:
    threshold_name = "{0:.3f}".format(threshold)
    if label is None:
        trace_name = name
    else:
        trace_name = f"{name}_{label}"
    if is_compact:
        trace_name = f"{trace_name}_compact"
    if variant is not None:
        trace_name = f"{trace_name}_{variant}"
    if per_channel:
        trace_type = "class_channel_trace"
    elif is_unstructured:
        trace_type = "unstructured_class_trace"
    else:
        trace_type = "class_trace"
    if is_unstructured:
        return f"{trace_type}/{trace_name}/approx_{threshold_name}/density_{density_name(density)}"
    else:
        return f"{trace_type}/{trace_name}/approx_{threshold_name}"


def trace_store_path_v2(
    name: str,
    threshold: float,
    label: str = None,
    variant: str = None,
    is_compact: bool = False,
    trace_type: str = None,
    trace_parameter: str = None,
) -> str:
    threshold_name = "{0:.1f}".format(threshold)
    if label is None:
        trace_name = name
    else:
        trace_name = f"{name}_{label}"
    if is_compact:
        trace_name = f"{trace_name}_compact"
    if variant is not None:
        trace_name = f"{trace_name}_{variant}"
    # trace_type = trace_type or "class_trace"
    # if trace_parameter is not None:
    #     return f"{trace_type}/{trace_name}/approx_{threshold_name}/{trace_parameter}"
    # else:
    #     return f"{trace_type}/{trace_name}/approx_{threshold_name}"
    if trace_parameter is not None:
        return f"{trace_name}_{threshold_name}/{trace_parameter}"
    else:
        return f"{trace_name}_{threshold_name}"



def example_trace(
    model_config: ModelConfig,
    data_config: DataConfig,
    use_raw: bool = False,
    per_channel: bool = False,
):
    def example_trace_fn(
        class_id: int,
        image_id: int,
        threshold: float,
        label: str = None,
        parallel: int = 1,
        variant: str = None,
        select_seed_fn: Callable[[np.ndarray], np.ndarray] = None,
        entry_points: List[int] = None,
    ) -> AttrMap:
        try:
            mode.check(False)
            # mode.check(True)
            data_dir = abspath(data_config.data_dir)
            model_dir = abspath(
                model_config.model_dir
                if label is None
                else f"{model_config.model_dir}_{label}"
            )
            graph = model_config.network_class.graph().load()
            model_fn = partial(
                model_fn_with_fetch_hook,
                create_model=lambda: model_config.network_class(),
                graph=graph,
            )
            if use_raw:
                return reconstruct_class_trace_from_tf(
                    class_id,
                    model_fn=model_fn,
                    input_fn=lambda: data_config.dataset_fn(
                        data_dir, class_id, image_id
                    ),
                    model_dir=model_dir,
                    select_fn=lambda input: arg_approx(input, threshold),
                    select_seed_fn=select_seed_fn,
                    entry_points=entry_points,
                    parallel=parallel,
                    per_channel=per_channel,
                )
            else:
                return reconstruct_class_trace_from_tf(
                    class_id,
                    model_fn=model_fn,
                    input_fn=lambda: data_config.dataset_fn(
                        data_dir,
                        1,
                        transform_fn=lambda dataset: dataset.filter(
                            lambda image, label: tf.equal(
                                tf.convert_to_tensor(class_id, dtype=tf.int32), label
                            )
                        )
                        .skip(image_id)
                        .take(1),
                    ),
                    model_dir=model_dir,
                    select_fn=lambda input: arg_approx(input, threshold),
                    select_seed_fn=select_seed_fn,
                    entry_points=entry_points,
                    parallel=parallel,
                    per_channel=per_channel,
                )
        except Exception as cause:
            raise RuntimeError(f"error when handling class {class_id}") from cause

    return example_trace_fn


def class_trace_growth(
    name: str,
    model_config: ModelConfig,
    data_config: DataConfig,
    use_raw: bool = False,
    per_channel: bool = False,
):
    def class_trace_growth_fn(
        class_id: int,
        threshold: float,
        label: str = None,
        example_num: int = 0,
        example_upperbound: int = 0,
        merge_fn=merge_trace,
        cache: bool = True,
        compress: bool = True,
        batch_size: int = 16,
        parallel: int = 1,
        variant: str = None,
    ) -> IOAction[AttrMap]:
        def get_class_trace() -> pd.DataFrame:
            error_detail = ""
            try:
                trace_growth = []
                graph = model_config.network_class.graph().load()
                layers = graph.layers()
                mode.check(False)
                # mode.check(True)
                data_dir = abspath(data_config.data_dir)
                model_dir = abspath(
                    model_config.model_dir
                    if label is None
                    else f"{model_config.model_dir}_{label}"
                )
                model_fn = partial(
                    model_fn_with_fetch_hook,
                    create_model=lambda: model_config.network_class(),
                    graph=graph,
                )
                if example_num == 0:
                    if use_raw:
                        class_trace = reconstruct_class_trace_from_tf(
                            class_id,
                            model_fn=model_fn,
                            input_fn=lambda: data_config.dataset_fn(data_dir, class_id),
                            model_dir=model_dir,
                            select_fn=lambda input: arg_approx(input, threshold),
                            parallel=parallel,
                            merge_fn=merge_fn,
                            per_channel=per_channel,
                        )
                    else:
                        class_trace = reconstruct_class_trace_from_tf(
                            class_id,
                            model_fn=model_fn,
                            input_fn=lambda: data_config.dataset_fn(
                                data_dir,
                                batch_size,
                                transform_fn=lambda dataset: dataset.filter(
                                    lambda image, label: tf.equal(
                                        tf.convert_to_tensor(class_id, dtype=tf.int32),
                                        label,
                                    )
                                ),
                            ),
                            model_dir=model_dir,
                            select_fn=lambda input: arg_approx(input, threshold),
                            parallel=parallel,
                            merge_fn=merge_fn,
                            per_channel=per_channel,
                        )
                else:
                    assert example_upperbound != 0
                    class_trace = None
                    example_count = 0
                    example_index = 0
                    while example_index < example_upperbound:
                        error_detail = f"example_count: {example_count}, example_index: {example_index}"
                        if use_raw:
                            take_num = 1
                            next_trace = reconstruct_class_trace_from_tf(
                                class_id,
                                model_fn=model_fn,
                                input_fn=lambda: data_config.dataset_fn(
                                    data_dir, class_id, example_index
                                ),
                                model_dir=model_dir,
                                select_fn=lambda input: arg_approx(input, threshold),
                                parallel=parallel,
                                merge_fn=merge_fn,
                                per_channel=per_channel,
                            )
                        else:
                            rest_example_num = example_num - example_count
                            rest_example_index = example_upperbound - example_index
                            take_num = min(rest_example_num, rest_example_index)
                            next_trace = reconstruct_class_trace_from_tf(
                                class_id,
                                model_fn=model_fn,
                                input_fn=lambda: data_config.dataset_fn(
                                    data_dir,
                                    1,
                                    transform_fn=lambda dataset: dataset.filter(
                                        lambda image, label: tf.equal(
                                            tf.convert_to_tensor(
                                                class_id, dtype=tf.int32
                                            ),
                                            label,
                                        )
                                    )
                                    .skip(example_index)
                                    .take(take_num),
                                ),
                                model_dir=model_dir,
                                select_fn=lambda input: arg_approx(input, threshold),
                                parallel=parallel,
                                merge_fn=merge_fn,
                                per_channel=per_channel,
                            )

                        example_index += take_num
                        if next_trace is not None:
                            example_count += next_trace.attrs[TraceKey.COUNT]
                            if example_count > 1:
                                class_trace_nodes = class_trace.nodes
                                size_per_layer_before_merge = {
                                    f"{layer}.{key}": class_trace_nodes[layer][key].size
                                    for key in [TraceKey.WEIGHT, TraceKey.EDGE]
                                    for layer in layers
                                    if key in class_trace_nodes[layer]
                                }
                            class_trace = merge_fn(class_trace, next_trace)
                            if example_count > 1:
                                class_trace_nodes = class_trace.nodes
                                size_per_layer_after_merge = {
                                    f"{layer}.{key}": class_trace_nodes[layer][key].size
                                    for key in [TraceKey.WEIGHT, TraceKey.EDGE]
                                    for layer in layers
                                    if key in class_trace_nodes[layer]
                                }
                                growth_per_layer = {
                                    key: (
                                        size_per_layer_after_merge[key]
                                        - size_per_layer_before_merge[key]
                                    )
                                    for key in size_per_layer_before_merge
                                }
                                weight_sum = sum(
                                    [
                                        growth_per_layer[key]
                                        for key in growth_per_layer
                                        if TraceKey.WEIGHT in key
                                    ]
                                )
                                edge_sum = sum(
                                    [
                                        growth_per_layer[key]
                                        for key in growth_per_layer
                                        if TraceKey.EDGE in key
                                    ]
                                )
                                growth_per_layer = {
                                    key: growth_per_layer[key] / weight_sum
                                    if TraceKey.WEIGHT in key
                                    else growth_per_layer[key] / edge_sum
                                    for key in growth_per_layer
                                }
                                trace_growth.append(growth_per_layer)
                        # print(calc_density(class_trace, TraceKey.EDGE))
                        if example_count >= example_num:
                            break
                return pd.DataFrame(trace_growth)
            except Exception as cause:
                raise RuntimeError(
                    f"error when handling class {class_id}, detail: ({error_detail})"
                ) from cause

        threshold_name = "{0:.3f}".format(threshold)
        if label is None:
            trace_name = name
        else:
            trace_name = f"{name}_{label}"
        if variant is not None:
            trace_name = f"{trace_name}_{variant}"
        if per_channel:
            trace_type = "class_channel_trace_growth"
        else:
            trace_type = "class_trace_growth"
        path = f"store/csv/{trace_type}/{trace_name}/approx_{threshold_name}/{class_id}.csv"
        return CsvIOAction(
            path, init_fn=get_class_trace, cache=cache, compress=compress
        )

    return class_trace_growth_fn


def class_trace_size(
    class_trace_fn: Callable[..., IOAction[AttrMap]],
    name: str,
    threshold: float,
    label: Optional[str],
    variant: str = None,
    trace_type: str = None,
    trace_parameter: str = None,
):
    def get_trace_size() -> pd.DataFrame:
        def get_row(class_id: int) -> Dict[str, Any]:
            class_trace = class_trace_fn(
                class_id,
                threshold=threshold,
                label=label,
                variant=variant,
                trace_type=trace_type,
                trace_parameter=trace_parameter,
            ).load()
            return {
                "class_id": class_id,
                "trace_edge_size": calc_trace_size(
                    class_trace, key=TraceKey.EDGE, compact=True
                ),
                "trace_weight_size": calc_trace_size(
                    class_trace, key=TraceKey.WEIGHT, compact=True
                ),
                "trace_point_size": calc_trace_size(
                    class_trace, key=TraceKey.POINT, compact=True
                ),
            }

        trace_sizes = ray_iter(
            get_row,
            ((class_id,) for class_id in range(0, 1000)),
            chunksize=1,
            out_of_order=True,
            num_gpus=0,
        )
        return pd.DataFrame(trace_sizes)

    trace_path = trace_store_path_v2(
        name=name,
        threshold=threshold,
        label=label,
        variant=variant,
        is_compact=True,
        trace_type=trace_type,
        trace_parameter=trace_parameter,
    )
    path = f"store/analysis/{trace_path}/class_trace_size.csv"
    return CsvIOAction(path, init_fn=get_trace_size)

def merged_class_trace_compact(
    class_trace_fn: Callable[..., IOAction[AttrMap]],
    name: str,
    compress: bool = True,
    per_channel: bool = False,
):
    def merged_class_trace_fn(
        start_id: int,
        stop_id: int,
        min_id: int,
        max_id: int,
        threshold: float,
        label: Optional[str],
        variant: str = None,
        *args,
        **kwargs,
    ) -> IOAction[AttrMap]:
        def get_merged_class_trace():
            middle_id = start_id + ((stop_id - start_id) // 2)
            if middle_id >= max_id:
                if stop_id - start_id == 2:
                    return class_trace_fn(
                        class_id=start_id,
                        threshold=threshold,
                        label=label,
                        compress=compress,
                        variant=variant,
                    ).load()
                else:
                    return merged_class_trace_fn(
                        start_id,
                        middle_id,
                        min_id,
                        max_id,
                        threshold,
                        label,
                        variant,
                        *args,
                        **kwargs,
                    ).load()
            if stop_id - start_id == 2:
                return reduce(
                    merge_compact_trace,
                    (
                        class_trace_fn(
                            class_id=class_id,
                            threshold=threshold,
                            label=label,
                            compress=compress,
                            variant=variant,
                        ).load()
                        for class_id in range(start_id, stop_id)
                    ),
                )
            else:
                return merge_compact_trace(
                    merged_class_trace_fn(
                        start_id,
                        middle_id,
                        min_id,
                        max_id,
                        threshold,
                        label,
                        variant,
                        *args,
                        **kwargs,
                    ).load(),
                    merged_class_trace_fn(
                        middle_id,
                        stop_id,
                        min_id,
                        max_id,
                        threshold,
                        label,
                        variant,
                        *args,
                        **kwargs,
                    ).load(),
                )

        threshold_name = "{0:.3f}".format(threshold)
        if label is None:
            trace_name = f"{name}_compact"
        else:
            trace_name = f"{name}_{label}_compact"
        if variant is not None:
            trace_name = f"{trace_name}_{variant}"
        if per_channel:
            trace_type = "merged_class_channel_trace"
        else:
            trace_type = "merged_class_trace"
        path = f"store/analysis/{trace_type}/{trace_name}/approx_{threshold_name}/{start_id}_{stop_id}.pkl"
        return IOAction(path, init_fn=get_merged_class_trace, cache=True, compress=True)

    return merged_class_trace_fn


def class_unique_trace_compact(
    class_trace_fn: Callable[..., IOAction[AttrMap]],
    merged_class_trace_fn: Callable[..., IOAction[AttrMap]],
    name: str,
    min_id: int,
    max_id: int,
    compress: bool = True,
    per_channel: bool = False,
):
    def class_unique_trace_fn(
        class_id: int,
        threshold: float,
        label: Optional[str],
        variant: str = None,
        *args,
        **kwargs,
    ) -> IOAction[AttrMap]:
        def get_class_unique_trace():
            def get_merged_trace(start_id: int, stop_id: int):
                if stop_id - start_id == 2:
                    merged_class_id = start_id + 1 if start_id == class_id else start_id
                    if merged_class_id >= max_id:
                        return None
                    else:
                        return class_trace_fn(
                            class_id=merged_class_id,
                            threshold=threshold,
                            label=label,
                            compress=compress,
                            variant=variant,
                        ).load()
                else:
                    middle_id = start_id + ((stop_id - start_id) // 2)
                    if stop_id > max_id:
                        stop_id = (
                            int(2 ** math.ceil(math.log2(max_id - middle_id)))
                            + middle_id
                        )
                    if class_id < middle_id:
                        return merge_compact_trace(
                            get_merged_trace(start_id, middle_id),
                            merged_class_trace_fn(
                                middle_id,
                                stop_id,
                                min_id,
                                max_id,
                                threshold=threshold,
                                label=label,
                                cache=True,
                                compress=True,
                                variant=variant,
                            ).load(),
                        )
                    else:
                        return merge_compact_trace(
                            merged_class_trace_fn(
                                start_id,
                                middle_id,
                                min_id,
                                max_id,
                                threshold=threshold,
                                label=label,
                                cache=True,
                                compress=True,
                                variant=variant,
                            ).load(),
                            get_merged_trace(middle_id, stop_id),
                        )

            return merge_compact_trace_diff(
                class_trace_fn(
                    class_id=class_id,
                    threshold=threshold,
                    label=label,
                    compress=compress,
                    variant=variant,
                ).load(),
                get_merged_trace(
                    min_id, int(2 ** math.ceil(math.log2(max_id - min_id))) + min_id
                ),
            )

        threshold_name = "{0:.3f}".format(threshold)
        if label is None:
            trace_name = f"{name}_compact"
        else:
            trace_name = f"{name}_{label}_compact"
        if variant is not None:
            trace_name = f"{trace_name}_{variant}"
        if per_channel:
            trace_type = "class_channel_unique_trace"
        else:
            trace_type = "class_unique_trace"
        path = f"store/analysis/{trace_type}/{trace_name}/approx_{threshold_name}/{class_id}.pkl"
        return IOAction(path, init_fn=get_class_unique_trace, cache=True, compress=True)

    return class_unique_trace_fn


def save_full_trace_growth(name: str, class_trace_fn: Callable[..., IOAction[AttrMap]]):
    def save_full_trace_growth_fn(
        threshold: float,
        label: str = None,
        class_ids: Iterable[int] = None,
        start_from: Iterable[int] = None,
        is_compact: bool = True,
    ):
        def get_class_trace(class_id) -> AttrMap:
            if is_compact:
                trace_label = "compact" if label is None else label + "_compact"
            else:
                trace_label = label
            try:
                return class_trace_fn(
                    class_id, threshold=threshold, label=trace_label, compress=True
                ).load()
            except Exception as cause:
                raise RuntimeError(f"raise from class {class_id}") from cause

        threshold_name = "{0:.3f}".format(threshold)
        if label is not None:
            trace_name = f"{name}_{label}"
        else:
            trace_name = name
        path = f"store/analysis/trace_growth/{trace_name}/approx_{threshold_name}/trace_growth.csv"
        path = ensure_dir(abspath(path))
        if start_from is not None:
            merged_trace = full_trace(name, class_trace_fn)(
                threshold=threshold,
                label=label,
                class_ids=start_from,
                is_compact=is_compact,
            ).init_fn()
        else:
            merged_trace = None
        for class_id in class_ids:
            class_trace = get_class_trace(class_id)
            merged_trace = merge_compact_trace(merged_trace, class_trace)
            file_exists = os.path.exists(path)
            with open(path, "a") as csv_file:
                headers = [
                    "class_id",
                    "point_density",
                    "edge_density",
                    "weight_density",
                ]
                writer = csv.DictWriter(
                    csv_file, delimiter=",", lineterminator="\n", fieldnames=headers
                )
                if not file_exists:
                    writer.writeheader()
                writer.writerow(
                    {
                        "class_id": class_id,
                        **{
                            header: calc_density_compact(merged_trace, key)
                            for key, header in [
                                (TraceKey.POINT, "point_density"),
                                (TraceKey.EDGE, "edge_density"),
                                (TraceKey.WEIGHT, "weight_density"),
                            ]
                        },
                    }
                )
            print(f"finish class {class_id}")

    return save_full_trace_growth_fn



def full_intersect_trace(
    name: str,
    class_trace_fn: Callable[..., IOAction[AttrMap]],
    compress: bool = True,
    per_channel: bool = False,
):
    def full_trace_fn(
        threshold: float,
        label: str = None,
        class_ids: Iterable[int] = None,
        is_compact: bool = True,
        variant: str = None,
    ) -> IOAction[AttrMap]:
        def get_trace() -> AttrMap:
            def get_class_trace(class_id):
                if is_compact:
                    trace_label = "compact" if label is None else label + "_compact"
                else:
                    trace_label = label
                try:
                    return class_trace_fn(
                        class_id,
                        threshold=threshold,
                        label=trace_label,
                        compress=compress,
                        variant=variant,
                    ).load()
                except Exception as cause:
                    raise RuntimeError(f"raise from class {class_id}") from cause

            def merge(class_ids):

                return reduce(
                    merge_compact_trace_intersect,
                    (get_class_trace(class_id) for class_id in class_ids),
                )

            return reduce(
                merge_compact_trace_intersect,
                ray_iter(
                    merge,
                    grouper(int(math.sqrt(len(class_ids))), class_ids),
                    out_of_order=True,
                    huge_task=True,
                ),
            )

        threshold_name = "{0:.3f}".format(threshold)
        if label is not None:
            trace_name = f"{name}_{label}"
        else:
            trace_name = name
        if variant is not None:
            trace_name = f"{trace_name}_{variant}"
        if per_channel:
            trace_type = "channel_intersect_trace"
        else:
            trace_type = "intersect_trace"
        path = f"store/analysis/{trace_type}/{trace_name}/approx_{threshold_name}/trace.pkl"
        return IOAction(path, init_fn=get_trace, compress=True, cache=True)

    return full_trace_fn

def save_class_traces_v2(
    class_trace_fn: Callable[..., IOAction[AttrMap]], class_ids: Iterable[int]
):
    def class_trace(class_id: int) -> Union[int, Tuple[int, str]]:
        try:
            class_id = int(class_id)
            class_trace_fn(class_id=class_id, compress=True).save()
            return class_id
        except Exception:
            return class_id, traceback.format_exc()

    results = ray_iter(
        class_trace,
        class_ids,
        chunksize=1,
        out_of_order=True,
        num_gpus=0,
        huge_task=True,
    )
    for result in results:
        if not isinstance(result, int):
            class_id, tb = result
            print(f"## raise exception from class {class_id}:")
            print(tb)
        else:
            print(f"finish class {result}")
    print("finish")


def save_merged_traces(
    merged_trace_fn: Callable[..., IOAction[AttrMap]],
    min_id: int,
    max_id: int,
    threshold: float,
    label: str = None,
    variant: str = None,
):
    def merged_trace(
        start_id: int, stop_id: int
    ) -> Union[Tuple[int, int], Tuple[int, int, str]]:
        try:
            start_id = int(start_id)
            stop_id = int(stop_id)
            merged_trace_fn(
                start_id,
                stop_id,
                min_id,
                max_id,
                threshold=threshold,
                label=label,
                cache=True,
                compress=True,
                variant=variant,
            ).save()
            return start_id, stop_id
        except Exception:
            return start_id, stop_id, traceback.format_exc()

    for step in list(
        itertools.takewhile(
            lambda x: x < (max_id - min_id),
            map(lambda x: int(2 ** x), itertools.count(1)),
        )
    ):
        results = ray_iter(
            merged_trace,
            list(
                map(
                    lambda start_id: (start_id, start_id + step),
                    range(min_id, max_id, step),
                )
            ),
            chunksize=1,
            out_of_order=True,
            num_gpus=0,
            huge_task=True,
        )
        for result in results:
            if len(result) == 3:
                start_id, stop_id, tb = result
                print(f"## raise exception from class [{start_id}, {stop_id}):")
                print(tb)
            else:
                start_id, stop_id = result
                print(f"finish class [{start_id}, {stop_id})")
        print(f"finish step {step}")
    print("finish")


def save_class_traces_low_latency(
    name: str, model_config: ModelConfig, data_config: DataConfig, use_raw: bool = False
):
    def save_class_traces_low_latency_fn(
        class_ids: Iterable[int],
        example_num: int,
        threshold: float,
        label: str = None,
        merge_fn=merge_trace,
        cache: bool = True,
        compress: bool = True,
        batch_size: int = 1,
        parallel: int = 1,
    ):
        def get_trace(class_id: int, batch_id: int, batch_size: int = 1) -> AttrMap:
            try:
                mode.check(False)
                data_dir = abspath(data_config.data_dir)
                model_dir = abspath(
                    model_config.model_dir
                    if label is None
                    else f"{model_config.model_dir}_{label}"
                )
                model_fn = partial(
                    model_fn_with_fetch_hook,
                    create_model=lambda: model_config.network_class(),
                    graph=model_config.network_class.graph().load(),
                )
                if use_raw:
                    # TODO: use batch size
                    trace = reconstruct_class_trace_from_tf(
                        class_id,
                        model_fn=model_fn,
                        input_fn=lambda: data_config.dataset_fn(
                            data_dir, class_id, batch_id
                        ),
                        model_dir=model_dir,
                        select_fn=lambda input: arg_approx(input, threshold),
                        parallel=parallel,
                        merge_fn=merge_fn,
                    )
                else:
                    trace = reconstruct_class_trace_from_tf(
                        model_fn=model_fn,
                        input_fn=lambda: data_config.dataset_fn(
                            data_dir,
                            batch_size,
                            transform_fn=lambda dataset: dataset.filter(
                                lambda image, label: tf.equal(
                                    tf.convert_to_tensor(class_id, dtype=tf.int32),
                                    label,
                                )
                            )
                            .skip(batch_id * batch_size)
                            .take(batch_size),
                        ),
                        model_dir=model_dir,
                        select_fn=lambda input: arg_approx(input, threshold),
                        class_id=class_id,
                        parallel=parallel,
                    )
                return trace
            except Exception as cause:
                raise RuntimeError(
                    f"error when handling class {class_id} batch {batch_id}"
                ) from cause

        threshold_name = "{0:.3f}".format(threshold)
        if label is None:
            trace_name = name
        else:
            trace_name = f"{name}_{label}"
        prefix = f"store/analysis/class_trace/{trace_name}/approx_{threshold_name}"
        class_ids = [
            class_id
            for class_id in class_ids
            if not (cache and os.path.exists(f"{prefix}/{class_id}.pkl"))
        ]
        batch_num = example_num // batch_size
        traces = ray_map_reduce(
            get_trace,
            merge_fn,
            [
                (
                    class_id,
                    [
                        (class_id, batch_id, batch_size)
                        for batch_id in range(0, batch_num)
                    ],
                )
                for class_id in class_ids
            ],
            num_gpus=0,
        )
        for class_id, trace in traces:
            IOAction(
                f"{prefix}/{class_id}.pkl",
                init_fn=lambda: trace,
                cache=cache,
                compress=compress,
            ).save()
            print(f"finish class {class_id}")

    return save_class_traces_low_latency_fn


def check_class_traces(
    class_trace_fn: Callable[..., IOAction[AttrMap]],
    class_ids: Iterable[int],
    threshold: float,
    label: str = None,
    compress: bool = False,
):
    def check(class_id):
        class_trace = class_trace_fn(
            class_id, threshold=threshold, label=label, compress=compress
        )
        if class_trace.is_saved() and os.path.getsize(class_trace.path) < (
            100 * 1024 * 1024
        ):
            try:
                class_trace.load()
            except (EOFError, zlib.error):
                os.remove(class_trace.path)
                return class_id
            except Exception as cause:
                raise RuntimeError(f"raise in class {class_id}") from cause

    corrupt_traces = list(filter_not_null(ray_map(check, class_ids, out_of_order=True)))
    print(f"corrupt traces: {corrupt_traces}")
