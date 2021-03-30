function [rCorr,Header]=y_Correlation_Image(DependentDirs,SeedSeries,OutputName,MaskFile,CovariateDirs,OtherCovariates,PALMSettings)
% [rCorr,pCorr,Header]=y_Correlation_Image(DependentDir,SeedSeries,OutputName,MaskFile,CovariateDir,OtherCovariate,PALMSettings)
% Perform correlation analysis with or without covariate.
% Input:
%   DependentDirs - the image directory of the group. 1 by 1 cell
%   SeedSeries - the seed series. n by 1 vector
%   OutputName - the output name.
%   MaskFile - the mask file.
%   CovariateDirs - the image directory of covariate, in which the files should be correspond to the DependentDir. 1 by 1 cell
%   OtherCovariates - The other covariate. 1 by 1 cell
%   PALMSettings - Settings for permutation test with PALM. 161116.
% Output:
%   rCorr - Pearson's Correlation Coefficient or partial correlation coeffcient, also write image file out indicated by OutputName
%___________________________________________________________________________
% Written by YAN Chao-Gan 100411.
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
% Core function re-written by YAN Chao-Gan 14011.
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
for i=1:1
    [AllVolume,VoxelSize,theImgFileList, Header] = y_ReadAll(DependentDirs{i});
    if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames') %YAN Chao-Gan 181204. If NIfTI data
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
            msgbox('The dimension of covariate image is different from the dimension of group image, please check them!','Dimension Error','error');
            return;
        end
    end
    if exist('OtherCovariates','var') && ~isempty(OtherCovariates)
        OtherCovariatesMatrix=[OtherCovariatesMatrix;OtherCovariates{i}];
    end
    clear AllVolume
end


if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames') %YAN Chao-Gan 181204. If NIfTI data
    [nDim1,nDim2,nDim3,nDimTimePoints]=size(DependentVolume);
else
    [nDimVertex nDimTimePoints]=size(DependentVolume);
end


Regressors = ones(nDimTimePoints,1);

Regressors = [SeedSeries,Regressors,OtherCovariatesMatrix];

if exist('CovariateDirs','var') && ~isempty(CovariateDirs)
    Contrast = zeros(1,size(Regressors,2)+1);
else
    Contrast = zeros(1,size(Regressors,2));
end
Contrast(1) = 1;

if exist('PALMSettings','var') && (~isempty(PALMSettings)) %YAN Chao-Gan, 161116. Add permutation test.
    PALMSettings.Pearson=1;
    y_GroupAnalysis_PermutationTest_Image(DependentVolume,Regressors,OutputName,MaskFile,CovariateVolume,Contrast,'T',0,Header,PALMSettings);
    rCorr=[];
else
    
    [b_OLS_brain, t_OLS_brain, TTest1_T, r_OLS_brain, Header] = y_GroupAnalysis_Image(DependentVolume,Regressors,OutputName,MaskFile,CovariateVolume,Contrast,'T',0,Header);
    %[b_OLS_brain, t_OLS_brain, TF_ForContrast_brain, r_OLS_brain, Header] = y_GroupAnalysis_Image(DependentVolume,Predictor,OutputName,MaskFile,CovVolume,Contrast,TF_Flag,IsOutputResidual,Header)
    
    Df_E = size(Regressors,1) - size(Contrast,2);
    
    rCorr = TTest1_T./(sqrt(Df_E+TTest1_T.*TTest1_T));
    %r = t./(sqrt(Df_E+t.*t))
    
    if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames') %YAN Chao-Gan 181204. If NIfTI data
        Index = findstr(Header.descrip,'}');
        Header.descrip = sprintf('DPABI{R_[%.1f]}%s',Df_E,Header.descrip(Index(1)+1:end));
    elseif isfield(Header,'cdata')
        Index = findstr(Header.private.metadata(4).value,'}');
        Header.private.metadata(4).value = sprintf('DPABI{R_[%.1f]}%s',Df_E,Header.private.metadata(4).value(Index(1)+1:end));
    elseif isfield(Header,'MatrixNames') %YAN Chao-Gan 210122. Add DPABINet Matrix support.
        Header.OtherInfo.StatOpt.TestFlag='R';
        Header.OtherInfo.StatOpt.Df=Df_E;
    end

    y_Write(rCorr,Header,OutputName);
    
end
fprintf('\n\tCorrelation Calculation finished.\n');
