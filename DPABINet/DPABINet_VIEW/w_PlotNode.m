function H=w_PlotNode(Vector, ElementLabel, ...
    HigherOrderNetworkIndex, HigherOrderNetworkLabel,...
    ColorMap)

LineWidth=2;
LineColor=[0, 0, 0];

NumNode=size(Vector, 1);
if ~isempty(HigherOrderNetworkIndex) && NumNode~=size(HigherOrderNetworkIndex, 1) 
    errordlg('Invalid Length of HigherOrderNetworkIndex');
end

if ~isempty(ElementLabel) && NumNode~=numel(ElementLabel) 
    errordlg('Invalid Length of HigherOrderNetworkIndex');
end

if isempty(HigherOrderNetworkIndex)
    % Draw
    H.Fig=figure;
    H.Img=imagesc(Vector);
    H.Axe=gca;
    if isempty(ElementLabel)
        set(H.Axe, 'YTick', [], 'YTickLabel', []);
    else
        set(H.Axe, 'YTick', 1:NumNode, 'YTickLabel', ElementLabel);
    end
    set(H.Axe, 'XTick', [], 'XTickLabel', []);
    
    % Draw Colorbar
    set(H.Fig, 'Colormap', ColorMap);
    H.ColorBar=colorbar('peer', H.Axe, 'location', 'SouthOutSide');    
else
    [HIndexSorted, e_ind]=sort(HigherOrderNetworkIndex);
    VectorSorted=Vector(e_ind, 1);
    if ~isempty(ElementLabel)
        ELabelSorted=ElementLabel(e_ind);
    end
    HIndexU=unique(HIndexSorted);
    
    if ~isempty(HigherOrderNetworkLabel)
        h_ind=zeros(numel(HIndexU), 1);
        
        for i=1:numel(HIndexU)
            msk=cellfun(@(x) x==HIndexU(i), HigherOrderNetworkLabel(:, 1));
            h_ind(msk)=HIndexU(i);
        end
        if any(h_ind==0)
            errordlg('Unmatched HigherOrderNetworkIndex and HigherOrderNetworkLabel');
        end
        
        HLabelSorted=HigherOrderNetworkLabel(h_ind, 2);
    end
    % Estimate Position of Lines
    XLineCoordCell=cell(numel(HIndexU)-1, 2);
    for i=1:numel(HIndexU)-1
        pos=find(HIndexSorted==HIndexU(i), 1, 'last');
        coord=pos+0.5;
        
        % X Line X(col_1) & Y(col_2) Coord
        XLineCoordCell{i, 1}=[0.5, 1+0.5];
        XLineCoordCell{i, 2}=[coord, coord];
    end
    
    % Estimate Position of HigherOrderLabel
    HTick=zeros(numel(HIndexU), 1);
    for i=1:numel(HIndexU)
        pos1=find(HIndexSorted==HIndexU(i), 1, 'first');
        pos2=find(HIndexSorted==HIndexU(i), 1, 'last');
        HTick(i, 1)=(pos1+pos2)/2;
    end
    
    % Draw
    H.Fig=figure;
    H.Img=imagesc(VectorSorted);
    H.Axe=gca;
    %Pos=get(H.Axe, 'Position');
    %Pos(1,3)=Pos(1,3)-0.2;
    %set(H.Axe, 'Position', Pos);

    H.Lines=cell(numel(HIndexU), 1);
    for i=1:numel(HIndexU)-1
        H.Lines{i, 1}=line(XLineCoordCell{i, 1}, XLineCoordCell{i, 2},...
            'LineWidth', LineWidth, 'Color', LineColor);
    end
    
    % Hide Tick
    set(H.Axe, 'TickLength', [0 0]);
    
    % Tick & Label
    if isempty(ElementLabel)
        set(H.Axe, 'YTick', [], 'YTickLabel', []);
    else
        set(H.Axe, 'YTick', 1:NumNode, 'YTickLabel', ELabelSorted);
    end
    set(H.Axe, 'XTick', [], 'XTickLabel', []);
    
    % Draw Colorbar
    set(H.Fig, 'Colormap', ColorMap);
    H.ColorBar=colorbar('peer', H.Axe, 'location', 'SouthOutSide');
    
    H.LabAxe=axes('Position', get(H.Axe, 'Position'), 'Color', 'none');
    set(H.LabAxe, 'XAxisLocation', 'top', 'YAxisLocation', 'right');
    set(H.LabAxe, 'XLim', get(H.Axe, 'XLim'), 'YLim', get(H.Axe, 'YLim'));
    set(H.LabAxe, 'XDir', get(H.Axe, 'XDir'), 'YDir', get(H.Axe, 'YDir'));
    if isempty(HigherOrderNetworkLabel)
        set(H.LabAxe, 'YTick', [], 'YTickLabel', []);
    else
        set(H.LabAxe, 'YTick', HTick, 'YTickLabel', HLabelSorted);
    end
    set(H.LabAxe, 'XTick', [], 'XTickLabel', []);
end


%AxePos=get(H.Axe, 'Position');
%AxePos(2)=AxePos(2)+0.1;
%AxePos(4)=AxePos(4)-0.1;
%set(H.Axe, 'Position', AxePos);
%set(H.LabAxe, 'Position', AxePos);