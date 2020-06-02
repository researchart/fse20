function [run, history] = IFBT_ART(inpRanges,opt,Oldt,controlPointNames,categorical,count)
% IFBT_ART(ART based Important Features Boundary Test) - generates test cases by focusing mainly on the important features that have the highest impact on the fitness
%           values given the previously generated test cases and the previously generated assumptions
% USAGE:
%   [run, history] = IFBT_ART(inpRanges,opt,Oldt,controlPointNames,categorical,count)
%
% INPUTS:
%
%   inpRanges: n-by-2 lower and upper bounds on initial conditions and
%       input ranges, e.g.,
%           inpRanges(i,1) <= x(i) <= inpRanges(i,2)
%       where n = dimension of the initial conditions vector +
%           the dimension of the input signal vector * # of control points
%
%   opt : staliro options object
%
%   Oldt: previously generated test cases
%
%   controlPointNames: the control points labels
%
%   categorical: an array of the categorical inputs indexes
%               it serves as the parameter predictors names during the decision tree building 
%   count: iteration counter
%
% OUTPUTS:
%   run: a structure array that contains the results of each run of
%       the stochastic optimization algorithm. The structure has the
%       following fields:
%
%           bestRob : The best (min or max) robustness value found
%
%           bestSample : The sample in the search space that generated
%               the trace with the best robustness value.
%
%           nTests: number of tests performed (this is needed if
%               falsification rather than optimization is performed)
%
%           bestCost: Best cost value. bestCost and bestRob are the
%               same for falsification problems. bestCost and bestRob
%               are different for parameter estimation problems. The
%               best robustness found is always stored in bestRob.
%
%           paramVal: Best parameter value. This is used only in
%               parameter query problems. This is valid if only if
%               bestRob is negative.
%
%           falsified: Indicates whether a falsification occurred. This
%               is used if a stochastic optimization algorithm does not
%               return the minimum robustness value found.
%
%           time: The total running time of each run. This value is set by
%               the calling function.
%
%   history: array of structures containing the following fields
%
%       rob: all the robustness values computed for each test
%
%       samples: all the samples generated for each test
%
%       cost: all the cost function values computed for each test.
%           This is the same with robustness values only in the case
%           of falsification.
%
% See also: staliro, staliro_options, UR_Taliro_parameters

% (C) 2010, Sriram Sankaranarayanan, University of Colorado
% (C) 2010, Georgios Fainekos, Arizona State University
% (C) 2019, Shakiba Yaghoubi, Arizona State University 
%modified by:
% Copyright by University of Luxembourg 2019-2020. 
% Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg. 
% Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg. 
% Developed by Shiva Nejati, shiva.nejati@uni.lu University of Luxembourg. 
% Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg. 
ranges={};
assumeRanges={};
tc=0;
num = opt.adaptive;
tmc = tic;
max_T = opt.optim_params.max_time;

X=Oldt(:,1:end-1);     % X contains the input predictors
if ~isempty(categorical)
    X(:,categorical)=double(X>=0.5);
end
Y=Oldt(:,end);       % Y contains the fitness values
    
[feature,informativeA] = computeAssumption(X, Y, controlPointNames,categorical,count,opt);
for assume=1 : size(informativeA,1)
    assumtionsRanges{assume}=getRange(informativeA{assume,1},controlPointNames,inpRanges);
end
perc=1+2*count;
for assumeR=1:size(assumtionsRanges,2)
    assumeRanges=assumtionsRanges{assumeR};
    for in=1:size(assumeRanges,1)
        ranges{assumeR}{in}=[];
        for inputBound=1:size(assumeRanges,2)
            if assumeRanges(in,inputBound)~=inpRanges(in,inputBound)
                lowB=max(assumeRanges(in,inputBound)-assumeRanges(in,inputBound)/perc,inpRanges(in,1));
                upB=min(assumeRanges(in,inputBound)+assumeRanges(in,inputBound)/perc,inpRanges(in,2));
                ranges{assumeR}{in}=cat(1,ranges{assumeR}{in},[lowB upB]);
            end
        end
        if isempty(ranges{assumeR}{in})
            ranges{assumeR}{in}=inpRanges(in,:);
        end
    end
end
            


cellOfFOldTC=getTests(Oldt,informativeA,controlPointNames,opt.testSuiteSize);
nSamples=opt.testSuiteSize;

[nInputs, ~] = size(inpRanges); 
% Initialize outputs
run = struct('bestRob',[],'bestSample',[],'nTests',[],'bestCost',[],'paramVal',[],'falsified',[],'time',[]);
history = struct('rob',[],'samples',[],'cost',[]);

%initialize curSample vector
curSample = repmat({0}, 1, opt.n_workers);

% get polarity and set the fcn_cmp
if isequal(opt.parameterEstimation,1)
    if isequal(opt.optimization,'min')
        fcn_cmp = @le;
        minmax = @min;
    elseif isequal(opt.optimization,'max')
        fcn_cmp = @ge;
        minmax = @max;
    end
else
    fcn_cmp = @le;
    minmax = @min;
end

if rem(nSamples/opt.n_workers,1) ~= 0
    error('The number of tests (opt.ur_params.n_tests) should be divisible by the number of workers.')
end

% Initialize optimization
for jj = 1:opt.n_workers
rng('shuffle');
    curSample{jj} = (inpRanges(:,1)-inpRanges(:,2)).*rand(nInputs,1)+inpRanges(:,2);
end

curVal = Compute_Robustness(curSample);

if nargout>1
    if isa(curVal{1},'hydis')
        history.cost = hydis(zeros(nSamples,1));
        history.rob = hydis(zeros(nSamples,1));
        history.cost(1:opt.n_workers) = hydisc2m(curVal)';
        history.rob(1:opt.n_workers) = hydisc2m(curVal)';
    else
        history.cost = zeros(nSamples,1);
        history.rob = zeros(nSamples,1);
        history.cost(1:opt.n_workers) = cell2mat(curVal)';
        history.rob(1:opt.n_workers) = cell2mat(curVal)';
    end
    history.samples = zeros(nSamples,nInputs);
    history.samples(1:opt.n_workers,:) = cell2mat(curSample)';
    
end

if isa(curVal{1},'hydis')
    [minmax_val, minmax_idx] = minmax(hydisc2m(curVal));
else
    [minmax_val, minmax_idx] = minmax(cell2mat(curVal));
end
bestCost = minmax_val;

run.bestCost = minmax_val;
run.bestSample = curSample{minmax_idx};
run.bestRob = minmax_val;
run.falsified = minmax_val<=0;
run.nTests = 1;
no_success = 0;

for oneAssum=1: size(ranges,2)
    fOldTCs=cellOfFOldTC{1,oneAssum};
    if size(feature,2)>1  
        for f=1:size(feature,2)
            nbrOfRangesPerInput(f)=size(ranges{oneAssum}{feature(f)},1);
        end
        [max_nbrOfRangesPerInput,index_max]=max(nbrOfRangesPerInput);
        
        for f=1:size(feature,2)
            nbrOfRangesF=size(ranges{oneAssum}{feature(f)},1);
            if nbrOfRangesF < max_nbrOfRangesPerInput
                ct=1;
                for x =nbrOfRangesF+1:max_nbrOfRangesPerInput
                    ranges{oneAssum}{feature(f)}=cat(1,ranges{oneAssum}{feature(f)},ranges{oneAssum}{feature(f)}(ct,:));
                    ct=ct+1;
                end
            end
        end
                    
    else
        index_max=feature;
    end

    tcsize=round(size(fOldTCs,1)/(size(ranges{oneAssum}{index_max},1)))-1;
    for oneinputrange=1:size(ranges{oneAssum}{index_max},1) 
        start=(oneinputrange-1)*tcsize;
        endd=oneinputrange*tcsize;
        for rangetc = start+1 : endd+1
            tc=tc+1;
            fOldTC=fOldTCs(rangetc,:); % one test case in FOld
            candidates= zeros(num,nInputs);
            for c= 1 : num
                rng('shuffle');
                for f=1:size(feature,2)
                    fOldTC(feature(f))=(ranges{oneAssum}{feature(f)}(oneinputrange,2)-ranges{oneAssum}{feature(f)}(oneinputrange,1)).*rand(size(feature(f),1),1)+ranges{oneAssum}{feature(f)}(oneinputrange,1);
                end
                curSample{jj} =fOldTC;
                curSamples{c,:}=curSample{jj};
                candidates(c,:)= cell2mat(curSample)';
            end

        % concat the new history with the old data
            if isempty(Oldt)
                points=history.samples;
            else
                points=cat(1,Oldt(:,1:end-1),history.samples);
            end
            points( ~any(points,2), : ) = [];
            c=pdist2(candidates,points);
            mindist=min(c,[],2);
            maxdist = max(mindist);
            maxcandindex= find(mindist==maxdist);
            curSample{1}=curSamples{maxcandindex,:};

            % simulate cursample and compute rob
            disp('Iteration number :');
            disp(strcat(num2str(run.nTests+1),'/',num2str(nSamples)));
            curVal = Compute_Robustness(curSample);

            if isa(curVal{1},'hydis')
                [minmax_val, minmax_idx] = minmax(hydisc2m(curVal));
            else
                [minmax_val, minmax_idx] = minmax(cell2mat(curVal));
            end
            if nargout>1
                if isa(curVal{1},'hydis')
                    history.cost((tc-1)*opt.n_workers+1 : tc*opt.n_workers) = hydisc2m(curVal)';
                    history.rob((tc-1)*opt.n_workers+1 : tc*opt.n_workers) = hydisc2m(curVal)';
                else
                    history.cost((tc-1)*opt.n_workers+1 : tc*opt.n_workers) = cell2mat(curVal)';
                    history.rob((tc-1)*opt.n_workers+1 : tc*opt.n_workers) = cell2mat(curVal)';
                end
                history.samples((tc-1)*opt.n_workers+1 : tc*opt.n_workers , :) = cell2mat(curSample)';
            end
            run.nTests = run.nTests+1;

            if (fcn_cmp(minmax_val,bestCost))
                bestCost = minmax_val;
                run.bestCost = minmax_val;
                run.bestRob = minmax_val;
                run.bestSample = curSample{minmax_idx};
                if opt.dispinfo>0
                    if isa(minmax_val,'hydis')
                        disp(['Best ==> <',num2str(get(minmax_val,1)),',',num2str(get(minmax_val,2)),'>']);
                    else
                        disp(['Best ==> ' num2str(minmax_val)]);
                    end
                end
                no_success = 0;
            else
                no_success = no_success+1;
            end
            if opt.dispinfo>0
                if (mod(tc,floor(100/opt.n_workers)) == 0)
                    disp([' IFBT_ART_Taliro: Number of tests so far ',num2str(tc*opt.n_workers)])
                end
            end

            run.falsified = fcn_cmp(minmax_val,0) | run.falsified;
            if toc(tmc)>max_T
                break
            end
        end
    end
end
run.nTests = nSamples;

end
