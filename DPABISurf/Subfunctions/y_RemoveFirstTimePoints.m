function Cfg = y_RemoveFirstTimePoints(Cfg,WorkingDir,SubjectListFile,StartingDirName,RemoveFirstTimePoints,FunctionalSessionNumber)
% function Cfg = y_RemoveFirstTimePoints(Cfg,WorkingDir,SubjectListFile,StartingDirName,RemoveFirstTimePoints,FunctionalSessionNumber)
% Remove First Time Points
%   Input:
%   Cfg - the parameters for auto data processing. 
%   WorkingDir - Define the working directory to replace the one defined in Cfg
%   SubjectListFile - Define the subject list to replace the one defined in Cfg. Should be a text file
%   StartingDirName - StartingDirName. E.g., BIDS
%   RemoveFirstTimePoints - Number of time points needs to be removed
%   FunctionalSessionNumber - Number of Functional Sessions
%   Output:
%     Data After Removing First Time Points.
%___________________________________________________________________________
% Written by YAN Chao-Gan 230912.
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
    if exist(SubjectListFile, 'file') == 2
        fid = fopen(SubjectListFile);
        IDCell = textscan(fid,'%s\n'); %YAN Chao-Gan. For compatiblity of MALLAB 2014b. IDCell = textscan(fid,'%s','\n');
        fclose(fid);
        Cfg.SubjectID=IDCell{1};
    else
        Cfg.SubjectID={};
        Cfg.SubjectID{1}=SubjectListFile;
    end
end


if exist('StartingDirName','var') && ~isempty(StartingDirName)
    Cfg.StartingDirName=StartingDirName;
end

if exist('RemoveFirstTimePoints','var') && ~isempty(RemoveFirstTimePoints)
    if ischar(RemoveFirstTimePoints)
        Cfg.RemoveFirstTimePoints=str2num(RemoveFirstTimePoints);
    else
        Cfg.RemoveFirstTimePoints=RemoveFirstTimePoints;
    end
end

if exist('FunctionalSessionNumber','var') && ~isempty(FunctionalSessionNumber)
    if ischar(FunctionalSessionNumber)
        Cfg.FunctionalSessionNumber=str2num(FunctionalSessionNumber);
    else
        Cfg.FunctionalSessionNumber=FunctionalSessionNumber;
    end
end

Error=[];

Cfg.SubjectNum=length(Cfg.SubjectID);

% Multiple Sessions Processing 
% YAN Chao-Gan, 111215 added.
FunSessionPrefixSet={''}; %The first session doesn't need a prefix. From the second session, need a prefix such as 'S2_';
for iFunSession=2:Cfg.FunctionalSessionNumber
    FunSessionPrefixSet=[FunSessionPrefixSet;{['S',num2str(iFunSession),'_']}];
end


%Remove First Time Points
if (Cfg.RemoveFirstTimePoints>0)
    
    % The parpool might be shut down, restart it.
    % if isempty(gcp('nocreate')) && Cfg.ParallelWorkersNumber~=0
    %     parpool(Cfg.ParallelWorkersNumber);
    % end
    % YAN Chao-Gan, 190312. To be compatible with early matlab versions
    PCTVer = ver('distcomp');
    if ~isempty(PCTVer)
        FullMatlabVersion = sscanf(version,'%d.%d.%d.%d%s');
        if FullMatlabVersion(1)*1000+FullMatlabVersion(2)<8*1000+3    %YAN Chao-Gan, 151117. If it's lower than MATLAB 2014a.  %FullMatlabVersion(1)*1000+FullMatlabVersion(2)>=7*1000+8    %YAN Chao-Gan, 120903. If it's higher than MATLAB 2008.
            CurrentSize_MatlabPool = matlabpool('size');
            if (CurrentSize_MatlabPool==0) && (Cfg.ParallelWorkersNumber~=0)
                matlabpool(Cfg.ParallelWorkersNumber)
            end
        else
            if isempty(gcp('nocreate')) && Cfg.ParallelWorkersNumber~=0
                parpool(Cfg.ParallelWorkersNumber);
            end
        end
    end
    
    for iFunSession=1:Cfg.FunctionalSessionNumber
        cd([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName]);
        parfor i=1:Cfg.SubjectNum

            if strcmpi(Cfg.StartingDirName,'BIDS')  % YAN Chao-Gan, 221002. Also delete first time points if start with BIDS
                if Cfg.FunctionalSessionNumber==1
                    cd([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,Cfg.SubjectID{i},filesep,'func']);
                else
                    cd([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,Cfg.SubjectID{i},filesep,'ses-',num2str(iFunSession),filesep,'func']);
                end
            else
                cd([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,Cfg.SubjectID{i}]);
            end

            DirImg=dir('*.img');
            if ~isempty(DirImg)  %YAN Chao-Gan, 111114. Also support .nii files.
                if Cfg.TimePoints>0 && length(DirImg)~=Cfg.TimePoints % Will not check if TimePoints set to 0. YAN Chao-Gan 120806.
                    Error=[Error;{['Error in Removing First ',num2str(Cfg.RemoveFirstTimePoints),'Time Points: ',Cfg.SubjectID{i}]}];
                end
                for j=1:Cfg.RemoveFirstTimePoints
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
                    if Cfg.TimePoints>0 && length(DirImg)~=Cfg.TimePoints % Will not check if TimePoints set to 0. YAN Chao-Gan 120806.
                        Error=[Error;{['Error in Removing First ',num2str(Cfg.RemoveFirstTimePoints),'Time Points: ',Cfg.SubjectID{i}]}];
                    end
                    for j=1:Cfg.RemoveFirstTimePoints
                        delete(DirImg(j).name);
                    end
                else %4D .nii images
                    Nii  = nifti(DirImg(1).name);
                    if Cfg.TimePoints>0 && size(Nii.dat,4)~=Cfg.TimePoints % Will not check if TimePoints set to 0. YAN Chao-Gan 120806.
                        Error=[Error;{['Error in Removing First ',num2str(Cfg.RemoveFirstTimePoints),'Time Points: ',Cfg.SubjectID{i}]}];
                    end
                    %y_Write(Nii.dat(:,:,:,Cfg.RemoveFirstTimePoints+1:end),Nii,DirImg(1).name);
                    %YAN Chao-Gan, 210309. Save in single incase of Philips data.
                    [Data Header]=y_Read(DirImg(1).name);
                    Header.pinfo=[1;0;0]; Header.dt=[16,0];
                    y_Write(Data(:,:,:,Cfg.RemoveFirstTimePoints+1:end),Header,DirImg(1).name);
                    
                end
                
            end
            cd('..');
            fprintf(['Removing First ',num2str(Cfg.RemoveFirstTimePoints),' Time Points: ',Cfg.SubjectID{i},' OK']);
        end
        fprintf('\n');
    end
    Cfg.TimePoints=Cfg.TimePoints-Cfg.RemoveFirstTimePoints;
end

fprintf('Remove First Time Points finished!\n');


