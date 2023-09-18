function [Matobj12]=rbf_dot(X1,X2,deg)

D12 = dist2(X1,X2);

Matobj12=exp(-D12./(2*deg));
