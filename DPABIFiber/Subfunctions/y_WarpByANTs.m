function y_WarpByANTs(SourceFile,OutFile,RefFile,TransformFile,Interpolation,Dimensionality,InputImageType,DefaultValue,IsFloat0,DockerName)
% FORMAT y_WarpByANTs(SourceFile,OutFile,RefFile,TransformFile,Interpolation,Dimensionality,InputImageType,DefaultValue,IsFloat0,DockerName)
% Warp a file with ANTs' antsApplyTransforms
%   SourceFile - source filename
%   OutFile    - output filename
%   RefFile    - reference file
%   TransformFile - transformFileName by ANTs
%   Interpolation - Could be: Linear; NearestNeighbor; MultiLabel[<sigma=imageSpacing>,<alpha=4.0>]; Gaussian[<sigma=imageSpacing>,<alpha=1.0>]; BSpline[<order=3>]; CosineWindowedSinc; WelchWindowedSinc; HammingWindowedSinc; LanczosWindowedSinc; GenericLabel[<interpolator=Linear>]
%                 - Default: 'Linear'
%   Dimensionality - Could be: 2; 3; 4 or []
%                  - If undefined or empty: antsWarp tries to infer the dimensionality from the input image
%   InputImageType - 0/1/2/3 means scalar/vector/tensor/time-series
%                  - Default: 0
%   DefaultValue - Default voxel value to be used with input images only. Specifies  the  voxel  value when  the  input  point  maps  outside the output domain. With tensor input images, specifies the default voxel eigenvalues.
%                  - Default: 0
%   IsFloat0   - Use 'float' instead of 'double' for computations.  value be 0
%              - If undefined or empty: not use float
%   DockerName   - What docker to be used? e.g., 'cgyan/dpabi' or 'cgyan/dpabifiber'
%                - Default: 'cgyan/dpabi'
%__________________________________________________________________________
% Written by YAN Chao-Gan 221123.
% The R-fMRI Lab, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% International Big-Data Center for Depression Research, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com


% antsApplyTransforms --default-value 0 --dimensionality 3 --float 0 --input /DPABI/Templates/HarvardOxford-sub-maxprob-thr25-2mm_YCG.nii --interpolation MultiLabel --output /data/Masks/MasksForDwi/T1Space_sub-Sub001_HarvardOxford-sub-maxprob-thr25-2mm_YCG.nii --reference-image /data/qsiprep/sub-Sub001/dwi/sub-Sub001_space-T1w_desc-preproc_dwi.nii.gz --transform /data/qsiprep/sub-Sub001/anat/sub-Sub001_from-MNI152NLin2009cAsym_to-T1w_mode-image_xfm.h5


if ~exist('Interpolation','var')
    Interpolation = 'Linear';
end
if ~exist('Dimensionality','var')
    Dimensionality = [];
end
if ~exist('InputImageType','var')
    InputImageType = 0;
end
if ~exist('DefaultValue','var')
    DefaultValue = 0;
end
if ~exist('IsFloat0','var')
    DefaultValue = [];
end
if ~exist('DockerName','var')
    DockerName = 'cgyan/dpabi';
end


%Get ready
if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
    CommandInit='';
else
    
    [SourcePath, SourceFileName, SourceExt] = fileparts(SourceFile);
    [RefPath, RefFileName, RefExt] = fileparts(RefFile);
    [TransformPath, TransformFileName, TransformExt] = fileparts(TransformFile);
    [OutPath, OutFileName, OutExt] = fileparts(OutFile);
    
    if ispc
        CommandInit=sprintf('docker run -i --rm -v %s:/SourcePath -v %s:/RefPath -v %s:/TransformPath -v %s:/OutPath %s', SourcePath, RefPath, TransformPath, OutPath, DockerName);
    else
        CommandInit=sprintf('docker run -ti --rm -v %s:/SourcePath -v %s:/RefPath -v %s:/TransformPath -v %s:/OutPath %s', SourcePath, RefPath, TransformPath, OutPath, DockerName);
    end
    
    SourceFile=['/SourcePath/',SourceFileName, SourceExt];
    RefFile=['/RefPath/',RefFileName, RefExt];
    TransformFile=['/TransformPath/',TransformFileName, TransformExt];
    OutFile=['/OutPath/',OutFileName, OutExt];
end

Command=sprintf('%s antsApplyTransforms --input %s --output %s --transform %s --reference-image %s --interpolation %s --input-image-type %g --default-value %g', CommandInit,SourceFile,OutFile,TransformFile,RefFile,Interpolation,InputImageType,DefaultValue);

if ~isempty(Dimensionality)
    Command = sprintf('%s --dimensionality %g', Command, Dimensionality);
end
if ~isempty(IsFloat0)
    Command = sprintf('%s --float %g', Command, IsFloat0);
end

system(Command);
