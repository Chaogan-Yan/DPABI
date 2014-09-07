function Vars = getQdecVars(Qdec)
% Vars = getQdecVars(Qdec)
%
% Returns a one dimensional cell string array with the name of the variables
% in Qdec.
%
% Input
% Qdec: Two dimensional cell string array of Qdec data.
%
% Output
% Vars: One dimensional cell string array.
%
% $Revision: 1.1.1.1 $  $Date: 2012/02/02 11:25:52 $
% Original Author: Jorge Luis Bernal Rusiel 
% CVS Revision Info:
%    $Author: jbernal$
%    $Date: 2012/02/02 11:25:52 $
%    $Revision: 1.1 $
%
Vars = Qdec(1,:)';