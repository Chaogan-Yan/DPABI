function [StandardizedBrain_LH, StandardizedBrain_RH, Header_LH, Header_RH, OutNameList_LH, OutNameList_RH] = y_Standardization_Surf(ImgCells_LH, ImgCells_RH, MaskData_LH, MaskData_RH, MethodType, OutputDir, Suffix)
% [StandardizedBrain_LH, StandardizedBrain_RH, Header_LH, Header_RH, OutNameList_LH, OutNameList_RH] = y_Standardization_Surf(ImgCells_LH, ImgCells_RH, MaskData_LH, MaskData_RH, MethodType, OutputDir, Suffix)
% Standardize the brains for Statistical Analysis. Ref: Yan, C.G., Craddock, R.C., Zuo, X.N., Zang, Y.F., Milham, M.P., 2013. Standardizing the intrinsic brain: towards robust measurement of inter-individual variation in 1000 functional connectomes. Neuroimage 80, 246-262.
% Input:
% 	ImgCells_LH		-	Left Hemisphere, Input Data. 1 by N cells. For each cell, can be: 1. a single file; 2. N by 1 cell of filenames.
% 	ImgCells_RH		-	Right Hemisphere, Input Data. 1 by N cells. For each cell, can be: 1. a single file; 2. N by 1 cell of filenames.
%   MaskData_LH     -   Left Hemisphere, The mask file, within which the standardization is performed.
%   MaskData_RH     -   Right Hemisphere, The mask file, within which the standardization is performed.
%	MethodType  	-	The type of Standardization, can be:
%                       Mean Regression
%                       Mean Regression & SD Division
%                       Mean Regression & Log SD Regression
%                       Z - Standardization
%                       Mean Division
%                       Mean Subtraction
%                       Median-IQR Standardization
%                       Rank
%                       Quantile Standardization
%                       Gaussian Fit
% 	OutputDir		-   The output directory
%   Suffix          -   The Suffix added to the folder name
%
% Output:
%	StandardizedBrain         -   the brains after standardization
%   Header                    -   The NIfTI Header
%   All the standardized brains will be output as where OutputDir specified.
%-----------------------------------------------------------
% Written by YAN Chao-Gan 190716.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com


%For Left Hemisphere
ImgCells=ImgCells_LH; MaskData=MaskData_LH;

AllVolumeSet = [];
OutputFileNames = [];
fprintf('\nReading Data...\n');
for i=1:numel(ImgCells)
    ImgFiles=ImgCells{i};
    [AllVolume,VoxelSize,theImgFileList, Header] =y_ReadAll(ImgFiles);
    [nDimVertex nDimTimePoints]=size(AllVolume);
    if ischar(MaskData)
        fprintf('\nLoad mask "%s".\n', MaskData);
        if ~isempty(MaskData)
            MaskData=gifti(MaskData);
            MaskData=MaskData.cdata;
            if size(MaskData,1)~=nDimVertex
                error('The size of Mask (%d) doesn''t match the required size (%d).\n',size(MaskData,1), nDimVertex);
            end
            MaskData = double(logical(MaskData));
        else
            MaskData=ones(nDimVertex,1);
        end
    end
    % Convert into 2D. NOTE: here the first dimension is voxels,
    % and the second dimension is subjects. This is different from
    % the way used in y_bandpass.

    MaskDataOneDim=reshape(MaskData,[],1);
    MaskIndex = find(MaskDataOneDim);
    nVoxels = length(MaskIndex);
    %AllVolume=AllVolume(:,MaskIndex);
    AllVolume=AllVolume(MaskIndex,:);
    AllVolumeSet = [AllVolumeSet,AllVolume];
    if iscell(ImgFiles)
        OutputFileNames = [OutputFileNames;ImgFiles];
    else
        %OutputFileNames = [OutputFileNames;{ImgFiles}];
        %OutputFileNames{end,2} = size(AllVolume,2);
        OutputFileNames = [OutputFileNames;{ImgFiles}, size(AllVolume,2)]; %Thanks to the Report by Andrew Owenson
    end
end

AllVolumeSet_LH=AllVolumeSet;
OutputFileNames_LH=OutputFileNames;
nDimVertex_LH=nDimVertex;
MaskIndex_LH=MaskIndex;
Header_LH=Header;


%For Right Hemisphere
ImgCells=ImgCells_RH; MaskData=MaskData_RH;

AllVolumeSet = [];
OutputFileNames = [];
fprintf('\nReading Data...\n');
for i=1:numel(ImgCells)
    ImgFiles=ImgCells{i};
    [AllVolume,VoxelSize,theImgFileList, Header] =y_ReadAll(ImgFiles);
    [nDimVertex nDimTimePoints]=size(AllVolume);
    if ischar(MaskData)
        fprintf('\nLoad mask "%s".\n', MaskData);
        if ~isempty(MaskData)
            MaskData=gifti(MaskData);
            MaskData=MaskData.cdata;
            if size(MaskData,1)~=nDimVertex
                error('The size of Mask (%d) doesn''t match the required size (%d).\n',size(MaskData,1), nDimVertex);
            end
            MaskData = double(logical(MaskData));
        else
            MaskData=ones(nDimVertex,1);
        end
    end
    % Convert into 2D. NOTE: here the first dimension is voxels,
    % and the second dimension is subjects. This is different from
    % the way used in y_bandpass.

    MaskDataOneDim=reshape(MaskData,[],1);
    MaskIndex = find(MaskDataOneDim);
    nVoxels = length(MaskIndex);
    %AllVolume=AllVolume(:,MaskIndex);
    AllVolume=AllVolume(MaskIndex,:);
    AllVolumeSet = [AllVolumeSet,AllVolume];
    if iscell(ImgFiles)
        OutputFileNames = [OutputFileNames;ImgFiles];
    else
        %OutputFileNames = [OutputFileNames;{ImgFiles}];
        %OutputFileNames{end,2} = size(AllVolume,2);
        OutputFileNames = [OutputFileNames;{ImgFiles}, size(AllVolume,2)]; %Thanks to the Report by Andrew Owenson
    end
end

AllVolumeSet_RH=AllVolumeSet;
OutputFileNames_RH=OutputFileNames;
nDimVertex_RH=nDimVertex;
MaskIndex_RH=MaskIndex;
Header_RH=Header;




%Now processing

AllVolume = [AllVolumeSet_LH;AllVolumeSet_RH];
clear AllVolumeSet AllVolumeSet_LH AllVolumeSet_RH;

%Calculate the standardization parameters
Mean_AllSub = mean(AllVolume)';
Std_AllSub = std(AllVolume)';
Prctile_25_75 = prctile(AllVolume,[25 50 75]);
Median_AllSub = Prctile_25_75(2,:)';
IQR_AllSub = (Prctile_25_75(3,:) - Prctile_25_75(1,:))';

fprintf('\nStandardizing...\n');
switch MethodType
    case 1 %Mean Regression
        Cov = Mean_AllSub;
        %Mean centering
        Cov = (Cov - mean(Cov))/std(Cov);
        AllVolumeMean = mean(AllVolume,2);
        AllVolume = (AllVolume-repmat(AllVolumeMean,1,size(AllVolume,2)));
        
        %AllVolume = (eye(size(Cov,1)) - Cov*inv(Cov'*Cov)*Cov')*AllVolume; %If the time series are columns
        AllVolume = AllVolume*(eye(size(Cov,1)) - Cov*inv(Cov'*Cov)*Cov')';  %If the time series are rows
        
        AllVolume = AllVolume + repmat(AllVolumeMean,1,size(AllVolume,2));
    case 2 %Mean Regression & SD Division
        Cov = Mean_AllSub;
        %Mean centering
        Cov = (Cov - mean(Cov))/std(Cov);
        AllVolumeMean = mean(AllVolume,2);
        AllVolume = (AllVolume-repmat(AllVolumeMean,1,size(AllVolume,2)));
        
        %AllVolume = (eye(size(Cov,1)) - Cov*inv(Cov'*Cov)*Cov')*AllVolume; %If the time series are columns
        AllVolume = AllVolume*(eye(size(Cov,1)) - Cov*inv(Cov'*Cov)*Cov')';  %If the time series are rows
        %AllVolume = AllVolume + repmat(AllVolumeMean,1,size(AllVolume,2));
        
        STD_2D = repmat(Std_AllSub', [size(AllVolume,1), 1]);
        AllVolume = AllVolume./STD_2D;
        
        AllVolume = AllVolume + repmat(AllVolumeMean,1,size(AllVolume,2));
    case 3 %Mean Regression & Log SD Regression
        Cov = Mean_AllSub;
        Cov = (Cov - mean(Cov))/std(Cov);
        AllVolumeMean_First = mean(AllVolume,2);
        AllVolume = (AllVolume-repmat(AllVolumeMean_First,1,size(AllVolume,2)));
        
        %AllVolume = (eye(size(Cov,1)) - Cov*inv(Cov'*Cov)*Cov')*AllVolume; %If the time series are columns
        AllVolume = AllVolume*(eye(size(Cov,1)) - Cov*inv(Cov'*Cov)*Cov')';  %If the time series are rows
        
        %Back up the sign
        AllVolumeSign = sign(AllVolume);
        
        %Log SD regression
        AllVolume = log(abs(AllVolume)); %!!!
        Cov = log(Std_AllSub);
        
        %Mean centering
        Cov = (Cov - mean(Cov))/std(Cov);
        AllVolumeMean = mean(AllVolume,2);
        AllVolume = (AllVolume-repmat(AllVolumeMean,1,size(AllVolume,2)));
        
        %AllVolume = (eye(size(Cov,1)) - Cov*inv(Cov'*Cov)*Cov')*AllVolume; %If the time series are columns
        AllVolume = AllVolume*(eye(size(Cov,1)) - Cov*inv(Cov'*Cov)*Cov')';  %If the time series are rows
        AllVolume = AllVolume + repmat(AllVolumeMean,1,size(AllVolume,2));

        AllVolume = exp(AllVolume);
        AllVolume = AllVolume.*AllVolumeSign;
        
        AllVolume = AllVolume + repmat(AllVolumeMean_First,1,size(AllVolume,2));
    case 4 %Z - Standardization
        % Zero mean and unit variance
        AllVolume = (AllVolume - repmat(Mean_AllSub',[size(AllVolume,1),1])) ./ repmat(Std_AllSub',[size(AllVolume,1),1]);
        % Remove the NaN values, those could be caused by dividing by 0 standard deviation.
        AllVolume(find(isnan(AllVolume))) = 0;
    case 5 %Mean Division
        AllVolume = AllVolume ./ repmat(Mean_AllSub',[size(AllVolume,1),1]);
        AllVolume(find(isnan(AllVolume))) = 0;
    case 6 %Mean Subtraction
        AllVolume = AllVolume - repmat(Mean_AllSub',[size(AllVolume,1),1]);
    case 7 %Median-IQR Standardization
        AllVolume = (AllVolume - repmat(Median_AllSub',[size(AllVolume,1),1])) ./ repmat(IQR_AllSub',[size(AllVolume,1),1]);
        % Remove the NaN values, those could be caused by dividing by 0 standard deviation.
        AllVolume(find(isnan(AllVolume))) = 0;
    case 8 %Rank
        [AllVolume,SortIndex] = sort(AllVolume,1);
        Ranks = zeros(nVoxels,size(AllVolume,2));
        SortedRanks = [1:nVoxels]';
        for iPoint = 1:size(AllVolume,2)
            Ranks(SortIndex(:,iPoint),iPoint)=SortedRanks;
        end
        AllVolume = Ranks;
    case 9 %Quantile Standardization
        [AllVolume,SortIndex] = sort(AllVolume,1);
        Mean_ForEachRank = mean(AllVolume,2);
        QuantileNormalized = zeros(nVoxels,size(AllVolume,2));
        SortedRanks = [1:nVoxels]';
        for iPoint = 1:size(AllVolume,2)
            QuantileNormalized(SortIndex(:,iPoint),iPoint)=Mean_ForEachRank;
        end
        AllVolume = QuantileNormalized;
        
    case 10 %Gaussian Fit
        
        for iPoint = 1:size(AllVolume,2)
            [y,x]=hist(AllVolume(:,iPoint),ceil(sqrt(nVoxels)));
            
            h=0.5; %For FWHM
            
            %% cutting
            ymax=max(y);
            xnew=x(find(y>ymax*h));
            ynew=y(find(y>ymax*h));
            
            %% fitting to the function
            % y=A * exp( -(x-mu)^2 / (2*sigma^2) )
            % (the fitting is done by a polyfit on the log of the data)
            
            ylog=log(ynew);
            xlog=xnew;
            p=polyfit(xlog,ylog,2);
            A2=p(1);
            A1=p(2);
            A0=p(3);
            sigma=sqrt(-1/(2*A2));
            mu=A1*sigma^2;
            A=exp(A0+mu^2/(2*sigma^2));

            AllVolume(:,iPoint) = ((AllVolume(:,iPoint) - mu) ./ sigma);
        end        
end


StandardizedBrain_LH = (zeros(nDimVertex_LH, size(AllVolume,2)));
StandardizedBrain_LH(MaskIndex_LH,:) = AllVolume(1:length(MaskIndex_LH),:);

StandardizedBrain_RH = (zeros(nDimVertex_RH, size(AllVolume,2)));
StandardizedBrain_RH(MaskIndex_RH,:) = AllVolume((length(MaskIndex_LH)+1):end,:);


%Write to file
fprintf('\nWriting to files...\n');
%For Left Hemisphere
iPoint = 0;
OutNameList_LH=[];
for iFile = 1:size(OutputFileNames_LH,1)
    [Path, File, Ext]=fileparts(OutputFileNames_LH{iFile,1});
    TempIndex = strfind(Path,filesep);
    [status,message,messageid] = mkdir(fullfile(OutputDir,'LH',[Path(TempIndex(end)+1:end),Suffix]));
    OutName = fullfile(OutputDir,'LH',[Path(TempIndex(end)+1:end),Suffix],[File, Ext]);
    if size(OutputFileNames_LH,2)>=2 && (~isempty(OutputFileNames_LH{iFile,2}))
        y_Write(squeeze(StandardizedBrain_LH(:,iPoint+1:iPoint+OutputFileNames_LH{iFile,2})),Header_LH,OutName);
        iPoint=iPoint+OutputFileNames_LH{iFile,2};
    else
        y_Write(squeeze(StandardizedBrain_LH(:,iPoint+1)),Header_LH,OutName);
        iPoint=iPoint+1;
    end
    OutNameList_LH=[OutNameList_LH;{OutName}];
end

%For Right Hemisphere
iPoint = 0;
OutNameList_RH=[];
for iFile = 1:size(OutputFileNames_RH,1)
    [Path, File, Ext]=fileparts(OutputFileNames_RH{iFile,1});
    TempIndex = strfind(Path,filesep);
    [status,message,messageid] = mkdir(fullfile(OutputDir,'RH',[Path(TempIndex(end)+1:end),Suffix]));
    OutName = fullfile(OutputDir,'RH',[Path(TempIndex(end)+1:end),Suffix],[File, Ext]);
    if size(OutputFileNames_RH,2)>=2 && (~isempty(OutputFileNames_RH{iFile,2}))
        y_Write(squeeze(StandardizedBrain_RH(:,iPoint+1:iPoint+OutputFileNames_RH{iFile,2})),Header_RH,OutName);
        iPoint=iPoint+OutputFileNames_RH{iFile,2};
    else
        y_Write(squeeze(StandardizedBrain_RH(:,iPoint+1)),Header_RH,OutName);
        iPoint=iPoint+1;
    end
    OutNameList_RH=[OutNameList_RH;{OutName}];
end

fprintf('\nStandardization finished.\n');
