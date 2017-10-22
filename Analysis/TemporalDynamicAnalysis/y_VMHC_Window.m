function [VMHCBrain_AllWindow, zVMHCBrain_AllWindow, Header] = y_VMHC_Window(WindowSize, WindowStep, WindowType, AllVolume, OutputName, MaskData, IsNeedDetrend, Band, TR, TemporalMask, ScrubbingMethod, ScrubbingTiming, Header)
% [VMHCBrain_AllWindow, zVMHCBrain_AllWindow, Header] = y_VMHC_Window(WindowSize, WindowStep, WindowType, AllVolume, OutputName, MaskData, IsNeedDetrend, Band, TR, TemporalMask, ScrubbingMethod, ScrubbingTiming, Header)
% Calculate dynamic VMHC
% Input:
%   WindowSize      -   the size of the sliding window
%   WindowStep      -   the step size
%   WindowType      -   the type of window (e.g., hamming)
% 	AllVolume		-	4D data matrix (DimX*DimY*DimZ*DimTimePoints) or the directory of 3D image data file or the filename of one 4D data file
%	OutputName  	-	Output filename
% 	MaskData		-   Mask matrix (DimX*DimY*DimZ) or the mask file name
%   IsNeedDetrend   -   0: Dot not detrend; 1: Use Matlab's detrend
%   Band            -   Temporal filter band: matlab's ideal filter e.g. [0.01 0.08]
%   TR              -   The TR of scanning. (Used for filtering.)
%   TemporalMask    -   Temporal mask for scrubbing (DimTimePoints*1)
%                   -   Empty (blank: '' or []) means do not need scrube. Then ScrubbingMethod and ScrubbingTiming can leave blank
%   ScrubbingMethod -   The methods for scrubbing.
%                       -1. 'cut': discarding the timepoints with TemporalMask == 0
%                       -2. 'nearest': interpolate the timepoints with TemporalMask == 0 by Nearest neighbor interpolation 
%                       -3. 'linear': interpolate the timepoints with TemporalMask == 0 by Linear interpolation
%                       -4. 'spline': interpolate the timepoints with TemporalMask == 0 by Cubic spline interpolation
%                       -5. 'pchip': interpolate the timepoints with TemporalMask == 0 by Piecewise cubic Hermite interpolation
%   ScrubbingTiming -   The timing for scrubbing.
%                       -1. 'BeforeFiltering': scrubbing (and interpolation, if) before detrend (if) and filtering (if).
%                       -2. 'AfterFiltering': scrubbing after filtering, right before extract ROI TC and FC analysis
%   Header          -   If AllVolume is given as a 4D Brain matrix, then Header should be designated.
%   CUTNUMBER       -   Cut the data into pieces if small RAM memory e.g. 4GB is available on PC. It can be set to 1 on server with big memory (e.g., 50GB).
%                       default: 10
% Output:
%	VMHCBrain_AllWindow        -   The VHMC results of the windows
%	zVMHCBrain_AllWindow       -   The VHMC results of the windows after Fisher's r to z transformation
%   Header          -   The NIfTI Header
%   The VMHC image will be output as where OutputName specified.
%-----------------------------------------------------------
% Written by YAN Chao-Gan 171001 based on y_VMHC.m.
% The R-fMRI Lab, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com

if ~exist('CUTNUMBER','var')
    CUTNUMBER = 10;
end

theElapsedTime =cputime;
fprintf('\nComputing VMHC...');

if ~isnumeric(AllVolume)
    [AllVolume,VoxelSize,theImgFileList, Header] =y_ReadAll(AllVolume);
end

[nDim1 nDim2 nDim3 nDimTimePoints]=size(AllVolume);
BrainSize = [nDim1 nDim2 nDim3];
VoxelSize = sqrt(sum(Header.mat(1:3,1:3).^2));

if ischar(MaskData)
    if ~isempty(MaskData)
        [MaskData,MaskVox,MaskHead]=y_ReadRPI(MaskData);
        
        %Make the mask symmetric
        MaskData = logical(MaskData + flipdim(MaskData,1));
    else
        MaskData=ones(nDim1,nDim2,nDim3);
    end
end

% Convert into 2D
AllVolume=reshape(AllVolume,[],nDimTimePoints)';

MaskDataOneDim=reshape(MaskData,1,[]);
MaskIndex = find(MaskDataOneDim);

AllVolume=AllVolume(:,find(MaskDataOneDim));

% Get the flipped Index
Index3D_Flipped=zeros(size(MaskDataOneDim));
Index3D_Flipped(1,MaskIndex)=MaskIndex;
Index3D_Flipped=reshape(Index3D_Flipped,nDim1, nDim2, nDim3);
Index3D_Flipped = flipdim(Index3D_Flipped,1); %This is the fliped mask with the index for 3D Brain

Index2D_Flipped_Masked = Index3D_Flipped(MaskIndex); %Only chose those within the mask, the index is still for 3D Brain

%Convert the index for 3D Brain to the index for the 2D Mask (Note: the index length is reduced for the latter)
[MaskIndexSort MaskIndexIX]=sort(MaskIndex);
[Index2D_Flipped_MaskedSort Index2D_Flipped_MaskedIX]=sort(Index2D_Flipped_Masked);
Flipped_Masked_Index_In_UnFlippedMask(Index2D_Flipped_MaskedIX)=MaskIndexIX;



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


nWindow = fix((nDimTimePoints - WindowSize)/WindowStep) + 1;
nDimTimePoints_WithinWindow = WindowSize;

VMHCBrain_AllWindow = zeros([nDim1 nDim2 nDim3 nWindow]);

if ischar(WindowType)
    eval(['WindowType = ',WindowType,'(WindowSize);'])
end
WindowMultiplier = repmat(WindowType(:),1,size(AllVolume,2));

for iWindow = 1:nWindow
    fprintf('\nProcessing window %g of total %g windows\n', iWindow, nWindow);
    
    AllVolumeWindow = AllVolume((iWindow-1)*WindowStep+1:(iWindow-1)*WindowStep+WindowSize,:);
    AllVolumeWindow = AllVolumeWindow.*WindowMultiplier;
    
    % ZeroMeanOneStd
    AllVolumeWindow = (AllVolumeWindow-repmat(mean(AllVolumeWindow),size(AllVolumeWindow,1),1))./repmat(std(AllVolumeWindow),size(AllVolumeWindow,1),1);   %Zero mean and one std
    AllVolumeWindow(isnan(AllVolumeWindow))=0;
    
    AllVolume_Flipped = AllVolumeWindow(:,Flipped_Masked_Index_In_UnFlippedMask);
    
    VMHC = zeros(length(MaskIndex),1);
    for iVoxel=1:length(MaskIndex)
        VMHC(iVoxel) = AllVolumeWindow(:,iVoxel)' * AllVolume_Flipped(:,iVoxel) / (nDimTimePoints_WithinWindow - 1);
    end
    
    VMHCBrain=zeros(size(MaskDataOneDim));
    VMHCBrain(1,find(MaskDataOneDim))=VMHC;
    VMHCBrain=reshape(VMHCBrain,nDim1, nDim2, nDim3);
    
    VMHCBrain(fix(nDim1/2) + 1,:,:) = 0; %Added by YAN Chao-Gan, 130611. Put the midline voxels to zero.
    
    VMHCBrain_AllWindow(:,:,:,iWindow) = VMHCBrain;

end

Header.pinfo = [1;0;0];
Header.dt    =[16,0];

y_Write(VMHCBrain_AllWindow,Header,OutputName);

zVMHCBrain_AllWindow = (0.5 * log((1 + VMHCBrain_AllWindow)./(1 - VMHCBrain_AllWindow)));
[pathstr, name, ext] = fileparts(OutputName);
y_Write(zVMHCBrain_AllWindow,Header,[fullfile(pathstr,['z',name, ext])]);

theElapsedTime = cputime - theElapsedTime;
fprintf('\nVMHC compution over, elapsed time: %g seconds.\n', theElapsedTime);
