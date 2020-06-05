import math
import sys
import os
import random
from PIL import Image
from PIL import ImageOps
import numpy as np
import libs.ssim as ssim
import libs.utils as ut
import ctls.mpc as mpccontroller
import ctls.random as randomcontroller
import ctls.bangbang as bangbangcontroller
import ctls.integral as integralcontroller
import ctls.greedy as greedycontroller

def image_to_matrix(path):
	img = Image.open(str(path))
	img = ImageOps.grayscale(img)
	img_data = img.getdata()
	img_tab = np.array(img_data)
	w,h = img.size
	img_mat = np.reshape(img_tab, (h,w))
	return img_mat

def compute_ssim(path_a, path_b):
	matrix_a = image_to_matrix(path_a)
	matrix_b = image_to_matrix(path_b)
	return ssim.compute_ssim(matrix_a, matrix_b)
	
def generate_random_configuration():
	# random quality - min or max
	if bool(random.getrandbits(1)):
		quality = 100
	else:
		quality = 1
	# random sharpen - min or max
	if bool(random.getrandbits(1)):
		sharpen = 5
	else:
		sharpen = 0
	# random noise - min or max
	if bool(random.getrandbits(1)):
		noise = 5
	else:
		noise = 0
	# return random choice
	return (quality, sharpen, noise)

def encode(i, frame_in, frame_out, quality, sharpen, noise):
	framename = str(i).zfill(8) + '.jpg'
	img_in = frame_in + '/' + framename
	img_out = frame_out + '/' + framename
	# generating os command for conversion
	# sharpen actuator
	if sharpen != 0:
		sharpenstring = ' -sharpen ' + str(sharpen) + ' '
	else:
		sharpenstring = ' '
	# noise actuator
	if noise != 0:
		noisestring = ' -noise ' + str(noise) + ' '
	else:
		noisestring = ' '
	# command setup
	command = 'convert {file_in} -quality {quality} '.format(
			file_in = img_in, quality = quality)
	command += sharpenstring
	command += noisestring
	command += img_out
	# executing conversion
	os.system(command)
	# computing current values of indices
	current_quality = compute_ssim(img_in, img_out)
	current_size = os.path.getsize(img_out)
	return (current_quality, current_size)

# -------------------------------------------------------------------

def main(args):

	# parsing arguments
	mode = args[1] # identify, mpc
	folder_frame_in = args[2]
	folder_frame_out = args[3]
	folder_results = args[4]
	setpoint_quality = float(args[5])
	setpoint_compression = float(args[6])
	
	# getting frames and opening result file
	path, dirs, files = os.walk(folder_frame_in).next()
	frame_count = len(files)
	final_frame = frame_count + 1
	log = open(folder_results + '/results.csv', 'w')
	
	if mode == "mpc":
		controller = mpccontroller.initialize_mpc()
	elif mode == "random":
		controller = randomcontroller.RandomController()
	elif mode == "bangbang":
		controller = bangbangcontroller.BangbangController()
	elif mode == "integral":
		controller = integralcontroller.IntegralController()
	elif mode == "greedy":
		controller = greedycontroller.GreedyController()
	
	# initial values for actuators
	ctl = np.matrix([[100], [0], [0]])

	# initialize performance parameter
	integrated_ssim_error = 0.0
	integrated_size_error = 0.0
		
	for i in range(1, final_frame):
		# main loop
		ut.progress(i, final_frame) # display progress bar
		quality = np.round(ctl.item(0))
		sharpen = np.round(ctl.item(1))
		noise = np.round(ctl.item(2))

		# encoding the current frame
		(current_quality, current_size) = \
			encode(i, folder_frame_in, folder_frame_out, quality, sharpen, noise)
		log_line = '{i}, {quality}, {sharpen}, {noise}, {ssim}, {size}'.format(
			i = i, quality = quality, sharpen = sharpen, noise = noise,
			ssim = current_quality, size = current_size)
		print >>log, log_line
		
		setpoints = np.matrix([[setpoint_quality], [setpoint_compression]])
		current_outputs = np.matrix([[current_quality], [current_size]])
		
		# compute integrated error with relu
		error = np.subtract(setpoints,current_outputs)
		ssim_error = error.item(0)
		size_error = error.item(1)
		if (ssim_error > 0.0):
			integrated_ssim_error = integrated_ssim_error + ssim_error
		if (size_error < 0.0):
			integrated_size_error = integrated_size_error - size_error

		# computing actuator values for the next frame
		if mode == "mpc":
			try:
				ctl = controller.compute_u(current_outputs, setpoints)
			except Exception:
				pass

		elif mode == "random":
			ctl = controller.compute_u()
			
		elif mode == "bangbang":
			ctl = controller.compute_u(current_outputs, setpoints)

		elif mode == "integral":
			ctl = controller.compute_u(current_outputs, setpoints)
		elif mode == "greedy":
			action = np.matrix([[quality], [sharpen], [noise]])
			ctl = controller.compute_u(current_outputs, setpoints, action)
		# end of loop over the frames
	
	# divide by number of frames to obtain weighted error
	average_ssim_error = integrated_ssim_error/final_frame
	average_size_error = integrated_size_error/final_frame
	# print to file performance parameter
	tmp = folder_frame_in.split('/')
	video_name = tmp[2]
	folder_name = tmp[1]
	log_performance_parameter = open('results/summary/'+mode+'/performance_log_'+folder_name+'.csv', 'a')
	log_line_performance = '{video}, {controller}, {target_ssim}, {target_size}, {average_ssim_error}, {average_size_error}'.format(
			video = video_name , controller = mode , target_ssim = setpoint_quality , target_size = setpoint_compression, average_ssim_error = average_ssim_error, average_size_error = average_size_error)
	print >>log_performance_parameter, log_line_performance
	print " done"

if __name__ == "__main__":
	main(sys.argv)
  
