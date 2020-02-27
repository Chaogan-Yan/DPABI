function y_Call_DPABISurf_VIEW_FromVolume(BrainFile,OutputName,NMin,PMin,Mask,Mask_Rule,ClusterSize,ConnectivityCriterion,Space,SurfUnderlay,ColorMap,NMax,PMax)
% function y_Call_DPABISurf_VIEW_FromVolume(BrainFile,OutputName,NMin,PMin,Mask,Mask_Rule,ClusterSize,ConnectivityCriterion,Space,SurfUnderlay,ColorMap,NMax,PMax)
% Function to DPABISurf_VIEW to show volume based images.
% Input:
%     BrainFile    - the File Name of a Brain Image, e.g. '/home/T.img'
%     OutputName   - the File Name for output files
%     NMin         - The negative minimum (minimum in absolute value). Could be the negative threshold
%                  - default: calculate from BrainVolume
%     PMin         - The positive minimum. Could be the positive threshold
%                  - default: calculate from BrainVolume
%     Mask         - The mask file for surface. Can also be the TFCE p map.
%     Mask_Rule    - The rule of appying mask file. Can be '' or '<0.05' (for TFCE p map).
%     ClusterSize  - Set a cluster (voxel number) must be no less than the specified Cluster Size.
%                  - default: 0
%     ConnectivityCriterion - Set Connectivity Criterion, could be: 1) 6 - six neighboring voxels (surface connected)? 2) 18 - eighteen neighboring voxels (edge connected, SPM use this criterion); 3) 26 - twenty-six neighboring voxels (corner connected).
%                  - default: 18
%     Space        - can be 'fsaverage' or 'fsaverage5'. Can be ignored if SurfUnderlay was defined
%                    default: 'fsaverage'
%     SurfUnderlay - The cell which contains two names of underlay surface files, the fisrt name is the left hemisphere while the second is the right hemisphere.
%     ColorMap     - The color map. Should be m by 3 color array.
%                  - default: AFNI_ColorMap 12 segments
%     NMax         - The negative maximum (maximum in absolute value)
%                  - default: calculate from BrainVolume
%     PMax         - The maximum
%                  - default: calculate from BrainVolume
% Output:
%     The fatastic Brain Surface View by DPABISurf_VIEW!
%___________________________________________________________________________
% Written by YAN Chao-Gan 20200227. 
% The R-fMRI Lab, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% International Big-Data Center for Depression Research, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com

if ~exist('Mask','var')
    Mask=[];
end

if ~exist('Mask_Rule','var')
    Mask_Rule=[];
end

% Define Space
if ~exist('Space','var')
    Space='fsaverage';
end

% Reading Volume Data. If it is still a file name, then read it.
[BrainVolume Vox BrainHeader]=y_ReadRPI(BrainFile);

% Define SurfUnderlay
if ~exist('SurfUnderlay','var')
    DPABISurfPath=fileparts(which('DPABISurf.m'));
    SurfUnderlay={fullfile(DPABISurfPath,'SurfTemplates',[Space,'_lh_inflated.surf.gii']);fullfile(DPABISurfPath,'SurfTemplates',[Space,'_rh_inflated.surf.gii'])};
end

% Set up colormap and negative max, negative min, positive min, positive max values
if ~exist('ColorMap','var')
    ColorMap = y_AFNI_ColorMap(12);
end

if ~exist('NMax','var')
    NMax = min(BrainVolume(:));
end
if ~exist('NMin','var')
    NMin = max(BrainVolume(BrainVolume<0));
end
if ~exist('PMin','var')
    PMin = min(BrainVolume(BrainVolume>0));
end
if ~exist('PMax','var')
    PMax = max(BrainVolume(:));
end


% Deal with mask
if ~isempty(Mask)
    if ~isempty(Mask_Rule) %Apply rule. e.g., '<0.025'
        [Mask_Data,~,~,Header] = y_ReadAll(Mask);
        eval(['Mask_Data=Mask_Data',Mask_Rule,';']);
        [pathstr, name, ext] = fileparts(Mask);
        Mask = fullfile(pathstr,[name,'_Mask.nii']);
        y_Write(Mask_Data,Header,Mask);
    end
elseif exist('ClusterSize','var')
    if ~exist('ConnectivityCriterion','var')
        ConnectivityCriterion = 18;
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
    [pathstr, name, ext] = fileparts(OutputName);
    Mask = fullfile(pathstr,[name,'_Overlay_Mask.nii']);
    y_Write(double(logical(BrainVolume)),BrainHeader,Mask);
end

[pathstr, name, ext] = fileparts(OutputName);
y_Vol2Surf(BrainFile,fullfile(pathstr,[name,'_Surf.gii']),1,Space);
SurfOverlay={fullfile(pathstr,[name,'_Surf_lh.gii']);fullfile(pathstr,[name,'_Surf_rh.gii'])};

if ~isempty(Mask)
    y_Vol2Surf(Mask,fullfile(pathstr,[name,'_Overlay_Mask.gii']),0,Space);
    Surf_Mask={fullfile(pathstr,[name,'_Overlay_Mask_lh.gii']);fullfile(pathstr,[name,'_Overlay_Mask_rh.gii'])};
else
    Surf_Mask={[];[]};
end

if ~isempty(pathstr)
    cd(pathstr)
end
Surf_Mask_Rule=[];
%y_Call_DPABISurf_VIEW(SurfUnderlay,SurfOverlay,Flag_LR, N_Min,P_Min,Surf_Mask,Surf_Mask_Rule,ColorMap,N_Max,P_Max)
y_Call_DPABISurf_VIEW(SurfUnderlay{1},SurfOverlay{1},'L', NMin,PMin,Surf_Mask{1},Surf_Mask_Rule,ColorMap,NMax,PMax);
close(gcf)
y_Call_DPABISurf_VIEW(SurfUnderlay{2},SurfOverlay{2},'R', NMin,PMin,Surf_Mask{2},Surf_Mask_Rule,ColorMap,NMax,PMax);
close(gcf)

LR=cat(2,imread([name,'_Surf_lh_Montage.jpg']),imread([name,'_Surf_rh_Montage.jpg']));
imwrite(LR,fullfile(pathstr,[name,'_SurfaceMap.jpg']))
h=figure;
imshow(LR);

