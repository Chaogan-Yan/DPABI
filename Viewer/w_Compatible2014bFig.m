function FigNum=w_Compatible2014bFig(Fig)

if strcmpi(version('-release'), '2014b') && ~isnumeric(Fig)
    FigNum=Fig.Number;
    if isempty(FigNum)
        FigNum=-0.1;
    end
else
    FigNum=Fig;
end