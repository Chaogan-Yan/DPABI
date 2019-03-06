function writeMz3(filename, face, vertex,vertexColors,alpha)
%function writeNv(vertex,faces,filename)
% --- save Face/Vertex data as Surfice MZ3 format file
%inputs:
% vertex: Vx3 array with X,Y,Z coordinates of each vertex
% vertexColors: Vx0 (empty), Vx1 (scalar) or Vx3 (RGB) colors for each vertex
% face: Vx3 triangle list indexed from 1, e.g. 1,2,3 is triangle connecting first 3 vertices
% filename: name to save object
% alpha: (optional) if provided, sets transparency of vertex colors, range 0..1
%Example
% [f,v,c] = fileUtils.ply.readPly('stroke.ply');
% fileUtils.mz3.writeMz3('stroke.mz3',f,v,c)
%MZ3 format specifications:
%  Faces indexed from 0: a triangle of the first 3 vertices is  0,1,2
%  Always LITTLE endian: endian can be determined by reading signature
%  Optionally: may be GZ compressed (two detect: first two bytes are signature, GZip = 0x1f8B, raw = 0x4D5A )
% HEADER: first 32 bytes
%  bytes : type : notes
%  0-1: UINT16 : MAGIC signature hex = 0x4D5A integer = 23117, ASCII = 'MZ'
%  2-3: UINT16 : ATTR attributes bitfield reporting stored data (value larger than 15 indicates future version):
%        bitand(ATTR,1) = 1 : isFACE File includes FACE indices
%        bitand(ATTR,2) = 2 : isVERT File includes VERT vertices
%        bitand(ATTR,4) = 4 : isRGBA File includes RGBA values (one per vertex)
%        bitand(ATTR,8) = 8 : isSCALAR File includes SCALAR values (one per vertex)
%  4-7: UINT32 : NFACE number of faces (one face per triangle)
%  8-11: UINT32 : NVERT number of vertices
%  12-15: UINT32 : NSKIP bytes to skip (0 for current version)
% The header is 16+NSKIP bytes long
% Note: for better compression integer data is transposed (interleaved)
%  FACE DATA: if isFACE, next 12*NFACE bytes
%   +0..3: INT32 : 1st index of 1st triangle
%   +0..3: INT32 : 1st index of 2nd triangle
%   +0..3: INT32 : 1st index of 3rd triangle
%    ....
%   ++     INT32 : 3rd index of NVERT triangle
%  VERTEX DATA: if isVERT, next 12*NVERT bytes
%   +0..3: FLOAT32 : X of first vertex
%   +4..7: FLOAT32 : Y of first vertex
%   +8..11: FLOAT32 : Z of first vertex
%   +12..15: FLOAT32 : X of second vertex
%    ....
%   ++     INT32 : Z of NVERT triangle
%  RGBA DATA: if isRGBA next 4*NVERT bytes
%   +0: UINT8: red for first vertex
%   +1: UINT8: red for 2nd vertex
%   +2: UINT8: red for 3rd vertex
%   ...
%   ++     UINT8 : blue for NVERT vertex
%  SCALAR DATA: if isSCALAR next 4*NVERT bytes
%   +0..3: FLOAT32: intensity for first vertex
%   +4..7: FLOAT32: intensity for 2nd vertex
%   +8..11: FLOAT32: intensity for 3rd vertex
%   ...
%   ++     FLOAT32 : intensity for NVERT vertex


if ~exist('vertexColors','var'), vertexColors = []; end;
if isempty(vertex) && isempty(vertexColors) && isempty(face), return; end;
if isempty(face)
    nFace = 0;
else
    nFace = size(face,1);
end
isFace = (nFace > 0);
if isempty(vertex)
    nVert = 0;
else
    nVert = size(vertex,1);
end
isVert = (nVert > 0);
isRGBA = false;
if ~isempty(vertexColors) && (size(vertexColors,2) == 3)
    isRGBA = true;
    if (nVert > 0) && (size(vertexColors,1) ~= nVert), error('Number of vertices and colors must match');  end;
    nVert = size(vertexColors,1);

end
isScalar = false;
if ~isempty(vertexColors) && (size(vertexColors,2) == 1)
    isScalar = true;
    if (nVert > 0) && (size(vertexColors,1) ~= nVert), error('Number of vertices and colors must match');  end;
    nVert = size(vertexColors,1);
end
[fid,Msg] = fopen(filename,'Wb', 'l');
if fid == -1, error(Msg); end;
%write header
attr = 0;
if isFace, attr = attr + 1; end;
if isVert, attr = attr + 2; end;
if isRGBA, attr = attr + 4; end;
if isScalar, attr = attr + 8; end;
fwrite(fid, 23117, 'uint16'); %MAGIC SIG to catch ftp conversion errors http://en.wikipedia.org/wiki/Portable_Network_Graphics
fwrite(fid, attr, 'uint16'); %attr = ATTRIBUTES
fwrite(fid, nFace, 'uint32'); %nFace
fwrite(fid, nVert, 'uint32'); %nVert
fwrite(fid, 0, 'uint32'); %nSkip - bytes to skip
if isFace
    face = face - 1; %this format indexes from 0
    fwrite(fid,face','int32'); %triangle indices
end
if isVert
    fwrite(fid,vertex','float32'); %vertex coordinates
end;
if isRGBA
    if ~exist('alpha','var'), alpha = 1.0; end;
    a = ones(size(vertexColors,1),1) * alpha;
    vertexColors = [vertexColors, a] * 255; %save 0..255
    fwrite(fid,vertexColors','uint8'); %vertex coordinates
end;
if isScalar
    fwrite(fid,vertexColors,'float32'); %vertex coordinates
end
fclose(fid);
%compress data
% system(sprintf('/Users/rorden/Downloads/zopfli-master/zopfli -i100 %s', filename));
% system(sprintf('gzip -9 %s', filename));
 gzip(filename); %compress
% delete(filename); %delete uncompressed
movefile([filename '.gz'], filename); %rename
%end writeMz3()