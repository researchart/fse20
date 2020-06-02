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

function y = CustomInputSignal_FixedTime(x,timeStamps)

%nr of samples
ns = length(timeStamps);
y = zeros(ns,1);

%signal constant until x6 which is greater than 5,
y(timeStamps<5) = x(1);

%samples where signal is constant
nsConst = find(timeStamps<5 == 1);

%timeStamp where signal changes from constant to interpolated
interpTimeSamp = timeStamps(nsConst(end)+1);

%Total simulation time
simTime = timeStamps(end); 

%Interpolation time vector
timeVector = interpTimeSamp:(simTime-interpTimeSamp)/8:simTime;

%interpolation signal, in this case linear interpolation is utilized
interpSignal = zeros(ns-nsConst(end),1);
interpSignal(:,1) = interp1(timeVector,x,timeStamps(nsConst(end)+1:end), 'linear');

%add interpolated signal after constant signal
y(nsConst(end) + 1:end) = interpSignal;

%For ploting, not necessary in your custom function
plot(timeStamps,y); hold on;
axis([0 30 0 100])
title('Fixed time custom input signals')
pause(0.05)

end