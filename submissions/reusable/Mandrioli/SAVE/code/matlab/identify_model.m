function [A,B,C,D] = identify_model(data,sampling_period)
if nargin < 2
    sampling_period = 1;
end

identified_model = n4sid(data, 'best' ,'Ts',sampling_period,'Focus','simulation');
%identified_model.c(end,:) = -identified_model.c(end,:);
y=compare(data,identified_model);
[~,t_modl] = detrend(y);
[~,t_data] = detrend(data);
for i = 1:length(t_modl.OutputOffset)
    if sign(t_modl.OutputOffset(i)) ~= sign(t_data.OutputOffset(i))
        identified_model.c(i,:) = -identified_model.c(i,:);
    end
end
%compare(data,identified_model);
sys = ss(identified_model);

A = sys.a;
B = sys.b;
C = sys.c;
D = sys.d;
