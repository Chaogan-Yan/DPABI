function y_ResultsOrganizer(WorkingDir,SubjectID,OutputDir)
% FORMAT y_ResultsOrganizer(WorkingDir,SubjectID,OutputDir)
% Input:
%   WorkingDir - the directory contains processed data
%   SubjectID - the list of subject IDs for organize. n by 1 cell
%   OutputDir - the directory for saving results
% Output:
%   The organized results.
%-----------------------------------------------------------
% Written by YAN Chao-Gan 151127.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com
% Revised by YAN Chao-Gan, 161004. Change parfor for gzipping each .nii file to parfor for each subject.



%Organize functional Results
MeasureList = {'ALFF';'fALFF';'ReHo';'VMHC';'DegreeCentrality';'ROISignals'};
MeasurePrefixList = {'ALFFMap_';'fALFFMap_';'ReHoMap_';'zVMHCMap_';'DegreeCentrality_PositiveWeightedSumBrainMap_';'ROISignals_'};

for iMeasure=1:length(MeasureList)
    fprintf('\n\tOrganizing %s Results.\n',MeasureList{iMeasure});
    DirList = dir([WorkingDir,filesep,'Results',filesep,MeasureList{iMeasure},'*']);
    for iDir = 1:length(DirList)
        mkdir([OutputDir,filesep,'Results',filesep,DirList(iDir).name]);
        parfor iSub=1:length(SubjectID)
            if iMeasure <= 4
                %copyfile([WorkingDir,filesep,'Results',filesep,DirList(iDir).name,filesep,MeasurePrefixList{iMeasure},SubjectID{iSub},'.nii'],[OutputDir,filesep,'Results',filesep,DirList(iDir).name]);
                gzip([WorkingDir,filesep,'Results',filesep,DirList(iDir).name,filesep,MeasurePrefixList{iMeasure},SubjectID{iSub},'.nii'],[OutputDir,filesep,'Results',filesep,DirList(iDir).name]);
            end
            if iMeasure == 5
                gzip([WorkingDir,filesep,'Results',filesep,DirList(iDir).name,filesep,'DegreeCentrality_PositiveWeightedSumBrainMap_',SubjectID{iSub},'.nii'],[OutputDir,filesep,'Results',filesep,DirList(iDir).name]);
                gzip([WorkingDir,filesep,'Results',filesep,DirList(iDir).name,filesep,'DegreeCentrality_PositiveBinarizedSumBrainMap_',SubjectID{iSub},'.nii'],[OutputDir,filesep,'Results',filesep,DirList(iDir).name]);
            end
            if iMeasure == 6
                copyfile([WorkingDir,filesep,'Results',filesep,DirList(iDir).name,filesep,MeasurePrefixList{iMeasure},SubjectID{iSub},'.mat'],[OutputDir,filesep,'Results',filesep,DirList(iDir).name]);
                %copyfile([WorkingDir,filesep,'Results',filesep,DirList(iDir).name,filesep,MeasurePrefixList{iMeasure},SubjectID{iSub},'.txt'],[OutputDir,filesep,'Results',filesep,DirList(iDir).name]);
            end
        end
    end
end

DirSessionResults = dir([WorkingDir,filesep,'S*_Results']);

for iSession=1:length(DirSessionResults)
    for iMeasure=1:length(MeasureList)
        fprintf('\n\tOrganizing %s Results.\n',MeasureList{iMeasure});
        DirList = dir([WorkingDir,filesep,DirSessionResults(iSession).name,filesep,MeasureList{iMeasure},'*']);
        for iDir = 1:length(DirList)
            mkdir([OutputDir,filesep,DirSessionResults(iSession).name,filesep,DirList(iDir).name]);
            parfor iSub=1:length(SubjectID)
                if iMeasure <= 4
                    gzip([WorkingDir,filesep,DirSessionResults(iSession).name,filesep,DirList(iDir).name,filesep,MeasurePrefixList{iMeasure},SubjectID{iSub},'.nii'],[OutputDir,filesep,DirSessionResults(iSession).name,filesep,DirList(iDir).name]);
                end
                if iMeasure == 5
                    gzip([WorkingDir,filesep,DirSessionResults(iSession).name,filesep,DirList(iDir).name,filesep,'DegreeCentrality_PositiveWeightedSumBrainMap_',SubjectID{iSub},'.nii'],[OutputDir,filesep,DirSessionResults(iSession).name,filesep,DirList(iDir).name]);
                    gzip([WorkingDir,filesep,DirSessionResults(iSession).name,filesep,DirList(iDir).name,filesep,'DegreeCentrality_PositiveBinarizedSumBrainMap_',SubjectID{iSub},'.nii'],[OutputDir,filesep,DirSessionResults(iSession).name,filesep,DirList(iDir).name]);
                end
                if iMeasure == 6
                    copyfile([WorkingDir,filesep,DirSessionResults(iSession).name,filesep,DirList(iDir).name,filesep,MeasurePrefixList{iMeasure},SubjectID{iSub},'.mat'],[OutputDir,filesep,DirSessionResults(iSession).name,filesep,DirList(iDir).name]);
                    %copyfile([WorkingDir,filesep,DirSessionResults(iSession).name,filesep,DirList(iDir).name,filesep,MeasurePrefixList{iMeasure},SubjectID{iSub},'.txt'],[OutputDir,filesep,DirSessionResults(iSession).name,filesep,DirList(iDir).name]);
                end
            end
        end
    end
    
end


%Organize VBM Results
T1ImgSegmentDirectoryName='';
if (7==exist([WorkingDir,filesep,'T1ImgSegment',filesep,SubjectID{1}],'dir'))
    T1ImgSegmentDirectoryName = 'T1ImgSegment';
elseif (7==exist([WorkingDir,filesep,'T1ImgNewSegment',filesep,SubjectID{1}],'dir'))
    T1ImgSegmentDirectoryName = 'T1ImgNewSegment';
end
if ~isempty(T1ImgSegmentDirectoryName)
    mkdir([OutputDir,filesep,'VBM',filesep,'c1']);
    mkdir([OutputDir,filesep,'VBM',filesep,'c2']);
    mkdir([OutputDir,filesep,'VBM',filesep,'c3']);
    mkdir([OutputDir,filesep,'VBM',filesep,'wc1']);
    mkdir([OutputDir,filesep,'VBM',filesep,'wc2']);
    mkdir([OutputDir,filesep,'VBM',filesep,'wc3']);
    mkdir([OutputDir,filesep,'VBM',filesep,'mwc1']);
    mkdir([OutputDir,filesep,'VBM',filesep,'mwc2']);
    mkdir([OutputDir,filesep,'VBM',filesep,'mwc3']);
    mkdir([OutputDir,filesep,'VBM',filesep,'u_rc1']);
    PrefixSet={'c1';'c2';'c3';'wc1';'wc2';'wc3';'mwc1';'mwc2';'mwc3';'u_rc1'};
    for iMeasure=1:length(PrefixSet)
        fprintf('\n\tOrganizing %s Results.\n',PrefixSet{iMeasure});
        parfor iSub=1:length(SubjectID)
            DirList=dir([WorkingDir,filesep,T1ImgSegmentDirectoryName,filesep,SubjectID{iSub},filesep,PrefixSet{iMeasure},'*']);
            for iFile=1:length(DirList)
                copyfile([WorkingDir,filesep,T1ImgSegmentDirectoryName,filesep,SubjectID{iSub},filesep,DirList(iFile).name],[OutputDir,filesep,'VBM',filesep,PrefixSet{iMeasure},filesep,SubjectID{iSub},'_',DirList(iFile).name]);
                gzip([OutputDir,filesep,'VBM',filesep,PrefixSet{iMeasure},filesep,SubjectID{iSub},'_',DirList(iFile).name]);
                delete([OutputDir,filesep,'VBM',filesep,PrefixSet{iMeasure},filesep,SubjectID{iSub},'_',DirList(iFile).name]);
            end
        end
    end
    copyfile([WorkingDir,filesep,T1ImgSegmentDirectoryName,filesep,SubjectID{1},filesep,'Template_6_2mni.mat'],[OutputDir,filesep,'VBM']);
    gzip([WorkingDir,filesep,T1ImgSegmentDirectoryName,filesep,SubjectID{1},filesep,'Template_6.nii'],[OutputDir,filesep,'VBM']);
end


%Organize Masks
if exist([WorkingDir,filesep,'Masks'])
    fprintf('\n\tOrganizing Masks.\n')
    mkdir([OutputDir,filesep,'Masks'])
    copyfile([WorkingDir,filesep,'Masks'],[OutputDir,filesep,'Masks']);
%     DirNii=y_rdir([OutputDir,filesep,'Masks',filesep,'**',filesep,'*.nii']);
%     parfor i=1:length(DirNii)
%         gzip(DirNii(i).name);
%         delete(DirNii(i).name);
%     end
    parfor iSub=1:length(SubjectID) %YAN Chao-Gan, 161004. Change parfor for gzipping each .nii file to parfor for each subject.
        DirNii=dir([OutputDir,filesep,'Masks',filesep,'*',SubjectID{iSub},'*.nii']);
        for i=1:length(DirNii)
            gzip([OutputDir,filesep,'Masks',filesep,DirNii(i).name]);
            delete([OutputDir,filesep,'Masks',filesep,DirNii(i).name]);
        end
    end
    MaskDirs = dir([OutputDir,filesep,'Masks',filesep,'*Masks']);
    for iMaskDirs = 1:length(MaskDirs)
        parfor iSub=1:length(SubjectID)
            DirNii=dir([OutputDir,filesep,'Masks',filesep,MaskDirs(iMaskDirs).name,filesep,'*',SubjectID{iSub},'*.nii']);
            for i=1:length(DirNii)
                gzip([OutputDir,filesep,'Masks',filesep,MaskDirs(iMaskDirs).name,filesep,DirNii(i).name]);
                delete([OutputDir,filesep,'Masks',filesep,MaskDirs(iMaskDirs).name,filesep,DirNii(i).name]);
            end
        end
    end
end

%Organize Realign Parameters
if exist([WorkingDir,filesep,'RealignParameter'])
    fprintf('\n\tOrganizing Realign Parameters.\n')
    mkdir([OutputDir,filesep,'RealignParameter'])
    copyfile([WorkingDir,filesep,'RealignParameter'],[OutputDir,filesep,'RealignParameter']);
%     DirNii=y_rdir([OutputDir,filesep,'RealignParameter',filesep,'**',filesep,'*.nii']);
%     parfor i=1:length(DirNii)
%         gzip(DirNii(i).name);
%         delete(DirNii(i).name);
%     end
    parfor iSub=1:length(SubjectID) %YAN Chao-Gan, 161004. Change parfor for gzipping each .nii file to parfor for each subject.
        DirNii=dir([OutputDir,filesep,'RealignParameter',filesep,SubjectID{iSub},filesep,'*.nii']);
        for i=1:length(DirNii)
            gzip([OutputDir,filesep,'RealignParameter',filesep,SubjectID{iSub},filesep,DirNii(i).name]);
            delete([OutputDir,filesep,'RealignParameter',filesep,SubjectID{iSub},filesep,DirNii(i).name]);
        end
    end
end

%Organize Reorient Matrices
if exist([WorkingDir,filesep,'ReorientMats'])
    fprintf('\n\tOrganizing Reorient Matrices.\n')
    mkdir([OutputDir,filesep,'ReorientMats'])
    copyfile([WorkingDir,filesep,'ReorientMats'],[OutputDir,filesep,'ReorientMats']);
end

%Organize QC Results
if exist([WorkingDir,filesep,'QC'])
    fprintf('\n\tOrganizing QC Results.\n')
    mkdir([OutputDir,filesep,'QC'])
    copyfile([WorkingDir,filesep,'QC'],[OutputDir,filesep,'QC']);
end

%Organize Pictures For Check Normalization
if exist([WorkingDir,filesep,'PicturesForChkNormalization'])
    fprintf('\n\tOrganizing Pictures For Check Normalization.\n')
    mkdir([OutputDir,filesep,'PicturesForChkNormalization'])
    copyfile([WorkingDir,filesep,'PicturesForChkNormalization'],[OutputDir,filesep,'PicturesForChkNormalization']);
end

fprintf('\n\tResults Organizing Finished.\n')


