function y_MixedEffectsAnalysis_Image(DependentDir,BetweenSubjectFactor,WithinSubjectFactor,OutputName,MaskFile,CovariateDirs,OtherCovariates)
% y_MixedEffectsAnalysis_Image(DependentDir,BetweenSubjectFactor,WithinSubjectFactor,OutputName,MaskFile,CovariateDirs,OtherCovariates)
% Perform mixed effect analysis: one between subject factor, one within subject factor.
% Input:
%   DependentDir - dependent data: directory of 3D image data file or the filename of one 4D data file
%   BetweenSubjectFactor - between subject factor. A vector of 1s and -1s, 1 for group one, -1 for group 2. E.g., [1 1 1 1 -1 -1 -1 -1 -1 -1].
%   WithinSubjectFactor - within subject factor. A vector of 1s and -1s, 1 for condition one, -1 for condition 2. E.g., [1 -1 1 -1 1 -1 1 -1 1 -1].
%   OutputName - the output name.
%   MaskFile - the mask file.
%   CovariateDirs - the image directory (or file list) of covariate, in which the files should be correspond to the DependentDir.
%   OtherCovariates - The other covariates. 
% Output:
%   *_Group_TwoT.nii - the T values of group differences (corresponding to the first group minus the second group)
%   *_Interaction_T.nii - the T values of interaction (BetweenSubjectFactor by WithinSubjectFactor)
%___________________________________________________________________________
% Written by YAN Chao-Gan 160515.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com


if ~exit('OtherCovariates')
    OtherCovariates=[];
end
if ~exit('CovariateDirs')
    CovariateDirs=[];
end
if ~exit('MaskFile')
    MaskFile='';
end

nSub=length(WithinSubjectFactor)/2;
SubjectRegressors=[];
for i=1:nSub
    SubjectRegressors(:,i) = zeros(2*nSub,1);
    SubjectRegressors(i*2-1 : i*2,i) = 1;
end

Interaction = WithinSubjectFactor.*BetweenSubjectFactor;

AllCov = [WithinSubjectFactor,Interaction,SubjectRegressors];

if exist(OtherCovariates) && ~isempty(OtherCovariates)
    AllCov = [AllCov,OtherCovariates];
end

Contrast=zeros(1,size(AllCov,2));
Contrast(2)=1;

%[b_OLS_brain, t_OLS_brain, TF_ForContrast_brain, r_OLS_brain, Header] = y_GroupAnalysis_Image(DependentVolume,Predictor,OutputName,MaskFile,CovVolume,Contrast,TF_Flag,IsOutputResidual,Header)
[b_OLS_brain, t_OLS_brain, TF_ForContrast_brain, r_OLS_brain, Header] = y_GroupAnalysis_Image(DependentDir,AllCov,[OutputName,'_Interaction_T'],MaskFile,CovariateDirs,Contrast,'T');



% For two-sample t-test
[DependentVolume,VoxelSize,theImgFileList, Header] = y_ReadAll(DependentDir);
for i=1:nSub
    DependentVolumeSubjectMean(:,:,:,i) = (DependentVolume(:,:,:,i*2-1) + DependentVolume(:,:,:,i*2))/2;
end

if exist('CovariateDirs','var') && (~isempty(CovariateDirs))
    [CovVolume] = y_ReadAll(CovariateDirs);%YAN Chao-Gan, 160119. Fixed a bug.  %[CovVolume] = y_ReadAll(DependentVolume);
    for i=1:nSub
        CovVolumeSubjectMean(:,:,:,i) = (CovVolume(:,:,:,i*2-1) + CovVolume(:,:,:,i*2))/2;
    end
else
    CovVolumeSubjectMean=[];
end

GroupLabel=BetweenSubjectFactor;
Constant=ones(nSub,1);
AllCov=[Constant,GroupLabel];

if exist(OtherCovariates) && ~isempty(OtherCovariates)
    AllCov = [AllCov,OtherCovariates];
end

Contrast=zeros(1,size(AllCov,2));
Contrast(2)=1;

%[b_OLS_brain, t_OLS_brain, TF_ForContrast_brain, r_OLS_brain, Header] = y_GroupAnalysis_Image(DependentVolume,Predictor,OutputName,MaskFile,CovVolume,Contrast,TF_Flag,IsOutputResidual,Header)
[b_OLS_brain, t_OLS_brain, TF_ForContrast_brain, r_OLS_brain, Header] = y_GroupAnalysis_Image(DependentVolumeSubjectMean,AllCov,[OutputName,'_Group_TwoT'],MaskFile,CovVolumeSubjectMean,Contrast,'T');


