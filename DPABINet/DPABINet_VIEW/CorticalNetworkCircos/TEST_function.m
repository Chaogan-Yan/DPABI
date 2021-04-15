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
% flag = [flag,'P'];
if ~isempty(CircosStruct.HigherOrderNetworkLabel) &&...
        ~isempty(CircosStruct. ElementLabel)
else
    flag = [flag,'T'];
end

offsetPixel = 260;
% offsetPixel = 0;
CircosConfPath=EditConf(WorkDir, flag, offsetPixel);
% fprintf('Circos Config Created: %\n', CircosConfPath);
system('circos -conf CircosPlot.conf');
