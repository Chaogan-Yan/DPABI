function y_T1ImgDefacer(AutoDataProcessParameter)

% FORMAT y_T1ImgDefacer(AutoDataProcessParameter)
% Input:
%   AutoDataProcessParameter - the parameters for auto data processing
%   AutoDataProcessParameter.DataProcessDir='/home/data/YCG_AllData/YAN_Work/Monkey/Analysis/Cebus/CP1F/T1CoregAverage';
%   AutoDataProcessParameter.SubjectID={'CP1F'};
%   AutoDataProcessParameter.IsT1Deface=1;
% Output:
%   The defaced T1Img.
%-----------------------------------------------------------
% Written by YAN Chao-Gan 140827.
% The Nathan Kline Institute for Psychiatric Research, Orangeburg, NY 10962
% Department of Child and Adolescent Psychiatry / NYU Langone Medical Center Child Study Center, New York University, New York, NY 10016
% ycg.yan@gmail.com


if ischar(AutoDataProcessParameter)  %If inputed a .mat file name. (Cfg inside)
    load(AutoDataProcessParameter);
    AutoDataProcessParameter=Cfg;
end

%[ProgramPath, fileN, extn] = fileparts(which('DPARSFA_run.m'));
[DPABIPath, fileN, extn] = fileparts(which('DPABI.m'));
ProgramPath=fullfile(DPABIPath, 'DPARSF');
AutoDataProcessParameter.SubjectNum=length(AutoDataProcessParameter.SubjectID);
Error=[];
addpath([ProgramPath,filesep,'Subfunctions']);

[DPABIPath, fileN, extn] = fileparts(which('DPABI.m'));
TemplatePath=fullfile(DPABIPath, 'Templates');

[SPMversion,c]=spm('Ver');
SPMversion=str2double(SPMversion(end));


%Make compatible with missing parameters. YAN Chao-Gan, 100420.
if ~isfield(AutoDataProcessParameter,'DataProcessDir')
    AutoDataProcessParameter.DataProcessDir=AutoDataProcessParameter.WorkingDir;
end

if ~isfield(AutoDataProcessParameter,'IsNeedReorientT1ImgInteractively')
    AutoDataProcessParameter.IsNeedReorientT1ImgInteractively=0;
end

if ~isfield(AutoDataProcessParameter,'IsT1Deface')
    AutoDataProcessParameter.IsT1Deface=0;
end



%Convert T1 DICOM files to NIFTI images
if (AutoDataProcessParameter.IsNeedConvertT1DCM2IMG==1)
    cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1Raw']);
    parfor i=1:AutoDataProcessParameter.SubjectNum
        OutputDir=[AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i}];
        mkdir(OutputDir);
        DirDCM=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Raw',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*']); %Revised by YAN Chao-Gan 100130. %DirDCM=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Raw',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.*']);
        if strcmpi(DirDCM(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
            StartIndex=4;
        else
            StartIndex=3;
        end
        InputFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'T1Raw',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirDCM(StartIndex).name];
        
        %YAN Chao-Gan 120817.
        y_Call_dcm2nii(InputFilename, OutputDir, 'DefaultINI');
        
        fprintf(['Converting T1 Images:',AutoDataProcessParameter.SubjectID{i},' OK']);
    end
    fprintf('\n');
end




%Reorient T1 Image Interactively
%Do not need parfor
if (AutoDataProcessParameter.IsNeedReorientT1ImgInteractively==1)
    % First check which kind of T1 image need to be applied
    if ~exist('UseNoCoT1Image','var')
        cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{1}]);
        DirCo=dir('c*.img');
        if isempty(DirCo)
            DirCo=dir('c*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
            if isempty(DirCo)
                DirCo=dir('*Crop*.nii.gz'); 
            end
            if length(DirCo)==1
                gunzip(DirCo(1).name);
                delete(DirCo(1).name);
            end
            DirCo=dir('c*.nii');  %YAN Chao-Gan, 111114. Also support .nii files.
            if isempty(DirCo)
                DirCo=dir('*Crop*.nii');  %YAN Chao-Gan, 191121. Support BIDS format.
            end
        end
        if isempty(DirCo)
            DirImg=dir('*.img');
            if isempty(DirImg)  %YAN Chao-Gan, 111114. Also support .nii files.
                DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirImg)>=1
                    for j=1:length(DirImg)
                        gunzip(DirImg(j).name);
                        delete(DirImg(j).name);
                    end
                end
                DirImg=dir('*.nii');
            end
            if length(DirImg)==1
                button = questdlg(['No co* T1 image (T1 image which is reoriented to the nearest orthogonal direction to ''canonical space'' and removed excess air surrounding the individual as well as parts of the neck below the cerebellum) is found. Do you want to use the T1 image without co? Such as: ',DirImg(1).name,'?'],'No co* T1 image is found','Yes','No','Yes');
                if strcmpi(button,'Yes')
                    UseNoCoT1Image=1;
                else
                    return;
                end
            elseif length(DirImg)==0
                errordlg(['No T1 image has been found.'],'No T1 image has been found');
                return;
            else
                errordlg(['No co* T1 image (T1 image which is reoriented to the nearest orthogonal direction to ''canonical space'' and removed excess air surrounding the individual as well as parts of the neck below the cerebellum) is found. And there are too many T1 images detected in T1Img directory. Please determine which T1 image you want to use and delete the others from the T1Img directory, then re-run the analysis.'],'No co* T1 image is found');
                return;
            end
        else
            UseNoCoT1Image=0;
        end
        cd('..');
    end
    
    if ~(7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'ReorientMats'],'dir'))
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'ReorientMats']);
    end
    %Reorient
    for i=1:AutoDataProcessParameter.SubjectNum
        if UseNoCoT1Image==0
            DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'c*.img']);
            if isempty(DirT1Img)
                DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'c*.nii.gz']);% Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if isempty(DirT1Img)
                    DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*Crop*.nii.gz']); %YAN Chao-Gan, 191121. Calling dcm2niix for BIDS format. Change searching c* to *Crop*
                end
                if length(DirT1Img)==1
                    gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1Img(1).name]);
                    delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1Img(1).name]);
                end
                DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'c*.nii']);
                if isempty(DirT1Img)
                    DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*Crop*.nii']); %YAN Chao-Gan, 191121. Calling dcm2niix for BIDS format. Change searching c* to *Crop*
                end
            end
        else
            DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.img']);
            if isempty(DirT1Img)
                DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii.gz']);% Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirT1Img)==1
                    gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1Img(1).name]);
                    delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1Img(1).name]);
                end
                DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii']);
            end
        end
        FileList=[{[AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1Img(1).name,',1']}];
        fprintf('Reorienting T1 Image Interactively for %s: \n',AutoDataProcessParameter.SubjectID{i});
        global y_spm_image_Parameters
        y_spm_image_Parameters.ReorientFileList=FileList;
        uiwait(y_spm_image('init',[AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1Img(1).name]));
        mat=y_spm_image_Parameters.ReorientMat;
        
        % YAN Chao-Gan 131126. Save the QC scores and comments
        AutoDataProcessParameter.QC.RawT1ImgQC.QCScore(i,1) = y_spm_image_Parameters.QCScore;
        AutoDataProcessParameter.QC.RawT1ImgQC.QCComment{i,1} = y_spm_image_Parameters.QCComment;
        
        save([AutoDataProcessParameter.DataProcessDir,filesep,'ReorientMats',filesep,AutoDataProcessParameter.SubjectID{i},'_ReorientT1ImgMat.mat'],'mat')
        clear global y_spm_image_Parameters
        fprintf('Reorienting T1 Image Interactively for %s: OK\n',AutoDataProcessParameter.SubjectID{i});
    end
    
    
    %Write the QC information as {WorkDir}/QC/RawT1ImgQC.tsv
    mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'QC'])
    fid = fopen([AutoDataProcessParameter.DataProcessDir,filesep,'QC',filesep,'RawT1ImgQC.tsv'],'w');
    
    fprintf(fid,'Subject ID');
    fprintf(fid,['\t','QC Score']);
    fprintf(fid,['\t','QC Comment']);
    fprintf(fid,'\n');
    for i=1:AutoDataProcessParameter.SubjectNum
        fprintf(fid,'%s',AutoDataProcessParameter.SubjectID{i});
        fprintf(fid,'\t%g',AutoDataProcessParameter.QC.RawT1ImgQC.QCScore(i,1));
        fprintf(fid,'\t%s',AutoDataProcessParameter.QC.RawT1ImgQC.QCComment{i,1});
        fprintf(fid,'\n');
    end
    fclose(fid);
    
end
if ~isempty(Error)
    disp(Error);
    return;
end






%Deface
if (AutoDataProcessParameter.IsT1Deface==1)
    
    % First check which kind of T1 image need to be applied
    if ~exist('UseNoCoT1Image','var')
        cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{1}]);
        DirCo=dir('c*.img');
        if isempty(DirCo)
            DirCo=dir('c*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
            if isempty(DirCo)
                DirCo=dir('*Crop*.nii.gz');
            end
            if length(DirCo)==1
                gunzip(DirCo(1).name);
                delete(DirCo(1).name);
            end
            DirCo=dir('c*.nii');  %YAN Chao-Gan, 111114. Also support .nii files.
            if isempty(DirCo)
                DirCo=dir('*Crop*.nii');  %YAN Chao-Gan, 191121. Support BIDS format.
            end
        end
        if isempty(DirCo)
            DirImg=dir('*.img');
            if isempty(DirImg)  %YAN Chao-Gan, 111114. Also support .nii files.
                DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirImg)>=1
                    for j=1:length(DirImg)
                        gunzip(DirImg(j).name);
                        delete(DirImg(j).name);
                    end
                end
                DirImg=dir('*.nii');
            end
            if length(DirImg)==1
                button = questdlg(['No co* T1 image (T1 image which is reoriented to the nearest orthogonal direction to ''canonical space'' and removed excess air surrounding the individual as well as parts of the neck below the cerebellum) is found. Do you want to use the T1 image without co? Such as: ',DirImg(1).name,'?'],'No co* T1 image is found','Yes','No','Yes');
                if strcmpi(button,'Yes')
                    UseNoCoT1Image=1;
                else
                    return;
                end
            elseif length(DirImg)==0
                errordlg(['No T1 image has been found.'],'No T1 image has been found');
                return;
            else
                errordlg(['No co* T1 image (T1 image which is reoriented to the nearest orthogonal direction to ''canonical space'' and removed excess air surrounding the individual as well as parts of the neck below the cerebellum) is found. And there are too many T1 images detected in T1Img directory. Please determine which T1 image you want to use and delete the others from the T1Img directory, then re-run the analysis.'],'No co* T1 image is found');
                return;
            end
        else
            UseNoCoT1Image=0;
        end
        cd('..');
    end
    
    
    
    parfor i=1:AutoDataProcessParameter.SubjectNum
        
        if UseNoCoT1Image==0
            DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'c*.img']);
            if isempty(DirT1Img)
                DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'c*.nii.gz']);% Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if isempty(DirT1Img)
                    DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*Crop*.nii.gz']); %YAN Chao-Gan, 191121. Calling dcm2niix for BIDS format. Change searching c* to *Crop*
                end
                if length(DirT1Img)==1
                    gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1Img(1).name]);
                    delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1Img(1).name]);
                end
                DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'c*.nii']);
                if isempty(DirT1Img)
                    DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*Crop*.nii']); %YAN Chao-Gan, 191121. Calling dcm2niix for BIDS format. Change searching c* to *Crop*
                end
            end
        else
            DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.img']);
            if isempty(DirT1Img)
                DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii.gz']);% Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirT1Img)==1
                    gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1Img(1).name]);
                    delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1Img(1).name]);
                end
                DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii']);
            end
        end
        RefFile=[AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1Img(1).name];
        
        
        copyfile([TemplatePath,filesep,'mni_icbm152_t1_tal_nlin_asym_09c.nii'],[AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i}]);
        copyfile([TemplatePath,filesep,'mni_icbm152_t1_tal_nlin_asym_09c_face_mask.nii'],[AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i}]);
        
        SourceFile = [AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mni_icbm152_t1_tal_nlin_asym_09c.nii'];
        
        
        SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Coregister_Estimate_Reslice.mat']);
        
        SPMJOB.matlabbatch{1,1}.spm.spatial.coreg.estwrite.ref={RefFile};
        SPMJOB.matlabbatch{1,1}.spm.spatial.coreg.estwrite.source={SourceFile};
        
        SPMJOB.matlabbatch{1,1}.spm.spatial.coreg.estwrite.other = {[AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mni_icbm152_t1_tal_nlin_asym_09c_face_mask.nii']};
        SPMJOB.matlabbatch{1,1}.spm.spatial.coreg.estwrite.roptions.interp = 0;
        
        fprintf(['Coregister Setup:',AutoDataProcessParameter.SubjectID{i},' OK']);
        
        fprintf('\n');
        spm_jobman('run',SPMJOB.matlabbatch);
        
        %Calculate the mean
        fprintf('\nApplying the warped face mask for "%s".\n',AutoDataProcessParameter.SubjectID{i});
        
        [Data Header] = y_Read(RefFile);
        DataFaceMask = y_Read([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'rmni_icbm152_t1_tal_nlin_asym_09c_face_mask.nii']);
        
        Data(find(DataFaceMask>0.5)) = 0;
        
        Header.pinfo = [1;0;0];
        Header.dt = [16,0];
        
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgDefaced',filesep,AutoDataProcessParameter.SubjectID{i}]);
        y_Write(Data,Header,[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgDefaced',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1Img(1).name]);
        
    end
end


