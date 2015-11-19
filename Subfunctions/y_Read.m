function [Data, Header] = y_Read(FileName, VolumeIndex)
%function [Data, Header] = y_Read(FileName, VolumeIndex)
% Read NIfTI file Based on SPM's nifti
% ------------------------------------------------------------------------
% Input:
% FileName - the path and filename of the image file (*.img, *.hdr, *.nii, *.nii.gz)
% VolumeIndex - the index of one volume within the 4D data to be read, can be 1,2,..., or 'all'.
%               default: 'all' - means read all volumes
% Output:
% Data - 3D or 4D matrix of image data
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
% Written by YAN Chao-Gan 130624 based on SPM's NIfTI.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com


if ~exist('VolumeIndex', 'var')
    VolumeIndex='all';
end

[pathstr, name, ext] = fileparts(FileName);

if isempty(ext)
    FileName = fullfile(pathstr,[name '.nii']);
    if ~exist(FileName,'file')
        FileName = fullfile(pathstr,[name '.hdr']);
    end
    if ~exist(FileName,'file')
        FileName = fullfile(pathstr,[name '.nii.gz']);
        [pathstr, name, ext] = fileparts(FileName);
    end
end

if ~exist(FileName,'file')
    error(['File doesn''t exist: ',fullfile(pathstr,[name ext])]);
end

FileNameWithGZ = FileName;
if strcmpi(ext,'.gz')
    gunzip(FileName);
    FileName = fullfile(pathstr,[name]);
end


Nii  = nifti(FileName);
V = spm_vol(FileName);

if(~strcmpi(VolumeIndex,'all'))
    Data = squeeze(double(Nii.dat(:,:,:,VolumeIndex)));
    Header = V(VolumeIndex);
else
    Data = double(Nii.dat);
    Header = V(1);
end
Header.fname=FileNameWithGZ;

if strcmpi(ext,'.gz')
    delete(FileName);
end
