function [icc] = LFCD_lmm0( metric_rep )
%LFCD_LMM0 computes the ICC for repeated measures on brain metrics based on
%   the so-called linear mixed model (LMM), actually here just an empty model
%   is employed.
% INPUTS:
%   metric_rep -- data matrix with each column represents repeated instances.
% OUTPUTS:
%   icc -- the intraclass correlation coefficent.
%
% Author:
%   Xi-Nian Zuo (zuoxn@psych.ac.cn) and Ting Xu.
% Dec., 27, 2011 at IPCAS.

[Nsub, Nscan] = size(metric_rep); 
N = Nsub * Nscan;
% Generate design matrices
X = ones(N,1);
Z = kron(eye(Nsub),ones(Nscan,1));
% Data
y = zeros(N,1);
for k=1:Nscan
    y(k:Nscan:end) = metric_rep(:,k);
end
% Estimate variance components using ReML
s20 = [0.001 0.1]; dim = Nsub;
[s2,b,u,Is2,C,H,q,loglik,loops] = mixed(y,X,Z,dim,s20,2);
% Compute ICC
icc = s2(1)/sum(s2);
end

