function [Error, AutoDataProcessParameter]=DPARSFA_run(AutoDataProcessParameter,WorkingDir,SubjectListFile,IsAllowGUI)
% FORMAT [Error, AutoDataProcessParameter]=DPARSFA_run(AutoDataProcessParameter,WorkingDir,SubjectListFile,IsAllowGUI)
% Input:
%   AutoDataProcessParameter - the parameters for auto data processing. Read http://rfmri.org/content/configurations-dparsfarun to learn how to define it.
%   WorkingDir - Define the working directory to replace the one defined in AutoDataProcessParameter
%   SubjectListFile - Define the subject list to replace the one defined in AutoDataProcessParameter. Should be a text file
%   IsAllowGUI - Set to 0 if you are running on a remote cluster without GUI. Interactively Reorienting will be skipped and pictures for checking normalization will not be generated.
% Output:
%   The processed data that you want.
%___________________________________________________________________________
% Written by YAN Chao-Gan 090306.
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962; Child Mind Institute, 445 Park Avenue, New York, NY 10022; The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016
% ycg.yan@gmail.com
% Modified by YAN Chao-Gan 090712, added the function of mReHo - 1, mALFF - 1, mfALFF -1.
% Modified by YAN Chao-Gan 090901, added the function of smReHo, remove variable first time points.
% Modified by YAN Chao-Gan, 090925, SPM8 compatible.
% Modified by YAN Chao-Gan 091001, Generate the pictures for checking normalization.
% Modified by YAN Chao-Gan 091111. 1. Use different Affine Regularisation in Segmentation: East Asian brains (eastern) or European brains (mni). 2. Added a checkbox for removing first time points. 3.Added popup menu to delete selected subject by right click. 4. Close wait bar when program finished.
% Modified by YAN Chao-Gan 091212. Also can regress out other covariates.
% Modified by YAN Chao-Gan 100201. Fixed the bug in converting DICOM files to NIfTI files when DPARSF stored under C:\Program Files\Matlab\Toolbox.
% Modified by YAN Chao-Gan, 100420. Release the memory occupied by "hdr" after converting one participant's Functional DICOM files to NIFTI images in linux. Make compatible with missing parameters. Fixed a bug in generating the pictures for checking normalizationdisplaying when overlay with different bounding box from those of underlay in according to rest_sliceviewer.m.
% Modified by YAN Chao-Gan, 100510. Fixed a bug in converting DICOM files to NIfTI in Windows 7, thanks to Prof. Chris Rorden's new dcm2nii. Now will detect if co* T1 image is exist before normalization by using T1 image unified segmentation.
% Modified by YAN Chao-Gan, 101025. Changed for Data Processing Assistant for Resting-State fMRI (DPARSF) Advanced Edition (alias: DPARSFA).
% Modified by YAN Chao-Gan, 120101. DARTEL, multiplse sessions, reorient, .nii.gz files and so on added.
% Modified by YAN Chao-Gan, 120905. DPARSF V2.2 PRE.
% Modified by YAN Chao-Gan, 121225. DPARSF V2.2.
% Modified by YAN Chao-Gan, 130303. DPARSF V2.2, minor revision.
% Modified by YAN Chao-Gan, 130615. DPARSF V2.3.
% Modified by YAN Chao-Gan, 161006. For compiling.
% Modified by YAN Chao-Gan, 191121. Calling dcm2niix for BIDS format. Change searching c* to *Crop*


if ischar(AutoDataProcessParameter)  %If inputed a .mat file name. (Cfg inside)
    load(AutoDataProcessParameter);
    AutoDataProcessParameter=Cfg;
end

if exist('WorkingDir','var') && ~isempty(WorkingDir)
    AutoDataProcessParameter.DataProcessDir=WorkingDir;
    AutoDataProcessParameter.WorkingDir=WorkingDir;
end

if exist('SubjectListFile','var') && ~isempty(SubjectListFile)
    fid = fopen(SubjectListFile);
    IDCell = textscan(fid,'%s\n'); %YAN Chao-Gan. For compatiblity of MALLAB 2014b. IDCell = textscan(fid,'%s','\n');
    fclose(fid);
    AutoDataProcessParameter.SubjectID=IDCell{1};
end

if exist('IsAllowGUI','var') && ~isempty(IsAllowGUI)
    if isdeployed
        IsAllowGUI=str2num(IsAllowGUI);
    end
    AutoDataProcessParameter.IsAllowGUI=IsAllowGUI;
end


AutoDataProcessParameter.SubjectNum=length(AutoDataProcessParameter.SubjectID);
Error=[];

[DPABIPath, fileN, extn] = fileparts(which('DPABI.m'));
ProgramPath=fullfile(DPABIPath, 'DPARSF');
addpath([ProgramPath,filesep,'Subfunctions']);
TemplatePath=fullfile(DPABIPath, 'Templates');

%[SPMPath, fileN, extn] = fileparts(which('spm.m'));
SPMFilePath=fullfile(DPABIPath, 'Templates','SPMTemplates'); %YAN Chao-Gan, 161006. Move the necessary files to DPABI. After compiling, this should be usable.

if isdeployed %YAN Chao-Gan, 161006. For Compiler.
    SPMversion=12;
else
    [SPMversionText,c]=spm('Ver');
    SPMversion=str2double(SPMversionText(end-1:end));
    if isnan(SPMversion)
        SPMversion=str2double(SPMversionText(end));
    end
end


%Make compatible with missing parameters. YAN Chao-Gan, 100420.
if ~isfield(AutoDataProcessParameter,'DataProcessDir')
    AutoDataProcessParameter.DataProcessDir=AutoDataProcessParameter.WorkingDir;
end
% if isfield(AutoDataProcessParameter,'TR')
%     AutoDataProcessParameter.SliceTiming.TR=AutoDataProcessParameter.TR;
%     AutoDataProcessParameter.SliceTiming.TA=AutoDataProcessParameter.SliceTiming.TR-(AutoDataProcessParameter.SliceTiming.TR/AutoDataProcessParameter.SliceTiming.SliceNumber);
%     AutoDataProcessParameter.Filter.ASamplePeriod=AutoDataProcessParameter.TR;
%     AutoDataProcessParameter.CalALFF.ASamplePeriod=AutoDataProcessParameter.TR;
%     AutoDataProcessParameter.CalfALFF.ASamplePeriod=AutoDataProcessParameter.TR;
% end
if ~isfield(AutoDataProcessParameter,'FunctionalSessionNumber')
    AutoDataProcessParameter.FunctionalSessionNumber=1; 
end
if ~isfield(AutoDataProcessParameter,'IsNeedConvertFunDCM2IMG')
    AutoDataProcessParameter.IsNeedConvertFunDCM2IMG=0; 
end
if ~isfield(AutoDataProcessParameter,'IsNeedConvertT1DCM2IMG')
    AutoDataProcessParameter.IsNeedConvertT1DCM2IMG=0; 
end

if ~isfield(AutoDataProcessParameter,'IsBIDStoDPARSF')
    AutoDataProcessParameter.IsBIDStoDPARSF=0;
elseif AutoDataProcessParameter.IsBIDStoDPARSF==1
    UseNoCoT1Image=1; %Prevent the dialog asking confirm use no co t1 images.
end


if ~isfield(AutoDataProcessParameter,'IsApplyDownloadedReorientMats')
    AutoDataProcessParameter.IsApplyDownloadedReorientMats=0;
end
% if ~isfield(AutoDataProcessParameter,'IsNeedConvert4DFunInto3DImg')
%     AutoDataProcessParameter.IsNeedConvert4DFunInto3DImg=0; 
% end
if ~isfield(AutoDataProcessParameter,'RemoveFirstTimePoints')
    AutoDataProcessParameter.RemoveFirstTimePoints=0; 
end
if ~isfield(AutoDataProcessParameter,'IsSliceTiming')
    AutoDataProcessParameter.IsSliceTiming=0; 
end
if ~isfield(AutoDataProcessParameter,'IsRealign')
    AutoDataProcessParameter.IsRealign=0; 
end
if ~isfield(AutoDataProcessParameter,'IsCalVoxelSpecificHeadMotion')
    AutoDataProcessParameter.IsCalVoxelSpecificHeadMotion=0; 
end
if ~isfield(AutoDataProcessParameter,'IsNeedReorientFunImgInteractively')
    AutoDataProcessParameter.IsNeedReorientFunImgInteractively=0; 
end

% if ~isfield(AutoDataProcessParameter,'IsNeedUnzipT1IntoT1Img')
%     AutoDataProcessParameter.IsNeedUnzipT1IntoT1Img=0; 
% end
if ~isfield(AutoDataProcessParameter,'IsNeedReorientCropT1Img')
    AutoDataProcessParameter.IsNeedReorientCropT1Img=0; 
end
if ~isfield(AutoDataProcessParameter,'IsNeedReorientT1ImgInteractively')
    AutoDataProcessParameter.IsNeedReorientT1ImgInteractively=0; 
end
if ~isfield(AutoDataProcessParameter,'IsBet')  %130801
    AutoDataProcessParameter.IsBet=0; 
end
if ~isfield(AutoDataProcessParameter,'IsAutoMask')  %130801
    AutoDataProcessParameter.IsAutoMask=0; 
end
if ~isfield(AutoDataProcessParameter,'IsNeedT1CoregisterToFun')
    AutoDataProcessParameter.IsNeedT1CoregisterToFun=0; 
end
if ~isfield(AutoDataProcessParameter,'IsNeedReorientInteractivelyAfterCoreg')
    AutoDataProcessParameter.IsNeedReorientInteractivelyAfterCoreg=0; 
end
if ~isfield(AutoDataProcessParameter,'IsSegment')  %1: Segment; 2: New Segment
    AutoDataProcessParameter.IsSegment=0; 
end
if ~isfield(AutoDataProcessParameter,'IsDARTEL')
    AutoDataProcessParameter.IsDARTEL=0; 
end
if ~isfield(AutoDataProcessParameter,'IsCovremove')
    AutoDataProcessParameter.IsCovremove=0; 
end
if ~isfield(AutoDataProcessParameter,'IsFilter')
    AutoDataProcessParameter.IsFilter=0; 
end
if ~isfield(AutoDataProcessParameter,'IsNormalize')  %1: Normalization by using the EPI template directly; 2: Normalization by using the T1 image segment information (T1 images stored in 'DataProcessDir\T1Img' and initiated with 'co*'); 3: Normalized by DARTEL
    AutoDataProcessParameter.IsNormalize=0; 
end
% if ~isfield(AutoDataProcessParameter,'IsDelFilesBeforeNormalize')
%     AutoDataProcessParameter.IsDelFilesBeforeNormalize=0; 
% end
if ~isfield(AutoDataProcessParameter,'IsSmooth')  %1: Smooth module in SPM; 2: Smooth by DARTEL
    AutoDataProcessParameter.IsSmooth=0; 
end
if ~isfield(AutoDataProcessParameter,'MaskFile')
    AutoDataProcessParameter.MaskFile ='Default';
end
if ~isfield(AutoDataProcessParameter,'IsWarpMasksIntoIndividualSpace')
    AutoDataProcessParameter.IsWarpMasksIntoIndividualSpace=0; 
end
if ~isfield(AutoDataProcessParameter,'IsDetrend')
    AutoDataProcessParameter.IsDetrend=0; 
end
% if ~isfield(AutoDataProcessParameter,'IsDelDetrendedFiles')
%     AutoDataProcessParameter.IsDelDetrendedFiles=0; 
% end
if ~isfield(AutoDataProcessParameter,'IsCalALFF')
    AutoDataProcessParameter.IsCalALFF=0; 
end
% if ~isfield(AutoDataProcessParameter,'IsCalfALFF')
%     AutoDataProcessParameter.IsCalfALFF=0; 
% end
if ~isfield(AutoDataProcessParameter,'IsScrubbing')
    AutoDataProcessParameter.IsScrubbing=0;
end
if ~isfield(AutoDataProcessParameter,'IsCalReHo')
    AutoDataProcessParameter.IsCalReHo=0;
else
    if isfield(AutoDataProcessParameter,'CalReHo') && (~isfield(AutoDataProcessParameter.CalReHo,'SmoothReHo')) %YAN Chao-Gan, 121227.
        AutoDataProcessParameter.CalReHo.SmoothReHo=0;
    end
end

if ~isfield(AutoDataProcessParameter,'IsCalDegreeCentrality')
    AutoDataProcessParameter.IsCalDegreeCentrality=0; 
end
if ~isfield(AutoDataProcessParameter,'IsCalFC')
    AutoDataProcessParameter.IsCalFC=0; 
end
if ~isfield(AutoDataProcessParameter,'CalFC')
    AutoDataProcessParameter.CalFC.ROIDef = {};
else
    if ~isfield(AutoDataProcessParameter.CalFC,'ROIDef')
        AutoDataProcessParameter.CalFC.ROIDef = {};
    end
    if ~isfield(AutoDataProcessParameter.CalFC,'ROISelectedIndex')
        AutoDataProcessParameter.CalFC.ROISelectedIndex = [];
    end
end
if ~isfield(AutoDataProcessParameter,'IsExtractROISignals')
    AutoDataProcessParameter.IsExtractROISignals=0; 
end
if ~isfield(AutoDataProcessParameter,'IsDefineROIInteractively')
    AutoDataProcessParameter.IsDefineROIInteractively=0; 
end
if ~isfield(AutoDataProcessParameter,'IsExtractAALTC')
    AutoDataProcessParameter.IsExtractAALTC=0; 
end
if ~isfield(AutoDataProcessParameter,'IsNormalizeToSymmetricGroupT1Mean') %YAN Chao-Gan 121221.
    AutoDataProcessParameter.IsNormalizeToSymmetricGroupT1Mean=0; 
end
if ~isfield(AutoDataProcessParameter,'IsSmoothBeforeVMHC') %YAN Chao-Gan 151119.
    AutoDataProcessParameter.IsSmoothBeforeVMHC=0; 
end
if ~isfield(AutoDataProcessParameter,'IsCalVMHC')
    AutoDataProcessParameter.IsCalVMHC=0; 
end
if ~isfield(AutoDataProcessParameter,'IsCWAS')
    AutoDataProcessParameter.IsCWAS=0; 
end
if ~isfield(AutoDataProcessParameter,'IsAllowGUI')
    AutoDataProcessParameter.IsAllowGUI=1; 
end






% Multiple Sessions Processing 
% YAN Chao-Gan, 111215 added.
FunSessionPrefixSet={''}; %The first session doesn't need a prefix. From the second session, need a prefix such as 'S2_';
for iFunSession=2:AutoDataProcessParameter.FunctionalSessionNumber
    FunSessionPrefixSet=[FunSessionPrefixSet;{['S',num2str(iFunSession),'_']}];
end


%Convert Functional DICOM files to NIFTI images
if (AutoDataProcessParameter.IsNeedConvertFunDCM2IMG==1)
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunRaw']);
        for i=1:AutoDataProcessParameter.SubjectNum
            OutputDir=[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunImg',filesep,AutoDataProcessParameter.SubjectID{i}];
            mkdir(OutputDir);
            DirDCM=dir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunRaw',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*']); %Revised by YAN Chao-Gan 100130. %DirDCM=dir([AutoDataProcessParameter.DataProcessDir,filesep,'FunRaw',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.*']);
            if strcmpi(DirDCM(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
                StartIndex=4;
            else
                StartIndex=3;
            end
            InputFilename=[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunRaw',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirDCM(StartIndex).name];

            %YAN Chao-Gan 120817.
            y_Call_dcm2nii(InputFilename, OutputDir, 'DefaultINI');

            fprintf(['Converting Functional Images:',AutoDataProcessParameter.SubjectID{i},' OK']);
        end
        fprintf('\n');
    end
    AutoDataProcessParameter.StartingDirName='FunImg';   %Now start with FunImg directory. 101010
end


%Convert T1 DICOM files to NIFTI images
if (AutoDataProcessParameter.IsNeedConvertT1DCM2IMG==1)
    cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1Raw']);
    for i=1:AutoDataProcessParameter.SubjectNum
        OutputDir=[AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i}];
        mkdir(OutputDir);
        DirDCM=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Raw',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*']); %Revised by YAN Chao-Gan 100130. %DirDCM=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Raw',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.*']);
        if strcmpi(DirDCM(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
            StartIndex=4;
        else
            StartIndex=3;
        end
        InputFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'T1Raw',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirDCM(StartIndex).name];
        
        %YAN Chao-Gan 120817.
        y_Call_dcm2nii(InputFilename, OutputDir, 'DefaultINI');
        
        fprintf(['Converting T1 Images:',AutoDataProcessParameter.SubjectID{i},' OK']);
    end
    fprintf('\n');
end

%Convert FieldMap DICOM files to NIFTI images. YAN Chao-Gan, 191122.
if isfield(AutoDataProcessParameter,'FieldMap')
    if (AutoDataProcessParameter.FieldMap.IsNeedConvertDCM2IMG==1)
        FieldMapMeasures={'PhaseDiff','Magnitude1','Magnitude2','Phase1','Phase2'};
        for iFieldMapMeasure=1:length(FieldMapMeasures)
            if exist([AutoDataProcessParameter.DataProcessDir,filesep,'FieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},'Raw'])
                cd([AutoDataProcessParameter.DataProcessDir,filesep,'FieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},'Raw']);
                for i=1:AutoDataProcessParameter.SubjectNum
                    OutputDir=[AutoDataProcessParameter.DataProcessDir,filesep,'FieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},'Img',filesep,AutoDataProcessParameter.SubjectID{i}];
                    mkdir(OutputDir);
                    DirDCM=dir([AutoDataProcessParameter.DataProcessDir,filesep,'FieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},'Raw',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*']); %Revised by YAN Chao-Gan 100130. %DirDCM=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Raw',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.*']);
                    if strcmpi(DirDCM(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
                        StartIndex=4;
                    else
                        StartIndex=3;
                    end
                    InputFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'FieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},'Raw',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirDCM(StartIndex).name];
                    y_Call_dcm2nii(InputFilename, OutputDir, 'DefaultINI');
                    fprintf(['Converting FieldMap ',FieldMapMeasures{iFieldMapMeasure},' Images:',AutoDataProcessParameter.SubjectID{i},' OK']);
                end
                fprintf('\n');
            end
        end
    end
end


%YAN Chao-Gan, 200214. BIDS compatible.
if (AutoDataProcessParameter.IsBIDStoDPARSF==1)
    y_Convert_BIDS2DPARSF([AutoDataProcessParameter.DataProcessDir,filesep,'BIDS'],AutoDataProcessParameter.DataProcessDir,AutoDataProcessParameter.SubjectID);
    AutoDataProcessParameter.StartingDirName='FunImg';   %Now start with FunImg directory.
end


%Reorient and Crop T1Img by using Chris Rorden's dcm2nii
% YAN Chao-Gan, 111121
if (AutoDataProcessParameter.IsNeedReorientCropT1Img==1)
    cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img']);
    for i=1:AutoDataProcessParameter.SubjectNum
        OutputDir=[AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i}];
        DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii.gz']);
        if isempty(DirImg)
            DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii']);
        end
        if isempty(DirImg)
            DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.img']);
        end
        
        InputFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name];
        
        %YAN Chao-Gan 120817.
        y_Call_dcm2nii(InputFilename, OutputDir, '-g N -m N -n Y -r Y -v N -x Y');
        
        fprintf(['Reorienting and Cropping Images:',AutoDataProcessParameter.SubjectID{i},' OK']);
    end
    fprintf('\n');
end



%Apply Downloaded Reorient Mats      -- YAN Chao-Gan, 130615.
%The downloaded reorient mats (*_ReorientFunImgMat.mat and *_ReorientT1ImgMat.mat) should be put in DownloadedReorientMats folder under the working directory!
if (AutoDataProcessParameter.IsApplyDownloadedReorientMats==1)
    % Apply downloaded Reorient Mats to functional images
    parfor i=1:AutoDataProcessParameter.SubjectNum
        ReorientMat=eye(4);
        if exist([AutoDataProcessParameter.DataProcessDir,filesep,'DownloadedReorientMats'],'dir')==7
            if exist([AutoDataProcessParameter.DataProcessDir,filesep,'DownloadedReorientMats',filesep,AutoDataProcessParameter.SubjectID{i},'_ReorientFunImgMat.mat'],'file')==2
                ReorientMat_Interactively = load([AutoDataProcessParameter.DataProcessDir,filesep,'DownloadedReorientMats',filesep,AutoDataProcessParameter.SubjectID{i},'_ReorientFunImgMat.mat']);
                ReorientMat=ReorientMat_Interactively.mat*ReorientMat;
            end
        end
        
        if ~all(all(ReorientMat==eye(4)))
            for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                %Apply to the functional images
                cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
                DirImg=dir('*.img');
                if isempty(DirImg)  %YAN Chao-Gan, 111114. Also support .nii files.
                    DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                    if length(DirImg)==1
                        gunzip(DirImg(1).name);
                        delete(DirImg(1).name);
                    end
                    DirImg=dir('*.nii');
                end
                
                for j=1:length(DirImg)
                    OldMat = spm_get_space(DirImg(j).name);
                    spm_get_space(DirImg(j).name,ReorientMat*OldMat);
                end
                if length(DirImg)==1 % delete the .mat file generated by spm_get_space for 4D nii images
                    if exist([DirImg(j).name(1:end-4),'.mat'],'file')==2
                        delete([DirImg(j).name(1:end-4),'.mat']);
                    end
                end
            end
        end
        fprintf('Apply Downloaded Reorient Mats to functional images for %s: OK\n',AutoDataProcessParameter.SubjectID{i});
    end
    

    % Apply downloaded Reorient Mats to T1 images
    % First check which kind of T1 image need to be applied
    if ~exist('UseNoCoT1Image','var')
        cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{1}]);
        DirCo=dir('c*.img');
        if isempty(DirCo)
            DirCo=dir('c*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
            if length(DirCo)==1
                gunzip(DirCo(1).name);
                delete(DirCo(1).name);
            end
            DirCo=dir('c*.nii');  %YAN Chao-Gan, 111114. Also support .nii files.
            if isempty(DirCo)
                DirCo=dir('*Crop*.nii');  %YAN Chao-Gan, 191121. Support BIDS format.
            end
        end
        if isempty(DirCo)
            DirImg=dir('*.img');
            if isempty(DirImg)  %YAN Chao-Gan, 111114. Also support .nii files.
                DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirImg)>=1
                    for j=1:length(DirImg)
                        gunzip(DirImg(j).name);
                        delete(DirImg(j).name);
                    end
                end
                DirImg=dir('*.nii');
            end
            if length(DirImg)==1
                button = questdlg(['No co* T1 image (T1 image which is reoriented to the nearest orthogonal direction to ''canonical space'' and removed excess air surrounding the individual as well as parts of the neck below the cerebellum) is found. Do you want to use the T1 image without co? Such as: ',DirImg(1).name,'?'],'No co* T1 image is found','Yes','No','Yes');
                if strcmpi(button,'Yes')
                    UseNoCoT1Image=1;
                else
                    return;
                end
            elseif length(DirImg)==0
                errordlg(['No T1 image has been found.'],'No T1 image has been found');
                return;
            else
                errordlg(['No co* T1 image (T1 image which is reoriented to the nearest orthogonal direction to ''canonical space'' and removed excess air surrounding the individual as well as parts of the neck below the cerebellum) is found. And there are too many T1 images detected in T1Img directory. Please determine which T1 image you want to use and delete the others from the T1Img directory, then re-run the analysis.'],'No co* T1 image is found');
                return;
            end
        else
            UseNoCoT1Image=0;
        end
        cd('..');
    end
    
    
    %Apply Reorient Mats
    parfor i=1:AutoDataProcessParameter.SubjectNum
        ReorientMat=eye(4);
        if exist([AutoDataProcessParameter.DataProcessDir,filesep,'DownloadedReorientMats'],'dir')==7
            if exist([AutoDataProcessParameter.DataProcessDir,filesep,'DownloadedReorientMats',filesep,AutoDataProcessParameter.SubjectID{i},'_ReorientT1ImgMat.mat'],'file')==2
                ReorientMat_Interactively = load([AutoDataProcessParameter.DataProcessDir,filesep,'DownloadedReorientMats',filesep,AutoDataProcessParameter.SubjectID{i},'_ReorientT1ImgMat.mat']);
                ReorientMat=ReorientMat_Interactively.mat*ReorientMat;
            end
        end
        
        if ~all(all(ReorientMat==eye(4)))
            if UseNoCoT1Image==0
                DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'c*.img']);
                if isempty(DirT1Img)
                    DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'c*.nii.gz']);% Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                    if length(DirT1Img)==1
                        gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1Img(1).name]);
                        delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1Img(1).name]);
                    end
                    DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'c*.nii']);
                    if isempty(DirT1Img)
                        DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*Crop*.nii']); %YAN Chao-Gan, 191121. Calling dcm2niix for BIDS format. Change searching c* to *Crop*
                    end
                end
            else
                DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.img']);
                if isempty(DirT1Img)
                    DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii.gz']);% Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                    if length(DirT1Img)==1
                        gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1Img(1).name]);
                        delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1Img(1).name]);
                    end
                    DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii']);
                end
            end
            
            FileList=[AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1Img(1).name];
            
            OldMat = spm_get_space(FileList);
            spm_get_space(FileList,ReorientMat*OldMat);
            
            if exist([FileList(1:end-4),'.mat'],'file')==2
                delete([FileList(1:end-4),'.mat']);
            end

        end
        fprintf('Apply Downloaded Reorient Mats to T1 images for %s: OK\n',AutoDataProcessParameter.SubjectID{i});
        
    end
end





%****************************************************************Processing of fMRI BOLD images*****************
%Check TR and store Subject ID, TR, Slice Number, Time Points, Voxel Size into TRInfo.tsv if needed.
if isfield(AutoDataProcessParameter,'TR')
    if AutoDataProcessParameter.TR==0  % Need to retrieve the TR information from the NIfTI images
        if ~( strcmpi(AutoDataProcessParameter.StartingDirName,'T1Raw') || strcmpi(AutoDataProcessParameter.StartingDirName,'T1Img') )  %Only need for functional processing
            if (2==exist([AutoDataProcessParameter.DataProcessDir,filesep,'TRInfo.tsv'],'file'))  %If the TR information is stored in TRInfo.tsv. %YAN Chao-Gan, 130612
                
                fid = fopen([AutoDataProcessParameter.DataProcessDir,filesep,'TRInfo.tsv']);
                StringFilter = '%s';
                for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                    StringFilter = [StringFilter,'\t%f']; %Get the TRs for the sessions.
                end
                StringFilter = [StringFilter,'%*[^\n]']; %Skip the else till end of the line
                tline = fgetl(fid); %Skip the title line
                TRInfoTemp = textscan(fid,StringFilter);
                fclose(fid);

                TRSet = zeros(AutoDataProcessParameter.SubjectNum,AutoDataProcessParameter.FunctionalSessionNumber);
                for i=1:AutoDataProcessParameter.SubjectNum
                    [HasSubject SubjectIndex] = ismember(AutoDataProcessParameter.SubjectID{i},TRInfoTemp{1});
                    if HasSubject
                        for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                            TRSet(i,iFunSession) = TRInfoTemp{1+iFunSession}(SubjectIndex); %The first column is Subject ID
                        end
                    else
                        error(['The subject ID ',AutoDataProcessParameter.SubjectID{i},' was not found in TRInfo.tsv!'])
                    end
                end

            elseif (2==exist([AutoDataProcessParameter.DataProcessDir,filesep,'TRSet.txt'],'file'))  %If the TR information is stored in TRSet.txt (DPARSF V2.2).
                TRSet = load([AutoDataProcessParameter.DataProcessDir,filesep,'TRSet.txt']);
                TRSet = TRSet'; %YAN Chao-Gan 130612. This is for the compatibility with DPARSFA V2.2. Cause the TRSet saved there is in a transpose manner.
            else

                TRSet = zeros(AutoDataProcessParameter.SubjectNum,AutoDataProcessParameter.FunctionalSessionNumber);
                SliceNumber = zeros(AutoDataProcessParameter.SubjectNum,AutoDataProcessParameter.FunctionalSessionNumber);
                nTimePoints = zeros(AutoDataProcessParameter.SubjectNum,AutoDataProcessParameter.FunctionalSessionNumber);
                VoxelSize = zeros(AutoDataProcessParameter.SubjectNum,AutoDataProcessParameter.FunctionalSessionNumber,3);
                for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                    for i=1:AutoDataProcessParameter.SubjectNum
                        cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
                        DirImg=dir('*.img');
                        if isempty(DirImg)  %YAN Chao-Gan, 111114. Also support .nii files. % Either in .nii.gz or in .nii
                            DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                            if length(DirImg)==1
                                gunzip(DirImg(1).name);
                                delete(DirImg(1).name);
                            end
                            DirImg=dir('*.nii');
                        end
                        Nii  = nifti(DirImg(1).name);
                        if (~isfield(Nii.timing,'tspace'))
                            error('Can NOT retrieve the TR information from the NIfTI images');
                        end
                        TRSet(i,iFunSession) = Nii.timing.tspace;
                        
                        SliceNumber(i,iFunSession) = size(Nii.dat,3);
                        
                        if size(Nii.dat,4)==1 %Test if 3D volume
                            nTimePoints(i,iFunSession) = length(DirImg);
                        else %4D volume
                            nTimePoints(i,iFunSession) = size(Nii.dat,4);
                        end
                        
                        VoxelSize(i,iFunSession,:) = sqrt(sum(Nii.mat(1:3,1:3).^2));
                    end
                end
                %save([AutoDataProcessParameter.DataProcessDir,filesep,'TRSet.txt'], 'TRSet', '-ASCII', '-DOUBLE','-TABS'); %YAN Chao-Gan, 121214. Save the TR information.
                
                %YAN Chao-Gan, 130612. No longer save to TRSet.txt, but save to TRInfo.tsv with information of Slice Number, Time Points, Voxel Size.
                
                
                %Write the information as TRInfo.tsv
                fid = fopen([AutoDataProcessParameter.DataProcessDir,filesep,'TRInfo.tsv'],'w');
  
                fprintf(fid,'Subject ID');
                for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                    fprintf(fid,['\t',FunSessionPrefixSet{iFunSession},'TR']);
                end
                for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                    fprintf(fid,['\t',FunSessionPrefixSet{iFunSession},'Slice Number']);
                end
                for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                    fprintf(fid,['\t',FunSessionPrefixSet{iFunSession},'Time Points']);
                end
                for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                    fprintf(fid,['\t',FunSessionPrefixSet{iFunSession},'Voxel Size']);
                end
                
                fprintf(fid,'\n');
                for i=1:AutoDataProcessParameter.SubjectNum
                    fprintf(fid,'%s',AutoDataProcessParameter.SubjectID{i});
                    
                    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                        fprintf(fid,'\t%g',TRSet(i,iFunSession));
                    end
                    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                        fprintf(fid,'\t%g',SliceNumber(i,iFunSession));
                    end
                    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                        fprintf(fid,'\t%g',nTimePoints(i,iFunSession));
                    end
                    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                        fprintf(fid,'\t%g %g %g',VoxelSize(i,iFunSession,1),VoxelSize(i,iFunSession,2),VoxelSize(i,iFunSession,3));
                    end
                    fprintf(fid,'\n');
                end
                
                fclose(fid);

            end
            AutoDataProcessParameter.TRSet = TRSet;
        end
    end
end


%Remove First Time Points
if (AutoDataProcessParameter.RemoveFirstTimePoints>0)
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName]);
        parfor i=1:AutoDataProcessParameter.SubjectNum
            cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
            DirImg=dir('*.img');
            if ~isempty(DirImg)  %YAN Chao-Gan, 111114. Also support .nii files.
                if AutoDataProcessParameter.TimePoints>0 && length(DirImg)~=AutoDataProcessParameter.TimePoints % Will not check if TimePoints set to 0. YAN Chao-Gan 120806.
                    Error=[Error;{['Error in Removing First ',num2str(AutoDataProcessParameter.RemoveFirstTimePoints),'Time Points: ',AutoDataProcessParameter.SubjectID{i}]}];
                end
                for j=1:AutoDataProcessParameter.RemoveFirstTimePoints
                    delete(DirImg(j).name);
                    delete([DirImg(j).name(1:end-4),'.hdr']);
                end
            else % either in .nii.gz or in .nii
                DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirImg)==1
                    gunzip(DirImg(1).name);
                    delete(DirImg(1).name);
                end
                
                DirImg=dir('*.nii');
                
                if length(DirImg)>1  %3D .nii images.
                    if AutoDataProcessParameter.TimePoints>0 && length(DirImg)~=AutoDataProcessParameter.TimePoints % Will not check if TimePoints set to 0. YAN Chao-Gan 120806.
                        Error=[Error;{['Error in Removing First ',num2str(AutoDataProcessParameter.RemoveFirstTimePoints),'Time Points: ',AutoDataProcessParameter.SubjectID{i}]}];
                    end
                    for j=1:AutoDataProcessParameter.RemoveFirstTimePoints
                        delete(DirImg(j).name);
                    end
                else %4D .nii images
                    Nii  = nifti(DirImg(1).name);
                    if AutoDataProcessParameter.TimePoints>0 && size(Nii.dat,4)~=AutoDataProcessParameter.TimePoints % Will not check if TimePoints set to 0. YAN Chao-Gan 120806.
                        Error=[Error;{['Error in Removing First ',num2str(AutoDataProcessParameter.RemoveFirstTimePoints),'Time Points: ',AutoDataProcessParameter.SubjectID{i}]}];
                    end
                    %y_Write(Nii.dat(:,:,:,AutoDataProcessParameter.RemoveFirstTimePoints+1:end),Nii,DirImg(1).name);

                    %YAN Chao-Gan, 210309. Save in single incase of Philips data.
                    [Data Header]=y_Read(DirImg(1).name);
                    Header.pinfo=[1;0;0]; Header.dt=[16,0];
                    y_Write(Data(:,:,:,AutoDataProcessParameter.RemoveFirstTimePoints+1:end),Header,DirImg(1).name);
                end
                
            end
            cd('..');
            fprintf(['Removing First ',num2str(AutoDataProcessParameter.RemoveFirstTimePoints),' Time Points: ',AutoDataProcessParameter.SubjectID{i},' OK']);
        end
        fprintf('\n');
    end
    AutoDataProcessParameter.TimePoints=AutoDataProcessParameter.TimePoints-AutoDataProcessParameter.RemoveFirstTimePoints;
end
if ~isempty(Error)
    disp(Error);
    return;
end


%Slice Timing
if (AutoDataProcessParameter.IsSliceTiming==1)
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        
        parfor i=1:AutoDataProcessParameter.SubjectNum
            SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'SliceTiming.mat']);
            
            cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
            DirImg=dir('*.img');
            
            if isempty(DirImg)  %YAN Chao-Gan, 111114. Also support .nii files. % Either in .nii.gz or in .nii
                DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirImg)==1
                    gunzip(DirImg(1).name);
                    delete(DirImg(1).name);
                end
                DirImg=dir('*.nii');
            end
            
            if length(DirImg)>1  %3D .img or .nii images.
                if AutoDataProcessParameter.TimePoints>0 && length(DirImg)~=AutoDataProcessParameter.TimePoints % Will not check if TimePoints set to 0. YAN Chao-Gan 120806.
                    Error=[Error;{['Error in Slice Timing, time point number doesn''t match: ',AutoDataProcessParameter.SubjectID{i}]}];
                end
                FileList=[];
                for j=1:length(DirImg)
                    FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(j).name]}];
                end
            else %4D .nii images
                Nii  = nifti(DirImg(1).name);
                if AutoDataProcessParameter.TimePoints>0 && size(Nii.dat,4)~=AutoDataProcessParameter.TimePoints % Will not check if TimePoints set to 0. YAN Chao-Gan 120806.
                    Error=[Error;{['Error in Slice Timing, time point number doesn''t match: ',AutoDataProcessParameter.SubjectID{i}]}];
                end
                FileList=[];
                for j=1:size(Nii.dat,4)
                    FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name,',',num2str(j)]}];
                end
            end
            
            
            SPMJOB.matlabbatch{1,1}.spm.temporal.st.scans{1}=FileList;
            
            
            if AutoDataProcessParameter.SliceTiming.SliceNumber==0 %If SliceNumber is set to 0, then retrieve the slice number from the NIfTI images. The slice order is then assumed as interleaved scanning: [1:2:SliceNumber,2:2:SliceNumber]. The reference slice is set to the slice acquired at the middle time point, i.e., SliceOrder(ceil(SliceNumber/2)). SHOULD BE EXTREMELY CAUTIOUS!!!
                
                Nii=nifti(FileList{1});
                SliceNumber = size(Nii.dat,3);
                SPMJOB.matlabbatch{1,1}.spm.temporal.st.nslices = SliceNumber;
                
                DirJSON=dir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.json']);
                if exist([AutoDataProcessParameter.DataProcessDir,filesep,'SliceOrderInfo.tsv'],'file')==2 % YAN Chao-Gan, 130524. Read the slice timing information from a tsv file (Tab-separated values)
                    
                    fid = fopen([AutoDataProcessParameter.DataProcessDir,filesep,'SliceOrderInfo.tsv']);
                    StringFilter = '%s';
                    for iFunSessionTemp=1:AutoDataProcessParameter.FunctionalSessionNumber
                        StringFilter = [StringFilter,'\t%s']; %Get the Slice Order Type for the sessions.
                    end
                    tline = fgetl(fid); %Skip the title line
                    SliceOrderSet = textscan(fid,StringFilter); %YAN Chao-Gan, 151210. For matlab 2015. %SliceOrderSet = textscan(fid,StringFilter,'\n');
                    fclose(fid);
                    
                    if ~strcmp(AutoDataProcessParameter.SubjectID{i},SliceOrderSet{1}{i})
                        error(['The subject ID ',SliceOrderSet{1}{i},' in SliceOrderInfo.tsv doesn''t match the target sbuject ID: ',AutoDataProcessParameter.SubjectID{i},'!'])
                    end
                    
                    switch SliceOrderSet{1+iFunSession}{i}
                        case {'IA'} %Interleaved Ascending
                            SliceOrder = [1:2:SliceNumber,2:2:SliceNumber];
                        case {'IA2'} %Interleaved Ascending for SIEMENS scanner if the slice number in an even number
                            SliceOrder = [2:2:SliceNumber,1:2:SliceNumber];
                        case {'ID'} %Interleaved Descending
                            SliceOrder = [SliceNumber:-2:1,SliceNumber-1:-2:1];
                        case {'ID2'} %Interleaved Descending for SIEMENS scanner if the slice number in an even number
                            SliceOrder = [SliceNumber-1:-2:1,SliceNumber:-2:1];
                        case {'SA'} %Sequential Ascending
                            SliceOrder = [1:SliceNumber];
                        case {'SD'} %Sequential Descending
                            SliceOrder = [SliceNumber:-1:1];
                            
                        otherwise
                            try
                                SliceOrder = load([AutoDataProcessParameter.DataProcessDir,filesep,SliceOrderSet{1+iFunSession}{i}]); %The slice order is specified in a text file.
                            catch
                                error(['The specified slice order definition ',SliceOrderSet{1+iFunSession}{i},' for subject ',AutoDataProcessParameter.SubjectID{i},' is not supported!'])
                            end
                    end;
                    
                    SPMJOB.matlabbatch{1,1}.spm.temporal.st.so = SliceOrder;
                    fprintf(['Using slice timing information from SliceOrderInfo.tsv: ',AutoDataProcessParameter.SubjectID{i},'.\n']);
                elseif ~isempty(DirJSON) %Use the slice timing information from DICOM BIDS information. %YAN Chao-Gan, 191122.
                    JSON=spm_jsonread([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirJSON(1).name]);
                    %SPMJOB.matlabbatch{1,1}.spm.temporal.st.so = JSON.SliceTiming;
                    SPMJOB.matlabbatch{1,1}.spm.temporal.st.so = JSON.SliceTiming * 1000; %YAN Chao-Gan, 200810. Fixed a bug as SPM is using ms unit.
                    fprintf(['Using slice timing information from DICOM BIDS information: ',AutoDataProcessParameter.SubjectID{i},'.\n']);
                else
                    SPMJOB.matlabbatch{1,1}.spm.temporal.st.so = [1:2:SliceNumber,2:2:SliceNumber];
                    fprintf(['BE CAUTIONS: Using slice order as [1:2:SliceNumber,2:2:SliceNumber]: ',AutoDataProcessParameter.SubjectID{i},'.\n']);
                end
                SPMJOB.matlabbatch{1,1}.spm.temporal.st.refslice = SPMJOB.matlabbatch{1,1}.spm.temporal.st.so(ceil(SliceNumber/2));
                
            else
                SliceNumber = AutoDataProcessParameter.SliceTiming.SliceNumber;
                SPMJOB.matlabbatch{1,1}.spm.temporal.st.nslices = SliceNumber;
                SPMJOB.matlabbatch{1,1}.spm.temporal.st.so = AutoDataProcessParameter.SliceTiming.SliceOrder;
                SPMJOB.matlabbatch{1,1}.spm.temporal.st.refslice = AutoDataProcessParameter.SliceTiming.ReferenceSlice;
            end
            
            if AutoDataProcessParameter.TR==0  %If TR is set to 0, then Need to retrieve the TR information from the NIfTI images
                SPMJOB.matlabbatch{1,1}.spm.temporal.st.tr = AutoDataProcessParameter.TRSet(i,iFunSession);
                SPMJOB.matlabbatch{1,1}.spm.temporal.st.ta = AutoDataProcessParameter.TRSet(i,iFunSession) - (AutoDataProcessParameter.TRSet(i,iFunSession)/SliceNumber);
            else
                SPMJOB.matlabbatch{1,1}.spm.temporal.st.tr = AutoDataProcessParameter.TR;
                SPMJOB.matlabbatch{1,1}.spm.temporal.st.ta = AutoDataProcessParameter.TR - (AutoDataProcessParameter.TR/SliceNumber);
            end

            fprintf(['Slice Timing Setup:',AutoDataProcessParameter.SubjectID{i},' OK\n']);
            spm_jobman('run',SPMJOB.matlabbatch);
        end
        
        %Copy the Slice Timing Corrected files to DataProcessDir\{AutoDataProcessParameter.StartingDirName}+A
        parfor i=1:AutoDataProcessParameter.SubjectNum
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'A',filesep,AutoDataProcessParameter.SubjectID{i}])
            try %YAN Chao-Gan, 200902. In case somebody has files initiated with a*, I need to double check if there is aa*
                movefile([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'aa*'],[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'A',filesep,AutoDataProcessParameter.SubjectID{i}])
            catch
                movefile([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'a*'],[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'A',filesep,AutoDataProcessParameter.SubjectID{i}])
            end
            fprintf(['Moving Slice Timing Corrected Files:',AutoDataProcessParameter.SubjectID{i},' OK']);
        end
        fprintf('\n');
        
    end
    AutoDataProcessParameter.StartingDirName=[AutoDataProcessParameter.StartingDirName,'A']; %Now StartingDirName is with new suffix 'A'
end
if ~isempty(Error)
    disp(Error);
    return;
end



%Calculate VDM for FieldMap Correction %YAN Chao-Gan 191122.
if isfield(AutoDataProcessParameter,'FieldMap')
    if (AutoDataProcessParameter.FieldMap.IsCalculateVDM==1)
        parfor i=1:AutoDataProcessParameter.SubjectNum
            SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'FieldMapCalculateVDM.mat']);
            SPMJOB.matlabbatch{1,1}.spm.tools.fieldmap.calculatevdm.subj.data=[];
            if strcmpi(AutoDataProcessParameter.FieldMap.DataFormat,'PhaseDiffMagnitude')
                DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'FieldMap',filesep,'PhaseDiffImg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii']);
                File=[AutoDataProcessParameter.DataProcessDir,filesep,'FieldMap',filesep,'PhaseDiffImg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name];
                SPMJOB.matlabbatch{1,1}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.phase={File};
                DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'FieldMap',filesep,'Magnitude1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii']);
                File=[AutoDataProcessParameter.DataProcessDir,filesep,'FieldMap',filesep,'Magnitude1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name];
                SPMJOB.matlabbatch{1,1}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.magnitude={File};
            else 
                DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'FieldMap',filesep,'Phase1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii']);
                File=[AutoDataProcessParameter.DataProcessDir,filesep,'FieldMap',filesep,'Phase1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name];
                SPMJOB.matlabbatch{1,1}.spm.tools.fieldmap.calculatevdm.subj.data.phasemag.shortphase={File};
                DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'FieldMap',filesep,'Phase2Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii']);
                File=[AutoDataProcessParameter.DataProcessDir,filesep,'FieldMap',filesep,'Phase2Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name];
                SPMJOB.matlabbatch{1,1}.spm.tools.fieldmap.calculatevdm.subj.data.phasemag.longphase={File};
                DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'FieldMap',filesep,'Magnitude1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii']);
                File=[AutoDataProcessParameter.DataProcessDir,filesep,'FieldMap',filesep,'Magnitude1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name];
                SPMJOB.matlabbatch{1,1}.spm.tools.fieldmap.calculatevdm.subj.data.phasemag.shortmag={File};
                DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'FieldMap',filesep,'Magnitude2Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii']);
                File=[AutoDataProcessParameter.DataProcessDir,filesep,'FieldMap',filesep,'Magnitude2Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name];
                SPMJOB.matlabbatch{1,1}.spm.tools.fieldmap.calculatevdm.subj.data.phasemag.longmag={File};
            end
            
            if AutoDataProcessParameter.FieldMap.TE1==0
                DirJSON=dir([AutoDataProcessParameter.DataProcessDir,filesep,'FieldMap',filesep,'Magnitude1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.json']);
                JSON=spm_jsonread([AutoDataProcessParameter.DataProcessDir,filesep,'FieldMap',filesep,'Magnitude1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirJSON(1).name]);
                TE1 = JSON.EchoTime*1000;
            else
                TE1 = AutoDataProcessParameter.FieldMap.TE1;
            end
            if AutoDataProcessParameter.FieldMap.TE2==0
                DirJSON=dir([AutoDataProcessParameter.DataProcessDir,filesep,'FieldMap',filesep,'Magnitude2Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.json']);
                JSON=spm_jsonread([AutoDataProcessParameter.DataProcessDir,filesep,'FieldMap',filesep,'Magnitude2Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirJSON(1).name]);
                TE2 = JSON.EchoTime*1000;
            else
                TE2 = AutoDataProcessParameter.FieldMap.TE2;
            end
            SPMJOB.matlabbatch{1,1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.et=[TE1,TE2];
            SPMJOB.matlabbatch{1,1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.maskbrain=0;
            DirJSON=dir([AutoDataProcessParameter.DataProcessDir,filesep,'FunImg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.json']);
            JSON=spm_jsonread([AutoDataProcessParameter.DataProcessDir,filesep,'FunImg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirJSON(1).name]);
            if isempty(strfind(JSON.PhaseEncodingDirection,'-'))
                SPMJOB.matlabbatch{1,1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.blipdir=1;
            else
                SPMJOB.matlabbatch{1,1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.blipdir=-1;
            end
            SPMJOB.matlabbatch{1,1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.tert=JSON.EffectiveEchoSpacing*JSON.ReconMatrixPE*1000;
            SPMJOB.matlabbatch{1,1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.epifm=AutoDataProcessParameter.FieldMap.EPIBasedFieldMap;
            SPMJOB.matlabbatch{1,1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.ajm=0;
            SPMJOB.matlabbatch{1,1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.template={fullfile(spm('Dir'),'toolbox','FieldMap','T1.nii')};
            
            DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii']);
            File=[AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name];
            SPMJOB.matlabbatch{1,1}.spm.tools.fieldmap.calculatevdm.subj.session.epi={[File,',1']};
            
            SPMJOB.matlabbatch{1,1}.spm.tools.fieldmap.calculatevdm.subj.matchvdm=1;
            SPMJOB.matlabbatch{1,1}.spm.tools.fieldmap.calculatevdm.subj.writeunwarped=0;
            SPMJOB.matlabbatch{1,1}.spm.tools.fieldmap.calculatevdm.subj.anat='';
            SPMJOB.matlabbatch{1,1}.spm.tools.fieldmap.calculatevdm.subj.matchanat=0;
            
            fprintf(['Calculate VDM for FieldMap Correction Setup:',AutoDataProcessParameter.SubjectID{i},' OK\n']);
            spm_jobman('run',SPMJOB.matlabbatch);
            
            %Clean the intermediate files
            delete([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'u',DirImg(1).name]);
            delete([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'wfmag_',DirImg(1).name]);
        end
        
        %Move the VDM files
        for i=1:AutoDataProcessParameter.SubjectNum
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'FieldMap',filesep,'VDMImg',filesep,AutoDataProcessParameter.SubjectID{i}])
            if strcmpi(AutoDataProcessParameter.FieldMap.DataFormat,'PhaseDiffMagnitude')
                movefile([AutoDataProcessParameter.DataProcessDir,filesep,'FieldMap',filesep,'PhaseDiffImg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'vdm*'],[AutoDataProcessParameter.DataProcessDir,filesep,'FieldMap',filesep,'VDMImg',filesep,AutoDataProcessParameter.SubjectID{i}])
            else
               movefile([AutoDataProcessParameter.DataProcessDir,filesep,'FieldMap',filesep,'Phase1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'vdm*'],[AutoDataProcessParameter.DataProcessDir,filesep,'FieldMap',filesep,'VDMImg',filesep,AutoDataProcessParameter.SubjectID{i}])
            end
        end
    end
end



%Realign
if (AutoDataProcessParameter.IsRealign==1)
    parfor i=1:AutoDataProcessParameter.SubjectNum
        if isfield(AutoDataProcessParameter,'FieldMap') && AutoDataProcessParameter.FieldMap.IsFieldMapCorrectionUnwarpRealign
            SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'RealignUnwarp.mat']);
        else
            SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Realign.mat']);
        end

        for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
            cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
            DirImg=dir('*.img');

            if isempty(DirImg)  %YAN Chao-Gan, 111114. Also support .nii files. % Either in .nii.gz or in .nii
                DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirImg)==1
                    gunzip(DirImg(1).name);
                    delete(DirImg(1).name);
                end
                DirImg=dir('*.nii');
            end
            
            if length(DirImg)>1  %3D .img or .nii images.
                if AutoDataProcessParameter.TimePoints>0 && length(DirImg)~=AutoDataProcessParameter.TimePoints % Will not check if TimePoints set to 0. YAN Chao-Gan 120806.
                    Error=[Error;{['Error in Realign, time point number doesn''t match: ',AutoDataProcessParameter.SubjectID{i}]}];
                end
                FileList=[];
                for j=1:length(DirImg)
                    FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(j).name]}];
                end
            else %4D .nii images
                Nii  = nifti(DirImg(1).name);
                if AutoDataProcessParameter.TimePoints>0 && size(Nii.dat,4)~=AutoDataProcessParameter.TimePoints % Will not check if TimePoints set to 0. YAN Chao-Gan 120806.
                    Error=[Error;{['Error in Realign, time point number doesn''t match: ',AutoDataProcessParameter.SubjectID{i}]}];
                end
                FileList=[];
                for j=1:size(Nii.dat,4)
                    FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name,',',num2str(j)]}];
                end
            end

            if isfield(AutoDataProcessParameter,'FieldMap') && AutoDataProcessParameter.FieldMap.IsFieldMapCorrectionUnwarpRealign %YAN Chao-Gan, 191122. Field Map Correction.
                SPMJOB.matlabbatch{1, 1}.spm.spatial.realignunwarp.data(iFunSession).scans=FileList;
                VDMFile=dir([AutoDataProcessParameter.DataProcessDir,filesep,'FieldMap',filesep,'VDMImg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'vdm*']);
                VDMFile=[AutoDataProcessParameter.DataProcessDir,filesep,'FieldMap',filesep,'VDMImg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,VDMFile(1).name];
                SPMJOB.matlabbatch{1, 1}.spm.spatial.realignunwarp.data(iFunSession).pmscan={VDMFile};
            else
                SPMJOB.matlabbatch{1,1}.spm.spatial.realign.estwrite.data{1,iFunSession}=FileList;
            end
        end

        fprintf(['Realign Setup:',AutoDataProcessParameter.SubjectID{i},' OK\n']);
        spm_jobman('run',SPMJOB.matlabbatch);
    end

    %Copy the Realign Parameters
    mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter']);
    if ~isempty(dir('*.ps'))
        copyfile('*.ps',[AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter']);
    end
    parfor i=1:AutoDataProcessParameter.SubjectNum
        cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{1},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i}]);
        movefile('mean*',[AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i}]);
        movefile('rp*.txt',[AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i}]);
        for iFunSession=2:AutoDataProcessParameter.FunctionalSessionNumber
            cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
            DirRP=dir('rp*.txt');
            [PathTemp, fileN, extn] = fileparts(DirRP.name);
            copyfile([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRP.name],[AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},fileN, extn]);
        end
    end

    %Copy the Head Motion Corrected files to DataProcessDir\{AutoDataProcessParameter.StartingDirName}+R
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName]);
        parfor i=1:AutoDataProcessParameter.SubjectNum
            cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
            mkdir(['..',filesep,'..',filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'R',filesep,AutoDataProcessParameter.SubjectID{i}])
            DirRR=dir('rr*'); %If the file name before realignment is initialed with 'r', then move the 'rr*' files. YAN Chao-Gan, 171205
            if isempty(DirRR)
                DirImg=dir('*.img');
                if ~isempty(DirImg)  %YAN Chao-Gan, 111114
                    movefile('r*.img',['..',filesep,'..',filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'R',filesep,AutoDataProcessParameter.SubjectID{i}])
                    movefile('r*.hdr',['..',filesep,'..',filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'R',filesep,AutoDataProcessParameter.SubjectID{i}])
                else
                    movefile('r*.nii',['..',filesep,'..',filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'R',filesep,AutoDataProcessParameter.SubjectID{i}])
                end
            else
                DirImg=dir('*.img');
                if ~isempty(DirImg)  %YAN Chao-Gan, 111114
                    movefile('rr*.img',['..',filesep,'..',filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'R',filesep,AutoDataProcessParameter.SubjectID{i}])
                    movefile('rr*.hdr',['..',filesep,'..',filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'R',filesep,AutoDataProcessParameter.SubjectID{i}])
                else
                    movefile('rr*.nii',['..',filesep,'..',filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'R',filesep,AutoDataProcessParameter.SubjectID{i}])
                end
            end
            cd('..');
            fprintf(['Moving Head Motion Corrected Files:',AutoDataProcessParameter.SubjectID{i},' OK']);
        end
    end
    fprintf('\n');
    AutoDataProcessParameter.StartingDirName=[AutoDataProcessParameter.StartingDirName,'R']; %Now StartingDirName is with new suffix 'R'
    
    %Check Head Motion
    cd([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter']);
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        
        HeadMotion = zeros(AutoDataProcessParameter.SubjectNum,20);
        % max(abs(Tx)), max(abs(Ty)), max(abs(Tz)), max(abs(Rx)), max(abs(Ry)), max(abs(Rz)),
        % mean(abs(Tx)), mean(abs(Ty)), mean(abs(Tz)), mean(abs(Rx)), mean(abs(Ry)), mean(abs(Rz)),
        % mean RMS, mean relative RMS (mean FD_VanDijk), 
        % mean FD_Power, Number of FD_Power>0.5, Percent of FD_Power>0.5, Number of FD_Power>0.2, Percent of FD_Power>0.2
        % mean FD_Jenkinson (FSL's relative RMS)

        for i=1:AutoDataProcessParameter.SubjectNum
            cd([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i}]);
           
            rpname=dir([FunSessionPrefixSet{iFunSession},'rp*']);
            
            RP=load(rpname.name);
            
            MaxRP = max(abs(RP));
            MaxRP(4:6) = MaxRP(4:6)*180/pi;
            
            MeanRP = mean(abs(RP));
            MeanRP(4:6) = MeanRP(4:6)*180/pi;
            
            %Calculate FD Van Dijk (Van Dijk, K.R., Sabuncu, M.R., Buckner, R.L., 2012. The influence of head motion on intrinsic functional connectivity MRI. Neuroimage 59, 431-438.)
            RPRMS = sqrt(sum(RP(:,1:3).^2,2));
            MeanRMS = mean(RPRMS);
            
            FD_VanDijk = abs(diff(RPRMS));
            FD_VanDijk = [0;FD_VanDijk];
            save([FunSessionPrefixSet{iFunSession},'FD_VanDijk_',AutoDataProcessParameter.SubjectID{i},'.txt'], 'FD_VanDijk', '-ASCII', '-DOUBLE','-TABS');
            MeanFD_VanDijk = mean(FD_VanDijk);
            
            %Calculate FD Power (Power, J.D., Barnes, K.A., Snyder, A.Z., Schlaggar, B.L., Petersen, S.E., 2012. Spurious but systematic correlations in functional connectivity MRI networks arise from subject motion. Neuroimage 59, 2142-2154.) 
            RPDiff=diff(RP);
            RPDiff=[zeros(1,6);RPDiff];
            RPDiffSphere=RPDiff;
            RPDiffSphere(:,4:6)=RPDiffSphere(:,4:6)*50;
            FD_Power=sum(abs(RPDiffSphere),2);
            save([FunSessionPrefixSet{iFunSession},'FD_Power_',AutoDataProcessParameter.SubjectID{i},'.txt'], 'FD_Power', '-ASCII', '-DOUBLE','-TABS');
            MeanFD_Power = mean(FD_Power);
            
            NumberFD_Power_05 = length(find(FD_Power>0.5));
            PercentFD_Power_05 = length(find(FD_Power>0.5)) / length(FD_Power);
            NumberFD_Power_02 = length(find(FD_Power>0.2));
            PercentFD_Power_02 = length(find(FD_Power>0.2)) / length(FD_Power);

            %Calculate FD Jenkinson (FSL's relative RMS) (Jenkinson, M., Bannister, P., Brady, M., Smith, S., 2002. Improved optimization for the robust and accurate linear registration and motion correction of brain images. Neuroimage 17, 825-841. Jenkinson, M. 1999. Measuring transformation error by RMS deviation. Internal Technical Report TR99MJ1, FMRIB Centre, University of Oxford. Available at www.fmrib.ox.ac.uk/analysis/techrep for downloading.)
            DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.img']);
            if isempty(DirMean)  %YAN Chao-Gan, 111114. Also support .nii files.
                DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.nii']);
            end
            if ~isempty(DirMean)
                RefFile=[AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name];
            end
            
            FD_Jenkinson = y_FD_Jenkinson(rpname.name,RefFile);
            save([FunSessionPrefixSet{iFunSession},'FD_Jenkinson_',AutoDataProcessParameter.SubjectID{i},'.txt'], 'FD_Jenkinson', '-ASCII', '-DOUBLE','-TABS');
            MeanFD_Jenkinson = mean(FD_Jenkinson);

            
            HeadMotion(i,:) = [MaxRP,MeanRP,MeanRMS,MeanFD_VanDijk,MeanFD_Power,NumberFD_Power_05,PercentFD_Power_05,NumberFD_Power_02,PercentFD_Power_02,MeanFD_Jenkinson];

        end
        save([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,FunSessionPrefixSet{iFunSession},'HeadMotion.mat'],'HeadMotion');

        %Write the Head Motion as .tsv
        fid = fopen([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,FunSessionPrefixSet{iFunSession},'HeadMotion.tsv'],'w');
        fprintf(fid,'Subject ID\tmax(abs(Tx))\tmax(abs(Ty))\tmax(abs(Tz))\tmax(abs(Rx))\tmax(abs(Ry))\tmax(abs(Rz))\tmean(abs(Tx))\tmean(abs(Ty))\tmean(abs(Tz))\tmean(abs(Rx))\tmean(abs(Ry))\tmean(abs(Rz))\tmean RMS\tmean relative RMS (mean FD_VanDijk)\tmean FD_Power\tNumber of FD_Power>0.5\tPercent of FD_Power>0.5\tNumber of FD_Power>0.2\tPercent of FD_Power>0.2\tmean FD_Jenkinson\n');
        for i=1:AutoDataProcessParameter.SubjectNum
            fprintf(fid,'%s\t',AutoDataProcessParameter.SubjectID{i});
            fprintf(fid,'%e\t',HeadMotion(i,:));
            fprintf(fid,'\n');
        end
        fclose(fid);

        
        ExcludeSub_Text=[];
        for ExcludingCriteria=3:-0.5:0.5
            BigHeadMotion=find(HeadMotion(:,1:6)>ExcludingCriteria);
            if ~isempty(BigHeadMotion)
                [II JJ]=ind2sub([AutoDataProcessParameter.SubjectNum,6],BigHeadMotion);
                ExcludeSub=unique(II);
                ExcludeSub_ID=AutoDataProcessParameter.SubjectID(ExcludeSub);
                TempText='';
                for iExcludeSub=1:length(ExcludeSub_ID)
                    TempText=sprintf('%s%s\n',TempText,ExcludeSub_ID{iExcludeSub});
                end
            else
                TempText='None';
            end
            ExcludeSub_Text=sprintf('%s\nExcluding Criteria: %2.1fmm and %2.1f degree in max head motion\n%s\n\n\n',ExcludeSub_Text,ExcludingCriteria,ExcludingCriteria,TempText);
        end
        fid = fopen([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,FunSessionPrefixSet{iFunSession},'ExcludeSubjectsAccordingToMaxHeadMotion.txt'],'at+');
        fprintf(fid,'%s',ExcludeSub_Text);
        fclose(fid);
    end

end
if ~isempty(Error)
    disp(Error);
    return;
end


%Calculate the voxel-specific head motion translation in x, y, z and TDvox, FDvox
%YAN Chao-Gan, 120819
if (AutoDataProcessParameter.IsCalVoxelSpecificHeadMotion==1)
    parfor i=1:AutoDataProcessParameter.SubjectNum
        if 7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i}],'dir')
            DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.img']);
            if isempty(DirMean)  %YAN Chao-Gan, 111114. Also support .nii files.
                DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.nii']);
            end
            if ~isempty(DirMean)
                RefFile=[AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name];
            end
            
        end
        
        for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
            
            OutputDir=[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'VoxelSpecificHeadMotion',filesep,AutoDataProcessParameter.SubjectID{i}];
            mkdir(OutputDir);

            DirRP=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},'rp*']);
            RPFile=[AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRP.name];
            
            [MeanTDvox, MeanFDvox, Header_Out] = y_VoxelSpecificHeadMotion(RPFile,RefFile,OutputDir,0);
            %[MeanTDvox, MeanFDvox, Header_Out] = y_VoxelSpecificHeadMotion(RealignmentParameterFile,ReferenceImage,OutputDir,GZFlag)
            
            % Save the mean TDvox and mean FDvox to folder of "MeanVoxelSpecificHeadMotion"

            if ~(7==exist([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'MeanVoxelSpecificHeadMotion_MeanTDvox'],'dir'))
                mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'MeanVoxelSpecificHeadMotion_MeanTDvox']);
            end
            y_Write(MeanTDvox,Header_Out,[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'MeanVoxelSpecificHeadMotion_MeanTDvox',filesep,'MeanTDvox_',AutoDataProcessParameter.SubjectID{i},'.nii']);
           
            if ~(7==exist([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'MeanVoxelSpecificHeadMotion_MeanFDvox'],'dir'))
                mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'MeanVoxelSpecificHeadMotion_MeanFDvox']);
            end
            y_Write(MeanFDvox,Header_Out,[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'MeanVoxelSpecificHeadMotion_MeanFDvox',filesep,'MeanFDvox_',AutoDataProcessParameter.SubjectID{i},'.nii']);

            
            fprintf(['\nGenerate voxel specific head motion: ',AutoDataProcessParameter.SubjectID{i},' ',FunSessionPrefixSet{iFunSession},' OK.\n']);
            
        end
    end
    
end



%Reorient T1 Image Interactively
%Do not need parfor
if (AutoDataProcessParameter.IsNeedReorientT1ImgInteractively==1) && (7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img'],'dir')) && AutoDataProcessParameter.IsAllowGUI
    % First check which kind of T1 image need to be applied
    if ~exist('UseNoCoT1Image','var')
        cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{1}]);
        DirCo=dir('c*.img');
        if isempty(DirCo)
            DirCo=dir('c*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
            if length(DirCo)==1
                gunzip(DirCo(1).name);
                delete(DirCo(1).name);
            end
            DirCo=dir('c*.nii');  %YAN Chao-Gan, 111114. Also support .nii files.
            if isempty(DirCo)
                DirCo=dir('*Crop*.nii');  %YAN Chao-Gan, 191121. Support BIDS format.
            end
        end
        if isempty(DirCo)
            DirImg=dir('*.img');
            if isempty(DirImg)  %YAN Chao-Gan, 111114. Also support .nii files.
                DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirImg)>=1
                    for j=1:length(DirImg)
                        gunzip(DirImg(j).name);
                        delete(DirImg(j).name);
                    end
                end
                DirImg=dir('*.nii');
            end
            if length(DirImg)==1
                button = questdlg(['No co* T1 image (T1 image which is reoriented to the nearest orthogonal direction to ''canonical space'' and removed excess air surrounding the individual as well as parts of the neck below the cerebellum) is found. Do you want to use the T1 image without co? Such as: ',DirImg(1).name,'?'],'No co* T1 image is found','Yes','No','Yes');
                if strcmpi(button,'Yes')
                    UseNoCoT1Image=1;
                else
                    return;
                end
            elseif length(DirImg)==0
                errordlg(['No T1 image has been found.'],'No T1 image has been found');
                return;
            else
                errordlg(['No co* T1 image (T1 image which is reoriented to the nearest orthogonal direction to ''canonical space'' and removed excess air surrounding the individual as well as parts of the neck below the cerebellum) is found. And there are too many T1 images detected in T1Img directory. Please determine which T1 image you want to use and delete the others from the T1Img directory, then re-run the analysis.'],'No co* T1 image is found');
                return;
            end
        else
            UseNoCoT1Image=0;
        end
        cd('..');
    end

    if ~(7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'ReorientMats'],'dir'))
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'ReorientMats']);
    end
    %Reorient
    for i=1:AutoDataProcessParameter.SubjectNum
        if UseNoCoT1Image==0
            DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'c*.img']);
            if isempty(DirT1Img)
                DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'c*.nii.gz']);% Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirT1Img)==1
                    gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1Img(1).name]);
                    delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1Img(1).name]);
                end
                DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'c*.nii']);
                if isempty(DirT1Img)
                    DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*Crop*.nii']); %YAN Chao-Gan, 191121. Calling dcm2niix for BIDS format. Change searching c* to *Crop*
                end
            end
        else
            DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.img']);
            if isempty(DirT1Img)
                DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii.gz']);% Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirT1Img)==1
                    gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1Img(1).name]);
                    delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1Img(1).name]);
                end
                DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii']);
            end
        end
        FileList=[{[AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1Img(1).name,',1']}];
        fprintf('Reorienting T1 Image Interactively for %s: \n',AutoDataProcessParameter.SubjectID{i});
        global y_spm_image_Parameters
        y_spm_image_Parameters.ReorientFileList=FileList;
        uiwait(y_spm_image('init',[AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1Img(1).name]));
        mat=y_spm_image_Parameters.ReorientMat;
        
        % YAN Chao-Gan 131126. Save the QC scores and comments
        AutoDataProcessParameter.QC.RawT1ImgQC.QCScore(i,1) = y_spm_image_Parameters.QCScore;
        AutoDataProcessParameter.QC.RawT1ImgQC.QCComment{i,1} = y_spm_image_Parameters.QCComment;
        
        save([AutoDataProcessParameter.DataProcessDir,filesep,'ReorientMats',filesep,AutoDataProcessParameter.SubjectID{i},'_ReorientT1ImgMat.mat'],'mat')
        clear global y_spm_image_Parameters
        fprintf('Reorienting T1 Image Interactively for %s: OK\n',AutoDataProcessParameter.SubjectID{i});
    end
    

    %Write the QC information as {WorkDir}/QC/RawT1ImgQC.tsv
    mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'QC'])
    fid = fopen([AutoDataProcessParameter.DataProcessDir,filesep,'QC',filesep,'RawT1ImgQC.tsv'],'w');
    
    fprintf(fid,'Subject ID');
    fprintf(fid,['\t','QC Score']);
    fprintf(fid,['\t','QC Comment']);
    fprintf(fid,'\n');
    for i=1:AutoDataProcessParameter.SubjectNum
        fprintf(fid,'%s',AutoDataProcessParameter.SubjectID{i});
        fprintf(fid,'\t%g',AutoDataProcessParameter.QC.RawT1ImgQC.QCScore(i,1));
        fprintf(fid,'\t%s',AutoDataProcessParameter.QC.RawT1ImgQC.QCComment{i,1});
        fprintf(fid,'\n');
    end
    fclose(fid);

end
if ~isempty(Error)
    disp(Error);
    return;
end


%Reorient Functional Images Interactively
%Do not need parfor
if (AutoDataProcessParameter.IsNeedReorientFunImgInteractively==1) && AutoDataProcessParameter.IsAllowGUI
    % Check if mean* image generated in Head Motion Correction exist. Added by YAN Chao-Gan 101010.
    if 7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{1}],'dir')
        DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{1},filesep,'mean*.img']);
        if isempty(DirMean)  %YAN Chao-Gan, 111114. Also support .nii files.
            DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{1},filesep,'mean*.nii.gz']);% Search .nii.gz and unzip; YAN Chao-Gan, 120806.
            if length(DirMean)==1
                gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{1},filesep,DirMean(1).name]);
                delete([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{1},filesep,DirMean(1).name]);
            end
            DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{1},filesep,'mean*.nii']);
        end
    else
        DirMean=[];
    end
    if isempty(DirMean)
        % Generate mean image. ONLY FOR situation with ONE SESSION.
        cd([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName]);
        for i=1:AutoDataProcessParameter.SubjectNum
            fprintf('\nCalculate mean functional brain (%s) for "%s" since there is no mean* image generated in Head Motion Correction exist.\n',AutoDataProcessParameter.StartingDirName, AutoDataProcessParameter.SubjectID{i});
            cd([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
            DirImg=dir('*.img');
            if isempty(DirImg)  %YAN Chao-Gan, 111114. Also support .nii files.
                DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirImg)==1
                    gunzip(DirImg(1).name);
                    delete(DirImg(1).name);
                end
                DirImg=dir('*.nii');
            end

            if length(DirImg)>1  %3D .img or .nii images.
                [Data, Header] = y_Read(DirImg(1).name);
                AllVolume =repmat(Data, [1,1,1, length(DirImg)]);
                for j=2:length(DirImg)
                    [Data, Header] = y_Read(DirImg(j).name);
                    AllVolume(:,:,:,j) = Data;
                    if ~mod(j,5)
                        fprintf('.');
                    end
                end
            else %4D .nii images
                [AllVolume, Header] = y_Read(DirImg(1).name); %Revised according to ORSOLINI's suggestion ~ 12 february 2013
            end
            
            AllVolume=mean(AllVolume,4);
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i}]);
            Header.pinfo = [1;0;0];
            Header.dt    =[16,0];
            y_Write(AllVolume,Header,[AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean',AutoDataProcessParameter.SubjectID{i},'img']);
            fprintf('\nMean functional brain (%s) for "%s" saved as: %s\n',AutoDataProcessParameter.StartingDirName, AutoDataProcessParameter.SubjectID{i}, [AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean',AutoDataProcessParameter.SubjectID{i},'img']);
            cd('..');
        end
    end

    if ~(7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'ReorientMats'],'dir'))
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'ReorientMats']);
    end
    %Reorient
    cd([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName]);
    for i=1:AutoDataProcessParameter.SubjectNum
        FileList=[];
        
        % Find the mean* functional image.
        if 7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i}],'dir')
            DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.img']);
            if isempty(DirMean)  %YAN Chao-Gan, 111114. Also support .nii files.
                DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.nii']);
            end
            if ~isempty(DirMean)
                FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name,',1']}];
            end
        end

        fprintf('Reorienting Functional Images Interactively for %s: \n',AutoDataProcessParameter.SubjectID{i});
        global y_spm_image_Parameters
        y_spm_image_Parameters.ReorientFileList=FileList;
        uiwait(y_spm_image('init',[AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name,',1']));
        mat=y_spm_image_Parameters.ReorientMat;
        
        % YAN Chao-Gan 131126. Save the QC scores and comments
        AutoDataProcessParameter.QC.RawFunImgQC.QCScore(i,1) = y_spm_image_Parameters.QCScore;
        AutoDataProcessParameter.QC.RawFunImgQC.QCComment{i,1} = y_spm_image_Parameters.QCComment;

        save([AutoDataProcessParameter.DataProcessDir,filesep,'ReorientMats',filesep,AutoDataProcessParameter.SubjectID{i},'_ReorientFunImgMat.mat'],'mat')
        clear global y_spm_image_Parameters
        fprintf('Reorienting Functional Images Interactively for %s: OK\n',AutoDataProcessParameter.SubjectID{i});
    end

    %Write the QC information as {WorkDir}/QC/RawFunImgQC.tsv
    mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'QC'])
    fid = fopen([AutoDataProcessParameter.DataProcessDir,filesep,'QC',filesep,'RawFunImgQC.tsv'],'w');
    
    fprintf(fid,'Subject ID');
    fprintf(fid,['\t','QC Score']);
    fprintf(fid,['\t','QC Comment']);
    fprintf(fid,'\n');
    for i=1:AutoDataProcessParameter.SubjectNum
        fprintf(fid,'%s',AutoDataProcessParameter.SubjectID{i});
        fprintf(fid,'\t%g',AutoDataProcessParameter.QC.RawFunImgQC.QCScore(i,1));
        fprintf(fid,'\t%s',AutoDataProcessParameter.QC.RawFunImgQC.QCComment{i,1});
        fprintf(fid,'\n');
    end
    fclose(fid);

    
    % Apply Reorient Mats to functional images and/or the voxel-specific head motion files
    parfor i=1:AutoDataProcessParameter.SubjectNum
        % In case there exist reorient matrix (interactive reorient after head motion correction and before T1-Fun coregistration)
        ReorientMat=eye(4);
        if exist([AutoDataProcessParameter.DataProcessDir,filesep,'ReorientMats'],'dir')==7
            if exist([AutoDataProcessParameter.DataProcessDir,filesep,'ReorientMats',filesep,AutoDataProcessParameter.SubjectID{i},'_ReorientFunImgMat.mat'],'file')==2
                ReorientMat_Interactively = load([AutoDataProcessParameter.DataProcessDir,filesep,'ReorientMats',filesep,AutoDataProcessParameter.SubjectID{i},'_ReorientFunImgMat.mat']);
                ReorientMat=ReorientMat_Interactively.mat*ReorientMat;
            end
        end

        if ~all(all(ReorientMat==eye(4)))
            for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                %Apply to the functional images
                cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
                DirImg=dir('*.img');
                if isempty(DirImg)  %YAN Chao-Gan, 111114. Also support .nii files.
                    DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                    if length(DirImg)==1
                        gunzip(DirImg(1).name);
                        delete(DirImg(1).name);
                    end
                    DirImg=dir('*.nii');
                end

                for j=1:length(DirImg)
                    OldMat = spm_get_space(DirImg(j).name);
                    spm_get_space(DirImg(j).name,ReorientMat*OldMat);
                end
                if length(DirImg)==1 % delete the .mat file generated by spm_get_space for 4D nii images
                    if exist([DirImg(j).name(1:end-4),'.mat'],'file')==2
                        delete([DirImg(j).name(1:end-4),'.mat']);
                    end
                end
                
                %Apply to voxel-specific head motion files
                if (7==exist([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'VoxelSpecificHeadMotion',filesep,AutoDataProcessParameter.SubjectID{i}],'dir'))
                    cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'VoxelSpecificHeadMotion',filesep,AutoDataProcessParameter.SubjectID{i}]);
                    DirImg=dir('*.nii');
                    
                    for j=1:length(DirImg)
                        OldMat = spm_get_space(DirImg(j).name);
                        spm_get_space(DirImg(j).name,ReorientMat*OldMat);
                        if exist([DirImg(j).name(1:end-4),'.mat'],'file')==2
                            delete([DirImg(j).name(1:end-4),'.mat']);
                        end
                    end
                end
                FileNameTemp = [AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'MeanVoxelSpecificHeadMotion_MeanTDvox',filesep,'MeanTDvox_',AutoDataProcessParameter.SubjectID{i},'.nii'];
                if exist(FileNameTemp,'file')==2
                    OldMat = spm_get_space(FileNameTemp);
                    spm_get_space(FileNameTemp,ReorientMat*OldMat);
                end
                FileNameTemp = [AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'MeanVoxelSpecificHeadMotion_MeanFDvox',filesep,'MeanFDvox_',AutoDataProcessParameter.SubjectID{i},'.nii'];
                if exist(FileNameTemp,'file')==2
                    OldMat = spm_get_space(FileNameTemp);
                    spm_get_space(FileNameTemp,ReorientMat*OldMat);
                end
                
            end
        end
        
        fprintf('Apply Reorient Mats to functional images for %s: OK\n',AutoDataProcessParameter.SubjectID{i});
    end   
end
if ~isempty(Error)
    disp(Error);
    return;
end


%YAN Chao-Gan, 210419. We will threshold those subjects with bad T1 and Fun quality
if ((AutoDataProcessParameter.IsNeedReorientT1ImgInteractively==1) || (AutoDataProcessParameter.IsNeedReorientFunImgInteractively==1) ) && AutoDataProcessParameter.IsAllowGUI
    ThreQC=ReorientThreQC;
    GoodSub=ones(AutoDataProcessParameter.SubjectNum,1);
    if ThreQC.IsThreT1
        try
            GoodSub=GoodSub.*(AutoDataProcessParameter.QC.RawT1ImgQC.QCScore>=ThreQC.ThreT1);
        catch % YAN Chao-Gan, 211116. In case no field of RawT1ImgQC.QCScore
        end
    end
    if ThreQC.IsThreFun
        try
            GoodSub=GoodSub.*(AutoDataProcessParameter.QC.RawFunImgQC.QCScore>=ThreQC.ThreFun);
        catch % YAN Chao-Gan, 211116. In case no field of RawFunImgQC.QCScore
        end
    end
    
    AutoDataProcessParameter.SubjectID=AutoDataProcessParameter.SubjectID(find(GoodSub));
    AutoDataProcessParameter.SubjectNum=length(AutoDataProcessParameter.SubjectID);
end


%Bet %130801
if (AutoDataProcessParameter.IsBet==1)
    fprintf('Bet begin...\n');
    
    %For functional image
    % Check if mean* image generated in Head Motion Correction exist. Added by YAN Chao-Gan 101010.
    if 7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{1}],'dir')
        DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{1},filesep,'mean*.img']);
        if isempty(DirMean)  %YAN Chao-Gan, 111114. Also support .nii files.
            DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{1},filesep,'mean*.nii.gz']);% Search .nii.gz and unzip; YAN Chao-Gan, 120806.
            if length(DirMean)==1
                gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{1},filesep,DirMean(1).name]);
                delete([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{1},filesep,DirMean(1).name]);
            end
            DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{1},filesep,'mean*.nii']);
        end
    else
        DirMean=[];
    end
    if isempty(DirMean)
        % Generate mean image. ONLY FOR situation with ONE SESSION.
        cd([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName]);
        for i=1:AutoDataProcessParameter.SubjectNum
            fprintf('\nCalculate mean functional brain (%s) for "%s" since there is no mean* image generated in Head Motion Correction exist.\n',AutoDataProcessParameter.StartingDirName, AutoDataProcessParameter.SubjectID{i});
            cd([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
            DirImg=dir('*.img');
            if isempty(DirImg)  %YAN Chao-Gan, 111114. Also support .nii files.
                DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirImg)==1
                    gunzip(DirImg(1).name);
                    delete(DirImg(1).name);
                end
                DirImg=dir('*.nii');
            end

            if length(DirImg)>1  %3D .img or .nii images.
                [Data, Header] = y_Read(DirImg(1).name);
                AllVolume =repmat(Data, [1,1,1, length(DirImg)]);
                for j=2:length(DirImg)
                    [Data, Header] = y_Read(DirImg(j).name);
                    AllVolume(:,:,:,j) = Data;
                    if ~mod(j,5)
                        fprintf('.');
                    end
                end
            else %4D .nii images
                [AllVolume, Header] = y_Read(DirImg(1).name); %Revised according to ORSOLINI's suggestion ~ 12 february 2013
            end
            
            AllVolume=mean(AllVolume,4);
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i}]);
            Header.pinfo = [1;0;0];
            Header.dt    =[16,0];
            y_Write(AllVolume,Header,[AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean',AutoDataProcessParameter.SubjectID{i},'img']);
            fprintf('\nMean functional brain (%s) for "%s" saved as: %s\n',AutoDataProcessParameter.StartingDirName, AutoDataProcessParameter.SubjectID{i}, [AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean',AutoDataProcessParameter.SubjectID{i},'img']);
            cd('..');
        end
    end

    %Bet functional image
    for i=1:AutoDataProcessParameter.SubjectNum %YAN Chao-Gan, 180824. Cut parfor becuase of losing some processes. %parfor
                
        % Find the mean* functional image.
        if 7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i}],'dir')
            DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.img']);
            if isempty(DirMean)  %YAN Chao-Gan, 111114. Also support .nii files.
                DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.nii']);
            end
            if ~isempty(DirMean)
                MeanFile=[AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name];
            
                OutputFile_Temp = [AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'Bet_',DirMean(1).name];
                
                %eval(['!bet ',MeanFile,' ',OutputFile_Temp,' -f 0.3'])
                
                y_Call_bet(MeanFile, OutputFile_Temp, '-f 0.3', AutoDataProcessParameter.DataProcessDir); %YAN Chao-Gan, 190710. y_Call_bet(MeanFile, OutputFile_Temp, '-f 0.3');
                
            end
        end

    end
    
    
    %%%%For structural image%%%%
    if (7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img'],'dir')) %YAN Chao-Gan, 141101.
        % Check if co* image exist. Added by YAN Chao-Gan 100510.
        if ~exist('UseNoCoT1Image','var')
            cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{1}]);
            DirCo=dir('c*.img');
            if isempty(DirCo)
                DirCo=dir('c*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirCo)==1
                    gunzip(DirCo(1).name);
                    delete(DirCo(1).name);
                end
                DirCo=dir('c*.nii');  %YAN Chao-Gan, 111114. Also support .nii files.
                if isempty(DirCo)
                    DirCo=dir('*Crop*.nii');  %YAN Chao-Gan, 191121. Support BIDS format.
                end
            end
            if isempty(DirCo)
                DirImg=dir('*.img');
                if isempty(DirImg)  %YAN Chao-Gan, 111114. Also support .nii files.
                    DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                    if length(DirImg)>=1
                        for j=1:length(DirImg)
                            gunzip(DirImg(j).name);
                            delete(DirImg(j).name);
                        end
                    end
                    DirImg=dir('*.nii');
                end
                if length(DirImg)==1
                    button = questdlg(['No co* T1 image (T1 image which is reoriented to the nearest orthogonal direction to ''canonical space'' and removed excess air surrounding the individual as well as parts of the neck below the cerebellum) is found. Do you want to use the T1 image without co? Such as: ',DirImg(1).name,'?'],'No co* T1 image is found','Yes','No','Yes');
                    if strcmpi(button,'Yes')
                        UseNoCoT1Image=1;
                    else
                        return;
                    end
                elseif length(DirImg)==0
                    errordlg(['No T1 image has been found.'],'No T1 image has been found');
                    return;
                else
                    errordlg(['No co* T1 image (T1 image which is reoriented to the nearest orthogonal direction to ''canonical space'' and removed excess air surrounding the individual as well as parts of the neck below the cerebellum) is found. And there are too many T1 images detected in T1Img directory. Please determine which T1 image you want to use and delete the others from the T1Img directory, then re-run the analysis.'],'No co* T1 image is found');
                    return;
                end
            else
                UseNoCoT1Image=0;
            end
        end
        
        for i=1:AutoDataProcessParameter.SubjectNum %YAN Chao-Gan, 180824. Cut parfor becuase of losing some processes. %parfor
            if UseNoCoT1Image==0
                %Search the T1 file - first go with "c" initial
                DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'c*.img']);
                if isempty(DirImg)
                    DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'c*.nii.gz']);
                end
                if isempty(DirImg)
                    DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'c*.nii']);
                end
                if isempty(DirImg)
                    DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*Crop*.nii']); %YAN Chao-Gan, 191121. Calling dcm2niix for BIDS format. Change searching c* to *Crop*
                end
            else
                %Search the T1 file - then any possible file
                DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.img']);
                if isempty(DirImg)
                    DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii.gz']);
                end
                if isempty(DirImg)
                    DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii']);
                end
            end
            
            T1File=[AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name];
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgBet',filesep,AutoDataProcessParameter.SubjectID{i}]);
            
            OutputFile_Temp = [AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgBet',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'Bet_',DirImg(1).name];
            
            %eval(['!bet ',T1File,' ',OutputFile_Temp])
            
            y_Call_bet(T1File, OutputFile_Temp, '', AutoDataProcessParameter.DataProcessDir); %YAN Chao-Gan, 190710. y_Call_bet(T1File, OutputFile_Temp, '');
            
        end
    end
    fprintf('Bet finished\n');
   
end


% The parpool might be shut down, restart it.
% if isempty(gcp('nocreate')) && AutoDataProcessParameter.ParallelWorkersNumber~=0
%     parpool(AutoDataProcessParameter.ParallelWorkersNumber);
% end
% YAN Chao-Gan, 190312. To be compatible with early matlab versions
PCTVer = ver('distcomp');
if ~isempty(PCTVer)
    FullMatlabVersion = sscanf(version,'%d.%d.%d.%d%s');
    if FullMatlabVersion(1)*1000+FullMatlabVersion(2)<8*1000+3    %YAN Chao-Gan, 151117. If it's lower than MATLAB 2014a.  %FullMatlabVersion(1)*1000+FullMatlabVersion(2)>=7*1000+8    %YAN Chao-Gan, 120903. If it's higher than MATLAB 2008.
        CurrentSize_MatlabPool = matlabpool('size');
        if (CurrentSize_MatlabPool==0) && (AutoDataProcessParameter.ParallelWorkersNumber~=0)
            matlabpool(AutoDataProcessParameter.ParallelWorkersNumber)
        end
    else
        if isempty(gcp('nocreate')) && AutoDataProcessParameter.ParallelWorkersNumber~=0
            parpool(AutoDataProcessParameter.ParallelWorkersNumber);
        end
    end
end



%Coregister T1 Image to Functional space
if (AutoDataProcessParameter.IsNeedT1CoregisterToFun==1)
    %Backup the T1 images to T1ImgCoreg
    % Check if co* image exist. Added by YAN Chao-Gan 100510.
    if ~exist('UseNoCoT1Image','var')
        cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{1}]);
        DirCo=dir('c*.img');
        if isempty(DirCo)
            DirCo=dir('c*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
            if length(DirCo)==1
                gunzip(DirCo(1).name);
                delete(DirCo(1).name);
            end
            DirCo=dir('c*.nii');  %YAN Chao-Gan, 111114. Also support .nii files.
            if isempty(DirCo)
                DirCo=dir('*Crop*.nii');  %YAN Chao-Gan, 191121. Support BIDS format.
            end
        end
        if isempty(DirCo)
            DirImg=dir('*.img');
            if isempty(DirImg)  %YAN Chao-Gan, 111114. Also support .nii files.
                DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirImg)>=1
                    for j=1:length(DirImg)
                        gunzip(DirImg(j).name);
                        delete(DirImg(j).name);
                    end
                end
                DirImg=dir('*.nii');
            end
            if length(DirImg)==1
                button = questdlg(['No co* T1 image (T1 image which is reoriented to the nearest orthogonal direction to ''canonical space'' and removed excess air surrounding the individual as well as parts of the neck below the cerebellum) is found. Do you want to use the T1 image without co? Such as: ',DirImg(1).name,'?'],'No co* T1 image is found','Yes','No','Yes');
                if strcmpi(button,'Yes')
                    UseNoCoT1Image=1;
                else
                    return;
                end
            elseif length(DirImg)==0
                errordlg(['No T1 image has been found.'],'No T1 image has been found');
                return;
            else
                errordlg(['No co* T1 image (T1 image which is reoriented to the nearest orthogonal direction to ''canonical space'' and removed excess air surrounding the individual as well as parts of the neck below the cerebellum) is found. And there are too many T1 images detected in T1Img directory. Please determine which T1 image you want to use and delete the others from the T1Img directory, then re-run the analysis.'],'No co* T1 image is found');
                return;
            end
        else
            UseNoCoT1Image=0;
        end
    end
    
    parfor i=1:AutoDataProcessParameter.SubjectNum
        cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i}]);
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i}])
        % Check in co* image exist. Added by YAN Chao-Gan 100510.
        if UseNoCoT1Image==0
            DirImg=dir('c*.img');
            if ~isempty(DirImg)  %YAN Chao-Gan, 111114
                copyfile('c*.hdr',[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i}])
                copyfile('c*.img',[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i}])
            else
                DirImg=dir('c*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirImg)==1
                    gunzip(DirImg(1).name);
                    delete(DirImg(1).name);
                end
                DirImg=dir('c*.nii');
                if ~isempty(DirImg)
                    copyfile('c*.nii',[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i}])
                else
                    copyfile('*Crop*.nii',[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i}])
                end
            end
        else
            DirImg=dir('*.img');
            if ~isempty(DirImg)  %YAN Chao-Gan, 111114
                copyfile('*.hdr',[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i}])
                copyfile('*.img',[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i}])
            else
                DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirImg)>=1
                    for j=1:length(DirImg)
                        gunzip(DirImg(j).name);
                        delete(DirImg(j).name);
                    end
                end
                copyfile('*.nii',[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i}])
            end
        end
        fprintf(['Copying T1 image Files:',AutoDataProcessParameter.SubjectID{i},' OK']);
    end
    fprintf('\n');
    
    % Check if mean* image generated in Head Motion Correction exist. Added by YAN Chao-Gan 101010.
    if 7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{1}],'dir')
        DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{1},filesep,'mean*.img']);
        if isempty(DirMean)  %YAN Chao-Gan, 111114. Also support .nii files.
            DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{1},filesep,'mean*.nii.gz']);% Search .nii.gz and unzip; YAN Chao-Gan, 120806.
            if length(DirMean)==1
                gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{1},filesep,DirMean(1).name]);
                delete([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{1},filesep,DirMean(1).name]);
            end
            DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{1},filesep,'mean*.nii']);
        end
    else
        DirMean=[];
    end
    if isempty(DirMean)
        % Generate mean image. ONLY FOR situation with ONE SESSION.
        cd([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName]);
        for i=1:AutoDataProcessParameter.SubjectNum
            fprintf('\nCalculate mean functional brain (%s) for "%s" since there is no mean* image generated in Head Motion Correction exist.\n',AutoDataProcessParameter.StartingDirName, AutoDataProcessParameter.SubjectID{i});
            cd([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
            DirImg=dir('*.img');
            if isempty(DirImg)  %YAN Chao-Gan, 111114. Also support .nii files.
                DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirImg)==1
                    gunzip(DirImg(1).name);
                    delete(DirImg(1).name);
                end
                DirImg=dir('*.nii');
            end
            
            if length(DirImg)>1  %3D .img or .nii images.
                [Data, Header] = y_Read(DirImg(1).name);
                AllVolume =repmat(Data, [1,1,1, length(DirImg)]);
                for j=2:length(DirImg)
                    [Data, Header] = y_Read(DirImg(j).name);
                    AllVolume(:,:,:,j) = Data;
                    if ~mod(j,5)
                        fprintf('.');
                    end
                end
            else %4D .nii images
                [AllVolume, Header] = y_Read(DirImg(1).name); %Revised according to ORSOLINI's suggestion ~ 12 february 2013
            end
            
            AllVolume=mean(AllVolume,4);
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i}]);
            Header.pinfo = [1;0;0];
            Header.dt    =[16,0];
            y_Write(AllVolume,Header,[AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean',AutoDataProcessParameter.SubjectID{i},'img']);
            fprintf('\nMean functional brain (%s) for "%s" saved as: %s\n',AutoDataProcessParameter.StartingDirName, AutoDataProcessParameter.SubjectID{i}, [AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean',AutoDataProcessParameter.SubjectID{i},'img']);
            cd('..');
        end
    end

    
    parfor i=1:AutoDataProcessParameter.SubjectNum
        SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Coregister.mat']);
        
        %For mean functional image, first check if the betted version exists. YAN Chao-Gan, 130729
        RefDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'Bet_mean*.img']);
        if isempty(RefDir)
            RefDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'Bet_mean*.nii.gz']);
            if length(RefDir)==1
                gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,RefDir(1).name]);
                delete([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,RefDir(1).name]);
            end
            RefDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'Bet_mean*.nii']);
        end
        
        %If the betted version doesn't exist, then check the original mean version.
        if isempty(RefDir)
            RefDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.img']);
            if isempty(RefDir)
                RefDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.nii.gz']);
                if length(RefDir)==1
                    gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,RefDir(1).name]);
                    delete([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,RefDir(1).name]);
                end
                RefDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.nii']);
            end
        end
        RefFile=[AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,RefDir(1).name,',1'];
        
        
        SourceDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.img']);
        if isempty(SourceDir)  %YAN Chao-Gan, 111114. Also support .nii files.
           SourceDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii.gz']);
           if length(SourceDir)==1
               gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,SourceDir(1).name]);
               delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,SourceDir(1).name]);
           end
           SourceDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii']);
        end
        SourceFile=[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,SourceDir(1).name];

        SPMJOB.matlabbatch{1,1}.spm.spatial.coreg.estimate.ref={RefFile};
        SPMJOB.matlabbatch{1,1}.spm.spatial.coreg.estimate.source={SourceFile};
        
        
        %If did bet on T1 image!!! Then use the betted version as source, and the original version as "other images" to write!!!
        if (7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgBet'],'dir'))
            SPMJOB.matlabbatch{1,1}.spm.spatial.coreg.estimate.other={SourceFile};
            
            SourceDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgBet',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'Bet_*.img']);
            if isempty(SourceDir)  %YAN Chao-Gan, 111114. Also support .nii files.
                SourceDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgBet',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'Bet_*.nii.gz']);
                if length(SourceDir)==1
                    gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgBet',filesep,AutoDataProcessParameter.SubjectID{i},filesep,SourceDir(1).name]);
                    delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgBet',filesep,AutoDataProcessParameter.SubjectID{i},filesep,SourceDir(1).name]);
                end
                SourceDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgBet',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'Bet_*.nii']);
            end
            SourceFile=[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgBet',filesep,AutoDataProcessParameter.SubjectID{i},filesep,SourceDir(1).name];
            
            SPMJOB.matlabbatch{1,1}.spm.spatial.coreg.estimate.source={SourceFile};
        end

        
        fprintf(['Coregister Setup:',AutoDataProcessParameter.SubjectID{i},' OK\n']);
        spm_jobman('run',SPMJOB.matlabbatch);
    end
end




%Reorient Interactively After Coregistration for better orientation in Segmentation
%Do not need parfor
if (AutoDataProcessParameter.IsNeedReorientInteractivelyAfterCoreg==1) && AutoDataProcessParameter.IsAllowGUI
    
    if ~(7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'ReorientMats'],'dir'))
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'ReorientMats']);
    end
    %Reorient
    cd([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName]);
    for i=1:AutoDataProcessParameter.SubjectNum
        FileList=[];

        DirT1ImgCoreg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.img']);
        if isempty(DirT1ImgCoreg)  %YAN Chao-Gan, 111114. Also support .nii files.
            DirT1ImgCoreg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii.gz']);
            if length(DirT1ImgCoreg)==1
                gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]);
                delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]);
            end
            DirT1ImgCoreg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii']);
        end
        FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1ImgCoreg(1).name,',1']}];

        % if the mean* functional image exist, then also reorient it.
        if 7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i}],'dir')
            DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.img']);
            if isempty(DirMean)  %YAN Chao-Gan, 111114. Also support .nii files.
                DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.nii.gz']);% Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirMean)==1
                    gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name]);
                    delete([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name]);
                end
                DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.nii']);
            end
            if ~isempty(DirMean)
                FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name,',1']}];
            end
        end

        fprintf('Reorienting Interactively After Coregistration for %s: \n',AutoDataProcessParameter.SubjectID{i});
        global y_spm_image_Parameters
        y_spm_image_Parameters.ReorientFileList=FileList;
        uiwait(y_spm_image('init',[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1ImgCoreg(1).name]));
        mat=y_spm_image_Parameters.ReorientMat;
        
        % YAN Chao-Gan 131126. Save the QC scores and comments
        AutoDataProcessParameter.QC.RawT1ImgQC.QCScore(i,1) = y_spm_image_Parameters.QCScore;
        AutoDataProcessParameter.QC.RawT1ImgQC.QCComment{i,1} = y_spm_image_Parameters.QCComment;

        save([AutoDataProcessParameter.DataProcessDir,filesep,'ReorientMats',filesep,AutoDataProcessParameter.SubjectID{i},'_ReorientT1FunAfterCoregMat.mat'],'mat')
        clear global y_spm_image_Parameters
        fprintf('Reorienting Interactively After Coregistration for %s: OK\n',AutoDataProcessParameter.SubjectID{i});
        cd('..');
    end

    %Write the QC information as {WorkDir}/QC/RawT1ImgQC.tsv
    mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'QC'])
    fid = fopen([AutoDataProcessParameter.DataProcessDir,filesep,'QC',filesep,'RawT1ImgQC.tsv'],'w');
    
    fprintf(fid,'Subject ID');
    fprintf(fid,['\t','QC Score']);
    fprintf(fid,['\t','QC Comment']);
    fprintf(fid,'\n');
    for i=1:AutoDataProcessParameter.SubjectNum
        fprintf(fid,'%s',AutoDataProcessParameter.SubjectID{i});
        fprintf(fid,'\t%g',AutoDataProcessParameter.QC.RawT1ImgQC.QCScore(i,1));
        fprintf(fid,'\t%s',AutoDataProcessParameter.QC.RawT1ImgQC.QCComment{i,1});
        fprintf(fid,'\n');
    end
    fclose(fid);

    
    % Apply Reorient Mats (after T1-Fun coregistration) to functional images and/or the voxel-specific head motion files
    parfor i=1:AutoDataProcessParameter.SubjectNum
        % In case there exist reorient matrix (interactive reorient after T1-Fun coregistration)
        ReorientMat=eye(4);
        if exist([AutoDataProcessParameter.DataProcessDir,filesep,'ReorientMats'],'dir')==7
            if exist([AutoDataProcessParameter.DataProcessDir,filesep,'ReorientMats',filesep,AutoDataProcessParameter.SubjectID{i},'_ReorientT1FunAfterCoregMat.mat'],'file')==2
                ReorientMat_Interactively = load([AutoDataProcessParameter.DataProcessDir,filesep,'ReorientMats',filesep,AutoDataProcessParameter.SubjectID{i},'_ReorientT1FunAfterCoregMat.mat']);
                ReorientMat=ReorientMat_Interactively.mat*ReorientMat;
            end
        end
           
        if ~all(all(ReorientMat==eye(4)))
            for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                %Apply to the functional images
                cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
                DirImg=dir('*.img');
                if isempty(DirImg)  %YAN Chao-Gan, 111114. Also support .nii files.
                    DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                    if length(DirImg)==1
                        gunzip(DirImg(1).name);
                        delete(DirImg(1).name);
                    end
                    DirImg=dir('*.nii');
                end
                
                for j=1:length(DirImg)
                    OldMat = spm_get_space(DirImg(j).name);
                    spm_get_space(DirImg(j).name,ReorientMat*OldMat);
                end
                if length(DirImg)==1 % delete the .mat file generated by spm_get_space for 4D nii images
                    if exist([DirImg(j).name(1:end-4),'.mat'],'file')==2
                        delete([DirImg(j).name(1:end-4),'.mat']);
                    end
                end
                
                %Apply to voxel-specific head motion files
                if (7==exist([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'VoxelSpecificHeadMotion',filesep,AutoDataProcessParameter.SubjectID{i}],'dir'))
                    cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'VoxelSpecificHeadMotion',filesep,AutoDataProcessParameter.SubjectID{i}]);
                    DirImg=dir('*.nii');
                    
                    for j=1:length(DirImg)
                        OldMat = spm_get_space(DirImg(j).name);
                        spm_get_space(DirImg(j).name,ReorientMat*OldMat);
                        if exist([DirImg(j).name(1:end-4),'.mat'],'file')==2
                            delete([DirImg(j).name(1:end-4),'.mat']);
                        end
                    end
                end
                FileNameTemp = [AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'MeanVoxelSpecificHeadMotion_MeanTDvox',filesep,'MeanTDvox_',AutoDataProcessParameter.SubjectID{i},'.nii'];
                if exist(FileNameTemp,'file')==2
                    OldMat = spm_get_space(FileNameTemp);
                    spm_get_space(FileNameTemp,ReorientMat*OldMat);
                end
                FileNameTemp = [AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'MeanVoxelSpecificHeadMotion_MeanFDvox',filesep,'MeanFDvox_',AutoDataProcessParameter.SubjectID{i},'.nii'];
                if exist(FileNameTemp,'file')==2
                    OldMat = spm_get_space(FileNameTemp);
                    spm_get_space(FileNameTemp,ReorientMat*OldMat);
                end
                
            end
        end

        fprintf('Apply Reorient Mats (after T1-Fun coregistration) to functional images for %s: OK\n',AutoDataProcessParameter.SubjectID{i});
    end

end
if ~isempty(Error)
    disp(Error);
    return;
end


%Generating AutoMasks %140401
if (AutoDataProcessParameter.IsAutoMask==1)
    fprintf('Generating AutoMasks begin...\n');
    mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'AutoMasks'])
    
    for i=1:AutoDataProcessParameter.SubjectNum
        
        for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
            %Apply to the functional images
            cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
            
            InputDir = [AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}];
            
            OutputFile = [AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'AutoMasks',filesep,FunSessionPrefixSet{iFunSession},'AutoMask_',AutoDataProcessParameter.SubjectID{i},'.nii'];

            HasDocker = system('which docker'); %Test if docker installed, I will use AFNI's 3dautomask %YAN CHao-Gan, 211011
            if HasDocker == 0
                CommandInit=sprintf('docker run -ti --rm -v %s:/opt/freesurfer/license.txt -v %s:/data -e SUBJECTS_DIR=/data/freesurfer cgyan/dpabi', fullfile(DPABIPath, 'DPABISurf', 'FreeSurferLicense', 'license.txt'), AutoDataProcessParameter.DataProcessDir);
                if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
                    CommandInit=sprintf('export SUBJECTS_DIR=%s/freesurfer && ', WorkingDir);
                end
                DirFile=dir([InputDir,filesep,'*.nii']);
                InputFilename=[InputDir,filesep,DirFile(1).name];
                
                InputFilename = strrep(InputFilename,AutoDataProcessParameter.DataProcessDir,'/data'); %Replace the path for docker
                OutputFile = strrep(OutputFile,AutoDataProcessParameter.DataProcessDir,'/data');
                Command = [CommandInit, ' 3dAutomask -prefix ',OutputFile,' ',InputFilename];
                system(Command);
            else
                w_Automask(InputDir, OutputFile);
            end
            
        end
        
        fprintf('Generating AutoMasks for %s: OK\n',AutoDataProcessParameter.SubjectID{i});
    end

    fprintf('Generating AutoMasks finished\n');
end



% Segmentation
if (AutoDataProcessParameter.IsSegment>=1)
    if AutoDataProcessParameter.IsSegment==1
        T1ImgSegmentDirectoryName = 'T1ImgSegment';
    elseif AutoDataProcessParameter.IsSegment==2
        T1ImgSegmentDirectoryName = 'T1ImgNewSegment';
    end
    if 7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{1}],'dir')
        DirT1ImgCoreg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{1},filesep,'*.img']);
        if isempty(DirT1ImgCoreg)  %YAN Chao-Gan, 111114. Also support .nii files.
            DirT1ImgCoreg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{1},filesep,'*.nii.gz']);
            if length(DirT1ImgCoreg)==1
                gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{1},filesep,DirImg(1).name]);
                delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{1},filesep,DirImg(1).name]);
            end
            DirT1ImgCoreg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{1},filesep,'*.nii']);
        end
    else
        DirT1ImgCoreg=[];
    end
    if isempty(DirT1ImgCoreg)
        
        %Backup the T1 images to T1ImgSegment or T1ImgNewSegment
        % Check if co* image exist. Added by YAN Chao-Gan 100510.
        if ~exist('UseNoCoT1Image','var')
            cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{1}]);
            DirCo=dir('c*.img');
            if isempty(DirCo)
                DirCo=dir('c*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirCo)==1
                    gunzip(DirCo(1).name);
                    delete(DirCo(1).name);
                end
                DirCo=dir('c*.nii');  %YAN Chao-Gan, 111114. Also support .nii files.
                if isempty(DirCo)
                    DirCo=dir('*Crop*.nii');  %YAN Chao-Gan, 191121. Support BIDS format.
                end
                
            end
            if isempty(DirCo)
                DirImg=dir('*.img');
                if isempty(DirImg)  %YAN Chao-Gan, 111114. Also support .nii files.
                    DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                    if length(DirImg)>=1
                        for j=1:length(DirImg)
                            gunzip(DirImg(j).name);
                            delete(DirImg(j).name);
                        end
                    end
                    DirImg=dir('*.nii');
                end
                if length(DirImg)==1
                    button = questdlg(['No co* T1 image (T1 image which is reoriented to the nearest orthogonal direction to ''canonical space'' and removed excess air surrounding the individual as well as parts of the neck below the cerebellum) is found. Do you want to use the T1 image without co? Such as: ',DirImg(1).name,'?'],'No co* T1 image is found','Yes','No','Yes');
                    if strcmpi(button,'Yes')
                        UseNoCoT1Image=1;
                    else
                        return;
                    end
                elseif length(DirImg)==0
                    errordlg(['No T1 image has been found.'],'No T1 image has been found');
                    return;
                else
                    errordlg(['No co* T1 image (T1 image which is reoriented to the nearest orthogonal direction to ''canonical space'' and removed excess air surrounding the individual as well as parts of the neck below the cerebellum) is found. And there are too many T1 images detected in T1Img directory. Please determine which T1 image you want to use and delete the others from the T1Img directory, then re-run the analysis.'],'No co* T1 image is found');
                    return;
                end
            else
                UseNoCoT1Image=0;
            end
        end
        
        parfor i=1:AutoDataProcessParameter.SubjectNum
            cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i}]);
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i}])
            % Check in co* image exist. Added by YAN Chao-Gan 100510.
            if UseNoCoT1Image==0
                DirImg=dir('c*.img');
                if ~isempty(DirImg)  %YAN Chao-Gan, 111114
                    copyfile('c*.hdr',[AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i}])
                    copyfile('c*.img',[AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i}])
                else
                    DirImg=dir('c*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                    if length(DirImg)==1
                        gunzip(DirImg(1).name);
                        delete(DirImg(1).name);
                    end
                    
                    DirImg=dir('c*.nii');
                    if ~isempty(DirImg)
                        copyfile('c*.nii',[AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i}])
                    else
                        copyfile('*Crop*.nii',[AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i}])
                    end
                end
            else
                DirImg=dir('*.img');
                if ~isempty(DirImg)  %YAN Chao-Gan, 111114
                    copyfile('*.hdr',[AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i}])
                    copyfile('*.img',[AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i}])
                else
                    DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                    if length(DirImg)>=1
                        for j=1:length(DirImg)
                            gunzip(DirImg(j).name);
                            delete(DirImg(j).name);
                        end
                    end
                    copyfile('*.nii',[AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i}])
                end
            end
            fprintf(['Copying T1 image Files from "T1Img" to',T1ImgSegmentDirectoryName,': ',AutoDataProcessParameter.SubjectID{i},' OK']);
        end
        fprintf('\n');
        
        
    else  % T1ImgCoreg exists
        cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg']);
        parfor i=1:AutoDataProcessParameter.SubjectNum
            cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i}]);
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i}])
            DirImg=dir('*.img');
            if ~isempty(DirImg)  %YAN Chao-Gan, 111114
                copyfile('*.hdr',[AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i}])
                copyfile('*.img',[AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i}])
            else
                DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirImg)>=1
                    for j=1:length(DirImg)
                        gunzip(DirImg(j).name);
                        delete(DirImg(j).name);
                    end
                end
                copyfile('*.nii',[AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i}])
            end
            cd('..');
            fprintf(['Copying coregistered T1 image Files from "T1ImgCoreg":',AutoDataProcessParameter.SubjectID{i},' OK']);
        end
        fprintf('\n');
    end
    T1SourceFileSet = cell(AutoDataProcessParameter.SubjectNum,1); % Save to use in the step of DARTEL normalize to MNI
    
    if AutoDataProcessParameter.IsSegment==1  %Segment
        cd([AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName]);
        parfor i=1:AutoDataProcessParameter.SubjectNum
            SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Segment.mat']);
            SourceDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.img']);
            if isempty(SourceDir)  %YAN Chao-Gan, 111114. Also support .nii files.
                SourceDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii']);
            end
            SourceFile=[AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,SourceDir(1).name];
            %SPMJOB.matlabbatch{1,1}.spm.spatial.preproc.opts.tpm={[SPMFilePath,filesep,'tpm',filesep,'grey.nii'];[SPMFilePath,filesep,'tpm',filesep,'white.nii'];[SPMFilePath,filesep,'tpm',filesep,'csf.nii']}; %YAN Chao-Gan, 161006.
            SPMJOB.matlabbatch{1,1}.spm.spatial.preproc.opts.tpm={[SPMFilePath,filesep,'toolbox',filesep,'OldSeg',filesep,'grey.nii'];[SPMFilePath,filesep,'toolbox',filesep,'OldSeg',filesep,'white.nii'];[SPMFilePath,filesep,'toolbox',filesep,'OldSeg',filesep,'csf.nii']}; %YAN Chao-Gan, 161006.
            SPMJOB.matlabbatch{1,1}.spm.spatial.preproc.data={SourceFile};
            SPMJOB.matlabbatch{1,1}.spm.spatial.preproc.opts.regtype = AutoDataProcessParameter.Segment.AffineRegularisationInSegmentation;
%             if strcmpi(AutoDataProcessParameter.Segment.AffineRegularisationInSegmentation,'mni')   %Added by YAN Chao-Gan 091110. Use different Affine Regularisation in Segmentation: East Asian brains (eastern) or European brains (mni).
%                 SPMJOB.matlabbatch{1,1}.spm.spatial.preproc.opts.regtype='mni';
%             else
%                 SPMJOB.matlabbatch{1,1}.spm.spatial.preproc.opts.regtype='eastern';
%             end
            T1SourceFileSet{i} = SourceFile;%YAN Chao-Gan 121218.
            fprintf(['Segment Setup:',AutoDataProcessParameter.SubjectID{i},' OK']);

            %YAN Chao-Gan, 140815. Monkey mode.
            if isfield(AutoDataProcessParameter,'SpecialMode') && (AutoDataProcessParameter.SpecialMode == 2)  %Special Mode: Monkey
                SPMJOB.matlabbatch{1,1}.spm.spatial.preproc.opts.tpm={[TemplatePath,filesep,'WisconsinRhesusMacaqueAtlases',filesep,'gm_priors_ohsu+uw.nii'];[TemplatePath,filesep,'WisconsinRhesusMacaqueAtlases',filesep,'wm_priors_ohsu+uw.nii'];[TemplatePath,filesep,'WisconsinRhesusMacaqueAtlases',filesep,'csf_priors_ohsu+uw.nii']};
                SPMJOB.matlabbatch{1,1}.spm.spatial.preproc.opts.regtype = 'subj';
                SPMJOB.matlabbatch{1,1}.spm.spatial.preproc.opts.samp = 2;
            end

            fprintf('\n');

            if SPMversion==12    % YAN Chao-Gan, 150703. In SPM 12, Segment (in SPM8) has turned to Old Segment.
                oldseg = SPMJOB.matlabbatch{1,1}.spm.spatial.preproc;
                if (~isfield(AutoDataProcessParameter,'SpecialMode')) || (isfield(AutoDataProcessParameter,'SpecialMode') && (AutoDataProcessParameter.SpecialMode == 1))
                    oldseg.opts.tpm={[SPMFilePath,filesep,'toolbox',filesep,'OldSeg',filesep,'grey.nii'];[SPMFilePath,filesep,'toolbox',filesep,'OldSeg',filesep,'white.nii'];[SPMFilePath,filesep,'toolbox',filesep,'OldSeg',filesep,'csf.nii']};
                end
                SPMJOB=[];
                SPMJOB.matlabbatch{1,1}.spm.tools.oldseg = oldseg;
            end
            
            try %YAN Chao-Gan, 210414. Let's report who failed segmentation.
                spm_jobman('run',SPMJOB.matlabbatch);
            catch e
                fprintf(1,'There was an error! The message was:\n%s',e.message);
                fprintf(1,'\nThis subject failed segmentation: %s!!! Please check!!!\n\n',AutoDataProcessParameter.SubjectID{i});
                error('Error detected during segmentation, please read the above information carefully!');
            end
        end

    elseif AutoDataProcessParameter.IsSegment==2  %New Segment in SPM8 %YAN Chao-Gan, 111111.

        cd([AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName]);
        parfor i=1:AutoDataProcessParameter.SubjectNum
            
            SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'NewSegment.mat']);
            for T1ImgSegmentDirectoryNameue=1:6
                %SPMJOB.matlabbatch{1,1}.spm.tools.preproc8.tissue(1,T1ImgSegmentDirectoryNameue).tpm{1,1}=[SPMFilePath,filesep,'toolbox',filesep,'Seg',filesep,'TPM.nii',',',num2str(T1ImgSegmentDirectoryNameue)];
                SPMJOB.matlabbatch{1,1}.spm.tools.preproc8.tissue(1,T1ImgSegmentDirectoryNameue).tpm{1,1}=[SPMFilePath,filesep,'tpm',filesep,'TPM.nii',',',num2str(T1ImgSegmentDirectoryNameue)]; %YAN Chao-Gan, 161006.
                SPMJOB.matlabbatch{1,1}.spm.tools.preproc8.tissue(1,T1ImgSegmentDirectoryNameue).warped = [0 0]; % Do not need warped results. Warp by DARTEL
            end
            
            SPMJOB.matlabbatch{1,1}.spm.tools.preproc8.warp.affreg = AutoDataProcessParameter.Segment.AffineRegularisationInSegmentation;
%             if strcmpi(AutoDataProcessParameter.Segment.AffineRegularisationInSegmentation,'mni')   %Added by YAN Chao-Gan 091110. Use different Affine Regularisation in Segmentation: East Asian brains (eastern) or European brains (mni).
%                 SPMJOB.matlabbatch{1,1}.spm.tools.preproc8.warp.affreg='mni';
%             else
%                 SPMJOB.matlabbatch{1,1}.spm.tools.preproc8.warp.affreg='eastern';
%             end

            SourceDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.img']);
            if isempty(SourceDir)  %YAN Chao-Gan, 111114. Also support .nii files.
                SourceDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii']);
            end
            SourceFile=[AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,SourceDir(1).name];

            SPMJOB.matlabbatch{1,1}.spm.tools.preproc8.channel.vols={SourceFile};
            T1SourceFileSet{i} = SourceFile;
            fprintf(['Segment Setup:',AutoDataProcessParameter.SubjectID{i},' OK\n']);
            
            
            if SPMversion==12    % YAN Chao-Gan, 150703. In SPM 12, New Segment (in SPM8) has turned to normal Segment.
                preproc = SPMJOB.matlabbatch{1,1}.spm.tools.preproc8;
                %Set the TPMs
                for T1ImgSegmentDirectoryNameue=1:6
                    preproc.tissue(1,T1ImgSegmentDirectoryNameue).tpm{1,1}=[SPMFilePath,filesep,'tpm',filesep,'TPM.nii',',',num2str(T1ImgSegmentDirectoryNameue)];
                    preproc.tissue(1,T1ImgSegmentDirectoryNameue).warped = [0 0]; % Do not need warped results. Warp by DARTEL
                end
                
                %Set the new parameters in SPM12 to default
                preproc.warp.mrf = 1;
                preproc.warp.cleanup = 1;
                preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
                preproc.warp.fwhm = 0;
                SPMJOB=[];
                SPMJOB.matlabbatch{1,1}.spm.spatial.preproc = preproc;
            end
            
            try %YAN Chao-Gan, 210414. Let's report who failed segmentation.
                spm_jobman('run',SPMJOB.matlabbatch);
            catch e
                fprintf(1,'There was an error! The message was:\n%s',e.message);
                fprintf(1,'\nThis subject failed segmentation: %s!!! Please check!!!\n\n',AutoDataProcessParameter.SubjectID{i});
                error('Error detected during segmentation, please read the above information carefully!');
            end
        end
        
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DARTEL and Normalize VBM results. %YAN Chao-Gan, 111111.
%Do Not Need Parfor
if (AutoDataProcessParameter.IsDARTEL==1)
    %DARTEL: Create Template
    SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Dartel_CreateTemplate.mat']);
    %Look for rc1* and rc2* images.
    cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment']);
    rc1FileList=[];
    rc2FileList=[];
    for i=1:AutoDataProcessParameter.SubjectNum
        cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i}]);
        DirImg=dir('rc1*');
        rc1FileList=[rc1FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]}];
        DirImg=dir('rc2*');
        rc2FileList=[rc2FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]}];
        cd('..');
    end
    SPMJOB.matlabbatch{1,1}.spm.tools.dartel.warp.images{1,1}=rc1FileList;
    SPMJOB.matlabbatch{1,1}.spm.tools.dartel.warp.images{1,2}=rc2FileList;
    fprintf(['Running DARTEL: Create Template.\n']);
    spm_jobman('run',SPMJOB.matlabbatch);
    
    % DARTEL: Normalize to MNI space - GM, WM, CSF and T1 Images.
    SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Dartel_NormaliseToMNI_ManySubjects.mat']);
    cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment']);
    FlowFieldFileList=[];
    GMFileList=[];
    WMFileList=[];
    CSFFileList=[];
    for i=1:AutoDataProcessParameter.SubjectNum
        cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i}]);
        DirImg=dir('u_*');
        FlowFieldFileList=[FlowFieldFileList;{[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]}];
        DirImg=dir('c1*');
        GMFileList=[GMFileList;{[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]}];
        DirImg=dir('c2*');
        WMFileList=[WMFileList;{[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]}];
        DirImg=dir('c3*');
        CSFFileList=[CSFFileList;{[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]}];

        if i==1
            DirImg=dir('Template_6.*');
            TemplateFile={[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]};
        end
        cd('..');
    end
    
    SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.template=TemplateFile;
    SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subjs.flowfields=FlowFieldFileList;
    
    SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subjs.images{1,1}=GMFileList;
    SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subjs.images{1,2}=WMFileList;
    SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subjs.images{1,3}=CSFFileList;
    
    fprintf(['Running DARTEL: Normalize to MNI space for VBM. Modulated version With smooth kernel [8 8 8].\n']);
    spm_jobman('run',SPMJOB.matlabbatch);
    
    SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.fwhm=[0 0 0]; % Do not want to perform smooth
    fprintf(['Running DARTEL: Normalize to MNI space for VBM. Modulated version.\n']);
    spm_jobman('run',SPMJOB.matlabbatch);
    
    SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.preserve = 0;
    if exist('T1SourceFileSet','var')
        SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subjs.images{1,4}=T1SourceFileSet;
    end
    fprintf(['Running DARTEL: Normalize to MNI space for VBM. Unmodulated version.\n']);
    spm_jobman('run',SPMJOB.matlabbatch);
    
end



%%%%
%Normalize the T1 image in the case of unified segmentation (No New Segment nor DARTEL)
%YAN Chao-Gan, 121217
if AutoDataProcessParameter.IsSegment==1
    for i=1:AutoDataProcessParameter.SubjectNum
        FileList = T1SourceFileSet(i);
        
        %Normalize-Write: Using the segment information
        SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Normalize_Write.mat']);
        
        MatFileDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*seg_sn.mat']);
        MatFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,MatFileDir(1).name];
        
        SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.write.subj(1,1).matname={MatFilename};
        SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.write.subj(1,1).resample=FileList;
        SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.write.roptions.bb=[-60 -40 -60;60 80 60];
        SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.write.roptions.vox=[0.5 0.5 0.5];
        
        spm_jobman('run',SPMJOB.matlabbatch);
        
        fprintf(['Normalize-Write T1 Image:',AutoDataProcessParameter.SubjectID{i},' OK\n']);
        
    end
    
end



%%%%%%%
%Genereated the masks based on Segmentation results
% YAN Chao-Gan, 140617

%Reslice WM and CSF masks to functional space.

if ((AutoDataProcessParameter.IsCovremove==1) && (strcmpi(AutoDataProcessParameter.Covremove.Timing,'AfterRealign')))
    T1ImgSegmentDirectoryName = '';
    if (7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgSegment',filesep,AutoDataProcessParameter.SubjectID{1}],'dir'))
        T1ImgSegmentDirectoryName = 'T1ImgSegment';
    elseif (7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1}],'dir'))
        T1ImgSegmentDirectoryName = 'T1ImgNewSegment';
    end
    
    if ~isempty(T1ImgSegmentDirectoryName)
        if ~(2==exist([AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_ThrdMask_',AutoDataProcessParameter.SubjectID{1},'_WM.nii'],'file'))
            % If have not generated previously.
            
            if ~(7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks'],'dir'))
                mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks']);
            end
            
            for i=1:AutoDataProcessParameter.SubjectNum
                DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.img']);
                if isempty(DirMean)  %YAN Chao-Gan, 111114. Also support .nii files.
                    DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.nii.gz']);% Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                    if length(DirMean)==1
                        gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name]);
                        delete([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name]);
                    end
                    DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.nii']);
                end
                RefFile = [AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name];
                [RefData,RefVox,RefHeader]=y_ReadRPI(RefFile,1);
                cd([AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i}]);
                
%                 DirImg=dir('c1*');
%                 [OutVolume OutHead] = y_Reslice([AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name],[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_',AutoDataProcessParameter.SubjectID{i},'_GM.nii'],RefVox,1, RefFile);
%                 OutHead.pinfo = [1;0;0]; OutHead.dt    =[16,0];
%                 y_Write(OutVolume,OutHead,[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_',AutoDataProcessParameter.SubjectID{i},'_GM.nii']);
%                 OutHead.pinfo = [1;0;0]; OutHead.dt    =[2,0];
%                 y_Write(OutVolume>GMThrd,OutHead,[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_ThrdMask_',AutoDataProcessParameter.SubjectID{i},'_GM.nii']);
%                 


                DirImg=dir('c2*.img');
                if isempty(DirImg)
                    DirImg=dir('c2*.nii.gz');
                    if length(DirImg)==1
                        gunzip(DirImg(1).name);
                        delete(DirImg(1).name);
                    end
                    DirImg=dir('c2*.nii');
                end

                %DirImg=dir('c2*'); %YAN Chao-Gan, 150820. Fixed the "File too small" error when .hdr/.img files are used.
                
                [OutVolume OutHead] = y_Reslice([AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name],[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_',AutoDataProcessParameter.SubjectID{i},'_WM.nii'],RefVox,1, RefFile);
                OutHead.pinfo = [1;0;0]; OutHead.dt    =[16,0];
                y_Write(OutVolume,OutHead,[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_',AutoDataProcessParameter.SubjectID{i},'_WM.nii']);
                OutHead.pinfo = [1;0;0]; OutHead.dt    =[2,0];
                y_Write(OutVolume>AutoDataProcessParameter.Covremove.WM.MaskThreshold,OutHead,[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_ThrdMask_',AutoDataProcessParameter.SubjectID{i},'_WM.nii']);
                
                
                DirImg=dir('c3*.img');
                if isempty(DirImg)
                    DirImg=dir('c3*.nii.gz');
                    if length(DirImg)==1
                        gunzip(DirImg(1).name);
                        delete(DirImg(1).name);
                    end
                    DirImg=dir('c3*.nii');
                end
                
                %DirImg=dir('c3*'); %YAN Chao-Gan, 150820. Fixed the "File too small" error when .hdr/.img files are used.
                
                [OutVolume OutHead] = y_Reslice([AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name],[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_',AutoDataProcessParameter.SubjectID{i},'_CSF.nii'],RefVox,1, RefFile);
                OutHead.pinfo = [1;0;0]; OutHead.dt    =[16,0];
                y_Write(OutVolume,OutHead,[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_',AutoDataProcessParameter.SubjectID{i},'_CSF.nii']);
                OutHead.pinfo = [1;0;0]; OutHead.dt    =[2,0];
                y_Write(OutVolume>AutoDataProcessParameter.Covremove.CSF.MaskThreshold,OutHead,[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_ThrdMask_',AutoDataProcessParameter.SubjectID{i},'_CSF.nii']);
                
            end
        end
    end
end






%%%%%%%%
% Warp the common-used masks into original space
% YAN Chao-Gan, 120822.

if (AutoDataProcessParameter.IsWarpMasksIntoIndividualSpace==1) || ((AutoDataProcessParameter.IsCovremove==1) && (strcmpi(AutoDataProcessParameter.Covremove.Timing,'AfterRealign')))
    if ~(2==exist([AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'WarpedMasks',filesep,AutoDataProcessParameter.SubjectID{1},'_','BrainMask_05_91x109x91','.nii'],'file'))
        % If have not warped by previous analysis.
        
        MasksName{1,1}=[TemplatePath,filesep,'BrainMask_05_91x109x91.img'];
        MasksName{2,1}=[TemplatePath,filesep,'CsfMask_07_91x109x91.img'];
        MasksName{3,1}=[TemplatePath,filesep,'WhiteMask_09_91x109x91.img'];
        MasksName{4,1}=[TemplatePath,filesep,'GreyMask_02_91x109x91.img'];
        
        if (isfield(AutoDataProcessParameter,'MaskFile')) && (~isempty(AutoDataProcessParameter.MaskFile)) && (~isequal(AutoDataProcessParameter.MaskFile, 'Default'))
            MasksName{5,1}=AutoDataProcessParameter.MaskFile;
        end
        
        if ~(7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'WarpedMasks'],'dir'))
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'WarpedMasks']);
        end
        
        if (7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1}],'dir')) 
            % If is processed by New Segment and DARTEL
            
            TemplateDir_SubID=AutoDataProcessParameter.SubjectID{1};
            if exist([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,TemplateDir_SubID,filesep,'Template_6.nii.gz'],'file') %YAN Chao-Gan, 151129. Check if it's .nii.gz
                gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,TemplateDir_SubID,filesep,'Template_6.nii.gz']);
                delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,TemplateDir_SubID,filesep,'Template_6.nii.gz']);
            end
            DARTELTemplateFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,TemplateDir_SubID,filesep,'Template_6.nii'];
            DARTELTemplateMatFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,TemplateDir_SubID,filesep,'Template_6_2mni.mat'];
            
            Interp=0;
            
            parfor i=1:AutoDataProcessParameter.SubjectNum
                
                DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'u_*']);
                [pathstr,name,ext] = fileparts(DirImg(1).name); %YAN Chao-Gan, 151129. Check if it's .nii.gz
                if strcmpi(ext,'.gz')
                    gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]);
                    delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]);
                    DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'u_*']);
                end
                FlowFieldFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name];

                % Set the reference image
                DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.img']);
                if isempty(DirMean)  %YAN Chao-Gan, 111114. Also support .nii files.
                    DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.nii.gz']);% Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                    if length(DirMean)==1
                        gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name]);
                        delete([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name]);
                    end
                    DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.nii']);
                end
                RefFile = [AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name];
                
                OutFile=[];
                for iMask=1:length(MasksName)
                    AMaskFilename = MasksName{iMask};
                    fprintf('\nWarp Masks (%s) for "%s" to individual space using DARTEL flow field (in T1ImgNewSegment) genereated by DARTEL.\n',AMaskFilename, AutoDataProcessParameter.SubjectID{i});
                    [pathstr, name, ext] = fileparts(AMaskFilename);
                    OutFile{iMask,1}=[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'WarpedMasks',filesep,AutoDataProcessParameter.SubjectID{i},'_',name,'.nii'];
                end
                
                y_WarpBackByDARTEL(MasksName,OutFile,RefFile,DARTELTemplateFilename,DARTELTemplateMatFilename,FlowFieldFilename,Interp);
                
            end
            
            
        elseif (7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgSegment',filesep,AutoDataProcessParameter.SubjectID{1}],'dir'))
            % If is processed by unified segmentation
            
            parfor i=1:AutoDataProcessParameter.SubjectNum
                
                % Set the reference image
                DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.img']);
                if isempty(DirMean)  %YAN Chao-Gan, 111114. Also support .nii files.
                    DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.nii.gz']);% Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                    if length(DirMean)==1
                        gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name]);
                        delete([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name]);
                    end
                    DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.nii']);
                end
                RefFile = [AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name];
                
                MatFileDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*seg_inv_sn.mat']);
                MatFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,MatFileDir(1).name];
                
                for iMask=1:length(MasksName)
                    AMaskFilename = MasksName{iMask};
                    fprintf('\nWarp Masks (%s) for "%s" to individual space using *seg_inv_sn.mat (in T1ImgSegment) genereated by T1 image segmentation.\n',AMaskFilename, AutoDataProcessParameter.SubjectID{i});
                    
                    [pathstr, name, ext] = fileparts(AMaskFilename);
                    
                    WarpedMaskName=[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'WarpedMasks',filesep,AutoDataProcessParameter.SubjectID{i},'_',name,'.nii'];
                    
                    y_NormalizeWrite(AMaskFilename,WarpedMaskName,RefFile,MatFilename,0);
                    AMaskFilename=WarpedMaskName;
                    
                end
                
            end
            
        end
        
    end
end



%Deal with the other covariables mask: warp into original space
if (AutoDataProcessParameter.IsCovremove==1) && ((strcmpi(AutoDataProcessParameter.Covremove.Timing,'AfterRealign'))||(AutoDataProcessParameter.IsWarpMasksIntoIndividualSpace==1))
    
    if ~isempty(AutoDataProcessParameter.Covremove.OtherCovariatesROI)
        
        if ~(7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'WarpedMasks'],'dir'))
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'WarpedMasks']);
        end
        
        % Check if masks appropriate %This can be used as a function!!! % ONLY WARP!!!
        OtherCovariatesROIForEachSubject=cell(AutoDataProcessParameter.SubjectNum,1);
        parfor i=1:AutoDataProcessParameter.SubjectNum
            Suffix='OtherCovariateROI_'; %%!!! Change as in Function
            SubjectROI=AutoDataProcessParameter.Covremove.OtherCovariatesROI;%%!!! Change as in Fuction

            % Set the reference image
            DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.img']);
            if isempty(DirMean)  %YAN Chao-Gan, 111114. Also support .nii files.
                DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.nii.gz']);% Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirMean)==1
                    gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name]);
                    delete([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name]);
                end
                DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.nii']);
            end
            RefFile = [AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name];

            % Ball to mask
            for iROI=1:length(SubjectROI)
                if strcmpi(int2str(size(SubjectROI{iROI})),int2str([1, 4]))  %Sphere ROI definition: CenterX, CenterY, CenterZ, Radius
                    ROIMaskName=[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'WarpedMasks',filesep,Suffix,num2str(iROI),'_',AutoDataProcessParameter.SubjectID{i},'.nii'];
                    y_Sphere(SubjectROI{iROI}(1:3), SubjectROI{iROI}(4), [TemplatePath,filesep,'aal.nii'], ROIMaskName);
                    SubjectROI{iROI}=[ROIMaskName];
                end
            end

            %Need to warp masks
            % Check if have .txt file. Note: the txt files should be put the last of the ROI definition
            NeedWarpMaskNameSet=[];
            WarpedMaskNameSet=[];
            for iROI=1:length(SubjectROI)
                if exist(SubjectROI{iROI},'file')==2
                    [pathstr, name, ext] = fileparts(SubjectROI{iROI});
                    if (~strcmpi(ext, '.txt'))
                        NeedWarpMaskNameSet=[NeedWarpMaskNameSet;{SubjectROI{iROI}}];
                        WarpedMaskNameSet=[WarpedMaskNameSet;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'WarpedMasks',filesep,Suffix,num2str(iROI),'_',AutoDataProcessParameter.SubjectID{i},'.nii']}];
                        
                        SubjectROI{iROI}=[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'WarpedMasks',filesep,Suffix,num2str(iROI),'_',AutoDataProcessParameter.SubjectID{i},'.nii'];
                    end
                end
            end

            if (7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1}],'dir'))
                % If is processed by New Segment and DARTEL
                
                TemplateDir_SubID=AutoDataProcessParameter.SubjectID{1};
                if exist([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,TemplateDir_SubID,filesep,'Template_6.nii.gz'],'file') %YAN Chao-Gan, 151129
                    gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,TemplateDir_SubID,filesep,'Template_6.nii.gz']);
                    delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,TemplateDir_SubID,filesep,'Template_6.nii.gz']);
                end
                DARTELTemplateFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,TemplateDir_SubID,filesep,'Template_6.nii'];
                DARTELTemplateMatFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,TemplateDir_SubID,filesep,'Template_6_2mni.mat'];
                
                DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'u_*']);
                [pathstr,name,ext] = fileparts(DirImg(1).name); %YAN Chao-Gan, 151129. Check if it's .nii.gz
                if strcmpi(ext,'.gz')
                    gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]);
                    delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]);
                    DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'u_*']);
                end
                FlowFieldFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name];
                
                if ~isempty(NeedWarpMaskNameSet) %YAN Chao-Gan, 180320. In case there was only txt ROI
                    y_WarpBackByDARTEL(NeedWarpMaskNameSet,WarpedMaskNameSet,RefFile,DARTELTemplateFilename,DARTELTemplateMatFilename,FlowFieldFilename,0);
                end
                
                for iROI=1:length(NeedWarpMaskNameSet)
                    fprintf('\nWarp %s Mask (%s) for "%s" to individual space using DARTEL flow field (in T1ImgNewSegment) genereated by DARTEL.\n',Suffix,NeedWarpMaskNameSet{iROI}, AutoDataProcessParameter.SubjectID{i});
                end
                
            elseif (7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgSegment',filesep,AutoDataProcessParameter.SubjectID{1}],'dir'))
                % If is processed by unified segmentation
                
                MatFileDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*seg_inv_sn.mat']);
                MatFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,MatFileDir(1).name];
                
                for iROI=1:length(NeedWarpMaskNameSet)
                    y_NormalizeWrite(NeedWarpMaskNameSet{iROI},WarpedMaskNameSet{iROI},RefFile,MatFilename,0);
                    fprintf('\nWarp %s Mask (%s) for "%s" to individual space using *seg_inv_sn.mat (in T1ImgSegment) genereated by T1 image segmentation.\n',Suffix,NeedWarpMaskNameSet{iROI}, AutoDataProcessParameter.SubjectID{i});
                end
                
            end
            
            
            % Check if the text file is a definition for multiple subjects. i.e., the first line is 'Covariables_List:', then get the corresponded covariables file
            for iROI=1:length(SubjectROI)
                if (ischar(SubjectROI{iROI})) && (exist(SubjectROI{iROI},'file')==2)
                    [pathstr, name, ext] = fileparts(SubjectROI{iROI});
                    if (strcmpi(ext, '.txt'))
                        fid = fopen(SubjectROI{iROI});
                        SeedTimeCourseList=textscan(fid,'%s\n'); %YAN Chao-Gan, 180320. For compatiblity of MALLAB 2014b. SeedTimeCourseList=textscan(fid,'%s','\n'); 
                        fclose(fid);
                        if strcmpi(SeedTimeCourseList{1}{1},'Covariables_List:')
                            SubjectROI{iROI}=SeedTimeCourseList{1}{i+1};
                        end
                    end
                end
                
            end
            
            OtherCovariatesROIForEachSubject{i}=SubjectROI; %%!!! Change as in Fuction

        end
        
        AutoDataProcessParameter.Covremove.OtherCovariatesROIForEachSubject = OtherCovariatesROIForEachSubject;
    end
end


%Remove the nuisance Covaribles
if (AutoDataProcessParameter.IsCovremove==1) && (strcmpi(AutoDataProcessParameter.Covremove.Timing,'AfterRealign'))
    
    %Remove the Covariables
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        parfor i=1:AutoDataProcessParameter.SubjectNum
            
            CovariablesDef=[];
            
            %Polynomial trends
            %0: constant
            %1: constant + linear trend
            %2: constant + linear trend + quadratic trend.
            %3: constant + linear trend + quadratic trend + cubic trend.   ...
            
            CovariablesDef.polort = AutoDataProcessParameter.Covremove.PolynomialTrend;

            %Head Motion Regressors
            ImgCovModel = 1; %Default
            CovariablesDef.CovMat=[];
            if (AutoDataProcessParameter.Covremove.HeadMotion==1) %1: Use the current time point of rigid-body 6 realign parameters. e.g., Txi, Tyi, Tzi...
                DirRP=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},'rp*']);
                Q1=load([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRP.name]);
                CovariablesDef.CovMat = Q1;
            elseif (AutoDataProcessParameter.Covremove.HeadMotion==2) %2: Use the current time point and the previous time point of rigid-body 6 realign parameters. e.g., Txi, Tyi, Tzi,..., Txi-1, Tyi-1, Tzi-1...
                DirRP=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},'rp*']);
                Q1=load([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRP.name]);
                CovariablesDef.CovMat = [Q1, [zeros(1,size(Q1,2));Q1(1:end-1,:)]];
            elseif (AutoDataProcessParameter.Covremove.HeadMotion==3) %3: Use the current time point and their squares of rigid-body 6 realign parameters. e.g., Txi, Tyi, Tzi,..., Txi^2, Tyi^2, Tzi^2...
                DirRP=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},'rp*']);
                Q1=load([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRP.name]);
                CovariablesDef.CovMat = [Q1,  Q1.^2];
            elseif (AutoDataProcessParameter.Covremove.HeadMotion==4) %4: Use the Friston 24-parameter model: current time point, the previous time point and their squares of rigid-body 6 realign parameters. e.g., Txi, Tyi, Tzi, ..., Txi-1, Tyi-1, Tzi-1,... and their squares (total 24 items). Friston autoregressive model (Friston, K.J., Williams, S., Howard, R., Frackowiak, R.S., Turner, R., 1996. Movement-related effects in fMRI time-series. Magn Reson Med 35, 346-355.)
                DirRP=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},'rp*']);
                Q1=load([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRP.name]);
                CovariablesDef.CovMat = [Q1, [zeros(1,size(Q1,2));Q1(1:end-1,:)], Q1.^2, [zeros(1,size(Q1,2));Q1(1:end-1,:)].^2];
            elseif (AutoDataProcessParameter.Covremove.HeadMotion>=11) %11-14: Use the voxel-specific models. 14 is the voxel-specific 12 model.
                
                HMvoxDir=[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'VoxelSpecificHeadMotion',filesep,AutoDataProcessParameter.SubjectID{i}];
                
                CovariablesDef.CovImgDir = {[HMvoxDir,filesep,'HMvox_X_4DVolume.nii'];[HMvoxDir,filesep,'HMvox_Y_4DVolume.nii'];[HMvoxDir,filesep,'HMvox_Z_4DVolume.nii']};
                
                ImgCovModel = AutoDataProcessParameter.Covremove.HeadMotion - 10;
                
            end
            
            
            %Head Motion "Scrubbing" Regressors: each bad time point is a separate regressor
            if (AutoDataProcessParameter.Covremove.IsHeadMotionScrubbingRegressors==1)

                % Use FD_Power or FD_Jenkinson. YAN Chao-Gan, 121225.
                FD = load([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.Covremove.HeadMotionScrubbingRegressors.FDType,'_',AutoDataProcessParameter.SubjectID{i},'.txt']);
                %FD = load([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},'FD_Power_',AutoDataProcessParameter.SubjectID{i},'.txt']);
                
                
                TemporalMask=ones(length(FD),1);
                Index=find(FD > AutoDataProcessParameter.Covremove.HeadMotionScrubbingRegressors.FDThreshold);
                TemporalMask(Index)=0;
                IndexPrevious=Index;
                for iP=1:AutoDataProcessParameter.Covremove.HeadMotionScrubbingRegressors.PreviousPoints
                    IndexPrevious=IndexPrevious-1;
                    IndexPrevious=IndexPrevious(IndexPrevious>=1);
                    TemporalMask(IndexPrevious)=0;
                end
                IndexNext=Index;
                for iN=1:AutoDataProcessParameter.Covremove.HeadMotionScrubbingRegressors.LaterPoints
                    IndexNext=IndexNext+1;
                    IndexNext=IndexNext(IndexNext<=length(FD));
                    TemporalMask(IndexNext)=0;
                end
                
                BadTimePointsIndex = find(TemporalMask==0);
                BadTimePointsRegressor = zeros(length(FD),length(BadTimePointsIndex));
                for iBadTimePoints = 1:length(BadTimePointsIndex)
                    BadTimePointsRegressor(BadTimePointsIndex(iBadTimePoints),iBadTimePoints) = 1;
                end
                
                CovariablesDef.CovMat = [CovariablesDef.CovMat, BadTimePointsRegressor];
            end

            
            %Mask covariates CompCor methods %YAN Chao-Gan, 140628. Deal with different kind of nuisance covarites.
            CompCorMasks = [];
            if (AutoDataProcessParameter.Covremove.WM.IsRemove==1) && strcmpi(AutoDataProcessParameter.Covremove.WM.Method,'CompCor')
                if strcmpi(AutoDataProcessParameter.Covremove.WM.Mask,'SPM')
                    CompCorMasks=[CompCorMasks;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'WarpedMasks',filesep,AutoDataProcessParameter.SubjectID{i},'_WhiteMask_09_91x109x91.nii']}];
                elseif strcmpi(AutoDataProcessParameter.Covremove.WM.Mask,'Segment')
                    CompCorMasks=[CompCorMasks;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_ThrdMask_',AutoDataProcessParameter.SubjectID{i},'_WM.nii']}];
                end
            end
            if (AutoDataProcessParameter.Covremove.CSF.IsRemove==1) && strcmpi(AutoDataProcessParameter.Covremove.CSF.Method,'CompCor')
                if strcmpi(AutoDataProcessParameter.Covremove.CSF.Mask,'SPM')
                    CompCorMasks=[CompCorMasks;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'WarpedMasks',filesep,AutoDataProcessParameter.SubjectID{i},'_CsfMask_07_91x109x91.nii']}];
                elseif strcmpi(AutoDataProcessParameter.Covremove.CSF.Mask,'Segment')
                    CompCorMasks=[CompCorMasks;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_ThrdMask_',AutoDataProcessParameter.SubjectID{i},'_CSF.nii']}];
                end
            end
            if ~isempty(CompCorMasks)
                if ~(7==exist([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'Covs'],'dir'))
                    mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'Covs']);
                end
                [PCs] = y_CompCor_PC([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}],CompCorMasks, [AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'Covs',filesep,AutoDataProcessParameter.SubjectID{i},'_CompCorPCs'], AutoDataProcessParameter.Covremove.CSF.CompCorPCNum);
                %[PCs] = y_CompCor_PC(ADataDir,Nuisance_MaskFilename, OutputName, PCNum, IsNeedDetrend, Band, TR, IsVarianceNormalization)
                %IsNeedDetrend and IsVarianceNormalization defaulted to 1
                
                CovariablesDef.CovMat = [CovariablesDef.CovMat, PCs];
            end
            
            
            %Mask covariates %YAN Chao-Gan, 140628. Deal with different kind of nuisance covarites.
            SubjectCovariatesROI=[];
            
            if (AutoDataProcessParameter.Covremove.WM.IsRemove==1) && strcmpi(AutoDataProcessParameter.Covremove.WM.Method,'Mean')
                if strcmpi(AutoDataProcessParameter.Covremove.WM.Mask,'SPM')
                    SubjectCovariatesROI=[SubjectCovariatesROI;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'WarpedMasks',filesep,AutoDataProcessParameter.SubjectID{i},'_WhiteMask_09_91x109x91.nii']}];
                elseif strcmpi(AutoDataProcessParameter.Covremove.WM.Mask,'Segment')
                    SubjectCovariatesROI=[SubjectCovariatesROI;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_ThrdMask_',AutoDataProcessParameter.SubjectID{i},'_WM.nii']}];
                end
            end
            
            if (AutoDataProcessParameter.Covremove.CSF.IsRemove==1) && strcmpi(AutoDataProcessParameter.Covremove.CSF.Method,'Mean')
                if strcmpi(AutoDataProcessParameter.Covremove.CSF.Mask,'SPM')
                    SubjectCovariatesROI=[SubjectCovariatesROI;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'WarpedMasks',filesep,AutoDataProcessParameter.SubjectID{i},'_CsfMask_07_91x109x91.nii']}];
                elseif strcmpi(AutoDataProcessParameter.Covremove.CSF.Mask,'Segment')
                    SubjectCovariatesROI=[SubjectCovariatesROI;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_ThrdMask_',AutoDataProcessParameter.SubjectID{i},'_CSF.nii']}];
                end
            end
            
            
            if (AutoDataProcessParameter.Covremove.WholeBrain.IsRemove==1)
                if strcmpi(AutoDataProcessParameter.Covremove.WholeBrain.Mask,'SPM')
                    SubjectCovariatesROI=[SubjectCovariatesROI;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'WarpedMasks',filesep,AutoDataProcessParameter.SubjectID{i},'_BrainMask_05_91x109x91.nii']}];
                elseif strcmpi(AutoDataProcessParameter.Covremove.WholeBrain.Mask,'AutoMask')
                    SubjectCovariatesROI=[SubjectCovariatesROI;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'AutoMasks',filesep,FunSessionPrefixSet{iFunSession},'AutoMask_',AutoDataProcessParameter.SubjectID{i},'.nii']}];
                end
            end
                 

            % Add the other Covariate ROIs
            if ~isempty(AutoDataProcessParameter.Covremove.OtherCovariatesROI)
                SubjectCovariatesROI=[SubjectCovariatesROI;AutoDataProcessParameter.Covremove.OtherCovariatesROIForEachSubject{i}];
            end
            
            if ~(7==exist([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'Covs'],'dir'))
                mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'Covs']);
            end
            
            %Extract Time course for the Mask covariates
            if ~isempty(SubjectCovariatesROI)

                y_ExtractROISignal([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}], SubjectCovariatesROI, [AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'Covs',filesep,AutoDataProcessParameter.SubjectID{i}], '', 1);             
                
                CovariablesDef.ort_file=[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'Covs',filesep,'ROISignals_',AutoDataProcessParameter.SubjectID{i},'.txt'];
            end
            
            CovariablesDef.IsAddMeanBack = AutoDataProcessParameter.Covremove.IsAddMeanBack; %YAN Chao-Gan, 160415: Add the option of "Add Mean Back".
            
            %Regressing out the covariates
            fprintf('\nRegressing out covariates for subject %s %s.\n',AutoDataProcessParameter.SubjectID{i},FunSessionPrefixSet{iFunSession});
            [Covariables] = y_RegressOutImgCovariates([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}],CovariablesDef,'_Covremoved','', ImgCovModel);

            Covariables = double(Covariables);
            y_CallSave([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'Covs',filesep,'Covariables',AutoDataProcessParameter.SubjectID{i},'.mat'], Covariables, '');
            y_CallSave([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'Covs',filesep,'Covariables',AutoDataProcessParameter.SubjectID{i},'.txt'], Covariables, ' ''-ASCII'', ''-DOUBLE'',''-TABS''');

        end
        fprintf('\n');
    end
    
    
    %Copy the Covariates Removed files to DataProcessDir\{AutoDataProcessParameter.StartingDirName}+C
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        parfor i=1:AutoDataProcessParameter.SubjectNum
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'C',filesep,AutoDataProcessParameter.SubjectID{i}])
            movefile([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}, '_Covremoved',filesep,'*'],[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'C',filesep,AutoDataProcessParameter.SubjectID{i}])

            rmdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}, '_Covremoved']);
            fprintf(['Moving Coviables Removed Files:',AutoDataProcessParameter.SubjectID{i},' OK']);
        end
        fprintf('\n');
    end
    AutoDataProcessParameter.StartingDirName=[AutoDataProcessParameter.StartingDirName,'C']; %Now StartingDirName is with new suffix 'C'
    
end


%Filter
if (AutoDataProcessParameter.IsFilter==1) && (strcmpi(AutoDataProcessParameter.Filter.Timing,'BeforeNormalize'))
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        parfor i=1:AutoDataProcessParameter.SubjectNum

            if AutoDataProcessParameter.TR==0  % Need to retrieve the TR information from the NIfTI images
                TR = AutoDataProcessParameter.TRSet(i,iFunSession);
            else
                TR = AutoDataProcessParameter.TR;
            end
            
            
            y_bandpass([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}], ...
                TR, ...  
                AutoDataProcessParameter.Filter.ALowPass_HighCutoff, ...
                AutoDataProcessParameter.Filter.AHighPass_LowCutoff, ...
                AutoDataProcessParameter.Filter.AAddMeanBack, ...   
                ''); % Just don't use mask in filtering. %AutoDataProcessParameter.Filter.AMaskFilename);
        end
    end
    
    %Copy the Filtered files to DataProcessDir\{AutoDataProcessParameter.StartingDirName}+F
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        parfor i=1:AutoDataProcessParameter.SubjectNum
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'F',filesep,AutoDataProcessParameter.SubjectID{i}])
            movefile([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}, '_filtered',filesep,'*'],[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'F',filesep,AutoDataProcessParameter.SubjectID{i}])

            rmdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}, '_filtered']);
            fprintf(['Moving Filtered Files:',AutoDataProcessParameter.SubjectID{i},' OK']);
        end
        fprintf('\n');
    end
    AutoDataProcessParameter.StartingDirName=[AutoDataProcessParameter.StartingDirName,'F']; %Now StartingDirName is with new suffix 'F'
    
end
    


%Normalize on functional data
if (AutoDataProcessParameter.IsNormalize>0) && strcmpi(AutoDataProcessParameter.Normalize.Timing,'OnFunctionalData')
    parfor i=1:AutoDataProcessParameter.SubjectNum
        FileList=[];
        for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
            cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
            DirImg=dir('*.img');
            if isempty(DirImg)  %YAN Chao-Gan, 111114. Also support .nii files. % Either in .nii.gz or in .nii
                DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirImg)==1
                    gunzip(DirImg(1).name);
                    delete(DirImg(1).name);
                end
                DirImg=dir('*.nii');
            end
            
            if length(DirImg)>1  %3D .img or .nii images.
                if AutoDataProcessParameter.TimePoints>0 && length(DirImg)~=AutoDataProcessParameter.TimePoints % Will not check if TimePoints set to 0. YAN Chao-Gan 120806.
                    Error=[Error;{['Error in Normalize, time point number doesn''t match: ',AutoDataProcessParameter.SubjectID{i}]}];
                end
                for j=1:length(DirImg)
                    FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(j).name]}];
                end
            else %4D .nii images
                Nii  = nifti(DirImg(1).name);
                if AutoDataProcessParameter.TimePoints>0 && size(Nii.dat,4)~=AutoDataProcessParameter.TimePoints % Will not check if TimePoints set to 0. YAN Chao-Gan 120806.
                    Error=[Error;{['Error in Normalize, time point number doesn''t match: ',AutoDataProcessParameter.SubjectID{i}]}];
                end
                FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]}];
                %YAN Chao-Gan, 130301. Fixed a bug (leave session 1) in normalization in multiple sessions.  %FileList={[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]};

            end
        end
        
        % Set the mean functional image % YAN Chao-Gan, 120826
        DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.img']);
        if isempty(DirMean)  %YAN Chao-Gan, 111114. Also support .nii files.
            DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.nii.gz']);% Search .nii.gz and unzip; YAN Chao-Gan, 120806.
            if length(DirMean)==1
                gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name]);
                delete([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name]);
            end
            DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.nii']);
        end
        MeanFilename = [AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name];
        
        FileList=[FileList;{MeanFilename}]; %YAN Chao-Gan, 120826. Also normalize the mean functional image.
        
        %Set the automasks to be normalized. %YAN Chao-Gan, 140401.
        if (7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'AutoMasks'],'dir'))
            for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                AutomaskFile = [AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'AutoMasks',filesep,FunSessionPrefixSet{iFunSession},'AutoMask_',AutoDataProcessParameter.SubjectID{i},'.nii'];
                AutomaskFileDir = dir(AutomaskFile); %YAN Chao-Gan, 181116. In case Automask.nii was zipped.
                if isempty(AutomaskFileDir)
                    gunzip([AutomaskFile,'.gz']);
                    delete([AutomaskFile,'.gz']);
                end
                FileList=[FileList;{AutomaskFile}];
            end
        end
        
        
        
        if (AutoDataProcessParameter.IsNormalize==1) %Normalization by using the EPI template directly
            
            SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Normalize.mat']);
            
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.subj(1,1).source={MeanFilename};
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.subj(1,1).resample=FileList;
            
            %SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.eoptions.template={[SPMFilePath,filesep,'templates',filesep,'EPI.nii,1']};
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.eoptions.template={[SPMFilePath,filesep,'toolbox',filesep,'OldNorm',filesep,'EPI.nii,1']}; %YAN Chao-Gan, 161006.
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.roptions.bb=AutoDataProcessParameter.Normalize.BoundingBox;
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.roptions.vox=AutoDataProcessParameter.Normalize.VoxSize;
            
            %YAN Chao-Gan, 140815.
            if isfield(AutoDataProcessParameter,'SpecialMode') && (AutoDataProcessParameter.SpecialMode == 2)  %Special Mode: Monkey
                SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.eoptions.template={[TemplatePath,filesep,'WisconsinRhesusMacaqueAtlases',filesep,'112RM-SL_T2.nii,1']};
            end
            
            %YAN Chao-Gan, 150515.
            if isfield(AutoDataProcessParameter,'SpecialMode') && (AutoDataProcessParameter.SpecialMode == 3)  %Special Mode: Rat
                SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.eoptions.template={[TemplatePath,filesep,'SchwarzRatTemplates',filesep,'rat97t2w_96x96x30.v6.nii,1']};
            end
            
            fprintf(['Normalize:',AutoDataProcessParameter.SubjectID{i},' OK\n']);
            
            if SPMversion==12    % YAN Chao-Gan, 150703. In SPM 12, Segment (in SPM8) has turned to Old Segment.
                oldnorm = SPMJOB.matlabbatch{1,1}.spm.spatial.normalise;
                if (~isfield(AutoDataProcessParameter,'SpecialMode')) || (isfield(AutoDataProcessParameter,'SpecialMode') && (AutoDataProcessParameter.SpecialMode == 1))
                    oldnorm.estwrite.eoptions.template={[SPMFilePath,filesep,'toolbox',filesep,'OldNorm',filesep,'EPI.nii,1']};
                end
                SPMJOB=[];
                SPMJOB.matlabbatch{1,1}.spm.tools.oldnorm = oldnorm;
            end
            
            spm_jobman('run',SPMJOB.matlabbatch);
            
        end
        
        if (AutoDataProcessParameter.IsNormalize==2) %Normalization by using the T1 image segment information
            %Normalize-Write: Using the segment information
            SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Normalize_Write.mat']);
            
            MatFileDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*seg_sn.mat']);
            MatFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,MatFileDir(1).name];
            
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.write.subj(1,1).matname={MatFilename};
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.write.subj(1,1).resample=FileList;
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.write.roptions.bb=AutoDataProcessParameter.Normalize.BoundingBox;
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.write.roptions.vox=AutoDataProcessParameter.Normalize.VoxSize;
            fprintf(['Normalize-Write:',AutoDataProcessParameter.SubjectID{i},' OK\n']);
            
            if SPMversion==12    % YAN Chao-Gan, 150703. In SPM 12, Segment (in SPM8) has turned to Old Segment.
                oldnorm = SPMJOB.matlabbatch{1,1}.spm.spatial.normalise;
                SPMJOB=[];
                SPMJOB.matlabbatch{1,1}.spm.tools.oldnorm = oldnorm;
            end

            spm_jobman('run',SPMJOB.matlabbatch);
            
        end
        
        if (AutoDataProcessParameter.IsNormalize==3) %Normalization by using DARTEL %YAN Chao-Gan, 111111.
            
            SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Dartel_NormaliseToMNI_FewSubjects.mat']);
            
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.fwhm=[0 0 0];
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.preserve=0;
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.bb=AutoDataProcessParameter.Normalize.BoundingBox;
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.vox=AutoDataProcessParameter.Normalize.VoxSize;
            
            DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1},filesep,'Template_6.*']);
            [pathstr,name,ext] = fileparts(DirImg(1).name); %YAN Chao-Gan, 151129. Check if it's .nii.gz
            if strcmpi(ext,'.gz')
                gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1},filesep,DirImg(1).name]);
                delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1},filesep,DirImg(1).name]);
                DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1},filesep,'Template_6.*']);
            end
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.template={[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1},filesep,DirImg(1).name]};
            
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subj(1,1).images=FileList;
            
            DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'u_*']);
            [pathstr,name,ext] = fileparts(DirImg(1).name); %YAN Chao-Gan, 151129. Check if it's .nii.gz
            if strcmpi(ext,'.gz')
                gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]);
                delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]);
                DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'u_*']);
            end
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subj(1,1).flowfield={[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]};
            
            spm_jobman('run',SPMJOB.matlabbatch);
            fprintf(['Normalization by using DARTEL:',AutoDataProcessParameter.SubjectID{i},' OK\n']);
        end
        
        
        if (AutoDataProcessParameter.IsNormalize==4) %Normalization by using the T1 image templates: Normalize T1 image to T1 template, and then apply to functional images. For Rat SpecialMode 3.
            
            SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Normalize.mat']);

            DirT1ImgCoreg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.img']);
            if isempty(DirT1ImgCoreg)  %YAN Chao-Gan, 111114. Also support .nii files.
                DirT1ImgCoreg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii.gz']);
                if length(DirT1ImgCoreg)==1
                    gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]);
                    delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]);
                end
                DirT1ImgCoreg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii']);
            end
            Source = [AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1ImgCoreg(1).name];

            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.subj(1,1).source={Source};
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.subj(1,1).resample=[FileList;{Source}];
            
            %SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.eoptions.template={[SPMFilePath,filesep,'templates',filesep,'T1.nii,1']};
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.eoptions.template={[SPMFilePath,filesep,'toolbox',filesep,'OldNorm',filesep,'T1.nii,1']}; %YAN Chao-Gan, 161006.
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.roptions.bb=AutoDataProcessParameter.Normalize.BoundingBox;
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.roptions.vox=AutoDataProcessParameter.Normalize.VoxSize;
            
            %YAN Chao-Gan, 140815.
            if isfield(AutoDataProcessParameter,'SpecialMode') && (AutoDataProcessParameter.SpecialMode == 2)  %Special Mode: Monkey
                SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.eoptions.template={[TemplatePath,filesep,'WisconsinRhesusMacaqueAtlases',filesep,'112RM-SL_T1.nii,1']};
            end
            
            %YAN Chao-Gan, 150515.
            if isfield(AutoDataProcessParameter,'SpecialMode') && (AutoDataProcessParameter.SpecialMode == 3)  %Special Mode: Rat
                SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.eoptions.template={[TemplatePath,filesep,'SchwarzRatTemplates',filesep,'ratT1Template_YCG.nii,1']};
            end
            
            fprintf(['Normalize:',AutoDataProcessParameter.SubjectID{i},' OK\n']);
            
            if SPMversion==12    % YAN Chao-Gan, 150703. In SPM 12, Segment (in SPM8) has turned to Old Segment.
                oldnorm = SPMJOB.matlabbatch{1,1}.spm.spatial.normalise;
                if (~isfield(AutoDataProcessParameter,'SpecialMode')) || (isfield(AutoDataProcessParameter,'SpecialMode') && (AutoDataProcessParameter.SpecialMode == 1))
                    oldnorm.estwrite.eoptions.template={[SPMFilePath,filesep,'toolbox',filesep,'OldNorm',filesep,'T1.nii,1']};
                end
                SPMJOB=[];
                SPMJOB.matlabbatch{1,1}.spm.tools.oldnorm = oldnorm;
            end
            
            spm_jobman('run',SPMJOB.matlabbatch);
            
        end
        
    end
    
    %Copy the Normalized files to DataProcessDir\{AutoDataProcessParameter.StartingDirName}+W
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        parfor i=1:AutoDataProcessParameter.SubjectNum
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'W',filesep,AutoDataProcessParameter.SubjectID{i}])
            movefile([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'w*'],[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'W',filesep,AutoDataProcessParameter.SubjectID{i}])
            fprintf(['Moving Normalized Files:',AutoDataProcessParameter.SubjectID{i},' OK']);
        end
        fprintf('\n');
    end
    AutoDataProcessParameter.StartingDirName=[AutoDataProcessParameter.StartingDirName,'W']; %Now StartingDirName is with new suffix 'W'
    
    
    % Don't do this (Delete files before normalization) anymore: YAN Chao-Gan, 120826
%     %Delete files before normalization
%     if AutoDataProcessParameter.IsDelFilesBeforeNormalize==1
%         for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
%             cd(AutoDataProcessParameter.DataProcessDir);
%             if (AutoDataProcessParameter.IsSliceTiming==1) || (AutoDataProcessParameter.IsRealign==1)
%                 rmdir([FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName(1:end-1)],'s')
%                 if (AutoDataProcessParameter.IsSliceTiming==1) && (AutoDataProcessParameter.IsRealign==1)
%                     rmdir([FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName(1:end-2)],'s')
%                 end
%             end
%         end
%     end
    

    if AutoDataProcessParameter.IsAllowGUI %YAN Chao-Gan, 161011. Generate the pictures only if GUI is allowed.
        %Generate the pictures for checking normalization %YAN Chao-Gan, 091001
        %Revised to use y_Call_spm_orthviews on 140331.
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'PicturesForChkNormalization']);
        cd([AutoDataProcessParameter.DataProcessDir,filesep,'PicturesForChkNormalization']);
        
        
        Ch2Filename=fullfile(TemplatePath,'ch2.nii');
        %YAN Chao-Gan, 140815.
        if isfield(AutoDataProcessParameter,'SpecialMode') && (AutoDataProcessParameter.SpecialMode == 2)  %Special Mode: Monkey
            Ch2Filename=[TemplatePath,filesep,'WisconsinRhesusMacaqueAtlases',filesep,'112RM-SL_T1.nii'];
        end
        %YAN Chao-Gan, 150515.
        if isfield(AutoDataProcessParameter,'SpecialMode') && (AutoDataProcessParameter.SpecialMode == 3)  %Special Mode: Rat
            Ch2Filename=[TemplatePath,filesep,'SchwarzRatTemplates',filesep,'rat97t2w_96x96x30.v6.nii'];
        end
        
        for i=1:AutoDataProcessParameter.SubjectNum
            
            % Set the normalized mean functional image instead of the first normalized volume to get pictures % YAN Chao-Gan, 120826
            DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'wmean*.img']);
            if isempty(DirMean)  %YAN Chao-Gan, 111114. Also support .nii files.
                DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'wmean*.nii.gz']);% Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirMean)==1
                    gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name]);
                    delete([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name]);
                end
                DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'wmean*.nii']);
            end
            Filename = [AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name];
            
            global st; clear st; %YAN Chao-Gan, 180611. In some cases generating pictures calling y_spm_orthviews may leave something need to be cleared.
            
            H = figure;
            H = y_Call_spm_orthviews(Ch2Filename,0,0,0,18,Filename,jet(64),0,250,H,0.8);
            %H = y_Call_spm_orthviews(BrainVolume,NMin,PMin,ClusterSize,ConnectivityCriterion,UnderlayFileName,ColorMap,NMax,PMax,H,Transparency,Position,BrainHeader);
            
            eval(['print(''-dtiff'',''-r100'',''',AutoDataProcessParameter.SubjectID{i},'.tif'',H);']);
            fprintf(['Generating the pictures for checking normalization: ',AutoDataProcessParameter.SubjectID{i},' OK. ']);
            
            close(H)
            
        end
        fprintf('\n');
    end

end
if ~isempty(Error)
    disp(Error);
    return;
end



%Smooth on functional data
if (AutoDataProcessParameter.IsSmooth>=1) && strcmpi(AutoDataProcessParameter.Smooth.Timing,'OnFunctionalData')
    if (AutoDataProcessParameter.IsSmooth==1)
        parfor i=1:AutoDataProcessParameter.SubjectNum

            FileList=[];
            for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
                DirImg=dir('*.img');
                if isempty(DirImg)  %YAN Chao-Gan, 111114. Also support .nii files. % Either in .nii.gz or in .nii
                    DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                    if length(DirImg)==1
                        gunzip(DirImg(1).name);
                        delete(DirImg(1).name);
                    end
                    DirImg=dir('*.nii');
                end
                
                if length(DirImg)>1  %3D .img or .nii images.
                    if AutoDataProcessParameter.TimePoints>0 && length(DirImg)~=AutoDataProcessParameter.TimePoints % Will not check if TimePoints set to 0. YAN Chao-Gan 120806.
                        Error=[Error;{['Error in Smooth: ',AutoDataProcessParameter.SubjectID{i}]}];
                    end
                    for j=1:length(DirImg)
                        FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(j).name]}];
                    end
                else %4D .nii images
                    Nii  = nifti(DirImg(1).name);
                    if AutoDataProcessParameter.TimePoints>0 && size(Nii.dat,4)~=AutoDataProcessParameter.TimePoints % Will not check if TimePoints set to 0. YAN Chao-Gan 120806.
                        Error=[Error;{['Error in Smooth: ',AutoDataProcessParameter.SubjectID{i}]}];
                    end

                    FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]}];
                    %YAN Chao-Gan, 130301. Fixed a bug (leave session 1) in smooth in multiple sessions.  %FileList={[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]};
                    
                end
            end

            SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Smooth.mat']);
            SPMJOB.matlabbatch{1,1}.spm.spatial.smooth.data = FileList;
            SPMJOB.matlabbatch{1,1}.spm.spatial.smooth.fwhm = AutoDataProcessParameter.Smooth.FWHM;
            spm_jobman('run',SPMJOB.matlabbatch);

            fprintf(['Smooth:',AutoDataProcessParameter.SubjectID{i},' OK']);
        end
        
    elseif (AutoDataProcessParameter.IsSmooth==2)   %YAN Chao-Gan, 111111. Smooth by DARTEL. The smoothing that is a part of the normalization to MNI space computes these average intensities from the original data, rather than the warped versions. When the data are warped, some voxels will grow and others will shrink. This will change the regional averages, with more weighting towards those voxels that have grows.

        parfor i=1:AutoDataProcessParameter.SubjectNum
            SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Dartel_NormaliseToMNI_FewSubjects.mat']);
            
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.fwhm=AutoDataProcessParameter.Smooth.FWHM;
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.preserve=0;
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.bb=AutoDataProcessParameter.Normalize.BoundingBox;
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.vox=AutoDataProcessParameter.Normalize.VoxSize;
            
            DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1},filesep,'Template_6.*']);
            [pathstr,name,ext] = fileparts(DirImg(1).name); %YAN Chao-Gan, 151129. Check if it's .nii.gz
            if strcmpi(ext,'.gz')
                gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1},filesep,DirImg(1).name]);
                delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1},filesep,DirImg(1).name]);
                DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1},filesep,'Template_6.*']);
            end
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.template={[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1},filesep,DirImg(1).name]};
            
            
            FileList=[];
            for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName(1:end-1),filesep,AutoDataProcessParameter.SubjectID{i}]);
                DirImg=dir('*.img');
                if isempty(DirImg)  %YAN Chao-Gan, 111114. Also support .nii files. % Either in .nii.gz or in .nii
                    DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                    if length(DirImg)==1
                        gunzip(DirImg(1).name);
                        delete(DirImg(1).name);
                    end
                    DirImg=dir('*.nii');
                end
                
                if length(DirImg)>1  %3D .img or .nii images.
                    if AutoDataProcessParameter.TimePoints>0 && length(DirImg)~=AutoDataProcessParameter.TimePoints % Will not check if TimePoints set to 0. YAN Chao-Gan 120806.
                        Error=[Error;{['Error in Smooth: ',AutoDataProcessParameter.SubjectID{i}]}];
                    end
                    for j=1:length(DirImg)
                        FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName(1:end-1),filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(j).name]}];
                    end
                else %4D .nii images
                    Nii  = nifti(DirImg(1).name);
                    if AutoDataProcessParameter.TimePoints>0 && size(Nii.dat,4)~=AutoDataProcessParameter.TimePoints % Will not check if TimePoints set to 0. YAN Chao-Gan 120806.
                        Error=[Error;{['Error in Smooth: ',AutoDataProcessParameter.SubjectID{i}]}];
                    end
                    
                    FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName(1:end-1),filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]}];
                    %YAN Chao-Gan 130309. Fixed a bug in "Smooth by DARTEL" caused in last revision. %YAN Chao-Gan, 130301. Fixed a bug (leave session 1) in smooth in multiple sessions.  %FileList={[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]};
         
                end
            end

            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subj(1,1).images=FileList;
            
            DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'u_*']);
            [pathstr,name,ext] = fileparts(DirImg(1).name); %YAN Chao-Gan, 151129. Check if it's .nii.gz
            if strcmpi(ext,'.gz')
                gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]);
                delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]);
                DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'u_*']);
            end
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subj(1,1).flowfield={[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]};
            
            spm_jobman('run',SPMJOB.matlabbatch);
            fprintf(['Smooth by using DARTEL:',AutoDataProcessParameter.SubjectID{i},' OK\n']);
        end

    end

    %Copy the Smoothed files to DataProcessDir\{AutoDataProcessParameter.StartingDirName}+S
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        parfor i=1:AutoDataProcessParameter.SubjectNum
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'S',filesep,AutoDataProcessParameter.SubjectID{i}])
            
            if (AutoDataProcessParameter.IsSmooth==1)
                movefile([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'s*'],[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'S',filesep,AutoDataProcessParameter.SubjectID{i}])
            elseif (AutoDataProcessParameter.IsSmooth==2) % If smoothed by DARTEL, then the smoothed files still under realign directory.
                movefile([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName(1:end-1),filesep,AutoDataProcessParameter.SubjectID{i},filesep,'s*'],[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'S',filesep,AutoDataProcessParameter.SubjectID{i}])
            end
            fprintf(['Moving Smoothed Files:',AutoDataProcessParameter.SubjectID{i},' OK']);
        end
        fprintf('\n');
    end
    
    AutoDataProcessParameter.StartingDirName=[AutoDataProcessParameter.StartingDirName,'S']; %Now StartingDirName is with new suffix 'S'
end
if ~isempty(Error)
    disp(Error);
    return;
end


%Detrend
%YAN Chao-Gan 120826: detrend is no longer needed if linear trend is included in nuisance regression. Keeping this function is for back compatibility
if (AutoDataProcessParameter.IsDetrend==1)
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        parfor i=1:AutoDataProcessParameter.SubjectNum
            y_detrend([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
        end
    end
    
    %Copy the Detrended files to DataProcessDir\{AutoDataProcessParameter.StartingDirName}+D
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        parfor i=1:AutoDataProcessParameter.SubjectNum
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'D',filesep,AutoDataProcessParameter.SubjectID{i}])
            movefile([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}, '_detrend',filesep,'*'],[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'D',filesep,AutoDataProcessParameter.SubjectID{i}])

            rmdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}, '_detrend']);
            fprintf(['Moving Dtrended Files:',AutoDataProcessParameter.SubjectID{i},' OK']);
        end
        fprintf('\n');
    end
    AutoDataProcessParameter.StartingDirName=[AutoDataProcessParameter.StartingDirName,'D']; %Now StartingDirName is with new suffix 'D'
end





%%%%%%%
%Genereated the masks based on Segmentation results
% YAN Chao-Gan, 140617
%Reslice WM and CSF masks to MNI functional space.

if ((AutoDataProcessParameter.IsCovremove==1) && (strcmpi(AutoDataProcessParameter.Covremove.Timing,'AfterNormalize')))
    T1ImgSegmentDirectoryName = '';
    if (7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgSegment',filesep,AutoDataProcessParameter.SubjectID{1}],'dir'))
        T1ImgSegmentDirectoryName = 'T1ImgSegment';
    elseif (7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1}],'dir'))
        T1ImgSegmentDirectoryName = 'T1ImgNewSegment';
    end
    
    if ~isempty(T1ImgSegmentDirectoryName)
        if ~(2==exist([AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'MNIFunSpace_ThrdMask_',AutoDataProcessParameter.SubjectID{1},'_WM.nii'],'file'))
            
            if ~(7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks'],'dir'))
                mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks']);
            end
            
            % If have not generated previously.
            parfor i=1:AutoDataProcessParameter.SubjectNum
                DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'wmean*.img']);
                if isempty(DirMean)  %YAN Chao-Gan, 111114. Also support .nii files.
                    DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'wmean*.nii.gz']);% Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                    if length(DirMean)==1
                        gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name]);
                        delete([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name]);
                    end
                    DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'wmean*.nii']);
                end
                RefFile = [AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name];
                [RefData,RefVox,RefHeader]=y_ReadRPI(RefFile,1);
                cd([AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i}]);
                
%                 DirImg=dir('wc1*');
%                 [OutVolume OutHead] = y_Reslice([AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name],[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'MNIFunSpace_',AutoDataProcessParameter.SubjectID{i},'_GM.nii'],RefVox,1, RefFile);
%                 OutHead.pinfo = [1;0;0]; OutHead.dt    =[16,0];
%                 y_Write(OutVolume,OutHead,[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'MNIFunSpace_',AutoDataProcessParameter.SubjectID{i},'_GM.nii']);
%                 OutHead.pinfo = [1;0;0]; OutHead.dt    =[2,0];
%                 y_Write(OutVolume>GMThrd,OutHead,[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'MNIFunSpace_ThrdMask_',AutoDataProcessParameter.SubjectID{i},'_GM.nii']);
%                 
                DirImg=dir('wc2*.img');
                if isempty(DirImg)
                    DirImg=dir('wc2*.nii.gz');
                    if length(DirImg)==1
                        gunzip(DirImg(1).name);
                        delete(DirImg(1).name);
                    end
                    DirImg=dir('wc2*.nii');
                end

                %DirImg=dir('wc2*'); %YAN Chao-Gan, 150820. Fixed the "File too small" error when .hdr/.img files are used.

                [OutVolume OutHead] = y_Reslice([AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name],[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'MNIFunSpace_',AutoDataProcessParameter.SubjectID{i},'_WM.nii'],RefVox,1, RefFile);
                OutHead.pinfo = [1;0;0]; OutHead.dt    =[16,0];
                y_Write(OutVolume,OutHead,[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'MNIFunSpace_',AutoDataProcessParameter.SubjectID{i},'_WM.nii']);
                OutHead.pinfo = [1;0;0]; OutHead.dt    =[2,0];
                y_Write(OutVolume>AutoDataProcessParameter.Covremove.WM.MaskThreshold,OutHead,[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'MNIFunSpace_ThrdMask_',AutoDataProcessParameter.SubjectID{i},'_WM.nii']);
                
                DirImg=dir('wc3*.img');
                if isempty(DirImg)
                    DirImg=dir('wc3*.nii.gz');
                    if length(DirImg)==1
                        gunzip(DirImg(1).name);
                        delete(DirImg(1).name);
                    end
                    DirImg=dir('wc3*.nii');
                end
                
                %DirImg=dir('wc3*'); %YAN Chao-Gan, 150820. Fixed the "File too small" error when .hdr/.img files are used.

                [OutVolume OutHead] = y_Reslice([AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name],[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'MNIFunSpace_',AutoDataProcessParameter.SubjectID{i},'_CSF.nii'],RefVox,1, RefFile);
                OutHead.pinfo = [1;0;0]; OutHead.dt    =[16,0];
                y_Write(OutVolume,OutHead,[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'MNIFunSpace_',AutoDataProcessParameter.SubjectID{i},'_CSF.nii']);
                OutHead.pinfo = [1;0;0]; OutHead.dt    =[2,0];
                y_Write(OutVolume>AutoDataProcessParameter.Covremove.CSF.MaskThreshold,OutHead,[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'MNIFunSpace_ThrdMask_',AutoDataProcessParameter.SubjectID{i},'_CSF.nii']);
                
            end
        end
    end
end



%%%%%%%%
% If don't need to Warp into original space, then check if the masks are appropriate and resample if not.
% YAN Chao-Gan, 120827.

if (AutoDataProcessParameter.IsWarpMasksIntoIndividualSpace==0) && ((AutoDataProcessParameter.IsCalALFF==1)||( (AutoDataProcessParameter.IsCovremove==1) && (strcmpi(AutoDataProcessParameter.Covremove.Timing,'AfterNormalize')) )||(AutoDataProcessParameter.IsCalReHo==1)||(AutoDataProcessParameter.IsCalDegreeCentrality==1)||(AutoDataProcessParameter.IsCalFC==1)||(AutoDataProcessParameter.IsCalVMHC==1)||(AutoDataProcessParameter.IsCWAS==1))
    
    MasksName{1,1}=[TemplatePath,filesep,'BrainMask_05_91x109x91.img'];
    MasksName{2,1}=[TemplatePath,filesep,'CsfMask_07_91x109x91.img'];
    MasksName{3,1}=[TemplatePath,filesep,'WhiteMask_09_91x109x91.img'];
    MasksName{4,1}=[TemplatePath,filesep,'GreyMask_02_91x109x91.img'];
    
    if (isfield(AutoDataProcessParameter,'MaskFile')) && (~isempty(AutoDataProcessParameter.MaskFile)) && (~isequal(AutoDataProcessParameter.MaskFile, 'Default'))
        MasksName{5,1}=AutoDataProcessParameter.MaskFile;
    end
    
    if ~(7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'Masks'],'dir'))
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'Masks']);
    end
    
    RefFile=dir([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{1},filesep,'*.img']);
    if isempty(RefFile)  %YAN Chao-Gan, 120827. Also support .nii.gz files.
        RefFile=dir([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{1},filesep,'*.nii.gz']);
    end
    if isempty(RefFile)  %YAN Chao-Gan, 111114. Also support .nii files.
        RefFile=dir([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{1},filesep,'*.nii']);
    end
    RefFile=[AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{1},filesep,RefFile(1).name];
    [RefData,RefVox,RefHeader]=y_ReadRPI(RefFile,1);

    for iMask=1:length(MasksName)
        AMaskFilename = MasksName{iMask};
        fprintf('\nResample Masks (%s) to the resolution of functional images.\n',AMaskFilename);
        
        [pathstr, name, ext] = fileparts(AMaskFilename);
        ReslicedMaskName=[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'AllResampled_',name,'.nii'];
        
        y_Reslice(AMaskFilename,ReslicedMaskName,RefVox,0, RefFile);
        
    end
end


% Get the appropriate mask for each subject
% YAN Chao-Gan, 140628
MaskFileForEachSubject=cell(AutoDataProcessParameter.SubjectNum,1);
for i=1:AutoDataProcessParameter.SubjectNum
    
    if ~isempty(AutoDataProcessParameter.MaskFile)
        if (isequal(AutoDataProcessParameter.MaskFile, 'Default'))
            MaskNameString = 'BrainMask_05_91x109x91';
        else
            [pathstr, name, ext] = fileparts(AutoDataProcessParameter.MaskFile);
            MaskNameString = name;
        end
        if (AutoDataProcessParameter.IsWarpMasksIntoIndividualSpace==1)
            MaskPrefix = ['WarpedMasks',filesep,AutoDataProcessParameter.SubjectID{i}];
        else
            MaskPrefix = 'AllResampled';
        end
        MaskFileForEachSubject{i} = [AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,MaskPrefix,'_',MaskNameString,'.nii'];
    else
        MaskFileForEachSubject{i}='';
    end
end
AutoDataProcessParameter.MaskFileForEachSubject = MaskFileForEachSubject;



%If don't need to Warp into original space, then resample the other covariables mask
if (AutoDataProcessParameter.IsCovremove==1) && ((strcmpi(AutoDataProcessParameter.Covremove.Timing,'AfterNormalize'))&&(AutoDataProcessParameter.IsWarpMasksIntoIndividualSpace==0))
    
    if ~isempty(AutoDataProcessParameter.Covremove.OtherCovariatesROI)
        
        if ~(7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'Masks'],'dir'))
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'Masks']);
        end
        
        % Check if masks appropriate %This can be used as a function!!! ONLY FOR RESAMPLE
        OtherCovariatesROIForEachSubject=cell(AutoDataProcessParameter.SubjectNum,1);
        parfor i=1:AutoDataProcessParameter.SubjectNum
            Suffix='OtherCovariateROI_'; %%!!! Change as in Function
            SubjectROI=AutoDataProcessParameter.Covremove.OtherCovariatesROI;%%!!! Change as in Fuction
            
            % Set the reference image
            RefFile=dir([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{1},filesep,'*.img']);
            if isempty(RefFile)  %YAN Chao-Gan, 120827. Also support .nii.gz files.
                RefFile=dir([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{1},filesep,'*.nii.gz']);
            end
            if isempty(RefFile)  %YAN Chao-Gan, 111114. Also support .nii files.
                RefFile=dir([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{1},filesep,'*.nii']);
            end
            RefFile=[AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{1},filesep,RefFile(1).name];
            [RefData,RefVox,RefHeader]=y_ReadRPI(RefFile,1);
            
            % Ball to mask
            for iROI=1:length(SubjectROI)
                if strcmpi(int2str(size(SubjectROI{iROI})),int2str([1, 4]))  %Sphere ROI definition: CenterX, CenterY, CenterZ, Radius
                    
                    ROIMaskName=[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,Suffix,num2str(iROI),'_',AutoDataProcessParameter.SubjectID{i},'.nii'];

                    y_Sphere(SubjectROI{iROI}(1:3), SubjectROI{iROI}(4), RefFile, ROIMaskName);
                    
                    SubjectROI{iROI}=[ROIMaskName];
                end
            end
            
            % Check if the ROI mask is appropriate
            for iROI=1:length(SubjectROI)
                AMaskFilename=SubjectROI{iROI};
                if exist(SubjectROI{iROI},'file')==2
                    [pathstr, name, ext] = fileparts(SubjectROI{iROI});
                    if (~strcmpi(ext, '.txt'))
                        [MaskData,MaskVox,MaskHeader]=y_ReadRPI(AMaskFilename);
                        if ~isequal(size(MaskData), size(RefData))
                            fprintf('\nReslice %s Mask (%s) for "%s" since the dimension of mask mismatched the dimension of the functional data.\n',Suffix,AMaskFilename, AutoDataProcessParameter.SubjectID{i});
                            
                            ReslicedMaskName=[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,Suffix,num2str(iROI),'_',AutoDataProcessParameter.SubjectID{i},'.nii'];
                            y_Reslice(AMaskFilename,ReslicedMaskName,RefVox,0, RefFile);
                            SubjectROI{iROI}=ReslicedMaskName;
                        end
                    end
                end
            end
            
            % Check if the text file is a definition for multiple subjects. i.e., the first line is 'Covariables_List:', then get the corresponded covariables file
            for iROI=1:length(SubjectROI)
                if (ischar(SubjectROI{iROI})) && (exist(SubjectROI{iROI},'file')==2)
                    [pathstr, name, ext] = fileparts(SubjectROI{iROI});
                    if (strcmpi(ext, '.txt'))
                        fid = fopen(SubjectROI{iROI});
                        SeedTimeCourseList=textscan(fid,'%s\n'); %YAN Chao-Gan, 180320. For compatiblity of MALLAB 2014b. SeedTimeCourseList=textscan(fid,'%s','\n'); 
                        fclose(fid);
                        if strcmpi(SeedTimeCourseList{1}{1},'Covariables_List:')
                            SubjectROI{iROI}=SeedTimeCourseList{1}{i+1};
                        end
                    end
                end
                
            end
            
            OtherCovariatesROIForEachSubject{i}=SubjectROI; %%!!! Change as in Fuction
        end
        
        AutoDataProcessParameter.Covremove.OtherCovariatesROIForEachSubject = OtherCovariatesROIForEachSubject;
    end
end


%Remove the nuisance Covaribles ('AfterNormalize') %YAN Chao-Gan, 140810. Change cov remove before filtering since DPARSFA 3.0. Previous is ('AfterNormalizeFiltering')
if (AutoDataProcessParameter.IsCovremove==1) && (strcmpi(AutoDataProcessParameter.Covremove.Timing,'AfterNormalize')) %if (AutoDataProcessParameter.IsCovremove==1) && (strcmpi(AutoDataProcessParameter.Covremove.Timing,'AfterNormalizeFiltering'))
    
    %Remove the Covariables
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        parfor i=1:AutoDataProcessParameter.SubjectNum
            
            CovariablesDef=[];
            
            %Polynomial trends
            %0: constant
            %1: constant + linear trend
            %2: constant + linear trend + quadratic trend.
            %3: constant + linear trend + quadratic trend + cubic trend.   ...
            
            CovariablesDef.polort = AutoDataProcessParameter.Covremove.PolynomialTrend;

            
            %Head Motion
            ImgCovModel = 1; %Default
            
            CovariablesDef.CovMat = []; %YAN Chao-Gan, 130116. Fixed a bug when CovMat is not defined.
            
            if (AutoDataProcessParameter.Covremove.HeadMotion==1) %1: Use the current time point of rigid-body 6 realign parameters. e.g., Txi, Tyi, Tzi...
                DirRP=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},'rp*']);
                Q1=load([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRP.name]);
                CovariablesDef.CovMat = Q1;
            elseif (AutoDataProcessParameter.Covremove.HeadMotion==2) %2: Use the current time point and the previous time point of rigid-body 6 realign parameters. e.g., Txi, Tyi, Tzi,..., Txi-1, Tyi-1, Tzi-1...
                DirRP=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},'rp*']);
                Q1=load([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRP.name]);
                CovariablesDef.CovMat = [Q1, [zeros(1,size(Q1,2));Q1(1:end-1,:)]];
            elseif (AutoDataProcessParameter.Covremove.HeadMotion==3) %3: Use the current time point and their squares of rigid-body 6 realign parameters. e.g., Txi, Tyi, Tzi,..., Txi^2, Tyi^2, Tzi^2...
                DirRP=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},'rp*']);
                Q1=load([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRP.name]);
                CovariablesDef.CovMat = [Q1,  Q1.^2];
            elseif (AutoDataProcessParameter.Covremove.HeadMotion==4) %4: Use the Friston 24-parameter model: current time point, the previous time point and their squares of rigid-body 6 realign parameters. e.g., Txi, Tyi, Tzi, ..., Txi-1, Tyi-1, Tzi-1,... and their squares (total 24 items). Friston autoregressive model (Friston, K.J., Williams, S., Howard, R., Frackowiak, R.S., Turner, R., 1996. Movement-related effects in fMRI time-series. Magn Reson Med 35, 346-355.)
                DirRP=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},'rp*']);
                Q1=load([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRP.name]);
                CovariablesDef.CovMat = [Q1, [zeros(1,size(Q1,2));Q1(1:end-1,:)], Q1.^2, [zeros(1,size(Q1,2));Q1(1:end-1,:)].^2];
            elseif (AutoDataProcessParameter.Covremove.HeadMotion>=11) %11-14: Use the voxel-specific models. 14 is the voxel-specific 12 model.
                
                if AutoDataProcessParameter.IsWarpMasksIntoIndividualSpace==1
                    %Use the voxel-specific head motion in original space. 
                    
                    HMvoxDir=[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'VoxelSpecificHeadMotion',filesep,AutoDataProcessParameter.SubjectID{i}];
                    
                    CovariablesDef.CovImgDir = {[HMvoxDir,filesep,'HMvox_X_4DVolume.nii'];[HMvoxDir,filesep,'HMvox_Y_4DVolume.nii'];[HMvoxDir,filesep,'HMvox_Z_4DVolume.nii']};

                else
                    %Use the voxel-specific head motion in MNI space, need to normalize first.
                    TemplateDir_SubID = AutoDataProcessParameter.SubjectID{1};
                    SubjectID_Temp = AutoDataProcessParameter.SubjectID{i};
                    SourceDir_Temp = [AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'VoxelSpecificHeadMotion'];
                    OutpurDir_Temp = [AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'VoxelSpecificHeadMotion','W'];
                    T1ImgNewSegmentDir = [AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment'];
                    if exist([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,TemplateDir_SubID,filesep,'Template_6.nii.gz'],'file') %YAN Chao-Gan, 151129
                        gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,TemplateDir_SubID,filesep,'Template_6.nii.gz']);
                        delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,TemplateDir_SubID,filesep,'Template_6.nii.gz']);
                    end
                    DARTELTemplateFile = [AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,TemplateDir_SubID,filesep,'Template_6.nii'];
                    IsSubDirectory = 1;
                    BoundingBox=AutoDataProcessParameter.Normalize.BoundingBox;
                    VoxSize=AutoDataProcessParameter.Normalize.VoxSize;
                    y_Normalize_WriteToMNI_DARTEL(SubjectID_Temp,SourceDir_Temp,OutpurDir_Temp,T1ImgNewSegmentDir,DARTELTemplateFile,IsSubDirectory,BoundingBox,VoxSize)
                    
                    % Set the normalized voxel-specific head motion
                    HMvoxDir=[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'VoxelSpecificHeadMotionW',filesep,AutoDataProcessParameter.SubjectID{i}];

                    CovariablesDef.CovImgDir = {[HMvoxDir,filesep,'wHMvox_X_4DVolume.nii'];[HMvoxDir,filesep,'wHMvox_Y_4DVolume.nii'];[HMvoxDir,filesep,'wHMvox_Z_4DVolume.nii']};

                end
                
                ImgCovModel = AutoDataProcessParameter.Covremove.HeadMotion - 10;
            end
            

            %Head Motion "Scrubbing" Regressors: each bad time point is a separate regressor
            if (AutoDataProcessParameter.Covremove.IsHeadMotionScrubbingRegressors==1)
                
                % Use FD_Power or FD_Jenkinson YAN Chao-Gan, 121225.
                FD = load([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.Covremove.HeadMotionScrubbingRegressors.FDType,'_',AutoDataProcessParameter.SubjectID{i},'.txt']);
                %FD = load([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},'FD_Power_',AutoDataProcessParameter.SubjectID{i},'.txt']);

                TemporalMask=ones(length(FD),1);
                Index=find(FD > AutoDataProcessParameter.Covremove.HeadMotionScrubbingRegressors.FDThreshold);
                TemporalMask(Index)=0;
                IndexPrevious=Index;
                for iP=1:AutoDataProcessParameter.Covremove.HeadMotionScrubbingRegressors.PreviousPoints
                    IndexPrevious=IndexPrevious-1;
                    IndexPrevious=IndexPrevious(IndexPrevious>=1);
                    TemporalMask(IndexPrevious)=0;
                end
                IndexNext=Index;
                for iN=1:AutoDataProcessParameter.Covremove.HeadMotionScrubbingRegressors.LaterPoints
                    IndexNext=IndexNext+1;
                    IndexNext=IndexNext(IndexNext<=length(FD));
                    TemporalMask(IndexNext)=0;
                end
                
                BadTimePointsIndex = find(TemporalMask==0);
                BadTimePointsRegressor = zeros(length(FD),length(BadTimePointsIndex));
                for iBadTimePoints = 1:length(BadTimePointsIndex)
                    BadTimePointsRegressor(BadTimePointsIndex(iBadTimePoints),iBadTimePoints) = 1;
                end
                
                CovariablesDef.CovMat = [CovariablesDef.CovMat, BadTimePointsRegressor];
            end

            
            
            %Mask covariates CompCor methods %YAN Chao-Gan, 140628. Deal with different kind of nuisance covarites.
            CompCorMasks = [];
            if (AutoDataProcessParameter.IsWarpMasksIntoIndividualSpace==1) %In Original space
                if (AutoDataProcessParameter.Covremove.WM.IsRemove==1) && strcmpi(AutoDataProcessParameter.Covremove.WM.Method,'CompCor')
                    if strcmpi(AutoDataProcessParameter.Covremove.WM.Mask,'SPM')
                        CompCorMasks=[CompCorMasks;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'WarpedMasks',filesep,AutoDataProcessParameter.SubjectID{i},'_WhiteMask_09_91x109x91.nii']}];
                    elseif strcmpi(AutoDataProcessParameter.Covremove.WM.Mask,'Segment')
                        CompCorMasks=[CompCorMasks;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_ThrdMask_',AutoDataProcessParameter.SubjectID{i},'_WM.nii']}];
                    end
                end
                if (AutoDataProcessParameter.Covremove.CSF.IsRemove==1) && strcmpi(AutoDataProcessParameter.Covremove.CSF.Method,'CompCor')
                    if strcmpi(AutoDataProcessParameter.Covremove.CSF.Mask,'SPM')
                        CompCorMasks=[CompCorMasks;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'WarpedMasks',filesep,AutoDataProcessParameter.SubjectID{i},'_CsfMask_07_91x109x91.nii']}];
                    elseif strcmpi(AutoDataProcessParameter.Covremove.CSF.Mask,'Segment')
                        CompCorMasks=[CompCorMasks;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_ThrdMask_',AutoDataProcessParameter.SubjectID{i},'_CSF.nii']}];
                    end
                end
            else %In MNI space
                if (AutoDataProcessParameter.Covremove.WM.IsRemove==1) && strcmpi(AutoDataProcessParameter.Covremove.WM.Method,'CompCor')
                    if strcmpi(AutoDataProcessParameter.Covremove.WM.Mask,'SPM')
                        CompCorMasks=[CompCorMasks;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'AllResampled','_WhiteMask_09_91x109x91.nii']}];
                    elseif strcmpi(AutoDataProcessParameter.Covremove.WM.Mask,'Segment')
                        CompCorMasks=[CompCorMasks;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'MNIFunSpace_ThrdMask_',AutoDataProcessParameter.SubjectID{i},'_WM.nii']}];
                    end
                end
                if (AutoDataProcessParameter.Covremove.CSF.IsRemove==1) && strcmpi(AutoDataProcessParameter.Covremove.CSF.Method,'CompCor')
                    if strcmpi(AutoDataProcessParameter.Covremove.CSF.Mask,'SPM')
                        CompCorMasks=[CompCorMasks;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'AllResampled','_CsfMask_07_91x109x91.nii']}];
                    elseif strcmpi(AutoDataProcessParameter.Covremove.CSF.Mask,'Segment')
                        CompCorMasks=[CompCorMasks;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'MNIFunSpace_ThrdMask_',AutoDataProcessParameter.SubjectID{i},'_CSF.nii']}];
                    end
                end
            end
            if ~isempty(CompCorMasks)
                if ~(7==exist([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'Covs'],'dir'))
                    mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'Covs']);
                end
                [PCs] = y_CompCor_PC([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}],CompCorMasks, [AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'Covs',filesep,AutoDataProcessParameter.SubjectID{i},'_CompCorPCs'], AutoDataProcessParameter.Covremove.CSF.CompCorPCNum);
                %[PCs] = y_CompCor_PC(ADataDir,Nuisance_MaskFilename, OutputName, PCNum, IsNeedDetrend, Band, TR, IsVarianceNormalization)
                %IsNeedDetrend and IsVarianceNormalization defaulted to 1
                
                CovariablesDef.CovMat = [CovariablesDef.CovMat, PCs];
            end
            
            
            %Mask covariates %YAN Chao-Gan, 140628. Deal with different kind of nuisance covarites.
            SubjectCovariatesROI=[];
            if (AutoDataProcessParameter.IsWarpMasksIntoIndividualSpace==1) %In Original space
                if (AutoDataProcessParameter.Covremove.WM.IsRemove==1) && strcmpi(AutoDataProcessParameter.Covremove.WM.Method,'Mean')
                    if strcmpi(AutoDataProcessParameter.Covremove.WM.Mask,'SPM')
                        SubjectCovariatesROI=[SubjectCovariatesROI;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'WarpedMasks',filesep,AutoDataProcessParameter.SubjectID{i},'_WhiteMask_09_91x109x91.nii']}];
                    elseif strcmpi(AutoDataProcessParameter.Covremove.WM.Mask,'Segment')
                        SubjectCovariatesROI=[SubjectCovariatesROI;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_ThrdMask_',AutoDataProcessParameter.SubjectID{i},'_WM.nii']}];
                    end
                end
                
                if (AutoDataProcessParameter.Covremove.CSF.IsRemove==1) && strcmpi(AutoDataProcessParameter.Covremove.CSF.Method,'Mean')
                    if strcmpi(AutoDataProcessParameter.Covremove.CSF.Mask,'SPM')
                        SubjectCovariatesROI=[SubjectCovariatesROI;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'WarpedMasks',filesep,AutoDataProcessParameter.SubjectID{i},'_CsfMask_07_91x109x91.nii']}];
                    elseif strcmpi(AutoDataProcessParameter.Covremove.CSF.Mask,'Segment')
                        SubjectCovariatesROI=[SubjectCovariatesROI;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_ThrdMask_',AutoDataProcessParameter.SubjectID{i},'_CSF.nii']}];
                    end
                end
                
                if (AutoDataProcessParameter.Covremove.WholeBrain.IsRemove==1)
                    if strcmpi(AutoDataProcessParameter.Covremove.WholeBrain.Mask,'SPM')
                        SubjectCovariatesROI=[SubjectCovariatesROI;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'WarpedMasks',filesep,AutoDataProcessParameter.SubjectID{i},'_BrainMask_05_91x109x91.nii']}];
                    elseif strcmpi(AutoDataProcessParameter.Covremove.WholeBrain.Mask,'AutoMask')
                        SubjectCovariatesROI=[SubjectCovariatesROI;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'AutoMasks',filesep,FunSessionPrefixSet{iFunSession},'AutoMask_',AutoDataProcessParameter.SubjectID{i},'.nii']}];
                    end
                end
            else %In MNI space
                if (AutoDataProcessParameter.Covremove.WM.IsRemove==1) && strcmpi(AutoDataProcessParameter.Covremove.WM.Method,'Mean')
                    if strcmpi(AutoDataProcessParameter.Covremove.WM.Mask,'SPM')
                        SubjectCovariatesROI=[SubjectCovariatesROI;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'AllResampled','_WhiteMask_09_91x109x91.nii']}];
                    elseif strcmpi(AutoDataProcessParameter.Covremove.WM.Mask,'Segment')
                        SubjectCovariatesROI=[SubjectCovariatesROI;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'MNIFunSpace_ThrdMask_',AutoDataProcessParameter.SubjectID{i},'_WM.nii']}];
                    end
                end
                
                if (AutoDataProcessParameter.Covremove.CSF.IsRemove==1) && strcmpi(AutoDataProcessParameter.Covremove.CSF.Method,'Mean')
                    if strcmpi(AutoDataProcessParameter.Covremove.CSF.Mask,'SPM')
                        SubjectCovariatesROI=[SubjectCovariatesROI;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'AllResampled','_CsfMask_07_91x109x91.nii']}];
                    elseif strcmpi(AutoDataProcessParameter.Covremove.CSF.Mask,'Segment')
                        SubjectCovariatesROI=[SubjectCovariatesROI;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'MNIFunSpace_ThrdMask_',AutoDataProcessParameter.SubjectID{i},'_CSF.nii']}];
                    end
                end
                
                if (AutoDataProcessParameter.Covremove.WholeBrain.IsRemove==1)
                    if strcmpi(AutoDataProcessParameter.Covremove.WholeBrain.Mask,'SPM')
                        SubjectCovariatesROI=[SubjectCovariatesROI;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'AllResampled','_BrainMask_05_91x109x91.nii']}];
                    elseif strcmpi(AutoDataProcessParameter.Covremove.WholeBrain.Mask,'AutoMask')
                        SubjectCovariatesROI=[SubjectCovariatesROI;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'AutoMasks',filesep,'w',FunSessionPrefixSet{iFunSession},'AutoMask_',AutoDataProcessParameter.SubjectID{i},'.nii']}];
                    end
                end
                
            end
            
            % Add the other Covariate ROIs
            if ~isempty(AutoDataProcessParameter.Covremove.OtherCovariatesROI)
                SubjectCovariatesROI=[SubjectCovariatesROI;AutoDataProcessParameter.Covremove.OtherCovariatesROIForEachSubject{i}];
            end
            
            if ~(7==exist([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'Covs'],'dir'))
                mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'Covs']);
            end
            
            %Extract Time course for the Mask covariates
            if ~isempty(SubjectCovariatesROI)
                
                y_ExtractROISignal([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}], SubjectCovariatesROI, [AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'Covs',filesep,AutoDataProcessParameter.SubjectID{i}], '', 1);
                
                CovariablesDef.ort_file=[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'Covs',filesep,'ROISignals_',AutoDataProcessParameter.SubjectID{i},'.txt'];
            end
            
            CovariablesDef.IsAddMeanBack = AutoDataProcessParameter.Covremove.IsAddMeanBack; %YAN Chao-Gan, 160415: Add the option of "Add Mean Back".
            
            %Regressing out the covariates
            fprintf('\nRegressing out covariates for subject %s %s.\n',AutoDataProcessParameter.SubjectID{i},FunSessionPrefixSet{iFunSession});
            [Covariables] = y_RegressOutImgCovariates([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}],CovariablesDef,'_Covremoved','', ImgCovModel);
            
            Covariables = double(Covariables);
            y_CallSave([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'Covs',filesep,'Covariables',AutoDataProcessParameter.SubjectID{i},'.mat'], Covariables, '');
            y_CallSave([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'Covs',filesep,'Covariables',AutoDataProcessParameter.SubjectID{i},'.txt'], Covariables, ' ''-ASCII'', ''-DOUBLE'',''-TABS''');

        end
        fprintf('\n');
    end
    
    
    %Copy the Covariates Removed files to DataProcessDir\{AutoDataProcessParameter.StartingDirName}+C
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        parfor i=1:AutoDataProcessParameter.SubjectNum
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'C',filesep,AutoDataProcessParameter.SubjectID{i}])
            movefile([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}, '_Covremoved',filesep,'*'],[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'C',filesep,AutoDataProcessParameter.SubjectID{i}])

            rmdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}, '_Covremoved']);
            fprintf(['Moving Coviables Removed Files:',AutoDataProcessParameter.SubjectID{i},' OK']);
        end
        fprintf('\n');
    end
    AutoDataProcessParameter.StartingDirName=[AutoDataProcessParameter.StartingDirName,'C']; %Now StartingDirName is with new suffix 'C'
    
end



%Calculate ALFF and fALFF  %YAN Chao-Gan, 120827
if (AutoDataProcessParameter.IsCalALFF==1)
    
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'ALFF_',AutoDataProcessParameter.StartingDirName]);
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'fALFF_',AutoDataProcessParameter.StartingDirName]);
        
        parfor i=1:AutoDataProcessParameter.SubjectNum
            
            if AutoDataProcessParameter.TR==0  % Need to retrieve the TR information from the NIfTI images
                TR = AutoDataProcessParameter.TRSet(i,iFunSession);
            else
                TR = AutoDataProcessParameter.TR;
            end
            
            
            % ALFF and fALFF calculation
            [ALFFBrain, fALFFBrain, Header] = y_alff_falff([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}], ...
                TR, ...  
                AutoDataProcessParameter.CalALFF.ALowPass_HighCutoff, ...
                AutoDataProcessParameter.CalALFF.AHighPass_LowCutoff, ...
                AutoDataProcessParameter.MaskFileForEachSubject{i}, ...
                {[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'ALFF_',AutoDataProcessParameter.StartingDirName,filesep,'ALFFMap_',AutoDataProcessParameter.SubjectID{i},'.nii'];[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'fALFF_',AutoDataProcessParameter.StartingDirName,filesep,'fALFFMap_',AutoDataProcessParameter.SubjectID{i},'.nii']});

            % Get the m* files: divided by the mean within the mask
            % and the z* files: substract by the mean and then divided by the std within the mask
            
            if ~isempty(AutoDataProcessParameter.MaskFileForEachSubject{i}) %Added by YAN Chao-Gan 130605. Skip if mask is not defined.
                
                BrainMaskData=y_ReadRPI(AutoDataProcessParameter.MaskFileForEachSubject{i});
                
                Temp = (ALFFBrain ./ mean(ALFFBrain(find(BrainMaskData)))) .* (BrainMaskData~=0);
                y_Write(Temp,Header,[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'ALFF_',AutoDataProcessParameter.StartingDirName,filesep,'mALFFMap_',AutoDataProcessParameter.SubjectID{i},'.nii']);
                
                Temp = ((ALFFBrain - mean(ALFFBrain(find(BrainMaskData)))) ./ std(ALFFBrain(find(BrainMaskData)))) .* (BrainMaskData~=0);
                y_Write(Temp,Header,[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'ALFF_',AutoDataProcessParameter.StartingDirName,filesep,'zALFFMap_',AutoDataProcessParameter.SubjectID{i},'.nii']);
                
                
                Temp = (fALFFBrain ./ mean(fALFFBrain(find(BrainMaskData)))) .* (BrainMaskData~=0);
                y_Write(Temp,Header,[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'fALFF_',AutoDataProcessParameter.StartingDirName,filesep,'mfALFFMap_',AutoDataProcessParameter.SubjectID{i},'.nii']);
                
                Temp = ((fALFFBrain - mean(fALFFBrain(find(BrainMaskData)))) ./ std(fALFFBrain(find(BrainMaskData)))) .* (BrainMaskData~=0);
                y_Write(Temp,Header,[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'fALFF_',AutoDataProcessParameter.StartingDirName,filesep,'zfALFFMap_',AutoDataProcessParameter.SubjectID{i},'.nii']);
                
            end
        end
    end
end


%Filter ('AfterNormalize')
if (AutoDataProcessParameter.IsFilter==1) && (strcmpi(AutoDataProcessParameter.Filter.Timing,'AfterNormalize'))
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        parfor i=1:AutoDataProcessParameter.SubjectNum

            if AutoDataProcessParameter.TR==0  % Need to retrieve the TR information from the NIfTI images
                TR = AutoDataProcessParameter.TRSet(i,iFunSession);
            else
                TR = AutoDataProcessParameter.TR;
            end

            y_bandpass([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}], ...
                TR, ...
                AutoDataProcessParameter.Filter.ALowPass_HighCutoff, ...
                AutoDataProcessParameter.Filter.AHighPass_LowCutoff, ...
                AutoDataProcessParameter.Filter.AAddMeanBack, ...   %Revised by YAN Chao-Gan,100420. %AutoDataProcessParameter.Filter.ARetrend, ...
                ''); %
        end
    end
    
    %Copy the Filtered files to DataProcessDir\{AutoDataProcessParameter.StartingDirName}+F
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        parfor i=1:AutoDataProcessParameter.SubjectNum
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'F',filesep,AutoDataProcessParameter.SubjectID{i}])
            movefile([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}, '_filtered',filesep,'*'],[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'F',filesep,AutoDataProcessParameter.SubjectID{i}])

            rmdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}, '_filtered']);
            fprintf(['Moving Filtered Files:',AutoDataProcessParameter.SubjectID{i},' OK']);
        end
        fprintf('\n');
    end
    AutoDataProcessParameter.StartingDirName=[AutoDataProcessParameter.StartingDirName,'F']; %Now StartingDirName is with new suffix 'F'
    
end
    


%Scrubbing
if (AutoDataProcessParameter.IsScrubbing==1) && (strcmpi(AutoDataProcessParameter.Scrubbing.Timing,'AfterPreprocessing'))
    
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        parfor i=1:AutoDataProcessParameter.SubjectNum
            
            % Use FD_Power or FD_Jenkinson. YAN Chao-Gan, 121225.
            FD = load([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.Scrubbing.FDType,'_',AutoDataProcessParameter.SubjectID{i},'.txt']);
            %FD = load([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},'FD_Power_',AutoDataProcessParameter.SubjectID{i},'.txt']);
            
            TemporalMask=ones(length(FD),1);
            Index=find(FD > AutoDataProcessParameter.Scrubbing.FDThreshold);
            TemporalMask(Index)=0;
            IndexPrevious=Index;
            for iP=1:AutoDataProcessParameter.Scrubbing.PreviousPoints
                IndexPrevious=IndexPrevious-1;
                IndexPrevious=IndexPrevious(IndexPrevious>=1);
                TemporalMask(IndexPrevious)=0;
            end
            IndexNext=Index;
            for iN=1:AutoDataProcessParameter.Scrubbing.LaterPoints
                IndexNext=IndexNext+1;
                IndexNext=IndexNext(IndexNext<=length(FD));
                TemporalMask(IndexNext)=0;
            end
            
            %'B' stands for scrubbing
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'B',filesep,AutoDataProcessParameter.SubjectID{i}]);
            y_Scrubbing([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}], ...
                [AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'B',filesep,AutoDataProcessParameter.SubjectID{i},filesep,AutoDataProcessParameter.SubjectID{i},'_4DVolume.nii'],...
                '', ... %Don't need to use brain mask
                TemporalMask, AutoDataProcessParameter.Scrubbing.ScrubbingMethod, '');

        end
    end
    
    AutoDataProcessParameter.StartingDirName=[AutoDataProcessParameter.StartingDirName,'B']; %Now StartingDirName is with new suffix 'B': scrubbing
    
end
  



%Calculate ReHo
if (AutoDataProcessParameter.IsCalReHo==1)
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'ReHo_',AutoDataProcessParameter.StartingDirName]);
        
        parfor i=1:AutoDataProcessParameter.SubjectNum

            % ReHo Calculation
            [ReHoBrain, Header] = y_reho([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}], ...
                AutoDataProcessParameter.CalReHo.ClusterNVoxel, ...
                AutoDataProcessParameter.MaskFileForEachSubject{i}, ...
                [AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'ReHo_',AutoDataProcessParameter.StartingDirName,filesep,'ReHoMap_',AutoDataProcessParameter.SubjectID{i},'.nii']);

            % Get the m* files: divided by the mean within the mask
            % and the z* files: substract by the mean and then divided by the std within the mask
            
            if ~isempty(AutoDataProcessParameter.MaskFileForEachSubject{i}) %Added by YAN Chao-Gan 130605. Skip if mask is not defined.
                BrainMaskData=y_ReadRPI(AutoDataProcessParameter.MaskFileForEachSubject{i});
                
                Temp = (ReHoBrain ./ mean(ReHoBrain(find(BrainMaskData)))) .* (BrainMaskData~=0);
                y_Write(Temp,Header,[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'ReHo_',AutoDataProcessParameter.StartingDirName,filesep,'mReHoMap_',AutoDataProcessParameter.SubjectID{i},'.nii']);
                
                Temp = ((ReHoBrain - mean(ReHoBrain(find(BrainMaskData)))) ./ std(ReHoBrain(find(BrainMaskData)))) .* (BrainMaskData~=0);
                y_Write(Temp,Header,[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'ReHo_',AutoDataProcessParameter.StartingDirName,filesep,'zReHoMap_',AutoDataProcessParameter.SubjectID{i},'.nii']);
            end
            
            
            
            %YAN Chao-Gan, 121224. Add the option of smooth reho back.
            if AutoDataProcessParameter.CalReHo.SmoothReHo == 1

                FileList=[];
                FileList{1,1}=[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'ReHo_',AutoDataProcessParameter.StartingDirName,filesep,'ReHoMap_',AutoDataProcessParameter.SubjectID{i},'.nii'];
                FileList{2,1}=[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'ReHo_',AutoDataProcessParameter.StartingDirName,filesep,'mReHoMap_',AutoDataProcessParameter.SubjectID{i},'.nii'];
                FileList{3,1}=[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'ReHo_',AutoDataProcessParameter.StartingDirName,filesep,'zReHoMap_',AutoDataProcessParameter.SubjectID{i},'.nii'];
                
                
                SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Smooth.mat']);
                SPMJOB.matlabbatch{1,1}.spm.spatial.smooth.data = FileList;
                SPMJOB.matlabbatch{1,1}.spm.spatial.smooth.fwhm = AutoDataProcessParameter.Smooth.FWHM;
                spm_jobman('run',SPMJOB.matlabbatch); 

            end

        end
    end
end



%Calculate Degree Centrality
if (AutoDataProcessParameter.IsCalDegreeCentrality==1)
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'DegreeCentrality_',AutoDataProcessParameter.StartingDirName]);
        
        parfor i=1:AutoDataProcessParameter.SubjectNum

            % Degree Centrality Calculation
            [DegreeCentrality_PositiveWeightedSumBrain, DegreeCentrality_PositiveBinarizedSumBrain, Header] = y_DegreeCentrality([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}], ...
                AutoDataProcessParameter.CalDegreeCentrality.rThreshold, ...
                {[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'DegreeCentrality_',AutoDataProcessParameter.StartingDirName,filesep,'DegreeCentrality_PositiveWeightedSumBrainMap_',AutoDataProcessParameter.SubjectID{i},'.nii'];[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'DegreeCentrality_',AutoDataProcessParameter.StartingDirName,filesep,'DegreeCentrality_PositiveBinarizedSumBrainMap_',AutoDataProcessParameter.SubjectID{i},'.nii']}, ...
                AutoDataProcessParameter.MaskFileForEachSubject{i});

            
            % Get the m* files: divided by the mean within the mask
            % and the z* files: substract by the mean and then divided by the std within the mask
            
            if ~isempty(AutoDataProcessParameter.MaskFileForEachSubject{i}) %Added by YAN Chao-Gan 130605. Skip if mask is not defined.
                BrainMaskData=y_ReadRPI(AutoDataProcessParameter.MaskFileForEachSubject{i});
                
                Temp = (DegreeCentrality_PositiveWeightedSumBrain ./ mean(DegreeCentrality_PositiveWeightedSumBrain(find(BrainMaskData)))) .* (BrainMaskData~=0);
                y_Write(Temp,Header,[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'DegreeCentrality_',AutoDataProcessParameter.StartingDirName,filesep,'mDegreeCentrality_PositiveWeightedSumBrainMap_',AutoDataProcessParameter.SubjectID{i},'.nii']);
                
                Temp = ((DegreeCentrality_PositiveWeightedSumBrain - mean(DegreeCentrality_PositiveWeightedSumBrain(find(BrainMaskData)))) ./ std(DegreeCentrality_PositiveWeightedSumBrain(find(BrainMaskData)))) .* (BrainMaskData~=0);
                y_Write(Temp,Header,[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'DegreeCentrality_',AutoDataProcessParameter.StartingDirName,filesep,'zDegreeCentrality_PositiveWeightedSumBrainMap_',AutoDataProcessParameter.SubjectID{i},'.nii']);
                
                
                Temp = (DegreeCentrality_PositiveBinarizedSumBrain ./ mean(DegreeCentrality_PositiveBinarizedSumBrain(find(BrainMaskData)))) .* (BrainMaskData~=0);
                y_Write(Temp,Header,[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'DegreeCentrality_',AutoDataProcessParameter.StartingDirName,filesep,'mDegreeCentrality_PositiveBinarizedSumBrainMap_',AutoDataProcessParameter.SubjectID{i},'.nii']);
                
                Temp = ((DegreeCentrality_PositiveBinarizedSumBrain - mean(DegreeCentrality_PositiveBinarizedSumBrain(find(BrainMaskData)))) ./ std(DegreeCentrality_PositiveBinarizedSumBrain(find(BrainMaskData)))) .* (BrainMaskData~=0);
                y_Write(Temp,Header,[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'DegreeCentrality_',AutoDataProcessParameter.StartingDirName,filesep,'zDegreeCentrality_PositiveBinarizedSumBrainMap_',AutoDataProcessParameter.SubjectID{i},'.nii']);
            end
        end
    end
end





% Define ROI Interactively
if (AutoDataProcessParameter.IsDefineROIInteractively==1) && AutoDataProcessParameter.IsAllowGUI
    prompt ={'How many ROIs do you want to define interactively?', 'ROI Radius (mm. "0" means define for each ROI seperately): '};
    def	={	'1', ...
        '0', ...
        };
    options.Resize='on';
    options.WindowStyle='modal';
    options.Interpreter='tex';
    answer =inputdlg(prompt, 'Define ROI Interactively', 1, def,options);
    if numel(answer)==2,
        ROINumber_DefinedInteractively =abs(round(str2num(answer{1})));
        ROIRadius_DefinedInteractively =abs(round(str2num(answer{2})));
    end
    ROIRadius_DefinedInteractively=ROIRadius_DefinedInteractively*ones(AutoDataProcessParameter.SubjectNum,ROINumber_DefinedInteractively);
%     ROICenter_DefinedInteractively=zeros(AutoDataProcessParameter.SubjectNum,ROINumber_DefinedInteractively);
    for i=1:AutoDataProcessParameter.SubjectNum
        DirT1ImgCoreg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.img']);
        if isempty(DirT1ImgCoreg)  %YAN Chao-Gan, 111114. Also support .nii files.
            DirT1ImgCoreg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii']);
        end
        for iROI=1:ROINumber_DefinedInteractively
            fprintf('Define ROI %d interactively for %s: \n',iROI,AutoDataProcessParameter.SubjectID{i});
            global y_spm_image_Parameters
            uiwait(y_spm_image('init',[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1ImgCoreg(1).name]));
            ROICenter_DefinedInteractively{i,iROI}=reshape(y_spm_image_Parameters.pos,1,[]);
            clear global y_spm_image_Parameters
            if ROIRadius_DefinedInteractively(i,iROI)==0
                answer =inputdlg(sprintf('ROI Radius (mm) for ROI %d with %s: \n',iROI,AutoDataProcessParameter.SubjectID{i}), 'Define ROI Interactively', 1, {'0'},options);
                ROIRadius_DefinedInteractively(i,iROI) =abs(round(str2num(answer{1})));
            end
        end
    end
    AutoDataProcessParameter.ROICenter_DefinedInteractively=ROICenter_DefinedInteractively;
    AutoDataProcessParameter.ROIRadius_DefinedInteractively=ROIRadius_DefinedInteractively;
    AutoDataProcessParameter.ROINumber_DefinedInteractively=ROINumber_DefinedInteractively;
    
    
    %Save the Interactively Defined ROIs into as ROI_DefinedInteractively.tsv
    fid = fopen([AutoDataProcessParameter.DataProcessDir,filesep,'ROI_DefinedInteractively.tsv'],'w');
    fprintf(fid,'Subject ID\tROI Number\tROI Center X\tROI Center Y\tROI Center Z\tROI Radius\n');
    for i=1:AutoDataProcessParameter.SubjectNum
        for iROI=1:AutoDataProcessParameter.ROINumber_DefinedInteractively
            fprintf(fid,'%s\t',AutoDataProcessParameter.SubjectID{i});
            fprintf(fid,'%g\t',iROI);
            fprintf(fid,'%g\t',[AutoDataProcessParameter.ROICenter_DefinedInteractively{i,iROI},AutoDataProcessParameter.ROIRadius_DefinedInteractively(i,iROI)]);
            fprintf(fid,'\n');
        end
    end
    fclose(fid);
    
end




% Generate the appropriate ROI masks
if (~isempty(AutoDataProcessParameter.CalFC.ROIDef)) || (AutoDataProcessParameter.IsDefineROIInteractively==1)
    if ~isfield(AutoDataProcessParameter,'ROINumber_DefinedInteractively')
        AutoDataProcessParameter.ROINumber_DefinedInteractively=0;
    end
    
    if ~(7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'Masks'],'dir'))
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'Masks']);
    end
    
    % Check if masks appropriate %This can be used as a function!!!
    ROIDefForEachSubject=cell(AutoDataProcessParameter.SubjectNum,1);
    parfor i=1:AutoDataProcessParameter.SubjectNum
        Suffix='FCROI_'; %%!!! Change as in Function
        SubjectROI=AutoDataProcessParameter.CalFC.ROIDef;%%!!! Change as in Fuction
        RefFile=dir([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.img']);
        if isempty(RefFile)  %YAN Chao-Gan, 111114. Also support .nii files.
            RefFile=dir([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii']);
        end
        if isempty(RefFile)  %YAN Chao-Gan, 120827. Also support .nii files.
            RefFile=dir([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii.gz']);
        end
        RefFile=[AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,RefFile(1).name];
        [RefData,RefVox,RefHeader]=y_ReadRPI(RefFile,1);
        % Ball to mask
        for iROI=1:length(SubjectROI)
            if strcmpi(int2str(size(SubjectROI{iROI})),int2str([1, 4]))  %Sphere ROI definition: CenterX, CenterY, CenterZ, Radius
                
                ROIMaskName=[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,Suffix,num2str(iROI),'_',AutoDataProcessParameter.SubjectID{i},'.nii'];
                
                if (AutoDataProcessParameter.IsWarpMasksIntoIndividualSpace==0)
                    y_Sphere(SubjectROI{iROI}(1:3), SubjectROI{iROI}(4), RefFile, ROIMaskName);
                else
                    y_Sphere(SubjectROI{iROI}(1:3), SubjectROI{iROI}(4), [TemplatePath,filesep,'aal.nii'], ROIMaskName);
                end

                SubjectROI{iROI}=[ROIMaskName];
            end
        end
        
        
        if AutoDataProcessParameter.IsWarpMasksIntoIndividualSpace==1
            %Need to warp masks
            
            % Check if have .txt file. Note: the txt files should be put the last of the ROI definition
            NeedWarpMaskNameSet=[];
            WarpedMaskNameSet=[];
            for iROI=1:length(SubjectROI)
                if exist(SubjectROI{iROI},'file')==2
                    [pathstr, name, ext] = fileparts(SubjectROI{iROI});
                    if (~strcmpi(ext, '.txt'))
                        NeedWarpMaskNameSet=[NeedWarpMaskNameSet;{SubjectROI{iROI}}];
                        WarpedMaskNameSet=[WarpedMaskNameSet;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'WarpedMasks',filesep,Suffix,num2str(iROI),'_',AutoDataProcessParameter.SubjectID{i},'.nii']}];
                        
                        SubjectROI{iROI}=[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'WarpedMasks',filesep,Suffix,num2str(iROI),'_',AutoDataProcessParameter.SubjectID{i},'.nii'];
                    end
                end
            end
            
            
            if (7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1}],'dir'))
                % If is processed by New Segment and DARTEL
                
                TemplateDir_SubID=AutoDataProcessParameter.SubjectID{1};
                
                if exist([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,TemplateDir_SubID,filesep,'Template_6.nii.gz'],'file') %YAN Chao-Gan, 151129
                    gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,TemplateDir_SubID,filesep,'Template_6.nii.gz']);
                    delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,TemplateDir_SubID,filesep,'Template_6.nii.gz']);
                end
                DARTELTemplateFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,TemplateDir_SubID,filesep,'Template_6.nii'];
                DARTELTemplateMatFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,TemplateDir_SubID,filesep,'Template_6_2mni.mat'];
                
                DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'u_*']);
                [pathstr,name,ext] = fileparts(DirImg(1).name); %YAN Chao-Gan, 151129. Check if it's .nii.gz
                if strcmpi(ext,'.gz')
                    gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]);
                    delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]);
                    DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'u_*']);
                end
                FlowFieldFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name];
                
                if ~isempty(NeedWarpMaskNameSet) %YAN Chao-Gan, 180320. In case there was only txt ROI
                    y_WarpBackByDARTEL(NeedWarpMaskNameSet,WarpedMaskNameSet,RefFile,DARTELTemplateFilename,DARTELTemplateMatFilename,FlowFieldFilename,0);
                end
                
                for iROI=1:length(NeedWarpMaskNameSet)
                    fprintf('\nWarp %s Mask (%s) for "%s" to individual space using DARTEL flow field (in T1ImgNewSegment) genereated by DARTEL.\n',Suffix,NeedWarpMaskNameSet{iROI}, AutoDataProcessParameter.SubjectID{i});
                end
                
            elseif (7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgSegment',filesep,AutoDataProcessParameter.SubjectID{1}],'dir'))
                % If is processed by unified segmentation
                
                MatFileDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*seg_inv_sn.mat']);
                MatFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,MatFileDir(1).name];
                
                for iROI=1:length(NeedWarpMaskNameSet)
                    y_NormalizeWrite(NeedWarpMaskNameSet{iROI},WarpedMaskNameSet{iROI},RefFile,MatFilename,0);
                    fprintf('\nWarp %s Mask (%s) for "%s" to individual space using *seg_inv_sn.mat (in T1ImgSegment) genereated by T1 image segmentation.\n',Suffix,NeedWarpMaskNameSet{iROI}, AutoDataProcessParameter.SubjectID{i});
                end
                
            end
            
        else %Do not need to warp masks but may need to resample
            
            % Check if the ROI mask is appropriate
            for iROI=1:length(SubjectROI)
                AMaskFilename=SubjectROI{iROI};
                if exist(SubjectROI{iROI},'file')==2
                    [pathstr, name, ext] = fileparts(SubjectROI{iROI});
                    if (~strcmpi(ext, '.txt'))
                        [MaskData,MaskVox,MaskHeader]=y_ReadRPI(AMaskFilename);
                        if ~isequal(size(MaskData), size(RefData))
                            fprintf('\nReslice %s Mask (%s) for "%s" since the dimension of mask mismatched the dimension of the functional data.\n',Suffix,AMaskFilename, AutoDataProcessParameter.SubjectID{i});
                            
                            ReslicedMaskName=[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,Suffix,num2str(iROI),'_',AutoDataProcessParameter.SubjectID{i},'.nii'];
                            y_Reslice(AMaskFilename,ReslicedMaskName,RefVox,0, RefFile);
                            SubjectROI{iROI}=ReslicedMaskName;
                        end
                    end
                end
            end
            
        end
        
        % Check if the text file is a definition for multiple subjects. i.e., the first line is 'Seed_Time_Course_List:', then get the corresponded seed series file
        for iROI=1:length(SubjectROI)
            if (ischar(SubjectROI{iROI})) && (exist(SubjectROI{iROI},'file')==2)
                [pathstr, name, ext] = fileparts(SubjectROI{iROI});
                if (strcmpi(ext, '.txt'))
                    fid = fopen(SubjectROI{iROI});
                    SeedTimeCourseList=textscan(fid,'%s\n'); %YAN Chao-Gan, 180320. For compatiblity of MALLAB 2014b. SeedTimeCourseList=textscan(fid,'%s','\n'); 
                    fclose(fid);
                    if strcmpi(SeedTimeCourseList{1}{1},'Seed_Time_Course_List:') || strcmpi(SeedTimeCourseList{1}{1},'Seed_ROI_List:')
                        SubjectROI{iROI}=SeedTimeCourseList{1}{i+1};
                    end
                end
            end
            
        end
        
        ROIDefForEachSubject{i}=SubjectROI; %%!!! Change as in Fuction
        
        % Process ROIs defined interactively
        % These files don't need to warp, cause they are defined in original space and mask was created in original space.
        Suffix='ROIDefinedInteractively_';
        for iROI=1:AutoDataProcessParameter.ROINumber_DefinedInteractively

            ROIMaskName=[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,Suffix,num2str(iROI),'_',AutoDataProcessParameter.SubjectID{i},'.nii'];

            y_Sphere(AutoDataProcessParameter.ROICenter_DefinedInteractively{i,iROI}, AutoDataProcessParameter.ROIRadius_DefinedInteractively(i,iROI), RefFile, ROIMaskName);

            ROIDefForEachSubject{i}{length(AutoDataProcessParameter.CalFC.ROIDef)+iROI}=[ROIMaskName];
        end

    end
    
    AutoDataProcessParameter.CalFC.ROIDefForEachSubject = ROIDefForEachSubject;
end




%Functional Connectivity Calculation (by Seed based Correlation Anlyasis)
if (AutoDataProcessParameter.IsCalFC==1)
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FC_',AutoDataProcessParameter.StartingDirName]);
        
        parfor i=1:AutoDataProcessParameter.SubjectNum
            
            % Calculate Functional Connectivity by Seed based Correlation Anlyasis

            y_SCA([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}], ...
                AutoDataProcessParameter.CalFC.ROIDefForEachSubject{i}, ...
                [AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FC_',AutoDataProcessParameter.StartingDirName,filesep,'FCMap_',AutoDataProcessParameter.SubjectID{i}], ...
                AutoDataProcessParameter.MaskFileForEachSubject{i}, ...
                AutoDataProcessParameter.CalFC.IsMultipleLabel,AutoDataProcessParameter.CalFC.ROISelectedIndex);
            
            % Fisher's r to z transformation has been performed inside y_SCA
            
        end
    end
end




%Extract ROI Signals
if (AutoDataProcessParameter.IsExtractROISignals==1)
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'ROISignals_',AutoDataProcessParameter.StartingDirName]);
        
        %Extract the ROI time courses
        parfor i=1:AutoDataProcessParameter.SubjectNum
            
            y_ExtractROISignal([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}], ...
                AutoDataProcessParameter.CalFC.ROIDefForEachSubject{i}, ...
                [AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'ROISignals_',AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}], ...
                '', ... % Will not restrict into the brain mask in extracting ROI signals
                AutoDataProcessParameter.CalFC.IsMultipleLabel,AutoDataProcessParameter.CalFC.ROISelectedIndex);
            
            
            %YAN Chao-Gan, 210119. Also Extract Center of Mass.
            y_ExtractROICenterOfMass(AutoDataProcessParameter.CalFC.ROIDefForEachSubject{i}, ...
                [AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'ROISignals_',AutoDataProcessParameter.StartingDirName,filesep,'ROI_CenterOfMass_',AutoDataProcessParameter.SubjectID{i}], ...
                AutoDataProcessParameter.CalFC.IsMultipleLabel, AutoDataProcessParameter.CalFC.ROISelectedIndex, ...
                [AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
            
            %y_ExtractROICenterOfMass(ROIDef, OutputName, IsMultipleLabel, RefFile, Header)    
        end
    end
end






%Calculate CWAS: This should be performed in MNI Space (4*4*4) and only one session!
if (AutoDataProcessParameter.IsCWAS==1)
    for iFunSession=1:1
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'CWAS_',AutoDataProcessParameter.StartingDirName]);

        % CWAS Calculation
        [p_Brain, F_Brain, Header] = y_CWAS([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName], ...
            AutoDataProcessParameter.SubjectID, ...
            [AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'CWAS_',AutoDataProcessParameter.StartingDirName,filesep,'CWAS.nii'], ...
            AutoDataProcessParameter.CWAS.Regressors, ...
            AutoDataProcessParameter.CWAS.iter);
        
    end
end





%%%%
%Normalize to symmetric template

if AutoDataProcessParameter.IsNormalizeToSymmetricGroupT1Mean==1
    
    mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'SymmetricGroupT1MeanTemplate']);
    
    %Get the normalized T1 image files
    if (7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgSegment',filesep,AutoDataProcessParameter.SubjectID{1}],'dir'))
        T1ImgSegmentDirectoryName = 'T1ImgSegment';
        T1VoxSize = [2 2 2];
    elseif (7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1}],'dir'))
        T1ImgSegmentDirectoryName = 'T1ImgNewSegment';
        T1VoxSize = [1.5 1.5 1.5];
    end
    
    for i=1:AutoDataProcessParameter.SubjectNum
        DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'w*.img']);
        if isempty(DirImg)
            DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'w*.nii']);
        end
        if isempty(DirImg)
            DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'w*.nii.gz']);
        end

        for iFile = 1:length(DirImg)
            if ~( strcmpi(DirImg(iFile).name(1:3),'wc1') || strcmpi(DirImg(iFile).name(1:3),'wc2') || strcmpi(DirImg(iFile).name(1:3),'wc3') )
                SubwT1File{i} = [AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(iFile).name];
            end
        end
    end
    
    %Create Group T1 Template
    GroupT1Sum=0;
    for i=1:AutoDataProcessParameter.SubjectNum
        [pathstr,name,ext] = fileparts(SubwT1File{i}); %YAN Chao-Gan, 151129. Check if it's .nii.gz
        if strcmpi(ext,'.gz')
            gunzip(SubwT1File{i});
            delete(SubwT1File{i});
            SubwT1File{i} = SubwT1File{i}(1:end-3);
        end
        
        [Data Vox Head]=y_ReadRPI(SubwT1File{i});
        GroupT1Sum = GroupT1Sum + Data;
    end
    GroupT1Mean = GroupT1Sum/AutoDataProcessParameter.SubjectNum;
    GroupT1MeanFileName = [AutoDataProcessParameter.DataProcessDir,filesep,'SymmetricGroupT1MeanTemplate',filesep,'GroupT1MeanTemplate.nii'];
    y_Write(GroupT1Mean, Head, GroupT1MeanFileName);
    
    SymmetricGroupT1Mean = (GroupT1Mean + flipdim(GroupT1Mean,1))/2;
    SymmetricGroupT1MeanFileName = [AutoDataProcessParameter.DataProcessDir,filesep,'SymmetricGroupT1MeanTemplate',filesep,'SymmetricGroupT1MeanTemplate.nii'];
    y_Write(SymmetricGroupT1Mean, Head, SymmetricGroupT1MeanFileName);
    
    
    %Normalize to symmetric template
    parfor i=1:AutoDataProcessParameter.SubjectNum
        FileList=[];
        for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
            cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
            DirImg=dir('*.img');
            if isempty(DirImg)  %YAN Chao-Gan, 111114. Also support .nii files. % Either in .nii.gz or in .nii
                DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirImg)==1
                    gunzip(DirImg(1).name);
                    delete(DirImg(1).name);
                end
                DirImg=dir('*.nii');
            end
            
            if length(DirImg)>1  %3D .img or .nii images.
                if AutoDataProcessParameter.TimePoints>0 && length(DirImg)~=AutoDataProcessParameter.TimePoints % Will not check if TimePoints set to 0. YAN Chao-Gan 120806.
                    Error=[Error;{['Error in Normalize, time point number doesn''t match: ',AutoDataProcessParameter.SubjectID{i}]}];
                end
                for j=1:length(DirImg)
                    FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(j).name]}];
                end
            else %4D .nii images
                Nii  = nifti(DirImg(1).name);
                if AutoDataProcessParameter.TimePoints>0 && size(Nii.dat,4)~=AutoDataProcessParameter.TimePoints % Will not check if TimePoints set to 0. YAN Chao-Gan 120806.
                    Error=[Error;{['Error in Normalize, time point number doesn''t match: ',AutoDataProcessParameter.SubjectID{i}]}];
                end
                
                FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]}];
                %YAN Chao-Gan, 130301. Fixed a bug (leave session 1) in multiple sessions.  %FileList={[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]};
            end
        end
        
        
        SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Normalize.mat']);

        SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.subj(1,1).source=SubwT1File(i);
        SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.subj(1,1).resample=FileList;
        
        SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.eoptions.template={SymmetricGroupT1MeanFileName};
        
        SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.eoptions.regtype = 'none'; %No regularisation because all the source images and the template images are in MNI space already.
        
        SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.roptions.bb=AutoDataProcessParameter.Normalize.BoundingBox;
        SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.roptions.vox=AutoDataProcessParameter.Normalize.VoxSize;
        
        SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.roptions.prefix = 'sym_';
        
        if SPMversion==12    % YAN Chao-Gan, 150703. In SPM 12, Segment (in SPM8) has turned to Old Segment.
            oldnorm = SPMJOB.matlabbatch{1,1}.spm.spatial.normalise;
            SPMJOB=[];
            SPMJOB.matlabbatch{1,1}.spm.tools.oldnorm = oldnorm;
        end

        spm_jobman('run',SPMJOB.matlabbatch);
        
                
        %Also normalize T1 image to symmetric template
        if SPMversion==8
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.subj(1,1).resample=SubwT1File(i);
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.roptions.vox=T1VoxSize;
        elseif SPMversion==12
            SPMJOB.matlabbatch{1,1}.spm.tools.oldnorm.estwrite.subj(1,1).resample=SubwT1File(i);
            SPMJOB.matlabbatch{1,1}.spm.tools.oldnorm.estwrite.roptions.vox=T1VoxSize;
        end
        
        spm_jobman('run',SPMJOB.matlabbatch);
        
        fprintf(['Normalize to symmetric group T1 mean Template:',AutoDataProcessParameter.SubjectID{i},' OK\n']);


    end

    %Copy the Normalized files to DataProcessDir\{AutoDataProcessParameter.StartingDirName}+sym
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        parfor i=1:AutoDataProcessParameter.SubjectNum
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'sym',filesep,AutoDataProcessParameter.SubjectID{i}])
            movefile([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'sym_*'],[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'sym',filesep,AutoDataProcessParameter.SubjectID{i}])
            fprintf(['Moving Normalized Files:',AutoDataProcessParameter.SubjectID{i},' OK']);
        end
        fprintf('\n');
    end
    AutoDataProcessParameter.StartingDirName=[AutoDataProcessParameter.StartingDirName,'sym']; %Now StartingDirName is with new suffix 'sym'

end


%Smooth on functional data right before VMHC %YAN Chao-Gan, 151119
if (AutoDataProcessParameter.IsSmoothBeforeVMHC==1)
    parfor i=1:AutoDataProcessParameter.SubjectNum
        FileList=[];
        for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
            cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
            DirImg=dir('*.img');
            if isempty(DirImg)  %YAN Chao-Gan, 111114. Also support .nii files. % Either in .nii.gz or in .nii
                DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirImg)==1
                    gunzip(DirImg(1).name);
                    delete(DirImg(1).name);
                end
                DirImg=dir('*.nii');
            end
            
            if length(DirImg)>1  %3D .img or .nii images.
                if AutoDataProcessParameter.TimePoints>0 && length(DirImg)~=AutoDataProcessParameter.TimePoints % Will not check if TimePoints set to 0. YAN Chao-Gan 120806.
                    Error=[Error;{['Error in Smooth: ',AutoDataProcessParameter.SubjectID{i}]}];
                end
                for j=1:length(DirImg)
                    FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(j).name]}];
                end
            else %4D .nii images
                Nii  = nifti(DirImg(1).name);
                if AutoDataProcessParameter.TimePoints>0 && size(Nii.dat,4)~=AutoDataProcessParameter.TimePoints % Will not check if TimePoints set to 0. YAN Chao-Gan 120806.
                    Error=[Error;{['Error in Smooth: ',AutoDataProcessParameter.SubjectID{i}]}];
                end
                
                FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]}];
                %YAN Chao-Gan, 130301. Fixed a bug (leave session 1) in smooth in multiple sessions.  %FileList={[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]};
                
            end
        end
        
        SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Smooth.mat']);
        SPMJOB.matlabbatch{1,1}.spm.spatial.smooth.data = FileList;
        SPMJOB.matlabbatch{1,1}.spm.spatial.smooth.fwhm = AutoDataProcessParameter.Smooth.FWHM;
        spm_jobman('run',SPMJOB.matlabbatch);
        
        fprintf(['Smooth:',AutoDataProcessParameter.SubjectID{i},' OK']);
    end
    
    
    %Copy the Smoothed files to DataProcessDir\{AutoDataProcessParameter.StartingDirName}+S
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        parfor i=1:AutoDataProcessParameter.SubjectNum
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'S',filesep,AutoDataProcessParameter.SubjectID{i}])
            
            %YAN Chao-Gan, 151124. In considering the files initiated wity sym_
            DirList = dir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'s*']);
            for iFile=1:length(DirList)
                if ~strcmpi(DirList(iFile).name(1:4),'sym_')
                    movefile([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirList(iFile).name],[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'S',filesep,AutoDataProcessParameter.SubjectID{i}])
                end
            end
            fprintf(['Moving Smoothed Files:',AutoDataProcessParameter.SubjectID{i},' OK']);
        end
        fprintf('\n');
    end
    
    AutoDataProcessParameter.StartingDirName=[AutoDataProcessParameter.StartingDirName,'S']; %Now StartingDirName is with new suffix 'S'
end
if ~isempty(Error)
    disp(Error);
    return;
end


%Calculate VMHC: This usually performed in MNI Space
if (AutoDataProcessParameter.IsCalVMHC==1)
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'VMHC_',AutoDataProcessParameter.StartingDirName]);
        
        parfor i=1:AutoDataProcessParameter.SubjectNum

            % VMHC Calculation
            [VMHCBrain, Header] = y_VMHC([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}], ...
                [AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'VMHC_',AutoDataProcessParameter.StartingDirName,filesep,'VMHCMap_',AutoDataProcessParameter.SubjectID{i},'.nii'], ...
                AutoDataProcessParameter.MaskFileForEachSubject{i});

            
            % Get the z* files: Fisher's r to z transformation
            
            VMHCBrain(find(VMHCBrain >= 1)) = 1 - 1E-16; %YAN Chao-Gan, 121225. Supress the voxels with extremely high correlation values (e.g., have value of 1).
                  
            zVMHCBrain = (0.5 * log((1 + VMHCBrain)./(1 - VMHCBrain)));

            y_Write(zVMHCBrain,Header,[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'VMHC_',AutoDataProcessParameter.StartingDirName,filesep,'zVMHCMap_',AutoDataProcessParameter.SubjectID{i},'.nii']);

        end
    end
end






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%***Normalize and/or Smooth the results***%%%%%%%%%%%%%%%%

AutoDataProcessParameter.StartingDirName = 'Results';

%Normalize on Results
if (AutoDataProcessParameter.IsNormalize>0) && strcmpi(AutoDataProcessParameter.Normalize.Timing,'OnResults')

    %Check the measures need to be normalized
    DirMeasure = dir([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName]);
    if strcmpi(DirMeasure(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
        StartIndex=4;
    else
        StartIndex=3;
    end
    MeasureSet=[];
    for iDir=StartIndex:length(DirMeasure)
        if DirMeasure(iDir).isdir
            if ~( (length(DirMeasure(iDir).name)>=4 && strcmpi(DirMeasure(iDir).name(1:4),'VMHC')) || (length(DirMeasure(iDir).name)>=10 && strcmpi(DirMeasure(iDir).name(1:10),'ROISignals')))   %~(strcmpi(DirMeasure(iDir).name,'VMHC') || (length(DirMeasure(iDir).name)>10 && strcmpi(DirMeasure(iDir).name(end-10:end),'_ROISignals')))
                MeasureSet = [MeasureSet;{DirMeasure(iDir).name}];
            end
        end
        
    end
    
    fprintf(['Normalizing the resutls into MNI space...\n']);

    
    parfor i=1:AutoDataProcessParameter.SubjectNum
        
        FileList=[];
        for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
            for iMeasure=1:length(MeasureSet)
                cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,MeasureSet{iMeasure}]);
                DirImg=dir(['*',AutoDataProcessParameter.SubjectID{i},'*.img']);
                for j=1:length(DirImg)
                    FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,MeasureSet{iMeasure},filesep,DirImg(j).name]}];
                end
                
                DirImg=dir(['*',AutoDataProcessParameter.SubjectID{i},'*.nii']);
                for j=1:length(DirImg)
                    FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,MeasureSet{iMeasure},filesep,DirImg(j).name]}];
                end
            end
            
        end
        
        % Set the mean functional image % YAN Chao-Gan, 120826
        DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.img']);
        if isempty(DirMean)  %YAN Chao-Gan, 111114. Also support .nii files.
            DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.nii.gz']);% Search .nii.gz and unzip; YAN Chao-Gan, 120806.
            if length(DirMean)==1
                gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name]);
                delete([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name]);
            end
            DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.nii']);
        end
        MeanFilename = [AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name];
        
        FileList=[FileList;{MeanFilename}]; %YAN Chao-Gan, 120826. Also normalize the mean functional image.
        
        %Set the automasks to be normalized. %YAN Chao-Gan, 140401.
        if (7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'AutoMasks'],'dir'))
            for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                AutomaskFile = [AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'AutoMasks',filesep,FunSessionPrefixSet{iFunSession},'AutoMask_',AutoDataProcessParameter.SubjectID{i},'.nii'];
                AutomaskFileDir = dir(AutomaskFile); %YAN Chao-Gan, 181116. In case Automask.nii was zipped.
                if isempty(AutomaskFileDir)
                    gunzip([AutomaskFile,'.gz']);
                    delete([AutomaskFile,'.gz']);
                end
                FileList=[FileList;{AutomaskFile}];
            end
        end

        if (AutoDataProcessParameter.IsNormalize==1) %Normalization by using the EPI template directly
            
            SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Normalize.mat']);
            
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.subj(1,1).source={MeanFilename};
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.subj(1,1).resample=FileList;
            
            %SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.eoptions.template={[SPMFilePath,filesep,'templates',filesep,'EPI.nii,1']};
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.eoptions.template={[SPMFilePath,filesep,'toolbox',filesep,'OldNorm',filesep,'EPI.nii,1']}; %YAN Chao-Gan, 161006.
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.roptions.bb=AutoDataProcessParameter.Normalize.BoundingBox;
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.roptions.vox=AutoDataProcessParameter.Normalize.VoxSize;

            %YAN Chao-Gan, 140815.
            if isfield(AutoDataProcessParameter,'SpecialMode') && (AutoDataProcessParameter.SpecialMode == 2)  %Special Mode: Monkey
                SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.eoptions.template={[TemplatePath,filesep,'WisconsinRhesusMacaqueAtlases',filesep,'112RM-SL_T2.nii,1']};
            end
            
            
            if SPMversion==12    % YAN Chao-Gan, 150703. In SPM 12, Segment (in SPM8) has turned to Old Segment.
                oldnorm = SPMJOB.matlabbatch{1,1}.spm.spatial.normalise;
                if (~isfield(AutoDataProcessParameter,'SpecialMode')) || (isfield(AutoDataProcessParameter,'SpecialMode') && (AutoDataProcessParameter.SpecialMode == 1))
                    oldnorm.estwrite.eoptions.template={[SPMFilePath,filesep,'toolbox',filesep,'OldNorm',filesep,'EPI.nii,1']};
                end
                SPMJOB=[];
                SPMJOB.matlabbatch{1,1}.spm.tools.oldnorm = oldnorm;
            end
            
            spm_jobman('run',SPMJOB.matlabbatch);
        end
        
        if (AutoDataProcessParameter.IsNormalize==2) %Normalization by using the T1 image segment information
            %Normalize-Write: Using the segment information
            SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Normalize_Write.mat']);
            
            MatFileDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*seg_sn.mat']);
            MatFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,MatFileDir(1).name];
            
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.write.subj(1,1).matname={MatFilename};
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.write.subj(1,1).resample=FileList;
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.write.roptions.bb=AutoDataProcessParameter.Normalize.BoundingBox;
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.write.roptions.vox=AutoDataProcessParameter.Normalize.VoxSize;
            
            if SPMversion==12    % YAN Chao-Gan, 150703. In SPM 12, Segment (in SPM8) has turned to Old Segment.
                oldnorm = SPMJOB.matlabbatch{1,1}.spm.spatial.normalise;
                SPMJOB=[];
                SPMJOB.matlabbatch{1,1}.spm.tools.oldnorm = oldnorm;
            end
            
            spm_jobman('run',SPMJOB.matlabbatch);
            
        end
        
        if (AutoDataProcessParameter.IsNormalize==3) %Normalization by using DARTEL %YAN Chao-Gan, 111111.
            
            SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Dartel_NormaliseToMNI_FewSubjects.mat']);
            
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.fwhm=[0 0 0];
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.preserve=0;
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.bb=AutoDataProcessParameter.Normalize.BoundingBox;
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.vox=AutoDataProcessParameter.Normalize.VoxSize;
            
            DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1},filesep,'Template_6.*']);
            [pathstr,name,ext] = fileparts(DirImg(1).name); %YAN Chao-Gan, 151129. Check if it's .nii.gz
            if strcmpi(ext,'.gz')
                gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1},filesep,DirImg(1).name]);
                delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1},filesep,DirImg(1).name]);
                DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1},filesep,'Template_6.*']);
            end
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.template={[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1},filesep,DirImg(1).name]};
            
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subj(1,1).images=FileList;
            
            DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'u_*']);
            [pathstr,name,ext] = fileparts(DirImg(1).name); %YAN Chao-Gan, 151129. Check if it's .nii.gz
            if strcmpi(ext,'.gz')
                gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]);
                delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]);
                DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'u_*']);
            end
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subj(1,1).flowfield={[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]};

            spm_jobman('run',SPMJOB.matlabbatch);
        end
        
        
        if (AutoDataProcessParameter.IsNormalize==4) %Normalization by using the T1 image templates: Normalize T1 image to T1 template, and then apply to functional images. For Rat SpecialMode 3.
            
            SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Normalize.mat']);
            
            DirT1ImgCoreg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.img']);
            if isempty(DirT1ImgCoreg)  %YAN Chao-Gan, 111114. Also support .nii files.
                DirT1ImgCoreg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii.gz']);
                if length(DirT1ImgCoreg)==1
                    gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]);
                    delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]);
                end
                DirT1ImgCoreg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii']);
            end
            Source = [AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1ImgCoreg(1).name];
            
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.subj(1,1).source={Source};
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.subj(1,1).resample=[FileList;{Source}];
            
            %SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.eoptions.template={[SPMFilePath,filesep,'templates',filesep,'T1.nii,1']};
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.eoptions.template={[SPMFilePath,filesep,'toolbox',filesep,'OldNorm',filesep,'T1.nii,1']}; %YAN Chao-Gan, 161006.
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.roptions.bb=AutoDataProcessParameter.Normalize.BoundingBox;
            SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.roptions.vox=AutoDataProcessParameter.Normalize.VoxSize;
            
            %YAN Chao-Gan, 140815.
            if isfield(AutoDataProcessParameter,'SpecialMode') && (AutoDataProcessParameter.SpecialMode == 2)  %Special Mode: Monkey
                SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.eoptions.template={[TemplatePath,filesep,'WisconsinRhesusMacaqueAtlases',filesep,'112RM-SL_T1.nii,1']};
            end
            
            %YAN Chao-Gan, 150515.
            if isfield(AutoDataProcessParameter,'SpecialMode') && (AutoDataProcessParameter.SpecialMode == 3)  %Special Mode: Rat
                SPMJOB.matlabbatch{1,1}.spm.spatial.normalise.estwrite.eoptions.template={[TemplatePath,filesep,'SchwarzRatTemplates',filesep,'ratT1Template_YCG.nii,1']};
            end
             
            if SPMversion==12    % YAN Chao-Gan, 150703. In SPM 12, Segment (in SPM8) has turned to Old Segment.
                oldnorm = SPMJOB.matlabbatch{1,1}.spm.spatial.normalise;
                if (~isfield(AutoDataProcessParameter,'SpecialMode')) || (isfield(AutoDataProcessParameter,'SpecialMode') && (AutoDataProcessParameter.SpecialMode == 1))
                    oldnorm.estwrite.eoptions.template={[SPMFilePath,filesep,'toolbox',filesep,'OldNorm',filesep,'T1.nii,1']};
                end
                SPMJOB=[];
                SPMJOB.matlabbatch{1,1}.spm.tools.oldnorm = oldnorm;
            end
            
            spm_jobman('run',SPMJOB.matlabbatch);
        end

    end
    

    %Copy the Normalized results to ResultsW
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        parfor iMeasure=1:length(MeasureSet)
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'W',filesep,MeasureSet{iMeasure}])
            movefile([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,MeasureSet{iMeasure},filesep,'w*'],[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'W',filesep,MeasureSet{iMeasure}])
            fprintf(['Moving Normalized Files:',MeasureSet{iMeasure},' OK']);
        end
        fprintf('\n');
    end
    AutoDataProcessParameter.StartingDirName=[AutoDataProcessParameter.StartingDirName,'W']; %Now StartingDirName is with new suffix 'W'
    

    if AutoDataProcessParameter.IsAllowGUI %YAN Chao-Gan, 161011. Generate the pictures only if GUI is allowed.
        %Generate the pictures for checking normalization %YAN Chao-Gan, 091001
        %Revised to use y_Call_spm_orthviews on 140331.
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'PicturesForChkNormalization']);
        cd([AutoDataProcessParameter.DataProcessDir,filesep,'PicturesForChkNormalization']);
        
        Ch2Filename=fullfile(TemplatePath,'ch2.nii');
        %YAN Chao-Gan, 140815.
        if isfield(AutoDataProcessParameter,'SpecialMode') && (AutoDataProcessParameter.SpecialMode == 2)  %Special Mode: Monkey
            Ch2Filename=[TemplatePath,filesep,'WisconsinRhesusMacaqueAtlases',filesep,'112RM-SL_T1.nii'];
        end
        %YAN Chao-Gan, 150515.
        if isfield(AutoDataProcessParameter,'SpecialMode') && (AutoDataProcessParameter.SpecialMode == 3)  %Special Mode: Rat
            Ch2Filename=[TemplatePath,filesep,'SchwarzRatTemplates',filesep,'rat97t2w_96x96x30.v6.nii'];
        end
        
        for i=1:AutoDataProcessParameter.SubjectNum
            
            % Set the normalized mean functional image instead of the first normalized volume to get pictures % YAN Chao-Gan, 120826
            DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'wmean*.img']);
            if isempty(DirMean)  %YAN Chao-Gan, 111114. Also support .nii files.
                DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'wmean*.nii.gz']);% Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirMean)==1
                    gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name]);
                    delete([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name]);
                end
                DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'wmean*.nii']);
            end
            Filename = [AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name];
            
            global st; clear st; %YAN Chao-Gan, 180611. In some cases generating pictures calling y_spm_orthviews may leave something need to be cleared.

            H = figure;
            H = y_Call_spm_orthviews(Ch2Filename,0,0,0,18,Filename,jet(64),0,250,H,0.8);
            %H = y_Call_spm_orthviews(BrainVolume,NMin,PMin,ClusterSize,ConnectivityCriterion,UnderlayFileName,ColorMap,NMax,PMax,H,Transparency,Position,BrainHeader);
            
            eval(['print(''-dtiff'',''-r100'',''',AutoDataProcessParameter.SubjectID{i},'.tif'',H);']);
            fprintf(['Generating the pictures for checking normalization: ',AutoDataProcessParameter.SubjectID{i},' OK. ']);
            
            close(H)
            
        end
        fprintf('\n');
    end
    
end
if ~isempty(Error)
    disp(Error);
    return;
end



%Smooth on Results
if (AutoDataProcessParameter.IsSmooth>=1) && strcmpi(AutoDataProcessParameter.Smooth.Timing,'OnResults')

    %Check the measures need to be normalized
    DirMeasure = dir([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName]);
    if strcmpi(DirMeasure(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
        StartIndex=4;
    else
        StartIndex=3;
    end
    MeasureSet=[];
    for iDir=StartIndex:length(DirMeasure)
        if DirMeasure(iDir).isdir
            if ~((length(DirMeasure(iDir).name)>=10 && strcmpi(DirMeasure(iDir).name(1:10),'ROISignals'))) %~((length(DirMeasure(iDir).name)>10 && strcmpi(DirMeasure(iDir).name(end-10:end),'_ROISignals')))
                MeasureSet = [MeasureSet;{DirMeasure(iDir).name}];
            end
        end
        
    end
    
    fprintf(['Smoothing the resutls...\n']);

    
    if (AutoDataProcessParameter.IsSmooth==1)
        parfor i=1:AutoDataProcessParameter.SubjectNum

            FileList=[];
            for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                for iMeasure=1:length(MeasureSet)
                    cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,MeasureSet{iMeasure}]);
                    DirImg=dir(['*',AutoDataProcessParameter.SubjectID{i},'*.img']);
                    for j=1:length(DirImg)
                        FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,MeasureSet{iMeasure},filesep,DirImg(j).name]}];
                    end
                    
                    DirImg=dir(['*',AutoDataProcessParameter.SubjectID{i},'*.nii']);
                    for j=1:length(DirImg)
                        FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,MeasureSet{iMeasure},filesep,DirImg(j).name]}];
                    end
                end
                
            end

            SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Smooth.mat']);
            SPMJOB.matlabbatch{1,1}.spm.spatial.smooth.data = FileList;
            SPMJOB.matlabbatch{1,1}.spm.spatial.smooth.fwhm = AutoDataProcessParameter.Smooth.FWHM;
            spm_jobman('run',SPMJOB.matlabbatch);

        end
        
    elseif (AutoDataProcessParameter.IsSmooth==2)   %YAN Chao-Gan, 111111. Smooth by DARTEL. The smoothing that is a part of the normalization to MNI space computes these average intensities from the original data, rather than the warped versions. When the data are warped, some voxels will grow and others will shrink. This will change the regional averages, with more weighting towards those voxels that have grows.

        parfor i=1:AutoDataProcessParameter.SubjectNum

            SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Dartel_NormaliseToMNI_FewSubjects.mat']);
            
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.fwhm=AutoDataProcessParameter.Smooth.FWHM;
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.preserve=0;
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.bb=AutoDataProcessParameter.Normalize.BoundingBox;
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.vox=AutoDataProcessParameter.Normalize.VoxSize;
            
            DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1},filesep,'Template_6.*']);
            [pathstr,name,ext] = fileparts(DirImg(1).name); %YAN Chao-Gan, 151129. Check if it's .nii.gz
            if strcmpi(ext,'.gz')
                gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1},filesep,DirImg(1).name]);
                delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1},filesep,DirImg(1).name]);
                DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1},filesep,'Template_6.*']);
            end
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.template={[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1},filesep,DirImg(1).name]};
            
            FileList=[];
            for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                for iMeasure=1:length(MeasureSet)
                    cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName(1:end-1),filesep,MeasureSet{iMeasure}]);
                    DirImg=dir(['*',AutoDataProcessParameter.SubjectID{i},'*.img']);
                    for j=1:length(DirImg)
                        FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName(1:end-1),filesep,MeasureSet{iMeasure},filesep,DirImg(j).name]}];
                    end
                    
                    DirImg=dir(['*',AutoDataProcessParameter.SubjectID{i},'*.nii']);
                    for j=1:length(DirImg)
                        FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName(1:end-1),filesep,MeasureSet{iMeasure},filesep,DirImg(j).name]}];
                    end
                end
                
            end
            
            
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subj(1,1).images=FileList;
            
            DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'u_*']);
            [pathstr,name,ext] = fileparts(DirImg(1).name); %YAN Chao-Gan, 151129. Check if it's .nii.gz
            if strcmpi(ext,'.gz')
                gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]);
                delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]);
                DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'u_*']);
            end
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subj(1,1).flowfield={[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]};
            
            spm_jobman('run',SPMJOB.matlabbatch);
            fprintf(['Smooth by using DARTEL:',AutoDataProcessParameter.SubjectID{i},' OK\n']);
        end

    end

    
    %Copy the Smoothed files to ResultsWS or ResultsS
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        parfor iMeasure=1:length(MeasureSet)
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'S',filesep,MeasureSet{iMeasure}])
            if (AutoDataProcessParameter.IsSmooth==1)
                movefile([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,MeasureSet{iMeasure},filesep,'s*'],[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'S',filesep,MeasureSet{iMeasure}])
            elseif (AutoDataProcessParameter.IsSmooth==2) % If smoothed by DARTEL, then the smoothed files still under realign directory.
                movefile([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName(1:end-1),filesep,MeasureSet{iMeasure},filesep,'s*'],[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'S',filesep,MeasureSet{iMeasure}])
            end
            fprintf(['Moving Smoothed Files:',MeasureSet{iMeasure},' OK']);
        end
        fprintf('\n');
    end
    
    AutoDataProcessParameter.StartingDirName=[AutoDataProcessParameter.StartingDirName,'S']; %Now StartingDirName is with new suffix 'S'
    
end
if ~isempty(Error)
    disp(Error);
    return;
end

fprintf(['\nCongratulations, the running of DPARSFA is done!!! :)\n\n']);

