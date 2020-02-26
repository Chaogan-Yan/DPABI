function [StabilityBrain_LH, StabilityBrain_RH, GHeader_LH, GHeader_RH] = y_Stability_Surf_Window(WindowSize, WindowStep, WindowType, InFile_LH, InFile_RH, InFile_Volume, ROIDef, OutputName_LH, OutputName_RH, AMaskFilename_LH, AMaskFilename_RH, IsMultipleLabel, IsNeedDetrend, CUTNUMBER)
% [StabilityBrain_LH, StabilityBrain_RH, GHeader_LH, GHeader_RH] = y_Stability_Surf_Window(WindowSize, WindowStep, WindowType, InFile_LH, InFile_RH, InFile_Volume, ROIDef, OutputName_LH, OutputName_RH, AMaskFilename_LH, AMaskFilename_RH, IsMultipleLabel, IsNeedDetrend, CUTNUMBER)
% Calculate Stability according to Li, L., Lu, B., Yan, C.G., 2019. Stability of dynamic functional architecture differs between brain networks and states. Neuroimage, 116230.
% Input:
%   WindowSize      -   the size of the sliding window
%   WindowStep      -   the step size
%   WindowType      -   the type of window (e.g., hamming)
% 	InFile_LH	    -   The input surface time series file for left hemishpere
% 	InFile_RH	    -   The input surface time series file for right hemishpere
% 	InFile_Volume   -   The volume file that used to extract atlas time courses. Can be ignored if calculate Vertex To Vertex stability
%   ROIDef          -   The way to calculate stability (Vertex To Vertex or Vertex To Atlas)
%                       -1. if calculate Vertex To Vertex, then input 'VertexToVertex'
%                       -2. if calculate Vertex To Atlas, then should define the atlas as ROI struct.
%                       ROIDef.SurfLH; ROIDef.SurfRH; ROIDef.Volume. 
%                       ROIDef.SurfLH; ROIDef.SurfRH should be cells. Each cell could be:
%                       -(1). mask martrix (nDimVertex*1)
%                       -(2). Series matrix (DimTimePoints*1)
%                       -(3). .gii mask file
%                       -(4). .txt Series. If multiple columns, when IsMultipleLabel==1: each column is a seperate seed series
%                                                             when IsMultipleLabel==0: average all the columns and take the mean series (one column) as seed series
%                       ROIDef.Volume should be:
%                       -(1). 3D mask martrix (DimX*DimY*DimZ)
%                       -(2). Series matrix (DimTimePoints*1)
%                       -(3). REST Sphere Definition
%                       -(4). .img/.nii/.nii.gz mask file
%                       -(5). .txt Series. If multiple columns, when IsMultipleLabel==1: each column is a seperate seed series
%	OutputName_LH  	-	Output filename for left hemishpere.
%	OutputName_RH  	-	Output filename for right hemishpere.
% 	AMaskFilename_LH	the mask file name ofr left hemishpere, only compute the point within the mask
% 	AMaskFilename_RH	the mask file name ofr right hemishpere, only compute the point within the mask
%   IsMultipleLabel -   1: There are multiple labels in the ROI mask file. Will extract each of them. (e.g., for aal.nii, extract all the time series for 116 regions)
%                       0 (default): All the non-zero values will be used to define the only ROI
%   IsNeedDetrend   -   0: Dot not detrend; 1: Use Matlab's detrend
%   CUTNUMBER       -   Cut the data into pieces if small RAM memory e.g. 4GB is available on PC. It can be set to 1 on server with big memory.
%                       default: 1
% Output:
%	StabilityBrain  -   The Stability
%   GHeader_LH         -   The GIfTI Header for for left hemishpere
%   GHeader_RH         -   The GIfTI Header for for right hemishpere
%   The Stability image will be output as where OutputName specified.
%___________________________________________________________________________
% Written by YAN Chao-Gan 200224. Based on Li, L., Lu, B., Yan, C.G., 2019. Stability of dynamic functional architecture differs between brain networks and states. Neuroimage, 116230.
% The R-fMRI Lab, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% International Big-Data Center for Depression Research, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com


if ~exist('ROIDef','var') || isempty(ROIDef)
    ROIDef = 'VertexToVertex';
end

if ~exist('IsMultipleLabel','var')
    IsMultipleLabel = 0;
end

if ~exist('CUTNUMBER','var')
    CUTNUMBER = 1;
end


theElapsedTime =cputime;
fprintf('\nComputing Stability...');


[AllVolume_LH,~,~,GHeader_LH] = y_ReadAll(InFile_LH);
[nDimVertex_LH nDimTimePoints]=size(AllVolume_LH);

fprintf('\nLoad mask "%s".\n', AMaskFilename_LH);
if ~isempty(AMaskFilename_LH)
    MaskData=y_ReadAll(AMaskFilename_LH);
    if size(MaskData,1)~=nDimVertex_LH
        error('The size of Mask (%d) doesn''t match the required size (%d).\n',size(MaskData,1), nDimVertex);
    end
    MaskData = double(logical(MaskData));
else
    MaskData=ones(nDimVertex_LH,1);
end
MaskDataOneDim_LH=reshape(MaskData,1,[]);
MaskIndex_LH = find(MaskDataOneDim_LH);


[AllVolume_RH,~,~,GHeader_RH] = y_ReadAll(InFile_RH);
[nDimVertex_RH nDimTimePoints]=size(AllVolume_RH);

fprintf('\nLoad mask "%s".\n', AMaskFilename_RH);
if ~isempty(AMaskFilename_RH)
    MaskData=y_ReadAll(AMaskFilename_RH);
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


AllVolume = cat(2,AllVolume_LH,AllVolume_RH);

if ischar(ROIDef) && strcmpi(ROIDef,'VertexToVertex')
    SeedSeries = AllVolume; %This is VertexToVertex Stability
else
    % This is the VertexToAtlas Stability
    % Extract the Seed Time Courses
    ROISignalsSurfLH=[];
    ROISignalsSurfRH=[];
    ROISignalsVolu=[];
    % Left Hemi
    if ~isempty(ROIDef.SurfLH)
        [ROISignalsSurfLH] = y_ExtractROISignal_Surf(InFile_LH, ...
            ROIDef.SurfLH, ...
            '', ... % Will not output files
            '', ... % Will not restrict into the brain mask in extracting ROI signals
            IsMultipleLabel);
    end
    % Right Hemi
    if ~isempty(ROIDef.SurfRH)
        [ROISignalsSurfRH] = y_ExtractROISignal_Surf(InFile_RH, ...
            ROIDef.SurfRH, ...
            '', ... % Will not output files
            '', ... % Will not restrict into the brain mask in extracting ROI signals
            IsMultipleLabel);
    end
    % Volume
    if ~isempty(ROIDef.Volume)  % YAN Chao-Gan, 190708: if (Cfg.IsProcessVolumeSpace==1) && (~isempty(Cfg.CalFC.ROIDefVolu))
        [ROISignalsVolu] = y_ExtractROISignal(InFile_Volume, ...
            ROIDef.Volume, ...
            '', ... % Will not output files
            '', ... % Will not restrict into the brain mask in extracting ROI signals
            IsMultipleLabel);
    end
    
    SeedSeries = [ROISignalsSurfLH, ROISignalsSurfRH, ROISignalsVolu];
    
    % Detrend
    if exist('IsNeedDetrend','var') && IsNeedDetrend==1
        SeedSeries=detrend(SeedSeries);
    end
end


nWindow = fix((nDimTimePoints - WindowSize)/WindowStep) + 1;
nDimTimePoints_WithinWindow = WindowSize;

CUTNUMBER = CUTNUMBER * ceil(size(AllVolume,2)*size(SeedSeries,2)*nWindow*8/2000000000); %More cut needed for Stability calculation

if ischar(WindowType)
    eval(['WindowType = ',WindowType,'(WindowSize);'])
end

fprintf('\n\t Stability Calculating...');
SegmentLength = ceil(size(AllVolume,2) / CUTNUMBER);
CUTNUMBER = ceil(size(AllVolume,2) / SegmentLength); % Revise CUTNUMBER in case SegmentLength*CUTNUMBER is too bigger than size(AllVolume,2)

Stability = zeros(size(AllVolume,2),1);
for iCut=1:CUTNUMBER
    fprintf('\nProcessing Cut %g of total %g Cuts\n', iCut, CUTNUMBER);
    if iCut~=CUTNUMBER
        Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
    else
        Segment = (iCut-1)*SegmentLength+1 : size(AllVolume,2);
    end
    
    dFC_Segment = zeros(length(Segment), size(SeedSeries,2), nWindow);
    for iWindow = 1:nWindow
        AllVolumeWindow = AllVolume((iWindow-1)*WindowStep+1:(iWindow-1)*WindowStep+WindowSize,Segment);
        AllVolumeWindow = AllVolumeWindow.*repmat(WindowType(:),1,size(AllVolumeWindow,2));
        SeedSeriesWindow = SeedSeries((iWindow-1)*WindowStep+1:(iWindow-1)*WindowStep+WindowSize,:);
        SeedSeriesWindow = SeedSeriesWindow.*repmat(WindowType(:),1,size(SeedSeriesWindow,2));

        % ZeroMeanOneStd
        AllVolumeWindow = (AllVolumeWindow-repmat(mean(AllVolumeWindow),size(AllVolumeWindow,1),1))./repmat(std(AllVolumeWindow),size(AllVolumeWindow,1),1);   %Zero mean and one std
        AllVolumeWindow(isnan(AllVolumeWindow))=0;
        SeedSeriesWindow = (SeedSeriesWindow-repmat(mean(SeedSeriesWindow),size(SeedSeriesWindow,1),1))./repmat(std(SeedSeriesWindow),size(SeedSeriesWindow,1),1);   %Zero mean and one std
        SeedSeriesWindow(isnan(SeedSeriesWindow))=0;

        FC_Segment = AllVolumeWindow'*SeedSeriesWindow/(nDimTimePoints_WithinWindow-1);
        dFC_Segment(:, :, iWindow) = FC_Segment; %%% vertex x template x window
    end
    Stability(Segment) = y_kendallW(permute(dFC_Segment, [2 3 1]));   %%% after permute: template x window x vertex 
end

StabilityBrain_LH = zeros(nDimVertex_LH,1);
StabilityBrain_LH(MaskIndex_LH,1) = Stability(1:length(MaskIndex_LH));
StabilityBrain_RH = zeros(nDimVertex_RH,1);
StabilityBrain_RH(MaskIndex_RH,1) = Stability(length(MaskIndex_LH)+1:end);

y_Write(StabilityBrain_LH,GHeader_LH,OutputName_LH);
y_Write(StabilityBrain_RH,GHeader_RH,OutputName_RH);

theElapsedTime = cputime - theElapsedTime;
fprintf('\nStability compution over, elapsed time: %g seconds.\n', theElapsedTime);
