% test function CircosDataOrganize.m
clc;clear;

workingDir = pwd;
load('CircosStruct.mat');
% load('RawDataCircos.mat');
% CircosStruct = RawDataCircos;

RawDataCircos = CircosStruct;
% LINK_MODE = 4;

WorkDir = pwd;

%%
[CircosNetworkPath, CircosRegionPath, CircosLabelPath, CircosLinkPath]=CircosDataOrganize(WorkDir,CircosStruct);

% fprintf('Network Information Created: %\n', CircosNetworkPath);
% fprintf('Region Information Created: %\n', CircosRegionPath);
% fprintf('Label Information Created: %\n', CircosLabelPath);
% fprintf('Link Information Created: %\n', CircosLinkPath);

flag = '';
if ~isempty(CircosStruct.ElementLabel)
    flag = [flag,'L'];
end
if ~isempty(CircosStruct.HigherOrderNetworkLabel)
    flag = [flag,'N'];
end

offsetPixel = 260;
% offsetPixel = 0;
CircosConfPath=EditConf(WorkDir, flag, offsetPixel);
% fprintf('Circos Config Created: %\n', CircosConfPath);
system('circos -conf CircosPlot.conf');
