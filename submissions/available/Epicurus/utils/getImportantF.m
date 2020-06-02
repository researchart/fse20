% Copyright by University of Luxembourg 2019-2020. 
% Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg. 
% Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg. 
% Developed by Shiva Nejati, shiva.nejati@uni.lu University of Luxembourg. 
% Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg. 

% GETIMPORTANTF selects the most important features to be used in the next test case
% generation.
% INPUTS
%   tree: the decision tree
%   count: the iteration counter
%   opt : epicurus_options . epicurus should be of type "epicurus_options". 
%       If the default options are going to be used, then this input may be
%       omitted. For instructions on how to change epicurus options, 
%       see the epicurus_options help file for each desired property.
% OUTPUTS:
% feature: the most important features

function feature=getImportantF(tree,count,opt)
    global hFeatures;
    feature=[];
    imp=predictorImportance(tree);
    sortedimp=sort(imp,'descend'); % sort the predictorImportance from max to min
    sortedimp( :,~any(sortedimp,1) ) = [];
    idx=find(imp(:)==sortedimp(1));
    if (count<=(opt.assumeIterations/2))
        feature=idx;
        hFeatures=feature;
    else
        if (count>(opt.assumeIterations/2) && (count<=(opt.assumeIterations/2+opt.assumeIterations/3)))
            if size(sortedimp,2)>=2
                idx=find(imp(:)==sortedimp(2));
                if ~ismember(idx,hFeatures)
                    feature=cat(2,hFeatures,idx);
                    hFeatures=feature;
                end
           else
               feature=hFeatures;
            end
        else
            for i= 1: size(sortedimp,2)
                idx=find(imp(:)==sortedimp(i));
                feature=cat(2,feature,idx);              
            end
            hFeatures=feature;
        end
    end

    if isempty(feature)% if the feature stays empty, it means all the feature were used as important features or all the features have 0 as importance
        if ~isempty(sortedimp)
            idx=find(imp(:)==sortedimp(1)); 
            feature=idx;      % the feature takes the the most important one 
            hFeatures=feature; % the history of features is reseted and takes the most important one.
        else
            feature=1;
        end
    end
end