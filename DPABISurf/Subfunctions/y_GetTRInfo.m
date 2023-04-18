function Cfg = y_GetTRInfo(Cfg,WorkingDir,SubjectListFile,StartingDirName)
% function Cfg = y_GetTRInfo(Cfg,WorkingDir,SubjectListFile,StartingDirName)
% Generate TRInfo.tsv
%   Input:
%   Cfg - the parameters for auto data processing. 
%   WorkingDir - Define the working directory to replace the one defined in Cfg
%   SubjectListFile - Define the subject list to replace the one defined in Cfg. Should be a text file
%   StartingDirName - StartingDirName. E.g., BIDS
%   Output:
%     see TRInfo.tsv.
%___________________________________________________________________________
% Written by YAN Chao-Gan 230214.
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

if exist('StartingDirName','var') && ~isempty(StartingDirName)
    Cfg.StartingDirName=StartingDirName;
end

Cfg.SubjectNum=length(Cfg.SubjectID);

% Multiple Sessions Processing 
% YAN Chao-Gan, 111215 added.
FunSessionPrefixSet={''}; %The first session doesn't need a prefix. From the second session, need a prefix such as 'S2_';
for iFunSession=2:Cfg.FunctionalSessionNumber
    FunSessionPrefixSet=[FunSessionPrefixSet;{['S',num2str(iFunSession),'_']}];
end


%Check TR and store Subject ID, TR, Slice Number, Time Points, Voxel Size into TRInfo.tsv if needed.

if ~( strcmpi(Cfg.StartingDirName,'T1Raw') || strcmpi(Cfg.StartingDirName,'T1Img') )  %Only need for functional processing
    if ~(2==exist([Cfg.WorkingDir,filesep,'TRInfo.tsv'],'file'))  %If the TR information is stored in TRInfo.tsv. %YAN Chao-Gan, 130612
        TRSet = zeros(Cfg.SubjectNum,Cfg.FunctionalSessionNumber);
        SliceNumber = zeros(Cfg.SubjectNum,Cfg.FunctionalSessionNumber);
        nTimePoints = zeros(Cfg.SubjectNum,Cfg.FunctionalSessionNumber);
        VoxelSize = zeros(Cfg.SubjectNum,Cfg.FunctionalSessionNumber,3);
        for iFunSession=1:Cfg.FunctionalSessionNumber
            for i=1:Cfg.SubjectNum

                if strcmpi(Cfg.StartingDirName,'BIDS') || strcmpi(Cfg.StartingDirName,'fmriprep') % YAN Chao-Gan, 221002. Also detect TR if start with BIDS or fmriprep

                    if Cfg.FunctionalSessionNumber==1
                        cd([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,Cfg.SubjectID{i},filesep,'func']);
                    else
                        cd([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,Cfg.SubjectID{i},filesep,'ses-',num2str(iFunSession),filesep,'func']);
                    end

                    DirImg=dir('*_bold.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                    if length(DirImg)>=1
                        gunzip(DirImg(1).name,tempdir);
                        ImgFileName=fullfile(tempdir,DirImg(1).name(1:end-3));
                    else
                        DirImg=dir('*_bold.nii');
                        ImgFileName=DirImg(1).name;
                    end
                    Nii  = nifti(ImgFileName);

                else

                    cd([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,Cfg.SubjectID{i}]);
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
                end


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

        %Write the information as TRInfo.tsv
        fid = fopen([Cfg.WorkingDir,filesep,'TRInfo.tsv'],'w');

        fprintf(fid,'Subject ID');
        for iFunSession=1:Cfg.FunctionalSessionNumber
            fprintf(fid,['\t',FunSessionPrefixSet{iFunSession},'TR']);
        end
        for iFunSession=1:Cfg.FunctionalSessionNumber
            fprintf(fid,['\t',FunSessionPrefixSet{iFunSession},'Slice Number']);
        end
        for iFunSession=1:Cfg.FunctionalSessionNumber
            fprintf(fid,['\t',FunSessionPrefixSet{iFunSession},'Time Points']);
        end
        for iFunSession=1:Cfg.FunctionalSessionNumber
            fprintf(fid,['\t',FunSessionPrefixSet{iFunSession},'Voxel Size']);
        end

        fprintf(fid,'\n');
        for i=1:Cfg.SubjectNum
            fprintf(fid,'%s',Cfg.SubjectID{i});

            for iFunSession=1:Cfg.FunctionalSessionNumber
                fprintf(fid,'\t%g',TRSet(i,iFunSession));
            end
            for iFunSession=1:Cfg.FunctionalSessionNumber
                fprintf(fid,'\t%g',SliceNumber(i,iFunSession));
            end
            for iFunSession=1:Cfg.FunctionalSessionNumber
                fprintf(fid,'\t%g',nTimePoints(i,iFunSession));
            end
            for iFunSession=1:Cfg.FunctionalSessionNumber
                fprintf(fid,'\t%g %g %g',VoxelSize(i,iFunSession,1),VoxelSize(i,iFunSession,2),VoxelSize(i,iFunSession,3));
            end
            fprintf(fid,'\n');
        end

        fclose(fid);
    end
end

fprintf('Generate TRInfo.tsv finished!\n');
