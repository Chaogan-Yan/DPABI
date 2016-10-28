function y_IntermediateFilesOrganizer(WorkingDir,SubjectID,OutputDir)
% FORMAT y_IntermediateFilesOrganizer(WorkingDir,SubjectID,OutputDir)
% Input:
%   WorkingDir - the directory contains processed data
%   SubjectID - the list of subject IDs for organize. n by 1 cell
%   OutputDir - the directory for saving Intermediate Files.
% Output:
%   The organized Intermediate Files, for re-process with DPABI.
%-----------------------------------------------------------
% Written by YAN Chao-Gan 151129.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com
% Revised by YAN Chao-Gan, 161004. Change parfor for gzipping each .nii file to parfor for each subject.



%Organize FunImgAR
FunImgARName='';
if (7==exist([WorkingDir,filesep,'FunImgAR',filesep,SubjectID{1}],'dir'))
    FunImgARName = 'FunImgAR';
elseif (7==exist([WorkingDir,filesep,'FunImgR',filesep,SubjectID{1}],'dir'))
    FunImgARName = 'FunImgR';
end
if ~isempty(FunImgARName)
    if (7==exist([WorkingDir,filesep,FunImgARName,filesep,SubjectID{1}],'dir'))
        fprintf('\n\tOrganizing %s.\n',FunImgARName)
        mkdir([OutputDir,filesep,FunImgARName])
        copyfile([WorkingDir,filesep,FunImgARName],[OutputDir,filesep,FunImgARName]);

%         DirNii=y_rdir([OutputDir,filesep,FunImgARName,filesep,'**',filesep,'*.nii']);
%         parfor i=1:length(DirNii)
%             gzip(DirNii(i).name);
%             delete(DirNii(i).name);
%         end
        parfor iSub=1:length(SubjectID) %YAN Chao-Gan, 161004. Change parfor for gzipping each .nii file to parfor for each subject.
            DirNii=dir([OutputDir,filesep,FunImgARName,filesep,SubjectID{iSub},filesep,'*.nii']);
            for i=1:length(DirNii)
                gzip([OutputDir,filesep,FunImgARName,filesep,SubjectID{iSub},filesep,DirNii(i).name]);
                delete([OutputDir,filesep,FunImgARName,filesep,SubjectID{iSub},filesep,DirNii(i).name]);
            end
        end
    end
end

DirSessionResults = dir([WorkingDir,filesep,'S*_',FunImgARName]);
for iSession=1:length(DirSessionResults)
    if (7==exist([WorkingDir,filesep,DirSessionResults(iSession).name,filesep,SubjectID{1}],'dir'))
        fprintf('\n\tOrganizing %s.\n',DirSessionResults(iSession).name)
        mkdir([OutputDir,filesep,DirSessionResults(iSession).name])
        copyfile([WorkingDir,filesep,DirSessionResults(iSession).name],[OutputDir,filesep,DirSessionResults(iSession).name]);
        
%         DirNii=y_rdir([OutputDir,filesep,DirSessionResults(iSession).name,filesep,'**',filesep,'*.nii']);
%         parfor i=1:length(DirNii)
%             gzip(DirNii(i).name);
%             delete(DirNii(i).name);
%         end
        parfor iSub=1:length(SubjectID) %YAN Chao-Gan, 161004. Change parfor for gzipping each .nii file to parfor for each subject.
            DirNii=dir([OutputDir,filesep,DirSessionResults(iSession).name,filesep,SubjectID{iSub},filesep,'*.nii']);
            for i=1:length(DirNii)
                gzip([OutputDir,filesep,DirSessionResults(iSession).name,filesep,SubjectID{iSub},filesep,DirNii(i).name]);
                delete([OutputDir,filesep,DirSessionResults(iSession).name,filesep,SubjectID{iSub},filesep,DirNii(i).name]);
            end
        end

    end
end



%Organize Segmentation Results
T1ImgSegmentDirectoryName='';
if (7==exist([WorkingDir,filesep,'T1ImgSegment',filesep,SubjectID{1}],'dir'))
    T1ImgSegmentDirectoryName = 'T1ImgSegment';
elseif (7==exist([WorkingDir,filesep,'T1ImgNewSegment',filesep,SubjectID{1}],'dir'))
    T1ImgSegmentDirectoryName = 'T1ImgNewSegment';
end
if ~isempty(T1ImgSegmentDirectoryName)
    fprintf('\n\tOrganizing %s.\n',T1ImgSegmentDirectoryName)
    mkdir([OutputDir,filesep,T1ImgSegmentDirectoryName])
    copyfile([WorkingDir,filesep,T1ImgSegmentDirectoryName],[OutputDir,filesep,T1ImgSegmentDirectoryName]);
    
%     DirNii=y_rdir([OutputDir,filesep,T1ImgSegmentDirectoryName,filesep,'**',filesep,'*.nii']);
%     parfor i=1:length(DirNii)
%         gzip(DirNii(i).name);
%         delete(DirNii(i).name);
%     end
    parfor iSub=1:length(SubjectID) %YAN Chao-Gan, 161004. Change parfor for gzipping each .nii file to parfor for each subject.
        DirNii=dir([OutputDir,filesep,T1ImgSegmentDirectoryName,filesep,SubjectID{iSub},filesep,'*.nii']);
        for i=1:length(DirNii)
            gzip([OutputDir,filesep,T1ImgSegmentDirectoryName,filesep,SubjectID{iSub},filesep,DirNii(i).name]);
            delete([OutputDir,filesep,T1ImgSegmentDirectoryName,filesep,SubjectID{iSub},filesep,DirNii(i).name]);
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

%Organize Masks
if exist([WorkingDir,filesep,'Masks'])
    fprintf('\n\tOrganizing Masks.\n')
    mkdir([OutputDir,filesep,'Masks'])
    copyfile([WorkingDir,filesep,'Masks'],[OutputDir,filesep,'Masks']);
end

if exist([WorkingDir,filesep,'TRInfo.tsv'])
    copyfile([WorkingDir,filesep,'TRInfo.tsv'],OutputDir)
end


fprintf('\n\tIntermediate Files Organizing Finished.\n')


