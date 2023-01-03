function [ROISignals] = y_ExtractROISignal(AllVolume, ROIDef, OutputName, MaskData, IsMultipleLabel, ROISelectedIndex, IsNeedDetrend, Band, TR, TemporalMask, ScrubbingMethod, ScrubbingTiming, Header, CUTNUMBER)             
% [ROISignals] = y_ExtractROISignal(AllVolume, ROIDef, OutputName, MaskData, IsMultipleLabel, ROISelectedIndex, IsNeedDetrend, Band, TR, TemporalMask, ScrubbingMethod, ScrubbingTiming, Header, CUTNUMBER)             
% Extract the ROI signals
% Input:
% 	AllVolume		-	4D data matrix (DimX*DimY*DimZ*DimTimePoints) or the directory of 3D image data file or the filename of one 4D data file
%   ROIDef              ROI definition, cells. Each cell could be:
%                       -1. 3D mask martrix (DimX*DimY*DimZ)
%                       -2. Series matrix (DimTimePoints*1)
%                       -3. REST Sphere Definition
%                       -4. .img/.nii/.nii.gz mask file
%                       -5. .txt Series. If multiple columns, when IsMultipleLabel==1: each column is a seperate seed series
%                                                             when IsMultipleLabel==0: average all the columns and take the mean series (one column) as seed series
%	OutputName  	-	Output filename
% 	MaskData		-   The Brain Mask matrix (DimX*DimY*DimZ) or the Brain Mask file name
%   IsMultipleLabel -   1: There are multiple labels in the ROI mask file. Will extract each of them. (e.g., for aal.nii, extract all the time series for 116 regions)
%                       0 (default): All the non-zero values will be used to define the only ROI
%   ROISelectedIndex -  Only extract ROIs defined by ROISelectedIndex. Empty means extract all non-zero ROIs.
%   IsNeedDetrend   -   0: Dot not detrend; 1: Use Matlab's detrend
%   Band            -   Temporal filter band: matlab's ideal filter e.g. [0.01 0.08]
%   TR              -   The TR of scanning. (Used for filtering.)
%   TemporalMask    -   Temporal mask for scrubbing (DimTimePoints*1)
%                   -   Empty (blank: '' or []) means do not need scrube. Then ScrubbingMethod and ScrubbingTiming can leave blank
%   ScrubbingMethod -   The methods for scrubbing.
%                       -1. 'cut': discarding the timepoints with TemporalMask == 0
%                       -2. 'nearest': interpolate the timepoints with TemporalMask == 0 by Nearest neighbor interpolation 
%                       -3. 'linear': interpolate the timepoints with TemporalMask == 0 by Linear interpolation
%                       -4. 'spline': interpolate the timepoints with TemporalMask == 0 by Cubic spline interpolation
%                       -5. 'pchip': interpolate the timepoints with TemporalMask == 0 by Piecewise cubic Hermite interpolation
%   ScrubbingTiming -   The timing for scrubbing.
%                       -1. 'BeforeFiltering': scrubbing (and interpolation, if) before detrend (if) and filtering (if).
%                       -2. 'AfterFiltering': scrubbing after filtering, right before extract ROI TC and FC analysis
%   Header          -   If AllVolume is given as a 4D Brain matrix, then Header should be designated.
%   CUTNUMBER       -   Cut the data into pieces if small RAM memory e.g. 4GB is available on PC. It can be set to 1 on server with big memory (e.g., 50GB).
%                       default: 10
% Output:
%	ROISignals      -   The ROI signals
%   The ROI signals will be output as where OutputName specified.
%-----------------------------------------------------------
% Written by YAN Chao-Gan 120216 based on fc.m.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com

if ~exist('IsMultipleLabel','var')
    IsMultipleLabel = 0;
end

if ~exist('CUTNUMBER','var')
    CUTNUMBER = 10;
end

if ~exist('ROISelectedIndex','var')
    ROISelectedIndex = [];
end

theElapsedTime =cputime;
fprintf('\n\t Extracting ROI signals...');

if ~isnumeric(AllVolume)
    [AllVolume,VoxelSize,theImgFileList, Header] =y_ReadAll(AllVolume);
end

AllVolume(find(isnan(AllVolume))) = 0; %YAN Chao-Gan, 171022. Set the NaN voxels to 0.

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

% Convert into 2D
AllVolume=reshape(AllVolume,[],nDimTimePoints)';
% AllVolume=permute(AllVolume,[4,1,2,3]); % Change the Time Course to the first dimention
% AllVolume=reshape(AllVolume,nDimTimePoints,[]);

MaskDataOneDim=reshape(MaskData,1,[]);
MaskIndex = find(MaskDataOneDim);
AllVolume=AllVolume(:,MaskIndex);

% Scrubbing
if exist('TemporalMask','var') && ~isempty(TemporalMask) && ~strcmpi(ScrubbingTiming,'AfterFiltering')
    if ~all(TemporalMask)
        AllVolume = AllVolume(find(TemporalMask),:); %'cut'
        if ~strcmpi(ScrubbingMethod,'cut')
            xi=1:length(TemporalMask);
            x=xi(find(TemporalMask));
            AllVolume = interp1(x,AllVolume,xi,ScrubbingMethod);
        end
        nDimTimePoints = size(AllVolume,1);
    end
end


% Detrend
if exist('IsNeedDetrend','var') && IsNeedDetrend==1
    %AllVolume=detrend(AllVolume);
    fprintf('\n\t Detrending...');
    SegmentLength = ceil(size(AllVolume,2) / CUTNUMBER);
    for iCut=1:CUTNUMBER
        if iCut~=CUTNUMBER
            Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
        else
            Segment = (iCut-1)*SegmentLength+1 : size(AllVolume,2);
        end
        AllVolume(:,Segment) = detrend(AllVolume(:,Segment));
        fprintf('.');
    end
end

% Filtering
if exist('Band','var') && ~isempty(Band)
    fprintf('\n\t Filtering...');
    SegmentLength = ceil(size(AllVolume,2) / CUTNUMBER);
    for iCut=1:CUTNUMBER
        if iCut~=CUTNUMBER
            Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
        else
            Segment = (iCut-1)*SegmentLength+1 : size(AllVolume,2);
        end
        AllVolume(:,Segment) = y_IdealFilter(AllVolume(:,Segment), TR, Band);
        fprintf('.');
    end
end



% Scrubbing after filtering
if exist('TemporalMask','var') && ~isempty(TemporalMask) && strcmpi(ScrubbingTiming,'AfterFiltering')
    if ~all(TemporalMask)
        AllVolume = AllVolume(find(TemporalMask),:); %'cut'
        if ~strcmpi(ScrubbingMethod,'cut')
            xi=1:length(TemporalMask);
            x=xi(find(TemporalMask));
            AllVolume = interp1(x,AllVolume,xi,ScrubbingMethod);
        end
        nDimTimePoints = size(AllVolume,1);
    end
end


% Extract the Seed Time Courses

SeedSeries = [];
MaskROIName=[];

for iROI=1:length(ROIDef)
    IsDefinedROITimeCourse =0;
    if strcmpi(int2str(size(ROIDef{iROI})),int2str([nDim1, nDim2, nDim3]))  %ROI Data
        MaskROI = ROIDef{iROI};
        MaskROIName{iROI} = sprintf('Mask Matrix definition %d',iROI);
    elseif (size(ROIDef{iROI},1) == nDimTimePoints) && (nDimTimePoints > 1) %size(ROIDef{iROI},1) == nDimTimePoints %Seed series% strcmpi(int2str(size(ROIDef{iROI})),int2str([nDimTimePoints, 1])) %Seed series
        SeedSeries{1,iROI} = ROIDef{iROI};
        IsDefinedROITimeCourse =1;
        MaskROIName{iROI} = sprintf('Seed Series definition %d',iROI);
    elseif strcmpi(int2str(size(ROIDef{iROI})),int2str([1, 4]))  %Sphere ROI definition: CenterX, CenterY, CenterZ, Radius
        MaskROI = y_Sphere(ROIDef{iROI}(1:3), ROIDef{iROI}(4), Header);
        MaskROIName{iROI} = sprintf('Sphere definition (CenterX, CenterY, CenterZ, Radius): %g %g %g %g.',ROIDef{iROI});
    elseif exist(ROIDef{iROI},'file')==2	% Make sure the Definition file exist
        [pathstr, name, ext] = fileparts(ROIDef{iROI});
        if strcmpi(ext, '.txt'),
            TextSeries = load(ROIDef{iROI});
            if IsMultipleLabel == 1
                for iElement=1:size(TextSeries,2)
                    MaskROILabel{1,iROI}{iElement,1} = ['Column ',num2str(iElement)];
                end
                SeedSeries{1,iROI} = TextSeries;
            else
                SeedSeries{1,iROI} = mean(TextSeries,2);
            end
            IsDefinedROITimeCourse =1;
            MaskROIName{iROI} = ROIDef{iROI};
        elseif strcmpi(ext, '.img') || strcmpi(ext, '.nii') || strcmpi(ext, '.gz')
            %The ROI definition is a mask file
            
            MaskROI=y_ReadRPI(ROIDef{iROI});
            if ~strcmpi(int2str(size(MaskROI)),int2str([nDim1, nDim2, nDim3]))
                error(sprintf('\n\tMask does not match.\n\tMask size is %dx%dx%d, not same with required size %dx%dx%d',size(MaskROI), [nDim1, nDim2, nDim3]));
            end

            MaskROIName{iROI} = ROIDef{iROI};
        else
            error(sprintf('Wrong ROI file type, please check: \n%s', ROIDef{iROI}));
        end
        
    else
        error(sprintf('File doesn''t exist or wrong ROI definition, please check: %s.\n', ROIDef{iROI}));
    end

    if ~IsDefinedROITimeCourse
        % Speed up! YAN Chao-Gan 101010.
        MaskROI=reshape(MaskROI,1,[]);
        MaskROI=MaskROI(MaskIndex); %Apply the brain mask
        
        if IsMultipleLabel == 1

            if ~isempty(ROISelectedIndex) && ~isempty(ROISelectedIndex{iROI})
                Element=ROISelectedIndex{iROI};
            else
                Element = unique(MaskROI);
                Element(find(isnan(Element))) = []; % ignore background if encoded as nan. Suggested by Dr. Martin Dyrba
                Element(find(Element==0)) = []; % This is the background 0
            end

            SeedSeries_MultipleLabel = zeros(nDimTimePoints,length(Element));
            for iElement=1:length(Element)
                
                SeedSeries_MultipleLabel(:,iElement) = mean(AllVolume(:,find(MaskROI==Element(iElement))),2);
                
                MaskROILabel{1,iROI}{iElement,1} = num2str(Element(iElement));

            end
            SeedSeries{1,iROI} = SeedSeries_MultipleLabel;
        else
            SeedSeries{1,iROI} = mean(AllVolume(:,find(MaskROI)),2);
        end
    end
end


%Merge the seed series cell into seed series matrix
ROISignals = double(cell2mat(SeedSeries)); %Suggested by H. Baetschmann.    %ROISignals = cell2mat(SeedSeries);


%Save the results
if ~isempty(OutputName)
    [pathstr, name, ext] = fileparts(OutputName);
    
    save([fullfile(pathstr,['ROISignals_', name]), '.mat'], 'ROISignals')
    save([fullfile(pathstr,['ROISignals_', name]), '.txt'], 'ROISignals', '-ASCII', '-DOUBLE','-TABS')
    
    ROICorrelation = corrcoef(ROISignals);
    save([fullfile(pathstr,['ROICorrelation_', name]), '.mat'], 'ROICorrelation')
    save([fullfile(pathstr,['ROICorrelation_', name]), '.txt'], 'ROICorrelation', '-ASCII', '-DOUBLE','-TABS')
    
    ROICorrelation_FisherZ = 0.5 * log((1 + ROICorrelation)./(1- ROICorrelation));
    save([fullfile(pathstr,['ROICorrelation_FisherZ_', name]), '.mat'], 'ROICorrelation_FisherZ')
    save([fullfile(pathstr,['ROICorrelation_FisherZ_', name]), '.txt'], 'ROICorrelation_FisherZ', '-ASCII', '-DOUBLE','-TABS')
    
    
    %Write the order key file as .tsv
    fid = fopen([fullfile(pathstr,['ROI_OrderKey_', name]), '.tsv'],'w');
    if IsMultipleLabel == 1
        if size(MaskROILabel,2) < length(ROIDef) %YAN Chao-Gan, 131124. To avoid if the labels of the last ROI has been defined.
            MaskROILabel{1,length(ROIDef)} = []; % Force the undefined cells to empty
        end
        fprintf(fid,'Order\tLabel in Mask\tROI Definition\n');
        iOrder = 1;
        for iROI=1:length(ROIDef)
            if isempty(MaskROILabel{1,iROI})
                fprintf(fid,'%d\t\t%s\n',iOrder,MaskROIName{iROI});
                iOrder = iOrder + 1;
            else
                for iElement=1:length(MaskROILabel{1,iROI})
                    fprintf(fid,'%d\t%s\t%s\n',iOrder,MaskROILabel{1,iROI}{iElement,1},MaskROIName{iROI});
                    iOrder = iOrder + 1;
                end
            end
        end
    else
        fprintf(fid,'Order\tROI Definition\n');
        for iROI=1:length(ROIDef)
            fprintf(fid,'%d\t%s\n',iROI,MaskROIName{iROI});
        end
    end
    fclose(fid);
end


theElapsedTime = cputime - theElapsedTime;
fprintf('\n\t Extracting ROI signals finished, elapsed time: %g seconds.\n', theElapsedTime);
