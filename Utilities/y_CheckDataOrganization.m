function [CheckingPass]=y_CheckDataOrganization(WorkingDir,StartingDirName)
% FORMAT [CheckingPass]=y_CheckDataOrganization(WorkingDir,StartingDirName)
%   WorkingDir - Define the working directory
%   StartingDirName (optional) - Define the StartingDirName
% Output:
%   CheckingPass - if passed checking
%___________________________________________________________________________
% Written by YAN Chao-Gan 200219.
% The R-fMRI Lab, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% International Big-Data Center for Depression Research, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com

CheckingPass=0;

if ~exist('WorkingDir','var') || isempty(WorkingDir)
    WorkingDir = uigetdir(pwd,'Please select the working dir...');
end

if ~exist('StartingDirName','var') || isempty(StartingDirName)
    if exist(fullfile(WorkingDir,'FunRaw'))
        StartingDirName = 'FunRaw';
    elseif exist(fullfile(WorkingDir,'FunImg'))
        StartingDirName = 'FunImg';
    else
        error('There is no FunRaw or FunImg dir under the working dir: %s!',WorkingDir);
    end
end

if ~exist(fullfile(WorkingDir,StartingDirName))
    error('There is no such dir: %s!',fullfile(WorkingDir,StartingDirName));
end


DirSessions=dir([WorkingDir,filesep,'S*_',StartingDirName]);
FunctionalSessionNumber=length(DirSessions)+1;

FunSessionPrefixSet={''}; %The first session doesn't need a prefix. From the second session, need a prefix such as 'S2_';
for iFunSession=2:FunctionalSessionNumber
    FunSessionPrefixSet=[FunSessionPrefixSet;{['S',num2str(iFunSession),'_']}];
end

%Get subject list
SubjectID=[];
Dir=dir([WorkingDir,filesep,StartingDirName]);
for i=3:length(Dir)
    if Dir(i).isdir
        SubjectID=[SubjectID;{Dir(i).name}];
    end
end
SubjectNum=length(SubjectID);
if SubjectNum==0
    error('There is no subjects under dir: %s!',[WorkingDir,filesep,StartingDirName]);
end

for iFunSession=1:FunctionalSessionNumber
    for i=1:SubjectNum
        if ~exist([WorkingDir,filesep,FunSessionPrefixSet{iFunSession},StartingDirName,filesep,SubjectID{i}])
            error('There is no such dir: %s!',[WorkingDir,filesep,FunSessionPrefixSet{iFunSession},StartingDirName,filesep,SubjectID{i}]);
        else
            DirFile=dir([WorkingDir,filesep,FunSessionPrefixSet{iFunSession},StartingDirName,filesep,SubjectID{i},filesep,'*']);
            if (length(DirFile) >=3) && strcmpi(DirFile(3).name,'.DS_Store')
                MinimumFile=3;
            else
                MinimumFile=2;
            end
            if length(DirFile)<=MinimumFile
                error('There are no image files under dir: %s!',[WorkingDir,filesep,FunSessionPrefixSet{iFunSession},StartingDirName,filesep,SubjectID{i}]);
            end
        end
    end
end

%Then check T1
if strcmpi(StartingDirName, 'FunRaw')
    StartingDirName_T1='T1Raw';
else
    StartingDirName_T1='T1Img';
end

if ~exist(fullfile(WorkingDir,StartingDirName_T1))
    button = questdlg(['No T1 image is found (i.e., ',fullfile(WorkingDir,StartingDirName_T1),'). Do you want to process without T1 image?'],'No T1 image is found','Yes','No','Yes');
    if strcmpi(button,'No')
        error('There is no such dir: %s!',fullfile(WorkingDir,StartingDirName_T1));
    end
else
    for i=1:SubjectNum
        if ~exist([WorkingDir,filesep,StartingDirName_T1,filesep,SubjectID{i}])
            error('There is no such dir: %s!',[WorkingDir,filesep,StartingDirName_T1,filesep,SubjectID{i}]);
        else
            DirFile=dir([WorkingDir,filesep,StartingDirName_T1,filesep,SubjectID{i},filesep,'*']);
            if (length(DirFile) >=3) && strcmpi(DirFile(3).name,'.DS_Store')
                MinimumFile=3;
            else
                MinimumFile=2;
            end
            if length(DirFile)<=MinimumFile
                error('There are no image files under dir: %s!',[WorkingDir,filesep,StartingDirName_T1,filesep,SubjectID{i}]);
            end
        end
    end
end


%Then check Dwi
if strcmpi(StartingDirName, 'FunRaw')
    StartingDirName_Dwi='DwiRaw';
else
    StartingDirName_Dwi='DwiImg';
end
if exist(fullfile(WorkingDir,StartingDirName_Dwi))
    for i=1:SubjectNum
        if ~exist([WorkingDir,filesep,StartingDirName_Dwi,filesep,SubjectID{i}])
            error('There is no such dir: %s!',[WorkingDir,filesep,StartingDirName_Dwi,filesep,SubjectID{i}]);
        else
            DirFile=dir([WorkingDir,filesep,StartingDirName_Dwi,filesep,SubjectID{i},filesep,'*']);
            if (length(DirFile) >=3) && strcmpi(DirFile(3).name,'.DS_Store')
                MinimumFile=3;
            else
                MinimumFile=2;
            end
            if length(DirFile)<=MinimumFile
                error('There are no image files under dir: %s!',[WorkingDir,filesep,StartingDirName_Dwi,filesep,SubjectID{i}]);
            end
        end
    end
end


%Then check FieldMap
if exist([WorkingDir,filesep,'FieldMap'])
    if strcmpi(StartingDirName, 'FunRaw')
        Suffix='Raw';
    else
        Suffix='Img';
    end

    if exist([WorkingDir,filesep,'FieldMap',filesep,'Magnitude1',Suffix]) && (exist([WorkingDir,filesep,'FieldMap',filesep,'PhaseDiff',Suffix]) || (exist([WorkingDir,filesep,'FieldMap',filesep,'Phase1',Suffix]) && exist([WorkingDir,filesep,'FieldMap',filesep,'Phase2',Suffix])))
        FieldMapMeasures={'PhaseDiff','Magnitude1','Magnitude2','Phase1','Phase2'};
         for iFieldMapMeasure=1:length(FieldMapMeasures)
             if exist([WorkingDir,filesep,'FieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},Suffix])
                 for i=1:SubjectNum
                     if ~exist([WorkingDir,filesep,'FieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},Suffix,filesep,SubjectID{i}])
                         error('There is no such dir: %s!',[WorkingDir,filesep,'FieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},Suffix,filesep,SubjectID{i}]);
                     else
                         DirFile=dir([WorkingDir,filesep,'FieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},Suffix,filesep,SubjectID{i},filesep,'*']);
                         if (length(DirFile) >=3) && strcmpi(DirFile(3).name,'.DS_Store')
                             MinimumFile=3;
                         else
                             MinimumFile=2;
                         end
                         if length(DirFile)<=MinimumFile
                             error('There are no image files under dir: %s!',[WorkingDir,filesep,'FieldMap',filesep,FieldMapMeasures{iFieldMapMeasure},Suffix,filesep,SubjectID{i}]);
                         end
                     end
                 end
             end
         end
    else
        error('If you want to perform fieldmap correction, at least you should have: \n%s && %s \n OR \n%s && %s && %s!',[WorkingDir,filesep,'FieldMap',filesep,'Magnitude1',Suffix],[WorkingDir,filesep,'FieldMap',filesep,'PhaseDiff',Suffix],[WorkingDir,filesep,'FieldMap',filesep,'Magnitude1',Suffix],[WorkingDir,filesep,'FieldMap',filesep,'Phase1',Suffix],[WorkingDir,filesep,'FieldMap',filesep,'Phase2',Suffix]);
    end
end

CheckingPass=1;

fprintf(['\nCongratulations, data organization checking passed!!! Now please go ahead to DPARSFA or DPABISurf! :)\n\n']);


