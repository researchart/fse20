import numpy as np 
import cvxopt as cvx 
from cvxopt import solvers

solvers.options['show_progress'] = False

class MPCController:
	""" Definition of a Controller
	    Computes a control action according to an MPC control law
	    u(k+1) = f(u,yo,y)
	    where
	    - u is the control signal
	    - yo is the set point
	    - y is the measured output
	"""
	def __init__(self,A,B,C,D,L,Q,P,Lk,Pk,Qn,Rn,Umin,Umax,DeltaUmin,DeltaUmax,optim=True,fast=False,time_varying=False):
		# System matrices
		self.A = A
		self.B = B
		self.C = C
		self.D = D

		self.n = A.shape[0]
		self.m = B.shape[1]
		self.p = C.shape[0]

		# Augmented system (velocity form) with augmented state xt' = [\Delta x' y']'
		self.At = np.r_[np.c_[A,np.zeros((self.n,self.p))],np.c_[C,np.eye(self.p)]]
		self.Bt = np.r_[B, np.zeros((self.p,self.m))]
		self.Ct = np.c_[C, np.eye(self.p)]

		self.nt = self.At.shape[0]
		self.mt = self.Bt.shape[1]
		self.pt = self.Ct.shape[0]

		# Control parameters
		## If unconstrained optimization and fast execution,
		#  then limit the prediction horizon to 1
		if fast and not(optim):
			print "[MPCController] Warning! Prediction horizon limited to L=1 due to configuration!"
			self.L = 1
			self.Q  = Q[0:self.p*self.L,0:self.p*self.L]
			self.P  = P[0:self.m*self.L,0:self.m*self.L]
			self.P1 = P[0:self.m,0:self.m]
		else:
			self.L  = L
			self.Q  = Q
			self.P  = P
			self.P1 = P[0:self.m,0:self.m]

		# Controller state
		self.uu = np.zeros((self.m,1))

		# Control saturations
		self.Umin = Umin
		self.Umax = Umax
		self.DeltaUmin = DeltaUmin
		self.DeltaUmax = DeltaUmax

		# Kalman filter parameters
		self.Lk = Lk
		self.Pk = Pk
		self.Qn = Qn
		self.Rn = Rn

		# Kalman filter states
		self.xe = np.zeros((self.n,1))
		self.xe_old = np.zeros((self.n,1))
		self.ye = np.zeros((self.p,1))

		# Online optimization
		self.optim = optim
		# Faster version of optim
		self.fast = fast
		# Time-varying Kalman-filter
		self.time_varying = time_varying


		# Compute optimization matrices
		if fast:
			self.OL,self.FL,self.H = self.compute_optim_matrices_fast(self.At,self.Bt,self.Ct,self.L,self.Q,self.P1)
		else:
			self.OL,self.FL,self.H = self.compute_optim_matrices(self.At,self.Bt,self.Ct,self.L,self.Q,self.P)


	def initialize_controller_state(self,u):
		self.uu = u

	def compute_optim_matrices_fast(self,At,Bt,Ct,L,Q,P):
		nt = At.shape[0]
		mt = Bt.shape[1]
		pt = Ct.shape[0]

		# Control matrices
		OL = np.zeros((L*pt,nt));
		for i in range(1,L+1):
		    OL[(i-1)*pt:i*pt,:] = Ct*np.linalg.matrix_power(At,i-1);

		FL = OL*Bt;

		# Optimization matrices for the QP problem
		H = FL.T*Q*FL + P;
		return OL,FL,H

	def compute_optim_matrices(self,At,Bt,Ct,L,Q,P):
		nt = At.shape[0]
		mt = Bt.shape[1]
		pt = Ct.shape[0]

		# Control matrices
		OL = np.zeros((L*pt,nt));
		for i in range(1,L+1):
		    OL[(i-1)*pt:i*pt,:] = Ct*np.linalg.matrix_power(At,i-1);

		HL = np.zeros((L*pt,(L-1)*mt));
		for i in range(2,L+1):
		    for j in range(1,i):
		        HL[(i-1)*pt:i*pt,(j-1)*mt:j*mt] = Ct*np.linalg.matrix_power(At,i-2-j+1)*Bt;

		FL = np.c_[OL*Bt,HL];

		# Optimization matrices for the QP problem
		H = FL.T*Q*FL + P;
		return OL,FL,H


	## Control law
	#  it computes the control values u given the setpoint sp
	#  and the last measured output value y
	def compute_u(self,y,sp):
		# Kalman filtering
		if self.time_varying:
			# Measurement update
			Mn = self.Pk*self.C.T*np.linalg.inv(self.C*self.Pk*self.C.T + self.Rn);
			self.ye = self.C*self.xe_old;
			self.xe = self.xe_old + Mn*(y-self.ye);
			self.Pk = (np.eye(self.n) - Mn*self.C)*self.Pk;

			# Time update
			self.xe = self.A*self.xe + self.B*self.uu;
			self.Pk = self.A*self.Pk*self.A.T + self.B*self.Qn*self.B.T;
		else:
			self.ye = self.C*self.xe_old
			self.xe = self.A*self.xe_old + self.B*self.uu + self.Lk*(y - self.ye)

		# Control law with constraints
		DeltaX = self.xe - self.xe_old

		# If optimization needs to be used then solve MPC with constraints
		deltaU = self.compute_mpc(DeltaX,y,sp)
		deltaU = np.minimum(np.maximum(deltaU,self.DeltaUmin),self.DeltaUmax)

		# Storing states
		self.xe_old = self.xe
		self.uu = self.uu + deltaU

		# Saturation just to make sure that everything went fine
		# Needed when solving without optimization
		self.uu = np.minimum(np.maximum(self.uu,self.Umin),self.Umax)

		return self.uu

	## MPC control law with constraints (online optimization)
	#  it computes deltaU accounting also for saturations and maximum increment
	def compute_mpc(self,DeltaX,y,sp):
		# Inequality matrix
		if self.fast:
			AA = np.r_[np.r_[np.eye(self.m),-np.eye(self.m)],np.r_[np.eye(self.m),-np.eye(self.m)]];
			bb = np.r_[np.r_[self.DeltaUmax,-self.DeltaUmin],np.r_[self.Umax-self.uu,-self.Umin+self.uu]];
		else:
			mL = self.m*self.L
			S = np.zeros((mL,mL))
			cc = np.zeros((mL,self.m))
			for i in range(1,self.L+1):
				for j in range(1,i):
					S[(i-1)*self.m:i*self.m,(j-1)*self.m:j*self.m] = np.eye(self.m)
				cc[(i-1)*self.m:i*self.m,:] = np.eye(self.m)

			DeltaUminVec = np.tile(self.DeltaUmin,(self.L,1))
			DeltaUmaxVec = np.tile(self.DeltaUmax,(self.L,1))
			UminVec = np.tile(self.Umin,(self.L,1))
			UmaxVec = np.tile(self.Umax,(self.L,1))

			# Optimization matrices
			AA = np.r_[np.r_[np.eye(mL),-np.eye(mL)],np.r_[S,-S]]
			ccu = cc.dot(self.uu)
			bb = np.r_[np.r_[DeltaUmaxVec,-DeltaUminVec],np.r_[UmaxVec-ccu,-UminVec+ccu]]

		# Control law
		r  = np.tile(sp,(self.L,1));
		xk = np.r_[DeltaX,y];
		pL = self.OL*self.At*xk;
		fk = self.FL.T*self.Q*(pL-r);
		 
		if self.optim:
			sol = solvers.qp(cvx.matrix(np.array(self.H)),cvx.matrix(np.array(fk)),cvx.matrix(np.array(AA)),cvx.matrix(np.array(bb)));
			deltaUL = np.matrix(sol['x'])
		else:
			deltaUL = -np.linalg.inv(self.H)*fk;

		if self.fast:
			return deltaUL
		else:
			return deltaUL[0:self.mt]


	def getXEst(self):
		return self.xe

	def getYEst(self):
		return self.ye



