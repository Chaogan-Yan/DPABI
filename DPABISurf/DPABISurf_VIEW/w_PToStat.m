function StatVal=w_PToStat(P, StatOpt)
TestFlag=StatOpt.TestFlag;
if isempty(TestFlag)
    StatVal=[];
end

if isfield(StatOpt, 'Df')
    Df1=StatOpt.Df;
end
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
        StatVal=tinv(1-P/Scale, Df1);
    case 'R'
        T=tinv(1-P/Scale, Df1);
        StatVal=sqrt(T^2/(Df1+T^2));       
    case 'F'
        StatVal=finv(1-P/Scale, Df1, Df2);        
    case 'Z'
        StatVal=norminv(1-P/Scale);        
    otherwise
        error('Invalid Test Flag');
end