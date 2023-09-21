function[slope,intercept] = subsamplingMMD(datasource,datatarget,indexsource,indextarget,itertime)
%% Inputs: datasource and datatarget are related to the one dimension measurement of interest; indexsource and indextarget give the subgroup index, which need to have same range; itertime provides iteration times 'B' for the subsampling.
%% Outputs: slope and intercept give the transformation. pvalue is for the subsamples from the first iteration.
slope = 0;
intercept = 0;

%% This step determines the subsample size.
tmp = tabulate(indextarget);
basetarget = tmp(:,2)';

tmp = tabulate(indexsource);
basesource = tmp(:,2)';
if length(basesource)<length(basetarget)
	basesource = zeros(size(basetarget));
	basesource(1,1:size(tmp,1)) = tmp(:,2)';
elseif length(basesource)<length(basetarget)
	error('Target has less subgroups than this source, please check your setting.');
end
		
subsamplesize = ceil(min(basesource,basetarget).^0.7);
subsamplesize = max(subsamplesize-2,0); 
subsamplesize = subsamplesize + 2*(subsamplesize>0);

%% Initializing step.
S = sum(subsamplesize);
subsource = zeros(S,size(datasource,2));
subtarget = zeros(S,size(datatarget,2));
cumsubsize = [0,cumsum(subsamplesize)];
    
for iter = 1:itertime
    %% Generate subsamples for one iteration.
    for k = 1:length(subsamplesize)
        startpt = cumsubsize(k)+1;
        endpt = cumsubsize(k+1);
        if(endpt > startpt)
            subsource(startpt:endpt,:) = datasample(datasource(indexsource==k,:),subsamplesize(k),'Replace',true);%false
            subtarget(startpt:endpt,:) = datasample(datatarget(indextarget==k,:),subsamplesize(k),'Replace',true);%false
        end
    end
    %% Run fitMMD to get the transformation for each iteration and pvalue for the first iteration.
    [subslope,subintercept] = fitMMD(subsource,subtarget,0);

    slope = slope + subslope;
    intercept = intercept + subintercept;
end

%% Return the average of transformations.
slope = slope/itertime;
intercept = intercept/itertime;
