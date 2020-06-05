% Copyright by University of Luxembourg 2019-2020. 
% Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg. 
% Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg. 
% Developed by Shiva Nejati, shiva.nejati@uni.lu University of Luxembourg. 
% Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg. 

% writeAssum takes the execution time during one iteration and the files name and 
% writes the execution time to the text file.

function  writeAssum(assumption,file,count,executiontime)    
    fid1=fopen([file,'.txt'],'a');
    fprintf(fid1,'%s\n',[num2str(count),',',assumption,',',num2str(executiontime)]);
    fclose(fid1);
end