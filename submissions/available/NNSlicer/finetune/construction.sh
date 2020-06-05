
export PYTHONPATH=$PYTHONPATH:..
export PYTHONPATH=$PYTHONPATH:../NNSlicing

STRATEGY=random
# VICTIM=models/victim/tf_resnet10cifar10
VICTIM=resnet10cifar10
BUDGET=50000
ADVDIR=$VICTIM
# ADVDIR=test


export PYTHONPATH=$PYTHONPATH:..
CUDA_VISIBLE_DEVICES=1 \
python knockoff/adversary/transfer.py \
$STRATEGY \
$VICTIM \
--out_dir $ADVDIR \
--begin_budget 0 \
--end_budget $BUDGET \
--inc_budget $BUDGET \
--queryset CIFAR10 \
--batch_size 500 \
