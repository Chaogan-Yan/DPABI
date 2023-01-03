function DPABI_TDA_run(Cfg)
% FORMAT DPABI_TDA_run(Cfg)
% Perform temporal dynamics analysis and concordance analysis
% Input:
%   Cfg - the parameters for temporal dynamics analysis.
% Output:
%   The processed results that you want.
%___________________________________________________________________________
% Written by YAN Chao-Gan 171001.
% The R-fMRI Lab, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com


if ~isfield(Cfg,'ConcordanceMeasuresSelected') %YAN Chao-Gan, 180704. If ConcordanceMeasuresSelected is not defined.
    Cfg.ConcordanceMeasuresSelected = 'fALFF;ReHo;DC;GSCorr;VMHC'; %YAN Chao-Gan, 180704. Added flexibility for concordance
end



if ~isfield(Cfg,'CalFC')
    Cfg.CalFC.ROIDef = {};
    Cfg.CalFC.ROISelectedIndex = [];
else
    if ~isfield(Cfg.CalFC,'ROIDef')
        Cfg.CalFC.ROIDef = {};
    end
    if ~isfield(Cfg.CalFC,'ROISelectedIndex')
        Cfg.CalFC.ROISelectedIndex = [];
    end
end


[SPMversion,c]=spm('Ver');
SPMversion=str2double(SPMversion(end));

[DPABIPath, fileN, extn] = fileparts(which('DPABI.m'));
TemplatePath=fullfile(DPABIPath, 'Templates');

% Multiple Sessions Processing
FunSessionPrefixSet={''}; %The first session doesn't need a prefix. From the second session, need a prefix such as 'S2_';
for iFunSession=2:Cfg.FunctionalSessionNumber
    FunSessionPrefixSet=[FunSessionPrefixSet;{['S',num2str(iFunSession),'_']}];
end

Cfg.SubjectNum=length(Cfg.SubjectID);

switch Cfg.MaskType
    case 'Default'
        MaskFile = [TemplatePath,filesep,'BrainMask_05_61x73x61.img'];
    case 'NoMask'
        MaskFile = '';
    case 'UserMask'
        MaskFile = Cfg.MaskDir;
end


StartingDirName = Cfg.StartingDirName;
%Dynamic ALFF
if (Cfg.IsALFF==1)
    for iFunSession=1:Cfg.FunctionalSessionNumber
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'ALFF_',StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'fALFF_',StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ALFF_',StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'fALFF_',StartingDirName]);
        parfor iSub=1:length(Cfg.SubjectID)
            InFiles = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},StartingDirName,filesep,Cfg.SubjectID{iSub}];
            OutFile = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'ALFF_',StartingDirName,filesep,'ALFF_',Cfg.SubjectID{iSub}];
            OutFile2 = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'fALFF_',StartingDirName,filesep,'fALFF_',Cfg.SubjectID{iSub}];

            %[ALFFBrain_AllWindow, fALFFBrain_AllWindow, Header] = y_alff_falff_Window(WindowSize, WindowStep, WindowType, AllVolume,ASamplePeriod, HighCutoff, LowCutoff, AMaskFilename, AResultFilename, TemporalMask, ScrubbingMethod, Header, CUTNUMBER)
            [ALFFBrain_AllWindow, fALFFBrain_AllWindow, Header] = y_alff_falff_Window(Cfg.WindowSize, Cfg.WindowStep, Cfg.WindowType, InFiles, Cfg.TR, Cfg.ALFF.ALowPass_HighCutoff, Cfg.ALFF.AHighPass_LowCutoff, MaskFile, {OutFile;OutFile2});
            
            %Calculate mean and std
            y_Write(squeeze(mean(ALFFBrain_AllWindow,4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ALFF_',StartingDirName,filesep,'MeanALFF_',Cfg.SubjectID{iSub}]);
            y_Write(squeeze(std(ALFFBrain_AllWindow,0,4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ALFF_',StartingDirName,filesep,'StdALFF_',Cfg.SubjectID{iSub}]);
            Temp = squeeze(std(ALFFBrain_AllWindow,0,4)) ./ squeeze(mean(ALFFBrain_AllWindow,4));
            Temp(find(isnan(Temp)))=0;
            y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ALFF_',StartingDirName,filesep,'CVALFF_',Cfg.SubjectID{iSub}]);

            y_Write(squeeze(mean(fALFFBrain_AllWindow,4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'fALFF_',StartingDirName,filesep,'MeanfALFF_',Cfg.SubjectID{iSub}]);
            y_Write(squeeze(std(fALFFBrain_AllWindow,0,4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'fALFF_',StartingDirName,filesep,'StdfALFF_',Cfg.SubjectID{iSub}]);
            Temp = squeeze(std(fALFFBrain_AllWindow,0,4)) ./ squeeze(mean(fALFFBrain_AllWindow,4));
            Temp(find(isnan(Temp)))=0;
            y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'fALFF_',StartingDirName,filesep,'CVfALFF_',Cfg.SubjectID{iSub}]);
        end
    end
end


%Check StartingDirName
if isempty(Cfg.StartingDirForDCetc)
    StartingDirName = Cfg.StartingDirName;
else
    StartingDirName = Cfg.StartingDirForDCetc{1};
end


%Dynamic ReHo
if (Cfg.IsReHo==1)
    for iFunSession=1:Cfg.FunctionalSessionNumber
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'ReHo_',StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ReHo_',StartingDirName]);
        parfor iSub=1:length(Cfg.SubjectID)
            InFiles = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},StartingDirName,filesep,Cfg.SubjectID{iSub}];
            OutFile = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'ReHo_',StartingDirName,filesep,'ReHo_',Cfg.SubjectID{iSub}];
            
            %[ReHoBrain_AllWindow, Header] = y_reho_Window(WindowSize, WindowStep, WindowType, AllVolume, NVoxel, AMaskFilename, AResultFilename, IsNeedDetrend, Band, TR, TemporalMask, ScrubbingMethod, ScrubbingTiming, Header, CUTNUMBER)
            [ReHoBrain_AllWindow, Header] = y_reho_Window(Cfg.WindowSize, Cfg.WindowStep, Cfg.WindowType, InFiles, Cfg.ReHo.Cluster, MaskFile, OutFile, Cfg.IsDetrend);

            %Calculate mean and std
            y_Write(squeeze(mean(ReHoBrain_AllWindow,4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ReHo_',StartingDirName,filesep,'MeanReHo_',Cfg.SubjectID{iSub}]);
            y_Write(squeeze(std(ReHoBrain_AllWindow,0,4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ReHo_',StartingDirName,filesep,'StdReHo_',Cfg.SubjectID{iSub}]);
            Temp = squeeze(std(ReHoBrain_AllWindow,0,4)) ./ squeeze(mean(ReHoBrain_AllWindow,4));
            Temp(find(isnan(Temp)))=0;
            y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ReHo_',StartingDirName,filesep,'CVReHo_',Cfg.SubjectID{iSub}]);
        end
    end
end

%Dynamic Degree Centrality
if (Cfg.IsDC==1)
    for iFunSession=1:Cfg.FunctionalSessionNumber
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'DC_',StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'DC_',StartingDirName]);
        parfor iSub=1:length(Cfg.SubjectID)
            InFiles = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},StartingDirName,filesep,Cfg.SubjectID{iSub}];
            OutFile = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'DC_',StartingDirName,filesep,'DC_',Cfg.SubjectID{iSub}];
            
            %[DegreeCentrality_PositiveWeightedSumBrain_AllWindow, DegreeCentrality_PositiveBinarizedSumBrain_AllWindow, Header] = y_DegreeCentrality_Window(WindowSize, WindowStep, WindowType, AllVolume, rThreshold, OutputName, MaskData, IsNeedDetrend, Band, TR, TemporalMask, ScrubbingMethod, ScrubbingTiming, Header, CUTNUMBER)
            [DegreeCentrality_PositiveWeightedSumBrain_AllWindow, DegreeCentrality_PositiveBinarizedSumBrain_AllWindow, Header] = y_DegreeCentrality_Window(Cfg.WindowSize, Cfg.WindowStep, Cfg.WindowType, InFiles, Cfg.DC.rThreshold, OutFile, MaskFile, Cfg.IsDetrend);

            %Calculate mean and std
            y_Write(squeeze(mean(DegreeCentrality_PositiveWeightedSumBrain_AllWindow,4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'DC_',StartingDirName,filesep,'MeanDC_PositiveWeightedSum_',Cfg.SubjectID{iSub}]);
            y_Write(squeeze(std(DegreeCentrality_PositiveWeightedSumBrain_AllWindow,0,4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'DC_',StartingDirName,filesep,'StdDC_PositiveWeightedSum_',Cfg.SubjectID{iSub}]);
            Temp = squeeze(std(DegreeCentrality_PositiveWeightedSumBrain_AllWindow,0,4)) ./ squeeze(mean(DegreeCentrality_PositiveWeightedSumBrain_AllWindow,4));
            Temp(find(isnan(Temp)))=0;
            y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'DC_',StartingDirName,filesep,'CVDC_PositiveWeightedSum_',Cfg.SubjectID{iSub}]);

            y_Write(squeeze(mean(DegreeCentrality_PositiveBinarizedSumBrain_AllWindow,4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'DC_',StartingDirName,filesep,'MeanDC_BinarizedSum_',Cfg.SubjectID{iSub}]);
            y_Write(squeeze(std(DegreeCentrality_PositiveBinarizedSumBrain_AllWindow,0,4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'DC_',StartingDirName,filesep,'StdDC_BinarizedSum_',Cfg.SubjectID{iSub}]);
            Temp = squeeze(std(DegreeCentrality_PositiveBinarizedSumBrain_AllWindow,0,4)) ./ squeeze(mean(DegreeCentrality_PositiveBinarizedSumBrain_AllWindow,4));
            Temp(find(isnan(Temp)))=0;
            y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'DC_',StartingDirName,filesep,'CVDC_BinarizedSum_',Cfg.SubjectID{iSub}]);
        end
    end
end


%Dynamic Global Signal Correlation
if (Cfg.IsGSCorr==1)
    
    switch Cfg.GSCorr.GlobalMask
        case 'Default'
            GlobalMaskFile = [TemplatePath,filesep,'BrainMask_05_61x73x61.img'];
        case 'UserMask'
            GlobalMaskFile = Cfg.GSCorr.GlobalMaskDir;
    end
    
    ROIDef = {GlobalMaskFile};
    
    for iFunSession=1:Cfg.FunctionalSessionNumber
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'GSCorr_',StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'GSCorr_',StartingDirName]);
        parfor iSub=1:length(Cfg.SubjectID)
            InFiles = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},StartingDirName,filesep,Cfg.SubjectID{iSub}];
            OutFile = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'GSCorr_',StartingDirName,filesep,'GSCorr_',Cfg.SubjectID{iSub}];
            
            %[FCBrain_AllWindow, zFCBrain_AllWindow, Header] = y_SCA_Window(WindowSize, WindowStep, WindowType, AllVolume, ROIDef, OutputName, MaskData, IsMultipleLabel, IsNeedDetrend, Band, TR, TemporalMask, ScrubbingMethod, ScrubbingTiming, Header, CUTNUMBER)
            [FCBrain_AllWindow, zFCBrain_AllWindow, Header] = y_SCA_Window(Cfg.WindowSize, Cfg.WindowStep, Cfg.WindowType, InFiles, ROIDef, OutFile, MaskFile, 0, Cfg.IsDetrend);
            
            %Calculate mean and std
            y_Write(squeeze(mean(zFCBrain_AllWindow,4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'GSCorr_',StartingDirName,filesep,'MeanzGSCorr_',Cfg.SubjectID{iSub}]);
            y_Write(squeeze(std(zFCBrain_AllWindow,0,4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'GSCorr_',StartingDirName,filesep,'StdzGSCorr_',Cfg.SubjectID{iSub}]);
            Temp = squeeze(std(zFCBrain_AllWindow,0,4)) ./ squeeze(mean(zFCBrain_AllWindow,4));
            Temp(find(isnan(Temp)))=0;
            y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'GSCorr_',StartingDirName,filesep,'CVzGSCorr_',Cfg.SubjectID{iSub}]);
        end
    end
end



%Dynamic Functional Connectivity
if (Cfg.IsFC==1)    
    for iFunSession=1:Cfg.FunctionalSessionNumber
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'FC_',StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'FC_',StartingDirName]);
        parfor iSub=1:length(Cfg.SubjectID)
            InFiles = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},StartingDirName,filesep,Cfg.SubjectID{iSub}];
            OutFile = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'FC_',StartingDirName,filesep,'FC_',Cfg.SubjectID{iSub}];
            
            %[FCBrain_AllWindow, zFCBrain_AllWindow, Header] = y_SCA_Window(WindowSize, WindowStep, WindowType, AllVolume, ROIDef, OutputName, MaskData, IsMultipleLabel, IsNeedDetrend, Band, TR, TemporalMask, ScrubbingMethod, ScrubbingTiming, Header, CUTNUMBER)
            [FCBrain_AllWindow, zFCBrain_AllWindow, Header] = y_SCA_Window(Cfg.WindowSize, Cfg.WindowStep, Cfg.WindowType, InFiles, Cfg.CalFC.ROIDef, OutFile, MaskFile, Cfg.CalFC.IsMultipleLabel, Cfg.CalFC.ROISelectedIndex, Cfg.IsDetrend);
            
            %Calculate mean and std
            for iROI=1:size(zFCBrain_AllWindow,5)
                y_Write(squeeze(mean(zFCBrain_AllWindow(:,:,:,:,iROI),4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'FC_',StartingDirName,filesep,'MeanzFC_','ROI',num2str(iROI),'_',Cfg.SubjectID{iSub}]);
                y_Write(squeeze(std(zFCBrain_AllWindow(:,:,:,:,iROI),0,4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'FC_',StartingDirName,filesep,'StdzFC_','ROI',num2str(iROI),'_',Cfg.SubjectID{iSub}]);
                Temp = squeeze(std(zFCBrain_AllWindow(:,:,:,:,iROI),0,4)) ./ squeeze(mean(zFCBrain_AllWindow(:,:,:,:,iROI),4));
                Temp(find(isnan(Temp)))=0;
                y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'FC_',StartingDirName,filesep,'CVzFC_','ROI',num2str(iROI),'_',Cfg.SubjectID{iSub}]);
            end
        end
    end
end




%Check StartingDirName
if ~isempty(Cfg.StartingDirForVMHC)
    StartingDirName = Cfg.StartingDirForVMHC{1};
end

%Dynamic VMHC
if (Cfg.IsVMHC==1)
    for iFunSession=1:Cfg.FunctionalSessionNumber
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'VMHC_',StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'VMHC_',StartingDirName]);
        parfor iSub=1:length(Cfg.SubjectID)
            InFiles = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},StartingDirName,filesep,Cfg.SubjectID{iSub}];
            OutFile = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'VMHC_',StartingDirName,filesep,'VMHC_',Cfg.SubjectID{iSub}];
            
            %[VMHCBrain_AllWindow, zVMHCBrain_AllWindow, Header] = y_VMHC_Window(WindowSize, WindowStep, WindowType, AllVolume, OutputName, MaskData, IsNeedDetrend, Band, TR, TemporalMask, ScrubbingMethod, ScrubbingTiming, Header)
            [VMHCBrain_AllWindow, zVMHCBrain_AllWindow, Header] = y_VMHC_Window(Cfg.WindowSize, Cfg.WindowStep, Cfg.WindowType, InFiles, OutFile, MaskFile, Cfg.IsDetrend);

            %Calculate mean and std
            y_Write(squeeze(mean(zVMHCBrain_AllWindow,4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'VMHC_',StartingDirName,filesep,'MeanzVMHC_',Cfg.SubjectID{iSub}]);
            y_Write(squeeze(std(zVMHCBrain_AllWindow,0,4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'VMHC_',StartingDirName,filesep,'StdzVMHC_',Cfg.SubjectID{iSub}]);
            Temp = squeeze(std(zVMHCBrain_AllWindow,0,4)) ./ squeeze(mean(zVMHCBrain_AllWindow,4));
            Temp(find(isnan(Temp)))=0;
            y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'VMHC_',StartingDirName,filesep,'CVzVMHC_',Cfg.SubjectID{iSub}]);
        end
    end
end



%Dynamic Voxel-wise Concordance
if (Cfg.VoxelWiseConcordance==1)
    for iFunSession=1:Cfg.FunctionalSessionNumber
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'Concordance_VoxelWise']);
        parfor iSub=1:length(Cfg.SubjectID)
            DirFile=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'ALFF_*']);
            if length(DirFile)>=1 % YAN Chao-Gan, 180806. In case some dynamic indices didn't calculate
                ALFF = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,DirFile(1).name,filesep,'ALFF_',Cfg.SubjectID{iSub},'.nii'];
            else
                ALFF = [];
            end
            DirFile=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'fALFF_*']);
            if length(DirFile)>=1
                fALFF = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,DirFile(1).name,filesep,'fALFF_',Cfg.SubjectID{iSub},'.nii'];
            else
                fALFF = [];
            end
            DirFile=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'ReHo*']);
            if length(DirFile)>=1
                ReHo = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,DirFile(1).name,filesep,'ReHo_',Cfg.SubjectID{iSub},'.nii'];
            else
                ReHo = [];
            end
            DirFile=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'DC_*']);
            if length(DirFile)>=1
                DC = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,DirFile(1).name,filesep,'DC_',Cfg.SubjectID{iSub},'_DegreeCentrality_PositiveWeightedSumBrain','.nii'];
            else
                DC = [];
            end
            DirFile=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'GSCorr_*']);
            if length(DirFile)>=1
                GSCorr = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,DirFile(1).name,filesep,'zGSCorr_',Cfg.SubjectID{iSub},'.nii'];
            else
                GSCorr = [];
            end
            DirFile=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'VMHC_*']);
            if length(DirFile)>=1
                VMHC = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,DirFile(1).name,filesep,'zVMHC_',Cfg.SubjectID{iSub},'.nii'];
            else
                VMHC = [];
            end
            %RaterImages={fALFF;ReHo;DC;GSCorr;VMHC};
            RaterImages = y_Call_Eval_ConcordanceMeasuresSelected(Cfg.ConcordanceMeasuresSelected,ALFF,fALFF,ReHo,DC,GSCorr,VMHC);  %YAN Chao-Gan, 180704. Added flexibility for concordance
            
            OutFile = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'Concordance_VoxelWise',filesep,'Concordance_VoxelWise_',Cfg.SubjectID{iSub}];
            [KendallWBrain, Header] = y_KendallW_Image(RaterImages, MaskFile, OutFile);
        end
    end
end


%Dynamic Volume-wise Concordance
if (Cfg.VolumeWiseConcordance==1)
    for iFunSession=1:Cfg.FunctionalSessionNumber
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'Concordance_VolumeWise']);
        parfor iSub=1:length(Cfg.SubjectID)
            DirFile=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'ALFF_*']);
            if length(DirFile)>=1 % YAN Chao-Gan, 180806. In case some dynamic indices didn't calculate
                ALFF = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,DirFile(1).name,filesep,'ALFF_',Cfg.SubjectID{iSub},'.nii'];
            else
                ALFF = [];
            end
            DirFile=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'fALFF_*']);
            if length(DirFile)>=1
                fALFF = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,DirFile(1).name,filesep,'fALFF_',Cfg.SubjectID{iSub},'.nii'];
            else
                fALFF = [];
            end
            DirFile=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'ReHo*']);
            if length(DirFile)>=1
                ReHo = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,DirFile(1).name,filesep,'ReHo_',Cfg.SubjectID{iSub},'.nii'];
            else
                ReHo = [];
            end
            DirFile=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'DC_*']);
            if length(DirFile)>=1
                DC = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,DirFile(1).name,filesep,'DC_',Cfg.SubjectID{iSub},'_DegreeCentrality_PositiveWeightedSumBrain','.nii'];
            else
                DC = [];
            end
            DirFile=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'GSCorr_*']);
            if length(DirFile)>=1
                GSCorr = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,DirFile(1).name,filesep,'zGSCorr_',Cfg.SubjectID{iSub},'.nii'];
            else
                GSCorr = [];
            end
            DirFile=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'VMHC_*']);
            if length(DirFile)>=1
                VMHC = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,DirFile(1).name,filesep,'zVMHC_',Cfg.SubjectID{iSub},'.nii'];
            else
                VMHC = [];
            end
            
            %RaterImages={fALFF;ReHo;DC;GSCorr;VMHC};
            RaterImages = y_Call_Eval_ConcordanceMeasuresSelected(Cfg.ConcordanceMeasuresSelected,ALFF,fALFF,ReHo,DC,GSCorr,VMHC);  %YAN Chao-Gan, 180704. Added flexibility for concordance

            OutFile = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'Concordance_VolumeWise',filesep,'Concordance_VolumeWise',Cfg.SubjectID{iSub}];
            [KendallW] = y_KendallW_AcrossImages(RaterImages, MaskFile, OutFile);
        end
    end
end

%Smooth Concordance
if (Cfg.IsSmoothConcordance==1)
    parfor iSub=1:length(Cfg.SubjectID)
        FileList=[];
        for iFunSession=1:Cfg.FunctionalSessionNumber
            FileList=[FileList;{[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'TemporalDynamics',filesep,'Concordance_VoxelWise',filesep,'Concordance_VoxelWise_',Cfg.SubjectID{iSub},'.nii']}];
        end
        
        SPMJOB = load([DPABIPath, filesep, 'DPARSF',filesep,'Jobmats',filesep,'Smooth.mat']);
        SPMJOB.matlabbatch{1,1}.spm.spatial.smooth.data = FileList;
        SPMJOB.matlabbatch{1,1}.spm.spatial.smooth.fwhm = Cfg.SmoothConcordance.FWHM;
        spm_jobman('run',SPMJOB.matlabbatch);
    end
end

fprintf(['\nCongratulations, the running of Temporal Dynamics Analysis is done!!! :)\n\n']);


function RaterImages = y_Call_Eval_ConcordanceMeasuresSelected(ConcordanceMeasuresSelected,ALFF,fALFF,ReHo,DC,GSCorr,VMHC)
eval(['RaterImages={',ConcordanceMeasuresSelected,'};'])




