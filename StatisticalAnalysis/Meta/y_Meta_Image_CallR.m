function y_Meta_Image_CallR(TFiles,OutputName,MaskFile,N1, N2)
% function y_Meta_Image_CallR(TFiles,OutputName,MaskFile,N1, N2)
% Perform meta analysis call 'metansue' R package.
%   Input:
%     TFiles - n by 1 Cell. Each cell is a T file for a study.
%     OutputName - OutputName
%     MaskFile - Maks File
%     N1 - n by 1 matrix. The sample size of group 1 for each study
%     N2 - n by 1 matrix. The sample size of group 2 for each study
%   Output:
%     OutputName - meta Z results
%___________________________________________________________________________
% Written by YAN Chao-Gan 171115.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com


[AllVolume,VoxelSize,theImgFileList, Header] = y_ReadAll(TFiles);

[nDim1,nDim2,nDim3,nDim4]=size(AllVolume);

if ~isempty(MaskFile)
    [MaskData,MaskVox,MaskHead]=y_ReadRPI(MaskFile);
else
    MaskData=ones(nDim1,nDim2,nDim3);
end

% Convert into 2D
AllVolume=reshape(AllVolume,[],size(AllVolume,4))';
MaskDataOneDim=reshape(MaskData,1,[]);
MaskIndex = find(MaskDataOneDim);
TVal=AllVolume(:,MaskIndex);

nTests = size(TVal,2);

[Path, fileN, extn] = fileparts(OutputName);
MatNameForR=fullfile(Path,[fileN,'_ForR.mat']);
save(MatNameForR,'TVal','N1','N2','nTests');
MatNameRResults=fullfile(Path,[fileN,'_RResults.mat']);

[ProgramPath] = fileparts(which('y_Meta_Image_CallR.m'));
Expression = sprintf('!Rscript %s%sR_Cal_Meta.R %s %s', ProgramPath, filesep,MatNameForR,MatNameRResults);
eval(Expression);
load(MatNameRResults);

ZBrain=zeros(size(MaskDataOneDim));
ZBrain(1,MaskIndex)=Z;
ZBrain=reshape(ZBrain,nDim1, nDim2, nDim3);

PBrain=zeros(size(MaskDataOneDim));
PBrain(1,MaskIndex)=P;
PBrain=reshape(PBrain,nDim1, nDim2, nDim3);

Header.pinfo = [1;0;0];
Header.dt    =[16,0];

y_Write(PBrain,Header,fullfile(Path,[fileN,'_P.nii']));

HeaderTWithDOF=Header;
HeaderTWithDOF.descrip=sprintf('DPABI{Z}');

y_Write(ZBrain,HeaderTWithDOF,OutputName);

fprintf('\n\tMeta calculation finished\n');
