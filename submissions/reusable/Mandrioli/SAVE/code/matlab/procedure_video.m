% Parameter passed at the command line is "video"

%% Target file for storing function
file_fun = '../ctls/mpc.py';

%% Import data
sampling_period = 1;
filename = ['../../results/', video, '/identification/results.csv'];
[frame, quality, sharpen, noise, ssim, size_frame] = importfile_video(filename);

data = iddata([ssim, size_frame], [quality, sharpen,noise], sampling_period);
data.InputName  = {'quality'; 'sharpen'; 'noise_value'};
data.OutputName = {'ssim'; 'size'};

%% Identify model
[A,B,C,D] = identify_model(data, sampling_period);
sys = ss(A, B, C, D, sampling_period);

% Saving data dimensions
n = size(A, 1);
m = size(B, 2);
p = size(C, 1);

%% Control parameters
L = 4;
q_vec = [1e3, 1e-4]; % given for the control generation
r_vec = [1e3, 1e5,1e5]; % given for the control generation
Q = diag(repmat(q_vec, 1, L));
R = diag(repmat(r_vec, 1, L));

Umin = [1, 0, 0]';
Umax = [99, 5, 5]';
DeltaUmin = [-10, -1, -1]';
DeltaUmax = [10, 1, 1]';

%% Kalman filter design
Qn = 1e0 * eye(m, m);
Rn = 1e0 * eye(p, p);

[kal,Lk,Pk,Mk] = kalman(sys,Qn,Rn);

%% Setpoint
sp = [0.9, 25000]';

%% Write needed matrices in Python
out = write_python_fun(A, B, C, D, L, q_vec, r_vec, ...
    Umin, Umax, DeltaUmin, DeltaUmax, ...
    diag(Qn), diag(Rn), Lk, Pk, sp);

fid = fopen(file_fun, 'w+');
fprintf(fid, out);
fclose(fid);

fprintf(['    control generated in ',file_fun,'\n']);
