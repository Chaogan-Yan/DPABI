function [RawData,HarmonizedBrain, HarmonizedBrain_LH, HarmonizedBrain_RH, Header_LH, Header_RH, OutNameList_LH, OutNameList_RH] =  yw_Harmonization_Surf(ImgCells_LH, ImgCells_RH, MaskData_LH, MaskData_RH, MethodType,AdjustInfo, ParallelWorkersNum,OutputDir)
% [HarmonizedBrain_LH, HarmonizedBrain_RH, Header_LH, Header_RH, OutNameList_LH, OutNameList_RH] = yw_Harmonization_Surf(ImgCells_LH, ImgCells_RH, MaskData_LH, MaskData_RH, MethodType, OutputDir, Suffix)
% Harmonize brain surface data across multiple sites using various methods.
%
% Inputs:
%   ImgCells_LH/RH    - Cell arrays of left/right hemisphere image data
%   MaskData_LH/RH    - Mask files for left/right hemispheres  
%   MethodType        - Harmonization method ('SMA', 'ComBat/CovBat', 'ICVAE', 'Linear')
%   AdjustInfo        - Structure with method-specific parameters
%   ParallelWorkersNum- Number of parallel workers to use
%   OutputDir         - Output directory for harmonized data
%
% Outputs:
%   RawData           - Original unharmonized data
%   HarmonizedBrain   - Harmonized data for both hemispheres
%   HarmonizedBrain_LH/RH - Harmonized data for left/right hemispheres
%   Header_LH/RH      - Headers for left/right hemisphere data
%   OutNameList_LH/RH - Lists of output filenames for each hemisphere
%
%
%-----------------------------------------------------------
% Written by Wang Yu-Wei(dwong6275@gmail.com) & YAN Chao-Gan .
% Latest Modified by Wang Yu-Wei 240831.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com
% Wang, Y.W., Chen, X., Yan, C.G. (2023). Comprehensive evaluation of harmonization on functional brain imaging for multisite data-fusion. Neuroimage, 274, 120089, doi:10.1016/j.neuroimage.2023.120089.

%For Left Hemisphere
ImgCells=ImgCells_LH; MaskData=MaskData_LH;

AllVolumeSet = [];
OutputFileNames = [];
fprintf('\nReading Data...\n');
for i=1:numel(ImgCells)
    ImgFiles=ImgCells{i};
    [AllVolume,VoxelSize,theImgFileList, Header] =yw_ReadAll(ImgFiles);
    [nDimVertex nDimTimePoints]=size(AllVolume);
    if ischar(MaskData) || isempty(MaskData)
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


    MaskDataOneDim=reshape(MaskData,[],1);
    MaskIndex = find(MaskDataOneDim);
    nVertex = length(MaskIndex);
    AllVolume= AllVolume(MaskIndex,:);    
    AllVolumeSet = [AllVolumeSet,AllVolume];
    
    if iscell(ImgFiles) 
        OutputFileNames = [OutputFileNames;ImgFiles];
    else
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
    [AllVolume,VoxelSize,theImgFileList, Header] =yw_ReadAll(ImgFiles);
    [nDimVertex nDimTimePoints]=size(AllVolume);
    
    if ischar(MaskData) || isempty(MaskData)
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
    
    
    MaskDataOneDim=reshape(MaskData,[],1);
    MaskIndex = find(MaskDataOneDim);
    nVertex = length(MaskIndex);
    AllVolume= AllVolume(MaskIndex,:);

    
    AllVolumeSet = [AllVolumeSet,AllVolume];
    
    if iscell(ImgFiles)
        OutputFileNames = [OutputFileNames;ImgFiles];
    else
        OutputFileNames = [OutputFileNames;{ImgFiles}, size(AllVolume,2)]; %Thanks to the Report by Andrew Owenson
    end
end

AllVolumeSet_RH=AllVolumeSet;
OutputFileNames_RH=OutputFileNames;
nDimVertex_RH=nDimVertex;
MaskIndex_RH=MaskIndex;
Header_RH=Header;


%Now processing

AllVolume = double([AllVolumeSet_LH;AllVolumeSet_RH]);
RawData = AllVolume; % for report
clear AllVolumeSet AllVolumeSet_LH AllVolumeSet_RH;

fprintf('\nHarmonizing...\n');
HarmonizedData = zeros(size(AllVolume));

switch MethodType
    case 'SMA' % AdjustInfo = SMA.Cfg  
        fprintf('\nSMA Harmonizing...\n');
        
        TargetIndex = AdjustInfo.SiteIndex{AdjustInfo.TargetSiteIndex};
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
                if labindex < ParallelWorkersNum
                    parfor i_feature = 1:size(SourceData,1)
                        [slope,intercept] = fitMMD(SourceData(i_feature,:)',TargetData(i_feature,:)',0);
                        harmonized(i_feature,:) = SourceData(i_feature,:).*slope+intercept;
                    end
                else
                    for i_feature = 1:size(SourceData,1)
                        %parfor i_feature = 1:size(SourceData,1)
                        [slope,intercept] = fitMMD(SourceData(i_feature,:)',TargetData(i_feature,:)',0);
                        harmonized(i_feature,:) = SourceData(i_feature,:).*slope+intercept;
                    end
                end
             else 
                fprintf('\nfitting Site %s to TargetSite %s with Subsampling \n', uniqueSites{SourceSiteIndex(i_source)},uniqueSites{AdjustInfo.TargetSiteIndex});
                
                IndexSource = AdjustInfo.Subgroups(SourceIndex);
                IndexTarget = AdjustInfo.Subgroups(TargetIndex);
                if labindex < ParallelWorkersNum
                    parfor i_feature = 1:size(SourceData,1)
                        [slope,intercept] = subsamplingMMD(SourceData(i_feature,:)',TargetData(i_feature,:)',IndexSource,IndexTarget,100);
                        harmonized(i_feature,:) = SourceData(i_feature,:).*slope+intercept;
                    end
                else
                    for i_feature = 1:size(SourceData,1)
                        [slope,intercept] = subsamplingMMD(SourceData(i_feature,:)',TargetData(i_feature,:)',IndexSource,IndexTarget,100);
                        harmonized(i_feature,:) = SourceData(i_feature,:).*slope+intercept;
                    end
                end
            end     
            harmonized(all(isnan(harmonized),2))=0;
            HarmonizedData(:,SourceIndex) = harmonized;
         end
    case 'ComBat/CovBat'
        fprintf('\nComBat Harmonizing...\n');
         % combat can't deal with all-zero rows   2024.5.26    
        if any(~any(AllVolume,2)) %if exists all-zero row
            TmpVolume = zeros(size(AllVolume));
            
            nonZeroRowInd = find(any(AllVolume,2));
            if isempty(nonZeroRowInd)
                error('Data are all zero.');
            end
            
            AllVolume = AllVolume(nonZeroRowInd,:);
        end
        if ~AdjustInfo.IsCovBat
            if ~isempty(AdjustInfo.batch) 
                HarmonizedData = combat(AllVolume,AdjustInfo.batch,AdjustInfo.mod,abs(AdjustInfo.IsParametric-2));
            else
                error('No batch information in AdjusteInfo, please check!');            
            end
        else
            if ~isinteger(AdjustInfo.Percent)
                HarmonizedData = yw_covbat(AllVolume,AdjustInfo.batch,AdjustInfo.mod,abs(AdjustInfo.IsParametric-2),[],AdjustInfo.IsCovBatParametric,AdjustInfo.Percent,[]);
            elseif isnumeric(AdjustInfo.Percent)
                HarmonizedData = yw_covbat(AllVolume,AdjustInfo.batch,AdjustInfo.mod,abs(AdjustInfo.IsParametric-2),[],AdjustInfo.IsCovBatParametric,[],AdjustInfo.Percent);
            end
        end
        
        if exist('TmpVolume','var')
        	TmpVolume(nonZeroRowInd,:) = HarmonizedData;
            HarmonizedData = TmpVolume;
        end
    case 'ICVAE'
        Datetime=fix(clock);
        HDF5_fname = [OutputDir,filesep,'Harmonize_AutoSave_ICVAE_Surf_',num2str(Datetime(1)),'_',num2str(Datetime(2)),'_',num2str(Datetime(3)),'_',num2str(Datetime(4)),'_',num2str(Datetime(5)),'.h5'];
        if ParallelWorkersNum==0
            PWN =1;
        else
            PWN =ParallelWorkersNum;
        end
        hdf5write(HDF5_fname,'/RawData',AllVolume,...
                             '/OnehotEncoding/zTrain',AdjustInfo.zTrain,...
                             '/OnehotEncoding/zHarmonize',AdjustInfo.zHarmonize,...
                             '/ParallelWorkersNum',PWN,...
                             '/Output/Outputdir',OutputDir);
        cmd  = sprintf('docker run -ti --rm -v %s:/in -v %s:/ICVAE cgyan/icvae python3 train.py',HDF5_fname,OutputDir);
        system(cmd);
        fprintf('ICVAE Harmonization finished... \n');
        HarmonizedData = importdata([OutputDir,filesep,'ICVAE_Harmonized.mat'])';
    case 'Linear' 
        switch AdjustInfo.LinearMode 
            case 1 %'General'
                fprintf('Linear general model Harmonizing...\n');
                if labindex < ParallelWorkersNum
                    parfor row = 1:size(AllVolume, 1)
                        m = mod(row,1000);
                        if m==0 && row>=1000
                            fprintf('\n Finishing %.2f percentage...\n',row/size(AllVolume,1)*100);
                        end
                        y = AllVolume(row,:)';
                        x = [AdjustInfo.SiteMatrix,AdjustInfo.AdjCov];
                        lm = fitlm(x, y);
                        siteeffect = AdjustInfo.SiteMatrix * lm.Coefficients.Estimate(2:size(AdjustInfo.SiteMatrix,2)+1);
                        HarmonizedData(row,:) = y-siteeffect;
                    end
                else
                    for row = 1:size(AllVolume, 1)
                        m = mod(row,1000);
                        if m==0 && row>=1000
                            fprintf('\n Finishing %.2f percentage...\n',row/size(AllVolume,1)*100);
                        end
                        y = AllVolume(row,:)';
                        x = [AdjustInfo.SiteMatrix,AdjustInfo.AdjCov];
                        lm = fitlm(x, y);
                        siteeffect = AdjustInfo.SiteMatrix * lm.Coefficients.Estimate(2:size(AdjustInfo.SiteMatrix,2)+1);
                        HarmonizedData(row,:) = y-siteeffect;
                    end
                end
            case 2 %'Mixed'
                fprintf('Linear mixed model Harmonizing...\n');
                tbl = table;
                tbl.x1 = categorical(AdjustInfo.SiteName);
                
                formula = 'y~1';
                
                if ~isempty(AdjustInfo.AdjCov)
                    for i = 1:size(AdjustInfo.AdjCov,2)
                        eval(['tbl.x',num2str(i+1),'=AdjustInfo.AdjCov(:,i);']);
                        formula = sprintf('%s+x%s',formula, num2str(i+1));
                    end
                end
                
                formula = [formula,'+(1|x1)'];
                if labindex < ParallelWorkersNum
                    disp('The linear mixed model does not support multicore.');
                end
                for row = 1:size(AllVolume, 1)
                    m = mod(row,1000);
                    if m==0 && row>=1000
                        fprintf('\n Finishing %.2f percentage...\n',row/size(AllVolume,1)*100);
                    end
                    tbl.y = double(AllVolume(row,:)');
                    lme= fitlme(tbl,formula);
                    
                    intercept  = ones(size(AdjustInfo.SiteName,1),1);
                    designmat = [intercept,AdjustInfo.AdjCov];
                    beta = lme.Coefficients.Estimate;
                    
                    HarmonizedData(row,:) = designmat*beta + residuals(lme);
                end
        end
end
HarmonizedBrain = HarmonizedData;
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
    
    if isequal(Path,OutputDir) & size(OutputFileNames,1) ~= 1
        error('Death Warning: the files going to be created will cover your original data, please change the output directory!!!');
    end

    if isempty(SiteOrganized) && ~contains(Path,AdjustInfo.SiteName{iFile}) 
        mkdir(fullfile(OutputDir,'LH'));
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
    SiteOrganized = extractAfter(Path,['/',AdjustInfo.SiteName{iFile},'/']);
    
    if isequal(Path,OutputDir) & size(OutputFileNames,1) ~= 1
        error('Death Warning: the files going to be created will cover your original data, please change the output directory!!!');
    end

    if isempty(SiteOrganized) && ~contains(Path,AdjustInfo.SiteName{iFile})
        mkdir(fullfile(OutputDir,'RH'));
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