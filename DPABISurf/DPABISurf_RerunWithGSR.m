function [Error, Cfg]=DPABISurf_RerunWithGSR(Cfg)
% FORMAT [Error]=DPABISurf_RerunWithGSR(Cfg)
% The data has been processed without global signal regression for the first pass. Now re-run it with global signal regression.
% Input:
%   Cfg - the parameters for auto data processing
% Output:
%   The processed data that you want.
%___________________________________________________________________________
% Written by YAN Chao-Gan 190122.
% Institute of Psychology, Chinese Academy of Sciences, 16 Lincui Road, Chaoyang District, Beijing 100101, China
% ycg.yan@gmail.com

if ischar(Cfg)  %If inputed a .mat file name. (Cfg inside)
    load(Cfg);
end


StartingDirName = Cfg.StartingDirName;

if strcmpi(StartingDirName,'FunRaw')
    StartingDirName = 'FunSurf';
end

if (Cfg.TimePoints~=0)&&(Cfg.RemoveFirstTimePoints~=0) %YAN Chao-Gan, 161219. Cfg.TimePoints~=0 %Adjust the number of time points. 151214. Thanks for the report of Hua-Sheng Liu
    Cfg.TimePoints = Cfg.TimePoints - Cfg.RemoveFirstTimePoints;
end
Cfg.RemoveFirstTimePoints=0; %YAN Chao-Gan, 161219. Reset to 0 after adjusting the number of time points.

Cfg.IsNeedConvertFunDCM2IMG=0;
Cfg.IsNeedConvertT1DCM2IMG=0; 

if isfield(Cfg,'FieldMap')
    Cfg.FieldMap.IsNeedConvertDCM2IMG=0;
end

if Cfg.IsConvert2BIDS
    StartingDirName = 'BIDS';
    Cfg.IsConvert2BIDS=0;
end

if Cfg.Isfmriprep
    StartingDirName = 'fmriprep';
    Cfg.Isfmriprep=0;
end

if Cfg.IsOrganizefmriprepResults
    if Cfg.IsBasedOnFunSurf
        StartingDirName = 'FunSurf';
    else
        StartingDirName = 'FunSurfW';
    end
    Cfg.IsOrganizefmriprepResults=0;
end

if (Cfg.NonAgressiveRegressICAAROMANoise==1)
    StartingDirName = [StartingDirName,'I'];
    Cfg.NonAgressiveRegressICAAROMANoise=0;
end

StartingDirName_Volume = ['FunVolu',StartingDirName(8:end)];

% Multiple Sessions Processing 
FunSessionPrefixSet={''}; %The first session doesn't need a prefix. From the second session, need a prefix such as 'S2_';
for iFunSession=2:Cfg.FunctionalSessionNumber
    FunSessionPrefixSet=[FunSessionPrefixSet;{['S',num2str(iFunSession),'_']}];
end
for iFunSession=1:Cfg.FunctionalSessionNumber
    if ispc
        %YAN Chao-Gan, 161122. Change mklink to copyfile.
        copyfile([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},StartingDirName],[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},StartingDirName,'global']);
        copyfile([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},StartingDirName_Volume],[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},StartingDirName_Volume,'global']);
        %eval(['!mklink /d ',Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},StartingDirName,'global ',Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},StartingDirName])
    else
        eval(['!ln -s ',Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},StartingDirName,' ',Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},StartingDirName,'global'])
        eval(['!ln -s ',Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},StartingDirName_Volume,' ',Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},StartingDirName_Volume,'global'])
    end
end

Cfg.Covremove.WholeBrain.IsRemove = 1;
Cfg.StartingDirName = [StartingDirName,'global'];
Cfg.StartingDirName_Volume = [StartingDirName_Volume,'global'];


[Error]=DPABISurf_run(Cfg);


