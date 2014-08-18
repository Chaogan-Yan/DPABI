function y_detrend (ADataDir, CUTNUMBER)
%function y_detrend (ADataDir, CUTNUMBER)
%   ADataDir			where the 3d+time dataset stay, and there should be 3d EPI functional image files. It must not contain / or \ at the end.
%   CUTNUMBER           cut the data into pieces if small RAM memory e.g. 4GB is available on PC. It can be set to 1 on server with big memory (e.g., 50GB).
%                       default: 10
%------------------------------------------------------------------------------------------------------------------------------
% Remove linear trend and save to ADataDir_detrend
%
%------------------------------------------------------------------------------------------------------------------------------
%	Copyright(c) 2007~2010
%	State Key Laboratory of Cognitive Neuroscience and Learning in Beijing Normal University
%	Written by Xiao-Wei Song 
%	http://resting-fmri.sourceforge.net
% Dawnwei.Song@gmail.com, Copyright 2007~2010
%------------------------------------------------------------------------------------------------------------------------------
% 	Mail to Authors:  <a href="Dawnwei.Song@gmail.com">Xiaowei Song</a>; <a href="ycg.yan@gmail.com">Chaogan Yan</a> 
%	Version=1.3;
%	Release=20090321;
%   Revised by YAN Chao-Gan 080610: NIFTI compatible
%   Revised by YAN Chao-Gan, 090321. Data in processing will not be converted to the format 'int16'.
%   Re-organized by Sandy Wang and YAN Chao-Gan, 120719. Speed up based on an detrend option in y_SCA.m

if ~exist('CUTNUMBER','var')
    CUTNUMBER = 10;
end

tic;
fprintf(['\nRemoving the linear trend: ',ADataDir,'\n']);

[AllVolume,vsize,theImgFileList, Header] = y_ReadAll(ADataDir);

[nDim1 nDim2 nDim3 nDimTimePoints]=size(AllVolume);

%Change by Sandy Wang to increase detrend speed, based on y_SCA.m
AllVolume=reshape(AllVolume,[],nDimTimePoints)';
theMean=mean(AllVolume);
SegmentLength = ceil(size(AllVolume,2) / CUTNUMBER);
fprintf('\n\t Detrend working.\tWait...');
for iCut=1:CUTNUMBER
    if iCut~=CUTNUMBER
        Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
    else
        Segment = (iCut-1)*SegmentLength+1 : size(AllVolume,2);
    end
    
    AllVolume(:,Segment) = detrend(AllVolume(:,Segment));
    
    fprintf('.');
end

AllVolume=AllVolume+repmat(theMean,[nDimTimePoints,1]);
AllVolume=reshape(AllVolume',[nDim1, nDim2, nDim3, nDimTimePoints]);

if strcmp(ADataDir(end),filesep)==1
    ADataDir=ADataDir(1:end-1);
end
theResultOutputDir =sprintf('%s_detrend',ADataDir);
ans=rmdir(theResultOutputDir, 's');%suppress the error msg
mkdir(theResultOutputDir); %YAN Chao-Gan, 110911. For Matlab future release compatible.

Header_Out = Header;
Header_Out.pinfo = [1;0;0];
Header_Out.dt    =[16,0];

y_Write(AllVolume,Header_Out,sprintf('%s%sDetrend_4DVolume.nii', theResultOutputDir ,filesep));

fprintf('\n\t Detrend finished.\n\t');
toc;
