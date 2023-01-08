function [Error, Cfg]=DPABIFiber_run(Cfg,WorkingDir,SubjectListFile)
% FORMAT [Error]=DPABISurf_run(Cfg,WorkingDir,SubjectListFile)
%   Cfg - the parameters for auto data processing. 
%   WorkingDir - Define the working directory to replace the one defined in Cfg
%   SubjectListFile - Define the subject list to replace the one defined in Cfg. Should be a text file
% Output:
%   The brain white matter fiber profiles data that you want.
%___________________________________________________________________________
% Written by YAN Chao-Gan 221122.
% The R-fMRI Lab, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% International Big-Data Center for Depression Research, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com



if ischar(Cfg)  %If inputed a .mat file name. (Cfg inside)
    load(Cfg);
end

if exist('WorkingDir','var') && ~isempty(WorkingDir)
    Cfg.WorkingDir=WorkingDir;
end

if exist('SubjectListFile','var') && ~isempty(SubjectListFile)
    fid = fopen(SubjectListFile);
    IDCell = textscan(fid,'%s\n'); %YAN Chao-Gan. For compatiblity of MALLAB 2014b. IDCell = textscan(fid,'%s','\n');
    fclose(fid);
    Cfg.SubjectID=IDCell{1};
end


Cfg.SubjectNum=length(Cfg.SubjectID);
Error=[];

[DPABIPath, fileN, extn] = fileparts(which('DPABI.m'));


%Make compatible with missing parameters.
if ~isfield(Cfg,'ParallelWorkersNumber')
    Cfg.ParallelWorkersNumber=1; 
end
if ~isfield(Cfg,'Isqsiprep')
    Cfg.Isqsiprep=0; 
end
if ~isfield(Cfg,'OutputResolution')
    Cfg.OutputResolution=2; 
end
if ~isfield(Cfg,'IsLowMem')
    Cfg.IsLowMem=0; 
end
if ~isfield(Cfg,'IsCalTensorMetrics')
    Cfg.IsCalTensorMetrics=0; 
end
if ~isfield(Cfg,'IsTBSS')
    Cfg.IsTBSS=0; 
end
if ~isfield(Cfg,'Isqsirecon')
    Cfg.Isqsirecon=0; 
end
if ~isfield(Cfg,'FreesurferInput')
    Cfg.FreesurferInput=[Cfg.WorkingDir,filesep,'freesurfer']; 
end
if ~isfield(Cfg,'ROIDef')
    Cfg.ROIDef=[]; 
end
if ~isfield(Cfg,'ROISelectedIndex')
    Cfg.ROISelectedIndex=[]; 
end
if ~isfield(Cfg,'StructuralConnectomeMatrix')
    Cfg.StructuralConnectomeMatrix.Is=0; 
else
    if ~isfield(Cfg.StructuralConnectomeMatrix,'WeightedByFA')
        Cfg.StructuralConnectomeMatrix.WeightedByFA=0;
    end
    if ~isfield(Cfg.StructuralConnectomeMatrix,'WeightedByImage')
        Cfg.StructuralConnectomeMatrix.WeightedByImage.Is=0;
    end
end
if ~isfield(Cfg,'SeedBasedStructuralConnectivity')
    Cfg.SeedBasedStructuralConnectivity.Is=0; 
else
    if ~isfield(Cfg.SeedBasedStructuralConnectivity,'TWFC')
        Cfg.SeedBasedStructuralConnectivity.TWFC.Is=0;
    end
end
if ~isfield(Cfg,'Normalize')
    Cfg.Normalize.Is=0; 
end
if ~isfield(Cfg,'Smooth')
    Cfg.Smooth.Is=0; 
end



%Get ready for later usage.
if ispc
    CommandInit=sprintf('docker run -i --rm -v %s:/DPABI -v %s:/data ', DPABIPath, Cfg.WorkingDir); %YAN Chao-Gan, 181214. Remove -t because there is a tty issue in windows
else
    CommandInit=sprintf('docker run -ti --rm -v %s:/DPABI -v %s:/data ', DPABIPath, Cfg.WorkingDir); %YAN Chao-Gan, 181214. Remove -t because there is a tty issue in windows
end


if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
    CommandParallel=sprintf('parallel -j %g', Cfg.ParallelWorkersNumber);
    WorkingDir=Cfg.WorkingDir;
else
    CommandParallel=sprintf('%s cgyan/dpabifiber parallel -j %g', CommandInit, Cfg.ParallelWorkersNumber );
    WorkingDir='/data';
end

SubjectIDString=[];
for i=1:Cfg.SubjectNum
    SubjectIDString = sprintf('%s %s',SubjectIDString,Cfg.SubjectID{i});
end



%Preprocessing with qsiprep
if (Cfg.Isqsiprep==1)

    % Close parpool
    PCTVer = ver('distcomp');
    if ~isempty(PCTVer)
        FullMatlabVersion = sscanf(version,'%d.%d.%d.%d%s');
        if FullMatlabVersion(1)*1000+FullMatlabVersion(2)<8*1000+3    %YAN Chao-Gan, 151117. If it's lower than MATLAB 2014a.  %FullMatlabVersion(1)*1000+FullMatlabVersion(2)>=7*1000+8    %YAN Chao-Gan, 120903. If it's higher than MATLAB 2008.
            CurrentSize_MatlabPool = matlabpool('size');
            if (CurrentSize_MatlabPool~=0)
                matlabpool close
            end
        else
            if ~isempty(gcp('nocreate'))
                delete(gcp('nocreate'));
            end
        end
    end
    
    %!docker run -ti --rm -v /mnt/Data45/RfMRILab/yan/YAN_Work/DPABIUpdating/Program/DPABI_V6.1_220101/DPABISurf/FreeSurferLicense/license.txt:/opt/freesurfer/license.txt -v /mnt/Data45/RfMRILab/yan/YAN_Work/DPABIUpdating/DPABIFiber/Data/Test/BJDataTest/Try1:/data  cgyan/qsiprep /usr/local/miniconda/bin/qsiprep /data/BIDS /data participant --nthreads 1 --omp-nthreads 1 --fs-license-file /opt/freesurfer/license.txt --recon_spec /data/mrtrix_singleshell_ss3t_ACT-hsvs.json --freesurfer-input /data/freesurfer --output-resolution 2 -w /data/qsiprepwork/sub-Sub001  --participant_label sub-Sub001

    if ~exist([Cfg.WorkingDir,filesep,'qsiprep'],'dir') % If it's the first time to run qsiprep
        
        if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
            Command=sprintf('parallel -j %g /usr/local/miniconda/bin/qsiprep %s/BIDS %s participant --fs-license-file /DPABI/DPABISurf/FreeSurferLicense/license.txt --resource-monitor', Cfg.ParallelWorkersNumber, Cfg.WorkingDir, Cfg.WorkingDir);
        else
            Command=sprintf('%s cgyan/dpabifiber parallel -j %g /usr/local/miniconda/bin/qsiprep /data/BIDS /data participant --fs-license-file /DPABI/DPABISurf/FreeSurferLicense/license.txt --resource-monitor', CommandInit, Cfg.ParallelWorkersNumber );
        end
        
        if Cfg.ParallelWorkersNumber~=0
            Command = sprintf('%s --nthreads 1 --omp-nthreads 1', Command);
        end
        
        Command = sprintf('%s --output-resolution %g', Command, Cfg.OutputResolution);

        if Cfg.IsLowMem==1
            Command = sprintf('%s --low-mem', Command);
        end
        
        Command = sprintf('%s -w /data/qsiprepwork/{1}', Command); %Specify the working dir for qsiprep
        Command = sprintf('%s  --participant_label {1} ::: %s', Command, SubjectIDString);
        
        fprintf('Preprocessing with qsiprep, this process is very time consuming, please be patient...\n');
        
        system(Command);
   
    end
    
    %     %Check subjects failed qsiprep and re-run
    %     [FailedID WaitingID SuccessID]=y_ReRunqsiprepFailedSubjects(Cfg,Cfg.WorkingDir,Cfg.SubjectID);
    %
    %     if ~isempty(FailedID)
    %         fprintf(['\nError: These subjects have always failed run qsiprep, please check the raw data and the logs:\n']);
    %         disp(FailedID)
    %         error('Error detected during running qsiprep, please check the log files for the above subjects!');
    %     end
    %     if ~isempty(WaitingID)
    %         error('Error detected during running qsiprep, please check!');
    %     end
    
    
    if ~(isdeployed && (isunix && (~ismac))) % Give permission
        Command=sprintf('%s cgyan/dpabifiber chmod -R 777 /data/qsiprep/', CommandInit);
        system(Command);
    end

    Cfg.StartingDirName = 'qsiprep';
end




% Calculate DWI Tensor Metrics
if (Cfg.IsCalTensorMetrics==1)

    %dwi2tensor -grad /data/qsiprep/sub-Sub001/dwi/sub-Sub001_space-T1w_desc-preproc_dwi.b -mask /data/qsiprep/sub-Sub001/dwi/sub-Sub001_space-T1w_desc-brain_mask.nii.gz /data/qsiprep/sub-Sub001/dwi/sub-Sub001_space-T1w_desc-preproc_dwi.nii.gz /data/Tensor/Tensor/sub-Sub001_space-T1w_desc-preproc_dwitensor.nii.gz
    mkdir([Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'TensorMetrics',filesep,'Tensor']);
    if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
        Command=sprintf('parallel -j %g dwi2tensor -grad %s/qsiprep/{1}/dwi/{1}_space-T1w_desc-preproc_dwi.b -mask %s/qsiprep/{1}/dwi/{1}_space-T1w_desc-brain_mask.nii.gz %s/qsiprep/{1}/dwi/{1}_space-T1w_desc-preproc_dwi.nii.gz %s/Results/DwiVolu/TensorMetrics/Tensor/{1}_space-T1w_desc-preproc_dwitensor.nii.gz', Cfg.ParallelWorkersNumber, Cfg.WorkingDir, Cfg.WorkingDir,Cfg.WorkingDir,Cfg.WorkingDir);
    else
        Command=sprintf('%s cgyan/dpabifiber parallel -j %g dwi2tensor -grad /data/qsiprep/{1}/dwi/{1}_space-T1w_desc-preproc_dwi.b -mask /data/qsiprep/{1}/dwi/{1}_space-T1w_desc-brain_mask.nii.gz /data/qsiprep/{1}/dwi/{1}_space-T1w_desc-preproc_dwi.nii.gz /data/Results/DwiVolu/TensorMetrics/Tensor/{1}_space-T1w_desc-preproc_dwitensor.nii.gz', CommandInit, Cfg.ParallelWorkersNumber);
    end
    Command = sprintf('%s -force ::: %s', Command, SubjectIDString);
    system(Command);

    %tensor2metric -mask /data/qsiprep/sub-Sub001/dwi/sub-Sub001_space-T1w_desc-brain_mask.nii.gz -adc /data/Tensor/TensorMetrics/sub-Sub001_space-T1w_desc-preproc_dwitensor_adc.nii.gz -fa /data/Tensor/TensorMetrics/sub-Sub001_space-T1w_desc-preproc_dwitensor_fa.nii.gz -ad /data/Tensor/TensorMetrics/sub-Sub001_space-T1w_desc-preproc_dwitensor_ad.nii.gz -rd /data/Tensor/TensorMetrics/sub-Sub001_space-T1w_desc-preproc_dwitensor_rd.nii.gz /data/Tensor/Tensor/sub-Sub001_space-T1w_desc-preproc_dwitensor.nii.gz
    %tensor2metric -mask /data/qsiprep/sub-Sub001/dwi/sub-Sub001_space-T1w_desc-brain_mask.nii.gz -adc /data/Results/DwiVolu/TensorMetrics/ADC/sub-Sub001_space-T1w_desc-preproc_dwitensor_metrics.nii.gz -fa /data/Results/DwiVolu/TensorMetrics/FA/sub-Sub001_space-T1w_desc-preproc_dwitensor_metrics.nii.gz -ad /data/Results/DwiVolu/TensorMetrics/AD/sub-Sub001_space-T1w_desc-preproc_dwitensor_metrics.nii.gz -rd /data/Results/DwiVolu/TensorMetrics/RD/sub-Sub001_space-T1w_desc-preproc_dwitensor_metrics.nii.gz /data/Results/DwiVolu/TensorMetrics/Tensor/{1}_space-T1w_desc-preproc_dwitensor.nii.gz
    mkdir([Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'TensorMetrics',filesep,'ADC']);
    mkdir([Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'TensorMetrics',filesep,'FA']);
    mkdir([Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'TensorMetrics',filesep,'AD']);
    mkdir([Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'TensorMetrics',filesep,'RD']);
    if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
        Command=sprintf('parallel -j %g tensor2metric -mask %s/qsiprep/{1}/dwi/{1}_space-T1w_desc-brain_mask.nii.gz -adc %s/Results/DwiVolu/TensorMetrics/ADC/{1}_space-T1w_desc-preproc_dwitensor_metrics.nii.gz -fa %s/Results/DwiVolu/TensorMetrics/FA/{1}_space-T1w_desc-preproc_dwitensor_metrics.nii.gz -ad %s/Results/DwiVolu/TensorMetrics/AD/{1}_space-T1w_desc-preproc_dwitensor_metrics.nii.gz -rd %s/Results/DwiVolu/TensorMetrics/RD/{1}_space-T1w_desc-preproc_dwitensor_metrics.nii.gz %s/Results/DwiVolu/TensorMetrics/Tensor/{1}_space-T1w_desc-preproc_dwitensor.nii.gz', Cfg.ParallelWorkersNumber, Cfg.WorkingDir, Cfg.WorkingDir,Cfg.WorkingDir,Cfg.WorkingDir,Cfg.WorkingDir,Cfg.WorkingDir);
    else
        Command=sprintf('%s cgyan/dpabifiber parallel -j %g tensor2metric -mask /data/qsiprep/{1}/dwi/{1}_space-T1w_desc-brain_mask.nii.gz -adc /data/Results/DwiVolu/TensorMetrics/ADC/{1}_space-T1w_desc-preproc_dwitensor_metrics.nii.gz -fa /data/Results/DwiVolu/TensorMetrics/FA/{1}_space-T1w_desc-preproc_dwitensor_metrics.nii.gz -ad /data/Results/DwiVolu/TensorMetrics/AD/{1}_space-T1w_desc-preproc_dwitensor_metrics.nii.gz -rd /data/Results/DwiVolu/TensorMetrics/RD/{1}_space-T1w_desc-preproc_dwitensor_metrics.nii.gz /data/Results/DwiVolu/TensorMetrics/Tensor/{1}_space-T1w_desc-preproc_dwitensor.nii.gz', CommandInit, Cfg.ParallelWorkersNumber);
    end
    Command = sprintf('%s -force ::: %s', Command, SubjectIDString);
    system(Command);
end



if (Cfg.IsTBSS==1)
    mkdir([Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'TBSS',filesep,'Working']);
    if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
        Command=sprintf('chmod +x /DPABI/DPABIFiber/y_TBSS.sh && source /DPABI/DPABIFiber/y_TBSS.sh %s', Cfg.WorkingDir);
        system(Command);
    else
        Command=sprintf('%s cgyan/dpabifiber bash -c "source /DPABI/DPABIFiber/y_TBSS.sh /data"', CommandInit);
        system(Command);
        Command=sprintf('%s cgyan/dpabifiber chmod -R 777 /data/Results/DwiVolu/TBSS/Working/stats/', CommandInit);
        system(Command);
    end
    
    mkdir([Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'TBSS',filesep,'Skeletonised',filesep,'FA']);
    [Data Header]=y_Read([Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'TBSS',filesep,'Working',filesep,'stats',filesep,'all_FA_skeletonised.nii.gz']);
    for i=1:size(Data,4)
        y_Write(Data(:,:,:,i),Header,[Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'TBSS',filesep,'Skeletonised',filesep,'FA',filesep,Cfg.SubjectID{i},'_FA_skeletonised.nii']);
    end
    
    mkdir([Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'TBSS',filesep,'Skeletonised',filesep,'AD']);
    [Data Header]=y_Read([Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'TBSS',filesep,'Working',filesep,'stats',filesep,'all_AD_skeletonised.nii.gz']);
    for i=1:size(Data,4)
        y_Write(Data(:,:,:,i),Header,[Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'TBSS',filesep,'Skeletonised',filesep,'AD',filesep,Cfg.SubjectID{i},'_AD_skeletonised.nii']);
    end
        
    mkdir([Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'TBSS',filesep,'Skeletonised',filesep,'ADC']);
    [Data Header]=y_Read([Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'TBSS',filesep,'Working',filesep,'stats',filesep,'all_ADC_skeletonised.nii.gz']);
    for i=1:size(Data,4)
        y_Write(Data(:,:,:,i),Header,[Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'TBSS',filesep,'Skeletonised',filesep,'ADC',filesep,Cfg.SubjectID{i},'_ADC_skeletonised.nii']);
    end
        
    mkdir([Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'TBSS',filesep,'Skeletonised',filesep,'RD']);
    [Data Header]=y_Read([Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'TBSS',filesep,'Working',filesep,'stats',filesep,'all_RD_skeletonised.nii.gz']);
    for i=1:size(Data,4)
        y_Write(Data(:,:,:,i),Header,[Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'TBSS',filesep,'Skeletonised',filesep,'RD',filesep,Cfg.SubjectID{i},'_RD_skeletonised.nii']);
    end
end



%Reconstructing with qsiprep
if (Cfg.Isqsirecon==1)

    % Close parpool
    PCTVer = ver('distcomp');
    if ~isempty(PCTVer)
        FullMatlabVersion = sscanf(version,'%d.%d.%d.%d%s');
        if FullMatlabVersion(1)*1000+FullMatlabVersion(2)<8*1000+3    %YAN Chao-Gan, 151117. If it's lower than MATLAB 2014a.  %FullMatlabVersion(1)*1000+FullMatlabVersion(2)>=7*1000+8    %YAN Chao-Gan, 120903. If it's higher than MATLAB 2008.
            CurrentSize_MatlabPool = matlabpool('size');
            if (CurrentSize_MatlabPool~=0)
                matlabpool close
            end
        else
            if ~isempty(gcp('nocreate'))
                delete(gcp('nocreate'));
            end
        end
    end

    if ~exist([Cfg.WorkingDir,filesep,'qsirecon'],'dir') % If it's the first time to run qsirecon
        
        if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
            Command=sprintf('parallel -j %g /usr/local/miniconda/bin/qsiprep %s/BIDS %s participant --fs-license-file /DPABI/DPABISurf/FreeSurferLicense/license.txt --resource-monitor', Cfg.ParallelWorkersNumber, Cfg.WorkingDir, Cfg.WorkingDir);
        else
            if isempty(Cfg.FreesurferInput)
                Command=sprintf('%s cgyan/dpabifiber parallel -j %g /usr/local/miniconda/bin/qsiprep /data/BIDS /data participant --fs-license-file /DPABI/DPABISurf/FreeSurferLicense/license.txt --resource-monitor', CommandInit, Cfg.ParallelWorkersNumber );
            else
                Command=sprintf('%s -v %s:/FreesurferInput cgyan/dpabifiber parallel -j %g /usr/local/miniconda/bin/qsiprep /data/BIDS /data participant --fs-license-file /DPABI/DPABISurf/FreeSurferLicense/license.txt --resource-monitor', CommandInit, Cfg.FreesurferInput, Cfg.ParallelWorkersNumber );
            end
        end
        
        if Cfg.ParallelWorkersNumber~=0
            Command = sprintf('%s --nthreads 1 --omp-nthreads 1', Command);
        end
        
        %Command = sprintf('%s --output-resolution %g', Command, Cfg.OutputResolution);

        if ~isempty(Cfg.FreesurferInput)
            if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
                Command=sprintf('%s --freesurfer-input %s', Command, Cfg.FreesurferInput);
            else
                Command=sprintf('%s --freesurfer-input /FreesurferInput', Command);
            end
        end

        if ~isempty(Cfg.ReconSpec) || ~strcmpi(Cfg.ReconSpec,'none')
            copyfile([DPABIPath,filesep,'DPABIFiber',filesep,'qsiprep_recon_workflows',filesep,Cfg.ReconSpec,'.json'],Cfg.WorkingDir);
            if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
                Command=sprintf('%s --recon_spec %s/%s.json', Command, Cfg.WorkingDir, Cfg.ReconSpec);
            else
                Command=sprintf('%s --recon_spec /data/%s.json', Command, Cfg.ReconSpec);
            end
        end

        if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
            Command=sprintf('%s --recon-input %s/qsiprep', Command, Cfg.WorkingDir);
        else
            Command=sprintf('%s --recon-input /data/qsiprep', Command);
        end

        Command = sprintf('%s --recon-only', Command); 

        if Cfg.IsLowMem==1
            Command = sprintf('%s --low-mem', Command);
        end
        
        Command = sprintf('%s -w /data/qsireconwork/{1}', Command); %Specify the working dir for qsiprep
        Command = sprintf('%s  --participant_label {1} ::: %s', Command, SubjectIDString);
        
        fprintf('Reconstructing with qsiprep, this process is very time consuming, please be patient...\n');
        
        system(Command);
    end
    
    %Check subjects failed qsirecon and re-run 
    [FailedID WaitingID SuccessID]=y_ReRunqsireconFailedSubjects(Cfg,Cfg.WorkingDir,Cfg.SubjectID);

    if ~isempty(FailedID)
        fprintf(['\nError: These subjects have always failed run qsirecon, please check the data and the logs:\n']);
        disp(FailedID)
        error('Error detected during running qsirecon, please check the log files for the above subjects!');
    end
    if ~isempty(WaitingID)
        error('Error detected during running qsirecon, please check!');
    end
    
    
    if ~(isdeployed && (isunix && (~ismac))) % Give permission
        Command=sprintf('%s cgyan/dpabifiber chmod -R 777 /data/qsirecon/', CommandInit);
        system(Command);
    end
    
    Cfg.StartingDirName = 'qsirecon';
    
end



% Process ROI Masks
if ~isempty(Cfg.ROIDef)

    if ~(7==exist([Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForDwi',filesep, 'Masks_DwiSpace'],'dir'))
        mkdir([Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForDwi',filesep, 'Masks_DwiSpace']);
    end

    % Ball to mask
    AllSubjectROI=Cfg.ROIDef;
    for iROI=1:length(AllSubjectROI)
        if ~(7==exist([Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForDwi',filesep, 'Masks_MNISpace'],'dir'))
            mkdir([Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForDwi',filesep, 'Masks_MNISpace']);
        end
        if strcmpi(int2str(size(AllSubjectROI{iROI})),int2str([1, 4]))  %Sphere ROI definition: CenterX, CenterY, CenterZ, Radius
            ROIMaskName=[Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForDwi',filesep, 'Masks_MNISpace',filesep,'SphereMask_',num2str(iROI),'_Center_',num2str(AllSubjectROI{iROI}(1)),'_',num2str(AllSubjectROI{iROI}(2)),'_',num2str(AllSubjectROI{iROI}(3)),'_',num2str(AllSubjectROI{iROI}(4)),'.nii'];
            y_Sphere(AllSubjectROI{iROI}(1:3), AllSubjectROI{iROI}(4), [DPABIPath,filesep,'Templates',filesep,'aal.nii'], ROIMaskName);
            AllSubjectROI{iROI}=[ROIMaskName];
        end
    end

    % Check if masks appropriate 
    for i=1:Cfg.SubjectNum
        Suffix=''; %%!!! Change as in Function
        SubjectROI=AllSubjectROI;
        if 1% Cfg.IsWarpMasksIntoIndividualSpace==1
            %Need to warp masks

            RefFile=[Cfg.WorkingDir,filesep,'qsiprep',filesep,Cfg.SubjectID{i},filesep,'dwi',filesep,Cfg.SubjectID{i},'_space-T1w_dwiref.nii.gz'];
            [RefData,RefVox,RefHeader]=y_ReadRPI(RefFile,1);
            TransformFile=[Cfg.WorkingDir,filesep,'qsiprep',filesep,Cfg.SubjectID{i},filesep,'anat',filesep,Cfg.SubjectID{i},'_from-MNI152NLin2009cAsym_to-T1w_mode-image_xfm.h5'];
            Interpolation='MultiLabel';
            Dimensionality=3;
            InputImageType=0;
            DefaultValue=0;
            IsFloat0=0;
            DockerName='cgyan/dpabifiber';

            for iROI=1:length(SubjectROI)
                if exist(SubjectROI{iROI},'file')==2 % MNI Mask files need to be warped
                    SourceFile=SubjectROI{iROI};
                    MaskName=[Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForDwi',filesep, 'Masks_DwiSpace',filesep,Suffix,'MaskFile_',num2str(iROI),'_',Cfg.SubjectID{i},'.nii'];
                    fprintf('\nWarp %s Mask (%s) for "%s".\n',Suffix,SourceFile, Cfg.SubjectID{i});
                    y_WarpByANTs(SourceFile,MaskName,RefFile,TransformFile,Interpolation,Dimensionality,InputImageType,DefaultValue,IsFloat0,DockerName)
                    %y_WarpByANTs(SourceFile,OutFile,RefFile,TransformFile,Interpolation,Dimensionality,InputImageType,DefaultValue,IsFloat0,DockerName)
                    SubjectROI{iROI}=MaskName;

                elseif (ischar(SubjectROI{iROI})) && ~isempty(strfind(SubjectROI{iROI},'{SubjectID}')) % Process the individual ROI from an expression
                    NewStrDef = replace(SubjectROI{iROI},'{SubjectID}',Cfg.SubjectID{i});
                    NewStrDef = replace(NewStrDef,'{WorkingDir}',Cfg.WorkingDir);
                    if exist(NewStrDef,'file')==2
                        [MaskData,MaskVox,MaskHeader]=y_ReadRPI(NewStrDef);
                        if ~isequal(size(MaskData), size(RefData))
                            fprintf('\nReslice %s Mask (%s) for "%s" since the dimension of mask mismatched the dimension of the target data.\n',Suffix,NewStrDef, Cfg.SubjectID{i});
                            ReslicedMaskName=[Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForDwi',filesep, 'Masks_DwiSpace',filesep,Suffix,'MaskFile_',num2str(iROI),'_',Cfg.SubjectID{i},'.nii'];
                            y_Reslice(NewStrDef,ReslicedMaskName,[],0, RefFile);
                            SubjectROI{iROI}=ReslicedMaskName;
                        else
                            SubjectROI{iROI}=NewStrDef;
                        end
                    else
                        error(['The Mask File ',NewStrDef,' does not exist!'])
                    end
                else
                    error(['This Mask definition can not be processed: ',SubjectROI{iROI}])
                end
            end

        end

        %Merge the needed index
        fprintf('\nMerging maks...\n');
        if ~(7==exist([Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForDwi',filesep, 'Masks_DwiSpace_Merged'],'dir'))
            mkdir([Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForDwi',filesep, 'Masks_DwiSpace_Merged']);
        end
        [RefData,RefVox,RefHeader]=y_ReadRPI(RefFile,1);

        MergedMaskData=zeros(size(RefData));

        iOrder = 1;
        fid = fopen([Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForDwi',filesep,'Masks_DwiSpace_Merged',filesep,'ROI_OrderKey_',Cfg.SubjectID{i},'.tsv'],'w');
        fprintf(fid,'NewIndex\tRawIndex\tRawDefinition\tDwiSpaceMask\n');
        for iROI=1:length(SubjectROI)
            iMaskData=y_ReadRPI(SubjectROI{iROI});
            if isfield(Cfg,'ROISelectedIndex') && ~isempty(Cfg.ROISelectedIndex) && ~isempty(Cfg.ROISelectedIndex{iROI})
                Element=Cfg.ROISelectedIndex{iROI};
            else
                Element = unique(iMaskData);
                Element(find(isnan(Element))) = []; % ignore background if encoded as nan.
                Element(find(Element==0)) = []; % This is the background 0
            end
            for iElement=1:length(Element)
                MergedMaskData(find(iMaskData==Element(iElement)))=iOrder;
                fprintf(fid,'%g\t%g\t%s\t%s\n',iOrder,Element(iElement),AllSubjectROI{iROI},SubjectROI{iROI});
                iOrder = iOrder + 1;
            end
        end
        fclose(fid);
        RefHeader.pinfo = [1;0;0]; RefHeader.dt =[16,0];
        y_Write(MergedMaskData,RefHeader,[Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForDwi',filesep,'Masks_DwiSpace_Merged',filesep,'MergedMask_',Cfg.SubjectID{i},'.nii']);
    end


    %Split the processed masks for Seed Based Structural Connectivity
    if Cfg.SeedBasedStructuralConnectivity.Is
        fprintf('\nSpliting maks...\n');
        if ~(7==exist([Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForDwi',filesep, 'Masks_DwiSpace_Split'],'dir'))
            mkdir([Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForDwi',filesep, 'Masks_DwiSpace_Split']);
        end
        for i=1:Cfg.SubjectNum
            [MergedMaskData,Vox,Header]=y_ReadRPI([Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForDwi',filesep,'Masks_DwiSpace_Merged',filesep,'MergedMask_',Cfg.SubjectID{i},'.nii']);
            MaxElement = max(MergedMaskData(:)); %MaxElement will be used in Calculating Seed Based Structural Connectivity
            for iElement=1:MaxElement
                SplitMaskData = MergedMaskData==iElement;
                y_Write(SplitMaskData,Header,[Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForDwi',filesep,'Masks_DwiSpace_Split',filesep,'SplitMask_ROI_',num2str(iElement),'_',Cfg.SubjectID{i},'.nii']);
            end
        end
    end
end



%Get structural connectome matrix
if (Cfg.StructuralConnectomeMatrix.Is==1)
    % Close parpool
    PCTVer = ver('distcomp');
    if ~isempty(PCTVer)
        FullMatlabVersion = sscanf(version,'%d.%d.%d.%d%s');
        if FullMatlabVersion(1)*1000+FullMatlabVersion(2)<8*1000+3    %YAN Chao-Gan, 151117. If it's lower than MATLAB 2014a.  %FullMatlabVersion(1)*1000+FullMatlabVersion(2)>=7*1000+8    %YAN Chao-Gan, 120903. If it's higher than MATLAB 2008.
            CurrentSize_MatlabPool = matlabpool('size');
            if (CurrentSize_MatlabPool~=0)
                matlabpool close
            end
        else
            if ~isempty(gcp('nocreate'))
                delete(gcp('nocreate'));
            end
        end
    end


    mkdir([Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'StructuralConnectomeMatrix']);
    copyfile([Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForDwi',filesep,'Masks_DwiSpace_Merged',filesep,'ROI_OrderKey_',Cfg.SubjectID{i},'.tsv'],[Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'StructuralConnectomeMatrix']);


    if Cfg.StructuralConnectomeMatrix.WeightedByFA
        %Mean FA per Streamline
        Command = sprintf('%s tcksample %s/qsirecon/{1}/dwi/{1}_space-T1w_desc-preproc_desc-tracks_ifod2.tck %s/Results/DwiVolu/TensorMetrics/FA/{1}_space-T1w_desc-preproc_dwitensor_metrics.nii.gz %s/Results/DwiVolu/StructuralConnectomeMatrix/MeanFAPerStreamline_{1}.csv -stat_tck mean -quiet', CommandParallel,WorkingDir,WorkingDir,WorkingDir);
        %tcksample tracks.tck FA.mif mean_FA_per_streamline.csv -stat_tck mean
        if Cfg.ParallelWorkersNumber~=0
            Command = sprintf('%s -nthreads 1', Command);
        end
        Command = sprintf('%s -force ::: %s', Command, SubjectIDString);
        fprintf('Mean FA per Streamline Calculating, please wait...\n');
        system(Command);

    elseif Cfg.StructuralConnectomeMatrix.WeightedByImage.Is

        ImageFile = Cfg.StructuralConnectomeMatrix.WeightedByImage.ImageFile;
        ImageFile = replace(ImageFile,'/',filesep);
        ImageFile = replace(ImageFile,'{WorkingDir}',Cfg.WorkingDir);
        

        k_SubjectID = strfind(ImageFile,'{SubjectID}');
        k_Filesep = strfind(ImageFile,filesep);
        if ~isempty(k_SubjectID)
            FirstFilesep = k_Filesep(max(find(k_Filesep<k_SubjectID(1))));
        else
            FirstFilesep=k_Filesep(end);
        end

        MountPath=ImageFile(1:FirstFilesep-1);
        WithinFile=ImageFile(FirstFilesep+1:end);

        WithinFile = replace(WithinFile,'{SubjectID}','{1}');
        WithinFile = replace(WithinFile,filesep,'/');

        ImageFile = replace(ImageFile,'{SubjectID}','{1}');


        if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
            Command=sprintf('parallel -j %g tcksample %s/qsirecon/{1}/dwi/{1}_space-T1w_desc-preproc_desc-tracks_ifod2.tck %s %s/Results/DwiVolu/StructuralConnectomeMatrix/WeightedImagePerStreamline_{1}.csv -stat_tck %s -quiet', ...
                Cfg.ParallelWorkersNumber, WorkingDir,ImageFile,WorkingDir,Cfg.StructuralConnectomeMatrix.WeightedByImage.StatTck);
        else
            Command=sprintf('%s -v %s:/MountPath cgyan/dpabifiber parallel -j %g tcksample %s/qsirecon/{1}/dwi/{1}_space-T1w_desc-preproc_desc-tracks_ifod2.tck /MountPath/%s %s/Results/DwiVolu/StructuralConnectomeMatrix/WeightedImagePerStreamline_{1}.csv -stat_tck %s -quiet', ...
                CommandInit, MountPath, Cfg.ParallelWorkersNumber, WorkingDir,WithinFile,WorkingDir,Cfg.StructuralConnectomeMatrix.WeightedByImage.StatTck);
        end
        if Cfg.ParallelWorkersNumber~=0
            Command = sprintf('%s -nthreads 1', Command);
        end
        Command = sprintf('%s -force ::: %s', Command, SubjectIDString);
        fprintf('Weighted Image per Streamline Calculating, please wait...\n');
        system(Command);
    end
    

    %tck2connectome -tck_weights_in /data/Dev/conn/conntest/sub-ASDSHIKEYU20191215_space-T1w_desc-preproc_desc-siftweights_ifod2.csv -nthreads 1 -out_assignments /data/Dev/conn/conntest/assignmentsnii.txt -quiet -assignment_radial_search 2.000000 -stat_edge sum -symmetric /data/Dev/conn/conntest/sub-ASDSHIKEYU20191215_space-T1w_desc-preproc_desc-tracks_ifod2.tck /data/Dev/conn/conntest/My400.nii /data/Dev/conn/conntest/My400nii_Connectome.csv

    Command = sprintf('%s tck2connectome %s/qsirecon/{1}/dwi/{1}_space-T1w_desc-preproc_desc-tracks_ifod2.tck %s/Masks/MasksForDwi/Masks_DwiSpace_Merged/MergedMask_{1}.nii %s/Results/DwiVolu/StructuralConnectomeMatrix/CSV_StructuralConnectome_{1}.csv -out_assignments %s/Results/DwiVolu/StructuralConnectomeMatrix/Assignments_{1}.txt -quiet', CommandParallel,WorkingDir,WorkingDir,WorkingDir,WorkingDir);

    if Cfg.ParallelWorkersNumber~=0
        Command = sprintf('%s -nthreads 1', Command);
    end

    Command = sprintf('%s -assignment_radial_search %g', Command,Cfg.StructuralConnectomeMatrix.AssignmentRadialSearch);
    Command = sprintf('%s -stat_edge %s', Command,Cfg.StructuralConnectomeMatrix.StatEdge);
    if Cfg.StructuralConnectomeMatrix.Symmetric
        Command = sprintf('%s -symmetric', Command);
    end

    if Cfg.StructuralConnectomeMatrix.UseSiftWeights
        Command = sprintf('%s -tck_weights_in %s/qsirecon/{1}/dwi/{1}_space-T1w_desc-preproc_desc-siftweights_ifod2.csv', Command,WorkingDir);
    end

    if Cfg.StructuralConnectomeMatrix.ScaleLength
        Command = sprintf('%s -scale_length', Command);
    end
    if Cfg.StructuralConnectomeMatrix.ScaleInvLength
        Command = sprintf('%s -scale_invlength', Command);
    end
    if Cfg.StructuralConnectomeMatrix.ScaleInvNodeVol
        Command = sprintf('%s -scale_invnodevol', Command);
    end

    if Cfg.StructuralConnectomeMatrix.WeightedByFA
        Command = sprintf('%s -scale_file %s/Results/DwiVolu/StructuralConnectomeMatrix/MeanFAPerStreamline_{1}.csv', Command,WorkingDir);
    elseif Cfg.StructuralConnectomeMatrix.WeightedByImage.Is
        Command = sprintf('%s -scale_file %s/Results/DwiVolu/StructuralConnectomeMatrix/WeightedImagePerStreamline_{1}.csv', Command,WorkingDir);
    end

    Command = sprintf('%s -force ::: %s', Command, SubjectIDString);
    fprintf('Structural Connectome Matrix Calculating, please wait...\n');
    system(Command);

    for i=1:Cfg.SubjectNum
        NetworkMatrix = load(sprintf('%s/Results/DwiVolu/StructuralConnectomeMatrix/CSV_StructuralConnectome_%s.csv',Cfg.WorkingDir,Cfg.SubjectID{i}));
        save(sprintf('%s/Results/DwiVolu/StructuralConnectomeMatrix/StructuralConnectomeMatrix_%s.mat',Cfg.WorkingDir,Cfg.SubjectID{i}),'NetworkMatrix');
    end
end




%Calculate Seed Based Structural Connectivity: tracks and TDI
if (Cfg.SeedBasedStructuralConnectivity.Is==1)

    % Close parpool
    PCTVer = ver('distcomp');
    if ~isempty(PCTVer)
        FullMatlabVersion = sscanf(version,'%d.%d.%d.%d%s');
        if FullMatlabVersion(1)*1000+FullMatlabVersion(2)<8*1000+3    %YAN Chao-Gan, 151117. If it's lower than MATLAB 2014a.  %FullMatlabVersion(1)*1000+FullMatlabVersion(2)>=7*1000+8    %YAN Chao-Gan, 120903. If it's higher than MATLAB 2008.
            CurrentSize_MatlabPool = matlabpool('size');
            if (CurrentSize_MatlabPool~=0)
                matlabpool close
            end
        else
            if ~isempty(gcp('nocreate'))
                delete(gcp('nocreate'));
            end
        end
    end


    mkdir([Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'SeedBasedStructuralConnectivityTrack']);
    mkdir([Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'SeedBasedStructuralConnectivityTDIMap']);
    for i=1:Cfg.SubjectNum
        copyfile([Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForDwi',filesep,'Masks_DwiSpace_Merged',filesep,'ROI_OrderKey_',Cfg.SubjectID{i},'.tsv'],[Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'SeedBasedStructuralConnectivityTrack']);
        copyfile([Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForDwi',filesep,'Masks_DwiSpace_Merged',filesep,'ROI_OrderKey_',Cfg.SubjectID{i},'.tsv'],[Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'SeedBasedStructuralConnectivityTDIMap']);
    end
    if Cfg.SeedBasedStructuralConnectivity.TWFC.Is==1
        mkdir([Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'SeedBasedStructuralConnectivityTWFCMap']);
        for i=1:Cfg.SubjectNum
            copyfile([Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForDwi',filesep,'Masks_DwiSpace_Merged',filesep,'ROI_OrderKey_',Cfg.SubjectID{i},'.tsv'],[Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'SeedBasedStructuralConnectivityTWFCMap']);
        end
    end

    if Cfg.SeedBasedStructuralConnectivity.TracksForEachROI==1
        for iElement=1:MaxElement
            %tckedit /data/qsirecon/sub-Sub001/dwi/sub-Sub001_space-T1w_desc-preproc_desc-tracks_ifod2.tck /data/Results/DwiVolu/Tracks/Test/RPI.tck -tck_weights_in /data/qsirecon/sub-Sub001/dwi/sub-Sub001_space-T1w_desc-preproc_desc-siftweights_ifod2.csv  -tck_weights_out /data/Results/DwiVolu/Tracks/Test/RPI.csv -include /data/Masks/TestingMasks/MyRPI.nii
            Command = sprintf('%s tckedit %s/qsirecon/{1}/dwi/{1}_space-T1w_desc-preproc_desc-tracks_ifod2.tck',CommandParallel,WorkingDir);
            Command = sprintf('%s %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/ROI_%s_{1}.tck -tck_weights_in %s/qsirecon/{1}/dwi/{1}_space-T1w_desc-preproc_desc-siftweights_ifod2.csv  -tck_weights_out %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/ROI_%s_{1}.csv', Command,WorkingDir,num2str(iElement),WorkingDir,WorkingDir,num2str(iElement));
            Command = sprintf('%s -include %s/Masks/MasksForDwi/Masks_DwiSpace_Split/SplitMask_ROI_%s_{1}.nii', Command,WorkingDir,num2str(iElement));
            if Cfg.ParallelWorkersNumber~=0
                Command = sprintf('%s -nthreads 1', Command);
            end
            Command = sprintf('%s -force ::: %s', Command, SubjectIDString);
            fprintf('Seed Based Structural Connectivity: Tracks Calculating, please wait...\n');
            system(Command);
            %tckmap /data/Results/DwiVolu/Tracks/Test/RPI.tck /data/Results/DwiVolu/Tracks/Test/RPI.nii -tck_weights_in /data/Results/DwiVolu/Tracks/Test/RPI.csv -template /data/qsiprep/sub-Sub001/dwi/sub-Sub001_space-T1w_desc-preproc_dwi.nii.gz
            Command = sprintf('%s tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/ROI_%s_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTDIMap/ROI_%s_{1}_TDIMap.nii -tck_weights_in %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/ROI_%s_{1}.csv -template %s/qsiprep/{1}/dwi/{1}_space-T1w_desc-preproc_dwi.nii.gz',CommandParallel,WorkingDir,num2str(iElement),WorkingDir,num2str(iElement),WorkingDir,num2str(iElement),WorkingDir);
            if Cfg.ParallelWorkersNumber~=0
                Command = sprintf('%s -nthreads 1', Command);
            end
            Command = sprintf('%s -force ::: %s', Command, SubjectIDString);
            fprintf('Seed Based Structural Connectivity: TDI Map Calculating, please wait...\n');
            system(Command);

            %TWFC
            if Cfg.SeedBasedStructuralConnectivity.TWFC.Is==1
                FCFile = Cfg.SeedBasedStructuralConnectivity.TWFC.FCFile;
                FCFile = replace(FCFile,'/',filesep);

                FCFile = replace(FCFile,'{WorkingDir}',Cfg.WorkingDir);
                FCFile = replace(FCFile,'{iROI}',num2str(iElement));


                k_SubjectID = strfind(FCFile,'{SubjectID}');
                k_Filesep = strfind(FCFile,filesep);
                if ~isempty(k_SubjectID)
                    FirstFilesep = k_Filesep(max(find(k_Filesep<k_SubjectID(1))));
                else
                    FirstFilesep=k_Filesep(end);
                end

                MountPath=FCFile(1:FirstFilesep-1);
                WithinFile=FCFile(FirstFilesep+1:end);

                WithinFile = replace(WithinFile,'{SubjectID}','{1}');
                WithinFile = replace(WithinFile,filesep,'/');

                FCFile = replace(FCFile,'{SubjectID}','{1}');

                %tckmap tracks.tck temp.mif <-template / -vox options> -contrast scalar_map -image FC_map.mif -stat_vox mean -stat_tck sum
                if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
                    Command=sprintf('parallel -j %g tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/ROI_%s_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTWFCMap/ROI_%s_{1}_TWFCMap_Unthresholded.nii -template %s/qsiprep/{1}/dwi/{1}_space-T1w_desc-preproc_dwi.nii.gz -contrast scalar_map -image %s -stat_vox %s -stat_tck %s', ...
                        Cfg.ParallelWorkersNumber, WorkingDir,num2str(iElement),WorkingDir,num2str(iElement),WorkingDir,FCFile,Cfg.SeedBasedStructuralConnectivity.TWFC.StatVox,Cfg.SeedBasedStructuralConnectivity.TWFC.StatTck);
                else
                    Command=sprintf('%s -v %s:/MountPath cgyan/dpabifiber parallel -j %g tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/ROI_%s_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTWFCMap/ROI_%s_{1}_TWFCMap_Unthresholded.nii -template %s/qsiprep/{1}/dwi/{1}_space-T1w_desc-preproc_dwi.nii.gz -contrast scalar_map -image /MountPath/%s -stat_vox %s -stat_tck %s', ...
                        CommandInit, MountPath, Cfg.ParallelWorkersNumber, WorkingDir,num2str(iElement),WorkingDir,num2str(iElement),WorkingDir,WithinFile,Cfg.SeedBasedStructuralConnectivity.TWFC.StatVox,Cfg.SeedBasedStructuralConnectivity.TWFC.StatTck);
                end
                if Cfg.ParallelWorkersNumber~=0
                    Command = sprintf('%s -nthreads 1', Command);
                end
                Command = sprintf('%s -force ::: %s', Command, SubjectIDString);
                fprintf('Seed Based Structural Connectivity: TWFC Map Calculating, please wait...\n');
                system(Command);


                %tckmap tracks.tck - -template temp.mif -contrast scalar_map_count -image FC_map.mif |... mrcalc - 5 -ge mask.mif -datatype bit
                if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
                    Command=sprintf('parallel -j %g tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/ROI_%s_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTWFCMap/ROI_%s_{1}_TWFCMap_StreamlineCount.nii -template %s/qsiprep/{1}/dwi/{1}_space-T1w_desc-preproc_dwi.nii.gz -contrast scalar_map_count -image %s', ...
                        Cfg.ParallelWorkersNumber, WorkingDir,num2str(iElement),WorkingDir,num2str(iElement),WorkingDir,FCFile);
                else
                    Command=sprintf('%s -v %s:/MountPath cgyan/dpabifiber parallel -j %g tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/ROI_%s_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTWFCMap/ROI_%s_{1}_TWFCMap_StreamlineCount.nii -template %s/qsiprep/{1}/dwi/{1}_space-T1w_desc-preproc_dwi.nii.gz -contrast scalar_map_count -image /MountPath/%s', ...
                        CommandInit, MountPath, Cfg.ParallelWorkersNumber, WorkingDir,num2str(iElement),WorkingDir,num2str(iElement),WorkingDir,WithinFile);
                end
                if Cfg.ParallelWorkersNumber~=0
                    Command = sprintf('%s -nthreads 1', Command);
                end
                Command = sprintf('%s -force ::: %s', Command, SubjectIDString);
                fprintf('Seed Based Structural Connectivity: TWFC Streamline Count Calculating, please wait...\n');
                system(Command);

                % mrcalc - 5 -ge mask.mif -datatype bit ... mrcalc temp.mif mask.mif -mult TWFC.mif
                for i=1:Cfg.SubjectNum
                    [Data, VoxelSize, FileList, Header] = y_ReadAll([Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'SeedBasedStructuralConnectivityTWFCMap',filesep,'ROI_',num2str(iElement),'_',Cfg.SubjectID{i},'_TWFCMap_Unthresholded.nii']);
                    StreamlineCount = y_ReadAll([Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'SeedBasedStructuralConnectivityTWFCMap',filesep,'ROI_',num2str(iElement),'_',Cfg.SubjectID{i},'_TWFCMap_StreamlineCount.nii']);
                    Data = Data .* (StreamlineCount >= Cfg.SeedBasedStructuralConnectivity.TWFC.MinimumStreamlineCount);
                    y_Write(Data,Header,[Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'SeedBasedStructuralConnectivityTWFCMap',filesep,'ROI_',num2str(iElement),'_',Cfg.SubjectID{i},'_TWFCMap_Thresholded.nii']);
                end

            end


        end
    else
        %tckedit /data/qsirecon/sub-Sub001/dwi/sub-Sub001_space-T1w_desc-preproc_desc-tracks_ifod2.tck /data/Results/DwiVolu/Tracks/Test/RPI.tck -tck_weights_in /data/qsirecon/sub-Sub001/dwi/sub-Sub001_space-T1w_desc-preproc_desc-siftweights_ifod2.csv  -tck_weights_out /data/Results/DwiVolu/Tracks/Test/RPI.csv -include /data/Masks/TestingMasks/MyRPI.nii
        Command = sprintf('%s tckedit %s/qsirecon/{1}/dwi/{1}_space-T1w_desc-preproc_desc-tracks_ifod2.tck',CommandParallel,WorkingDir);
        Command = sprintf('%s %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/AllROITraverse_{1}.tck -tck_weights_in %s/qsirecon/{1}/dwi/{1}_space-T1w_desc-preproc_desc-siftweights_ifod2.csv  -tck_weights_out %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/AllROITraverse_{1}.csv', Command,WorkingDir,WorkingDir,WorkingDir);
        for iElement=1:MaxElement
            Command = sprintf('%s -include %s/Masks/MasksForDwi/Masks_DwiSpace_Split/SplitMask_ROI_%s_{1}.nii', Command,WorkingDir,num2str(iElement));
        end
        if Cfg.ParallelWorkersNumber~=0
            Command = sprintf('%s -nthreads 1', Command);
        end
        Command = sprintf('%s -force ::: %s', Command, SubjectIDString);
        fprintf('Seed Based Structural Connectivity: Tracks Calculating, please wait...\n');
        system(Command);
        %tckmap /data/Results/DwiVolu/Tracks/Test/RPI.tck /data/Results/DwiVolu/Tracks/Test/RPI.nii -tck_weights_in /data/Results/DwiVolu/Tracks/Test/RPI.csv -template /data/qsiprep/sub-Sub001/dwi/sub-Sub001_space-T1w_desc-preproc_dwi.nii.gz
        Command = sprintf('%s tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/AllROITraverse_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTDIMap/AllROITraverse_{1}_TDIMap.nii -tck_weights_in %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/AllROITraverse_{1}.csv -template %s/qsiprep/{1}/dwi/{1}_space-T1w_desc-preproc_dwi.nii.gz',CommandParallel,WorkingDir,WorkingDir,WorkingDir,WorkingDir);
        if Cfg.ParallelWorkersNumber~=0
            Command = sprintf('%s -nthreads 1', Command);
        end
        Command = sprintf('%s -force ::: %s', Command, SubjectIDString);
        fprintf('Seed Based Structural Connectivity: TDI Map Calculating, please wait...\n');
        system(Command);


        %TWFC
        if Cfg.SeedBasedStructuralConnectivity.TWFC.Is==1
            FCFile = Cfg.SeedBasedStructuralConnectivity.TWFC.FCFile;
            FCFile = replace(FCFile,'/',filesep);

            FCFile = replace(FCFile,'{WorkingDir}',Cfg.WorkingDir);

            k_SubjectID = strfind(FCFile,'{SubjectID}');
            k_Filesep = strfind(FCFile,filesep);
            if ~isempty(k_SubjectID)
                FirstFilesep = k_Filesep(max(find(k_Filesep<k_SubjectID(1))));
            else
                FirstFilesep=k_Filesep(end);
            end

            MountPath=FCFile(1:FirstFilesep-1);
            WithinFile=FCFile(FirstFilesep+1:end);

            WithinFile = replace(WithinFile,'{SubjectID}','{1}');
            WithinFile = replace(WithinFile,filesep,'/');

            FCFile = replace(FCFile,'{SubjectID}','{1}');

            %tckmap tracks.tck temp.mif <-template / -vox options> -contrast scalar_map -image FC_map.mif -stat_vox mean -stat_tck sum
            if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
                Command=sprintf('parallel -j %g tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/AllROITraverse_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTWFCMap/AllROITraverse_{1}_TWFCMap_Unthresholded.nii -template %s/qsiprep/{1}/dwi/{1}_space-T1w_desc-preproc_dwi.nii.gz -contrast scalar_map -image %s -stat_vox %s -stat_tck %s', ...
                    Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,WorkingDir,FCFile,Cfg.SeedBasedStructuralConnectivity.TWFC.StatVox,Cfg.SeedBasedStructuralConnectivity.TWFC.StatTck);
            else
                Command=sprintf('%s -v %s:/MountPath cgyan/dpabifiber parallel -j %g tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/AllROITraverse_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTWFCMap/AllROITraverse_{1}_TWFCMap_Unthresholded.nii -template %s/qsiprep/{1}/dwi/{1}_space-T1w_desc-preproc_dwi.nii.gz -contrast scalar_map -image /MountPath/%s -stat_vox %s -stat_tck %s', ...
                    CommandInit, MountPath, Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,WorkingDir,WithinFile,Cfg.SeedBasedStructuralConnectivity.TWFC.StatVox,Cfg.SeedBasedStructuralConnectivity.TWFC.StatTck);
            end
            if Cfg.ParallelWorkersNumber~=0
                Command = sprintf('%s -nthreads 1', Command);
            end
            Command = sprintf('%s -force ::: %s', Command, SubjectIDString);
            fprintf('Seed Based Structural Connectivity: TWFC Map Calculating, please wait...\n');
            system(Command);


            %tckmap tracks.tck - -template temp.mif -contrast scalar_map_count -image FC_map.mif |... mrcalc - 5 -ge mask.mif -datatype bit
            if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
                Command=sprintf('parallel -j %g tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/AllROITraverse_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTWFCMap/AllROITraverse_{1}_TWFCMap_StreamlineCount.nii -template %s/qsiprep/{1}/dwi/{1}_space-T1w_desc-preproc_dwi.nii.gz -contrast scalar_map_count -image %s', ...
                    Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,WorkingDir,FCFile);
            else
                Command=sprintf('%s -v %s:/MountPath cgyan/dpabifiber parallel -j %g tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/AllROITraverse_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTWFCMap/AllROITraverse_{1}_TWFCMap_StreamlineCount.nii -template %s/qsiprep/{1}/dwi/{1}_space-T1w_desc-preproc_dwi.nii.gz -contrast scalar_map_count -image /MountPath/%s', ...
                    CommandInit, MountPath, Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,WorkingDir,WithinFile);
            end
            if Cfg.ParallelWorkersNumber~=0
                Command = sprintf('%s -nthreads 1', Command);
            end
            Command = sprintf('%s -force ::: %s', Command, SubjectIDString);
            fprintf('Seed Based Structural Connectivity: TWFC Streamline Count Calculating, please wait...\n');
            system(Command);

            % mrcalc - 5 -ge mask.mif -datatype bit ... mrcalc temp.mif mask.mif -mult TWFC.mif
            for i=1:Cfg.SubjectNum
                [Data, VoxelSize, FileList, Header] = y_ReadAll([Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'SeedBasedStructuralConnectivityTWFCMap',filesep,'AllROITraverse_',Cfg.SubjectID{i},'_TWFCMap_Unthresholded.nii']);
                StreamlineCount = y_ReadAll([Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'SeedBasedStructuralConnectivityTWFCMap',filesep,'AllROITraverse_',Cfg.SubjectID{i},'_TWFCMap_StreamlineCount.nii']);
                Data = Data .* (StreamlineCount >= Cfg.SeedBasedStructuralConnectivity.TWFC.MinimumStreamlineCount);
                y_Write(Data,Header,[Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'SeedBasedStructuralConnectivityTWFCMap',filesep,'AllROITraverse_',Cfg.SubjectID{i},'_TWFCMap_Thresholded.nii']);
            end

        end

    end
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%***Normalize and/or Smooth the results***%%%%%%%%%%%%%%%%

Cfg.StartingDirName = 'Results';

% I will not use FunSessionPrefixSet, but just make the code compatiblewith the functional ones
Cfg.FunctionalSessionNumber=1;
FunSessionPrefixSet={''}; 
for iFunSession=2:Cfg.FunctionalSessionNumber
    FunSessionPrefixSet=[FunSessionPrefixSet;{['S',num2str(iFunSession),'_']}];
end

%Normalize on Results
if (Cfg.Normalize.Is>0) && strcmpi(Cfg.Normalize.Timing,'OnResults')

    %Prepare the ref file
    if ~(7==exist([Cfg.WorkingDir,filesep,'Masks'],'dir'))
        mkdir([Cfg.WorkingDir,filesep,'Masks']);
    end
    copyfile([DPABIPath,filesep,'Templates',filesep,'BrainMask_05_97x115x97.nii'],[Cfg.WorkingDir,filesep,'Masks']);


    fprintf(['Normalizing the resutls...\n']);
    for iFunSession=1:Cfg.FunctionalSessionNumber
        for i=1:Cfg.SubjectNum
            %Check the DSpaces need to be normalized
            DirDSpace = dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName]);
            if strcmpi(DirDSpace(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
                StartIndex=4;
            else
                StartIndex=3;
            end
            DSpaceSet=[];
            for iDir=StartIndex:length(DirDSpace)
                if DirDSpace(iDir).isdir
                    DSpaceSet = [DSpaceSet;{DirDSpace(iDir).name}];
                end

            end

            for iDSpace=1:length(DSpaceSet)
                switch DSpaceSet{iDSpace}
                    case {'DwiVolu'}
                        %Check the measures need to be normalized
                        DirMeasure = dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace}]);
                        if strcmpi(DirMeasure(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
                            StartIndex=4;
                        else
                            StartIndex=3;
                        end
                        MeasureSet=[];
                        for iDir=StartIndex:length(DirMeasure)
                            if DirMeasure(iDir).isdir
                                MeasureSet = [MeasureSet;{DirMeasure(iDir).name}];
                            end
                        end
                        for iMeasure=1:length(MeasureSet)
                            switch MeasureSet{iMeasure}
                                case {'SeedBasedStructuralConnectivityTDIMap','SeedBasedStructuralConnectivityTWFCMap'}
                                    [tmp1 tmp2]=mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,'W',filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure}]);
                                    FileList=[];
                                    DirImg=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure},filesep,'*',Cfg.SubjectID{i},'*.nii*']);
                                    for j=1:length(DirImg)
                                        FileList=[FileList,' ',DirImg(j).name];
                                    end
                                    Command = sprintf('%s antsApplyTransforms --default-value 0 --float 0 --input %s/%s/%s/%s/{1} --interpolation Linear --output %s/%sW/%s/%s/w{1} --reference-image %s/Masks/BrainMask_05_97x115x97.nii  --transform %s/qsiprep/%s/anat/%s_from-T1w_to-MNI152NLin2009cAsym_mode-image_xfm.h5 ::: %s', ...
                                        CommandParallel, WorkingDir, [FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],DSpaceSet{iDSpace},MeasureSet{iMeasure}, WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],DSpaceSet{iDSpace},MeasureSet{iMeasure},WorkingDir,WorkingDir,Cfg.SubjectID{i},Cfg.SubjectID{i},FileList);
                                    system(Command);

                                case {'TensorMetrics'}

                                    DirSubfolder = dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure}]);
                                    if strcmpi(DirSubfolder(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
                                        StartIndex=4;
                                    else
                                        StartIndex=3;
                                    end
                                    SubfolderSet=[];
                                    for iDir=StartIndex:length(DirSubfolder)
                                        if DirSubfolder(iDir).isdir
                                            SubfolderSet = [SubfolderSet;{DirSubfolder(iDir).name}];
                                        end
                                    end

                                    for iSubfolder=1:length(SubfolderSet)

                                        [tmp1 tmp2]=mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,'W',filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure},filesep,SubfolderSet{iSubfolder}]);
                                        FileList=[];
                                        DirImg=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure},filesep,SubfolderSet{iSubfolder},filesep,'*',Cfg.SubjectID{i},'*.nii*']);
                                        for j=1:length(DirImg)
                                            FileList=[FileList,' ',DirImg(j).name];
                                        end
                                        if strcmpi(SubfolderSet{iSubfolder},'Tensor')
                                            Command = sprintf('%s antsApplyTransforms --default-value 0 --float 0 --input-image-type 3 --input %s/%s/%s/%s/%s/{1} --interpolation Linear --output %s/%sW/%s/%s/%s/w{1} --reference-image %s/Masks/BrainMask_05_97x115x97.nii  --transform %s/qsiprep/%s/anat/%s_from-T1w_to-MNI152NLin2009cAsym_mode-image_xfm.h5 ::: %s', ...
                                                CommandParallel, WorkingDir, [FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],DSpaceSet{iDSpace},MeasureSet{iMeasure},SubfolderSet{iSubfolder}, WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],DSpaceSet{iDSpace},MeasureSet{iMeasure},SubfolderSet{iSubfolder},WorkingDir,WorkingDir,Cfg.SubjectID{i},Cfg.SubjectID{i},FileList);
                                        else
                                            Command = sprintf('%s antsApplyTransforms --default-value 0 --float 0 --input %s/%s/%s/%s/%s/{1} --interpolation Linear --output %s/%sW/%s/%s/%s/w{1} --reference-image %s/Masks/BrainMask_05_97x115x97.nii  --transform %s/qsiprep/%s/anat/%s_from-T1w_to-MNI152NLin2009cAsym_mode-image_xfm.h5 ::: %s', ...
                                                CommandParallel, WorkingDir, [FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],DSpaceSet{iDSpace},MeasureSet{iMeasure},SubfolderSet{iSubfolder}, WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],DSpaceSet{iDSpace},MeasureSet{iMeasure},SubfolderSet{iSubfolder},WorkingDir,WorkingDir,Cfg.SubjectID{i},Cfg.SubjectID{i},FileList);
                                        end
                                        system(Command);
                                    end
                            end

                        end
                end
            end
        end
    end
    Cfg.StartingDirName=[Cfg.StartingDirName,'W']; %Now StartingDirName is with new suffix 'S'

  
end



%Smooth on Results
if (Cfg.Smooth.Is==1) && strcmpi(Cfg.Smooth.Timing,'OnResults')
    fprintf(['Smoothing the resutls...\n']);
    for iFunSession=1:Cfg.FunctionalSessionNumber
        for i=1:Cfg.SubjectNum
            %Check the DSpaces need to be normalized
            DirDSpace = dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName]);
            if strcmpi(DirDSpace(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
                StartIndex=4;
            else
                StartIndex=3;
            end
            DSpaceSet=[];
            for iDir=StartIndex:length(DirDSpace)
                if DirDSpace(iDir).isdir
                    if ~((length(DirDSpace(iDir).name)>=28 && strcmpi(DirDSpace(iDir).name(1:28),'ROISignals_SurfLHSurfRHVolu_')))
                        DSpaceSet = [DSpaceSet;{DirDSpace(iDir).name}];
                    end
                end

            end

            for iDSpace=1:length(DSpaceSet)
                switch DSpaceSet{iDSpace}

                    case {'DwiVolu'}
                        %Check the measures need to be normalized
                        DirMeasure = dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace}]);
                        if strcmpi(DirMeasure(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
                            StartIndex=4;
                        else
                            StartIndex=3;
                        end
                        MeasureSet=[];
                        for iDir=StartIndex:length(DirMeasure)
                            if DirMeasure(iDir).isdir
                                MeasureSet = [MeasureSet;{DirMeasure(iDir).name}];
                            end
                        end
                        for iMeasure=1:length(MeasureSet)
                            switch MeasureSet{iMeasure}
                                case {'SeedBasedStructuralConnectivityTDIMap','SeedBasedStructuralConnectivityTWFCMap'}

                                    [tmp1 tmp2]=mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,'S',filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure}]);
                                    FileList=[];
                                    DirImg=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure},filesep,'*',Cfg.SubjectID{i},'*.nii.gz']);
                                    if ~isempty(DirImg)
                                        for j=1:length(DirImg)
                                            gunzip([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure},filesep,DirImg(j).name]);
                                            delete([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure},filesep,DirImg(j).name]);
                                        end
                                    end
                                    DirImg=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure},filesep,'*',Cfg.SubjectID{i},'*.nii']);
                                    if ~isempty(DirImg)
                                        for j=1:length(DirImg)
                                            FileList=[FileList;{[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure},filesep,DirImg(j).name]}];
                                        end
                                        SPMJOB = load([DPABIPath,filesep,'DPARSF',filesep,'Jobmats',filesep,'Smooth.mat']);
                                        SPMJOB.matlabbatch{1,1}.spm.spatial.smooth.data = FileList;
                                        SPMJOB.matlabbatch{1,1}.spm.spatial.smooth.fwhm = Cfg.Smooth.FWHMVolu;
                                        spm_jobman('run',SPMJOB.matlabbatch);

                                        DirTemp=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure},filesep,'ss*']);
                                        if isempty(DirTemp)
                                            movefile([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure},filesep,'s*'],[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,'S',filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure}]);
                                        else
                                            movefile([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure},filesep,'ss*'],[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,'S',filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure}]);
                                        end
                                    end


                                case {'TensorMetrics'}

                                    DirSubfolder = dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure}]);
                                    if strcmpi(DirSubfolder(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
                                        StartIndex=4;
                                    else
                                        StartIndex=3;
                                    end
                                    SubfolderSet=[];
                                    for iDir=StartIndex:length(DirSubfolder)
                                        if DirSubfolder(iDir).isdir
                                            SubfolderSet = [SubfolderSet;{DirSubfolder(iDir).name}];
                                        end
                                    end

                                    for iSubfolder=1:length(SubfolderSet)


                                        [tmp1 tmp2]=mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,'S',filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure},filesep,SubfolderSet{iSubfolder}]);
                                        FileList=[];
                                        DirImg=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure},filesep,SubfolderSet{iSubfolder},filesep,'*',Cfg.SubjectID{i},'*.nii.gz']);
                                        if ~isempty(DirImg)
                                            for j=1:length(DirImg)
                                                gunzip([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure},filesep,SubfolderSet{iSubfolder},filesep,DirImg(j).name]);
                                                delete([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure},filesep,SubfolderSet{iSubfolder},filesep,DirImg(j).name]);
                                            end
                                        end
                                        DirImg=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure},filesep,SubfolderSet{iSubfolder},filesep,'*',Cfg.SubjectID{i},'*.nii']);
                                        if ~isempty(DirImg)
                                            for j=1:length(DirImg)
                                                FileList=[FileList;{[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure},filesep,SubfolderSet{iSubfolder},filesep,DirImg(j).name]}];
                                            end
                                            SPMJOB = load([DPABIPath,filesep,'DPARSF',filesep,'Jobmats',filesep,'Smooth.mat']);
                                            SPMJOB.matlabbatch{1,1}.spm.spatial.smooth.data = FileList;
                                            SPMJOB.matlabbatch{1,1}.spm.spatial.smooth.fwhm = Cfg.Smooth.FWHMVolu;
                                            spm_jobman('run',SPMJOB.matlabbatch);

                                            DirTemp=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure},filesep,SubfolderSet{iSubfolder},filesep,'ss*']);
                                            if isempty(DirTemp)
                                                movefile([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure},filesep,SubfolderSet{iSubfolder},filesep,'s*'],[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,'S',filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure},filesep,SubfolderSet{iSubfolder}]);
                                            else
                                                movefile([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure},filesep,SubfolderSet{iSubfolder},filesep,'ss*'],[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,'S',filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure},filesep,SubfolderSet{iSubfolder}]);
                                            end
                                        end

                                    end
                            end

                        end

                end
            end
        end
    end
    Cfg.StartingDirName=[Cfg.StartingDirName,'S']; %Now StartingDirName is with new suffix 'S'
end





fprintf(['\nCongratulations, the running of DPABIFiber is done!!! :)\n\n']);

