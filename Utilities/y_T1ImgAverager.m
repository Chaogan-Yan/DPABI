function y_T1ImgAverager(AutoDataProcessParameter)

% FORMAT y_T1ImgAverager(AutoDataProcessParameter)
% Input:
%   AutoDataProcessParameter - the parameters for auto data processing
%   AutoDataProcessParameter.DataProcessDir='/home/data/YCG_AllData/YAN_Work/Monkey/Analysis/Cebus/CP1F/T1CoregAverage';
%   AutoDataProcessParameter.SubjectID={'CP1F'};
%   AutoDataProcessParameter.IsNeedConvertT1DCM2IMG=1;
%   AutoDataProcessParameter.IsCalMeanT1Image=1;
% Output:
%   The averaged T1 data in T1Img.
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

if ~isfield(AutoDataProcessParameter,'IsNeedConvertT1DCM2IMG')
    AutoDataProcessParameter.IsNeedConvertT1DCM2IMG=0;
end

if ~isfield(AutoDataProcessParameter,'IsCalMeanT1Image')
    AutoDataProcessParameter.IsCalMeanT1Image=0;
end



%Convert T1 DICOM files to NIFTI images
if (AutoDataProcessParameter.IsNeedConvertT1DCM2IMG==1)
    cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1Raw_MultiRun']);
    parfor i=1:AutoDataProcessParameter.SubjectNum
        cd (AutoDataProcessParameter.SubjectID{i})
        DirRuns=dir;
        
        if strcmpi(DirRuns(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
            StartIndex=4;
        else
            StartIndex=3;
        end
        
        for iRun=StartIndex:length(DirRuns)
            OutputDir=[AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRuns(iRun).name];
            mkdir(OutputDir);
            DirDCM=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Raw_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRuns(iRun).name,filesep,'*']); %Revised by YAN Chao-Gan 100130. %DirDCM=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Raw_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.*']);
            
            
            if strcmpi(DirDCM(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
                StartIndex=4;
            else
                StartIndex=3;
            end
            InputFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'T1Raw_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRuns(iRun).name,filesep,DirDCM(StartIndex).name];
            
            %YAN Chao-Gan 120817.
            y_Call_dcm2nii(InputFilename, OutputDir, 'DefaultINI');
            
            fprintf(['Converting T1 Images:',AutoDataProcessParameter.SubjectID{i},' OK']);
            
        end
        cd ('..')
    end
    fprintf('\n');
end





%Calaulate the mean T1 Image for the multiple runs
if (AutoDataProcessParameter.IsCalMeanT1Image==1)
    
    % First check which kind of T1 image need to be applied
    if ~exist('UseNoCoT1Image','var')
        cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{1}]);
        
        DirRuns=dir;
        
        if strcmpi(DirRuns(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
            StartIndex=4;
        else
            StartIndex=3;
        end
        
        cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{1},filesep,DirRuns(StartIndex).name]);
        
        DirCo=dir('c*.img');
        if isempty(DirCo)
            DirCo=dir('c*.nii.gz');  % Search .nii.gz and unzip; YAN Chao-Gan, 120806.
            if length(DirCo)==1
                gunzip(DirCo(1).name);
                delete(DirCo(1).name);
            end
            DirCo=dir('c*.nii');  %YAN Chao-Gan, 111114. Also support .nii files.
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
        cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i}]);
        DirRuns=dir;
        
        if strcmpi(DirRuns(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
            StartIndex=4;
        else
            StartIndex=3;
        end
        
        
        if UseNoCoT1Image==0
            DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRuns(StartIndex).name,filesep,'c*.img']);
            if isempty(DirT1Img)
                DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRuns(StartIndex).name,filesep,'c*.nii.gz']);% Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirT1Img)==1
                    gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRuns(StartIndex).name,filesep,DirT1Img(1).name]);
                    delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRuns(StartIndex).name,filesep,DirT1Img(1).name]);
                end
                DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRuns(StartIndex).name,filesep,'c*.nii']);
            end
        else
            DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRuns(StartIndex).name,filesep,'*.img']);
            if isempty(DirT1Img)
                DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRuns(StartIndex).name,filesep,'*.nii.gz']);% Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                if length(DirT1Img)==1
                    gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRuns(StartIndex).name,filesep,DirT1Img(1).name]);
                    delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRuns(StartIndex).name,filesep,DirT1Img(1).name]);
                end
                DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRuns(StartIndex).name,filesep,'*.nii']);
            end
        end
        
        RefDir = DirT1Img;
        RefFile=[AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRuns(StartIndex).name,filesep,DirT1Img(1).name];
        
        
        for iRun=StartIndex+1:length(DirRuns)
            
            if UseNoCoT1Image==0
                DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRuns(iRun).name,filesep,'c*.img']);
                if isempty(DirT1Img)
                    DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRuns(iRun).name,filesep,'c*.nii.gz']);% Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                    if length(DirT1Img)==1
                        gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRuns(iRun).name,filesep,DirT1Img(1).name]);
                        delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRuns(iRun).name,filesep,DirT1Img(1).name]);
                    end
                    DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRuns(iRun).name,filesep,'c*.nii']);
                end
            else
                DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRuns(iRun).name,filesep,'*.img']);
                if isempty(DirT1Img)
                    DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRuns(iRun).name,filesep,'*.nii.gz']);% Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                    if length(DirT1Img)==1
                        gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRuns(iRun).name,filesep,DirT1Img(1).name]);
                        delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRuns(iRun).name,filesep,DirT1Img(1).name]);
                    end
                    DirT1Img=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRuns(iRun).name,filesep,'*.nii']);
                end
            end
            
            SourceFile=[AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRuns(iRun).name,filesep,DirT1Img(1).name];
            
            
            SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Coregister_Estimate_Reslice.mat']);
            
            SPMJOB.matlabbatch{1,1}.spm.spatial.coreg.estwrite.ref={RefFile};
            SPMJOB.matlabbatch{1,1}.spm.spatial.coreg.estwrite.source={SourceFile};
            fprintf(['Coregister Setup:',AutoDataProcessParameter.SubjectID{i},', Run- ',num2str(iRun),' OK']);
            
            fprintf('\n');
            spm_jobman('run',SPMJOB.matlabbatch);
        end
        
        %Calculate the mean
        fprintf('\nCalculate the mean T1 mean brain for "%s".\n',AutoDataProcessParameter.SubjectID{i});
        cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i}]);
        
        [Data, Header] = y_Read(RefFile);
        DataSum = Data;
        nT1 = 1;
        
        for iRun=StartIndex+1:length(DirRuns)
            SourceDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRuns(iRun).name,filesep,'r*.nii']);
            SourceFile=[AutoDataProcessParameter.DataProcessDir,filesep,'T1Img_MultiRun',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRuns(iRun).name,filesep,SourceDir(1).name];
            
            [Data, Header] = y_Read(SourceFile);
            DataSum = DataSum + Data;
            nT1 = nT1 + 1;
        end
        Data=DataSum/nT1;
        
        Header.pinfo = [1;0;0];
        Header.dt = [16,0];
        
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i}]);
        
        Data(find(isnan(Data)))=0; %YAN Chao-Gan, 161116. Clean data.
        Data(find(isinf(Data)))=0;
        
        y_Write(Data,Header,[AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean',RefDir(1).name]);
        fprintf('\nMean T1 brain for "%s" saved as: %s\n',AutoDataProcessParameter.SubjectID{i}, [AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean',RefDir(1).name]);
        
    end
end







