function [Data, VoxelSize, FileList, Header] = y_ReadAll(InputName)
%function [Data, VoxelSize, FileList, Header] = y_ReadAll(InputName)
% Read NIfTI or GIfTI files or DPABINet Matrix files in all kinds of input formats.
% ------------------------------------------------------------------------
% Input:
% InputName - Could be the following format:
%                  1. A single file (.img/hdr, .nii, .nii.gz, .gii, or .mat), give the path and filename.
%                  2. A directory, under which could be 1) for NIfTI: a single 4D file, or a set of 3D images 
%                                                       2) for GIfTI: a single 2D file, or a set of 1D images
%                                                       3) for DPABINet Matrix: a set of .mat matrix files
%                  3. A Cell (nFile * 1 cells) of filenames of 1) for NIfTI: 3D image file, or a single file of 4D NIfTI file.
%                                                              2) for GIfTI: 1D image file, or a single file of 2D GIfTI file.
%                                                              3) for DPABINet Matrix: a .mat matrix file
% Output:
% Data - 1) for NIfTI: 4D matrix of image data. (If there is no rotation in affine matrix, then will be transformed into RPI orientation).
%      - 2) for GIfTI: 2D matrix of image data. 
%      - 3) for DPABINet Matrix: 2D matrix of all matrices. 
% VoxelSize - the voxel size. It would be empty when reading GIfTI files or DPABINet Matrix files
% FileList - the list of files
% Header - 1. or NIfTI: 
% a structure containing image volume information (as defined by SPM, see spm_vol.m)
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
% Header - 2. or GIfTI: 
% a structure containing GIfTI information (as defined by SPM, see gifti.m)
% Header - 3. or DPABINet Matrix: 
% a structure containing DPABINet Matrix information: Header.MatrixNames and Header.MatrixSize
%       Header.MatrixNames  - the matrix names.
%       Header.MatrixSize   - the size of the matrices.
%__________________________________________________________________________
% Written by YAN Chao-Gan 130624.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com
% Revised by YAN Chao-Gan 181204. Add GIfTI support.
% Revised by YAN Chao-Gan 200122. Add DPABINet Matrix support.

VoxelSize=[]; %YAN Chao-Gan 181204. It would be empty when reading GIfTI files or DPABINet Matrix files

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
    if isempty(DirImg)
        DirImg=dir(fullfile(InputName,'*.gii')); %YAN Chao-Gan 181204. Add GIfTI support.
    end
    
    if isempty(DirImg)
        DirImg=dir(fullfile(InputName,'*.mat')); %YAN Chao-Gan 210122. Add DPABINet Matrix support.
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
    [Path,Name,Ext] = fileparts(FileList{1});
    if strcmpi(Ext,'.gii')  %YAN Chao-Gan 181204. Add GIfTI support.
        Header=gifti(FileList{1});
        Data=Header.cdata;
    elseif strcmpi(Ext,'.mat')  %YAN Chao-Gan 210122. Add DPABINet Matrix support.
        [Data, Header] = y_ReadMat(FileList{1});
    else
        [Data, VoxelSize, Header] = y_ReadRPI(FileList{1});
    end
elseif length(FileList) > 1 % A set of 3D images
    [Path,Name,Ext] = fileparts(FileList{1});
    if strcmpi(Ext,'.gii')  %YAN Chao-Gan 181204. Add GIfTI support.
        Header=gifti(FileList{1});
        Data=Header.cdata;
        Data = zeros([size(Data,1),length(FileList)]);
        for j=1:length(FileList)
            HeaderTemp=gifti(FileList{j});
            Data(:,j) = HeaderTemp.cdata;
        end
        
    elseif strcmpi(Ext,'.mat')  %YAN Chao-Gan 210122. Add DPABINet Matrix support.
        [Data, Header] = y_ReadMat(FileList{1});
        Data = zeros([size(Data,1),length(FileList)]);
        for j=1:length(FileList)
            Data(:,j) = y_ReadMat(FileList{j});
        end
        
    else
        [Data, VoxelSize, Header] = y_ReadRPI(FileList{1});
        Data = zeros([size(Data),length(FileList)]);
        
        if prod([size(Data),length(FileList),8]) < 8*1024*1024*1024 %YAN Chao-Gan 181204, increase the memory limit %1024*1024*1024 %If data is with two many volumes, then it will be converted to the format 'single'.
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
end

