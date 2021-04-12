function y_ICC_Image_LMM_CallR(RateDir,OutputName,MaskFile,CovWCell, CovBCell)
% function y_ICC_Image_LMM_CallR(RateDir,OutputName,MaskFile, CovW, CovB)
% Calculate the Intraclass correlation coefficient for brain images.
% Note: the ICC values were derived by linear mixed models (LMMs) as in Zuo et al. (2013): Zuo, X.N., Xu, T., Jiang, L., Yang, Z., Cao, X.Y., He, Y., Zang, Y.F., Castellanos, F.X., Milham, M.P., 2013. Toward reliable characterization of functional homogeneity in the human brain: preprocessing, scan duration, imaging resolution and computational space. Neuroimage 65, 374?386.
%   Input:
%     RateDir - n by 1 Cell, n repetitions. Within each cell are the subjects.
%     OutputName - OutputName
%     MaskFile - Maks File
%     CovWCell - n by 1 Cell, within subject covariates
%     CovBCell - n by 1 Cell, between subject covariates
%   Output:
%     OutputName - image with ICC
%___________________________________________________________________________
% Written by YAN Chao-Gan 161124. Based on the R code written by Dr. Ting Xu.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com


AllVolume=[];
time=[];
sID=[];
CovW=[];
CovB=[];
for i=1:length(RateDir)
    [AllVolumeTemp,VoxelSize,theImgFileList, Header] = y_ReadAll(RateDir{i});
    if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames') %YAN Chao-Gan 210402. If NIfTI data
        FinalDim=4;
    else
        FinalDim=2;
    end
    fprintf('\n\tImage Files in Repetition %d:\n',i);
    for itheImgFileList=1:length(theImgFileList)
        fprintf('\t%s\n',theImgFileList{itheImgFileList});
    end
    AllVolume=cat(FinalDim,AllVolume,AllVolumeTemp);
    nSubj = size(AllVolumeTemp,FinalDim);
    
    if ~isempty(CovWCell)
        CovW=[CovW;CovWCell{i}];
    end
    if ~isempty(CovBCell)
        CovB=[CovB;CovBCell{i}];
    end
    
    time=[time;i*ones(nSubj,1)];
    sID=[sID;[1:nSubj]'];
    clear AllVolumeTemp
end

if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames') %YAN Chao-Gan 210402. If NIfTI data
    [nDim1,nDim2,nDim3,nDimTimePoints]=size(AllVolume);
    if ~isempty(MaskFile)
        [MaskData,MaskVox,MaskHead]=y_ReadRPI(MaskFile);
    else
        MaskData=ones(nDim1,nDim2,nDim3);
    end
    % Convert into 2D
    AllVolume=reshape(AllVolume,[],size(AllVolume,4))';
    MaskDataOneDim=reshape(MaskData,1,[]);
    MaskIndex = find(MaskDataOneDim);
    AllVolume=AllVolume(:,MaskIndex);
else
    [nDimVertex nDimTimePoints]=size(AllVolume);
    fprintf('\nLoad mask "%s".\n', MaskFile);
    if ~isempty(MaskFile)
        MaskData=y_ReadAll(MaskFile);
        if size(MaskData,1)~=nDimVertex
            error('The size of Mask (%d) doesn''t match the required size (%d).\n',size(MaskData,1), nDimVertex);
        end
        MaskData = double(logical(MaskData));
    else
        MaskData=ones(nDimVertex,1);
    end
    AllVolume=AllVolume';
    MaskIndex=find(MaskData);
    AllVolume=AllVolume(:,MaskIndex);
end

%Demean
if ~isempty(CovW)
    CovW = CovW-repmat(mean(CovW),size(CovW,1),1);
end
if ~isempty(CovB)
    CovB = CovB-repmat(mean(CovB),size(CovB,1),1);
end


nSession = length(RateDir);
nVoxels = size(AllVolume,2);

[Path, fileN, extn] = fileparts(OutputName);
MatNameForR=fullfile(Path,[fileN,'_ForR.mat']);
save(MatNameForR,'AllVolume','CovW','CovB','time','sID','nSubj','nSession','nVoxels');
MatNameRResults=fullfile(Path,[fileN,'_RResults.mat']);

[ProgramPath] = fileparts(which('y_ICC_Image_LMM_CallR.m'));
Expression = sprintf('!Rscript %s%sR_Cal_ICC.R %s %s', ProgramPath, filesep,MatNameForR,MatNameRResults);
eval(Expression);
load(MatNameRResults);

% Get the brain back
if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames') %YAN Chao-Gan 210402. If NIfTI data
    ICCBrain=zeros(size(MaskDataOneDim));
    ICCBrain(1,MaskIndex)=icc;
    ICCBrain=reshape(ICCBrain,nDim1, nDim2, nDim3);
    Header.pinfo = [1;0;0];
    Header.dt    =[16,0];
else
    ICCBrain = zeros(1, nDimVertex);
    ICCBrain(1,MaskIndex) = icc;
    ICCBrain = ICCBrain';
end

y_Write(ICCBrain,Header,OutputName);

fprintf('\n\tICC calculation finished\n');
