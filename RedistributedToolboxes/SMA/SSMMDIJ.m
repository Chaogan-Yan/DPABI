function[slope,intercept,pvalue,IJ,slopevar,intervar] = SSMMDIJ(datasource,datatarget,indexsource,indextarget,itertime)
%% The only difference from subsamplingMMD.m is IJ in output that records information needed for calculating IJ variance.
slope = 0;
intercept = 0;

%% This step determines the subsample size.
tmp = tabulate(indexsource);
basesource = tmp(:,2)';
tmp = tabulate(indextarget);
basetarget = tmp(:,2)';
subsamplesize = ceil(min(basesource,basetarget).^0.7);
subsamplesize = max(subsamplesize-2,0);
subsamplesize = subsamplesize + 2*(subsamplesize>0);

S = sum(subsamplesize);
subsource = zeros(S,size(datasource,2));
subtarget = zeros(S,size(datatarget,2));
cumsubsize = [0,cumsum(subsamplesize)];

%% IJ Initialization
groupnum = length(basesource);
IJstruct = cell(2,groupnum);
for domainloop = 1:2
    for grouploop = 1:groupnum
        if domainloop == 1
            itemnum = basesource(grouploop);
        else
            itemnum = basetarget(grouploop);
        end
        IJstruct{domainloop,grouploop} = zeros(1,itemnum);
    end
end
IJ.slope = IJstruct;
IJ.intercept = IJstruct;
IJ.constant = IJstruct;
%% Initialization is completed

for iter = 1:itertime
    %% Generate subsamples for one iteration.
    IJcount = IJstruct;
    for k = 1:length(subsamplesize)
        startpt = cumsubsize(k)+1;
        endpt = cumsubsize(k+1);
        if(endpt > startpt)
            [subsource(startpt:endpt,:),chosenS] = datasample(datasource(indexsource==k,:),subsamplesize(k),'Replace',true);%false
            [subtarget(startpt:endpt,:),chosenT] = datasample(datatarget(indextarget==k,:),subsamplesize(k),'Replace',true);%false
            %% Update IJ count
            updateinfo = tabulate(chosenS);
            IJcount{1,k}(updateinfo(:,1)') = updateinfo(:,2)';
            IJcount{1,k} = IJcount{1,k}-subsamplesize(k)/basesource(k);
            updateinfo = tabulate(chosenT);
            IJcount{2,k}(updateinfo(:,1)') = updateinfo(:,2)';
            IJcount{2,k} = IJcount{2,k}-subsamplesize(k)/basetarget(k);
            %% Updating is completed
        end
    end
    %% Run fitMMD to get the transformation for each iteration and pvalue for the first iteration.
    if iter == 1
        [subslope,subintercept,pvalue] = fitMMD(subsource,subtarget,1);
    else
        [subslope,subintercept,~] = fitMMD(subsource,subtarget,0); 
    end
    slope = slope + subslope;
    intercept = intercept + subintercept;
    %% Update IJ
    for k = 1:length(subsamplesize)
        IJ.constant{1,k} = IJ.constant{1,k}+IJcount{1,k};
        IJ.constant{2,k} = IJ.constant{2,k}+IJcount{2,k};
        IJ.slope{1,k} = IJ.slope{1,k}+subslope.*IJcount{1,k};
        IJ.slope{2,k} = IJ.slope{2,k}+subslope.*IJcount{2,k};
        IJ.intercept{1,k} = IJ.intercept{1,k}+subintercept.*IJcount{1,k};
        IJ.intercept{2,k} = IJ.intercept{2,k}+subintercept.*IJcount{2,k};
    end
    %% Updating is completed
end

slope = slope/itertime;
intercept = intercept/itertime;

for k = 1:length(subsamplesize)
    IJ.constant{1,k} = IJ.constant{1,k}./itertime;
    IJ.constant{2,k} = IJ.constant{2,k}./itertime;
    IJ.slope{1,k} = IJ.slope{1,k}./itertime;
    IJ.slope{2,k} = IJ.slope{2,k}./itertime;
    IJ.intercept{1,k} = IJ.intercept{1,k}./itertime;
    IJ.intercept{2,k} = IJ.intercept{2,k}./itertime;
end

%% This step calculates slopevar and intervar given IJ, which can be moved out of this function for parallel computing.
slopevar = 0;
intervar = 0;
for dlp = 1:2
    for glp = 1:length(subsamplesize)
        slopevar = slopevar + sum((IJ.slope{dlp,glp}-slope.*IJ.constant{dlp,glp}).^2);
        intervar = intervar + sum((IJ.intercept{dlp,glp}-intercept.*IJ.constant{dlp,glp}).^2);
    end
end
