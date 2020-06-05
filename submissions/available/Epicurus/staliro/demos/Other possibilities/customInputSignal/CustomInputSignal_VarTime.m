% CustomInputSignal_VarTime
%    This is an example of how to define custom input signal generators for
%    S-TaLiRo. See the CustomInputSignal_help.pdf for details. 
%
%    Inputs: 
%       x          - the values of the search variables as provided by S-Taliro
%       timeStamps - the points in time where the values of the signal are
%                    required
%    Output:
%       y - the signal values at the times in timeStamps
%
% See also: ComputeInputSignals
% (C) 2016, Bardh Hoxha, Arizona State University

function y = CustomInputSignal_VarTime(x,timeStamps)

%nr of samples
ns = length(timeStamps);
y = zeros(ns,1);

%signal constant until x6 which is greater than 5,
y(timeStamps<x(6)) = x(1);

%samples where signal is constant
nsConst = find(timeStamps<x(6) == 1);

%Total simulation time
simTime = timeStamps(end); 

%Interpolation time vector
timeVector = [x(6:9)' simTime];

%interpolation signal, in this case pchip is utilized
interpSignal = zeros(ns-nsConst(end),1);
interpSignal(:,1) = interp1(timeVector,x(1:5)',timeStamps(nsConst(end)+1:end), 'linear');

%add interpolated signal after constant signal
y(nsConst(end) + 1:end) = interpSignal;

%For ploting, not necessary in your custom function
plot(timeStamps,y); hold on;
axis([0 30 0 100])
title('Variable time custom input signals')
pause(0.05)

end