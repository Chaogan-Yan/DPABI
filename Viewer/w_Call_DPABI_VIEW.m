function H = w_Call_DPABI_VIEW(BrainVolume,NMin,PMin,ClusterSize,ConnectivityCriterion,UnderlayFileName,ColorMap,NMax,PMax,H,Transparency,Position,BrainHeader)
% function H = w_Call_DPABI_VIEW(BrainVolume,NMin,PMin,ClusterSize,ConnectivityCriterion,UnderlayFileName,ColorMap,NMax,PMax,BrainHeader)
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
% Written by Wang Xin-di 131204. Modified based on y_Call_spm_orthview.m
% sandywang.rest@gmail.com

%Init
global st

if ~exist('H','var')
    curfig=DPABI_VIEW;
else
    curfig=H;
end
Handle=guidata(curfig);

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
    UnderlayHeader.Data = zeros(UnderlayHeader);
end

Handle.UnderlayFileName=UnderlayFileName;
set(Handle.UnderlayEntry, 'String', UnderlayFileName);
Num=get(Handle.TemplatePopup, 'String');
set(Handle.TemplatePopup, 'Value', length(Num));

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
            BrainFilename=Nii.fname;
            Vox=diag(Nii.mat);
            Vox=abs(Vox(1:3));
        else
            BrainFilename=BrainVolume;
            [BrainVolume Vox BrainHeader] = y_ReadRPI(BrainVolume);
        end
    end
    BrainHeader=w_ExtendHeader(BrainHeader);
    BrainHeader.Raw=BrainVolume;
    BrainHeader.Vox=Vox;
    
    [Path, Name, Ext]=fileparts(BrainFilename);
    if isempty(Path)
        Path=pwd;
    end
    BrainFilename=fullfile(Path, [Name, Ext]);
    BrainHeader.fname=BrainFilename;
    
    % Set up colormap and negative max, negative min, positive min, positive max values
    if ~exist('ColorMap','var')
        ColorMap = y_AFNI_ColorMap(12);
        BrainHeader.cbarstring='12';
    else
        BrainHeader.cbarstring='0';
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
    if ~exist('Transparency','var')
        Transparency = 0.2;
    else
        if (isdeployed)
            Transparency = str2num(Transparency);
        end
    end
    st{curfig}.Transparency=Transparency;
    
    BrainHeader.PMax = PMax;
    BrainHeader.PMin = PMin;
    BrainHeader.NMin = NMin;
    BrainHeader.NMax = NMax;
    
    BrainHeader.curTP=1;
    BrainHeader.numTP=1;
    BrainHeader.IsSelected=1;
    
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
        BrainHeader.CSize=ClusterSize*prod(Vox);
        
        if ~exist('ConnectivityCriterion','var')
            ConnectivityCriterion = 18;
        else
            if (isdeployed)
                ConnectivityCriterion = str2num(ConnectivityCriterion);
            end
        end
        BrainHeader.RMM=ConnectivityCriterion;
        
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
    
    Handle.OverlayHeaders{1}=BrainHeader;
    Handle.OverlayFileName{1}=BrainFilename;
    set(Handle.OverlayEntry, 'Enable', 'On');
    BrainString=get(Handle.OverlayEntry, 'String');
    BrainString=[BrainString; {sprintf('%s (%s)', [Name, Ext], Path)}];
    set(Handle.OverlayEntry, 'String', BrainString);
    set(Handle.OverlayEntry, 'Value', 2);
    set(Handle.OverlayLabel, 'Value', 1);
    
    y_spm_orthviews('Addtruecolourimage',H,BrainHeader,ColorMap,1-Transparency,PMax,NMax);    
end

y_spm_orthviews('AddContext',1);

if ~exist('Position','var')
    y_spm_orthviews('Reposition',[0 0 0]);
else
    y_spm_orthviews('Reposition',Position);
end

y_spm_orthviews('Redraw');
guidata(curfig, Handle);