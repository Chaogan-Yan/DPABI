
function W = y_kendallW(Data)
% Calculate Kendall's W (also known as Kendall's coefficient of concordance) for a 3D matrix. Based on https://en.wikipedia.org/wiki/Kendall%27s_W

% FORMAT W = y_kendallW(Data)
%   Data - the data (before ranking). object x judge x instance
% Output:
%   W - Kendall's W (also known as Kendall's coefficient of concordance)
%___________________________________________________________________________
% Written by YAN Chao-Gan 200221.
% International Big-Data Center for Depression Research, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com


r = tiedrank(Data);

n = size(r,1);
m = size(r,2);

Ri = sum(r,2);
Rbar = mean(Ri,1);

S = squeeze(sum((Ri - repmat(Rbar,n,1)).^2,1));

W = 12*S/m^2/(n^3-n);
