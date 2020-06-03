import numpy as np;

class RandomController:

	def __init__(self, seed=0):
		np.random.seed(seed)

	def compute_u(self):
		quality = np.random.random_integers(1, 100) # generate random number
		sharpen = np.random.random_integers(0, 5) # generate random number
		noise = np.random.random_integers(0, 5) #generate random number
		self.ctl = np.matrix([[quality], [sharpen], [noise]])
		return self.ctl
	

