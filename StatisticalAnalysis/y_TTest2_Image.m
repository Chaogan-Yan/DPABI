function [TTest2_T,Header] = y_TTest2_Image(DependentDirs,OutputName,MaskFile,CovariateDirs,OtherCovariates)
% [TTest2_T,Header] = y_TTest2_Image(DependentDirs,OutputName,MaskFile,CovariateDirs,OtherCovariates)
% Perform two sample t test with or without covariates.
% Input:
%   DependentDirs - the image directory of dependent variable, each directory indicate a group. The T is corresponding to the first group minus the second group. 2 by 1 cell
%   OutputName - the output name.
%   MaskFile - the mask file.
%   CovariateDirs - the image directory of covariates, in which the files should be correspond to the DependentDirs. 2 by 1 cell
%   OtherCovariates - The other covariates. 2 by 1 cell 
% Output:
%   TTest2_T - the T value (corresponding to the first group minus the second group), also write image file out indicated by OutputName
%___________________________________________________________________________
% Written by YAN Chao-Gan 100317.
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
% Core function re-written by YAN Chao-Gan 140225.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com


if nargin<=4
    OtherCovariates=[];
    if nargin<=3
        CovariateDirs=[];
        if nargin<=2
            MaskFile=[];
        end
    end
end

GroupNumber=length(DependentDirs);

DependentVolume=[];
CovariateVolume=[];
GroupLabel=[];
OtherCovariatesMatrix=[];
for i=1:GroupNumber
    [AllVolume,VoxelSize,theImgFileList, Header] = y_ReadAll(DependentDirs{i});
    fprintf('\n\tImage Files in Group %d:\n',i);
    for itheImgFileList=1:length(theImgFileList)
        fprintf('\t%s\n',theImgFileList{itheImgFileList});
    end
    DependentVolume=cat(4,DependentVolume,AllVolume);
    if ~isempty(CovariateDirs)
        [AllVolume,VoxelSize,theImgFileList, Header_Covariate] = y_ReadAll(CovariateDirs{i});
        fprintf('\n\tImage Files in Covariate %d:\n',i);
        for itheImgFileList=1:length(theImgFileList)
            fprintf('\t%s\n',theImgFileList{itheImgFileList});
        end
        CovariateVolume=cat(4,CovariateVolume,AllVolume);
        
        if ~all(Header.dim==Header_Covariate.dim)
            msgbox('The dimension of covariate image is different from the dimension of group image, please check them!','Dimension Error','error');
            return;
        end
    end
    if ~isempty(OtherCovariates)
        OtherCovariatesMatrix=[OtherCovariatesMatrix;OtherCovariates{i}];
    end
    GroupLabel=[GroupLabel;ones(size(AllVolume,4),1)*i];
    clear AllVolume
end

GroupLabel(GroupLabel==2)=-1;

[nDim1,nDim2,nDim3,nDim4]=size(DependentVolume);

Regressors = [GroupLabel,ones(nDim4,1),OtherCovariatesMatrix];


if exist('CovariateDirs','var') && ~isempty(CovariateDirs)
    Contrast = zeros(1,size(Regressors,2)+1);
else
    Contrast = zeros(1,size(Regressors,2));
end
Contrast(1) = 1;

[b_OLS_brain, t_OLS_brain, TTest2_T, r_OLS_brain, Header] = y_GroupAnalysis_Image(DependentVolume,Regressors,OutputName,MaskFile,CovariateVolume,Contrast,'T',0,Header);

%[b_OLS_brain, t_OLS_brain, TF_ForContrast_brain, r_OLS_brain, Header] = y_GroupAnalysis_Image(DependentVolume,Predictor,OutputName,MaskFile,CovVolume,Contrast,TF_Flag,IsOutputResidual,Header)

fprintf('\n\tTwo Sample T Test Calculation finished.\n');
