function [KendallW] = y_KendallW_AcrossImages_Surf(RaterImages_L, RaterImages_R, MaskData_L, MaskData_R, AResultFilename)
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
%	KendallWBrain   -   The Kendall's W results
%   Header          -   The NIfTI Header
%	AResultFilename	the filename of Kendall's W result
%___________________________________________________________________________
% Written by YAN Chao-Gan 171001.
% The R-fMRI Lab, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com



theElapsedTime =cputime;

fprintf('\n\tKendall''s W computation Start...\n');
if length(RaterImages_L)~=length(RaterImages_R)
    error('The number of RaterImages of two hemispheres do not fit');
end
GHeader_L = gifti(RaterImages_L{1});
GHeader_R = gifti(RaterImages_R{1});
AllVolume_L=GHeader_L.cdata;
AllVolume_R=GHeader_R.cdata;

[nDimVertex_L, nDimTimePoints_L]=size(AllVolume_L);
[nDimVertex_R, nDimTimePoints_R]=size(AllVolume_R);
if nDimTimePoints_L~=nDimTimePoints_R
    error('The TimePoints of two hemispheres do not fit');
end
nDimTimePoints=nDimTimePoints_L;
nDimVertex=nDimVertex_L+nDimVertex_R;
BrainSize = nDimVertex;

if ischar(MaskData_L)
    if ~isempty(MaskData_L)
        MaskData_L=gifti(MaskData_L);
        MaskData_L=MaskData_L.cdata;
    else
        MaskData_L=ones(nDimVertex_L,1);
    end
end

if ischar(MaskData_R)
    if ~isempty(MaskData_R)
        MaskData_R=gifti(MaskData_R);
        MaskData_R=MaskData_R.cdata;
    else
        MaskData_R=ones(nDimVertex_R,1);
    end
end
MaskData=[MaskData_L;MaskData_R];
MaskDataOneDim=reshape(MaskData,1,[]);
MaskIndex = find(MaskDataOneDim);



%RankSet = zeros(nDimTimePoints,length(MaskIndex),length(RaterImages));
RankSet = repmat((zeros(length(MaskIndex),1)),[1,nDimTimePoints,length(RaterImages_L)]);

for iRater = 1:length(RaterImages_L)

    AllVolume_L = gifti(RaterImages_L{iRater});
    AllVolume_L=AllVolume_L.cdata;
    AllVolume_R = gifti(RaterImages_R{iRater});
    AllVolume_R=AllVolume_R.cdata;
    AllVolume=[AllVolume_L;AllVolume_R];
    % Convert into 2D
    AllVolume=reshape(AllVolume,[],nDimTimePoints)';
    AllVolume=AllVolume(:,MaskIndex);
    
    [R,TIEADJ] = tiedrank(AllVolume);
    
    
    RankSet(:,:,iRater) = R';
    
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
