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
    Cfg.WorkingDir=InDir;
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
fid = fopen([Cfg.WorkingDir,filesep,'SubjectID_DPARSFA2BIDS.tsv'],'w');
fprintf(fid,'SubjectID_BIDS');
fprintf(fid,['\t','SubjectID_Original']);
fprintf(fid,'\n');
for i=1:Cfg.SubjectNum
    fprintf(fid,'%s',SubjectID_BIDS{i});
    fprintf(fid,'\t%s',Cfg.SubjectID{i});
    fprintf(fid,'\n');
end
fclose(fid);

MaxFunSessionNumber=max(Cfg.FunctionalSessionNumber,1);
FunJSONFileSet=cell(Cfg.SubjectNum,MaxFunSessionNumber);
FunSBREFJSONFileSet=cell(Cfg.SubjectNum,MaxFunSessionNumber);
FunMetadataSourceFiles=cell(Cfg.SubjectNum,MaxFunSessionNumber);
% uMR 5T data includes TI2Img (INV2); use it to MPRAGEise the T1/UNI image.
IsUMR5T=7==exist([Cfg.WorkingDir,filesep,'TI2Img'],'dir');
if IsUMR5T
    [DPABIPath, ~, ~] = fileparts(which('DPABI.m'));
    [CurrentDPABIPath, ~, ~] = fileparts(fileparts(mfilename('fullpath')));
    if isempty(DPABIPath) || ...
            ((2~=exist(fullfile(DPABIPath,'RedistributedToolboxes','MPRAGEise_yan.py'),'file')) && ...
            (2==exist(fullfile(CurrentDPABIPath,'RedistributedToolboxes','MPRAGEise_yan.py'),'file')))
        DPABIPath=CurrentDPABIPath;
    end
    fprintf('TI2Img folder detected. Applying uMR 5T MPRAGEise correction to T1w images...\n');
else
    DPABIPath='';
end

%Single session data
if Cfg.FunctionalSessionNumber<=1
    for i=1:length(SubjectID_BIDS)
        %Dealing with anatomical data
        mkdir([OutDir,filesep,SubjectID_BIDS{i},filesep,'anat']);
        %First check T1w image started with co (T1 image which is reoriented to the nearest orthogonal direction to ''canonical space'' and removed excess air surrounding the individual as well as parts of the neck below the cerebellum)
        DirImg=dir([Cfg.WorkingDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,'c*.img']);
        if ~isempty(DirImg)
            [Data Header]=y_Read([Cfg.WorkingDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name]);
            y_Write(Data,Header,[OutDir,filesep,SubjectID_BIDS{i},filesep,'anat',filesep,SubjectID_BIDS{i},'_T1w.nii'])
        else
            DirImg=dir([Cfg.WorkingDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,'c*.nii.gz']);
            if ~isempty(DirImg)
                copyfile([Cfg.WorkingDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'anat',filesep,SubjectID_BIDS{i},'_T1w.nii.gz'])
            else
                DirImg=dir([Cfg.WorkingDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,'c*.nii']);
                if ~isempty(DirImg)
                    copyfile([Cfg.WorkingDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'anat',filesep,SubjectID_BIDS{i},'_T1w.nii'])
                else
                    DirImg=dir([Cfg.WorkingDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,'*Crop*.nii']); %YAN Chao-Gan, 191121. For BIDS format. Change searching c* to *Crop*
                    if ~isempty(DirImg)
                        copyfile([Cfg.WorkingDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'anat',filesep,SubjectID_BIDS{i},'_T1w.nii'])
                    end
                end
            end
        end
        
        %If there is no co* T1w images
        if isempty(DirImg)
            DirImg=dir([Cfg.WorkingDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,'*.img']);
            if ~isempty(DirImg)
                [Data Header]=y_Read([Cfg.WorkingDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name]);
                y_Write(Data,Header,[OutDir,filesep,SubjectID_BIDS{i},filesep,'anat',filesep,SubjectID_BIDS{i},'_T1w.nii'])
            else
                DirImg=dir([Cfg.WorkingDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,'*.nii.gz']);
                if ~isempty(DirImg)
                    copyfile([Cfg.WorkingDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'anat',filesep,SubjectID_BIDS{i},'_T1w.nii.gz'])
                else
                    DirImg=dir([Cfg.WorkingDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,'*.nii']);
                    if ~isempty(DirImg)
                        copyfile([Cfg.WorkingDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'anat',filesep,SubjectID_BIDS{i},'_T1w.nii'])
                    end
                end
            end
        end
        
        DirJSON=dir([Cfg.WorkingDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,'*.json']); %YAN Chao-Gan, 191121. For BIDS format. Copy JSON
        if ~isempty(DirJSON)
            copyfile([Cfg.WorkingDir,filesep,'T1Img',filesep,Cfg.SubjectID{i},filesep,DirJSON(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'anat',filesep,SubjectID_BIDS{i},'_T1w.json'])
        end

        if IsUMR5T
            y_RunMPRAGEiseYanForUMR5T(Cfg.WorkingDir, OutDir, '', [], Cfg.SubjectID{i}, SubjectID_BIDS{i}, DPABIPath);
        end
        
        
        %Dealing with T2 data
        mkdir([OutDir,filesep,SubjectID_BIDS{i},filesep,'anat']);
        DirImg=dir([Cfg.WorkingDir,filesep,'T2Img',filesep,Cfg.SubjectID{i},filesep,'*.img']);
        if ~isempty(DirImg)
            [Data Header]=y_Read([Cfg.WorkingDir,filesep,'T2Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name]);
            y_Write(Data,Header,[OutDir,filesep,SubjectID_BIDS{i},filesep,'anat',filesep,SubjectID_BIDS{i},'_T2w.nii'])
        else
            DirImg=dir([Cfg.WorkingDir,filesep,'T2Img',filesep,Cfg.SubjectID{i},filesep,'*.nii.gz']);
            if ~isempty(DirImg)
                copyfile([Cfg.WorkingDir,filesep,'T2Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'anat',filesep,SubjectID_BIDS{i},'_T2w.nii.gz'])
            else
                DirImg=dir([Cfg.WorkingDir,filesep,'T2Img',filesep,Cfg.SubjectID{i},filesep,'*.nii']);
                if ~isempty(DirImg)
                    copyfile([Cfg.WorkingDir,filesep,'T2Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'anat',filesep,SubjectID_BIDS{i},'_T2w.nii'])
                end
            end
        end
        DirJSON=dir([Cfg.WorkingDir,filesep,'T2Img',filesep,Cfg.SubjectID{i},filesep,'*.json']); %YAN Chao-Gan, 191121. For BIDS format. Copy JSON
        if ~isempty(DirJSON)
            copyfile([Cfg.WorkingDir,filesep,'T2Img',filesep,Cfg.SubjectID{i},filesep,DirJSON(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'anat',filesep,SubjectID_BIDS{i},'_T2w.json'])
        end


        %Dealing with functional data
        if Cfg.FunctionalSessionNumber==1
            OutFuncDir=[OutDir,filesep,SubjectID_BIDS{i},filesep,'func'];
            mkdir(OutFuncDir)
            [FunFile_IntendedFor,FunJSONFileSet{i,1},FunMetadataSourceFiles{i,1}] = y_CopyFunImgToBIDS(...
                [Cfg.WorkingDir,filesep,'FunImg',filesep,Cfg.SubjectID{i}], ...
                OutFuncDir, ...
                'func', ...
                [SubjectID_BIDS{i},'_task-rest']);
            if 7==exist([Cfg.WorkingDir,filesep,'FunSBREFImg'],'dir')
                FunSBREFJSONFileSet{i,1}=y_CopyFunSBREFImgToBIDS(...
                    [Cfg.WorkingDir,filesep,'FunSBREFImg',filesep,Cfg.SubjectID{i}], ...
                    OutFuncDir, ...
                    [SubjectID_BIDS{i},'_task-rest']);
            end
            
            %Dealing with Fun FieldMap data
            FieldMapMeasures={'PhaseDiff','Magnitude1','Magnitude2','Phase1','Phase2','Magnitude','FieldMap'};
            for iFieldMapMeasure=1:length(FieldMapMeasures)
                DirNii=dir([Cfg.WorkingDir,filesep,'FunFieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},filesep,Cfg.SubjectID{i},filesep,'*.nii']);
                if ~isempty(DirNii)
                    mkdir([OutDir,filesep,SubjectID_BIDS{i},filesep,'fmap']);
                    copyfile([Cfg.WorkingDir,filesep,'FunFieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},filesep,Cfg.SubjectID{i},filesep,DirNii(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'fmap',filesep,SubjectID_BIDS{i},'_',lower(FieldMapMeasures{iFieldMapMeasure}),'.nii'])
                    DirJSON=dir([Cfg.WorkingDir,filesep,'FunFieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},filesep,Cfg.SubjectID{i},filesep,'*.json']);
                    copyfile([Cfg.WorkingDir,filesep,'FunFieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},filesep,Cfg.SubjectID{i},filesep,DirJSON(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'fmap',filesep,SubjectID_BIDS{i},'_',lower(FieldMapMeasures{iFieldMapMeasure}),'.json'])

                    %Filling IntendedFor information

                    JSON = spm_jsonread([OutDir,filesep,SubjectID_BIDS{i},filesep,'fmap',filesep,SubjectID_BIDS{i},'_',lower(FieldMapMeasures{iFieldMapMeasure}),'.json']);
                    JSON.IntendedFor=FunFile_IntendedFor;
                    spm_jsonwrite([OutDir,filesep,SubjectID_BIDS{i},filesep,'fmap',filesep,SubjectID_BIDS{i},'_',lower(FieldMapMeasures{iFieldMapMeasure}),'.json'],JSON);

                end
            end
            y_FillEchoTimesInPhaseDiffJSON(...
                [OutDir,filesep,SubjectID_BIDS{i},filesep,'fmap',filesep,SubjectID_BIDS{i},'_phasediff.json'], ...
                [OutDir,filesep,SubjectID_BIDS{i},filesep,'fmap',filesep,SubjectID_BIDS{i},'_magnitude1.json'], ...
                [OutDir,filesep,SubjectID_BIDS{i},filesep,'fmap',filesep,SubjectID_BIDS{i},'_magnitude2.json']);

            %Dealing with Fun Topup data
            DirNii=dir([Cfg.WorkingDir,filesep,'FunFieldMap',filesep,'Topup',filesep,Cfg.SubjectID{i},filesep,'*.nii']);
            if ~isempty(DirNii)
                mkdir([OutDir,filesep,SubjectID_BIDS{i},filesep,'fmap']);

                DirJSON=dir([Cfg.WorkingDir,filesep,'FunFieldMap',filesep,'Topup',filesep,Cfg.SubjectID{i},filesep,'*.json']);

                JSON=spm_jsonread([Cfg.WorkingDir,filesep,'FunFieldMap',filesep,'Topup',filesep,Cfg.SubjectID{i},filesep,DirJSON(1).name]);
                if strcmpi(JSON.PhaseEncodingDirection,'j')
                    topupdir='pa';
                elseif strcmpi(JSON.PhaseEncodingDirection,'j-')
                    topupdir='ap';
                end

                copyfile([Cfg.WorkingDir,filesep,'FunFieldMap',filesep,'Topup',filesep,Cfg.SubjectID{i},filesep,DirJSON(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'fmap',filesep,SubjectID_BIDS{i},'_dir-',topupdir,'_epi','.json'])

                copyfile([Cfg.WorkingDir,filesep,'FunFieldMap',filesep,'Topup',filesep,Cfg.SubjectID{i},filesep,DirNii(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'fmap',filesep,SubjectID_BIDS{i},'_dir-',topupdir,'_epi','.nii'])
                

                %Filling IntendedFor information
                JSON = spm_jsonread([OutDir,filesep,SubjectID_BIDS{i},filesep,'fmap',filesep,SubjectID_BIDS{i},'_dir-',topupdir,'_epi','.json']);
                JSON.IntendedFor=FunFile_IntendedFor;
                spm_jsonwrite([OutDir,filesep,SubjectID_BIDS{i},filesep,'fmap',filesep,SubjectID_BIDS{i},'_dir-',topupdir,'_epi','.json'],JSON);
            end

            
        end


        %Dealing with diffusion weighted data %By Zhao-Yu Deng
        if 7==exist([Cfg.WorkingDir,filesep,'DwiImg'],'dir')

            mkdir([OutDir,filesep,SubjectID_BIDS{i},filesep,'dwi'])
            DirImg=dir([Cfg.WorkingDir,filesep,'DwiImg',filesep,Cfg.SubjectID{i},filesep,'*.img']);
            DirNii=dir([Cfg.WorkingDir,filesep,'DwiImg',filesep,Cfg.SubjectID{i},filesep,'*.nii']);
            DirNiiGZ=dir([Cfg.WorkingDir,filesep,'DwiImg',filesep,Cfg.SubjectID{i},filesep,'*.nii.gz']);
            DwiFile_IntendedFor=[];
            if ~isempty(DirImg) || length(DirNii)>=2  || length(DirNiiGZ)>=2
                [Data,~,~, Header] =y_ReadAll([Cfg.WorkingDir,filesep,'DwiImg',filesep,Cfg.SubjectID{i}]);
                y_Write(Data,Header,[OutDir,filesep,SubjectID_BIDS{i},filesep,'dwi',filesep,SubjectID_BIDS{i},'_dwi.nii']) % suffix dwi
                DwiFile_IntendedFor=['dwi/',SubjectID_BIDS{i},'_dwi.nii'];
            elseif length(DirNii)==1
                copyfile([Cfg.WorkingDir,filesep,'DwiImg',filesep,Cfg.SubjectID{i},filesep,DirNii(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'dwi',filesep,SubjectID_BIDS{i},'_dwi.nii'])
                DwiFile_IntendedFor=['dwi/',SubjectID_BIDS{i},'_dwi.nii'];
            elseif length(DirNiiGZ)==1
                copyfile([Cfg.WorkingDir,filesep,'DwiImg',filesep,Cfg.SubjectID{i},filesep,DirNiiGZ(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'dwi',filesep,SubjectID_BIDS{i},'_dwi.nii.gz'])
                DwiFile_IntendedFor=['dwi/',SubjectID_BIDS{i},'_dwi.nii.gz'];
            end
            DirBval=dir([Cfg.WorkingDir,filesep,'DwiImg',filesep,Cfg.SubjectID{i},filesep,'*.bval']);
            DirBvec=dir([Cfg.WorkingDir,filesep,'DwiImg',filesep,Cfg.SubjectID{i},filesep,'*.bvec']);
            copyfile([Cfg.WorkingDir,filesep,'DwiImg',filesep,Cfg.SubjectID{i},filesep,DirBval(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'dwi',filesep,SubjectID_BIDS{i},'_dwi.bval'])
            copyfile([Cfg.WorkingDir,filesep,'DwiImg',filesep,Cfg.SubjectID{i},filesep,DirBvec(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'dwi',filesep,SubjectID_BIDS{i},'_dwi.bvec'])

            DirJSON=dir([Cfg.WorkingDir,filesep,'DwiImg',filesep,Cfg.SubjectID{i},filesep,'*.json']); %YAN Chao-Gan, 191121. For BIDS format. Copy JSON
            if ~isempty(DirJSON)
                copyfile([Cfg.WorkingDir,filesep,'DwiImg',filesep,Cfg.SubjectID{i},filesep,DirJSON(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'dwi',filesep,SubjectID_BIDS{i},'_dwi.json'])
            end

            %Dealing with Dwi FieldMap data
            FieldMapMeasures={'PhaseDiff','Magnitude1','Magnitude2','Phase1','Phase2','Magnitude','FieldMap'};
            for iFieldMapMeasure=1:length(FieldMapMeasures)
                DirNii=dir([Cfg.WorkingDir,filesep,'DwiFieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},filesep,Cfg.SubjectID{i},filesep,'*.nii']);
                if ~isempty(DirNii)
                    mkdir([OutDir,filesep,SubjectID_BIDS{i},filesep,'fmap']);
                    copyfile([Cfg.WorkingDir,filesep,'DwiFieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},filesep,Cfg.SubjectID{i},filesep,DirNii(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'fmap',filesep,SubjectID_BIDS{i},'_acq-dwi_',lower(FieldMapMeasures{iFieldMapMeasure}),'.nii'])
                    DirJSON=dir([Cfg.WorkingDir,filesep,'DwiFieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},filesep,Cfg.SubjectID{i},filesep,'*.json']);
                    copyfile([Cfg.WorkingDir,filesep,'DwiFieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},filesep,Cfg.SubjectID{i},filesep,DirJSON(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'fmap',filesep,SubjectID_BIDS{i},'_acq-dwi_',lower(FieldMapMeasures{iFieldMapMeasure}),'.json'])

                    %Filling IntendedFor information
                    JSON = spm_jsonread([OutDir,filesep,SubjectID_BIDS{i},filesep,'fmap',filesep,SubjectID_BIDS{i},'_acq-dwi_',lower(FieldMapMeasures{iFieldMapMeasure}),'.json']);
                    JSON.IntendedFor=DwiFile_IntendedFor;
                    spm_jsonwrite([OutDir,filesep,SubjectID_BIDS{i},filesep,'fmap',filesep,SubjectID_BIDS{i},'_acq-dwi_',lower(FieldMapMeasures{iFieldMapMeasure}),'.json'],JSON);
                end
            end
            y_FillEchoTimesInPhaseDiffJSON(...
                [OutDir,filesep,SubjectID_BIDS{i},filesep,'fmap',filesep,SubjectID_BIDS{i},'_acq-dwi_phasediff.json'], ...
                [OutDir,filesep,SubjectID_BIDS{i},filesep,'fmap',filesep,SubjectID_BIDS{i},'_acq-dwi_magnitude1.json'], ...
                [OutDir,filesep,SubjectID_BIDS{i},filesep,'fmap',filesep,SubjectID_BIDS{i},'_acq-dwi_magnitude2.json']);


            %Dealing with Dwi Topup data
            DirNii=dir([Cfg.WorkingDir,filesep,'DwiFieldMap',filesep,'Topup',filesep,Cfg.SubjectID{i},filesep,'*.nii']);
            if ~isempty(DirNii)
                mkdir([OutDir,filesep,SubjectID_BIDS{i},filesep,'fmap']);

                DirJSON=dir([Cfg.WorkingDir,filesep,'DwiFieldMap',filesep,'Topup',filesep,Cfg.SubjectID{i},filesep,'*.json']);

                JSON=spm_jsonread([Cfg.WorkingDir,filesep,'DwiFieldMap',filesep,'Topup',filesep,Cfg.SubjectID{i},filesep,DirJSON(1).name]);
                if strcmpi(JSON.PhaseEncodingDirection,'j')
                    topupdir='pa';
                elseif strcmpi(JSON.PhaseEncodingDirection,'j-')
                    topupdir='ap';
                end

                copyfile([Cfg.WorkingDir,filesep,'DwiFieldMap',filesep,'Topup',filesep,Cfg.SubjectID{i},filesep,DirJSON(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'fmap',filesep,SubjectID_BIDS{i},'_acq-dwi_dir-',topupdir,'_epi','.json'])

                
                [Data  Header] = y_Read([Cfg.WorkingDir,filesep,'DwiFieldMap',filesep,'Topup',filesep,Cfg.SubjectID{i},filesep,DirNii(1).name]);
                
                if size(Data,4)==1
                    copyfile([Cfg.WorkingDir,filesep,'DwiFieldMap',filesep,'Topup',filesep,Cfg.SubjectID{i},filesep,DirNii(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'fmap',filesep,SubjectID_BIDS{i},'_acq-dwi_dir-',topupdir,'_epi','.nii'])
                else
                    %% modify 20260805
                    %                     DirBval=dir([Cfg.WorkingDir,filesep,'DwiFieldMap',filesep,'Topup',filesep,Cfg.SubjectID{i},filesep,'*.bval']);
                    %                     Bval=load([Cfg.WorkingDir,filesep,'DwiFieldMap',filesep,'Topup',filesep,Cfg.SubjectID{i},filesep,DirBval(1).name]);
                    %                     B0VolIndex=find(Bval==0);
                    %                     B0Data=mean(Data(:,:,:,B0VolIndex),4);
                    DirBval=dir([Cfg.WorkingDir,filesep,'DwiFieldMap',filesep,'Topup',filesep,Cfg.SubjectID{i},filesep,'*.bval']);
                    if ~isempty(DirBval)
                        filePath = [Cfg.WorkingDir, filesep, 'DwiFieldMap', filesep, 'Topup', filesep, Cfg.SubjectID{i}, filesep, DirBval(1).name];
                        Bval = load(filePath);
                        B0VolIndex = find(Bval == 0);
                        B0Data = mean(Data(:,:,:,B0VolIndex), 4);
                    else
                        B0Data = mean(Data, 4);
                    end
                    %%

                    Header.pinfo=[1;0;0]; Header.dt=[16,0];
                    y_Write(B0Data,Header,[OutDir,filesep,SubjectID_BIDS{i},filesep,'fmap',filesep,SubjectID_BIDS{i},'_acq-dwi_dir-',topupdir,'_epi','.nii']);  
                end

                %Filling IntendedFor information
                JSON = spm_jsonread([OutDir,filesep,SubjectID_BIDS{i},filesep,'fmap',filesep,SubjectID_BIDS{i},'_acq-dwi_dir-',topupdir,'_epi','.json']);
                JSON.IntendedFor=DwiFile_IntendedFor;
                spm_jsonwrite([OutDir,filesep,SubjectID_BIDS{i},filesep,'fmap',filesep,SubjectID_BIDS{i},'_acq-dwi_dir-',topupdir,'_epi','.json'],JSON);
            end

        end

    end
end


%Multiple session data
if Cfg.FunctionalSessionNumber>=2
    %Dealing with anatomical data
    %Check if exist S2_T1Img, that means mutiple run of T1 image exist
    if 7==exist([Cfg.WorkingDir,filesep,'S2_T1Img'],'dir')
        T1SessionNumber = Cfg.FunctionalSessionNumber;
    else
        T1SessionNumber = 1;
    end
    for iT1Session=1:T1SessionNumber
        for i=1:length(SubjectID_BIDS)
            
            mkdir([OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iT1Session),filesep,'anat']);
            %First check T1w image started with co (T1 image which is reoriented to the nearest orthogonal direction to ''canonical space'' and removed excess air surrounding the individual as well as parts of the neck below the cerebellum)
            DirImg=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,'c*.img']);
            if ~isempty(DirImg)
                [Data Header]=y_Read([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name]);
                y_Write(Data,Header,[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iT1Session),filesep,'anat',filesep,SubjectID_BIDS{i},'_ses-',num2str(iT1Session),'_T1w.nii'])
            else
                DirImg=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,'c*.nii.gz']);
                if ~isempty(DirImg)
                    copyfile([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iT1Session),filesep,'anat',filesep,SubjectID_BIDS{i},'_ses-',num2str(iT1Session),'_T1w.nii.gz'])
                else
                    DirImg=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,'c*.nii']);
                    if ~isempty(DirImg)
                        copyfile([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iT1Session),filesep,'anat',filesep,SubjectID_BIDS{i},'_ses-',num2str(iT1Session),'_T1w.nii'])
                    else
                        DirImg=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,'*Crop*.nii']); %YAN Chao-Gan, 191121. For BIDS format. Change searching c* to *Crop*
                        if ~isempty(DirImg)
                            copyfile([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iT1Session),filesep,'anat',filesep,SubjectID_BIDS{i},'_ses-',num2str(iT1Session),'_T1w.nii'])
                        end
                    end
                end
            end
            
            %If there is no co* T1w images
            if isempty(DirImg)
                DirImg=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,'*.img']);
                if ~isempty(DirImg)
                    [Data Header]=y_Read([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name]);
                    y_Write(Data,Header,[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iT1Session),filesep,'anat',filesep,SubjectID_BIDS{i},'_ses-',num2str(iT1Session),'_T1w.nii'])
                else
                    DirImg=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,'*.nii.gz']);
                    if ~isempty(DirImg)
                        copyfile([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iT1Session),filesep,'anat',filesep,SubjectID_BIDS{i},'_ses-',num2str(iT1Session),'_T1w.nii.gz'])
                    else
                        DirImg=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,'*.nii']);
                        if ~isempty(DirImg)
                            copyfile([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iT1Session),filesep,'anat',filesep,SubjectID_BIDS{i},'_ses-',num2str(iT1Session),'_T1w.nii'])
                        end
                    end
                end
            end
            
            DirJSON=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,'*.json']); %YAN Chao-Gan, 191121. For BIDS format. Copy JSON
            if ~isempty(DirJSON)
                copyfile([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iT1Session},'T1Img',filesep,Cfg.SubjectID{i},filesep,DirJSON(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iT1Session),filesep,'anat',filesep,SubjectID_BIDS{i},'_ses-',num2str(iT1Session),'_T1w.json'])
            end

            if IsUMR5T
                y_RunMPRAGEiseYanForUMR5T(Cfg.WorkingDir, OutDir, FunSessionPrefixSet{iT1Session}, iT1Session, Cfg.SubjectID{i}, SubjectID_BIDS{i}, DPABIPath);
            end
        end
    end


    %Dealing with T2 data
    %Check if exist S2_T2Img, that means mutiple run of T2 image exist
    if 7==exist([Cfg.WorkingDir,filesep,'S2_T2Img'],'dir')
        T2SessionNumber = Cfg.FunctionalSessionNumber;
    else
        T2SessionNumber = 1;
    end
    for iT2Session=1:T2SessionNumber
        for i=1:length(SubjectID_BIDS)
            mkdir([OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iT2Session),filesep,'anat']);
            DirImg=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iT2Session},'T2Img',filesep,Cfg.SubjectID{i},filesep,'*.img']);
            if ~isempty(DirImg)
                [Data Header]=y_Read([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iT2Session},'T2Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name]);
                y_Write(Data,Header,[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iT2Session),filesep,'anat',filesep,SubjectID_BIDS{i},'_ses-',num2str(iT2Session),'_T2w.nii'])
            else
                DirImg=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iT2Session},'T2Img',filesep,Cfg.SubjectID{i},filesep,'*.nii.gz']);
                if ~isempty(DirImg)
                    copyfile([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iT2Session},'T2Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iT2Session),filesep,'anat',filesep,SubjectID_BIDS{i},'_ses-',num2str(iT2Session),'_T2w.nii.gz'])
                else
                    DirImg=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iT2Session},'T2Img',filesep,Cfg.SubjectID{i},filesep,'*.nii']);
                    if ~isempty(DirImg)
                        copyfile([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iT2Session},'T2Img',filesep,Cfg.SubjectID{i},filesep,DirImg(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iT2Session),filesep,'anat',filesep,SubjectID_BIDS{i},'_ses-',num2str(iT2Session),'_T2w.nii'])
                    end
                end
            end

            DirJSON=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iT2Session},'T2Img',filesep,Cfg.SubjectID{i},filesep,'*.json']); %YAN Chao-Gan, 191121. For BIDS format. Copy JSON
            if ~isempty(DirJSON)
                copyfile([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iT2Session},'T2Img',filesep,Cfg.SubjectID{i},filesep,DirJSON(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iT2Session),filesep,'anat',filesep,SubjectID_BIDS{i},'_ses-',num2str(iT2Session),'_T2w.json'])
            end
        end
    end

    %Dealing with functional data
    
    for i=1:length(SubjectID_BIDS)
        FunFile_IntendedFor=[];
        for iFunSession=1:Cfg.FunctionalSessionNumber
            OutFuncDir=[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFunSession),filesep,'func'];
            mkdir(OutFuncDir)
            [FunFile_IntendedForTemp,FunJSONFileSet{i,iFunSession},FunMetadataSourceFiles{i,iFunSession}] = y_CopyFunImgToBIDS(...
                [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'FunImg',filesep,Cfg.SubjectID{i}], ...
                OutFuncDir, ...
                ['ses-',num2str(iFunSession),'/func'], ...
                [SubjectID_BIDS{i},'_ses-',num2str(iFunSession),'_task-rest']);
            if 7==exist([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'FunSBREFImg'],'dir')
                FunSBREFJSONFileSet{i,iFunSession}=y_CopyFunSBREFImgToBIDS(...
                    [Cfg.WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'FunSBREFImg',filesep,Cfg.SubjectID{i}], ...
                    OutFuncDir, ...
                    [SubjectID_BIDS{i},'_ses-',num2str(iFunSession),'_task-rest']);
            end
            FunFile_IntendedFor=[FunFile_IntendedFor,FunFile_IntendedForTemp];
        end
        
        
        %Dealing with Fun FieldMap data
        iFieldMapSession=1;
        FieldMapMeasures={'PhaseDiff','Magnitude1','Magnitude2','Phase1','Phase2','Magnitude','FieldMap'};
        for iFieldMapMeasure=1:length(FieldMapMeasures)
            
            DirNii=dir([Cfg.WorkingDir,filesep,'FunFieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},filesep,Cfg.SubjectID{i},filesep,'*.nii']);
            if ~isempty(DirNii)
                mkdir([OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFieldMapSession),filesep,'fmap']);
                copyfile([Cfg.WorkingDir,filesep,'FunFieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},filesep,Cfg.SubjectID{i},filesep,DirNii(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFieldMapSession),filesep,'fmap',filesep,SubjectID_BIDS{i},'_ses-',num2str(iFieldMapSession),'_',lower(FieldMapMeasures{iFieldMapMeasure}),'.nii'])
                DirJSON=dir([Cfg.WorkingDir,filesep,'FunFieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},filesep,Cfg.SubjectID{i},filesep,'*.json']);
                copyfile([Cfg.WorkingDir,filesep,'FunFieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},filesep,Cfg.SubjectID{i},filesep,DirJSON(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFieldMapSession),filesep,'fmap',filesep,SubjectID_BIDS{i},'_ses-',num2str(iFieldMapSession),'_',lower(FieldMapMeasures{iFieldMapMeasure}),'.json'])
                
                %Filling IntendedFor information

                JSON = spm_jsonread([OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFieldMapSession),filesep,'fmap',filesep,SubjectID_BIDS{i},'_ses-',num2str(iFieldMapSession),'_',lower(FieldMapMeasures{iFieldMapMeasure}),'.json']);
                JSON.IntendedFor=FunFile_IntendedFor;
                spm_jsonwrite([OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFieldMapSession),filesep,'fmap',filesep,SubjectID_BIDS{i},'_ses-',num2str(iFieldMapSession),'_',lower(FieldMapMeasures{iFieldMapMeasure}),'.json'],JSON);
            end
        end
        y_FillEchoTimesInPhaseDiffJSON(...
            [OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFieldMapSession),filesep,'fmap',filesep,SubjectID_BIDS{i},'_ses-',num2str(iFieldMapSession),'_phasediff.json'], ...
            [OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFieldMapSession),filesep,'fmap',filesep,SubjectID_BIDS{i},'_ses-',num2str(iFieldMapSession),'_magnitude1.json'], ...
            [OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFieldMapSession),filesep,'fmap',filesep,SubjectID_BIDS{i},'_ses-',num2str(iFieldMapSession),'_magnitude2.json']);

        %Dealing with Fun Topup data
        DirNii=dir([Cfg.WorkingDir,filesep,'FunFieldMap',filesep,'Topup',filesep,Cfg.SubjectID{i},filesep,'*.nii']);
        if ~isempty(DirNii)
            mkdir([OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFieldMapSession),filesep,'fmap']);

            DirJSON=dir([Cfg.WorkingDir,filesep,'FunFieldMap',filesep,'Topup',filesep,Cfg.SubjectID{i},filesep,'*.json']);

            JSON=spm_jsonread([Cfg.WorkingDir,filesep,'FunFieldMap',filesep,'Topup',filesep,Cfg.SubjectID{i},filesep,DirJSON(1).name]);
            if strcmpi(JSON.PhaseEncodingDirection,'j')
                topupdir='pa';
            elseif strcmpi(JSON.PhaseEncodingDirection,'j-')
                topupdir='ap';
            end

            copyfile([Cfg.WorkingDir,filesep,'FunFieldMap',filesep,'Topup',filesep,Cfg.SubjectID{i},filesep,DirJSON(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFieldMapSession),filesep,'fmap',filesep,SubjectID_BIDS{i},'_ses-',num2str(iFieldMapSession),'_dir-',topupdir,'_epi','.json'])

            copyfile([Cfg.WorkingDir,filesep,'FunFieldMap',filesep,'Topup',filesep,Cfg.SubjectID{i},filesep,DirNii(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFieldMapSession),filesep,'fmap',filesep,SubjectID_BIDS{i},'_ses-',num2str(iFieldMapSession),'_dir-',topupdir,'_epi','.nii'])


            %Filling IntendedFor information
            JSON = spm_jsonread([OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFieldMapSession),filesep,'fmap',filesep,SubjectID_BIDS{i},'_ses-',num2str(iFieldMapSession),'_dir-',topupdir,'_epi','.json']);
            JSON.IntendedFor=FunFile_IntendedFor;
            spm_jsonwrite([OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFieldMapSession),filesep,'fmap',filesep,SubjectID_BIDS{i},'_ses-',num2str(iFieldMapSession),'_dir-',topupdir,'_epi','.json'],JSON);
        end
    end


    %Dealing with diffusion weighted data %By Zhao-Yu Deng
    if 7==exist([Cfg.WorkingDir,filesep,'DwiImg'],'dir')
        if 7==exist([Cfg.WorkingDir,filesep,'S2_DwiImg'],'dir')
            DwiSessionNumber = Cfg.FunctionalSessionNumber;
        else
            DwiSessionNumber = 1;
        end

        for i=1:length(SubjectID_BIDS)
            DwiFile_IntendedFor=[];
            for iDwiSession=1:DwiSessionNumber

                mkdir([OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iDwiSession),filesep,'dwi']);
                DirImg=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iDwiSession},'DwiImg',filesep,Cfg.SubjectID{i},filesep,'*.img']);
                DirNii=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iDwiSession},'DwiImg',filesep,Cfg.SubjectID{i},filesep,'*.nii']);
                DirNiiGZ=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iDwiSession},'DwiImg',filesep,Cfg.SubjectID{i},filesep,'*.nii.gz']);
                if ~isempty(DirImg) || length(DirNii)>=2  || length(DirNiiGZ)>=2
                    [Data,~,~, Header] =y_ReadAll([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iDwiSession},'DwiImg',filesep,Cfg.SubjectID{i}]);
                    y_Write(Data,Header,[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iDwiSession),filesep,'dwi',filesep,SubjectID_BIDS{i},'_ses-',num2str(iDwiSession),'_dwi.nii']) % suffix dwi
                    DwiFile_IntendedFor=[DwiFile_IntendedFor,{['ses-',num2str(iDwiSession),'/dwi/',SubjectID_BIDS{i},'_ses-',num2str(iDwiSession),'_dwi.nii']}];
                elseif length(DirNii)==1
                    copyfile([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iDwiSession},'DwiImg',filesep,Cfg.SubjectID{i},filesep,DirNii(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iDwiSession),filesep,'dwi',filesep,SubjectID_BIDS{i},'_ses-',num2str(iDwiSession),'_dwi.nii'])
                    DwiFile_IntendedFor=[DwiFile_IntendedFor,{['ses-',num2str(iDwiSession),'/dwi/',SubjectID_BIDS{i},'_ses-',num2str(iDwiSession),'_dwi.nii']}];
                elseif length(DirNiiGZ)==1
                    copyfile([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iDwiSession},'DwiImg',filesep,Cfg.SubjectID{i},filesep,DirNiiGZ(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iDwiSession),filesep,'dwi',filesep,SubjectID_BIDS{i},'_ses-',num2str(iDwiSession),'_dwi.nii.gz'])
                    DwiFile_IntendedFor=[DwiFile_IntendedFor,{['ses-',num2str(iDwiSession),'/dwi/',SubjectID_BIDS{i},'_ses-',num2str(iDwiSession),'_dwi.nii.gz']}];
                end
                DirBval=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iDwiSession},'DwiImg',filesep,Cfg.SubjectID{i},filesep,'*.bval']);
                DirBvec=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iDwiSession},'DwiImg',filesep,Cfg.SubjectID{i},filesep,'*.bvec']);
                copyfile([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iDwiSession},'DwiImg',filesep,Cfg.SubjectID{i},filesep,DirBval(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iDwiSession),filesep,'dwi',filesep,SubjectID_BIDS{i},'_ses-',num2str(iDwiSession),'_dwi.bval'])
                copyfile([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iDwiSession},'DwiImg',filesep,Cfg.SubjectID{i},filesep,DirBvec(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iDwiSession),filesep,'dwi',filesep,SubjectID_BIDS{i},'_ses-',num2str(iDwiSession),'_dwi.bvec'])

                DirJSON=dir([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iDwiSession},'DwiImg',filesep,Cfg.SubjectID{i},filesep,'*.json']); %YAN Chao-Gan, 191121. For BIDS format. Copy JSON
                if ~isempty(DirJSON)
                    copyfile([Cfg.WorkingDir,filesep,FunSessionPrefixSet{iDwiSession},'DwiImg',filesep,Cfg.SubjectID{i},filesep,DirJSON(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iDwiSession),filesep,'dwi',filesep,SubjectID_BIDS{i},'_ses-',num2str(iDwiSession),'_dwi.json'])
                end
            end

            %Dealing with Dwi FieldMap data
            iFieldMapSession=1;
            FieldMapMeasures={'PhaseDiff','Magnitude1','Magnitude2','Phase1','Phase2','Magnitude','FieldMap'};
            for iFieldMapMeasure=1:length(FieldMapMeasures)
                DirNii=dir([Cfg.WorkingDir,filesep,'DwiFieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},filesep,Cfg.SubjectID{i},filesep,'*.nii']);
                if ~isempty(DirNii)
                    mkdir([OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFieldMapSession),filesep,'fmap']);
                    copyfile([Cfg.WorkingDir,filesep,'DwiFieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},filesep,Cfg.SubjectID{i},filesep,DirNii(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFieldMapSession),filesep,'fmap',filesep,SubjectID_BIDS{i},'_ses-',num2str(iFieldMapSession),'_acq-dwi_',lower(FieldMapMeasures{iFieldMapMeasure}),'.nii'])
                    DirJSON=dir([Cfg.WorkingDir,filesep,'DwiFieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},filesep,Cfg.SubjectID{i},filesep,'*.json']);
                    copyfile([Cfg.WorkingDir,filesep,'DwiFieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},filesep,Cfg.SubjectID{i},filesep,DirJSON(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFieldMapSession),filesep,'fmap',filesep,SubjectID_BIDS{i},'_ses-',num2str(iFieldMapSession),'_acq-dwi_',lower(FieldMapMeasures{iFieldMapMeasure}),'.json'])

                    %Filling IntendedFor information
                    JSON = spm_jsonread([OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFieldMapSession),filesep,'fmap',filesep,SubjectID_BIDS{i},'_ses-',num2str(iFieldMapSession),'_acq-dwi_',lower(FieldMapMeasures{iFieldMapMeasure}),'.json']);
                    JSON.IntendedFor=DwiFile_IntendedFor;
                    spm_jsonwrite([OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFieldMapSession),filesep,'fmap',filesep,SubjectID_BIDS{i},'_ses-',num2str(iFieldMapSession),'_acq-dwi_',lower(FieldMapMeasures{iFieldMapMeasure}),'.json'],JSON);
                end
            end
            y_FillEchoTimesInPhaseDiffJSON(...
                [OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFieldMapSession),filesep,'fmap',filesep,SubjectID_BIDS{i},'_ses-',num2str(iFieldMapSession),'_acq-dwi_phasediff.json'], ...
                [OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFieldMapSession),filesep,'fmap',filesep,SubjectID_BIDS{i},'_ses-',num2str(iFieldMapSession),'_acq-dwi_magnitude1.json'], ...
                [OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFieldMapSession),filesep,'fmap',filesep,SubjectID_BIDS{i},'_ses-',num2str(iFieldMapSession),'_acq-dwi_magnitude2.json']);


            %Dealing with Dwi Topup data

            DirNii=dir([Cfg.WorkingDir,filesep,'DwiFieldMap',filesep,'Topup',filesep,Cfg.SubjectID{i},filesep,'*.nii']);
            if ~isempty(DirNii)
                mkdir([OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFieldMapSession),filesep,'fmap']);

                DirJSON=dir([Cfg.WorkingDir,filesep,'DwiFieldMap',filesep,'Topup',filesep,Cfg.SubjectID{i},filesep,'*.json']);

                JSON=spm_jsonread([Cfg.WorkingDir,filesep,'DwiFieldMap',filesep,'Topup',filesep,Cfg.SubjectID{i},filesep,DirJSON(1).name]);
                if strcmpi(JSON.PhaseEncodingDirection,'j')
                    topupdir='pa';
                elseif strcmpi(JSON.PhaseEncodingDirection,'j-')
                    topupdir='ap';
                end

                copyfile([Cfg.WorkingDir,filesep,'DwiFieldMap',filesep,'Topup',filesep,Cfg.SubjectID{i},filesep,DirJSON(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFieldMapSession),filesep,'fmap',filesep,SubjectID_BIDS{i},'_ses-',num2str(iFieldMapSession),'_acq-dwi_dir-',topupdir,'_epi','.json'])
                
                [Data  Header] = y_Read([Cfg.WorkingDir,filesep,'DwiFieldMap',filesep,'Topup',filesep,Cfg.SubjectID{i},filesep,DirNii(1).name]);
                
                if size(Data,4)==1
                     copyfile([Cfg.WorkingDir,filesep,'DwiFieldMap',filesep,'Topup',filesep,Cfg.SubjectID{i},filesep,DirNii(1).name],[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFieldMapSession),filesep,'fmap',filesep,SubjectID_BIDS{i},'_ses-',num2str(iFieldMapSession),'_acq-dwi_dir-',topupdir,'_epi','.nii'])
                else
                    DirBval=dir([Cfg.WorkingDir,filesep,'DwiFieldMap',filesep,'Topup',filesep,Cfg.SubjectID{i},filesep,'*.bval']);
                    
                    Bval=load([Cfg.WorkingDir,filesep,'DwiFieldMap',filesep,'Topup',filesep,Cfg.SubjectID{i},filesep,DirBval(1).name]);
                    B0VolIndex=find(Bval==0);
                    
                    B0Data=mean(Data(:,:,:,B0VolIndex),4);
                    Header.pinfo=[1;0;0]; Header.dt=[16,0];
                    y_Write(B0Data,Header,[OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFieldMapSession),filesep,'fmap',filesep,SubjectID_BIDS{i},'_ses-',num2str(iFieldMapSession),'_acq-dwi_dir-',topupdir,'_epi','.nii']);
                end

                %Filling IntendedFor information
                JSON = spm_jsonread([OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFieldMapSession),filesep,'fmap',filesep,SubjectID_BIDS{i},'_ses-',num2str(iFieldMapSession),'_acq-dwi_dir-',topupdir,'_epi','.json']);
                JSON.IntendedFor=DwiFile_IntendedFor;
                spm_jsonwrite([OutDir,filesep,SubjectID_BIDS{i},filesep,'ses-',num2str(iFieldMapSession),filesep,'fmap',filesep,SubjectID_BIDS{i},'_ses-',num2str(iFieldMapSession),'_acq-dwi_dir-',topupdir,'_epi','.json'],JSON);
            end

        end
    end
   
    
end


%Save JISON files
clear JSON
JSON.BIDSVersion='1.0.0';
JSON.Name='DPARSFA2BIDS';
spm_jsonwrite([OutDir,filesep,'dataset_description.json'],JSON);


if Cfg.FunctionalSessionNumber==0 % YAN Chao-Gan, 210414. If anat only, then no need go further.
    return
end



%Check TR and Subject ID, TR, Slice Number, Time Points, Voxel Size into TRInfo.tsv if needed.
if isfield(Cfg,'TR')
    if Cfg.TR==0  % Need to retrieve the TR information from the NIfTI images
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
            
            for i=1:Cfg.SubjectNum
                if ~strcmp(Cfg.SubjectID{i},TRInfoTemp{1}{i})
                    error(['The subject ID ',TRInfoTemp{1}{i},' in TRInfo.tsv doesn''t match the target sbuject ID: ',Cfg.SubjectID{i},'!'])
                end
            end
            
            TRSet = zeros(Cfg.SubjectNum,Cfg.FunctionalSessionNumber);
            for iFunSession=1:Cfg.FunctionalSessionNumber
                TRSet(:,iFunSession) = TRInfoTemp{1+iFunSession}; %The first column is Subject ID
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
                    [TRSet(i,iFunSession), SliceNumber(i,iFunSession), nTimePoints(i,iFunSession), VoxelSize(i,iFunSession,:)] = ...
                        y_GetFunImgBasicInfo(FunMetadataSourceFiles{i,iFunSession});
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
        [~, SliceNumber] = y_GetFunImgBasicInfo(FunMetadataSourceFiles{i,iFunSession});
        
        if Cfg.SliceTiming.SliceNumber==0 %If SliceNumber is set to 0, then retrieve the slice number from the NIfTI images. The slice order is then assumed as interleaved scanning: [1:2:SliceNumber,2:2:SliceNumber]. The reference slice is set to the slice acquired at the middle time point, i.e., SliceOrder(ceil(SliceNumber/2)). SHOULD BE EXTREMELY CAUTIOUS!!!
            if exist([Cfg.WorkingDir,filesep,'SliceOrderInfo.tsv'],'file')==2 % YAN Chao-Gan, 130524. Read the slice timing information from a tsv file (Tab-separated values)
                fid = fopen([Cfg.WorkingDir,filesep,'SliceOrderInfo.tsv']);
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
                            SliceOrder = load([Cfg.WorkingDir,filesep,SliceOrderSet{1+iFunSession}{i}]); %The slice order is specified in a text file.
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
            SliceTiming=zeros(1,SliceNumber);
            SliceTiming(SliceOrder)=SliceTimingInAcquisition;
        else
            SliceTiming=SliceOrder/1000; %From ms to s.
        end
        
        
        clear JSON
        JSON.RepetitionTime=TR;
        JSON.SliceTiming=SliceTiming;
        JSON.TaskName='REST';
        JSONFileSet=FunJSONFileSet{i,iFunSession};
        for iJSONFile=1:length(JSONFileSet)
            JSONFile=JSONFileSet{iJSONFile};
            if ~exist(JSONFile,'file') % If the JSON files were not copied from dcm2niix's conversion, then write one.
                spm_jsonwrite(JSONFile,JSON);
            else
                JSON_Exist = spm_jsonread(JSONFile);
                JSON_Exist.RepetitionTime=JSON.RepetitionTime;
                if ~isfield(JSON_Exist,'SliceTiming') % If the JSON from dcm2niix does not have slice timing information, then write one.
                    JSON_Exist.SliceTiming=JSON.SliceTiming;
                end
                if ~isfield(JSON_Exist,'TaskName')
                    JSON_Exist.TaskName=JSON.TaskName;
                end
                spm_jsonwrite(JSONFile,JSON_Exist);
            end
        end
        y_FillSBREFJSONFiles(FunSBREFJSONFileSet{i,iFunSession}, TR);
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


function y_RunMPRAGEiseYanForUMR5T(WorkingDir, OutDir, SessionPrefix, SessionIndex, SubjectID, SubjectID_BIDS, DPABIPath)
[Inv2File, UniFile, TI2Dir, T1Dir] = y_GetMPRAGEiseYanInputFiles(WorkingDir, SessionPrefix, SubjectID);
if isempty(Inv2File)
    error(['Can NOT find TI2 image for MPRAGEise_yan in: ',TI2Dir])
end
if isempty(UniFile)
    error(['Can NOT find T1/UNI image for MPRAGEise_yan in: ',T1Dir])
end

if isempty(SessionIndex)
    OutAnatDir=[OutDir,filesep,SubjectID_BIDS,filesep,'anat'];
    OutputBase=[OutAnatDir,filesep,SubjectID_BIDS,'_T1w'];
else
    OutAnatDir=[OutDir,filesep,SubjectID_BIDS,filesep,'ses-',num2str(SessionIndex),filesep,'anat'];
    OutputBase=[OutAnatDir,filesep,SubjectID_BIDS,'_ses-',num2str(SessionIndex),'_T1w'];
end
mkdir(OutAnatDir);

MPRAGEiseScript=fullfile(DPABIPath,'RedistributedToolboxes','MPRAGEise_yan.py');
if 2~=exist(MPRAGEiseScript,'file')
    error(['MPRAGEise_yan.py does not exist: ',MPRAGEiseScript])
end

[~, Inv2Ext] = y_GetImageStemAndExt(Inv2File);
[UniStem, ~] = y_GetImageStemAndExt(UniFile);
MPRAGEiseOutputFile=[OutAnatDir,filesep,UniStem,'_unbiased_clean',Inv2Ext];
BIDSOutputFile=[OutputBase,Inv2Ext];

fprintf('Running MPRAGEise_yan correction for %s...\n',SubjectID);
if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
    Command=sprintf('python3 %s -i %s -u %s -o %s --overwrite', ...
        y_ShellQuote(MPRAGEiseScript), y_ShellQuote(Inv2File), y_ShellQuote(UniFile), y_ShellQuote(OutAnatDir));
else
    if ispc
        CommandInit=sprintf('docker run -i --rm -v %s:/data -v %s:/opt/DPABI ', y_ShellQuote(WorkingDir), y_ShellQuote(DPABIPath)); %YAN Chao-Gan, 181214. Remove -t because there is a tty issue in windows
    else
        CommandInit=sprintf('docker run -ti --rm -v %s:/data -v %s:/opt/DPABI ', y_ShellQuote(WorkingDir), y_ShellQuote(DPABIPath));
    end

    Command=sprintf('%s cgyan/dpabi python3 /opt/DPABI/RedistributedToolboxes/MPRAGEise_yan.py -i %s -u %s -o %s --overwrite', ...
        CommandInit, ...
        y_ShellQuote(y_LocalPathToDockerPath(Inv2File,WorkingDir,'/data')), ...
        y_ShellQuote(y_LocalPathToDockerPath(UniFile,WorkingDir,'/data')), ...
        y_ShellQuote(y_LocalPathToDockerPath(OutAnatDir,WorkingDir,'/data')));
end

Status=system(Command);
if Status~=0
    error(['MPRAGEise_yan failed for subject ',SubjectID,'. Command: ',Command])
end
if 2~=exist(MPRAGEiseOutputFile,'file')
    error(['MPRAGEise_yan finished but expected output was not found: ',MPRAGEiseOutputFile])
end

y_DeleteIfExists([OutputBase,'.nii']);
y_DeleteIfExists([OutputBase,'.nii.gz']);
[MoveStatus, MoveMessage] = movefile(MPRAGEiseOutputFile,BIDSOutputFile);
if ~MoveStatus
    error(['Failed to move MPRAGEise_yan output to BIDS T1w file: ',MoveMessage])
end

JSONFile=y_GetMatchingJSONFile(UniFile);
if 2==exist(JSONFile,'file')
    copyfile(JSONFile,[OutputBase,'.json']);
end


function [Inv2File, UniFile, TI2Dir, T1Dir] = y_GetMPRAGEiseYanInputFiles(WorkingDir, SessionPrefix, SubjectID)
TI2Dir=[WorkingDir,filesep,SessionPrefix,'TI2Img'];
T1Dir=[WorkingDir,filesep,SessionPrefix,'T1Img'];
Inv2File=y_FindFirstSubjectNifti(TI2Dir, SubjectID);
UniFile=y_FindFirstSubjectNifti(T1Dir, SubjectID);


function File = y_FindFirstSubjectNifti(BaseDir, SubjectID)
File='';
SubjectDir=[BaseDir,filesep,SubjectID];
if 7==exist(SubjectDir,'dir')
    File=y_FindFirstNiftiByPatterns(SubjectDir, {'*Crop*.nii','*Crop*.nii.gz','*.nii','*.nii.gz'});
    if ~isempty(File)
        return
    end
end
File=y_FindFirstNiftiByPatterns(BaseDir, {[SubjectID,'*Crop*.nii'],[SubjectID,'*Crop*.nii.gz'],[SubjectID,'*.nii'],[SubjectID,'*.nii.gz']});


function File = y_FindFirstNiftiByPatterns(SearchDir, PatternSet)
File='';
if 7~=exist(SearchDir,'dir')
    return
end
for iPattern=1:length(PatternSet)
    DirImg=dir([SearchDir,filesep,PatternSet{iPattern}]);
    if ~isempty(DirImg)
        [~, SortIndex] = sort(lower({DirImg.name}));
        DirImg=DirImg(SortIndex);
        File=[SearchDir,filesep,DirImg(1).name];
        return
    end
end


function ContainerPath = y_LocalPathToDockerPath(LocalPath, LocalRoot, ContainerRoot)
if length(LocalPath)<length(LocalRoot) || ~strcmp(LocalPath(1:length(LocalRoot)),LocalRoot)
    error(['Path is not under the Docker-mounted working directory: ',LocalPath])
end
RelativePath=LocalPath(length(LocalRoot)+1:end);
if ~isempty(RelativePath) && (strcmp(RelativePath(1),filesep) || strcmp(RelativePath(1),'/') || strcmp(RelativePath(1),'\'))
    RelativePath=RelativePath(2:end);
end
RelativePath=strrep(RelativePath,'\','/');
RelativePath=strrep(RelativePath,filesep,'/');
if isempty(RelativePath)
    ContainerPath=ContainerRoot;
else
    ContainerPath=[ContainerRoot,'/',RelativePath];
end


function Quoted = y_ShellQuote(Path)
if ispc
    Path=strrep(Path,'"','\"');
else
    Path=strrep(Path,'\','\\');
    Path=strrep(Path,'"','\"');
    Path=strrep(Path,'$','\$');
    Path=strrep(Path,'`','\`');
end
Quoted=['"',Path,'"'];


function JSONFile = y_GetMatchingJSONFile(NiftiFile)
[PathName, FileName, Ext] = fileparts(NiftiFile);
if strcmpi(Ext,'.gz')
    [~, FileName, ~] = fileparts(FileName);
end
JSONFile=[PathName,filesep,FileName,'.json'];


function y_DeleteIfExists(File)
if 2==exist(File,'file')
    delete(File);
end


function y_FillSBREFJSONFiles(JSONFileSet, TR)
if isempty(JSONFileSet)
    return
end

for iJSONFile=1:length(JSONFileSet)
    JSONFile=JSONFileSet{iJSONFile};
    clear JSON
    JSON.TaskName='REST';
    if TR>0
        JSON.RepetitionTime=TR;
    end

    if ~exist(JSONFile,'file')
        spm_jsonwrite(JSONFile,JSON);
    else
        JSON_Exist = spm_jsonread(JSONFile);
        NeedWrite=0;
        if ~isfield(JSON_Exist,'TaskName')
            JSON_Exist.TaskName=JSON.TaskName;
            NeedWrite=1;
        end
        if ~isfield(JSON_Exist,'RepetitionTime') && ~isfield(JSON_Exist,'VolumeTiming') && isfield(JSON,'RepetitionTime')
            JSON_Exist.RepetitionTime=JSON.RepetitionTime;
            NeedWrite=1;
        end
        if NeedWrite
            spm_jsonwrite(JSONFile,JSON_Exist);
        end
    end
end


function [FunFile_IntendedFor, FunJSONFiles, MetadataSourceFiles] = y_CopyFunImgToBIDS(FunDir, OutFuncDir, RelativeFuncDir, BIDSBaseName)
[FunFile_IntendedFor, FunJSONFiles, MetadataSourceFiles] = y_CopyFunImgToBIDSWithSuffix(FunDir, OutFuncDir, RelativeFuncDir, BIDSBaseName, 'bold', 1);


function SBREFJSONFiles = y_CopyFunSBREFImgToBIDS(FunSBREFDir, OutFuncDir, BIDSBaseName)
[~, SBREFJSONFiles, ~] = y_CopyFunImgToBIDSWithSuffix(FunSBREFDir, OutFuncDir, '', BIDSBaseName, 'sbref', 0);


function [FunFile_IntendedFor, FunJSONFiles, MetadataSourceFiles] = y_CopyFunImgToBIDSWithSuffix(FunDir, OutFuncDir, RelativeFuncDir, BIDSBaseName, Suffix, IsRequired)
[EchoGroups, IsMultiEcho] = y_GetFunImgEchoGroups(FunDir);

FunFile_IntendedFor={};
FunJSONFiles={};
MetadataSourceFiles={};
if isempty(EchoGroups)
    if IsRequired
        error(['No functional image is found in: ',FunDir]);
    else
        return
    end
end

MetadataSourceFiles=EchoGroups(1).Files;
for iEcho=1:length(EchoGroups)
    if IsMultiEcho
        OutputBaseName=[BIDSBaseName,'_echo-',num2str(EchoGroups(iEcho).EchoIndex),'_',Suffix];
    else
        OutputBaseName=[BIDSBaseName,'_',Suffix];
    end

    OutputImgPathBase=[OutFuncDir,filesep,OutputBaseName];
    OutputExt=y_CopyFunImgGroup(EchoGroups(iEcho).Files,OutputImgPathBase);
    if ~isempty(RelativeFuncDir)
        FunFile_IntendedFor=[FunFile_IntendedFor,{[RelativeFuncDir,'/',OutputBaseName,OutputExt]}];
    end

    OutputJSONFile=[OutFuncDir,filesep,OutputBaseName,'.json'];
    FunJSONFiles=[FunJSONFiles,{OutputJSONFile}];
    if ~isempty(EchoGroups(iEcho).JSONFiles)
        copyfile(EchoGroups(iEcho).JSONFiles{1},OutputJSONFile);
    end
end


function [EchoGroups, IsMultiEcho] = y_GetFunImgEchoGroups(FunDir)
DirImg=dir([FunDir,filesep,'*.img']);
DirNii=dir([FunDir,filesep,'*.nii']);
DirNiiGZ=dir([FunDir,filesep,'*.nii.gz']);
DirAll=[DirImg;DirNii;DirNiiGZ];

EchoGroups=struct('EchoIndex',{},'Files',{},'JSONFiles',{});
IsMultiEcho=0;
if isempty(DirAll)
    return
end

[~, SortIndex] = sort(lower({DirAll.name}));
DirAll=DirAll(SortIndex);

ImageInfo=struct('Name',{},'Path',{},'Stem',{},'EchoIndex',{},'HasEchoLabel',{});
for iFile=1:length(DirAll)
    [Stem, ~] = y_GetImageStemAndExt(DirAll(iFile).name);
    EchoTokens=regexpi(DirAll(iFile).name,'_e(\d+)\.(nii\.gz|nii|img)$','tokens','once');

    ImageInfo(iFile).Name=DirAll(iFile).name;
    ImageInfo(iFile).Path=[FunDir,filesep,DirAll(iFile).name];
    ImageInfo(iFile).Stem=Stem;
    if isempty(EchoTokens)
        ImageInfo(iFile).EchoIndex=NaN;
        ImageInfo(iFile).HasEchoLabel=0;
    else
        ImageInfo(iFile).EchoIndex=str2double(EchoTokens{1});
        ImageInfo(iFile).HasEchoLabel=1;
    end
end

HasEchoLabel=logical([ImageInfo.HasEchoLabel]);
if any(HasEchoLabel)
    EchoIndexSet=[ImageInfo(HasEchoLabel).EchoIndex];
    IsMultiEcho=any(EchoIndexSet>=2);
else
    EchoIndexSet=[];
end

if IsMultiEcho
    if ~any(EchoIndexSet==1)
        Index=find(~HasEchoLabel);
        if ~isempty(Index)
            EchoGroups(end+1)=y_BuildFunImgEchoGroup(ImageInfo(Index),1,FunDir); %#ok<AGROW>
        end
    end

    EchoIndexSet=unique(EchoIndexSet);
    EchoIndexSet=sort(EchoIndexSet);
    for iEcho=1:length(EchoIndexSet)
        Index=find(HasEchoLabel & [ImageInfo.EchoIndex]==EchoIndexSet(iEcho));
        EchoGroups(end+1)=y_BuildFunImgEchoGroup(ImageInfo(Index),EchoIndexSet(iEcho),FunDir); %#ok<AGROW>
    end
else
    EchoGroups=y_BuildFunImgEchoGroup(ImageInfo,1,FunDir);
end


function EchoGroup = y_BuildFunImgEchoGroup(ImageInfo, EchoIndex, FunDir)
EchoGroup.EchoIndex=EchoIndex;
EchoGroup.Files={ImageInfo.Path};
EchoGroup.JSONFiles={};
for iFile=1:length(ImageInfo)
    JSONFile=[FunDir,filesep,ImageInfo(iFile).Stem,'.json'];
    if 2==exist(JSONFile,'file')
        EchoGroup.JSONFiles=[EchoGroup.JSONFiles,{JSONFile}]; %#ok<AGROW>
    end
end


function OutputExt = y_CopyFunImgGroup(SourceFiles, OutputImgPathBase)
if isempty(SourceFiles)
    error('No functional image is found.');
end

[~, SourceExt] = y_GetImageStemAndExt(SourceFiles{1});
if length(SourceFiles)>1
    TempDir=tempname;
    mkdir(TempDir);
    CleanupObj=onCleanup(@()rmdir(TempDir,'s')); %#ok<NASGU>
    for iFile=1:length(SourceFiles)
        copyfile(SourceFiles{iFile},TempDir);
        [SourcePath, SourceName, SourceExtTemp] = fileparts(SourceFiles{iFile});
        if strcmpi(SourceExtTemp,'.img')
            HeaderFile=[SourcePath,filesep,SourceName,'.hdr'];
            if 2==exist(HeaderFile,'file')
                copyfile(HeaderFile,TempDir);
            end
            MatFile=[SourcePath,filesep,SourceName,'.mat'];
            if 2==exist(MatFile,'file')
                copyfile(MatFile,TempDir);
            end
        end
    end
    [Data,~,~, Header] =y_ReadAll(TempDir);
    y_Write(Data,Header,[OutputImgPathBase,'.nii'])
    OutputExt='.nii';
elseif strcmpi(SourceExt,'.img')
    [Data, Header]=y_Read(SourceFiles{1});
    y_Write(Data,Header,[OutputImgPathBase,'.nii'])
    OutputExt='.nii';
elseif strcmpi(SourceExt,'.nii')
    copyfile(SourceFiles{1},[OutputImgPathBase,'.nii'])
    OutputExt='.nii';
elseif strcmpi(SourceExt,'.nii.gz')
    copyfile(SourceFiles{1},[OutputImgPathBase,'.nii.gz'])
    OutputExt='.nii.gz';
else
    error(['Unsupported functional image format: ',SourceFiles{1}]);
end


function [TR, SliceNumber, nTimePoints, VoxelSize] = y_GetFunImgBasicInfo(SourceFiles)
if isempty(SourceFiles)
    error('No functional image is found for metadata extraction.');
end

[~, SourceExt] = y_GetImageStemAndExt(SourceFiles{1});
if strcmpi(SourceExt,'.nii.gz')
    TempDir=tempname;
    mkdir(TempDir);
    CleanupObj=onCleanup(@()rmdir(TempDir,'s')); %#ok<NASGU>
    gunzip(SourceFiles{1},TempDir);
    [SourceStem, ~] = y_GetImageStemAndExt(SourceFiles{1});
    File=[TempDir,filesep,SourceStem,'.nii'];
else
    File=SourceFiles{1};
end

Nii  = nifti(File);
if (~isfield(Nii.timing,'tspace'))
    error('Can NOT retrieve the TR information from the NIfTI images');
end
TR = Nii.timing.tspace;

SliceNumber = size(Nii.dat,3);

if size(Nii.dat,4)==1 %Test if 3D volume
    nTimePoints = length(SourceFiles);
else %4D volume
    nTimePoints = size(Nii.dat,4);
end

VoxelSize = sqrt(sum(Nii.mat(1:3,1:3).^2));


function [Stem, Ext] = y_GetImageStemAndExt(FileName)
if length(FileName)>=7 && strcmpi(FileName(end-6:end),'.nii.gz')
    [~, NameOnly] = fileparts(FileName(1:end-3));
    Stem=NameOnly;
    Ext='.nii.gz';
else
    [~, Stem, Ext] = fileparts(FileName);
end


function y_FillEchoTimesInPhaseDiffJSON(PhaseDiffJSONFile, Magnitude1JSONFile, Magnitude2JSONFile)
if 2~=exist(PhaseDiffJSONFile,'file')
    return
end

PhaseDiffJSON=spm_jsonread(PhaseDiffJSONFile);
NeedWrite=0;

if ~isfield(PhaseDiffJSON,'EchoTime1') || isempty(PhaseDiffJSON.EchoTime1)
    EchoTime1=y_GetEchoTimeFromJSON(Magnitude1JSONFile);
    if ~isempty(EchoTime1)
        PhaseDiffJSON.EchoTime1=EchoTime1;
        NeedWrite=1;
    end
end

if ~isfield(PhaseDiffJSON,'EchoTime2') || isempty(PhaseDiffJSON.EchoTime2)
    EchoTime2=y_GetEchoTimeFromJSON(Magnitude2JSONFile);
    if ~isempty(EchoTime2)
        PhaseDiffJSON.EchoTime2=EchoTime2;
        NeedWrite=1;
    end
end

if NeedWrite
    spm_jsonwrite(PhaseDiffJSONFile,PhaseDiffJSON);
end


function EchoTime = y_GetEchoTimeFromJSON(JSONFile)
EchoTime=[];
if 2~=exist(JSONFile,'file')
    return
end

JSON=spm_jsonread(JSONFile);
if isfield(JSON,'EchoTime') && ~isempty(JSON.EchoTime)
    EchoTime=JSON.EchoTime;
end

