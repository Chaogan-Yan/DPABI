function [ROISignals] = y_ExtractROISignal_Surf(AllVolume, ROIDef, OutputName, AMaskFilename, IsMultipleLabel, ROISelectedIndex, GHeader, CUTNUMBER)             
% [ROISignals] = y_ExtractROISignal_Surf(AllVolume, ROIDef, OutputName, AMaskFilename, IsMultipleLabel, ROISelectedIndex, GHeader, CUTNUMBER)             
% Extract the ROI signals
% Input:
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
%   GHeader         -   If AllVolume is given as a 2D Brain matrix, then Header should be designated.
%   CUTNUMBER       -   Cut the data into pieces if small RAM memory e.g. 4GB is available on PC. It can be set to 1 on server with big memory (e.g., 50GB).
%                       default: 10
% Output:
%	ROISignals      -   The ROI signals
%   The ROI signals will be output as where OutputName specified.
%-----------------------------------------------------------
% Inherited from y_ExtractROISignal.m
% Revised by YAN Chao-Gan 181127.
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
    [AllVolume,VoxelSize,theImgFileList, Header] = y_ReadAll(AllVolume);
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
