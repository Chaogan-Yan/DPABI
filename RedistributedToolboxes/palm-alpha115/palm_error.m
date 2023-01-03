function palm_error(ME)
% Print error messages somewhat similarly as it would
% natively in Octave or Matlab, but does not necessarily
% crash the calling function, such that PALM can exit
% cleanly even if there are errors.
%
% Usage:
% palm_error(ME)
%
% - ME : MException object (or a struct with
%        similar fields).
% 
% _____________________________________
% Anderson M. Winkler
% NIH/NIMH
% Mar/2018
% http://brainder.org

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% PALM -- Permutation Analysis of Linear Models
% Copyright (C) 2015 Anderson M. Winkler
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

fprintf('Error using %s (%s:%d)\n', ...
    ME.stack(1).name, ME.stack(1).file, ME.stack(1).line);
fprintf('%s\n\n', ME.message);
for s = 2:numel(ME.stack)
    fprintf('Error in %s (%s:%d->%s)\n', ...
        ME.stack(s).name, ME.stack(s).file, ME.stack(s).line, ME.stack(s-1).name);
end
