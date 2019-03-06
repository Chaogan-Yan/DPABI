function [TTest1_T,Header] = y_TTest1_Image(DependentDirs,OutputName,MaskFile,CovariateDirs,OtherCovariates,Base,PALMSettings)

% [TTest1_T,Header] = y_TTest1_Image(DependentDirs,OutputName,MaskFile,CovariateDirs,OtherCovariates,Base,PALMSettings)
% Perform one sample t test.
% Input:
%   DependentDirs - the image directory of dependent variable. 1 by 1 cell
%   OutputName - the output name.
%   MaskFile - the mask file.
%   CovariateDirs - the image directory of covariates, in which the files should be correspond to the DependentDirs. 1 by 1 cell
%   OtherCovariates - The other covariates. 1 by 1 cell 
%   Base - the base of one sample T Test. 0: default.
%   PALMSettings - Settings for permutation test with PALM. 161116.
% Output:
%   TTest1_T - the T value, also write image file out indicated by OutputName
%___________________________________________________________________________
% Written by YAN Chao-Gan 100317.
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
% Core function re-written by YAN Chao-Gan 140225.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com
% Revised by YAN Chao-Gan 181204. Add GIfTI support.

if ~exist('Base','var')
    Base = 0;
end

if ~exist('MaskFile','var')
    MaskFile = '';
end

DependentVolume=[];
CovariateVolume=[];
OtherCovariatesMatrix=[];
for i=1:1
    [AllVolume,VoxelSize,theImgFileList, Header] = y_ReadAll(DependentDirs{i});
    if ~isfield(Header,'cdata') %YAN Chao-Gan 181204. If NIfTI data
        FinalDim=4;
    else
        FinalDim=2;
    end
    fprintf('\n\tImage Files in the Group:\n');
    for itheImgFileList=1:length(theImgFileList)
        fprintf('\t%s\n',theImgFileList{itheImgFileList});
    end
    DependentVolume=cat(FinalDim,DependentVolume,AllVolume);
    if exist('CovariateDirs','var') && ~isempty(CovariateDirs)
        [AllVolume,VoxelSize,theImgFileList, Header_Covariate] = y_ReadAll(CovariateDirs{i});
        fprintf('\n\tImage Files in Covariate:\n');
        for itheImgFileList=1:length(theImgFileList)
            fprintf('\t%s\n',theImgFileList{itheImgFileList});
        end
        CovariateVolume=cat(FinalDim,CovariateVolume,AllVolume);
        
        SizeDependentVolume=size(DependentVolume);
        SizeCovariateVolume=size(CovariateVolume);
        if ~isequal(SizeDependentVolume,SizeCovariateVolume)
            msgbox('The dimension of covariate image is different from the dimension of condition image, please check them!','Dimension Error','error');
            return;
        end
    end
    if exist('OtherCovariates','var') && ~isempty(OtherCovariates)
        OtherCovariatesMatrix=[OtherCovariatesMatrix;OtherCovariates{i}];
    end
    clear AllVolume
end

if ~isfield(Header,'cdata') %YAN Chao-Gan 181204. If NIfTI data
    [nDim1,nDim2,nDim3,nDimTimePoints]=size(DependentVolume);
else
    [nDimVertex nDimTimePoints]=size(DependentVolume);
end


%Mean centering the covariates -- since this is testing the effect the constant column
if exist('CovariateDirs','var') && ~isempty(CovariateDirs)
    if ~isfield(Header,'cdata') %YAN Chao-Gan 181204. If NIfTI data
        CovariateVolume = CovariateVolume - repmat(mean(CovariateVolume,FinalDim),[1,1,1,nDimTimePoints]);
    else
        CovariateVolume = CovariateVolume - repmat(mean(CovariateVolume,FinalDim),[1,nDimTimePoints]);
    end
end

if ~isempty(OtherCovariatesMatrix)
    OtherCovariatesMatrix = OtherCovariatesMatrix - repmat(mean(OtherCovariatesMatrix,1),[nDimTimePoints,1]);
end


DependentVolume = DependentVolume-Base;

Regressors = ones(nDimTimePoints,1);

Regressors = [Regressors,OtherCovariatesMatrix];

if exist('CovariateDirs','var') && ~isempty(CovariateDirs)
    Contrast = zeros(1,size(Regressors,2)+1);
else
    Contrast = zeros(1,size(Regressors,2));
end
Contrast(1) = 1;

if exist('PALMSettings','var') && (~isempty(PALMSettings)) %YAN Chao-Gan, 161116. Add permutation test.
    PALMSettings.ISE=1;
    y_GroupAnalysis_PermutationTest_Image(DependentVolume,Regressors,OutputName,MaskFile,CovariateVolume,Contrast,'T',0,Header,PALMSettings);
    TTest1_T=[];
else
    [b_OLS_brain, t_OLS_brain, TTest1_T, r_OLS_brain, Header] = y_GroupAnalysis_Image(DependentVolume,Regressors,OutputName,MaskFile,CovariateVolume,Contrast,'T',0,Header);
    %[b_OLS_brain, t_OLS_brain, TF_ForContrast_brain, r_OLS_brain, Header] = y_GroupAnalysis_Image(DependentVolume,Predictor,OutputName,MaskFile,CovVolume,Contrast,TF_Flag,IsOutputResidual,Header)
end

fprintf('\n\tOne Sample T Test Calculation finished.\n');
