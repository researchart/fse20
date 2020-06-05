
export PYTHONPATH=$PYTHONPATH:..
export PYTHONPATH=$PYTHONPATH:../NNSlicing

VICTIM=resnet10cifar10
BUDGET=50000
OUTPUT=results/finetune

python knockoff/adversary/test_protection.py \
$VICTIM \
resnet10 \
CIFAR10 \
--output $OUTPUT \
--budget $BUDGET \
--device_id 1 \
--resume $VICTIM/checkpoint.pth.tar \

