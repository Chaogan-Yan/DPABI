function [Header] = w_ReadDLH(Header)
%function [Header] = w_ReadDLH(Header)
% Read image header to get dLh and FWHM(x,y,z)
% ------------------------------------------------------------------------
% Input:
% Header - The Header of image data, use y_Read.m to get it.
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
%
% Output:
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
%       Header.dLh  - The kind of test, if cannot read Flag=[]
%       Header.FWHMx   - The voxel size for x of FWHM
%       Header.FWHMy   - The voxel size for y of FWHM
%       Header.FWHMz   - The voxel size for z of FWHM
%__________________________________________________________________________
% Written by Wang Xin-di, 20131028.
% sandywang.rest@gmail.com

if isstruct(Header)   %For single header
    Header.dLh = 0;
    Header.FWHMx = 0;
    Header.FWHMy = 0;
    Header.FWHMz = 0;
    if ~isfield(Header, 'descrip')
        return
    end
    
    Info=Header.descrip;
    [dLh, FWHMx, FWHMy, FWHMz]=FindDLH(Info);
    Header.dLh = dLh;
    Header.FWHMx = FWHMx;
    Header.FWHMy = FWHMy;
    Header.FWHMz = FWHMz;
elseif iscell %For multi-header
    for i=1:numel(Header)
        Header{i}=w_ReadDF(Header{i});
    end
else
    error('struct or cell');
end

function [dLh, FWHMx, FWHMy, FWHMz] = FindDLH(Info)
dLh=0;
FWHMx=0;
FWHMy=0;
FWHMz=0;

tok=regexp(Info, '\{dLh_(.*?)\}\{FWHMx_(.*?)FWHMy_(.*?)FWHMz_(.*?)mm\}',...
    'tokens');
if isempty(tok) || numel(tok)~=1
    return;
end 
dLh=str2double(tok{1}{1});

if isempty(tok{1}{2})
    return;
end
FWHMx=str2double(tok{1}{2});

if isempty(tok{1}{3})
    return;
end
FWHMy=str2double(tok{1}{3});

if isempty(tok{1}{4})
    return;
end
FWHMz=str2double(tok{1}{4});