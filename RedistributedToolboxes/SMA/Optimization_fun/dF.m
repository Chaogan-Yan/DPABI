function deriv = dF(W)
global XA XB bA sigma2

X1 = XA;
X2 = XB-repmat(bA,size(XB,1),1);
n1 = size(X1,1);
n2 = size(X2,1);

D12 = dist2(X1*W,X2);
D1 = dist2(X1*W,X1*W);

Matobj11=exp(-D1./(2*sigma2));
Matobj12=exp(-D12./(2*sigma2));

R1=repmat(X1',1,n1);
J1tmp=repmat(X1',n1,1);
J1=reshape(J1tmp,size(X1,2),[]);
vecobj11=reshape(Matobj11,1,[]);
Alpha1=repmat(vecobj11,size(X1,2),1);
deriv1=((R1-J1).*Alpha1*(R1-J1)')*W;

R1=repmat(X1',1,n2);
R2tmp=repmat(X2',n1,1);
R2=reshape(R2tmp,size(X2,2),[]);
vecobj12=reshape(Matobj12,1,[]);
Alpha12=repmat(vecobj12,size(X1,2),1);
deriv12=2*(R1.*Alpha12*(W'*R1-R2)');

deriv=deriv12./(n1*n2*sigma2)-deriv1./(n1^2*sigma2);
