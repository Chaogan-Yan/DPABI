function [Error, Cfg]=DPABI_BIDS_Converter_run(Cfg,WorkingDir,SubjectListFile)
% FORMAT [Error, Cfg]=DPABI_BIDS_Converter_run(Cfg,WorkingDir,SubjectListFile)
%   Cfg - the parameters for auto data processing. 
%   WorkingDir - Define the working directory to replace the one defined in Cfg
%   SubjectListFile - Define the subject list to replace the one defined in Cfg. Should be a text file
% Output:
%   The processed data that you want.
%___________________________________________________________________________
% Written by YAN Chao-Gan 181126.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
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
ProgramPath=fullfile(DPABIPath, 'DPARSF');
TemplatePath=fullfile(DPABIPath, 'Templates');


%Make compatible with missing parameters.
if ~isfield(Cfg,'TR')
    Cfg.TR=0; 
end
if ~isfield(Cfg,'TimePoints')
    Cfg.TimePoints=0; 
end
if ~isfield(Cfg,'FunctionalSessionNumber')
    Cfg.FunctionalSessionNumber=1; 
end
if ~isfield(Cfg,'ParallelWorkersNumber')
    Cfg.ParallelWorkersNumber=1; 
end
if ~isfield(Cfg,'IsNeedConvertFunDCM2IMG')
    Cfg.IsNeedConvertFunDCM2IMG=0; 
end
if ~isfield(Cfg,'IsNeedConvertT1DCM2IMG')
    Cfg.IsNeedConvertT1DCM2IMG=0; 
end
if ~isfield(Cfg,'RemoveFirstTimePoints')
    Cfg.RemoveFirstTimePoints=0; 
end
if ~isfield(Cfg,'IsConvert2BIDS')
    Cfg.IsConvert2BIDS=0; 
end



% Multiple Sessions Processing 
% YAN Chao-Gan, 111215 added.
FunSessionPrefixSet={''}; %The first session doesn't need a prefix. From the second session, need a prefix such as 'S2_';
for iFunSession=2:Cfg.FunctionalSessionNumber
    FunSessionPrefixSet=[FunSessionPrefixSet;{['S',num2str(iFunSession),'_']}];
end


%Convert Functional DICOM files to NIFTI images
if (Cfg.IsNeedConvertFunDCM2IMG==1)
    for iFunSession=1:Cfg.FunctionalSessionNumber
        cd([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'FunRaw']);
        for i=1:Cfg.SubjectNum
            OutputDir=[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'FunImg',filesep,Cfg.SubjectID{i}];
            mkdir(OutputDir);
            DirDCM=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'FunRaw',filesep,Cfg.SubjectID{i},filesep,'*']); %Revised by YAN Chao-Gan 100130. %DirDCM=dir([Cfg.WorkingDir,filesep,'FunRaw',filesep,Cfg.SubjectID{i},filesep,'*.*']);
            if strcmpi(DirDCM(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
                StartIndex=4;
            else
                StartIndex=3;
            end
            InputFilename=[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'FunRaw',filesep,Cfg.SubjectID{i},filesep,DirDCM(StartIndex).name];

            %YAN Chao-Gan 120817.
            y_Call_dcm2nii(InputFilename, OutputDir, 'DefaultINI');

            fprintf(['Converting Functional Images:',Cfg.SubjectID{i},' OK']);
        end
        fprintf('\n');
    end
    Cfg.StartingDirName='FunImg';   %Now start with FunImg directory. 101010
end


%Convert T1 DICOM files to NIFTI images
if (Cfg.IsNeedConvertT1DCM2IMG==1)
    %Check if exist S2_T1Raw, that means mutiple run of T1 image exist
    if 7==exist([Cfg.WorkingDir,filesep,'S2_T1Raw'],'dir')
        T1SessionNumber = Cfg.FunctionalSessionNumber;
    else
        T1SessionNumber = 1;
    end
    
    for iFunSession=1:T1SessionNumber
        cd([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'T1Raw']);
        for i=1:Cfg.SubjectNum
            OutputDir=[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'T1Img',filesep,Cfg.SubjectID{i}];
            mkdir(OutputDir);
            DirDCM=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'T1Raw',filesep,Cfg.SubjectID{i},filesep,'*']); %Revised by YAN Chao-Gan 100130. %DirDCM=dir([Cfg.WorkingDir,filesep,'FunRaw',filesep,Cfg.SubjectID{i},filesep,'*.*']);
            if strcmpi(DirDCM(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
                StartIndex=4;
            else
                StartIndex=3;
            end
            InputFilename=[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'T1Raw',filesep,Cfg.SubjectID{i},filesep,DirDCM(StartIndex).name];

            %YAN Chao-Gan 120817.
            y_Call_dcm2nii(InputFilename, OutputDir, 'DefaultINI');

            fprintf(['Converting T1 Images:',Cfg.SubjectID{i},' OK']);
        end
        fprintf('\n');
    end
end


if Cfg.IsDeface
    CfgTemp.WorkingDir=Cfg.WorkingDir;
    CfgTemp.SubjectID=Cfg.SubjectID;
    CfgTemp.IsT1Deface=1; 
    CfgTemp.IsNeedConvertT1DCM2IMG=0;
    CfgTemp.IsNeedReorientT1ImgInteractively=0;
    y_T1ImgDefacer(CfgTemp);
    cd(Cfg.WorkingDir);
    movefile(['T1Img'],['T1ImgBeforeDefacing']);
    movefile(['T1ImgDefaced'],['T1Img']);
end



%Convert FieldMap DICOM files to NIFTI images. YAN Chao-Gan, 191122.
if isfield(Cfg,'FieldMap')
    if (Cfg.FieldMap.IsNeedConvertDCM2IMG==1)
        FieldMapMeasures={'PhaseDiff','Magnitude1','Magnitude2','Phase1','Phase2'};
        for iFieldMapMeasure=1:length(FieldMapMeasures)
            if exist([Cfg.WorkingDir,filesep,'FieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},'Raw'])
                cd([Cfg.WorkingDir,filesep,'FieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},'Raw']);
                for i=1:Cfg.SubjectNum
                    OutputDir=[Cfg.WorkingDir,filesep,'FieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},'Img',filesep,Cfg.SubjectID{i}];
                    mkdir(OutputDir);
                    DirDCM=dir([Cfg.WorkingDir,filesep,'FieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},'Raw',filesep,Cfg.SubjectID{i},filesep,'*']); %Revised by YAN Chao-Gan 100130. %DirDCM=dir([Cfg.WorkingDir,filesep,'T1Raw',filesep,Cfg.SubjectID{i},filesep,'*.*']);
                    if strcmpi(DirDCM(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
                        StartIndex=4;
                    else
                        StartIndex=3;
                    end
                    InputFilename=[Cfg.WorkingDir,filesep,'FieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},'Raw',filesep,Cfg.SubjectID{i},filesep,DirDCM(StartIndex).name];
                    y_Call_dcm2nii(InputFilename, OutputDir, 'DefaultINI');
                    fprintf(['Converting FieldMap ',FieldMapMeasures{iFieldMapMeasure},' Images:',Cfg.SubjectID{i},' OK']);
                end
                fprintf('\n');
            end
        end
    end
end



%Check TR and store Subject ID, TR, Slice Number, Time Points, Voxel Size into TRInfo.tsv if needed.
if isfield(Cfg,'TR')
    if Cfg.TR==0  % Need to retrieve the TR information from the NIfTI images
        if ~( strcmpi(Cfg.StartingDirName,'T1Raw') || strcmpi(Cfg.StartingDirName,'T1Img') )  %Only need for functional processing
            if (2==exist([Cfg.WorkingDir,filesep,'TRInfo.tsv'],'file'))  %If the TR information is stored in TRInfo.tsv. %YAN Chao-Gan, 130612
                
                fid = fopen([Cfg.WorkingDir,filesep,'TRInfo.tsv']);
                StringFilter = '%s';
                for iFunSession=1:Cfg.FunctionalSessionNumber
                    StringFilter = [StringFilter,'\t%f']; %Get the TRs for the sessions.
                end
                StringFilter = [StringFilter,'%*[^\n]']; %Skip the else till end of the line
                tline = fgetl(fid); %Skip the title line
                TRInfoTemp = textscan(fid,StringFilter);
                fclose(fid);

                TRSet = zeros(Cfg.SubjectNum,Cfg.FunctionalSessionNumber);
                for i=1:Cfg.SubjectNum
                    [HasSubject SubjectIndex] = ismember(Cfg.SubjectID{i},TRInfoTemp{1});
                    if HasSubject
                        for iFunSession=1:Cfg.FunctionalSessionNumber
                            TRSet(i,iFunSession) = TRInfoTemp{1+iFunSession}(SubjectIndex); %The first column is Subject ID
                        end
                    else
                        error(['The subject ID ',Cfg.SubjectID{i},' was not found in TRInfo.tsv!'])
                    end
                end
                
            elseif (2==exist([Cfg.WorkingDir,filesep,'TRSet.txt'],'file'))  %If the TR information is stored in TRSet.txt (DPARSF V2.2).
                TRSet = load([Cfg.WorkingDir,filesep,'TRSet.txt']);
                TRSet = TRSet'; %YAN Chao-Gan 130612. This is for the compatibility with DPARSFA V2.2. Cause the TRSet saved there is in a transpose manner.
            else

                TRSet = zeros(Cfg.SubjectNum,Cfg.FunctionalSessionNumber);
                SliceNumber = zeros(Cfg.SubjectNum,Cfg.FunctionalSessionNumber);
                nTimePoints = zeros(Cfg.SubjectNum,Cfg.FunctionalSessionNumber);
                VoxelSize = zeros(Cfg.SubjectNum,Cfg.FunctionalSessionNumber,3);
                for iFunSession=1:Cfg.FunctionalSessionNumber
                    for i=1:Cfg.SubjectNum
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
                %save([Cfg.WorkingDir,filesep,'TRSet.txt'], 'TRSet', '-ASCII', '-DOUBLE','-TABS'); %YAN Chao-Gan, 121214. Save the TR information.
                
                %YAN Chao-Gan, 130612. No longer save to TRSet.txt, but save to TRInfo.tsv with information of Slice Number, Time Points, Voxel Size.
                
                
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
            Cfg.TRSet = TRSet;
        end
    end
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
            cd([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,Cfg.SubjectID{i}]);
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
if ~isempty(Error)
    disp(Error);
    return;
end



%Convert to BIDS structure for fmriprep
if (Cfg.IsConvert2BIDS==1)
    mkdir([Cfg.WorkingDir,filesep,'BIDS']);
    SubjectID_BIDS = y_Convert_DPARSFA2BIDS(Cfg.WorkingDir, [Cfg.WorkingDir,filesep,'BIDS'], Cfg);
    Cfg.SubjectID = SubjectID_BIDS;
    Cfg.StartingDirName = 'BIDS';
end


fprintf(['\nCongratulations, converting to BIDS format is done!!! :)\n\n']);

