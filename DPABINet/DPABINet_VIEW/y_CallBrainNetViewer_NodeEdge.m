function H_BrainNet = y_CallBrainNetViewer_NodeEdge(NodeCoordinates,EdgeMatrix,EdgeThreshold,NodeWeight,IsAutoAdjustNodeWeight,NodeNetwork,NodeColorMap,NodeLabel,NetworkIndex,viewtype,SurfFileName)
% function H_BrainNet = y_CallBrainNetViewer_NodeEdge(NodeCoordinates,EdgeMatrix,EdgeThreshold,NodeWeight,NodeNetwork,NodeColorMap,NodeLabel,viewtype,SurfFileName)
% Function to call BrainNet Viewer (by Mingrui Xia) to display nodes and edges. Also can be used to scripting call BrainNet Viewer.
% Input:
%     NodeCoordinates  - 1 Node Coordinates: Number of nodes * 3
%     EdgeMatrix       - Edge Matrix: Number of nodes * Number of nodes
%     EdgeThreshold    - Edge threshold, only dispaly those above threshold
%                      - default 0
%     NodeWeight       - Node Weight: Number of nodes * 1
%                      - default: all one
%     IsAutoAdjustNodeWeight - if need to ajust the node weight for shperes
%                            - default: 1
%     NodeNetwork        - Node Network: Number of nodes * 1
%                      - default: all one
%     NodeColorMap     - The color map of nodes: Number of colors*3. For a node need to skip label, use '-' instead, i.e., NodeLabel{i,1}={{'-'}};
%                      - default: [0 1 0;0 0 1; 1 0 0];
%     NodeLabel        - Node Label: Number of nodes * 1 CELLS. 
%                      - default: no labels
%     NetworkIndex     - The index of network, will be used to plot node or edges with specific network color. E.g., [1,2,3];
%                      - default: the unique number as defined in NodeNetwork
%     viewtype     - The type of view. Could be 'FullView' (8 views), 'MediumView' (4 views), 'SagittalView', 'AxialView' or 'CoronalView'.
%                  - default: 'MediumView' (4 views)
%     SurfFileName - The File Name of brain surface. '*.nv'
%                    default: BrainMesh_ICBM152.nv in BrainNet Viewer
% Output:
%     The fatastic Brain Surface View. Thanks to Mingrui Xia's work!
%     H_BrainNet   - The figure handle of the Brain Surface View.
%___________________________________________________________________________
% Written by YAN Chao-Gan 120104.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com

% Citing Information
%msgbox('The surface view is based on Mingrui Xia''s BrainNet Viewer. Please cite BrainNet Viewer (http://www.nitrc.org/projects/bnv/) when publishing.','Citing Information');

% Call BrainNet.m and share the global variables
[H_BrainNet] = BrainNet;
global FLAG
global EC
global surf
global a
global cam



% Reading Surf Data. Referenced from Mingrui Xia's BrainNet Viewer
if ~exist('SurfFileName','var')
    [BrainNetViewerPath, fileN, extn] = fileparts(which('BrainNet.m'));
    SurfFileName=[BrainNetViewerPath,filesep,'Data',filesep,'SurfTemplate',filesep,'BrainMesh_ICBM152_smoothed.nv'];
end

if ~iscell(SurfFileName)
    SurfFileName={SurfFileName};
end

surf.vertex_number=0;
surf.coord=[];
surf.ntri=0;
surf.tri=[];

for i=1:length(SurfFileName)
    [path, fname, ext] = fileparts(SurfFileName{i});
    switch ext
        case '.nv'
            
            fid=fopen(SurfFileName{i});
            data = textscan(fid,'%f','CommentStyle','#');
            vertex_number_This = data{1}(1);
            ntri_This = data{1}(3*vertex_number_This+2);
            surf.tri= [surf.tri; double(reshape(data{1}(3*vertex_number_This+3:end),[3,ntri_This])')+double(surf.vertex_number)];
            surf.coord  = [surf.coord, reshape(data{1}(2:1+3*vertex_number_This),[3,vertex_number_This])];
            surf.ntri = surf.ntri + ntri_This;
            surf.vertex_number = surf.vertex_number + vertex_number_This;
            
            fclose(fid);

        case '.gii' % Added by Mingrui, 20170309, load gii by using gifti toolbox
            g = gifti(SurfFileName{i});
            surf.tri= [surf.tri; double(g.faces)+double(surf.vertex_number)];
            surf.vertex_number = surf.vertex_number + size(g.vertices,1);
            surf.coord  = [surf.coord, double(g.vertices')];
            surf.ntri = surf.ntri + size(g.faces,1);
    end
    surf.test='No';
end


FLAG.Loadfile=7;


if ~exist('NodeWeight','var') || isempty(NodeWeight)
    NodeWeight=ones(size(NodeCoordinates,1),1);
end

if ~exist('NodeNetwork','var') || isempty(NodeNetwork)
    NodeNetwork=sign(NodeWeight)+2;

    NodeNetworkClass=unique(NodeNetwork);
    NodeColorMap=[];
    if ismember(1,NodeNetworkClass)
        NodeColorMap=[NodeColorMap;0 0 1];
    end
    if ismember(2,NodeNetworkClass)
        NodeColorMap=[NodeColorMap;0 1 0];
    end
    if ismember(3,NodeNetworkClass)
        NodeColorMap=[NodeColorMap;1 0 0];
    end
end

if ~exist('NodeLabel','var') || isempty(NodeLabel)
    for i=1:size(NodeCoordinates,1)
        NodeLabel{i,1}={{'-'}};
    end
    EC.lbl=2; %Do not Plot node label
else
    EC.lbl=1; %Plot node label
    EC.lbl_font.FontName = 'Arial';
    EC.lbl_font.FontAngle = 'normal';
    EC.lbl_font.FontSize = 13;
    EC.lbl_font.FontUnits = 'points';
    EC.lbl_font.FontWeight = 'bold';
end

if ~exist('NetworkIndex','var') || isempty(NetworkIndex) %Added by YAN Chao-Gan 130517 to be compatible with BrainNet Viewer 1.41
    EC.nod.ModularNumber = unique(NodeNetwork);
else
    EC.nod.ModularNumber = NetworkIndex; %Added by YAN Chao-Gan 130517 to be compatible with BrainNet Viewer 1.41
end



if iscell(NodeCoordinates)
    NodeCoordinates=cell2mat(NodeCoordinates);
end
NodeCoordinates=double(NodeCoordinates);
surf.nsph=size(NodeCoordinates,1);
surf.sphere=[NodeCoordinates,NodeNetwork,abs(NodeWeight)];
surf.label=NodeLabel;

if ~exist('IsAutoAdjustNodeWeight','var') || isempty(IsAutoAdjustNodeWeight) %Added by YAN Chao-Gan 130517 to be compatible with BrainNet Viewer 1.41
    EC.nod.size = 2;
else
    if IsAutoAdjustNodeWeight
        EC.nod.size = 2;
    else
        EC.nod.size = 4;
    end
end


if ~exist('EdgeMatrix','var') || isempty(EdgeMatrix)
    EdgeMatrix=zeros(size(NodeCoordinates,1),size(NodeCoordinates,1));
end

surf.net=EdgeMatrix;

% Set up View type
if ~exist('viewtype','var') || isempty(viewtype)
    viewtype='MediumView';
end
if strcmpi(viewtype,'FullView')
    EC.lot.view=2;
elseif strcmpi(viewtype,'MediumView')
    EC.lot.view=3;
elseif strcmpi(viewtype,'SagittalView')
    EC.lot.view=1;
    EC.lot.view_direction=1;
elseif strcmpi(viewtype,'AxialView')
    EC.lot.view=1;
    EC.lot.view_direction=2;
elseif strcmpi(viewtype,'CoronalView')
    EC.lot.view=1;
    EC.lot.view_direction=3;
end


% Set up other parameters

if ~exist('EdgeThreshold','var') || isempty(EdgeThreshold)
    EC.edg.draw=1;
else
    EC.edg.draw=2; % Only dispay above Threshold
    EC.edg.draw_threshold=EdgeThreshold;
end

% Adjust Color of Pos & Neg by Sandy
EC.edg.color=3; %EC.edg.color=2;
%EC.edg.CM=jet(64);
%EC.edg.CM=[0 0 1; 1 0 0];
EC.edg.CM=[repmat([1 0 0],[32,1]);repmat([0 0 1],[32,1])];
%EC.edg.CM=[1 0 0;0 0 1];
EC.edg.draw_abs=1;
EC.edg.size_abs=1;
EC.edg.color_abs=0;  %this is a bug, color_abs==1, then not abs value
EC.edg.color_threshold=0;
% Will only get the up triangle of edge net matrix.

if ~exist('NodeNetwork','var') || isempty(NodeNetwork)
    EC.nod.CM=zeros(64,3);
    EC.nod.CM(:,2)=1; %Node in green
elseif ~exist('NodeColorMap','var') || isempty(NodeColorMap)
    EC.nod.CM=[0 1 0;0 0 1; 1 0 0];
    EC.nod.color=3;
    EC.nod.color_threshold=1;
else
    EC.nod.CM=NodeColorMap;
    EC.nod.color=3;
    EC.nod.color_threshold=0.1;
end

EC.msh.alpha=0.5;%EC.msh.alpha=0.8;
FLAG.MAP=2;
FLAG.LF=1;

% Tell Brain Net Viewer is called by REST and do not reset colormap
FLAG.IsCalledByREST=1;

% Call Brain Net Viewer ReDraw callback to refresh

set(H_BrainNet,'handlevisib','on');
BrainNet('NV_m_nm_Callback',H_BrainNet)

