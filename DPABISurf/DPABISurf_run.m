function [Error, Cfg]=DPABISurf_run(Cfg,WorkingDir,SubjectListFile)
% FORMAT [Error]=DPABISurf_run(Cfg,WorkingDir,SubjectListFile)
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
if ~isfield(Cfg,'IsNeedConvertDwiDCM2IMG')
    Cfg.IsNeedConvertDwiDCM2IMG=0; 
end
if ~isfield(Cfg,'RemoveFirstTimePoints')
    Cfg.RemoveFirstTimePoints=0; 
end
if ~isfield(Cfg,'IsConvert2BIDS')
    Cfg.IsConvert2BIDS=0; 
end
if ~isfield(Cfg,'Isfastsurfer')
    Cfg.Isfastsurfer=0; 
end
if ~isfield(Cfg,'IsSliceTiming')
    Cfg.IsSliceTiming=0; 
end
if ~isfield(Cfg,'IsICA_AROMA')
    Cfg.IsICA_AROMA=0; 
end
if ~isfield(Cfg,'Isfmriprep')
    Cfg.Isfmriprep=0; 
end
if ~isfield(Cfg,'AlreadyHaveFreesurferResults')
    Cfg.AlreadyHaveFreesurferResults=0; 
end
if ~isfield(Cfg,'IsLowMem')
    Cfg.IsLowMem=0; 
end
if ~isfield(Cfg,'IsOrganizefmriprepResults')
    Cfg.IsOrganizefmriprepResults=0; 
end
if ~isfield(Cfg,'IsSegmentSubregions')
    Cfg.IsSegmentSubregions=0; 
end
% if ~isfield(Cfg,'IsWarpMasksIntoIndividualSpace') %!!!
%     Cfg.IsWarpMasksIntoIndividualSpace=0; 
% end
if ~isfield(Cfg,'IsBasedOnFunSurf')
    Cfg.IsBasedOnFunSurf=0; 
end
if ~isfield(Cfg,'MaskFileSurfLH')
    Cfg.MaskFileSurfLH = fullfile(DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_lh_cortex.label.gii');
end
if ~isfield(Cfg,'MaskFileSurfRH')
    Cfg.MaskFileSurfRH = fullfile(DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_rh_cortex.label.gii');
end
if ~isfield(Cfg,'MaskFileVolu')
    Cfg.MaskFileVolu = fullfile(DPABIPath, 'Templates','BrainMask_05_91x109x91.img');
end
if ~isfield(Cfg,'SurfFileLH')
    Cfg.SurfFileLH = fullfile(DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_lh_white.surf.gii');
end
if ~isfield(Cfg,'SurfFileRH')
    Cfg.SurfFileRH = fullfile(DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_rh_white.surf.gii');
end
if ~isfield(Cfg,'NonAgressiveRegressICAAROMANoise')
    Cfg.NonAgressiveRegressICAAROMANoise=0;
end
if ~isfield(Cfg,'IsCovremove')
    Cfg.IsCovremove=0; 
end
if ~isfield(Cfg,'IsProcessVolumeSpace')
    Cfg.IsProcessVolumeSpace=1; 
end
if ~isfield(Cfg,'IsNormalize') 
    Cfg.IsNormalize=0; 
end
if ~isfield(Cfg,'IsSmooth') 
    Cfg.IsSmooth=0; 
end
if ~isfield(Cfg,'IsCalALFF')
    Cfg.IsCalALFF=0; 
end
if ~isfield(Cfg,'IsFilter')
    Cfg.IsFilter=0; 
end
if ~isfield(Cfg,'IsScrubbing')
    Cfg.IsScrubbing=0;
end
if ~isfield(Cfg,'IsCalReHo')
    Cfg.IsCalReHo=0;
end
if ~isfield(Cfg,'IsCalDegreeCentrality')
    Cfg.IsCalDegreeCentrality=0; 
end
if ~isfield(Cfg,'IsCalFC')
    Cfg.IsCalFC=0; 
end
if ~isfield(Cfg,'CalFC')
    Cfg.CalFC.ROIDefVolu = {};
else
    if ~isfield(Cfg.CalFC,'ROIDefVolu')
        Cfg.CalFC.ROIDefVolu = {};
    end
    if ~isfield(Cfg.CalFC,'ROISelectedIndexVolu')
        Cfg.CalFC.ROISelectedIndexVolu = [];
    end
    if ~isfield(Cfg.CalFC,'ROISelectedIndexSurfLH')
        Cfg.CalFC.ROISelectedIndexSurfLH = [];
    end
    if ~isfield(Cfg.CalFC,'ROISelectedIndexSurfRH')
        Cfg.CalFC.ROISelectedIndexSurfRH = [];
    end
end
if ~isfield(Cfg,'IsExtractROISignals')
    Cfg.IsExtractROISignals=0; 
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


%Convert Dwi DICOM files to NIFTI images
if (Cfg.IsNeedConvertDwiDCM2IMG==1)
    %Check if exist S2_DwiRaw, that means mutiple run of Dwi image exist
    if 7==exist([Cfg.WorkingDir,filesep,'S2_DwiRaw'],'dir')
        DwiSessionNumber = Cfg.FunctionalSessionNumber;
    else
        DwiSessionNumber = 1;
    end
    
    for iFunSession=1:DwiSessionNumber
        cd([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'DwiRaw']);
        for i=1:Cfg.SubjectNum
            OutputDir=[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'DwiImg',filesep,Cfg.SubjectID{i}];
            mkdir(OutputDir);
            DirDCM=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'DwiRaw',filesep,Cfg.SubjectID{i},filesep,'*']); %Revised by YAN Chao-Gan 100130. %DirDCM=dir([Cfg.WorkingDir,filesep,'FunRaw',filesep,Cfg.SubjectID{i},filesep,'*.*']);
            if strcmpi(DirDCM(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
                StartIndex=4;
            else
                StartIndex=3;
            end
            InputFilename=[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'DwiRaw',filesep,Cfg.SubjectID{i},filesep,DirDCM(StartIndex).name];

            %YAN Chao-Gan 120817.
            y_Call_dcm2nii(InputFilename, OutputDir, 'DefaultINI');

            fprintf(['Converting Dwi Images:',Cfg.SubjectID{i},' OK']);
        end
        fprintf('\n');
    end
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


%Get ready for later freesurfer usage.
if ispc
    CommandInit=sprintf('docker run -i --rm -v %s:/opt/freesurfer/license.txt -v %s:/data ', fullfile(DPABIPath, 'DPABISurf', 'FreeSurferLicense', 'license.txt'), Cfg.WorkingDir); %YAN Chao-Gan, 181214. Remove -t because there is a tty issue in windows
else
    CommandInit=sprintf('docker run -ti --rm -v %s:/opt/freesurfer/license.txt -v %s:/data ', fullfile(DPABIPath, 'DPABISurf', 'FreeSurferLicense', 'license.txt'), Cfg.WorkingDir); %YAN Chao-Gan, 181214. Remove -t because there is a tty issue in windows
end

SubjectIDString=[];
for i=1:Cfg.SubjectNum
    SubjectIDString = sprintf('%s %s',SubjectIDString,Cfg.SubjectID{i});
end






%Preprocessing T1 image with fastsurfer
if (Cfg.Isfastsurfer==1)
    % Let's stop parpool before entering fastsurfer

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
    

    
    %!docker run -ti --rm -v /mnt/Data45/RfMRILab/yan/YAN_Work/DPABIUpdating/Program/DPABI_V6.1_220101/DPABISurf/FreeSurferLicense/license.txt:/opt/freesurfer/license.txt -v /mnt/Data45/RfMRILab/yan/YAN_Work/DPABIUpdating/DPABISurf/FastSurferDev/Work/datatest2:/data  cgyan/dpabidev /opt/fastsurfer/run_fastsurfer.sh --fs_license /opt/freesurfer/license.txt --t1 /data/BIDS/sub-Sub001/anat/sub-Sub001_T1w.nii --sid sub-Sub001 --sd /data/freesurfer --threads 1


    if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
        Command=sprintf('parallel -j %g /opt/fastsurfer/run_fastsurfer.sh --fs_license /opt/freesurfer/license.txt --surfreg --sd %s/freesurfer', Cfg.ParallelWorkersNumber,Cfg.WorkingDir);
    else
        Command=sprintf('%s cgyan/fastsurfer parallel -j %g /fastsurfer/run_fastsurfer.sh --fs_license /opt/freesurfer/license.txt --surfreg --sd /data/freesurfer', CommandInit, Cfg.ParallelWorkersNumber );
    end

    if Cfg.ParallelWorkersNumber~=0
        Command = sprintf('%s --threads 1', Command);
    end

    DirSessions=dir([Cfg.WorkingDir,filesep,'BIDS',filesep,Cfg.SubjectID{1},filesep,'ses*']);
    if length(DirSessions)==0
        if exist([Cfg.WorkingDir,filesep,'BIDS',filesep,Cfg.SubjectID{1},filesep,'anat',filesep,Cfg.SubjectID{1},'_T1w.nii.gz'])
            if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
                Command = sprintf('%s --t1 %s/BIDS/{1}/anat/{1}_T1w.nii.gz', Command,Cfg.WorkingDir); %Specify the T1 image for fastsurfer
            else
                Command = sprintf('%s --t1 /data/BIDS/{1}/anat/{1}_T1w.nii.gz', Command); %Specify the T1 image for fastsurfer
            end
        elseif exist([Cfg.WorkingDir,filesep,'BIDS',filesep,Cfg.SubjectID{1},filesep,'anat',filesep,Cfg.SubjectID{1},'_T1w.nii'])
            if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
                Command = sprintf('%s --t1 %s/BIDS/{1}/anat/{1}_T1w.nii', Command,Cfg.WorkingDir); %Specify the T1 image for fastsurfer
            else
                Command = sprintf('%s --t1 /data/BIDS/{1}/anat/{1}_T1w.nii', Command); %Specify the T1 image for fastsurfer
            end
        else
            error([Cfg.WorkingDir,filesep,'BIDS',filesep,Cfg.SubjectID{1},filesep,'anat',filesep,Cfg.SubjectID{1},'_T1w.nii or .nii.gz does not exist!'])
        end
    else
        if exist([Cfg.WorkingDir,filesep,'BIDS',filesep,Cfg.SubjectID{1},filesep,'ses-1',filesep,'anat',filesep,Cfg.SubjectID{1},'_ses-1_T1w.nii.gz'])
            if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
                Command = sprintf('%s --t1 %s/BIDS/{1}/ses-1/anat/{1}_ses-1_T1w.nii.gz', Command,Cfg.WorkingDir); %Specify the T1 image for fastsurfer
            else
                Command = sprintf('%s --t1 /data/BIDS/{1}/ses-1/anat/{1}_ses-1_T1w.nii.gz', Command); %Specify the T1 image for fastsurfer
            end
        elseif exist([Cfg.WorkingDir,filesep,'BIDS',filesep,Cfg.SubjectID{1},filesep,'ses-1',filesep,'anat',filesep,Cfg.SubjectID{1},'_ses-1_T1w.nii'])
            if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
                Command = sprintf('%s --t1 %s/BIDS/{1}/ses-1/anat/{1}_ses-1_T1w.nii', Command,Cfg.WorkingDir); %Specify the T1 image for fastsurfer
            else
                Command = sprintf('%s --t1 /data/BIDS/{1}/ses-1/anat/{1}_ses-1_T1w.nii', Command); %Specify the T1 image for fastsurfer
            end
        else
            error([Cfg.WorkingDir,filesep,'BIDS',filesep,Cfg.SubjectID{1},filesep,'ses-1',filesep,'anat',filesep,Cfg.SubjectID{1},'_ses-1_T1w.nii or .nii.gz does not exist!'])
        end
    end



    Command = sprintf('%s --sid {1} ::: %s', Command, SubjectIDString);

    fprintf('Preprocessing T1 image with fastsurfer, this process is very time consuming, please be patient...\n');

    system(Command);

end








%Preprocessing with fmriprep
if (Cfg.Isfmriprep==1)
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
    

    %YAN Chao-Gan, 211102. In case the TR info in NIfTI header is incorrect.
    if Cfg.TR~=0
        DirSessions=dir([Cfg.WorkingDir,filesep,'BIDS',filesep,Cfg.SubjectID{1,1},filesep,'ses*']);
        if length(DirSessions)==0
            parfor i=1:Cfg.SubjectNum
                DirFile=dir([Cfg.WorkingDir,filesep,'BIDS',filesep,Cfg.SubjectID{i},filesep,'func',filesep,'*.nii*']);
                [Data Header]=y_Read([Cfg.WorkingDir,filesep,'BIDS',filesep,Cfg.SubjectID{i},filesep,'func',filesep,DirFile(1).name]);
                try
                    if Header.private.timing.tspace ~= Cfg.TR
                        Header.private.timing.tspace=Cfg.TR;
                        Header.pinfo=[1;0;0]; Header.dt=[16,0];
                        [Path, fileN, extn] = fileparts(DirFile(1).name);
                        if strcmpi(extn,'.gz')
                            delete([Cfg.WorkingDir,filesep,'BIDS',filesep,Cfg.SubjectID{i},filesep,'func',filesep,DirFile(1).name])
                            DirFile(1).name=DirFile(1).name(1:end-3);
                        end
                        y_Write(Data,Header,[Cfg.WorkingDir,filesep,'BIDS',filesep,Cfg.SubjectID{i},filesep,'func',filesep,DirFile(1).name]);
                    end
                catch
                    Header.private.timing.tspace=Cfg.TR;
                    Header.pinfo=[1;0;0]; Header.dt=[16,0];
                    [Path, fileN, extn] = fileparts(DirFile(1).name);
                    if strcmpi(extn,'.gz')
                        delete([Cfg.WorkingDir,filesep,'BIDS',filesep,Cfg.SubjectID{i},filesep,'func',filesep,DirFile(1).name])
                        DirFile(1).name=DirFile(1).name(1:end-3);
                    end
                    y_Write(Data,Header,[Cfg.WorkingDir,filesep,'BIDS',filesep,Cfg.SubjectID{i},filesep,'func',filesep,DirFile(1).name]);
                end
            end
            
        else
            for iFunSession=1:Cfg.FunctionalSessionNumber
                parfor i=1:Cfg.SubjectNum
                    DirFile=dir([Cfg.WorkingDir,filesep,'BIDS',filesep,Cfg.SubjectID{i},filesep,DirSessions(iFunSession).name,filesep,'func',filesep,'*.nii*']);
                    [Data Header]=y_Read([Cfg.WorkingDir,filesep,'BIDS',filesep,Cfg.SubjectID{i},filesep,DirSessions(iFunSession).name,filesep,'func',filesep,DirFile(1).name]);
                    try
                        if Header.private.timing.tspace ~= Cfg.TR
                            Header.private.timing.tspace=Cfg.TR;
                            Header.pinfo=[1;0;0]; Header.dt=[16,0];
                            [Path, fileN, extn] = fileparts(DirFile(1).name);
                            if strcmpi(extn,'.gz')
                                delete([Cfg.WorkingDir,filesep,'BIDS',filesep,Cfg.SubjectID{i},filesep,DirSessions(iFunSession).name,filesep,'func',filesep,DirFile(1).name])
                                DirFile(1).name=DirFile(1).name(1:end-3);
                            end
                            y_Write(Data,Header,[Cfg.WorkingDir,filesep,'BIDS',filesep,Cfg.SubjectID{i},filesep,DirSessions(iFunSession).name,filesep,'func',filesep,DirFile(1).name]);
                        end
                    catch
                        Header.private.timing.tspace=Cfg.TR;
                        Header.pinfo=[1;0;0]; Header.dt=[16,0];
                        [Path, fileN, extn] = fileparts(DirFile(1).name);
                        if strcmpi(extn,'.gz')
                            delete([Cfg.WorkingDir,filesep,'BIDS',filesep,Cfg.SubjectID{i},filesep,DirSessions(iFunSession).name,filesep,'func',filesep,DirFile(1).name])
                            DirFile(1).name=DirFile(1).name(1:end-3);
                        end
                        y_Write(Data,Header,[Cfg.WorkingDir,filesep,'BIDS',filesep,Cfg.SubjectID{i},filesep,DirSessions(iFunSession).name,filesep,'func',filesep,DirFile(1).name]);
                    end
                end
            end
        end
    end
    
    
    
    if ~exist([Cfg.WorkingDir,filesep,'fmriprep'],'dir') % If it's the first time to run fmriprep
        
        %Copy fsaverage and fsaverage5 %YAN Chao-Gan, 221018.
        mkdir(fullfile(Cfg.WorkingDir,'fmriprep','sourcedata','freesurfer'));
        if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
            Command=sprintf('cp -rf /opt/freesurfer/subjects/fsaverage %s/fmriprep/sourcedata/freesurfer/fsaverage', Cfg.WorkingDir);
        else
            Command=sprintf('%s cgyan/dpabi cp -rf /opt/freesurfer/subjects/fsaverage /data/fmriprep/sourcedata/freesurfer/fsaverage', CommandInit);
        end
        system(Command);
        if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
            Command=sprintf('cp -rf /opt/freesurfer/subjects/fsaverage5 %s/fmriprep/sourcedata/freesurfer/fsaverage5', Cfg.WorkingDir);
        else
            Command=sprintf('%s cgyan/dpabi cp -rf /opt/freesurfer/subjects/fsaverage5 /data/fmriprep/sourcedata/freesurfer/fsaverage5', CommandInit);
        end
        system(Command);

        
        
        if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
            Command=sprintf('export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/fsl-6.0.5.1/lib && parallel -j %g /opt/conda/bin/fmriprep %s/BIDS %s/fmriprep participant --resource-monitor', Cfg.ParallelWorkersNumber, Cfg.WorkingDir, Cfg.WorkingDir);
        else
            Command=sprintf('%s cgyan/dpabi parallel -j %g /opt/conda/bin/fmriprep /data/BIDS /data/fmriprep participant --resource-monitor', CommandInit, Cfg.ParallelWorkersNumber);
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
        if strcmpi(Cfg.Normalize.VoxelSize(end-1:end),'mm')
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
        
        fprintf('Preprocessing with fmriprep, this process is very time consuming, please be patient...\n');
        
        system(Command);
    end
    
    %Check subjects failed fmriprep and re-run %YAN Chao-Gan, 200218
    [FailedID WaitingID SuccessID]=y_ReRunfmriprepFailedSubjects(Cfg,Cfg.WorkingDir,Cfg.SubjectID);
%     while ~isempty(WaitingID)
%         [FailedID WaitingID SuccessID]=y_ReRunfmriprepFailedSubjects(Cfg,Cfg.WorkingDir,Cfg.SubjectID);
%     end
    if ~isempty(FailedID)
        fprintf(['\nError: These subjects have always failed run fmriprep, please check the raw data and the logs:\n']);
        disp(FailedID)
        error('Error detected during running fmriprep, please check the log files for the above subjects!');
    end
    if ~isempty(WaitingID)
        error('Error detected during running fmriprep, please check!');
    end
    
    
    if exist([Cfg.WorkingDir,filesep,'fmriprep',filesep,'sourcedata'],'dir')
        if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
            Command=sprintf('mv %s/fmriprep/sourcedata/freesurfer %s/freesurfer', Cfg.WorkingDir, Cfg.WorkingDir);
        else
            Command=sprintf('%s cgyan/dpabi mv /data/fmriprep/sourcedata/freesurfer /data/freesurfer', CommandInit);
        end
        system(Command);
        
        if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
            Command=sprintf('rm -rf %s/fmriprep/sourcedata', Cfg.WorkingDir);
        else
            Command=sprintf('%s cgyan/dpabi rm -rf /data/fmriprep/sourcedata', CommandInit);
        end
        system(Command);

    end
    

    if ~(isdeployed && (isunix && (~ismac))) % Give permission
        Command=sprintf('%s cgyan/dpabi chmod -R 777 /data/fmriprep/', CommandInit);
        system(Command);
    end
    
    Cfg.StartingDirName = 'fmriprep';
end


if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
    CommandInit=sprintf('export SUBJECTS_DIR=%s/freesurfer && ', Cfg.WorkingDir);
    CommandParallel=sprintf('%s parallel -j %g', CommandInit, Cfg.ParallelWorkersNumber);
    WorkingDir=Cfg.WorkingDir;
else
    CommandInit=sprintf('%s -e SUBJECTS_DIR=/data/freesurfer cgyan/dpabi', CommandInit);
    CommandParallel=sprintf('%s parallel -j %g', CommandInit, Cfg.ParallelWorkersNumber );
    WorkingDir='/data';
end


%Organize the results generated by fmriprep
if (Cfg.IsOrganizefmriprepResults==1)
    
    if ~exist([Cfg.WorkingDir,filesep,'freesurfer',filesep,'fsaverage'],'dir') %Check if /data/freesurfer/fsaverage exist
        if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
            Command=sprintf('cp -rf /opt/freesurfer/subjects/fsaverage %s/freesurfer/fsaverage', Cfg.WorkingDir);
        else
            Command=sprintf('%s cp -rf /opt/freesurfer/subjects/fsaverage /data/freesurfer/fsaverage', CommandInit);
        end
        system(Command);
    end
    
    if ~exist([Cfg.WorkingDir,filesep,'freesurfer',filesep,'fsaverage5'],'dir') %Check if /data/freesurfer/fsaverage5 exist
        if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
            Command=sprintf('cp -rf /opt/freesurfer/subjects/fsaverage5 %s/freesurfer/fsaverage5', Cfg.WorkingDir);
        else
            Command=sprintf('%s cp -rf /opt/freesurfer/subjects/fsaverage5 /data/freesurfer/fsaverage5', CommandInit);
        end
        system(Command);
    end
    
    y_Organize_fmriprep(Cfg);
    if Cfg.IsBasedOnFunSurf==1
        Cfg.StartingDirName = 'FunSurf';
    else
        Cfg.StartingDirName = 'FunSurfW';
    end
end

Cfg.StartingDirName_Volume = ['FunVolu',Cfg.StartingDirName(8:end)];




% Segment Subregions with freesurfer 7.3+
if (Cfg.IsSegmentSubregions==1)
    if ispc
        CommandTemp=sprintf('docker run -i --rm -v %s:/usr/local/freesurfer/7.3.2/license.txt -v %s:/data ', fullfile(DPABIPath, 'DPABISurf', 'FreeSurferLicense', 'license.txt'), Cfg.WorkingDir);
    else
        CommandTemp=sprintf('docker run -ti --rm -v %s:/usr/local/freesurfer/7.3.2/license.txt -v %s:/data ', fullfile(DPABIPath, 'DPABISurf', 'FreeSurferLicense', 'license.txt'), Cfg.WorkingDir);
    end

    if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
        Command=sprintf('export SUBJECTS_DIR=%s/freesurfer && parallel -j %g segment_subregions thalamus --cross {1} ::: %s', Cfg.WorkingDir,Cfg.ParallelWorkersNumber, SubjectIDString);
    else
        Command=sprintf('%s -e SUBJECTS_DIR=/data/freesurfer cgyan/freesurfer parallel -j %g segment_subregions thalamus --cross {1} ::: %s', CommandTemp, Cfg.ParallelWorkersNumber,SubjectIDString);
    end
    fprintf('Segment thalamus subregions with freesurfer, please be patient...\n');
    system(Command);


    if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
        Command=sprintf('export SUBJECTS_DIR=%s/freesurfer && parallel -j %g segment_subregions hippo-amygdala --cross {1} ::: %s', Cfg.WorkingDir,Cfg.ParallelWorkersNumber, SubjectIDString);
    else
        Command=sprintf('%s -e SUBJECTS_DIR=/data/freesurfer cgyan/freesurfer parallel -j %g segment_subregions hippo-amygdala --cross {1} ::: %s', CommandTemp, Cfg.ParallelWorkersNumber,SubjectIDString);
    end
    fprintf('Segment hippo-amygdala subregions with freesurfer, please be patient...\n');
    system(Command);

    if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
        Command=sprintf('export SUBJECTS_DIR=%s/freesurfer && parallel -j %g segment_subregions brainstem --cross {1} ::: %s', Cfg.WorkingDir,Cfg.ParallelWorkersNumber, SubjectIDString);
    else
        Command=sprintf('%s -e SUBJECTS_DIR=/data/freesurfer cgyan/freesurfer parallel -j %g segment_subregions brainstem --cross {1} ::: %s', CommandTemp, Cfg.ParallelWorkersNumber,SubjectIDString);
    end
    fprintf('Segment brainstem subregions with freesurfer, please be patient...\n');
    system(Command);

    
    %Write table
    SegTable=[];
    for i=1:Cfg.SubjectNum
        
        SubjectID={Cfg.SubjectID{i}};
        OneSub=table(SubjectID);
        
        SegVolume=readtable(fullfile(Cfg.WorkingDir,'freesurfer',Cfg.SubjectID{i},'mri','lh.hippoSfVolumes.txt'),'ReadRowNames',true);
        SegVolume=rows2vars(SegVolume);
        SegVolume=removevars(SegVolume,'OriginalVariableNames');
        VarName=SegVolume.Properties.VariableNames;
        VarName = append('Left-',VarName);
        SegVolume=renamevars(SegVolume,1:width(SegVolume),VarName);
        SegVolume.SubjectID={Cfg.SubjectID{i}};
        OneSub=join(OneSub,SegVolume);
        
        SegVolume=readtable(fullfile(Cfg.WorkingDir,'freesurfer',Cfg.SubjectID{i},'mri','rh.hippoSfVolumes.txt'),'ReadRowNames',true);
        SegVolume=rows2vars(SegVolume);
        SegVolume=removevars(SegVolume,'OriginalVariableNames');
        VarName=SegVolume.Properties.VariableNames;
        VarName = append('Right-',VarName);
        SegVolume=renamevars(SegVolume,1:width(SegVolume),VarName);
        SegVolume.SubjectID={Cfg.SubjectID{i}};
        OneSub=join(OneSub,SegVolume);
        
        SegVolume=readtable(fullfile(Cfg.WorkingDir,'freesurfer',Cfg.SubjectID{i},'mri','lh.amygNucVolumes.txt'),'ReadRowNames',true);
        SegVolume=rows2vars(SegVolume);
        SegVolume=removevars(SegVolume,'OriginalVariableNames');
        VarName=SegVolume.Properties.VariableNames;
        VarName = append('Left-',VarName);
        SegVolume=renamevars(SegVolume,1:width(SegVolume),VarName);
        SegVolume.SubjectID={Cfg.SubjectID{i}};
        OneSub=join(OneSub,SegVolume);
        
        SegVolume=readtable(fullfile(Cfg.WorkingDir,'freesurfer',Cfg.SubjectID{i},'mri','rh.amygNucVolumes.txt'),'ReadRowNames',true);
        SegVolume=rows2vars(SegVolume);
        SegVolume=removevars(SegVolume,'OriginalVariableNames');
        VarName=SegVolume.Properties.VariableNames;
        VarName = append('Right-',VarName);
        SegVolume=renamevars(SegVolume,1:width(SegVolume),VarName);
        SegVolume.SubjectID={Cfg.SubjectID{i}};
        OneSub=join(OneSub,SegVolume);
        
        SegVolume=readtable(fullfile(Cfg.WorkingDir,'freesurfer',Cfg.SubjectID{i},'mri','ThalamicNuclei.volumes.txt'),'ReadRowNames',true);
        SegVolume=rows2vars(SegVolume);
        SegVolume=removevars(SegVolume,'OriginalVariableNames');
        SegVolume.SubjectID={Cfg.SubjectID{i}};
        OneSub=join(OneSub,SegVolume);
        
        SegVolume=readtable(fullfile(Cfg.WorkingDir,'freesurfer',Cfg.SubjectID{i},'mri','brainstemSsLabels.volumes.txt'),'ReadRowNames',true);
        SegVolume=rows2vars(SegVolume);
        SegVolume=removevars(SegVolume,'OriginalVariableNames');
        SegVolume.SubjectID={Cfg.SubjectID{i}};
        OneSub=join(OneSub,SegVolume);
        
        SegTable=[SegTable;OneSub];
    end
 
    writetable(SegTable,fullfile(Cfg.WorkingDir,'Results','AnatVolu','Anat_Segment_Subregions_Volume.csv'),'Delimiter','\t');
    
    
     %Convert to .nii
     Command = sprintf('%s parallel -j %g mri_convert %s/freesurfer/{1}/mri/lh.hippoAmygLabels.CA.FSvoxelSpace.mgz %s/Results/AnatVolu/T1wSpace/{1}/{1}_Subregions_lh.hippoAmygLabels.CA.FSvoxelSpace.nii.gz ::: %s', ...
         CommandInit, Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,SubjectIDString);
     system(Command);
     Command = sprintf('%s parallel -j %g mri_convert %s/freesurfer/{1}/mri/lh.hippoAmygLabels.FS60.FSvoxelSpace.mgz %s/Results/AnatVolu/T1wSpace/{1}/{1}_Subregions_lh.hippoAmygLabels.FS60.FSvoxelSpace.nii.gz ::: %s', ...
         CommandInit, Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,SubjectIDString);
     system(Command);
     Command = sprintf('%s parallel -j %g mri_convert %s/freesurfer/{1}/mri/lh.hippoAmygLabels.HBT.FSvoxelSpace.mgz %s/Results/AnatVolu/T1wSpace/{1}/{1}_Subregions_lh.hippoAmygLabels.HBT.FSvoxelSpace.nii.gz ::: %s', ...
         CommandInit, Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,SubjectIDString);
     system(Command);
     Command = sprintf('%s parallel -j %g mri_convert %s/freesurfer/{1}/mri/lh.hippoAmygLabels.FSvoxelSpace.mgz %s/Results/AnatVolu/T1wSpace/{1}/{1}_Subregions_lh.hippoAmygLabels.FSvoxelSpace.nii.gz ::: %s', ...
         CommandInit, Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,SubjectIDString);
     system(Command);
     
     Command = sprintf('%s parallel -j %g mri_convert %s/freesurfer/{1}/mri/rh.hippoAmygLabels.CA.FSvoxelSpace.mgz %s/Results/AnatVolu/T1wSpace/{1}/{1}_Subregions_rh.hippoAmygLabels.CA.FSvoxelSpace.nii.gz ::: %s', ...
         CommandInit, Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,SubjectIDString);
     system(Command);
     Command = sprintf('%s parallel -j %g mri_convert %s/freesurfer/{1}/mri/rh.hippoAmygLabels.FS60.FSvoxelSpace.mgz %s/Results/AnatVolu/T1wSpace/{1}/{1}_Subregions_rh.hippoAmygLabels.FS60.FSvoxelSpace.nii.gz ::: %s', ...
         CommandInit, Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,SubjectIDString);
     system(Command);
     Command = sprintf('%s parallel -j %g mri_convert %s/freesurfer/{1}/mri/rh.hippoAmygLabels.HBT.FSvoxelSpace.mgz %s/Results/AnatVolu/T1wSpace/{1}/{1}_Subregions_rh.hippoAmygLabels.HBT.FSvoxelSpace.nii.gz ::: %s', ...
         CommandInit, Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,SubjectIDString);
     system(Command);
     Command = sprintf('%s parallel -j %g mri_convert %s/freesurfer/{1}/mri/rh.hippoAmygLabels.FSvoxelSpace.mgz %s/Results/AnatVolu/T1wSpace/{1}/{1}_Subregions_rh.hippoAmygLabels.FSvoxelSpace.nii.gz ::: %s', ...
         CommandInit, Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,SubjectIDString);
     system(Command);

     Command = sprintf('%s parallel -j %g mri_convert %s/freesurfer/{1}/mri/ThalamicNuclei.FSvoxelSpace.mgz %s/Results/AnatVolu/T1wSpace/{1}/{1}_Subregions_ThalamicNuclei.FSvoxelSpace.nii.gz ::: %s', ...
         CommandInit, Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,SubjectIDString);
     system(Command);
     Command = sprintf('%s parallel -j %g mri_convert %s/freesurfer/{1}/mri/brainstemSsLabels.FSvoxelSpace.mgz %s/Results/AnatVolu/T1wSpace/{1}/{1}_Subregions_brainstemSsLabels.FSvoxelSpace.nii.gz ::: %s', ...
         CommandInit, Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,SubjectIDString);
     system(Command);

end





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



%%%%%%%
%Genereated the masks based on Segmentation results
%Reslice WM and CSF masks to functional space.
% YAN Chao-Gan, 221205.
if (Cfg.IsCovremove==1) && (Cfg.IsBasedOnFunSurf==1) %(strcmpi(Cfg.Covremove.Timing,'AfterNormalize')))
    if ~(2==exist([Cfg.WorkingDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_ThrdMask_',Cfg.SubjectID{1},'_WM.nii'],'file'))
        if ~(7==exist([Cfg.WorkingDir,filesep,'Masks',filesep,'SegmentationMasks'],'dir'))
            mkdir([Cfg.WorkingDir,filesep,'Masks',filesep,'SegmentationMasks']);
        end
        % If have not generated previously.
        parfor i=1:Cfg.SubjectNum
            RefFile=[Cfg.WorkingDir,filesep,'Masks',filesep,'AutoMasks',filesep,Cfg.SubjectID{i},'_task-rest_space-T1w_desc-brain_mask.nii.gz'];

            [RefData,RefVox,RefHeader]=y_ReadRPI(RefFile,1);

            %Use new logic according to fmriprep changes
            DirFile=dir(fullfile(Cfg.WorkingDir,'Results','AnatVolu','T1wSpace',Cfg.SubjectID{i},[Cfg.SubjectID{i},'*label-WM_probseg.nii*']));
            File=fullfile(Cfg.WorkingDir,'Results','AnatVolu','T1wSpace',Cfg.SubjectID{i},DirFile(1).name);
            [OutVolume OutHead] = y_Reslice(File,[Cfg.WorkingDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_',Cfg.SubjectID{i},'_WM.nii'],RefVox,1, RefFile);
            OutHead.pinfo = [1;0;0]; OutHead.dt    =[16,0];
            y_Write(OutVolume,OutHead,[Cfg.WorkingDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_',Cfg.SubjectID{i},'_WM.nii']);
            OutHead.pinfo = [1;0;0]; OutHead.dt    =[2,0];
            y_Write(OutVolume>Cfg.Covremove.WM.MaskThreshold,OutHead,[Cfg.WorkingDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_ThrdMask_',Cfg.SubjectID{i},'_WM.nii']);
            
            %Use new logic according to fmriprep changes
            DirFile=dir(fullfile(Cfg.WorkingDir,'Results','AnatVolu','T1wSpace',Cfg.SubjectID{i},[Cfg.SubjectID{i},'*label-CSF_probseg.nii*']));
            File=fullfile(Cfg.WorkingDir,'Results','AnatVolu','T1wSpace',Cfg.SubjectID{i},DirFile(1).name);
            [OutVolume OutHead] = y_Reslice(File,[Cfg.WorkingDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_',Cfg.SubjectID{i},'_CSF.nii'],RefVox,1, RefFile);
            OutHead.pinfo = [1;0;0]; OutHead.dt    =[16,0];
            y_Write(OutVolume,OutHead,[Cfg.WorkingDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_',Cfg.SubjectID{i},'_CSF.nii']);
            OutHead.pinfo = [1;0;0]; OutHead.dt    =[2,0];
            y_Write(OutVolume>Cfg.Covremove.CSF.MaskThreshold,OutHead,[Cfg.WorkingDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_ThrdMask_',Cfg.SubjectID{i},'_CSF.nii']);
        end
    end
end




%%%%%%%
%Genereated the masks based on Segmentation results
%Reslice WM and CSF masks to MNI functional space.
if (Cfg.IsCovremove==1) && (Cfg.IsBasedOnFunSurf==0) %&& (strcmpi(Cfg.Covremove.Timing,'AfterNormalize')))
    if ~(2==exist([Cfg.WorkingDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'MNIFunSpace_ThrdMask_',Cfg.SubjectID{1},'_WM.nii'],'file'))
        if ~(7==exist([Cfg.WorkingDir,filesep,'Masks',filesep,'SegmentationMasks'],'dir'))
            mkdir([Cfg.WorkingDir,filesep,'Masks',filesep,'SegmentationMasks']);
        end
        % If have not generated previously.
        parfor i=1:Cfg.SubjectNum
            RefFile=dir([Cfg.WorkingDir,filesep,Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i},filesep,'*.img']);
            if isempty(RefFile)  %YAN Chao-Gan, 120827. Also support .nii.gz files.
                RefFile=dir([Cfg.WorkingDir,filesep,Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i},filesep,'*.nii.gz']);
            end
            if isempty(RefFile)  %YAN Chao-Gan, 111114. Also support .nii files.
                RefFile=dir([Cfg.WorkingDir,filesep,Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i},filesep,'*.nii']);
            end
            RefFile=[Cfg.WorkingDir,filesep,Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i},filesep,RefFile(1).name];
            [RefData,RefVox,RefHeader]=y_ReadRPI(RefFile,1);

            %Use new logic according to fmriprep changes
            DirFile=dir(fullfile(Cfg.WorkingDir,'Results','AnatVolu','MNISpace',Cfg.SubjectID{i},[Cfg.SubjectID{i},'*_space-MNI152NLin2009cAsym_*label-WM_probseg.nii*']));
            File=fullfile(Cfg.WorkingDir,'Results','AnatVolu','MNISpace',Cfg.SubjectID{i},DirFile(1).name);
            [OutVolume OutHead] = y_Reslice(File,[Cfg.WorkingDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'MNIFunSpace_',Cfg.SubjectID{i},'_WM.nii'],RefVox,1, RefFile);
            OutHead.pinfo = [1;0;0]; OutHead.dt    =[16,0];
            y_Write(OutVolume,OutHead,[Cfg.WorkingDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'MNIFunSpace_',Cfg.SubjectID{i},'_WM.nii']);
            OutHead.pinfo = [1;0;0]; OutHead.dt    =[2,0];
            y_Write(OutVolume>Cfg.Covremove.WM.MaskThreshold,OutHead,[Cfg.WorkingDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'MNIFunSpace_ThrdMask_',Cfg.SubjectID{i},'_WM.nii']);
            
            %Use new logic according to fmriprep changes
            DirFile=dir(fullfile(Cfg.WorkingDir,'Results','AnatVolu','MNISpace',Cfg.SubjectID{i},[Cfg.SubjectID{i},'*_space-MNI152NLin2009cAsym_*label-CSF_probseg.nii*']));
            File=fullfile(Cfg.WorkingDir,'Results','AnatVolu','MNISpace',Cfg.SubjectID{i},DirFile(1).name);
            [OutVolume OutHead] = y_Reslice(File,[Cfg.WorkingDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'MNIFunSpace_',Cfg.SubjectID{i},'_CSF.nii'],RefVox,1, RefFile);
            OutHead.pinfo = [1;0;0]; OutHead.dt    =[16,0];
            y_Write(OutVolume,OutHead,[Cfg.WorkingDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'MNIFunSpace_',Cfg.SubjectID{i},'_CSF.nii']);
            OutHead.pinfo = [1;0;0]; OutHead.dt    =[2,0];
            y_Write(OutVolume>Cfg.Covremove.CSF.MaskThreshold,OutHead,[Cfg.WorkingDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'MNIFunSpace_ThrdMask_',Cfg.SubjectID{i},'_CSF.nii']);
        end
    end
end


%%%%%%%%
% Warp the common-used masks into original space
% YAN Chao-Gan, 221205.
if (Cfg.IsBasedOnFunSurf==1) && ((Cfg.IsCalALFF==1)||(Cfg.IsCovremove==1)||(Cfg.IsCalReHo==1)||(Cfg.IsCalDegreeCentrality==1)||(Cfg.IsCalFC==1)) 
    MasksName{1,1}=[TemplatePath,filesep,'BrainMask_05_91x109x91.img'];
    MasksName{2,1}=[TemplatePath,filesep,'CsfMask_07_91x109x91.img'];
    MasksName{3,1}=[TemplatePath,filesep,'WhiteMask_09_91x109x91.img'];
    MasksName{4,1}=[TemplatePath,filesep,'GreyMask_02_91x109x91.img'];
    if (isfield(Cfg,'MaskFileVolu')) && (~isempty(Cfg.MaskFileVolu)) && (~isequal(Cfg.MaskFileVolu, 'Default'))
        MasksName{5,1}=Cfg.MaskFileVolu;
    end
    if ~(7==exist([Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_FunSpace'],'dir'))
        mkdir([Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_FunSpace']);
    end

    for i=1:Cfg.SubjectNum

        RefFile=[Cfg.WorkingDir,filesep,'Masks',filesep,'AutoMasks',filesep,Cfg.SubjectID{i},'_task-rest_space-T1w_desc-brain_mask.nii.gz'];

        [RefData,RefVox,RefHeader]=y_ReadRPI(RefFile,1);

        TransformFile=[Cfg.WorkingDir,filesep,'fmriprep',filesep,Cfg.SubjectID{i},filesep,'anat',filesep,Cfg.SubjectID{i},'_from-MNI152NLin2009cAsym_to-T1w_mode-image_xfm.h5'];
        Interpolation='MultiLabel';
        Dimensionality=3;
        InputImageType=0;
        DefaultValue=0;
        IsFloat0=0;
        DockerName='cgyan/dpabi';

        for iMask=1:length(MasksName)
            iROIDef = MasksName{iMask};

            if exist(iROIDef,'file')==2 % MNI Mask files need to be warped
                SourceFile=iROIDef;
                [pathstr, name, ext] = fileparts(iROIDef);
                MaskName=[Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForFun',filesep,'Masks_FunSpace',filesep,'FunSpace_',Cfg.SubjectID{i},'_',name,'.nii'];
                fprintf('\nWarp Masks (%s) for "%s" to individual space by ANTs.\n',iROIDef, Cfg.SubjectID{i});
                y_WarpByANTs(SourceFile,MaskName,RefFile,TransformFile,Interpolation,Dimensionality,InputImageType,DefaultValue,IsFloat0,DockerName)
                %y_WarpByANTs(SourceFile,OutFile,RefFile,TransformFile,Interpolation,Dimensionality,InputImageType,DefaultValue,IsFloat0,DockerName)
                MaskName = replace(MaskName,Cfg.SubjectID{i},'{SubjectID}');
                MaskName = replace(MaskName,Cfg.WorkingDir,'{WorkingDir}');
                iROIDef=MaskName;
            elseif (ischar(iROIDef)) && ~isempty(strfind(iROIDef,'{SubjectID}')) % Process the individual ROI from an expression
                NewStrDef = replace(iROIDef,'{SubjectID}',Cfg.SubjectID{i});
                NewStrDef = replace(NewStrDef,'{WorkingDir}',Cfg.WorkingDir);
                if exist(NewStrDef,'file')==2
                    [MaskData,MaskVox,MaskHeader]=y_ReadRPI(NewStrDef);
                    if ~isequal(size(MaskData), size(RefData))
                        fprintf('\nReslice %s Mask (%s) for "%s" since the dimension of mask mismatched the dimension of the target data.\n',NewStrDef, Cfg.SubjectID{i});
                        [pathstr, name, ext] = fileparts(NewStrDef);
                        MaskName=[Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForFun',filesep,'Masks_FunSpace',filesep,'FunSpace_',Cfg.SubjectID{i},'_',name,'.nii'];
                        y_Reslice(NewStrDef,MaskName,[],0, RefFile);
                        MaskName = replace(MaskName,Cfg.SubjectID{i},'{SubjectID}');
                        MaskName = replace(MaskName,Cfg.WorkingDir,'{WorkingDir}');
                        iROIDef=MaskName;
                    end
                else
                    error(['The Mask File ',NewStrDef,' does not exist!'])
                end
            else
                error(['This Mask definition can not be processed: ',iROIDef])
            end
        end

        if (isequal(Cfg.MaskFileVolu, 'Default'))
            Cfg.MaskFileVolu = ['{WorkingDir}',filesep,'Masks',filesep, 'MasksForFun',filesep,'Masks_FunSpace',filesep,'FunSpace_{SubjectID}_BrainMask_05_91x109x91','.nii'];
        else
            Cfg.MaskFileVolu = iROIDef; %The final iROIDef is iMask==5, processed for user defined mask.
        end
    end
end



%%%%%%%%
% If don't need to Warp into original space, then check if the masks are appropriate and resample if not.
if (Cfg.IsBasedOnFunSurf==0) && ((Cfg.IsCalALFF==1)||(Cfg.IsCovremove==1)||(Cfg.IsCalReHo==1)||(Cfg.IsCalDegreeCentrality==1)||(Cfg.IsCalFC==1)) 
    MasksName{1,1}=[TemplatePath,filesep,'BrainMask_05_91x109x91.img'];
    MasksName{2,1}=[TemplatePath,filesep,'CsfMask_07_91x109x91.img'];
    MasksName{3,1}=[TemplatePath,filesep,'WhiteMask_09_91x109x91.img'];
    MasksName{4,1}=[TemplatePath,filesep,'GreyMask_02_91x109x91.img'];
    if (isfield(Cfg,'MaskFileVolu')) && (~isempty(Cfg.MaskFileVolu)) && (~isequal(Cfg.MaskFileVolu, 'Default'))
        MasksName{5,1}=Cfg.MaskFileVolu;
    end
    if ~(7==exist([Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_MNIFunSpace'],'dir'))
        mkdir([Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_MNIFunSpace']);
    end
    RefFile=dir([Cfg.WorkingDir,filesep,Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{1},filesep,'*.img']);
    if isempty(RefFile)  %YAN Chao-Gan, 120827. Also support .nii.gz files.
        RefFile=dir([Cfg.WorkingDir,filesep,Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{1},filesep,'*.nii.gz']);
    end
    if isempty(RefFile)  %YAN Chao-Gan, 111114. Also support .nii files.
        RefFile=dir([Cfg.WorkingDir,filesep,Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{1},filesep,'*.nii']);
    end
    RefFile=[Cfg.WorkingDir,filesep,Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{1},filesep,RefFile(1).name];
    [RefData,RefVox,RefHeader]=y_ReadRPI(RefFile,1);

    for iMask=1:length(MasksName)
        AMaskFilename = MasksName{iMask};
        fprintf('\nResample Masks (%s) to the resolution of functional images.\n',AMaskFilename);
        [pathstr, name, ext] = fileparts(AMaskFilename);
        ReslicedMaskName=[Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_MNIFunSpace',filesep,'AllResampled_',name,'.nii'];
        y_Reslice(AMaskFilename,ReslicedMaskName,RefVox,0, RefFile);
    end

    if (isequal(Cfg.MaskFileVolu, 'Default'))
        Cfg.MaskFileVolu = [Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_MNIFunSpace',filesep,'AllResampled_BrainMask_05_91x109x91.nii'];
    else
        [pathstr, name, ext] = fileparts(Cfg.MaskFileVolu);
        Cfg.MaskFileVolu = [Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_MNIFunSpace',filesep,'AllResampled_',name,'.nii'];
    end
end



%Deal with the other covariables mask: warp into original space
%YAN Chao-Gan, 221205
if (Cfg.IsCovremove==1) && (Cfg.IsBasedOnFunSurf==1)
    if ~isempty(Cfg.Covremove.OtherCovariatesROI)
        if ~(7==exist([Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_FunSpace'],'dir'))
            mkdir([Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_FunSpace']);
        end

        Suffix='OtherCovariateROI_'; %%!!! Change as in Function
        OtherCovariatesROIForEachSubject=cell(Cfg.SubjectNum,1);

        % Ball to mask
        AllSubjectROI=Cfg.Covremove.OtherCovariatesROI;
        for iROI=1:length(AllSubjectROI)
            if ~(7==exist([Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForFun',filesep, 'Masks_MNISpace'],'dir'))
                mkdir([Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForFun',filesep, 'Masks_MNISpace']);
            end
            if strcmpi(int2str(size(AllSubjectROI{iROI})),int2str([1, 4]))  %Sphere ROI definition: CenterX, CenterY, CenterZ, Radius
                ROIMaskName=[Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForFun',filesep, 'Masks_MNISpace',filesep,Suffix,'SphereMask_',num2str(iROI),'_Center_',num2str(AllSubjectROI{iROI}(1)),'_',num2str(AllSubjectROI{iROI}(2)),'_',num2str(AllSubjectROI{iROI}(3)),'_',num2str(AllSubjectROI{iROI}(4)),'.nii'];
                y_Sphere(AllSubjectROI{iROI}(1:3), AllSubjectROI{iROI}(4), [DPABIPath,filesep,'Templates',filesep,'aal.nii'], ROIMaskName);
                AllSubjectROI{iROI}=ROIMaskName;
            end
        end

        for i=1:Cfg.SubjectNum
            SubjectROI=AllSubjectROI;%%!!! Change as in Fuction
            
            % Set the reference image
            RefFile=[Cfg.WorkingDir,filesep,'Masks',filesep,'AutoMasks',filesep,Cfg.SubjectID{i},'_task-rest_space-T1w_desc-brain_mask.nii.gz'];
            [RefData,RefVox,RefHeader]=y_ReadRPI(RefFile,1);

            TransformFile=[Cfg.WorkingDir,filesep,'fmriprep',filesep,Cfg.SubjectID{i},filesep,'anat',filesep,Cfg.SubjectID{i},'_from-MNI152NLin2009cAsym_to-T1w_mode-image_xfm.h5'];
            Interpolation='MultiLabel';
            Dimensionality=3;
            InputImageType=0;
            DefaultValue=0;
            IsFloat0=0;
            DockerName='cgyan/dpabi';

            for iROI=1:length(SubjectROI)
                if exist(SubjectROI{iROI},'file')==2 % MNI Mask files need to be warped
                    [pathstr, name, ext] = fileparts(SubjectROI{iROI});
                    if (~strcmpi(ext, '.txt'))
                        SourceFile=SubjectROI{iROI};
                        MaskName=[Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForFun',filesep, 'Masks_FunSpace',filesep,Suffix,'MaskFile_',num2str(iROI),'_',Cfg.SubjectID{i},'.nii'];
                        fprintf('\nWarp Masks (%s) for "%s" to individual space by ANTs.\n',SourceFile, Cfg.SubjectID{i});
                        y_WarpByANTs(SourceFile,MaskName,RefFile,TransformFile,Interpolation,Dimensionality,InputImageType,DefaultValue,IsFloat0,DockerName)
                        %y_WarpByANTs(SourceFile,OutFile,RefFile,TransformFile,Interpolation,Dimensionality,InputImageType,DefaultValue,IsFloat0,DockerName)
                        SubjectROI{iROI}=MaskName;
                    end

                elseif (ischar(SubjectROI{iROI})) && ~isempty(strfind(SubjectROI{iROI},'{SubjectID}')) % Process the individual ROI from an expression
                    NewStrDef = replace(SubjectROI{iROI},'{SubjectID}',Cfg.SubjectID{i});
                    NewStrDef = replace(NewStrDef,'{WorkingDir}',Cfg.WorkingDir);
                    if exist(NewStrDef,'file')==2
                        [MaskData,MaskVox,MaskHeader]=y_ReadRPI(NewStrDef);
                        if ~isequal(size(MaskData), size(RefData))
                            fprintf('\nReslice %s Mask (%s) for "%s" since the dimension of mask mismatched the dimension of the target data.\n',Suffix,NewStrDef, Cfg.SubjectID{i});
                            ReslicedMaskName=[Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForFun',filesep, 'Masks_FunSpace',filesep,Suffix,'MaskFile_',num2str(iROI),'_',Cfg.SubjectID{i},'.nii'];
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
        
        Cfg.Covremove.OtherCovariatesROIForEachSubject = OtherCovariatesROIForEachSubject;
    end
end




%If don't need to Warp into original space, then resample the other covariables mask
if (Cfg.IsCovremove==1) && (Cfg.IsBasedOnFunSurf==0)
    if ~isempty(Cfg.Covremove.OtherCovariatesROI)
        if ~(7==exist([Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_MNIFunSpace'],'dir'))
            mkdir([Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_MNIFunSpace']);
        end

        Suffix='OtherCovariateROI_'; %%!!! Change as in Function
        % Ball to mask
        AllSubjectROI=Cfg.Covremove.OtherCovariatesROI;
        for iROI=1:length(AllSubjectROI)
            if ~(7==exist([Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForFun',filesep, 'Masks_MNISpace'],'dir'))
                mkdir([Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForFun',filesep, 'Masks_MNISpace']);
            end
            if strcmpi(int2str(size(AllSubjectROI{iROI})),int2str([1, 4]))  %Sphere ROI definition: CenterX, CenterY, CenterZ, Radius
                ROIMaskName=[Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForFun',filesep, 'Masks_MNISpace',filesep,Suffix,'SphereMask_',num2str(iROI),'_Center_',num2str(AllSubjectROI{iROI}(1)),'_',num2str(AllSubjectROI{iROI}(2)),'_',num2str(AllSubjectROI{iROI}(3)),'_',num2str(AllSubjectROI{iROI}(4)),'.nii'];
                y_Sphere(AllSubjectROI{iROI}(1:3), AllSubjectROI{iROI}(4), [DPABIPath,filesep,'Templates',filesep,'aal.nii'], ROIMaskName);
                AllSubjectROI{iROI}=ROIMaskName;
            end
        end

        % Check if masks appropriate %This can be used as a function!!! ONLY FOR RESAMPLE
        OtherCovariatesROIForEachSubject=cell(Cfg.SubjectNum,1);
        for i=1:Cfg.SubjectNum
            SubjectROI=AllSubjectROI;%%!!! Change as in Fuction
            
            % Set the reference image
            RefFile=dir([Cfg.WorkingDir,filesep,Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i},filesep,'*.img']);
            if isempty(RefFile)  %YAN Chao-Gan, 120827. Also support .nii.gz files.
                RefFile=dir([Cfg.WorkingDir,filesep,Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i},filesep,'*.nii.gz']);
            end
            if isempty(RefFile)  %YAN Chao-Gan, 111114. Also support .nii files.
                RefFile=dir([Cfg.WorkingDir,filesep,Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i},filesep,'*.nii']);
            end
            RefFile=[Cfg.WorkingDir,filesep,Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i},filesep,RefFile(1).name];
            [RefData,RefVox,RefHeader]=y_ReadRPI(RefFile,1);
            
            % Check if the ROI mask is appropriate
            for iROI=1:length(SubjectROI)
                AMaskFilename=SubjectROI{iROI};
                AMaskFilename = replace(AMaskFilename,'{SubjectID}',Cfg.SubjectID{i});
                AMaskFilename = replace(AMaskFilename,'{WorkingDir}',Cfg.WorkingDir);

                if exist(SubjectROI{iROI},'file')==2
                    [pathstr, name, ext] = fileparts(SubjectROI{iROI});
                    if (~strcmpi(ext, '.txt'))
                        [MaskData,MaskVox,MaskHeader]=y_ReadRPI(AMaskFilename);
                        if ~isequal(size(MaskData), size(RefData))
                            fprintf('\nReslice %s Mask (%s) for "%s" since the dimension of mask mismatched the dimension of the functional data.\n',Suffix,AMaskFilename, Cfg.SubjectID{i});
                            ReslicedMaskName=[Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_MNIFunSpace',filesep,Suffix,num2str(iROI),'_',Cfg.SubjectID{i},'.nii'];
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
        
        Cfg.Covremove.OtherCovariatesROIForEachSubject = OtherCovariatesROIForEachSubject;
    end
end


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


% Non-aggressively regressed out the covariates of ICA-AROMA noises.
if Cfg.NonAgressiveRegressICAAROMANoise==1
    for iFunSession=1:Cfg.FunctionalSessionNumber
        parfor i=1:Cfg.SubjectNum
            CovariablesDef=[];
            DirFile=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},'FunVoluWICAAROMANoise'],Cfg.SubjectID{i},'*-MELODIC_mixing.tsv'));
            DirFile=fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},'FunVoluWICAAROMANoise'],Cfg.SubjectID{i},DirFile(1).name);
            CovariablesDef.Regressors = DirFile;
            DirFile=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},'FunVoluWICAAROMANoise'],Cfg.SubjectID{i},'*_AROMAnoiseICs.csv'));
            DirFile=fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},'FunVoluWICAAROMANoise'],Cfg.SubjectID{i},DirFile(1).name);
            CovariablesDef.ICsToBeRejected = DirFile;

            %Non-agressively regressed out the covariates of ICA-AROMA noises.
            fprintf('\nNon-agressively regressed out the covariates of ICA-AROMA noises for subject %s %s.\n',Cfg.SubjectID{i},FunSessionPrefixSet{iFunSession});
            
            mkdir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,'I'],Cfg.SubjectID{i}));
            DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume],Cfg.SubjectID{i},'*.nii.gz'));
            if isempty(DirName)
                DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume],Cfg.SubjectID{i},'*.nii'));
            end
            
            InFile=fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume],Cfg.SubjectID{i},DirName(1).name);
            OutFile=fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,'I'],Cfg.SubjectID{i},DirName(1).name);
            if strcmp(OutFile(end-2:end),'.gz')
                OutFile=OutFile(1:end-3);
            end
            y_RegressOutCovariates_NonAggressive(InFile,CovariablesDef,OutFile,'');

            mkdir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,'I'],Cfg.SubjectID{i}));
            DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*_hemi-*.func.gii'));
            for iFile=1:length(DirName)
                InFile=fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},DirName(iFile).name);
                OutFile=fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,'I'],Cfg.SubjectID{i},DirName(iFile).name);
                y_RegressOutCovariates_NonAggressive(InFile,CovariablesDef,OutFile,'');
            end
        end
        fprintf('\n');
    end
    
    Cfg.StartingDirName=[Cfg.StartingDirName,'I']; %Now StartingDirName is with new suffix 'I'
    Cfg.StartingDirName_Volume=[Cfg.StartingDirName_Volume,'I']; %Now StartingDirName is with new suffix 'I'
end


%Remove the nuisance Covaribles ('AfterNormalize')
if (Cfg.IsCovremove==1) %&& (strcmpi(Cfg.Covremove.Timing,'AfterNormalize')) 
    %Remove the Covariables
    for iFunSession=1:Cfg.FunctionalSessionNumber
        parfor i=1:Cfg.SubjectNum
            CovariablesDef=[];
            %Polynomial trends
            %0: constant
            %1: constant + linear trend
            %2: constant + linear trend + quadratic trend.
            %3: constant + linear trend + quadratic trend + cubic trend.   ...
            CovariablesDef.polort = Cfg.Covremove.PolynomialTrend;
            
            %Head Motion
            CovariablesDef.CovMat = []; %YAN Chao-Gan, 130116. Fixed a bug when CovMat is not defined.
            if (Cfg.Covremove.HeadMotion==1) %1: Use the current time point of rigid-body 6 realign parameters. e.g., Txi, Tyi, Tzi...
                DirRP=dir([Cfg.WorkingDir,filesep,'RealignParameter',filesep,Cfg.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},'rp*']);
                Q1=load([Cfg.WorkingDir,filesep,'RealignParameter',filesep,Cfg.SubjectID{i},filesep,DirRP.name]);
                CovariablesDef.CovMat = Q1;
            elseif (Cfg.Covremove.HeadMotion==2) %2: Use the current time point and the previous time point of rigid-body 6 realign parameters. e.g., Txi, Tyi, Tzi,..., Txi-1, Tyi-1, Tzi-1...
                DirRP=dir([Cfg.WorkingDir,filesep,'RealignParameter',filesep,Cfg.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},'rp*']);
                Q1=load([Cfg.WorkingDir,filesep,'RealignParameter',filesep,Cfg.SubjectID{i},filesep,DirRP.name]);
                CovariablesDef.CovMat = [Q1, [zeros(1,size(Q1,2));Q1(1:end-1,:)]];
            elseif (Cfg.Covremove.HeadMotion==3) %3: Use the current time point and their squares of rigid-body 6 realign parameters. e.g., Txi, Tyi, Tzi,..., Txi^2, Tyi^2, Tzi^2...
                DirRP=dir([Cfg.WorkingDir,filesep,'RealignParameter',filesep,Cfg.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},'rp*']);
                Q1=load([Cfg.WorkingDir,filesep,'RealignParameter',filesep,Cfg.SubjectID{i},filesep,DirRP.name]);
                CovariablesDef.CovMat = [Q1,  Q1.^2];
            elseif (Cfg.Covremove.HeadMotion==4) %4: Use the Friston 24-parameter model: current time point, the previous time point and their squares of rigid-body 6 realign parameters. e.g., Txi, Tyi, Tzi, ..., Txi-1, Tyi-1, Tzi-1,... and their squares (total 24 items). Friston autoregressive model (Friston, K.J., Williams, S., Howard, R., Frackowiak, R.S., Turner, R., 1996. Movement-related effects in fMRI time-series. Magn Reson Med 35, 346-355.)
                DirRP=dir([Cfg.WorkingDir,filesep,'RealignParameter',filesep,Cfg.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},'rp*']);
                Q1=load([Cfg.WorkingDir,filesep,'RealignParameter',filesep,Cfg.SubjectID{i},filesep,DirRP.name]);
                CovariablesDef.CovMat = [Q1, [zeros(1,size(Q1,2));Q1(1:end-1,:)], Q1.^2, [zeros(1,size(Q1,2));Q1(1:end-1,:)].^2];
            end
            
            %Head Motion "Scrubbing" Regressors: each bad time point is a separate regressor
            if (Cfg.Covremove.IsHeadMotionScrubbingRegressors==1)
                % Use FD_Power or FD_Jenkinson YAN Chao-Gan, 121225.
                FD = load([Cfg.WorkingDir,filesep,'RealignParameter',filesep,Cfg.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},Cfg.Covremove.HeadMotionScrubbingRegressors.FDType,'_',Cfg.SubjectID{i},'.txt']);
                TemporalMask=ones(length(FD),1);
                Index=find(FD > Cfg.Covremove.HeadMotionScrubbingRegressors.FDThreshold);
                TemporalMask(Index)=0;
                IndexPrevious=Index;
                for iP=1:Cfg.Covremove.HeadMotionScrubbingRegressors.PreviousPoints
                    IndexPrevious=IndexPrevious-1;
                    IndexPrevious=IndexPrevious(IndexPrevious>=1);
                    TemporalMask(IndexPrevious)=0;
                end
                IndexNext=Index;
                for iN=1:Cfg.Covremove.HeadMotionScrubbingRegressors.LaterPoints
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

            %YAN Chao-Gan, 221205
            if (Cfg.IsBasedOnFunSurf==1) %YAN Chao-Gan, 221205. If calculate in individual space
                if (Cfg.Covremove.WM.IsRemove==1) && strcmpi(Cfg.Covremove.WM.Method,'CompCor')
                    if strcmpi(Cfg.Covremove.WM.Mask,'SPM')
                        CompCorMasks=[CompCorMasks;{[Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForFun',filesep,'Masks_FunSpace',filesep,'FunSpace_',Cfg.SubjectID{i},'_WhiteMask_09_91x109x91.nii']}];
                    elseif strcmpi(Cfg.Covremove.WM.Mask,'Segment')
                        CompCorMasks=[CompCorMasks;{[Cfg.WorkingDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_ThrdMask_',Cfg.SubjectID{i},'_WM.nii']}];
                    end
                end
                if (Cfg.Covremove.CSF.IsRemove==1) && strcmpi(Cfg.Covremove.CSF.Method,'CompCor')
                    if strcmpi(Cfg.Covremove.CSF.Mask,'SPM')
                        CompCorMasks=[CompCorMasks;{[Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForFun',filesep,'Masks_FunSpace',filesep,'FunSpace_',Cfg.SubjectID{i},'_CsfMask_07_91x109x91.nii']}];
                    elseif strcmpi(Cfg.Covremove.CSF.Mask,'Segment')
                        CompCorMasks=[CompCorMasks;{[Cfg.WorkingDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_ThrdMask_',Cfg.SubjectID{i},'_CSF.nii']}];
                    end
                end
            else %YAN Chao-Gan, 221205. If calculate in MNI space
                if (Cfg.Covremove.WM.IsRemove==1) && strcmpi(Cfg.Covremove.WM.Method,'CompCor')
                    if strcmpi(Cfg.Covremove.WM.Mask,'SPM')
                        CompCorMasks=[CompCorMasks;{[Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_MNIFunSpace',filesep,'AllResampled','_WhiteMask_09_91x109x91.nii']}];
                    elseif strcmpi(Cfg.Covremove.WM.Mask,'Segment')
                        CompCorMasks=[CompCorMasks;{[Cfg.WorkingDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'MNIFunSpace_ThrdMask_',Cfg.SubjectID{i},'_WM.nii']}];
                    end
                end
                if (Cfg.Covremove.CSF.IsRemove==1) && strcmpi(Cfg.Covremove.CSF.Method,'CompCor')
                    if strcmpi(Cfg.Covremove.CSF.Mask,'SPM')
                        CompCorMasks=[CompCorMasks;{[Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_MNIFunSpace',filesep,'AllResampled','_CsfMask_07_91x109x91.nii']}];
                    elseif strcmpi(Cfg.Covremove.CSF.Mask,'Segment')
                        CompCorMasks=[CompCorMasks;{[Cfg.WorkingDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'MNIFunSpace_ThrdMask_',Cfg.SubjectID{i},'_CSF.nii']}];
                    end
                end
            end

            if ~isempty(CompCorMasks)
                if ~(7==exist([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,'Covs'],'dir'))
                    mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,'Covs']);
                end
                [PCs] = y_CompCor_PC([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i}],CompCorMasks, [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,'Covs',filesep,Cfg.SubjectID{i},'_CompCorPCs'], Cfg.Covremove.CSF.CompCorPCNum);
                %[PCs] = y_CompCor_PC(ADataDir,Nuisance_MaskFilename, OutputName, PCNum, IsNeedDetrend, Band, TR, IsVarianceNormalization)
                %IsNeedDetrend and IsVarianceNormalization defaulted to 1
                CovariablesDef.CovMat = [CovariablesDef.CovMat, PCs];
            end


            %Mask covariates %YAN Chao-Gan, 140628. Deal with different kind of nuisance covarites.
            SubjectCovariatesROI=[];

            %YAN Chao-Gan, 221205
            if (Cfg.IsBasedOnFunSurf==1) %YAN Chao-Gan, 221205. If calculate in individual space
                if (Cfg.Covremove.WM.IsRemove==1) && strcmpi(Cfg.Covremove.WM.Method,'Mean')
                    if strcmpi(Cfg.Covremove.WM.Mask,'SPM')
                        SubjectCovariatesROI=[SubjectCovariatesROI;{[Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForFun',filesep,'Masks_FunSpace',filesep,'FunSpace_',Cfg.SubjectID{i},'_WhiteMask_09_91x109x91.nii']}];
                    elseif strcmpi(Cfg.Covremove.WM.Mask,'Segment')
                        SubjectCovariatesROI=[SubjectCovariatesROI;{[Cfg.WorkingDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_ThrdMask_',Cfg.SubjectID{i},'_WM.nii']}];
                    end
                end

                if (Cfg.Covremove.CSF.IsRemove==1) && strcmpi(Cfg.Covremove.CSF.Method,'Mean')
                    if strcmpi(Cfg.Covremove.CSF.Mask,'SPM')
                        SubjectCovariatesROI=[SubjectCovariatesROI;{[Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForFun',filesep,'Masks_FunSpace',filesep,'FunSpace_',Cfg.SubjectID{i},'_CsfMask_07_91x109x91.nii']}];
                    elseif strcmpi(Cfg.Covremove.CSF.Mask,'Segment')
                        SubjectCovariatesROI=[SubjectCovariatesROI;{[Cfg.WorkingDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'FunSpace_ThrdMask_',Cfg.SubjectID{i},'_CSF.nii']}];
                    end
                end

                if (Cfg.Covremove.WholeBrain.IsRemove==1)
                    if strcmpi(Cfg.Covremove.WholeBrain.Mask,'SPM')
                        SubjectCovariatesROI=[SubjectCovariatesROI;{[Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForFun',filesep,'Masks_FunSpace',filesep,'FunSpace_',Cfg.SubjectID{i},'_BrainMask_05_91x109x91.nii']}];
                    elseif strcmpi(Cfg.Covremove.WholeBrain.Mask,'AutoMask')
                        SubjectCovariatesROI=[SubjectCovariatesROI;{[Cfg.WorkingDir,filesep,'Masks',filesep,'AutoMasks',filesep,Cfg.SubjectID{i},'_task-rest_space-T1w_desc-brain_mask.nii.gz']}];
                    end
                end
            else
                if (Cfg.Covremove.WM.IsRemove==1) && strcmpi(Cfg.Covremove.WM.Method,'Mean')
                    if strcmpi(Cfg.Covremove.WM.Mask,'SPM')
                        SubjectCovariatesROI=[SubjectCovariatesROI;{[Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_MNIFunSpace',filesep,'AllResampled','_WhiteMask_09_91x109x91.nii']}];
                    elseif strcmpi(Cfg.Covremove.WM.Mask,'Segment')
                        SubjectCovariatesROI=[SubjectCovariatesROI;{[Cfg.WorkingDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'MNIFunSpace_ThrdMask_',Cfg.SubjectID{i},'_WM.nii']}];
                    end
                end

                if (Cfg.Covremove.CSF.IsRemove==1) && strcmpi(Cfg.Covremove.CSF.Method,'Mean')
                    if strcmpi(Cfg.Covremove.CSF.Mask,'SPM')
                        SubjectCovariatesROI=[SubjectCovariatesROI;{[Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_MNIFunSpace',filesep,'AllResampled','_CsfMask_07_91x109x91.nii']}];
                    elseif strcmpi(Cfg.Covremove.CSF.Mask,'Segment')
                        SubjectCovariatesROI=[SubjectCovariatesROI;{[Cfg.WorkingDir,filesep,'Masks',filesep,'SegmentationMasks',filesep,'MNIFunSpace_ThrdMask_',Cfg.SubjectID{i},'_CSF.nii']}];
                    end
                end

                if (Cfg.Covremove.WholeBrain.IsRemove==1)
                    if strcmpi(Cfg.Covremove.WholeBrain.Mask,'SPM')
                        SubjectCovariatesROI=[SubjectCovariatesROI;{[Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_MNIFunSpace',filesep,'AllResampled','_BrainMask_05_91x109x91.nii']}];
                    elseif strcmpi(Cfg.Covremove.WholeBrain.Mask,'AutoMask')
                        SubjectCovariatesROI=[SubjectCovariatesROI;{[Cfg.WorkingDir,filesep,'Masks',filesep,'AutoMasks',filesep,Cfg.SubjectID{i},'_task-rest_space-MNI152NLin2009cAsym_desc-brain_mask.nii.gz']}];
                    end
                end
            end

            % Add the other Covariate ROIs
            if ~isempty(Cfg.Covremove.OtherCovariatesROI)
                SubjectCovariatesROI=[SubjectCovariatesROI;Cfg.Covremove.OtherCovariatesROIForEachSubject{i}];
            end
            
            if ~(7==exist([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,'Covs'],'dir'))
                mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,'Covs']);
            end
            
            %Extract Time course for the Mask covariates
            if ~isempty(SubjectCovariatesROI)
                y_ExtractROISignal([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i}], SubjectCovariatesROI, [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,'Covs',filesep,Cfg.SubjectID{i}], '', 1);
                CovariablesDef.ort_file=[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,'Covs',filesep,'ROISignals_',Cfg.SubjectID{i},'.txt'];
            end
            
            CovariablesDef.IsAddMeanBack = Cfg.Covremove.IsAddMeanBack; %YAN Chao-Gan, 160415: Add the option of "Add Mean Back".
            
            %Regressing out the covariates
            fprintf('\nRegressing out covariates for subject %s %s.\n',Cfg.SubjectID{i},FunSessionPrefixSet{iFunSession});
            [Covariables] = y_RegressOutImgCovariates([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i}],CovariablesDef,'_Covremoved','');
            
            Covariables = double(Covariables);
            y_CallSave([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,'Covs',filesep,'Covariables',Cfg.SubjectID{i},'.mat'], Covariables, '');
            y_CallSave([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,'Covs',filesep,'Covariables',Cfg.SubjectID{i},'.txt'], Covariables, ' ''-ASCII'', ''-DOUBLE'',''-TABS''');

            mkdir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,'C'],Cfg.SubjectID{i}));
            DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*_hemi-*.func.gii'));
            for iFile=1:length(DirName)
                InFile=fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},DirName(iFile).name);
                OutFile=fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,'C'],Cfg.SubjectID{i},DirName(iFile).name);
                y_RegressOutCovariates_OnSurf(InFile,CovariablesDef,OutFile,'');
            end
        end
        fprintf('\n');
    end
    
    
    %Copy the Covariates Removed files to WorkingDir\{Cfg.StartingDirName_Volume}+C
    for iFunSession=1:Cfg.FunctionalSessionNumber
        parfor i=1:Cfg.SubjectNum
            mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,'C',filesep,Cfg.SubjectID{i}])
            movefile([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i}, '_Covremoved',filesep,'*'],[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,'C',filesep,Cfg.SubjectID{i}])

            rmdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i}, '_Covremoved']);
            fprintf(['Moving Coviables Removed Files:',Cfg.SubjectID{i},' OK']);
        end
        fprintf('\n');
    end
    Cfg.StartingDirName=[Cfg.StartingDirName,'C']; %Now StartingDirName is with new suffix 'C'
    Cfg.StartingDirName_Volume=[Cfg.StartingDirName_Volume,'C']; %Now StartingDirName is with new suffix 'C'
end




%Smooth on functional data
if (Cfg.IsSmooth==1) && strcmpi(Cfg.Smooth.Timing,'OnFunctionalData')
    %Smooth on functional surface data
    if (Cfg.IsBasedOnFunSurf==1) %YAN Chao-Gan, 221205. If calculate in individual space
        SpaceName='{1}';
    else
        SpaceName='fsaverage5';
    end
    for iFunSession=1:Cfg.FunctionalSessionNumber
        for i=1:Cfg.SubjectNum
            mkdir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,'S'],Cfg.SubjectID{i}));
        end
        %Smooth left hemi
        DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{1},'*_hemi-L*.func.gii'));
        for iFile=1:length(DirName)
            Suffix=DirName(iFile).name(length(Cfg.SubjectID{1})+1:end);
            Command = sprintf('%s parallel -j %g mri_surf2surf --s %s --hemi lh --sval %s/%s%s/{1}/{1}%s  --fwhm %g --cortex --tval %s/%s%sS/{1}/s{1}%s ::: %s', CommandInit, Cfg.ParallelWorkersNumber, SpaceName, WorkingDir, FunSessionPrefixSet{iFunSession}, Cfg.StartingDirName, Suffix, Cfg.Smooth.FWHMSurf, WorkingDir, FunSessionPrefixSet{iFunSession}, Cfg.StartingDirName, Suffix, SubjectIDString);
            system(Command);
        end
        %Smooth right hemi
        DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{1},'*_hemi-R*.func.gii'));
        for iFile=1:length(DirName)
            Suffix=DirName(iFile).name(length(Cfg.SubjectID{1})+1:end);
            Command = sprintf('%s parallel -j %g mri_surf2surf --s %s --hemi rh --sval %s/%s%s/{1}/{1}%s  --fwhm %g --cortex --tval %s/%s%sS/{1}/s{1}%s ::: %s', CommandInit, Cfg.ParallelWorkersNumber, SpaceName, WorkingDir, FunSessionPrefixSet{iFunSession}, Cfg.StartingDirName, Suffix, Cfg.Smooth.FWHMSurf, WorkingDir, FunSessionPrefixSet{iFunSession}, Cfg.StartingDirName, Suffix, SubjectIDString);
            system(Command);
        end
    end

    %Smooth on functional volume data
    if (Cfg.IsProcessVolumeSpace==1)
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

        parfor i=1:Cfg.SubjectNum
            FileList=[];
            for iFunSession=1:Cfg.FunctionalSessionNumber
                cd([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i}]);
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
                    if Cfg.TimePoints>0 && length(DirImg)~=Cfg.TimePoints % Will not check if TimePoints set to 0. YAN Chao-Gan 120806.
                        Error=[Error;{['Error in Smooth: ',Cfg.SubjectID{i}]}];
                    end
                    for j=1:length(DirImg)
                        FileList=[FileList;{[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i},filesep,DirImg(j).name]}];
                    end
                else %4D .nii images
                    Nii  = nifti(DirImg(1).name);
                    if Cfg.TimePoints>0 && size(Nii.dat,4)~=Cfg.TimePoints % Will not check if TimePoints set to 0. YAN Chao-Gan 120806.
                        Error=[Error;{['Error in Smooth: ',Cfg.SubjectID{i}]}];
                    end
                    FileList=[FileList;{[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i},filesep,DirImg(1).name]}];
                    %YAN Chao-Gan, 130301. Fixed a bug (leave session 1) in smooth in multiple sessions.  %FileList={[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i},filesep,DirImg(1).name]};
                end
            end
            SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Smooth.mat']);
            SPMJOB.matlabbatch{1,1}.spm.spatial.smooth.data = FileList;
            SPMJOB.matlabbatch{1,1}.spm.spatial.smooth.fwhm = Cfg.Smooth.FWHMVolu;
            spm_jobman('run',SPMJOB.matlabbatch);
            fprintf(['Smooth:',Cfg.SubjectID{i},' OK']);
        end
        %Copy the Smoothed files to WorkingDir\{Cfg.StartingDirName_Volume}+S
        for iFunSession=1:Cfg.FunctionalSessionNumber
            parfor i=1:Cfg.SubjectNum
                mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,'S',filesep,Cfg.SubjectID{i}])
                if (Cfg.IsSmooth==1)
                    movefile([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i},filesep,'s*'],[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,'S',filesep,Cfg.SubjectID{i}])
                elseif (Cfg.IsSmooth==2) % If smoothed by DARTEL, then the smoothed files still under realign directory.
                    movefile([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume(1:end-1),filesep,Cfg.SubjectID{i},filesep,'s*'],[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,'S',filesep,Cfg.SubjectID{i}])
                end
                fprintf(['Moving Smoothed Files:',Cfg.SubjectID{i},' OK']);
            end
            fprintf('\n');
        end
        Cfg.StartingDirName_Volume=[Cfg.StartingDirName_Volume,'S']; %Now StartingDirName is with new suffix 'S'
    end
    Cfg.StartingDirName = [Cfg.StartingDirName,'S'];
end




%Calculate ALFF and fALFF
if (Cfg.IsCalALFF==1)
    for iFunSession=1:Cfg.FunctionalSessionNumber
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'ALFF_',Cfg.StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'fALFF_',Cfg.StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'ALFF_',Cfg.StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'fALFF_',Cfg.StartingDirName]);
        if (Cfg.IsProcessVolumeSpace==1)
            mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'ALFF_',Cfg.StartingDirName_Volume]);
            mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'fALFF_',Cfg.StartingDirName_Volume]);
        end
        parfor i=1:Cfg.SubjectNum

            MaskFileSurfLH = Cfg.MaskFileSurfLH;
            MaskFileSurfLH = replace(MaskFileSurfLH,'{SubjectID}',Cfg.SubjectID{i});
            MaskFileSurfLH = replace(MaskFileSurfLH,'{WorkingDir}',Cfg.WorkingDir);
            MaskFileSurfRH = Cfg.MaskFileSurfRH;
            MaskFileSurfRH = replace(MaskFileSurfRH,'{SubjectID}',Cfg.SubjectID{i});
            MaskFileSurfRH = replace(MaskFileSurfRH,'{WorkingDir}',Cfg.WorkingDir);
            MaskFileVolu = Cfg.MaskFileVolu;
            MaskFileVolu = replace(MaskFileVolu,'{SubjectID}',Cfg.SubjectID{i});
            MaskFileVolu = replace(MaskFileVolu,'{WorkingDir}',Cfg.WorkingDir);

            if Cfg.TR==0  % Need to retrieve the TR information from the NIfTI images
                TR = Cfg.TRSet(i,iFunSession);
            else
                TR = Cfg.TR;
            end

            % ALFF and fALFF calculation
            % Left Hemi
            DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*_hemi-L*.func.gii'));
            for iFile=1:length(DirName)
                FileName=DirName(iFile).name;
                [ALFFBrain, fALFFBrain, Header] = y_alff_falff_Surf(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},FileName),TR, Cfg.CalALFF.ALowPass_HighCutoff, Cfg.CalALFF.AHighPass_LowCutoff, MaskFileSurfLH, ...
                    {[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'ALFF_',Cfg.StartingDirName,filesep,'ALFF_',Cfg.SubjectID{i},'.func.gii'];[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'fALFF_',Cfg.StartingDirName,filesep,'fALFF_',Cfg.SubjectID{i},'.func.gii']});
            end
            
            % Right Hemi
            DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*_hemi-R*.func.gii'));
            for iFile=1:length(DirName)
                FileName=DirName(iFile).name;
                [ALFFBrain, fALFFBrain, Header] = y_alff_falff_Surf(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},FileName),TR, Cfg.CalALFF.ALowPass_HighCutoff, Cfg.CalALFF.AHighPass_LowCutoff, MaskFileSurfRH, ...
                    {[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'ALFF_',Cfg.StartingDirName,filesep,'ALFF_',Cfg.SubjectID{i},'.func.gii'];[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'fALFF_',Cfg.StartingDirName,filesep,'fALFF_',Cfg.SubjectID{i},'.func.gii']});
            end
            
            % ZStandardization for bilateral hemispheres % YAN Chao-Gan, 190522
            y_ZStandardization_Bilateral_Surf([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'ALFF_',Cfg.StartingDirName,filesep,'ALFF_',Cfg.SubjectID{i},'.func.gii'], [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'ALFF_',Cfg.StartingDirName,filesep,'ALFF_',Cfg.SubjectID{i},'.func.gii'], [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'ALFF_',Cfg.StartingDirName,filesep,'zALFF_',Cfg.SubjectID{i},'.func.gii'], [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'ALFF_',Cfg.StartingDirName,filesep,'zALFF_',Cfg.SubjectID{i},'.func.gii'], MaskFileSurfLH, MaskFileSurfRH);
            y_ZStandardization_Bilateral_Surf([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'fALFF_',Cfg.StartingDirName,filesep,'fALFF_',Cfg.SubjectID{i},'.func.gii'], [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'fALFF_',Cfg.StartingDirName,filesep,'fALFF_',Cfg.SubjectID{i},'.func.gii'], [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'fALFF_',Cfg.StartingDirName,filesep,'zfALFF_',Cfg.SubjectID{i},'.func.gii'], [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'fALFF_',Cfg.StartingDirName,filesep,'zfALFF_',Cfg.SubjectID{i},'.func.gii'], MaskFileSurfLH, MaskFileSurfRH);

            
            % Volume
            if (Cfg.IsProcessVolumeSpace==1)
                % ALFF and fALFF calculation
                [ALFFBrain, fALFFBrain, Header] = y_alff_falff([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i}], ...
                    TR, ...
                    Cfg.CalALFF.ALowPass_HighCutoff, ...
                    Cfg.CalALFF.AHighPass_LowCutoff, ...
                    MaskFileVolu, ...
                    {[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'ALFF_',Cfg.StartingDirName_Volume,filesep,'ALFF_',Cfg.SubjectID{i},'.nii'];[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'fALFF_',Cfg.StartingDirName_Volume,filesep,'fALFF_',Cfg.SubjectID{i},'.nii']});
                % Get the m* files: divided by the mean within the mask
                % and the z* files: substract by the mean and then divided by the std within the mask
                if ~isempty(MaskFileVolu) %Added by YAN Chao-Gan 130605. Skip if mask is not defined.
                    BrainMaskData=y_ReadRPI(MaskFileVolu);
                    Temp = ((ALFFBrain - mean(ALFFBrain(find(BrainMaskData)))) ./ std(ALFFBrain(find(BrainMaskData)))) .* (BrainMaskData~=0);
                    y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'ALFF_',Cfg.StartingDirName_Volume,filesep,'zALFF_',Cfg.SubjectID{i},'.nii']);
                    Temp = ((fALFFBrain - mean(fALFFBrain(find(BrainMaskData)))) ./ std(fALFFBrain(find(BrainMaskData)))) .* (BrainMaskData~=0);
                    y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'fALFF_',Cfg.StartingDirName_Volume,filesep,'zfALFF_',Cfg.SubjectID{i},'.nii']);
                end
            end
        end
    end
end


%Filter ('AfterNormalize')
if (Cfg.IsFilter==1) && (strcmpi(Cfg.Filter.Timing,'AfterNormalize'))
    for iFunSession=1:Cfg.FunctionalSessionNumber
        parfor i=1:Cfg.SubjectNum
            if Cfg.TR==0  % Need to retrieve the TR information from the NIfTI images
                TR = Cfg.TRSet(i,iFunSession);
            else
                TR = Cfg.TR;
            end
            y_bandpass([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i}], ...
                TR, ...
                Cfg.Filter.ALowPass_HighCutoff, ...
                Cfg.Filter.AHighPass_LowCutoff, ...
                Cfg.Filter.AAddMeanBack, ...   %Revised by YAN Chao-Gan,100420. %Cfg.Filter.ARetrend, ...
                ''); %

            mkdir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,'F'],Cfg.SubjectID{i}));
            DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*_hemi-*.func.gii'));
            for iFile=1:length(DirName)
                InFile=fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},DirName(iFile).name);
                OutFile=fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,'F'],Cfg.SubjectID{i},DirName(iFile).name);
                y_bandpass_Surf(InFile, ...
                TR, ...
                Cfg.Filter.ALowPass_HighCutoff, ...
                Cfg.Filter.AHighPass_LowCutoff, ...
                Cfg.Filter.AAddMeanBack, ...
                '',...
                OutFile);
            end
        end
    end
    
    %Copy the Filtered files to WorkingDir\{Cfg.StartingDirName_Volume}+F
    for iFunSession=1:Cfg.FunctionalSessionNumber
        parfor i=1:Cfg.SubjectNum
            mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,'F',filesep,Cfg.SubjectID{i}])
            movefile([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i}, '_filtered',filesep,'*'],[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,'F',filesep,Cfg.SubjectID{i}])

            rmdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i}, '_filtered']);
            fprintf(['Moving Filtered Files:',Cfg.SubjectID{i},' OK']);
        end
        fprintf('\n');
    end
    Cfg.StartingDirName_Volume=[Cfg.StartingDirName_Volume,'F']; %Now StartingDirName is with new suffix 'F'
    Cfg.StartingDirName = [Cfg.StartingDirName,'F'];
end


%Scrubbing
if (Cfg.IsScrubbing==1) && (strcmpi(Cfg.Scrubbing.Timing,'AfterPreprocessing'))
    for iFunSession=1:Cfg.FunctionalSessionNumber
        parfor i=1:Cfg.SubjectNum
            % Use FD_Power or FD_Jenkinson. YAN Chao-Gan, 121225.
            FD = load([Cfg.WorkingDir,filesep,'RealignParameter',filesep,Cfg.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},Cfg.Scrubbing.FDType,'_',Cfg.SubjectID{i},'.txt']);
            TemporalMask=ones(length(FD),1);
            Index=find(FD > Cfg.Scrubbing.FDThreshold);
            TemporalMask(Index)=0;
            IndexPrevious=Index;
            for iP=1:Cfg.Scrubbing.PreviousPoints
                IndexPrevious=IndexPrevious-1;
                IndexPrevious=IndexPrevious(IndexPrevious>=1);
                TemporalMask(IndexPrevious)=0;
            end
            IndexNext=Index;
            for iN=1:Cfg.Scrubbing.LaterPoints
                IndexNext=IndexNext+1;
                IndexNext=IndexNext(IndexNext<=length(FD));
                TemporalMask(IndexNext)=0;
            end
            
            %'B' stands for scrubbing
            mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,'B',filesep,Cfg.SubjectID{i}]);
            y_Scrubbing([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i}], ...
                [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,'B',filesep,Cfg.SubjectID{i},filesep,Cfg.SubjectID{i},'_4DVolume.nii'],...
                '', ... %Don't need to use brain mask
                TemporalMask, Cfg.Scrubbing.ScrubbingMethod, '');
            
            mkdir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,'B'],Cfg.SubjectID{i}));
            DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*_hemi-*.func.gii'));
            for iFile=1:length(DirName)
                InFile=fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},DirName(iFile).name);
                OutFile=fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,'B'],Cfg.SubjectID{i},DirName(iFile).name);
                y_Scrubbing_Surf(InFile, ...
                    OutFile,...
                    '', ... %Don't need to use brain mask
                    TemporalMask, Cfg.Scrubbing.ScrubbingMethod, '');
            end
        end
    end
    Cfg.StartingDirName_Volume=[Cfg.StartingDirName_Volume,'B']; %Now StartingDirName_Volume is with new suffix 'B': scrubbing
    Cfg.StartingDirName = [Cfg.StartingDirName,'B'];
end


%Calculate ReHo
if (Cfg.IsCalReHo==1)
    for iFunSession=1:Cfg.FunctionalSessionNumber
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'ReHo_',Cfg.StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'ReHo_',Cfg.StartingDirName]);
        if (Cfg.IsProcessVolumeSpace==1)
            mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'ReHo_',Cfg.StartingDirName_Volume]);
        end
        
        parfor i=1:Cfg.SubjectNum
            % ReHo calculation
            MaskFileSurfLH = Cfg.MaskFileSurfLH;
            MaskFileSurfLH = replace(MaskFileSurfLH,'{SubjectID}',Cfg.SubjectID{i});
            MaskFileSurfLH = replace(MaskFileSurfLH,'{WorkingDir}',Cfg.WorkingDir);
            MaskFileSurfRH = Cfg.MaskFileSurfRH;
            MaskFileSurfRH = replace(MaskFileSurfRH,'{SubjectID}',Cfg.SubjectID{i});
            MaskFileSurfRH = replace(MaskFileSurfRH,'{WorkingDir}',Cfg.WorkingDir);
            MaskFileVolu = Cfg.MaskFileVolu;
            MaskFileVolu = replace(MaskFileVolu,'{SubjectID}',Cfg.SubjectID{i});
            MaskFileVolu = replace(MaskFileVolu,'{WorkingDir}',Cfg.WorkingDir);

            SurfFileLH = Cfg.SurfFileLH;
            SurfFileLH = replace(SurfFileLH,'{SubjectID}',Cfg.SubjectID{i});
            SurfFileLH = replace(SurfFileLH,'{WorkingDir}',Cfg.WorkingDir);
            SurfFileRH = Cfg.SurfFileRH;
            SurfFileRH = replace(SurfFileRH,'{SubjectID}',Cfg.SubjectID{i});
            SurfFileRH = replace(SurfFileRH,'{WorkingDir}',Cfg.WorkingDir);

            % Left Hemi
            DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*_hemi-L*.func.gii'));
            for iFile=1:length(DirName)
                FileName=DirName(iFile).name;
                [ReHoBrain, Header] = y_reho_Surf(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},FileName), ...
                    Cfg.CalReHo.SurfNNeighbor, MaskFileSurfLH, ...
                    [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'ReHo_',Cfg.StartingDirName,filesep,'ReHo_',Cfg.SubjectID{i},'.func.gii'], ...
                    SurfFileLH);
            end
            
            % Right Hemi
            DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*_hemi-R*.func.gii'));
            for iFile=1:length(DirName)
                FileName=DirName(iFile).name;
                [ReHoBrain, Header] = y_reho_Surf(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},FileName), ...
                    Cfg.CalReHo.SurfNNeighbor, MaskFileSurfRH, ...
                    [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'ReHo_',Cfg.StartingDirName,filesep,'ReHo_',Cfg.SubjectID{i},'.func.gii'], ...
                    SurfFileRH);
            end
            
            % ZStandardization for bilateral hemispheres % YAN Chao-Gan, 190522
            y_ZStandardization_Bilateral_Surf([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'ReHo_',Cfg.StartingDirName,filesep,'ReHo_',Cfg.SubjectID{i},'.func.gii'], [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'ReHo_',Cfg.StartingDirName,filesep,'ReHo_',Cfg.SubjectID{i},'.func.gii'], [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'ReHo_',Cfg.StartingDirName,filesep,'zReHo_',Cfg.SubjectID{i},'.func.gii'], [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'ReHo_',Cfg.StartingDirName,filesep,'zReHo_',Cfg.SubjectID{i},'.func.gii'], MaskFileSurfLH, MaskFileSurfRH);
            
            
            % Volume
            if (Cfg.IsProcessVolumeSpace==1)
                % ReHo Calculation
                [ReHoBrain, Header] = y_reho([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i}], ...
                    Cfg.CalReHo.ClusterNVoxel, ...
                    MaskFileVolu, ...
                    [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'ReHo_',Cfg.StartingDirName_Volume,filesep,'ReHo_',Cfg.SubjectID{i},'.nii']);
                % Get the m* files: divided by the mean within the mask
                % and the z* files: substract by the mean and then divided by the std within the mask
                if ~isempty(MaskFileVolu) %Added by YAN Chao-Gan 130605. Skip if mask is not defined.
                    BrainMaskData=y_ReadRPI(MaskFileVolu);
                    Temp = ((ReHoBrain - mean(ReHoBrain(find(BrainMaskData)))) ./ std(ReHoBrain(find(BrainMaskData)))) .* (BrainMaskData~=0);
                    y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'ReHo_',Cfg.StartingDirName_Volume,filesep,'zReHo_',Cfg.SubjectID{i},'.nii']);
                end
            end
        end
    end
end


%Calculate Degree Centrality
if (Cfg.IsCalDegreeCentrality==1)
    for iFunSession=1:Cfg.FunctionalSessionNumber
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'DegreeCentrality_',Cfg.StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'DegreeCentrality_',Cfg.StartingDirName]);
        if (Cfg.IsProcessVolumeSpace==1)
            mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'DegreeCentrality_',Cfg.StartingDirName_Volume]);
        end
        parfor i=1:Cfg.SubjectNum

            MaskFileSurfLH = Cfg.MaskFileSurfLH;
            MaskFileSurfLH = replace(MaskFileSurfLH,'{SubjectID}',Cfg.SubjectID{i});
            MaskFileSurfLH = replace(MaskFileSurfLH,'{WorkingDir}',Cfg.WorkingDir);
            MaskFileSurfRH = Cfg.MaskFileSurfRH;
            MaskFileSurfRH = replace(MaskFileSurfRH,'{SubjectID}',Cfg.SubjectID{i});
            MaskFileSurfRH = replace(MaskFileSurfRH,'{WorkingDir}',Cfg.WorkingDir);
            MaskFileVolu = Cfg.MaskFileVolu;
            MaskFileVolu = replace(MaskFileVolu,'{SubjectID}',Cfg.SubjectID{i});
            MaskFileVolu = replace(MaskFileVolu,'{WorkingDir}',Cfg.WorkingDir);

            % Degree Centrality Calculation
%             % Left Hemi
%             DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*_hemi-L*.func.gii'));
%             for iFile=1:length(DirName)
%                 FileName=DirName(iFile).name;
%                 [DegreeCentrality_PositiveWeightedSumBrain, DegreeCentrality_PositiveBinarizedSumBrain, Header] = y_DegreeCentrality_Surf(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},FileName), ...
%                     Cfg.CalDegreeCentrality.rThreshold, ...
%                     {[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'DegreeCentrality_PositiveWeightedSumBrain_',Cfg.SubjectID{i},'.func.gii'];[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'DegreeCentrality_PositiveBinarizedSumBrain_',Cfg.SubjectID{i},'.func.gii']}, ...
%                     MaskFileSurfLH);
%                 % Get the m* files: divided by the mean within the mask
%                 % and the z* files: substract by the mean and then divided by the std within the mask
%                 BrainMaskData=gifti(MaskFileSurfLH);
%                 BrainMaskData=BrainMaskData.cdata;
%                 Temp = (DegreeCentrality_PositiveWeightedSumBrain ./ mean(DegreeCentrality_PositiveWeightedSumBrain(find(BrainMaskData)))) .* (BrainMaskData~=0);
%                 y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'mDegreeCentrality_PositiveWeightedSumBrain_',Cfg.SubjectID{i},'.func.gii']);
%                 Temp = ((DegreeCentrality_PositiveWeightedSumBrain - mean(DegreeCentrality_PositiveWeightedSumBrain(find(BrainMaskData)))) ./ std(DegreeCentrality_PositiveWeightedSumBrain(find(BrainMaskData)))) .* (BrainMaskData~=0);
%                 y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'zDegreeCentrality_PositiveWeightedSumBrain_',Cfg.SubjectID{i},'.func.gii']);
%                 
%                 Temp = (DegreeCentrality_PositiveBinarizedSumBrain ./ mean(DegreeCentrality_PositiveBinarizedSumBrain(find(BrainMaskData)))) .* (BrainMaskData~=0);
%                 y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'mDegreeCentrality_PositiveBinarizedSumBrain_',Cfg.SubjectID{i},'.func.gii']);
%                 Temp = ((DegreeCentrality_PositiveBinarizedSumBrain - mean(DegreeCentrality_PositiveBinarizedSumBrain(find(BrainMaskData)))) ./ std(DegreeCentrality_PositiveBinarizedSumBrain(find(BrainMaskData)))) .* (BrainMaskData~=0);
%                 y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'zDegreeCentrality_PositiveBinarizedSumBrain_',Cfg.SubjectID{i},'.func.gii']);
%              end
%             
%             % Right Hemi
%             DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*_hemi-R*.func.gii'));
%             for iFile=1:length(DirName)
%                 FileName=DirName(iFile).name;
%                 [DegreeCentrality_PositiveWeightedSumBrain, DegreeCentrality_PositiveBinarizedSumBrain, Header] = y_DegreeCentrality_Surf(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},FileName), ...
%                     Cfg.CalDegreeCentrality.rThreshold, ...
%                     {[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'DegreeCentrality_PositiveWeightedSumBrain_',Cfg.SubjectID{i},'.func.gii'];[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'DegreeCentrality_PositiveBinarizedSumBrain_',Cfg.SubjectID{i},'.func.gii']}, ...
%                     MaskFileSurfRH);
%                 % Get the m* files: divided by the mean within the mask
%                 % and the z* files: substract by the mean and then divided by the std within the mask
%                 BrainMaskData=gifti(MaskFileSurfRH);
%                 BrainMaskData=BrainMaskData.cdata;
%                 Temp = (DegreeCentrality_PositiveWeightedSumBrain ./ mean(DegreeCentrality_PositiveWeightedSumBrain(find(BrainMaskData)))) .* (BrainMaskData~=0);
%                 y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'mDegreeCentrality_PositiveWeightedSumBrain_',Cfg.SubjectID{i},'.func.gii']);
%                 Temp = ((DegreeCentrality_PositiveWeightedSumBrain - mean(DegreeCentrality_PositiveWeightedSumBrain(find(BrainMaskData)))) ./ std(DegreeCentrality_PositiveWeightedSumBrain(find(BrainMaskData)))) .* (BrainMaskData~=0);
%                 y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'zDegreeCentrality_PositiveWeightedSumBrain_',Cfg.SubjectID{i},'.func.gii']);
%                 
%                 Temp = (DegreeCentrality_PositiveBinarizedSumBrain ./ mean(DegreeCentrality_PositiveBinarizedSumBrain(find(BrainMaskData)))) .* (BrainMaskData~=0);
%                 y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'mDegreeCentrality_PositiveBinarizedSumBrain_',Cfg.SubjectID{i},'.func.gii']);
%                 Temp = ((DegreeCentrality_PositiveBinarizedSumBrain - mean(DegreeCentrality_PositiveBinarizedSumBrain(find(BrainMaskData)))) ./ std(DegreeCentrality_PositiveBinarizedSumBrain(find(BrainMaskData)))) .* (BrainMaskData~=0);
%                 y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'zDegreeCentrality_PositiveBinarizedSumBrain_',Cfg.SubjectID{i},'.func.gii']);
%             end
%             
            
            %Degree Centrality Calculation while consider bilateral hemishperes % YAN Chao-Gan, 190521
            DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*_hemi-L*.func.gii'));
            FileName_LH=fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},DirName(1).name);
            DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*_hemi-R*.func.gii'));
            FileName_RH=fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},DirName(1).name);
            
            y_DegreeCentrality_Bilateral_Surf(FileName_LH, FileName_RH, ...
                Cfg.CalDegreeCentrality.rThreshold, ...
                {[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'DegreeCentrality_Bilateral_PositiveWeightedSumBrain_',Cfg.SubjectID{i},'.func.gii'];[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'DegreeCentrality_Bilateral_PositiveBinarizedSumBrain_',Cfg.SubjectID{i},'.func.gii']}, ...
                {[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'DegreeCentrality_Bilateral_PositiveWeightedSumBrain_',Cfg.SubjectID{i},'.func.gii'];[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'DegreeCentrality_Bilateral_PositiveBinarizedSumBrain_',Cfg.SubjectID{i},'.func.gii']}, ...
                MaskFileSurfLH, MaskFileSurfRH);
            
            y_ZStandardization_Bilateral_Surf([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'DegreeCentrality_Bilateral_PositiveWeightedSumBrain_',Cfg.SubjectID{i},'.func.gii'], [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'DegreeCentrality_Bilateral_PositiveWeightedSumBrain_',Cfg.SubjectID{i},'.func.gii'], [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'zDegreeCentrality_Bilateral_PositiveWeightedSumBrain_',Cfg.SubjectID{i},'.func.gii'], [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'zDegreeCentrality_Bilateral_PositiveWeightedSumBrain_',Cfg.SubjectID{i},'.func.gii'], MaskFileSurfLH, MaskFileSurfRH);
            y_ZStandardization_Bilateral_Surf([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'DegreeCentrality_Bilateral_PositiveBinarizedSumBrain_',Cfg.SubjectID{i},'.func.gii'], [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'DegreeCentrality_Bilateral_PositiveBinarizedSumBrain_',Cfg.SubjectID{i},'.func.gii'], [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'zDegreeCentrality_Bilateral_PositiveBinarizedSumBrain_',Cfg.SubjectID{i},'.func.gii'], [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'DegreeCentrality_',Cfg.StartingDirName,filesep,'zDegreeCentrality_Bilateral_PositiveBinarizedSumBrain_',Cfg.SubjectID{i},'.func.gii'], MaskFileSurfLH, MaskFileSurfRH);
            


            % Volume
            if (Cfg.IsProcessVolumeSpace==1)
                % Degree Centrality Calculation
                [DegreeCentrality_PositiveWeightedSumBrain, DegreeCentrality_PositiveBinarizedSumBrain, Header] = y_DegreeCentrality([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i}], ...
                    Cfg.CalDegreeCentrality.rThreshold, ...
                    {[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'DegreeCentrality_',Cfg.StartingDirName_Volume,filesep,'DegreeCentrality_PositiveWeightedSumBrain_',Cfg.SubjectID{i},'.nii'];[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'DegreeCentrality_',Cfg.StartingDirName_Volume,filesep,'DegreeCentrality_PositiveBinarizedSumBrain_',Cfg.SubjectID{i},'.nii']}, ...
                    MaskFileVolu);
                % Get the m* files: divided by the mean within the mask
                % and the z* files: substract by the mean and then divided by the std within the mask
                if ~isempty(MaskFileVolu) %Added by YAN Chao-Gan 130605. Skip if mask is not defined.
                    BrainMaskData=y_ReadRPI(MaskFileVolu);
%                     Temp = (DegreeCentrality_PositiveWeightedSumBrain ./ mean(DegreeCentrality_PositiveWeightedSumBrain(find(BrainMaskData)))) .* (BrainMaskData~=0);
%                     y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'DegreeCentrality_',Cfg.StartingDirName_Volume,filesep,'mDegreeCentrality_PositiveWeightedSumBrain_',Cfg.SubjectID{i},'.nii']);
                    Temp = ((DegreeCentrality_PositiveWeightedSumBrain - mean(DegreeCentrality_PositiveWeightedSumBrain(find(BrainMaskData)))) ./ std(DegreeCentrality_PositiveWeightedSumBrain(find(BrainMaskData)))) .* (BrainMaskData~=0);
                    y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'DegreeCentrality_',Cfg.StartingDirName_Volume,filesep,'zDegreeCentrality_PositiveWeightedSumBrain_',Cfg.SubjectID{i},'.nii']);
%                     Temp = (DegreeCentrality_PositiveBinarizedSumBrain ./ mean(DegreeCentrality_PositiveBinarizedSumBrain(find(BrainMaskData)))) .* (BrainMaskData~=0);
%                     y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'DegreeCentrality_',Cfg.StartingDirName_Volume,filesep,'mDegreeCentrality_PositiveBinarizedSumBrain_',Cfg.SubjectID{i},'.nii']);
                    Temp = ((DegreeCentrality_PositiveBinarizedSumBrain - mean(DegreeCentrality_PositiveBinarizedSumBrain(find(BrainMaskData)))) ./ std(DegreeCentrality_PositiveBinarizedSumBrain(find(BrainMaskData)))) .* (BrainMaskData~=0);
                    y_Write(Temp,Header,[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'DegreeCentrality_',Cfg.StartingDirName_Volume,filesep,'zDegreeCentrality_PositiveBinarizedSumBrain_',Cfg.SubjectID{i},'.nii']);
                end
            end
        end
    end
end




%Deal with the ROI masks: warp into original space
%YAN Chao-Gan, 221205
if (Cfg.IsBasedOnFunSurf==1) && ( (~isempty(Cfg.CalFC.ROIDefVolu)) || (~isempty(Cfg.CalFC.ROIDefSurfLH)) || (~isempty(Cfg.CalFC.ROIDefSurfRH)) ) && ((Cfg.IsExtractROISignals==1) || (Cfg.IsCalFC==1))
    if ~isempty(Cfg.CalFC.ROIDefVolu)
        if ~(7==exist([Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_FunSpace'],'dir'))
            mkdir([Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_FunSpace']);
        end

        Suffix='ROI_'; %%!!! Change as in Function
        ROIDefVoluForEachSubject=cell(Cfg.SubjectNum,1);

        % Ball to mask
        AllSubjectROI=Cfg.CalFC.ROIDefVolu;
        for iROI=1:length(AllSubjectROI)
            if ~(7==exist([Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForFun',filesep, 'Masks_MNISpace'],'dir'))
                mkdir([Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForFun',filesep, 'Masks_MNISpace']);
            end
            if strcmpi(int2str(size(AllSubjectROI{iROI})),int2str([1, 4]))  %Sphere ROI definition: CenterX, CenterY, CenterZ, Radius
                ROIMaskName=[Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForFun',filesep, 'Masks_MNISpace',filesep,Suffix,'SphereMask_',num2str(iROI),'_Center_',num2str(AllSubjectROI{iROI}(1)),'_',num2str(AllSubjectROI{iROI}(2)),'_',num2str(AllSubjectROI{iROI}(3)),'_',num2str(AllSubjectROI{iROI}(4)),'.nii'];
                y_Sphere(AllSubjectROI{iROI}(1:3), AllSubjectROI{iROI}(4), [DPABIPath,filesep,'Templates',filesep,'aal.nii'], ROIMaskName);
                AllSubjectROI{iROI}=ROIMaskName;
            end
        end

        for i=1:Cfg.SubjectNum
            SubjectROI=AllSubjectROI;%%!!! Change as in Fuction
            
            % Set the reference image
            RefFile=[Cfg.WorkingDir,filesep,'Masks',filesep,'AutoMasks',filesep,Cfg.SubjectID{i},'_task-rest_space-T1w_desc-brain_mask.nii.gz'];
            [RefData,RefVox,RefHeader]=y_ReadRPI(RefFile,1);

            TransformFile=[Cfg.WorkingDir,filesep,'fmriprep',filesep,Cfg.SubjectID{i},filesep,'anat',filesep,Cfg.SubjectID{i},'_from-MNI152NLin2009cAsym_to-T1w_mode-image_xfm.h5'];
            Interpolation='MultiLabel';
            Dimensionality=3;
            InputImageType=0;
            DefaultValue=0;
            IsFloat0=0;
            DockerName='cgyan/dpabi';

            for iROI=1:length(SubjectROI)
                if exist(SubjectROI{iROI},'file')==2 % MNI Mask files need to be warped
                    [pathstr, name, ext] = fileparts(SubjectROI{iROI});
                    if (~strcmpi(ext, '.txt'))
                        SourceFile=SubjectROI{iROI};
                        MaskName=[Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForFun',filesep, 'Masks_FunSpace',filesep,Suffix,'MaskFile_',num2str(iROI),'_',Cfg.SubjectID{i},'_',name,'.nii'];
                        fprintf('\nWarp %s Mask (%s) for "%s" to individual space by ANTs.\n',Suffix,SourceFile, Cfg.SubjectID{i});
                        y_WarpByANTs(SourceFile,MaskName,RefFile,TransformFile,Interpolation,Dimensionality,InputImageType,DefaultValue,IsFloat0,DockerName)
                        %y_WarpByANTs(SourceFile,OutFile,RefFile,TransformFile,Interpolation,Dimensionality,InputImageType,DefaultValue,IsFloat0,DockerName)
                        SubjectROI{iROI}=MaskName;
                    end

                elseif (ischar(SubjectROI{iROI})) && ~isempty(strfind(SubjectROI{iROI},'{SubjectID}')) % Process the individual ROI from an expression
                    NewStrDef = replace(SubjectROI{iROI},'{SubjectID}',Cfg.SubjectID{i});
                    NewStrDef = replace(NewStrDef,'{WorkingDir}',Cfg.WorkingDir);
                    if exist(NewStrDef,'file')==2
                        [pathstr, name, ext] = fileparts(NewStrDef);
                        [MaskData,MaskVox,MaskHeader]=y_ReadRPI(NewStrDef);
                        if ~isequal(size(MaskData), size(RefData))
                            fprintf('\nReslice %s Mask (%s) for "%s" since the dimension of mask mismatched the dimension of the target data.\n',Suffix,NewStrDef, Cfg.SubjectID{i});
                            ReslicedMaskName=[Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForFun',filesep, 'Masks_FunSpace',filesep,Suffix,'MaskFile_',num2str(iROI),'_',Cfg.SubjectID{i},'_',name,'.nii'];
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

            % Check if the text file is a definition for multiple subjects. i.e., the first line is 'Seed_ROI_List:', then get the corresponded ROI file
            for iROI=1:length(SubjectROI)
                if (ischar(SubjectROI{iROI})) && (exist(SubjectROI{iROI},'file')==2)
                    [pathstr, name, ext] = fileparts(SubjectROI{iROI});
                    if (strcmpi(ext, '.txt'))
                        fid = fopen(SubjectROI{iROI});
                        SeedTimeCourseList=textscan(fid,'%s\n'); %YAN Chao-Gan, 180320. For compatiblity of MALLAB 2014b. SeedTimeCourseList=textscan(fid,'%s','\n'); 
                        fclose(fid);
                        if strcmpi(SeedTimeCourseList{1}{1},'Seed_ROI_List:')
                            SubjectROI{iROI}=SeedTimeCourseList{1}{i+1};
                        end
                    end
                end
                
            end
            
            ROIDefVoluForEachSubject{i}=SubjectROI; %%!!! Change as in Fuction
        end
        
        Cfg.CalFC.ROIDefVoluForEachSubject = ROIDefVoluForEachSubject;
    end


    if ~isempty(Cfg.CalFC.ROIDefSurfLH)
        if ~(7==exist([Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_fsnativeSpace'],'dir'))
            mkdir([Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_fsnativeSpace']);
        end

        if ~(7==exist([Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_fsaverage5Space'],'dir'))
            mkdir([Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_fsaverage5Space']);
        end

        Suffix='ROI_'; 
        ROIDefSurfLHForEachSubject=cell(Cfg.SubjectNum,1);

        for i=1:Cfg.SubjectNum
            SubjectROI=Cfg.CalFC.ROIDefSurfLH;

            for iROI=1:length(SubjectROI)
                if exist(SubjectROI{iROI},'file')==2 % fsaverage5 Mask files need to be warped
                    [pathstr, name, ext] = fileparts(SubjectROI{iROI});
                    if (~strcmpi(ext, '.txt'))
                        Data=y_ReadAll(SubjectROI{iROI});
                        SourceFile=[Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_fsaverage5Space',filesep,name, '.gii'];
                        y_Write(Data,gifti(Data),SourceFile);
                        MaskName=[Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForFun',filesep, 'Masks_fsnativeSpace',filesep,Suffix,'MaskFile_',num2str(iROI),'_',Cfg.SubjectID{i},'_',name,'.gii'];
                        Command = sprintf('%s parallel -j %g mri_surf2surf --srcsubject fsaverage5 --trgsubject {1} --mapmethod nnf --hemi lh --sval %s/Masks/MasksForFun/Masks_fsaverage5Space/%s%s --tval %s/Masks/MasksForFun/Masks_fsnativeSpace/%sMaskFile_%g_{1}_%s.gii ::: %s', CommandInit, Cfg.ParallelWorkersNumber, WorkingDir,name, '.gii', WorkingDir, Suffix, iROI, name, Cfg.SubjectID{i});
                        fprintf('\nWarp %s Mask (%s) for "%s" to individual space by mri_surf2surf.\n',Suffix,SourceFile, Cfg.SubjectID{i});
                        system(Command);
                        SubjectROI{iROI}=MaskName;
                    end
                elseif (ischar(SubjectROI{iROI})) && ~isempty(strfind(SubjectROI{iROI},'{SubjectID}')) % Process the individual ROI from an expression
                    NewStrDef = replace(SubjectROI{iROI},'{SubjectID}',Cfg.SubjectID{i});
                    NewStrDef = replace(NewStrDef,'{WorkingDir}',Cfg.WorkingDir);
                    if exist(NewStrDef,'file')==2
                        SubjectROI{iROI}=NewStrDef;
                    else
                        error(['The Mask File ',NewStrDef,' does not exist!'])
                    end
                else
                    error(['This Mask definition can not be processed: ',SubjectROI{iROI}])
                end
            end

            % Check if the text file is a definition for multiple subjects. i.e., the first line is 'Seed_ROI_List:', then get the corresponded ROI file
            for iROI=1:length(SubjectROI)
                if (ischar(SubjectROI{iROI})) && (exist(SubjectROI{iROI},'file')==2)
                    [pathstr, name, ext] = fileparts(SubjectROI{iROI});
                    if (strcmpi(ext, '.txt'))
                        fid = fopen(SubjectROI{iROI});
                        SeedTimeCourseList=textscan(fid,'%s\n'); %YAN Chao-Gan, 180320. For compatiblity of MALLAB 2014b. SeedTimeCourseList=textscan(fid,'%s','\n');
                        fclose(fid);
                        if strcmpi(SeedTimeCourseList{1}{1},'Seed_ROI_List:')
                            SubjectROI{iROI}=SeedTimeCourseList{1}{i+1};
                        end
                    end
                end
            end

            ROIDefSurfLHForEachSubject{i}=SubjectROI; %%!!! Change as in Fuction
        end

        Cfg.CalFC.ROIDefSurfLHForEachSubject = ROIDefSurfLHForEachSubject;
    end


    if ~isempty(Cfg.CalFC.ROIDefSurfRH)
        if ~(7==exist([Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_fsnativeSpace'],'dir'))
            mkdir([Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_fsnativeSpace']);
        end

        if ~(7==exist([Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_fsaverage5Space'],'dir'))
            mkdir([Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_fsaverage5Space']);
        end

        Suffix='ROI_'; %%!!! Change as in Function
        ROIDefSurfRHForEachSubject=cell(Cfg.SubjectNum,1);

        for i=1:Cfg.SubjectNum
            SubjectROI=Cfg.CalFC.ROIDefSurfRH;

            for iROI=1:length(SubjectROI)
                if exist(SubjectROI{iROI},'file')==2 % fsaverage5 Mask files need to be warped
                    [pathstr, name, ext] = fileparts(SubjectROI{iROI});
                    if (~strcmpi(ext, '.txt'))
                        Data=y_ReadAll(SubjectROI{iROI});
                        SourceFile=[Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_fsaverage5Space',filesep,name, '.gii'];
                        y_Write(Data,gifti(Data),SourceFile);
                        MaskName=[Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForFun',filesep, 'Masks_fsnativeSpace',filesep,Suffix,'MaskFile_',num2str(iROI),'_',Cfg.SubjectID{i},'_',name,'.gii'];
                        Command = sprintf('%s parallel -j %g mri_surf2surf --srcsubject fsaverage5 --trgsubject {1} --mapmethod nnf --hemi rh --sval %s/Masks/MasksForFun/Masks_fsaverage5Space/%s%s --tval %s/Masks/MasksForFun/Masks_fsnativeSpace/%sMaskFile_%g_{1}_%s.gii ::: %s', CommandInit, Cfg.ParallelWorkersNumber, WorkingDir,name, '.gii', WorkingDir, Suffix, iROI, name, Cfg.SubjectID{i});
                        fprintf('\nWarp %s Mask (%s) for "%s" to individual space by mri_surf2surf.\n',Suffix,SourceFile, Cfg.SubjectID{i});
                        system(Command);
                        SubjectROI{iROI}=MaskName;
                    end
                elseif (ischar(SubjectROI{iROI})) && ~isempty(strfind(SubjectROI{iROI},'{SubjectID}')) % Process the individual ROI from an expression
                    NewStrDef = replace(SubjectROI{iROI},'{SubjectID}',Cfg.SubjectID{i});
                    NewStrDef = replace(NewStrDef,'{WorkingDir}',Cfg.WorkingDir);
                    if exist(NewStrDef,'file')==2
                        SubjectROI{iROI}=NewStrDef;
                    else
                        error(['The Mask File ',NewStrDef,' does not exist!'])
                    end
                else
                    error(['This Mask definition can not be processed: ',SubjectROI{iROI}])
                end
            end

            % Check if the text file is a definition for multiple subjects. i.e., the first line is 'Seed_ROI_List:', then get the corresponded ROI file
            for iROI=1:length(SubjectROI)
                if (ischar(SubjectROI{iROI})) && (exist(SubjectROI{iROI},'file')==2)
                    [pathstr, name, ext] = fileparts(SubjectROI{iROI});
                    if (strcmpi(ext, '.txt'))
                        fid = fopen(SubjectROI{iROI});
                        SeedTimeCourseList=textscan(fid,'%s\n'); %YAN Chao-Gan, 180320. For compatiblity of MALLAB 2014b. SeedTimeCourseList=textscan(fid,'%s','\n');
                        fclose(fid);
                        if strcmpi(SeedTimeCourseList{1}{1},'Seed_ROI_List:')
                            SubjectROI{iROI}=SeedTimeCourseList{1}{i+1};
                        end
                    end
                end
            end

            ROIDefSurfRHForEachSubject{i}=SubjectROI; %%!!! Change as in Fuction
        end

        Cfg.CalFC.ROIDefSurfRHForEachSubject = ROIDefSurfRHForEachSubject;
    end

end



%If don't need to Warp into original space, then resample the ROI masks
if (Cfg.IsBasedOnFunSurf==0) && ( (~isempty(Cfg.CalFC.ROIDefVolu)) ) && ((Cfg.IsExtractROISignals==1) || (Cfg.IsCalFC==1))
    if ~isempty(Cfg.CalFC.ROIDefVolu)
        if ~(7==exist([Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_MNIFunSpace'],'dir'))
            mkdir([Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_MNIFunSpace']);
        end

        Suffix='ROI_'; %%!!! Change as in Function
        % Ball to mask
        AllSubjectROI=Cfg.CalFC.ROIDefVolu;
        for iROI=1:length(AllSubjectROI)
            if ~(7==exist([Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForFun',filesep, 'Masks_MNISpace'],'dir'))
                mkdir([Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForFun',filesep, 'Masks_MNISpace']);
            end
            if strcmpi(int2str(size(AllSubjectROI{iROI})),int2str([1, 4]))  %Sphere ROI definition: CenterX, CenterY, CenterZ, Radius
                ROIMaskName=[Cfg.WorkingDir,filesep,'Masks',filesep, 'MasksForFun',filesep, 'Masks_MNISpace',filesep,Suffix,'SphereMask_',num2str(iROI),'_Center_',num2str(AllSubjectROI{iROI}(1)),'_',num2str(AllSubjectROI{iROI}(2)),'_',num2str(AllSubjectROI{iROI}(3)),'_',num2str(AllSubjectROI{iROI}(4)),'.nii'];
                y_Sphere(AllSubjectROI{iROI}(1:3), AllSubjectROI{iROI}(4), [DPABIPath,filesep,'Templates',filesep,'aal.nii'], ROIMaskName);
                AllSubjectROI{iROI}=ROIMaskName;
            end
        end

        % Check if masks appropriate %This can be used as a function!!! ONLY FOR RESAMPLE
        ROIDefVoluForEachSubject=cell(Cfg.SubjectNum,1);
        for i=1:Cfg.SubjectNum
            SubjectROI=AllSubjectROI;%%!!! Change as in Fuction
            
            % Set the reference image
            RefFile=dir([Cfg.WorkingDir,filesep,Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i},filesep,'*.img']);
            if isempty(RefFile)  %YAN Chao-Gan, 120827. Also support .nii.gz files.
                RefFile=dir([Cfg.WorkingDir,filesep,Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i},filesep,'*.nii.gz']);
            end
            if isempty(RefFile)  %YAN Chao-Gan, 111114. Also support .nii files.
                RefFile=dir([Cfg.WorkingDir,filesep,Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i},filesep,'*.nii']);
            end
            RefFile=[Cfg.WorkingDir,filesep,Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i},filesep,RefFile(1).name];
            [RefData,RefVox,RefHeader]=y_ReadRPI(RefFile,1);
            
            % Check if the ROI mask is appropriate
            for iROI=1:length(SubjectROI)
                AMaskFilename=SubjectROI{iROI};
                AMaskFilename = replace(AMaskFilename,'{SubjectID}',Cfg.SubjectID{i});
                AMaskFilename = replace(AMaskFilename,'{WorkingDir}',Cfg.WorkingDir);

                if exist(SubjectROI{iROI},'file')==2
                    [pathstr, name, ext] = fileparts(SubjectROI{iROI});
                    if (~strcmpi(ext, '.txt'))
                        [MaskData,MaskVox,MaskHeader]=y_ReadRPI(AMaskFilename);
                        if ~isequal(size(MaskData), size(RefData))
                            fprintf('\nReslice %s Mask (%s) for "%s" since the dimension of mask mismatched the dimension of the functional data.\n',Suffix,AMaskFilename, Cfg.SubjectID{i});
                            ReslicedMaskName=[Cfg.WorkingDir,filesep,'Masks',filesep,'MasksForFun',filesep,'Masks_MNIFunSpace',filesep,Suffix,num2str(iROI),'_',Cfg.SubjectID{i},'_',name,'.nii'];
                            y_Reslice(AMaskFilename,ReslicedMaskName,RefVox,0, RefFile);
                            SubjectROI{iROI}=ReslicedMaskName;
                        end
                    end
                end
            end
            
            % Check if the text file is a definition for multiple subjects. i.e., the first line is 'Seed_ROI_List:', then get the corresponded ROI file
            for iROI=1:length(SubjectROI)
                if (ischar(SubjectROI{iROI})) && (exist(SubjectROI{iROI},'file')==2)
                    [pathstr, name, ext] = fileparts(SubjectROI{iROI});
                    if (strcmpi(ext, '.txt'))
                        fid = fopen(SubjectROI{iROI});
                        SeedTimeCourseList=textscan(fid,'%s\n'); %YAN Chao-Gan, 180320. For compatiblity of MALLAB 2014b. SeedTimeCourseList=textscan(fid,'%s','\n'); 
                        fclose(fid);
                        if strcmpi(SeedTimeCourseList{1}{1},'Seed_ROI_List:')
                            SubjectROI{iROI}=SeedTimeCourseList{1}{i+1};
                        end
                    end
                end
                
            end
            
            ROIDefVoluForEachSubject{i}=SubjectROI; %%!!! Change as in Fuction
        end
        
        Cfg.CalFC.ROIDefVoluForEachSubject = ROIDefVoluForEachSubject;
    end


    if ~isempty(Cfg.CalFC.ROIDefSurfLH)
        ROIDefSurfLHForEachSubject=cell(Cfg.SubjectNum,1);
        for i=1:Cfg.SubjectNum
            SubjectROI=Cfg.CalFC.ROIDefSurfLH;%%!!! Change as in Fuction
            for iROI=1:length(SubjectROI)
                if exist(SubjectROI{iROI},'file')==2 % MNI Mask files need to be warped

                elseif (ischar(SubjectROI{iROI})) && ~isempty(strfind(SubjectROI{iROI},'{SubjectID}')) % Process the individual ROI from an expression
                    NewStrDef = replace(SubjectROI{iROI},'{SubjectID}',Cfg.SubjectID{i});
                    NewStrDef = replace(NewStrDef,'{WorkingDir}',Cfg.WorkingDir);
                    if exist(NewStrDef,'file')==2
                        SubjectROI{iROI}=NewStrDef;
                    else
                        error(['The Mask File ',NewStrDef,' does not exist!'])
                    end
                else
                    error(['This Mask definition can not be processed: ',SubjectROI{iROI}])
                end
            end

            % Check if the text file is a definition for multiple subjects. i.e., the first line is 'Seed_ROI_List:', then get the corresponded ROI file
            for iROI=1:length(SubjectROI)
                if (ischar(SubjectROI{iROI})) && (exist(SubjectROI{iROI},'file')==2)
                    [pathstr, name, ext] = fileparts(SubjectROI{iROI});
                    if (strcmpi(ext, '.txt'))
                        fid = fopen(SubjectROI{iROI});
                        SeedTimeCourseList=textscan(fid,'%s\n'); %YAN Chao-Gan, 180320. For compatiblity of MALLAB 2014b. SeedTimeCourseList=textscan(fid,'%s','\n');
                        fclose(fid);
                        if strcmpi(SeedTimeCourseList{1}{1},'Seed_ROI_List:')
                            SubjectROI{iROI}=SeedTimeCourseList{1}{i+1};
                        end
                    end
                end
            end

            ROIDefSurfLHForEachSubject{i}=SubjectROI; %%!!! Change as in Fuction
        end

        Cfg.CalFC.ROIDefSurfLHForEachSubject = ROIDefSurfLHForEachSubject;
    end


    if ~isempty(Cfg.CalFC.ROIDefSurfRH)
        ROIDefSurfRHForEachSubject=cell(Cfg.SubjectNum,1);
        for i=1:Cfg.SubjectNum
            SubjectROI=Cfg.CalFC.ROIDefSurfRH;%%!!! Change as in Fuction
            for iROI=1:length(SubjectROI)
                if exist(SubjectROI{iROI},'file')==2 % MNI Mask files need to be warped
                elseif (ischar(SubjectROI{iROI})) && ~isempty(strfind(SubjectROI{iROI},'{SubjectID}')) % Process the individual ROI from an expression
                    NewStrDef = replace(SubjectROI{iROI},'{SubjectID}',Cfg.SubjectID{i});
                    NewStrDef = replace(NewStrDef,'{WorkingDir}',Cfg.WorkingDir);
                    if exist(NewStrDef,'file')==2
                        SubjectROI{iROI}=NewStrDef;
                    else
                        error(['The Mask File ',NewStrDef,' does not exist!'])
                    end
                else
                    error(['This Mask definition can not be processed: ',SubjectROI{iROI}])
                end
            end

            % Check if the text file is a definition for multiple subjects. i.e., the first line is 'Seed_ROI_List:', then get the corresponded ROI file
            for iROI=1:length(SubjectROI)
                if (ischar(SubjectROI{iROI})) && (exist(SubjectROI{iROI},'file')==2)
                    [pathstr, name, ext] = fileparts(SubjectROI{iROI});
                    if (strcmpi(ext, '.txt'))
                        fid = fopen(SubjectROI{iROI});
                        SeedTimeCourseList=textscan(fid,'%s\n'); %YAN Chao-Gan, 180320. For compatiblity of MALLAB 2014b. SeedTimeCourseList=textscan(fid,'%s','\n');
                        fclose(fid);
                        if strcmpi(SeedTimeCourseList{1}{1},'Seed_ROI_List:')
                            SubjectROI{iROI}=SeedTimeCourseList{1}{i+1};
                        end
                    end
                end
            end

            ROIDefSurfRHForEachSubject{i}=SubjectROI; %%!!! Change as in Fuction
        end

        Cfg.CalFC.ROIDefSurfRHForEachSubject = ROIDefSurfRHForEachSubject;
    end

end


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


%Extract ROI Signals and Functional Connectivity Analysis
if (Cfg.IsExtractROISignals==1) || (Cfg.IsCalFC==1)
    for iFunSession=1:Cfg.FunctionalSessionNumber
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'ROISignals_',Cfg.StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'ROISignals_',Cfg.StartingDirName]);
        if (Cfg.IsProcessVolumeSpace==1)
            mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'ROISignals_',Cfg.StartingDirName_Volume]);
        end
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'ROISignals_SurfLHSurfRHVolu_',Cfg.StartingDirName]);
        
        %Extract the ROI time courses
        parfor i=1:Cfg.SubjectNum
            ROISignalsSurfLH=[];
            ROISignalsSurfRH=[];
            ROISignalsVolu=[];
            % Left Hemi
            if isfield(Cfg.CalFC,'ROIDefSurfLHForEachSubject') && (~isempty(Cfg.CalFC.ROIDefSurfLHForEachSubject)) && (~isempty(Cfg.CalFC.ROIDefSurfLHForEachSubject{i})) % if ~isempty(Cfg.CalFC.ROIDefSurfLH)
                IndividualROI = Cfg.CalFC.ROIDefSurfLHForEachSubject{i}; %y_CheckIndividualROI(Cfg.CalFC.ROIDefSurfLH, i, {'Seed_ROI_List:'}); %YAN Chao-Gan, 210415. Check if need to deal with individual ROI
                DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*_hemi-L*.func.gii'));
                for iFile=1:length(DirName)
                    FileName=DirName(iFile).name;
                    [ROISignalsSurfLH] = y_ExtractROISignal_Surf(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},FileName), ...
                        IndividualROI, ...
                        [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'ROISignals_',Cfg.StartingDirName,filesep,Cfg.SubjectID{i}], ...
                        '', ... % Will not restrict into the brain mask in extracting ROI signals
                        Cfg.CalFC.IsMultipleLabel,Cfg.CalFC.ROISelectedIndexSurfLH);
                end
            end
            
            % Right Hemi
            if isfield(Cfg.CalFC,'ROIDefSurfRHForEachSubject') && (~isempty(Cfg.CalFC.ROIDefSurfRHForEachSubject)) && (~isempty(Cfg.CalFC.ROIDefSurfRHForEachSubject{i})) %~isempty(Cfg.CalFC.ROIDefSurfRH)
                IndividualROI = Cfg.CalFC.ROIDefSurfRHForEachSubject{i}; %y_CheckIndividualROI(Cfg.CalFC.ROIDefSurfRH, i, {'Seed_ROI_List:'}); %YAN Chao-Gan, 210415. Check if need to deal with individual ROI
                DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*_hemi-R*.func.gii'));
                for iFile=1:length(DirName)
                    FileName=DirName(iFile).name;
                    [ROISignalsSurfRH] = y_ExtractROISignal_Surf(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},FileName), ...
                        IndividualROI, ...
                        [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'ROISignals_',Cfg.StartingDirName,filesep,Cfg.SubjectID{i}], ...
                        '', ... % Will not restrict into the brain mask in extracting ROI signals
                        Cfg.CalFC.IsMultipleLabel,Cfg.CalFC.ROISelectedIndexSurfRH);
                end
            end
            
            % Volume
            if isfield(Cfg.CalFC,'ROIDefVoluForEachSubject') && (~isempty(Cfg.CalFC.ROIDefVoluForEachSubject)) && (~isempty(Cfg.CalFC.ROIDefVoluForEachSubject{i})) %~isempty(Cfg.CalFC.ROIDefVolu)  % YAN Chao-Gan, 190708: if (Cfg.IsProcessVolumeSpace==1) && (~isempty(Cfg.CalFC.ROIDefVolu))
                IndividualROI = Cfg.CalFC.ROIDefVoluForEachSubject{i}; %y_CheckIndividualROI(Cfg.CalFC.ROIDefVolu, i, {'Seed_ROI_List:'}); %YAN Chao-Gan, 210415. Check if need to deal with individual ROI
                [ROISignalsVolu] = y_ExtractROISignal([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i}], ...
                IndividualROI, ...
                [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'ROISignals_',Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i}], ...
                '', ... % Will not restrict into the brain mask in extracting ROI signals
                Cfg.CalFC.IsMultipleLabel,Cfg.CalFC.ROISelectedIndexVolu);
            end
            
            ROISignals = [ROISignalsSurfLH, ROISignalsSurfRH, ROISignalsVolu];
            y_CallSave([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'ROISignals_SurfLHSurfRHVolu_',Cfg.StartingDirName,filesep, 'ROISignals_',Cfg.SubjectID{i},'.mat'], ROISignals, '');
            y_CallSave([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'ROISignals_SurfLHSurfRHVolu_',Cfg.StartingDirName,filesep, 'ROISignals_',Cfg.SubjectID{i},'.txt'], ROISignals, ' ''-ASCII'', ''-DOUBLE'',''-TABS''');
            ROICorrelation = corrcoef(ROISignals);
            y_CallSave([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'ROISignals_SurfLHSurfRHVolu_',Cfg.StartingDirName,filesep, 'ROICorrelation_',Cfg.SubjectID{i},'.mat'], ROICorrelation, '');
            y_CallSave([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'ROISignals_SurfLHSurfRHVolu_',Cfg.StartingDirName,filesep, 'ROICorrelation_',Cfg.SubjectID{i},'.txt'], ROICorrelation, ' ''-ASCII'', ''-DOUBLE'',''-TABS''');
            ROICorrelation_FisherZ = 0.5 * log((1 + ROICorrelation)./(1- ROICorrelation));
            y_CallSave([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'ROISignals_SurfLHSurfRHVolu_',Cfg.StartingDirName,filesep, 'ROICorrelation_FisherZ_',Cfg.SubjectID{i},'.mat'], ROICorrelation_FisherZ, '');
            y_CallSave([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'ROISignals_SurfLHSurfRHVolu_',Cfg.StartingDirName,filesep, 'ROICorrelation_FisherZ_',Cfg.SubjectID{i},'.txt'], ROICorrelation_FisherZ, ' ''-ASCII'', ''-DOUBLE'',''-TABS''');
        end
        
        
        %Extract the ROI Center of Mass for Surf. Only do it in the case of calculating in template space
        if (Cfg.IsBasedOnFunSurf==0)
            ROICenter=[];
            if isfield(Cfg.CalFC,'ROIDefSurfLHForEachSubject') && (~isempty(Cfg.CalFC.ROIDefSurfLHForEachSubject)) && (~isempty(Cfg.CalFC.ROIDefSurfLHForEachSubject{1})) 
                [ROICenterLH,XYZCenter,VertexCenter] = y_ExtractCenterOfMass_Surf(Cfg.CalFC.ROIDefSurfLHForEachSubject{1}, [], Cfg.CalFC.IsMultipleLabel,Cfg.CalFC.ROISelectedIndexSurfLH, Cfg.SurfFileLH);
                %[ROICenter,XYZCenter,VertexCenter] = y_ExtractCenterOfMass_Surf(ROIDef, OutputName, IsMultipleLabel, SurfFile)
                ROICenter=[ROICenter;[ROICenterLH,zeros(size(ROICenterLH,1),2)]];
            end

            if isfield(Cfg.CalFC,'ROIDefSurfRHForEachSubject') && (~isempty(Cfg.CalFC.ROIDefSurfRHForEachSubject)) && (~isempty(Cfg.CalFC.ROIDefSurfRHForEachSubject{1})) 
                [ROICenterRH,XYZCenter,VertexCenter] = y_ExtractCenterOfMass_Surf(Cfg.CalFC.ROIDefSurfRHForEachSubject{1}, [], Cfg.CalFC.IsMultipleLabel,Cfg.CalFC.ROISelectedIndexSurfRH, Cfg.SurfFileRH);
                ROICenter=[ROICenter;[ROICenterRH,zeros(size(ROICenterRH,1),2)]];
            end

            if isfield(Cfg.CalFC,'ROIDefVoluForEachSubject') && (~isempty(Cfg.CalFC.ROIDefVoluForEachSubject)) && (~isempty(Cfg.CalFC.ROIDefVoluForEachSubject{1}))
                [ROICenterVolu,XYZCenter,IJKCenter] = y_ExtractROICenterOfMass(Cfg.CalFC.ROIDefVoluForEachSubject{1}, [], Cfg.CalFC.IsMultipleLabel,Cfg.CalFC.ROISelectedIndexVolu, [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{1}]);
                %[ROICenter,XYZCenter,IJKCenter] = y_ExtractROICenterOfMass(ROIDef, OutputName, IsMultipleLabel, RefFile, Header)
                ROICenter=[ROICenter;ROICenterVolu];
            end

            %ROICenter=[[ROICenterLH,zeros(size(ROICenterLH,1),2)];[ROICenterRH,zeros(size(ROICenterRH,1),2)];ROICenterVolu];

            save([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'ROISignals_SurfLHSurfRHVolu_',Cfg.StartingDirName,filesep, 'ROI_CenterOfMass.mat'],'ROICenter');
        end

        %Merge ROI_OrderKey
        fidw = fopen([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'ROISignals_SurfLHSurfRHVolu_',Cfg.StartingDirName,filesep, 'ROI_OrderKey.tsv'],'a+');
        fid = fopen([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'ROISignals_',Cfg.StartingDirName,filesep,'ROI_OrderKey_',Cfg.SubjectID{1},'.tsv']);
        if fid>0
            Table=fread(fid);
            fclose(fid);
            fwrite(fidw,Table);
        end
        
        fid = fopen([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'ROISignals_',Cfg.StartingDirName,filesep,'ROI_OrderKey_',Cfg.SubjectID{1},'.tsv']);
        if fid>0
            tline = fgetl(fid); %Skip the title line
            Table=fread(fid);
            fclose(fid);
            fwrite(fidw,Table);
        end
        
        fid = fopen([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'ROISignals_',Cfg.StartingDirName_Volume,filesep,'ROI_OrderKey_',Cfg.SubjectID{1},'.tsv']);
        if fid>0
            tline = fgetl(fid); %Skip the title line
            Table=fread(fid);
            fclose(fid);
            fwrite(fidw,Table);
        end
        
        fclose(fidw);
    end
end


%Calculate Seed Based Functional Connectivity
if (Cfg.IsCalFC==1)
    for iFunSession=1:Cfg.FunctionalSessionNumber
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'FC_SeedSurfLHSurfRHVolu_',Cfg.StartingDirName]);
        mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'FC_SeedSurfLHSurfRHVolu_',Cfg.StartingDirName]);
        if (Cfg.IsProcessVolumeSpace==1)
            mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'FC_SeedSurfLHSurfRHVolu_',Cfg.StartingDirName_Volume]);
        end
        
        parfor i=1:Cfg.SubjectNum
            % Calculate Functional Connectivity by Seed based Correlation Anlyasis
            MaskFileSurfLH = Cfg.MaskFileSurfLH;
            MaskFileSurfLH = replace(MaskFileSurfLH,'{SubjectID}',Cfg.SubjectID{i});
            MaskFileSurfLH = replace(MaskFileSurfLH,'{WorkingDir}',Cfg.WorkingDir);
            MaskFileSurfRH = Cfg.MaskFileSurfRH;
            MaskFileSurfRH = replace(MaskFileSurfRH,'{SubjectID}',Cfg.SubjectID{i});
            MaskFileSurfRH = replace(MaskFileSurfRH,'{WorkingDir}',Cfg.WorkingDir);
            MaskFileVolu = Cfg.MaskFileVolu;
            MaskFileVolu = replace(MaskFileVolu,'{SubjectID}',Cfg.SubjectID{i});
            MaskFileVolu = replace(MaskFileVolu,'{WorkingDir}',Cfg.WorkingDir);
            
            % Left Hemi
            DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*_hemi-L*.func.gii'));
            for iFile=1:length(DirName)
                FileName=DirName(iFile).name;
                y_SCA_Surf(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},FileName), ...
                    {[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'ROISignals_SurfLHSurfRHVolu_',Cfg.StartingDirName,filesep, 'ROISignals_',Cfg.SubjectID{i},'.txt']}, ... %This is the ROI Signals extracted by the previous step
                    [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfLH',filesep,'FC_SeedSurfLHSurfRHVolu_',Cfg.StartingDirName,filesep,'FC_',Cfg.SubjectID{i},'.func.gii'], ...
                    MaskFileSurfLH, ...
                    1);
            end
            
            % Right Hemi
            DirName=dir(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},'*_hemi-R*.func.gii'));
            for iFile=1:length(DirName)
                FileName=DirName(iFile).name;
                y_SCA_Surf(fullfile(Cfg.WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],Cfg.SubjectID{i},FileName), ...
                    {[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'ROISignals_SurfLHSurfRHVolu_',Cfg.StartingDirName,filesep, 'ROISignals_',Cfg.SubjectID{i},'.txt']}, ...
                    [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunSurfRH',filesep,'FC_SeedSurfLHSurfRHVolu_',Cfg.StartingDirName,filesep,'FC_',Cfg.SubjectID{i},'.func.gii'], ...
                    MaskFileSurfRH, ...
                    1);
            end
            
            % Volume
            if (Cfg.IsProcessVolumeSpace==1)
                % Calculate Functional Connectivity by Seed based Correlation Anlyasis
                y_SCA([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName_Volume,filesep,Cfg.SubjectID{i}], ...
                    {[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'ROISignals_SurfLHSurfRHVolu_',Cfg.StartingDirName,filesep, 'ROISignals_',Cfg.SubjectID{i},'.txt']}, ...
                    [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FunVolu',filesep,'FC_SeedSurfLHSurfRHVolu_',Cfg.StartingDirName_Volume,filesep,'FC_',Cfg.SubjectID{i},'.nii'], ...
                    MaskFileVolu, ...
                    1);
            end
        end
    end
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%***Normalize and/or Smooth the results***%%%%%%%%%%%%%%%%

Cfg.StartingDirName = 'Results';


%Normalize on Results
if (Cfg.IsNormalize>0) && strcmpi(Cfg.Normalize.Timing,'OnResults')

    %Prepare the ref file
    if ~(7==exist([Cfg.WorkingDir,filesep,'Masks'],'dir'))
        mkdir([Cfg.WorkingDir,filesep,'Masks']);
    end
    copyfile([DPABIPath,filesep,'Templates',filesep,'BrainMask_05_97x115x97.nii'],[Cfg.WorkingDir,filesep,'Masks']);

    fprintf(['Normalizing the resutls...\n']);

    try
        mkdir([Cfg.WorkingDir,filesep,Cfg.StartingDirName,'W',filesep,'AnatSurfLH']);
        movefile([Cfg.WorkingDir,filesep,Cfg.StartingDirName,filesep,'AnatSurfLH',filesep,'fsaverage'],[Cfg.WorkingDir,filesep,Cfg.StartingDirName,'W',filesep,'AnatSurfLH']);
        movefile([Cfg.WorkingDir,filesep,Cfg.StartingDirName,filesep,'AnatSurfLH',filesep,'fsaverage5'],[Cfg.WorkingDir,filesep,Cfg.StartingDirName,'W',filesep,'AnatSurfLH']);

        mkdir([Cfg.WorkingDir,filesep,Cfg.StartingDirName,'W',filesep,'AnatSurfRH']);
        movefile([Cfg.WorkingDir,filesep,Cfg.StartingDirName,filesep,'AnatSurfRH',filesep,'fsaverage'],[Cfg.WorkingDir,filesep,Cfg.StartingDirName,'W',filesep,'AnatSurfRH']);
        movefile([Cfg.WorkingDir,filesep,Cfg.StartingDirName,filesep,'AnatSurfRH',filesep,'fsaverage5'],[Cfg.WorkingDir,filesep,Cfg.StartingDirName,'W',filesep,'AnatSurfRH']);

        mkdir([Cfg.WorkingDir,filesep,Cfg.StartingDirName,'W',filesep,'AnatVolu']);
        movefile([Cfg.WorkingDir,filesep,Cfg.StartingDirName,filesep,'AnatVolu',filesep,'MNISpace'],[Cfg.WorkingDir,filesep,Cfg.StartingDirName,'W',filesep,'AnatVolu']);
    catch
    end

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

                    case {'FunSurfLH','FunSurfRH'}
                        SpaceName='fsaverage5';
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
                                if ~((length(DirMeasure(iDir).name)>=10 && strcmpi(DirMeasure(iDir).name(1:10),'ROISignals'))) %~((length(DirMeasure(iDir).name)>10 && strcmpi(DirMeasure(iDir).name(end-10:end),'_ROISignals')))
                                    MeasureSet = [MeasureSet;{DirMeasure(iDir).name}];
                                end
                            end
                        end
                        for iMeasure=1:length(MeasureSet)
                            [tmp1 tmp2]=mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,'W',filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure}]);
                            FileList=[];
                            DirImg=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure},filesep,'*',Cfg.SubjectID{i},'*.gii']);
                            for j=1:length(DirImg)
                                FileList=[FileList,' ',DirImg(j).name];
                            end
                            if strcmpi(DSpaceSet{iDSpace},'FunSurfLH')
                                Command = sprintf('%s parallel -j %g mri_surf2surf --srcsubject %s --trgsubject %s --hemi lh --sval %s/%s/FunSurfLH/%s/{1}  --tval %s/%sW/FunSurfLH/%s/w{1} ::: %s', ...
                                    CommandInit, Cfg.ParallelWorkersNumber, Cfg.SubjectID{i}, SpaceName,WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],MeasureSet{iMeasure}, WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],MeasureSet{iMeasure},FileList);
                                system(Command);
                            elseif strcmpi(DSpaceSet{iDSpace},'FunSurfRH')
                                Command = sprintf('%s parallel -j %g mri_surf2surf --srcsubject %s --trgsubject %s --hemi rh --sval %s/%s/FunSurfRH/%s/{1}  --tval %s/%sW/FunSurfRH/%s/w{1} ::: %s', ...
                                    CommandInit, Cfg.ParallelWorkersNumber, Cfg.SubjectID{i}, SpaceName,WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],MeasureSet{iMeasure}, WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],MeasureSet{iMeasure},FileList);
                                system(Command);
                            end
                        end

                    case {'FunVolu'}
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
                                if ~((length(DirMeasure(iDir).name)>=10 && strcmpi(DirMeasure(iDir).name(1:10),'ROISignals'))) %~((length(DirMeasure(iDir).name)>10 && strcmpi(DirMeasure(iDir).name(end-10:end),'_ROISignals')))
                                    MeasureSet = [MeasureSet;{DirMeasure(iDir).name}];
                                end
                            end
                        end

                        for iMeasure=1:length(MeasureSet)
                            [tmp1 tmp2]=mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,'W',filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure}]);
                            FileList=[];
                            DirImg=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure},filesep,'*',Cfg.SubjectID{i},'*.nii*']);
                            for j=1:length(DirImg)
                                FileList=[FileList,' ',DirImg(j).name];
                            end
                            Command = sprintf('%s antsApplyTransforms --default-value 0 --float 0 --input %s/%s/%s/%s/{1} --interpolation Linear --output %s/%sW/%s/%s/w{1} --reference-image %s/Masks/BrainMask_05_97x115x97.nii  --transform %s/fmriprep/%s/anat/%s_from-T1w_to-MNI152NLin2009cAsym_mode-image_xfm.h5 ::: %s', ...
                                CommandParallel, WorkingDir, [FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],DSpaceSet{iDSpace},MeasureSet{iMeasure}, WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],DSpaceSet{iDSpace},MeasureSet{iMeasure},WorkingDir,WorkingDir,Cfg.SubjectID{i},Cfg.SubjectID{i},FileList);
                            system(Command);

                        end

                end
            end
        end
    end

    Cfg.StartingDirName=[Cfg.StartingDirName,'W']; %Now StartingDirName is with new suffix 'S'
end



%Smooth on Results
if (Cfg.IsSmooth==1) && strcmpi(Cfg.Smooth.Timing,'OnResults')
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
                    case {'AnatSurfLH','AnatSurfRH'}
                        DirLevel1 = dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace}]);
                        if strcmpi(DirLevel1(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
                            StartIndexLevel1=4;
                        else
                            StartIndexLevel1=3;
                        end
                        for iDirLevel1=StartIndexLevel1:length(DirLevel1)
                            if DirLevel1(iDirLevel1).isdir

                                SpaceName=DirLevel1(iDirLevel1).name;
                                if strcmpi(SpaceName,'fsnative')
                                    SpaceName=Cfg.SubjectID{i};
                                end

                                DirLevel2 = dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,DirLevel1(iDirLevel1).name]);
                                if strcmpi(DirLevel2(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
                                    StartIndexLevel2=4;
                                else
                                    StartIndexLevel2=3;
                                end
                                for iDirLevel2=StartIndexLevel2:length(DirLevel2)
                                    if DirLevel2(iDirLevel2).isdir
                                        [tmp1 tmp2]=mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,'S',filesep,DSpaceSet{iDSpace},filesep,DirLevel1(iDirLevel1).name,filesep,DirLevel2(iDirLevel2).name]);
                                        FileList=[];
                                        DirImg=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,DirLevel1(iDirLevel1).name,filesep,DirLevel2(iDirLevel2).name,filesep,'*',Cfg.SubjectID{i},'*.gii']);
                                        for j=1:length(DirImg)
                                            FileList=[FileList,' ',DirImg(j).name];
                                        end
                                        if strcmpi(DSpaceSet{iDSpace},'AnatSurfLH')
                                            Command = sprintf('%s parallel -j %g mri_surf2surf --s %s --hemi lh --sval %s/%s/AnatSurfLH/%s/%s/{1}  --fwhm %g --cortex --tval %s/%sS/AnatSurfLH/%s/%s/s{1} ::: %s', ...
                                                CommandInit, Cfg.ParallelWorkersNumber, SpaceName, WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],DirLevel1(iDirLevel1).name, DirLevel2(iDirLevel2).name, Cfg.Smooth.FWHMSurf, WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],DirLevel1(iDirLevel1).name, DirLevel2(iDirLevel2).name,FileList);
                                            system(Command);

                                        elseif strcmpi(DSpaceSet{iDSpace},'AnatSurfRH')
                                            Command = sprintf('%s parallel -j %g mri_surf2surf --s %s --hemi rh --sval %s/%s/AnatSurfRH/%s/%s/{1}  --fwhm %g --cortex --tval %s/%sS/AnatSurfRH/%s/%s/s{1} ::: %s', ...
                                                CommandInit, Cfg.ParallelWorkersNumber, SpaceName, WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],DirLevel1(iDirLevel1).name, DirLevel2(iDirLevel2).name, Cfg.Smooth.FWHMSurf, WorkingDir,[FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],DirLevel1(iDirLevel1).name, DirLevel2(iDirLevel2).name,FileList);
                                            system(Command);
                                        end
                                    end
                                end
                            end
                        end

                    case {'FunSurfLH','FunSurfRH'}

                        if (Cfg.IsBasedOnFunSurf==1) && (~strcmp(Cfg.StartingDirName(end),'W'))
                            SpaceName=Cfg.SubjectID{i};
                        else
                            SpaceName='fsaverage5';
                        end
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
                                if ~((length(DirMeasure(iDir).name)>=10 && strcmpi(DirMeasure(iDir).name(1:10),'ROISignals'))) %~((length(DirMeasure(iDir).name)>10 && strcmpi(DirMeasure(iDir).name(end-10:end),'_ROISignals')))
                                    MeasureSet = [MeasureSet;{DirMeasure(iDir).name}];
                                end
                            end
                        end
                        for iMeasure=1:length(MeasureSet)
                            [tmp1 tmp2]=mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,'S',filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure}]);
                            FileList=[];
                            DirImg=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,MeasureSet{iMeasure},filesep,'*',Cfg.SubjectID{i},'*.gii']);
                            for j=1:length(DirImg)
                                FileList=[FileList,' ',DirImg(j).name];
                            end
                            if strcmpi(DSpaceSet{iDSpace},'FunSurfLH')
                                Command = sprintf('%s parallel -j %g mri_surf2surf --s %s --hemi lh --sval /data/%s/FunSurfLH/%s/{1}  --fwhm %g --cortex --tval /data/%sS/FunSurfLH/%s/s{1} ::: %s', ...
                                    CommandInit, Cfg.ParallelWorkersNumber, SpaceName, [FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],MeasureSet{iMeasure}, Cfg.Smooth.FWHMSurf, [FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],MeasureSet{iMeasure},FileList);
                                system(Command);
                            elseif strcmpi(DSpaceSet{iDSpace},'FunSurfRH')
                                Command = sprintf('%s parallel -j %g mri_surf2surf --s %s --hemi rh --sval /data/%s/FunSurfRH/%s/{1}  --fwhm %g --cortex --tval /data/%sS/FunSurfRH/%s/s{1} ::: %s', ...
                                    CommandInit, Cfg.ParallelWorkersNumber, SpaceName, [FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],MeasureSet{iMeasure}, Cfg.Smooth.FWHMSurf, [FunSessionPrefixSet{iFunSession},Cfg.StartingDirName],MeasureSet{iMeasure},FileList);
                                system(Command);
                            end
                        end

                    case {'FunVolu'}
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
                                if ~((length(DirMeasure(iDir).name)>=10 && strcmpi(DirMeasure(iDir).name(1:10),'ROISignals'))) %~((length(DirMeasure(iDir).name)>10 && strcmpi(DirMeasure(iDir).name(end-10:end),'_ROISignals')))
                                    MeasureSet = [MeasureSet;{DirMeasure(iDir).name}];
                                end
                            end
                        end
                        for iMeasure=1:length(MeasureSet)
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
                                SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Smooth.mat']);
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
                        end

                    case {'AnatVolu'}
                        %Check the measures need to be normalized
                        DirLevel1 = dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace}]);
                        if strcmpi(DirLevel1(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
                            StartIndexLevel1=4;
                        else
                            StartIndexLevel1=3;
                        end
                        for iDirLevel1=StartIndexLevel1:length(DirLevel1)
                            if DirLevel1(iDirLevel1).isdir
                                DirLevel2 = dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,DirLevel1(iDirLevel1).name]);
                                if strcmpi(DirLevel2(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
                                    StartIndexLevel2=4;
                                else
                                    StartIndexLevel2=3;
                                end
                                for iDirLevel2=StartIndexLevel2:length(DirLevel2)
                                    if DirLevel2(iDirLevel2).isdir
                                        [tmp1 tmp2]=mkdir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,'S',filesep,DSpaceSet{iDSpace},filesep,DirLevel1(iDirLevel1).name,filesep,DirLevel2(iDirLevel2).name]);
                                        FileList=[];
                                        DirImg=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,DirLevel1(iDirLevel1).name,filesep,DirLevel2(iDirLevel2).name,filesep,'*',Cfg.SubjectID{i},'*.nii.gz']);

                                        if ~isempty(DirImg)
                                            for j=1:length(DirImg)
                                                gunzip([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,DirLevel1(iDirLevel1).name,filesep,DirLevel2(iDirLevel2).name,filesep,DirImg(j).name]);
                                                delete([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,DirLevel1(iDirLevel1).name,filesep,DirLevel2(iDirLevel2).name,filesep,DirImg(j).name]);
                                            end
                                        end
                                        DirImg=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,DirLevel1(iDirLevel1).name,filesep,DirLevel2(iDirLevel2).name,filesep,'*',Cfg.SubjectID{i},'*.nii']);
                                        if ~isempty(DirImg)
                                            for j=1:length(DirImg)
                                                FileList=[FileList;{[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,DirLevel1(iDirLevel1).name,filesep,DirLevel2(iDirLevel2).name,filesep,DirImg(j).name]}];
                                            end
                                            SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Smooth.mat']);
                                            SPMJOB.matlabbatch{1,1}.spm.spatial.smooth.data = FileList;
                                            SPMJOB.matlabbatch{1,1}.spm.spatial.smooth.fwhm = Cfg.Smooth.FWHMVolu;
                                            spm_jobman('run',SPMJOB.matlabbatch);

                                            DirTemp=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,DirLevel1(iDirLevel1).name,filesep,DirLevel2(iDirLevel2).name,filesep,'ss*']);
                                            if isempty(DirTemp)
                                                movefile([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,DirLevel1(iDirLevel1).name,filesep,DirLevel2(iDirLevel2).name,filesep,'s*'],[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,'S',filesep,DSpaceSet{iDSpace},filesep,DirLevel1(iDirLevel1).name,filesep,DirLevel2(iDirLevel2).name]);
                                            else
                                                movefile([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,filesep,DSpaceSet{iDSpace},filesep,DirLevel1(iDirLevel1).name,filesep,DirLevel2(iDirLevel2).name,filesep,'ss*'],[Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},Cfg.StartingDirName,'S',filesep,DSpaceSet{iDSpace},filesep,DirLevel1(iDirLevel1).name,filesep,DirLevel2(iDirLevel2).name]);
                                            end
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



fprintf(['\nCongratulations, the running of DPABISurf is done!!! :)\n\n']);

