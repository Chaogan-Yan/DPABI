function [pvalue] = mmdTestBoot(X1,X2,shufflenum,fvalue)
global sigma2
n1=size(X1,1);
n2=size(X2,1);
D1 = rbf_dot(X1,X1,sigma2);
D2 = rbf_dot(X2,X2,sigma2);
D12 = rbf_dot(X1,X2,sigma2);
Kz = [D1 D12; D12' D2];

MMDboot = zeros(shufflenum,1);
for bootnum=1:shufflenum    
    [~,indShuff] = sort(rand(n1+n2,1));
    KzShuff = Kz(indShuff,indShuff);
    D1 = KzShuff(1:n1,1:n1);
    D2 = KzShuff((n1+1):(n1+n2),(n1+1):(n1+n2));
    D12 = KzShuff(1:n1,(n1+1):(n1+n2));    
    MMDboot(bootnum) = 1/(n1^2)*sum(D1(:))+1/(n2^2)*sum(D2(:))-2/(n1*n2)*sum(D12(:));    
end 

MMDboot = sort(MMDboot);
pvalue=sum(MMDboot>fvalue)/shufflenum;


% for bootnum=1:shufflenum
%     n1 = size(X1,1);
%     n2 = size(X2,1);
%     [~,indShuff] = sort(rand(n1+n2,1));
%     Xtotal = [X1;X2];
%     Xtotal = Xtotal(indShuff,:);
%     Xshf1 = Xtotal(1:n1,:);
%     Xshf2 = Xtotal((n1+1):(n1+n2),:);
%     [slope,intercept,~] = fitMMD(Xshf1,Xshf2,0);
%     Xshf1 = Xshf1.*slope+intercept;
%     D1 = rbf_dot(Xshf1,Xshf1,sigma2);
%     D2 = rbf_dot(Xshf2,Xshf2,sigma2);
%     D12 = rbf_dot(Xshf1,Xshf2,sigma2);
%     MMDboot(bootnum) = 1/(n1^2)*sum(D1(:))+1/(n2^2)*sum(D2(:))-2/(n1*n2)*sum(D12(:));
% end
