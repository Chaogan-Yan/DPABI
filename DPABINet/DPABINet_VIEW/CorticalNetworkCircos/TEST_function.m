% test function CircosDataOrganize.m
clc;clear;

% load raw data
load('RawDataCircos.mat');
% define variables
workingDir = pwd;
LINK_MODE = 4;
% check existence of labels
if (isfield(RawDataCircos,'HigherOrderNetworkLabel') || isempty(RawDataCircos.HigherOrderNetworkLabel)) && (isfield(RawDataCircos,'ElementLabel') || isempty(RawDataCircos.ElementLabel))
    flag = '';
else
    flag = 'LT';
end

% test function
[filePathBand,filePathLabel,filePathLink] = CircosDataOrganize(workingDir,RawDataCircos,LINK_MODE);
filePathConf = EditConf(workingDir,flag);


% run Circos command, if need run Matlab in Terminal
system(['circos -conf ',workingDir,filesep,'CircosPlot.conf']);

%%
workingDir = pwd;
load('CircosStruct.mat');
load('RawDataCircos.mat');
% CircosStruct = RawDataCircos;

RawDataCircos = CircosStruct;
LINK_MODE = 4;

WorkDir = pwd;

%%
[CircosBandPath, CircosLabelPath, CircosLinkPath]=CircosDataOrganize(WorkDir,CircosStruct,4);

% fprintf('Band Information Created: %\n', CircosBandPath);
% fprintf('Label Information Created: %\n', CircosLabelPath);
% fprintf('Link Information Created: %\n', CircosLinkPath);

flag = '';
% flag = [flag,'P'];
if ~isempty(CircosStruct.HigherOrderNetworkLabel) &&...
        ~isempty(CircosStruct. ElementLabel)
else
    flag = [flag,'LT'];
end

offsetPixel = 200;
CircosConfPath=EditConf(WorkDir, flag, offsetPixel);
% fprintf('Circos Config Created: %\n', CircosConfPath);
system('circos -conf CircosPlot.conf');
