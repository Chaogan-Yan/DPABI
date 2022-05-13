function [filePathNetwork,filePathRegion,filePathLabel,filePathLink] = CircosDataOrganize(workingDir,CircosStruct)
% FORMAT [filePathNetwork,filePathRegion,filePathLabel,filePathLink] = CircosDataOrganize(workingDir,CircosStruct)
% Data organization for Circos plot via the format of txt
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
%       .netCmap - customize color map for network
%       .regCmap - customize color map for region
%       .linkCmap - customize color map in RGB for link
% Output:
%   filePathNetwork - 1st txt file contains network information (band)
%   filePathRegion - 2nd txt file contains region information (highlight)
%   filePathLabel - 3rd txt file contains label information
%   filePathLink - 4th txt file contains link information
%__________________________________________________________________________
% Written by DENG Zhao-Yu 210408 for DPARBI.
% Institute of Psychology, Chinese Academy of Sciences
% dengzy@psych.ac.cn
%__________________________________________________________________________
%%

% change working directory
cd(workingDir);

% define variables
COLORBAR_ROUNDN_SENS = -2;
% LINK_TRANSPARENCY = 0.3; % transparency of links in plot!!PNG vs SVG complementary
MAX_WIDTH = 1; MIN_WIDTH = 0.2; % normalize width parameter

% define the amount of networks and regions
nRegion = length(CircosStruct.ProcMatrix(:,1)); % number of regions
if (~isfield(CircosStruct,'HigherOrderNetworkIndex') || isempty(CircosStruct.HigherOrderNetworkIndex))
    CircosStruct.HigherOrderNetworkIndex = ones(nRegion,1);
end
nNetwork = max(CircosStruct.HigherOrderNetworkIndex); % number of networks

% networks and regions
tabTemp = tabulate(CircosStruct.HigherOrderNetworkIndex);
nNetworkRegion = tabTemp(:,2);

% if no label information, set them default
if (~isfield(CircosStruct,'HigherOrderNetworkLabel') || isempty(CircosStruct.HigherOrderNetworkLabel))
    nameNetwork = cell(nNetwork,1);
    for k = 1:nNetwork
        nameNetwork(k) = cellstr(strcat('n',num2str(k)));
    end
else
    nameNetwork = CircosStruct.HigherOrderNetworkLabel(:,2);
end
nameNetwork = strrep(nameNetwork,' ','-'); % replace space with hyphen Update 220418

if (~isfield(CircosStruct,'ElementLabel') || isempty(CircosStruct.ElementLabel))
    nameRegion = cell(nRegion,1);
    for k = 1:nRegion
        nameRegion(k) = cellstr(strcat('r',num2str(k)));
    end
else
    nameRegion = CircosStruct.ElementLabel(:,2);
end
nameRegion = strrep(nameRegion,' ','-'); % replace space with hyphen Update 220418


% generate correlation matrix for links, filter threshold
% matCorr = RawDataCircos.P_Corrected < P_THRESHOLD; 
[rowCorr,colCorr] = find(triu(CircosStruct.ProcMatrix~=0)); % withdraw upper triangle matrix
nCorr = length(rowCorr); % number of correlation pairs
arrPlot = zeros(length(rowCorr),1); % initialize array that store values that plots
for k = 1:length(rowCorr)
    arrPlot(k) = CircosStruct.ProcMatrix(rowCorr(k),colCorr(k)); % store values in matrix
end
maxabsArrPlot = max(abs(min(arrPlot)),abs(max(arrPlot)));
arrCorRatio = roundn((arrPlot/maxabsArrPlot),COLORBAR_ROUNDN_SENS); % correlation normalization, sensitivity
% normalize to appropriate range
maxArrPlot = max(abs(arrPlot(:))); minArrPlot = min(abs(arrPlot(:)));
if maxArrPlot~=minArrPlot
    normArrPlot = roundn(MIN_WIDTH+(MAX_WIDTH-MIN_WIDTH)*(abs(arrPlot)-minArrPlot)/(maxArrPlot-minArrPlot),COLORBAR_ROUNDN_SENS);
else
    normArrPlot = arrPlot./arrPlot;
end

% calculate correlation for plot
logiMatIndexLink = false(nCorr,nCorr);
arrLink = zeros(nRegion,1); 
matLinkWidthRatio = zeros(nRegion,nRegion); % initialize ratio of regions' link width
for k = 1:nRegion
    logiMatIndexLink(:,k) = rowCorr==k|colCorr==k;
    arrLink(k) = sum(logiMatIndexLink(:,k)); % regions' links amount
    matLinkWidthRatio(k,1:arrLink(k)) = normArrPlot(logiMatIndexLink(:,k))';
end


% generate network RGB colormap
if (~isfield(CircosStruct,'netCmap') || isempty(CircosStruct.netCmap))
    netCmap = fix(zeros(nNetwork,3)*255); % default color black
else
    netCmap = fix(CircosStruct.netCmap*255);
end
% generate region RGB colormap
if (~isfield(CircosStruct,'regCmap') || isempty(CircosStruct.regCmap))
    regCmap = fix(hsv(nRegion)*255);  % default color hsv
else
    regCmap = fix(CircosStruct.regCmap*255);
end
% generate or load link RGB colormap
if (~isfield(CircosStruct,'linkCmap') || isempty(CircosStruct.linkCmap))
    load('linkCmap.mat','linkCmap');
else
    linkCmap = fix(CircosStruct.linkCmap*255); % default color part of jet
end
nCmap = length(linkCmap);

% set 4 matrix limit
if (~isfield(CircosStruct,'CmapLimit') || isempty(CircosStruct.CmapLimit))
    leftMinLimit = min(arrPlot(arrPlot<0));
    leftMaxLimit = max(arrPlot(arrPlot<0));
    rightMinLimit = min(arrPlot(arrPlot>0));
    rightMaxLimit = max(arrPlot(arrPlot>0));
else
    leftMinLimit = CircosStruct.CmapLimit(1,1);
    leftMaxLimit = CircosStruct.CmapLimit(1,2);
    rightMinLimit = CircosStruct.CmapLimit(2,1);
    rightMaxLimit = CircosStruct.CmapLimit(2,2);
end
% select the color of links in colormap
matColor = zeros(nCorr,3); % initialize matrix that store color of links
cmapArrCorr = zeros(nCorr,1);
norArrCorRatio = zeros(nCorr,1);
for k = 1:nCorr
    if arrCorRatio(k) < 0
        norArrCorRatio(k) = (arrPlot(k)-leftMaxLimit)/(leftMaxLimit-leftMinLimit);
        % fixed a bug when leftMaxLimit=leftMinLimit, Update in 220412
        if isinf(norArrCorRatio(k)) || isnan(norArrCorRatio(k))
            norArrCorRatio(k) = -1;
        end
        cmapArrCorr(k) = fix(norArrCorRatio(k)*(nCmap/2))+(nCmap/2)+1;
    elseif arrCorRatio(k) > 0
        norArrCorRatio(k) = (arrPlot(k)-rightMinLimit)/(rightMaxLimit-rightMinLimit);
        % fixed a bug when rightMaxLimit=rightMinLimit, Update in 220412
        if isinf(norArrCorRatio(k)) || isnan(norArrCorRatio(k))
            norArrCorRatio(k) = 1;
        end
        cmapArrCorr(k) = fix(norArrCorRatio(k)*(nCmap/2))+(nCmap/2);
    end
    matColor(k,:) = linkCmap(cmapArrCorr(k),:);
end

% write data of networks
filePathNetwork = strcat(workingDir,filesep,'CircosInput1_network.txt');
fid = fopen(filePathNetwork,'w');
% describe external networks, FORMAT: chr - ID label start end attribute
% isometry band, width = max link width ratio
matLinkWidthRatio100 = floor(matLinkWidthRatio*100);
isoBandWidth = max(sum(matLinkWidthRatio100,2)); % initialize isometry band width
for k = 1:nNetwork
    fprintf(fid,'chr - %s %s ',['net',num2str(k)],cell2mat(nameNetwork(k)));
%     fprintf(fid,'%u %u %s',0,nNetworkRegion(k)*isoBandWidth,['chr',num2str(k)]);
    fprintf(fid,'%u %u ',0,nNetworkRegion(k)*isoBandWidth);
    fprintf(fid,'rgb(%u,%u,%u)',netCmap(k,1),netCmap(k,2),netCmap(k,3));
    fprintf(fid,'\n');
end
fclose(fid);

% write data of regions
filePathRegion = strcat(workingDir,filesep,'CircosInput2_region.txt');
fid = fopen(filePathRegion,'w');
% describe internal hightlight, FORMAT: chrID start end fill_color
index = 1;
for k = 1:nNetwork
    for l = 1:nNetworkRegion(k)
        fprintf(fid,'%s ',['net',num2str(k)]);
        fprintf(fid,'%u %u ',(l-1)*isoBandWidth,l*isoBandWidth);
        fprintf(fid,'fill_color=%u,%u,%u',regCmap(index,1),regCmap(index,2),regCmap(index,3));
        fprintf(fid,'\n');
        index = index + 1;
    end
end
fclose(fid);

% write data of band labels
filePathLabel = strcat(workingDir,filesep,'CircosInput3_label.txt');
fid = fopen(filePathLabel,'w');
% label karyotype band, FORMAT: ID start end label
index = 1;
for k = 1:nNetwork
    for l = 1:nNetworkRegion(k)
        fprintf(fid,'%s %u %u %s',['net',num2str(k)],(l-1)*isoBandWidth,l*isoBandWidth,cell2mat(nameRegion(index)));
        fprintf(fid,'\n');
        index = index + 1;
    end
end
fclose(fid);

% write data of links
filePathLink = strcat(workingDir,filesep,'CircosInput4_link.txt');
fid = fopen(filePathLink,'w'); 
% describe links, FORMAT: Chromosome1 Start1 End1 Chromosome2 Start2 End2 Attributes
arrLinkOrderPloted = zeros(nRegion,1); % initialize, record ploted order
for k = 1:nCorr
    % calculate chromsome1's network and region
    rowCorrNet = CircosStruct.HigherOrderNetworkIndex(rowCorr(k));
    rowCorrReg = rowCorr(k);
    if rowCorrNet > 1
        for l = 1:rowCorrNet-1
            rowCorrReg = rowCorrReg - nNetworkRegion(l);
        end
    end
    % calculate chromsome2's network and region
    colCorrNet = CircosStruct.HigherOrderNetworkIndex(colCorr(k));
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
    fprintf(fid,'color=%u,%u,%u',matColor(k,1),matColor(k,2),matColor(k,3));
%         fprintf(fid,'color=%u,%u,%u,%.1f',matColor(k,1),matColor(k,2),matColor(k,3),LINK_TRANSPARENCY);
    fprintf(fid,'\n');
end
fclose(fid);



