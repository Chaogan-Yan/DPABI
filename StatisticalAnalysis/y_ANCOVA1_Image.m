function [ANCOVA_F,Header] = y_ANCOVA1_Image(DependentDirs,OutputName,MaskFile,CovariateDirs,OtherCovariates,PALMSettings)
% [ANCOVA_F,Header] = y_ANCOVA1_Image(DependentDirs,OutputName,MaskFile,CovariateDirs,OtherCovariates,PALMSettings)
% Perform one-way ANOVA or ANCOVA analysis on Images
% Input:
%   DependentDirs - the image directory of dependent variable, each directory indicate a group. Group number by 1 cell
%   OutputName - the output name.
%   MaskFile - the mask file.
%   CovariateDirs - the image directory of covariates, in which the files should be correspond to the DependentDirs. Group number by 1 cell
%   OtherCovariates - The other covariates. Group number by 1 cell 
%                     Perform ANOVA analysis if all the covariates are empty.
%   PALMSettings - Settings for permutation test with PALM. 161116.
% Output:
%   ANCOVA_F - the F value, also write image file out indicated by OutputName
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
    if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames') %YAN Chao-Gan 181204. If NIfTI data
        FinalDim=4;
    else
        FinalDim=2;
    end
    fprintf('\n\tImage Files in Group %d:\n',i);
    for itheImgFileList=1:length(theImgFileList)
        fprintf('\t%s\n',theImgFileList{itheImgFileList});
    end
    DependentVolume=cat(FinalDim,DependentVolume,AllVolume);
    if ~isempty(CovariateDirs)
        [AllVolume,VoxelSize,theImgFileList, Header_Covariate] = y_ReadAll(CovariateDirs{i});
        fprintf('\n\tImage Files in Covariate %d:\n',i);
        for itheImgFileList=1:length(theImgFileList)
            fprintf('\t%s\n',theImgFileList{itheImgFileList});
        end
        CovariateVolume=cat(FinalDim,CovariateVolume,AllVolume);
        
        SizeDependentVolume=size(DependentVolume);
        SizeCovariateVolume=size(CovariateVolume);
        if ~isequal(SizeDependentVolume,SizeCovariateVolume)
            msgbox('The dimension of covariate image is different from the dimension of group image, please check them!','Dimension Error','error');
            return;
        end
    end
    if ~isempty(OtherCovariates)
        OtherCovariatesMatrix=[OtherCovariatesMatrix;OtherCovariates{i}];
    end
    GroupLabel=[GroupLabel;ones(size(AllVolume,FinalDim),1)*i];
    clear AllVolume
end

if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames') %YAN Chao-Gan 181204. If NIfTI data
    [nDim1,nDim2,nDim3,nDimTimePoints]=size(DependentVolume);
else
    [nDimVertex nDimTimePoints]=size(DependentVolume);
end


GroupLabelUnique=unique(GroupLabel);
Df_Group=length(GroupLabelUnique)-1;
GroupDummyVariable=zeros(nDimTimePoints,Df_Group);
for i=1:Df_Group
    GroupDummyVariable(:,i)=GroupLabel==GroupLabelUnique(i);
end


Regressors = [GroupDummyVariable,ones(nDimTimePoints,1),OtherCovariatesMatrix];

if exist('CovariateDirs','var') && ~isempty(CovariateDirs)
    Contrast = zeros(1,size(Regressors,2)+1);
else
    Contrast = zeros(1,size(Regressors,2));
end
Contrast(1:Df_Group) = 1;

if exist('PALMSettings','var') && (~isempty(PALMSettings)) %YAN Chao-Gan, 161116. Add permutation test.
    %Set up t contrast for F.
    ContrastIndex=find(Contrast);
    Contrast_T_forF=zeros(length(ContrastIndex),size(Contrast,2));
    for iContrast=1:size(Contrast_T_forF,1)
        Contrast_T_forF(iContrast,ContrastIndex(iContrast))=1;
    end
    PALMSettings.Contrast_T_forF=Contrast_T_forF;
    y_GroupAnalysis_PermutationTest_Image(DependentVolume,Regressors,OutputName,MaskFile,CovariateVolume,Contrast,'F',0,Header,PALMSettings);
    ANCOVA_F=[];
else
    [b_OLS_brain, t_OLS_brain, ANCOVA_F, r_OLS_brain, Header] = y_GroupAnalysis_Image(DependentVolume,Regressors,OutputName,MaskFile,CovariateVolume,Contrast,'F',0,Header);
    %[b_OLS_brain, t_OLS_brain, TF_ForContrast_brain, r_OLS_brain, Header] = y_GroupAnalysis_Image(DependentVolume,Predictor,OutputName,MaskFile,CovVolume,Contrast,TF_Flag,IsOutputResidual,Header)
end

fprintf('\n\tANCOVA Test Calculation finished.\n');

