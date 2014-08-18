function H_BrainNet = y_CallBrainNetViewer(BrainVolume,NMin,PMin,ClusterSize,ConnectivityCriterion,SurfFileName,viewtype,ColorMap,NMax,PMax,BrainHeader)
% function H_BrainNet = y_CallBrainNetViewer(BrainVolume,NMin,PMin,ClusterSize,ConnectivityCriterion,SurfFileName,viewtype,ColorMap,NMax,PMax,BrainHeader)
% Function to call BrainNet Viewer (by Mingrui Xia) by REST Slice Viewer. Also can be used to scripting call BrainNet Viewer.
% Input:
%     BrainVolume  - 1) The 3D Brain Volume (could be thresholded), parameter 'BrainHeader' needed.
%                 or 2) the File Name of a Brain Image, e.g. '/home/T.img'
%     NMin         - The negative minimum (minimum in absolute value). Could be the negative threshold
%                  - default: calculate from BrainVolume
%     PMin         - The positive minimum. Could be the positive threshold
%                  - default: calculate from BrainVolume
%     ClusterSize  - Set a cluster (voxel number) must be no less than the specified Cluster Size.
%                  - default: 0
%     ConnectivityCriterion - Set Connectivity Criterion, could be: 1) 6 - six neighboring voxels (surface connected)? 2) 18 - eighteen neighboring voxels (edge connected, SPM use this criterion); 3) 26 - twenty-six neighboring voxels (corner connected).
%                  - default: 18
%     SurfFileName - The File Name of brain surface. '*.nv'
%                    default: BrainMesh_ICBM152.nv in BrainNet Viewer
%     viewtype     - The type of view. Could be 'FullView' (8 views), 'MediumView' (4 views), 'SagittalView', 'AxialView' or 'CoronalView'.
%                  - default: 'MediumView' (4 views)
%     ColorMap     - The color map. Should be m by 3 color array.
%                  - default: AFNI_ColorMap 12 segments
%     NMax         - The negative maximum (maximum in absolute value)
%                  - default: calculate from BrainVolume
%     PMax         - The maximum
%                  - default: calculate from BrainVolume
%     BrainHeader  - If BrainVolume is given as a 3D Brain Volume, then BrainHeader should be designated.
% Output:
%     The fatastic Brain Surface View. Thanks to Mingrui Xia's work!
%     H_BrainNet   - The figure handle of the Brain Surface View.
%___________________________________________________________________________
% Written by YAN Chao-Gan 111023.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com

% Citing Information
%msgbox('The surface view is based on Mingrui Xia''s BrainNet Viewer. Please cite BrainNet Viewer (http://www.nitrc.org/projects/bnv/) when publishing.','Citing Information');

% Call BrainNet.m and share the global variables
[H_BrainNet] = BrainNet;
global FLAG
global EC
global surf
global a
global cam


% Reading Volume Data. If it is still a file name, then read it.
if ischar(BrainVolume)
    if (isdeployed)
        Nii  = nifti(BrainVolume);
        BrainVolume = double(Nii.dat);
        BrainHeader.mat = Nii.mat;
    else
        [BrainVolume Vox BrainHeader]=rest_readfile(BrainVolume);
    end
end

% Reading Surf Data. Referenced from Mingrui Xia's BrainNet Viewer
if ~exist('SurfFileName','var')
    [BrainNetViewerPath, fileN, extn] = fileparts(which('BrainNet.m'));
    SurfFileName=[BrainNetViewerPath,filesep,'Data',filesep,'SurfTemplate',filesep,'BrainMesh_ICBM152.nv'];
end
fid=fopen(SurfFileName);
surf.vertex_number=fscanf(fid,'%f',1);
surf.coord=fscanf(fid,'%f',[3,surf.vertex_number]);
surf.ntri=fscanf(fid,'%f',1);
surf.tri=fscanf(fid,'%d',[3,surf.ntri])';
fclose(fid);

% Set up View type
if ~exist('viewtype','var')
    viewtype='MediumView';
end
if strcmpi(viewtype,'FullView')
    EC.lot.view=2;
elseif strcmpi(viewtype,'MediumView')
    EC.lot.view=3;
elseif strcmpi(viewtype,'SagittalView')
    EC.lot.view=1;
    EC.lot.view_direction=1;
elseif strcmpi(viewtype,'AxialView')
    EC.lot.view=1;
    EC.lot.view_direction=2;
elseif strcmpi(viewtype,'CoronalView')
    EC.lot.view=1;
    EC.lot.view_direction=3;
end

% Set up colormap and negative max, negative min, positive min, positive max values
if ~exist('ColorMap','var')
    ColorMap = AFNI_ColorMap(12);
end

if ~exist('NMax','var')
    NMax = min(BrainVolume(:));
else
    if (isdeployed)
        NMax = str2num(NMax);
    end
end
if ~exist('NMin','var')
    NMin = max(BrainVolume(BrainVolume<0));
else
    if (isdeployed)
        NMin = str2num(NMin);
    end
end
if ~exist('PMin','var')
    PMin = min(BrainVolume(BrainVolume>0));
else
    if (isdeployed)
        PMin = str2num(PMin);
    end
end
if ~exist('PMax','var')
    PMax = max(BrainVolume(:));
else
    if (isdeployed)
        PMax = str2num(PMax);
    end
end

% Cluster Size thresholding, only need when ClusterSize exist and bigger than zero
if exist('ClusterSize','var')
    if (isdeployed)
        ClusterSize = str2num(ClusterSize);
    end
    if ~exist('ConnectivityCriterion','var')
        ConnectivityCriterion = 18;
    else
        if (isdeployed)
            ConnectivityCriterion = str2num(ConnectivityCriterion);
        end
    end
    if ClusterSize > 0
        BrainVolume = BrainVolume .* ((BrainVolume <= NMin) + (BrainVolume >= PMin));
        [theObjMask, theObjNum]=bwlabeln(BrainVolume,ConnectivityCriterion);
        for x=1:theObjNum,
            theCurrentCluster = theObjMask==x;
            if length(find(theCurrentCluster)) < ClusterSize,
                BrainVolume(logical(theCurrentCluster))=0;
            end
        end
    end
end
surf.hdr=BrainHeader;
surf.mask=BrainVolume;


% Adjust the colormap to leave blank to values under threshold, the orginal color map with be set into [NMax NMin] and [PMin PMax].
EC.vol.CM=AdjustColorMap(ColorMap,EC.vol.null,NMax,NMin,PMin,PMax);
EC.vol.px=PMax;
EC.vol.nx=NMax;

% Set up other parameters
EC.msh.alpha=1;
FLAG.MAP=2;
FLAG.LF=1;
FLAG.Loadfile=9;

% Tell Brain Net Viewer is called by REST and do not reset colormap
FLAG.IsCalledByREST=1;

% Call Brain Net Viewer ReDraw callback to refresh

set(H_BrainNet,'handlevisib','on');
BrainNet('NV_m_nm_Callback',H_BrainNet)




function NewColorMap=AdjustColorMap(OriginalColorMap,NullColor,NMax,NMin,PMin,PMax)
% Adjust the colormap to leave blank to values under threshold, the orginal color map with be set into [NMax NMin] and [PMin PMax]. Written by YAN Chao-Gan, 111023
% Input: OriginalColorMap - the original color map
%        NullColor - The values between NMin and PMin will be set to this color (leave blank)
%        NMax, NMin, PMin, PMax - set the axis of colorbar (the orginal color map with be set into [NMax NMin] and [PMin PMax])
% Output: NewColorMap - the generated color map, a 1000 by 3 matrix.

NewColorMap = repmat(NullColor,[1000 1]);
ColorLen=size(OriginalColorMap,1);
NegativeColorSegment = fix(1000*(NMin-NMax)/(PMax-NMax)/(ColorLen/2));
for iColor=1:fix(ColorLen/2)
    NewColorMap((iColor-1)*NegativeColorSegment+1:(iColor)*NegativeColorSegment,:) = repmat(OriginalColorMap(iColor,:),[NegativeColorSegment 1]);
end

PositiveColorSegment = fix(1000*(PMax-PMin)/(PMax-NMax)/(ColorLen/2));
for iColor=ColorLen:-1:ceil(ColorLen/2+1)
    NewColorMap(end-(ColorLen-iColor+1)*PositiveColorSegment+1:end-(ColorLen-iColor)*PositiveColorSegment,:) = repmat(OriginalColorMap(iColor,:),[PositiveColorSegment 1]);
end


function ColorMap =AFNI_ColorMap(SegmentNum)
% Generate the color map like AFNI. Written by YAN Chao-Gan, 090601
% Input: SegmentNum - the number of segments. it should be 2,4,6,8,9,10,11,12,13,14,15,16,17,18,19,20 or 256
% Output: ColorMap - the generated color map, an x by 3 matrix.
switch SegmentNum
    case 2,
        ColorMap=[1,1,0;0,0.8,1;];
    case 4,
        ColorMap=[1,1,0;1,0.4118,0;0,0.2667,1;0,0.8,1;];
    case 6,
        ColorMap=[1,1,0;1,0.6,0;1,0.2667,0;0,0,1;0,0.4118,1;0,0.8,1;];
    case 8,
        ColorMap=[1,1,0;1,0.8,0;1,0.4118,0;1,0.2667,0;0,0.2667,1;0,0.4118,1;0,0.6,1;0,0.8,1;];
    case 9,
        ColorMap=[1,1,0;1,0.8,0;1,0.4118,0;1,0.2667,0;0,0.2667,1;0,0.4118,1;0,0.6,1;0,0.8,1;];
    case 10,
        ColorMap=[1,1,0;1,0.8,0;1,0.6,0;1,0.4118,0;1,0.2667,0;0,0,1;0,0.2667,1;0,0.4118,1;0,0.6,1;0,0.8,1;];
    case 11,
        ColorMap=[1,1,0;1,0.8,0;1,0.6,0;1,0.4118,0;1,0.2667,0;1,0,0;0,0,1;0,0.2667,1;0,0.4118,1;0,0.6,1;0,0.8,1;];
    case 12,
        ColorMap=[1,1,0;1,0.8,0;1,0.6,0;1,0.4118,0;1,0.2667,0;1,0,0;0,0,1;0,0.2667,1;0,0.4118,1;0,0.6,1;0,0.8,1;0,1,1;];
    case 13,
        ColorMap=[1,1,0;1,0.8,0;1,0.6,0;1,0.4118,0;1,0.2667,0;1,0,0;0,0,1;0,0.2667,1;0,0.4118,1;0,0.6,1;0,0.8,1;0,1,1;0,1,0;];
    case 14,
        ColorMap=[1,1,0;1,0.8,0;1,0.6,0;1,0.4118,0;1,0.2667,0;1,0,0;0,0,1;0,0.2667,1;0,0.4118,1;0,0.6,1;0,0.8,1;0,1,1;0,1,0;0.1961,0.8039,0.1961;];
    case 15,
        ColorMap=[1,1,0;1,0.8,0;1,0.6,0;1,0.4118,0;1,0.2667,0;1,0,0;0,0,1;0,0.2667,1;0,0.4118,1;0,0.6,1;0,0.8,1;0,1,1;0,1,0;0.1961,0.8039,0.1961;0.3098,0.1843,0.3098;];
    case 16,
        ColorMap=[1,1,0;1,0.8,0;1,0.6,0;1,0.4118,0;1,0.2667,0;1,0,0;0,0,1;0,0.2667,1;0,0.4118,1;0,0.6,1;0,0.8,1;0,1,1;0,1,0;0.1961,0.8039,0.1961;0.3098,0.1843,0.3098;1,0.4118,0.7059;];
    case 17,
        ColorMap=[1,1,0;1,0.8,0;1,0.6,0;1,0.4118,0;1,0.2667,0;1,0,0;0,0,1;0,0.2667,1;0,0.4118,1;0,0.6,1;0,0.8,1;0,1,1;0,1,0;0.1961,0.8039,0.1961;0.3098,0.1843,0.3098;1,0.4118,0.7059;1,1,1;];
    case 18,
        ColorMap=[1,1,0;1,0.8,0;1,0.6,0;1,0.4118,0;1,0.2667,0;1,0,0;0,0,1;0,0.2667,1;0,0.4118,1;0,0.6,1;0,0.8,1;0,1,1;0,1,0;0.1961,0.8039,0.1961;0.3098,0.1843,0.3098;1,0.4118,0.7059;1,1,1;0.8667,0.8667,0.8667;];
    case 19,
        ColorMap=[1,1,0;1,0.8,0;1,0.6,0;1,0.4118,0;1,0.2667,0;1,0,0;0,0,1;0,0.2667,1;0,0.4118,1;0,0.6,1;0,0.8,1;0,1,1;0,1,0;0.1961,0.8039,0.1961;0.3098,0.1843,0.3098;1,0.4118,0.7059;1,1,1;0.8667,0.8667,0.8667;0.7333,0.7333,0.7333;];
    case 20,
        ColorMap=[0.8,0.0627,0.2;0.6,0.1255,0.4;0.4,0.1922,0.6;0.2,0.2549,0.8;0,0.3176,1;0,0.4549,0.8;0,0.5922,0.6;0,0.7255,0.4;0,0.8627,0.2;0,1,0;0.2,1,0;0.4,1,0;0.6,1,0;0.8,1,0;1,1,0;1,0.8,0;1,0.6,0;1,0.4,0;1,0.2,0;1,0,0;];
    otherwise,
        ColorMap=[1,0,0.1373;1,0,0.1176;1,0,0.0941;1,0,0.0706;1,0,0.0471;1,0.0667,0;1,0.0902,0;1,0.1137,0;1,0.1333,0;1,0.1569,0;1,0.1765,0;1,0.1961,0;1,0.2118,0;1,0.2314,0;1,0.251,0;1,0.2667,0;1,0.2863,0;1,0.302,0;1,0.3176,0;1,0.3373,0;1,0.3529,0;1,0.3686,0;1,0.3843,0;1,0.4,0;1,0.4157,0;1,0.4314,0;1,0.4471,0;1,0.4627,0;1,0.4784,0;1,0.4941,0;1,0.5098,0;1,0.5255,0;1,0.5412,0;1,0.5529,0;1,0.5686,0;1,0.5843,0;1,0.6,0;1,0.6118,0;1,0.6275,0;1,0.6431,0;1,0.6549,0;1,0.6706,0;1,0.6824,0;1,0.698,0;1,0.7098,0;1,0.7255,0;1,0.7373,0;1,0.7529,0;1,0.7647,0;1,0.7804,0;1,0.7922,0;1,0.8078,0;1,0.8196,0;1,0.8353,0;1,0.8471,0;1,0.8588,0;1,0.8745,0;1,0.8863,0;1,0.898,0;1,0.9137,0;1,0.9255,0;1,0.9373,0;1,0.9529,0;1,0.9647,0;1,0.9765,0;1,0.9882,0;0.9961,1,0;0.9843,1,0;0.9725,1,0;0.9608,1,0;0.9451,1,0;0.9333,1,0;0.9216,1,0;0.9059,1,0;0.8941,1,0;0.8824,1,0;0.8667,1,0;0.8549,1,0;0.8431,1,0;0.8275,1,0;0.8157,1,0;0.8,1,0;0.7882,1,0;0.7765,1,0;0.7608,1,0;0.749,1,0;0.7333,1,0;0.7216,1,0;0.7059,1,0;0.6941,1,0;0.6784,1,0;0.6627,1,0;0.651,1,0;0.6353,1,0;0.6235,1,0;0.6078,1,0;0.5922,1,0;0.5765,1,0;0.5647,1,0;0.549,1,0;0.5333,1,0;0.5176,1,0;0.5059,1,0;0.4902,1,0;0.4745,1,0;0.4588,1,0;0.4431,1,0;0.4275,1,0;0.4118,1,0;0.3961,1,0;0.3804,1,0;0.3647,1,0;0.3451,1,0;0.3294,1,0;0.3137,1,0;0.2941,1,0;0.2784,1,0;0.2627,1,0;0.2431,1,0;0.2235,1,0;0.2078,1,0;0.1882,1,0;0.1686,1,0;0.149,1,0;0.1255,1,0;0.1059,1,0;0.0824,1,0;0.0549,1,0;0,1,0.0549;0,1,0.0824;0,1,0.1059;0,1,0.1255;0,1,0.149;0,1,0.1686;0,1,0.1882;0,1,0.2078;0,1,0.2235;0,1,0.2431;0,1,0.2627;0,1,0.2784;0,1,0.2941;0,1,0.3137;0,1,0.3294;0,1,0.3451;0,1,0.3647;0,1,0.3804;0,1,0.3961;0,1,0.4118;0,1,0.4275;0,1,0.4431;0,1,0.4588;0,1,0.4745;0,1,0.4902;0,1,0.5059;0,1,0.5176;0,1,0.5333;0,1,0.549;0,1,0.5647;0,1,0.5765;0,1,0.5922;0,1,0.6078;0,1,0.6235;0,1,0.6353;0,1,0.651;0,1,0.6627;0,1,0.6784;0,1,0.6941;0,1,0.7059;0,1,0.7216;0,1,0.7333;0,1,0.749;0,1,0.7608;0,1,0.7765;0,1,0.7882;0,1,0.8;0,1,0.8157;0,1,0.8275;0,1,0.8431;0,1,0.8549;0,1,0.8667;0,1,0.8824;0,1,0.8941;0,1,0.9059;0,1,0.9216;0,1,0.9333;0,1,0.9451;0,1,0.9608;0,1,0.9725;0,1,0.9843;0,1,0.9961;0,0.9882,1;0,0.9765,1;0,0.9647,1;0,0.9529,1;0,0.9373,1;0,0.9255,1;0,0.9137,1;0,0.898,1;0,0.8863,1;0,0.8745,1;0,0.8588,1;0,0.8471,1;0,0.8353,1;0,0.8196,1;0,0.8078,1;0,0.7922,1;0,0.7804,1;0,0.7647,1;0,0.7529,1;0,0.7373,1;0,0.7255,1;0,0.7098,1;0,0.698,1;0,0.6824,1;0,0.6706,1;0,0.6549,1;0,0.6431,1;0,0.6275,1;0,0.6118,1;0,0.6,1;0,0.5843,1;0,0.5686,1;0,0.5529,1;0,0.5412,1;0,0.5255,1;0,0.5098,1;0,0.4941,1;0,0.4784,1;0,0.4627,1;0,0.4471,1;0,0.4314,1;0,0.4157,1;0,0.4,1;0,0.3843,1;0,0.3686,1;0,0.3529,1;0,0.3373,1;0,0.3176,1;0,0.302,1;0,0.2863,1;0,0.2667,1;0,0.251,1;0,0.2314,1;0,0.2118,1;0,0.1961,1;0,0.1765,1;0,0.1569,1;0,0.1333,1;0,0.1137,1;0,0.0902,1;0,0.0667,1;0.0471,0,1;0.0706,0,1;0.0941,0,1;0.1176,0,1;0.1373,0,1;];
end
ColorMap=flipdim(ColorMap,1);



