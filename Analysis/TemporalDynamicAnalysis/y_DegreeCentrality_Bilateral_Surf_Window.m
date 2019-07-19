function [DegreeCentrality_PositiveWeightedSumBrain_LH_AllWindow, DegreeCentrality_PositiveWeightedSumBrain_RH_AllWindow, DegreeCentrality_PositiveBinarizedSumBrain_LH_AllWindow, DegreeCentrality_PositiveBinarizedSumBrain_RH_AllWindow, GHeader_LH, GHeader_RH] = y_DegreeCentrality_Bilateral_Surf_Window(WindowSize, WindowStep, WindowType, InFile_LH, InFile_RH, rThreshold, OutputName_LH, OutputName_RH, AMaskFilename_LH, AMaskFilename_RH, IsNeedDetrend, CUTNUMBER)
% [DegreeCentrality_PositiveWeightedSumBrain_LH_AllWindow, DegreeCentrality_PositiveWeightedSumBrain_RH_AllWindow, DegreeCentrality_PositiveBinarizedSumBrain_LH_AllWindow, DegreeCentrality_PositiveBinarizedSumBrain_RH_AllWindow, GHeader_LH, GHeader_RH] = y_DegreeCentrality_Bilateral_Surf_Window(WindowSize, WindowStep, WindowType, InFile_LH, InFile_RH, rThreshold, OutputName_LH, OutputName_RH, AMaskFilename_LH, AMaskFilename_RH, CUTNUMBER)
% Calculate Dynamic Degree Centrality for Bilateral Hemishperes
% Ref: Buckner, R.L., Sepulcre, J., Talukdar, T., Krienen, F.M., Liu, H., Hedden, T., Andrews-Hanna, J.R., Sperling, R.A., Johnson, K.A., 2009. Cortical hubs revealed by intrinsic functional connectivity: mapping, assessment of stability, and relation to Alzheimer's disease. J Neurosci 29, 1860-1873.
%      Zuo, X.N., Ehmke, R., Mennes, M., Imperati, D., Castellanos, F.X., Sporns, O., Milham, M.P., 2012. Network Centrality in the Human Functional Connectome. Cereb Cortex 22, 1862-1875.
% Input:
%   WindowSize      -   the size of the sliding window
%   WindowStep      -   the step size
%   WindowType      -   the type of window (e.g., hamming)
% 	InFile_LH	        The input surface time series file for left hemishpere
% 	InFile_RH	        The input surface time series file for right hemishpere
%   rThreshold      -   The r (correlation) threshold for Degree Centrality calculation (sum of r > rThreshold).
%	OutputName_LH  	-	Output filename for left hemishpere. Could be
%                            2*1 cells: for DegreeCentrality_PositiveWeightedSumBrain and DegreeCentrality_PositiveBinarizedSumBrain results respectively
%                       or   string: will be seperated by suffix: _DegreeCentrality_PositiveWeightedSumBrain and _DegreeCentrality_PositiveBinarizedSumBrain
%	OutputName_RH  	-	Output filename for right hemishpere. Could be
%                            2*1 cells: for DegreeCentrality_PositiveWeightedSumBrain and DegreeCentrality_PositiveBinarizedSumBrain results respectively
%                       or   string: will be seperated by suffix: _DegreeCentrality_PositiveWeightedSumBrain and _DegreeCentrality_PositiveBinarizedSumBrain
% 	AMaskFilename_LH	the mask file name ofr left hemishpere, only compute the point within the mask
% 	AMaskFilename_RH	the mask file name ofr right hemishpere, only compute the point within the mask
%   IsNeedDetrend       0: Dot not detrend; 1: Use Matlab's detrend
%   CUTNUMBER       -   Cut the data into pieces if small RAM memory e.g. 4GB is available on PC. It can be set to 1 on server with big memory (e.g., 50GB).
%                       default: 10
% Output:
%	DegreeCentrality_PositiveWeightedSumBrain_LH_AllWindow       -   The Dynamic Degree Centrality results Weighted sum of those r with r > rThreshold, for left hemishpere
%	DegreeCentrality_PositiveWeightedSumBrain_RH_AllWindow       -   The Dynamic Degree Centrality results Weighted sum of those r with r > rThreshold, for right hemishpere
%	DegreeCentrality_PositiveBinarizedSumBrain_LH_AllWindow      -   The Dynamic Degree Centrality results Binarized sum of those r with r > rThreshold (i.e., count the number of r > rThreshold), for left hemishpere
%	DegreeCentrality_PositiveBinarizedSumBrain_RH_AllWindow      -   The Dynamic Degree Centrality results Binarized sum of those r with r > rThreshold (i.e., count the number of r > rThreshold), for right hemishpere
%   GHeader_LH         -   The GIfTI Header for for left hemishpere
%   GHeader_RH         -   The GIfTI Header for for right hemishpere
%   The Degree Centrality image will be output as where OutputName specified.
%-----------------------------------------------------------
% Inherited from y_DegreeCentrality_Bilateral_Surf.m
% Revised by YAN Chao-Gan 190625.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com

if ~exist('CUTNUMBER','var')
    CUTNUMBER = 10;
end

theElapsedTime =cputime;
fprintf('\nComputing Degree Centrality...');

GHeader_LH=gifti(InFile_LH);
AllVolume_LH=GHeader_LH.cdata;
[nDimVertex_LH nDimTimePoints]=size(AllVolume_LH);

fprintf('\nLoad mask "%s".\n', AMaskFilename_LH);
if ~isempty(AMaskFilename_LH)
    MaskData=gifti(AMaskFilename_LH);
    MaskData=MaskData.cdata;
    if size(MaskData,1)~=nDimVertex_LH
        error('The size of Mask (%d) doesn''t match the required size (%d).\n',size(MaskData,1), nDimVertex);
    end
    MaskData = double(logical(MaskData));
else
    MaskData=ones(nDimVertex_LH,1);
end
MaskDataOneDim_LH=reshape(MaskData,1,[]);
MaskIndex_LH = find(MaskDataOneDim_LH);


GHeader_RH=gifti(InFile_RH);
AllVolume_RH=GHeader_RH.cdata;
[nDimVertex_RH nDimTimePoints]=size(AllVolume_RH);

fprintf('\nLoad mask "%s".\n', AMaskFilename_RH);
if ~isempty(AMaskFilename_RH)
    MaskData=gifti(AMaskFilename_RH);
    MaskData=MaskData.cdata;
    if size(MaskData,1)~=nDimVertex_RH
        error('The size of Mask (%d) doesn''t match the required size (%d).\n',size(MaskData,1), nDimVertex);
    end
    MaskData = double(logical(MaskData));
else
    MaskData=ones(nDimVertex_RH,1);
end
MaskDataOneDim_RH=reshape(MaskData,1,[]);
MaskIndex_RH = find(MaskDataOneDim_RH);



% First dimension is time
AllVolume_LH=AllVolume_LH';
AllVolume_LH=AllVolume_LH(:,MaskIndex_LH);
AllVolume_RH=AllVolume_RH';
AllVolume_RH=AllVolume_RH(:,MaskIndex_RH);

% Detrend
if exist('IsNeedDetrend','var') && IsNeedDetrend==1
    %AllVolume=detrend(AllVolume);
    fprintf('\n\t Detrending...');
    SegmentLength = ceil(size(AllVolume_LH,2) / CUTNUMBER);
    for iCut=1:CUTNUMBER
        if iCut~=CUTNUMBER
            Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
        else
            Segment = (iCut-1)*SegmentLength+1 : size(AllVolume_LH,2);
        end
        AllVolume_LH(:,Segment) = detrend(AllVolume_LH(:,Segment));
        fprintf('.');
    end
    
    SegmentLength = ceil(size(AllVolume_RH,2) / CUTNUMBER);
    for iCut=1:CUTNUMBER
        if iCut~=CUTNUMBER
            Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
        else
            Segment = (iCut-1)*SegmentLength+1 : size(AllVolume_RH,2);
        end
        AllVolume_RH(:,Segment) = detrend(AllVolume_RH(:,Segment));
        fprintf('.');
    end
end


nWindow = fix((nDimTimePoints - WindowSize)/WindowStep) + 1;
nDimTimePoints_WithinWindow = WindowSize;
DegreeCentrality_PositiveWeightedSumBrain_LH_AllWindow = zeros([nDimVertex_LH, nWindow]);
DegreeCentrality_PositiveBinarizedSumBrain_LH_AllWindow = zeros([nDimVertex_LH, nWindow]);
DegreeCentrality_PositiveWeightedSumBrain_RH_AllWindow = zeros([nDimVertex_RH, nWindow]);
DegreeCentrality_PositiveBinarizedSumBrain_RH_AllWindow = zeros([nDimVertex_RH, nWindow]);
if ischar(WindowType)
    eval(['WindowType = ',WindowType,'(WindowSize);'])
end
WindowMultiplier_LH = repmat(WindowType(:),1,size(AllVolume_LH,2));
WindowMultiplier_RH = repmat(WindowType(:),1,size(AllVolume_RH,2));
% WindowMultiplier = repmat(WindowType(:),1,size(AllVolume,2));


for iWindow = 1:nWindow
    fprintf('\nProcessing window %g of total %g windows\n', iWindow, nWindow);
    
    %     AllVolumeWindow_LH = AllVolume_LH((iWindow-1)*WindowStep+1:(iWindow-1)*WindowStep+WindowSize,:);
    %     AllVolumeWindow_LH = AllVolumeWindow_LH.*WindowMultiplier_LH;
    %     AllVolumeWindow_RH = AllVolume_RH((iWindow-1)*WindowStep+1:(iWindow-1)*WindowStep+WindowSize,:);
    %     AllVolumeWindow_RH = AllVolumeWindow_RH.*WindowMultiplier_RH;
    %     AllVolumeWindow=cat(2,AllVolumeWindow_LH,AllVolumeWindow_RH);
    AllVolumeWindow=cat(2,AllVolume_LH((iWindow-1)*WindowStep+1:(iWindow-1)*WindowStep+WindowSize,:).*WindowMultiplier_LH,AllVolume_RH((iWindow-1)*WindowStep+1:(iWindow-1)*WindowStep+WindowSize,:).*WindowMultiplier_RH);
    
    % ZeroMeanOneStd
    AllVolumeWindow = (AllVolumeWindow-repmat(mean(AllVolumeWindow),size(AllVolumeWindow,1),1))./repmat(std(AllVolumeWindow),size(AllVolumeWindow,1),1);   %Zero mean and one std
    AllVolumeWindow(isnan(AllVolumeWindow))=0;
    
    DegreeCentrality_PositiveWeightedSum = zeros(length(MaskIndex_LH)+length(MaskIndex_RH),1);
    DegreeCentrality_PositiveBinarizedSum = zeros(length(MaskIndex_LH)+length(MaskIndex_RH),1);
    
    % Degree Centrality Calculating
    CUTNUMBER = 30*CUTNUMBER; % More cut needed for degree centrality calculation
    fprintf('\n\t Degree Centrality Calculating...');
    SegmentLength = ceil(size(AllVolumeWindow,2) / CUTNUMBER);
    CUTNUMBER = ceil(size(AllVolumeWindow,2) / SegmentLength); % Revise CUTNUMBER in case SegmentLength*CUTNUMBER is too bigger than size(AllVolume,2)
    
    for iCut=1:CUTNUMBER
        if iCut~=CUTNUMBER
            Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
        else
            Segment = (iCut-1)*SegmentLength+1 : size(AllVolumeWindow,2);
        end
        
        FC_Segment = AllVolumeWindow(:,Segment)'*AllVolumeWindow/(nDimTimePoints_WithinWindow-1);
        
        DegreeCentrality_PositiveWeightedSum(Segment) = sum(FC_Segment.*(FC_Segment > rThreshold),2);
        DegreeCentrality_PositiveBinarizedSum(Segment) = sum(FC_Segment > rThreshold,2);
        
        fprintf('.');
        %fprintf('Block: %d. ',iCut);
    end
    
    DegreeCentrality_PositiveWeightedSum = DegreeCentrality_PositiveWeightedSum - 1; % -1 because we need to substarct the r with itself
    DegreeCentrality_PositiveBinarizedSum = DegreeCentrality_PositiveBinarizedSum - 1; % -1 because we need to substarct the r with itself
    
    
    % Get the brain back
    DegreeCentrality_PositiveWeightedSumBrain_LH = zeros(nDimVertex_LH,1);
    DegreeCentrality_PositiveWeightedSumBrain_LH(MaskIndex_LH,1) = DegreeCentrality_PositiveWeightedSum(1:length(MaskIndex_LH));
    DegreeCentrality_PositiveWeightedSumBrain_RH = zeros(nDimVertex_RH,1);
    DegreeCentrality_PositiveWeightedSumBrain_RH(MaskIndex_RH,1) = DegreeCentrality_PositiveWeightedSum(length(MaskIndex_LH)+1:end);
    DegreeCentrality_PositiveWeightedSumBrain_LH=DegreeCentrality_PositiveWeightedSumBrain_LH';
    DegreeCentrality_PositiveWeightedSumBrain_RH=DegreeCentrality_PositiveWeightedSumBrain_RH';
    
    DegreeCentrality_PositiveBinarizedSumBrain_LH = zeros(nDimVertex_LH,1);
    DegreeCentrality_PositiveBinarizedSumBrain_LH(MaskIndex_LH,1) = DegreeCentrality_PositiveBinarizedSum(1:length(MaskIndex_LH));
    DegreeCentrality_PositiveBinarizedSumBrain_RH = zeros(nDimVertex_RH,1);
    DegreeCentrality_PositiveBinarizedSumBrain_RH(MaskIndex_RH,1) = DegreeCentrality_PositiveBinarizedSum(length(MaskIndex_LH)+1:end);
    DegreeCentrality_PositiveBinarizedSumBrain_LH=DegreeCentrality_PositiveBinarizedSumBrain_LH';
    DegreeCentrality_PositiveBinarizedSumBrain_RH=DegreeCentrality_PositiveBinarizedSumBrain_RH';
    
    DegreeCentrality_PositiveWeightedSumBrain_LH_AllWindow(:,iWindow) = DegreeCentrality_PositiveWeightedSumBrain_LH;
    DegreeCentrality_PositiveBinarizedSumBrain_LH_AllWindow(:,iWindow) = DegreeCentrality_PositiveBinarizedSumBrain_LH;
    DegreeCentrality_PositiveWeightedSumBrain_RH_AllWindow(:,iWindow) = DegreeCentrality_PositiveWeightedSumBrain_RH;
    DegreeCentrality_PositiveBinarizedSumBrain_RH_AllWindow(:,iWindow) = DegreeCentrality_PositiveBinarizedSumBrain_RH;
end


if ischar(OutputName_LH)
    [pathstr, name, ext] = fileparts(OutputName_LH);
    OutputName_PositiveWeightedSumBrain_LH = fullfile(pathstr,[name,'_DegreeCentrality_PositiveWeightedSumBrain',ext]);
    OutputName_PositiveBinarizedSumBrain_LH = fullfile(pathstr,[name,'_DegreeCentrality_PositiveBinarizedSumBrain',ext]);
elseif iscell(OutputName_LH)
    OutputName_PositiveWeightedSumBrain_LH = OutputName_LH{1};
    OutputName_PositiveBinarizedSumBrain_LH = OutputName_LH{2};
end

if ischar(OutputName_RH)
    [pathstr, name, ext] = fileparts(OutputName_RH);
    OutputName_PositiveWeightedSumBrain_RH = fullfile(pathstr,[name,'_DegreeCentrality_PositiveWeightedSumBrain',ext]);
    OutputName_PositiveBinarizedSumBrain_RH = fullfile(pathstr,[name,'_DegreeCentrality_PositiveBinarizedSumBrain',ext]);
elseif iscell(OutputName_RH)
    OutputName_PositiveWeightedSumBrain_RH = OutputName_RH{1};
    OutputName_PositiveBinarizedSumBrain_RH = OutputName_RH{2};
end

y_Write(DegreeCentrality_PositiveWeightedSumBrain_LH_AllWindow,GHeader_LH,OutputName_PositiveWeightedSumBrain_LH);
y_Write(DegreeCentrality_PositiveBinarizedSumBrain_LH_AllWindow,GHeader_LH,OutputName_PositiveBinarizedSumBrain_LH);
y_Write(DegreeCentrality_PositiveWeightedSumBrain_RH_AllWindow,GHeader_RH,OutputName_PositiveWeightedSumBrain_RH);
y_Write(DegreeCentrality_PositiveBinarizedSumBrain_RH_AllWindow,GHeader_RH,OutputName_PositiveBinarizedSumBrain_RH);

theElapsedTime = cputime - theElapsedTime;
fprintf('\nDegree Centrality compution over, elapsed time: %g seconds.\n', theElapsedTime);
