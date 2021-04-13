function [filePathBand,filePathLabel,filePathLink] = CircosDataOrganize(workingDir,RawDataCircos,LINK_MODE)
% FORMAT [filePathBand,filePathLabel,filePathLink] = CircosDataOrganize(workingDir,RawDataCircos,LINK_MODE)
% Data organization for Circos plot via the format of txt
% ATTENTION: this program temporary support up to 24 regions
%
% Input:
%   workingDir - working directory that generate scripts and Circos figure
%   RawDataCircos - raw data according to format that manual defined
%     (MUST HAVE):
%       .HigherOrderNetworkIndex - identify networks of corresponding regions
%       .ProcMatrix - processed matrix of magnitude of regions correlation
%       .CmapLimit - consist of colormap limit 
%     (NOT MUST HAVE):
%       .ElementLabel - Identify regions' order and label
%       .HigherOrderNetworkLabel - Identify networks' order and label
%       .ColorMap - consist of customized color map in RGB
%   LINK_MODE - select link mode: 
%     1-even region and link width, 
%     2-even region width, ratio link width, 
%     3-even region width, ratio link width,
%     4-even region wodth, absolute link width
% Output:
%   filePathBand - 1st txt file contains band information
%   filePathLabel - 2nd txt file contains label information
%   filePathLink - 3rd txt file contains link information
%__________________________________________________________________________
% Written by DENG Zhao-Yu 210408 for DPARBI.
% Institute of Psychology, Chinese Academy of Sciences
% dengzy@psych.ac.cn
%__________________________________________________________________________
%%

% change working directory
cd(workingDir);

% define variables
% P_THRESHOLD = 0.005; % default threshold for P value
COLORBAR_ROUNDN_SENS = -2;
LINK_TRANSPARENCY = 0.3; % transparency of links in plot!!PNG vs SVG complementary
MAX_WIDTH = 1; MIN_WIDTH = 0.2; % normalize width parameter
DEFAULT_SPACING = 100;

% define the amount of networks and regions
nRegion = length(RawDataCircos.ProcMatrix(:,1)); % number of regions
if (~isfield(RawDataCircos,'HigherOrderNetworkIndex') || isempty(RawDataCircos.HigherOrderNetworkIndex))
    RawDataCircos.HigherOrderNetworkIndex = ones(nRegion,1);
end
nNetwork = max(RawDataCircos.HigherOrderNetworkIndex); % number of networks

% networks and regions
tabTemp = tabulate(RawDataCircos.HigherOrderNetworkIndex);
nNetworkRegion = tabTemp(:,2);

% if no label information, set them default
if (~isfield(RawDataCircos,'HigherOrderNetworkLabel') || isempty(RawDataCircos.HigherOrderNetworkLabel))
    nameNetwork = cell(nNetwork,1);
    for k = 1:nNetwork
        nameNetwork(k) = cellstr(strcat('n',num2str(k)));
    end
else
    nameNetwork = RawDataCircos.HigherOrderNetworkLabel(:,2);
end

if (~isfield(RawDataCircos,'ElementLabel') || isempty(RawDataCircos.ElementLabel))
    nameRegion = cell(nRegion,1);
    for k = 1:nRegion
        nameRegion(k) = cellstr(strcat('r',num2str(k)));
    end
else
    nameRegion = RawDataCircos.ElementLabel(:,2);
end

% sort HigherOrderNetworkLabel & CircosStruct.HigherOrderNetworkLabel & CircosStruct.ElementLabel



% generate correlation matrix for links, filter threshold
% matCorr = RawDataCircos.P_Corrected < P_THRESHOLD; 
[rowCorr,colCorr] = find(triu(RawDataCircos.ProcMatrix~=0)); % withdraw upper triangle matrix
nCorr = length(rowCorr); % number of correlation pairs
arrPlot = zeros(length(rowCorr),1); % initialize array that store values that plots
for k = 1:length(rowCorr)
    arrPlot(k) = RawDataCircos.ProcMatrix(rowCorr(k),colCorr(k)); % store values in matrix
end
maxabsArrPlot = max(abs(min(arrPlot)),abs(max(arrPlot)));
arrCorRatio = roundn((arrPlot/maxabsArrPlot),COLORBAR_ROUNDN_SENS); % correlation normalization, sensitivity
% normalize to appropriate range
maxArrPlot = max(abs(arrPlot(:))); minArrPlot = min(abs(arrPlot(:)));
normArrPlot = roundn(MIN_WIDTH+(MAX_WIDTH-MIN_WIDTH)*(abs(arrPlot)-minArrPlot)/(maxArrPlot-minArrPlot),COLORBAR_ROUNDN_SENS);

% calculate correlation for plot
logiMatIndexLink = false(nCorr,nCorr);
arrLink = zeros(nRegion,1); 
matLinkWidthRatio = zeros(nRegion,nRegion); % initialize ratio of regions' link width
for k = 1:nRegion
    logiMatIndexLink(:,k) = rowCorr==k|colCorr==k;
    arrLink(k) = sum(logiMatIndexLink(:,k)); % regions' links amount
    matLinkWidthRatio(k,1:arrLink(k)) = normArrPlot(logiMatIndexLink(:,k))';
end
arrRegionWidthRatio = sum(matLinkWidthRatio,2); % calculate width of regions

% load colormap file
if isfield(RawDataCircos,'ColorMap')
    cmap = RawDataCircos.ColorMap;
else
    load('cmap.mat','cmap');
end
nCmap = length(cmap);
% set 4 matrix limit
if isfield(RawDataCircos,'CmapLimit')
    leftMinLimit = RawDataCircos.CmapLimit(1,1);
    leftMaxLimit = RawDataCircos.CmapLimit(1,2);
    rightMinLimit = RawDataCircos.CmapLimit(2,1);
    rightMaxLimit = RawDataCircos.CmapLimit(2,2);
else
    leftMinLimit = min(arrPlot(arrPlot<0));
    leftMaxLimit = max(arrPlot(arrPlot<0));
    rightMinLimit = min(arrPlot(arrPlot>0));
    rightMaxLimit = max(arrPlot(arrPlot>0));
end
% select the color of links in colormap
matColor = zeros(nCorr,3); % initialize matrix that store color of links
cmapArrCorr = zeros(nCorr,1);
norArrCorRatio = zeros(nCorr,1);
for k = 1:nCorr
    if arrCorRatio(k) < 0
        norArrCorRatio(k) = (arrPlot(k)-leftMaxLimit)/(leftMaxLimit-leftMinLimit);
        cmapArrCorr(k) = fix(norArrCorRatio(k)*(nCmap/2))+(nCmap/2)+1;
    elseif arrCorRatio(k) > 0
        norArrCorRatio(k) = (arrPlot(k)-rightMinLimit)/(rightMaxLimit-rightMinLimit);
        cmapArrCorr(k) = fix(norArrCorRatio(k)*(nCmap/2))+(nCmap/2);
    end
    matColor(k,:) = fix(cmap(cmapArrCorr(k),:)*255);
end

% define width of a region band
if LINK_MODE == 1 % even region and link width
    spacing = nRegion;
elseif LINK_MODE == 2 % even region width, ratio link width
    spacing = DEFAULT_SPACING;
elseif LINK_MODE == 3 % region width is sum of whose links, absolute link width
    spacing = []; 
elseif LINK_MODE == 4 % even region wodth, absolute link width
    spacing = [];
end


% write data of networks and regions
filePathBand = strcat(workingDir,filesep,'CircosInput1_band.txt');
fid = fopen(filePathBand,'w');
% describe external networks, FORMAT: chr - ID label start end attribute
if LINK_MODE==1 || LINK_MODE==2
    % isometry band
    for k = 1:nNetwork
        fprintf(fid,'chr - %s %s ',['net',num2str(k)],cell2mat(nameNetwork(k)));
        fprintf(fid,'%u %u %s',0,nNetworkRegion(k)*spacing,['chr',num2str(k)]); %color may not needed
        fprintf(fid,'\n');
    end
elseif LINK_MODE==3
    % not isometry band
    matLinkWidthRatio100 = floor(matLinkWidthRatio*100);
    bandWidth = sum(matLinkWidthRatio100,2);
    bandWidth(bandWidth==0) = floor(min(bandWidth(bandWidth~=0)));
    network_width = zeros(3,1);
    for k = 1:nNetwork
        network_width(k) = sum(bandWidth(RawDataCircos.HigherOrderNetworkIndex==k));
    end
    for k = 1:nNetwork
        fprintf(fid,'chr - %s %s ',['net',num2str(k)],cell2mat(nameNetwork(k)));
        fprintf(fid,'%u %u %s',0,network_width(k),['chr',num2str(k)]);
        fprintf(fid,'\n');
    end
elseif LINK_MODE==4
    % isometry band, width = max link width ratio
    matLinkWidthRatio100 = floor(matLinkWidthRatio*100);
    isoBandWidth = max(sum(matLinkWidthRatio100,2)); % initialize isometry band width
    for k = 1:nNetwork
        fprintf(fid,'chr - %s %s ',['net',num2str(k)],cell2mat(nameNetwork(k)));
        fprintf(fid,'%u %u %s',0,nNetworkRegion(k)*isoBandWidth,['chr',num2str(k)]);
        fprintf(fid,'\n');
    end
end

% describe internal bands, FORMAT: band ID label label start end attribute
if LINK_MODE==1 || LINK_MODE==2 || LINK_MODE==4
    if LINK_MODE==4
        spacing = isoBandWidth;
    end
    index = 1;
    for k = 1:nNetwork
        for l = 1:nNetworkRegion(k)
            fprintf(fid,'band %s %s %s ',['net',num2str(k)],cell2mat(nameRegion(index)),cell2mat(nameRegion(index)));
            fprintf(fid,'%u %u %s',(l-1)*spacing,l*spacing,['chr',num2str(index)]);
            fprintf(fid,'\n');
            index = index + 1;
        end
    end
elseif LINK_MODE==3
    index = 1;
    for k = 1:nNetwork
        tempFormerSum = 0; % temporary record the sum of former band width
        for l = 1:nNetworkRegion(k)
            fprintf(fid,'band %s %s %s ',['net',num2str(k)],cell2mat(nameRegion(index)),cell2mat(nameRegion(index)));
            fprintf(fid,'%u %u %s',tempFormerSum,tempFormerSum+bandWidth(index),['chr',num2str(index)]);
            fprintf(fid,'\n');
            tempFormerSum = tempFormerSum + bandWidth(index);
            index = index + 1;
        end
    end
end
fclose(fid);

% write data of band labels
filePathLabel = strcat(workingDir,filesep,'CircosInput2_label.txt');
fid = fopen(filePathLabel,'w');
% label karyotype band, FORMAT: ID start end label
if LINK_MODE==1 || LINK_MODE==2 || LINK_MODE==4
    if LINK_MODE==4
        spacing = isoBandWidth;
    end
    index = 1;
    for k = 1:nNetwork
        for l = 1:nNetworkRegion(k)
            fprintf(fid,'%s %u %u %s',['net',num2str(k)],(l-1)*spacing,l*spacing,cell2mat(nameRegion(index)));
            fprintf(fid,'\n');
            index = index + 1;
        end
    end
elseif LINK_MODE==3
    index = 1;
    for k = 1:nNetwork
        tempFormerSum = 0;
        for l = 1:nNetworkRegion(k)
            fprintf(fid,'%s %u %u %s',['net',num2str(k)],tempFormerSum,tempFormerSum+bandWidth(index),cell2mat(nameRegion(index)));
            fprintf(fid,'\n');
            tempFormerSum = tempFormerSum + bandWidth(index);
            index = index + 1;
        end
    end
end
fclose(fid);

% write data of links
filePathLink = strcat(workingDir,filesep,'CircosInput3_link.txt');
fid = fopen(filePathLink,'w'); 
% describe links, FORMAT: Chromosome1 Start1 End1 Chromosome2 Start2 End2 Attributes
if LINK_MODE == 1 % even link width mode
    for k = 1:nCorr
        % calculate chromsome1's network and region
        rowCorrNet = RawDataCircos.HigherOrderNetworkIndex(rowCorr(k));
        rowCorrReg = rowCorr(k);
        if rowCorrNet > 1
            for l = 1:rowCorrNet-1
                rowCorrReg = rowCorrReg - nNetworkRegion(l);
            end
        end
        % calculate chromsome2's network and region
        colCorrNet = RawDataCircos.HigherOrderNetworkIndex(colCorr(k));
        colCorrReg = colCorr(k);
        if colCorrNet > 1
            for l = 1:colCorrNet-1
                colCorrReg = colCorrReg - nNetworkRegion(l);
            end
        end
        % calculate start and end
        rowCorrStart = (rowCorrReg-1)*spacing+(colCorrReg-1);
        rowCorrEnd = rowCorrStart+1;
        colCorrStart = (colCorrReg-1)*spacing+(rowCorrReg-1);
        colCorrEnd = colCorrStart+1;
        % print on txt according to format
        fprintf(fid,'net%u %u %u ',rowCorrNet,rowCorrStart,rowCorrEnd);
        fprintf(fid,'net%u %u %u ',colCorrNet,colCorrStart,colCorrEnd);
        fprintf(fid,'color=%u,%u,%u',matColor(k,1),matColor(k,2),matColor(k,3));
        fprintf(fid,'\n');
    end
elseif LINK_MODE == 2 % ratio link width mode
    matLinkWidthPercent = zeros(nRegion,nRegion);
    % normalize link width percent
    for k = 1:nRegion
        if arrRegionWidthRatio(k) ~= 0
            matLinkWidthPercent(k,:) = floor(matLinkWidthRatio(k,:)/arrRegionWidthRatio(k)*spacing);
            % use 'floor', sum is less than spacing(100), compensate the rest to first order
            if sum(matLinkWidthPercent(k,:)) ~= spacing
                matLinkWidthPercent(k,1) = matLinkWidthPercent(k,1) + (spacing - sum(matLinkWidthPercent(k,:)));
            end
        end
    end
    arrLinkOrderPloted = zeros(nRegion,1); % initialize, record ploted order
    for k = 1:nCorr
        % calculate chromsome1's network and region
        rowCorrNet = RawDataCircos.HigherOrderNetworkIndex(rowCorr(k));
        rowCorrReg = rowCorr(k);
        if rowCorrNet > 1
            for l = 1:rowCorrNet-1
                rowCorrReg = rowCorrReg - nNetworkRegion(l);
            end
        end
        % calculate chromsome2's network and region
        colCorrNet = RawDataCircos.HigherOrderNetworkIndex(colCorr(k));
        colCorrReg = colCorr(k);
        if colCorrNet > 1
            for l = 1:colCorrNet-1
                colCorrReg = colCorrReg - nNetworkRegion(l);
            end
        end
        % calculate chromsome1's start and end
        if arrLinkOrderPloted(rowCorr(k)) == 0
            rowCorrStart = (rowCorrReg-1)*spacing;
        else
            rowCorrStart = (rowCorrReg-1)*spacing + sum(matLinkWidthPercent(rowCorr(k),1:arrLinkOrderPloted(rowCorr(k))));
        end
        arrLinkOrderPloted(rowCorr(k)) = arrLinkOrderPloted(rowCorr(k)) + 1;
        rowCorrEnd = rowCorrStart + matLinkWidthPercent(rowCorr(k),arrLinkOrderPloted(rowCorr(k))) - 1;
        % calculate chromsome2's start and end
        if arrLinkOrderPloted(colCorr(k)) == 0
            colCorrStart = (colCorrReg-1)*spacing;
        else
            colCorrStart = (colCorrReg-1)*spacing + sum(matLinkWidthPercent(colCorr(k),1:arrLinkOrderPloted(colCorr(k))));
        end
        arrLinkOrderPloted(colCorr(k)) = arrLinkOrderPloted(colCorr(k)) + 1;
        colCorrEnd = colCorrStart + matLinkWidthPercent(colCorr(k),arrLinkOrderPloted(colCorr(k))) - 1;
        % print on txt according to format
        fprintf(fid,'net%u %u %u ',rowCorrNet,rowCorrStart,rowCorrEnd);
        fprintf(fid,'net%u %u %u ',colCorrNet,colCorrStart,colCorrEnd);
        fprintf(fid,'color=%u,%u,%u,%.1f',matColor(k,1),matColor(k,2),matColor(k,3),LINK_TRANSPARENCY);
        fprintf(fid,'\n');
    end
elseif LINK_MODE==3
    arrLinkOrderPloted = zeros(nRegion,1); % initialize, record ploted order
    % calculate start point of regions
    matRegStart = zeros(3,max(nNetworkRegion)); % initialize
    index = 1;
    for k = 1:nNetwork
        tempFormerSum = 0;
        for l = 1:nNetworkRegion(k)
            matRegStart(k,l) = tempFormerSum;
            tempFormerSum = tempFormerSum + bandWidth(index);
            index = index + 1;
        end
    end
    for k = 1:nCorr
        % calculate chromsome1's network and region
        rowCorrNet = RawDataCircos.HigherOrderNetworkIndex(rowCorr(k));
        rowCorrReg = rowCorr(k);
        if rowCorrNet > 1
            for l = 1:rowCorrNet-1
                rowCorrReg = rowCorrReg - nNetworkRegion(l);
            end
        end
        % calculate chromsome2's network and region
        colCorrNet = RawDataCircos.HigherOrderNetworkIndex(colCorr(k));
        colCorrReg = colCorr(k);
        if colCorrNet > 1
            for l = 1:colCorrNet-1
                colCorrReg = colCorrReg - nNetworkRegion(l);
            end
        end
        % calculate chromsome1's start and end
        if arrLinkOrderPloted(rowCorr(k)) == 0
            rowCorrStart = matRegStart(rowCorrNet,rowCorrReg);
        else
            rowCorrStart = matRegStart(rowCorrNet,rowCorrReg) + sum(matLinkWidthRatio100(rowCorr(k),1:arrLinkOrderPloted(rowCorr(k))));
        end
        arrLinkOrderPloted(rowCorr(k)) = arrLinkOrderPloted(rowCorr(k)) + 1;
        rowCorrEnd = rowCorrStart + matLinkWidthRatio100(rowCorr(k),arrLinkOrderPloted(rowCorr(k))) - 1;
        % calculate chromsome2's start and end
        if arrLinkOrderPloted(colCorr(k)) == 0
            colCorrStart = matRegStart(colCorrNet,colCorrReg);
        else
            colCorrStart = matRegStart(colCorrNet,colCorrReg) + sum(matLinkWidthRatio100(colCorr(k),1:arrLinkOrderPloted(colCorr(k))));
        end
        arrLinkOrderPloted(colCorr(k)) = arrLinkOrderPloted(colCorr(k)) + 1;
        colCorrEnd = colCorrStart + matLinkWidthRatio100(colCorr(k),arrLinkOrderPloted(colCorr(k))) - 1;
        % print on txt according to format
        fprintf(fid,'net%u %u %u ',rowCorrNet,rowCorrStart,rowCorrEnd);
        fprintf(fid,'net%u %u %u ',colCorrNet,colCorrStart,colCorrEnd);
        fprintf(fid,'color=%u,%u,%u,%.1f',matColor(k,1),matColor(k,2),matColor(k,3),LINK_TRANSPARENCY);
        fprintf(fid,'\n');
    end
elseif LINK_MODE==4
    arrLinkOrderPloted = zeros(nRegion,1); % initialize, record ploted order
    for k = 1:nCorr
        % calculate chromsome1's network and region
        rowCorrNet = RawDataCircos.HigherOrderNetworkIndex(rowCorr(k));
        rowCorrReg = rowCorr(k);
        if rowCorrNet > 1
            for l = 1:rowCorrNet-1
                rowCorrReg = rowCorrReg - nNetworkRegion(l);
            end
        end
        % calculate chromsome2's network and region
        colCorrNet = RawDataCircos.HigherOrderNetworkIndex(colCorr(k));
        colCorrReg = colCorr(k);
        if colCorrNet > 1
            for l = 1:colCorrNet-1
                colCorrReg = colCorrReg - nNetworkRegion(l);
            end
        end
        % calculate chromsome1's start and end
        if arrLinkOrderPloted(rowCorr(k)) == 0
            rowCorrStart = (rowCorrReg-1)*isoBandWidth;
        else
            rowCorrStart = (rowCorrReg-1)*isoBandWidth + sum(matLinkWidthRatio100(rowCorr(k),1:arrLinkOrderPloted(rowCorr(k))));
        end
        arrLinkOrderPloted(rowCorr(k)) = arrLinkOrderPloted(rowCorr(k)) + 1;
        rowCorrEnd = rowCorrStart + matLinkWidthRatio100(rowCorr(k),arrLinkOrderPloted(rowCorr(k))) - 1;
        % calculate chromsome2's start and end
        if arrLinkOrderPloted(colCorr(k)) == 0
            colCorrStart = (colCorrReg-1)*isoBandWidth;
        else
            colCorrStart = (colCorrReg-1)*isoBandWidth + sum(matLinkWidthRatio100(colCorr(k),1:arrLinkOrderPloted(colCorr(k))));
        end
        arrLinkOrderPloted(colCorr(k)) = arrLinkOrderPloted(colCorr(k)) + 1;
        colCorrEnd = colCorrStart + matLinkWidthRatio100(colCorr(k),arrLinkOrderPloted(colCorr(k))) - 1;
        % print on txt according to format
        fprintf(fid,'net%u %u %u ',rowCorrNet,rowCorrStart,rowCorrEnd);
        fprintf(fid,'net%u %u %u ',colCorrNet,colCorrStart,colCorrEnd);
        fprintf(fid,'color=%u,%u,%u,%.1f',matColor(k,1),matColor(k,2),matColor(k,3),LINK_TRANSPARENCY);
        fprintf(fid,'\n');
    end
end
fclose(fid);



