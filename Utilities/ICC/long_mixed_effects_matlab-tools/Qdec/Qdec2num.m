function M = Qdec2num(Qdec)
% M = Qdec2num(Qdec)
%
% Attempts to convert the two dimensional cell string array Qdec to numeric
% matrix M.
%
% Input
% Qdec: Two dimensional cell string array of Qdec data (eg. read with 
% fReadQdec).
%
% Output
% M: Numeric matrix (without the name of the variables).
%
% $Revision: 1.1.1.1 $  $Date: 2012/02/02 11:25:52 $
% Original Author: Jorge Luis Bernal Rusiel 
% CVS Revision Info:
%    $Author: jbernal$
%    $Date: 2012/02/02 11:25:52 $
%    $Revision: 1.1 $
%
Qdec = Qdec(2:end,:);
M = str2double(Qdec);
