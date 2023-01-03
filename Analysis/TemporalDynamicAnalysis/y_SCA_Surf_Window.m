function [FCBrain_AllWindow, zFCBrain_AllWindow, GHeader] = y_SCA_Surf_Window(WindowSize, WindowStep, WindowType, AllVolume, ROIDef, OutputName, AMaskFilename, IsMultipleLabel, ROISelectedIndex, IsNeedDetrend, GHeader, CUTNUMBER)
% [FCBrain_AllWindow, zFCBrain_AllWindow, GHeader] = y_SCA_Surf_Window(WindowSize, WindowStep, WindowType, AllVolume, ROIDef, OutputName, AMaskFilename, IsMultipleLabel, ROISelectedIndex, IsNeedDetrend, GHeader, CUTNUMBER)
% Calculate Dynamic Functional Connectivity by Seed based Correlation Anlyasis
% Input:
%   WindowSize      -   the size of the sliding window
%   WindowStep      -   the step size
%   WindowType      -   the type of window (e.g., hamming)
% 	AllVolume       -   The input surface time series file. Or a data matrix nDimVertex*nDimTimePoints
%   ROIDef          -   ROI definition, cells. Each cell could be:
%                       -1. mask martrix (nDimVertex*1)
%                       -2. Series matrix (DimTimePoints*1)
%                       -3. .gii mask file
%                       -4. .txt Series. If multiple columns, when IsMultipleLabel==1: each column is a seperate seed series
%                                                             when IsMultipleLabel==0: average all the columns and take the mean series (one column) as seed series
%	OutputName  	-	Output filename
% 	AMaskFilename   -   Mask file name
%   IsMultipleLabel -   1: There are multiple labels in the ROI mask file. Will extract each of them. (e.g., for aal.nii, extract all the time series for 116 regions)
%                       0 (default): All the non-zero values will be used to define the only ROI
%   ROISelectedIndex -  Only extract ROIs defined by ROISelectedIndex. Empty means extract all non-zero ROIs.
%   IsNeedDetrend   -   0: Dot not detrend; 1: Use Matlab's detrend
%   GHeader         -   If AllVolume is given as a 2D Brain matrix, then Header should be designated.
%   CUTNUMBER       -   Cut the data into pieces if small RAM memory e.g. 4GB is available on PC. It can be set to 1 on server with big memory (e.g., 50GB).
%                       default: 10
% Output:
%	FCBrain_AllWindow         -   the FC of the ROIs (Only Use it correctly with only one seed)
%	zFCBrain_AllWindow         -   the FC of the ROIs after Fisher's r to z transformation
%   GHeader         -   The GIfTI Header
%   All the FC images will be output as where OutputName specified.
%-----------------------------------------------------------
% Inherited from y_SCA_Window.m
% Revised by YAN Chao-Gan 190625.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
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
    GHeader=gifti(AllVolume);
    AllVolume=GHeader.cdata;
end

AllVolume(find(isnan(AllVolume))) = 0; %YAN Chao-Gan, 171022. Set the NaN voxels to 0.

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

% Convert into 2D
AllVolume=AllVolume';
MaskIndex = find(MaskDataOneDim);
AllVolume=AllVolume(:,MaskIndex);

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


% Extract the Seed Time Courses
SeedSeries = [];
MaskROIName=[];
for iROI=1:length(ROIDef)
    IsDefinedROITimeCourse =0;
    if strcmpi(int2str(size(ROIDef{iROI})),int2str([nDimVertex 1]))  %ROI Data
        MaskROI = ROIDef{iROI};
        MaskROIName{iROI} = sprintf('Mask Matrix definition %d',iROI);
    elseif size(ROIDef{iROI},1) == nDimTimePoints %Seed series
        SeedSeries{1,iROI} = ROIDef{iROI};
        IsDefinedROITimeCourse =1;
        MaskROIName{iROI} = sprintf('Seed Series definition %d',iROI);
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
        elseif strcmpi(ext, '.gii')
            %The ROI definition is a mask file
            
            MaskROI=gifti(ROIDef{iROI});
            MaskROI=MaskROI.cdata;
            if ~strcmpi(int2str(size(MaskROI)),int2str([nDimVertex 1]))
                error(sprintf('\n\tMask does not match.\n\tMask size is %dx%d, not same with required size %dx%d',size(MaskROI), [nDimVertex 1]));
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
SeedSeries = double(cell2mat(SeedSeries)); %Suggested by H. Baetschmann.    %ROISignals = cell2mat(SeedSeries);

%Save the results
[pathstr, name, ext] = fileparts(OutputName);

save([fullfile(pathstr,['ROI_', name]), '.mat'], 'SeedSeries')
save([fullfile(pathstr,['ROI_', name]), '.txt'], 'SeedSeries', '-ASCII', '-DOUBLE','-TABS')


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

% Detrend
if exist('IsNeedDetrend','var') && IsNeedDetrend==1
    SeedSeries=detrend(SeedSeries);
end


nWindow = fix((nDimTimePoints - WindowSize)/WindowStep) + 1;
nDimTimePoints_WithinWindow = WindowSize;

FCBrain_AllWindow = zeros([nDimVertex nWindow size(SeedSeries,2)]);
zFCBrain_AllWindow = zeros([nDimVertex nWindow size(SeedSeries,2)]);

if ischar(WindowType)
    eval(['WindowType = ',WindowType,'(WindowSize);'])
end
WindowMultiplier = repmat(WindowType(:),1,size(AllVolume,2));

for iWindow = 1:nWindow
    fprintf('\nProcessing window %g of total %g windows\n', iWindow, nWindow);
    
    AllVolumeWindow = AllVolume((iWindow-1)*WindowStep+1:(iWindow-1)*WindowStep+WindowSize,:);
    AllVolumeWindow = AllVolumeWindow.*WindowMultiplier;
    
    SeedSeriesWindow = SeedSeries((iWindow-1)*WindowStep+1:(iWindow-1)*WindowStep+WindowSize,:);
    SeedSeriesWindow = SeedSeriesWindow.*repmat(WindowType(:),1,size(SeedSeriesWindow,2));
    
    
    % FC calculation
    AllVolumeWindow = AllVolumeWindow-repmat(mean(AllVolumeWindow),size(AllVolumeWindow,1),1);
    AllVolumeSTD= squeeze(std(AllVolumeWindow, 0, 1));
    AllVolumeSTD(find(AllVolumeSTD==0))=inf;
    
    SeedSeriesWindow=SeedSeriesWindow-repmat(mean(SeedSeriesWindow),size(SeedSeriesWindow,1),1);
    SeedSeriesSTD=squeeze(std(SeedSeriesWindow,0,1));
    
    
    for iROI=1:size(SeedSeriesWindow,2)
        
        FC=SeedSeriesWindow(:,iROI)'*AllVolumeWindow/(WindowSize-1);
        FC=(FC./AllVolumeSTD)/SeedSeriesSTD(iROI);
        
        % Get the brain back
        FCBrain = zeros(size(MaskDataOneDim));
        FCBrain(1,MaskIndex) = FC;
        FCBrain = FCBrain';
        
        %Also produce the results after Fisher's r to z transformation
        FCBrain(find(FCBrain>0.999999999))=0.999999999; %Prevent outliers
        FCBrain(find(FCBrain<-0.999999999))=-0.999999999;
        zFCBrain = (0.5 * log((1 + FCBrain)./(1 - FCBrain))) .* (MaskData~=0);
        
        FCBrain_AllWindow(:,iWindow,iROI) = FCBrain;
        zFCBrain_AllWindow(:,iWindow,iROI) = zFCBrain;
        
        
    end
end

for iROI=1:size(SeedSeriesWindow,2)
    [pathstr, name, ext] = fileparts(OutputName);
    if size(SeedSeries, 2)>1
        %Save every maps from result maps
        y_Write(FCBrain_AllWindow(:,:,iROI),GHeader,[fullfile(pathstr,['ROI',num2str(iROI),name, ext])]);
        y_Write(zFCBrain_AllWindow(:,:,iROI),GHeader,[fullfile(pathstr,['zROI',num2str(iROI),name, ext])]);
    elseif size(SeedSeries, 2)==1,
        %Save one map
        y_Write(FCBrain_AllWindow,GHeader,[fullfile(pathstr,[name, ext])]);
        y_Write(zFCBrain_AllWindow,GHeader,[fullfile(pathstr,['z',name, ext])]);
    end
end

theElapsedTime = cputime - theElapsedTime;
fprintf('\n\t Calculating Functional Connectivity by Seed based Correlation Anlyasis finished, elapsed time: %g seconds.\n', theElapsedTime);
