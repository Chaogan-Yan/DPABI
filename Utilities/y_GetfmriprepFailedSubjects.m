function [FailedID WaitingID SuccessID]=y_GetfmriprepFailedSubjects(Cfg,WorkingDir,SubjectListFile, SubjectID)
% FORMAT [FailedID WaitingID SuccessID]=y_ReRunfmriprepFailedSubjects(Cfg,WorkingDir,SubjectID)
%   Cfg - the parameters for auto data processing. 
%   WorkingDir - Define the working directory to replace the one defined in Cfg
%   SubjectListFile - Define the subject list to replace the one defined in Cfg. Should be a text file
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

if exist('SubjectListFile','var') && ~isempty(SubjectListFile)
    fid = fopen(SubjectListFile);
    IDCell = textscan(fid,'%s\n'); %YAN Chao-Gan. For compatiblity of MALLAB 2014b. IDCell = textscan(fid,'%s','\n');
    fclose(fid);
    Cfg.SubjectID=IDCell{1};
end

if exist('SubjectID','var') && ~isempty(SubjectID)
    Cfg.SubjectID=SubjectID;
end

Cfg.SubjectNum=length(Cfg.SubjectID);


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
                Command=sprintf('%s cgyan/dpabi rm -rf /data/fmriprepwork/%s', CommandInit,FailedID{i});
            end
            system(Command);
        end

        if exist(fullfile(Cfg.WorkingDir,'fmriprep','sourcedata','freesurfer',FailedID{i}))
            %status = rmdir(fullfile(Cfg.WorkingDir,'fmriprep',FailedID{i}),'s');
            if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
                Command=sprintf('rm -rf %s/fmriprep/sourcedata/freesurfer/%s', Cfg.WorkingDir,FailedID{i});
            else
                Command=sprintf('%s cgyan/dpabi rm -rf /data/fmriprep/sourcedata/freesurfer/%s', CommandInit,FailedID{i});
            end
            system(Command);
        end
    end
end


NeedReRunID=[WaitingID;FailedID];



fileID = fopen([Cfg.WorkingDir,filesep,'subjects_SuccessID.txt'], 'w');
for i = 1:length(SuccessID)
    fprintf(fileID, '%s\n', SuccessID{i});
end
fclose(fileID);

fileID = fopen([Cfg.WorkingDir,filesep,'subjects_WaitingID.txt'], 'w');
for i = 1:length(WaitingID)
    fprintf(fileID, '%s\n', WaitingID{i});
end
fclose(fileID);

fileID = fopen([Cfg.WorkingDir,filesep,'subjects_FailedID.txt'], 'w');
for i = 1:length(FailedID)
    fprintf(fileID, '%s\n', FailedID{i});
end
fclose(fileID);

fileID = fopen([Cfg.WorkingDir,filesep,'subjects_NeedReRunID.txt'], 'w');
for i = 1:length(NeedReRunID)
    fprintf(fileID, '%s\n', NeedReRunID{i});
end
fclose(fileID);



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
if length(DirFiles_func)<30   %YAN Chao-Gan, 211223. ICA-AROMA will have more files. %length(DirFiles_func)~=31
    DirFiles_func=dir(fullfile(WorkingDir,'fmriprep',SubjectID,'ses-1','func','*'));
end
DirFiles_anat=dir(fullfile(WorkingDir,'fmriprep',SubjectID,'anat','*'));
if length(DirFiles_anat)<42  
    DirFiles_anat=dir(fullfile(WorkingDir,'fmriprep',SubjectID,'ses-1','anat','*'));
end
if (length(DirFiles_surf)~=84 && length(DirFiles_surf)~=94) || length(DirFiles_func)<30 || length(DirFiles_anat)<42 %YAN Chao-Gan, 211223. ICA-AROMA will have more files. %length(DirFiles_surf)~=84 || length(DirFiles_func)~=31
    HasMissingFiles = 1;
end



