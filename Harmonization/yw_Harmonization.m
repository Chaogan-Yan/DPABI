function [RawData, AllVolume] = yw_Harmonization(ImgCells, MaskData, MethodType, AdjustInfo, ParallelWorkersNum,OutputDir)
% [HarmonizedBrain, Header, OutNameList] = yw_Harmonization(ImgCells, MaskData, MethodType, OutputDir, Suffix)
% Harmonizes brain imaging data across multiple sites using various methods.
%
% Inputs:
%   ImgCells            - Cell array of input data files or matrices
%   MaskData            - Mask file for data processing
%   MethodType          - Harmonization method ('SMA', 'ComBat/CovBat', 'ICVAE', 'Linear')
%   AdjustInfo          - Structure with method-specific parameters
%   ParallelWorkersNum  - Number of parallel workers to use
%   OutputDir           - Output directory for harmonized data
%
% Outputs:
%   RawData             - Original unharmonized data
%   AllVolume           - Harmonized data
%
% Key Steps:
%   1. Reads and preprocesses input data
%   2. Applies specified harmonization method
%   3. Writes harmonized data to output files
%
% Supported File Types:
%   - Neuroimaging: .nii, .gii, .mat
%   - Tabular data: .xlsx, .csv, .tsv, .txt
%
% Notes:
%   - Handles both 3D brain images and 2D matrices
%   - Supports various harmonization methods with different parameter requirements
%   - Parallel processing option for improved performance
%
%-----------------------------------------------------------
% Written in 2022. Latest Modified by Wang Yu-Wei 240831.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com
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
        [AllVolume,VoxelSize,theImgFileList, Header] =yw_ReadAll(ImgFiles); % extend to xlsx,csv,tsv,txt files
        
        if isfield(Header,'cdata')
            [nDimVertex nDimTimePoints]=size(AllVolume);
            if ischar(MaskData) || isempty(MaskData)
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
        elseif isfield(Header,'MatrixSize')
            [nDimEdges nDimTimePoints]=size(AllVolume);
            NetworkShape = Header.MatrixSize{1};
            if NetworkShape(1)~= NetworkShape(2)
                error('Input is not a square matrix.');
            end
            if ischar(MaskData) || isempty(MaskData)
                fprintf('\nLoad mask "%s".\n', MaskData);
                if ~isempty(MaskData)
                    fprintf('\nLoad mask "%s".\n', MaskData);
                    [MaskData,Header]=y_ReadMat(MaskData);
                    MaskData = double(logical(MaskData));
                else
                    % create upper triangle mask
                    MaskData=zeros(NetworkShape);
                    triu_index = triu(true(size(MaskData)),1);
                    MaskData(triu_index)=1;
                end
            end
        elseif isfield(Header,'mat') %.nii %Wang Yu-Wei 240603.
            [nDim1 nDim2 nDim3 nDimTimePoints]=size(AllVolume);
            BrainSize = [nDim1 nDim2 nDim3];
            VoxelSize = sqrt(sum(Header.mat(1:3,1:3).^2));
            
            if ischar(MaskData) || isempty(MaskData)
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
            
        else
            [nDim1 nDimTimePoints]=size(AllVolume);
            if ischar(MaskData) || isempty(MaskData)
                fprintf('\nLoad mask "%s".\n', MaskData);
                if ~isempty(MaskData)
                    fprintf('\nLoad mask "%s".\n', MaskData);
                    [MaskData,Header]=yw_ReadAll(MaskData);
                    MaskData = double(logical(MaskData));
                else
                    MaskData=ones(nDim1,nDimTimePoints);
                end
            end
        end
        AllVolume=reshape(AllVolume,[],nDimTimePoints);
        % ------------------- M a s k O u t D a t a （ 2 D ）-------------------
        MaskDataOneDim = reshape(MaskData,[],1);
        MaskIndex = find(MaskDataOneDim);
        %nVoxels = length(MaskIndex);
        AllVolume = AllVolume(MaskIndex,:);
        AllVolumeSet = [AllVolumeSet,AllVolume];
        
    elseif numel(ImgCells) == 1
        % modified 10/15/2023  for those already organized as a 2-D matrix: subject x feature
        % for now, only support .xlsx, .mat and .csv
        organized_data = yw_ReadOrganizedData(ImgFiles);
        AllVolumeSet = organized_data';
    end
    
    % ------------------- O u t p u t F i l e s ----------------------
    if iscell(ImgFiles)
        OutputFileNames = [OutputFileNames;ImgFiles];
    elseif numel(ImgCells)==1  % single file
        OutputFileNames = [OutputFileNames;{ImgFiles},size(organized_data,1)]; % the number of subjects && rows of organized data
    else
        %OutputFileNames = [OutputFileNames;{ImgFiles}];
        %OutputFileNames{end,2} = size(AllVolume,2);
        OutputFileNames = [OutputFileNames;{ImgFiles}, size(AllVolume,2)]; %Thanks to the Report by Andrew Owenson
    end
end
RawData = AllVolumeSet;
AllVolume = AllVolumeSet;
clear AllVolumeSet



% -----------------------H A M O N I Z A T I O N --------------------------

HarmonizedData = zeros(size(AllVolume));
fprintf('\nHarmonizing...\n\n');
switch MethodType
    case 'SMA'
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
                if labindex < ParallelWorkersNum
                    parfor i_feature = labindex:numlabs:size(SourceData,1)
                        [slope,intercept] = fitMMD(SourceData(i_feature,:)',TargetData(i_feature,:)',0);
                        harmonized(i_feature,:) = SourceData(i_feature,:).*slope+intercept;
                    end
                else
                    for i_feature = 1:size(SourceData,1)
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
    case 'ComBat/CovBat' %combat/covbat
        fprintf('\nComBat Harmonizing...\n');
        % combat can't deal with all-zero rows
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
                HarmonizedData = combat(AllVolume,AdjustInfo.batch,AdjustInfo.mod,abs(AdjustInfo.IsParametric-2)); % if error happened here, it means same value exist in the same voxel/edge/others, considering use a mask
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
        HDF5_fname = [OutputDir,filesep,'Harmonize_AutoSave_ICVAE_',num2str(Datetime(1)),'_',num2str(Datetime(2)),'_',num2str(Datetime(3)),'_',num2str(Datetime(4)),'_',num2str(Datetime(5)),'.h5'];
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
        cmd  = sprintf('docker run -ti --rm -v %s:/in -v %s:/ICVAE cgyan/icvae python3 train.py --ICVAE_Train_hdf5 /in',HDF5_fname,OutputDir);
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
            case 2
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
                for row = 1:size(AllVolume, 1)
                    m = mod(row,1000);
                    if m==0 && row>=1000
                        fprintf('\n Finishing %.2f percentage...\n',row/size(AllVolume,1)*100);
                    end
                    tbl.y = AllVolume(row,:)';
                    lme= fitlme(tbl,formula);
                    
                    intercept  = ones(size(AdjustInfo.SiteName,1),1);
                    designmat = [intercept,AdjustInfo.AdjCov];
                    beta = lme.Coefficients.Estimate;
                    
                    HarmonizedData(row,:) = designmat*beta + residuals(lme);
                end
        end
end
AllVolume =  HarmonizedData;
clear HarmonizedData;
delete(gcp('nocreate'));
% ----------------------------- W r i t e D a t a -------------------------

if numel(ImgCells)==numel(AdjustInfo.SiteName)
    if isfield(Header,'cdata')
        HarmonizedBrain = (zeros(nDimVertex, size(AllVolume,2)));
        HarmonizedBrain(MaskIndex,:) = AllVolume;
    elseif isfield(Header,'MatrixNames')
        HarmonizedBrain = (zeros(nDimEdges, size(AllVolume,2)));
        HarmonizedBrain(MaskIndex,:) = AllVolume;
    elseif isfield(Header,'mat')
        HarmonizedBrain = (zeros(nDim1*nDim2*nDim3, size(AllVolume,2)));
        HarmonizedBrain(MaskIndex,:) = AllVolume;
        HarmonizedBrain=reshape(HarmonizedBrain,[nDim1, nDim2, nDim3, size(AllVolume,2)]);
        Header.pinfo = [1;0;0];
        Header.dt    =[16,0];
    else
        HarmonizedBrain = (zeros(nDim1, size(AllVolume,2)));
        HarmonizedBrain(MaskIndex,:) = AllVolume;
        HarmonizedBrain = reshape(HarmonizedBrain,[Header.tablesize,size(AllVolume,2)]);
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
    SiteOrganized = extractAfter(Path,['/',AdjustInfo.SiteName{iFile},'/']);
    
    if isequal(Path,OutputDir) & size(OutputFileNames,1) ~= 1
        error('Death Warning(╬ ಠ益ಠ): the files going to be created will cover your original data, please change the output directory!!!');
    end
    
    if size(OutputFileNames,1) ~= 1
        if isempty(SiteOrganized) && ~contains(Path,AdjustInfo.SiteName{iFile})
            OutName = fullfile(OutputDir,[File, Ext]);
        else
            [status,~,~] = mkdir(fullfile(OutputDir,AdjustInfo.SiteName{iFile},SiteOrganized));
            OutName = fullfile(OutputDir,AdjustInfo.SiteName{iFile},SiteOrganized,[File, Ext]);
        end
    else
        OutName = fullfile(OutputDir,['Harmonized_',File, Ext]);
    end
    
    if numel(ImgCells)==numel(AdjustInfo.SiteName)
        if size(OutputFileNames,2)>=2 && (~isempty(OutputFileNames{iFile,2})) %
            if isfield(Header,'mat')
                y_Write(squeeze(HarmonizedBrain(:,:,:,iPoint+1:iPoint+OutputFileNames{iFile,2})),Header,OutName);
            elseif isfield(Header,'cdata') || isfield(Header,'MatrixNames')
                y_Write(squeeze(HarmonizedBrain(:,iPoint+1:iPoint+OutputFileNames{iFile,2})),Header,OutName);
            elseif isfield(Header,'tablesize')
                if Header.tablesize(2) == 1
                    T = array2table(HarmonizedBrain(:,iPoint+1:iPoint+OutputFileNames{iFile,2}),'VariableNames',Header.name);
                else
                    T = array2table(HarmonizedBrain(:,:,iPoint+1:iPoint+OutputFileNames{iFile,2}),'VariableNames',Header.name);
                end
                writetable(T,OutName);
            end
            iPoint=iPoint+OutputFileNames{iFile,2};
        else
            if isfield(Header,'mat')
                y_Write(squeeze(HarmonizedBrain(:,:,:,iPoint+1)),Header,OutName);
            elseif isfield(Header,'cdata') || isfield(Header,'MatrixNames')
                y_Write(squeeze(HarmonizedBrain(:,iPoint+1)),Header,OutName);
            elseif isfield(Header,'tablesize')
                if Header.tablesize(2) == 1
                    T = array2table(HarmonizedBrain(:,iPoint+1),'VariableNames',Header.name);
                else
                    T = array2table(HarmonizedBrain(:,:,iPoint+1),'VariableNames',Header.name);
                end
                writetable(T,OutName);
            end
            
            iPoint=iPoint+1;
        end
    elseif numel(ImgCells) < numel(AdjustInfo.SiteName)
        Harmonized = HarmonizedBrain(:,double((iFile-1)>0*sum(OutputFileNames{1:(iFile-1)^((iFile-1)>0),2}))+1:sum(OutputFileNames{1:iFile,2}))';
        if strcmpi(Ext, '.mat')
            save(OutName, 'Harmonized');
        elseif strcmpi(Ext, '.xlsx')
            writematrix(Harmonized, OutName);
        elseif strcmpi(Ext, '.csv')
            writematrix(Harmonized, OutName, 'Delimiter', ',');
        else
            error('Unsupported file format: %s', Ext);
        end
    end
    OutNameList = [OutNameList;{OutName}];
end

fprintf('\nHarmonization finished.\n');
