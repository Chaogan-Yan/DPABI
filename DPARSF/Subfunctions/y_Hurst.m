function [HurstBrain_DSOD, HurstBrain_WDSOD, HurstBrain_WDRE, Header] = y_Hurst(AllVolume, OutputName, MaskData, Header)
% Calculate Hurst exponent. Using wfbmesti in Matlab Wavelet Toolbox.
% function [HurstBrain_DSOD, HurstBrain_WDSOD, HurstBrain_WDRE, Header] = y_Hurst(AllVolume, OutputName, MaskData, Header)
% Input:
% 	AllVolume		-	4D data matrix (DimX*DimY*DimZ*DimTimePoints) or the directory of 3D image data file or the filename of one 4D data file
%	OutputName		the output filename
% 	MaskData		the mask file name, I only compute the point within the mask
%   Header          -   If AllVolume is given as a 4D Brain matrix, then Header should be designated.
% Output:
%	HurstBrain_DSOD       -   The Hurst results: Discrete second derivative estimator (DSOD)
%	HurstBrain_WDSOD      -   The Hurst results: Wavelet version of DSOD (WDSOD)
%	HurstBrain_WDRE       -   The Hurst results: Wavelet details regression estimator (WDRE)
%   Header          -   The NIfTI Header
%	OutputName*.nii.
%-----------------------------------------------------------

theElapsedTime =cputime;

fprintf('\nComputing Hurst exponent...');

if ~isnumeric(AllVolume)
    [AllVolume,VoxelSize,theImgFileList, Header] =y_ReadAll(AllVolume);
end

[nDim1 nDim2 nDim3 nDimTimePoints]=size(AllVolume);
BrainSize = [nDim1 nDim2 nDim3];
VoxelSize = sqrt(sum(Header.mat(1:3,1:3).^2));

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

fprintf('\n\tHurst exponent Calculating...\n');
HurstBrain_DSOD=zeros(nDim1,nDim2,nDim3);
HurstBrain_WDSOD=zeros(nDim1,nDim2,nDim3);
HurstBrain_WDRE=zeros(nDim1,nDim2,nDim3);
for i=1:nDim1
    fprintf('.');
    for j=1:nDim2
        for k=1:nDim3
            if MaskData(i,j,k)
                DV=squeeze(AllVolume(i,j,k,:));
                Hurst=wfbmesti(DV);
                HurstBrain_DSOD(i,j,k)=Hurst(1);
                HurstBrain_WDSOD(i,j,k)=Hurst(2);
                HurstBrain_WDRE(i,j,k)=Hurst(3);
            end
        end
    end
end

Header.pinfo = [1;0;0];
Header.dt    =[16,0];

[pathstr, name, ext] = fileparts(OutputName);
y_Write(HurstBrain_DSOD,Header,fullfile(pathstr,[name,'_DSOD',ext]));
y_Write(HurstBrain_WDSOD,Header,fullfile(pathstr,[name,'_WDSOD',ext]));
y_Write(HurstBrain_WDRE,Header,fullfile(pathstr,[name,'_WDRE',ext]));

theElapsedTime = cputime - theElapsedTime;
fprintf('\n\t Hurst exponent compution over, elapsed time: %g seconds.\n', theElapsedTime);

