function y_Convert_BIDS2DPARSF(InDir, OutDir, SubID)
% function y_Convert_BIDS2DPARSF(InDir, OutDir, Options)
% Convert BIDS data structure to DPARSF data structure.
%   Input:
%     InDir  - Input dir with BIDS data.
%     OutDir - Output dir with DPARSF data.
%     SubID - subject ID
%___________________________________________________________________________
% Written by YAN Chao-Gan 200214. Adapted from y_Convert_BIDS2DPARSFA.m
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com

fprintf('Converting BIDS to DPARSF structure...\n');

DirSessions=dir([InDir,filesep,SubID{1,1},filesep,'ses*']);
FunctionalSessionNumber=length(DirSessions);

%Single session data
if FunctionalSessionNumber==0
    mkdir([OutDir,filesep,'T1Img']);
    mkdir([OutDir,filesep,'FunImg']);
    for i=1:length(SubID)
        mkdir([OutDir,filesep,'T1Img',filesep,SubID{i},filesep]);
        DirFile=dir([InDir,filesep,SubID{i},filesep,'anat',filesep,SubID{i},'*_T1w.nii*']);
        copyfile([InDir,filesep,SubID{i},filesep,'anat',filesep,DirFile(1).name],[OutDir,filesep,'T1Img',filesep,SubID{i},filesep]);
        
        mkdir([OutDir,filesep,'FunImg',filesep,SubID{i},filesep]);
        DirFile=dir([InDir,filesep,SubID{i},filesep,'func',filesep,'*.nii*']);
        copyfile([InDir,filesep,SubID{i},filesep,'func',filesep,DirFile(1).name],[OutDir,filesep,'FunImg',filesep,SubID{i},filesep]);
        DirFile=dir([InDir,filesep,SubID{i},filesep,'func',filesep,'*.json']);
        copyfile([InDir,filesep,SubID{i},filesep,'func',filesep,DirFile(1).name],[OutDir,filesep,'FunImg',filesep,SubID{i},filesep]);

        %Dealing with FieldMap data
        FieldMapMeasures={'PhaseDiff','Magnitude1','Magnitude2','Phase1','Phase2'};
        for iFieldMapMeasure=1:length(FieldMapMeasures)
            DirFile=dir([InDir,filesep,SubID{i},filesep,'fmap',filesep,'*',SubID{i},'*',lower(FieldMapMeasures{iFieldMapMeasure}),'*.nii']);
            if ~isempty(DirFile)
                mkdir([OutDir,filesep,'FieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},'Img',filesep,SubID{i}]);
                copyfile([InDir,filesep,SubID{i},filesep,'fmap',filesep,DirFile(1).name],[OutDir,filesep,'FieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},'Img',filesep,SubID{i}])
                DirFile=dir([InDir,filesep,SubID{i},filesep,'fmap',filesep,'*',SubID{i},'*',lower(FieldMapMeasures{iFieldMapMeasure}),'*.json']);
                copyfile([InDir,filesep,SubID{i},filesep,'fmap',filesep,DirFile(1).name],[OutDir,filesep,'FieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},'Img',filesep,SubID{i}])
            end
        end
        
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
        DirFile=dir([InDir,filesep,SubID{i},filesep,DirSessions(1).name,filesep,'anat',filesep,SubID{i},'*_T1w.nii*']);
        copyfile([InDir,filesep,SubID{i},filesep,DirSessions(1).name,filesep,'anat',filesep,DirFile(1).name],[OutDir,filesep,'T1Img',filesep,SubID{i},filesep]);
    end
    
    for iFunSession=1:FunctionalSessionNumber
        mkdir([OutDir,filesep,FunSessionPrefixSet{iFunSession},'FunImg']);
        for i=1:length(SubID)
            mkdir([OutDir,filesep,FunSessionPrefixSet{iFunSession},'FunImg',filesep,SubID{i},filesep]);
            DirFile=dir([InDir,filesep,SubID{i},filesep,DirSessions(iFunSession).name,filesep,'func',filesep,'*.nii*']);
            copyfile([InDir,filesep,SubID{i},filesep,DirSessions(iFunSession).name,filesep,'func',filesep,DirFile(1).name],[OutDir,filesep,FunSessionPrefixSet{iFunSession},'FunImg',filesep,SubID{i},filesep]);
            DirFile=dir([InDir,filesep,SubID{i},filesep,DirSessions(iFunSession).name,filesep,'func',filesep,'*.json']);
            copyfile([InDir,filesep,SubID{i},filesep,DirSessions(iFunSession).name,filesep,'func',filesep,DirFile(1).name],[OutDir,filesep,FunSessionPrefixSet{iFunSession},'FunImg',filesep,SubID{i},filesep]);
        end
    end

    %Dealing with FieldMap data
    FieldMapMeasures={'PhaseDiff','Magnitude1','Magnitude2','Phase1','Phase2'};
    for iFieldMapMeasure=1:length(FieldMapMeasures)
        DirFile=dir([InDir,filesep,SubID{i},filesep,DirSessions(1).name,filesep,'fmap',filesep,'*',SubID{i},'*',lower(FieldMapMeasures{iFieldMapMeasure}),'*.nii']);
        if ~isempty(DirFile)
            mkdir([OutDir,filesep,'FieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},'Img',filesep,SubID{i}]);
            copyfile([InDir,filesep,SubID{i},filesep,DirSessions(1).name,filesep,'fmap',filesep,DirFile(1).name],[OutDir,filesep,'FieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},'Img',filesep,SubID{i}])
            DirFile=dir([InDir,filesep,SubID{i},filesep,DirSessions(1).name,filesep,'fmap',filesep,'*',SubID{i},'*',lower(FieldMapMeasures{iFieldMapMeasure}),'*.json']);
            copyfile([InDir,filesep,SubID{i},filesep,DirSessions(1).name,filesep,'fmap',filesep,DirFile(1).name],[OutDir,filesep,'FieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},'Img',filesep,SubID{i}])
        end
    end
    
end








