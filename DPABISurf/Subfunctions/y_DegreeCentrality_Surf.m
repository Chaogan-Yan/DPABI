function [DegreeCentrality_PositiveWeightedSumBrain, DegreeCentrality_PositiveBinarizedSumBrain, GHeader] = y_DegreeCentrality_Surf(InFile, rThreshold, OutputName, AMaskFilename, CUTNUMBER)
% [DegreeCentrality_PositiveWeightedSumBrain, DegreeCentrality_PositiveBinarizedSumBrain, OutHeader] = y_DegreeCentrality_Surf(InFile, rThreshold, OutputName, AMaskFilename, CUTNUMBER)
% Calculate Degree Centrality
% Ref: Buckner, R.L., Sepulcre, J., Talukdar, T., Krienen, F.M., Liu, H., Hedden, T., Andrews-Hanna, J.R., Sperling, R.A., Johnson, K.A., 2009. Cortical hubs revealed by intrinsic functional connectivity: mapping, assessment of stability, and relation to Alzheimer's disease. J Neurosci 29, 1860-1873.
%      Zuo, X.N., Ehmke, R., Mennes, M., Imperati, D., Castellanos, F.X., Sporns, O., Milham, M.P., 2012. Network Centrality in the Human Functional Connectome. Cereb Cortex 22, 1862-1875.
% Input:
% 	InFile	        	The input surface time series file
%   rThreshold      -   The r (correlation) threshold for Degree Centrality calculation (sum of r > rThreshold).
%	OutputName  	-	Output filename. Could be 
%                            2*1 cells: for DegreeCentrality_PositiveWeightedSumBrain and DegreeCentrality_PositiveBinarizedSumBrain results respectively
%                       or   string: will be seperated by suffix: _DegreeCentrality_PositiveWeightedSumBrain and _DegreeCentrality_PositiveBinarizedSumBrain
% 	AMaskFilename		the mask file name, only compute the point within the mask
%   CUTNUMBER       -   Cut the data into pieces if small RAM memory e.g. 4GB is available on PC. It can be set to 1 on server with big memory (e.g., 50GB).
%                       default: 10
% Output:
%	DegreeCentrality_PositiveWeightedSumBrain       -   The Degree Centrality results Weighted sum of those r with r > rThreshold
%	DegreeCentrality_PositiveBinarizedSumBrain      -   The Degree Centrality results Binarized sum of those r with r > rThreshold (i.e., count the number of r > rThreshold)
%   GHeader         -   The GIfTI Header
%   The Degree Centrality image will be output as where OutputName specified.
%-----------------------------------------------------------
% Inherited from y_DegreeCentrality_Surf.m
% Revised by YAN Chao-Gan 181119.
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

% ZeroMeanOneStd
AllVolume = (AllVolume-repmat(mean(AllVolume),size(AllVolume,1),1))./repmat(std(AllVolume),size(AllVolume,1),1);   %Zero mean and one std
AllVolume(isnan(AllVolume))=0;

DegreeCentrality_PositiveWeightedSum = zeros(length(MaskIndex),1);
DegreeCentrality_PositiveBinarizedSum = zeros(length(MaskIndex),1);

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

    fprintf('.');
    %fprintf('Block: %d. ',iCut);
end

DegreeCentrality_PositiveWeightedSum = DegreeCentrality_PositiveWeightedSum - 1; % -1 because we need to substarct the r with itself
DegreeCentrality_PositiveBinarizedSum = DegreeCentrality_PositiveBinarizedSum - 1; % -1 because we need to substarct the r with itself


% Get the brain back
DegreeCentrality_PositiveWeightedSumBrain = zeros(size(MaskData));
DegreeCentrality_PositiveWeightedSumBrain(find(MaskDataOneDim),1) = DegreeCentrality_PositiveWeightedSum;

DegreeCentrality_PositiveBinarizedSumBrain = zeros(size(MaskData));
DegreeCentrality_PositiveBinarizedSumBrain(find(MaskDataOneDim),1) = DegreeCentrality_PositiveBinarizedSum;


if ischar(OutputName)
    [pathstr, name, ext] = fileparts(OutputName);
    OutputName_PositiveWeightedSumBrain = fullfile(pathstr,[name,'_DegreeCentrality_PositiveWeightedSumBrain',ext]);
    OutputName_PositiveBinarizedSumBrain = fullfile(pathstr,[name,'_DegreeCentrality_PositiveBinarizedSumBrain',ext]);
elseif iscell(OutputName)
    OutputName_PositiveWeightedSumBrain = OutputName{1};
    OutputName_PositiveBinarizedSumBrain = OutputName{2};
end

y_Write(DegreeCentrality_PositiveWeightedSumBrain,GHeader,OutputName_PositiveWeightedSumBrain);
y_Write(DegreeCentrality_PositiveBinarizedSumBrain,GHeader,OutputName_PositiveBinarizedSumBrain);

theElapsedTime = cputime - theElapsedTime;
fprintf('\nDegree Centrality compution over, elapsed time: %g seconds.\n', theElapsedTime);
