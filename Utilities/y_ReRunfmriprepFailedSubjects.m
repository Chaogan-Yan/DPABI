function [FailedID WaitingID SuccessID]=y_ReRunfmriprepFailedSubjects(Cfg,WorkingDir,SubjectID)
% FORMAT [FailedID WaitingID SuccessID]=y_ReRunfmriprepFailedSubjects(Cfg,WorkingDir,SubjectID)
%   Cfg - the parameters for auto data processing. 
%   WorkingDir - Define the working directory to replace the one defined in Cfg
%   SubjectID - Define the subject list to replace the one defined in Cfg. 
% Output:
%   FailedID - After re-run fmriprep, these subjects have failed run fmriprep
%   WaitingID - After re-run fmriprep, these subjects have not run fmriprep yet
%   SuccessID - After re-run fmriprep, these subjects have successfully run fmriprep
%   The processed data that you want.
%___________________________________________________________________________
% Written by YAN Chao-Gan 200218.
% The R-fMRI Lab, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% International Big-Data Center for Depression Research, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com


if ~exist('Cfg','var') 
    [file,path] = uigetfile('*.mat','Please select the previous Cfg .mat for DPABISurf...');
    Cfg=fullfile(path,file);
end

if ischar(Cfg)  %If inputed a .mat file name. (Cfg inside)
    load(Cfg);
end

if exist('WorkingDir','var') && ~isempty(WorkingDir)
    Cfg.WorkingDir=WorkingDir;
end

%Check if needs to convert the original subject ID to BIDS format
if (Cfg.IsConvert2BIDS==1)
    Cfg.SubjectNum=length(Cfg.SubjectID);
    SubjectID_BIDS=cell(Cfg.SubjectNum,1);
    for i=1:Cfg.SubjectNum
        Temp=strfind(Cfg.SubjectID{i},'sub-');
        if ~isempty(Temp)
            SubjectID_BIDS{i}=Cfg.SubjectID{i};
        else
            TempStr=Cfg.SubjectID{i};
            Temp=strfind(TempStr,'-');
            TempStr(Temp)=[];
            Temp=strfind(TempStr,'_');
            TempStr(Temp)=[];
            SubjectID_BIDS{i}=['sub-',TempStr];
        end
    end
    Cfg.SubjectID = SubjectID_BIDS;
end

if exist('SubjectID','var') && ~isempty(SubjectID)
    Cfg.SubjectID=SubjectID;
end

Cfg.SubjectNum=length(Cfg.SubjectID);


[DPABIPath, fileN, extn] = fileparts(which('DPABI.m'));
ProgramPath=fullfile(DPABIPath, 'DPARSF');
TemplatePath=fullfile(DPABIPath, 'Templates');

%Get ready for later freesurfer usage.
if ispc
    CommandInit=sprintf('docker run -i --rm -v %s:/opt/freesurfer/license.txt -v %s:/data ', fullfile(DPABIPath, 'DPABISurf', 'FreeSurferLicense', 'license.txt'), Cfg.WorkingDir); %YAN Chao-Gan, 181214. Remove -t because there is a tty issue in windows
else
    CommandInit=sprintf('docker run -ti --rm -v %s:/opt/freesurfer/license.txt -v %s:/data ', fullfile(DPABIPath, 'DPABISurf', 'FreeSurferLicense', 'license.txt'), Cfg.WorkingDir); %YAN Chao-Gan, 181214. Remove -t because there is a tty issue in windows
end


SuccessID=[];
FailedID=[];
WaitingID=[];
for i=1:Cfg.SubjectNum
    if exist(fullfile(Cfg.WorkingDir,'fmriprep',Cfg.SubjectID{i}))
        %if exist(fullfile(Cfg.WorkingDir,'fmriprep',Cfg.SubjectID{i},'logs')) || exist(fullfile(Cfg.WorkingDir,'fmriprep',Cfg.SubjectID{i},'log'))
        if CheckFailedLogs(fullfile(Cfg.WorkingDir,'fmriprep',Cfg.SubjectID{i})) || CheckMissingFiles(Cfg.WorkingDir,Cfg.SubjectID{i}) %YAN Chao-Gan, 200904. Use new logic according to fmriprep's change
            FailedID=[FailedID;Cfg.SubjectID(i)];
        else
            SuccessID=[SuccessID;Cfg.SubjectID(i)];
        end
    else
        WaitingID=[WaitingID;Cfg.SubjectID(i)];
    end
end

if ~isempty(SuccessID)
    fprintf(['\nThese subjects have successfully run fmriprep:\n']);
    disp(SuccessID)
end

if ~isempty(WaitingID)
    fprintf(['\nThese subjects have not run fmriprep yet:\n']);
    disp(WaitingID)
end

if ~isempty(FailedID)
    fprintf(['\nThese subjects have failed run fmriprep:\n']);
    disp(FailedID)
    
    %Delete the intermediate files for failed subjects
    for i=1:length(FailedID)
        if exist(fullfile(Cfg.WorkingDir,'fmriprep',FailedID{i}))
            %status = rmdir(fullfile(Cfg.WorkingDir,'fmriprep',FailedID{i}),'s');
            if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
                Command=sprintf('rm -rf %s/fmriprep/%s', Cfg.WorkingDir,FailedID{i});
            else
                Command=sprintf('%s cgyan/dpabi rm -rf /data/fmriprep/%s', CommandInit,FailedID{i});
            end
            system(Command);
        end
        if exist(fullfile(Cfg.WorkingDir,'fmriprepwork',FailedID{i}))
            %status = rmdir(fullfile(Cfg.WorkingDir,'fmriprepwork',FailedID{i}),'s');
            if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
                Command=sprintf('rm -rf %s/fmriprepwork/%s', Cfg.WorkingDir,FailedID{i});
            else
                Command=sprintf('%s cgyan/dpabi rm -rf /data/fmriprep/%s', CommandInit,FailedID{i});
            end
            system(Command);
        end
    end
end


NeedReRunID=[WaitingID;FailedID];
SubjectIDString=[];
for i=1:length(NeedReRunID)
    SubjectIDString = sprintf('%s %s',SubjectIDString,NeedReRunID{i});
end


%Preprocessing with fmriprep
if ~isempty(NeedReRunID) %(Cfg.Isfmriprep==1)
    % Let's stop parpool before entering fmriprep
%         if ~isempty(gcp('nocreate'))
%             delete(gcp('nocreate'));
%         end
    % YAN Chao-Gan, 190312. To be compatible with early matlab versions
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
    

    if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
        Command=sprintf('export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/fsl-6.0.5.1/lib && parallel -j %g /opt/conda/bin/fmriprep %s/BIDS %s/fmriprep participant --resource-monitor', Cfg.ParallelWorkersNumber, Cfg.WorkingDir, Cfg.WorkingDir);
    else
        Command=sprintf('%s cgyan/dpabi parallel -j %g /opt/conda/bin/fmriprep /data/BIDS /data/fmriprep participant --resource-monitor', CommandInit, Cfg.ParallelWorkersNumber );
    end

    if Cfg.ParallelWorkersNumber~=0
        Command = sprintf('%s --nthreads 1 --omp-nthreads 1', Command);
    end
    if Cfg.IsSliceTiming==0
        Command = sprintf('%s --ignore slicetiming', Command);
    end
    if isfield(Cfg,'FieldMap') && Cfg.FieldMap.IsApplyFieldMapCorrection==0 %YAN Chao-Gan, 191124.
        Command = sprintf('%s --ignore fieldmaps', Command);
    end
    if Cfg.IsICA_AROMA==1
        %Command = sprintf('%s --use-aroma --aroma-melodic-dimensionality -250 --ignore-aroma-denoising-errors', Command); %The HCP pipeline default is 250 maximum
        %Command = sprintf('%s --use-aroma --aroma-melodic-dimensionality -200 --ignore-aroma-denoising-errors', Command); %The fMRIPrep pipeline default is 200 maximum
        Command = sprintf('%s --use-aroma --aroma-melodic-dimensionality -200', Command); %The fMRIPrep pipeline default is 200 maximum
    end

    %Change to fmriprep's new output space command convention. YAN Chao-Gan. 20200229.
    %Command = sprintf('%s --template-resampling-grid %s', Command, Cfg.Normalize.VoxelSize);
    if length(Cfg.Normalize.VoxelSize)>=3 && strcmpi(Cfg.Normalize.VoxelSize(end-1:end),'mm')
        Cfg.Normalize.VoxelSize=Cfg.Normalize.VoxelSize(1); %Change 1mm to 1; 2mm to 2.
    end
    Command = sprintf('%s --output-spaces fsaverage5 MNI152NLin2009cAsym:res-%s fsnative T1w', Command, Cfg.Normalize.VoxelSize); %YAN Chao-Gan, 221204. Also output native results. Command = sprintf('%s --output-spaces fsaverage5 MNI152NLin2009cAsym:res-%s', Command, Cfg.Normalize.VoxelSize);


    if Cfg.IsLowMem==1
        Command = sprintf('%s --low-mem', Command);
    end

    if Cfg.FunctionalSessionNumber==0 %YAN Chao-Gan, 210414. If no anatomical images
        Command = sprintf('%s --anat-only', Command);
    end

    if isfield(Cfg,'AlreadyHaveFreesurferResults') && Cfg.AlreadyHaveFreesurferResults==1 %YAN Chao-Gan, 221007. If Already Have Freesurfer Results. E.g., from fastsurfer outputs
        if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
            Command = sprintf('%s --fs-subjects-dir %s/freesurfer', Command,Cfg.WorkingDir);
        else
            Command = sprintf('%s --fs-subjects-dir /data/freesurfer', Command);
        end
    end

    Command = sprintf('%s -w /data/fmriprepwork/{1}', Command); %Specify the working dir for fmriprep
    Command = sprintf('%s  --participant_label {1} ::: %s', Command, SubjectIDString);

    fprintf('Re-run the failed subjects with fmriprep, this process is very time consuming, please be patient...\n');

    system(Command);

    %Check if there is any error during re-running fmriprep
    FailedID_Beginning = FailedID;

    SuccessID=[];
    FailedID=[];
    WaitingID=[];
    for i=1:Cfg.SubjectNum
        if exist(fullfile(Cfg.WorkingDir,'fmriprep',Cfg.SubjectID{i}))
            %if exist(fullfile(Cfg.WorkingDir,'fmriprep',Cfg.SubjectID{i},'logs')) || exist(fullfile(Cfg.WorkingDir,'fmriprep',Cfg.SubjectID{i},'log'))
            if CheckFailedLogs(fullfile(Cfg.WorkingDir,'fmriprep',Cfg.SubjectID{i})) %YAN Chao-Gan, 200904. Use new logic according to fmriprep's change
                FailedID=[FailedID;Cfg.SubjectID(i)];
            else
                SuccessID=[SuccessID;Cfg.SubjectID(i)];
            end
        else
            WaitingID=[WaitingID;Cfg.SubjectID(i)];
        end
    end

    if ~isempty(SuccessID)
        fprintf(['\nAfter re-run fmriprep, these subjects have successfully run fmriprep:\n']);
        disp(SuccessID)
    end

    if ~isempty(WaitingID)
        fprintf(['\nAfter re-run fmriprep, these subjects have not run fmriprep yet:\n']);
        disp(WaitingID)
    end

    if ~isempty(FailedID)
        fprintf(['\nAfter re-run fmriprep, these subjects have failed run fmriprep:\n']);
        disp(FailedID)

        %Check subjects failed twice
        for i=1:length(FailedID)
            for j=1:length(FailedID_Beginning)
                if strcmpi(FailedID{i},FailedID_Beginning{j})
                    fprintf('%s failed twice during running fmriprep, please check the raw data and the logs %s\n',FailedID{i},fullfile(Cfg.WorkingDir,'fmriprep',FailedID{i},'log'));
                end
            end
        end
    end

end



function HasFailedLogs = CheckFailedLogs(SubDir)
%YAN Chao-Gan. Check failed logs according to fmriprep's new logic
HasFailedLogs = 0;
if exist(fullfile(SubDir,'log'))
    Dirs=dir(fullfile(SubDir,'log','*'));
    if ~isempty(Dirs)
        for iDir=length(Dirs)
            if Dirs(iDir).isdir
                DirLogs=dir(fullfile(SubDir,'log',Dirs(iDir).name,'crash*'));
                if ~isempty(DirLogs)
                    HasFailedLogs=1;
                end
            end
        end
    end
end


function HasMissingFiles = CheckMissingFiles(WorkingDir,SubjectID)
%YAN Chao-Gan 210205. Check Missing Files according for fmriprep
HasMissingFiles = 0;
DirFiles_surf=dir(fullfile(WorkingDir,'freesurfer',SubjectID,'surf','*'));
if length(DirFiles_surf)==0   %YAN Chao-Gan, 221018. 
    DirFiles_surf=dir(fullfile(WorkingDir,'fmriprep','sourcedata','freesurfer',SubjectID,'surf','*'));
end
DirFiles_func=dir(fullfile(WorkingDir,'fmriprep',SubjectID,'func','*'));
if length(DirFiles_func)<17   %YAN Chao-Gan, 211223. ICA-AROMA will have more files. %length(DirFiles_func)~=17
    DirFiles_func=dir(fullfile(WorkingDir,'fmriprep',SubjectID,'ses-1','func','*'));
end
if (length(DirFiles_surf)~=84 && length(DirFiles_surf)~=94) || length(DirFiles_func)<17 %YAN Chao-Gan, 211223. ICA-AROMA will have more files. %length(DirFiles_surf)~=84 || length(DirFiles_func)~=17
    HasMissingFiles = 1;
end



