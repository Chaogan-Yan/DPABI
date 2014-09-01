function [ ICC, idx_fail] = do_ICC(Y, time, Cov_w, Cov_b, sID)
% [ ICC ] = do_ICC(Y, time, Cov_w, Cov_b, sID)
% Compute the ICC map of
% Base on toolbox of Jorge Luis Bernal Rusiel
% Input
% Y: Data matrix (nm x nv, nv # locations) whos colums can represent data
% vectors for each voxel/vertex.
% Time: Vector indicating measurement time.
% Cov_w: Covariance matrix(nm x kw, kw # within-subjects covariance variables)
% Cov_b: Covariance matrix(nm x bw, bw # between-subjects covariance variables)
% set intercept as random effects
% set fixed effects for these between-subjects covariances
% sID: Vector or cell array of subjects'ID (nm x 1). This is a vector
% indicating a subject ID for each row of Y, time, Cov_w, Cov_b.
% Output
% ICC: icc map (1 x nv, nv # locations)

% ni: Vector (mx1, m # of subjects in the study) whose entries are the
% number of repeated measures for each subject (ordered according to sX and
% sY).

% sort data according to subject's ID (sID) and according to time within each subject.
M = [time Cov_w Cov_b];
tcols = 1;
[M,Y,ni] = sortData(M,tcols,Y,sID);
% design matrix X, format [intercept, Cov_w, Cov_b]
nm = length(time);
X = [ones(nm,1) M(:,2:end)];
Nrandom = 1 + size(Cov_w,2); % total # random effects
Zcols = 1:Nrandom; % Column number in X for the random effects
%% Linear mixed-effects estimation for each location
nv = size(Y,2);
ICC = zeros(1,nv); idx_fail = zeros(1,nv);
%matlabpool(4)
parfor i=1:nv
    y = Y(:,i);
    [stats, st]= ccs_lme_fit_FS(X,1,y,ni,10^-8);
    count = 1;
    while st==0&&count<1
        count = count + 1;
        D = stats.Dhat;
        phisq = stats.phisqhat;
        [stats,st] = ccs_lme_fit_FS(X,1,y,ni,10^-8,D,phisq);
    end
    if st
        sigma_w = stats.phisqhat;
        sigma_b = stats.Dhat(1,1);
        ICC(i) = sigma_b/(sigma_w + sigma_b);
    else
        disp(['Not converge after ' num2str(count) ' lme_fit_FS iterations, assign ICC=0 in voxel ' num2str(i) ])
        ICC(i) = 0;
        idx_fail(i) = 1;
    end
end
%matlabpool close
