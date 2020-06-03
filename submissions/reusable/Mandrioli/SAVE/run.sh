#!/bin/bash

# ----------------- FIX ME ------------------------------------------------ #
# This script executes the compression case study: it takes all the #
# mp4 videos placed in the folder "videos" and process them. The       #
# processing is done in two steps: prepare, and encode.             #
# The prepare step creates the folder structure needed to execute   #
# the rest and unpacks the video into frames that are stored in the #
# corresponding folder. The encode step executes the encoder        #
# alongside with the control strategy that sets the actuator values #
# to obtain the goals.                                              #
#                                                                   #
# For each of the frames, the two procedures use as actuators three #
# parameters of the convert system call:                            #
#   - quality (from 1 to 100)                                       #
#   - noise (from 0 to 5)                                           #
#   - sharpen (from 0 to 5)                                         #
#                                                                   #
# There are three adaptation strategies already designed:           #
#   - random: just select random values for the actuators           #
#   - bangbang: implements a bangbang controller                    #
#   - mpc: implements a model predictive controller                 #
#                                                                   #
# The controllers tries to achieve two objectives:                  #
#   - a setpoint on the similarity with the original frame (ssim)   #
#   - a setpoint on the frame size after the conversion             #
# ----------------------------------------------------------------- #

DIR_FRAMES=frames
DIR_FRAMES_ORIG=orig
DIR_FRAMES_PROC=proc
DIR_RESULTS=results
DIR_RESULTS_SUMMARY=summary
PROGRAM=./code/encoder.py

print_usage ()
{
  echo "<usage> call this script with parameters:"
  echo "  ./run.sh input_folder control"
  echo "           <input_folder : the subfolder of /frames to process>"
  echo "           <control : the adaptation strategy for the encoding>"
  exit
}

encode ()
{
	V=$1; INPUTFOLDER=$2; METHOD=$3; QUALITY=$4; FRAMESIZE=$5;
	ORIG=${DIR_FRAMES}/${INPUTFOLDER}/${V}/${DIR_FRAMES_ORIG};
	BASIC_PROC=${DIR_FRAMES}/${INPUTFOLDER}/${V}/${DIR_FRAMES_PROC};
	BASIC_RESULTS=${DIR_RESULTS}/${INPUTFOLDER}/${V};
	
	if [[ -z "${QUALITY// }" ]]; then QUALITY=0.9; fi
	if [[ -z "${FRAMESIZE// }" ]]; then FRAMESIZE=8000; fi
	
	SUFFIX="${METHOD}-Q${QUALITY}-F${FRAMESIZE}"
	PROC="${BASIC_PROC}/${SUFFIX}"
	RESULTS="${BASIC_RESULTS}/${SUFFIX}"
	mkdir -p ${RESULTS}
	mkdir -p ${PROC}
	rm -rf ${RESULTS}/*
	rm -rf ${PROC}/*
	
	echo "  [encode] encoding of $V ($QUALITY, $FRAMESIZE)"
	python $PROGRAM $METHOD \
		$ORIG $PROC $RESULTS \
		$QUALITY $FRAMESIZE
	echo "  [encode] encoding of $V terminated"
	
}


# ----------------------------------------------------------------- #

# usage printing
if [[ "$#" -eq 0 ]]; then
	print_usage;
	exit;
fi

#####################
# normal usage mode #
#####################

# input handling
INPUTFOLDER=$1 # the subfolder of the directory /${DIR_FRAMES} that you want to
               # process: it should contain one folder per video each containing
               # a folder DIR_FRAMES_ORIG with the unprocessed frames. 
               # unpacked_360P, unpacked_480P, unpacked_720P, unpacked_1080P, 
               # unpacked_2160P
METHOD=$2      # the adaptation strategy
QUALITY=0.9    # ssim setpoint (an input in the original SAVE artifact,
               # always set to 0.9 in the ESEC/FSE paper experiments)

# create results directory if needed
mkdir -p ${DIR_RESULTS}
mkdir -p ${DIR_RESULTS}/${DIR_RESULTS_SUMMARY}
mkdir -p ${DIR_RESULTS}/${DIR_RESULTS_SUMMARY}/${METHOD}

VIDEOS=`ls ${DIR_FRAMES}/$INPUTFOLDER` # get list of videos to be processed
for VIDEO in $VIDEOS; do # iterate over the videos
	echo "Processing $VIDEO"
	# create directory for output logging
	BASIC_RESULTS=${DIR_RESULTS}/${INPUTFOLDER}/${VIDEO}; mkdir -p ${BASIC_RESULTS}
	# create direcotry for processed frames
	PROC=${DIR_FRAMES}/${INPUTFOLDER}/${VIDEO}/${DIR_FRAMES_PROC}; mkdir -p ${PROC}

	# get size reference from stored ones
	cd size_references/${METHOD}/${INPUTFOLDER}
	while IFS=, read -r VID ADAPT QUALITY_REF SIZE_REF  
		do
		if [[ $VID == $VIDEO ]]; then
			FRAMESIZE=$SIZE_REF;
		fi
	done < ref.csv
	cd ../../..
	
	echo "Setpoints: $QUALITY for quality and $FRAMESIZE for framesize"
	# encode the video
	encode $VIDEO $INPUTFOLDER $METHOD $QUALITY $FRAMESIZE

done


# cleanup
rm -f ./code/*/*.pyc

