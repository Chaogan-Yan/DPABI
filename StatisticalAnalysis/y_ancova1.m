function [F P]=y_ancova1(DependentVariable,GroupLabel,Covariates)
% [F P]=y_ancova1(DependentVariable,GroupLabel,Covariates)
% Perform one-way ANOVA or ANCOVA analysis
% Input:
%   DependentVariable - the dependent variable. n by 1 vector
%   GroupLabel - the label indicate which group is. eg. [1 1 1 2 2 2 2 3 3 3 3], n by 1 vector
%   Covariates - The covariates. Perform ANOVA analysis if this parameter is empty.
% Output:
%   F - the F value
%   P - the P value
%___________________________________________________________________________
% Written by YAN Chao-Gan 100317.
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
% ycg.yan@gmail.com

if nargin==2
    Covariates=[];
end

% Construct dummy variable
N=size(DependentVariable,1);
GroupLabelUnique=unique(GroupLabel);
Df_Group=length(GroupLabelUnique)-1;
GroupDummyVariable=zeros(N,Df_Group);
for i=1:Df_Group
    GroupDummyVariable(:,i)=GroupLabel==GroupLabelUnique(i);
end
Df_E=N-Df_Group-1-size(Covariates,2);


% Calculate SSE_H: sum of squared errors when H0 is true
[b,r,SSE_H,SSR] = y_regress_ss(DependentVariable,[ones(N,1),Covariates]);
% Calulate SSE
[b,r,SSE,SSR] = y_regress_ss(DependentVariable,[ones(N,1),GroupDummyVariable,Covariates]);
% Calculate F
F=((SSE_H-SSE)/Df_Group)/(SSE/Df_E);
if nargout >= 2
    P =1-fcdf(F,Df_Group,Df_E);
end

