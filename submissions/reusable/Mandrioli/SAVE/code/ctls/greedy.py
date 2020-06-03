import numpy as np;

class GreedyController:

	def __init__(self, seed=0):
		self.epsilon = 0.2 # probability of taking random action
		self.controllers = [] # list of tried settings
		self.performance = [] # list of obtained performance
		np.random.seed(seed)

	def compute_u(self, current_outputs, setpoints, action):
		error = np.subtract(setpoints,current_outputs) # compute errors
		ssim_error_normalized = (max( error.item(0), 0))/setpoints.item(0)
		size_error_normalized = (max(-error.item(1), 0))/setpoints.item(1)
		current_performance = ssim_error_normalized + size_error_normalized
		# look for the action in the already known settings
		found = -1	
		i=0
		for x in self.controllers :
			if np.array_equal(action,x):
				found = i #self.controllers.index(x)
			i=i+1
		# if used a known setting update errors
		if found>=0 : 
			self.performance[found]=current_performance
		else : # otherwise append new info
			self.controllers.append(action)
			self.performance.append(current_performance)

		#immplement epsilon greedy approach
		if len(self.controllers)>10 and np.random.random_sample()>self.epsilon : 
			# epsilon not triggered - choose best setting found so far
			index = self.performance.index(min(self.performance))
			self.ctl = self.controllers[index]
		else : 
			#epsilon is triggered, take random action
			quality = np.random.random_integers(20, 100) # generate random number
			sharpen = np.random.random_integers(0, 5) # generate random number
			noise = np.random.random_integers(0, 5) #generate random number
			self.ctl = np.matrix([[quality], [sharpen], [noise]])
		return self.ctl
	
