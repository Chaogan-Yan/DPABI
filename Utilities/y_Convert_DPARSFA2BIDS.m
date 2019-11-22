function SubjectID_BIDS = y_Convert_DPARSFA2BIDS(InDir, OutDir, Cfg)
% function SubjectID_BIDS = y_Convert_DPARSFA2BIDS(InDir, OutDir, Cfg)
% Convert DPARSF data structure to BIDS data structure.
%   Input:
%     InDir  - Input dir with DPARSFA data.
%     OutDir - Output dir with BIDS data.
%     Cfg - DPARSFA Cfg structure
%   Output:
%     OutDir  - Output dir with BIDS data.
%     SubjectID_BIDS  - Subject ID in BIDS.
%___________________________________________________________________________
% Written by YAN Chao-Gan 181104.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com

fprintf('Converting DPARSFA to BIDS structure...\n');

if ~isempty(InDir)
    Cfg.DataProcessDir=InDir;
end

Cfg.SubjectNum=length(Cfg.SubjectID);
FunSessionPrefixSet={''}; %The first session doesn't need a prefix. From the second session, need a prefix such as 'S2_';
for iFunSession=2:Cfg.FunctionalSessionNumber
    FunSessionPrefixSet=[FunSessionPrefixSet;{['S',num2str(iFunSession),'_']}];
end

%Generate new subject ID
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

%Write the ID
fid = fopen([Cfg.DataProcessDir,filesep,'SubjectID_DPARSFA2BIDS.tsv'],'w');
fprintf(fid,'SubjectID_BIDS');
fprintf(fid,['\t','SubjectID_Original']);
fprintf(fid,'\n');
for i=1:Cfg.SubjectNum
    fprintf(fid,'%s',SubjectID_BIDS{i});
    fprintf(fid,'\t%s',Cfg.SubjectID{i});
    fprintf(fid,'\n');
end
fclose(fid);

%Single session data
if Cfg.FunctionalSessionNumber==1
    for i=1:length(SubjectID_BIDS)
        %Dealing with anatomical data
        mkdir([OutDir,filesep,SubjectID_BIDS{i},filesep,'anat']);
        %First check T1w image started with co (T1 image which is reoriented to the nearest orthogonal direction to ''canonical space'' and removed excess air surrounding the individual as well as parts of the neck below the cerebellum)
        DirImg=dir([Cfg.DataProcessDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,'c*.img']);
        if ~isempty(DirImg)
            [Data Header]=y_Read([Cfg.DataProcessDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name]);
            y_Write(Data,Header,[OutDir,filesep,SubjectID_BIDS{i},filesep,'anat',filesep,SubjectID_BIDS{i},'_T1w.nii'])
        else
            DirImg=dir([Cfg.DataProcessDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,'c*.nii.gz']);
            if ~isempty(DirImg)
                copyfile([Cfg.DataProcessDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'anat',filesep,SubjectID_BIDS{i},'_T1w.nii.gz'])
            else
                DirImg=dir([Cfg.DataProcessDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,'c*.nii']);
                if ~isempty(DirImg)
                    copyfile([Cfg.DataProcessDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'anat',filesep,SubjectID_BIDS{i},'_T1w.nii'])
                else
                    DirImg=dir([Cfg.DataProcessDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,'*Crop*.nii']); %YAN Chao-Gan, 191121. For BIDS format. Change searching c* to *Crop*
                    if ~isempty(DirImg)
                        copyfile([Cfg.DataProcessDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'anat',filesep,SubjectID_BIDS{i},'_T1w.nii'])
                    end
                end
            end
        end
        
        %If there is no co* T1w images
        if isempty(DirImg)
            DirImg=dir([Cfg.DataProcessDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,'*.img']);
            if ~isempty(DirImg)
                [Data Header]=y_Read([Cfg.DataProcessDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name]);
                y_Write(Data,Header,[OutDir,filesep,SubjectID_BIDS{i},filesep,'anat',filesep,SubjectID_BIDS{i},'_T1w.nii'])
            else
                DirImg=dir([Cfg.DataProcessDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,'*.nii.gz']);
                if ~isempty(DirImg)
                    copyfile([Cfg.DataProcessDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'anat',filesep,SubjectID_BIDS{i},'_T1w.nii.gz'])
                else
                    DirImg=dir([Cfg.DataProcessDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,'*.nii']);
                    if ~isempty(DirImg)
                        copyfile([Cfg.DataProcessDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'anat',filesep,SubjectID_BIDS{i},'_T1w.nii'])
                    end
                end
            end
        end
        
        DirJSON=dir([Cfg.DataProcessDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,'*.json']); %YAN Chao-Gan, 191121. For BIDS format. Copy JSON
        if ~isempty(DirJSON)
            copyfile([Cfg.DataProcessDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,DirJSON(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'anat',filesep,SubjectID_BIDS{i},'_T1w.json'])
        end
        
        
        %Dealing with functional data
        mkdir([OutDir,filesep,SubjectID_BIDS{i},filesep,'func'])
        DirImg=dir([Cfg.DataProcessDir,filesep,'FunImg',filesep,Cfg.SubjectID{i},filesep,'*.img']);
        DirNii=dir([Cfg.DataProcessDir,filesep,'FunImg',filesep,Cfg.SubjectID{i},filesep,'*.nii']);
        DirNiiGZ=dir([Cfg.DataProcessDir,filesep,'FunImg',filesep,Cfg.SubjectID{i},filesep,'*.nii.gz']);
        if ~isempty(DirImg) || length(DirNii)>=2  || length(DirNiiGZ)>=2
            [Data,VoxelSize,theImgFileList, Header] =y_ReadAll([Cfg.DataProcessDir,filesep,'FunImg',filesep,Cfg.SubjectID{i}]);
            y_Write(Data,Header,[OutDir,filesep,SubjectID_BIDS{i},filesep,'func',filesep,SubjectID_BIDS{i},'_task-rest_bold.nii'])
        elseif length(DirNii)==1
            copyfile([Cfg.DataProcessDir,filesep,'FunImg',filesep,Cfg.SubjectID{i},filesep,DirNii(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'func',filesep,SubjectID_BIDS{i},'_task-rest_bold.nii'])
        elseif length(DirNiiGZ)==1
            copyfile([Cfg.DataProcessDir,filesep,'FunImg',filesep,Cfg.SubjectID{i},filesep,DirNiiGZ(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'func',filesep,SubjectID_BIDS{i},'_task-rest_bold.nii.gz'])
        end
        
        DirJSON=dir([Cfg.DataProcessDir,filesep,'FunImg',filesep,Cfg.SubjectID{i},filesep,'*.json']); %YAN Chao-Gan, 191121. For BIDS format. Copy JSON
        if ~isempty(DirJSON)
            copyfile([Cfg.DataProcessDir,filesep,'FunImg',filesep,Cfg.SubjectID{i},filesep,DirJSON(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'func',filesep,SubjectID_BIDS{i},'_task-rest_bold.json'])
        end
        
    end
end


%Multiple session data
if Cfg.FunctionalSessionNumber>=2
    %Dealing with anatomical data
    %Check if exist S2_T1Img, that means mutiple run of T1 image exist
    if 7==exist([Cfg.DataProcessDir,filesep,'S2_T1Img'],'dir')
        T1SessionNumber = Cfg.FunctionalSessionNumber;
    else
        T1SessionNumber = 1;
    end
    for iT1Session=1:T1SessionNumber
        for i=1:length(SubjectID_BIDS)
            
            mkdir([OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iT1Session),filesep,'anat']);
            %First check T1w image started with co (T1 image which is reoriented to the nearest orthogonal direction to ''canonical space'' and removed excess air surrounding the individual as well as parts of the neck below the cerebellum)
            DirImg=dir([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,'c*.img']);
            if ~isempty(DirImg)
                [Data Header]=y_Read([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name]);
                y_Write(Data,Header,[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iT1Session),filesep,'anat',filesep,SubjectID_BIDS{i},'_ses-',num2str(iT1Session),'_T1w.nii'])
            else
                DirImg=dir([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,'c*.nii.gz']);
                if ~isempty(DirImg)
                    copyfile([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iT1Session),filesep,'anat',filesep,SubjectID_BIDS{i},'_ses-',num2str(iT1Session),'_T1w.nii.gz'])
                else
                    DirImg=dir([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,'c*.nii']);
                    if ~isempty(DirImg)
                        copyfile([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iT1Session),filesep,'anat',filesep,SubjectID_BIDS{i},'_ses-',num2str(iT1Session),'_T1w.nii'])
                    else
                        DirImg=dir([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,'*Crop*.nii']); %YAN Chao-Gan, 191121. For BIDS format. Change searching c* to *Crop*
                        if ~isempty(DirImg)
                            copyfile([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iT1Session),filesep,'anat',filesep,SubjectID_BIDS{i},'_ses-',num2str(iT1Session),'_T1w.nii'])
                        end
                    end
                end
            end
            
            %If there is no co* T1w images
            if isempty(DirImg)
                DirImg=dir([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,'*.img']);
                if ~isempty(DirImg)
                    [Data Header]=y_Read([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name]);
                    y_Write(Data,Header,[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iT1Session),filesep,'anat',filesep,SubjectID_BIDS{i},'_ses-',num2str(iT1Session),'_T1w.nii'])
                else
                    DirImg=dir([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,'*.nii.gz']);
                    if ~isempty(DirImg)
                        copyfile([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iT1Session),filesep,'anat',filesep,SubjectID_BIDS{i},'_ses-',num2str(iT1Session),'_T1w.nii.gz'])
                    else
                        DirImg=dir([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,'*.nii']);
                        if ~isempty(DirImg)
                            copyfile([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iT1Session),filesep,'anat',filesep,SubjectID_BIDS{i},'_ses-',num2str(iT1Session),'_T1w.nii'])
                        end
                    end
                end
            end
            
            DirJSON=dir([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,'*.json']); %YAN Chao-Gan, 191121. For BIDS format. Copy JSON
            if ~isempty(DirJSON)
                copyfile([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,DirJSON(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iT1Session),filesep,'anat',filesep,SubjectID_BIDS{i},'_ses-',num2str(iT1Session),'_T1w.json'])
            end
        end
    end
            
    %Dealing with functional data
    for iFunSession=1:Cfg.FunctionalSessionNumber
        for i=1:length(SubjectID_BIDS)
            mkdir([OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFunSession),filesep,'func'])
            DirImg=dir([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunImg',filesep,Cfg.SubjectID{i},filesep,'*.img']);
            DirNii=dir([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunImg',filesep,Cfg.SubjectID{i},filesep,'*.nii']);
            DirNiiGZ=dir([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunImg',filesep,Cfg.SubjectID{i},filesep,'*.nii.gz']);
            if ~isempty(DirImg) || length(DirNii)>=2  || length(DirNiiGZ)>=2
                [Data,VoxelSize,theImgFileList, Header] =y_ReadAll([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunImg',filesep,Cfg.SubjectID{i}]);
                y_Write(Data,Header,[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFunSession),filesep,'func',filesep,SubjectID_BIDS{i},'_ses-',num2str(iFunSession),'_task-rest_bold.nii'])
            elseif length(DirNii)==1
                copyfile([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunImg',filesep,Cfg.SubjectID{i},filesep,DirNii(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFunSession),filesep,'func',filesep,SubjectID_BIDS{i},'_ses-',num2str(iFunSession),'_task-rest_bold.nii'])
            elseif length(DirNiiGZ)==1
                copyfile([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunImg',filesep,Cfg.SubjectID{i},filesep,DirNiiGZ(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFunSession),filesep,'func',filesep,SubjectID_BIDS{i},'_ses-',num2str(iFunSession),'_task-rest_bold.nii.gz'])
            end
            
            DirJSON=dir([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunImg',filesep,Cfg.SubjectID{i},filesep,'*.json']); %YAN Chao-Gan, 191121. For BIDS format. Copy JSON
            if ~isempty(DirJSON)
                copyfile([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunImg',filesep,Cfg.SubjectID{i},filesep,DirJSON(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFunSession),filesep,'func',filesep,SubjectID_BIDS{i},'_ses-',num2str(iFunSession),'_task-rest_bold.json'])
            end
        end
    end
end


%Save JISON files
clear JSON
JSON.BIDSVersion='1.0.0';
JSON.Name='DPARSFA2BIDS';
spm_jsonwrite([OutDir,filesep,'dataset_description.json'],JSON);


%Check TR and Subject ID, TR, Slice Number, Time Points, Voxel Size into TRInfo.tsv if needed.
if isfield(Cfg,'TR')
    if Cfg.TR==0  % Need to retrieve the TR information from the NIfTI images
        if (2==exist([Cfg.DataProcessDir,filesep,'TRInfo.tsv'],'file'))  %If the TR information is stored in TRInfo.tsv. %YAN Chao-Gan, 130612
            
            fid = fopen([Cfg.DataProcessDir,filesep,'TRInfo.tsv']);
            StringFilter = '%s';
            for iFunSession=1:Cfg.FunctionalSessionNumber
                StringFilter = [StringFilter,'\t%f']; %Get the TRs for the sessions.
            end
            StringFilter = [StringFilter,'%*[^\n]']; %Skip the else till end of the line
            tline = fgetl(fid); %Skip the title line
            TRInfoTemp = textscan(fid,StringFilter);
            fclose(fid);
            
            for i=1:Cfg.SubjectNum
                if ~strcmp(Cfg.SubjectID{i},TRInfoTemp{1}{i})
                    error(['The subject ID ',TRInfoTemp{1}{i},' in TRInfo.tsv doesn''t match the target sbuject ID: ',Cfg.SubjectID{i},'!'])
                end
            end
            
            TRSet = zeros(Cfg.SubjectNum,Cfg.FunctionalSessionNumber);
            for iFunSession=1:Cfg.FunctionalSessionNumber
                TRSet(:,iFunSession) = TRInfoTemp{1+iFunSession}; %The first column is Subject ID
            end
            
        elseif (2==exist([Cfg.DataProcessDir,filesep,'TRSet.txt'],'file'))  %If the TR information is stored in TRSet.txt (DPARSF V2.2).
            TRSet = load([Cfg.DataProcessDir,filesep,'TRSet.txt']);
            TRSet = TRSet'; %YAN Chao-Gan 130612. This is for the compatibility with DPARSFA V2.2. Cause the TRSet saved there is in a transpose manner.
        else
            
            TRSet = zeros(Cfg.SubjectNum,Cfg.FunctionalSessionNumber);
            SliceNumber = zeros(Cfg.SubjectNum,Cfg.FunctionalSessionNumber);
            nTimePoints = zeros(Cfg.SubjectNum,Cfg.FunctionalSessionNumber);
            VoxelSize = zeros(Cfg.SubjectNum,Cfg.FunctionalSessionNumber,3);
            for iFunSession=1:Cfg.FunctionalSessionNumber
                for i=1:Cfg.SubjectNum
                    cd([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunImg',filesep,Cfg.SubjectID{i}]);
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
            
            %Write the information as TRInfo.tsv
            fid = fopen([Cfg.DataProcessDir,filesep,'TRInfo.tsv'],'w');
            
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
                fprintf(fid,'%s',SubjectID_BIDS{i}); %fprintf(fid,'%s',Cfg.SubjectID{i});
                
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


%Get Slice Timing info
for iFunSession=1:Cfg.FunctionalSessionNumber
    for i=1:Cfg.SubjectNum
        cd([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunImg',filesep,Cfg.SubjectID{i}]);
        DirImg=dir([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunImg',filesep,Cfg.SubjectID{i},filesep,'*.img']);
        if isempty(DirImg)
            DirImg=dir([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunImg',filesep,Cfg.SubjectID{i},filesep,'*.nii.gz']);
            if length(DirImg)==1
                gunzip([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunImg',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name]);
                delete([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunImg',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name]);
            end
            DirImg=dir([Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunImg',filesep,Cfg.SubjectID{i},filesep,'*.nii']);
        end
        File=[Cfg.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunImg',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name];
        
        if Cfg.SliceTiming.SliceNumber==0 %If SliceNumber is set to 0, then retrieve the slice number from the NIfTI images. The slice order is then assumed as interleaved scanning: [1:2:SliceNumber,2:2:SliceNumber]. The reference slice is set to the slice acquired at the middle time point, i.e., SliceOrder(ceil(SliceNumber/2)). SHOULD BE EXTREMELY CAUTIOUS!!!
            Nii=nifti(File);
            SliceNumber = size(Nii.dat,3);
            if exist([Cfg.DataProcessDir,filesep,'SliceOrderInfo.tsv'],'file')==2 % YAN Chao-Gan, 130524. Read the slice timing information from a tsv file (Tab-separated values)
                fid = fopen([Cfg.DataProcessDir,filesep,'SliceOrderInfo.tsv']);
                StringFilter = '%s';
                for iFunSessionTemp=1:Cfg.FunctionalSessionNumber
                    StringFilter = [StringFilter,'\t%s']; %Get the Slice Order Type for the sessions.
                end
                tline = fgetl(fid); %Skip the title line
                SliceOrderSet = textscan(fid,StringFilter); %YAN Chao-Gan, 151210. For matlab 2015. %SliceOrderSet = textscan(fid,StringFilter,'\n');
                fclose(fid);
                
                if ~strcmp(Cfg.SubjectID{i},SliceOrderSet{1}{i})
                    error(['The subject ID ',SliceOrderSet{1}{i},' in SliceOrderInfo.tsv doesn''t match the target sbuject ID: ',Cfg.SubjectID{i},'!'])
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
                            SliceOrder = load([Cfg.DataProcessDir,filesep,SliceOrderSet{1+iFunSession}{i}]); %The slice order is specified in a text file.
                        catch
                            error(['The specified slice order definition ',SliceOrderSet{1+iFunSession}{i},' for subject ',Cfg.SubjectID{i},' is not supported!'])
                        end
                end;
                
                SliceOrder = SliceOrder;
                
            else
                SliceOrder = [1:2:SliceNumber,2:2:SliceNumber];
            end
            
        else
            SliceNumber = Cfg.SliceTiming.SliceNumber;
            SliceOrder = Cfg.SliceTiming.SliceOrder;
        end
        
        if Cfg.TR==0  %If TR is set to 0, then Need to retrieve the TR information from the NIfTI images
            TR = Cfg.TRSet(i,iFunSession);
        else
            TR = Cfg.TR;
        end

        if max(SliceOrder) <= SliceNumber %if provided is slice order
            TA = TR - (TR/SliceNumber);
            SliceTimingInAcquisition = linspace(0, TA, SliceNumber);
            SliceTiming(SliceOrder)=SliceTimingInAcquisition;
        else
            SliceTiming=SliceOrder/1000; %From ms to s.
        end
        
        
        clear JSON
        JSON.RepetitionTime=TR;
        JSON.SliceTiming=SliceTiming;
        JSON.TaskName='REST';
        if Cfg.FunctionalSessionNumber==1
            JSONFile=[OutDir,filesep,SubjectID_BIDS{i},filesep,'func',filesep,SubjectID_BIDS{i},'_task-rest_bold.json'];
        else
            JSONFile=[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFunSession),filesep,'func',filesep,SubjectID_BIDS{i},'_ses-',num2str(iFunSession),'_task-rest_bold.json'];
        end
        if ~exist(JSONFile) % If the JSON files were not copied from dcm2niix's conversion, then write one.
            spm_jsonwrite(JSONFile,JSON);
        else
            JSON_Exist = spm_jsonread(JSONFile);
            if ~isfield(JSON_Exist,'SliceTiming') % If the JSON from dcm2niix does not have slice timing information, then write one.
                spm_jsonwrite(JSONFile,JSON);
            end
        end
    end
end


%Rewrite subject ID in TRInfo.tsv if exists.
if (2==exist([Cfg.WorkingDir,filesep,'TRInfo.tsv'],'file'))  %If the TR information is stored in TRInfo.tsv. %YAN Chao-Gan, 130612
    movefile([Cfg.WorkingDir,filesep,'TRInfo.tsv'],[Cfg.WorkingDir,filesep,'TRInfo_SubjectID_Original.tsv'])
    fidr = fopen([Cfg.WorkingDir,filesep,'TRInfo_SubjectID_Original.tsv']);
    fidw = fopen([Cfg.WorkingDir,filesep,'TRInfo.tsv'],'w');
    
    tline = fgetl(fidr);  %the title line
    fprintf(fidw,tline);
    fprintf(fidw,'\n');
    
    tline = fgetl(fidr);
    i=1;
    while ischar(tline)
        newline=[SubjectID_BIDS{i}, tline(length(Cfg.SubjectID{i})+1:end)];
        fprintf(fidw,newline);
        fprintf(fidw,'\n');
        tline = fgetl(fidr);
        i=i+1;
    end
    fclose(fidr);
    fclose(fidw);
end



