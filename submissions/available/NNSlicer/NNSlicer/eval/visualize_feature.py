import csv
import random
from functools import partial
from typing import Callable, Optional
from pdb import set_trace as st
import os
import random
import pandas as pd

import numpy as np
import tensorflow as tf
from foolbox.attacks import (
    FGSM,
    Attack,
    DeepFoolAttack,
    IterativeGradientSignAttack,
    SaliencyMapAttack,
)
# from foolbox.criteria import TargetClass
# from foolbox.models import TensorFlowModel
from tensorflow.python.training import saver
from tensorflow.python.training.session_manager import SessionManager
import tensorflow as tf
import numpy as np
import sklearn.metrics as metrics
import matplotlib.pyplot as plt
plt.switch_backend('Agg')

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

from .common import get_overlay_summary, clean_overlap_ratio, \
                translation_overlap_ratio, attack_overlap_ratio
from .cw_attack import cw_generate_adversarial_example
from .cw_attacks import CarliniL2

# Model config
model_label = "augmentation"
model_dir = f"result/lenet/model_{model_label}"
# Trace config
trace_dir =  f"{model_dir}/traces"
trace_name = "9translation"
key = TraceKey.POINT
# Result dir
result_name = key.split('.')[1]
result_dir = f"result/lenet/model_augmentation/visualize"
# result_dir = f"result/lenet/test"
images_per_class = 10
attack_name = "FGSM"

attacks = {
    "FGSM": [FGSM],
    "BIM": [IterativeGradientSignAttack],
    "JSMA": [SaliencyMapAttack],
    "DeepFool": [DeepFoolAttack],
    # "DeepFool_full": [DeepFoolAttack, dict(subsample=None)],
    # "CWL2": [CarliniL2],
}

from typing import Any, Callable, Dict, Iterable, List, Tuple, Union
from tensorflow.python.training.session_run_hook import SessionRunHook
from nninst_utils.fs import CsvIOAction, ImageIOAction, IOAction, abspath
from nninst_graph import AttrMap, Graph, GraphAttrKey
from nninst_utils.ray import ray_iter, ray_map, ray_map_reduce
from dataset.config import MNIST_PATH

class LeNet:
    """Class that defines a graph to recognize digits in the MNIST dataset."""

    def __init__(self, data_format: str = "channels_first"):
        """Creates a model for classifying a hand-written digit.

        Args:
          data_format: Either "channels_first" or "channels_last".
            "channels_first" is typically faster on GPUs while "channels_last" is
            typically faster on CPUs. See
            https://www.tensorflow.org/performance/performance_guide#data_formats
        """
        # if data_format == "channels_first":
        #     self._input_shape = [-1, 1, 28, 28]
        # else:
        #     assert data_format == "channels_last"
        #     self._input_shape = [-1, 28, 28, 1]

        self.conv1 = tf.layers.Conv2D(
            6, 5, data_format=data_format, activation=tf.nn.relu
        )
        self.conv2 = tf.layers.Conv2D(
            16, 5, data_format=data_format, activation=tf.nn.relu
        )
        self.fc1 = tf.layers.Dense(120, activation=tf.nn.relu)
        self.fc2 = tf.layers.Dense(84, activation=tf.nn.relu)
        self.fc3 = tf.layers.Dense(10)
        self.max_pool2d = tf.layers.MaxPooling2D(
            (2, 2), (2, 2), padding="same", data_format=data_format
        )
        self.dropout = tf.layers.Dropout(rate=0.5)

    def __call__(self, inputs, training=False):
        """Add operations to classify a batch of input images.

        Args:
          inputs: A Tensor representing a batch of input images.
          training: A boolean. Set to True to add operations required only when
            training the classifier.

        Returns:
          A logits Tensor with shape [<batch_size>, 10].
        """
        # y = tf.reshape(inputs, self._input_shape)
        # y = self.conv1(y)
        # for i in range(28):
        #     inputs = tf.Print(inputs, [inputs[0][0][i]], "Inputs", summarize=30)
        # inputs = tf.Print(inputs, [tf.shape(inputs)], summarize=5)
        # tf.summary.image('input', inputs)

        # inputs = tf.Print(inputs, [tf.shape(inputs)], "Inputs: ", summarize=20)
        y = self.conv1(inputs)
        # y = tf.Print(y, [tf.shape(y)], "Conv1: ", summarize=20)
        y = self.max_pool2d(y)
        # y = tf.Print(y, [tf.shape(y)], "Pool1: ", summarize=20)
        y = self.conv2(y)
        # y = tf.Print(y, [tf.shape(y)], "Conv2: ", summarize=20)
        y = self.max_pool2d(y)
        # y = tf.Print(y, [tf.shape(y)], "Pool2: ", summarize=20)
        y = tf.layers.flatten(y)
        # y = tf.Print(y, [tf.shape(y)], "Flatten: ", summarize=20)
        y = self.fc1(y)
        # y = tf.Print(y, [tf.shape(y)], "Fc1: ", summarize=20)
        y = self.dropout(y, training=training)
        y = self.fc2(y)
        # y = tf.Print(y, [tf.shape(y)], "Fc2: ", summarize=20)
        y = self.dropout(y, training=training)
        return self.fc3(y)

    @classmethod
    def create_graph(cls, input_name: str = "IteratorGetNext:0") -> Graph:
        input = tf.placeholder(tf.float32, shape=(1, 1, 28, 28))
        new_graph = build_graph([input], [cls()(input)])
        new_graph.rename(new_graph.id(input.name), input_name)
        return new_graph

    @classmethod
    def graph(cls, path="result/lenet/graph/lenet.pkl") -> IOAction[Graph]:
        # path = "store/graph/lenet.pkl"
        return IOAction(path, init_fn=lambda: LeNet.create_graph())


def forward_propagate(
    create_model,
    input_fn,
    forward_fn: Callable[[tf.Tensor], tf.Tensor],
    model_dir: str,
    data_format: str = "channels_first",
    parallel: int = 1,
    prediction_hooks: List[SessionRunHook] = None,
    tag: str = "noop",
) -> Union[int, float]:

    def model_fn(features, labels, mode, params):
        image = features
        if isinstance(image, dict):
            image = features["image"]

        # Save inputs for visualization in tensorboard
        nonlocal prediction_hooks
        feature_trans = tf.transpose(image, perm=[0,2,3,1])
        image_summary = tf.summary.image(f"input_{tag}", feature_trans, max_outputs=100)
        eval_summary_hook = tf.train.SummarySaverHook(
                            summary_op=image_summary,
                            save_steps=2,
                            output_dir=result_dir)
        if prediction_hooks is None:
            prediction_hooks = [eval_summary_hook]
        else:
            prediction_hooks.append(eval_summary_hook)

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

    result = list(classifier.predict(input_fn=input_fn))
    return result[0]["classes"]


def predict(
    create_model,
    input_fn,
    model_dir: str,
    data_format: str = "channels_first",
    parallel: int = 1,
    prediction_hooks: List[SessionRunHook] = None,
    tag: str = "noop",
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
            tag = tag,
        )
    )


# Compute the mean overlap ratio of attacked image
def test_data_forward(
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
    **kwargs,
):
    def forward_one_image(class_id: int, image_id: int) -> Dict[str, Any]:
        nonlocal model_dir
        mode.check(False)
        data_dir = abspath(MNIST_PATH)
        model_dir = abspath(model_dir)
        ckpt_dir = f"{model_dir}/ckpts"
        create_model = lambda: LeNet(data_format="channels_first")
        graph = LeNet.graph().load()
        # model_fn = partial(
        #     model_fn_with_fetch_hook,
        #     create_model=create_model, graph=graph
        # )

        for transform, name in transforms:
            predicted_label = predict(
                create_model=create_model,
                input_fn=lambda: mnist.test(
                                            data_dir,
                                            transforms = transform
                                            )
                .filter(
                    lambda image, label: tf.equal(
                        tf.convert_to_tensor(class_id, dtype=tf.int32), label
                    )
                )
                .skip(image_id)
                .take(1)
                .batch(1),
                model_dir=ckpt_dir,
                tag = name,
            )

    results = ray_iter(
        forward_one_image,
        (
            (class_id, image_id)
            for image_id in range(0, images_per_class)
            for class_id in range(0, 1)
        ),
        chunksize=1,
        out_of_order=True,
        num_gpus=num_gpus,
    )

    results = [result for result in results]



def visualize_features(
    transforms,
    result_dir = "result/lenet/model_augmentation/visualize"
):

    name = attack_name

    lenet_mnist_class_trace = class_trace(
                                trace_name,
                                model_config=LENET,
                                data_config=data_config,
                            )

    threshold = 0.5

    # DeepFool will shutdown when num_gpu<0.2
    num_gpus = 0.2

    overlap_fn = calc_trace_side_overlap
    per_channel = False

    path = os.path.join(result_dir, f"{name}_overlap.csv")

    print(f"Computing {name}")

    lenet_overlap_ratio = test_data_forward(
        class_trace_fn=lambda class_id: lenet_mnist_class_trace(
            class_id,
            threshold,
            label=model_label,
            trace_dir = trace_dir,
        ),
        select_fn=lambda input: arg_approx(input, threshold),
        overlap_fn=overlap_fn,
        path=path,
        per_channel=per_channel,
        preprocessing=(0.1307, 0.3081),
        image_size=28,
        class_num=10,
        norm_fn=mnist.normalize,
        data_format="channels_first",
        **(attacks[attack_name][1] if len(attacks[attack_name]) == 2 else {}),
        images_per_class=images_per_class,
        model_dir=model_dir,
        num_gpus = num_gpus,
        transforms = transforms,
    )


def visualize_features_exp():
    exp_to_roc = {}

    os.makedirs(result_dir, exist_ok=True)

    transforms = [
        [None, "noop"],
        # [Translate(dx=-5,dy=-5), "leftup"],
    ]

    trace_frame = visualize_features(
        transforms,
        result_dir=result_dir
    )

if __name__ == "__main__":

    mode.debug()
    # mode.local()

    # ray_init("gpu")
    ray_init(
        log_to_driver=False
    )

    tf.set_random_seed(3)
    np.random.seed(3)
    random.seed(3)

    visualize_features_exp()
