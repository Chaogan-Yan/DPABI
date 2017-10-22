function [ReHoBrain_AllWindow, Header] = y_reho_Window(WindowSize, WindowStep, WindowType, AllVolume, NVoxel, AMaskFilename, AResultFilename, IsNeedDetrend, Band, TR, TemporalMask, ScrubbingMethod, ScrubbingTiming, Header, CUTNUMBER)
% Calculate dynamic regional homogeneity (i.e. ReHo)
% FORMAT     [ReHoBrain_AllWindow, Header] = y_reho_Window(WindowSize, WindowStep, WindowType, AllVolume, NVoxel, AMaskFilename, AResultFilename, IsNeedDetrend, Band, TR, TemporalMask, ScrubbingMethod, ScrubbingTiming, Header, CUTNUMBER)
% Input:
%   WindowSize      -   the size of the sliding window
%   WindowStep      -   the step size
%   WindowType      -   the type of window (e.g., hamming)
% 	AllVolume		-	4D data matrix (DimX*DimY*DimZ*DimTimePoints) or the directory of 3D image data file or the filename of one 4D data file
%   NVoxel              The number of the voxel for a given cluster during calculating the KCC (e.g. 27, 19, or 7); Recommand: NVoxel=27;
% 	AMaskFilename		the mask file name, I only compute the point within the mask
%	AResultFilename		the output filename
%   IsNeedDetrend       0: Dot not detrend; 1: Use Matlab's detrend
%   Band                Temporal filter band: matlab's ideal filter e.g. [0.01 0.08]
%   TR                  The TR of scanning. (Used for filtering.)
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
%	ReHoBrain_AllWindow       -   The ReHo results of the windows
%   Header          -   The NIfTI Header
%	AResultFilename	the filename of ReHo result
%___________________________________________________________________________
% Written by YAN Chao-Gan 171001 based on y_reho.m.
% The R-fMRI Lab, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com

if ~exist('CUTNUMBER','var')
    CUTNUMBER = 10;
end


theElapsedTime =cputime;

% Examine the Nvoxel
% --------------------------------------------------------------------------
if NVoxel ~= 27 & NVoxel ~= 19 & NVoxel ~= 7 
    error('The second parameter should be 7, 19 or 27. Please re-exmamin it.');
end

% Read the functional images 
% -------------------------------------------------------------------------
fprintf('\n\t Read these 3D EPI functional images.\twait...');

if ~isnumeric(AllVolume)
    [AllVolume,vsize,theImgFileList, Header] =y_ReadAll(AllVolume);
end

[nDim1 nDim2 nDim3 nDimTimePoints]=size(AllVolume);
M=nDim1;N=nDim2;O=nDim3;

fprintf('\nLoad mask "%s".\n', AMaskFilename);
if ~isempty(AMaskFilename)
    [mask,MaskVox,MaskHead]=y_ReadRPI(AMaskFilename);
    if ~all(size(mask)==[nDim1 nDim2 nDim3])
        error('The size of Mask (%dx%dx%d) doesn''t match the required size (%dx%dx%d).\n',size(mask), [nDim1 nDim2 nDim3]);
    end
    mask = double(logical(mask));
else
    mask=ones(nDim1,nDim2,nDim3);
end

%Algorithm re-written by YAN Chao-Gan, 090422. Speed up the calculation of ReHo.
%rank the 3d+time functional images voxel by voxel
% -------------------------------------------------------------------------
AllVolume=reshape(AllVolume,[],nDimTimePoints)';

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

ReHoBrain_AllWindow = zeros([nDim1 nDim2 nDim3 nWindow]);

if ischar(WindowType)
    eval(['WindowType = ',WindowType,'(WindowSize);'])
end
WindowMultiplier = repmat(WindowType(:),1,size(AllVolume,2));

for iWindow = 1:nWindow
    fprintf('\nProcessing window %g of total %g windows\n', iWindow, nWindow);
    
    AllVolumeWindow = AllVolume((iWindow-1)*WindowStep+1:(iWindow-1)*WindowStep+WindowSize,:);
    AllVolumeWindow = AllVolumeWindow.*WindowMultiplier;
    
    % Calcualte the rank
    
    fprintf('\n\t Rank calculating...');
    
    %YAN Chao-Gan, 120328. No longer change to uint16 type.
    Ranks_AllVolume = repmat(zeros(1,size(AllVolumeWindow,2)), [size(AllVolumeWindow,1), 1]);
    
    SegmentLength = ceil(size(AllVolumeWindow,2) / CUTNUMBER);
    for iCut=1:CUTNUMBER
        if iCut~=CUTNUMBER
            Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
        else
            Segment = (iCut-1)*SegmentLength+1 : size(AllVolumeWindow,2);
        end
        
        AllVolume_Piece = AllVolumeWindow(:,Segment);
        nVoxels_Piece = size(AllVolume_Piece,2);
        
        [AllVolume_Piece,SortIndex] = sort(AllVolume_Piece,1);
        db=diff(AllVolume_Piece,1,1);
        db = db == 0;
        sumdb=sum(db,1);
        
        %YAN Chao-Gan, 120328. No longer change to uint16 type.
        SortedRanks = repmat([1:nDimTimePoints_WithinWindow]',[1,nVoxels_Piece]);
        %SortedRanks = repmat(uint16([1:nDimTimePoints_WithinWindow]'),[1,nVoxels_Piece]);
        % For those have the same values at the current time point and previous time point (ties)
        if any(sumdb(:))
            TieAdjustIndex=find(sumdb);
            for i=1:length(TieAdjustIndex)
                ranks=SortedRanks(:,TieAdjustIndex(i));
                ties=db(:,TieAdjustIndex(i));
                tieloc = [find(ties); nDimTimePoints_WithinWindow+2];
                maxTies = numel(tieloc);
                tiecount = 1;
                while (tiecount < maxTies)
                    tiestart = tieloc(tiecount);
                    ntied = 2;
                    while(tieloc(tiecount+1) == tieloc(tiecount)+1)
                        tiecount = tiecount+1;
                        ntied = ntied+1;
                    end
                    % Compute mean of tied ranks
                    ranks(tiestart:tiestart+ntied-1) = ...
                        sum(ranks(tiestart:tiestart+ntied-1)) / ntied;
                    tiecount = tiecount + 1;
                end
                SortedRanks(:,TieAdjustIndex(i))=ranks;
            end
        end
        clear db sumdb;
        SortIndexBase = repmat([0:nVoxels_Piece-1].*nDimTimePoints_WithinWindow,[nDimTimePoints_WithinWindow,1]);
        SortIndex=SortIndex+SortIndexBase;
        clear SortIndexBase;
        Ranks_Piece = zeros(nDimTimePoints_WithinWindow,nVoxels_Piece);
        Ranks_Piece(SortIndex)=SortedRanks;
        clear SortIndex SortedRanks;
        
        %YAN Chao-Gan, 120328. No longer change to uint16 type.
        %Ranks_Piece=uint16(Ranks_Piece); % Change to uint16 to get the same results of previous version.
        
        Ranks_AllVolume(:,Segment) = Ranks_Piece;
        fprintf('.');
    end
    
    Ranks_AllVolume = reshape(Ranks_AllVolume,[nDimTimePoints_WithinWindow,nDim1 nDim2 nDim3]);
    
    
    % calulate the kcc for the data set
    % ------------------------------------------------------------------------
    fprintf('\n\t Calculate the kcc on voxel by voxel for the data set.');
    K = zeros(M,N,O);
    switch NVoxel
        case 27
            for i = 2:M-1
                for j = 2:N-1
                    for k = 2:O-1
                        block = Ranks_AllVolume(:,i-1:i+1,j-1:j+1,k-1:k+1);
                        mask_block = mask(i-1:i+1,j-1:j+1,k-1:k+1);
                        if mask_block(2,2,2)~=0
                            %YAN Chao-Gan 090717, We also calculate the ReHo value of the voxels near the border of the brain mask, users should be cautious when dicussing the results near the border. %if all(mask_block(:))
                            R_block=reshape(block,[],27); %Revised by YAN Chao-Gan, 090420. Speed up the calculation.
                            mask_R_block = R_block(:,reshape(mask_block,1,27) > 0);
                            K(i,j,k) = f_kendall(mask_R_block);
                        end %end if
                    end%end k
                end% end j
                fprintf('.');
            end%end i
            fprintf('\t The reho of the data set was finished.\n');
        case 19
            mask_cluster_19=ones(3,3,3);
            mask_cluster_19(1,1,1) = 0;    mask_cluster_19(1,3,1) = 0;    mask_cluster_19(3,1,1) = 0;    mask_cluster_19(3,3,1) = 0;
            mask_cluster_19(1,1,3) = 0;    mask_cluster_19(1,3,3) = 0;    mask_cluster_19(3,1,3) = 0;    mask_cluster_19(3,3,3) = 0;
            %Revised by YAN Chao-Gan, 090420. The element in the mask could be 1 other than 127. Fixed the bug of computing ReHo with 7 voxels or 19 voxels.
            for i = 2:M-1
                for j = 2:N-1
                    for k = 2:O-1
                        block = Ranks_AllVolume(:,i-1:i+1,j-1:j+1,k-1:k+1);
                        mask_block = mask(i-1:i+1,j-1:j+1,k-1:k+1);
                        if mask_block(2,2,2)~=0
                            %YAN Chao-Gan 090717, We also calculate the ReHo value of the voxels near the border of the brain mask, users should be cautious when dicussing the results near the border. %if all(mask_block(:))
                            mask_block=mask_block.*mask_cluster_19;
                            %Revised by YAN Chao-Gan, 090419. The element in the mask could be 1 other than 127. Fixed the bug of computing ReHo with 7 voxels or 19 voxels.
                            R_block=reshape(block,[],27);  %Revised by YAN Chao-Gan, 090420. Speed up the calculation.
                            mask_R_block = R_block(:,reshape(mask_block,1,27) > 0); %Revised by YAN Chao-Gan, 090419. The element in the mask could be 1 other than 127. Fixed the bug of computing ReHo with 7 voxels or 19 voxels. %> 2);
                            K(i,j,k) = f_kendall(mask_R_block);
                        end%end if
                    end%end k
                end%end j
                fprintf('.');
            end%end i
            fprintf('\t The reho of the data set was finished.\n');
        case 7
            mask_cluster_7=ones(3,3,3);
            mask_cluster_7(1,1,1) = 0;    mask_cluster_7(1,2,1) = 0;     mask_cluster_7(1,3,1) = 0;      mask_cluster_7(1,1,2) = 0;
            mask_cluster_7(1,3,2) = 0;    mask_cluster_7(1,1,3) = 0;     mask_cluster_7(1,2,3) = 0;      mask_cluster_7(1,3,3) = 0;
            mask_cluster_7(2,1,1) = 0;    mask_cluster_7(2,3,1) = 0;     mask_cluster_7(2,1,3) = 0;      mask_cluster_7(2,3,3) = 0;
            mask_cluster_7(3,1,1) = 0;    mask_cluster_7(3,2,1) = 0;     mask_cluster_7(3,3,1) = 0;      mask_cluster_7(3,1,2) = 0;
            mask_cluster_7(3,3,2) = 0;    mask_cluster_7(3,1,3) = 0;     mask_cluster_7(3,2,3) = 0;      mask_cluster_7(3,3,3) = 0;
            %Revised by YAN Chao-Gan, 090420. The element in the mask could be 1 other than 127. Fixed the bug of computing ReHo with 7 voxels or 19 voxels.
            for i = 2:M-1
                for j = 2:N-1
                    for k = 2:O-1
                        block = Ranks_AllVolume(:,i-1:i+1,j-1:j+1,k-1:k+1);
                        mask_block = mask(i-1:i+1,j-1:j+1,k-1:k+1);
                        if mask_block(2,2,2)~=0
                            %YAN Chao-Gan 090717, We also calculate the ReHo value of the voxels near the border of the brain mask, users should be cautious when dicussing the results near the border. %if all(mask_block(:))
                            mask_block=mask_block.*mask_cluster_7;
                            %Revised by YAN Chao-Gan, 090419. The element in the mask could be 1 other than 127. Fixed the bug of computing ReHo with 7 voxels or 19 voxels.
                            R_block=reshape(block,[],27); %Revised by YAN Chao-Gan, 090420. Speed up the calculation.
                            mask_R_block = R_block(:,reshape(mask_block,1,27) > 0); %Revised by YAN Chao-Gan, 090419. The element in the mask could be 1 other than 127. Fixed the bug of computing ReHo with 7 voxels or 19 voxels. %> 2);
                            K(i,j,k) = f_kendall(mask_R_block);
                        end%end if
                    end%end k
                end%end j
                fprintf('.');
            end%end i
            fprintf('\t The reho of the data set was finished.\n');
        otherwise
            error('The second parameter should be 7, 19 or 27. Please re-exmamin it.');
    end %end switch
    ReHoBrain = K;
    
    ReHoBrain_AllWindow(:,:,:,iWindow) = ReHoBrain;
end

Header.pinfo = [1;0;0];
Header.dt    =[16,0];

y_Write(ReHoBrain_AllWindow,Header,AResultFilename);


theElapsedTime =cputime - theElapsedTime;
fprintf('\n\tRegional Homogeneity computation over, elapsed time: %g seconds\n', theElapsedTime);






% calculate kcc for a time series
%---------------------------------------------------------------------------
function B = f_kendall(A)
nk = size(A); n = nk(1); k = nk(2);
SR = sum(A,2); SRBAR = mean(SR);
S = sum(SR.^2) - n*SRBAR^2;
B = 12*S/k^2/(n^3-n);
