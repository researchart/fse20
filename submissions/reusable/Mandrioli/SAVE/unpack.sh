#!/bin/bash

#############
# script to unpack the videos into frames
# - takes the videos from the subfolders of videos
# - extracts the frames of each video in a folder
#   in the frame directory with same structure as the
#   videos directory
#############

DIR_VIDEOS=videos
DIR_FRAMES=frames
DIR_FRAMES_ORIG=orig

# create frames directory if needed
mkdir -p ${DIR_FRAMES}

for dirname in `ls ${DIR_VIDEOS}`; do #iterate over 360P, 480P, 720P, 1080P, 2160P
	TARGETDIR="unpacked_${dirname}"
	mkdir -p ${DIR_FRAMES}/$TARGETDIR
	cd ${DIR_VIDEOS}/$dirname
	for filename in *.mp4; do
		base=${filename%.mp4}
		echo "I am unpacking the $base video"
		mkdir ../../${DIR_FRAMES}/${TARGETDIR}/${base}
        mkdir ../../${DIR_FRAMES}/${TARGETDIR}/${base}/${DIR_FRAMES_ORIG}
		mplayer -vo \
          jpeg:quality=100:outdir=../../${DIR_FRAMES}/${TARGETDIR}/${base}/${DIR_FRAMES_ORIG} \
		  $filename > /dev/null 2>&1
	done
	cd ../..
done

