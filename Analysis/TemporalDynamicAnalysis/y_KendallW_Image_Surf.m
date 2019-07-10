function [KendallWBrain, GHeader] = y_KendallW_Image_Surf(RaterImages, MaskData, AResultFilename)
% Calculate Kendall's W for sets of images. (e.g., different raters or Test Re-Test)
% FORMAT     [KendallWBrain, GHeader] = y_KendallW_Image_Surf(RaterImages, MaskData, AResultFilename)
% Input:
% 	RaterImages     -	Cells of raters (nRater * 1 cells), each rater could be:
%                       1. The directory of 2D image data
%                       2. The filename of one 1D data file
%                       3. a Cell (nFile * 1 cells) of filenames of 1D image data
% 	MaskData		-   the mask file name or 1D mask matrix
%	AResultFilename		the output filename

% Output:
%	KendallWBrain   -   The Kendall's W results
%   Header          -   The GIfTI Header
%	AResultFilename	the filename of Kendall's W result
%___________________________________________________________________________
% Written by YAN Chao-Gan 190704.
% The R-fMRI Lab, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com



theElapsedTime =cputime;

fprintf('\n\tKendall''s W computation Start...\n');

[AllVolume,VoxelSize,theImgFileList, GHeader] = y_ReadAll(RaterImages{1});

[nDimVertex,nDimTimePoints]=size(AllVolume);

if ischar(MaskData)
    if ~isempty(MaskData)
        MaskData=gifti(MaskData);
        MaskData=MaskData.cdata;
        if size(MaskData,1)~=nDimVertex
            error('The size of Mask (%d) doesn''t match the required size (%d).\n',size(MaskData,1), nDimVertex);
        end
        MaskData = double(logical(MaskData));
    else
        MaskData=ones(nDimVertex,1);
    end
end
    
MaskDataOneDim=reshape(MaskData,1,[]);
MaskIndex = find(MaskDataOneDim);

RankSet = repmat((zeros(nDimTimePoints,1)),[1,length(MaskIndex),length(RaterImages)]);

for iRater = 1:length(RaterImages)

    AllVolume = y_ReadAll(RaterImages{iRater});
    % Convert into 2D
    AllVolume=AllVolume';
    AllVolume=AllVolume(:,MaskIndex);
    
    [AllVolume,SortIndex] = sort(AllVolume,1);
    db=diff(AllVolume,1,1);
    clear AllVolume
    db = db == 0;
    sumdb=sum(db,1);
    
    SortedRanks = repmat(([1:nDimTimePoints]'),[1,length(MaskIndex)]);
    % For those have the same values at the current time point and previous time point (ties)
    if any(sumdb(:))
        TieAdjustIndex=find(sumdb);
        for i=1:length(TieAdjustIndex)
            ranks=SortedRanks(:,TieAdjustIndex(i));
            ties=db(:,TieAdjustIndex(i));
            tieloc = [find(ties); nDimTimePoints+2];
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
    SortIndexBase = repmat([0:length(MaskIndex)-1].*nDimTimePoints,[nDimTimePoints,1]);
    SortIndex=SortIndex+SortIndexBase;
    clear SortIndexBase;
    I(SortIndex)=SortedRanks;
    clear SortIndex SortedRanks; 
    
    I = reshape(I,nDimTimePoints,[]);
    
    RankSet(:,:,iRater) = I;
    
end


KendallW = zeros(length(MaskIndex),1);

for iVoxel=1:length(MaskIndex)
    KendallW(iVoxel) = f_kendall(squeeze(RankSet(:,iVoxel,:))); 
end

KendallWBrain=zeros(size(MaskDataOneDim));
KendallWBrain(1,MaskIndex)=KendallW;
KendallWBrain=reshape(KendallWBrain,nDimVertex, []);

y_Write(KendallWBrain, GHeader, AResultFilename);


theElapsedTime =cputime - theElapsedTime;
fprintf('\n\tKendall''s W computation over, elapsed time: %g seconds\n', theElapsedTime);




% calculate kcc for a time series
%---------------------------------------------------------------------------
function B = f_kendall(A)
nk = size(A); n = nk(1); k = nk(2);
SR = sum(A,2); SRBAR = mean(SR);
S = sum(SR.^2) - n*SRBAR^2;
B = 12*S/k^2/(n^3-n);
