function [mmd] = F(W)
global XA XB bA sigma2
%---Here, we calculate MMD of X1 and X2
X1 = (XA*W+ones(size(XA,1),1)*bA);
X2 = XB;

n1 = size(X1,1);
n2 = size(X2,1);
D12 = dist2(X1,X2);

Lii=ones(n1)./(n1^2);
Ljj=ones(n2)./(n2^2);
Lij=ones(n1,n2)./(-n1*n2);
L=[Lii Lij; Lij' Ljj];

D1 = dist2(X1,X1);
D2 = dist2(X2,X2);

Matobj11=exp(-D1./(2*sigma2));
Matobj22=exp(-D2./(2*sigma2));
Matobj12=exp(-D12./(2*sigma2));


K=[Matobj11 Matobj12; Matobj12' Matobj22];
mmd=sum(sum(K.*L));

    