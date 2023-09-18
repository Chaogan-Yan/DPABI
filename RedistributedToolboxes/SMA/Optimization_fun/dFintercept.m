function deriv = dFintercept(b)
global transXA XB sigma2

X1 = transXA+ones(size(transXA,1),1)*b;
X2 = XB;
n1 = size(X1,1);
n2 = size(X2,1);

D12 = dist2(X1,X2);
Matobj12=exp(-D12./(2*sigma2));

R1=repmat(X1',1,n2);
tmpR2=repmat(X2',n1,1);
R2=reshape(tmpR2,size(X2,2),[]);
vecobj12=reshape(Matobj12,1,[]);
derivtmp=vecobj12*(R1-R2)';

deriv=derivtmp./(n1*n2*sigma2);