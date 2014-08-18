function [Header] = w_ReadDF(Header)
%function [Header] = w_ReadDF(Header)
% Read image header to get DF 
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
%       Header.TestFlag  - The kind of test, if cannot read Flag=[]
%       Header.Df    - Degree of freedom, if cannot read, Df=0
%       Header.Df2   - Degree of freedom2, for F-test. if cannot read, DF=0
%__________________________________________________________________________
% Written by Wang Xin-di, 20131028.
% sandywang.rest@gmail.com

if isstruct(Header)   %For single header
    Header.TestFlag=[];
    Header.Df  = 0;
    Header.Df2 = 0;
    if ~isfield(Header, 'descrip')
        return
    end
    
    Info=Header.descrip;
    [Flag, Df, Df2]=FindDf(Info);
    Header.TestFlag=Flag;
    Header.Df  =Df;
    Header.Df2 =Df2;
elseif iscell %For multi-header
    for i=1:numel(Header)
        Header{i}=w_ReadDF(Header{i});
    end
else
    error('struct or cell');
end

function [Flag, Df, Df2] = FindDf(Info)
Flag='';
Df  = 0;
Df2 = 0;
tok=regexp(Info, '\{([TRFZ])_\[(\d*\.*\d*)[ _-,:;]*?(\d*\.*\d*)\]\}',...
    'tokens');
if isempty(tok) || numel(tok)~=1
    return;
end 
Flag=tok{1}{1};

if isempty(tok{1}{2})
    return;
end
Df=str2double(tok{1}{2});

if isempty(tok{1}{3})
    return;
end
Df2=str2double(tok{1}{3});
