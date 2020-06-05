import tensorflow as tf
from pdb import set_trace as st
import math
import random

class Transforms():
    def __init__(self, *transforms):
        self.transforms = transforms

    def __call__(self, image):
        for transform in self.transforms:
            image = transform(image)
        return image

'''
Translate tf tensor image
'''
def translate_image(image, dx, dy):
    assert image.shape[2] == 1 or image.shape[2] == 3
    # from https://nanonets.com/blog/data-augmentation-how-to-use-deep-learning-when-you-have-limited-data-part-2/
    # image should of shape [H,W,C]
    pad_top, pad_left = abs(dy), abs(dx)
    pad_bottom, pad_right = abs(dy), abs(dx)
    height, width = image.shape[:-1]
    image = tf.image.pad_to_bounding_box(image,
            pad_top, pad_left,
            height + pad_bottom + pad_top, width + pad_right + pad_left)
    if dx>0:
        offset_width = 0
    elif dx<0:
        offset_width = 2*abs(dx)
    else:
        offset_width = abs(dx)
    if dy>0:
        offset_height = 0
    elif dy<0:
        offset_height = 2*abs(dy)
    else:
        offset_height = abs(dy)
    image = tf.image.crop_to_bounding_box(image,
            offset_height, offset_width, height, width)
    return image


class Translate():
    def __init__(self, dx=0, dy=0):
        self.dx, self.dy = dx, dy

    def __call__(self, image):
        return translate_image(image, self.dx, self.dy)

class RandomTranslate():
    def __init__(self, dx=0, dy=0):
        self.dx, self.dy = dx, dy

    def __call__(self, image):
        dx = random.randrange(-self.dx, self.dx+1)
        dy = random.randrange(-self.dy, self.dy+1)

        return translate_image(image, dx, dy)

'''
Resize tf tensor image
'''
def resize(image, ratio):
    # image should of shape [H,W,C]
    assert image.shape[2] == 1 or image.shape[2] == 3
    h, w = int(image.shape[0]), int(image.shape[1])

    new_h, new_w = int(h*ratio), int(w*ratio)
    new_size = tf.constant([new_h,new_w],dtype=tf.int32)
    image = tf.image.resize_images(image, [new_h, new_w], align_corners=True)
    image = tf.image.resize_image_with_crop_or_pad(image, h, w)
    return image

class Resize():
    def __init__(self, ratio=1):
        self.ratio = ratio

    def __call__(self, image):
        return resize(image, self.ratio)

class RandomResize():
    def __init__(self, min_ratio=1, max_ratio=1):
        self.min_ratio = min_ratio
        self.max_ratio = max_ratio

    def __call__(self, image):
        ratio = random.uniform(self.min_ratio, self.max_ratio)
        return resize(image, ratio)


'''
Rotate tf tensor image
'''
def rotate(image, angle):
    # image should of shape [H,W,C]
    assert image.shape[2] == 1 or image.shape[2] == 3

    rotated_image = tf.contrib.image.rotate(
                        image, angle * math.pi / 180,
                        interpolation='BILINEAR'
                    )
    return rotated_image

class Rotate():
    def __init__(self, angle=0):
        self.angle = angle

    def __call__(self, image):
        return rotate(image, self.angle)

class RandomRotate():
    def __init__(self, angle=0):
        self.angle = angle

    def __call__(self, image):
        angle = random.uniform(-self.angle, self.angle)
        return rotate(image, angle)



if __name__=='__main__':
    t = Transforms([3,4,5])
