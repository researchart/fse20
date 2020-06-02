% S-Taliro script for the Heat Benchmark from the HSCC 04 paper by Fehnker & Ivancic
% This demo is modified from the original demo in order to demonstrate how
% to describe sample space as a polytope in the form Ax <= b.
%
% HOW TO DEFINE A POLYTOPE AS THE SAMPLE SPACE:
%
% The hit-and-run sampler take the samples from a sample space. 
% The dimensions of this sample space are the states of the system and the 
% control points for every input to the system. 
%
% When the "search_space_constrained" option is false, the sample 
% space is a hypercube whose size is determined by the minimum and
% maximum limit for the states and inputs.
%
% When the "search_space_constrained" option is true, the minimum and
% maximum limit for the states and inputs are still valid and the user can
% further add constraints between different dimensions.
% This is done by declaring a polytope with lower and upper bounds given as
% X0 and the input_range input to the staliro and the inequality "Ax <= b" 
% where x is a vector consisting of initial states of the system and the 
% control points for the inputs. 
% The vector x starts with the states (for which the ranges correspond to
% the X0 input) and continues with the control points for the inputs.
% User can define the matrix A and the vector b as "A_ineq" and "b_ineq"
% in the staliro options.
% 
% In this demo, for each control point of the first input, we will define
% the sample space as a triangle instead of a rectangle.
% We do not add any constraints for the state of the system and so the
% corresponding columns if the matrix A (the first 10 columns) will be all
% zeros.
% Range for the first input (u1) is [1, 2] and the range for the second
% input (u2) is [0.8, 1.2]. (The rectangle below)
%
%          |
%      2.0 _  ____________                   
%          |  |          |     
%          |  |          |             
%          |  |          |     
%          |  |          |
%          |  |  (area)  |
%  u1      |  |          |
%          |  |          |
%          |  |          |
%          |  |          |
%      1.0 +  | _________|
%          |            
%          |            
%          ---+----------+--- 
%            0.8        1.2    
%                  u2         
%
% We want the sample space to be constrained such that -0.4u1 + u2 <= 0.4
% Hence for each control point of the u1, we set -0.4, and for the u2 we
% set 1 at the corresponding locations of the matrix A and, we set the
% corresponding row of the vector b to 0.4.
%
%          |             
%      2.0 +             .                  
%          |            /|     
%          |           / |             
%          |          /  |     
%          |         /   |
%          |        /    |
%  u1      |       /     |
%          |      /      |
%          |     /(area) |
%          |    /        |
%      1.0 +   /_________|
%          |             
%          |              
%          ---+----------+--- 
%            0.8        1.2    
%                  u2         
%
% The resulting sample space is 15-dimensional polytope.
% It is possible to define constraints between inputs and system states and
% between different control points of an input.
% Please note that the resulting sample space is the intersection of the
% space created by Ax <= b inequality with the given ranges of the initial 
% states and inputs.

clear 

cd('..')
cd('SystemModelsAndData')

model = 'heat25830_staliro_02';
load heat30;
time = 24;
cp_array = [4 1];
input_range = [1 2; 0.8 1.2];
X0 = [17*ones(10,1) 18*ones(10,1)];
phi = '[]p';
pred.str = 'p';
pred.A = -eye(10);
pred.b = -[14.50; 14.50; 13.50; 14.00; 13.00; 14.00; 14.00; 13.00; 13.50; 14.00];

opt = staliro_options();
opt.runs = 1;
opt.optim_params.n_tests = 100;
opt.interpolationtype = {'pchip', 'const'};
opt.search_space_constrained.constrained = true; %This enables the use of polytopes
% Here we define A and b for Ax <= b.
% Note that we do it for every state and every cp of an input
% Here the first input has 4 cp's and the second input has 1 cp
opt.search_space_constrained.A_ineq = [0.4, 0, 0, 0, -1; 
                                       0, 0.4, 0, 0, -1; 
                                       0, 0, 0.4, 0, -1; 
                                       0, 0, 0, 0.4, -1];
opt.search_space_constrained.A_ineq = [zeros(4,10), opt.search_space_constrained.A_ineq]; %zeros for the states we don't put any constraints on.
opt.search_space_constrained.b_ineq = [-0.4; 
                                       -0.4; 
                                       -0.4; 
                                       -0.4];

results = staliro(model,X0,input_range,cp_array,phi,pred,time,opt);

figure(1)
clf
[T1,XT1,YT1,IT1] = SimSimulinkMdl(model,X0,input_range,cp_array,results.run(1).bestSample,time,opt);
subplot(2,1,1)
plot(T1,XT1)
title('State trajectories')
subplot(2,1,2)
plot(IT1(:,1),IT1(:,2))
title('Input Signal')

cd('..')
cd('Other possibilities')

