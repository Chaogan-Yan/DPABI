function y_Write(Data,Header,OutName)
% Write NIfTI file (3D or 4D) Based on SPM's nifti
% %------------------------------------------------------------------------
% Write data (Data) with a specified header (Header) into a image file with format 
% of Nifti 1.1. The data (Data) should be 3D or 4D matrix, the header (Header) should 
% be a structure the same as SPM. If the filename (OutName) is with 
% extra name as '.img', then it will generate two files (header and
% data seperately), or else, '.nii', it will generate single file with
% header and data together.
%
% Usage: y_Write(Data,Header,OutName)
%
% Input:
% 1. Data -  Data of 4D matrix to write
% 2. Header - a structure containing image volume information, the structure
%    is the same with a structure have read
%    The elements in the structure are:
%       Header.fname - the filename of the image. If the filename is not set, 
%                    just use the parameter.
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
%              The scale and intercept will be changed according to the
%              data to write
% 3. OutName - the path and filename of image file to output [path\*.img or *.nii]
% ------------------------------------------------------------------------
% Written by YAN Chao-Gan 120301. Based on SPM's nifti.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com


[Path,Name,Ext] = fileparts(OutName);
if isempty(Ext)
    OutName=[OutName,'.nii'];
end

dat = file_array;
dat.fname = OutName;
dat.dim   = size(Data);
if isfield(Header,'dt')
    dat.dtype  = Header.dt(1);
else % If data type is defined by the nifti command
    dat.dtype  = Header.dat.dtype;
end

dat.offset  = ceil(348/8)*8;

NIfTIObject = nifti;
NIfTIObject.dat=dat;
NIfTIObject.mat=Header.mat;
NIfTIObject.mat0 = Header.mat;
NIfTIObject.descrip = Header.descrip;

if (isfield(Header,'private'))
    try
        NIfTIObject.mat_intent=Header.private.mat_intent;
        NIfTIObject.mat0_intent=Header.private.mat0_intent;
        NIfTIObject.timing=Header.private.timing;
    catch
    end
end


create(NIfTIObject);
dat(:,:,:,:)=Data;
