#!/bin/bash - 

USER_DIR="iso"
LOG_DIR="/data/isolate_exp_data/js-conflict/large_scale_scripts/reusable_fse20" # Modify this to your local folder where the log files should be saved, please use absolute path
PROCESSED_DATA_DIR="$LOG_DIR/processed_data"
FUNC_DATA_DIR="$PROCESSED_DATA_DIR/conflicting_data"
SCRIPT_DIR=$PWD 

# Modify the following options to define the start/end rank, the number of processes and instances
START=1
END=1000
NUM_PROCESSES=256
NUM_INSTANCES=512

# You can comment some of the commands below to avoid redoing some computation
#date
#echo python collect_logs.py -u $USER_DIR -d $LOG_DIR -s $START -e $END -n $NUM_INSTANCES -p $NUM_PROCESSES
#time python collect_logs.py -u $USER_DIR -d $LOG_DIR -s $START -e $END -n $NUM_INSTANCES -p $NUM_PROCESSES

#echo $LOG_DIR
#echo $SCRIPT_DIR
#echo $PROCESSED_DATA_DIR
#echo $FUNC_DATA_DIR

date
echo python parse_logs_using_ids.py -u $USER_DIR -d $LOG_DIR -s $START -e $END -n $NUM_INSTANCES -p $NUM_PROCESSES #
time python parse_logs_using_ids.py -u $USER_DIR -d $LOG_DIR -s $START -e $END -n $NUM_INSTANCES -p $NUM_PROCESSES 

date
echo python func-parse_logs.py -u $USER_DIR -d $LOG_DIR -s $START -e $END -n $NUM_INSTANCES -p $NUM_PROCESSES 
time python func-parse_logs.py -u $USER_DIR -d $LOG_DIR -s $START -e $END -n $NUM_INSTANCES -p $NUM_PROCESSES 



date
echo python func-detect_conflicts.py -u $USER_DIR -d $PROCESSED_DATA_DIR -s $START -e $END -n $NUM_INSTANCES -p $NUM_PROCESSES 
time python func-detect_conflicts.py -u $USER_DIR -d $PROCESSED_DATA_DIR -s $START -e $END -n $NUM_INSTANCES -p $NUM_PROCESSES 

date
echo python preprocess_conflicts_using_ids.py -u $USER_DIR -d $PROCESSED_DATA_DIR -s $START -e $END -n $NUM_INSTANCES -p $NUM_PROCESSES -f $FUNC_DATA_DIR -r $LOG_DIR
time python preprocess_conflicts_using_ids.py -u $USER_DIR -d $PROCESSED_DATA_DIR -s $START -e $END -n $NUM_INSTANCES -p $NUM_PROCESSES -f $FUNC_DATA_DIR -r $LOG_DIR

date
echo python extract_rank2urls.py -u $USER_DIR -d $LOG_DIR -s $START -e $END -n $NUM_INSTANCES -p $NUM_PROCESSES -o $PROCESSED_DATA_DIR
time python extract_rank2urls.py -u $USER_DIR -d $LOG_DIR -s $START -e $END -n $NUM_INSTANCES -p $NUM_PROCESSES -o $PROCESSED_DATA_DIR



date
echo python categorize_conflicts.py -u $USER_DIR -d $PROCESSED_DATA_DIR -s $START -e $END -n $NUM_INSTANCES -p $NUM_PROCESSES -l $LOG_DIR
time python categorize_conflicts.py -u $USER_DIR -d $PROCESSED_DATA_DIR -s $START -e $END -n $NUM_INSTANCES -p $NUM_PROCESSES -l $LOG_DIR

date
echo python summarize_conflicts.py -u $USER_DIR -d $PROCESSED_DATA_DIR -s $START -e $END -n $NUM_INSTANCES -p $NUM_PROCESSES -o $SCRIPT_DIR
time python summarize_conflicts.py -u $USER_DIR -d $PROCESSED_DATA_DIR -s $START -e $END -n $NUM_INSTANCES -p $NUM_PROCESSES -o $SCRIPT_DIR


date
echo python check_conflict_var_usage_using_ids.py -u $USER_DIR -d $PROCESSED_DATA_DIR -s $START -e $END -n $NUM_INSTANCES -p $NUM_PROCESSES -r $LOG_DIR
time python check_conflict_var_usage_using_ids.py -u $USER_DIR -d $PROCESSED_DATA_DIR -s $START -e $END -n $NUM_INSTANCES -p $NUM_PROCESSES -r $LOG_DIR

date
echo python summarize_used_conflicts.py -u $USER_DIR -d $PROCESSED_DATA_DIR -s $START -e $END -n $NUM_INSTANCES -p $NUM_PROCESSES -o $SCRIPT_DIR
time python summarize_used_conflicts.py -u $USER_DIR -d $PROCESSED_DATA_DIR -s $START -e $END -n $NUM_INSTANCES -p $NUM_PROCESSES -o $SCRIPT_DIR



date
echo python parallel_select_duplicate_funcs.py -u $USER_DIR -d $PROCESSED_DATA_DIR -s $START -e $END -n $NUM_INSTANCES -p $NUM_PROCESSES -f $FUNC_DATA_DIR -r $LOG_DIR
time python parallel_select_duplicate_funcs.py -u $USER_DIR -d $PROCESSED_DATA_DIR -s $START -e $END -n $NUM_INSTANCES -p $NUM_PROCESSES -f $FUNC_DATA_DIR -r $LOG_DIR

date
echo python summarize_duplicate_funcs.py -u $USER_DIR -d $PROCESSED_DATA_DIR -s $START -e $END -n $NUM_INSTANCES -p $NUM_PROCESSES -o $SCRIPT_DIR
time python summarize_duplicate_funcs.py -u $USER_DIR -d $PROCESSED_DATA_DIR -s $START -e $END -n $NUM_INSTANCES -p $NUM_PROCESSES -o $SCRIPT_DIR



date
echo python parallel_select_duplicate_scripts.py -u $USER_DIR -d $PROCESSED_DATA_DIR -s $START -e $END -n $NUM_INSTANCES -p $NUM_PROCESSES -f $FUNC_DATA_DIR -r $LOG_DIR
time python parallel_select_duplicate_scripts.py -u $USER_DIR -d $PROCESSED_DATA_DIR -s $START -e $END -n $NUM_INSTANCES -p $NUM_PROCESSES -f $FUNC_DATA_DIR -r $LOG_DIR

date
echo python summarize_duplicate_scripts.py -u $USER_DIR -d $PROCESSED_DATA_DIR -s $START -e $END -n $NUM_INSTANCES -p $NUM_PROCESSES -o $SCRIPT_DIR
time python summarize_duplicate_scripts.py -u $USER_DIR -d $PROCESSED_DATA_DIR -s $START -e $END -n $NUM_INSTANCES -p $NUM_PROCESSES -o $SCRIPT_DIR



date
echo python compute_all_stats.py
time python compute_all_stats.py
