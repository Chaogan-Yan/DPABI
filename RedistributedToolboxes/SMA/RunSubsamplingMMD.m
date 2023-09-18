%% This is an example using subsamplingMMD.m.
%% Based on SimulatedDatasets.m, our goal is to learn a transformation h(X) = diag([4,2,3,5]) * X + [100,-40,-60,800].

%% First, we attach all required subfolders and run SimulatedDatasets.m to generate datasets.
addpath(genpath(pwd));
SimulatedDatasets

%% Currently, subsamplingMMD.m only supports matched subgroup indexes for the source and target.
%% This step works, for example, to force the age range both to be [50,70] if the source age range is [40,70] and the target age range is [50,80].
AgeSource = DatasetSource(:,1);
AgeTarget = DatasetTarget(:,1);
AgeLow = max(min(AgeSource), min(AgeTarget));
AgeHigh = min(max(AgeSource), max(AgeTarget));
DatasetSource = DatasetSource(AgeSource >= AgeLow & AgeSource <= AgeHigh,:);
DatasetTarget = DatasetTarget(AgeTarget >= AgeLow & AgeTarget <= AgeHigh,:);

%% This step reads data into age, sex and four dimension X.
AgeSource = DatasetSource(:,1);
AgeTarget = DatasetTarget(:,1);
Xsource = DatasetSource(:,3:6);
SexSource = DatasetSource(:,2);
Xtarget = DatasetTarget(:,3:6);
SexTarget = DatasetTarget(:,2);

%% This step generates subgroup index required for subsamplingMMD.m 
AgeSource = floor(double(AgeSource - 40)./double(10));
AgeTarget = floor(double(AgeTarget - 40)./double(10));
IndexSource = AgeSource.*2 + double(SexSource) + 1;
IndexTarget = AgeTarget.*2 + double(SexTarget) + 1;

%% subsamplingMMD.m supports one to one map. The code can be revised for other maps.
%% Here we repeat subsamplingMMD four times for each covariate.
tic;
MatrixTran = zeros(4,3);
for k = 1:4
    Source = Xsource(:,k);
    Target = Xtarget(:,k);
    [slope,intercept] = subsamplingMMD(Source,Target,IndexSource,IndexTarget,100);
    MatrixTran(k,:) = [slope,intercept];
    %Here, pvalue is for subsamples from first iteration
end                       
algtime = toc;

Names = {'X1','X2','X3','X4'};
TableTran = array2table(MatrixTran,'RowNames',Names,'VariableNames',{'Slope','Inter'});
save('SimulationResult','TableTran','algtime');

TableTran