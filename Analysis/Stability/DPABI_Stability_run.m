function DPABI_Stability_run(Cfg)
% FORMAT DPABI_Stability_run(Cfg)
% Perform Stability Analysis. Based on Li, L., Lu, B., Yan, C.G., 2019. Stability of dynamic functional architecture differs between brain networks and states. Neuroimage, 116230.
%
% Input:
%   Cfg - the parameters for stability analysis.
% Output:
%   The processed results that you want.
%___________________________________________________________________________
% Written by YAN Chao-Gan 200225. Based on Li, L., Lu, B., Yan, C.G., 2019. Stability of dynamic functional architecture differs between brain networks and states. Neuroimage, 116230.
% The R-fMRI Lab, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% International Big-Data Center for Depression Research, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
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


if Cfg.IsForDPABISurf %For suface-based analysis
    Cfg.StartingDirName_Volume = ['FunVolu',Cfg.StartingDirName(8:end)];
    for iFunSession=1:Cfg.FunctionalSessionNumber
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'Stability_',Cfg.StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'Stability_',Cfg.StartingDirName]);
        parfor i=1:Cfg.SubjectNum
            DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*fsaverage5_hemi-L*.func.gii'));
            FileName_LH=fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},DirName(1).name);
            DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*fsaverage5_hemi-R*.func.gii'));
            FileName_RH=fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},DirName(1).name);
            InFile_Volume = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i}];
            
            OutputName_LH=[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'Stability_',Cfg.StartingDirName,filesep,'Stability_',Cfg.SubjectID{i},'.func.gii'];
            OutputName_RH=[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'Stability_',Cfg.StartingDirName,filesep,'Stability_',Cfg.SubjectID{i},'.func.gii'];
            
            %[StabilityBrain_LH, StabilityBrain_RH, GHeader_LH, GHeader_RH] = y_Stability_Surf_Window(WindowSize, WindowStep, WindowType, InFile_LH, InFile_RH, InFile_Volume, ROIDef, OutputName_LH, OutputName_RH, AMaskFilename_LH, AMaskFilename_RH, IsMultipleLabel, IsNeedDetrend, CUTNUMBER)
            y_Stability_Surf_Window(Cfg.WindowSize, Cfg.WindowStep, Cfg.WindowType, FileName_LH, FileName_RH, ...
                InFile_Volume, Cfg.ROIDef, OutputName_LH, OutputName_RH, Cfg.MaskFileSurfLH, Cfg.MaskFileSurfRH, Cfg.IsMultipleLabel, Cfg.IsDetrend);
            y_ZStandardization_Bilateral_Surf(OutputName_LH, OutputName_RH, [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'Stability_',Cfg.StartingDirName,filesep,'zStability_',Cfg.SubjectID{i},'.func.gii'], [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'Stability_',Cfg.StartingDirName,filesep,'zStability_',Cfg.SubjectID{i},'.func.gii'], Cfg.MaskFileSurfLH, Cfg.MaskFileSurfRH);
        end
    end

    %Smooth Concordance
    if (Cfg.IsSmoothStability==1)
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
                Command = sprintf('%s mri_surf2surf --s %s --hemi lh --sval /data/%s/FunSurfLH/Stability_%s/Stability_%s.func.gii --fwhm %g --cortex --tval /data/%s/FunSurfLH/Stability_%s/sStability_%s.func.gii', ...
                    CommandInit, SpaceName, [FunSessionPrefixSet{iFunSession},'Results'],Cfg.StartingDirName,Cfg.SubjectID{iSub}, Cfg.SmoothStability.FWHM, [FunSessionPrefixSet{iFunSession},'Results'],Cfg.StartingDirName,Cfg.SubjectID{iSub});
                system(Command);
                
                Command = sprintf('%s mri_surf2surf --s %s --hemi rh --sval /data/%s/FunSurfRH/Stability_%s/Stability_%s.func.gii --fwhm %g --cortex --tval /data/%s/FunSurfRH/Stability_%s/sStability_%s.func.gii', ...
                    CommandInit, SpaceName, [FunSessionPrefixSet{iFunSession},'Results'],Cfg.StartingDirName,Cfg.SubjectID{iSub}, Cfg.SmoothStability.FWHM, [FunSessionPrefixSet{iFunSession},'Results'],Cfg.StartingDirName,Cfg.SubjectID{iSub});
                system(Command);
                
                Command = sprintf('%s mri_surf2surf --s %s --hemi lh --sval /data/%s/FunSurfLH/Stability_%s/zStability_%s.func.gii --fwhm %g --cortex --tval /data/%s/FunSurfLH/Stability_%s/szStability_%s.func.gii', ...
                    CommandInit, SpaceName, [FunSessionPrefixSet{iFunSession},'Results'],Cfg.StartingDirName,Cfg.SubjectID{iSub}, Cfg.SmoothStability.FWHM, [FunSessionPrefixSet{iFunSession},'Results'],Cfg.StartingDirName,Cfg.SubjectID{iSub});
                system(Command);
                
                Command = sprintf('%s mri_surf2surf --s %s --hemi rh --sval /data/%s/FunSurfRH/Stability_%s/zStability_%s.func.gii --fwhm %g --cortex --tval /data/%s/FunSurfRH/Stability_%s/szStability_%s.func.gii', ...
                    CommandInit, SpaceName, [FunSessionPrefixSet{iFunSession},'Results'],Cfg.StartingDirName,Cfg.SubjectID{iSub}, Cfg.SmoothStability.FWHM, [FunSessionPrefixSet{iFunSession},'Results'],Cfg.StartingDirName,Cfg.SubjectID{iSub});
                system(Command);
                
            end
        end
        
    end
    
    
    
else %For Volume space
    
    BrainMaskData=y_ReadAll(Cfg.MaskFileVolu);
    for iFunSession=1:Cfg.FunctionalSessionNumber
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'Stability_',Cfg.StartingDirName]);
        parfor iSub=1:length(Cfg.SubjectID)
            InFiles = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,Cfg.SubjectID{iSub}];
            OutFile = [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'Stability_',Cfg.StartingDirName,filesep,'Stability_',Cfg.SubjectID{iSub},'.nii'];
            
            %[StabilityBrain, Header] = y_Stability_Window(WindowSize, WindowStep, WindowType, AllVolume, ROIDef, OutputName, MaskData, IsMultipleLabel, IsNeedDetrend, Header, CUTNUMBER)
            [StabilityBrain, Header] = y_Stability_Window(Cfg.WindowSize, Cfg.WindowStep, Cfg.WindowType, InFiles, Cfg.ROIDef, OutFile, Cfg.MaskFileVolu, Cfg.IsMultipleLabel, Cfg.IsDetrend);
            
            Temp = ((StabilityBrain - mean(StabilityBrain(find(BrainMaskData)))) ./ std(StabilityBrain(find(BrainMaskData)))) .* (BrainMaskData~=0);
            y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'Stability_',Cfg.StartingDirName,filesep,'zStability_',Cfg.SubjectID{iSub},'.nii']);
        end
    end
    
    %Smooth Stability
    if (Cfg.IsSmoothStability==1)
        parfor iSub=1:length(Cfg.SubjectID)
            FileList=[];
            for iFunSession=1:Cfg.FunctionalSessionNumber
                FileList=[FileList;{[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'Stability_',Cfg.StartingDirName,filesep,'Stability_',Cfg.SubjectID{iSub},'.nii']}];
                FileList=[FileList;{[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'Stability_',Cfg.StartingDirName,filesep,'zStability_',Cfg.SubjectID{iSub},'.nii']}];
            end
            
            SPMJOB = load([DPABIPath, filesep, 'DPARSF',filesep,'Jobmats',filesep,'Smooth.mat']);
            SPMJOB.matlabbatch{1,1}.spm.spatial.smooth.data = FileList;
            SPMJOB.matlabbatch{1,1}.spm.spatial.smooth.fwhm = Cfg.SmoothStability.FWHM;
            spm_jobman('run',SPMJOB.matlabbatch);
        end
    end
end


fprintf(['\nCongratulations, the running of Stability Analysis is done!!! :)\n\n']);

