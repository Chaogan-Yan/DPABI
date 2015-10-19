function FigNum=w_Compatible2014bFig(Fig)

FullMatlabVersion = sscanf(version,'%d.%d.%d.%d%s');
if (FullMatlabVersion(1)*1000+FullMatlabVersion(2)>=8*1000+4) && ~isnumeric(Fig)
    FigNum=Fig.Number;
    if isempty(FigNum)
        FigNum=-0.1;
    end
else
    FigNum=Fig;
end