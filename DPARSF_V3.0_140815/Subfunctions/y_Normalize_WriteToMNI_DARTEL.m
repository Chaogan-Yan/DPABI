
function y_Normalize_WriteToMNI_DARTEL(SubjectID,SourceDir,OutpurDir,T1ImgNewSegmentDir,DARTELTemplateFile,IsSubDirectory,BoundingBox,VoxSize)
% FORMAT y_Normalize_WriteToMNI_DARTEL(SubjectID,SourceDir,OutpurDir,T1ImgNewSegmentDir,DARTELTemplateFile,IsSubDirectory,BoundingBox,VoxSize)
%   SubjectID   -  The ID (or name) for a subject want to be normalized
%   SourceDir   -  The directory stores the files want to be normalized. 
%                  If IsSubDirectory == 1: Data should be SourceDir/SubjectID/*.img (or *.nii)
%                  If IsSubDirectory == 0: Data should be SourceDir/*SubjectID*.img (or *SubjectID*.nii)
%   OutpurDir   -  The output directory
%   T1ImgNewSegmentDir - The directory of T1ImgNewSegment (by DPARSF), under which stored each subject's flow field: /SubjectID/u_*
%   DARTELTemplateFile - The DARTEL Template file (usually Template_6.nii) which is stored in the first subject's T1ImgNewSegment directory
%   IsSubDirectory  - 1. The files are stored in subdirectorys (SubjectID) under SourceDir (default)
%                     2. The files are stored in SourceDir directly with SubjectID as part of file name
%   BoundingBox     - The Bounding Box after normalization. default: [-90 -126 -72;90 90 108];
%   VoxSize         - The VoxSize after normalization. default: [3 3 3];
%__________________________________________________________________________
% Written by YAN Chao-Gan 120328 for DPARSF.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com


if ~exist('IsSubDirectory','var')
    IsSubDirectory = 1;
end
if ~exist('BoundingBox','var')
    BoundingBox=[-90 -126 -72;90 90 108];
end
if ~exist('VoxSize','var')
    VoxSize=[3 3 3];
end

[ProgramPath, fileN, extn] = fileparts(which('DPARSFA_run.m'));
addpath([ProgramPath,filesep,'Subfunctions']);


SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Dartel_NormaliseToMNI_FewSubjects.mat']);

SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.fwhm=[0 0 0];
SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.preserve=0;
SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.bb=BoundingBox;
SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.vox=VoxSize;

SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.template={DARTELTemplateFile};

DirImg=dir([T1ImgNewSegmentDir,filesep,SubjectID,filesep,'u_*']);
SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subj(1,1).flowfield={[T1ImgNewSegmentDir,filesep,SubjectID,filesep,DirImg(1).name]};

if IsSubDirectory ==1
    DirImg=dir([SourceDir,filesep,SubjectID,filesep,'*.img']);
    if isempty(DirImg)
        DirImg=dir([SourceDir,filesep,SubjectID,filesep,'*.nii']);
    end
    FileList=[];
    for j=1:length(DirImg)
        FileList=[FileList;{[SourceDir,filesep,SubjectID,filesep,DirImg(j).name]}];
    end
else
    DirImg=dir([SourceDir,filesep,'*',SubjectID,'*.img']);
    if isempty(DirImg)
        DirImg=dir([SourceDir,filesep,'*',SubjectID,'*.nii']);
    end
    FileList=[];
    for j=1:length(DirImg)
        FileList=[FileList;{[SourceDir,filesep,DirImg(j).name]}];
    end
end

SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subj(1,1).images=FileList;

spm_jobman('run',SPMJOB.matlabbatch);


if IsSubDirectory ==1
    [SUCCESS,MESSAGE,MESSAGEID] = mkdir([OutpurDir,filesep,SubjectID]);
    movefile([SourceDir,filesep,SubjectID,filesep,'w*'],[OutpurDir,filesep,SubjectID]);

else
    [SUCCESS,MESSAGE,MESSAGEID] = mkdir([OutpurDir]);
    movefile([SourceDir,filesep,'w*',SubjectID,'*'],[OutpurDir]);

end

fprintf(['Normalization by using DARTEL: ',SubjectID,' OK.\n']);



