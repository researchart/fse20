import tensorflow as tf
import torch
import numpy as np
from functools import partial
import os, sys
import pickle
from pdb import set_trace as st

from model.resnet10cifar10 import ResNet10Cifar10
from model.resnet18cifar10 import ResNet18Cifar10
from tf_utils import new_session_config
from nninst_utils.fs import abspath
from dataset.cifar10_main import input_fn_for_adversarial_examples
from dataset.config import CIFAR10_PATH

from torch.utils.data import Dataset, DataLoader

import knockoff.models.zoo as zoo

nninst_dir = "/home/zzq/nninst_tf"
# nninst_logic_dir = "result/resnet10cifar10/model_dropout/nninst_mu_posneg/posonly_logics_0.9/trace.point/unary/raw_logics"
resnet10_ckpt_dir = "result/resnet10cifar10/model_dropout/ckpts/"
resnet10_ckpt_dir = os.path.join(nninst_dir, resnet10_ckpt_dir)
resnet10_gathered_trace_dir = "result/resnet10cifar10/model_dropout/nninst_mu_posneg/original_train_gathered_trace/"

resnet18_ckpt_dir = "result/resnet18cifar10/model_dropout/ckpts/"
resnet18_ckpt_dir = os.path.join(nninst_dir, resnet18_ckpt_dir)
resnet18_gathered_trace_dir = "result/resnet18cifar10/model_dropout/nninst_mu_posneg/original_train_gathered_trace/"

def assign_bn(
    tf_classifier,
    tf_name,
    pytorch_bn,
):
    pytorch_bn.weight.data = torch.from_numpy(
        tf_classifier.get_variable_value(f"{tf_name}/gamma")
    )
    pytorch_bn.bias.data = torch.from_numpy(
        tf_classifier.get_variable_value(f"{tf_name}/beta")
    )
    pytorch_bn.running_mean.data = torch.from_numpy(
        tf_classifier.get_variable_value(f"{tf_name}/moving_mean")
    )
    pytorch_bn.running_var.data = torch.from_numpy(
        tf_classifier.get_variable_value(f"{tf_name}/moving_variance")
    )

def assign_conv(
    tf_classifier,
    tf_name,
    pytorch_conv,
):
    weight = tf_classifier.get_variable_value(f"{tf_name}/kernel")
    weight = weight.transpose(3, 2, 0,1)
    # print(weight.shape, pytorch_conv.weight.shape)
    assert pytorch_conv.weight.shape == weight.shape
    pytorch_conv.weight.data = torch.from_numpy(
        weight
    )
    
def assign_fc(
    tf_classifier,
    tf_name,
    pytorch_fc,
):
    weight = tf_classifier.get_variable_value(f"{tf_name}/kernel")
    bias = tf_classifier.get_variable_value(f"{tf_name}/bias")
    pytorch_fc.weight.data = torch.from_numpy(
        weight.transpose()
    )
    pytorch_fc.bias.data = torch.from_numpy(
        bias
    )
    
def tf_to_pytorch_model_resnet10(
    model,
    tf_classifier,
):
    
    assign_conv(tf_classifier, "conv2d", model.conv1)
    
    assign_bn(tf_classifier, "batch_normalization", model.layer1[0].bn1)
    assign_conv(tf_classifier, "conv2d_1", model.layer1[0].downsample[0])
    assign_conv(tf_classifier, "conv2d_2", model.layer1[0].conv1)
    assign_bn(tf_classifier, "batch_normalization_1", model.layer1[0].bn2)
    assign_conv(tf_classifier, "conv2d_3", model.layer1[0].conv2)
    
    assign_bn(tf_classifier, "batch_normalization_2", model.layer2[0].bn1)
    assign_conv(tf_classifier, "conv2d_4", model.layer2[0].downsample[0])
    assign_conv(tf_classifier, "conv2d_5", model.layer2[0].conv1)
    assign_bn(tf_classifier, "batch_normalization_3", model.layer2[0].bn2)
    assign_conv(tf_classifier, "conv2d_6", model.layer2[0].conv2)
    
    assign_bn(tf_classifier, "batch_normalization_4", model.layer3[0].bn1)
    assign_conv(tf_classifier, "conv2d_7", model.layer3[0].downsample[0])
    assign_conv(tf_classifier, "conv2d_8", model.layer3[0].conv1)
    assign_bn(tf_classifier, "batch_normalization_5", model.layer3[0].bn2)
    assign_conv(tf_classifier, "conv2d_9", model.layer3[0].conv2)
    
    assign_bn(tf_classifier, "batch_normalization_6", model.layer4[0].bn1)
    assign_conv(tf_classifier, "conv2d_10", model.layer4[0].downsample[0])
    assign_conv(tf_classifier, "conv2d_11", model.layer4[0].conv1)
    assign_bn(tf_classifier, "batch_normalization_7", model.layer4[0].bn2)
    assign_conv(tf_classifier, "conv2d_12", model.layer4[0].conv2)
    
    assign_bn(tf_classifier, "batch_normalization_8", model.bn_last)
    assign_fc(tf_classifier, "dense", model.fc)
    
    return model
    
input_fn=lambda: (
            input_fn_for_adversarial_examples(
                is_training= False,
                data_dir=abspath(CIFAR10_PATH),
                num_parallel_batches=1,
                is_shuffle=False,
                transform_fn=None,
            )
            .filter(
                lambda image, label: tf.equal(
                    tf.convert_to_tensor(0, dtype=tf.int32), label
                )
            )
            .skip(0)
            .take(1)
            .batch(1)
            .make_one_shot_iterator()
            .get_next()[0]
        )


def load_tf_model_resnet10(
    pytorch_model,
    model_dir = resnet10_ckpt_dir,
):
    create_model = lambda: partial(
        ResNet10Cifar10(),
        training = False,
    )
    
    def model_fn(features, labels, mode, params):
        image = features
        if isinstance(image, dict):
            image = features["image"]
        forward_fn = lambda logits: tf.argmax(logits, axis=1)
        if mode == tf.estimator.ModeKeys.PREDICT:
            logits = create_model()(image, training=False)
            predictions = {"classes": forward_fn(logits)}
            return tf.estimator.EstimatorSpec(
                mode=tf.estimator.ModeKeys.PREDICT,
                predictions=predictions,
                prediction_hooks=None,
                export_outputs={
                    "classify": tf.estimator.export.PredictOutput(predictions)
                },
            )
            
    model_dir = abspath(model_dir)
    model_function = model_fn
    data_format = (
        "channels_first" if tf.test.is_built_with_cuda() else "channels_last"
    )
    estimator_config = tf.estimator.RunConfig(
        session_config=new_session_config(parallel=1)
    )
    if not os.path.exists(model_dir):
        raise RuntimeError(f"model directory {model_dir} is not existed")
    classifier = tf.estimator.Estimator(
        model_fn=model_function,
        model_dir=model_dir,
        params={"data_format": data_format},
        config=estimator_config,
    )
    
    # pred = classifier.predict(input_fn=input_fn)
    # result = np.array([v["classes"] for v in pred])

        
    # train_var_names = classifier.get_variable_names()
    # for name in sorted(train_var_names):
    #     print(name)
    # print(pytorch_model)
    
    pytorch_model = tf_to_pytorch_model_resnet10(pytorch_model, classifier)
    return pytorch_model

def get_transferred_pytorch_model_resnet10():
    model = zoo.get_net("resnet10", "cifar", False, num_classes=10)
    model = load_tf_model_resnet10(model)
    return model

def tf_to_pytorch_model_resnet18(
    model,
    tf_classifier,
):
    assign_conv(tf_classifier, "conv2d", model.conv1)
    
    # block 1
    assign_bn(tf_classifier, "batch_normalization", model.layer1[0].bn1)
    assign_conv(tf_classifier, "conv2d_1", model.layer1[0].downsample[0])
    assign_conv(tf_classifier, "conv2d_2", model.layer1[0].conv1)
    assign_bn(tf_classifier, "batch_normalization_1", model.layer1[0].bn2)
    assign_conv(tf_classifier, "conv2d_3", model.layer1[0].conv2)
    
    assign_bn(tf_classifier, "batch_normalization_2", model.layer1[1].bn1)
    assign_conv(tf_classifier, "conv2d_4", model.layer1[1].downsample[0])
    assign_conv(tf_classifier, "conv2d_5", model.layer1[1].conv1)
    assign_bn(tf_classifier, "batch_normalization_3", model.layer1[1].bn2)
    assign_conv(tf_classifier, "conv2d_6", model.layer1[1].conv2)

    # block 2
    assign_bn(tf_classifier, "batch_normalization_4", model.layer2[0].bn1)
    assign_conv(tf_classifier, "conv2d_7", model.layer2[0].downsample[0])
    assign_conv(tf_classifier, "conv2d_8", model.layer2[0].conv1)
    assign_bn(tf_classifier, "batch_normalization_5", model.layer2[0].bn2)
    assign_conv(tf_classifier, "conv2d_9", model.layer2[0].conv2)
    
    assign_bn(tf_classifier, "batch_normalization_6", model.layer2[1].bn1)
    assign_conv(tf_classifier, "conv2d_10", model.layer2[1].downsample[0])
    assign_conv(tf_classifier, "conv2d_11", model.layer2[1].conv1)
    assign_bn(tf_classifier, "batch_normalization_7", model.layer2[1].bn2)
    assign_conv(tf_classifier, "conv2d_12", model.layer2[1].conv2)
    
    # block 3
    assign_bn(tf_classifier, "batch_normalization_8", model.layer3[0].bn1)
    assign_conv(tf_classifier, "conv2d_13", model.layer3[0].downsample[0])
    assign_conv(tf_classifier, "conv2d_14", model.layer3[0].conv1)
    assign_bn(tf_classifier, "batch_normalization_9", model.layer3[0].bn2)
    assign_conv(tf_classifier, "conv2d_15", model.layer3[0].conv2)
    
    assign_bn(tf_classifier, "batch_normalization_10", model.layer3[1].bn1)
    assign_conv(tf_classifier, "conv2d_16", model.layer3[1].downsample[0])
    assign_conv(tf_classifier, "conv2d_17", model.layer3[1].conv1)
    assign_bn(tf_classifier, "batch_normalization_11", model.layer3[1].bn2)
    assign_conv(tf_classifier, "conv2d_18", model.layer3[1].conv2)
    
    
    # block 4
    assign_bn(tf_classifier, "batch_normalization_12", model.layer4[0].bn1)
    assign_conv(tf_classifier, "conv2d_19", model.layer4[0].downsample[0])
    assign_conv(tf_classifier, "conv2d_20", model.layer4[0].conv1)
    assign_bn(tf_classifier, "batch_normalization_13", model.layer4[0].bn2)
    assign_conv(tf_classifier, "conv2d_21", model.layer4[0].conv2)
    
    assign_bn(tf_classifier, "batch_normalization_14", model.layer4[1].bn1)
    assign_conv(tf_classifier, "conv2d_22", model.layer4[1].downsample[0])
    assign_conv(tf_classifier, "conv2d_23", model.layer4[1].conv1)
    assign_bn(tf_classifier, "batch_normalization_15", model.layer4[1].bn2)
    assign_conv(tf_classifier, "conv2d_24", model.layer4[1].conv2)
    
    assign_bn(tf_classifier, "batch_normalization_16", model.bn_last)
    assign_fc(tf_classifier, "dense", model.fc)
    
    return model
    

def load_tf_model_resnet18(
    pytorch_model,
    testset,
    model_dir = resnet18_ckpt_dir,
):
    create_model = lambda: partial(
        ResNet18Cifar10(),
        training = False,
    )
    
    def model_fn(features, labels, mode, params):
        image = features
        if isinstance(image, dict):
            image = features["image"]
        forward_fn = lambda logits: tf.argmax(logits, axis=1)
        if mode == tf.estimator.ModeKeys.PREDICT:
            # logits, input, feat = create_model()(image, training=False)
            logits = create_model()(image, training=False)
            predictions = {
                "classes": forward_fn(logits),
                # "input": input,
                # "feat": feat,
            
            }
            return tf.estimator.EstimatorSpec(
                mode=tf.estimator.ModeKeys.PREDICT,
                predictions=predictions,
                prediction_hooks=None,
                export_outputs={
                    "classify": tf.estimator.export.PredictOutput(predictions)
                },
            )
            
    model_dir = abspath(model_dir)
    model_function = model_fn
    data_format = (
        "channels_first" if tf.test.is_built_with_cuda() else "channels_last"
    )
    estimator_config = tf.estimator.RunConfig(
        session_config=new_session_config(parallel=1)
    )
    if not os.path.exists(model_dir):
        raise RuntimeError(f"model directory {model_dir} is not existed")
    classifier = tf.estimator.Estimator(
        model_fn=model_function,
        model_dir=model_dir,
        params={"data_format": data_format},
        config=estimator_config,
    )
    # train_var_names = classifier.get_variable_names()
    # for name in sorted(train_var_names):
    #     print(name)
    
    # pred = classifier.predict(input_fn=input_fn)
    # result = [v for v in pred]
    # result = result[0]

    # Test tf model accuracy
    # correct = 0
    # for class_id in range(10):
    #     for image_id in range(0, 100, 1000):
    #         input_fn=lambda: (
    #             input_fn_for_adversarial_examples(
    #                 is_training= False,
    #                 data_dir=abspath(CIFAR10_PATH),
    #                 num_parallel_batches=1,
    #                 is_shuffle=False,
    #                 transform_fn=None,
    #             )
    #             .filter(
    #                 lambda image, label: tf.equal(
    #                     tf.convert_to_tensor(class_id, dtype=tf.int32), label
    #                 )
    #             )
    #             .skip(image_id)
    #             .take(100)
    #             .batch(100)
    #             .make_one_shot_iterator()
    #             .get_next()[0]
    #         )
    #         pred = classifier.predict(input_fn=input_fn)
    #         result = np.array([v["classes"] for v in pred])
    #         correct += (result==class_id).sum()
    # print(correct/1e3)
    # st()
    
    # train_var_names = classifier.get_variable_names()
    # for name in sorted(train_var_names):
    #     print(name)
    # print(pytorch_model)
    
    pytorch_model = tf_to_pytorch_model_resnet18(pytorch_model, classifier)
    
    return pytorch_model

def get_transferred_pytorch_model_resnet18(testset):
    model = zoo.get_net("resnet18", "cifar", False, num_classes=10)
    model = load_tf_model_resnet18(model, testset)
    return model

def numpy_to_cuda(array):
    return torch.Tensor(array).cuda()

def load_avg_to_module(module, logger):
    input_avg = logger.input_avg()
    input_avg = numpy_to_cuda(input_avg)
    output_avg = logger.output_avg()
    assert ( module.module.weight.shape[0] == output_avg.shape[0] and 
            module.module.weight.shape[1] == input_avg.shape[0] )
    output_avg = numpy_to_cuda(output_avg)
    module.set_avg(input_avg, output_avg)
    
def load_avg_resnet10(model, trace):
    load_avg_to_module(
        model.layer1[0].downsample[0], 
        trace.ops['conv2d_1/Conv2D']['trace.io_average']
    )
    load_avg_to_module(
        model.layer1[0].conv1, 
        trace.ops['conv2d_2/Conv2D']['trace.io_average']
    )
    load_avg_to_module(
        model.layer1[0].conv2, 
        trace.ops['conv2d_3/Conv2D']['trace.io_average']
    )
    
    load_avg_to_module(
        model.layer2[0].downsample[0], 
        trace.ops['conv2d_4/Conv2D']['trace.io_average']
    )
    load_avg_to_module(
        model.layer2[0].conv1, 
        trace.ops['conv2d_5/Conv2D']['trace.io_average']
    )
    load_avg_to_module(
        model.layer2[0].conv2, 
        trace.ops['conv2d_6/Conv2D']['trace.io_average']
    )
    
    load_avg_to_module(
        model.layer3[0].downsample[0], 
        trace.ops['conv2d_7/Conv2D']['trace.io_average']
    )
    load_avg_to_module(
        model.layer3[0].conv1, 
        trace.ops['conv2d_8/Conv2D']['trace.io_average']
    )
    load_avg_to_module(
        model.layer3[0].conv2, 
        trace.ops['conv2d_9/Conv2D']['trace.io_average']
    )
    
    load_avg_to_module(
        model.layer4[0].downsample[0], 
        trace.ops['conv2d_10/Conv2D']['trace.io_average']
    )
    load_avg_to_module(
        model.layer4[0].conv1, 
        trace.ops['conv2d_11/Conv2D']['trace.io_average']
    )
    load_avg_to_module(
        model.layer4[0].conv2, 
        trace.ops['conv2d_12/Conv2D']['trace.io_average']
    )
    
    load_avg_to_module(
        model.fc,
        trace.ops['dense/MatMul']['trace.io_average']
    )
    
    
def load_avg_resnet18(model, trace):
    load_avg_to_module(
        model.layer1[0].downsample[0], 
        trace.ops['conv2d_1/Conv2D']['trace.io_average']
    )
    load_avg_to_module(
        model.layer1[0].conv1, 
        trace.ops['conv2d_2/Conv2D']['trace.io_average']
    )
    load_avg_to_module(
        model.layer1[0].conv2, 
        trace.ops['conv2d_3/Conv2D']['trace.io_average']
    )
    load_avg_to_module(
        model.layer1[1].downsample[0], 
        trace.ops['conv2d_4/Conv2D']['trace.io_average']
    )
    load_avg_to_module(
        model.layer1[1].conv1, 
        trace.ops['conv2d_5/Conv2D']['trace.io_average']
    )
    load_avg_to_module(
        model.layer1[1].conv2, 
        trace.ops['conv2d_6/Conv2D']['trace.io_average']
    )
    
    
    load_avg_to_module(
        model.layer2[0].downsample[0], 
        trace.ops['conv2d_7/Conv2D']['trace.io_average']
    )
    load_avg_to_module(
        model.layer2[0].conv1, 
        trace.ops['conv2d_8/Conv2D']['trace.io_average']
    )
    load_avg_to_module(
        model.layer2[0].conv2, 
        trace.ops['conv2d_9/Conv2D']['trace.io_average']
    )
    load_avg_to_module(
        model.layer2[1].downsample[0], 
        trace.ops['conv2d_10/Conv2D']['trace.io_average']
    )
    load_avg_to_module(
        model.layer2[1].conv1, 
        trace.ops['conv2d_11/Conv2D']['trace.io_average']
    )
    load_avg_to_module(
        model.layer2[1].conv2, 
        trace.ops['conv2d_12/Conv2D']['trace.io_average']
    )
    
    
    
    load_avg_to_module(
        model.layer3[0].downsample[0], 
        trace.ops['conv2d_13/Conv2D']['trace.io_average']
    )
    load_avg_to_module(
        model.layer3[0].conv1, 
        trace.ops['conv2d_14/Conv2D']['trace.io_average']
    )
    load_avg_to_module(
        model.layer3[0].conv2, 
        trace.ops['conv2d_15/Conv2D']['trace.io_average']
    )
    load_avg_to_module(
        model.layer3[1].downsample[0], 
        trace.ops['conv2d_16/Conv2D']['trace.io_average']
    )
    load_avg_to_module(
        model.layer3[1].conv1, 
        trace.ops['conv2d_17/Conv2D']['trace.io_average']
    )
    load_avg_to_module(
        model.layer3[1].conv2, 
        trace.ops['conv2d_18/Conv2D']['trace.io_average']
    )
    
    
    load_avg_to_module(
        model.layer4[0].downsample[0], 
        trace.ops['conv2d_19/Conv2D']['trace.io_average']
    )
    load_avg_to_module(
        model.layer4[0].conv1, 
        trace.ops['conv2d_20/Conv2D']['trace.io_average']
    )
    load_avg_to_module(
        model.layer4[0].conv2, 
        trace.ops['conv2d_21/Conv2D']['trace.io_average']
    )
    load_avg_to_module(
        model.layer4[1].downsample[0], 
        trace.ops['conv2d_22/Conv2D']['trace.io_average']
    )
    load_avg_to_module(
        model.layer4[1].conv1, 
        trace.ops['conv2d_23/Conv2D']['trace.io_average']
    )
    load_avg_to_module(
        model.layer4[1].conv2, 
        trace.ops['conv2d_24/Conv2D']['trace.io_average']
    )
    
    
    load_avg_to_module(
        model.fc,
        trace.ops['dense/MatMul']['trace.io_average']
    )
    
def load_class_avg(model, arch, class_id="all"):
    if arch == "resnet10":
        path = os.path.join(nninst_dir, resnet10_gathered_trace_dir, f"{class_id}.pkl")
        with open(path, "rb") as f:
            class_trace = pickle.load(f)
        load_avg_resnet10(model, class_trace)
    elif arch == "resnet18":
        path = os.path.join(nninst_dir, resnet18_gathered_trace_dir, f"{class_id}.pkl")
        with open(path, "rb") as f:
            class_trace = pickle.load(f)
        load_avg_resnet18(model, class_trace)
    else:
        raise NotImplementedError
    
    return model
    
    
if __name__=="__main__":
    # get_transferred_pytorch_model()
    load_class_avg(None)