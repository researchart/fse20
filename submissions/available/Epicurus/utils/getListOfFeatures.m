% Copyright by University of Luxembourg 2019-2020. 
% Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg. 
% Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg. 
% Developed by Shiva Nejati, shiva.nejati@uni.lu University of Luxembourg. 
% Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg. 

% GETLISTOFFEATURES constructs the control points names and the categorical control points indexes based on the
% input names and the number of control points. 
% INPUT
%   cp_names: are the control points names. 
%             Example: input_names= {'a','b'} , numberOfControlPoints=2:
%             the cp_names are: a1, a2, b1, b2.
%   initial_cat: indexes of categorical inputs.
%   numberOfControlPoints: the number of control points
%   input_names: the input names
%   cp_array: the array of control points
%
% OUTPUT
% categorical: indexes of categorical control points
% cp: control points names 

function [categorical,cp]=getListOfFeatures(initial_cat,numberOfControlPoints,input_names,cp_array)
          
    categorical = zeros(1,size(initial_cat,2)*numberOfControlPoints);
    cp=cell(1,sum(cp_array));
    n=1;
    c=1;
    for i = 1: size(cp_array,2)
       for j = 1: cp_array(i)
           cp{n}= strcat(input_names{i},num2str(j));
           if any(initial_cat==i)
               categorical(c)=n;
               c=c+1;
           end
           n=n+1;
       end
    end
end