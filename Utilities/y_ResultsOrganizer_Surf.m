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
Spaces={'FunSurfLH','FunSurfRH','FunVolu'};
MeasureList = {'ALFF';'fALFF';'ReHo';'DegreeCentrality';'ROISignals'};
MeasurePrefixList = {'ALFF_';'fALFF_';'ReHo_';'DegreeCentrality_PositiveWeightedSumBrain_';'ROISignals_'};

DirSessionResults = dir([WorkingDir,filesep,'S*_Results']);
FunctionalSessionNumber=length(DirSessionResults)+1;
% Multiple Sessions Processing
FunSessionPrefixSet={''}; %The first session doesn't need a prefix. From the second session, need a prefix such as 'S2_';
for iFunSession=2:FunctionalSessionNumber
    FunSessionPrefixSet=[FunSessionPrefixSet;{['S',num2str(iFunSession),'_']}];
end

for iFunSession=1:FunctionalSessionNumber
    mkdir([OutputDir,filesep,FunSessionPrefixSet{iFunSession},'Results'])
    
    if iFunSession==1 %YAN Chao-Gan, 210219. In case there are multiple sessions. Anat is in the first session
        copyfile([WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'AnatSurfLH'],[OutputDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'AnatSurfLH']);
        copyfile([WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'AnatSurfRH'],[OutputDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'AnatSurfRH']);
        
        mkdir([OutputDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'AnatVolu'])
        copyfile([WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'AnatVolu',filesep,'*.tsv'],[OutputDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'AnatVolu']);

        parfor iSub=1:length(SubjectID)
            mkdir([OutputDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'AnatVolu',filesep,SubjectID{iSub}])
            DirFiles=dir([WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'AnatVolu',filesep,SubjectID{iSub},filesep,'*.nii']);
            for iFile=1:length(DirFiles)
                gzip([WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'AnatVolu',filesep,SubjectID{iSub},filesep,DirFiles(iFile).name],[OutputDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'AnatVolu',filesep,SubjectID{iSub}]);
            end
        end
    end
    
    for iSpace=1:length(Spaces)
        for iMeasure=1:length(MeasureList)
            fprintf('\n\tOrganizing %s Results for Space: %s.\n',MeasureList{iMeasure},Spaces{iSpace});
            
            DirList = dir([WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,Spaces{iSpace},filesep,MeasureList{iMeasure},'*']);
            for iDir = 1:length(DirList)
                mkdir([OutputDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,Spaces{iSpace},filesep,DirList(iDir).name]);
                parfor iSub=1:length(SubjectID)
                    
                    if strcmp(Spaces{iSpace},'FunVolu')
                        if iMeasure <= 3
                            gzip([WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,Spaces{iSpace},filesep,DirList(iDir).name,filesep,MeasurePrefixList{iMeasure},SubjectID{iSub},'.nii'],[OutputDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,Spaces{iSpace},filesep,DirList(iDir).name]);
                        end
                        if iMeasure == 4
                            gzip([WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,Spaces{iSpace},filesep,DirList(iDir).name,filesep,'DegreeCentrality_PositiveWeightedSumBrain_',SubjectID{iSub},'.nii'],[OutputDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,Spaces{iSpace},filesep,DirList(iDir).name]);
                            gzip([WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,Spaces{iSpace},filesep,DirList(iDir).name,filesep,'DegreeCentrality_PositiveBinarizedSumBrain_',SubjectID{iSub},'.nii'],[OutputDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,Spaces{iSpace},filesep,DirList(iDir).name]);
                        end
                        if iMeasure == 5
                            copyfile([WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,Spaces{iSpace},filesep,DirList(iDir).name,filesep,'ROI_OrderKey_',SubjectID{iSub},'.tsv'],[OutputDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,Spaces{iSpace},filesep,DirList(iDir).name]);
                        end
                    else
                        if iMeasure <= 3
                            copyfile([WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,Spaces{iSpace},filesep,DirList(iDir).name,filesep,MeasurePrefixList{iMeasure},SubjectID{iSub},'.func.gii'],[OutputDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,Spaces{iSpace},filesep,DirList(iDir).name]);
                        end
                        if iMeasure == 4
                            copyfile([WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,Spaces{iSpace},filesep,DirList(iDir).name,filesep,'DegreeCentrality_Bilateral_PositiveWeightedSumBrain_',SubjectID{iSub},'.func.gii'],[OutputDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,Spaces{iSpace},filesep,DirList(iDir).name]);
                            copyfile([WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,Spaces{iSpace},filesep,DirList(iDir).name,filesep,'DegreeCentrality_Bilateral_PositiveBinarizedSumBrain_',SubjectID{iSub},'.func.gii'],[OutputDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,Spaces{iSpace},filesep,DirList(iDir).name]);
                        end
                        if iMeasure == 5
                            copyfile([WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,Spaces{iSpace},filesep,DirList(iDir).name,filesep,'ROI_OrderKey_',SubjectID{iSub},'.tsv'],[OutputDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,Spaces{iSpace},filesep,DirList(iDir).name]);
                        end
                    end
                end
            end
        end
        
    end
    
    DirList = dir([WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'ROISignals_SurfLHSurfRHVolu_*']);
    for iDir = 1:length(DirList)
        mkdir([OutputDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,DirList(iDir).name]);
        parfor iSub=1:length(SubjectID)
            copyfile([WorkingDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,DirList(iDir).name,filesep,'ROISignals_',SubjectID{iSub},'.mat'],[OutputDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,DirList(iDir).name]);
        end
    end
end


fprintf('\n\tOrganizing files, please wait...\n');

%Organize Masks
if exist([WorkingDir,filesep,'Masks'])
    copyfile([WorkingDir,filesep,'Masks'],[OutputDir,filesep,'Masks']);
end

%Organize Realign Parameters
if exist([WorkingDir,filesep,'RealignParameter'])
    copyfile([WorkingDir,filesep,'RealignParameter'],[OutputDir,filesep,'RealignParameter']);
end

%Organize fmriprep
if exist([WorkingDir,filesep,'fmriprep'])
    copyfile([WorkingDir,filesep,'fmriprep'],[OutputDir,filesep,'fmriprep']);
end
%Delete T1 image which may have privacy information such as face
for iSub=1:length(SubjectID)
    delete([OutputDir,filesep,'fmriprep',filesep,SubjectID{iSub},filesep,'anat',filesep,'*preproc_T1w.nii.gz']);
end

%Organize freesurfer
if exist([WorkingDir,filesep,'freesurfer'])
    copyfile([WorkingDir,filesep,'freesurfer'],[OutputDir,filesep,'freesurfer']);
end
%Delete T1 image which may have privacy information such as face
for iSub=1:length(SubjectID)
    status = rmdir([OutputDir,filesep,'freesurfer',filesep,SubjectID{iSub},filesep,'mri',filesep,'orig'],'s');
    delete([OutputDir,filesep,'freesurfer',filesep,SubjectID{iSub},filesep,'mri',filesep,'orig*']);
    delete([OutputDir,filesep,'freesurfer',filesep,SubjectID{iSub},filesep,'mri',filesep,'nu.mgz']);
    delete([OutputDir,filesep,'freesurfer',filesep,SubjectID{iSub},filesep,'mri',filesep,'rawavg.mgz']);
    delete([OutputDir,filesep,'freesurfer',filesep,SubjectID{iSub},filesep,'mri',filesep,'T1.mgz']);
end

%Back up DPABISurf .mat files
copyfile([WorkingDir,filesep,'*.mat'],[OutputDir]);

fprintf('\n\tResults Organizing Finished.\n')


