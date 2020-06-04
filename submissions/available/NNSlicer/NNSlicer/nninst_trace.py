from functools import reduce, wraps
from typing import Any, Callable, Dict, List, Optional, Set, Type, Union

import numpy as np
import pandas as pd
from pdb import set_trace as st

import nninst_mode as mode
from nninst_graph import AttrMap, Graph, Operation, Tensor
from nninst_op import *
from nninst_utils import filter_not_null
from nninst_utils.numpy import argtopk, concatenate, repeat

__all__ = [
    "TraceKey",
    "register_op",
    "get_trace",
    "reconstruct_static_trace",
    "merge_trace",
    "compact_trace",
    "compact_edge",
    "merge_compact_trace",
    "merge_simple_trace",
    "merge_simple_trace_intersect",
    "merge_compact_trace_intersect",
    "merge_compact_trace_diff",
    "merge_simple_trace_xor",
    "merge_compact_trace_xor",
    "linear_layer_trace",
    "max_layer_trace",
    "conv2d_layer_trace",
    "trivial_layer_trace",
]

_trace_func_by_op: Dict[Type[Operation], Callable[..., None]] = {}

EPS = np.finfo(np.float16).eps

class OpAvgLogger(object):
    def __init__(self, 
                input, 
                output,
                _count=1
        ):
        self.input_sum = input
        self.output_sum = output
        self.count = _count
        
    def __repr__(self):
        info = (f"[Count: {self.count}, "
            f"input shape: {self.input_sum.shape}"
            f"output shape: {self.output_sum.shape}")
        return info
    
    def __add__(self, _logger):
        assert (self.input_sum.shape ==
                _logger.input_sum.shape)
        count = self.count + _logger.count
        input_sum = (self.input_sum + 
                              _logger.input_sum )
        output_sum = self.output_sum + _logger.output_sum
        add_logger = OpAvgLogger(
            input_sum, 
            output_sum,
            count
        )
        return add_logger
    
    def input_avg(self):
        return self.input_sum / self.count
    
    def output_avg(self):
        return self.output_sum / self.count
    
    

class TraceKey:
    debug_image_id = -1
    OP_TYPE = "trace.op_type"

    PATH = "trace.path"
    POINT = "trace.point"
    EDGE = "trace.edge"
    WEIGHT = "trace.weight"
    TRIVIAL = "trace.trivial"
    WEIGHTED_INPUT = "trace.weighted_input"
    FLIP_SIGN = "trace.flip_sign"
    FLIP_SIGN_CONFLICT = "trace.flip_sign_conflict"

    POINT_SHAPE = "trace.point_shape"
    EDGE_SHAPE = "trace.edge_shape"
    WEIGHT_SHAPE = "trace.weight_shape"

    POINT_NUM = "trace.point_num"
    EDGE_NUM = "trace.edge_num"
    WEIGHT_NUM = "trace.weight_num"

    MAX_POINT_NUM = "trace.max_point_num"
    MAX_EDGE_NUM = "trace.max_edge_num"
    MAX_WEIGHT_NUM = "trace.max_weight_num"

    MIN_POINT_NUM = "trace.min_point_num"
    MIN_EDGE_NUM = "trace.min_edge_num"
    MIN_WEIGHT_NUM = "trace.min_weight_num"
    
    IO_AVG = "trace.io_average"

    COUNT = "trace.count"
    DATA_FORMAT = "trace.data_format"
    ENTRY_POINTS = "trace.entry_points"

    OUTPUT_DENSITY = "trace.output_density"
    OUTPUT_THRESHOLD = "trace.output_threshold"
    RECEPTIVE_FIELD_DENSITY = "trace.receptive_field_density"
    RECEPTIVE_FIELD_THRESHOLD = "trace.receptive_field_threshold"
    
    CONTRIB = "trace.contrib"
    EDGE_CONTRIB = "trace.edge.contrib"
    WEIGHT_CONTRIB = "trace.weight.contrib"
    POINT_CONTRIB = "trace.point.contrib"
    DEBUG_FLAG = False
    
    BUG_IMAGEID = -1

    META = {OP_TYPE, TRIVIAL, POINT_SHAPE, EDGE_SHAPE, WEIGHT_SHAPE, DATA_FORMAT}
    STATISTICS = {
        POINT_NUM,
        EDGE_NUM,
        WEIGHT_NUM,
        MAX_POINT_NUM,
        MAX_EDGE_NUM,
        MAX_WEIGHT_NUM,
        MIN_POINT_NUM,
        MIN_EDGE_NUM,
        MIN_WEIGHT_NUM,
        COUNT,
    }
    METRICS = {
        OUTPUT_DENSITY,
        OUTPUT_THRESHOLD,
        RECEPTIVE_FIELD_DENSITY,
        RECEPTIVE_FIELD_THRESHOLD,
    }

    _base_keys = [POINT, EDGE, WEIGHT]

    @staticmethod
    def num_of(key: str) -> str:
        assert key in TraceKey._base_keys
        return key + "_num"

    @staticmethod
    def shape_of(key: str) -> str:
        assert key in TraceKey._base_keys
        return key + "_shape"

    @staticmethod
    def min_of(key: str) -> str:
        return key.replace("trace.", "trace.min_")

    @staticmethod
    def max_of(key: str) -> str:
        return key.replace("trace.", "trace.max_")

    @staticmethod
    def to_array(x, compact: bool = False):
        if isinstance(x, pd.DataFrame):
            return x.index.values
        elif isinstance(x, np.ndarray):
            return TraceKey.from_bitmap(x) if compact else x
        else:
            raise RuntimeError(f"expect array or data frame, get {type(x)}")

    @staticmethod
    def to_frame(x, compact: bool = False):
        if isinstance(x, pd.DataFrame):
            return x
        elif isinstance(x, np.ndarray):
            x = TraceKey.from_bitmap(x) if compact else x
            return pd.DataFrame(dict(count=np.ones(x.size, dtype=np.int)), index=x)
        else:
            raise RuntimeError(f"expect array or data frame, get {type(x)}")

    @staticmethod
    def to_bitmap(x, shape, compact: bool = False):
        if compact:
            return x
        else:
            mask = np.zeros(np.prod(shape), dtype=np.int8)
            mask[TraceKey.to_array(x)] = 1
            return np.packbits(mask)

    @staticmethod
    def to_mask(x, shape, compact: bool = False):
        if compact:
            mask = np.unpackbits(x)
        else:
            mask = np.zeros(np.prod(shape), dtype=np.int8)
            mask[TraceKey.to_array(x)] = 1
        return mask.reshape(shape)

    @staticmethod
    def from_bitmap(x):
        return np.nonzero(np.unpackbits(x))[0]

    @staticmethod
    def filter_key(
        match_key: Union[str, List[str], Set[str]], trace: AttrMap
    ) -> AttrMap:
        if isinstance(match_key, str):
            filter_fn = lambda key: key is match_key
        elif isinstance(match_key, list):
            match_key = set(match_key)
            filter_fn = lambda key: key in match_key
        elif isinstance(match_key, set):
            filter_fn = lambda key: key in match_key
        else:
            raise RuntimeError()
        return AttrMap(
            attrs={key: value for key, value in trace.attrs.items() if filter_fn(key)},
            ops={
                name: {key: value for key, value in op.items() if filter_fn(key)}
                for name, op in trace.ops.items()
            },
            tensors={
                name: {key: value for key, value in tensor.items() if filter_fn(key)}
                for name, tensor in trace.tensors.items()
            },
        )

    @staticmethod
    def is_trivial(op: Operation):
        return TraceKey.TRIVIAL in op.attrs and op.attrs[TraceKey.TRIVIAL]


def compact_trace(trace: AttrMap, graph: Graph, per_channel: bool = False) -> AttrMap:
    if trace is None:
        return trace
    for node_name, attrs in trace.nodes.items():
        for attr_name, attr in attrs.items():

            def to_bitmap(shape):
                mask = np.zeros(np.prod(shape), dtype=np.int8)
                mask[TraceKey.to_array(attr)] = 1
                return np.packbits(mask)

            if attr_name in [TraceKey.POINT, TraceKey.WEIGHT]:
                attrs[attr_name] = to_bitmap(attrs[attr_name + "_shape"])
            elif attr_name == TraceKey.EDGE:
                op = graph.op(graph.id(node_name))
                if isinstance(op, (AddOp, DenseOp)):
                    attrs[attr_name] = to_bitmap(attrs[attr_name + "_shape"])
                elif isinstance(op, (MaxPoolOp, Conv2dOp, AvgPoolOp)):
                    if per_channel:
                        attrs[attr_name] = to_bitmap(attrs[attr_name + "_shape"])
                    else:
                        edge = TraceKey.to_array(attr)
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
                        attrs[attr_name] = np.packbits(mask)
                else:
                    raise RuntimeError(f"unsupported op type {type(op)}")
            elif attr_name.startswith(TraceKey.POINT + ".") and attr is not None:
                attrs[attr_name] = to_bitmap(attrs[TraceKey.POINT_SHAPE])
    return trace


def compact_edge(trace: AttrMap, graph: Graph, per_channel: bool = False) -> AttrMap:
    if per_channel:
        return trace
    for node_name, attrs in trace.nodes.items():
        for attr_name, attr in attrs.items():
            if attr_name == TraceKey.EDGE:
                op = graph.op(graph.id(node_name))
                if isinstance(op, (MaxPoolOp, Conv2dOp, AvgPoolOp)):
                    edge = TraceKey.to_array(attr)
                    input_shape = trace.tensors[op.input_nodes[0].name][
                        TraceKey.POINT_SHAPE
                    ]
                    output_shape = trace.tensors[op.output_nodes[0].name][
                        TraceKey.POINT_SHAPE
                    ]
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
                    kernel_height = in_height + padding[1][0] - (out_height * stride[0])
                    kernel_width = in_width + padding[2][0] - (out_width * stride[1])
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
                    attrs[attr_name] = new_edge_index
    return trace


def _merge_trace(*traces: AttrMap, format: str = "sparse") -> Optional[AttrMap]:
    def merge_attr(attr_name: str, attrs: List[Any]) -> Any:
        if attr_name in [TraceKey.POINT, TraceKey.EDGE, TraceKey.WEIGHT]:

            def merge_with_count(attr1, attr2):
                merged_attr = pd.concat(
                    [TraceKey.to_frame(attr1), TraceKey.to_frame(attr2)]
                )
                return merged_attr.groupby(merged_attr.index).sum()

            if format == "sparse":
                return reduce(merge_with_count, attrs)
            elif format == "bitmap":
                return reduce(np.bitwise_or, attrs)
            elif format == "bitmap_intersect":
                return reduce(np.bitwise_and, attrs)
            elif format == "bitmap_diff":
                return np.bitwise_xor(attrs[0], np.bitwise_and(attrs[0], attrs[1]))
            elif format == "bitmap_xor":
                return np.bitwise_xor(attrs[0], attrs[1])
            elif format == "array":
                return reduce(np.union1d, map(TraceKey.to_array, attrs))
            elif format == "array_intersect":
                return reduce(np.intersect1d, map(TraceKey.to_array, attrs))
            elif format == "array_xor":
                return np.setxor1d(
                    TraceKey.to_array(attrs[0]), TraceKey.to_array(attrs[1])
                )
            else:
                raise RuntimeError(f"unsupported format {format}")
        elif attr_name in [
            TraceKey.POINT_SHAPE,
            TraceKey.EDGE_SHAPE,
            TraceKey.WEIGHT_SHAPE,
            TraceKey.OP_TYPE,
        ]:
            return attrs[0]
        elif attr_name in [
            TraceKey.POINT_NUM,
            TraceKey.EDGE_NUM,
            TraceKey.WEIGHT_NUM,
            TraceKey.COUNT,
            TraceKey.FLIP_SIGN_CONFLICT,
        ]:
            return sum(attrs)
        elif attr_name in [
            TraceKey.MAX_EDGE_NUM,
            TraceKey.MAX_POINT_NUM,
            TraceKey.MAX_WEIGHT_NUM,
        ]:
            return max(attrs)
        elif attr_name in [
            TraceKey.MIN_EDGE_NUM,
            TraceKey.MIN_POINT_NUM,
            TraceKey.MIN_WEIGHT_NUM,
        ]:
            return min(attrs)
        elif attr_name == TraceKey.TRIVIAL:
            return True
        else:
            return None

    traces = list(filter_not_null(traces))
    if len(traces) == 0:
        return None
    if len(traces) == 1:
        return traces[0]
    first_trace = traces[0]
    merged_trace = AttrMap(
        attrs={
            attr_name: merge_attr(
                attr_name,
                [
                    trace.attrs[attr_name]
                    for trace in traces
                    if attr_name in trace.attrs
                ],
            )
            for attr_name in first_trace.attrs
        },
        ops={
            node_name: {
                attr_name: merge_attr(
                    attr_name,
                    [
                        trace.ops[node_name][attr_name]
                        for trace in traces
                        if attr_name in trace.ops[node_name]
                    ],
                )
                for attr_name in first_trace.ops[node_name]
            }
            for node_name in first_trace.ops
        },
        tensors={
            node_name: {
                attr_name: merge_attr(
                    attr_name,
                    [
                        trace.tensors[node_name][attr_name]
                        for trace in traces
                        if attr_name in trace.tensors[node_name]
                    ],
                )
                for attr_name in first_trace.tensors[node_name]
            }
            for node_name in first_trace.tensors
        },
    )
    for node_name in first_trace.tensors:
        tensor = first_trace.tensors[node_name]
        if (TraceKey.POINT + ".1") in tensor:
            for attr_name in tensor:
                if attr_name.startswith(TraceKey.POINT + "."):
                    merged_trace.tensors[node_name][attr_name] = merge_attr(
                        TraceKey.POINT,
                        [trace.tensors[node_name][attr_name] for trace in traces],
                    )
    return merged_trace


def merge_trace(*traces: AttrMap) -> Optional[AttrMap]:
    return _merge_trace(*traces)


def merge_simple_trace(*traces: AttrMap) -> Optional[AttrMap]:
    return _merge_trace(*traces, format="array")


def merge_simple_trace_intersect(*traces: AttrMap) -> Optional[AttrMap]:
    return _merge_trace(*traces, format="array_intersect")


def merge_simple_trace_xor(trace1: AttrMap, trace2: AttrMap) -> Optional[AttrMap]:
    return _merge_trace(trace1, trace2, format="array_xor")


def merge_compact_trace(*traces: AttrMap) -> Optional[AttrMap]:
    return _merge_trace(*traces, format="bitmap")


def merge_compact_trace_intersect(*traces: AttrMap) -> Optional[AttrMap]:
    return _merge_trace(*traces, format="bitmap_intersect")


def merge_compact_trace_diff(trace1: AttrMap, trace2: AttrMap) -> Optional[AttrMap]:
    return _merge_trace(trace1, trace2, format="bitmap_diff")


def merge_compact_trace_xor(trace1: AttrMap, trace2: AttrMap) -> Optional[AttrMap]:
    return _merge_trace(trace1, trace2, format="bitmap_xor")


def register_op(op_type: Type[Operation], trace_func: Callable[..., None]):
    _trace_func_by_op[op_type] = trace_func


def trace_fn_wrapper(func):
    @wraps(func)
    def wrapper(graph: Graph, *args, **kwargs) -> AttrMap:
        new_graph = graph.clone()
        func(new_graph, *args, **kwargs)
        return new_graph.attrs_to_map()

    return wrapper


@trace_fn_wrapper
def get_trace(
    graph: Graph,
    select_fn: Callable[[np.ndarray], np.ndarray],
    select_seed_fn: Callable[[np.ndarray], np.ndarray] = None,
    entry_points: List[int] = None,
    debug: bool = False,
    stop_hook: Callable[[Operation], bool] = None,
    class_trace = None,
    *args,
    **kwargs,
) -> AttrMap:
    select_seed_fn = select_seed_fn or (lambda output: argtopk(output, 1))
    entry_points = entry_points or graph.outputs
    stop_hook = stop_hook or (lambda op: False)
    op_to_wait_count = {op.id: len(op.outputs) for op in graph.ops}
    tensor_to_wait_count = {tensor.id: len(tensor.outputs) for tensor in graph.tensors}
    for output_id in entry_points:
        output_tensor = graph.tensor(output_id)
        output_tensor.attrs[TraceKey.POINT] = select_seed_fn(output_tensor.value)
        output_tensor.attrs[TraceKey.POINT_SHAPE] = output_tensor.value.shape
        output_tensor.attrs[TraceKey.FLIP_SIGN] = None
        
        output_tensor.attrs[TraceKey.POINT_CONTRIB] = np.zeros(
            output_tensor.value.shape
        ) + 1
        # debug
        if class_trace is None:
            ...
        else:
            output_op_name = graph.op(output_tensor.op_id).name
            output_class_op = class_trace.ops[output_op_name][TraceKey.IO_AVG]
            output_avg = output_class_op.output_avg()
            output_contrib_direct = np.sign(
                output_tensor.value - output_avg
            )
            # output_tensor.attrs[TraceKey.POINT_CONTRIB] = output_contrib_direct
            output_point = output_tensor.attrs[TraceKey.POINT][0]
            # if output_contrib_direct[output_point]<0:
            #     TraceKey.DEBUG_FLAG = True
            
    ready_ops = list([graph.tensor(output_id).op_id for output_id in entry_points])
    while len(ready_ops) != 0:
        ready_op_id = ready_ops.pop()
        ready_op = graph.op(ready_op_id)
        ready_op.attrs[TraceKey.OP_TYPE] = type(ready_op).__name__
        if (class_trace is None or 
            TraceKey.IO_AVG not in class_trace.ops[ready_op.name]):
            class_ready_op = None
        else:
            class_ready_op = class_trace.ops[ready_op.name][TraceKey.IO_AVG]

        # if debug:
        #     print(f"Op id: {ready_op_id}, type: {type(ready_op).__name__}")
        
        # if ready_op.name == "conv2d_12/Conv2D":
        #     st()
        _trace_func_by_op[type(ready_op)](
            ready_op,
            select_fn=select_fn,
            debug=debug,
            collect_metrics=True,
            class_op=class_ready_op,
            *args,
            **kwargs,
        )
        
        # if ready_op.name == "conv2d_12/Conv2D":
        #     print(f"{ready_op.name}: {len(ready_op.output_nodes[0].attrs[TraceKey.POINT])}")
        #     st()
        
        if stop_hook(ready_op):
            break
        for input_tensor_id in ready_op.inputs:
            tensor_to_wait_count[input_tensor_id] = (
                tensor_to_wait_count[input_tensor_id] - 1
            )
            if tensor_to_wait_count[input_tensor_id] == 0:
                tensor_to_wait_count.pop(input_tensor_id)
                input_tensor = graph.tensor(input_tensor_id)
                if input_tensor.op is not None:
                    input_op_id = input_tensor.op.id
                    op_to_wait_count[input_op_id] = op_to_wait_count[input_op_id] - 1
                    if op_to_wait_count[input_op_id] == 0:
                        op_to_wait_count.pop(input_op_id)
                        ready_ops.append(input_op_id)
    graph.attrs[TraceKey.ENTRY_POINTS] = np.array(
        [graph.tensor(output_id).name for output_id in entry_points]
    )
    graph.attrs[TraceKey.COUNT] = 1
    graph.attrs[TraceKey.WEIGHT_NUM] = sum(
        op.attrs[TraceKey.WEIGHT].size
        for op in graph.ops
        if TraceKey.WEIGHT in op.attrs
    )
    graph.attrs[TraceKey.EDGE_NUM] = sum(
        op.attrs[TraceKey.EDGE].size for op in graph.ops if TraceKey.EDGE in op.attrs
    )
    graph.attrs[TraceKey.POINT_NUM] = sum(
        tensor.attrs[TraceKey.POINT].size
        for tensor in graph.tensors
        if TraceKey.POINT in tensor.attrs
    )
    graph.attrs[TraceKey.FLIP_SIGN_CONFLICT] = sum(
        tensor.attrs[TraceKey.FLIP_SIGN_CONFLICT]
        for tensor in graph.tensors
        if TraceKey.FLIP_SIGN_CONFLICT in tensor.attrs
    )
    graph.attrs[TraceKey.MAX_WEIGHT_NUM] = graph.attrs[TraceKey.WEIGHT_NUM]
    graph.attrs[TraceKey.MAX_POINT_NUM] = graph.attrs[TraceKey.POINT_NUM]
    graph.attrs[TraceKey.MAX_EDGE_NUM] = graph.attrs[TraceKey.EDGE_NUM]
    graph.attrs[TraceKey.MIN_WEIGHT_NUM] = graph.attrs[TraceKey.WEIGHT_NUM]
    graph.attrs[TraceKey.MIN_POINT_NUM] = graph.attrs[TraceKey.POINT_NUM]
    graph.attrs[TraceKey.MIN_EDGE_NUM] = graph.attrs[TraceKey.EDGE_NUM]


FloatOrDict = Union[float, Dict[str, float]]


def density_name(density: FloatOrDict, format: str = "{0:.3f}"):
    if isinstance(density, float):
        return format.format(density)
    else:
        return "from_" + format.format(density["threshold"])


@trace_fn_wrapper
def get_unstructured_trace(
    graph: Graph,
    density: FloatOrDict,
    select_fn: Callable[[np.ndarray], np.ndarray],
    debug: bool = False,
    *args,
    **kwargs,
) -> AttrMap:
    for op_name in graph.ops_in_layers(DenseOp, Conv2dOp):
        op = graph.op(graph.id(op_name))
        output_tensor = op.output_nodes[0]
        if isinstance(density, float):
            current_density = density
        else:
            current_density = density[f"{op_name}/{TraceKey.OUTPUT_DENSITY}"]

        output_tensor.attrs[TraceKey.POINT] = argtopk(
            np.abs(output_tensor.value), current_density
        )

        output_tensor.attrs[TraceKey.POINT_SHAPE] = output_tensor.value.shape
        output_tensor.attrs[TraceKey.FLIP_SIGN] = None
        op.attrs[TraceKey.OP_TYPE] = type(op).__name__
        _trace_func_by_op[type(op)](
            op, select_fn=select_fn, debug=debug, update_input=False, *args, **kwargs
        )
    graph.attrs[TraceKey.COUNT] = 1


@trace_fn_wrapper
def get_per_receptive_field_unstructured_trace(
    graph: Graph,
    output_threshold: FloatOrDict,
    select_fn: Callable[[np.ndarray], np.ndarray],
    debug: bool = False,
    *args,
    **kwargs,
) -> AttrMap:
    for op_name in graph.ops_in_layers(DenseOp, Conv2dOp):
        op = graph.op(graph.id(op_name))
        output_tensor = op.output_nodes[0]
        if isinstance(output_threshold, float):
            current_output_threshold = output_threshold
        else:
            current_output_threshold = output_threshold[
                f"{op_name}/{TraceKey.OUTPUT_THRESHOLD}"
            ]

        output_tensor.attrs[TraceKey.POINT] = np.nonzero(
            np.abs(output_tensor.value.flatten()) > current_output_threshold
        )[0]

        output_tensor.attrs[TraceKey.POINT_SHAPE] = output_tensor.value.shape
        output_tensor.attrs[TraceKey.FLIP_SIGN] = None
        op.attrs[TraceKey.OP_TYPE] = type(op).__name__
        _trace_func_by_op[type(op)](
            op, select_fn=select_fn, debug=debug, update_input=False, *args, **kwargs
        )
    graph.attrs[TraceKey.COUNT] = 1


@trace_fn_wrapper
def get_per_input_unstructured_trace(
    graph: Graph,
    output_threshold: FloatOrDict,
    input_threshold: FloatOrDict,
    select_fn: Callable[[np.ndarray], np.ndarray] = None,
    debug: bool = False,
    *args,
    **kwargs,
) -> AttrMap:
    for op_name in graph.ops_in_layers(DenseOp, Conv2dOp):
        op = graph.op(graph.id(op_name))
        output_tensor = op.output_nodes[0]
        if isinstance(output_threshold, float):
            current_output_threshold = output_threshold
        else:
            current_output_threshold = output_threshold[
                f"{op_name}/{TraceKey.OUTPUT_THRESHOLD}"
            ]
        if isinstance(input_threshold, float):
            current_input_threshold = input_threshold
        else:
            current_input_threshold = input_threshold[
                f"{op_name}/{TraceKey.RECEPTIVE_FIELD_THRESHOLD}"
            ]

        output_tensor.attrs[TraceKey.POINT] = np.nonzero(
            np.abs(output_tensor.value.flatten()) > current_output_threshold
        )[0]

        output_tensor.attrs[TraceKey.POINT_SHAPE] = output_tensor.value.shape
        output_tensor.attrs[TraceKey.FLIP_SIGN] = None
        op.attrs[TraceKey.OP_TYPE] = type(op).__name__
        select_fn = lambda input: np.nonzero(
            input.flatten() >= current_input_threshold
        )[0]
        _trace_func_by_op[type(op)](
            op, select_fn=select_fn, debug=debug, update_input=False, *args, **kwargs
        )
    graph.attrs[TraceKey.COUNT] = 1


def reconstruct_static_trace(graph: Graph, density: float):
    for op in graph.ops:
        if isinstance(op, (DenseOp, Conv2dOp)):
            weight = get_weight(op).value
            op.attrs[TraceKey.WEIGHT] = argtopk(np.abs(weight), density)
            op.attrs[TraceKey.WEIGHT_SHAPE] = weight.shape


def reconstruct_stat(
    graph: Graph,
    stat_name: str = None,
    data_format: str = "channels_first",
    stop_hook: Callable[[Operation], bool] = None,
) -> Dict[str, np.ndarray]:
    stat_name = stat_name or "avg"
    stat_name_to_fn = {"avg": np.average, "max": np.amax}
    stat = {}
    for op_name in reversed(graph.ops_in_layers(DenseOp, Conv2dOp)):
        op = graph.op(graph.id(op_name))
        if stop_hook is not None and stop_hook(op):
            break
        tensor = op.output_nodes[0].value
        if isinstance(op, Conv2dOp):
            if data_format == "channels_first":
                tensor = stat_name_to_fn[stat_name](tensor, axis=(1, 2))
            else:
                tensor = stat_name_to_fn[stat_name](tensor, axis=(0, 1))
        stat[op_name] = tensor
    return stat

def merge_contrib_by_key(
    traced_key,
    key_contrib,
):
    # unique_traced_key = np.unique(traced_key)
    # # unique_contrib = np.zeros(unique_traced_points.shape).astype(np.int32)
    # # for i, point in enumerate(unique_traced_points):
    # #     unique_contrib[i] = traced_point_contrib[traced_points == point].sum()
    # unique_contrib = np.array([
    #     key_contrib[traced_key == key].sum()
    #     for key in unique_traced_key
    # ])
    # zero_index = np.where(unique_contrib == 0)
    # # if (unique_contrib == 0).sum() > 0:
    # #     st()
    # unique_traced_key = np.delete(
    #     unique_traced_key, zero_index
    # )
    # unique_contrib = np.delete(
    #     unique_contrib, zero_index
    # )
    # return unique_traced_key, unique_contrib

    df = pd.DataFrame(dict(
        point=traced_key,
        contrib=key_contrib,
    ))
    merged_df = (
        df["contrib"]
        .groupby(df["point"])
        .aggregate('sum')
    )
    merged_df = merged_df[merged_df != 0]
    return merged_df.index.values, merged_df.values
    


def merge_traced_points(
    tensor: Tensor,
    op: Operation,
    traced_points: np.ndarray,
    flip_sign: Optional[np.ndarray],
    traced_point_contrib = None,
    is_unique: bool = False,
    update_input: bool = True,
):
    tensor.attrs[TraceKey.POINT_SHAPE] = tensor.value.shape
    if not update_input:
        return
    # Preprocess input, aggregate points
    if not is_unique:
        if flip_sign is None:
            if traced_point_contrib is None:
                traced_points = np.unique(traced_points)
            else:
                traced_points, traced_point_contrib = merge_contrib_by_key(
                    traced_points, traced_point_contrib,
                )
        else:
            if traced_point_contrib is None:
                df = pd.DataFrame(dict(
                    point=traced_points, 
                    flip_sign=flip_sign
                ))
                merged_df = (
                    df["flip_sign"]
                    .groupby(df["point"])
                    .aggregate(lambda flip_signs: flip_signs.values[0])
                )
                traced_points = merged_df.index.values
                flip_sign = merged_df.values
            else:
                df = pd.DataFrame(dict(
                    point=traced_points,
                    flip_sign=flip_sign,
                    contrib=traced_point_contrib,
                ))
                merged_flip_sign = (
                    df["flip_sign"]
                    .groupby(df["point"])
                    .aggregate(lambda flip_signs: flip_signs.values[0])
                )
                merged_contrib = (
                    df["contrib"]
                    .groupby(df["point"])
                    .aggregate('sum')
                )
                merged_df = pd.concat(
                    [merged_contrib, merged_flip_sign], axis=1
                )
                merged_df = merged_df[merger_df.contrib != 0]
                traced_points = merged_df.index.values
                flip_sign = merged_df.flip_sign.values
                traced_point_contrib = merged_df.contrib.values
                
    # Log current traced_points, flip_sign and contrib
    op_index = tensor.outputs.index(op.id)
    tensor.attrs[TraceKey.POINT + f".{op_index}"] = traced_points
    tensor.attrs[TraceKey.FLIP_SIGN + f".{op_index}"] = flip_sign
    if traced_point_contrib is not None:
        tensor.attrs[TraceKey.POINT_CONTRIB + f".{op_index}"] = traced_point_contrib
        
    # Combine to the original point attrs, including flip sign and contrib
    if TraceKey.POINT in tensor.attrs:
        if tensor.attrs[TraceKey.FLIP_SIGN] is None and flip_sign is None:
            # Both flip signs are None, only combine points and contribs
            tensor.attrs[TraceKey.FLIP_SIGN] = None
            if traced_point_contrib is None:
                tensor.attrs[TraceKey.POINT] = np.unique(
                    concatenate(
                        [traced_points, tensor.attrs[TraceKey.POINT]], dtype=np.int32
                    )
                )
            else:
                all_traced_points = concatenate(
                    [tensor.attrs[TraceKey.POINT], traced_points], dtype=np.int32
                )
                all_contrib = concatenate(
                    [tensor.attrs[TraceKey.POINT_CONTRIB], traced_point_contrib],
                    dtype=np.int32,
                )
                traced_points, traced_point_contrib = merge_contrib_by_key(
                    all_traced_points, all_contrib,
                )
                tensor.attrs[TraceKey.POINT] = traced_points
                tensor.attrs[TraceKey.POINT_CONTRIB] = traced_point_contrib
        else:
            if tensor.attrs[TraceKey.FLIP_SIGN] is None:
                tensor.attrs[TraceKey.FLIP_SIGN] = np.repeat(
                    1, tensor.attrs[TraceKey.POINT].size
                )
            if flip_sign is None:
                flip_sign = np.repeat(1, traced_points.size)

            def merge_flip_sign(flip_signs: pd.Series):
                flip_signs = flip_signs.values
                if flip_signs.size == 1:
                    return flip_signs[0]
                else:
                    assert flip_signs.size == 2
                    if flip_signs[0] == flip_signs[1]:
                        return flip_signs[0]
                    else:
                        raise RuntimeError("Not checked error")
                        if TraceKey.FLIP_SIGN_CONFLICT not in tensor.attrs:
                            tensor.attrs[TraceKey.FLIP_SIGN_CONFLICT] = 0
                        tensor.attrs[TraceKey.FLIP_SIGN_CONFLICT] += 1
                        return 1
                    
            all_traced_points = concatenate(
                [tensor.attrs[TraceKey.POINT], traced_points], dtype=np.int32
            )
            all_flip_sign = concatenate(
                [tensor.attrs[TraceKey.FLIP_SIGN], flip_sign], dtype=np.int32
            )
            if traced_point_contrib is None:
                df = pd.DataFrame(dict(
                    point=all_traced_points, 
                    flip_sign=all_flip_sign
                ))
                merged_df = (
                    df["flip_sign"]
                    .groupby(df["point"])
                    .aggregate(merge_flip_sign)
                )
                tensor.attrs[TraceKey.POINT] = merged_df.index.values
                if np.all(merged_df.values == 1):
                    tensor.attrs[TraceKey.FLIP_SIGN] = None
                else:
                    tensor.attrs[TraceKey.FLIP_SIGN] = merged_df.values
            else:
                all_contrib = concatenate(
                    [tensor.attrs[TraceKey.POINT_CONTRIB], traced_point_contrib],
                    dtype=np.int32,
                )
                df = pd.DataFrame(dict(
                    point=all_traced_points,
                    flip_sign=all_flip_sign,
                    contrib=all_contrib,
                ))
                merged_flip_sign = (
                    df["flip_sign"]
                    .groupby(df["point"])
                    .aggregate(merge_flip_sign)
                )
                merged_contrib = (
                    df["contrib"]
                    .groupby(df["point"])
                    .aggregate('sum')
                )
                merged_df = pd.concat(
                    [merged_contrib, merged_flip_sign], axis=1
                )
                merged_df = merged_df[merged_df.contrib != 0]
                
                tensor.attrs[TraceKey.POINT] = merged_df.index.values
                if np.all(merged_df.flip_sign == 1):
                    tensor.attrs[TraceKey.FLIP_SIGN] = None
                else:
                    tensor.attrs[TraceKey.FLIP_SIGN] = merged_df.flip_sign.values
                tensor.attrs[TraceKey.POINT_CONTRIB] = merged_df.contrib.values
    else:
        tensor.attrs[TraceKey.POINT] = traced_points
        if traced_point_contrib is not None:
            tensor.attrs[TraceKey.POINT_CONTRIB] = traced_point_contrib
        if flip_sign is not None and np.all(flip_sign == 1):
            tensor.attrs[TraceKey.FLIP_SIGN] = None
        else:
            tensor.attrs[TraceKey.FLIP_SIGN] = flip_sign


def calc_padding(
    input_shape: np.ndarray,
    output_shape: np.ndarray,
    stride: np.ndarray,
    kernel_size: np.ndarray,
) -> np.ndarray:
    margin = ((output_shape - 1) * stride) + kernel_size - input_shape
    margin[margin < 0] = 0
    padding = np.zeros((3, 2), np.int32)
    for i in [0, 1]:
        if margin[i] % 2 == 0:
            padding[i + 1] = np.array([margin[i] // 2, margin[i] // 2])
        else:
            padding[i + 1] = np.array([(margin[i] - 1) // 2, (margin[i] + 1) // 2])
    return padding


def calc_flip_sign(
    flip_sign,
    index,
    output_value,
    weighted_input,
    select_fn,
    flip_sign_inputs,
    
    return_threshold: bool = False,
):
    if flip_sign is not None:
        flipped_output_value = output_value * flip_sign[index]
    else:
        flipped_output_value = output_value
    # if isinstance(flipped_output_value, np.ndarray):
    #     st()
    if flipped_output_value < 0:
        flipped_weighed_input = -weighted_input
    else:
        flipped_weighed_input = weighted_input
    input_points = select_fn(flipped_weighed_input)
    if flip_sign is not None:
        if flip_sign[index] == -1 and flipped_weighed_input.max() < 0:
            new_flip_sign = -1
        else:
            new_flip_sign = 1
        flip_sign_inputs.append(repeat(new_flip_sign, input_points.size))
        # flip_sign_inputs += list(repeat(new_flip_sign, input_points.size))
    if return_threshold:
        return (
            input_points,
            float(np.min(flipped_weighed_input.flatten()[input_points])),
        )
    else:
        return input_points
    
def calc_flip_sign_with_class_op(
    index,
    contrib,
    output_value,
    weighted_input,
    select_fn,
    class_op,
    contrib_inputs,
    return_threshold: bool = False,
):
    input_points = select_fn(
        weighted_input,
        output_value,
    )
    selected_value = weighted_input.flatten()[input_points]
    # contrib = sign_cur * sign_father * contrib_father
    per_input_contrib = (
        np.sign(selected_value) * 
        np.sign(output_value) * 
        np.sign(contrib[index])
    )

    contrib_inputs += per_input_contrib.tolist()
    if TraceKey.DEBUG_FLAG:
        print(f"Index {index}")
        print(f"weighted input {weighted_input}")
        print(f"output {output_value}, output contrib {contrib[index]}")
        if len(input_points) > 0:
            print(f"selected biased input value {weighted_input.flatten()[input_points]}")
            print(f"input contrib {per_input_contrib}")
        else:
            print(f"do not have selected biased input value")
        if contrib[index] < 0:
            st()
    if return_threshold:
        if len(input_points) > 0:
            threshold = float(np.min(np.abs(selected_value)))
        else:
            threshold = np.inf
        return (
            input_points,
            threshold,
        )
    else:
        return input_points


def linear_layer_trace(
    op: DenseOp,
    select_fn: Callable[[np.ndarray], np.ndarray],
    debug: bool,
    update_input: bool = True,
    collect_metrics: bool = False,
    class_op = None,
    *args,
    **kwargs,
):
    weight = op.weight.value
    input_tensor: Tensor = op.input_nodes[0]
    output_tensor: Tensor = op.output_nodes[0]
    if class_op is None:
        input = input_tensor.value.copy()
        output: np.ndarray = output_tensor.value.copy()
        op_logger = OpAvgLogger(input, output)
        op.attrs[TraceKey.IO_AVG] = op_logger
        contrib_inputs = None
        
    else:
        input = input_tensor.value - class_op.input_avg()
        output = output_tensor.value - class_op.output_avg()
        if op.bias is not None:
            output += op.bias.value
        
        contrib = output_tensor.attrs[TraceKey.POINT_CONTRIB]
        contrib_inputs = []
        
    output_points = output_tensor.attrs[TraceKey.POINT]
    if len(output_points) == 0:
        trivial_layer_trace(op)
        return
    flip_sign = output_tensor.attrs[TraceKey.FLIP_SIGN]
    output_trace_points = []
    input_trace_points = []
    weighted_inputs = []
    flip_sign_inputs = []
    receptive_field_density = []
    receptive_field_threshold = []
    for index, output_point in enumerate(output_points):
        weighted_input = weight[output_point] * input
        output_value = output[output_point]
        
        # check
        if mode.is_check():
            if op.bias is not None:
                weighted_input_sum = (
                    np.sum(weighted_input) + op.bias.value[output_point]
                )
            else:
                weighted_input_sum = np.sum(weighted_input)
            if not abs(output_value - weighted_input_sum) < EPS * weighted_input.size:
                raise RuntimeError(f"left {abs(output_value - weighted_input_sum)}\n"
                                f"right {EPS * weighted_input.size}\n"
                                f"size {weighted_input.size}\n"
                                f"index {index}\n"
                                f"output value {output_value}\n"
                                f"weighted input sum {weighted_input_sum}\n"
                                f"raw output {op.output_nodes[0].value[output_point]}\n"
                                f"output avg {class_op.output_avg()}\n"
                                f"id {TraceKey.BUG_IMAGEID}")
            assert abs(output_value - weighted_input_sum) < EPS * weighted_input.size
            
            
        if class_op is None:
            result = calc_flip_sign(
                flip_sign=flip_sign,
                index=index,
                output_value=output_value,
                weighted_input=weighted_input,
                select_fn=select_fn,
                flip_sign_inputs=flip_sign_inputs,
                return_threshold=collect_metrics,
            )
        else:
            result = calc_flip_sign_with_class_op(
                index=index,
                contrib=contrib,
                output_value=output_value,
                weighted_input=weighted_input,
                select_fn=select_fn,
                class_op=class_op,
                contrib_inputs=contrib_inputs,
                return_threshold=collect_metrics,
            )
        if collect_metrics:
            input_points, threshold = result
            receptive_field_threshold.append(threshold)
            receptive_field_density.append(input_points.size / weighted_input.size)
        else:
            input_points = result
        output_trace_points.append(repeat(output_point, input_points.size))
        input_trace_points.append(input_points)
        if debug:
            weighted_inputs.append(weighted_input[input_points])
    output_trace_points = concatenate(output_trace_points, dtype=np.int32)
    input_trace_points = concatenate(input_trace_points, dtype=np.int32)
    if debug:
        weighted_inputs = concatenate(weighted_inputs, dtype=np.float32)
        op.attrs[TraceKey.WEIGHTED_INPUT] = weighted_inputs
    if flip_sign is not None:
        flip_sign_inputs = concatenate(flip_sign_inputs, dtype=np.int32)
    else:
        flip_sign_inputs = None
    edge_shape = (input.size, output.size)
    op.attrs[TraceKey.EDGE] = np.ravel_multi_index(
        (input_trace_points, output_trace_points), edge_shape
    )
    op.attrs[TraceKey.WEIGHT] = np.ravel_multi_index(
        (output_trace_points, input_trace_points), weight.shape
    )
    op.attrs[TraceKey.EDGE_SHAPE] = edge_shape
    op.attrs[TraceKey.WEIGHT_SHAPE] = weight.shape
    
    if class_op is None:
        ...
    else:
        contrib_inputs = np.array(contrib_inputs)
        op.attrs[TraceKey.EDGE_CONTRIB] = contrib_inputs
        op.attrs[TraceKey.WEIGHT_CONTRIB] = contrib_inputs

    if collect_metrics:
        op.attrs[TraceKey.OUTPUT_DENSITY] = len(output_points) / output.size
        op.attrs[TraceKey.OUTPUT_THRESHOLD] = np.sort(np.abs(output), axis=None)[
            output.size - len(output_points)
        ]
        op.attrs[TraceKey.RECEPTIVE_FIELD_DENSITY] = np.average(receptive_field_density)
        op.attrs[TraceKey.RECEPTIVE_FIELD_THRESHOLD] = np.average(
            receptive_field_threshold
        )
    merge_traced_points(
        input_tensor,
        op,
        input_trace_points,
        flip_sign=flip_sign_inputs,
        traced_point_contrib=contrib_inputs,
        update_input=update_input,
    )


register_op(DenseOp, linear_layer_trace)


def max_layer_trace(
    op: MaxPoolOp, 
    debug: bool, 
    class_op = None,
    *args, 
    **kwargs
):
    kernel_size = np.array(op.filter_shape)
    stride = np.array(op.strides)

    radius = np.zeros_like(kernel_size)
    for i in [0, 1]:
        if kernel_size[i] % 2 == 0:
            radius[i] = kernel_size[i] // 2
        else:
            radius[i] = (kernel_size[i] - 1) // 2

    input_tensor: Tensor = op.input_nodes[0]
    input = input_tensor.value
    output_tensor: Tensor = op.output_nodes[0]
    output = output_tensor.value
    if class_op is None:
        op_logger = OpAvgLogger(input, output)
        op.attrs[TraceKey.IO_AVG] = op_logger
    else:
        # input -= class_op.input_avg()
        # output -= class_op.output_avg()
        contrib = output_tensor.attrs[TraceKey.POINT_CONTRIB]
        contrib_inputs = []
        ...
    output_points = output_tensor.attrs[TraceKey.POINT]
    if len(output_points) == 0:
        trivial_layer_trace(op)
        return
    flip_sign = output_tensor.attrs[TraceKey.FLIP_SIGN]
    if op.data_format == "NHWC":
        input = np.rollaxis(input, 2)
        output = np.rollaxis(output, 2)
    elif op.data_format != "NCHW":
        raise RuntimeError(f"{op.data_format} is not supported value of data format")

    padding = calc_padding(
        np.array(input.shape)[1:], np.array(output.shape)[1:], stride, kernel_size
    )
    padded_input = np.pad(input, padding, mode="constant")
    
    input_trace_points = []
    output_trace_points = []
    weighted_inputs = []
    flip_sign_inputs = []
    for (output_point_pos, output_point), output_point_index in zip(
        enumerate(output_points), zip(*np.unravel_index(output_points, output.shape))
    ):
        index = np.array(output_point_index)[1:]
        center_index = radius + index * stride
        start_index = center_index - radius
        end_index = np.zeros_like(center_index)
        for i in [0, 1]:
            if kernel_size[i] % 2 == 0:
                end_index[i] = center_index[i] + radius[i] - 1
            else:
                end_index[i] = center_index[i] + radius[i]
            start_bound = padding[i + 1][0]
            end_bound = input.shape[i + 1] + start_bound
            if start_index[i] < start_bound:
                start_index[i] = start_bound
            if end_index[i] >= end_bound:
                end_index[i] = end_bound - 1
        receptive_field = padded_input[
            (
                output_point_index[0],
                slice(start_index[0], end_index[0] + 1),
                slice(start_index[1], end_index[1] + 1),
            )
        ]
        output_value = output[output_point_index]

        for unaligned_max_input_pos in np.argwhere(
            receptive_field == np.max(receptive_field)
        ):
            max_input_pos = (
                output_point_index[0],
                unaligned_max_input_pos[0] + start_index[0] - padding[1][0],
                unaligned_max_input_pos[1] + start_index[1] - padding[2][0],
            )
            output_trace_points.append(output_point)
            input_trace_points.append(np.ravel_multi_index(max_input_pos, input.shape))
            contrib_inputs.append(contrib[output_point_pos])
            if flip_sign is not None:
                flip_sign_inputs.append(flip_sign[output_point_pos])
            if debug:
                weighted_inputs.append(output_value)
            if mode.is_check():
                max_input_value = input[max_input_pos]
                if abs(max_input_value - output_value) > EPS:
                    print(
                        f"op: {op.name}, output index: {output_point_index}, "
                        f"max input: {max_input_value}, output: {output_value}"
                    )
                    raise ValueError()

    output_trace_points = np.array(output_trace_points, dtype=np.int32)
    input_trace_points = np.array(input_trace_points, dtype=np.int32)
    if debug:
        weighted_inputs = np.array(weighted_inputs)
        op.attrs[TraceKey.WEIGHTED_INPUT] = weighted_inputs
    
    if flip_sign is not None:
        flip_sign_inputs = np.array(flip_sign_inputs, dtype=np.int32)
    else:
        flip_sign_inputs = None
        
    # edge
    edge_shape = (input.size, output.size)
    op.attrs[TraceKey.EDGE] = np.ravel_multi_index(
        (input_trace_points, output_trace_points), edge_shape
    )
    op.attrs[TraceKey.EDGE_SHAPE] = tuple(kernel_size) + output.shape
    
    if class_op is None:
        ...
    else:
        contrib_inputs = np.array(contrib_inputs, dtype=np.int32)
        op.attrs[TraceKey.EDGE_CONTRIB] = contrib_inputs
    
    merge_traced_points(
        input_tensor, 
        op, 
        input_trace_points, 
        flip_sign=flip_sign_inputs,
        traced_point_contrib=contrib_inputs,
    )


register_op(MaxPoolOp, max_layer_trace)


def avg_layer_trace(
    op: AvgPoolOp,
    select_fn: Callable[[np.ndarray], np.ndarray],
    debug: bool,
    class_op = None,
    *args,
    **kwargs,
):
    kernel_size = np.array(op.filter_shape)
    stride = np.array(op.strides)

    radius = np.zeros_like(kernel_size)
    for i in [0, 1]:
        if kernel_size[i] % 2 == 0:
            radius[i] = kernel_size[i] // 2
        else:
            radius[i] = (kernel_size[i] - 1) // 2

    input_tensor: Tensor = op.input_nodes[0]
    input = input_tensor.value
    output_tensor: Tensor = op.output_nodes[0]
    output = output_tensor.value
    if class_op is None:
        op_logger = OpAvgLogger(input, output)
        op.attrs[TraceKey.IO_AVG] = op_logger
        contrib_inputs = None
    else:
        input -= class_op.input_avg()
        output -= class_op.output_avg()
        contrib = output_tensor.attrs[TraceKey.POINT_CONTRIB]
        contrib_inputs = []
        ...
    output_points = output_tensor.attrs[TraceKey.POINT]
    if len(output_points) == 0:
        trivial_layer_trace(op)
        return
    flip_sign = output_tensor.attrs[TraceKey.FLIP_SIGN]
    if op.data_format == "NHWC":
        input = np.rollaxis(input, 2)
        output = np.rollaxis(output, 2)
    elif op.data_format != "NCHW":
        raise RuntimeError(f"{op.data_format} is not supported value of data format")

    padding = calc_padding(
        np.array(input.shape)[1:], np.array(output.shape)[1:], stride, kernel_size
    )
    padded_input = np.pad(input, padding, mode="constant")

    input_trace_points = []
    output_trace_points = []
    weighted_inputs = []
    flip_sign_inputs = []
    for (output_point_pos, output_point), output_point_index in zip(
        enumerate(output_points), zip(*np.unravel_index(output_points, output.shape))
    ):
        output_value = output[output_point_index]
        index = np.array(output_point_index)[1:]
        center_index = radius + index * stride
        start_index = center_index - radius
        end_index = np.zeros_like(center_index)
        for i in [0, 1]:
            if kernel_size[i] % 2 == 0:
                end_index[i] = center_index[i] + radius[i] - 1
            else:
                end_index[i] = center_index[i] + radius[i]
            start_bound = padding[i + 1][0]
            end_bound = input.shape[i + 1] + start_bound
            if start_index[i] < start_bound:
                start_index[i] = start_bound
            if end_index[i] >= end_bound:
                end_index[i] = end_bound - 1
        receptive_field = padded_input[
            (
                output_point_index[0],
                slice(start_index[0], end_index[0] + 1),
                slice(start_index[1], end_index[1] + 1),
            )
        ]
        weighted_input = receptive_field
        if mode.is_check():
            weighted_input_avg = np.average(weighted_input)
            if abs(weighted_input_avg - output_value) > EPS * weighted_input.size:
                print(
                    f"op: {op.name}, output index: {output_point_index}, "
                    f"weighted input avg: {weighted_input_avg}, output: {output_value}"
                )
                raise ValueError()
        if class_op is None:
            unaligned_input_points = calc_flip_sign(
                flip_sign=flip_sign,
                index=output_point_pos,
                output_value=output_value,
                weighted_input=weighted_input,
                select_fn=select_fn,
                flip_sign_inputs=flip_sign_inputs,
            )
        else:
            unaligned_input_points = calc_flip_sign_with_class_op(
                index=output_point_pos,
                contrib=contrib,
                output_value=output_value,
                weighted_input=weighted_input,
                select_fn=select_fn,
                class_op=class_op,
                contrib_inputs=contrib_inputs,
            )
        unaligned_input_index = np.unravel_index(
            unaligned_input_points, weighted_input.shape
        )
        input_index = (
            repeat(output_point_index[0], unaligned_input_index[0].size),
            unaligned_input_index[0] + start_index[0] - padding[1][0],
            unaligned_input_index[1] + start_index[1] - padding[2][0],
        )
        repeated_output = repeat(output_point, input_index[0].size)
        output_trace_points.append(repeated_output)
        input_points = np.ravel_multi_index(input_index, input.shape)
        input_trace_points.append(input_points)
        if debug:
            weighted_inputs.append(weighted_input[unaligned_input_index])

    output_trace_points = concatenate(output_trace_points, dtype=np.int32)
    input_trace_points = concatenate(input_trace_points, dtype=np.int32)
    if debug:
        weighted_inputs = concatenate(weighted_inputs, dtype=np.float32)
        op.attrs[TraceKey.WEIGHTED_INPUT] = weighted_inputs
    if flip_sign is not None:
        flip_sign_inputs = concatenate(flip_sign_inputs, dtype=np.int32)
    else:
        flip_sign_inputs = None
    edge_shape = (input.size, output.size)
    op.attrs[TraceKey.EDGE] = np.ravel_multi_index(
        (input_trace_points, output_trace_points), edge_shape
    )
    op.attrs[TraceKey.EDGE_SHAPE] = tuple(kernel_size) + output.shape
    if class_op is None:
        ...
    else:
        contrib_inputs = np.array(contrib_inputs)
        op.attrs[TraceKey.EDGE_CONTRIB] = contrib_inputs
    merge_traced_points(
        input_tensor, 
        op, 
        input_trace_points, 
        flip_sign=flip_sign_inputs,
        traced_point_contrib=contrib_inputs,
    )


register_op(AvgPoolOp, avg_layer_trace)


def conv2d_layer_trace(
    op: Conv2dOp,
    select_fn: Callable[[np.ndarray], np.ndarray],
    debug: bool,
    update_input: bool = True,
    collect_metrics: bool = False,
    class_op = None,
    *args,
    **kwargs,
):
    weight: np.ndarray = op.kernel.value
    kernel_size = np.array(weight.shape)[2:]
    stride = np.array(op.strides)
    radius = np.zeros_like(kernel_size)
    for i in [0, 1]:
        if kernel_size[i] % 2 == 0:
            radius[i] = kernel_size[i] // 2
        else:
            radius[i] = (kernel_size[i] - 1) // 2

    input_tensor: Tensor = op.input_nodes[0]
    output_tensor: Tensor = op.output_nodes[0]
    if class_op is None:
        input = input_tensor.value.copy()
        output = output_tensor.value.copy()
        op_logger = OpAvgLogger(input, output)
        op.attrs[TraceKey.IO_AVG] = op_logger
        contrib_inputs = None
        
    else:
        input = input_tensor.value - class_op.input_avg()
        output = output_tensor.value - class_op.output_avg()
        if op.bias is not None:
            bias = np.expand_dims(
                    np.expand_dims(op.bias.value, axis=-1),
                    axis=-1
            )
            output += bias
            
        contrib = output_tensor.attrs[TraceKey.POINT_CONTRIB]
        contrib_inputs = []
    output_points = output_tensor.attrs[TraceKey.POINT]
    if len(output_points) == 0:
        trivial_layer_trace(op)
        return
    flip_sign = output_tensor.attrs[TraceKey.FLIP_SIGN]
    if op.data_format == "NHWC":
        input = np.rollaxis(input, 2)
        output = np.rollaxis(output, 2)
    elif op.data_format != "NCHW":
        raise RuntimeError(f"{op.data_format} is not supported value of data format")

    padding = calc_padding(
        np.array(input.shape)[1:], np.array(output.shape)[1:], stride, kernel_size
    )
    padded_input = np.pad(input, padding, mode="constant")

    output_trace_points = []
    input_trace_points = []
    weight_indices = []
    weighted_inputs = []
    flip_sign_inputs = []
    receptive_field_threshold = []
    receptive_field_density = []
    for (output_point_pos, output_point), output_point_index in zip(
        enumerate(output_points), zip(*np.unravel_index(output_points, output.shape))
    ):
        output_value = output[output_point_index]
        index = np.array(output_point_index)[1:]
        center_index = radius + index * stride
        start_index = center_index - radius
        end_index = np.zeros_like(center_index)
        for i in [0, 1]:
            if kernel_size[i] % 2 == 0:
                end_index[i] = center_index[i] + radius[i] - 1
            else:
                end_index[i] = center_index[i] + radius[i]
        receptive_field = padded_input[
            (
                slice(None),
                slice(start_index[0], end_index[0] + 1),
                slice(start_index[1], end_index[1] + 1),
            )
        ]
        weighted_input = receptive_field * weight[output_point_index[0], ...]
        for i in [0, 1]:
            start_bound = padding[i + 1][0]
            end_bound = input.shape[i + 1] + start_bound
            if start_index[i] < start_bound:
                bound_filter = [slice(None), slice(None), slice(None)]
                bound_filter[i + 1] = slice(start_bound - start_index[i], None)
                weighted_input = weighted_input[tuple(bound_filter)]
                start_index[i] = start_bound
            if end_index[i] >= end_bound:
                bound_filter = [slice(None), slice(None), slice(None)]
                bound_filter[i + 1] = slice(None, end_bound - 1 - end_index[i])
                weighted_input = weighted_input[tuple(bound_filter)]
                end_index[i] = end_bound - 1
                
        if mode.is_check():
            if op.bias is not None:
                weighted_input_sum = (
                    np.sum(weighted_input) + op.bias.value[output_point_index[0]]
                )
            else:
                weighted_input_sum = np.sum(weighted_input)
            if abs(weighted_input_sum - output_value) > EPS * weighted_input.size:
                print(
                    f"op: {op.name}, output index: {output_point_index}, "
                    f"weighted input sum: {weighted_input_sum}, output: {output_value}"
                )
                raise ValueError()
        
        if class_op is None:
            result = calc_flip_sign(
                flip_sign=flip_sign,
                index=output_point_pos,
                output_value=output_value,
                weighted_input=weighted_input,
                select_fn=select_fn,
                flip_sign_inputs=flip_sign_inputs,
                return_threshold=collect_metrics,
            )
        else:
            result = calc_flip_sign_with_class_op(
                index=output_point_pos,
                contrib=contrib,
                output_value=output_value,
                weighted_input=weighted_input,
                select_fn=select_fn,
                class_op=class_op,
                contrib_inputs=contrib_inputs,
                return_threshold=collect_metrics,
            )
        if collect_metrics:
            unaligned_input_points, threshold = result
            receptive_field_threshold.append(threshold)
            receptive_field_density.append(
                unaligned_input_points.size / weighted_input.size
            )
        else:
            unaligned_input_points = result
        if len(unaligned_input_points) == 0:
            continue
        unaligned_input_index = np.unravel_index(
            unaligned_input_points, weighted_input.shape
        )
        input_index = (
            unaligned_input_index[0],
            unaligned_input_index[1] + start_index[0] - padding[1][0],
            unaligned_input_index[2] + start_index[1] - padding[2][0],
        )
        repeated_output = repeat(output_point, input_index[0].size)
        output_trace_points.append(repeated_output)
        input_points = np.ravel_multi_index(input_index, input.shape)
        input_trace_points.append(input_points)
        weight_index = np.ravel_multi_index(
            (repeat(output_point_index[0], unaligned_input_index[0].size),)
            + unaligned_input_index,
            weight.shape,
        )
        weight_indices.append(weight_index)
        if debug:
            weighted_inputs.append(weighted_input[unaligned_input_index])
    output_trace_points = concatenate(output_trace_points, dtype=np.int32)
    input_trace_points = concatenate(input_trace_points, dtype=np.int32)
    # if len(input_trace_points) == 0:
    #     st()
    weight_indices = concatenate(weight_indices, dtype=np.int32)
    if debug:
        weighted_inputs = concatenate(weighted_inputs, dtype=np.float32)
        op.attrs[TraceKey.WEIGHTED_INPUT] = weighted_inputs
    if flip_sign is not None:
        flip_sign_inputs = concatenate(flip_sign_inputs, dtype=np.int32)
    else:
        flip_sign_inputs = None
    edge_shape = (input.size, output.size)
    op.attrs[TraceKey.EDGE] = np.ravel_multi_index(
        (input_trace_points, output_trace_points), edge_shape
    )
    op.attrs[TraceKey.EDGE_SHAPE] = (
        (input.shape[0],) + tuple(kernel_size) + output.shape
    )
    
    # some contrib-related var and weight
    op.attrs[TraceKey.WEIGHT_SHAPE] = weight.shape
    if class_op is None:
        op.attrs[TraceKey.WEIGHT] = np.unique(weight_indices)
    else:
        contrib_inputs = np.array(contrib_inputs, dtype=np.int32)
        op.attrs[TraceKey.EDGE_CONTRIB] = contrib_inputs
        
        unique_weight, unique_weight_contrib = merge_contrib_by_key(
            weight_indices,
            contrib_inputs
        )
        op.attrs[TraceKey.WEIGHT] = unique_weight
        op.attrs[TraceKey.WEIGHT_CONTRIB] = unique_weight_contrib
    

    if collect_metrics:
        op.attrs[TraceKey.OUTPUT_DENSITY] = len(output_points) / output.size
        try:
            op.attrs[TraceKey.OUTPUT_THRESHOLD] = float(
                np.sort(np.abs(output), axis=None)[output.size - len(output_points)]
            )
        except:
            print(f"Error!!! output_points {output_points}")
            print(f"output size {output.size}")
            print(f"op {op.name}, image id {TraceKey.debug_image_id}")
            

        op.attrs[TraceKey.RECEPTIVE_FIELD_DENSITY] = np.average(receptive_field_density)
        op.attrs[TraceKey.RECEPTIVE_FIELD_THRESHOLD] = np.average(
            receptive_field_threshold
        )
    merge_traced_points(
        input_tensor,
        op,
        input_trace_points,
        flip_sign=flip_sign_inputs,
        traced_point_contrib=contrib_inputs,
        update_input=update_input,
    )


register_op(Conv2dOp, conv2d_layer_trace)


def add_layer_trace(
    op: AddOp,
    select_fn: Callable[[np.ndarray], np.ndarray],
    debug: bool,
    class_op = None,
    *args,
    **kwargs,
):
    left_input_tensor: Tensor = op.input_nodes[0]
    left_input: np.ndarray = left_input_tensor.value.copy()
    right_input_tensor: Tensor = op.input_nodes[1]
    right_input: np.ndarray = right_input_tensor.value.copy()
    both_input = np.transpose(np.array([left_input.flatten(), right_input.flatten()]))
    output_tensor: Tensor = op.output_nodes[0]
    output: np.ndarray = output_tensor.value.copy()
    flatten_output = output.flatten()
    if class_op is None:
        op_logger = OpAvgLogger(both_input, flatten_output)
        op.attrs[TraceKey.IO_AVG] = op_logger
        left_contrib_inputs = None
        right_contrib_inputs = None
    else:
        both_input -= class_op.input_avg()
        flatten_output -= class_op.output_avg()
        contrib = output_tensor.attrs[TraceKey.POINT_CONTRIB]
        left_contrib_inputs = []
        right_contrib_inputs = []
        
    output_points = output_tensor.attrs[TraceKey.POINT]
    if len(output_points) == 0:
        trivial_layer_trace(op)
        return
    flip_sign = output_tensor.attrs[TraceKey.FLIP_SIGN]
    left_input_trace_points = []
    right_input_trace_points = []
    weighted_inputs = []
    left_flip_sign_inputs = []
    right_flip_sign_inputs = []
    if mode.is_check():
        # assert np.all(np.abs((left_input + right_input) - output) < EPS * 2)
        assert np.all(np.abs(both_input.sum(1) - flatten_output) < EPS * 2)
    output_size = output.size
    for index, output_point in enumerate(output_points):
        output_value = flatten_output[output_point]
        flip_sign_inputs = []
        # if op.id == 805 and index == 26:
        #     st()
        if class_op is None:
            input_points = calc_flip_sign(
                flip_sign=flip_sign,
                index=index,
                output_value=output_value,
                weighted_input=both_input[output_point],
                select_fn=select_fn,
                flip_sign_inputs=flip_sign_inputs,
            )
        else:
            contrib_inputs  = []
            input_points = calc_flip_sign_with_class_op(
                index=index,
                contrib=contrib,
                output_value=output_value,
                weighted_input=both_input[output_point],
                select_fn=select_fn,
                class_op=class_op,
                contrib_inputs=contrib_inputs,
            )
        # print(op.id, index, input_points.size, len(flip_sign_inputs))
        # if input_points.size == 2 and len(flip_sign_inputs) == 1:
        #     st()
        if input_points.size == 1:
            if input_points[0] == 0:
                left_input_trace_points.append(output_point)
                if flip_sign is not None and class_op is None:
                    left_flip_sign_inputs.append(flip_sign_inputs[0])
                if class_op is not None:
                    left_contrib_inputs.append(contrib_inputs[0])
            else:
                right_input_trace_points.append(output_point)
                if flip_sign is not None and class_op is None:
                    right_flip_sign_inputs.append(flip_sign_inputs[0])
                if class_op is not None:
                    right_contrib_inputs.append(contrib_inputs[0])
        elif input_points.size == 2:
            left_input_trace_points.append(output_point)
            right_input_trace_points.append(output_point)
            if flip_sign is not None and class_op is None:
                left_flip_sign_inputs.append(flip_sign_inputs[0])
                right_flip_sign_inputs.append(flip_sign_inputs[1])
            if class_op is not None:
                left_contrib_inputs.append(contrib_inputs[0])
                right_contrib_inputs.append(contrib_inputs[1])
        if debug:
            weighted_inputs.append(both_input[output_point, input_points])
    left_input_trace_points = np.array(left_input_trace_points, dtype=np.int32)
    right_input_trace_points = np.array(right_input_trace_points, dtype=np.int32)
    if debug:
        weighted_inputs = concatenate(weighted_inputs, dtype=np.float32)
        op.attrs[TraceKey.WEIGHTED_INPUT] = weighted_inputs
    op.attrs[TraceKey.EDGE] = np.concatenate(
        [left_input_trace_points, right_input_trace_points + output_size]
    )
    op.attrs[TraceKey.EDGE_SHAPE] = (2, output_size)
    if flip_sign is not None:
        left_flip_sign_inputs = (
            concatenate(left_flip_sign_inputs, dtype=np.int32)
            if len(left_flip_sign_inputs) > 0
            else None
        )
        right_flip_sign_inputs = (
            concatenate(right_flip_sign_inputs, dtype=np.int32)
            if len(right_flip_sign_inputs) > 0
            else None
        )
    else:
        left_flip_sign_inputs = None
        right_flip_sign_inputs = None
    if class_op is None:
        ...
    else:
        left_contrib_inputs = np.array(left_contrib_inputs)
        right_contrib_inputs = np.array(right_contrib_inputs)
        contrib_inputs = np.concatenate(
            [left_contrib_inputs, right_contrib_inputs]
        )
        op.attrs[TraceKey.EDGE_CONTRIB] = contrib_inputs
        
        
    merge_traced_points(
        left_input_tensor,
        op,
        left_input_trace_points,
        flip_sign=left_flip_sign_inputs,
        traced_point_contrib=left_contrib_inputs,
        is_unique=True,
    )
    merge_traced_points(
        right_input_tensor,
        op,
        right_input_trace_points,
        flip_sign=right_flip_sign_inputs,
        traced_point_contrib=right_contrib_inputs,
        is_unique=True,
    )


register_op(AddOp, add_layer_trace)


def transpose_layer_trace(
    op: TransposeOp, 
    *args, 
    **kwargs
):
    perm = np.array(op.perm[1:]) - 1
    input_tensor: Tensor = op.input_nodes[0]
    input_shape = input_tensor.value.shape
    output_tensor: Tensor = op.output_nodes[0]
    if TraceKey.POINT_CONTRIB in output_tensor.attrs:
        output_contrib = output_tensor.attrs[TraceKey.POINT_CONTRIB]
    else:
        output_contrib = None
    output_points = output_tensor.attrs[TraceKey.POINT]
    if len(output_points) == 0:
        trivial_layer_trace(op)
        return
    output_shape = output_tensor.value.shape
    output_point_index = np.unravel_index(output_points, output_shape)
    input_to_output_perm = {
        input_axis: output_axis for output_axis, input_axis in enumerate(perm)
    }
    inverse_perm = [
        input_to_output_perm[input_axis] for input_axis in range(len(input_shape))
    ]
    input_point_index = tuple([output_point_index[axis] for axis in inverse_perm])
    merge_traced_points(
        input_tensor,
        op,
        np.ravel_multi_index(input_point_index, input_shape),
        flip_sign=output_tensor.attrs[TraceKey.FLIP_SIGN],
        traced_point_contrib=output_contrib,
        is_unique=True,
    )
    op.attrs[TraceKey.TRIVIAL] = True


register_op(TransposeOp, transpose_layer_trace)


def pad_layer_trace(
    op: PadOp, 
    class_op = None,
    *args, 
    **kwargs
):
    paddings = op.paddings[1:]
    input_tensor: Tensor = op.input_nodes[0]
    input_shape = input_tensor.value.shape
    output_tensor: Tensor = op.output_nodes[0]
    output_points = output_tensor.attrs[TraceKey.POINT]
    if len(output_points) == 0:
        trivial_layer_trace(op)
        return
    output = output_tensor.value
    output_point_index = np.unravel_index(output_points, output.shape)
    input_point_index = tuple(
        [
            output_point_index[axis] - paddings[axis][0]
            for axis in range(len(output_point_index))
        ]
    )
    input_filter = reduce(
        np.logical_and,
        [
            np.logical_and(
                input_point_index[axis] >= 0,
                input_point_index[axis] < input_shape[axis],
            )
            for axis in range(len(input_point_index))
        ],
    )
    filtered_input_point_index = tuple(
        [
            input_point_index[axis][input_filter]
            for axis in range(len(input_point_index))
        ]
    )
    if TraceKey.POINT_CONTRIB in output_tensor.attrs:
        output_contrib = output_tensor.attrs[TraceKey.POINT_CONTRIB]
        output_contrib = output_contrib[input_filter]
    else:
        output_contrib = None
    op.attrs[TraceKey.TRIVIAL] = True
    merge_traced_points(
        input_tensor,
        op,
        np.ravel_multi_index(filtered_input_point_index, input_shape),
        flip_sign=output_tensor.attrs[TraceKey.FLIP_SIGN],
        traced_point_contrib=output_contrib,
        is_unique=True,
    )


register_op(PadOp, pad_layer_trace)


def concat_layer_trace(op: ConcatOp, *args, **kwargs):
    raise RuntimeError("Contrib not implemented")
    axis = op.axis - 1
    input_tensors: Tensor = op.input_nodes
    input_shapes = list(map(lambda tensor: tensor.value.shape, input_tensors))
    output_tensor: Tensor = op.output_nodes[0]
    output_points = output_tensor.attrs[TraceKey.POINT]
    if len(output_points) == 0:
        trivial_layer_trace(op)
        return
    output = output_tensor.value
    output_point_index = np.unravel_index(output_points, output.shape)
    start_index = 0
    for input_tensor, input_shape in zip(input_tensors, input_shapes):
        end_index = start_index + input_shape[axis]
        input_filter = np.logical_and(
            output_point_index[axis] >= start_index,
            output_point_index[axis] < end_index,
        )
        input_point_index = list(map(lambda x: x[input_filter], output_point_index))
        input_point_index[axis] = input_point_index[axis] - start_index
        merge_traced_points(
            input_tensor,
            op,
            np.ravel_multi_index(input_point_index, input_shape),
            flip_sign=None,
            is_unique=True,
        )
        start_index = end_index
    op.attrs[TraceKey.TRIVIAL] = True


register_op(ConcatOp, concat_layer_trace)


def batch_norm_layer_trace(
    op: BatchNormOp, 
    class_op = None,
    *args, 
    **kwargs
):
    input_tensor: Tensor = op.input_nodes[0]
    input = input_tensor.value
    output_tensor: Tensor = op.output_nodes[0]
    output = output_tensor.value
    output_points = output_tensor.attrs[TraceKey.POINT]
    if len(output_points) == 0:
        trivial_layer_trace(op)
        return
    if TraceKey.POINT_CONTRIB in output_tensor.attrs:
        output_contrib = output_tensor.attrs[TraceKey.POINT_CONTRIB]
    else:
        output_contrib = None
    index = np.unravel_index(output_points, output.shape)
    flip_sign = np.sign(input[index], dtype=np.int32, casting="unsafe") * np.sign(
        output[index], dtype=np.int32, casting="unsafe"
    )
    flip_sign[flip_sign == 0] = 1
    if mode.is_check():
        lose_point_num = output_points.size - np.count_nonzero(flip_sign > 0)
        if lose_point_num != 0:
            lose_point_percentage = "{:.2f}%".format(
                lose_point_num / output_points.size * 100
            )
            print(
                f"{lose_point_num}/{output_points.size}({lose_point_percentage}) points flip their signs "
                f"in batch norm layer {op.name}"
            )
    merge_traced_points(
        input_tensor, 
        op, 
        output_points, 
        flip_sign=flip_sign, 
        traced_point_contrib=output_contrib,
        is_unique=True
    )
    op.attrs[TraceKey.TRIVIAL] = True


register_op(BatchNormOp, batch_norm_layer_trace)


def trivial_layer_trace(
    op,
    class_op = None,
    *args, 
    **kwargs
):
    for input_tensor in op.input_nodes:
        # input_tensor: Tensor = op.input_nodes[0]
        output_tensor: Tensor = op.output_nodes[0]
        if TraceKey.POINT_CONTRIB in output_tensor.attrs:
            output_contrib = output_tensor.attrs[TraceKey.POINT_CONTRIB]
        else:
            output_contrib = None
        merge_traced_points(
            input_tensor,
            op,
            output_tensor.attrs[TraceKey.POINT],
            flip_sign=output_tensor.attrs[TraceKey.FLIP_SIGN],
            traced_point_contrib=output_contrib,
            is_unique=True,
        )
    op.attrs[TraceKey.TRIVIAL] = True


register_op(ReluOp, trivial_layer_trace)
register_op(ReshapeOp, trivial_layer_trace)
register_op(SqueezeOp, trivial_layer_trace)
