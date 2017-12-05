function y_Convert_BIDS2DPARSFA(InDir, OutDir, Options)
% function y_Convert_BIDS2DPARSFA(InDir, OutDir, Options)
% Convert BIDS data structure to DPARSF data structure.
%   Input:
%     InDir  - Input dir with BIDS data.
%     OutDir - Output dir with DPARSF data.
%     Options - Options from command line
%___________________________________________________________________________
% Written by YAN Chao-Gan 171125.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com

fprintf('Converting BIDS to DPARSFA structure...\n');

Temp=strfind(Options,'--participant_label');
if ~isempty(Temp) %Subject list provided
    TempStr=Options(Temp:end);
    Temp=strfind(TempStr,' ');
    SubID=[];
    for iSub=1:length(Temp)-1
        SubID{iSub,1}=['sub-',TempStr(Temp(iSub)+1:Temp(iSub+1)-1)];
    end
    SubID{length(Temp),1}=['sub-',TempStr(Temp(end)+1:end)];
else %Subject list not provided, process all the subjects
    Dir=dir([InDir,filesep,'sub*']);
    SubID=[];
    for i=1:length(Dir)
        SubID{i,1}=Dir(i).name;
    end
end

DirSessions=dir([InDir,filesep,SubID{1,1},filesep,'ses*']);
FunctionalSessionNumber=length(DirSessions);

%Single session data
if FunctionalSessionNumber==0
    mkdir([OutDir,filesep,'T1Img']);
    mkdir([OutDir,filesep,'FunImg']);
    for i=1:length(SubID)
        mkdir([OutDir,filesep,'T1Img',filesep,SubID{i},filesep]);
        DirFile=dir([InDir,filesep,SubID{i},filesep,'anat',filesep,SubID{i},'*_T1w.nii.gz']);
        copyfile([InDir,filesep,SubID{i},filesep,'anat',filesep,DirFile(1).name],[OutDir,filesep,'T1Img',filesep,SubID{i},filesep]);
        
        mkdir([OutDir,filesep,'FunImg',filesep,SubID{i},filesep]);
        DirFile=dir([InDir,filesep,SubID{i},filesep,'func',filesep,'*.nii.gz']);
        copyfile([InDir,filesep,SubID{i},filesep,'func',filesep,DirFile(1).name],[OutDir,filesep,'FunImg',filesep,SubID{i},filesep]);
    end
end


%Multiple session data
if FunctionalSessionNumber>=1
    FunSessionPrefixSet={''}; %The first session doesn't need a prefix. From the second session, need a prefix such as 'S2_';
    for iFunSession=2:FunctionalSessionNumber
        FunSessionPrefixSet=[FunSessionPrefixSet;{['S',num2str(iFunSession),'_']}];
    end
    
    mkdir([OutDir,filesep,'T1Img']);
    for i=1:length(SubID)
        mkdir([OutDir,filesep,'T1Img',filesep,SubID{i},filesep]);
        DirFile=dir([InDir,filesep,SubID{i},filesep,DirSessions(1).name,filesep,'anat',filesep,SubID{i},'*_T1w.nii.gz']);
        copyfile([InDir,filesep,SubID{i},filesep,DirSessions(1).name,filesep,'anat',filesep,DirFile(1).name],[OutDir,filesep,'T1Img',filesep,SubID{i},filesep]);
    end
    
    for iFunSession=1:FunctionalSessionNumber
        mkdir([OutDir,filesep,FunSessionPrefixSet{iFunSession},'FunImg']);
        for i=1:length(SubID)
            mkdir([OutDir,filesep,FunSessionPrefixSet{iFunSession},'FunImg',filesep,SubID{i},filesep]);
            DirFile=dir([InDir,filesep,SubID{i},filesep,DirSessions(iFunSession).name,filesep,'func',filesep,'*.nii.gz']);
            copyfile([InDir,filesep,SubID{i},filesep,DirSessions(iFunSession).name,filesep,'func',filesep,DirFile(1).name],[OutDir,filesep,FunSessionPrefixSet{iFunSession},'FunImg',filesep,SubID{i},filesep]);
        end
    end
end


%Save SubID file
SubID_File=[OutDir,filesep,'SubID.txt'];
fid = fopen(SubID_File,'w');
for iSub=1:length(SubID)
    fprintf(fid,'%s\n',SubID{iSub});
end
fclose(fid);

%Setup DPARSFA Cfg
MATPATH=fileparts(mfilename('fullpath'));
load([MATPATH,filesep,'Template_V4_CalculateInMNISpace_Warp_DARTEL_docker.mat'])
Cfg.SubID=SubID;
Cfg.DataProcessDir=OutDir;

Cfg.FunctionalSessionNumber=FunctionalSessionNumber;
if Cfg.FunctionalSessionNumber==0
    Cfg.FunctionalSessionNumber=1;
end
UseNoCoT1Image=1; %Prevent the dialog asking confirm use no co t1 images.
save('-v7',[OutDir,filesep,'DPARSFACfg.mat'],'Cfg','UseNoCoT1Image');






