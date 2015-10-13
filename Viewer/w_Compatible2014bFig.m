function FigNum=w_Compatible2014bFig(Fig)

if strcmpi(version('-release'), '2014b') && ~isnumeric(Fig)
    FigNum=Fig.Number;
else
    FigNum=Fig;
end