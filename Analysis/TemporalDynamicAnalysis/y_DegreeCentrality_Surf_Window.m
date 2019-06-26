function [DegreeCentrality_PositiveWeightedSum_AllWindow, DegreeCentrality_PositiveBinarizedSum_AllWindow, GHeader] = y_DegreeCentrality_Surf_Window(WindowSize, WindowStep, WindowType, InFile, rThreshold, OutputName, AMaskFilename, CUTNUMBER)
% [DegreeCentrality_PositiveWeightedSum_AllWindow, DegreeCentrality_PositiveBinarizedSum_AllWindow, GHeader] = y_DegreeCentrality_Surf_Window(WindowSize, WindowStep, WindowType, InFile, rThreshold, OutputName, AMaskFilename, CUTNUMBER)
% Calculate Dynamic Degree Centrality
% Input:
%   WindowSize      -   the size of the sliding window
%   WindowStep      -   the step size
%   WindowType      -   the type of window (e.g., hamming)
% 	InFile	        	The input surface time series file
%   rThreshold      -   The r (correlation) threshold for Degree Centrality calculation (sum of r > rThreshold).
%	OutputName  	-	Output filename. Could be 
%                            2*1 cells: for DegreeCentrality_PositiveWeightedSumBrain and DegreeCentrality_PositiveBinarizedSumBrain results respectively
%                       or   string: will be seperated by suffix: _DegreeCentrality_PositiveWeightedSumBrain and _DegreeCentrality_PositiveBinarizedSumBrain
% 	AMaskFilename		the mask file name, only compute the point within the mask
%   CUTNUMBER       -   Cut the data into pieces if small RAM memory e.g. 4GB is available on PC. It can be set to 1 on server with big memory (e.g., 50GB).
%                       default: 10
% Output:
%	DegreeCentrality_PositiveWeightedSumBrain_AllWindow       -   The Degree Centrality results Weighted sum of those r with r > rThreshold
%	DegreeCentrality_PositiveBinarizedSumBrain_AllWindow      -   The Degree Centrality results Binarized sum of those r with r > rThreshold (i.e., count the number of r > rThreshold)
%   GHeader         -   The GIfTI Header
%   The Degree Centrality image will be output as where OutputName specified.
%-----------------------------------------------------------
% Inherited from y_DegreeCentrality_Surf.m
% Revised by YAN Chao-Gan 190625.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com

if ~exist('CUTNUMBER','var')
    CUTNUMBER = 10;
end

theElapsedTime =cputime;
fprintf('\nComputing Degree Centrality...');

GHeader=gifti(InFile);
AllVolume=GHeader.cdata;
[nDimVertex nDimTimePoints]=size(AllVolume);

fprintf('\nLoad mask "%s".\n', AMaskFilename);
if ~isempty(AMaskFilename)
    MaskData=gifti(AMaskFilename);
    MaskData=MaskData.cdata;
    if size(MaskData,1)~=nDimVertex
        error('The size of Mask (%d) doesn''t match the required size (%d).\n',size(MaskData,1), nDimVertex);
    end
    MaskData = double(logical(MaskData));
else
    MaskData=ones(nDimVertex,1);
end
MaskDataOneDim=reshape(MaskData,1,[]);
MaskIndex = find(MaskDataOneDim);


% First dimension is time
AllVolume=AllVolume';
AllVolume=AllVolume(:,find(MaskDataOneDim));

nWindow = fix((nDimTimePoints - WindowSize)/WindowStep) + 1;
nDimTimePoints_WithinWindow = WindowSize;
DegreeCentrality_PositiveWeightedSum_AllWindow = zeros([nDimVertex nWindow]);
DegreeCentrality_PositiveBinarizedSum_AllWindow = zeros([nDimVertex nWindow]);

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

    DegreeCentrality_PositiveWeightedSum = zeros(length(MaskIndex),1);
    DegreeCentrality_PositiveBinarizedSum = zeros(length(MaskIndex),1);

    % Degree Centrality Calculating
    CUTNUMBER = 30*CUTNUMBER; % More cut needed for degree centrality calculation
    fprintf('\n\t Degree Centrality Calculating...');
    SegmentLength = ceil(size(AllVolumeWindow,2) / CUTNUMBER);
    CUTNUMBER = ceil(size(AllVolumeWindow,2) / SegmentLength); % Revise CUTNUMBER in case SegmentLength*CUTNUMBER is too bigger than size(AllVolume,2)

    for iCut=1:CUTNUMBER
        if iCut~=CUTNUMBER
            Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
        else
            Segment = (iCut-1)*SegmentLength+1 : size(AllVolume,2);
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
    DegreeCentrality_PositiveWeightedSumBrain = zeros(size(MaskData));
    DegreeCentrality_PositiveWeightedSumBrain(find(MaskDataOneDim),1) = DegreeCentrality_PositiveWeightedSum;
    DegreeCentrality_PositiveWeightedSumBrain=DegreeCentrality_PositiveWeightedSumBrain';

    DegreeCentrality_PositiveBinarizedSumBrain = zeros(size(MaskData));
    DegreeCentrality_PositiveBinarizedSumBrain(find(MaskDataOneDim),1) = DegreeCentrality_PositiveBinarizedSum;
    DegreeCentrality_PositiveBinarizedSumBrain=DegreeCentrality_PositiveBinarizedSumBrain';

    DegreeCentrality_PositiveWeightedSum_AllWindow(:,iWindow) = DegreeCentrality_PositiveWeightedSumBrain;
    DegreeCentrality_PositiveBinarizedSum_AllWindow(:,iWindow) = DegreeCentrality_PositiveBinarizedSumBrain;
end

if ischar(OutputName)
    [pathstr, name, ext] = fileparts(OutputName);
    OutputName_PositiveWeightedSumBrain = fullfile(pathstr,[name,'_DegreeCentrality_PositiveWeightedSumBrain',ext]);
    OutputName_PositiveBinarizedSumBrain = fullfile(pathstr,[name,'_DegreeCentrality_PositiveBinarizedSumBrain',ext]);
elseif iscell(OutputName)
    OutputName_PositiveWeightedSumBrain = OutputName{1};
    OutputName_PositiveBinarizedSumBrain = OutputName{2};
end

y_Write(DegreeCentrality_PositiveWeightedSum_AllWindow,GHeader,OutputName_PositiveWeightedSumBrain);
y_Write(DegreeCentrality_PositiveBinarizedSum_AllWindow,GHeader,OutputName_PositiveBinarizedSumBrain);

theElapsedTime = cputime - theElapsedTime;
fprintf('\nDegree Centrality compution over, elapsed time: %g seconds.\n', theElapsedTime);