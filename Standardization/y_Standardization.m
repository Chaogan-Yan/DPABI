function [StandardizedBrain, Header] = y_Standardization(ImgCells, MaskData, MethodType, OutputDir, Suffix)
% [StandardizedBrain, Header] = y_Standardization(ImgCells, MaskData, MethodType, OutputDir, Suffix)
% Standardize the brains for Statistical Analysis. Ref: Yan, C.G., Craddock, R.C., Zuo, X.N., Zang, Y.F., Milham, M.P., 2013. Standardizing the intrinsic brain: towards robust measurement of inter-individual variation in 1000 functional connectomes. Neuroimage 80, 246-262.
% Input:
% 	ImgCells		-	Input Data. 1 by N cells. For each cell, can be: 1. a single file; 2. N by 1 cell of filenames.
%   MaskData        -   The mask file, within which the standardization is performed.
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
% Written by YAN Chao-Gan 140815.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com

AllVolumeSet = [];
OutputFileNames = [];
fprintf('\nReading Data...\n');
for i=1:numel(ImgCells)
    ImgFiles=ImgCells{i};
    
    [AllVolume,VoxelSize,theImgFileList, Header] =y_ReadAll(ImgFiles);
    [nDim1 nDim2 nDim3 nDimTimePoints]=size(AllVolume);
    BrainSize = [nDim1 nDim2 nDim3];
    VoxelSize = sqrt(sum(Header.mat(1:3,1:3).^2));

    if ischar(MaskData)
        fprintf('\nLoad mask "%s".\n', MaskData);
        if ~isempty(MaskData)
            [MaskData,MaskVox,MaskHead]=y_ReadRPI(MaskData);
            if ~all(size(MaskData)==[nDim1 nDim2 nDim3])
                error('The size of Mask (%dx%dx%d) doesn''t match the required size (%dx%dx%d).\n',size(MaskData), [nDim1 nDim2 nDim3]);
            end
            MaskData = double(logical(MaskData));
        else
            MaskData=ones(nDim1,nDim2,nDim3);
        end
    end  

    % Convert into 2D. NOTE: here the first dimension is voxels,
    % and the second dimension is subjects. This is different from
    % the way used in y_bandpass.
    %AllVolume=reshape(AllVolume,[],nDimTimePoints)';
    AllVolume=reshape(AllVolume,[],nDimTimePoints);
    
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

AllVolume = AllVolumeSet;
clear AllVolumeSet

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

StandardizedBrain = (zeros(nDim1*nDim2*nDim3, size(AllVolume,2)));
StandardizedBrain(MaskIndex,:) = AllVolume;
StandardizedBrain=reshape(StandardizedBrain,[nDim1, nDim2, nDim3, size(AllVolume,2)]);

%Write to file
fprintf('\nWriting to files...\n');
Header.pinfo = [1;0;0];
Header.dt    =[16,0];
iPoint = 0;
for iFile = 1:size(OutputFileNames,1)
    [Path, File, Ext]=fileparts(OutputFileNames{iFile,1});
    TempIndex = strfind(Path,filesep);
    [status,message,messageid] = mkdir(fullfile(OutputDir,[Path(TempIndex(end)+1:end),Suffix]));
    OutName = fullfile(OutputDir,[Path(TempIndex(end)+1:end),Suffix],[File, Ext]);
    if size(OutputFileNames,2)>=2 && (~isempty(OutputFileNames{iFile,2}))
        y_Write(squeeze(StandardizedBrain(:,:,:,iPoint+1:iPoint+OutputFileNames{iFile,2})),Header,OutName);
        iPoint=iPoint+OutputFileNames{iFile,2};
    else
        y_Write(squeeze(StandardizedBrain(:,:,:,iPoint+1)),Header,OutName);
        iPoint=iPoint+1;
    end
    
end

fprintf('\nStandardization finished.\n');
