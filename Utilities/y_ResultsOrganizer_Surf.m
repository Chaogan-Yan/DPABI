function y_ResultsOrganizer_Surf(WorkingDir,SubjectID,OutputDir)
% FORMAT y_ResultsOrganizer_Surf(WorkingDir,SubjectID,OutputDir)
% Input:
%   WorkingDir - the directory contains processed data
%   SubjectID - the list of subject IDs for organize. n by 1 cell
%   OutputDir - the directory for saving results
% Output:
%   The organized results.
%-----------------------------------------------------------
% Written by YAN Chao-Gan 190710.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com
% Revised by YAN Chao-Gan, 161004. Change parfor for gzipping each .nii file to parfor for each subject.

%Organize Results
copyfile([WorkingDir,filesep,'Results'],[OutputDir,filesep,'Results']);
DirSessionResults = dir([WorkingDir,filesep,'S*_Results']);
for iSession=1:length(DirSessionResults)
    copyfile([WorkingDir,filesep,DirSessionResults(iSession).name],[OutputDir,filesep,DirSessionResults(iSession).name]);
end

%Organize Masks
if exist([WorkingDir,filesep,'Masks'])
    copyfile([WorkingDir,filesep,'Masks'],[OutputDir,filesep,'Masks']);
end

%Organize Realign Parameters
if exist([WorkingDir,filesep,'RealignParameter'])
    copyfile([WorkingDir,filesep,'RealignParameter'],[OutputDir,filesep,'RealignParameter']);
end

%Organize QC Results
fprintf('\n\tOrganizing QC Results.\n')
mkdir([OutputDir,filesep,'QC',filesep,'QC_fmriprep'])
for iSub=1:length(SubjectID)
    mkdir([OutputDir,filesep,'QC',filesep,'QC_fmriprep',filesep,SubjectID{iSub}]);
    copyfile([WorkingDir,filesep,'fmriprep',filesep,SubjectID{iSub},'.html'],[OutputDir,filesep,'QC',filesep,'QC_fmriprep']);
    copyfile([WorkingDir,filesep,'fmriprep',filesep,SubjectID{iSub},filesep,'figures'],[OutputDir,filesep,'QC',filesep,'QC_fmriprep',filesep,SubjectID{iSub},filesep,'figures']);
end


%Organize stats of freesurfer
fprintf('\n\tOrganizing stats results of freesurfer.\n')
mkdir([OutputDir,filesep,'QC',filesep,'Stats_freesurfer'])
for iSub=1:length(SubjectID)
    mkdir([OutputDir,filesep,'QC',filesep,'Stats_freesurfer',filesep,SubjectID{iSub}]);
    copyfile([WorkingDir,filesep,'freesurfer',filesep,SubjectID{iSub},filesep,'stats'],[OutputDir,filesep,'QC',filesep,'Stats_freesurfer',filesep,SubjectID{iSub},filesep,'stats']);
end

fprintf('\n\tResults Organizing Finished.\n')


