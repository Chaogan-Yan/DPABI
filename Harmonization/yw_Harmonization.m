function [HarmonizedBrain, Header, OutNameList] = yw_Harmonization(ImgCells, MaskData, MethodType, AdjustInfo, OutputDir)
% [HarmonizedBrain, Header, OutNameList] = yw_Harmonization(ImgCells, MaskData, MethodType, OutputDir, Suffix)
% Standardize the brains for Statistical Analysis. Ref: Yan, C.G., Craddock, R.C., Zuo, X.N., Zang, Y.F., Milham, M.P., 2013. Standardizing the intrinsic brain: towards robust measurement of inter-individual variation in 1000 functional connectomes. Neuroimage 80, 246-262.
% Input:
% 	ImgCells		-	Input Data. 1 by N cells. For each cell, can be: 1. a single file; 2. N by 1 cell of filenames.
%   MaskData        -   The mask file, within which the standardization is performed.
%	MethodType  	-	The type of Standardization, can be:
%                       SMA
%                       ComBat
%                       ICVAE
%                       Linear
%   AdjustInfo      -   The covariates/subsampling information(Dict).can be:
%                       1.for SMA, if is not empty, then should include
%                         keys as below，
%                         - Demographic info - support .xlsx, .tsv, .csv, .txt, .mat.
%                                            there at least contain a column named
%                                            "SiteName" to distinguish sites.
%                         - Fit Type       - 1. No subsampling.
%                                          - 2. Subsampling. Preferred where other
%                                          factors causually influence the data.
%                         - Z Cuts           when choose causual Z variables，use
%                                          0 as cut label for categorical
%                                          variables， and concrete number
%                                          for continuous variables.
%                         - Subgroup         After add all cuts， use the
%                                          button to subgroup. It will provide a
%                                          target site base on selection
%                                          fomula in our paper.
%                         - Target site      Choose a target site from the
%                                          list, which presents the unique
%                                          site names of "SiteName".
%
%                       2.for ComBat/CovBat, if is not empty, then should include
%                         keys as below,
%                         -ComBat 
%                               Demographic info - support .xlsx, .tsv, .csv, .txt, .mat.
%                                                  there at least contain a column named 
%                                                  "SiteName" to distinguish sites.
%                               Adjusted variables - AllVariables listbox will showcase
%                                                    all varibles in Demographic info file，
%                                                    except for "SiteName". Users can add those
%                                                    variables need to be adjusted in the linear 
%                                                    part of combat method into AdjustedVariables
%                                                    listbox.                
%                               isparametric       - 1 - parametric,2 - nonparametric
%                               IsCovBat           - 1 - do covariance harmonization
%                                                    0 - no CovBat
%                         -CovBat
%                               IsCovBatParametric - 1 - parametric 
%                                                    2 - nonparametric
%                                                      
%                               PCAPercent         - Default    - 95%
%                                                  - Percentage - user
%                                                       defined, [0,1]
%                                                  - PC number  - user
%                                                       defined, >=1
%                       3. ICVAE 
%                          - Pull Docker File  - Automcatically pull
%                                                docker image from ducker hub.
%                          - Demographic info - support .xlsx, .tsv, .csv, .txt, .mat.
%                                               there at least contain a column named
%                                               "SiteName" to distinguish sites.
%                          - Target site
%  
%                       4. Linear 
%                          - Demographic info - support .xlsx, .tsv, .csv, .txt, .mat.
%                                               there at least contain a column named
%                                               "SiteName" to distinguish sites.
%                          - Model              - General linear model
%                                               - Linear mixed model
%                          - Adjusted variables - AllVariables listbox will showcase
%                                                 all varibles in Demographic info file，
%                                                 except for "SiteName". Users can add those
%                                                 variables need to be adjusted into 
%                                                 AdjustedVariables listbox.
% 	OutputDir		-   The output directory
%
% Output:
%   1. If you input .img/.nii/.gii/.mat files equalling to your subjects，
%         then each subject will get a harmonized .img/.nii/.gii/.mat in the output path.	
%      If you input .xlsx/.mat encompassing organized data and file number
%         less than subjects，then harmonized will be separated and outputed
%         in the same file type and data size. Of note, name them
%         differently, otherwise the latter produced would overwrite the
%         former one.
%   2. If you use "AddSite" function to input the files，you will get the 
%         the same documentation way for outputs, e.g., outputpath/site/intermediate/xxx.nii.
%
%-----------------------------------------------------------
% Written in 2022. Latest Modified by Wang Yu-Wei 231016. 
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% wangyw@psych.ac.cn
% Wang, Y.W., Chen, X., Yan, C.G. (2023). Comprehensive evaluation of harmonization on functional brain imaging for multisite data-fusion. Neuroimage, 274, 120089, doi:10.1016/j.neuroimage.2023.120089.

AllVolumeSet = [];
OutputFileNames = [];
fprintf('\nReading Data...\n');

for i=1:numel(ImgCells)
    ImgFiles=ImgCells{i};
    % if want to reorder the file list by sublist of demographic
    % information, then try to strcmpi(filename,subjuct) and then
    % rearrange
    if numel(ImgCells) == numel(AdjustInfo.SiteName)
        % ------------------------ R e a d D a t a --------------------------
        [AllVolume,VoxelSize,theImgFileList, Header] =y_ReadAll(ImgFiles);
        
        if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames') %YAN Chao-Gan 181204. If NIfTI data
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
            
            
        else
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
        end
        MaskData = any(AllVolume,2) .* MaskData; % skip the voxels with all zeros
        
        AllVolume=reshape(AllVolume,[],nDimTimePoints);
        
        % ------------------- M a s k O u t D a t a ( 2 D ）-------------------
        MaskDataOneDim = reshape(MaskData,[],1);
        MaskIndex = find(MaskDataOneDim);
        nVoxels = length(MaskIndex);
        %AllVolume=AllVolume(:,MaskIndex);
        AllVolume=AllVolume(MaskIndex,:);
        
        AllVolumeSet = [AllVolumeSet,AllVolume];
        
    elseif numel(ImgCells) < numel(AdjustInfo.SiteName) % modified 10/15/2023  for those already organized as a 2-D matrix: subject x feature
        % for now，only support .xlsx and .mat
        organized_data = yw_ReadOrganizedData(ImgFiles);
        AllVolumeSet =[AllVolumeSet,organized_data'];
    end
    % ------------------- O u t p u t F i l e s ----------------------
    if iscell(ImgFiles)
        OutputFileNames = [OutputFileNames;ImgFiles];
    elseif numel(ImgCells) < numel(AdjustInfo.SiteName)
        OutputFileNames = [OutputFileNames;{ImgFiles},size(organized_data,1)]; % the number of subjects && rows of organized data
    else
        %OutputFileNames = [OutputFileNames;{ImgFiles}];
        %OutputFileNames{end,2} = size(AllVolume,2);
        OutputFileNames = [OutputFileNames;{ImgFiles}, size(AllVolume,2)]; %Thanks to the Report by Andrew Owenson
    end
end
    
    

AllVolume = AllVolumeSet;
clear AllVolumeSet
% -----------------------H A M O N I Z A T I O N --------------------------
HarmonizedData = zeros(size(AllVolume));
fprintf('\nHarmonizing...\n\n');
switch MethodType
    case 2 %'SMA' 
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
                fprintf('\nfitting Site %s to TargetSite %s with Subsampling \n', uniqueSites{SourceSiteIndex(i_source)},uniqueSites{AdjustInfo.TargetSiteIndex});
                IndexSource = AdjustInfo.Subgroups(SourceIndex);
                IndexTarget = AdjustInfo.Subgroups(TargetIndex);
                parfor i_feature = 1:size(SourceData,1)
                    [slope,intercept] = subsamplingMMD(SourceData(i_feature,:)',TargetData(i_feature,:)',IndexSource,IndexTarget,100);
                    harmonized(i_feature,:) = SourceData(i_feature,:).*slope+intercept;
                end
            end
             HarmonizedData(:,SourceIndex) = harmonized;
        end
    case 3 %combat/covbat
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
    case 4 %ICVAE
        Datetime=fix(clock);
        HDF5_fname = [pwd,filesep,'Harmonize_AutoSave_ICVAE_',num2str(Datetime(1)),'_',num2str(Datetime(2)),'_',num2str(Datetime(3)),'_',num2str(Datetime(4)),'_',num2str(Datetime(5)),'.h5'];

        hdf5write(HDF5_fname,'/RawData',AllVolume,...
                             '/OnehotEncoding/zTrain',AdjustInfo.zTrain,...
                             '/OnehotEncoding/zHarmonize',AdjustInfo.zHarmonize,...
                             '/Output/Outputdir',OutputDir);
        cmd  = sprintf('docker run -ti --rm -v %s:/in -v %s:/ICVAE cgyan/icvae python3 train.py --ICVAE_Train_hdf5 /in',HDF5_fname,OutputDir);
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
                    tbl.y = AllVolume(row,:)';      
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
% ----------------------------- W r i t e D a t a -------------------------

if numel(ImgCells)==numel(AdjustInfo.SiteName)
    if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames')  %YAN Chao-Gan 181204. If NIfTI data
        HarmonizedBrain = (zeros(nDim1*nDim2*nDim3, size(AllVolume,2)));
        HarmonizedBrain(MaskIndex,:) = AllVolume;
        HarmonizedBrain=reshape(HarmonizedBrain,[nDim1, nDim2, nDim3, size(AllVolume,2)]);
        Header.pinfo = [1;0;0];
        Header.dt    =[16,0];
    else
        HarmonizedBrain = (zeros(nDimVertex, size(AllVolume,2)));
        HarmonizedBrain(MaskIndex,:) = AllVolume;
    end
elseif numel(ImgCells) < numel(AdjustInfo.SiteName)
    HarmonizedBrain = AllVolume;
end

%Write to file
fprintf('\nWriting to files...\n');
iPoint = 0;
OutNameList=[];

for iFile = 1:size(OutputFileNames,1) 
    [Path, File, Ext]=fileparts(OutputFileNames{iFile,1}); % for numel(ImgCells) < numel(AdjustInfo.SiteName), File should be different
    SiteOrganized = extractAfter(Path,AdjustInfo.SiteName{iFile});
    
    if isempty(SiteOrganized) && ~contains(Path,AdjustInfo.SiteName{iFile})
        OutName = fullfile(OutputDir,[File, Ext]);
    else
        [status,~,~] = mkdir(fullfile(OutputDir,AdjustInfo.SiteName{iFile},SiteOrganized));
        OutName = fullfile(OutputDir,AdjustInfo.SiteName{iFile},SiteOrganized,[File, Ext]);
    end
    if numel(ImgCells)==numel(AdjustInfo.SiteName)
        if size(OutputFileNames,2)>=2 && (~isempty(OutputFileNames{iFile,2}))
            if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames')  %YAN Chao-Gan 181204. If NIfTI data
                y_Write(squeeze(HarmonizedBrain(:,:,:,iPoint+1:iPoint+OutputFileNames{iFile,2})),Header,OutName);
            else
                y_Write(squeeze(HarmonizedBrain(:,iPoint+1:iPoint+OutputFileNames{iFile,2})),Header,OutName);
            end
            iPoint=iPoint+OutputFileNames{iFile,2};
        else
            if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames') %YAN Chao-Gan 181204. If NIfTI data
                y_Write(squeeze(HarmonizedBrain(:,:,:,iPoint+1)),Header,OutName);
            else
                y_Write(squeeze(HarmonizedBrain(:,iPoint+1)),Header,OutName);
            end
            iPoint=iPoint+1;
        end
    elseif numel(ImgCells) < numel(AdjustInfo.SiteName)
        Harmonized = HarmonizedBrain(:,double((iFile-1)>0*sum(OutputFileNames{1:(iFile-1)^((iFile-1)>0),2}))+1:sum(OutputFileNames{1:iFile,2}))';
        if strcmpi(Ext,'.mat')  
            save(OutName,'Harmonized');
        elseif strcmpi(Ext,'.xlsx')
            xlswrite(OutName,'Harmonized'); 
        end            
    end
    OutNameList=[OutNameList;{OutName}];
end

fprintf('\nHarmonization finished.\n');
