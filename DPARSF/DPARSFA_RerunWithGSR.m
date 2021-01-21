function [Error]=DPARSFA_RerunWithGSR(Cfg)
% FORMAT Error]=DPARSFA_RerunWithGSR(Cfg)
% The data has been processed without global signal regression for the first pass. Now re-run it with global signal regression.
% Input:
%   Cfg - the parameters for auto data processing
% Output:
%   The processed data that you want.
%___________________________________________________________________________
% Written by YAN Chao-Gan 151123.
% Institute of Psychology, Chinese Academy of Sciences, 16 Lincui Road, Chaoyang District, Beijing 100101, China
% ycg.yan@gmail.com

if ischar(Cfg)  %If inputed a .mat file name. (Cfg inside)
    load(Cfg);
end


StartingDirName = Cfg.StartingDirName;

if strcmpi(StartingDirName,'FunRaw')
    StartingDirName = 'FunImg';
end

Cfg.IsNeedConvertFunDCM2IMG=0;

if isfield(Cfg,'FieldMap')
    Cfg.FieldMap.IsNeedConvertDCM2IMG=0;
end

Cfg.IsApplyDownloadedReorientMats=0;
%Cfg.RemoveFirstTimePoints=0;
if (Cfg.TimePoints~=0)&&(Cfg.RemoveFirstTimePoints~=0) %YAN Chao-Gan, 161219. Cfg.TimePoints~=0 %Adjust the number of time points. 151214. Thanks for the report of Hua-Sheng Liu
    Cfg.TimePoints = Cfg.TimePoints - Cfg.RemoveFirstTimePoints;
end
Cfg.RemoveFirstTimePoints=0; %YAN Chao-Gan, 161219. Reset to 0 after adjusting the number of time points.
if Cfg.IsSliceTiming
    StartingDirName = [StartingDirName,'A'];
    Cfg.IsSliceTiming=0;
end
if Cfg.IsRealign
    StartingDirName = [StartingDirName,'R'];
    Cfg.IsRealign=0;
end
Cfg.IsCalVoxelSpecificHeadMotion=0; 
Cfg.IsNeedReorientFunImgInteractively=0; 
Cfg.IsNeedConvertT1DCM2IMG=0; 
Cfg.IsNeedReorientCropT1Img=0; 
Cfg.IsNeedReorientT1ImgInteractively=0; 
Cfg.IsBet=0; 
Cfg.IsAutoMask=0; 
Cfg.IsNeedT1CoregisterToFun=0; 
Cfg.IsNeedReorientInteractivelyAfterCoreg=0; 
Cfg.IsSegment=0; 
Cfg.IsDARTEL=0; 


if (Cfg.IsCovremove==1) && (strcmpi(Cfg.Covremove.Timing,'AfterNormalize'))
    if (Cfg.IsFilter==1) && (strcmpi(Cfg.Filter.Timing,'BeforeNormalize'))
        StartingDirName = [StartingDirName,'F'];
        Cfg.IsFilter=0;
    end
    if (Cfg.IsNormalize>0) && strcmpi(Cfg.Normalize.Timing,'OnFunctionalData')
        StartingDirName = [StartingDirName,'W'];
        Cfg.IsNormalize=0;
    end
    if (Cfg.IsSmooth>=1) && strcmpi(Cfg.Smooth.Timing,'OnFunctionalData')
        StartingDirName = [StartingDirName,'S'];
        Cfg.IsSmooth=0;
    end
    if (Cfg.IsDetrend==1)
        StartingDirName = [StartingDirName,'D'];
        Cfg.IsDetrend=0;
    end
end


%Make Symbolic Links
if ~isfield(Cfg,'DataProcessDir')
    Cfg.DataProcessDir=Cfg.WorkingDir;
end
% Multiple Sessions Processing 
FunSessionPrefixSet={''}; %The first session doesn't need a prefix. From the second session, need a prefix such as 'S2_';
for iFunSession=2:Cfg.FunctionalSessionNumber
    FunSessionPrefixSet=[FunSessionPrefixSet;{['S',num2str(iFunSession),'_']}];
end
for iFunSession=1:Cfg.FunctionalSessionNumber
    if ispc
        %YAN Chao-Gan, 161122. Change mklink to copyfile.
        copyfile([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},StartingDirName],[Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},StartingDirName,'global']);
        %eval(['!mklink /d ',Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},StartingDirName,'global ',Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},StartingDirName])
    else
        eval(['!ln -s ',Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},StartingDirName,' ',Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},StartingDirName,'global'])
    end
end

Cfg.Covremove.WholeBrain.IsRemove = 1;
Cfg.StartingDirName = [StartingDirName,'global'];
global st; st=[]; %YAN Chao-Gan, 161201. In some cases generating pictures calling y_spm_orthviews may leave something need to be cleared.
clear st;  %YAN Chao-Gan, 171219. One step of clear more.
[Error]=DPARSFA_run(Cfg);


