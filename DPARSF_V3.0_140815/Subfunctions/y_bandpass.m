function [] = y_bandpass(ADataDir, ...
    ASamplePeriod, ALowPass_HighCutoff, AHighPass_LowCutoff, ...
    AAddMeanBack, ...
    AMaskFilename,...
    CUTNUMBER)
%Ideal Band pass filter
%Algorithm re-written to call y_IdealFilter by YAN Chao-Gan
% FORMAT y_bandpass(ADataDir, ...
%     ASamplePeriod, ALowPass_HighCutoff, AHighPass_LowCutoff, ...
%     AAddMeanBack, ...
%     AMaskFilename,...
%     CUTNUMBER)
% Use Ideal rectangular filter to filter a 3d+time dataset
% Input:
% 	ADataDir			where the 3d+time dataset stay, and there should be 3d EPI functional image files. It must not contain / or \ at the end.
% 	ASamplePeriod		TR, or like the variable name
% 	ALowPass_HighCutoff			low pass, high cutoff of the band, eg. 0.08
% 	AHighPass_LowCutoff			high pass,  low cutoff of the band, eg. 0.01
%	AAddMeanBack			'Yes' or 'No'. 	if yes, then add the mean back after filtering
% 	AMaskFilename		the mask file name, compatible with old reho or reho_gui, can be 'Default' or 1, '' or 0, 'mask.mat', '../mask.img'
%   CUTNUMBER           cut the data into pieces if small RAM memory e.g. 4GB is available on PC. It can be set to 1 on server with big memory (e.g., 50GB).
%                       default: 10
% Output:
%	 Create a new sibling-directory with ADataDir, and name as 'ADataDir_filtered', then put all filted images to the new sibling-directory
%-----------------------------------------------------------
%	Copyright(c) 2007~2010
%	State Key Laboratory of Cognitive Neuroscience and Learning in Beijing Normal University
%	Written by Xiao-Wei Song
%	http://resting-fmri.sourceforge.net
%-----------------------------------------------------------
% 	Mail to Authors:  <a href="Dawnwei.Song@gmail.com">SONG Xiao-Wei</a>; <a href="ycg.yan@gmail.com">YAN Chao-Gan</a>
%	Version=1.4;
%	Release=20100420;
%   Revised by YAN Chao-Gan 080610: NIFTI compatible
%   Revised by YAN Chao-Gan, 090321. Data in processing will not be converted to the format 'int16'.
%   Revised by YAN Chao-Gan, 090919. Data will be saved in single format.
%   Last Revised by YAN Chao-Gan, 100420. Fixed a bug in calculating the frequency band. And now will not remove the linear trend in bandpass filter (as fourier_filter.c in AFNI), but just save the mean and can add the mean back after filtering.
%   Algorithm Re-Written by YAN Chao-Gan (ycg.yan@gmail.com) on 120504. Note: The low cutoff frequency index calculation changed from round to "ceil". E.g., if low cut off corresponded to index 5.1, now it will start from 6 other than 5. 
%   Save in 4D volume .nii.


if ~exist('CUTNUMBER','var')
    CUTNUMBER = 10;
end

tic;
fprintf('\nIdeal rectangular filter:\t"%s"', ADataDir);
[AllVolume,vsize,theImgFileList, Header] = y_ReadAll(ADataDir);

[nDim1 nDim2 nDim3 nDimTimePoints]=size(AllVolume);


%Set Mask
if ~isempty(AMaskFilename)
    [MaskData,MaskVox,MaskHead]=y_ReadRPI(AMaskFilename);
else
    MaskData=ones(nDim1,nDim2,nDim3);
end


% Convert into 2D
AllVolume=reshape(AllVolume,[],nDimTimePoints)';

MaskDataOneDim=reshape(MaskData,1,[]);
MaskIndex = find(MaskDataOneDim);
AllVolume=AllVolume(:,MaskIndex);

fprintf('\n\t Band Pass Filter working.\tWait...');

%Remove the mean. YAN Chao-Gan 100401.
theMean=mean(AllVolume);
AllVolume=AllVolume-repmat(theMean,[nDimTimePoints,1]);

SegmentLength = ceil(size(AllVolume,2) / CUTNUMBER);
for iCut=1:CUTNUMBER
    if iCut~=CUTNUMBER
        Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
    else
        Segment = (iCut-1)*SegmentLength+1 : size(AllVolume,2);
    end
    
    AllVolume(:,Segment) = y_IdealFilter(AllVolume(:,Segment), ASamplePeriod, [AHighPass_LowCutoff, ALowPass_HighCutoff]);
    
    fprintf('.');
end


% Add the mean back after filter.
if strcmpi(AAddMeanBack, 'Yes')
    AllVolume=AllVolume+repmat(theMean,[nDimTimePoints,1]);
end

AllVolumeBrain = single(zeros(nDimTimePoints, nDim1*nDim2*nDim3));
AllVolumeBrain(:,MaskIndex) = AllVolume;

AllVolumeBrain=reshape(AllVolumeBrain',[nDim1, nDim2, nDim3, nDimTimePoints]);


%Save all images to disk
fprintf('\n\t Saving filtered images.\tWait...');
if strcmp(ADataDir(end),filesep)==1
    ADataDir=ADataDir(1:end-1);
end
theResultOutputDir =sprintf('%s_filtered',ADataDir);
ans=rmdir(theResultOutputDir, 's');%suppress the error msg
mkdir(theResultOutputDir); %YAN Chao-Gan, 110911. For Matlab future release compatible.


Header_Out = Header;
Header_Out.pinfo = [1;0;0];
Header_Out.dt    =[16,0];


y_Write(AllVolumeBrain,Header_Out,sprintf('%s_filtered%sFiltered_4DVolume.nii', ADataDir, filesep));

fprintf('\n\t Band pass filter finished.\n\t');
toc;
