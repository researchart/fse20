from dataset import cifar10
# from nninst.backend.tensorflow.dataset.imagenet import normalize, normalize_alexnet
# from nninst.backend.tensorflow.dataset.imagenet_preprocessing import (
#     alexnet_preprocess_image,
#     preprocess_image,
# )

# from .alexnet import AlexNet
# from .alexnet_cdrp import AlexNetCDRP
# from .inception_v4 import InceptionV4
from .lenet import LeNet
from .resnet18cifar10 import ResNet18Cifar10
# from .resnet_18_cifar100 import ResNet18Cifar100
# from .resnet_50 import ResNet50
# from .resnet_50_cdrp import ResNet50CDRP
# from .vgg_16 import VGG16
# from .vgg_16_cdrp import VGG16CDRP
# from .vgg_16_cifar10 import VGG16Cifar10


class ModelConfig:
    def __init__(
        self,
        name: str,
        model_dir: str,
        network_class,
        preprocessing_fn=None,
        normalize_fn=None,
        class_from_zero=True,
    ):
        self.name = name
        self.model_dir = model_dir
        self.network_class = network_class
        self.preprocessing_fn = preprocessing_fn
        self.normalize_fn = normalize_fn
        self.class_from_zero = class_from_zero

    def with_model_dir(self, model_dir) -> "ModelConfig":
        return ModelConfig(
            self.name,
            model_dir,
            self.network_class,
            self.preprocessing_fn,
            self.normalize_fn,
            self.class_from_zero,
        )

    def class_list(self):
        if self.class_from_zero:
            return list(range(1000))
        else:
            return list(range(1, 1001))


# RESNET_50 = ModelConfig(
#     name="resnet_50",
#     model_dir="tf/resnet-50-v2/model",
#     network_class=ResNet50,
#     preprocessing_fn=preprocess_image,
#     class_from_zero=False,
#     normalize_fn=normalize,
# )
RESNET_18_CIFAR10 = ModelConfig(
    name="resnet_18_cifar10",
    model_dir="result/resnet-18-cifar10/model_train",
    network_class=ResNet18Cifar10,
)
# RESNET_18_CIFAR100 = ModelConfig(
#     name="resnet_18_cifar100",
#     model_dir="tf/resnet-18-cifar100/model_train",
#     network_class=ResNet18Cifar100,
# )
# RESNET_50_CDRP = ModelConfig(
#     name="resnet_50",
#     model_dir="tf/resnet-50-v2/model",
#     network_class=ResNet50CDRP,
#     preprocessing_fn=preprocess_image,
#     class_from_zero=False,
#     normalize_fn=normalize,
# )
LENET = ModelConfig(name="lenet", model_dir="result/lenet/model", network_class=LeNet)
# INCEPTION_V4 = ModelConfig(
#     name="inception_v4",
#     model_dir="tf/inception_v4/model",
#     network_class=InceptionV4,
#     class_from_zero=False,
# )
# VGG_16 = ModelConfig(
#     name="vgg_16",
#     model_dir=None,
#     network_class=VGG16Cifar10,
#     preprocessing_fn=preprocess_image,
#     normalize_fn=normalize,
# )
# VGG_16_CDRP = ModelConfig(
#     name="vgg_16",
#     model_dir="tf/vgg_16/model",
#     network_class=VGG16CDRP,
#     preprocessing_fn=preprocess_image,
#     normalize_fn=normalize,
# )
# VGG_16_CIFAR10 = ModelConfig(
#     name="vgg_16_cifar10",
#     model_dir="",
#     network_class=VGG16Cifar10,
#     normalize_fn=cifar10.normalize,
# )
# ALEXNET = ModelConfig(
#     name="alexnet",
#     model_dir="tf/alexnet/model",
#     network_class=AlexNet,
#     preprocessing_fn=alexnet_preprocess_image,
#     normalize_fn=normalize_alexnet,
# )
# ALEXNET_CDRP = ModelConfig(
#     name="alexnet",
#     model_dir="tf/alexnet/model",
#     network_class=AlexNetCDRP,
#     preprocessing_fn=alexnet_preprocess_image,
#     normalize_fn=normalize_alexnet,
# )
