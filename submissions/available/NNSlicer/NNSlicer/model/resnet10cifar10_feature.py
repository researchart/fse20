import tensorflow as tf
from pdb import set_trace as st
from nninst_graph import Graph
from tf_graph import build_graph
from nninst_utils.fs import IOAction

from .resnet_cifar import CifarModel
from .resnet import *
# from .resnet_imagenet import ImagenetModel

class ResNet10Cifar10_Feature(CifarModel):
    def __init__(self):
        super().__init__(
            resnet_size=10, 
            num_filters=16,
            num_classes=10, 
            data_format="channels_first"
        )

    @classmethod
    def create_graph(cls, input_name: str = "IteratorGetNext:0") -> Graph:
        with tf.Session().as_default() as sess:
            input = tf.placeholder(tf.float32, shape=(1, 32, 32, 3))
            new_graph = build_graph([input], [cls()(input)])
            new_graph.rename(new_graph.id(input.name), input_name)
            sess.close()
            return new_graph

    @classmethod
    def graph(cls) -> IOAction[Graph]:
        path = "result/resnet10cifar10//graph/resnet10_cifar10.pkl"
        return IOAction(path, init_fn=lambda: ResNet10Cifar10.create_graph())
    
    def __call__(
        self,
        inputs,
        training=False,
        gate_variables: Dict[str, tf.Variable] = None,
        batch_size: int = 1,
    ):
        """Add operations to classify a batch of input images.

        Args:
            inputs: A Tensor representing a batch of input images.
            training: A boolean. Set to True to add operations required only when
            training the classifier.

        Returns:
            A logits Tensor with shape [<batch_size>, self.num_classes].
        """
        self.gate_count = 0
        self.gate_variables = {}

        if self.data_format == "channels_first":
            # Convert the inputs from channels_last (NHWC) to channels_first (NCHW).
            # This provides a large performance boost on GPU. See
            # https://www.tensorflow.org/performance/performance_guide#data_formats
            inputs = tf.transpose(inputs, [0, 3, 1, 2])

        inputs = conv2d_fixed_padding(
            inputs=inputs,
            filters=self.num_filters,
            kernel_size=self.kernel_size,
            strides=self.conv_stride,
            data_format=self.data_format,
        )
        inputs = tf.identity(inputs, "initial_conv")
        
        if self.first_pool_size:
            inputs = tf.layers.max_pooling2d(
                inputs=inputs,
                pool_size=self.first_pool_size,
                strides=self.first_pool_stride,
                padding="SAME",
                data_format=self.data_format,
            )
            inputs = tf.identity(inputs, "initial_max_pool")
        for i, num_blocks in enumerate(self.block_sizes):
            num_filters = self.num_filters * (2 ** i)
            inputs = block_layer(
                inputs=inputs,
                filters=num_filters,
                bottleneck=self.bottleneck,
                block_fn=self.block_fn,
                blocks=num_blocks,
                strides=self.block_strides[i],
                training=training,
                name="block_layer{}".format(i + 1),
                data_format=self.data_format,
            )
        lastconv_point = inputs
        inputs = batch_norm(inputs, training, self.data_format)
        inputs = tf.nn.relu(inputs)
        inputs = tf.layers.average_pooling2d(
            inputs=inputs,
            pool_size=self.second_pool_size,
            strides=self.second_pool_stride,
            padding="VALID",
            data_format=self.data_format,
        )
        inputs = tf.identity(inputs, "final_avg_pool")

        inputs = tf.reshape(inputs, [-1, self.final_size])
        inputs = tf.layers.dense(inputs=inputs, units=self.num_classes)
        inputs = tf.identity(inputs, "final_dense")

        if gate_variables is not None:
            gate_variables.update(self.gate_variables)

        return inputs, lastconv_point


if __name__ == "__main__":
    ResNet10Cifar10.graph().save()
    graph = ResNet10Cifar10.graph().load()
    layers = graph.layers()
    graph.print()
    for layer in layers:
        if "conv2d" in layer:
            print(layer)
    # print(layers)
    
