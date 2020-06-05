import os, sys
from pdb import set_trace as st
import numpy as np
from functools import partial
import copy

from model.config import LENET
import nninst_mode as mode
from dataset import mnist
from dataset.config import MNIST_TRAIN
from dataset.mnist_transforms import *
from trace.lenet_mnist_class_trace_v2 import (
    data_config,
)
from trace.common import (
    class_trace,
)
from tf_utils import new_session_config
from nninst_statistics import calc_trace_side_overlap
from nninst_trace import TraceKey
from nninst_utils.numpy import arg_approx
from nninst_utils.ray import ray_init
from nninst_utils.fs import ensure_dir
from nninst_op import *
from nninst_trace import calc_padding

# Configs
# Model config
model_label = "augmentation"
model_dir = f"result/lenet/model_{model_label}"
# Trace config
trace_dir =  f"{model_dir}/traces"
trace_name = "9translation"
# Thred
threshold = 0.5
key = TraceKey.EDGE

filter_zero_ratio_path = f"{model_dir}/filter_zero_ratio.txt"

lenet_mnist_class_trace = class_trace(
                            trace_name,
                            model_config=LENET,
                            data_config=data_config,
                        )

class_trace_fn=lambda class_id: lenet_mnist_class_trace(
    class_id,
    threshold,
    label=model_label,
    trace_dir = trace_dir,
)

graph = LENET.network_class.graph().load()

def to_bitmap(shape):
    mask = np.zeros(np.prod(shape), dtype=np.int8)
    mask[TraceKey.to_array(attr)] = 1
    return np.packbits(mask)

def reconstruct_edge(
    trace,
    graph,
    key,
    node_name,
):
    attrs = trace.nodes[node_name]
    op = graph.op(graph.id(node_name))
    if key not in attrs:
        return None
    else:
        attr = attrs[key]
        edge = TraceKey.to_array(attr)
        if isinstance(op, (AddOp, DenseOp)):
            shape = attrs[key+"_shape"]
            mask = np.zeros(np.prod(shape), dtype=np.int8)
            mask[edge] = 1
            mask = np.reshape(mask, shape)
            return mask
        elif isinstance(op, (MaxPoolOp, Conv2dOp, AvgPoolOp)):


            input_shape = trace.tensors[op.input_nodes[0].name][
                TraceKey.POINT_SHAPE
            ]
            output_shape = trace.tensors[op.output_nodes[0].name][
                TraceKey.POINT_SHAPE
            ]
            if op.data_format == "NHWC":
                input_shape = (
                    input_shape[2],
                    input_shape[0],
                    input_shape[1],
                )
                output_shape = (
                    output_shape[2],
                    output_shape[0],
                    output_shape[1],
                )
            in_channel, in_height, in_width, out_channel, out_height, out_width = np.unravel_index(
                edge, input_shape + output_shape
            )
            stride = np.array(op.strides)
            kernel_size = (
                np.array(attrs[TraceKey.WEIGHT_SHAPE])[2:]
                if isinstance(op, Conv2dOp)
                else np.array(op.filter_shape)
            )
            padding = calc_padding(
                np.array(input_shape)[1:],
                np.array(output_shape)[1:],
                stride,
                kernel_size,
            )
            kernel_height = (
                in_height + padding[1][0] - (out_height * stride[0])
            )
            kernel_width = (
                in_width + padding[2][0] - (out_width * stride[1])
            )
            edge_shape = attrs[TraceKey.EDGE_SHAPE]
            if isinstance(op, Conv2dOp):

                new_edge_index = np.ravel_multi_index(
                    (
                        in_channel,
                        kernel_height,
                        kernel_width,
                        out_channel,
                        out_height,
                        out_width,
                    ),
                    edge_shape,
                )
            else:

                new_edge_index = np.ravel_multi_index(
                    (
                        kernel_height,
                        kernel_width,
                        out_channel,
                        out_height,
                        out_width,
                    ),
                    edge_shape,
                )
            mask = np.zeros(np.prod(edge_shape), dtype=np.int8)
            mask[new_edge_index] = 1
            mask = np.reshape(mask, edge_shape)
            return mask

def compute_reduced_vector():
    # Compute reduced vectors of size (Ci, Hk, Wk, Co) that ommit spatial information
    # of feature map
    np.set_printoptions(precision=2, linewidth=200)
    f = open(filter_zero_ratio_path, "w")
    class_edge_info = {i: {} for i in range(10)}
    for class_id in range(10):
        print(f"Class {class_id}", file=f)
        trace = class_trace_fn(class_id).load()
        reconstruct_edge_fn = partial(
                                reconstruct_edge,
                                trace,
                                graph,
                                key,
                                )
        op_to_mask = {}
        for node_name in sorted(trace.nodes):
            if key in trace.nodes[node_name]:
                op_to_mask[node_name] = reconstruct_edge_fn(node_name)

        for node_name in op_to_mask:
            edge = op_to_mask[node_name]
            if "conv2d" in node_name:
                edge_sum = op_to_mask[node_name].sum(-1).sum(-1)
                edge_sum[edge_sum>0] = 1
            else:
                edge_sum = edge
            edge_sum_num = edge_sum.size
            edge_sum_zero = edge_sum_num - np.count_nonzero(edge_sum)
            ratio = edge_sum_zero / edge_sum_num
            print(f"{node_name}:\t{ratio:.2f}\t{edge_sum_zero}/{edge_sum_num}", file=f)
            class_edge_info[class_id][node_name] = edge_sum

        print(file=f)

def compute_zero_correlation():
    # Compute the correlation between zeros of reduced vectors
    correlation_path = f"{model_dir}/correlation.txt"
    f = open(correlation_path, "w")
    node_names = class_edge_info[0].keys()
    correlation = {node_name: np.zeros((10,10)) for node_name in node_names}
    for node_name in node_names:
        for src_id in range(10):
            for dst_id in range(10):
                src_edge = class_edge_info[src_id][node_name]
                src_mask = 1-src_edge
                dst_edge = class_edge_info[dst_id][node_name]
                dst_mask = 1-dst_edge
                intersect = src_mask * dst_mask
                ratio = intersect.sum() / src_mask.sum()
                correlation[node_name][src_id][dst_id] = ratio

    for node_name in node_names:
        print(node_name, file=f)
        print(correlation[node_name], file=f)

def compute_effective_node_number():
    # Compute reduced vectors of size (Ci, Hk, Wk, Co) that ommit spatial information
    # of feature map
    np.set_printoptions(precision=2, linewidth=200)
    effective_node_number_path = f"{model_dir}/node_number.txt"
    f = open(effective_node_number_path, "w")
    class_edge_info = {i: {} for i in range(10)}
    for class_id in range(10):
        print(f"Class {class_id}", file=f)
        trace = class_trace_fn(class_id).load()
        reconstruct_edge_fn = partial(
                                reconstruct_edge,
                                trace,
                                graph,
                                key,
                                )
        op_to_mask = {}
        for node_name in sorted(trace.nodes):
            if key in trace.nodes[node_name]:
                op_to_mask[node_name] = reconstruct_edge_fn(node_name)

        for node_name in op_to_mask:
            edge = op_to_mask[node_name]
            if "conv2d" in node_name:
                edge_sum = op_to_mask[node_name].sum(-1).sum(-1)
                edge_sum[edge_sum>0] = 1
            else:
                edge_sum = edge
            edge_sum_num = edge_sum.size
            edge_sum_zero = edge_sum_num - np.count_nonzero(edge_sum)
            ratio = edge_sum_zero / edge_sum_num
            node_number = np.count_nonzero(edge)
            sum_node_number = np.count_nonzero(edge_sum)
            print(f"{node_name}:\t{node_number}\t{sum_node_number}", file=f)
            class_edge_info[class_id][node_name] = edge_sum

        if class_id is 0:
            edge_all_class = copy.deepcopy(op_to_mask)
            edge_sum_all_class = copy.deepcopy(class_edge_info[class_id])
        else:
            for node_name in op_to_mask:
                edge_all_class[node_name] = np.logical_or(
                                            edge_all_class[node_name],
                                            op_to_mask[node_name])
                edge_sum_all_class[node_name] = np.logical_or(
                                                edge_sum_all_class[node_name],
                                                class_edge_info[class_id]
                )

        print(file=f)

    print(f"All", file=f)
    for node_name in edge_all_class:
        node_number = np.count_nonzero(edge_all_class[node_name])
        sum_node_number = np.count_nonzero(edge_sum_all_class[node_name])
        print(f"{node_name}:\t{node_number}\t{sum_node_number}", file=f)

# compute_effective_node_number()
