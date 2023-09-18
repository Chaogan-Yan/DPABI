%% This is an example using SSMMDIJ.m.
%% The only difference from RunSubsamplingMMD.m is replacing subsamplingMMD.m by SSMMDIJ.m and a step to calculate IJ variance.
%% Based on SimulatedDatasets.m, our goal is to learn a transformation h(X) = diag([4,2,3,5]) * X + [100,-40,-60,800].

%% First, we attach all required subfolders and run SimulatedDatasets.m to generate datasets.
addpath(genpath(pwd));
SimulatedDatasets

%% Currently, SSMMDIJ.m only supports matched subgroup indexes for the source and target.
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

%% This step generates subgroup index required for SSMMDIJ.m 
AgeSource = floor(double(AgeSource - 40)./double(10));
AgeTarget = floor(double(AgeTarget - 40)./double(10));
IndexSource = AgeSource.*2 + double(SexSource) + 1;
IndexTarget = AgeTarget.*2 + double(SexTarget) + 1;

%% SSMMDIJ.m supports one to one map. The code can be revised for other maps.
%% Here we repeat SSMMDIJ four times for each covariate.
tic;
MatrixTran = zeros(4,3);
IJMat = zeros(4,2);
for k = 1:4
    Source = Xsource(:,k);
    Target = Xtarget(:,k);
    [slope,intercept,pvalue,IJ,slopevar,intervar] = SSMMDIJ(Source,Target,IndexSource,IndexTarget,100);
    MatrixTran(k,:) = [slope,intercept,pvalue];
    IJMat(k,:) = [slopevar,intervar];
%     %% Calculate slopevar and intervar given IJ.
%     %% If the iteration time for SSMMDIJ is too expensive to compute. This commented code is easy to revised for parallel computing.
%     slopevar = 0;
%     intervar = 0;
%     tmp = tabulate(IndexSource);
%     d = length(tmp(:,2)');
%     for dlp = 1:2
%         for glp = 1:d
%             slopevar = slopevar + sum((IJ.slope{dlp,glp}-MatrixTran(k,1).*IJ.constant{dlp,glp}).^2);
%             intervar = intervar + sum((IJ.intercept{dlp,glp}-MatrixTran(k,2).*IJ.constant{dlp,glp}).^2);
%         end
%     end
%     IJMat(k,:)=[slopevar,intervar];
end
algtime = toc;

Names = {'X1','X2','X3','X4'};
TableTran = array2table([MatrixTran,sqrt(IJMat)],'RowNames',Names,'VariableNames',{'Slope','Inter','pvalue1st','Slopestd','Interstd'});
save('SimulationResult','TableTran','algtime');

TableTran