function [DegreeCentrality_PositiveWeightedSumBrain, DegreeCentrality_PositiveBinarizedSumBrain, Header] = y_DegreeCentrality(AllVolume, rThreshold, OutputName, MaskData, IsNeedDetrend, Band, TR, TemporalMask, ScrubbingMethod, ScrubbingTiming, Header, CUTNUMBER)
% [DegreeCentrality_PositiveWeightedSumBrain, DegreeCentrality_PositiveBinarizedSumBrain, Header] = y_DegreeCentrality(AllVolume, rThreshold, OutputName, MaskData, IsNeedDetrend, Band, TR, TemporalMask, ScrubbingMethod, ScrubbingTiming, Header, CUTNUMBER)
% Calculate Degree Centrality
% Ref: Buckner, R.L., Sepulcre, J., Talukdar, T., Krienen, F.M., Liu, H., Hedden, T., Andrews-Hanna, J.R., Sperling, R.A., Johnson, K.A., 2009. Cortical hubs revealed by intrinsic functional connectivity: mapping, assessment of stability, and relation to Alzheimer's disease. J Neurosci 29, 1860-1873.
%      Zuo, X.N., Ehmke, R., Mennes, M., Imperati, D., Castellanos, F.X., Sporns, O., Milham, M.P., 2012. Network Centrality in the Human Functional Connectome. Cereb Cortex 22, 1862-1875.
% Input:
% 	AllVolume		-	4D data matrix (DimX*DimY*DimZ*DimTimePoints) or the directory of 3D image data file or the filename of one 4D data file
%   rThreshold      -   The r (correlation) threshold for Degree Centrality calculation (sum of r > rThreshold).
%	OutputName  	-	Output filename. Could be 
%                            2*1 cells: for DegreeCentrality_PositiveWeightedSumBrain and DegreeCentrality_PositiveBinarizedSumBrain results respectively
%                       or   string: will be seperated by suffix: _DegreeCentrality_PositiveWeightedSumBrain and _DegreeCentrality_PositiveBinarizedSumBrain
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
%	DegreeCentrality_PositiveWeightedSumBrain       -   The Degree Centrality results Weighted sum of those r with r > rThreshold
%	DegreeCentrality_PositiveBinarizedSumBrain      -   The Degree Centrality results Binarized sum of those r with r > rThreshold (i.e., count the number of r > rThreshold)
%   Header          -   The NIfTI Header
%   The Degree Centrality image will be output as where OutputName specified.
%-----------------------------------------------------------
% Written by YAN Chao-Gan 120216.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com

if ~exist('CUTNUMBER','var')
    CUTNUMBER = 10;
end

theElapsedTime =cputime;
fprintf('\nComputing Degree Centrality...');

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

MaskDataOneDim=reshape(MaskData,1,[]);
MaskIndex = find(MaskDataOneDim);

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

% ZeroMeanOneStd
AllVolume = (AllVolume-repmat(mean(AllVolume),size(AllVolume,1),1))./repmat(std(AllVolume),size(AllVolume,1),1);   %Zero mean and one std
AllVolume(isnan(AllVolume))=0;

DegreeCentrality_PositiveWeightedSum = zeros(length(MaskIndex),1);
DegreeCentrality_PositiveBinarizedSum = zeros(length(MaskIndex),1);

% DegreeCentrality_NegativeWeightedSum = zeros(length(MaskIndex),1);
% DegreeCentrality_NegativeBinarizedSum = zeros(length(MaskIndex),1);



% Degree Centrality Calculating
CUTNUMBER = 30*CUTNUMBER; % More cut needed for degree centrality calculation
fprintf('\n\t Degree Centrality Calculating...');
SegmentLength = ceil(size(AllVolume,2) / CUTNUMBER);
CUTNUMBER = ceil(size(AllVolume,2) / SegmentLength); % Revise CUTNUMBER in case SegmentLength*CUTNUMBER is too bigger than size(AllVolume,2)

for iCut=1:CUTNUMBER
    if iCut~=CUTNUMBER
        Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
    else
        Segment = (iCut-1)*SegmentLength+1 : size(AllVolume,2);
    end
    
    FC_Segment = AllVolume(:,Segment)'*AllVolume/(nDimTimePoints-1);
    
    DegreeCentrality_PositiveWeightedSum(Segment) = sum(FC_Segment.*(FC_Segment > rThreshold),2);
    DegreeCentrality_PositiveBinarizedSum(Segment) = sum(FC_Segment > rThreshold,2);
    
%     DegreeCentrality_NegativeWeightedSum(Segment) = sum(FC_Segment(FC_Segment < rThreshold),2);
%     DegreeCentrality_NegativeBinarizedSum(Segment) = sum(FC_Segment < rThreshold,2);
    fprintf('.');
    %fprintf('Block: %d. ',iCut);
end

DegreeCentrality_PositiveWeightedSum = DegreeCentrality_PositiveWeightedSum - 1; % -1 because we need to substarct the r with itself
DegreeCentrality_PositiveBinarizedSum = DegreeCentrality_PositiveBinarizedSum - 1; % -1 because we need to substarct the r with itself


DegreeCentrality_PositiveWeightedSumBrain=zeros(size(MaskDataOneDim));
DegreeCentrality_PositiveWeightedSumBrain(1,find(MaskDataOneDim))=DegreeCentrality_PositiveWeightedSum;
DegreeCentrality_PositiveWeightedSumBrain=reshape(DegreeCentrality_PositiveWeightedSumBrain,nDim1, nDim2, nDim3);

DegreeCentrality_PositiveBinarizedSumBrain=zeros(size(MaskDataOneDim));
DegreeCentrality_PositiveBinarizedSumBrain(1,find(MaskDataOneDim))=DegreeCentrality_PositiveBinarizedSum;
DegreeCentrality_PositiveBinarizedSumBrain=reshape(DegreeCentrality_PositiveBinarizedSumBrain,nDim1, nDim2, nDim3);

% DegreeCentrality_NegativeWeightedSumBrain=zeros(size(MaskDataOneDim));
% DegreeCentrality_NegativeWeightedSumBrain(1,find(MaskDataOneDim))=DegreeCentrality_NegativeWeightedSum;
% DegreeCentrality_NegativeWeightedSumBrain=reshape(DegreeCentrality_NegativeWeightedSumBrain,nDim1, nDim2, nDim3);
% 
% DegreeCentrality_NegativeBinarizedSumBrain=zeros(size(MaskDataOneDim));
% DegreeCentrality_NegativeBinarizedSumBrain(1,find(MaskDataOneDim))=DegreeCentrality_NegativeBinarizedSum;
% DegreeCentrality_NegativeBinarizedSumBrain=reshape(DegreeCentrality_NegativeBinarizedSumBrain,nDim1, nDim2, nDim3);

Header.pinfo = [1;0;0];
Header.dt    =[16,0];
Header.descrip=sprintf('rThreshold{%g}',rThreshold);

if ischar(OutputName)
    [pathstr, name, ext] = fileparts(OutputName);
    OutputName_PositiveWeightedSumBrain = fullfile(pathstr,[name,'_DegreeCentrality_PositiveWeightedSumBrain',ext]);
    OutputName_PositiveBinarizedSumBrain = fullfile(pathstr,[name,'_DegreeCentrality_PositiveBinarizedSumBrain',ext]);
elseif iscell(OutputName)
    OutputName_PositiveWeightedSumBrain = OutputName{1};
    OutputName_PositiveBinarizedSumBrain = OutputName{2};
end

y_Write(DegreeCentrality_PositiveWeightedSumBrain,Header,OutputName_PositiveWeightedSumBrain);
y_Write(DegreeCentrality_PositiveBinarizedSumBrain,Header,OutputName_PositiveBinarizedSumBrain);


theElapsedTime = cputime - theElapsedTime;
fprintf('\nDegree Centrality compution over, elapsed time: %g seconds.\n', theElapsedTime);
