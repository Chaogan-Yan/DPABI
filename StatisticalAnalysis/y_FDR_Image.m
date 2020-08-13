function [Data_Corrected, Header, P]=y_FDR_Image(StatsImgFile,qThreshold,OutputName,MaskFile,Flag,Df1,Df2,VoxelSize,Header)
% function [Data_Corrected, Header]=y_FDR_Image(StatsImgFile,qThreshold,OutputName,MaskFile,Flag,Df1,Df2,VoxelSize,Header)
% Function to perform false discovery rate (FDR) correction.
% References:
% Input:
%     StatsImgFile      - The statistical image file name. Could be either Z, T, F or R statistical image. T/F/R images will transformed into Z image (according to their degree of freedom Df1, Df2) to perform further smoothness estimation and cluster thresholding.
%     qThreshold        - Q threshold for FDR
%     OutputName        - The output file name.
%     MaskFile          - The mask file name. If empty (i.e., ''), then all voxels are included.
%     Flag              - 'Z', 'T', 'F' or 'R'. Indicate the type of the input statistical image
%                       - If not defined or defined as empty, then will read the statistical type and degree of freedom information from the image (if the statistical analysis was performed with REST or SPM).
%     Df1               - The degree of freedom of the statistical image. For F statistical image, there is also Df2
%     Df2               - The second degree of freedom of F statistical image
%     VoxelSize         - The Voxel's size of the image inputed. Defined when call by rest_sliceviewer.
%     Header            - The Header of the nifti image.
% Output:
%     The image file  after correction.
%     Data_Corrected    - The Data matrix after correction
%     Header            - The output Header of the nifti image.
%     P                 - P threshold after correction
%___________________________________________________________________________
% Written by YAN Chao-Gan 170208.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com


%Read Header in.
if (~exist('Header','var')) || (exist('Header','var') && isempty(Header))
    [BrainVolume, VoxelSize, FileList, Header]=y_ReadAll(StatsImgFile);
end

%Read Mask
if ~isfield(Header,'cdata') %YAN Chao-Gan 181204. If NIfTI data
    [nDim1 nDim2 nDim3 nDimTimePoints]=size(BrainVolume);
    if ~isempty(MaskFile)
        [MaskData]=y_ReadRPI(MaskFile);
    else
        MaskData=ones(nDim1,nDim2,nDim3);
    end
else
    [nDimVertex nDimTimePoints]=size(BrainVolume);
    if ~isempty(MaskFile)
        [MaskData]=y_ReadAll(MaskFile);
    else
        MaskData=ones(nDimVertex,1);
    end
end
MaskDataOneDim=reshape(MaskData,1,[]);
MaskIndex = find(MaskDataOneDim);

%Added by YAN Chao-Gan 121222. Detect the Flag and DF from the data if Flag is not defined.
if (~exist('Flag','var')) || (exist('Flag','var') && isempty(Flag))
    Header_DF = w_ReadDF(Header);
    Flag = Header_DF.TestFlag;
    Df1 = Header_DF.Df;
    Df2 = Header_DF.Df2;
end


%FDR
SMap=BrainVolume(MaskIndex);
SMap=reshape(SMap,[],1);
switch upper(Flag)
    case 'T'
        PMap=2*(1-tcdf(abs(SMap), Df1));
    case 'R'
        PMap=2*(1-tcdf(abs(SMap).*sqrt((Df1)./(1-SMap.*SMap)), Df1));
    case 'F'
        PMap=(1-fcdf(SMap, Df1, Df2));
    case 'Z'
        PMap=2*(1-normcdf(abs(SMap)));
end

% Following  FDR.m	1.3 Tom Nichols 02/01/18
SortP=sort(PMap);
V=length(SortP);
I=(1:V)';
cVID = 1;
cVN  = sum(1./(1:V));
P   = SortP(find(SortP <= I/V*qThreshold/cVID, 1, 'last' ));

Thresholded=zeros(size(PMap));
if ~isempty(P)
    Thresholded(find(PMap<=P))=1;
end

if ~isfield(Header,'cdata') %YAN Chao-Gan 181204. If NIfTI data
    AllBrain = zeros(nDim1, nDim2, nDim3);
    AllBrain = reshape(AllBrain,1,[]);
    AllBrain(MaskIndex) = Thresholded;
    AllBrain = reshape(AllBrain,nDim1, nDim2, nDim3);
else
    AllBrain = zeros(nDimVertex,1);
    AllBrain(MaskIndex) = Thresholded;
end

Data_Corrected=BrainVolume.*AllBrain;

% If OutputName is empty, DO NOT WRITE, ADD by Sandy Wang
if ~isempty(OutputName)
    y_Write(Data_Corrected,Header,OutputName);
end
fprintf('\n\tFDR correction finished.\n');
