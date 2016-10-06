function [TTest2Cov_T,TTest2Cov_P]=y_TTest2Cov(Variable1,Variable2,CovariateVariable1,CovariateVariable2)
% [TTest2Cov_T,TTest2Cov_P]=y_TTest2Cov(DependentVariable,CovariateVariable)
% Perform two sample t test with or without covariates.
% Input:
%   Variable1 - The Variable 1. Test if Variable 1 is greater than Variable 2. n by 1
%   Variable2 - The Variable 2. n by 1
%   CovariateVariable - The covariates. n by number of covariates
% Output:
%   TTest2Cov_T - the T value (corresponding to the first Variable minus the second Variable)
%   TTest2Cov_P - the P value
%___________________________________________________________________________
% Written by YAN Chao-Gan 160603.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com

if nargin<=2
    CovariateVariable1=[];
    CovariateVariable2=[];
end
DependentVariable=[Variable1(:);Variable2(:)];
CovariateVariable=[CovariateVariable1;CovariateVariable2];

GroupLabel=[ones(length(Variable1),1);-1*ones(length(Variable2),1)];

Df_E=size(DependentVariable,1)-2-size(CovariateVariable,2);

% Calculate SSE_H: sum of squared errors when H0 is true
[b,r,SSE_H] = y_regress_ss(DependentVariable,[ones(length(DependentVariable),1),CovariateVariable]);
% Calulate SSE
[b,r,SSE] = y_regress_ss(DependentVariable,[ones(length(DependentVariable),1),GroupLabel,CovariateVariable]);
% Calculate F
F=((SSE_H-SSE)/1)/(SSE/Df_E);
P=1-fcdf(F,1,Df_E);
T=sqrt(F)*sign(b(2));
TTest2Cov_T=T;
TTest2Cov_P=P;
