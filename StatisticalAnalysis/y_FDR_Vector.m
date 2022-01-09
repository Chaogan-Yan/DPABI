function FDRMsk=y_FDR_Vector(VecP, FDRQ)
% Following  FDR.m	1.3 Tom Nichols 02/01/18
SortP=sort(VecP);
V=length(SortP);
I=(1:V)';
cVID = 1;
cVN  = sum(1./(1:V));
PThres   = SortP(find(SortP <= I/V*FDRQ/cVID, 1, 'last' ));

FDRMsk=zeros(size(VecP));
if ~isempty(PThres)
    FDRMsk(find(VecP<=PThres))=1;
else
    warndlg('There is no sample left!');
end