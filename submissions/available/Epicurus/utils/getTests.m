% Copyright by University of Luxembourg 2019-2020. 
% Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg. 
% Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg. 
% Developed by Shiva Nejati, shiva.nejati@uni.lu University of Luxembourg. 
% Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg. 

% GETTESTS selects the test inputs associated with the informative
% assumptions
%
% INPUT
%   tv: the test cases array
%   informativeA: informative assumptions (the assumptions associated with a fitness closest to the desired threshold value v)
%   inputnames: the input names
%   testSuiteSize: the size of the test suite
%
% OUTPUT
%   fOld: selected test cases associated with the informative assumptions.

function fOld=getTests(tv,informativeA,inputnames,testSuiteSize)
    new=[];
    fOld={};
    testSize=testSuiteSize/size(informativeA,1);
    if ~isempty(size(informativeA,1))
        infA=informativeA(:,1); % assumptions with the leaf node mean fitness is epsilon-close to v.
        for row=1: size(infA,1)
 % (number 0f constraints * 1 string array) extracts the group of constraints "cp1<1"
            p1=strfind(infA{row},'(');
            p2=strfind(infA{row},')');
            for pos = 1: size(p1,2)
                constraints{pos}=infA{row}(p1(pos)+1: p2(pos)-1);
            end
            for c = 1: size(constraints,2)
                for i = 1 : size(inputnames,2)
                    if ~isempty(strfind(constraints{c}, inputnames{i}))
                        constraints{c}=strrep(constraints{c},inputnames{i},['tv(:,',num2str(i),')']);
                    end
                end
            end
            s=strjoin(constraints(:),{' & '}); % ex: "tv(:,4)>=383.4343 & tv(:,1)<560.2788 & tv(:,2)>=-723.1114 & tv(:,1)<-951.7012"
            disp(s);
            try 
                x=tv(eval(s)==1,:); 
            catch ME
                if isempty(tv)
                    disp('tv empty!');
                end
                x=[];
            end
            branchTv=x(:,1:end-1);
            if ~isempty(x)
                if (size(branchTv,1)<=testSize) 
                    branchRep=repmat(branchTv,fix(testSize/size(branchTv,1)),1); % repeat the test case row
                    if (rem(testSize,size(branchTv,1))~=0)
                        new=cat(1,branchRep,branchTv(1:rem(testSize,size(branchTv,1)),:));
                    else
                        new=branchRep;
                    end
                else
                    new=branchTv(1:testSize,:); % get the tests. the number of tests = the oldt size 
                end
                
            end
            fOld{row}=new;  % evaluate and filtered tv into fOld            
        end            
    end
end
