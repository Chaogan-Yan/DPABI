function [HarmonizedBrain_LH, HarmonizedBrain_RH, Header_LH, Header_RH, OutNameList_LH, OutNameList_RH] =  yw_Harmonization_Surf(ImgCells_LH, ImgCells_RH, MaskData_LH, MaskData_RH, MethodType,AdjustInfo ,OutputDir, Suffix)
% [HarmonizedBrain_LH, HarmonizedBrain_RH, Header_LH, Header_RH, OutNameList_LH, OutNameList_RH] = yw_Harmonization_Surf(ImgCells_LH, ImgCells_RH, MaskData_LH, MaskData_RH, MethodType, OutputDir, Suffix)
% Harmonize the brains for Statistical Analysis. Ref: Yan, C.G., Craddock, R.C., Zuo, X.N., Zang, Y.F., Milham, M.P., 2013. Standardizing the intrinsic brain: towards robust measurement of inter-individual variation in 1000 functional connectomes. Neuroimage 80, 246-262.
% Input:
% 	ImgCells_LH		-	Left Hemisphere, Input Data. 1 by N cells. For each cell, can be: 1. a single file; 2. N by 1 cell of filenames.
% 	ImgCells_RH		-	Right Hemisphere, Input Data. 1 by N cells. For each cell, can be: 1. a single file; 2. N by 1 cell of filenames.
%   MaskData_LH     -   Left Hemisphere, The mask file, within which the standardization is performed.
%   MaskData_RH     -   Right Hemisphere, The mask file, within which the standardization is performed.
%	MethodType  	-	The type of Standardization, can be:
%                       ComBat
%                       SMA
%   AdjustInfo      -   The covariates/subsampling information(Dict).can be:
%                       1.for ComBat，if is not empty，then should include
%                         keys as below：
%                           batch - site label, 1 x N vector. N stands 
%                                   for subject number.
%                           mod   - covariates, N x M, M stands for the
%                                   number of adjusted variates
%                           isparametric - 1-parametric,0-nonparametric
%                       2.for SMA， if is not empty， then use
%                           subsampling，should include {age:21,sex}.
%                           qq(underconstruction...)
% 	OutputDir		-   The output directory
%   Suffix          -   The Suffix added to the folder name
%
% Output:
%	HarmonizedBrain         -   the brains after standardization
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
            MaskData = any(AllVolume,2).*double(logical(MaskData));
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
            MaskData = any(AllVolume,2).*double(logical(MaskData));
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



fprintf('\nHarmonizing...\n');
HarmonizedData = zeros(size(AllVolume));
fprintf('\nHarmonizing...\n');
switch MethodType
    case 2 %'SMA' % AdjustInfo = SMA.Cfg  
        fprintf('\nSMA Harmonizing...\n');
        
        TargetIndex =AdjustInfo.SiteIndex{AdjustInfo.TargetSiteIndex};
        SiteNum = numel(AdjustInfo.SiteIndex);
        TargetData = AllVolume(:,TargetIndex);
        HarmonizedData(:,TargetIndex) = TargetData;
        SourceSiteIndex = setdiff(1:SiteNum,AdjustInfo.TargetSiteIndex);
        
        uniqueSites = unique(AdjustInfo.SiteName);
        for i_source = 1:length(SourceSiteIndex)
            SourceIndex = AdjustInfo.SiteIndex{SourceSiteIndex(i_source)};
            SourceData = AllVolume(:,SourceIndex);
            harmonized = zeros(size(SourceData));
            if isempty(AdjustInfo.Subgroups) %no subsampling
                fprintf('\nfitting Site %s to TargetSite %s \n', uniqueSites{SourceSiteIndex(i_source)},uniqueSites{AdjustInfo.TargetSiteIndex});                
                parfor i_feature = 1:size(SourceData,1)
                    [slope,intercept] = fitMMD(SourceData(i_feature,:)',TargetData(i_feature,:)',0);
                    harmonized(i_feature,:) = SourceData(i_feature,:).*slope+intercept;
                end                  
            else        
                fprintf('\n fitting Site %s to TargetSite %s with subsampling \n', uniqueSites{SourceSiteIndex(i_source)},uniqueSites{AdjustInfo.TargetSiteIndex});                

                IndexSource = AdjustInfo.Subgroups(SourceIndex);
                IndexTarget = AdjustInfo.Subgroups(TargetIndex);
                parfor i_feature = 1:size(SourceData,1)
                    [slope,intercept] = subsamplingMMD(SourceData(i_feature,:)',TargetData(i_feature,:)',IndexSource,IndexTarget,100);
                    harmonized(i_feature,:) = SourceData(i_feature,:).*slope+intercept;
                end
            end
             HarmonizedData(:,SourceIndex) = harmonized;
        end
    case 3  %'ComBat/CovBat'
        fprintf('\nComBat Harmonizing...\n');
        if ~AdjustInfo.IsCovBat
            if ~isempty(AdjustInfo.batch) 
                HarmonizedData = combat(AllVolume,AdjustInfo.batch,AdjustInfo.mod,abs(AdjustInfo.isparametric-2));
            else
                error('No batch information in AdjusteInfo, please check!');            
            end
        else
            if ~isinteger(AdjustInfo.PCAPercent)
                HarmonizedData = yw_covbat(AllVolume,AdjustInfo.batch,AdjustInfo.mod,abs(AdjustInfo.isparametric-2),[],AdjustInfo.IsCovBatParametric,AdjustInfo.PCAPercent,[]);
            elseif isnumeric(AdjustInfo.PCAPercent)
                HarmonizedData = yw_covbat(AllVolume,AdjustInfo.batch,AdjustInfo.mod,abs(AdjustInfo.isparametric-2),[],AdjustInfo.IsCovBatParametric,[],AdjustInfo.PCAPercent);
            end
        end
    case 4 %'ICVAE'
        Datetime=fix(clock);
        HDF5_fname = [pwd,filesep,'Harmonize_AutoSave_ICVAE_Surf_',num2str(Datetime(1)),'_',num2str(Datetime(2)),'_',num2str(Datetime(3)),'_',num2str(Datetime(4)),'_',num2str(Datetime(5)),'.h5'];

        hdf5write(HDF5_fname,'/RawData',AllVolume,...
                             '/OnehotEncoding/zTrain',AdjustInfo.zTrain,...
                             '/OnehotEncoding/zHarmonize',AdjustInfo.zHarmonize,...
                             '/Output/Outputdir',OutputDir);
        cmd  = sprintf('docker run -ti --rm -v %s:/in -v %s:/ICVAE cgyan/icvae python3 train.py',HDF5_fname,OutputDir);
        system(cmd);
        fprintf('ICVAE Harmonization finished... \n');
        HarmonizedData = importdata([OutputDir,filesep,'ICVAE_Harmonized.mat'])';
    case 5 %Linear 
        switch AdjustInfo.LinearMode 
 case 1 %'General' 
                fprintf('Linear general model Harmonizing...\n');
                for row = 1:size(AllVolume, 1)
                    m = mod(row,1000);
                    if m==0 && row>=1000
                        fprintf('\n Finishing %.2f percentage...\n',row/size(AllVolume,1)*100);
                    end
                    y = AllVolume(row,:)'; 
                    x = [AdjustInfo.SiteMatrix,AdjustInfo.Cov];
                    lm = fitlm(x, y); 
                    siteeffect = AdjustInfo.SiteMatrix * lm.Coefficients.Estimate(2:size(AdjustInfo.SiteMatrix,2)+1);
                    HarmonizedData(row,:) = y-siteeffect; 
                end 
            case 2 %'Mixed'  
                fprintf('Linear mixed model Harmonizing...\n');
                tbl = table;
                tbl.x1 = categorical(AdjustInfo.SiteName);
                
                formula = 'y~1';
                if ~isempty(AdjustInfo.Cov)
                    for i = 1:size(AdjustInfo.Cov,2)
                        eval(['tbl.x',num2str(i+1),'=AdjustInfo.Cov(:,i);']);
                        formula = sprintf('%s+x%s',formula, num2str(i+1));
                    end
                end
                formula = [formula,'+(1|x1)'];
                for row = 1:size(AllVolume, 1)
                    m = mod(row,1000);
                    if m==0 && row>=1000
                        fprintf('\n Finishing %.2f percentage...\n',row/size(AllVolume,1)*100);
                    end
                    tbl.y = double(AllVolume(row,:)');      
                    lme= fitlme(tbl,formula); 
                    
                    intercept  = ones(size(AdjustInfo.SiteName,1),1);
                    designmat = [intercept,AdjustInfo.Cov];
                    beta = lme.Coefficients.Estimate;

                    HarmonizedData(row,:) = designmat*beta + residuals(lme); 
                end 
        end
end
AllVolume =  HarmonizedData;
clear HarmonizedData;

HarmonizedBrain_LH = (zeros(nDimVertex_LH, size(AllVolume,2)));
HarmonizedBrain_LH(MaskIndex_LH,:) = AllVolume(1:length(MaskIndex_LH),:);

HarmonizedBrain_RH = (zeros(nDimVertex_RH, size(AllVolume,2)));
HarmonizedBrain_RH(MaskIndex_RH,:) = AllVolume((length(MaskIndex_LH)+1):end,:);


%Write to file
fprintf('\nWriting to files...\n');
%For Left Hemisphere
iPoint = 0;
OutNameList_LH=[];
for iFile = 1:size(OutputFileNames_LH,1)
    [Path, File, Ext]=fileparts(OutputFileNames_LH{iFile,1});
    SiteOrganized = extractAfter(Path,AdjustInfo.SiteName{iFile});
    
    if isempty(SiteOrganized) && ~contains(Path,AdjustInfo.SiteName{iFile}) 
        OutName = fullfile(OutputDir,'LH',[File, Ext]);
    else
        [status,~,~] = mkdir(fullfile(OutputDir,AdjustInfo.SiteName{iFile},SiteOrganized));
        OutName = fullfile(OutputDir,AdjustInfo.SiteName{iFile},SiteOrganized,[File, Ext]);
    end
    
    if size(OutputFileNames_LH,2)>=2 && (~isempty(OutputFileNames_LH{iFile,2}))
        y_Write(squeeze(HarmonizedBrain_LH(:,iPoint+1:iPoint+OutputFileNames_LH{iFile,2})),Header_LH,OutName);
        iPoint=iPoint+OutputFileNames_LH{iFile,2};
    else
        y_Write(squeeze(HarmonizedBrain_LH(:,iPoint+1)),Header_LH,OutName);
        iPoint=iPoint+1;
    end
    OutNameList_LH=[OutNameList_LH;{OutName}];
end

%For Right Hemisphere
iPoint = 0;
OutNameList_RH=[];
for iFile = 1:size(OutputFileNames_RH,1)
    [Path, File, Ext]=fileparts(OutputFileNames_RH{iFile,1});
    SiteOrganized = extractAfter(Path,AdjustInfo.SiteName{iFile});
    
    if isempty(SiteOrganized) && ~contains(Path,AdjustInfo.SiteName{iFile})    
        OutName = fullfile(OutputDir,'RH',[File, Ext]);
    else
        [status,~,~] = mkdir(fullfile(OutputDir,AdjustInfo.SiteName{iFile},SiteOrganized));
        OutName = fullfile(OutputDir,AdjustInfo.SiteName{iFile},SiteOrganized,[File, Ext]);
    end
    
    if size(OutputFileNames_RH,2)>=2 && (~isempty(OutputFileNames_RH{iFile,2}))
        y_Write(squeeze(HarmonizedBrain_RH(:,iPoint+1:iPoint+OutputFileNames_RH{iFile,2})),Header_RH,OutName);
        iPoint=iPoint+OutputFileNames_RH{iFile,2};
    else
        y_Write(squeeze(HarmonizedBrain_RH(:,iPoint+1)),Header_RH,OutName);
        iPoint=iPoint+1;
    end
    OutNameList_RH=[OutNameList_RH;{OutName}];
end

fprintf('\nHarmonization finished.\n');