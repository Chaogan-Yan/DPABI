function [ALFFBrain, fALFFBrain, GHeader] = y_alff_falff_Surf(InFile,ASamplePeriod, HighCutoff, LowCutoff, AMaskFilename, AResultFilename, CUTNUMBER)
% Use ALFF method to compute the brain and return a ALFF brain map which reflects the "energy" of the voxels' BOLD signal
% Ref: Zang, Y.F., He, Y., Zhu, C.Z., Cao, Q.J., Sui, M.Q., Liang, M., Tian, L.X., Jiang, T.Z., Wang, Y.F., 2007. Altered baseline brain activity in children with ADHD revealed by resting-state functional MRI. Brain Dev 29, 83-91.
% And also output the fractional ALFF (fALFF) results.
% Ref: Zou QH, Zhu CZ, Yang Y, Zuo XN, Long XY, Cao QJ, Wang YF, Zang YF (2008) An improved approach to detection of amplitude of low-frequency fluctuation (ALFF) for resting-state fMRI: fractional ALFF. Journal of neuroscience methods 172:137-141.
% FORMAT    [ALFFBrain, fALFFBrain, OutHeader] = y_alff_falff_Surf(InFile,ASamplePeriod, HighCutoff, LowCutoff, AMaskFilename, AResultFilename, CUTNUMBER)
% Input:
% 	InFile	        	The input surface time series file
% 	ASamplePeriod		TR, or like the variable name
% 	HighCutoff			the High edge of the pass band
% 	LowCutoff			the low edge of the pass band
% 	AMaskFilename		the mask file name, only compute the point within the mask
%	AResultFilename		the output filename. Could be 
%                            2*1 cells: for ALFF and fALFF results respectively
%                       or   string: name for ALFF. fALFF results will have a surfix 'f' on this name.
%   CUTNUMBER           Cut the data into pieces if small RAM memory e.g. 4GB is available on PC. It can be set to 1 on server with big memory (e.g., 50GB).
%                       default: 10
% Output:
%	ALFFBrain       -   The ALFF results
%   fALFFBrain      -   The fALFF results
%   GHeader         -   The GIfTI Header
%	AResultFilename	the filename of ALFF and fALFF results.
%-----------------------------------------------------------
% Inherited from y_alff_falff.m
% Revised by YAN Chao-Gan 181117.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com

if ~exist('CUTNUMBER','var')
    CUTNUMBER = 10;
end

theElapsedTime =cputime;

fprintf('\nComputing ALFF...');

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


% First dimension is time
AllVolume=AllVolume';
AllVolume=AllVolume(:,find(MaskDataOneDim));


% Get the frequency index
sampleFreq 	 = 1/ASamplePeriod;
sampleLength = nDimTimePoints;
paddedLength = 2^nextpow2(sampleLength);
if (LowCutoff >= sampleFreq/2) % All high included
    idx_LowCutoff = paddedLength/2 + 1;
else % high cut off, such as freq > 0.01 Hz
    idx_LowCutoff = ceil(LowCutoff * paddedLength * ASamplePeriod + 1);
    % Change from round to ceil: idx_LowCutoff = round(LowCutoff *paddedLength *ASamplePeriod + 1);
end
if (HighCutoff>=sampleFreq/2)||(HighCutoff==0) % All low pass
    idx_HighCutoff = paddedLength/2 + 1;
else % Low pass, such as freq < 0.08 Hz
    idx_HighCutoff = fix(HighCutoff *paddedLength *ASamplePeriod + 1);
    % Change from round to fix: idx_HighCutoff	=round(HighCutoff *paddedLength *ASamplePeriod + 1);
end


% Detrend before fft as did in the previous alff.m
%AllVolume=detrend(AllVolume);
% Cut to be friendly with the RAM Memory
SegmentLength = ceil(size(AllVolume,2) / CUTNUMBER);
for iCut=1:CUTNUMBER
    if iCut~=CUTNUMBER
        Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
    else
        Segment = (iCut-1)*SegmentLength+1 : size(AllVolume,2);
    end
    AllVolume(:,Segment) = detrend(AllVolume(:,Segment));
end


% Zero Padding
AllVolume = [AllVolume;zeros(paddedLength -sampleLength,size(AllVolume,2))]; %padded with zero

fprintf('\n\t Performing FFT ...');
%AllVolume = 2*abs(fft(AllVolume))/sampleLength;
% Cut to be friendly with the RAM Memory
SegmentLength = ceil(size(AllVolume,2) / CUTNUMBER);
for iCut=1:CUTNUMBER
    if iCut~=CUTNUMBER
        Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
    else
        Segment = (iCut-1)*SegmentLength+1 : size(AllVolume,2);
    end
    AllVolume(:,Segment) = 2*abs(fft(AllVolume(:,Segment)))/sampleLength;
    fprintf('.');
end


ALFF_2D = mean(AllVolume(idx_LowCutoff:idx_HighCutoff,:));

% Get the brain back
ALFFBrain = zeros(size(MaskDataOneDim));
ALFFBrain(1,find(MaskDataOneDim)) = ALFF_2D;
ALFFBrain = ALFFBrain';


% Also generate fALFF
%fALFF_2D = sum(AllVolume(idx_LowCutoff:idx_HighCutoff,:)) ./ sum(AllVolume(2:(paddedLength/2 + 1),:));
fALFF_2D = sum(AllVolume(idx_LowCutoff:idx_HighCutoff,:),1) ./ sum(AllVolume(2:(paddedLength/2 + 1),:),1); %YAN Chao-Gan, 171218. In case there is only one point
fALFF_2D(~isfinite(fALFF_2D))=0;

% Get the brain back
fALFFBrain = zeros(size(MaskDataOneDim));
fALFFBrain(1,find(MaskDataOneDim)) = fALFF_2D;
fALFFBrain = fALFFBrain';

%Save ALFF and fALFF image to disk
if ischar(AResultFilename)
    AResultFilename_ALFF = AResultFilename;
    [pathstr, name, ext] = fileparts(AResultFilename);
    AResultFilename_fALFF = fullfile(pathstr,['f',name,ext]);
elseif iscell(AResultFilename)
    AResultFilename_ALFF = AResultFilename{1};
    AResultFilename_fALFF = AResultFilename{2};
end

y_Write(ALFFBrain,GHeader,AResultFilename_ALFF);
y_Write(fALFFBrain,GHeader,AResultFilename_fALFF);

theElapsedTime = cputime - theElapsedTime;
fprintf('\n\t ALFF and fALFF compution over, elapsed time: %g seconds.\n', theElapsedTime);

