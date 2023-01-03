function DPABI_TDA_Surf_run(Cfg)
% FORMAT DPABI_TDA_Surf_run(Cfg
% Perform temporal dynamics analysis and concordance analysis for surface (and volume)
% Input:
%   Cfg - the parameters for temporal dynamics analysis.
% Output:
%   The processed results that you want.
%___________________________________________________________________________
% Written by YAN Chao-Gan 190705.
% The R-fMRI Lab, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com


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

if ~isfield(Cfg,'MaskFileSurfLH')
    Cfg.MaskFileSurfLH = fullfile(DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_lh_cortex.label.gii');
end
if ~isfield(Cfg,'MaskFileSurfRH')
    Cfg.MaskFileSurfRH = fullfile(DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_rh_cortex.label.gii');
end
if ~isfield(Cfg,'MaskFileVolu')
    Cfg.MaskFileVolu=fullfile(Cfg.WorkingDir, 'Masks','AllResampled_BrainMask_05_91x109x91.nii');
end

if ~isfield(Cfg,'CalFC')
    Cfg.CalFC.ROIDefVolu = {};
else
    if ~isfield(Cfg.CalFC,'ROIDefVolu')
        Cfg.CalFC.ROIDefVolu = {};
    end
    if ~isfield(Cfg.CalFC,'ROISelectedIndexVolu')
        Cfg.CalFC.ROISelectedIndexVolu = [];
    end
    if ~isfield(Cfg.CalFC,'ROISelectedIndexSurfLH')
        Cfg.CalFC.ROISelectedIndexSurfLH = [];
    end
    if ~isfield(Cfg.CalFC,'ROISelectedIndexSurfRH')
        Cfg.CalFC.ROISelectedIndexSurfRH = [];
    end
end

Cfg.StartingDirName_Volume = ['FunVolu',Cfg.StartingDirName(8:end)];

%Dynamic ALFF
if (Cfg.IsALFF==1)
    for iFunSession=1:Cfg.FunctionalSessionNumber
        
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'ALFF_',Cfg.StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'fALFF_',Cfg.StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ALFF_',Cfg.StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'fALFF_',Cfg.StartingDirName]);
        
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'ALFF_',Cfg.StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'fALFF_',Cfg.StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ALFF_',Cfg.StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'fALFF_',Cfg.StartingDirName]);
        
        if (Cfg.IsProcessVolumeSpace==1)
            mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'ALFF_',Cfg.StartingDirName_Volume]);
            mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'fALFF_',Cfg.StartingDirName_Volume]);
            mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ALFF_',Cfg.StartingDirName_Volume]);
            mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'fALFF_',Cfg.StartingDirName_Volume]);
        end
        parfor i=1:Cfg.SubjectNum
            if Cfg.TR==0  % Need to retrieve the TR information from the NIfTI images
                TR = Cfg.TRSet(i,iFunSession);
            else
                TR = Cfg.TR;
            end
            
            % ALFF and fALFF calculation
            % Left Hemi
            DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*fsaverage5_hemi-L*.func.gii'));
            for iFile=1:length(DirName)
                FileName=DirName(iFile).name;
                InFiles = fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},FileName);
                OutFile = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'ALFF_',Cfg.StartingDirName,filesep,'ALFF_',Cfg.SubjectID{i},'.func.gii'];;
                OutFile2 = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'fALFF_',Cfg.StartingDirName,filesep,'fALFF_',Cfg.SubjectID{i},'.func.gii'];
                %[ALFFBrain_AllWindow, fALFFBrain_AllWindow, GHeader] = y_alff_falff_Surf_Window(WindowSize, WindowStep, WindowType,InFile,ASamplePeriod, HighCutoff, LowCutoff, AMaskFilename, AResultFilename, CUTNUMBER)
                [ALFFBrain_AllWindow, fALFFBrain_AllWindow, GHeader] = y_alff_falff_Surf_Window(Cfg.WindowSize, Cfg.WindowStep, Cfg.WindowType, InFiles, Cfg.TR, Cfg.ALFF.ALowPass_HighCutoff, Cfg.ALFF.AHighPass_LowCutoff, Cfg.MaskFileSurfLH, {OutFile;OutFile2});
                
                %Calculate mean and std
                y_Write(squeeze(mean(ALFFBrain_AllWindow,2)),GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ALFF_',Cfg.StartingDirName,filesep,'MeanALFF_',Cfg.SubjectID{i}]);
                y_Write(squeeze(std(ALFFBrain_AllWindow,0,2)),GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ALFF_',Cfg.StartingDirName,filesep,'StdALFF_',Cfg.SubjectID{i}]);
                Temp = squeeze(std(ALFFBrain_AllWindow,0,2)) ./ squeeze(mean(ALFFBrain_AllWindow,2));
                Temp(find(isnan(Temp)))=0;
                y_Write(Temp,GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ALFF_',Cfg.StartingDirName,filesep,'CVALFF_',Cfg.SubjectID{i}]);
                
                y_Write(squeeze(mean(fALFFBrain_AllWindow,2)),GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'fALFF_',Cfg.StartingDirName,filesep,'MeanfALFF_',Cfg.SubjectID{i}]);
                y_Write(squeeze(std(fALFFBrain_AllWindow,0,2)),GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'fALFF_',Cfg.StartingDirName,filesep,'StdfALFF_',Cfg.SubjectID{i}]);
                Temp = squeeze(std(fALFFBrain_AllWindow,0,2)) ./ squeeze(mean(fALFFBrain_AllWindow,2));
                Temp(find(isnan(Temp)))=0;
                y_Write(Temp,GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'fALFF_',Cfg.StartingDirName,filesep,'CVfALFF_',Cfg.SubjectID{i}]);
            end
            
            % Right Hemi
            DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*fsaverage5_hemi-R*.func.gii'));
            for iFile=1:length(DirName)
                FileName=DirName(iFile).name;
                InFiles = fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},FileName);
                OutFile = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'ALFF_',Cfg.StartingDirName,filesep,'ALFF_',Cfg.SubjectID{i},'.func.gii'];
                OutFile2 = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'fALFF_',Cfg.StartingDirName,filesep,'fALFF_',Cfg.SubjectID{i},'.func.gii'];
                %[ALFFBrain_AllWindow, fALFFBrain_AllWindow, GHeader] = y_alff_falff_Surf_Window(WindowSize, WindowStep, WindowType,InFile,ASamplePeriod, HighCutoff, LowCutoff, AMaskFilename, AResultFilename, CUTNUMBER)
                [ALFFBrain_AllWindow, fALFFBrain_AllWindow, GHeader] = y_alff_falff_Surf_Window(Cfg.WindowSize, Cfg.WindowStep, Cfg.WindowType, InFiles, Cfg.TR, Cfg.ALFF.ALowPass_HighCutoff, Cfg.ALFF.AHighPass_LowCutoff, Cfg.MaskFileSurfRH, {OutFile;OutFile2});
                
                %Calculate mean and std
                y_Write(squeeze(mean(ALFFBrain_AllWindow,2)),GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ALFF_',Cfg.StartingDirName,filesep,'MeanALFF_',Cfg.SubjectID{i}]);
                y_Write(squeeze(std(ALFFBrain_AllWindow,0,2)),GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ALFF_',Cfg.StartingDirName,filesep,'StdALFF_',Cfg.SubjectID{i}]);
                Temp = squeeze(std(ALFFBrain_AllWindow,0,2)) ./ squeeze(mean(ALFFBrain_AllWindow,2));
                Temp(find(isnan(Temp)))=0;
                y_Write(Temp,GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ALFF_',Cfg.StartingDirName,filesep,'CVALFF_',Cfg.SubjectID{i}]);
                
                y_Write(squeeze(mean(fALFFBrain_AllWindow,2)),GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'fALFF_',Cfg.StartingDirName,filesep,'MeanfALFF_',Cfg.SubjectID{i}]);
                y_Write(squeeze(std(fALFFBrain_AllWindow,0,2)),GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'fALFF_',Cfg.StartingDirName,filesep,'StdfALFF_',Cfg.SubjectID{i}]);
                Temp = squeeze(std(fALFFBrain_AllWindow,0,2)) ./ squeeze(mean(fALFFBrain_AllWindow,2));
                Temp(find(isnan(Temp)))=0;
                y_Write(Temp,GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'fALFF_',Cfg.StartingDirName,filesep,'CVfALFF_',Cfg.SubjectID{i}]);
            end
            
            % Volume
            if (Cfg.IsProcessVolumeSpace==1)
                InFiles = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i}];
                OutFile = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'ALFF_',Cfg.StartingDirName_Volume,filesep,'ALFF_',Cfg.SubjectID{i}];
                OutFile2 = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'fALFF_',Cfg.StartingDirName_Volume,filesep,'fALFF_',Cfg.SubjectID{i}];
                
                %[ALFFBrain_AllWindow, fALFFBrain_AllWindow, Header] = y_alff_falff_Window(WindowSize, WindowStep, WindowType, AllVolume,ASamplePeriod, HighCutoff, LowCutoff, AMaskFilename, AResultFilename, TemporalMask, ScrubbingMethod, Header, CUTNUMBER)
                [ALFFBrain_AllWindow, fALFFBrain_AllWindow, Header] = y_alff_falff_Window(Cfg.WindowSize, Cfg.WindowStep, Cfg.WindowType, InFiles, Cfg.TR, Cfg.ALFF.ALowPass_HighCutoff, Cfg.ALFF.AHighPass_LowCutoff, Cfg.MaskFileVolu, {OutFile;OutFile2});
                
                %Calculate mean and std
                y_Write(squeeze(mean(ALFFBrain_AllWindow,4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ALFF_',Cfg.StartingDirName_Volume,filesep,'MeanALFF_',Cfg.SubjectID{i}]);
                y_Write(squeeze(std(ALFFBrain_AllWindow,0,4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ALFF_',Cfg.StartingDirName_Volume,filesep,'StdALFF_',Cfg.SubjectID{i}]);
                Temp = squeeze(std(ALFFBrain_AllWindow,0,4)) ./ squeeze(mean(ALFFBrain_AllWindow,4));
                Temp(find(isnan(Temp)))=0;
                y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ALFF_',Cfg.StartingDirName_Volume,filesep,'CVALFF_',Cfg.SubjectID{i}]);
                
                y_Write(squeeze(mean(fALFFBrain_AllWindow,4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'fALFF_',Cfg.StartingDirName_Volume,filesep,'MeanfALFF_',Cfg.SubjectID{i}]);
                y_Write(squeeze(std(fALFFBrain_AllWindow,0,4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'fALFF_',Cfg.StartingDirName_Volume,filesep,'StdfALFF_',Cfg.SubjectID{i}]);
                Temp = squeeze(std(fALFFBrain_AllWindow,0,4)) ./ squeeze(mean(fALFFBrain_AllWindow,4));
                Temp(find(isnan(Temp)))=0;
                y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'fALFF_',Cfg.StartingDirName_Volume,filesep,'CVfALFF_',Cfg.SubjectID{i}]);
                
            end
        end
    end
end


%Check StartingDirName
if ~isempty(Cfg.StartingDirForDCetc)
    Cfg.StartingDirName = Cfg.StartingDirForDCetc{1};
    Cfg.StartingDirName_Volume = ['FunVolu',Cfg.StartingDirName(8:end)];
end


%Dynamic ReHo
if (Cfg.IsReHo==1)
    for iFunSession=1:Cfg.FunctionalSessionNumber
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'ReHo_',Cfg.StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ReHo_',Cfg.StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'ReHo_',Cfg.StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ReHo_',Cfg.StartingDirName]);
        
        if (Cfg.IsProcessVolumeSpace==1)
            mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'ReHo_',Cfg.StartingDirName_Volume]);
            mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ReHo_',Cfg.StartingDirName_Volume]);
        end
        parfor i=1:Cfg.SubjectNum
            
            % ReHo calculation
            % Left Hemi
            DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*fsaverage5_hemi-L*.func.gii'));
            for iFile=1:length(DirName)
                FileName=DirName(iFile).name;
                InFiles = fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},FileName);
                OutFile = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'ReHo_',Cfg.StartingDirName,filesep,'ReHo_',Cfg.SubjectID{i},'.func.gii'];
                %[ReHoBrain_AllWindow, GHeader] = y_reho_Surf_Window(WindowSize, WindowStep, WindowType,InFile, NNeighbor, AMaskFilename, AResultFilename, SurfFile, IsNeedDetrend, CUTNUMBER)
                [ReHoBrain_AllWindow, GHeader] = y_reho_Surf_Window(Cfg.WindowSize, Cfg.WindowStep, Cfg.WindowType, InFiles, Cfg.ReHo.SurfNNeighbor, Cfg.MaskFileSurfLH, OutFile, Cfg.SurfFileLH, Cfg.IsDetrend);

                %Calculate mean and std
                y_Write(squeeze(mean(ReHoBrain_AllWindow,2)),GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ReHo_',Cfg.StartingDirName,filesep,'MeanReHo_',Cfg.SubjectID{i}]);
                y_Write(squeeze(std(ReHoBrain_AllWindow,0,2)),GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ReHo_',Cfg.StartingDirName,filesep,'StdReHo_',Cfg.SubjectID{i}]);
                Temp = squeeze(std(ReHoBrain_AllWindow,0,2)) ./ squeeze(mean(ReHoBrain_AllWindow,2));
                Temp(find(isnan(Temp)))=0;
                y_Write(Temp,GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ReHo_',Cfg.StartingDirName,filesep,'CVReHo_',Cfg.SubjectID{i}]);
            end
            
            % Right Hemi
            DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*fsaverage5_hemi-R*.func.gii'));
            for iFile=1:length(DirName)
                FileName=DirName(iFile).name;
                InFiles = fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},FileName);
                OutFile = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'ReHo_',Cfg.StartingDirName,filesep,'ReHo_',Cfg.SubjectID{i},'.func.gii'];
                %[ReHoBrain_AllWindow, GHeader] = y_reho_Surf_Window(WindowSize, WindowStep, WindowType,InFile, NNeighbor, AMaskFilename, AResultFilename, SurfFile, IsNeedDetrend, CUTNUMBER)
                [ReHoBrain_AllWindow, GHeader] = y_reho_Surf_Window(Cfg.WindowSize, Cfg.WindowStep, Cfg.WindowType, InFiles, Cfg.ReHo.SurfNNeighbor, Cfg.MaskFileSurfRH, OutFile, Cfg.SurfFileRH, Cfg.IsDetrend);

                %Calculate mean and std
                y_Write(squeeze(mean(ReHoBrain_AllWindow,2)),GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ReHo_',Cfg.StartingDirName,filesep,'MeanReHo_',Cfg.SubjectID{i}]);
                y_Write(squeeze(std(ReHoBrain_AllWindow,0,2)),GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ReHo_',Cfg.StartingDirName,filesep,'StdReHo_',Cfg.SubjectID{i}]);
                Temp = squeeze(std(ReHoBrain_AllWindow,0,2)) ./ squeeze(mean(ReHoBrain_AllWindow,2));
                Temp(find(isnan(Temp)))=0;
                y_Write(Temp,GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ReHo_',Cfg.StartingDirName,filesep,'CVReHo_',Cfg.SubjectID{i}]);
            end
            
            % Volume
            if (Cfg.IsProcessVolumeSpace==1)
                InFiles = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i}];
                OutFile = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'ReHo_',Cfg.StartingDirName_Volume,filesep,'ReHo_',Cfg.SubjectID{i}];
                
                %[ReHoBrain_AllWindow, Header] = y_reho_Window(WindowSize, WindowStep, WindowType, AllVolume, NVoxel, AMaskFilename, AResultFilename, IsNeedDetrend, Band, TR, TemporalMask, ScrubbingMethod, ScrubbingTiming, Header, CUTNUMBER)
                [ReHoBrain_AllWindow, Header] = y_reho_Window(Cfg.WindowSize, Cfg.WindowStep, Cfg.WindowType, InFiles, Cfg.ReHo.Cluster, Cfg.MaskFileVolu, OutFile, Cfg.IsDetrend);
                
                %Calculate mean and std
                y_Write(squeeze(mean(ReHoBrain_AllWindow,4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ReHo_',Cfg.StartingDirName_Volume,filesep,'MeanReHo_',Cfg.SubjectID{i}]);
                y_Write(squeeze(std(ReHoBrain_AllWindow,0,4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ReHo_',Cfg.StartingDirName_Volume,filesep,'StdReHo_',Cfg.SubjectID{i}]);
                Temp = squeeze(std(ReHoBrain_AllWindow,0,4)) ./ squeeze(mean(ReHoBrain_AllWindow,4));
                Temp(find(isnan(Temp)))=0;
                y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'ReHo_',Cfg.StartingDirName_Volume,filesep,'CVReHo_',Cfg.SubjectID{i}]);
            end
        end
    end
end


%Dynamic Degree Centrality
if (Cfg.IsDegreeCentrality==1)
    for iFunSession=1:Cfg.FunctionalSessionNumber

        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'DegreeCentrality_',Cfg.StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'DegreeCentrality_',Cfg.StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'DegreeCentrality_',Cfg.StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'DegreeCentrality_',Cfg.StartingDirName]);
        
        if (Cfg.IsProcessVolumeSpace==1)
            mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'DegreeCentrality_',Cfg.StartingDirName_Volume]);
            mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'DegreeCentrality_',Cfg.StartingDirName_Volume]);
        end
        parfor i=1:Cfg.SubjectNum

            DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*fsaverage5_hemi-L*.func.gii'));
            FileName_LH=fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},DirName(1).name);
            DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*fsaverage5_hemi-R*.func.gii'));
            FileName_RH=fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},DirName(1).name);
            
            %[DegreeCentrality_PositiveWeightedSumBrain_LH_AllWindow, DegreeCentrality_PositiveWeightedSumBrain_RH_AllWindow, DegreeCentrality_PositiveBinarizedSumBrain_LH_AllWindow, DegreeCentrality_PositiveBinarizedSumBrain_RH_AllWindow, GHeader_LH, GHeader_RH] = y_DegreeCentrality_Bilateral_Surf_Window(WindowSize, WindowStep, WindowType, InFile_LH, InFile_RH, rThreshold, OutputName_LH, OutputName_RH, AMaskFilename_LH, AMaskFilename_RH, IsNeedDetrend, CUTNUMBER)
            [DegreeCentrality_PositiveWeightedSumBrain_LH_AllWindow, DegreeCentrality_PositiveWeightedSumBrain_RH_AllWindow, DegreeCentrality_PositiveBinarizedSumBrain_LH_AllWindow, DegreeCentrality_PositiveBinarizedSumBrain_RH_AllWindow, GHeader_LH, GHeader_RH] = y_DegreeCentrality_Bilateral_Surf_Window(Cfg.WindowSize, Cfg.WindowStep, Cfg.WindowType, FileName_LH, FileName_RH, ...
                Cfg.DegreeCentrality.rThreshold, ...
                {[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'DegreeCentrality_Bilateral_PositiveWeightedSumBrain_',Cfg.SubjectID{i},'.func.gii'];[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'DegreeCentrality_Bilateral_PositiveBinarizedSumBrain_',Cfg.SubjectID{i},'.func.gii']}, ...
                {[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'DegreeCentrality_Bilateral_PositiveWeightedSumBrain_',Cfg.SubjectID{i},'.func.gii'];[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'DegreeCentrality_Bilateral_PositiveBinarizedSumBrain_',Cfg.SubjectID{i},'.func.gii']}, ...
                Cfg.MaskFileSurfLH, Cfg.MaskFileSurfRH, Cfg.IsDetrend);

            %Calculate mean and std
            y_Write(squeeze(mean(DegreeCentrality_PositiveWeightedSumBrain_LH_AllWindow,2)),GHeader_LH,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'MeanDegreeCentrality_Bilateral_PositiveWeightedSumBrain_',Cfg.SubjectID{i}]);
            y_Write(squeeze(std(DegreeCentrality_PositiveWeightedSumBrain_LH_AllWindow,0,2)),GHeader_LH,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'StdDegreeCentrality_Bilateral_PositiveWeightedSumBrain_',Cfg.SubjectID{i}]);
            Temp = squeeze(std(DegreeCentrality_PositiveWeightedSumBrain_LH_AllWindow,0,2)) ./ squeeze(mean(DegreeCentrality_PositiveWeightedSumBrain_LH_AllWindow,2));
            Temp(find(isnan(Temp)))=0;
            y_Write(Temp,GHeader_LH,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'CVDegreeCentrality_Bilateral_PositiveWeightedSumBrain_',Cfg.SubjectID{i}]);
            
            y_Write(squeeze(mean(DegreeCentrality_PositiveBinarizedSumBrain_LH_AllWindow,2)),GHeader_LH,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'MeanDegreeCentrality_Bilateral_PositiveBinarizedSumBrain_',Cfg.SubjectID{i}]);
            y_Write(squeeze(std(DegreeCentrality_PositiveBinarizedSumBrain_LH_AllWindow,0,2)),GHeader_LH,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'StdDegreeCentrality_Bilateral_PositiveBinarizedSumBrain_',Cfg.SubjectID{i}]);
            Temp = squeeze(std(DegreeCentrality_PositiveBinarizedSumBrain_LH_AllWindow,0,2)) ./ squeeze(mean(DegreeCentrality_PositiveBinarizedSumBrain_LH_AllWindow,2));
            Temp(find(isnan(Temp)))=0;
            y_Write(Temp,GHeader_LH,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'CVDegreeCentrality_Bilateral_PositiveBinarizedSumBrain_',Cfg.SubjectID{i}]);
       
            y_Write(squeeze(mean(DegreeCentrality_PositiveWeightedSumBrain_RH_AllWindow,2)),GHeader_RH,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'MeanDegreeCentrality_Bilateral_PositiveWeightedSumBrain_',Cfg.SubjectID{i}]);
            y_Write(squeeze(std(DegreeCentrality_PositiveWeightedSumBrain_RH_AllWindow,0,2)),GHeader_RH,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'StdDegreeCentrality_Bilateral_PositiveWeightedSumBrain_',Cfg.SubjectID{i}]);
            Temp = squeeze(std(DegreeCentrality_PositiveWeightedSumBrain_RH_AllWindow,0,2)) ./ squeeze(mean(DegreeCentrality_PositiveWeightedSumBrain_RH_AllWindow,2));
            Temp(find(isnan(Temp)))=0;
            y_Write(Temp,GHeader_RH,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'CVDegreeCentrality_Bilateral_PositiveWeightedSumBrain_',Cfg.SubjectID{i}]);
            
            y_Write(squeeze(mean(DegreeCentrality_PositiveBinarizedSumBrain_RH_AllWindow,2)),GHeader_RH,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'MeanDegreeCentrality_Bilateral_PositiveBinarizedSumBrain_',Cfg.SubjectID{i}]);
            y_Write(squeeze(std(DegreeCentrality_PositiveBinarizedSumBrain_RH_AllWindow,0,2)),GHeader_RH,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'StdDegreeCentrality_Bilateral_PositiveBinarizedSumBrain_',Cfg.SubjectID{i}]);
            Temp = squeeze(std(DegreeCentrality_PositiveBinarizedSumBrain_RH_AllWindow,0,2)) ./ squeeze(mean(DegreeCentrality_PositiveBinarizedSumBrain_RH_AllWindow,2));
            Temp(find(isnan(Temp)))=0;
            y_Write(Temp,GHeader_RH,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'CVDegreeCentrality_Bilateral_PositiveBinarizedSumBrain_',Cfg.SubjectID{i}]);
            
            % Volume
            if (Cfg.IsProcessVolumeSpace==1)
                InFiles = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i}];
                OutFile = {[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'DegreeCentrality_',Cfg.StartingDirName_Volume,filesep,'DegreeCentrality_Bilateral_PositiveWeightedSumBrain_',Cfg.SubjectID{i},'.nii'];[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'DegreeCentrality_',Cfg.StartingDirName_Volume,filesep,'DegreeCentrality_Bilateral_PositiveBinarizedSumBrain_',Cfg.SubjectID{i},'.nii']};

                %[DegreeCentrality_PositiveWeightedSumBrain_AllWindow, DegreeCentrality_PositiveBinarizedSumBrain_AllWindow, Header] = y_DegreeCentrality_Window(WindowSize, WindowStep, WindowType, AllVolume, rThreshold, OutputName, MaskData, IsNeedDetrend, Band, TR, TemporalMask, ScrubbingMethod, ScrubbingTiming, Header, CUTNUMBER)
                [DegreeCentrality_PositiveWeightedSumBrain_AllWindow, DegreeCentrality_PositiveBinarizedSumBrain_AllWindow, Header] = y_DegreeCentrality_Window(Cfg.WindowSize, Cfg.WindowStep, Cfg.WindowType, InFiles, Cfg.DegreeCentrality.rThreshold, OutFile, Cfg.MaskFileVolu, Cfg.IsDetrend);
                
                %Calculate mean and std
                y_Write(squeeze(mean(DegreeCentrality_PositiveWeightedSumBrain_AllWindow,4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'DegreeCentrality_',Cfg.StartingDirName_Volume,filesep,'MeanDegreeCentrality_PositiveWeightedSum_',Cfg.SubjectID{i}]);
                y_Write(squeeze(std(DegreeCentrality_PositiveWeightedSumBrain_AllWindow,0,4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'DegreeCentrality_',Cfg.StartingDirName_Volume,filesep,'StdDegreeCentrality_PositiveWeightedSum_',Cfg.SubjectID{i}]);
                Temp = squeeze(std(DegreeCentrality_PositiveWeightedSumBrain_AllWindow,0,4)) ./ squeeze(mean(DegreeCentrality_PositiveWeightedSumBrain_AllWindow,4));
                Temp(find(isnan(Temp)))=0;
                y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'DegreeCentrality_',Cfg.StartingDirName_Volume,filesep,'CVDegreeCentrality_PositiveWeightedSum_',Cfg.SubjectID{i}]);
                
                y_Write(squeeze(mean(DegreeCentrality_PositiveBinarizedSumBrain_AllWindow,4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'DegreeCentrality_',Cfg.StartingDirName_Volume,filesep,'MeanDegreeCentrality_BinarizedSum_',Cfg.SubjectID{i}]);
                y_Write(squeeze(std(DegreeCentrality_PositiveBinarizedSumBrain_AllWindow,0,4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'DegreeCentrality_',Cfg.StartingDirName_Volume,filesep,'StdDegreeCentrality_BinarizedSum_',Cfg.SubjectID{i}]);
                Temp = squeeze(std(DegreeCentrality_PositiveBinarizedSumBrain_AllWindow,0,4)) ./ squeeze(mean(DegreeCentrality_PositiveBinarizedSumBrain_AllWindow,4));
                Temp(find(isnan(Temp)))=0;
                y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'DegreeCentrality_',Cfg.StartingDirName_Volume,filesep,'CVDegreeCentrality_BinarizedSum_',Cfg.SubjectID{i}]);
            end
        end
    end
end


%Dynamic Global Signal Correlation
if (Cfg.IsGSCorr==1)
    for iFunSession=1:Cfg.FunctionalSessionNumber
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'GSCorr_',Cfg.StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'GSCorr_',Cfg.StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'GSCorr_',Cfg.StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'GSCorr_',Cfg.StartingDirName]);
        
        if (Cfg.IsProcessVolumeSpace==1)
            mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'GSCorr_',Cfg.StartingDirName_Volume]);
            mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'GSCorr_',Cfg.StartingDirName_Volume]);
        end
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'ROISignals_',Cfg.StartingDirName_Volume]);
        parfor i=1:Cfg.SubjectNum
            %Extract global time course first.
            y_ExtractROISignal([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i}], ...
                {Cfg.GSCorr.GlobalMaskVolu}, ... %Global Signal Mask
                [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'ROISignals_',Cfg.StartingDirName_Volume,filesep,'GlobalSignal',Cfg.SubjectID{i}], ...
                '', ... % Will not restrict into the brain mask in extracting ROI signals
                0);

            ROIDef = {[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'ROISignals_',Cfg.StartingDirName_Volume,filesep,'ROISignals_','GlobalSignal',Cfg.SubjectID{i},'.txt']};
            IsMultipleLabel = 0;
            
            % Left Hemi
            DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*fsaverage5_hemi-L*.func.gii'));
            for iFile=1:length(DirName)
                FileName=DirName(iFile).name;
                InFiles = fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},FileName);
                OutFile = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'GSCorr_',Cfg.StartingDirName,filesep,'GSCorr_',Cfg.SubjectID{i},'.func.gii'];
                                
                %[FCBrain_AllWindow, zFCBrain_AllWindow, GHeader] = y_SCA_Surf_Window(WindowSize, WindowStep, WindowType, AllVolume, ROIDef, OutputName, AMaskFilename, IsMultipleLabel, IsNeedDetrend, GHeader, CUTNUMBER)
                [FCBrain_AllWindow, zFCBrain_AllWindow, GHeader] = y_SCA_Surf_Window(Cfg.WindowSize, Cfg.WindowStep, Cfg.WindowType, InFiles, ROIDef, OutFile, Cfg.MaskFileSurfLH, IsMultipleLabel, Cfg.IsDetrend);

                %Calculate mean and std
                y_Write(squeeze(mean(zFCBrain_AllWindow,2)),GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'GSCorr_',Cfg.StartingDirName,filesep,'MeanzGSCorr_',Cfg.SubjectID{i}]);
                y_Write(squeeze(std(zFCBrain_AllWindow,0,2)),GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'GSCorr_',Cfg.StartingDirName,filesep,'StdzGSCorr_',Cfg.SubjectID{i}]);
                Temp = squeeze(std(zFCBrain_AllWindow,0,2)) ./ squeeze(mean(zFCBrain_AllWindow,2));
                Temp(find(isnan(Temp)))=0;
                y_Write(Temp,GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'GSCorr_',Cfg.StartingDirName,filesep,'CVzGSCorr_',Cfg.SubjectID{i}]);
            end
            
            % Right Hemi
            DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*fsaverage5_hemi-R*.func.gii'));
            for iFile=1:length(DirName)
                FileName=DirName(iFile).name;
                InFiles = fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},FileName);
                OutFile = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'GSCorr_',Cfg.StartingDirName,filesep,'GSCorr_',Cfg.SubjectID{i},'.func.gii'];
                                
                %[FCBrain_AllWindow, zFCBrain_AllWindow, GHeader] = y_SCA_Surf_Window(WindowSize, WindowStep, WindowType, AllVolume, ROIDef, OutputName, AMaskFilename, IsMultipleLabel, IsNeedDetrend, GHeader, CUTNUMBER)
                [FCBrain_AllWindow, zFCBrain_AllWindow, GHeader] = y_SCA_Surf_Window(Cfg.WindowSize, Cfg.WindowStep, Cfg.WindowType, InFiles, ROIDef, OutFile, Cfg.MaskFileSurfRH, IsMultipleLabel, Cfg.IsDetrend);

                %Calculate mean and std
                y_Write(squeeze(mean(zFCBrain_AllWindow,2)),GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'GSCorr_',Cfg.StartingDirName,filesep,'MeanzGSCorr_',Cfg.SubjectID{i}]);
                y_Write(squeeze(std(zFCBrain_AllWindow,0,2)),GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'GSCorr_',Cfg.StartingDirName,filesep,'StdzGSCorr_',Cfg.SubjectID{i}]);
                Temp = squeeze(std(zFCBrain_AllWindow,0,2)) ./ squeeze(mean(zFCBrain_AllWindow,2));
                Temp(find(isnan(Temp)))=0;
                y_Write(Temp,GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'GSCorr_',Cfg.StartingDirName,filesep,'CVzGSCorr_',Cfg.SubjectID{i}]);
            end
            
            % Volume
            if (Cfg.IsProcessVolumeSpace==1)
                InFiles = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i}];
                OutFile = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'GSCorr_',Cfg.StartingDirName_Volume,filesep,'GSCorr_',Cfg.SubjectID{i}];

                %[FCBrain_AllWindow, zFCBrain_AllWindow, Header] = y_SCA_Window(WindowSize, WindowStep, WindowType, AllVolume, ROIDef, OutputName, MaskData, IsMultipleLabel, IsNeedDetrend, Band, TR, TemporalMask, ScrubbingMethod, ScrubbingTiming, Header, CUTNUMBER)
                [FCBrain_AllWindow, zFCBrain_AllWindow, Header] = y_SCA_Window(Cfg.WindowSize, Cfg.WindowStep, Cfg.WindowType, InFiles, ROIDef, OutFile, Cfg.MaskFileVolu, IsMultipleLabel, Cfg.IsDetrend);
                
                %Calculate mean and std
                y_Write(squeeze(mean(zFCBrain_AllWindow,4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'GSCorr_',Cfg.StartingDirName_Volume,filesep,'MeanzGSCorr_',Cfg.SubjectID{i}]);
                y_Write(squeeze(std(zFCBrain_AllWindow,0,4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'GSCorr_',Cfg.StartingDirName_Volume,filesep,'StdzGSCorr_',Cfg.SubjectID{i}]);
                Temp = squeeze(std(zFCBrain_AllWindow,0,4)) ./ squeeze(mean(zFCBrain_AllWindow,4));
                Temp(find(isnan(Temp)))=0;
                y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'GSCorr_',Cfg.StartingDirName_Volume,filesep,'CVzGSCorr_',Cfg.SubjectID{i}]);
                
            end
        end
    end
end


%Extract ROI Signals for Dynamic Functional Connectivity Analysis
if (Cfg.IsFC==1)
    for iFunSession=1:Cfg.FunctionalSessionNumber
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'ROISignals_',Cfg.StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'ROISignals_',Cfg.StartingDirName]);
        if (Cfg.IsProcessVolumeSpace==1)
            mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'ROISignals_',Cfg.StartingDirName_Volume]);
        end
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'ROISignals_SurfLHSurfRHVolu_',Cfg.StartingDirName]);
        
        %Extract the ROI time courses
        parfor i=1:Cfg.SubjectNum
            ROISignalsSurfLH=[];
            ROISignalsSurfRH=[];
            ROISignalsVolu=[];
            % Left Hemi
            if ~isempty(Cfg.CalFC.ROIDefSurfLH)
                DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*fsaverage5_hemi-L*.func.gii'));
                for iFile=1:length(DirName)
                    FileName=DirName(iFile).name;
                    [ROISignalsSurfLH] = y_ExtractROISignal_Surf(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},FileName), ...
                        Cfg.CalFC.ROIDefSurfLH, ...
                        [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'ROISignals_',Cfg.StartingDirName,filesep,Cfg.SubjectID{i}], ...
                        '', ... % Will not restrict into the brain mask in extracting ROI signals
                        Cfg.CalFC.IsMultipleLabel,Cfg.CalFC.ROISelectedIndexSurfLH);
                end
            end
            
            % Right Hemi
            if ~isempty(Cfg.CalFC.ROIDefSurfRH)
                DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*fsaverage5_hemi-R*.func.gii'));
                for iFile=1:length(DirName)
                    FileName=DirName(iFile).name;
                    [ROISignalsSurfRH] = y_ExtractROISignal_Surf(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},FileName), ...
                        Cfg.CalFC.ROIDefSurfRH, ...
                        [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'ROISignals_',Cfg.StartingDirName,filesep,Cfg.SubjectID{i}], ...
                        '', ... % Will not restrict into the brain mask in extracting ROI signals
                        Cfg.CalFC.IsMultipleLabel,Cfg.CalFC.ROISelectedIndexSurfRH);
                end
            end
            
            % Volume
            if ~isempty(Cfg.CalFC.ROIDefVolu)
                [ROISignalsVolu] = y_ExtractROISignal([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i}], ...
                Cfg.CalFC.ROIDefVolu, ...
                [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'ROISignals_',Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i}], ...
                '', ... % Will not restrict into the brain mask in extracting ROI signals
                Cfg.CalFC.IsMultipleLabel,Cfg.CalFC.ROISelectedIndexVolu);
            end
            
            ROISignals = [ROISignalsSurfLH, ROISignalsSurfRH, ROISignalsVolu];
            y_CallSave([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'ROISignals_SurfLHSurfRHVolu_',Cfg.StartingDirName,filesep, 'ROISignals_',Cfg.SubjectID{i},'.mat'], ROISignals, '');
            y_CallSave([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'ROISignals_SurfLHSurfRHVolu_',Cfg.StartingDirName,filesep, 'ROISignals_',Cfg.SubjectID{i},'.txt'], ROISignals, ' ''-ASCII'', ''-DOUBLE'',''-TABS''');
            ROICorrelation = corrcoef(ROISignals);
            y_CallSave([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'ROISignals_SurfLHSurfRHVolu_',Cfg.StartingDirName,filesep, 'ROICorrelation_',Cfg.SubjectID{i},'.mat'], ROICorrelation, '');
            y_CallSave([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'ROISignals_SurfLHSurfRHVolu_',Cfg.StartingDirName,filesep, 'ROICorrelation_',Cfg.SubjectID{i},'.txt'], ROICorrelation, ' ''-ASCII'', ''-DOUBLE'',''-TABS''');
            ROICorrelation_FisherZ = 0.5 * log((1 + ROICorrelation)./(1- ROICorrelation));
            y_CallSave([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'ROISignals_SurfLHSurfRHVolu_',Cfg.StartingDirName,filesep, 'ROICorrelation_FisherZ_',Cfg.SubjectID{i},'.mat'], ROICorrelation_FisherZ, '');
            y_CallSave([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'ROISignals_SurfLHSurfRHVolu_',Cfg.StartingDirName,filesep, 'ROICorrelation_FisherZ_',Cfg.SubjectID{i},'.txt'], ROICorrelation_FisherZ, ' ''-ASCII'', ''-DOUBLE'',''-TABS''');
        end
    end
end


%Dynamic FC
if (Cfg.IsFC==1)
    for iFunSession=1:Cfg.FunctionalSessionNumber
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'FC_',Cfg.StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'FC_',Cfg.StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'FC_',Cfg.StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'FC_',Cfg.StartingDirName]);
        
        if (Cfg.IsProcessVolumeSpace==1)
            mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'FC_',Cfg.StartingDirName_Volume]);
            mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'FC_',Cfg.StartingDirName_Volume]);
        end
        parfor i=1:Cfg.SubjectNum
            ROIDef = {[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'ROISignals_SurfLHSurfRHVolu_',Cfg.StartingDirName,filesep, 'ROISignals_',Cfg.SubjectID{i},'.txt']};
            IsMultipleLabel = 1;
            
            % Left Hemi
            DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*fsaverage5_hemi-L*.func.gii'));
            for iFile=1:length(DirName)
                FileName=DirName(iFile).name;
                InFiles = fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},FileName);
                OutFile = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'FC_',Cfg.StartingDirName,filesep,'FC_',Cfg.SubjectID{i},'.func.gii'];
                                
                %[FCBrain_AllWindow, zFCBrain_AllWindow, GHeader] = y_SCA_Surf_Window(WindowSize, WindowStep, WindowType, AllVolume, ROIDef, OutputName, AMaskFilename, IsMultipleLabel, IsNeedDetrend, GHeader, CUTNUMBER)
                [FCBrain_AllWindow, zFCBrain_AllWindow, GHeader] = y_SCA_Surf_Window(Cfg.WindowSize, Cfg.WindowStep, Cfg.WindowType, InFiles, ROIDef, OutFile, Cfg.MaskFileSurfLH, IsMultipleLabel, Cfg.IsDetrend);

                %Calculate mean and std
                for iROI=1:size(zFCBrain_AllWindow,3)
                    y_Write(squeeze(mean(zFCBrain_AllWindow(:,:,iROI),2)),GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'FC_',Cfg.StartingDirName,filesep,'MeanzFC_','ROI',num2str(iROI),'_',Cfg.SubjectID{i}]);
                    y_Write(squeeze(std(zFCBrain_AllWindow(:,:,iROI),0,2)),GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'FC_',Cfg.StartingDirName,filesep,'StdzFC_','ROI',num2str(iROI),'_',Cfg.SubjectID{i}]);
                    Temp = squeeze(std(zFCBrain_AllWindow(:,:,iROI),0,2)) ./ squeeze(mean(zFCBrain_AllWindow(:,:,iROI),2));
                    Temp(find(isnan(Temp)))=0;
                    y_Write(Temp,GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'FC_',Cfg.StartingDirName,filesep,'CVzFC_','ROI',num2str(iROI),'_',Cfg.SubjectID{i}]);
                end
            end
            
            % Right Hemi
            DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*fsaverage5_hemi-R*.func.gii'));
            for iFile=1:length(DirName)
                FileName=DirName(iFile).name;
                InFiles = fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},FileName);
                OutFile = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'FC_',Cfg.StartingDirName,filesep,'FC_',Cfg.SubjectID{i},'.func.gii'];
                
                %[FCBrain_AllWindow, zFCBrain_AllWindow, GHeader] = y_SCA_Surf_Window(WindowSize, WindowStep, WindowType, AllVolume, ROIDef, OutputName, AMaskFilename, IsMultipleLabel, IsNeedDetrend, GHeader, CUTNUMBER)
                [FCBrain_AllWindow, zFCBrain_AllWindow, GHeader] = y_SCA_Surf_Window(Cfg.WindowSize, Cfg.WindowStep, Cfg.WindowType, InFiles, ROIDef, OutFile, Cfg.MaskFileSurfRH, IsMultipleLabel, Cfg.IsDetrend);
                
                %Calculate mean and std
                for iROI=1:size(zFCBrain_AllWindow,3)
                    y_Write(squeeze(mean(zFCBrain_AllWindow(:,:,iROI),2)),GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'FC_',Cfg.StartingDirName,filesep,'MeanzFC_','ROI',num2str(iROI),'_',Cfg.SubjectID{i}]);
                    y_Write(squeeze(std(zFCBrain_AllWindow(:,:,iROI),0,2)),GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'FC_',Cfg.StartingDirName,filesep,'StdzFC_','ROI',num2str(iROI),'_',Cfg.SubjectID{i}]);
                    Temp = squeeze(std(zFCBrain_AllWindow(:,:,iROI),0,2)) ./ squeeze(mean(zFCBrain_AllWindow(:,:,iROI),2));
                    Temp(find(isnan(Temp)))=0;
                    y_Write(Temp,GHeader,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'FC_',Cfg.StartingDirName,filesep,'CVzFC_','ROI',num2str(iROI),'_',Cfg.SubjectID{i}]);
                end
            end
            
            % Volume
            if (Cfg.IsProcessVolumeSpace==1)
                InFiles = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i}];
                OutFile = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D',filesep,'FC_',Cfg.StartingDirName_Volume,filesep,'FC_',Cfg.SubjectID{i}];

                %[FCBrain_AllWindow, zFCBrain_AllWindow, Header] = y_SCA_Window(WindowSize, WindowStep, WindowType, AllVolume, ROIDef, OutputName, MaskData, IsMultipleLabel, IsNeedDetrend, Band, TR, TemporalMask, ScrubbingMethod, ScrubbingTiming, Header, CUTNUMBER)
                [FCBrain_AllWindow, zFCBrain_AllWindow, Header] = y_SCA_Window(Cfg.WindowSize, Cfg.WindowStep, Cfg.WindowType, InFiles, ROIDef, OutFile, Cfg.MaskFileVolu, IsMultipleLabel, Cfg.IsDetrend);
                
                %Calculate mean and std
                for iROI=1:size(zFCBrain_AllWindow,5)
                    y_Write(squeeze(mean(zFCBrain_AllWindow(:,:,:,:,iROI),4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'FC_',Cfg.StartingDirName_Volume,filesep,'MeanzFC_','ROI',num2str(iROI),'_',Cfg.SubjectID{i}]);
                    y_Write(squeeze(std(zFCBrain_AllWindow(:,:,:,:,iROI),0,4)),Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'FC_',Cfg.StartingDirName_Volume,filesep,'StdzFC_','ROI',num2str(iROI),'_',Cfg.SubjectID{i}]);
                    Temp = squeeze(std(zFCBrain_AllWindow(:,:,:,:,iROI),0,4)) ./ squeeze(mean(zFCBrain_AllWindow(:,:,:,:,iROI),4));
                    Temp(find(isnan(Temp)))=0;
                    y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamicsMetrics',filesep,'FC_',Cfg.StartingDirName_Volume,filesep,'CVzFC_','ROI',num2str(iROI),'_',Cfg.SubjectID{i}]);
                end
            end
        end
    end
end


%Dynamic Voxel-wise Concordance
if (Cfg.VoxelWiseConcordance==1)
    for iFunSession=1:Cfg.FunctionalSessionNumber
        
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'Concordance_VertexWise']);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'Concordance_VertexWise']);
        if (Cfg.IsProcessVolumeSpace==1)
            mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'Concordance_VoxelWise']);
        end
        parfor iSub=1:length(Cfg.SubjectID)
            
            % Left Hemi
            DataDir=[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D'];
            DirFile=dir([DataDir,filesep,'ALFF_*']);
            if length(DirFile)>=1 % YAN Chao-Gan, 180806. In case some dynamic indices didn't calculate
                ALFF = [DataDir,filesep,DirFile(1).name,filesep,'ALFF_',Cfg.SubjectID{iSub},'.func.gii'];
            else
                ALFF = [];
            end
            DirFile=dir([DataDir,filesep,'fALFF_*']);
            if length(DirFile)>=1
                fALFF = [DataDir,filesep,DirFile(1).name,filesep,'fALFF_',Cfg.SubjectID{iSub},'.func.gii'];
            else
                fALFF = [];
            end
            DirFile=dir([DataDir,filesep,'ReHo*']);
            if length(DirFile)>=1
                ReHo = [DataDir,filesep,DirFile(1).name,filesep,'ReHo_',Cfg.SubjectID{iSub},'.func.gii'];
            else
                ReHo = [];
            end
            DirFile=dir([DataDir,filesep,'DegreeCentrality_*']);
            if length(DirFile)>=1
                DC = [DataDir,filesep,DirFile(1).name,filesep,'DegreeCentrality_Bilateral_PositiveWeightedSumBrain_',Cfg.SubjectID{iSub},'.func.gii'];
            else
                DC = [];
            end
            DirFile=dir([DataDir,filesep,'GSCorr_*']);
            if length(DirFile)>=1
                GSCorr = [DataDir,filesep,DirFile(1).name,filesep,'zGSCorr_',Cfg.SubjectID{iSub},'.func.gii'];
            else
                GSCorr = [];
            end
            RaterImages = y_Call_Eval_ConcordanceMeasuresSelected(Cfg.ConcordanceMeasuresSelected,ALFF,fALFF,ReHo,DC,GSCorr);  
            OutFile = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'Concordance_VertexWise',filesep,'Concordance_VertexWise_',Cfg.SubjectID{iSub},'.func.gii'];
            [KendallWBrain, GHeader] = y_KendallW_Image_Surf(RaterImages, Cfg.MaskFileSurfLH, OutFile);

            % Right Hemi
            DataDir=[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D'];
            DirFile=dir([DataDir,filesep,'ALFF_*']);
            if length(DirFile)>=1 % YAN Chao-Gan, 180806. In case some dynamic indices didn't calculate
                ALFF = [DataDir,filesep,DirFile(1).name,filesep,'ALFF_',Cfg.SubjectID{iSub},'.func.gii'];
            else
                ALFF = [];
            end
            DirFile=dir([DataDir,filesep,'fALFF_*']);
            if length(DirFile)>=1
                fALFF = [DataDir,filesep,DirFile(1).name,filesep,'fALFF_',Cfg.SubjectID{iSub},'.func.gii'];
            else
                fALFF = [];
            end
            DirFile=dir([DataDir,filesep,'ReHo*']);
            if length(DirFile)>=1
                ReHo = [DataDir,filesep,DirFile(1).name,filesep,'ReHo_',Cfg.SubjectID{iSub},'.func.gii'];
            else
                ReHo = [];
            end
            DirFile=dir([DataDir,filesep,'DegreeCentrality_*']);
            if length(DirFile)>=1
                DC = [DataDir,filesep,DirFile(1).name,filesep,'DegreeCentrality_Bilateral_PositiveWeightedSumBrain_',Cfg.SubjectID{iSub},'.func.gii'];
            else
                DC = [];
            end
            DirFile=dir([DataDir,filesep,'GSCorr_*']);
            if length(DirFile)>=1
                GSCorr = [DataDir,filesep,DirFile(1).name,filesep,'zGSCorr_',Cfg.SubjectID{iSub},'.func.gii'];
            else
                GSCorr = [];
            end
            RaterImages = y_Call_Eval_ConcordanceMeasuresSelected(Cfg.ConcordanceMeasuresSelected,ALFF,fALFF,ReHo,DC,GSCorr);  
            OutFile = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'Concordance_VertexWise',filesep,'Concordance_VertexWise_',Cfg.SubjectID{iSub},'.func.gii'];
            [KendallWBrain, GHeader] = y_KendallW_Image_Surf(RaterImages, Cfg.MaskFileSurfRH, OutFile);

            % Volume
            if (Cfg.IsProcessVolumeSpace==1)
                DataDir=[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D'];
                DirFile=dir([DataDir,filesep,'ALFF_*']);
                if length(DirFile)>=1 % YAN Chao-Gan, 180806. In case some dynamic indices didn't calculate
                    ALFF = [DataDir,filesep,DirFile(1).name,filesep,'ALFF_',Cfg.SubjectID{iSub},'.nii'];
                else
                    ALFF = [];
                end
                DirFile=dir([DataDir,filesep,'fALFF_*']);
                if length(DirFile)>=1
                    fALFF = [DataDir,filesep,DirFile(1).name,filesep,'fALFF_',Cfg.SubjectID{iSub},'.nii'];
                else
                    fALFF = [];
                end
                DirFile=dir([DataDir,filesep,'ReHo*']);
                if length(DirFile)>=1
                    ReHo = [DataDir,filesep,DirFile(1).name,filesep,'ReHo_',Cfg.SubjectID{iSub},'.nii'];
                else
                    ReHo = [];
                end
                DirFile=dir([DataDir,filesep,'DegreeCentrality_*']);
                if length(DirFile)>=1
                    DC = [DataDir,filesep,DirFile(1).name,filesep,'DegreeCentrality_Bilateral_PositiveWeightedSumBrain_',Cfg.SubjectID{iSub},'.nii'];
                else
                    DC = [];
                end
                DirFile=dir([DataDir,filesep,'GSCorr_*']);
                if length(DirFile)>=1
                    GSCorr = [DataDir,filesep,DirFile(1).name,filesep,'zGSCorr_',Cfg.SubjectID{iSub},'.nii'];
                else
                    GSCorr = [];
                end
                RaterImages = y_Call_Eval_ConcordanceMeasuresSelected(Cfg.ConcordanceMeasuresSelected,ALFF,fALFF,ReHo,DC,GSCorr);
                OutFile = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'Concordance_VoxelWise',filesep,'Concordance_VoxelWise_',Cfg.SubjectID{iSub}];
                [KendallWBrain, GHeader] = y_KendallW_Image(RaterImages, Cfg.MaskFileVolu, OutFile);
            end
        end
    end
end


%Dynamic Volume-wise Concordance
if (Cfg.VolumeWiseConcordance==1)
    for iFunSession=1:Cfg.FunctionalSessionNumber

        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'Concordance_VolumeWise']);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'Concordance_VolumeWise']);
        if (Cfg.IsProcessVolumeSpace==1)
            mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'Concordance_VolumeWise']);
        end
        for iSub=1:length(Cfg.SubjectID)
            
            % Left Hemi Files
            DataDir=[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D'];
            DirFile=dir([DataDir,filesep,'ALFF_*']);
            if length(DirFile)>=1 % YAN Chao-Gan, 180806. In case some dynamic indices didn't calculate
                ALFF = [DataDir,filesep,DirFile(1).name,filesep,'ALFF_',Cfg.SubjectID{iSub},'.func.gii'];
            else
                ALFF = [];
            end
            DirFile=dir([DataDir,filesep,'fALFF_*']);
            if length(DirFile)>=1
                fALFF = [DataDir,filesep,DirFile(1).name,filesep,'fALFF_',Cfg.SubjectID{iSub},'.func.gii'];
            else
                fALFF = [];
            end
            DirFile=dir([DataDir,filesep,'ReHo*']);
            if length(DirFile)>=1
                ReHo = [DataDir,filesep,DirFile(1).name,filesep,'ReHo_',Cfg.SubjectID{iSub},'.func.gii'];
            else
                ReHo = [];
            end
            DirFile=dir([DataDir,filesep,'DegreeCentrality_*']);
            if length(DirFile)>=1
                DC = [DataDir,filesep,DirFile(1).name,filesep,'DegreeCentrality_Bilateral_PositiveWeightedSumBrain_',Cfg.SubjectID{iSub},'.func.gii'];
            else
                DC = [];
            end
            DirFile=dir([DataDir,filesep,'GSCorr_*']);
            if length(DirFile)>=1
                GSCorr = [DataDir,filesep,DirFile(1).name,filesep,'zGSCorr_',Cfg.SubjectID{iSub},'.func.gii'];
            else
                GSCorr = [];
            end
            RaterImages_LH = y_Call_Eval_ConcordanceMeasuresSelected(Cfg.ConcordanceMeasuresSelected,ALFF,fALFF,ReHo,DC,GSCorr);  
            
            % Right Hemi Files
            DataDir=[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D'];
            DirFile=dir([DataDir,filesep,'ALFF_*']);
            if length(DirFile)>=1 % YAN Chao-Gan, 180806. In case some dynamic indices didn't calculate
                ALFF = [DataDir,filesep,DirFile(1).name,filesep,'ALFF_',Cfg.SubjectID{iSub},'.func.gii'];
            else
                ALFF = [];
            end
            DirFile=dir([DataDir,filesep,'fALFF_*']);
            if length(DirFile)>=1
                fALFF = [DataDir,filesep,DirFile(1).name,filesep,'fALFF_',Cfg.SubjectID{iSub},'.func.gii'];
            else
                fALFF = [];
            end
            DirFile=dir([DataDir,filesep,'ReHo*']);
            if length(DirFile)>=1
                ReHo = [DataDir,filesep,DirFile(1).name,filesep,'ReHo_',Cfg.SubjectID{iSub},'.func.gii'];
            else
                ReHo = [];
            end
            DirFile=dir([DataDir,filesep,'DegreeCentrality_*']);
            if length(DirFile)>=1
                DC = [DataDir,filesep,DirFile(1).name,filesep,'DegreeCentrality_Bilateral_PositiveWeightedSumBrain_',Cfg.SubjectID{iSub},'.func.gii'];
            else
                DC = [];
            end
            DirFile=dir([DataDir,filesep,'GSCorr_*']);
            if length(DirFile)>=1
                GSCorr = [DataDir,filesep,DirFile(1).name,filesep,'zGSCorr_',Cfg.SubjectID{iSub},'.func.gii'];
            else
                GSCorr = [];
            end
            RaterImages_RH = y_Call_Eval_ConcordanceMeasuresSelected(Cfg.ConcordanceMeasuresSelected,ALFF,fALFF,ReHo,DC,GSCorr);  
            
            %Calculate Hemi Concordance
            OutFile = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'Concordance_VolumeWise',filesep,'Concordance_VolumeWise',Cfg.SubjectID{iSub},'.mat'];
            [KendallW] = y_KendallW_AcrossImages_Surf(RaterImages_LH, RaterImages_RH, Cfg.MaskFileSurfLH, Cfg.MaskFileSurfRH, OutFile);
            copyfile(OutFile,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'Concordance_VolumeWise',filesep,'Concordance_VolumeWise',Cfg.SubjectID{iSub},'.mat']);

            % Volume
            if (Cfg.IsProcessVolumeSpace==1)
                DataDir=[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D'];
                DirFile=dir([DataDir,filesep,'ALFF_*']);
                if length(DirFile)>=1 % YAN Chao-Gan, 180806. In case some dynamic indices didn't calculate
                    ALFF = [DataDir,filesep,DirFile(1).name,filesep,'ALFF_',Cfg.SubjectID{iSub},'.nii'];
                else
                    ALFF = [];
                end
                DirFile=dir([DataDir,filesep,'fALFF_*']);
                if length(DirFile)>=1
                    fALFF = [DataDir,filesep,DirFile(1).name,filesep,'fALFF_',Cfg.SubjectID{iSub},'.nii'];
                else
                    fALFF = [];
                end
                DirFile=dir([DataDir,filesep,'ReHo*']);
                if length(DirFile)>=1
                    ReHo = [DataDir,filesep,DirFile(1).name,filesep,'ReHo_',Cfg.SubjectID{iSub},'.nii'];
                else
                    ReHo = [];
                end
                DirFile=dir([DataDir,filesep,'DegreeCentrality_*']);
                if length(DirFile)>=1
                    DC = [DataDir,filesep,DirFile(1).name,filesep,'DegreeCentrality_Bilateral_PositiveWeightedSumBrain_',Cfg.SubjectID{iSub},'.nii'];
                else
                    DC = [];
                end
                DirFile=dir([DataDir,filesep,'GSCorr_*']);
                if length(DirFile)>=1
                    GSCorr = [DataDir,filesep,DirFile(1).name,filesep,'zGSCorr_',Cfg.SubjectID{iSub},'.nii'];
                else
                    GSCorr = [];
                end
                RaterImages = y_Call_Eval_ConcordanceMeasuresSelected(Cfg.ConcordanceMeasuresSelected,ALFF,fALFF,ReHo,DC,GSCorr);
                OutFile = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'Concordance_VolumeWise',filesep,'Concordance_VolumeWise',Cfg.SubjectID{iSub}];
                KendallW = y_KendallW_AcrossImages(RaterImages, Cfg.MaskFileVolu, OutFile);
            end
        end
    end
end

%Smooth Concordance
if (Cfg.IsSmoothConcordance==1)
    Cfg.StartingDirName = 'Results';
    
    if ispc
        CommandInit=sprintf('docker run -i --rm -v %s:/opt/freesurfer/license.txt -v %s:/data -e SUBJECTS_DIR=/data/freesurfer cgyan/dpabi', fullfile(DPABIPath, 'DPABISurf', 'FreeSurferLicense', 'license.txt'), Cfg.WorkingDir); %YAN Chao-Gan, 181214. Remove -t because there is a tty issue in windows
    else
        CommandInit=sprintf('docker run -ti --rm -v %s:/opt/freesurfer/license.txt -v %s:/data -e SUBJECTS_DIR=/data/freesurfer cgyan/dpabi', fullfile(DPABIPath, 'DPABISurf', 'FreeSurferLicense', 'license.txt'), Cfg.WorkingDir);
    end
    if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
        CommandInit=sprintf('export SUBJECTS_DIR=%s/freesurfer && ', Cfg.WorkingDir);
    end
    
    SpaceName='fsaverage5';
    
    for iSub=1:length(Cfg.SubjectID)
        for iFunSession=1:Cfg.FunctionalSessionNumber
            %OutFile = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'Concordance_VertexWise',filesep,'Concordance_VertexWise_',Cfg.SubjectID{iSub},'.func.gii'];
            Command = sprintf('%s mri_surf2surf --s %s --hemi lh --sval /data/%s/FunSurfLH/TemporalDynamics/Concordance_VertexWise/Concordance_VertexWise_%s.func.gii --fwhm %g --cortex --tval /data/%s/FunSurfLH/TemporalDynamics/Concordance_VertexWise/sConcordance_VertexWise_%s.func.gii', ...
                CommandInit, SpaceName, [FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{iSub}, Cfg.SmoothConcordance.FWHMSurf, [FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{iSub});
            system(Command);
            
            Command = sprintf('%s mri_surf2surf --s %s --hemi rh --sval /data/%s/FunSurfRH/TemporalDynamics/Concordance_VertexWise/Concordance_VertexWise_%s.func.gii --fwhm %g --cortex --tval /data/%s/FunSurfRH/TemporalDynamics/Concordance_VertexWise/sConcordance_VertexWise_%s.func.gii', ...
                CommandInit, SpaceName, [FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{iSub}, Cfg.SmoothConcordance.FWHMSurf, [FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{iSub});
            system(Command);
        end
    end
    
    % Volume
    if (Cfg.IsProcessVolumeSpace==1)
        for iSub=1:length(Cfg.SubjectID)
            FileList=[];
            for iFunSession=1:Cfg.FunctionalSessionNumber
                FileList=[FileList;{[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'Concordance_VoxelWise',filesep,'Concordance_VoxelWise_',Cfg.SubjectID{iSub},'.nii']}];
            end
            
            SPMJOB = load([DPABIPath, filesep, 'DPARSF',filesep,'Jobmats',filesep,'Smooth.mat']);
            SPMJOB.matlabbatch{1,1}.spm.spatial.smooth.data = FileList;
            SPMJOB.matlabbatch{1,1}.spm.spatial.smooth.fwhm = Cfg.SmoothConcordance.FWHMVolu;
            spm_jobman('run',SPMJOB.matlabbatch);
        end
    end
end


%Delete Dynamic 4D Files to save disk space
if (Cfg.IsDelete4D==1)
    for iFunSession=1:Cfg.FunctionalSessionNumber
        rmdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D'],'s');
        rmdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D'],'s');
        rmdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'TemporalDynamics',filesep,'TemporalDynamics4D'],'s');
    end
end




function RaterImages = y_Call_Eval_ConcordanceMeasuresSelected(ConcordanceMeasuresSelected,ALFF,fALFF,ReHo,DC,GSCorr)
eval(['RaterImages={',ConcordanceMeasuresSelected,'};'])




