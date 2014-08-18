function [TTestPaired_T,Header] = y_TTestPaired_Image(DependentDirs,OutputName,MaskFile,CovariateDirs,OtherCovariates)
% [TTestPaired_T,Header] = y_TTestPaired_Image(DependentDirs,OutputName,MaskFile,CovariateDirs,OtherCovariates)
% Perform Paired T test.
% Input:
%   DependentDirs - the image directory of dependent variable. Cell 1 indicate Condition 1 and Cell 2 indicate Condition 2. The T is corresponding to Condition 1 minus Condition 2. 2 by 1 cell
%   OutputName - the output name.
%   MaskFile - the mask file.
%   CovariateDirs - the image directory of covariates, in which the files should be correspond to the DependentDirs. 2 by 1 cell
%   OtherCovariates - The other covariates. 2 by 1 cell 
% Output:
%   TTestPaired_T - the T value, also write image file out indicated by OutputName
%___________________________________________________________________________
% Written by YAN Chao-Gan 100317.
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
% Core function re-written by YAN Chao-Gan 140225.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com

if ~exist('MaskFile','var')
    MaskFile = '';
end

DependentVolume=[];
CovariateVolume=[];
OtherCovariatesMatrix=[];
for i=1:2
    [AllVolume,VoxelSize,theImgFileList, Header] = y_ReadAll(DependentDirs{i});
    fprintf('\n\tImage Files in Condition %d:\n',i);
    for itheImgFileList=1:length(theImgFileList)
        fprintf('\t%s\n',theImgFileList{itheImgFileList});
    end
    DependentVolume=cat(4,DependentVolume,AllVolume);
    if exist('CovariateDirs','var') && ~isempty(CovariateDirs)
        [AllVolume,VoxelSize,theImgFileList, Header_Covariate] = y_ReadAll(CovariateDirs{i});
        fprintf('\n\tImage Files in Covariate %d:\n',i);
        for itheImgFileList=1:length(theImgFileList)
            fprintf('\t%s\n',theImgFileList{itheImgFileList});
        end
        CovariateVolume=cat(4,CovariateVolume,AllVolume);
        
        if ~all(Header.dim==Header_Covariate.dim)
            msgbox('The dimension of covariate image is different from the dimension of condition image, please check them!','Dimension Error','error');
            return;
        end
    end
    if exist('OtherCovariates','var') && ~isempty(OtherCovariates)
        OtherCovariatesMatrix=[OtherCovariatesMatrix;OtherCovariates{i}];
    end
    clear AllVolume
end

[nDim1,nDim2,nDim3,nDim4]=size(DependentVolume);
nSub = nDim4/2;

Regressors = [ones(nSub,1);-1*ones(nSub,1)];

for i=1:nSub
    SubjectRegressors(:,i) = zeros(nDim4,1);
    SubjectRegressors(i:nSub:nDim4,i) = 1;
end

Regressors = [Regressors,SubjectRegressors,OtherCovariatesMatrix];

if exist('CovariateDirs','var') && ~isempty(CovariateDirs)
    Contrast = zeros(1,size(Regressors,2)+1);
else
    Contrast = zeros(1,size(Regressors,2));
end
Contrast(1) = 1;

[b_OLS_brain, t_OLS_brain, TTestPaired_T, r_OLS_brain, Header] = y_GroupAnalysis_Image(DependentVolume,Regressors,OutputName,MaskFile,CovariateVolume,Contrast,'T',0,Header);


%[b_OLS_brain, t_OLS_brain, TF_ForContrast_brain, r_OLS_brain, Header] = y_GroupAnalysis_Image(DependentVolume,Predictor,OutputName,MaskFile,CovVolume,Contrast,TF_Flag,IsOutputResidual,Header)


fprintf('\n\tPaired T Test Calculation finished.\n');
