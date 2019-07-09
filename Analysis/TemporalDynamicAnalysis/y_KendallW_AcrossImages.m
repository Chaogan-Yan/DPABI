function [KendallW] = y_KendallW_AcrossImages(RaterImages, MaskData, AResultFilename)
% Calculate Kendall's W across images. (e.g., different raters or Test Re-Test)
% FORMAT     [KendallW] = y_KendallW_AcrossImages(RaterImages, MaskData, AResultFilename)
% Input:
% 	RaterImages     -	Cells of raters (nRater * 1 cells), each rater could be:
%                       1. The directory of 3D image data
%                       2. The filename of one 4D data file
%                       3. a Cell (nFile * 1 cells) of filenames of 3D image data
% 	MaskData		-   the mask file name or 3D mask matrix
%	AResultFilename		the output filename

% Output:
%	KendallW   -   The Kendall's W results
%   Header          -   The NIfTI Header
%	AResultFilename	the filename of Kendall's W result
%___________________________________________________________________________
% Written by YAN Chao-Gan 171001.
% The R-fMRI Lab, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com



theElapsedTime =cputime;

fprintf('\n\tKendall''s W computation Start...\n');

[AllVolume,VoxelSize,theImgFileList, Header] = y_ReadAll(RaterImages{1});

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

    
MaskDataOneDim=reshape(MaskData,1,[]);
MaskIndex = find(MaskDataOneDim);



%RankSet = zeros(nDimTimePoints,length(MaskIndex),length(RaterImages));
RankSet = repmat((zeros(length(MaskIndex),1)),[1,nDimTimePoints,length(RaterImages)]);

for iRater = 1:length(RaterImages)

    [AllVolume,VoxelSize,theImgFileList, Header] = y_ReadAll(RaterImages{iRater});
    % Convert into 2D
    AllVolume=reshape(AllVolume,[],nDimTimePoints);
    AllVolume=AllVolume(MaskIndex,:);
    
    [R,TIEADJ] = tiedrank(AllVolume);
    
    
    RankSet(:,:,iRater) = R;
    
end


KendallW = zeros(nDimTimePoints,1);

for iPoint=1:nDimTimePoints
    KendallW(iPoint) = f_kendall(squeeze(RankSet(:,iPoint,:))); 
end

save(AResultFilename, 'KendallW')

theElapsedTime =cputime - theElapsedTime;
fprintf('\n\tKendall''s W computation over, elapsed time: %g seconds\n', theElapsedTime);




% calculate kcc for a time series
%---------------------------------------------------------------------------
function B = f_kendall(A)
nk = size(A); n = nk(1); k = nk(2);
SR = sum(A,2); SRBAR = mean(SR);
S = sum(SR.^2) - n*SRBAR^2;
B = 12*S/k^2/(n^3-n);
