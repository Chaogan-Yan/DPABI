function [FailedID WaitingID SuccessID]=y_ReRunqsireconFailedSubjects(Cfg,WorkingDir,SubjectID)
% FORMAT [FailedID WaitingID SuccessID]=y_ReRunqsireconFailedSubjects(Cfg,WorkingDir,SubjectID)
%   Cfg - the parameters for auto data processing. 
%   WorkingDir - Define the working directory to replace the one defined in Cfg
%   SubjectID - Define the subject list to replace the one defined in Cfg. 
% Output:
%   FailedID - After re-run qsirecon, these subjects have failed run qsirecon
%   WaitingID - After re-run qsirecon, these subjects have not run qsirecon yet
%   SuccessID - After re-run qsirecon, these subjects have successfully run qsirecon
%   The processed data that you want.
%___________________________________________________________________________
% Written by YAN Chao-Gan 221118.
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
if isfield(Cfg,'IsConvert2BIDS') && (Cfg.IsConvert2BIDS==1)
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



%Get ready
if ispc
    CommandInit=sprintf('docker run -i --rm -v %s:/DPABI -v %s:/data ', DPABIPath, Cfg.WorkingDir); %YAN Chao-Gan, 181214. Remove -t because there is a tty issue in windows
else
    CommandInit=sprintf('docker run -ti --rm -v %s:/DPABI -v %s:/data ', DPABIPath, Cfg.WorkingDir); %YAN Chao-Gan, 181214. Remove -t because there is a tty issue in windows
end


SuccessID=[];
FailedID=[];
WaitingID=[];
for i=1:Cfg.SubjectNum
    if exist(fullfile(Cfg.WorkingDir,'qsirecon',Cfg.SubjectID{i}))
        if CheckFailedLogs(fullfile(Cfg.WorkingDir,'qsirecon',Cfg.SubjectID{i})) || CheckMissingFiles(Cfg.WorkingDir,Cfg.SubjectID{i}) 
            FailedID=[FailedID;Cfg.SubjectID(i)];
        else
            SuccessID=[SuccessID;Cfg.SubjectID(i)];
        end
    else
        WaitingID=[WaitingID;Cfg.SubjectID(i)];
    end
end

if ~isempty(SuccessID)
    fprintf(['\nThese subjects have successfully run qsirecon:\n']);
    disp(SuccessID)
end

if ~isempty(WaitingID)
    fprintf(['\nThese subjects have not run qsirecon yet:\n']);
    disp(WaitingID)
end

if ~isempty(FailedID)
    fprintf(['\nThese subjects have failed run qsirecon:\n']);
    disp(FailedID)
    
    %Delete the intermediate files for failed subjects
    for i=1:length(FailedID)
        if exist(fullfile(Cfg.WorkingDir,'qsirecon',FailedID{i}))
            %status = rmdir(fullfile(Cfg.WorkingDir,'qsirecon',FailedID{i}),'s');
            if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
                Command=sprintf('rm -rf %s/qsirecon/%s', Cfg.WorkingDir,FailedID{i});
            else
                Command=sprintf('%s cgyan/dpabi rm -rf /data/qsirecon/%s', CommandInit,FailedID{i});
            end
            system(Command);
        end
        if exist(fullfile(Cfg.WorkingDir,'qsireconwork',FailedID{i}))
            %status = rmdir(fullfile(Cfg.WorkingDir,'qsireconwork',FailedID{i}),'s');
            if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
                Command=sprintf('rm -rf %s/qsireconwork/%s', Cfg.WorkingDir,FailedID{i});
            else
                Command=sprintf('%s cgyan/dpabi rm -rf /data/qsireconwork/%s', CommandInit,FailedID{i});
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


%Reconstructing with qsiprep
if ~isempty(NeedReRunID) 

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

    fprintf('Re-run the failed subjects for reconstructing with qsiprep, this process is very time consuming, please be patient...\n');

    system(Command);


    %Check if there is any error during re-running qsirecon
    FailedID_Beginning = FailedID;
    
    SuccessID=[];
    FailedID=[];
    WaitingID=[];
    for i=1:Cfg.SubjectNum
        if exist(fullfile(Cfg.WorkingDir,'qsirecon',Cfg.SubjectID{i}))
            if CheckFailedLogs(fullfile(Cfg.WorkingDir,'qsirecon',Cfg.SubjectID{i}))
                FailedID=[FailedID;Cfg.SubjectID(i)];
            else
                SuccessID=[SuccessID;Cfg.SubjectID(i)];
            end
        else
            WaitingID=[WaitingID;Cfg.SubjectID(i)];
        end
    end
    
    if ~isempty(SuccessID)
        fprintf(['\nAfter re-run qsirecon, these subjects have successfully run qsirecon:\n']);
        disp(SuccessID)
    end
    
    if ~isempty(WaitingID)
        fprintf(['\nAfter re-run qsirecon, these subjects have not run qsirecon yet:\n']);
        disp(WaitingID)
    end
    
    if ~isempty(FailedID)
        fprintf(['\nAfter re-run qsirecon, these subjects have failed run qsirecon:\n']);
        disp(FailedID)
        
        %Check subjects failed twice
        for i=1:length(FailedID)
            for j=1:length(FailedID_Beginning)
                if strcmpi(FailedID{i},FailedID_Beginning{j})
                    fprintf('%s failed twice during running qsirecon, please check the data and the logs %s\n',FailedID{i},fullfile(Cfg.WorkingDir,'qsirecon',FailedID{i},'log'));
                end
            end
        end
    end

end



function HasFailedLogs = CheckFailedLogs(SubDir)
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
HasMissingFiles = 0;
DirFiles_tck=dir(fullfile(WorkingDir,'qsirecon',SubjectID,'dwi','*.tck'));
if length(DirFiles_tck)==0
    HasMissingFiles = 1;
end



