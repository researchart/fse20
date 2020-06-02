% Copyright by University of Luxembourg 2019-2020. 
% Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg. 
% Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg. 
% Developed by Shiva Nejati, shiva.nejati@uni.lu University of Luxembourg. 
% Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg. 

%   WRITEQCT takes the assumption, the file name and kmax the simulation time
%   transtaled into QVtrace time. It writes the qct formula into the file.
%   The qct formula includes setting kmax, the assumption and the property.

function writeQCT(assumption,qctfilename,kmax)
    kmax=['set k_max=',num2str(kmax),';'];
    S = fileread(qctfilename);
    S = [kmax, char(10),assumption, char(10), S];
    FID = fopen(qctfilename, 'w');
    if FID == -1, error('Cannot open file %s', qctfilename); end
    fwrite(FID, strcat(S), 'char');
    fclose(FID);
end