function [Data, VoxelSize, FileList, Header] = y_ReadAll(InputName)
%function [Data, VoxelSize, FileList, Header] = y_ReadAll(InputName)
% Read NIfTI files in all kinds of input formats.
% Will call y_ReadRPI.m, which reads a single file.
% ------------------------------------------------------------------------
% Input:
% InputName - Could be the following format:
%                  1. A single file (.img/hdr, .nii, or .nii.gz), give the path and filename.
%                  2. A directory, under which could be a single 4D file, or a set of 3D images
%                  3. A Cell (nFile * 1 cells) of filenames of 3D image file, or a single file of 4D NIfTI file.
% Output:
% Data - 4D matrix of image data. (If there is no rotation in affine matrix, then will be transformed into RPI orientation).
% VoxelSize - the voxel size
% FileList - the list of files
% Header - a structure containing image volume information (as defined by SPM, see spm_vol.m)
% The elements in the structure are:
%       Header.fname - the filename of the image.
%       Header.dim   - the x, y and z dimensions of the volume
%       Header.dt    - A 1x2 array.  First element is datatype (see spm_type).
%                 The second is 1 or 0 depending on the endian-ness.
%       Header.mat   - a 4x4 affine transformation matrix mapping from
%                 voxel coordinates to real world coordinates.
%       Header.pinfo - plane info for each plane of the volume.
%              Header.pinfo(1,:) - scale for each plane
%              Header.pinfo(2,:) - offset for each plane
%                 The true voxel intensities of the jth image are given
%                 by: val*Header.pinfo(1,j) + Header.pinfo(2,j)
%              Header.pinfo(3,:) - offset into image (in bytes).
%                 If the size of pinfo is 3x1, then the volume is assumed
%                 to be contiguous and each plane has the same scalefactor
%                 and offset.
%__________________________________________________________________________
% Written by YAN Chao-Gan 130624.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com

if iscell(InputName)
    if size(InputName,1)==1
        InputName=InputName';
    end
    FileList = InputName;
elseif (7==exist(InputName,'dir'))
    DirImg=dir(fullfile(InputName,'*.img'));
    if isempty(DirImg)
        DirImg=dir(fullfile(InputName,'*.nii.gz'));
    end
    if isempty(DirImg)
        DirImg=dir(fullfile(InputName,'*.nii'));
    end
    
    FileList={};
    for j=1:length(DirImg)
        FileList{j,1}=fullfile(InputName,DirImg(j).name);
    end
elseif (2==exist(InputName,'file'))
    FileList={InputName};
else
    error(['The input name is not supported by y_ReadAll: ',InputName]);
end

fprintf('\nReading images from "%s" etc.\n', FileList{1});

if length(FileList) == 0
    error(['No image file is found for: ',InputName]);
elseif length(FileList) == 1
    [Data, VoxelSize, Header] = y_ReadRPI(FileList{1});
elseif length(FileList) > 1 % A set of 3D images
    [Data, VoxelSize, Header] = y_ReadRPI(FileList{1});
    Data = zeros([size(Data),length(FileList)]);
    
    if prod([size(Data),length(FileList),8]) < 1024*1024*1024 %If data is with two many volumes, then it will be converted to the format 'single'.
        for j=1:length(FileList)
            [DataTemp] = y_ReadRPI(FileList{j});
            Data(:,:,:,j) = DataTemp;
        end
    else
        Data = single(Data);
        for j=1:length(FileList)
            [DataTemp] = y_ReadRPI(FileList{j});
            Data(:,:,:,j) = single(DataTemp);
        end
    end
end

