import tensorflow as tf
from pdb import set_trace as st
from nninst_graph import Graph
from tf_graph import build_graph
from nninst_utils.fs import IOAction

from .resnet_cifar import CifarModel
# from .resnet_imagenet import ImagenetModel

class ResNet10Cifar10(CifarModel):
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
    

if __name__ == "__main__":
    ResNet10Cifar10.graph().save()
    graph = ResNet10Cifar10.graph().load()
    print(f"Neuron number {graph.count_neurons()}")
    print(f"Synapse number {graph.count_synapse()}")
    print(f"Weight number {graph.count_weight()}")
    # layers = graph.layers()
    # graph.print()
    # for layer in layers:
    #     if "conv2d" in layer:
    #         print(layer)
    # print(layers)
    
