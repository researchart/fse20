from typing import Union
from pdb import set_trace as st

import numpy as np

__all__ = ["argtopk", "arg_approx", "arg_approx_signed", "repeat", "concatenate"]


def get_int_k(array: np.ndarray, k: Union[int, float]) -> int:
    if type(k) is float:
        if 0.0 < k < 1.0:
            k = round(array.size * k)
            if k == array.size:
                return array.size - 1
            elif k == 0:
                return 1
            return k
        else:
            raise ValueError()
    else:
        return k


def argtopk(array: np.ndarray, k: Union[int, float]) -> np.ndarray:
    k = get_int_k(array, k)
    if k == 1:
        return np.array([np.argmax(array)])
    else:
        return np.argpartition(array, -k, axis=None)[-k:]


def arg_sorted_topk(array: np.ndarray, k: Union[int, float]) -> np.ndarray:
    # topk_index = argtopk(array, k)
    # sorted_index = np.array(list(reversed(np.argsort(array[topk_index]))))
    # return topk_index[sorted_index]
    k = get_int_k(array, k)
    return np.argsort(array)[::-1][:k]


def arg_approx(array: np.ndarray, precision: float) -> np.ndarray:
    if (1 / array.size) >= precision:
        return np.array([np.argmax(array)])
    input_sum = array.sum()
    if input_sum <= 0:
        return np.array([np.argmax(array)])
    input = array.flatten()
    threshold = input_sum * precision
    sorted_input = input.copy()
    sorted_input[::-1].sort()
    # topk = np.argmax(sorted_input.cumsum() >= threshold)
    topk = sorted_input.cumsum().searchsorted(threshold)
    if topk == len(input):
        return np.where(input > 0)[0]
    else:
        return argtopk(input, topk + 1)
    
def arg_abs_approx(
    input_array: np.ndarray, 
    biased_output: np.ndarray, 
    sum_precision_error: float,
    threshold_bar_ratio: float = 0.1,
) -> np.ndarray:
    if (1 / input_array.size) >= 1 - sum_precision_error:
        return np.array([np.argmax(input_array)])
    biased_input = input_array.flatten()
    input_sum = biased_input.sum()
    sorted_input = list(biased_input.copy())
    sorted_input = sorted(
        sorted_input,
        key=lambda x: abs(x),
        reverse=True,
    )
    # sum < min(array)
    if ( abs(input_sum) < abs(sorted_input[-1]) or 
        abs(input_sum) < abs(sorted_input[0] * 1e-3) ):
        return np.array([]).astype(np.int32)
    
    sorted_input_cum = np.array(sorted_input).cumsum()
    index = np.where(
            abs(sorted_input_cum - input_sum) < sum_precision_error * abs(input_sum)
        )[0]
    if len(index) == 0:
        raise RuntimeError(f"Index length is 0, "
                        f"input: {biased_input}, "
                        f"sorted input: {sorted_input}"
                        f"sorted input cum: {sorted_input_cum}"
                        f"input sum: {input_sum}, "
                        f"biased output: {biased_output} "
                        f"abs input sum {abs(input_sum)} & smallest input {sorted_input[-1]}")
    first_index = index[0]
    threshold = abs(sorted_input[first_index])
    threshold -= threshold * threshold_bar_ratio
    topk_index = np.where(np.abs(biased_input) > threshold)[0]
    return topk_index


# def arg_abs_approx(
#     input_array: np.ndarray, 
#     biased_output: np.ndarray, 
#     sum_precision_error: float,
#     threshold_bar_ratio: float = 0.1,
# ) -> np.ndarray:
#     if (1 / input_array.size) >= 1 - sum_precision_error:
#         return np.array([np.argmax(abs(input_array))])
#     biased_input = input_array.flatten()
#     input_sum = biased_input.sum()
#     sorted_input = list(biased_input.copy())
#     sorted_input = sorted(
#         sorted_input,
#         key=lambda x: abs(x),
#         reverse=True,
#     )
#     # sum < min(array)
#     sorted_input_cum = np.array(sorted_input).cumsum()
#     if ( abs(input_sum) < abs(sorted_input[-1]) or 
#         abs(input_sum) < abs(sorted_input[0] * 1e-3) ):
#         index = np.where(
#             np.sign(sorted_input_cum[1:]) != np.sign(sorted_input_cum[:-1])
#         )[0]
#         if len(index) == 0:
#             return np.where(biased_input != 0)[0]
#     else:
#         index = np.where(
#                 abs(sorted_input_cum - input_sum) < sum_precision_error * abs(input_sum)
#             )[0]
    
#     if len(index) == 0:
#         raise RuntimeError(f"Index length is 0, "
#                         f"input: {biased_input}, "
#                         f"sorted input: {sorted_input}"
#                         f"sorted input cum: {sorted_input_cum}"
#                         f"input sum: {input_sum}, "
#                         f"biased output: {biased_output} "
#                         f"abs input sum {abs(input_sum)} & smallest input {sorted_input[-1]}")
#     first_index = index[0]
#     threshold = abs(sorted_input[first_index])
#     threshold -= threshold * threshold_bar_ratio
#     topk_index = np.where(np.abs(biased_input) > threshold)[0]
#     return topk_index



# def arg_approx(array: np.ndarray, precision: float) -> np.ndarray:
#     input_sum = array.sum()
#     if input_sum == 0:
#         return np.array([], dtype=np.int64)
#     input = array.flatten()
#     threshold = input_sum * precision
#     sorted_input = input.copy()
#     sorted_input[::-1].sort()
#     # topk = np.argmax(sorted_input.cumsum() >= threshold)
#     topk = sorted_input.cumsum().searchsorted(threshold)
#     return argtopk(input, topk + 1)


def arg_approx_signed(array: np.ndarray, precision: float) -> np.ndarray:
    result = []
    for input in [array.copy(), -array]:
        input[input < 0] = 0
        result.append(arg_approx(input, precision))
    return np.concatenate(result)


def repeat(a: int, repeats: int) -> np.ndarray:
    # if repeats > 1:
    #     return np.repeat(a, repeats)
    # elif repeats == 1:
    #     return np.array([a])
    # else:
    #     return np.array([])
    return np.repeat(a, repeats)


def concatenate(a_tuple, axis=0, out=None, dtype=np.int64) -> np.ndarray:
    if len(a_tuple) == 0:
        return np.array([], dtype=dtype)
    else:
        return np.concatenate(a_tuple, axis, out)
