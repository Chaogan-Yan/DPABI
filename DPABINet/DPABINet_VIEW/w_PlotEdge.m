function H=w_PlotEdge(Matrix, ElementLabel, ...
    HigherOrderNetworkIndex, HigherOrderNetworkLabel,...
    ColorMap)

LineWidth=2;
LineColor=[0, 0, 0];

NumNode=size(Matrix, 1);
if ~isempty(HigherOrderNetworkIndex) && NumNode~=size(HigherOrderNetworkIndex, 1) 
    errordlg('Invalid Length of HigherOrderNetworkIndex');
end

if ~isempty(ElementLabel) && NumNode~=numel(ElementLabel) 
    errordlg('Invalid Length of HigherOrderNetworkIndex');
end

if isempty(HigherOrderNetworkIndex)
    % Draw
    H.Fig=figure;
    H.Img=imagesc(Matrix);
    H.Axe=gca;
    if isempty(ElementLabel)
        set(H.Axe, 'YTick', [], 'YTickLabel', []);
    else
        set(H.Axe, 'YTick', 1:NumNode, 'YTickLabel', ElementLabel);
    end
    set(H.Axe, 'XTick', [], 'XTickLabel', []);
else
    [HIndexSorted, e_ind]=sort(HigherOrderNetworkIndex);
    MatrixSorted=Matrix(e_ind, e_ind);
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
    YLineCoordCell=cell(numel(HIndexU)-1, 2);
    for i=1:numel(HIndexU)-1
        pos=find(HIndexSorted==HIndexU(i), 1, 'last');
        coord=pos+0.5;
        
        % X Line X(col_1) & Y(col_2) Coord
        XLineCoordCell{i, 1}=[0.5, NumNode+0.5];
        XLineCoordCell{i, 2}=[coord, coord];
        
        % Y Line X(col_1) & Y(col_2) Coord
        YLineCoordCell{i, 1}=[coord, coord];
        YLineCoordCell{i, 2}=[0.5, NumNode+0.5];
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
    H.Img=imagesc(MatrixSorted);
    H.Axe=gca;
    H.Lines=cell(numel(HIndexU), 2);
    for i=1:numel(HIndexU)-1
        H.Lines{i, 1}=line(XLineCoordCell{i, 1}, XLineCoordCell{i, 2},...
            'LineWidth', LineWidth, 'Color', LineColor);
        H.Lines{i, 2}=line(YLineCoordCell{i, 1}, YLineCoordCell{i, 2},...
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
    if isempty(HigherOrderNetworkLabel)
        set(H.Axe, 'XTick', [], 'XTickLabel', []);
    else
        set(H.Axe, 'XTick', HTick, 'XTickLabel', HLabelSorted);
    end
end

% Draw Colorbar
set(H.Fig, 'Colormap', ColorMap);
colorbar;
