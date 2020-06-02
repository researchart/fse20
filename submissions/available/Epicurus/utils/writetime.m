% Copyright by University of Luxembourg 2019-2020. 
% Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg. 
% Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg. 
% Developed by Shiva Nejati, shiva.nejati@uni.lu University of Luxembourg. 
% Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg. 

% WRITETIME takes the file name and the time and writes the time in the file
function writetime(file,time)
    fid=fopen(file,'wt');
    fprintf(fid,'%s',num2str(time));
    fclose(fid);
end