function [ROICenter,XYZCenter,IJKCenter] = y_ExtractROICenterOfMass(ROIDef, OutputName, IsMultipleLabel, ROISelectedIndex, RefFile, Header)             
% [ROICenter,XYZCenter,IJKCenter] = y_ExtractROICenterOfMass(ROIDef, OutputName, IsMultipleLabel, ROISelectedIndex, RefFile, Header)             
% Extract the ROI Center of Mass
% Input:

%   ROIDef              ROI definition, cells. Each cell could be:
%                       -1. 3D mask martrix (DimX*DimY*DimZ)
%                       -2. Series matrix (DimTimePoints*1)
%                       -3. REST Sphere Definition
%                       -4. .img/.nii/.nii.gz mask file
%                       -5. .txt Series. If multiple columns, when IsMultipleLabel==1: each column is a seperate seed series
%                                                             when IsMultipleLabel==0: average all the columns and take the mean series (one column) as seed series
%	OutputName  	-	Output filename
%   IsMultipleLabel -   1: There are multiple labels in the ROI mask file. Will extract each of them. (e.g., for aal.nii, extract all the time series for 116 regions)
%                       0 (default): All the non-zero values will be used to define the only ROI
%   ROISelectedIndex -  Only extract ROIs defined by ROISelectedIndex. Empty means extract all non-zero ROIs.
% 	RefFile		    -	Ref file. Can be 4D data matrix (DimX*DimY*DimZ*DimTimePoints) or the directory of 3D image data file or the filename of one 4D data file
%   Header          -   If RefFile is given as a 4D Brain matrix, then Header should be designated.
% Output:
%	ROICenter       -   The ROI Center of Mass
%	XYZCenter       -   The ROI Center of Mass for XYZ
%	IJKCenter       -   The ROI Center of Mass for IJK
%   The ROI Center of Mass will be output as where OutputName specified.
%___________________________________________________________________________
% Written by YAN Chao-Gan 210119.
% International Big-Data Center for Depression Research
% Magnetic Resonance Imaging Research Center
% Institute of Psychology, Chinese Academy of Sciences
% ycg.yan@gmail.com

if ~exist('IsMultipleLabel','var')
    IsMultipleLabel = 0;
end

if ~exist('ROISelectedIndex','var')
    ROISelectedIndex = [];
end

theElapsedTime =cputime;
fprintf('\n\t Extracting ROI Center Of Mass...');

XYZCenter=[];
IJKCenter=[];

if ~isnumeric(RefFile)
    [RefFile,VoxelSize,theImgFileList, Header] =y_ReadAll(RefFile);
end
[nDim1 nDim2 nDim3 nDimTimePoints]=size(RefFile);

for iROI=1:length(ROIDef)
    IsDefinedCenter =0;
    if strcmpi(int2str(size(ROIDef{iROI})),int2str([nDim1, nDim2, nDim3]))  %ROI Data
        MaskROI = ROIDef{iROI};

    elseif size(ROIDef{iROI},1) == nDimTimePoints %Seed series% strcmpi(int2str(size(ROIDef{iROI})),int2str([nDimTimePoints, 1])) %Seed series
        XYZCenter=[XYZCenter;[0 0 0]];
        IJKCenter=[IJKCenter;[0 0 0]];
        IsDefinedCenter=1;
    elseif strcmpi(int2str(size(ROIDef{iROI})),int2str([1, 4]))  %Sphere ROI definition: CenterX, CenterY, CenterZ, Radius
        XYZCenter=[XYZCenter;ROIDef{iROI}(1:3)];
        IJKCenterTemp = inv(Header.mat)*[ROIDef{iROI}(1:3)';1];
        IJKCenter=[IJKCenter;round(IJKCenterTemp(1:3)')];
        IsDefinedCenter=1;
    elseif exist(ROIDef{iROI},'file')==2	% Make sure the Definition file exist
        [pathstr, name, ext] = fileparts(ROIDef{iROI});
        if strcmpi(ext, '.txt'),
            TextSeries = load(ROIDef{iROI});
            if IsMultipleLabel == 1
                
                XYZCenter=[XYZCenter;repmat([0 0 0],[size(TextSeries,2) 1])];
                IJKCenter=[IJKCenter;repmat([0 0 0],[size(TextSeries,2) 1])];
                
            else
                XYZCenter=[XYZCenter;[0 0 0]];
                IJKCenter=[IJKCenter;[0 0 0]];
            end
            IsDefinedCenter =1;

        elseif strcmpi(ext, '.img') || strcmpi(ext, '.nii') || strcmpi(ext, '.gz')
            %The ROI definition is a mask file
            MaskROI=y_ReadRPI(ROIDef{iROI});
            if ~strcmpi(int2str(size(MaskROI)),int2str([nDim1, nDim2, nDim3]))
                error(sprintf('\n\tMask does not match.\n\tMask size is %dx%dx%d, not same with required size %dx%dx%d',size(MaskROI), [nDim1, nDim2, nDim3]));
            end
        else
            error(sprintf('Wrong ROI file type, please check: \n%s', ROIDef{iROI}));
        end
        
    else
        error(sprintf('File doesn''t exist or wrong ROI definition, please check: %s.\n', ROIDef{iROI}));
    end

    if ~IsDefinedCenter
        [I J K] = ndgrid(1:nDim1,1:nDim2,1:nDim3);

        if IsMultipleLabel == 1

            if ~isempty(ROISelectedIndex) && ~isempty(ROISelectedIndex{iROI})
                Element=ROISelectedIndex{iROI};
            else
                Element = unique(MaskROI);
                Element(find(isnan(Element))) = []; % ignore background if encoded as nan. Suggested by Dr. Martin Dyrba
                Element(find(Element==0)) = []; % This is the background 0
            end

            for iElement=1:length(Element)

                ICenter = round(mean(I(MaskROI==Element(iElement))));
                JCenter = round(mean(J(MaskROI==Element(iElement))));
                KCenter = round(mean(K(MaskROI==Element(iElement))));
                
                IJKCenter=[IJKCenter;[ICenter,JCenter,KCenter]];
                
                XYZCenterTemp = Header.mat*[ICenter JCenter KCenter 1]';
                
                XYZCenter=[XYZCenter;XYZCenterTemp(1:3)'];

            end
        else
            ICenter = round(mean(I(MaskROI~=0)));
            JCenter = round(mean(J(MaskROI~=0)));
            KCenter = round(mean(K(MaskROI~=0)));
            
            IJKCenter=[IJKCenter;[ICenter,JCenter,KCenter]];
            
            XYZCenterTemp = Header.mat*[ICenter JCenter KCenter 1]';
            
            XYZCenter=[XYZCenter;XYZCenterTemp(1:3)'];
        end
    end
end

ROICenter=[XYZCenter,IJKCenter];

if exist('OutputName','var') && ~isempty(OutputName)
    save(OutputName, 'ROICenter');
end

theElapsedTime = cputime - theElapsedTime;
fprintf('\n\t Extracting ROI Center of Mass finished, elapsed time: %g seconds.\n', theElapsedTime);
