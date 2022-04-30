function P=w_StatToP(StatVal, StatOpt)
TestFlag=StatOpt.TestFlag;
if isempty(TestFlag)
    P=[];
    return
end

Df1=StatOpt.Df;
if isfield(StatOpt, 'Df2')
    Df2=StatOpt.Df2;
end

if StatOpt.TailedFlag==1
    Scale=1;
elseif StatOpt.TailedFlag==2
    Scale=2;
else
    error('Invalid Tailed Flag')
end


switch upper(TestFlag)
    case 'T'
        P=Scale*(1-tcdf(abs(StatVal), Df1));
    case 'R'
        T=sqrt(Df1*(StatVal.^2./(1-StatVal.^2))); %YAN Chao-Gan, 220422.  Change ^ to .^ and / to ./
        P=Scale*(1-tcdf(abs(T), Df1));        
    case 'F'
        P=Scale*(1-fcdf(StatVal, Df1, Df2));
    case 'Z'
        P=Scale*(1-normcdf(abs(StatVal)));
    otherwise
        error('Invalid Test Flag');
end