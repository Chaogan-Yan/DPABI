function [ALFFBrain_AllWindow, fALFFBrain_AllWindow, Header] = y_alff_falff_Window(WindowSize, WindowStep, WindowType, AllVolume,ASamplePeriod, HighCutoff, LowCutoff, AMaskFilename, AResultFilename, TemporalMask, ScrubbingMethod, Header, CUTNUMBER)
% Calculate dynamic ALFF and fALFF
% FORMAT    [ALFFBrain_AllWindow, fALFFBrain_AllWindow, Header] = y_alff_falff_Window(WindowSize, WindowStep, WindowType, AllVolume,ASamplePeriod, HighCutoff, LowCutoff, AMaskFilename, AResultFilename, TemporalMask, ScrubbingMethod, Header, CUTNUMBER)
% Input:
%   WindowSize      -   the size of the sliding window
%   WindowStep      -   the step size
%   WindowType      -   the type of window (e.g., hamming)
% 	AllVolume		-	4D data matrix (DimX*DimY*DimZ*DimTimePoints) or the directory of 3D image data file or the filename of one 4D data file
% 	ASamplePeriod		TR, or like the variable name
% 	LowCutoff			the low edge of the pass band
% 	HighCutoff			the High edge of the pass band
% 	AMaskFilename		the mask file name, I only compute the point within the mask
%	AResultFilename		the output filename. Could be 
%                            2*1 cells: for ALFF and fALFF results respectively
%                       or   string: name for ALFF. fALFF results will have a surfix 'f' on this name.
%   TemporalMask    -   Temporal mask for scrubbing (DimTimePoints*1)
%                   -   Empty (blank: '' or []) means do not need scrube. Then ScrubbingMethod can leave blank
%   ScrubbingMethod -   The methods for scrubbing.
%                       -1. 'cut': discarding the timepoints with TemporalMask == 0
%                       -2. 'nearest': interpolate the timepoints with TemporalMask == 0 by Nearest neighbor interpolation 
%                       -3. 'linear': interpolate the timepoints with TemporalMask == 0 by Linear interpolation
%                       -4. 'spline': interpolate the timepoints with TemporalMask == 0 by Cubic spline interpolation
%                       -5. 'pchip': interpolate the timepoints with TemporalMask == 0 by Piecewise cubic Hermite interpolation
%   Header          -   If AllVolume is given as a 4D Brain matrix, then Header should be designated.
%   CUTNUMBER           Cut the data into pieces if small RAM memory e.g. 4GB is available on PC. It can be set to 1 on server with big memory (e.g., 50GB).
%                       default: 10
% Output:
%	ALFFBrain_AllWindow       -   The ALFF results of the windows
%   fALFFBrain_AllWindow      -   The fALFF results of the windows
%   Header          -   The NIfTI Header
%	AResultFilename	the filename of ALFF and fALFF results.
%___________________________________________________________________________
% Written by YAN Chao-Gan 171001 based on y_alff_falff.m.
% The R-fMRI Lab, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com

if ~exist('CUTNUMBER','var')
    CUTNUMBER = 10;
end

theElapsedTime =cputime;

fprintf('\nComputing ALFF...');

if ~isnumeric(AllVolume)
    [AllVolume,VoxelSize,theImgFileList, Header] = y_ReadAll(AllVolume);
end

[nDim1 nDim2 nDim3 nDimTimePoints]=size(AllVolume);
BrainSize = [nDim1 nDim2 nDim3];
VoxelSize = sqrt(sum(Header.mat(1:3,1:3).^2));

fprintf('\nLoad mask "%s".\n', AMaskFilename);
if ~isempty(AMaskFilename)
    [MaskData,MaskVox,MaskHead]=y_ReadRPI(AMaskFilename);
    if ~all(size(MaskData)==[nDim1 nDim2 nDim3])
        error('The size of Mask (%dx%dx%d) doesn''t match the required size (%dx%dx%d).\n',size(MaskData,1),size(MaskData,2),size(MaskData,3), nDim1, nDim2, nDim3);
    end
    MaskData = double(logical(MaskData));
else
    MaskData=ones(nDim1,nDim2,nDim3);
end

% Convert into 2D
AllVolume=reshape(AllVolume,[],nDimTimePoints)';

MaskDataOneDim=reshape(MaskData,1,[]);
AllVolume=AllVolume(:,find(MaskDataOneDim));

% Scrubbing
if exist('TemporalMask','var') && ~isempty(TemporalMask)
    if ~all(TemporalMask)
        fprintf('\n\t Scrubbing...');
        AllVolume = AllVolume(find(TemporalMask),:); %'cut'
        if ~strcmpi(ScrubbingMethod,'cut')
            xi=1:length(TemporalMask);
            x=xi(find(TemporalMask));
            AllVolume = interp1(x,AllVolume,xi,ScrubbingMethod);
        end
        nDimTimePoints = size(AllVolume,1);
    end
end


% Get the frequency index
sampleFreq 	 = 1/ASamplePeriod;
%sampleLength = nDimTimePoints;
sampleLength = WindowSize; %Now the length is the widonw size
paddedLength = 2^nextpow2(sampleLength);
%paddedLength = rest_nextpow2_one35(sampleLength); %2^nextpow2(sampleLength);
if (LowCutoff >= sampleFreq/2) % All high included
    idx_LowCutoff = paddedLength/2 + 1;
else % high cut off, such as freq > 0.01 Hz
    idx_LowCutoff = ceil(LowCutoff * paddedLength * ASamplePeriod + 1);
    % Change from round to ceil: idx_LowCutoff = round(LowCutoff *paddedLength *ASamplePeriod + 1);
end
if (HighCutoff>=sampleFreq/2)||(HighCutoff==0) % All low pass
    idx_HighCutoff = paddedLength/2 + 1;
else % Low pass, such as freq < 0.08 Hz
    idx_HighCutoff = fix(HighCutoff *paddedLength *ASamplePeriod + 1);
    % Change from round to fix: idx_HighCutoff	=round(HighCutoff *paddedLength *ASamplePeriod + 1);
end


%First detrend all
% Detrend before fft as did in the previous alff.m
%AllVolume=detrend(AllVolume);
% Cut to be friendly with the RAM Memory
SegmentLength = ceil(size(AllVolume,2) / CUTNUMBER);
for iCut=1:CUTNUMBER
    if iCut~=CUTNUMBER
        Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
    else
        Segment = (iCut-1)*SegmentLength+1 : size(AllVolume,2);
    end
    AllVolume(:,Segment) = detrend(AllVolume(:,Segment));
end




nWindow = fix((nDimTimePoints - WindowSize)/WindowStep) + 1;

ALFFBrain_AllWindow = zeros([nDim1 nDim2 nDim3 nWindow]);
fALFFBrain_AllWindow = zeros([nDim1 nDim2 nDim3 nWindow]);

if ischar(WindowType)
    eval(['WindowType = ',WindowType,'(WindowSize);'])
end
WindowMultiplier = repmat(WindowType(:),1,size(AllVolume,2));

for iWindow = 1:nWindow
    fprintf('\nProcessing window %g of total %g windows\n', iWindow, nWindow);
    
    AllVolumeWindow = AllVolume((iWindow-1)*WindowStep+1:(iWindow-1)*WindowStep+WindowSize,:);
    AllVolumeWindow = AllVolumeWindow.*WindowMultiplier;
    
    %Detrend
    SegmentLength = ceil(size(AllVolumeWindow,2) / CUTNUMBER);
    for iCut=1:CUTNUMBER
        if iCut~=CUTNUMBER
            Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
        else
            Segment = (iCut-1)*SegmentLength+1 : size(AllVolumeWindow,2);
        end
        AllVolumeWindow(:,Segment) = detrend(AllVolumeWindow(:,Segment));
    end

    
    
    
    
    
    % Zero Padding
    AllVolumeWindow = [AllVolumeWindow;zeros(paddedLength -sampleLength,size(AllVolumeWindow,2))]; %padded with zero
    
    fprintf('\n\t Performing FFT ...');
    %AllVolume = 2*abs(fft(AllVolume))/sampleLength;
    % Cut to be friendly with the RAM Memory
    SegmentLength = ceil(size(AllVolumeWindow,2) / CUTNUMBER);
    for iCut=1:CUTNUMBER
        if iCut~=CUTNUMBER
            Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
        else
            Segment = (iCut-1)*SegmentLength+1 : size(AllVolumeWindow,2);
        end
        AllVolumeWindow(:,Segment) = 2*abs(fft(AllVolumeWindow(:,Segment)))/sampleLength;
        fprintf('.');
    end
    
    
    ALFF_2D = mean(AllVolumeWindow(idx_LowCutoff:idx_HighCutoff,:));
    
    % Get the 3D brain back
    ALFFBrain = zeros(size(MaskDataOneDim));
    ALFFBrain(1,find(MaskDataOneDim)) = ALFF_2D;
    ALFFBrain = reshape(ALFFBrain,nDim1, nDim2, nDim3);
    ALFFBrain_AllWindow(:,:,:,iWindow) = ALFFBrain;
    
    
    % Also generate fALFF
    %fALFF_2D = sum(AllVolumeWindow(idx_LowCutoff:idx_HighCutoff,:)) ./ sum(AllVolumeWindow(2:(paddedLength/2 + 1),:));
    fALFF_2D = sum(AllVolumeWindow(idx_LowCutoff:idx_HighCutoff,:),1) ./ sum(AllVolumeWindow(2:(paddedLength/2 + 1),:),1); %YAN Chao-Gan, 171218. In case there is only one point
    fALFF_2D(~isfinite(fALFF_2D))=0;
    
    % Get the 3D brain back
    fALFFBrain = zeros(size(MaskDataOneDim));
    fALFFBrain(1,find(MaskDataOneDim)) = fALFF_2D;
    fALFFBrain = reshape(fALFFBrain,nDim1, nDim2, nDim3);
    
    fALFFBrain_AllWindow(:,:,:,iWindow) = fALFFBrain;
    
end


%Save ALFF and fALFF image to disk
if ischar(AResultFilename)
    AResultFilename_ALFF = AResultFilename;
    [pathstr, name, ext] = fileparts(AResultFilename);
    AResultFilename_fALFF = fullfile(pathstr,['f',name,ext]);
elseif iscell(AResultFilename)
    AResultFilename_ALFF = AResultFilename{1};
    AResultFilename_fALFF = AResultFilename{2};
end

Header.pinfo = [1;0;0];
Header.dt    =[16,0];

y_Write(ALFFBrain_AllWindow,Header,AResultFilename_ALFF);
y_Write(fALFFBrain_AllWindow,Header,AResultFilename_fALFF);

theElapsedTime = cputime - theElapsedTime;
fprintf('\n\t ALFF and fALFF compution over, elapsed time: %g seconds.\n', theElapsedTime);

