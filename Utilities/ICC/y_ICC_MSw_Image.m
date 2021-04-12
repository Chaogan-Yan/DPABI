function y_ICC_MSw_Image(Rate1Dir,Rate2Dir,OutputName,MaskFile)
% function y_ICC_MSw_Image(Rate1Dir,Rate2Dir,OutputName,MaskFile)
% Calculate the within-subject mean square (MSw, a component of Intraclass correlation coefficient) for brain images.
%   Input:
%     Group1Dir - Cell, directory of the first group. Take average if multiple sessions
%     Group2Dir - Cell, directory of the the second group. Take average if multiple sessions
%   Output:
%     OutputName - image with within-subject mean square (MSw, a component of Intraclass correlation coefficient) for brain images.
%___________________________________________________________________________
% Written by YAN Chao-Gan 140901.
% First used in the paper: Yan, C.G., Cheung, B., Kelly, C., Colcombe, S., Craddock, R.C., Di Martino, A., Li, Q., Zuo, X.N., Castellanos, F.X., Milham, M.P., 2013. A comprehensive assessment of regional variation in the impact of head micromovements on functional connectomics. Neuroimage 76, 183-201.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com

Rate1Series=0;
for i=1:length(Rate1Dir)
    [Temp,VoxelSize,theImgFileList, Header] =y_ReadAll(Rate1Dir{i});
    Rate1Series = Rate1Series + Temp;
    fprintf('\n\tImage Files in Rate %d Directory %d:\n',1, i);
    for itheImgFileList=1:length(theImgFileList)
        fprintf('\t%s%s\n',theImgFileList{itheImgFileList},'.img');
    end
end
Rate1Series = Rate1Series ./ (length(Rate1Dir));


Rate2Series=0;
for i=1:length(Rate2Dir)
    [Temp,VoxelSize,theImgFileList, Header] =y_ReadAll(Rate2Dir{i});
    Rate2Series = Rate2Series + Temp;
    fprintf('\n\tImage Files in Rate %d Directory %d:\n',2, i);
    for itheImgFileList=1:length(theImgFileList)
        fprintf('\t%s%s\n',theImgFileList{itheImgFileList},'.img');
    end
end
Rate2Series = Rate2Series ./ (length(Rate2Dir));


if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames') %YAN Chao-Gan 210402. If NIfTI data
    [nDim1,nDim2,nDim3,nDim4]=size(Rate2Series);
    if ~isempty(MaskFile)
        [MaskData,MaskVox,MaskHead]=y_ReadRPI(MaskFile);
    else
        MaskData=ones(nDim1,nDim2,nDim3);
    end
    WMSBrain=zeros(nDim1,nDim2,nDim3);
    for i=1:nDim1
        for j=1:nDim2
            for k=1:nDim3
                if MaskData(i,j,k)
                    xA=squeeze(Rate1Series(i,j,k,:));
                    xB=squeeze(Rate2Series(i,j,k,:));
                    WMSBrain(i,j,k)=IPN_WMS([xA,xB]);
                end
            end
        end
    end
else
    [nDimVertex nDimTimePoints]=size(Rate2Series);
    fprintf('\nLoad mask "%s".\n', MaskFile);
    if ~isempty(MaskFile)
        MaskData=y_ReadAll(MaskFile);
        if size(MaskData,1)~=nDimVertex
            error('The size of Mask (%d) doesn''t match the required size (%d).\n',size(MaskData,1), nDimVertex);
        end
        MaskData = double(logical(MaskData));
    else
        MaskData=ones(nDimVertex,1);
    end
    WMSBrain=zeros(nDimVertex,1);
    for i=1:nDimVertex
        if MaskData(i,1)
            xA=Rate1Series(i,:)';
            xB=Rate2Series(i,:)';
            WMSBrain(i,1)=IPN_WMS([xA,xB]);
        end
    end
end

WMSBrain(isnan(WMSBrain))=0;
y_Write(WMSBrain,Header,OutputName);



function [WMS] = IPN_WMS(x)
% INPUT:
%   x   - ratings data matrix, data whose columns represent different
%         ratings/raters & whose rows represent different cases or 
%         targets being measured. Each target is assumed too be a random
%         sample from a population of targets.
%   cse - 1 2 or 3: 1 if each target is measured by a different set of 
%         raters from a population of raters, 2 if each target is measured
%         by the same raters, but that these raters are sampled from a 
%         population of raters, 3 if each target is measured by the same 
%         raters and these raters are the only raters of interest.
%   typ - 'single' or 'k': denotes whether the ICC is based on a single
%         measurement or on an average of k measurements, where 
%         k = the number of ratings/raters.
%    
% REFERENCE:
%   Shrout PE, Fleiss JL. Intraclass correlations: uses in assessing rater
%   reliability. Psychol Bull. 1979;86:420-428
%
% NOTE:
%   This code was mainly modified with the Kevin's codes in web. 
%   (London kevin.brownhill@kcl.ac.uk)
%
% XINIAN ZUO
% Email: zuoxinian@gmail.com

% if isanova
%     [p,table,stats] = anova1(x',{},'off');
%     ICC=(table{2,4}-table{3,4})/(table{2,4}+table{3,3}/(table{2,3}+1)*table{3,4});
% else
    
%k is the number of raters, and n is the number of tagets
[n,k]=size(x);
%mean per target
mpt = mean(x,2);
%mean per rater/rating
mpr = mean(x);
%get total mean
tm = mean(x(:));
%within target sum sqrs
tmp = (x - repmat(mpt,1,k)).^2;
WSS = sum(tmp(:));
%within target mean sqrs
WMS = WSS / (n*(k - 1));
%between rater sum sqrs
RSS = sum((mpr - tm).^2) * n;
%between rater mean sqrs
RMS = RSS / (k - 1);
%between target sum sqrs
BSS = sum((mpt - tm).^2) * k;
%between targets mean squares
BMS = BSS / (n - 1);
%residual sum of squares
ESS = WSS - RSS;
%residual mean sqrs
EMS = ESS / ((k - 1) * (n - 1));

