function y_Meta_Image_CallR(TFiles,OutputName,MaskFile,N1, N2, Regressor)
% function y_Meta_Image_CallR(TFiles,OutputName,MaskFile,N1, N2, Regressor)
% Perform meta analysis call 'metansue' R package.
%   Input:
%     TFiles - n by 1 Cell. Each cell is a T file for a study.
%     OutputName - OutputName
%     MaskFile - Maks File
%     N1 - n by 1 matrix. The sample size of group 1 for each study
%     N2 - n by 1 matrix. The sample size of group 2 for each study
%     Regressor - n by 1 matrix. Regressor for meta-regression
%   Output:
%     OutputName - meta Z results
%___________________________________________________________________________
% Written by YAN Chao-Gan 171115.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com


if ~exist('Regressor','var') %YAN Chao-Gan, 220424
    Regressor=[];
end

[AllVolume,VoxelSize,theImgFileList, Header] = y_ReadAll(TFiles);


if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames') %YAN Chao-Gan 220424. If NIfTI data
    FinalDim=4;
else
    FinalDim=2;
end

fprintf('\n\tImage Files for meta analysis:\n');
for itheImgFileList=1:length(theImgFileList)
    fprintf('\t%s\n',theImgFileList{itheImgFileList});
end


if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames') %YAN Chao-Gan 220424. If NIfTI data
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


TVal=AllVolume;

nTests = size(TVal,2);

[Path, fileN, extn] = fileparts(OutputName);
MatNameForR=fullfile(Path,[fileN,'_ForR.mat']);
save(MatNameForR,'TVal','N1','N2','nTests','Regressor');
MatNameRResults=fullfile(Path,[fileN,'_RResults.mat']);

[ProgramPath] = fileparts(which('y_Meta_Image_CallR.m'));
Expression = sprintf('!Rscript %s%sR_Cal_Meta.R %s %s', ProgramPath, filesep,MatNameForR,MatNameRResults);
eval(Expression);
load(MatNameRResults);


% Get residual for smoothness estimation
X = [ones(nDimTimePoints,1),Regressor];
Residual = EffectSize - X*inv((X'*X))*X'*EffectSize;

% Get the brain back
if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames') %YAN Chao-Gan 220424. If NIfTI data
    ZBrain=zeros(size(MaskDataOneDim));
    ZBrain(1,MaskIndex)=Z;
    ZBrain=reshape(ZBrain,nDim1, nDim2, nDim3);

    PBrain=zeros(size(MaskDataOneDim));
    PBrain(1,MaskIndex)=P;
    PBrain=reshape(PBrain,nDim1, nDim2, nDim3);

    ResidualBrain = zeros(nDimTimePoints, nDim1*nDim2*nDim3);
    ResidualBrain(:,MaskIndex) = Residual;
    ResidualBrain=reshape(ResidualBrain',[nDim1, nDim2, nDim3, nDimTimePoints]);

    Header.pinfo = [1;0;0];
    Header.dt    =[16,0];
else
    ZBrain = zeros(1, nDimVertex);
    ZBrain(1,MaskIndex) = Z;
    ZBrain = ZBrain';

    PBrain = zeros(1, nDimVertex);
    PBrain(1,MaskIndex) = P;
    PBrain = PBrain';

    ResidualBrain = zeros(nDimTimePoints,nDimVertex);
    ResidualBrain(:,MaskIndex) = Residual;
    ResidualBrain = ResidualBrain';
end

if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames') %YAN Chao-Gan 181204. If NIfTI data
    DOF = nDimTimePoints - size(X,2) ;
    VoxelSize = sqrt(sum(Header.mat(1:3,1:3).^2));
    [dLh,resels,FWHM, nVoxels] = y_Smoothest(ResidualBrain, MaskFile, DOF, VoxelSize);
    HeaderTWithDOF=Header;
    HeaderTWithDOF.descrip=sprintf('DPABI{Z}{dLh_%f}{FWHMx_%fFWHMy_%fFWHMz_%fmm}',dLh,FWHM(1),FWHM(2),FWHM(3));
else
    HeaderTWithDOF=Header;
    if isfield(Header,'cdata')
        [FWHM] = w_Smoothest_Surf([],{ResidualBrain}, {MaskFile});
        HeaderTWithDOF.private.metadata = [HeaderTWithDOF.private.metadata, struct('name','DOF','value',sprintf('DPABI{Z}{FWHM_%fmm}',FWHM))];
    elseif isfield(Header,'MatrixNames') %YAN Chao-Gan 210122. Add DPABINet Matrix support.
        HeaderTWithDOF.OtherInfo.StatOpt.TestFlag='Z';
        HeaderTWithDOF.OtherInfo.StatOpt.Df=1;
    end
end

y_Write(ZBrain,HeaderTWithDOF,OutputName);
y_Write(PBrain,HeaderTWithDOF,fullfile(Path,[fileN,'_P']));

fprintf('\n\tMeta calculation finished\n');
