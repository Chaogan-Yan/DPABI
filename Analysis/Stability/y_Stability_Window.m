function [StabilityBrain, Header] = y_Stability_Window(WindowSize, WindowStep, WindowType, AllVolume, ROIDef, OutputName, MaskData, IsMultipleLabel, IsNeedDetrend, Header, CUTNUMBER)
% [StabilityBrain, Header] = y_Stability_Window(WindowSize, WindowStep, WindowType, AllVolume, ROIDef, OutputName, MaskData, IsMultipleLabel, IsNeedDetrend, Header, CUTNUMBER)
% Calculate Stability according to Li, L., Lu, B., Yan, C.G., 2019. Stability of dynamic functional architecture differs between brain networks and states. Neuroimage, 116230.
% Input:
%   WindowSize      -   the size of the sliding window
%   WindowStep      -   the step size
%   WindowType      -   the type of window (e.g., hamming)
% 	AllVolume		-	4D data matrix (DimX*DimY*DimZ*DimTimePoints) or the directory of 3D image data file or the filename of one 4D data file
%   ROIDef          -   The way to calculate stability (Voxel To Voxel or Voxel To Atlas)
%                       -1. if calculate Voxel To Voxel, then input 'VoxelToVoxel'
%                       -2. if calculate Voxel To Atlas, then should define the atlas as ROI definition, cells. Each cell could be:
%                       -(1). 3D mask martrix (DimX*DimY*DimZ)
%                       -(2). Series matrix (DimTimePoints*1)
%                       -(3). REST Sphere Definition
%                       -(4). .img/.nii/.nii.gz mask file
%                       -(5). .txt Series. If multiple columns, when IsMultipleLabel==1: each column is a seperate seed series
%	OutputName  	-	Output filename.
% 	MaskData		-   Mask matrix (DimX*DimY*DimZ) or the mask file name
%   IsMultipleLabel -   1: There are multiple labels in the ROI mask file. Will extract each of them. (e.g., for aal.nii, extract all the time series for 116 regions)
%                       0 (default): All the non-zero values will be used to define the only ROI
%   IsNeedDetrend   -   0: Dot not detrend; 1: Use Matlab's detrend
%   Header          -   If AllVolume is given as a 4D Brain matrix, then Header should be designated.
%   CUTNUMBER       -   Cut the data into pieces if small RAM memory e.g. 4GB is available on PC. It can be set to 1 on server with big memory.
%                       default: 1
% Output:
%	StabilityBrain  -   The Stability
%   Header          -   The NIfTI Header
%   The Stability image will be output as where OutputName specified.
%___________________________________________________________________________
% Written by YAN Chao-Gan 200221. Based on Li, L., Lu, B., Yan, C.G., 2019. Stability of dynamic functional architecture differs between brain networks and states. Neuroimage, 116230.
% The R-fMRI Lab, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% International Big-Data Center for Depression Research, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com



if ~exist('ROIDef','var') || isempty(ROIDef)
    ROIDef = 'VoxelToVoxel';
end

if ~exist('IsMultipleLabel','var')
    IsMultipleLabel = 0;
end

if ~exist('CUTNUMBER','var')
    CUTNUMBER = 1;
end


theElapsedTime =cputime;
fprintf('\nComputing Stability...');

if ~isnumeric(AllVolume)
    [AllVolume,VoxelSize,theImgFileList, Header] =y_ReadAll(AllVolume);
end

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

MaskDataOneDim=reshape(MaskData,1,[]);
MaskIndex = find(MaskDataOneDim);
nVoxel = length(MaskIndex);

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


if ischar(ROIDef) && strcmpi(ROIDef,'VoxelToVoxel')
    SeedSeries = AllVolume; %This is VoxelToVoxel Stability
else
    % This is the VoxelToAtlas Stability
    % Extract the Seed Time Courses
    SeedSeries = [];
    MaskROIName=[];
    
    for iROI=1:length(ROIDef)
        IsDefinedROITimeCourse =0;
        if strcmpi(int2str(size(ROIDef{iROI})),int2str([nDim1, nDim2, nDim3]))  %ROI Data
            MaskROI = ROIDef{iROI};
            MaskROIName{iROI} = sprintf('Mask Matrix definition %d',iROI);
        elseif strcmpi(int2str(size(ROIDef{iROI})),int2str([nDimTimePoints, 1])) %Seed series
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
                Element = unique(MaskROI);
                Element(find(Element==0)) = []; % This is the background 0
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
    SeedSeries = double(cell2mat(SeedSeries)); %Suggested by H. Baetschmann.  % SeedSeries = cell2mat(SeedSeries);
    
    
    %Save the ROI averaged time course to disk for further study
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
end






nWindow = fix((nDimTimePoints - WindowSize)/WindowStep) + 1;
nDimTimePoints_WithinWindow = WindowSize;

CUTNUMBER = CUTNUMBER * ceil(nVoxel*size(SeedSeries,2)*nWindow*8/2000000000); %More cut needed for Stability calculation

if ischar(WindowType)
    eval(['WindowType = ',WindowType,'(WindowSize);'])
end

fprintf('\n\t Stability Calculating...');
SegmentLength = ceil(nVoxel / CUTNUMBER);
CUTNUMBER = ceil(nVoxel / SegmentLength); % Revise CUTNUMBER in case SegmentLength*CUTNUMBER is too bigger than size(AllVolume,2)

Stability = zeros(length(MaskIndex),1);
for iCut=1:CUTNUMBER
    fprintf('\nProcessing Cut %g of total %g Cuts\n', iCut, CUTNUMBER);
    if iCut~=CUTNUMBER
        Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
    else
        Segment = (iCut-1)*SegmentLength+1 : nVoxel;
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
        dFC_Segment(:, :, iWindow) = FC_Segment; %%% voxel x template x window
    end
    Stability(Segment) = y_kendallW(permute(dFC_Segment, [2 3 1]));   %%% after permute: template x window x voxel 
end

 
StabilityBrain=zeros(size(MaskDataOneDim));
StabilityBrain(1,MaskIndex)=Stability;
StabilityBrain=reshape(StabilityBrain,nDim1, nDim2, nDim3);

Header.pinfo = [1;0;0];
Header.dt    =[16,0];

y_Write(StabilityBrain,Header,OutputName);

theElapsedTime = cputime - theElapsedTime;
fprintf('\nStability compution over, elapsed time: %g seconds.\n', theElapsedTime);
