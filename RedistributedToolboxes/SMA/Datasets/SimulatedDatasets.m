AgeSource = round(40 + betarnd(3,2,[400,1]) * 40);
AgeTarget = round(40 + betarnd(2,3,[300,1]) * 40);
SexSource = binornd(1,0.2,400,1);
SexTarget = binornd(1,0.8,300,1);

mu1 = [100, 400, 500, 600];
Sigma1 = 0.8 * eye(4) + 0.2 * ones(4); 
mu2 = [30, 40, 50, 60];
Sigma2 = 0.6 * eye(4) + 0.4 * ones(4); 
Xsource = AgeSource * ones(1,4) + (SexSource * ones(1,4)) .* mvnrnd(mu1,Sigma1,400) ...
    + ((1 - SexSource) * ones(1,4)) .* mvnrnd(mu2,Sigma2,400); 
Xtarget = AgeTarget * ones(1,4) + (SexTarget * ones(1,4)) .* mvnrnd(mu1,Sigma1,300) ...
    + ((1 - SexTarget) * ones(1,4)) .* mvnrnd(mu2,Sigma2,300);

W0 = diag([4,2,3,5]);
b0 = [100,-40,-60,800];
Xtarget = Xtarget * W0 + ones(300,1)*b0;

subplot(2,2,1);
histogram(AgeSource);
title('Age distribution for the source');
subplot(2,2,2);
histogram(AgeTarget);
title('Age distribution for the target');
subplot(2,2,3);
histogram(Xsource(:,1));
title('The first covariate of X for the source');
subplot(2,2,4);
histogram(Xtarget(:,1));
title('The first covariate of X for the target');

DatasetSource = [AgeSource, SexSource, Xsource];
DatasetTarget = [AgeTarget, SexTarget, Xtarget];
%% X are the measurements of interest, such as protein levels. 
%% Their observations are distorted by a transformation h(X) = W0 * X +b0.
%% Besides this distribution shift, the final distribution difference is also affected by the differences in age and sex distributions.
%% Our goal here is to recover W0 and b0 so that we can remove the distribution shift for the source domain.
%% Here we only draw the plots for the first covariate among four covariates, which is distorted by h_1(x) = 4 * x + 100.

