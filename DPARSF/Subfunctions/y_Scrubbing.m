function [AllVolumeBrain, Header_Out] = y_Scrubbing(AllVolume, OutputName, MaskData, TemporalMask, ScrubbingMethod, ScrubbingTiming, IsNeedDetrend, Band, TR, Header, CUTNUMBER)
% [AllVolumeBrain, Header_Out] = y_Scrubbing(AllVolume, OutputName, MaskData, TemporalMask, ScrubbingMethod, ScrubbingTiming, IsNeedDetrend, Band, TR, Header, CUTNUMBER)
% Do scrubbing
% Input:
% 	AllVolume		-	4D data matrix (DimX*DimY*DimZ*DimTimePoints) or the directory of 3D image data file or the filename of one 4D data file
%	OutputName  	-	Output filename
% 	MaskData		-   Mask matrix (DimX*DimY*DimZ) or the mask file name
%   TemporalMask    -   Temporal mask for scrubbing (DimTimePoints*1)
%   ScrubbingMethod -   The methods for scrubbing.
%                       -1. 'cut': discarding the timepoints with TemporalMask == 0
%                       -2. 'nearest': interpolate the timepoints with TemporalMask == 0 by Nearest neighbor interpolation 
%                       -3. 'linear': interpolate the timepoints with TemporalMask == 0 by Linear interpolation
%                       -4. 'spline': interpolate the timepoints with TemporalMask == 0 by Cubic spline interpolation
%                       -5. 'pchip': interpolate the timepoints with TemporalMask == 0 by Piecewise cubic Hermite interpolation
%   ScrubbingTiming -   The timing for scrubbing.
%                       -1. 'BeforeFiltering': scrubbing (and interpolation, if) before detrend (if) and filtering (if).
%                       -2. 'AfterFiltering': scrubbing after filtering, right before extract ROI TC and FC analysis
%   IsNeedDetrend   -   0: Dot not detrend; 1: Use Matlab's detrend
%   Band            -   Temporal filter band: matlab's ideal filter e.g. [0.01 0.08]
%   TR              -   The TR of scanning. (Used for filtering.)
%   Header          -   If AllVolume is given as a 4D Brain matrix, then Header should be designated.
% Output:
%	AllVolumeBrain      -   The AllVolume after scrubbing
%   Header_Out          -   The NIfTI Header
%   All the volumes after scrubbing will be output as where OutputName specified.
%-----------------------------------------------------------
% Written by YAN Chao-Gan 120423.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com

if ~exist('CUTNUMBER','var')
    CUTNUMBER = 10;
end

if ~isnumeric(AllVolume)
    [AllVolume,VoxelSize,theImgFileList, Header] =y_ReadAll(AllVolume);
end

[nDim1 nDim2 nDim3 nDimTimePoints]=size(AllVolume);
BrainSize = [nDim1 nDim2 nDim3];
VoxelSize = sqrt(sum(Header.mat(1:3,1:3).^2));


if ischar(MaskData)
    if ~isempty(MaskData)
        [MaskData,MaskVox,MaskHead]=y_ReadRPI(MaskData);
    else
        MaskData=ones(nDim1,nDim2,nDim3);
    end
end

% Convert into 2D
AllVolume=reshape(AllVolume,[],nDimTimePoints)';
% AllVolume=permute(AllVolume,[4,1,2,3]); % Change the Time Course to the first dimention
% AllVolume=reshape(AllVolume,nDimTimePoints,[]);

MaskDataOneDim=reshape(MaskData,1,[]);
AllVolume=AllVolume(:,find(MaskDataOneDim));

% Scrubbing
if exist('TemporalMask','var') && ~isempty(TemporalMask) && ~strcmpi(ScrubbingTiming,'AfterFiltering')
    if ~all(TemporalMask)
        AllVolume = AllVolume(find(TemporalMask),:); %'cut'
        if ~strcmpi(ScrubbingMethod,'cut')
            xi=1:length(TemporalMask);
            x=xi(find(TemporalMask));
            AllVolume = interp1(x,AllVolume,xi,ScrubbingMethod);
        end
        nDimTimePoints = size(AllVolume,1);
    end
end

% Detrend
if exist('IsNeedDetrend','var') && IsNeedDetrend==1
    %AllVolume=detrend(AllVolume);
    fprintf('\n\t Detrending...');
    SegmentLength = ceil(size(AllVolume,2) / CUTNUMBER);
    for iCut=1:CUTNUMBER
        if iCut~=CUTNUMBER
            Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
        else
            Segment = (iCut-1)*SegmentLength+1 : size(AllVolume,2);
        end
        AllVolume(:,Segment) = detrend(AllVolume(:,Segment));
        fprintf('.');
    end
end

% Filtering
if exist('Band','var') && ~isempty(Band)
    fprintf('\n\t Filtering...');
    SegmentLength = ceil(size(AllVolume,2) / CUTNUMBER);
    for iCut=1:CUTNUMBER
        if iCut~=CUTNUMBER
            Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
        else
            Segment = (iCut-1)*SegmentLength+1 : size(AllVolume,2);
        end
        AllVolume(:,Segment) = y_IdealFilter(AllVolume(:,Segment), TR, Band);
        fprintf('.');
    end
end



% Scrubbing after filtering
if exist('TemporalMask','var') && ~isempty(TemporalMask) && strcmpi(ScrubbingTiming,'AfterFiltering')
    if ~all(TemporalMask)
        AllVolume = AllVolume(find(TemporalMask),:); %'cut'
        if ~strcmpi(ScrubbingMethod,'cut')
            xi=1:length(TemporalMask);
            x=xi(find(TemporalMask));
            AllVolume = interp1(x,AllVolume,xi,ScrubbingMethod);
        end
        nDimTimePoints = size(AllVolume,1);
    end
end

AllVolumeBrain = zeros(nDimTimePoints, nDim1*nDim2*nDim3);
AllVolumeBrain(:,find(MaskDataOneDim)) = AllVolume;
AllVolumeBrain=reshape(AllVolumeBrain',[nDim1, nDim2, nDim3, nDimTimePoints]);

Header_Out = Header;
Header_Out.pinfo = [1;0;0];
Header_Out.dt    = [16,0];
Header_Out.dim   = [nDim1, nDim2, nDim3, nDimTimePoints];

y_Write(AllVolumeBrain,Header_Out,OutputName);

