import numpy as np;

class IntegralController:

	def __init__(self):
		self.quality = 50
		self.sharpen = 3
		self.noise = 5

	def compute_u(self, current_outputs, setpoints):	
	    # size control
		if (current_outputs.item(1) < setpoints.item(1)):
			self.quality = np.clip(self.quality + 5,1,100)
		elif (current_outputs.item(1) > setpoints.item(1)):
			self.quality = np.clip(self.quality - 5,1,100)
		# ssim control
		if (current_outputs.item(0) < setpoints.item(0)):
			self.sharpen = np.clip(self.sharpen - 1,0,5)
			self.noise = np.clip(self.noise - 1,0,5)
		elif (current_outputs.item(0) > setpoints.item(0)):
			self.sharpen = np.clip(self.sharpen + 1,0,5)
			self.noise = np.clip(self.noise + 1,0,5)
	
		self.ctl = np.matrix([[self.quality], [self.sharpen], [self.noise]])
		return self.ctl
	
