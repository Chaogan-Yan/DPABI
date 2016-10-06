function [PartialCorrBrain, Header] = y_PartialCorr_Image(AllVolume, SeedSeries, OutputName, MaskData)
% [PartialCorrBrain, Header] = y_PartialCorr_Image(AllVolume, SeedSeries, OutputName, MaskData)
% Calculate partial correlation: the partial correlation between a voxel time series and a given column of SeedSeries, while controling the other columns in SeedSeries
% Input:
% 	AllVolume		-	4D data matrix (DimX*DimY*DimZ*DimTimePoints) or the directory of 3D image data file or the filename of one 4D data file
%   ROIDef              SeedSeries: Series matrix (DimTimePoints*N)
%	OutputName  	-	Output filename
% 	MaskData		-   The Mask matrix (DimX*DimY*DimZ) or the Mask file name
% Output:
%	PartialCorrBrain         -   the partial correlation of the seed series. (DimX*DimY*DimZ*N)
%   Header          -   The NIfTI Header
%   PartialCorrBrain will be output as where OutputName specified.
%-----------------------------------------------------------
% Written by YAN Chao-Gan 160706.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com

theElapsedTime =cputime;
fprintf('\n\t Calculating Partial Correlation...');

if ~isnumeric(AllVolume)
    [AllVolume,VoxelSize,theImgFileList, Header] =y_ReadAll(AllVolume);
end

[nDim1 nDim2 nDim3 nDimTimePoints]=size(AllVolume);
BrainSize = [nDim1 nDim2 nDim3];
VoxelSize = sqrt(sum(Header.mat(1:3,1:3).^2));

if ischar(MaskData)
    fprintf('\nLoad mask "%s".\n', MaskData);
    if ~isempty(MaskData)
        [MaskData,MaskVox,MaskHead]=y_ReadRPI(MaskData);
        if ~all(size(MaskData)==[nDim1 nDim2 nDim3])
            error('The size of Mask (%dx%dx%d) doesn''t match the required size (%dx%dx%d).\n',size(MaskData), [nDim1 nDim2 nDim3]);
        end
        MaskData = double(logical(MaskData));
    else
        MaskData=ones(nDim1,nDim2,nDim3);
    end
end

% Convert into 2D
AllVolume=reshape(AllVolume,[],nDimTimePoints)';
% AllVolume=permute(AllVolume,[4,1,2,3]); % Change the Time Course to the first dimention
% AllVolume=reshape(AllVolume,nDimTimePoints,[]);

MaskDataOneDim=reshape(MaskData,1,[]);
MaskIndex = find(MaskDataOneDim);
AllVolume=AllVolume(:,MaskIndex);

PartialCorrSet=zeros(size(SeedSeries,2),size(AllVolume,2));
for i=1:size(AllVolume,2)
    Temp=[AllVolume(:,i),SeedSeries];
    r=y_partialcorr(Temp);
    PartialCorrSet(:,i)=r(2:end,1);
    if mod(i,100)==0
        fprintf('.');
    end
end

PartialCorrSet(find(isnan(PartialCorrSet)))=0;

PartialCorrBrain = single(zeros(size(SeedSeries,2), nDim1*nDim2*nDim3));
PartialCorrBrain(:,MaskIndex) = PartialCorrSet;

PartialCorrBrain=reshape(PartialCorrBrain',[nDim1, nDim2, nDim3, size(SeedSeries,2)]);

Header_Out = Header;
Header_Out.pinfo = [1;0;0];
Header_Out.dt    =[16,0];

y_Write(PartialCorrBrain,Header_Out,OutputName);

theElapsedTime = cputime - theElapsedTime;
fprintf('\n\t Calculating Partial Correlation finished, elapsed time: %g seconds.\n', theElapsedTime);
