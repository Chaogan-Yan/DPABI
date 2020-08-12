function [Data_Corrected, ClusterSize, Header]=y_GRF_Threshold(StatsImgFile,VoxelPThreshold,IsTwoTailed,ClusterPThreshold,OutputName,MaskFile,Flag,Df1,Df2,VoxelSize,Header, dLh)
% function [Data_Corrected, ClusterSize, Header]=y_GRF_Threshold(StatsImgFile,VoxelPThreshold,IsTwoTailed,ClusterPThreshold,OutputName,MaskFile,Flag,Df1,Df2,VoxelSize,Header)
% Function to perform Gaussian Random Field theory multiple comparison correction like easythresh in FSL.
% References:
% Flitney, D.E., & Jenkinson, M. 2000. Cluster Analysis Revisited. Tech. rept. Oxford Centre for Functional Magnetic Resonance Imaging of the Brain, Department of Clinical Neurology, Oxford University, Oxford, UK. TR00DF1.
% K. Friston, K. Worsley, R. Frackowiak, J. Mazziotta, and A. Evans. Assessing the significance of focal activations using their spatial extent. Human Brain Mapping, 1:214?220, 1994.
% Input:
%     StatsImgFile      - The statistical image file name. Could be either Z, T, F or R statistical image. T/F/R images will transformed into Z image (according to their degree of freedom Df1, Df2) to perform further smoothness estimation and cluster thresholding.
%     VoxelPThreshold   - P threshold for each voxel. Will be transformed into Z threshold in two-tailed way or one-tailed way. Note: FSL's Z>2.3 corresponds to one-tailed VoxelPThreshold = 0.0107. |Z|>2.3 corresponds to two-tailed VoxelPThreshold = 0.0214.
%     IsTwoTailed       - 0: in one-tailed way. 1: converting voxel P threshold to z threshold in two-tailed way. Correct positive values to Cluster P at ClusterPThreshold/2, and correct negative values to Cluster P at ClusterPThreshold/2. Together the Cluster P < ClusterPThreshold.
%     ClusterPThreshold - The final cluster-level P threshold
%     OutputName        - The output file name. Will be suffixed by'Z_ClusterThresholded_'.
%                       - 'DO NOT OUTPUT IMAGE': means called by rest_sliceviewer, and do not need to write into a file.
%     MaskFile          - The mask file name. If empty (i.e., ''), then all voxels are included.
%     Flag              - 'Z', 'T', 'F' or 'R'. Indicate the type of the input statistical image
%                       - If not defined or defined as empty, then will read the statistical type and degree of freedom information from the image (if the statistical analysis was performed with REST or SPM).
%     Df1               - The degree of freedom of the statistical image. For F statistical image, there is also Df2
%     Df2               - The second degree of freedom of F statistical image
%     VoxelSize         - The Voxel's size of the image inputed. Defined when call by rest_sliceviewer.
%     Header            - The Header of the nifti image.
%     dLh               - Smoothness estimated as sqrt(det(Lambda)) with y_Smoothest, will be used in inference. 
%                         If this item is not provided, or is empty, then the smoothness will be estimated automatically from the statistical image (first convert to Z image).
% Output:
%     The image file (Z statistical image) after correction.
%     Data_Corrected    - The Data matrix after correction
%     ClusterSize       - The cluster size for cluster-level p threshold and can be used in REST Slice Viewer. (Note: corner connection is used in FSL)
%     Header            - The output Header of the nifti image.
%___________________________________________________________________________
% Written by YAN Chao-Gan 120120.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com

if ~exist('VoxelSize','var')
    VoxelSize = ''; % The voxel size will be defined later
end

[OutPath, OutName,OutExt]=fileparts(OutputName);
if isempty(OutPath)
    OutPath='.';
end

%Read Header in.
if (~exist('Header','var')) || (exist('Header','var') && isempty(Header))
    [BrainVolume, VoxelSize, Header]=y_ReadRPI(StatsImgFile);
end

%Read Mask
[nDim1 nDim2 nDim3 nDimTimePoints]=size(BrainVolume);
if ~isempty(MaskFile)
    [MaskData,MaskVox,MaskHead]=y_ReadRPI(MaskFile);
else
    MaskData=ones(nDim1,nDim2,nDim3);
end
nVoxels=length(find(MaskData));

%Added by YAN Chao-Gan 121222. Detect the Flag and DF from the data if Flag is not defined.
if (~exist('Flag','var')) || (exist('Flag','var') && isempty(Flag))
   Header_DF = w_ReadDF(Header);
   Flag = Header_DF.TestFlag;
   Df1 = Header_DF.Df;
   Df2 = Header_DF.Df2;
end

if ~strcmpi(Flag,'Z')
    fprintf('Converting the %s maps into Z maps.\n',Flag);
    if ~exist('Df2','var')
        Df2=0;
    end
    [Z P] = y_TFRtoZ(StatsImgFile,[OutPath,filesep,'Z_BeforeThreshold_',OutName,OutExt],Flag,Df1,Df2);
end

%Added by YAN Chao-Gan 130508. If dLh is not provided, or is empty, then the smoothness will be estimated automatically from the statistical image (first convert to Z image).
if (~exist('dLh','var')) || (exist('dLh','var') && isempty(dLh))
    Header_DLH = w_ReadFWHM(Header);
    dLh = Header_DLH.dLh;
    FWHM = [Header_DLH.FWHMx, Header_DLH.FWHMy, Header_DLH.FWHMz];
    
    if dLh == 0
        fprintf('Estimate the smoothness from the Z statistical image.\n');
        if strcmpi(Flag,'Z')
            DOF=''; %Degree of freedom for residual files
            [dLh,resels,FWHM, nVoxels]=y_Smoothest(StatsImgFile,MaskFile,DOF,VoxelSize);
        else
            [dLh,resels,FWHM, nVoxels]=y_Smoothest([OutPath,filesep,'Z_BeforeThreshold_',OutName,OutExt], MaskFile);
        end
    else %If smoothness was read from header, then display it.
        fprintf('Smoothness was read from the NIfTI header of the statistical image.\n');
        fprintf('FWHMx = %f mm\nFWHMy = %f mm\nFWHMz = %f mm\n',FWHM(1),FWHM(2),FWHM(3));
        nVoxels=length(find(MaskData));
        fprintf('DLH = %f\nVOLUME = %d\n',dLh,nVoxels);
    end
end


if IsTwoTailed
    zThrd=norminv(1 - VoxelPThreshold/2);
else
    zThrd=norminv(1 - VoxelPThreshold);
end
fprintf('The voxel Z threshold for voxel p threshold %f is: %f.\n',VoxelPThreshold,zThrd);

% Note: If two-tailed way is used, then correct positive values to Cluster P at ClusterPThreshold/2, and correct negative values to Cluster P at ClusterPThreshold/2. Together the Cluster P < ClusterPThreshold.
fprintf('The Minimum cluster size for voxel p threshold %f and cluster p threshold %f is: ',VoxelPThreshold,ClusterPThreshold);
if IsTwoTailed
    ClusterPThreshold = ClusterPThreshold/2;
end

% Calculate Expectations of m clusters Em and exponent Beta for inference.
D=3;
Em = nVoxels * (2*pi)^(-(D+1)/2) * dLh * (zThrd*zThrd-1)^((D-1)/2) * exp(-zThrd*zThrd/2);
EN = nVoxels * (1-normcdf(zThrd)); %In Friston et al., 1994, EN = S*Phi(-u). (Expectation of N voxels)  % K. Friston, K. Worsley, R. Frackowiak, J. Mazziotta, and A. Evans. Assessing the significance of focal activations using their spatial extent. Human Brain Mapping, 1:214?220, 1994.
Beta = ((gamma(D/2+1)*Em)/(EN)) ^ (2/D); % K. Friston, K. Worsley, R. Frackowiak, J. Mazziotta, and A. Evans. Assessing the significance of focal activations using their spatial extent. Human Brain Mapping, 1:214?220, 1994.

% Get the minimum cluster size
pTemp=1;
ClusterSize=0;
while pTemp >= ClusterPThreshold
    ClusterSize=ClusterSize+1;
    pTemp = 1 - exp(-Em * exp(-Beta * ClusterSize^(2/D))); %K. Friston, K. Worsley, R. Frackowiak, J. Mazziotta, and A. Evans. Assessing the significance of focal activations using their spatial extent. Human Brain Mapping, 1:214?220, 1994.
end

fprintf('%f voxels\n',ClusterSize);

ConnectivityCriterion = 26; % Corner connection is used in FSL.

if strcmpi(Flag,'Z')
    [BrainVolume, VoxelSize, Header]=y_ReadRPI(StatsImgFile);
else
    [BrainVolume, VoxelSize, Header]=y_ReadRPI([OutPath,filesep,'Z_BeforeThreshold_',OutName,OutExt]);
end

%Apply the Mask to the Brain Volume
BrainVolume = BrainVolume.*MaskData;


if ClusterSize > 0
    if IsTwoTailed % If Two Tailed, then correct negative values to Cluster P at ClusterPThreshold/2 first.
        BrainVolumeNegative = BrainVolume .* (BrainVolume <= -1*zThrd);
        [theObjMask, theObjNum]=bwlabeln(BrainVolumeNegative,ConnectivityCriterion);
        for x=1:theObjNum,
            theCurrentCluster = theObjMask==x;
            if length(find(theCurrentCluster)) < ClusterSize,
                BrainVolumeNegative(logical(theCurrentCluster))=0;
            end
        end
    else
        BrainVolumeNegative = 0;
    end
    
    % Correct positive values to Cluster P
    BrainVolume = BrainVolume .* (BrainVolume >= zThrd);
    [theObjMask, theObjNum]=bwlabeln(BrainVolume,ConnectivityCriterion);
    for x=1:theObjNum,
        theCurrentCluster = theObjMask==x;
        if length(find(theCurrentCluster)) < ClusterSize,
            BrainVolume(logical(theCurrentCluster))=0;
        end
    end
    
    BrainVolume = BrainVolume + BrainVolumeNegative;
end

Header.pinfo = [1;0;0];
Header.dt    =[16,0];
if ~isempty(OutputName)
    y_Write(BrainVolume,Header,[OutPath,filesep,'Z_ClusterThresholded_',OutName,OutExt]);
    if ~strcmpi(Flag,'Z') %Write the thresholded T or F image. YAN Chao-Gan, 160810
        [BrainVolumeRawStats]=y_ReadRPI(StatsImgFile);
        BrainVolumeRawStats = BrainVolumeRawStats .* (BrainVolume~=0);
        y_Write(BrainVolumeRawStats,Header,[OutPath,filesep,'ClusterThresholded_',OutName,OutExt]);
    end
end

Data_Corrected=BrainVolume;

