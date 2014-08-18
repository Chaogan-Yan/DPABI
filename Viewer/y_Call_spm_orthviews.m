function H = y_Call_spm_orthviews(BrainVolume,NMin,PMin,ClusterSize,ConnectivityCriterion,UnderlayFileName,ColorMap,NMax,PMax,H,Transparency,Position,BrainHeader)
% function H = y_Call_spm_orthviews(BrainVolume,NMin,PMin,ClusterSize,ConnectivityCriterion,UnderlayFileName,ColorMap,NMax,PMax,BrainHeader)
% Function to call y_spm_orthviews.
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
%     UnderlayFileName - The File Name of underlay
%                    default: ch2.nii in DPABI
%     ColorMap     - The color map. Should be m by 3 color array.
%                  - default: AFNI_ColorMap 12 segments
%     NMax         - The negative maximum (maximum in absolute value)
%                  - default: calculate from BrainVolume
%     PMax         - The maximum
%                  - default: calculate from BrainVolume
%     H            - The handle of the figure. Will create a new figure if this parameter is not given.
%     Transparency - The transparency of over lay. Default: 0.2
%     Position     - The position of the center cross. Default: [0 0 0]
%     BrainHeader  - If BrainVolume is given as a 3D Brain Volume, then BrainHeader should be designated.
% Output:
%     The Brain view.
%     H            - The figure handle of the Brain View.
%___________________________________________________________________________
% Written by YAN Chao-Gan 130719.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com

%Init
global st

if ~iscell(st)
    st=cell(5);
end

if ~exist('H','var')
    curfig=figure;
    st{curfig}.fig = curfig;
else
    curfig=gcf;
    st{curfig}.fig=H;
end

st{curfig}.xhairs=1;st{curfig}.hld=1;st{curfig}.yoke=1;st{curfig}.curblob=0;%Add yoke by Sandy 20130823
st{curfig}.n=0;st{curfig}.vols=cell(24);st{curfig}.bb=[];st{curfig}.Space=eye(4,4);st{curfig}.centre=[0 0 0];st{curfig}.callback=';';st{curfig}.mode=1;st{curfig}.snap=[];
st{curfig}.plugins={'movie'  'reorient'  'rgb'  'roi'};


%Add underlay
% Set up underlay file
if ~exist('UnderlayFileName','var')
    [DPABIPath, fileN, extn] = fileparts(which('DPABI.m'));
    UnderlayFileName=[DPABIPath,filesep,'Templates',filesep,'ch2.nii'];
end
if ~isempty(UnderlayFileName)
    [UnderlayVolume UnderlayVox UnderlayHeader] = y_ReadRPI(UnderlayFileName);
    UnderlayHeader.Data = UnderlayVolume;
else
    % If the underlay is empty, need to dispaly a dark backgroud. Thus, reading Overlay data as underlay
    if ischar(BrainVolume)
        [UnderlayVolume UnderlayVox UnderlayHeader] = y_ReadRPI(BrainVolume);
    else
        UnderlayHeader = BrainHeader;
    end
    %Set data to 0 (dark display)
    UnderlayHeader.Data = 0;
end
colormap(gray(64))
H = y_spm_orthviews('Image',UnderlayHeader);


%Add overlay
if ~isempty(BrainVolume)
    
    % Reading Volume Data. If it is still a file name, then read it.
    if ischar(BrainVolume)
        if (isdeployed)
            Nii  = nifti(BrainVolume);
            BrainVolume = double(Nii.dat);
            BrainHeader.mat = Nii.mat;
        else
            [BrainVolume Vox BrainHeader] = y_ReadRPI(BrainVolume);
        end
    end
    
    
    % Set up colormap and negative max, negative min, positive min, positive max values
    if ~exist('ColorMap','var') || isempty(ColorMap)
        ColorMap = y_AFNI_ColorMap(12);
    end
    
    if ~exist('NMax','var') || isempty(NMax)
        NMax = min(BrainVolume(:));
    else
        if (isdeployed)
            NMax = str2num(NMax);
        end
    end
    if ~exist('NMin','var') || isempty(NMin)
        NMin = max(BrainVolume(BrainVolume<0));
    else
        if (isdeployed)
            NMin = str2num(NMin);
        end
    end
    if ~exist('PMin','var') || isempty(PMin)
        PMin = min(BrainVolume(BrainVolume>0));
    else
        if (isdeployed)
            PMin = str2num(PMin);
        end
    end
    if ~exist('PMax','var') || isempty(PMax)
        PMax = max(BrainVolume(:));
    else
        if (isdeployed)
            PMax = str2num(PMax);
        end
    end
    if ~exist('Transparency','var') || isempty(Transparency)
        Transparency = 0.2;
    else
        if (isdeployed)
            Transparency = str2num(Transparency);
        end
    end
    
    
    %Mask out voxels under threshold
    BrainVolume = BrainVolume .* ((BrainVolume <= NMin) + (BrainVolume >= PMin));
    if NMax >= 0
        BrainVolume(BrainVolume<0) = 0;
    end
    if PMax <= 0
        BrainVolume(BrainVolume>0) = 0;
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
    
    %Display -- Call y_spm_orthviews, revised by YAN Chao-Gan based on SPM's spm_orthviews

    
    % Adjust the colormap to leave blank to values under threshold, the orginal color map with be set into [NMax NMin] and [PMin PMax].
    ColorMap = y_AdjustColorMap(ColorMap,[0.75 0.75 0.75],NMax,NMin,PMin,PMax);
    
    BrainHeader.Data = BrainVolume;
    
    y_spm_orthviews('Addtruecolourimage',H,BrainHeader,ColorMap,1-Transparency,PMax,NMax);
    
end

y_spm_orthviews('AddContext',1);

if ~exist('Position','var')
    y_spm_orthviews('Reposition',[0 0 0]);
else
    y_spm_orthviews('Reposition',Position);
end

y_spm_orthviews('Redraw');
