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
        Cfg.StructuralConnectomeMatrix.WeightedByImage.ImageFileSpace='T1w';
    else
        if ~isfield(Cfg.StructuralConnectomeMatrix.WeightedByImage,'Is')
            Cfg.StructuralConnectomeMatrix.WeightedByImage.Is=0;
        end
        if ~isfield(Cfg.StructuralConnectomeMatrix.WeightedByImage,'ImageFileSpace')
            Cfg.StructuralConnectomeMatrix.WeightedByImage.ImageFileSpace='T1w';
        end
    end
end
if ~isfield(Cfg,'SeedBasedStructuralConnectivity')
    Cfg.SeedBasedStructuralConnectivity.Is=0;
else
    if ~isfield(Cfg.SeedBasedStructuralConnectivity,'TWFC')
        Cfg.SeedBasedStructuralConnectivity.TWFC.Is=0;
    else
        if ~isfield(Cfg.SeedBasedStructuralConnectivity.TWFC,'Is')
            Cfg.SeedBasedStructuralConnectivity.TWFC.Is=0;
        end
        if ~isfield(Cfg.SeedBasedStructuralConnectivity.TWFC,'FCFileSpace')
            Cfg.SeedBasedStructuralConnectivity.TWFC.FCFileSpace='T1w';
        end
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
    CommandParallelQsiprep=sprintf('parallel -j %g', Cfg.ParallelWorkersNumber);
    WorkingDir=Cfg.WorkingDir;
else
    CommandParallel=sprintf('%s cgyan/dpabifiber parallel -j %g', CommandInit, Cfg.ParallelWorkersNumber );
    CommandParallelQsiprep=sprintf('%s cgyan/qsiprep parallel -j %g', CommandInit, Cfg.ParallelWorkersNumber );
    WorkingDir='/data';
end

SubjectIDString=[];
for i=1:Cfg.SubjectNum
    SubjectIDString = sprintf('%s %s',SubjectIDString,Cfg.SubjectID{i});
end

NeedWeightedImageT1wToACPC = local_need_weighted_image_to_acpc(Cfg);
NeedTWFCT1wToACPC = local_need_twfc_fcfile_to_acpc(Cfg);
NeedT1wToACPC = NeedWeightedImageT1wToACPC || NeedTWFCT1wToACPC;
ACPCReferenceFileSet = {};



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
    
    %!docker run -ti --rm -v /mnt/Data45/RfMRILab/yan/YAN_Work/DPABIUpdating/Program/DPABI_V6.1_220101/DPABISurf/FreeSurferLicense/license.txt:/opt/freesurfer/license.txt -v /mnt/Data45/RfMRILab/yan/YAN_Work/DPABIUpdating/DPABIFiber/Data/Test/BJDataTest/Try1:/data  cgyan/qsiprep /usr/local/miniconda/bin/qsiprep /data/BIDS /data participant --nthreads 1 --omp-nthreads 1 --fs-license-file /opt/freesurfer/license.txt --recon-spec /data/mrtrix_singleshell_ss3t_ACT-hsvs.json --freesurfer-input /data/freesurfer --output-resolution 2 -w /data/qsiprepwork/sub-Sub001  --participant_label sub-Sub001

    if ~exist([Cfg.WorkingDir,filesep,'qsiprep'],'dir') % If it's the first time to run qsiprep
        
        if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
            Command=sprintf('parallel -j %g qsiprep %s/BIDS %s/qsiprep participant --fs-license-file /DPABI/DPABISurf/FreeSurferLicense/license.txt --resource-monitor', Cfg.ParallelWorkersNumber, Cfg.WorkingDir, Cfg.WorkingDir);
        else
            Command=sprintf('%s cgyan/qsiprep parallel -j %g qsiprep /data/BIDS /data/qsiprep participant --fs-license-file /DPABI/DPABISurf/FreeSurferLicense/license.txt --resource-monitor', CommandInit, Cfg.ParallelWorkersNumber );
        end
        
        if Cfg.ParallelWorkersNumber~=0
            Command = sprintf('%s --nthreads 1 --omp-nthreads 1', Command);
        end
        
        Command = sprintf('%s --output-resolution %g', Command, Cfg.OutputResolution);

        if Cfg.IsLowMem==1
            Command = sprintf('%s --low-mem', Command);
        end
        
        Command = sprintf('%s -w /data/qsiprepwork/{1}', Command); %Specify the working dir for qsiprep
        Command = sprintf('%s  --participant-label {1} ::: %s', Command, SubjectIDString);
        
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



    %Chao-Gan Yan, 20260125. Prepare T1w -> qsiprep ACPC transform and convert freesurfer aparcaseg files
    local_cleanup_session_aliases_for_qsirecon(fullfile(Cfg.WorkingDir,'qsiprep'), Cfg.SubjectID);
    local_cleanup_session_aliases_for_qsirecon(fullfile(Cfg.WorkingDir,'fmriprep'), Cfg.SubjectID);
    AparcasegSourceFileSet = local_prepare_t1w_aparcaseg_aliases(fullfile(Cfg.WorkingDir,'Results','AnatVolu','T1wSpace'), Cfg.SubjectID);
    HasAparcasegSource = cellfun(@(FileName) ~isempty(FileName) && (2==exist(FileName,'file')), AparcasegSourceFileSet);

    if any(HasAparcasegSource)
        if ~all(HasAparcasegSource)
            error('T1w aparcaseg source file does not exist for: %s', strjoin(Cfg.SubjectID(~HasAparcasegSource), ', '));
        end
    end

    if any(HasAparcasegSource) || NeedT1wToACPC
        ACPCReferenceFileSet = local_ensure_fmriprep_t1_to_qsiprep_acpc_transform(Cfg, CommandInit, WorkingDir);
    end

    if any(HasAparcasegSource)
        AparcasegInput = [WorkingDir,'/Results/AnatVolu/T1wSpace/{1}/{1}_space-T1w_desc-aparcaseg.nii.gz'];
        AparcasegOutput = 'Results/AnatVolu/T1wSpace/{1}/{1}_space-ACPC_desc-aparcaseg.nii.gz';
        fprintf('Transform aparcaseg to space-ACPC, please wait...\n');
        local_apply_t1w_to_acpc(Cfg, CommandParallelQsiprep, WorkingDir, ACPCReferenceFileSet, AparcasegInput, AparcasegOutput, 'MultiLabel');
    end


    Cfg.StartingDirName = 'qsiprep';
end




% Calculate DWI Tensor Metrics
if (Cfg.IsCalTensorMetrics==1)
    %dwi2tensor -grad /data/qsiprep/sub-Sub001/dwi/sub-Sub001_space-ACPC_desc-preproc_dwi.b -mask /data/qsiprep/sub-Sub001/dwi/sub-Sub001_space-ACPC_desc-brain_mask.nii.gz /data/qsiprep/sub-Sub001/dwi/sub-Sub001_space-ACPC_desc-preproc_dwi.nii.gz /data/Tensor/Tensor/sub-Sub001_space-ACPC_desc-preproc_dwitensor.nii.gz
    mkdir([Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'TensorMetrics',filesep,'Tensor']);
    
    RefFile=[Cfg.WorkingDir,filesep,'qsiprep',filesep,Cfg.SubjectID{1},filesep,'dwi',filesep,Cfg.SubjectID{1},'_space-ACPC_desc-preproc_dwi.b'];
    if (2==exist(RefFile,'file'))
        if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
            Command=sprintf('parallel -j %g dwi2tensor -grad %s/qsiprep/{1}/dwi/{1}_space-ACPC_desc-preproc_dwi.b -mask %s/qsiprep/{1}/dwi/{1}_space-ACPC_desc-brain_mask.nii.gz %s/qsiprep/{1}/dwi/{1}_space-ACPC_desc-preproc_dwi.nii.gz %s/Results/DwiVolu/TensorMetrics/Tensor/{1}_space-ACPC_desc-preproc_dwitensor.nii.gz', Cfg.ParallelWorkersNumber, Cfg.WorkingDir, Cfg.WorkingDir,Cfg.WorkingDir,Cfg.WorkingDir);
        else
            Command=sprintf('%s cgyan/dpabifiber parallel -j %g dwi2tensor -grad /data/qsiprep/{1}/dwi/{1}_space-ACPC_desc-preproc_dwi.b -mask /data/qsiprep/{1}/dwi/{1}_space-ACPC_desc-brain_mask.nii.gz /data/qsiprep/{1}/dwi/{1}_space-ACPC_desc-preproc_dwi.nii.gz /data/Results/DwiVolu/TensorMetrics/Tensor/{1}_space-ACPC_desc-preproc_dwitensor.nii.gz', CommandInit, Cfg.ParallelWorkersNumber);
        end
    else
        if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
            Command=sprintf('parallel -j %g dwi2tensor -grad %s/qsiprep/{1}/ses-1/dwi/{1}_ses-1_space-ACPC_desc-preproc_dwi.b -mask %s/qsiprep/{1}/ses-1/dwi/{1}_ses-1_space-ACPC_desc-brain_mask.nii.gz %s/qsiprep/{1}/ses-1/dwi/{1}_ses-1_space-ACPC_desc-preproc_dwi.nii.gz %s/Results/DwiVolu/TensorMetrics/Tensor/{1}_space-ACPC_desc-preproc_dwitensor.nii.gz', Cfg.ParallelWorkersNumber, Cfg.WorkingDir, Cfg.WorkingDir,Cfg.WorkingDir,Cfg.WorkingDir);
        else
            Command=sprintf('%s cgyan/dpabifiber parallel -j %g dwi2tensor -grad /data/qsiprep/{1}/ses-1/dwi/{1}_ses-1_space-ACPC_desc-preproc_dwi.b -mask /data/qsiprep/{1}/ses-1/dwi/{1}_ses-1_space-ACPC_desc-brain_mask.nii.gz /data/qsiprep/{1}/ses-1/dwi/{1}_ses-1_space-ACPC_desc-preproc_dwi.nii.gz /data/Results/DwiVolu/TensorMetrics/Tensor/{1}_space-ACPC_desc-preproc_dwitensor.nii.gz', CommandInit, Cfg.ParallelWorkersNumber);
        end
    end
    

    Command = sprintf('%s -force ::: %s', Command, SubjectIDString);
    system(Command);

    %tensor2metric -mask /data/qsiprep/sub-Sub001/dwi/sub-Sub001_space-ACPC_desc-brain_mask.nii.gz -adc /data/Tensor/TensorMetrics/sub-Sub001_space-ACPC_desc-preproc_dwitensor_adc.nii.gz -fa /data/Tensor/TensorMetrics/sub-Sub001_space-ACPC_desc-preproc_dwitensor_fa.nii.gz -ad /data/Tensor/TensorMetrics/sub-Sub001_space-ACPC_desc-preproc_dwitensor_ad.nii.gz -rd /data/Tensor/TensorMetrics/sub-Sub001_space-ACPC_desc-preproc_dwitensor_rd.nii.gz /data/Tensor/Tensor/sub-Sub001_space-ACPC_desc-preproc_dwitensor.nii.gz
    %tensor2metric -mask /data/qsiprep/sub-Sub001/dwi/sub-Sub001_space-ACPC_desc-brain_mask.nii.gz -adc /data/Results/DwiVolu/TensorMetrics/ADC/sub-Sub001_space-ACPC_desc-preproc_dwitensor_metrics.nii.gz -fa /data/Results/DwiVolu/TensorMetrics/FA/sub-Sub001_space-ACPC_desc-preproc_dwitensor_metrics.nii.gz -ad /data/Results/DwiVolu/TensorMetrics/AD/sub-Sub001_space-ACPC_desc-preproc_dwitensor_metrics.nii.gz -rd /data/Results/DwiVolu/TensorMetrics/RD/sub-Sub001_space-ACPC_desc-preproc_dwitensor_metrics.nii.gz /data/Results/DwiVolu/TensorMetrics/Tensor/{1}_space-ACPC_desc-preproc_dwitensor.nii.gz
    mkdir([Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'TensorMetrics',filesep,'ADC']);
    mkdir([Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'TensorMetrics',filesep,'FA']);
    mkdir([Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'TensorMetrics',filesep,'AD']);
    mkdir([Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'TensorMetrics',filesep,'RD']);
    
    RefFile=[Cfg.WorkingDir,filesep,'qsiprep',filesep,Cfg.SubjectID{1},filesep,'dwi',filesep,Cfg.SubjectID{1},'_space-ACPC_desc-preproc_dwi.b'];
    if (2==exist(RefFile,'file'))
        if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
            Command=sprintf('parallel -j %g tensor2metric -mask %s/qsiprep/{1}/dwi/{1}_space-ACPC_desc-brain_mask.nii.gz -adc %s/Results/DwiVolu/TensorMetrics/ADC/{1}_space-ACPC_desc-preproc_dwitensor_metrics.nii.gz -fa %s/Results/DwiVolu/TensorMetrics/FA/{1}_space-ACPC_desc-preproc_dwitensor_metrics.nii.gz -ad %s/Results/DwiVolu/TensorMetrics/AD/{1}_space-ACPC_desc-preproc_dwitensor_metrics.nii.gz -rd %s/Results/DwiVolu/TensorMetrics/RD/{1}_space-ACPC_desc-preproc_dwitensor_metrics.nii.gz %s/Results/DwiVolu/TensorMetrics/Tensor/{1}_space-ACPC_desc-preproc_dwitensor.nii.gz', Cfg.ParallelWorkersNumber, Cfg.WorkingDir, Cfg.WorkingDir,Cfg.WorkingDir,Cfg.WorkingDir,Cfg.WorkingDir,Cfg.WorkingDir);
        else
            Command=sprintf('%s cgyan/dpabifiber parallel -j %g tensor2metric -mask /data/qsiprep/{1}/dwi/{1}_space-ACPC_desc-brain_mask.nii.gz -adc /data/Results/DwiVolu/TensorMetrics/ADC/{1}_space-ACPC_desc-preproc_dwitensor_metrics.nii.gz -fa /data/Results/DwiVolu/TensorMetrics/FA/{1}_space-ACPC_desc-preproc_dwitensor_metrics.nii.gz -ad /data/Results/DwiVolu/TensorMetrics/AD/{1}_space-ACPC_desc-preproc_dwitensor_metrics.nii.gz -rd /data/Results/DwiVolu/TensorMetrics/RD/{1}_space-ACPC_desc-preproc_dwitensor_metrics.nii.gz /data/Results/DwiVolu/TensorMetrics/Tensor/{1}_space-ACPC_desc-preproc_dwitensor.nii.gz', CommandInit, Cfg.ParallelWorkersNumber);
        end
    else
        if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
            Command=sprintf('parallel -j %g tensor2metric -mask %s/qsiprep/{1}/ses-1/dwi/{1}_ses-1_space-ACPC_desc-brain_mask.nii.gz -adc %s/Results/DwiVolu/TensorMetrics/ADC/{1}_space-ACPC_desc-preproc_dwitensor_metrics.nii.gz -fa %s/Results/DwiVolu/TensorMetrics/FA/{1}_space-ACPC_desc-preproc_dwitensor_metrics.nii.gz -ad %s/Results/DwiVolu/TensorMetrics/AD/{1}_space-ACPC_desc-preproc_dwitensor_metrics.nii.gz -rd %s/Results/DwiVolu/TensorMetrics/RD/{1}_space-ACPC_desc-preproc_dwitensor_metrics.nii.gz %s/Results/DwiVolu/TensorMetrics/Tensor/{1}_space-ACPC_desc-preproc_dwitensor.nii.gz', Cfg.ParallelWorkersNumber, Cfg.WorkingDir, Cfg.WorkingDir,Cfg.WorkingDir,Cfg.WorkingDir,Cfg.WorkingDir,Cfg.WorkingDir);
        else
            Command=sprintf('%s cgyan/dpabifiber parallel -j %g tensor2metric -mask /data/qsiprep/{1}/ses-1/dwi/{1}_ses-1_space-ACPC_desc-brain_mask.nii.gz -adc /data/Results/DwiVolu/TensorMetrics/ADC/{1}_space-ACPC_desc-preproc_dwitensor_metrics.nii.gz -fa /data/Results/DwiVolu/TensorMetrics/FA/{1}_space-ACPC_desc-preproc_dwitensor_metrics.nii.gz -ad /data/Results/DwiVolu/TensorMetrics/AD/{1}_space-ACPC_desc-preproc_dwitensor_metrics.nii.gz -rd /data/Results/DwiVolu/TensorMetrics/RD/{1}_space-ACPC_desc-preproc_dwitensor_metrics.nii.gz /data/Results/DwiVolu/TensorMetrics/Tensor/{1}_space-ACPC_desc-preproc_dwitensor.nii.gz', CommandInit, Cfg.ParallelWorkersNumber);
        end
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



%Reconstructing with qsirecon
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
            Command=sprintf('parallel -j %g qsirecon %s/qsiprep %s/qsirecon participant --fs-license-file /DPABI/DPABISurf/FreeSurferLicense/license.txt --resource-monitor', Cfg.ParallelWorkersNumber, Cfg.WorkingDir, Cfg.WorkingDir);
        else
            if isempty(Cfg.FreesurferInput)
                Command=sprintf('%s cgyan/qsirecon parallel -j %g qsirecon /data/qsiprep /data/qsirecon participant --fs-license-file /DPABI/DPABISurf/FreeSurferLicense/license.txt --resource-monitor', CommandInit, Cfg.ParallelWorkersNumber );
            else
                Command=sprintf('%s -v %s:/FreesurferInput cgyan/qsirecon parallel -j %g qsirecon /data/qsiprep /data/qsirecon participant --fs-license-file /DPABI/DPABISurf/FreeSurferLicense/license.txt --resource-monitor', CommandInit, Cfg.FreesurferInput, Cfg.ParallelWorkersNumber );
            end
        end
        
        if Cfg.ParallelWorkersNumber~=0
            Command = sprintf('%s --nthreads 1 --omp-nthreads 1', Command);
        end
        
        %Command = sprintf('%s --output-resolution %g', Command, Cfg.OutputResolution);

        if ~isempty(Cfg.FreesurferInput)
            Cfg.FreeSurferSubjectID = local_prepare_qsirecon_freesurfer_aliases(Cfg.FreesurferInput, Cfg.SubjectID);

            % Make FreeSurfer subject IDs consistent with BIDS participant labels for qsirecon.
            for i=1:Cfg.SubjectNum
                LeftPialT1 = fullfile(Cfg.FreesurferInput, Cfg.SubjectID{i}, 'surf', 'lh.pial.T1');
                LeftPial = fullfile(Cfg.FreesurferInput, Cfg.SubjectID{i}, 'surf', 'lh.pial');
                RightPialT1 = fullfile(Cfg.FreesurferInput, Cfg.SubjectID{i}, 'surf', 'rh.pial.T1');
                RightPial = fullfile(Cfg.FreesurferInput, Cfg.SubjectID{i}, 'surf', 'rh.pial');
                if exist(LeftPialT1,'file') && ~exist(LeftPial,'file')
                    copyfile(LeftPialT1, LeftPial);
                end
                if exist(RightPialT1,'file') && ~exist(RightPial,'file')
                    copyfile(RightPialT1, RightPial);
                end
            end

            if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
                Command=sprintf('%s --fs-subjects-dir %s', Command, Cfg.FreesurferInput);
            else
                Command=sprintf('%s --fs-subjects-dir /FreesurferInput', Command);
            end
        end

        if ~isempty(Cfg.ReconSpec) || ~strcmpi(Cfg.ReconSpec,'none')
            if ~strcmpi(Cfg.ReconSpec,'Custom') % if not {WorkingDir}/Custom.yaml
                copyfile([DPABIPath,filesep,'DPABIFiber',filesep,'qsiprep_recon_workflows',filesep,Cfg.ReconSpec,'.yaml'],Cfg.WorkingDir);
            end
            if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
                Command=sprintf('%s --recon-spec %s/%s.yaml', Command, Cfg.WorkingDir, Cfg.ReconSpec);
            else
                Command=sprintf('%s --recon-spec /data/%s.yaml', Command, Cfg.ReconSpec);
            end
        end

        if Cfg.IsLowMem==1
            Command = sprintf('%s --low-mem', Command);
        end
        
        Command = sprintf('%s -w /data/qsireconwork/{1}', Command); %Specify the working dir for qsiprep
        Command = sprintf('%s  --participant-label {1} ::: %s', Command, SubjectIDString);
        
        fprintf('Reconstructing with qsirecon, this process is very time consuming, please be patient...\n');
        
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

            [RefFile, TransformFile] = local_resolve_qsiprep_mni_to_acpc_files(Cfg.WorkingDir, Cfg.SubjectID{i});
            [RefData,RefVox,RefHeader]=y_ReadRPI(RefFile,1);
            
            Interpolation='MultiLabel';
            Dimensionality=3;
            InputImageType=0;
            DefaultValue=0;
            IsFloat0=0;
            DockerName='cgyan/qsiprep';

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


%Get QsireconDerivativesDirSpecific
Dir=dir(fullfile(Cfg.WorkingDir,'qsirecon','derivatives'));
if length(Dir)>=3
    if Dir(3).isdir
        QsireconDerivativesDirSpecific=Dir(3).name;
    else
        QsireconDerivativesDirSpecific=Dir(4).name;
    end
else
    QsireconDerivativesDirSpecific='';
end


%Gunzip .tck.gz files
if exist(fullfile(Cfg.WorkingDir,'qsirecon','derivatives',QsireconDerivativesDirSpecific,Cfg.SubjectID{1},'dwi',[Cfg.SubjectID{1},'_space-ACPC_model-ifod2_streamlines.tck.gz']))
    Command = sprintf('%s gunzip %s/qsirecon/derivatives/%s/{1}/dwi/{1}_space-ACPC_model-ifod2_streamlines.tck.gz', CommandParallel,WorkingDir,QsireconDerivativesDirSpecific);
    Command = sprintf('%s ::: %s', Command, SubjectIDString);
    fprintf('Gunzip .tck.gz files, please wait...\n');
    system(Command);
elseif exist(fullfile(Cfg.WorkingDir,'qsirecon','derivatives',QsireconDerivativesDirSpecific,Cfg.SubjectID{1},'ses-1','dwi',[Cfg.SubjectID{1},'_ses-1_space-ACPC_model-ifod2_streamlines.tck.gz']))
    Command = sprintf('%s gunzip %s/qsirecon/derivatives/%s/{1}/ses-1/dwi/{1}_ses-1_space-ACPC_model-ifod2_streamlines.tck.gz', CommandParallel,WorkingDir,QsireconDerivativesDirSpecific);
    Command = sprintf('%s ::: %s', Command, SubjectIDString);
    fprintf('Gunzip .tck.gz files, please wait...\n');
    system(Command);
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

    if NeedWeightedImageT1wToACPC && isempty(ACPCReferenceFileSet)
        ACPCReferenceFileSet = local_ensure_fmriprep_t1_to_qsiprep_acpc_transform(Cfg, CommandInit, WorkingDir);
    end


    mkdir([Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'StructuralConnectomeMatrix']);
    copyfile([Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForDwi',filesep,'Masks_DwiSpace_Merged',filesep,'ROI_OrderKey_',Cfg.SubjectID{i},'.tsv'],[Cfg.WorkingDir,filesep,'Results',filesep,'DwiVolu',filesep,'StructuralConnectomeMatrix']);


    if Cfg.StructuralConnectomeMatrix.WeightedByFA
        %Mean FA per Streamline
        
        RefFile=fullfile(Cfg.WorkingDir,'qsirecon','derivatives',QsireconDerivativesDirSpecific,Cfg.SubjectID{1},'dwi',[Cfg.SubjectID{1},'_space-ACPC_model-ifod2_streamlines.tck']);
        if (2==exist(RefFile,'file'))
            Command = sprintf('%s tcksample %s/qsirecon/derivatives/%s/{1}/dwi/{1}_space-ACPC_model-ifod2_streamlines.tck %s/Results/DwiVolu/TensorMetrics/FA/{1}_space-ACPC_desc-preproc_dwitensor_metrics.nii.gz %s/Results/DwiVolu/StructuralConnectomeMatrix/MeanFAPerStreamline_{1}.csv -stat_tck mean -quiet', CommandParallel,WorkingDir,QsireconDerivativesDirSpecific,WorkingDir,WorkingDir);
        else
            Command = sprintf('%s tcksample %s/qsirecon/derivatives/%s/{1}/ses-1/dwi/{1}_ses-1_space-ACPC_model-ifod2_streamlines.tck %s/Results/DwiVolu/TensorMetrics/FA/{1}_space-ACPC_desc-preproc_dwitensor_metrics.nii.gz %s/Results/DwiVolu/StructuralConnectomeMatrix/MeanFAPerStreamline_{1}.csv -stat_tck mean -quiet', CommandParallel,WorkingDir,QsireconDerivativesDirSpecific,WorkingDir,WorkingDir);
        end
        
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

        if NeedWeightedImageT1wToACPC
            [ImageFile, MountPath, WithinFile] = local_transform_weighted_image_to_acpc(Cfg, ImageFile, MountPath, WithinFile, CommandInit, CommandParallelQsiprep, WorkingDir, ACPCReferenceFileSet);
        end


        RefFile=fullfile(Cfg.WorkingDir,'qsirecon','derivatives',QsireconDerivativesDirSpecific,Cfg.SubjectID{1},'dwi',[Cfg.SubjectID{1},'_space-ACPC_model-ifod2_streamlines.tck']);
        if (2==exist(RefFile,'file'))
            if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
                Command=sprintf('parallel -j %g tcksample %s/qsirecon/derivatives/%s/{1}/dwi/{1}_space-ACPC_model-ifod2_streamlines.tck %s %s/Results/DwiVolu/StructuralConnectomeMatrix/WeightedImagePerStreamline_{1}.csv -stat_tck %s -quiet', ...
                    Cfg.ParallelWorkersNumber, WorkingDir,QsireconDerivativesDirSpecific,ImageFile,WorkingDir,Cfg.StructuralConnectomeMatrix.WeightedByImage.StatTck);
            else
                Command=sprintf('%s -v %s:/MountPath cgyan/dpabifiber parallel -j %g tcksample %s/qsirecon/derivatives/%s/{1}/dwi/{1}_space-ACPC_model-ifod2_streamlines.tck /MountPath/%s %s/Results/DwiVolu/StructuralConnectomeMatrix/WeightedImagePerStreamline_{1}.csv -stat_tck %s -quiet', ...
                    CommandInit, MountPath, Cfg.ParallelWorkersNumber, WorkingDir,QsireconDerivativesDirSpecific,WithinFile,WorkingDir,Cfg.StructuralConnectomeMatrix.WeightedByImage.StatTck);
            end
        else
            if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
                Command=sprintf('parallel -j %g tcksample %s/qsirecon/derivatives/%s/{1}/ses-1/dwi/{1}_ses-1_space-ACPC_model-ifod2_streamlines.tck %s %s/Results/DwiVolu/StructuralConnectomeMatrix/WeightedImagePerStreamline_{1}.csv -stat_tck %s -quiet', ...
                    Cfg.ParallelWorkersNumber, WorkingDir,QsireconDerivativesDirSpecific,ImageFile,WorkingDir,Cfg.StructuralConnectomeMatrix.WeightedByImage.StatTck);
            else
                Command=sprintf('%s -v %s:/MountPath cgyan/dpabifiber parallel -j %g tcksample %s/qsirecon/derivatives/%s/{1}/ses-1/dwi/{1}_ses-1_space-ACPC_model-ifod2_streamlines.tck /MountPath/%s %s/Results/DwiVolu/StructuralConnectomeMatrix/WeightedImagePerStreamline_{1}.csv -stat_tck %s -quiet', ...
                    CommandInit, MountPath, Cfg.ParallelWorkersNumber, WorkingDir,QsireconDerivativesDirSpecific,WithinFile,WorkingDir,Cfg.StructuralConnectomeMatrix.WeightedByImage.StatTck);
            end
            
        end
        
        
        if Cfg.ParallelWorkersNumber~=0
            Command = sprintf('%s -nthreads 1', Command);
        end
        Command = sprintf('%s -force ::: %s', Command, SubjectIDString);
        fprintf('Weighted Image per Streamline Calculating, please wait...\n');
        system(Command);
    end
    

    %tck2connectome -tck_weights_in /data/Dev/conn/conntest/sub-ASDSHIKEYU20191215_space-ACPC_model-sift2_streamlineweights.csv -nthreads 1 -out_assignments /data/Dev/conn/conntest/assignmentsnii.txt -quiet -assignment_radial_search 2.000000 -stat_edge sum -symmetric /data/Dev/conn/conntest/sub-ASDSHIKEYU20191215_space-ACPC_model-ifod2_streamlines.tck /data/Dev/conn/conntest/My400.nii /data/Dev/conn/conntest/My400nii_Connectome.csv
    
    
    RefFile=fullfile(Cfg.WorkingDir,'qsirecon','derivatives',QsireconDerivativesDirSpecific,Cfg.SubjectID{1},'dwi',[Cfg.SubjectID{1},'_space-ACPC_model-ifod2_streamlines.tck']);
    if (2==exist(RefFile,'file'))
        Command = sprintf('%s tck2connectome %s/qsirecon/derivatives/%s/{1}/dwi/{1}_space-ACPC_model-ifod2_streamlines.tck %s/Masks/MasksForDwi/Masks_DwiSpace_Merged/MergedMask_{1}.nii %s/Results/DwiVolu/StructuralConnectomeMatrix/CSV_StructuralConnectome_{1}.csv -out_assignments %s/Results/DwiVolu/StructuralConnectomeMatrix/Assignments_{1}.txt -quiet', CommandParallel,WorkingDir,QsireconDerivativesDirSpecific,WorkingDir,WorkingDir,WorkingDir);
    else
        Command = sprintf('%s tck2connectome %s/qsirecon/derivatives/%s/{1}/ses-1/dwi/{1}_ses-1_space-ACPC_model-ifod2_streamlines.tck %s/Masks/MasksForDwi/Masks_DwiSpace_Merged/MergedMask_{1}.nii %s/Results/DwiVolu/StructuralConnectomeMatrix/CSV_StructuralConnectome_{1}.csv -out_assignments %s/Results/DwiVolu/StructuralConnectomeMatrix/Assignments_{1}.txt -quiet', CommandParallel,WorkingDir,QsireconDerivativesDirSpecific,WorkingDir,WorkingDir,WorkingDir);
    end
    
    if Cfg.ParallelWorkersNumber~=0
        Command = sprintf('%s -nthreads 1', Command);
    end

    Command = sprintf('%s -assignment_radial_search %g', Command,Cfg.StructuralConnectomeMatrix.AssignmentRadialSearch);
    Command = sprintf('%s -stat_edge %s', Command,Cfg.StructuralConnectomeMatrix.StatEdge);
    if Cfg.StructuralConnectomeMatrix.Symmetric
        Command = sprintf('%s -symmetric', Command);
    end

    if Cfg.StructuralConnectomeMatrix.UseSiftWeights
        
        RefFile=fullfile(Cfg.WorkingDir,'qsirecon','derivatives',QsireconDerivativesDirSpecific,Cfg.SubjectID{1},'dwi',[Cfg.SubjectID{1},'_space-ACPC_model-ifod2_streamlines.tck']);
        if (2==exist(RefFile,'file'))
            Command = sprintf('%s -tck_weights_in %s/qsirecon/derivatives/%s/{1}/dwi/{1}_space-ACPC_model-sift2_streamlineweights.csv', Command,WorkingDir,QsireconDerivativesDirSpecific);
        else
            Command = sprintf('%s -tck_weights_in %s/qsirecon/derivatives/%s/{1}/ses-1/dwi/{1}_ses-1_space-ACPC_model-sift2_streamlineweights.csv', Command,WorkingDir,QsireconDerivativesDirSpecific);
        end
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

    if NeedTWFCT1wToACPC && isempty(ACPCReferenceFileSet)
        ACPCReferenceFileSet = local_ensure_fmriprep_t1_to_qsiprep_acpc_transform(Cfg, CommandInit, WorkingDir);
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
            %tckedit /data/qsirecon/sub-Sub001/dwi/sub-Sub001_space-ACPC_model-ifod2_streamlines.tck /data/Results/DwiVolu/Tracks/Test/RPI.tck -tck_weights_in /data/qsirecon/sub-Sub001/dwi/sub-Sub001_space-ACPC_model-sift2_streamlineweights.csv  -tck_weights_out /data/Results/DwiVolu/Tracks/Test/RPI.csv -include /data/Masks/TestingMasks/MyRPI.nii
            
            RefFile=fullfile(Cfg.WorkingDir,'qsirecon','derivatives',QsireconDerivativesDirSpecific,Cfg.SubjectID{1},'dwi',[Cfg.SubjectID{1},'_space-ACPC_model-ifod2_streamlines.tck']);
            if (2==exist(RefFile,'file'))
                Command = sprintf('%s tckedit %s/qsirecon/derivatives/%s/{1}/dwi/{1}_space-ACPC_model-ifod2_streamlines.tck',CommandParallel,WorkingDir,QsireconDerivativesDirSpecific);
                Command = sprintf('%s %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/ROI_%s_{1}.tck -tck_weights_in %s/qsirecon/derivatives/%s/{1}/dwi/{1}_space-ACPC_model-sift2_streamlineweights.csv  -tck_weights_out %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/ROI_%s_{1}.csv', Command,WorkingDir,num2str(iElement),WorkingDir,QsireconDerivativesDirSpecific,WorkingDir,num2str(iElement));
                Command = sprintf('%s -include %s/Masks/MasksForDwi/Masks_DwiSpace_Split/SplitMask_ROI_%s_{1}.nii', Command,WorkingDir,num2str(iElement));
            else
                Command = sprintf('%s tckedit %s/qsirecon/derivatives/%s/{1}/ses-1/dwi/{1}_ses-1_space-ACPC_model-ifod2_streamlines.tck',CommandParallel,WorkingDir,QsireconDerivativesDirSpecific);
                Command = sprintf('%s %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/ROI_%s_{1}.tck -tck_weights_in %s/qsirecon/derivatives/%s/{1}/ses-1/dwi/{1}_ses-1_space-ACPC_model-sift2_streamlineweights.csv  -tck_weights_out %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/ROI_%s_{1}.csv', Command,WorkingDir,num2str(iElement),WorkingDir,QsireconDerivativesDirSpecific,WorkingDir,num2str(iElement));
                Command = sprintf('%s -include %s/Masks/MasksForDwi/Masks_DwiSpace_Split/SplitMask_ROI_%s_{1}.nii', Command,WorkingDir,num2str(iElement));
            end
            if Cfg.ParallelWorkersNumber~=0
                Command = sprintf('%s -nthreads 1', Command);
            end
            Command = sprintf('%s -force ::: %s', Command, SubjectIDString);
            fprintf('Seed Based Structural Connectivity: Tracks Calculating, please wait...\n');
            system(Command);
            %tckmap /data/Results/DwiVolu/Tracks/Test/RPI.tck /data/Results/DwiVolu/Tracks/Test/RPI.nii -tck_weights_in /data/Results/DwiVolu/Tracks/Test/RPI.csv -template /data/qsiprep/sub-Sub001/dwi/sub-Sub001_space-ACPC_desc-preproc_dwi.nii.gz
            
            RefFile=fullfile(Cfg.WorkingDir,'qsirecon','derivatives',QsireconDerivativesDirSpecific,Cfg.SubjectID{1},'dwi',[Cfg.SubjectID{1},'_space-ACPC_model-ifod2_streamlines.tck']);
            if (2==exist(RefFile,'file'))
                Command = sprintf('%s tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/ROI_%s_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTDIMap/ROI_%s_{1}_TDIMap.nii -tck_weights_in %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/ROI_%s_{1}.csv -template %s/qsiprep/{1}/dwi/{1}_space-ACPC_desc-preproc_dwi.nii.gz',CommandParallel,WorkingDir,num2str(iElement),WorkingDir,num2str(iElement),WorkingDir,num2str(iElement),WorkingDir);
            else
                Command = sprintf('%s tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/ROI_%s_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTDIMap/ROI_%s_{1}_TDIMap.nii -tck_weights_in %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/ROI_%s_{1}.csv -template %s/qsiprep/{1}/ses-1/dwi/{1}_ses-1_space-ACPC_desc-preproc_dwi.nii.gz',CommandParallel,WorkingDir,num2str(iElement),WorkingDir,num2str(iElement),WorkingDir,num2str(iElement),WorkingDir);
            end
            
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

                if NeedTWFCT1wToACPC
                    [FCFile, MountPath, WithinFile] = local_transform_twfc_fcfile_to_acpc(Cfg, FCFile, MountPath, WithinFile, iElement, 1, CommandInit, CommandParallelQsiprep, WorkingDir, ACPCReferenceFileSet);
                end

                %tckmap tracks.tck temp.mif <-template / -vox options> -contrast scalar_map -image FC_map.mif -stat_vox mean -stat_tck sum

                RefFile=fullfile(Cfg.WorkingDir,'qsirecon','derivatives',QsireconDerivativesDirSpecific,Cfg.SubjectID{1},'dwi',[Cfg.SubjectID{1},'_space-ACPC_model-ifod2_streamlines.tck']);
                if (2==exist(RefFile,'file'))
                    
                    if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
                        Command=sprintf('parallel -j %g tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/ROI_%s_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTWFCMap/ROI_%s_{1}_TWFCMap_Unthresholded.nii -template %s/qsiprep/{1}/dwi/{1}_space-ACPC_desc-preproc_dwi.nii.gz -contrast scalar_map -image %s -stat_vox %s -stat_tck %s', ...
                            Cfg.ParallelWorkersNumber, WorkingDir,num2str(iElement),WorkingDir,num2str(iElement),WorkingDir,FCFile,Cfg.SeedBasedStructuralConnectivity.TWFC.StatVox,Cfg.SeedBasedStructuralConnectivity.TWFC.StatTck);
                    else
                        Command=sprintf('%s -v %s:/MountPath cgyan/dpabifiber parallel -j %g tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/ROI_%s_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTWFCMap/ROI_%s_{1}_TWFCMap_Unthresholded.nii -template %s/qsiprep/{1}/dwi/{1}_space-ACPC_desc-preproc_dwi.nii.gz -contrast scalar_map -image /MountPath/%s -stat_vox %s -stat_tck %s', ...
                            CommandInit, MountPath, Cfg.ParallelWorkersNumber, WorkingDir,num2str(iElement),WorkingDir,num2str(iElement),WorkingDir,WithinFile,Cfg.SeedBasedStructuralConnectivity.TWFC.StatVox,Cfg.SeedBasedStructuralConnectivity.TWFC.StatTck);
                    end
                    
                else
                    if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
                        Command=sprintf('parallel -j %g tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/ROI_%s_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTWFCMap/ROI_%s_{1}_TWFCMap_Unthresholded.nii -template %s/qsiprep/{1}/ses-1/dwi/{1}_ses-1_space-ACPC_desc-preproc_dwi.nii.gz -contrast scalar_map -image %s -stat_vox %s -stat_tck %s', ...
                            Cfg.ParallelWorkersNumber, WorkingDir,num2str(iElement),WorkingDir,num2str(iElement),WorkingDir,FCFile,Cfg.SeedBasedStructuralConnectivity.TWFC.StatVox,Cfg.SeedBasedStructuralConnectivity.TWFC.StatTck);
                    else
                        Command=sprintf('%s -v %s:/MountPath cgyan/dpabifiber parallel -j %g tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/ROI_%s_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTWFCMap/ROI_%s_{1}_TWFCMap_Unthresholded.nii -template %s/qsiprep/{1}/ses-1/dwi/{1}_ses-1_space-ACPC_desc-preproc_dwi.nii.gz -contrast scalar_map -image /MountPath/%s -stat_vox %s -stat_tck %s', ...
                            CommandInit, MountPath, Cfg.ParallelWorkersNumber, WorkingDir,num2str(iElement),WorkingDir,num2str(iElement),WorkingDir,WithinFile,Cfg.SeedBasedStructuralConnectivity.TWFC.StatVox,Cfg.SeedBasedStructuralConnectivity.TWFC.StatTck);
                    end
                end
                
                if Cfg.ParallelWorkersNumber~=0
                    Command = sprintf('%s -nthreads 1', Command);
                end
                Command = sprintf('%s -force ::: %s', Command, SubjectIDString);
                fprintf('Seed Based Structural Connectivity: TWFC Map Calculating, please wait...\n');
                system(Command);


                %tckmap tracks.tck - -template temp.mif -contrast scalar_map_count -image FC_map.mif |... mrcalc - 5 -ge mask.mif -datatype bit
                
                
                RefFile=fullfile(Cfg.WorkingDir,'qsirecon','derivatives',QsireconDerivativesDirSpecific,Cfg.SubjectID{1},'dwi',[Cfg.SubjectID{1},'_space-ACPC_model-ifod2_streamlines.tck']);
                if (2==exist(RefFile,'file'))
                    if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
                        Command=sprintf('parallel -j %g tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/ROI_%s_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTWFCMap/ROI_%s_{1}_TWFCMap_StreamlineCount.nii -template %s/qsiprep/{1}/dwi/{1}_space-ACPC_desc-preproc_dwi.nii.gz -contrast scalar_map_count -image %s', ...
                            Cfg.ParallelWorkersNumber, WorkingDir,num2str(iElement),WorkingDir,num2str(iElement),WorkingDir,FCFile);
                    else
                        Command=sprintf('%s -v %s:/MountPath cgyan/dpabifiber parallel -j %g tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/ROI_%s_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTWFCMap/ROI_%s_{1}_TWFCMap_StreamlineCount.nii -template %s/qsiprep/{1}/dwi/{1}_space-ACPC_desc-preproc_dwi.nii.gz -contrast scalar_map_count -image /MountPath/%s', ...
                            CommandInit, MountPath, Cfg.ParallelWorkersNumber, WorkingDir,num2str(iElement),WorkingDir,num2str(iElement),WorkingDir,WithinFile);
                    end
                else
                    if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
                        Command=sprintf('parallel -j %g tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/ROI_%s_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTWFCMap/ROI_%s_{1}_TWFCMap_StreamlineCount.nii -template %s/qsiprep/{1}/ses-1/dwi/{1}_ses-1_space-ACPC_desc-preproc_dwi.nii.gz -contrast scalar_map_count -image %s', ...
                            Cfg.ParallelWorkersNumber, WorkingDir,num2str(iElement),WorkingDir,num2str(iElement),WorkingDir,FCFile);
                    else
                        Command=sprintf('%s -v %s:/MountPath cgyan/dpabifiber parallel -j %g tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/ROI_%s_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTWFCMap/ROI_%s_{1}_TWFCMap_StreamlineCount.nii -template %s/qsiprep/{1}/ses-1/dwi/{1}_ses-1_space-ACPC_desc-preproc_dwi.nii.gz -contrast scalar_map_count -image /MountPath/%s', ...
                            CommandInit, MountPath, Cfg.ParallelWorkersNumber, WorkingDir,num2str(iElement),WorkingDir,num2str(iElement),WorkingDir,WithinFile);
                    end
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
        
        
        %tckedit /data/qsirecon/sub-Sub001/dwi/sub-Sub001_space-ACPC_model-ifod2_streamlines.tck /data/Results/DwiVolu/Tracks/Test/RPI.tck -tck_weights_in /data/qsirecon/sub-Sub001/dwi/sub-Sub001_space-ACPC_model-sift2_streamlineweights.csv  -tck_weights_out /data/Results/DwiVolu/Tracks/Test/RPI.csv -include /data/Masks/TestingMasks/MyRPI.nii
       
            RefFile=fullfile(Cfg.WorkingDir,'qsirecon','derivatives',QsireconDerivativesDirSpecific,Cfg.SubjectID{1},'dwi',[Cfg.SubjectID{1},'_space-ACPC_model-ifod2_streamlines.tck']);
            if (2==exist(RefFile,'file'))
                
                Command = sprintf('%s tckedit %s/qsirecon/derivatives/%s/{1}/dwi/{1}_space-ACPC_model-ifod2_streamlines.tck',CommandParallel,WorkingDir,QsireconDerivativesDirSpecific);
                Command = sprintf('%s %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/AllROITraverse_{1}.tck -tck_weights_in %s/qsirecon/derivatives/%s/{1}/dwi/{1}_space-ACPC_model-sift2_streamlineweights.csv  -tck_weights_out %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/AllROITraverse_{1}.csv', Command,WorkingDir,WorkingDir,QsireconDerivativesDirSpecific,WorkingDir);
                for iElement=1:MaxElement
                    Command = sprintf('%s -include %s/Masks/MasksForDwi/Masks_DwiSpace_Split/SplitMask_ROI_%s_{1}.nii', Command,WorkingDir,num2str(iElement));
                end
                if Cfg.ParallelWorkersNumber~=0
                    Command = sprintf('%s -nthreads 1', Command);
                end
                Command = sprintf('%s -force ::: %s', Command, SubjectIDString);
                fprintf('Seed Based Structural Connectivity: Tracks Calculating, please wait...\n');
                system(Command);
                %tckmap /data/Results/DwiVolu/Tracks/Test/RPI.tck /data/Results/DwiVolu/Tracks/Test/RPI.nii -tck_weights_in /data/Results/DwiVolu/Tracks/Test/RPI.csv -template /data/qsiprep/sub-Sub001/dwi/sub-Sub001_space-ACPC_desc-preproc_dwi.nii.gz
                Command = sprintf('%s tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/AllROITraverse_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTDIMap/AllROITraverse_{1}_TDIMap.nii -tck_weights_in %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/AllROITraverse_{1}.csv -template %s/qsiprep/{1}/dwi/{1}_space-ACPC_desc-preproc_dwi.nii.gz',CommandParallel,WorkingDir,WorkingDir,WorkingDir,WorkingDir);
                
                
            else
                Command = sprintf('%s tckedit %s/qsirecon/derivatives/%s/{1}/ses-1/dwi/{1}_ses-1_space-ACPC_model-ifod2_streamlines.tck',CommandParallel,WorkingDir,QsireconDerivativesDirSpecific);
                Command = sprintf('%s %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/AllROITraverse_{1}.tck -tck_weights_in %s/qsirecon/derivatives/%s/{1}/ses-1/dwi/{1}_ses-1_space-ACPC_model-sift2_streamlineweights.csv  -tck_weights_out %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/AllROITraverse_{1}.csv', Command,WorkingDir,WorkingDir,QsireconDerivativesDirSpecific,WorkingDir);
                for iElement=1:MaxElement
                    Command = sprintf('%s -include %s/Masks/MasksForDwi/Masks_DwiSpace_Split/SplitMask_ROI_%s_{1}.nii', Command,WorkingDir,num2str(iElement));
                end
                if Cfg.ParallelWorkersNumber~=0
                    Command = sprintf('%s -nthreads 1', Command);
                end
                Command = sprintf('%s -force ::: %s', Command, SubjectIDString);
                fprintf('Seed Based Structural Connectivity: Tracks Calculating, please wait...\n');
                system(Command);
                %tckmap /data/Results/DwiVolu/Tracks/Test/RPI.tck /data/Results/DwiVolu/Tracks/Test/RPI.nii -tck_weights_in /data/Results/DwiVolu/Tracks/Test/RPI.csv -template /data/qsiprep/sub-Sub001/dwi/sub-Sub001_space-ACPC_desc-preproc_dwi.nii.gz
                Command = sprintf('%s tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/AllROITraverse_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTDIMap/AllROITraverse_{1}_TDIMap.nii -tck_weights_in %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/AllROITraverse_{1}.csv -template %s/qsiprep/{1}/ses-1/dwi/{1}_ses-1_space-ACPC_desc-preproc_dwi.nii.gz',CommandParallel,WorkingDir,WorkingDir,WorkingDir,WorkingDir);
                
            end
        
        
        
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

            if NeedTWFCT1wToACPC
                [FCFile, MountPath, WithinFile] = local_transform_twfc_fcfile_to_acpc(Cfg, FCFile, MountPath, WithinFile, [], 0, CommandInit, CommandParallelQsiprep, WorkingDir, ACPCReferenceFileSet);
            end

            RefFile=fullfile(Cfg.WorkingDir,'qsirecon','derivatives',QsireconDerivativesDirSpecific,Cfg.SubjectID{1},'dwi',[Cfg.SubjectID{1},'_space-ACPC_model-ifod2_streamlines.tck']);
            if (2==exist(RefFile,'file'))
                
                %tckmap tracks.tck temp.mif <-template / -vox options> -contrast scalar_map -image FC_map.mif -stat_vox mean -stat_tck sum
                if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
                    Command=sprintf('parallel -j %g tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/AllROITraverse_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTWFCMap/AllROITraverse_{1}_TWFCMap_Unthresholded.nii -template %s/qsiprep/{1}/dwi/{1}_space-ACPC_desc-preproc_dwi.nii.gz -contrast scalar_map -image %s -stat_vox %s -stat_tck %s', ...
                        Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,WorkingDir,FCFile,Cfg.SeedBasedStructuralConnectivity.TWFC.StatVox,Cfg.SeedBasedStructuralConnectivity.TWFC.StatTck);
                else
                    Command=sprintf('%s -v %s:/MountPath cgyan/dpabifiber parallel -j %g tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/AllROITraverse_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTWFCMap/AllROITraverse_{1}_TWFCMap_Unthresholded.nii -template %s/qsiprep/{1}/dwi/{1}_space-ACPC_desc-preproc_dwi.nii.gz -contrast scalar_map -image /MountPath/%s -stat_vox %s -stat_tck %s', ...
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
                    Command=sprintf('parallel -j %g tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/AllROITraverse_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTWFCMap/AllROITraverse_{1}_TWFCMap_StreamlineCount.nii -template %s/qsiprep/{1}/dwi/{1}_space-ACPC_desc-preproc_dwi.nii.gz -contrast scalar_map_count -image %s', ...
                        Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,WorkingDir,FCFile);
                else
                    Command=sprintf('%s -v %s:/MountPath cgyan/dpabifiber parallel -j %g tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/AllROITraverse_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTWFCMap/AllROITraverse_{1}_TWFCMap_StreamlineCount.nii -template %s/qsiprep/{1}/dwi/{1}_space-ACPC_desc-preproc_dwi.nii.gz -contrast scalar_map_count -image /MountPath/%s', ...
                        CommandInit, MountPath, Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,WorkingDir,WithinFile);
                end
                
            else
                
                %tckmap tracks.tck temp.mif <-template / -vox options> -contrast scalar_map -image FC_map.mif -stat_vox mean -stat_tck sum
                if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
                    Command=sprintf('parallel -j %g tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/AllROITraverse_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTWFCMap/AllROITraverse_{1}_TWFCMap_Unthresholded.nii -template %s/qsiprep/{1}/ses-1/dwi/{1}_ses-1_space-ACPC_desc-preproc_dwi.nii.gz -contrast scalar_map -image %s -stat_vox %s -stat_tck %s', ...
                        Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,WorkingDir,FCFile,Cfg.SeedBasedStructuralConnectivity.TWFC.StatVox,Cfg.SeedBasedStructuralConnectivity.TWFC.StatTck);
                else
                    Command=sprintf('%s -v %s:/MountPath cgyan/dpabifiber parallel -j %g tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/AllROITraverse_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTWFCMap/AllROITraverse_{1}_TWFCMap_Unthresholded.nii -template %s/qsiprep/{1}/ses-1/dwi/{1}_ses-1_space-ACPC_desc-preproc_dwi.nii.gz -contrast scalar_map -image /MountPath/%s -stat_vox %s -stat_tck %s', ...
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
                    Command=sprintf('parallel -j %g tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/AllROITraverse_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTWFCMap/AllROITraverse_{1}_TWFCMap_StreamlineCount.nii -template %s/qsiprep/{1}/ses-1/dwi/{1}_ses-1_space-ACPC_desc-preproc_dwi.nii.gz -contrast scalar_map_count -image %s', ...
                        Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,WorkingDir,FCFile);
                else
                    Command=sprintf('%s -v %s:/MountPath cgyan/dpabifiber parallel -j %g tckmap %s/Results/DwiVolu/SeedBasedStructuralConnectivityTrack/AllROITraverse_{1}.tck %s/Results/DwiVolu/SeedBasedStructuralConnectivityTWFCMap/AllROITraverse_{1}_TWFCMap_StreamlineCount.nii -template %s/qsiprep/{1}/ses-1/dwi/{1}_ses-1_space-ACPC_desc-preproc_dwi.nii.gz -contrast scalar_map_count -image /MountPath/%s', ...
                        CommandInit, MountPath, Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,WorkingDir,WithinFile);
                end
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


    fprintf('Normalizing the results...\n');
    for iFunSession=1:Cfg.FunctionalSessionNumber
        ResultsDir = [FunSessionPrefixSet{iFunSession},Cfg.StartingDirName];
        local_normalize_dwi_results(Cfg.WorkingDir, WorkingDir, CommandParallelQsiprep, ...
            Cfg.SubjectID(1:Cfg.SubjectNum), ResultsDir);
    end
    Cfg.StartingDirName = [Cfg.StartingDirName,'W'];
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

end



function local_cleanup_session_aliases_for_qsirecon(DerivativesDir, SubjectIDCell)
if isempty(DerivativesDir) || ~exist(DerivativesDir,'dir')
    return;
end

for iSubject=1:length(SubjectIDCell)
    SubjectDir = fullfile(DerivativesDir, SubjectIDCell{iSubject});
    local_cleanup_session_alias_subdir(SubjectDir, 'anat', SubjectIDCell{iSubject});
    local_cleanup_session_alias_subdir(SubjectDir, 'dwi', SubjectIDCell{iSubject});
end
end



function local_cleanup_session_alias_subdir(SubjectDir, SubdirName, SubjectID)
SubjectSubdir = fullfile(SubjectDir, SubdirName);
SessionDir = fullfile(SubjectDir, 'ses-1');
SessionSubdir = fullfile(SessionDir, SubdirName);
FileSuffixCell = local_get_session_alias_suffixes(SubdirName);

if local_is_symlink_path(SessionSubdir)
    local_remove_symlink_path(SessionSubdir);
end
if local_is_symlink_path(SubjectSubdir)
    local_remove_symlink_path(SubjectSubdir);
end

if exist(SubjectSubdir,'dir') && ~local_is_symlink_path(SubjectSubdir)
    for iSuffix = 1:length(FileSuffixCell)
        AliasFile = fullfile(SubjectSubdir, [SubjectID, '_ses-1', FileSuffixCell{iSuffix}]);
        if local_is_symlink_path(AliasFile)
            local_remove_symlink_path(AliasFile);
        end
    end
end

if exist(SessionSubdir,'dir') && ~local_is_symlink_path(SessionSubdir)
    for iSuffix = 1:length(FileSuffixCell)
        AliasFile = fullfile(SessionSubdir, [SubjectID, FileSuffixCell{iSuffix}]);
        if local_is_symlink_path(AliasFile)
            local_remove_symlink_path(AliasFile);
        end
    end
end

if exist(SessionDir,'dir')
    DirSession = dir(fullfile(SessionDir, '*'));
    DirSessionName = {DirSession.name};
    DirSessionName = setdiff(DirSessionName, {'.','..'});
    if isempty(DirSessionName)
        rmdir(SessionDir);
    end
end
end



function FileSuffixCell = local_get_session_alias_suffixes(SubdirName)
switch lower(SubdirName)
    case 'anat'
        FileSuffixCell = {
            '_desc-preproc_T1w.nii.gz'
            '_space-ACPC_desc-preproc_T1w.nii.gz'
            '_from-MNI152NLin2009cAsym_to-ACPC_mode-image_xfm.h5'
            '_from-ACPC_to-MNI152NLin2009cAsym_mode-image_xfm.h5'
            };
    case 'dwi'
        FileSuffixCell = {
            '_space-ACPC_desc-preproc_dwi.b'
            '_space-ACPC_desc-preproc_dwi.nii.gz'
            '_space-ACPC_desc-brain_mask.nii.gz'
            '_space-ACPC_dwiref.nii.gz'
            };
    otherwise
        FileSuffixCell = {};
end
end



function IsSymlink = local_is_symlink_path(PathName)
IsSymlink = false;

if ~(exist(PathName,'file') || exist(PathName,'dir'))
    return;
end

if ispc
    return;
else
    [Status, ~] = system(sprintf('test -L "%s"', PathName));
    IsSymlink = (Status == 0);
end
end



function local_remove_symlink_path(PathName)
if ~local_is_symlink_path(PathName)
    return;
end

if ispc
    if exist(PathName,'dir')
        [Status, Message] = rmdir(PathName);
        IsFailed = (Status == 0);
    else
        [Status, Message] = system(sprintf('cmd /c del /f /q "%s"', PathName));
        IsFailed = (Status ~= 0);
    end
    if IsFailed
        error('Failed to remove symlink path %s: %s', PathName, Message);
    end
else
    [Status, Output] = system(sprintf('rm -f "%s"', PathName));
    if (Status~=0) && (exist(PathName,'file') || exist(PathName,'dir'))
        error('Failed to remove symlink path %s: %s', PathName, Output);
    end
end
end



function local_prepare_session_anat_aliases(DerivativesDir, SubjectIDCell)
if isempty(DerivativesDir) || ~exist(DerivativesDir,'dir')
    return;
end

for iSubject=1:length(SubjectIDCell)
    SubjectDir = fullfile(DerivativesDir, SubjectIDCell{iSubject});
    SubjectAnatDir = fullfile(SubjectDir, 'anat');
    SessionDir = fullfile(SubjectDir, 'ses-1');
    SessionAnatDir = fullfile(SessionDir, 'anat');

    if exist(SubjectAnatDir,'dir') && ~exist(SessionAnatDir,'dir')
        if ~exist(SessionDir,'dir')
            mkdir(SessionDir);
        end
        local_create_directory_alias(SessionAnatDir, SubjectAnatDir, fullfile('..','anat'));
    elseif ~exist(SubjectAnatDir,'dir') && exist(SessionAnatDir,'dir')
        local_create_directory_alias(SubjectAnatDir, SessionAnatDir, fullfile('ses-1','anat'));
    end

    if exist(SubjectAnatDir,'dir')
        local_prepare_session_anat_file_aliases(SubjectAnatDir, SubjectIDCell{iSubject}, 'ses-1');
    elseif exist(SessionAnatDir,'dir')
        local_prepare_session_anat_file_aliases(SessionAnatDir, SubjectIDCell{iSubject}, 'ses-1');
    end
end
end



function local_prepare_session_anat_file_aliases(AnatDir, SubjectID, SessionLabel)
FileSuffixCell = {
    '_desc-preproc_T1w.nii.gz'
    '_space-ACPC_desc-preproc_T1w.nii.gz'
    '_from-MNI152NLin2009cAsym_to-ACPC_mode-image_xfm.h5'
    '_from-ACPC_to-MNI152NLin2009cAsym_mode-image_xfm.h5'
    };

for iSuffix = 1:length(FileSuffixCell)
    SessionlessFile = fullfile(AnatDir, [SubjectID, FileSuffixCell{iSuffix}]);
    SessionFile = fullfile(AnatDir, [SubjectID, '_', SessionLabel, FileSuffixCell{iSuffix}]);

    if exist(SessionlessFile,'file') && ~exist(SessionFile,'file')
        local_create_file_alias(SessionFile, SessionlessFile, [SubjectID, FileSuffixCell{iSuffix}]);
    elseif ~exist(SessionlessFile,'file') && exist(SessionFile,'file')
        local_create_file_alias(SessionlessFile, SessionFile, [SubjectID, '_', SessionLabel, FileSuffixCell{iSuffix}]);
    end
end
end



function AparcasegSourceFileSet = local_prepare_t1w_aparcaseg_aliases(T1wSpaceDir, SubjectIDCell)
AparcasegSourceFileSet = cell(length(SubjectIDCell),1);

if isempty(T1wSpaceDir) || ~exist(T1wSpaceDir,'dir')
    return;
end

for iSubject=1:length(SubjectIDCell)
    SubjectDir = fullfile(T1wSpaceDir, SubjectIDCell{iSubject});
    if ~exist(SubjectDir,'dir')
        continue;
    end

    TargetFile = fullfile(SubjectDir, [SubjectIDCell{iSubject}, '_space-T1w_desc-aparcaseg.nii.gz']);
    if exist(TargetFile,'file')
        AparcasegSourceFileSet{iSubject} = TargetFile;
        continue;
    end

    CandidateFile = local_resolve_t1w_aparcaseg_source_file(SubjectDir, SubjectIDCell{iSubject});
    if isempty(CandidateFile)
        continue;
    end

    if local_is_nifti_gz_file(CandidateFile)
        local_create_file_alias(TargetFile, CandidateFile, local_basename(CandidateFile));
    elseif local_is_nifti_file(CandidateFile)
        TempTarget = fullfile(SubjectDir, [SubjectIDCell{iSubject}, '_space-T1w_desc-aparcaseg.nii']);
        IsTemporaryCopy = ~strcmpi(CandidateFile, TempTarget);
        if IsTemporaryCopy
            copyfile(CandidateFile, TempTarget);
        end
        gzip(TempTarget, SubjectDir);
        if IsTemporaryCopy
            delete(TempTarget);
        end
    end

    if exist(TargetFile,'file')
        AparcasegSourceFileSet{iSubject} = TargetFile;
    end
end
end



function CandidateFile = local_resolve_t1w_aparcaseg_source_file(SubjectDir, SubjectID)
CandidateFile = '';
CandidateFileSet = {
    fullfile(SubjectDir, [SubjectID, '_space-T1w_desc-aparcaseg.nii.gz'])
    fullfile(SubjectDir, [SubjectID, '_space-T1w_desc-aparcaseg.nii'])
    fullfile(SubjectDir, [SubjectID, '_desc-aparcaseg_dseg.nii.gz'])
    fullfile(SubjectDir, [SubjectID, '_desc-aparcaseg_dseg.nii'])
    fullfile(SubjectDir, [SubjectID, '_ses-1_space-T1w_desc-aparcaseg.nii.gz'])
    fullfile(SubjectDir, [SubjectID, '_ses-1_space-T1w_desc-aparcaseg.nii'])
    fullfile(SubjectDir, [SubjectID, '_ses-1_desc-aparcaseg_dseg.nii.gz'])
    fullfile(SubjectDir, [SubjectID, '_ses-1_desc-aparcaseg_dseg.nii'])
    };
CandidateFile = local_pick_existing_file(CandidateFileSet);
if ~isempty(CandidateFile)
    return;
end

DirFile = dir(fullfile(SubjectDir, [SubjectID, '*desc-aparcaseg*.nii*']));
for iFile = 1:length(DirFile)
    if ~DirFile(iFile).isdir
        CandidateFile = fullfile(SubjectDir, DirFile(iFile).name);
        return;
    end
end
end



function local_prepare_session_dwi_aliases(DerivativesDir, SubjectIDCell)
if isempty(DerivativesDir) || ~exist(DerivativesDir,'dir')
    return;
end

for iSubject=1:length(SubjectIDCell)
    SubjectDir = fullfile(DerivativesDir, SubjectIDCell{iSubject});
    SubjectDwiDir = fullfile(SubjectDir, 'dwi');
    SessionDir = fullfile(SubjectDir, 'ses-1');
    SessionDwiDir = fullfile(SessionDir, 'dwi');

    if exist(SubjectDwiDir,'dir') && ~exist(SessionDwiDir,'dir')
        if ~exist(SessionDir,'dir')
            mkdir(SessionDir);
        end
        local_create_directory_alias(SessionDwiDir, SubjectDwiDir, fullfile('..','dwi'));
    elseif ~exist(SubjectDwiDir,'dir') && exist(SessionDwiDir,'dir')
        local_create_directory_alias(SubjectDwiDir, SessionDwiDir, fullfile('ses-1','dwi'));
    end

    if exist(SubjectDwiDir,'dir')
        local_prepare_session_dwi_file_aliases(SubjectDwiDir, SubjectIDCell{iSubject}, 'ses-1');
    elseif exist(SessionDwiDir,'dir')
        local_prepare_session_dwi_file_aliases(SessionDwiDir, SubjectIDCell{iSubject}, 'ses-1');
    end
end
end



function local_prepare_session_dwi_file_aliases(DwiDir, SubjectID, SessionLabel)
FileSuffixCell = {
    '_space-ACPC_desc-preproc_dwi.b'
    '_space-ACPC_desc-preproc_dwi.nii.gz'
    '_space-ACPC_desc-brain_mask.nii.gz'
    '_space-ACPC_dwiref.nii.gz'
    };

for iSuffix = 1:length(FileSuffixCell)
    SessionlessFile = fullfile(DwiDir, [SubjectID, FileSuffixCell{iSuffix}]);
    SessionFile = fullfile(DwiDir, [SubjectID, '_', SessionLabel, FileSuffixCell{iSuffix}]);

    if exist(SessionlessFile,'file') && ~exist(SessionFile,'file')
        local_create_file_alias(SessionFile, SessionlessFile, [SubjectID, FileSuffixCell{iSuffix}]);
    elseif ~exist(SessionlessFile,'file') && exist(SessionFile,'file')
        local_create_file_alias(SessionlessFile, SessionFile, [SubjectID, '_', SessionLabel, FileSuffixCell{iSuffix}]);
    end
end
end



function NeedTransform = local_need_twfc_fcfile_to_acpc(Cfg)
NeedTransform = 0;

if ~isfield(Cfg,'SeedBasedStructuralConnectivity') || ~isfield(Cfg.SeedBasedStructuralConnectivity,'TWFC')
    return;
end

TWFC = Cfg.SeedBasedStructuralConnectivity.TWFC;
if ~isfield(TWFC,'Is') || isempty(TWFC.Is) || (TWFC.Is~=1)
    return;
end

if isfield(TWFC,'FCFileSpace')
    NeedTransform = local_is_t1w_space_to_acpc(TWFC.FCFileSpace);
else
    NeedTransform = local_is_t1w_space_to_acpc('T1w');
end
end



function NeedTransform = local_need_weighted_image_to_acpc(Cfg)
NeedTransform = 0;

if ~isfield(Cfg,'StructuralConnectomeMatrix') || ~isfield(Cfg.StructuralConnectomeMatrix,'WeightedByImage')
    return;
end

WeightedByImage = Cfg.StructuralConnectomeMatrix.WeightedByImage;
if ~isfield(WeightedByImage,'Is') || isempty(WeightedByImage.Is) || (WeightedByImage.Is~=1)
    return;
end

if isfield(WeightedByImage,'ImageFileSpace')
    NeedTransform = local_is_t1w_space_to_acpc(WeightedByImage.ImageFileSpace);
else
    NeedTransform = local_is_t1w_space_to_acpc('T1w');
end
end



function NeedTransform = local_is_t1w_space_to_acpc(ImageSpace)
NeedTransform = 0;

if isempty(ImageSpace)
    ImageSpace = 'T1w';
end

if iscell(ImageSpace)
    ImageSpace = ImageSpace{1};
end

if isnumeric(ImageSpace) || islogical(ImageSpace)
    NeedTransform = any(logical(ImageSpace(:)));
    return;
end

ImageSpace = lower(strtrim(ImageSpace));
NeedTransform = any(strcmp(ImageSpace, {'t1w','anat','anatomical','fmriprept1','fmriprept1w','fmriprep-t1','fmriprep-t1w','space-t1w'}));
end



function ACPCReferenceFileSet = local_ensure_fmriprep_t1_to_qsiprep_acpc_transform(Cfg, CommandInit, ContainerWorkingDir)
SubjectIDCell = Cfg.SubjectID(:);
TransformPrefix = local_t1w_to_acpc_transform_prefix();
TransformFileSet = local_expand_parallel_subject_file_template( ...
    fullfile(Cfg.WorkingDir, [TransformPrefix,'0GenericAffine.mat']), SubjectIDCell);
HasTransform = cellfun(@(FileName) 2==exist(FileName,'file'), TransformFileSet);

ACPCReferenceFileSet = cell(size(SubjectIDCell));
MovingFileSet = cell(size(SubjectIDCell));

for iSubject = 1:numel(SubjectIDCell)
    SubjectID = SubjectIDCell{iSubject};
    DwiSessions = local_get_qsiprep_dwi_sessions(Cfg.WorkingDir, SubjectID);

    [FixedFile, ACPCSession] = local_resolve_anat_derivative(Cfg.WorkingDir, 'qsiprep', SubjectID, ...
        '_space-ACPC_desc-preproc_T1w.nii.gz', DwiSessions);
    ACPCReferenceFileSet{iSubject} = [ContainerWorkingDir,'/',FixedFile];

    if ~HasTransform(iSubject)
        MovingFile = local_resolve_anat_derivative(Cfg.WorkingDir, 'fmriprep', SubjectID, ...
            '_desc-preproc_T1w.nii.gz', {ACPCSession});
        MovingFileSet{iSubject} = [ContainerWorkingDir,'/',MovingFile];
    end
end

if all(HasTransform)
    return;
end

MissingSubjects = SubjectIDCell(~HasTransform);
for iSubject = 1:numel(MissingSubjects)
    SubjectOutputDir = fullfile(Cfg.WorkingDir, 'Results', 'AnatVolu', 'T1wSpace', MissingSubjects{iSubject});
    if ~exist(SubjectOutputDir,'dir')
        mkdir(SubjectOutputDir);
    end
end
OutputPrefixSet = local_expand_parallel_subject_file_template([ContainerWorkingDir,'/',TransformPrefix], MissingSubjects);
JobFiles = [ACPCReferenceFileSet(~HasTransform), MovingFileSet(~HasTransform), OutputPrefixSet];

if isdeployed && isunix && ~ismac
    CommandParallel = 'parallel -j 1';
else
    CommandParallel = sprintf('%s cgyan/qsiprep parallel -j 1', CommandInit);
end
fprintf('Calculate T1 -> ACPC, please wait...\n');
local_run_ants_jobs(Cfg.WorkingDir, ContainerWorkingDir, CommandParallel, ...
    'antsRegistrationSyNQuick.sh -d 3 -f {1} -m {2} -t a -o {3}', JobFiles, 'T1w to ACPC registration');
local_require_ants_outputs(TransformFileSet, 'T1w to ACPC registration');
end



function DwiSessions = local_get_qsiprep_dwi_sessions(WorkingDir, SubjectID)
QsiprepSubjectDir = fullfile(WorkingDir, 'qsiprep', SubjectID);
DwiFiles = dir(fullfile(QsiprepSubjectDir, 'ses-*', 'dwi', ...
    [SubjectID,'_ses-*_space-ACPC_desc-preproc_dwi.nii.gz']));
DwiSessions = cellfun(@(FileName) local_get_session_label_from_bids_file(FileName, SubjectID), ...
    {DwiFiles(~[DwiFiles.isdir]).name}, 'UniformOutput', false);
DwiSessions = unique(DwiSessions(~cellfun(@isempty, DwiSessions)));
end



function [RelativeFile, SessionLabel] = local_resolve_anat_derivative(WorkingDir, DerivativeName, SubjectID, FileSuffix, RequiredSessions)
SubjectPath = [DerivativeName,'/',SubjectID];
SubjectAnat = [SubjectPath,'/anat/'];
RelativeFile = [SubjectAnat,SubjectID,FileSuffix];
SessionLabel = '';
if 2==exist(fullfile(WorkingDir, RelativeFile),'file')
    return;
end

SessionDirs = dir(fullfile(WorkingDir, SubjectPath, 'ses-*'));
SessionFiles = dir(fullfile(WorkingDir, SubjectAnat, [SubjectID,'_ses-*',FileSuffix]));
FlatSessions = cellfun(@(FileName) local_get_session_label_from_bids_file(FileName, SubjectID), ...
    {SessionFiles(~[SessionFiles.isdir]).name}, 'UniformOutput', false);
Sessions = unique([{SessionDirs([SessionDirs.isdir]).name}, FlatSessions]);
Sessions = Sessions(~cellfun(@isempty, Sessions));
RequiredSessions = RequiredSessions(~cellfun(@isempty, RequiredSessions));

% A session-specific reference must correspond to the target DWI or ACPC session.
CandidateFiles = cell(size(Sessions));
for iSession = 1:numel(Sessions)
    FileName = [SubjectID,'_',Sessions{iSession},FileSuffix];
    CandidateFiles{iSession} = local_pick_existing_file({ ...
        fullfile(WorkingDir, SubjectPath, Sessions{iSession}, 'anat', FileName), ...
        fullfile(WorkingDir, SubjectAnat, FileName)});
end
HasFile = ~cellfun(@isempty, CandidateFiles);
MatchesSession = true(size(Sessions));
if ~isempty(RequiredSessions)
    MatchesSession = ismember(Sessions, RequiredSessions);
end
Selected = find(HasFile & MatchesSession);
if numel(Selected) ~= 1 || numel(RequiredSessions) > 1
    Found = strjoin(CandidateFiles(HasFile), ', ');
    if isempty(Found)
        Found = '(none)';
    end
    error('Cannot select a unique %s anatomical derivative for %s. Target sessions: %s. Checked %s. Session candidates: %s.', ...
        DerivativeName, SubjectID, strjoin(RequiredSessions, ', '), fullfile(WorkingDir, RelativeFile), Found);
end

SessionLabel = Sessions{Selected};
FileName = [SubjectID,'_',SessionLabel,FileSuffix];
RelativeFile = [SubjectPath,'/',SessionLabel,'/anat/',FileName];
if 2~=exist(fullfile(WorkingDir, RelativeFile),'file')
    RelativeFile = [SubjectAnat,FileName];
end
end



function TransformPrefix = local_t1w_to_acpc_transform_prefix()
TransformPrefix = 'Results/AnatVolu/T1wSpace/{1}/{1}_fmriprepT1_to_qsiprepACPC_';
end



function local_apply_t1w_to_acpc(Cfg, CommandParallel, ContainerWorkingDir, ACPCReferenceFileSet, InputFile, OutputWithinFile, Interpolation)
SubjectIDCell = Cfg.SubjectID;
InputFileSet = local_expand_parallel_subject_file_template(InputFile, SubjectIDCell);
OutputFileSet = local_expand_parallel_subject_file_template([ContainerWorkingDir,'/',OutputWithinFile], SubjectIDCell);
TransformFileSet = local_expand_parallel_subject_file_template( ...
    [ContainerWorkingDir,'/',local_t1w_to_acpc_transform_prefix(),'0GenericAffine.mat'], SubjectIDCell);
JobFiles = [InputFileSet, ACPCReferenceFileSet, OutputFileSet, TransformFileSet];
JobCommand = sprintf('antsApplyTransforms --default-value 0 --float 0 -d 3 -i {1} -r {2} -o {3} -n %s -t {4}', Interpolation);
local_run_ants_jobs(Cfg.WorkingDir, ContainerWorkingDir, CommandParallel, JobCommand, JobFiles, 'T1w to ACPC resampling');
OutputFileSet = local_expand_parallel_subject_file_template(fullfile(Cfg.WorkingDir, OutputWithinFile), SubjectIDCell);
local_require_ants_outputs(OutputFileSet, 'T1w to ACPC resampling');
end



function local_normalize_dwi_results(WorkingDir, ContainerWorkingDir, CommandParallel, SubjectIDCell, ResultsDir)
InputRoot = [ResultsDir,'/DwiVolu/'];
OutputRoot = [ResultsDir,'W/DwiVolu/'];
ReferenceFile = [ContainerWorkingDir,'/Masks/BrainMask_05_97x115x97.nii'];
TransformSuffix = '_from-ACPC_to-MNI152NLin2009cAsym_mode-image_xfm.h5';

ResultFolders = {'SeedBasedStructuralConnectivityTDIMap','SeedBasedStructuralConnectivityTWFCMap'};
TensorFolders = dir(fullfile(WorkingDir, InputRoot, 'TensorMetrics'));
TensorFolders = {TensorFolders([TensorFolders.isdir]).name};
TensorFolders = TensorFolders(~ismember(TensorFolders, {'.','..'}));
ResultFolders = [ResultFolders,strcat('TensorMetrics/',TensorFolders)];

for iSubject = 1:numel(SubjectIDCell)
    SubjectID = SubjectIDCell{iSubject};
    SubjectPattern = ['(^|_)',regexptranslate('escape',SubjectID),'(?=_|\.)'];
    TransformFile = '';

    for iFolder = 1:numel(ResultFolders)
        InputDir = [InputRoot,ResultFolders{iFolder}];
        Images = dir(fullfile(WorkingDir, InputDir, ['*',SubjectID,'*.nii*']));
        FileNames = {Images(~[Images.isdir]).name}.';
        IsSubject = ~cellfun(@isempty, regexp(FileNames, SubjectPattern, 'once'));
        IsNifti = ~cellfun(@isempty, regexp(FileNames, '\.nii(\.gz)?$', 'once'));
        FileNames = FileNames(IsSubject & IsNifti);
        if isempty(FileNames)
            continue;
        end

        if isempty(TransformFile)
            DwiSessions = local_get_qsiprep_dwi_sessions(WorkingDir, SubjectID);
            RelativeTransform = local_resolve_anat_derivative(WorkingDir, 'qsiprep', ...
                SubjectID, TransformSuffix, DwiSessions);
            TransformFile = [ContainerWorkingDir,'/',RelativeTransform];
        end

        OutputDir = [OutputRoot,ResultFolders{iFolder}];
        HostOutputDir = fullfile(WorkingDir, OutputDir);
        if ~exist(HostOutputDir,'dir')
            mkdir(HostOutputDir);
        end

        InputFileSet = strcat([ContainerWorkingDir,'/',InputDir,'/'], FileNames);
        OutputFileSet = strcat([ContainerWorkingDir,'/',OutputDir,'/w'], FileNames);
        JobFiles = [InputFileSet, OutputFileSet, repmat({ReferenceFile,TransformFile}, numel(FileNames), 1)];
        JobCommand = ['antsApplyTransforms --default-value 0 --float 0 --input {1} ', ...
            '--interpolation Linear --output {2} --reference-image {3} --transform {4}'];
        if strcmpi(ResultFolders{iFolder}, 'TensorMetrics/Tensor')
            JobCommand = [JobCommand,' --input-image-type 3'];
        end

        Action = sprintf('ACPC to MNI normalization for %s (%s)', SubjectID, ResultFolders{iFolder});
        local_run_ants_jobs(WorkingDir, ContainerWorkingDir, CommandParallel, JobCommand, JobFiles, Action);
        local_require_ants_outputs(fullfile(HostOutputDir, strcat('w',FileNames)), Action);
    end
end
end



function local_run_ants_jobs(WorkingDir, ContainerWorkingDir, CommandParallel, JobCommand, JobFiles, Action)
% Each row keeps the input, reference and output paths for one job together.
JobList = [tempname(WorkingDir),'.tsv'];
[FileID, Message] = fopen(JobList, 'w', 'n', 'UTF-8');
if FileID == -1
    error('Could not create ANTs job list %s: %s', JobList, Message);
end
RemoveJobList = onCleanup(@() delete(JobList));
JobFormat = [repmat('%s\t', 1, size(JobFiles,2)-1), '%s\n'];
for iJob = 1:size(JobFiles,1)
    fprintf(FileID, JobFormat, JobFiles{iJob,:});
end
if fclose(FileID) ~= 0
    error('Could not write ANTs job list %s.', JobList);
end
Command = sprintf('%s --halt soon,fail=1 --colsep "\\t" %s :::: "%s/%s"', ...
    CommandParallel, JobCommand, ContainerWorkingDir, local_basename(JobList));
Status = system(Command);
if Status ~= 0
    error('%s failed (exit status %d). See the ANTs output above for the failed subject and image paths.', Action, Status);
end
end



function local_require_ants_outputs(FileSet, Action)
HasOutput = cellfun(@(FileName) 2==exist(FileName,'file'), FileSet);
if ~all(HasOutput)
    error('%s did not produce the expected files: %s', Action, strjoin(FileSet(~HasOutput), ', '));
end
end



function [FCFile, MountPath, WithinFile] = local_transform_twfc_fcfile_to_acpc(Cfg, FCFileInput, MountPathInput, WithinFileInput, iElement, IsTracksForEachROI, CommandInit, CommandParallelQsiprep, ContainerWorkingDir, ACPCReferenceFileSet)
OutputDir = fullfile(Cfg.WorkingDir,'Results','DwiVolu','SeedBasedStructuralConnectivityTWFCMap','FCFileACPC');
if ~exist(OutputDir,'dir')
    mkdir(OutputDir);
end

if IsTracksForEachROI
    OutputName = ['ROI_',num2str(iElement),'_{1}_space-ACPC_FCFile.nii.gz'];
else
    OutputName = 'AllROITraverse_{1}_space-ACPC_FCFile.nii.gz';
end

OutputFileHost = fullfile(OutputDir, OutputName);
OutputWithinFile = ['Results/DwiVolu/SeedBasedStructuralConnectivityTWFCMap/FCFileACPC/',OutputName];

OutputFileSet = local_expand_parallel_subject_file_template(OutputFileHost, Cfg.SubjectID);
HasOutput = cellfun(@(FileName) 2==exist(FileName,'file'), OutputFileSet);
if ~all(HasOutput)
    if isdeployed && (isunix && (~ismac))
        CommandParallelForFC = CommandParallelQsiprep;
        InputFile = FCFileInput;
    else
        CommandParallelForFC = sprintf('%s -v %s:/MountPath cgyan/qsiprep parallel -j %g', CommandInit, MountPathInput, Cfg.ParallelWorkersNumber);
        InputFile = ['/MountPath/',WithinFileInput];
    end

    fprintf('Transform TWFC FCFile to space-ACPC, please wait...\n');
    local_apply_t1w_to_acpc(Cfg, CommandParallelForFC, ContainerWorkingDir, ACPCReferenceFileSet, InputFile, OutputWithinFile, 'Linear');
end

FCFile = OutputFileHost;
MountPath = Cfg.WorkingDir;
WithinFile = OutputWithinFile;
end



function [ImageFile, MountPath, WithinFile] = local_transform_weighted_image_to_acpc(Cfg, ImageFileInput, MountPathInput, WithinFileInput, CommandInit, CommandParallelQsiprep, ContainerWorkingDir, ACPCReferenceFileSet)
OutputDir = fullfile(Cfg.WorkingDir,'Results','DwiVolu','StructuralConnectomeMatrix','ImageFileACPC');
if ~exist(OutputDir,'dir')
    mkdir(OutputDir);
end

OutputName = '{1}_space-ACPC_WeightedByImage.nii.gz';
OutputFileHost = fullfile(OutputDir, OutputName);
OutputWithinFile = ['Results/DwiVolu/StructuralConnectomeMatrix/ImageFileACPC/',OutputName];

OutputFileSet = local_expand_parallel_subject_file_template(OutputFileHost, Cfg.SubjectID);
HasOutput = cellfun(@(FileName) 2==exist(FileName,'file'), OutputFileSet);
if ~all(HasOutput)
    if isdeployed && (isunix && (~ismac))
        CommandParallelForImage = CommandParallelQsiprep;
        InputFile = ImageFileInput;
    else
        CommandParallelForImage = sprintf('%s -v %s:/MountPath cgyan/qsiprep parallel -j %g', CommandInit, MountPathInput, Cfg.ParallelWorkersNumber);
        InputFile = ['/MountPath/',WithinFileInput];
    end

    fprintf('Transform weighted image to space-ACPC, please wait...\n');
    local_apply_t1w_to_acpc(Cfg, CommandParallelForImage, ContainerWorkingDir, ACPCReferenceFileSet, InputFile, OutputWithinFile, 'Linear');
end

ImageFile = OutputFileHost;
MountPath = Cfg.WorkingDir;
WithinFile = OutputWithinFile;
end



function FileSet = local_expand_parallel_subject_file_template(FileTemplate, SubjectIDCell)
FileSet = cell(length(SubjectIDCell),1);

for iSubject=1:length(SubjectIDCell)
    FileSet{iSubject} = replace(FileTemplate,'{1}',SubjectIDCell{iSubject});
end
end



function [RefFile, TransformFile] = local_resolve_qsiprep_mni_to_acpc_files(WorkingDir, SubjectID)
QsiprepSubjectDir = fullfile(WorkingDir, 'qsiprep', SubjectID);
SessionLabel = '';

RefCandidates = {
    fullfile(QsiprepSubjectDir, 'dwi', [SubjectID, '_space-ACPC_dwiref.nii.gz'])
    fullfile(QsiprepSubjectDir, 'ses-1', 'dwi', [SubjectID, '_ses-1_space-ACPC_dwiref.nii.gz'])
    };
RefFile = local_pick_existing_file(RefCandidates);

if isempty(RefFile)
    DirSession = dir(fullfile(QsiprepSubjectDir, 'ses-*'));
    DirSession = DirSession([DirSession.isdir]);
    for iSession = 1:length(DirSession)
        CandidateFile = fullfile(QsiprepSubjectDir, DirSession(iSession).name, 'dwi', [SubjectID, '_', DirSession(iSession).name, '_space-ACPC_dwiref.nii.gz']);
        if exist(CandidateFile,'file')
            RefFile = CandidateFile;
            SessionLabel = DirSession(iSession).name;
            break;
        end
    end
else
    SessionLabel = local_get_session_label_from_bids_file(RefFile, SubjectID);
end

if isempty(RefFile)
    error('DWI reference file does not exist for %s under %s.', SubjectID, QsiprepSubjectDir);
end

TransformCandidates = {};
if ~isempty(SessionLabel)
    TransformCandidates = [TransformCandidates; {
        fullfile(QsiprepSubjectDir, SessionLabel, 'anat', [SubjectID, '_', SessionLabel, '_from-MNI152NLin2009cAsym_to-ACPC_mode-image_xfm.h5'])
        fullfile(QsiprepSubjectDir, 'anat', [SubjectID, '_', SessionLabel, '_from-MNI152NLin2009cAsym_to-ACPC_mode-image_xfm.h5'])
        }];
end

TransformCandidates = [TransformCandidates; {
    fullfile(QsiprepSubjectDir, 'anat', [SubjectID, '_from-MNI152NLin2009cAsym_to-ACPC_mode-image_xfm.h5'])
    fullfile(QsiprepSubjectDir, 'ses-1', 'anat', [SubjectID, '_ses-1_from-MNI152NLin2009cAsym_to-ACPC_mode-image_xfm.h5'])
    fullfile(QsiprepSubjectDir, 'anat', [SubjectID, '_ses-1_from-MNI152NLin2009cAsym_to-ACPC_mode-image_xfm.h5'])
    }];

if isempty(SessionLabel)
    DirSession = dir(fullfile(QsiprepSubjectDir, 'ses-*'));
    DirSession = DirSession([DirSession.isdir]);
    for iSession = 1:length(DirSession)
        TransformCandidates = [TransformCandidates; {
            fullfile(QsiprepSubjectDir, DirSession(iSession).name, 'anat', [SubjectID, '_', DirSession(iSession).name, '_from-MNI152NLin2009cAsym_to-ACPC_mode-image_xfm.h5'])
            fullfile(QsiprepSubjectDir, 'anat', [SubjectID, '_', DirSession(iSession).name, '_from-MNI152NLin2009cAsym_to-ACPC_mode-image_xfm.h5'])
            }];
    end
end

TransformFile = local_pick_existing_file(TransformCandidates);
if isempty(TransformFile)
    error('Transform file does not exist for %s under %s.', SubjectID, QsiprepSubjectDir);
end
end



function SessionLabel = local_get_session_label_from_bids_file(FileName, SubjectID)
SessionLabel = '';
Expression = [regexptranslate('escape', SubjectID), '_(ses-[^_]+)_'];
Tokens = regexp(FileName, Expression, 'tokens', 'once');
if ~isempty(Tokens)
    SessionLabel = Tokens{1};
end
end



function ExistingFile = local_pick_existing_file(FileCell)
ExistingFile = '';
for iFile=1:length(FileCell)
    if ~isempty(FileCell{iFile}) && exist(FileCell{iFile},'file')
        ExistingFile = FileCell{iFile};
        return;
    end
end
end



function local_create_directory_alias(TargetDir, SourceDir, UnixRelativeSourceDir)
if exist(TargetDir,'dir')
    return;
end

ParentDir = fileparts(TargetDir);
if ~exist(ParentDir,'dir')
    mkdir(ParentDir);
end

if ispc
    Command = sprintf('cmd /c mklink /J "%s" "%s"', TargetDir, SourceDir);
else
    Command = sprintf('ln -s "%s" "%s"', UnixRelativeSourceDir, TargetDir);
end
[Status, Output] = system(Command);

if (Status~=0) && ~exist(TargetDir,'dir')
    error('Failed to create directory alias from %s to %s: %s', TargetDir, SourceDir, Output);
end
end



function local_create_file_alias(TargetFile, SourceFile, UnixRelativeSourceFile)
if exist(TargetFile,'file')
    return;
end

if ispc
    [Status, Output] = copyfile(SourceFile, TargetFile);
    if Status == 0
        error('Failed to create file alias from %s to %s: %s', TargetFile, SourceFile, Output);
    end
else
    Command = sprintf('ln -s "%s" "%s"', UnixRelativeSourceFile, TargetFile);
    [Status, Output] = system(Command);
    if (Status~=0) && ~exist(TargetFile,'file')
        error('Failed to create file alias from %s to %s: %s', TargetFile, SourceFile, Output);
    end
end
end



function IsNiftiGz = local_is_nifti_gz_file(FileName)
IsNiftiGz = (length(FileName) >= 7) && strcmpi(FileName(end-6:end), '.nii.gz');
end



function IsNifti = local_is_nifti_file(FileName)
IsNifti = (length(FileName) >= 4) && strcmpi(FileName(end-3:end), '.nii');
end



function Name = local_basename(FileName)
[~, Name, Ext] = fileparts(FileName);
if strcmpi(Ext,'.gz')
    [~, Name2, Ext2] = fileparts(Name);
    Name = [Name2, Ext2, Ext];
else
    Name = [Name, Ext];
end
end



function FreeSurferSubjectID = local_prepare_qsirecon_freesurfer_aliases(FreesurferInput, SubjectIDCell)
FreeSurferSubjectID = cell(length(SubjectIDCell),1);

if isempty(FreesurferInput) || ~exist(FreesurferInput,'dir')
    return;
end

for iSubject=1:length(SubjectIDCell)
    FreeSurferSubjectID{iSubject} = local_resolve_freesurfer_subject_id(FreesurferInput, SubjectIDCell{iSubject});
    if isempty(FreeSurferSubjectID{iSubject})
        continue;
    end

    if ~strcmpi(FreeSurferSubjectID{iSubject}, SubjectIDCell{iSubject}) && ~exist(fullfile(FreesurferInput, SubjectIDCell{iSubject}),'dir')
        local_create_freesurfer_subject_alias(FreesurferInput, FreeSurferSubjectID{iSubject}, SubjectIDCell{iSubject});
    end
end
end



function FreeSurferSubjectID = local_resolve_freesurfer_subject_id(FreesurferInput, SubjectID)
FreeSurferSubjectID = '';

if exist(fullfile(FreesurferInput, SubjectID),'dir')
    FreeSurferSubjectID = SubjectID;
    return;
end

if exist(fullfile(FreesurferInput, [SubjectID, '_ses-1']),'dir')
    FreeSurferSubjectID = [SubjectID, '_ses-1'];
    return;
end

DirFS = dir(fullfile(FreesurferInput, [SubjectID, '_ses-*']));
DirFS = DirFS([DirFS.isdir]);
if isempty(DirFS)
    return;
end

FreeSurferSubjectID = DirFS(1).name;
end



function local_create_freesurfer_subject_alias(FreesurferInput, SourceSubjectID, TargetSubjectID)
SourceDir = fullfile(FreesurferInput, SourceSubjectID);
TargetDir = fullfile(FreesurferInput, TargetSubjectID);

if exist(TargetDir,'dir')
    return;
end

if ispc
    Command = sprintf('cmd /c mklink /J "%s" "%s"', TargetDir, SourceDir);
else
    Command = sprintf('ln -s "%s" "%s"', SourceSubjectID, TargetDir);
end
[Status, Output] = system(Command);

if (Status~=0) && ~exist(TargetDir,'dir')
    error('Failed to create FreeSurfer subject alias from %s to %s: %s', TargetSubjectID, SourceSubjectID, Output);
end
end

