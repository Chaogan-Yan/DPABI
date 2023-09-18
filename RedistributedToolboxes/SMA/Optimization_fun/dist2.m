function Matdist = dist2(X1, X2)
%       Copyright (c) Ian T Nabney (1996-2001)

[n1, dim1] = size(X1);
[n2, dim2] = size(X2);
if dim1 ~= dim2
        error('Data dimension does not match dimension of centres')
end

Matdist = (ones(n2, 1) * sum((X1.^2)', 1))' + ...
  ones(n1, 1) * sum((X2.^2)',1) - ...
  2.*(X1*(X2'));

if any(any(Matdist<0))
  Matdist(Matdist<0) = 0;
end