from __future__ import absolute_import

'''
Source for CIFAR models: https://github.com/bearpaw/pytorch-classification
by user "bearpaw"

Notes:
 - Network names have been edited to make it consistent with pytorch-torchvision and cadene imagenet models 
'''

'''Resnet for cifar dataset.
Ported form
https://github.com/facebook/fb.resnet.torch
and
https://github.com/pytorch/vision/blob/master/torchvision/models/resnet.py
(c) YANG, Wei
'''
import torch.nn as nn
import math
from pdb import set_trace as st

__all__ = ['resnet', 'resnet10', 'resnet18', 'resnet34', 'resnet50']

class wrapper(nn.Module):
    def __init__(self, module):
        super(wrapper, self).__init__()
        self.module = module
        self.input_avg = None
        self.output_avg = None
        self.weight = self.module.weight
        self.bias = self.module.bias
        
    def set_avg(self, input_avg, output_avg):
        self.input_avg = input_avg
        self.output_avg = output_avg
        
    def forward(self, x):
        if self.input_avg is None and self.output_avg is None:
            return self.module(x)
        else:
            # print(f"x shape {x.shape}, input avg shape {self.input_avg.shape}")
            if isinstance(self.module, nn.modules.conv.Conv2d):
                w, h = self.module.padding
                sw, sh = self.module.stride
                kw, kh = self.module.kernel_size
                if sw > 1 and kw > 1:
                    x = x[:] - self.input_avg[:, 1:-1, 1:-1]
                else:
                    try:
                        x = x[:] - self.input_avg
                    except:
                        st()
            else:
                x = x[:] - self.input_avg
            output = self.module(x)
            output = output[:] + self.output_avg
            return output
            
def conv3x3(in_planes, out_planes, stride=1):
    "3x3 convolution with padding"
    return nn.Conv2d(in_planes, out_planes, kernel_size=3, stride=stride,
                    padding=1, bias=False)


class BasicBlock(nn.Module):
    expansion = 1

    def __init__(self, inplanes, planes, stride=1, downsample=None):
        super(BasicBlock, self).__init__()
        self.bn1 = nn.BatchNorm2d(inplanes)
        self.relu = nn.ReLU(inplace=True)
        self.conv1 = wrapper(
            conv3x3(inplanes, planes, stride)
        )
        self.bn2 = nn.BatchNorm2d(planes)
        self.conv2 = wrapper(
            conv3x3(planes, planes)
        )
        self.downsample = downsample
        self.stride = stride

    def forward(self, x):
        x = self.bn1(x)
        x = self.relu(x)
        
        residual = x
        if self.downsample is not None:
            # print(self, x.shape, " down")
            residual = self.downsample(x)
            
        out = self.conv1(x)
        out = self.bn2(out)
        out = self.relu(out)
        out = self.conv2(out)
        return out + residual
        
        # residual = x

        # out = self.conv1(x)
        # out = self.bn1(out)
        # out = self.relu(out)

        # out = self.conv2(out)
        # out = self.bn2(out)

        # if self.downsample is not None:
        #     residual = self.downsample(x)

        # out += residual
        # out = self.relu(out)

        # return out


class Bottleneck(nn.Module):
    expansion = 4

    def __init__(self, inplanes, planes, stride=1, downsample=None):
        super(Bottleneck, self).__init__()
        self.conv1 = nn.Conv2d(inplanes, planes, kernel_size=1, bias=False)
        self.bn1 = nn.BatchNorm2d(planes)
        self.conv2 = nn.Conv2d(planes, planes, kernel_size=3, stride=stride,
                               padding=1, bias=False)
        self.bn2 = nn.BatchNorm2d(planes)
        self.conv3 = nn.Conv2d(planes, planes * 4, kernel_size=1, bias=False)
        self.bn3 = nn.BatchNorm2d(planes * 4)
        self.relu = nn.ReLU(inplace=True)
        self.downsample = downsample
        self.stride = stride

    def forward(self, x):
        residual = x

        out = self.conv1(x)
        out = self.bn1(out)
        out = self.relu(out)

        out = self.conv2(out)
        out = self.bn2(out)
        out = self.relu(out)

        out = self.conv3(out)
        out = self.bn3(out)

        if self.downsample is not None:
            residual = self.downsample(x)

        out += residual
        out = self.relu(out)

        return out


class ResNet(nn.Module):

    def __init__(self, depth, num_classes=1000, block_name='BasicBlock'):
        super(ResNet, self).__init__()
        # Model type specifies number of layers for CIFAR-10 model
        if block_name.lower() == 'basicblock':
            assert (depth - 2) % 8 == 0, 'When use basicblock, depth should be 8n+2, e.g. 20, 32, 44, 56, 110, 1202'
            n = (depth - 2) // 8
            block = BasicBlock
        elif block_name.lower() == 'bottleneck':
            assert (depth - 2) % 9 == 0, 'When use bottleneck, depth should be 9n+2, e.g. 20, 29, 47, 56, 110, 1199'
            n = (depth - 2) // 9
            block = Bottleneck
        else:
            raise ValueError('block_name shoule be Basicblock or Bottleneck')

        if depth == 10:
            self.inplanes = 16
            self.conv1 = nn.Conv2d(3, 16, kernel_size=3, padding=1,
                                bias=False)
            # self.bn1 = nn.BatchNorm2d(16)
            # self.relu = nn.ReLU(inplace=True)
            self.layer1 = self._make_layer(block, 16, n)
            self.layer2 = self._make_layer(block, 32, n, stride=2)
            self.layer3 = self._make_layer(block, 64, n, stride=2)
            self.layer4 = self._make_layer(block, 128, n, stride=2)
            self.bn_last = nn.BatchNorm2d(128)
            self.relu_last = nn.ReLU(inplace=True)
            self.avgpool = nn.AvgPool2d(4)
            self.fc = wrapper(
                nn.Linear(128 * block.expansion, num_classes)
            )
        elif depth == 18:
            self.inplanes = 16
            self.conv1 = nn.Conv2d(3, 16, kernel_size=3, padding=1,
                                bias=False)
            # self.bn1 = nn.BatchNorm2d(16)
            # self.relu = nn.ReLU(inplace=True)
            self.layer1 = self._make_layer(block, 16, 2)
            self.layer2 = self._make_layer(block, 32, 2, stride=2)
            self.layer3 = self._make_layer(block, 64, 2, stride=2)
            self.layer4 = self._make_layer(block, 128, 2, stride=2)
            self.bn_last = nn.BatchNorm2d(512)
            self.relu_last = nn.ReLU(inplace=True)
            self.avgpool = nn.AvgPool2d(4)
            self.fc = wrapper(
                nn.Linear(128 * block.expansion, num_classes)
            )
        
        for m in self.modules():
            if isinstance(m, nn.Conv2d):
                n = m.kernel_size[0] * m.kernel_size[1] * m.out_channels
                m.weight.data.normal_(0, math.sqrt(2. / n))
            elif isinstance(m, nn.BatchNorm2d):
                m.weight.data.fill_(1)
                m.bias.data.zero_()

    def _make_layer(self, block, planes, blocks, stride=1):
        downsample = None
        # if stride != 1 or self.inplanes != planes * block.expansion:
        downsample = nn.Sequential(
            wrapper(
                nn.Conv2d(self.inplanes, planes * block.expansion,
                    kernel_size=1, stride=stride, bias=False),
            )
            # nn.BatchNorm2d(planes * block.expansion),
        )

        layers = []
        layers.append(block(self.inplanes, planes, stride, downsample))
        self.inplanes = planes * block.expansion
        for i in range(1, blocks):
            fake_downsample = nn.Sequential(
                wrapper(
                    nn.Conv2d(self.inplanes, planes * block.expansion,
                        kernel_size=1, stride=1, bias=False),
                )
                # nn.BatchNorm2d(planes * block.expansion),
            )
            layers.append(block(self.inplanes, planes, 1, fake_downsample))

        return nn.Sequential(*layers)

    def forward(self, x):
        x = self.conv1(x)
        # x = self.bn1(x)
        # x = self.relu(x)    # 32x32

        x = self.layer1(x)  # 32x32
        x = self.layer2(x)  # 16x16
        x = self.layer3(x)  # 8x8
        x = self.layer4(x)
        
        x = self.bn_last(x)
        x = self.relu_last(x)
        x = self.avgpool(x)
        x = x.view(x.size(0), -1)
        x = self.fc(x)
        x = nn.functional.softmax(x)

        return x


def resnet(**kwargs):
    """
    Constructs a ResNet model.
    """
    return ResNet(**kwargs)

def resnet10(num_classes=10):
    return resnet(depth=10, num_classes=num_classes)

def resnet18(num_classes=1000):
    return resnet(depth=18, num_classes=num_classes)


def resnet34(num_classes=1000):
    return resnet(depth=32, num_classes=num_classes)


def resnet50(num_classes=1000):
    return resnet(depth=56, num_classes=num_classes)