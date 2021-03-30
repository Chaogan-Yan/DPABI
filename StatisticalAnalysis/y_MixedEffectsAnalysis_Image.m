function y_MixedEffectsAnalysis_Image(DependentDir,OutputName,MaskFile,CovariateDirs,OtherCovariates, PALMSettings)
% y_MixedEffectsAnalysis_Image(DependentDir,BetweenSubjectFactor,WithinSubjectFactor,OutputName,MaskFile,CovariateDirs,OtherCovariates)
% Perform mixed effect analysis: one between subject factor, one within subject factor.
% Input:
%   DependentDir -  4 by 1 Cell, should be: {Group1Condition1; Group1Condition2; Group2Condition1; Group2Condition2}
%   OutputName - the output name.
%   MaskFile - the mask file.
%   CovariateDirs - 4 by 1 Cell, should be: {Group1Condition1Cov; Group1Condition2Cov; Group2Condition1Cov; Group2Condition2Cov}. The files should be correspond to the DependentDir.
%   OtherCovariates - 4 by 1 Cell, {Group1Condition1OtherCov; Group1Condition2OtherCov; Group2Condition1OtherCov; Group2Condition2OtherCov}. 
% Output:
%   *_Group_TwoT.nii - the T values of group differences (corresponding to the first group minus the second group) (BetweenSubjectFactor)
%   *_ConditionEffect_T.nii - the T values of condition differences (corresponding to the first condition minus the second condition) (WithinSubjectFactor)
%   *_Interaction_F.nii - the F values of interaction (BetweenSubjectFactor by WithinSubjectFactor)
%___________________________________________________________________________
% Written by YAN Chao-Gan 160515.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com


if ~exist('OtherCovariates','var')
    OtherCovariates=[];
end
if ~exist('CovariateDirs','var')
    CovariateDirs=[];
end
if ~exist('MaskFile','var')
    MaskFile='';
end

[Path, fileN, extn] = fileparts(OutputName);
OutputName=fullfile(Path,fileN); %Remove the extention

DependentVolume=[];
CovariateVolume=[];
OtherCovariatesMatrix=[];
BetweenSubjectFactor=[];
WithinSubjectFactor=[];
SubjectRegressorsAll=[];
for i=1:length(DependentDir)
    [AllVolume,VoxelSize,theImgFileList, Header] = y_ReadAll(DependentDir{i});
    if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames') %YAN Chao-Gan 181204. If NIfTI data
        FinalDim=4;
    else
        FinalDim=2;
    end
    fprintf('\n\tImage Files in Group %g Condition %g:\n',ceil(i/2),i-(ceil(i/2)-1)*2);
    for itheImgFileList=1:length(theImgFileList)
        fprintf('\t%s\n',theImgFileList{itheImgFileList});
    end
    DependentVolume=cat(FinalDim,DependentVolume,AllVolume);
    nSubjTemp = size(AllVolume,FinalDim);
    
    if ~isempty(CovariateDirs)
        [AllVolume,VoxelSize,theImgFileList, Header_Covariate] = y_ReadAll(CovariateDirs{i});
        fprintf('\n\tImage Files in Covariate Group %g Condition %g:\n',ceil(i/2),i-(ceil(i/2)-1)*2);
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

    BetweenSubjectFactor=[BetweenSubjectFactor;ceil(i/2)*ones(nSubjTemp,1)];
    BetweenSubjectFactor(find(BetweenSubjectFactor==2))=-1;
    
    WithinSubjectFactor=[WithinSubjectFactor;(i-(ceil(i/2)-1)*2)*ones(nSubjTemp,1)];
    WithinSubjectFactor(find(WithinSubjectFactor==2))=-1;

    SubjectRegressorsAll=[SubjectRegressorsAll;(ceil(i/2)-1)*10000+([1:nSubjTemp]')];
    clear AllVolume
end

if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames') %YAN Chao-Gan 181204. If NIfTI data
    [nDim1,nDim2,nDim3,nDimTimePoints]=size(DependentVolume);
else
    [nDimVertex nDimTimePoints]=size(DependentVolume);
end

SubIndex=unique(SubjectRegressorsAll);
nSub=length(SubIndex);
SubjectRegressors=[];
for i=1:nSub
    SubjectRegressors(:,i) = zeros(size(SubjectRegressorsAll));
    SubjectRegressors(find(SubjectRegressorsAll==SubIndex(i)),i) = 1;
end

Interaction = WithinSubjectFactor.*BetweenSubjectFactor;
AllCov = [WithinSubjectFactor,Interaction,SubjectRegressors];
if exist('OtherCovariates','var') && ~isempty(OtherCovariates)
    AllCov = [AllCov,OtherCovariatesMatrix]; %YAN Chao-Gan, 161214. Fixed the bug of OtherCovariates.
end

if exist('CovariateDirs','var') && ~isempty(CovariateDirs)
    Contrast = zeros(1,size(AllCov,2)+1);
else
    Contrast = zeros(1,size(AllCov,2));
end

Contrast(1)=1;
if exist('PALMSettings','var') && (~isempty(PALMSettings)) %YAN Chao-Gan, 161116. Add permutation test.
    PALMSettings_Within=PALMSettings;
    PALMSettings_Within.ExchangeabilityBlocks=SubjectRegressorsAll;  %Permutation within subject and then between subject as a whole.
    PALMSettings_Within.Whole=1;
    PALMSettings_Within.Within=1;
    y_GroupAnalysis_PermutationTest_Image(DependentVolume,AllCov,[OutputName,'_ConditionEffect_T'],MaskFile,CovariateVolume,Contrast,'T',0,Header,PALMSettings_Within);
else
    [b_OLS_brain, t_OLS_brain, TF_ForContrast_brain, r_OLS_brain, Header] = y_GroupAnalysis_Image(DependentVolume,AllCov,[OutputName,'_ConditionEffect_T'],MaskFile,CovariateVolume,Contrast,'T',0,Header);
    %[b_OLS_brain, t_OLS_brain, TF_ForContrast_brain, r_OLS_brain, Header] = y_GroupAnalysis_Image(DependentVolume,Predictor,OutputName,MaskFile,CovVolume,Contrast,TF_Flag,IsOutputResidual,Header)
end

Contrast(1)=0;
Contrast(2)=1;
if exist('PALMSettings','var') && (~isempty(PALMSettings)) %YAN Chao-Gan, 161116. Add permutation test.
    PALMSettings_Within=PALMSettings;
    PALMSettings_Within.ExchangeabilityBlocks=SubjectRegressorsAll;  %Permutation within subject and then between subject as a whole.
    PALMSettings_Within.Whole=1;
    PALMSettings_Within.Within=1;

    % YAN Chao-Gan, 161201. Comment the below as PALM can not take care F with only one column. Output T instead.
%     ContrastIndex=find(Contrast);
%     Contrast_T_forF=zeros(length(ContrastIndex),size(Contrast,2));
%     for iContrast=1:size(Contrast_T_forF,1)
%         Contrast_T_forF(iContrast,ContrastIndex(iContrast))=1;
%     end
%     PALMSettings_Within.Contrast_T_forF=Contrast_T_forF;
%     Contrast=ones(1,length(ContrastIndex));
    %y_GroupAnalysis_PermutationTest_Image(DependentVolume,AllCov,[OutputName,'_Interaction_F'],MaskFile,CovariateVolume,Contrast,'F',0,Header,PALMSettings_Within);
    
    y_GroupAnalysis_PermutationTest_Image(DependentVolume,AllCov,[OutputName,'_Interaction_T'],MaskFile,CovariateVolume,Contrast,'T',0,Header,PALMSettings_Within);
else
    [b_OLS_brain, t_OLS_brain, TF_ForContrast_brain, r_OLS_brain, Header] = y_GroupAnalysis_Image(DependentVolume,AllCov,[OutputName,'_Interaction_F'],MaskFile,CovariateVolume,Contrast,'F',0,Header);
    %[b_OLS_brain, t_OLS_brain, TF_ForContrast_brain, r_OLS_brain, Header] = y_GroupAnalysis_Image(DependentVolume,Predictor,OutputName,MaskFile,CovVolume,Contrast,TF_Flag,IsOutputResidual,Header)
end



% For two-sample t-test
if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames') %YAN Chao-Gan 181204. If NIfTI data
    DependentVolumeSubjectMean=zeros(nDim1,nDim2,nDim3,nSub);
else
    DependentVolumeSubjectMean=zeros(nDimVertex,nSub);
end
GroupLabel=zeros(nSub,1);
for i=1:nSub
    if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames') %YAN Chao-Gan 181204. If NIfTI data
        DependentVolumeSubjectMean(:,:,:,i) = mean(DependentVolume(:,:,:,find(SubjectRegressorsAll==SubIndex(i))),4);
    else
        DependentVolumeSubjectMean(:,i) = mean(DependentVolume(:,find(SubjectRegressorsAll==SubIndex(i))),2);
    end
    GroupLabel(i,1)=mean(BetweenSubjectFactor(find(SubjectRegressorsAll==SubIndex(i))));
end
if exist('CovariateDirs','var') && (~isempty(CovariateDirs))
    if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames') %YAN Chao-Gan 181204. If NIfTI data
        CovVolumeSubjectMean=zeros(nDim1,nDim2,nDim3,nSub);
        for i=1:nSub
            CovVolumeSubjectMean(:,:,:,i) = mean(CovariateVolume(:,:,:,find(SubjectRegressorsAll==SubIndex(i))),4); %YAN Chao-Gan, 171126. CovVolume is not defined. %CovVolumeSubjectMean(:,:,:,i) = mean(CovVolume(:,:,:,find(SubjectRegressorsAll==SubIndex(i))),4);
        end
    else
        CovVolumeSubjectMean=zeros(nDimVertex,nSub);
        for i=1:nSub
            CovVolumeSubjectMean(:,i) = mean(CovariateVolume(:,find(SubjectRegressorsAll==SubIndex(i))),2); %YAN Chao-Gan, 171126. CovVolume is not defined. %CovVolumeSubjectMean(:,:,:,i) = mean(CovVolume(:,:,:,find(SubjectRegressorsAll==SubIndex(i))),4);
        end
    end
else
    CovVolumeSubjectMean=[];
end

Constant=ones(nSub,1);
AllCov=[Constant,GroupLabel];

if exist('OtherCovariates','var') && ~isempty(OtherCovariates)
    OtherCovariatesMean=[];
    for i=1:nSub
        OtherCovariatesMean(i,:) = mean(OtherCovariatesMatrix(find(SubjectRegressorsAll==SubIndex(i)),:),1); %YAN Chao-Gan, 170817. Fixed the bug of OtherCovariates.
    end
    AllCov = [AllCov,OtherCovariatesMean];
end

if exist('CovariateDirs','var') && ~isempty(CovariateDirs)
    Contrast = zeros(1,size(AllCov,2)+1);
else
    Contrast = zeros(1,size(AllCov,2));
end

Contrast(2)=1;

if exist('PALMSettings','var') && (~isempty(PALMSettings)) %YAN Chao-Gan, 161116. Add permutation test.
    y_GroupAnalysis_PermutationTest_Image(DependentVolumeSubjectMean,AllCov,[OutputName,'_Group_TwoT'],MaskFile,CovVolumeSubjectMean,Contrast,'T',0,Header,PALMSettings);
else
    [b_OLS_brain, t_OLS_brain, TF_ForContrast_brain, r_OLS_brain, Header] = y_GroupAnalysis_Image(DependentVolumeSubjectMean,AllCov,[OutputName,'_Group_TwoT'],MaskFile,CovVolumeSubjectMean,Contrast,'T',0,Header);
    %[b_OLS_brain, t_OLS_brain, TF_ForContrast_brain, r_OLS_brain, Header] = y_GroupAnalysis_Image(DependentVolume,Predictor,OutputName,MaskFile,CovVolume,Contrast,TF_Flag,IsOutputResidual,Header)
end

fprintf('\n\tMixed Effects Analysis finished.\n');

