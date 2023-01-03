function [ROICenter,XYZCenter,VertexCenter] = y_ExtractCenterOfMass_Surf(ROIDef, OutputName, IsMultipleLabel, ROISelectedIndex, SurfFile)             
% function [ROICenter,XYZCenter,VertexCenter] = y_ExtractCenterOfMass_Surf(ROIDef, OutputName, IsMultipleLabel, ROISelectedIndex, SurfFile)             
% Extract the ROI Center of Mass for Surf
% Input:
%   ROIDef          -   ROI definition, cells. Each cell could be:
%                       -1. mask martrix (nDimVertex*1)
%                       -2. Series matrix (DimTimePoints*1)
%                       -3. .gii mask file
%                       -4. .txt Series. If multiple columns, when IsMultipleLabel==1: each column is a seperate seed series
%                                                             when IsMultipleLabel==0: average all the columns and take the mean series (one column) as seed series
%	OutputName  	-	Output filename
%   IsMultipleLabel -   1: There are multiple labels in the ROI mask file. Will extract each of them. (e.g., for fsaverage5_lh_HCP-MMP1.label.gii, extract all the time series for each region)
%                       0 (default): All the non-zero values will be used to define the only ROI
%   ROISelectedIndex -  Only extract ROIs defined by ROISelectedIndex. Empty means extract all non-zero ROIs.
%   SurfFile        -   The surface file
% Output:
%	ROICenter       -   The ROI Center of Mass
%	XYZCenter       -   The ROI Center of Mass for XYZ
%	VertexCenter    -   The ROI Center of Mass for vertex
%   The ROI Center of Mass will be output as where OutputName specified.
%___________________________________________________________________________
% Written by YAN Chao-Gan 210119.
% International Big-Data Center for Depression Research
% Magnetic Resonance Imaging Research Center
% Institute of Psychology, Chinese Academy of Sciences
% ycg.yan@gmail.com

if ~exist('IsMultipleLabel','var')
    IsMultipleLabel = 0;
end

if ~exist('ROISelectedIndex','var')
    ROISelectedIndex = [];
end

theElapsedTime =cputime;
fprintf('\n\t Extracting ROI Center Of Mass...');

Surf = gifti(SurfFile);
edge = spm_mesh_adjacency(Surf); 
nDimVertex=size(Surf.vertices,1);

XYZCenter=[];
VertexCenter=[];

for iROI=1:length(ROIDef)
    IsDefinedCenter =0;
    if strcmpi(int2str(size(ROIDef{iROI})),int2str([nDimVertex 1]))  %ROI Data
        MaskROI = ROIDef{iROI};

%     elseif size(ROIDef{iROI},1) == nDimTimePoints %Seed series
%         XYZCenter=[XYZCenter;[0 0 0]];
%         VertexCenter=[VertexCenter;0];
%         IsDefinedCenter=1;
    elseif exist(ROIDef{iROI},'file')==2	% Make sure the Definition file exist
        [pathstr, name, ext] = fileparts(ROIDef{iROI});
        if strcmpi(ext, '.txt'),
            TextSeries = load(ROIDef{iROI});
            if IsMultipleLabel == 1
                XYZCenter=[XYZCenter;repmat([0 0 0],[size(TextSeries,2) 1])];
                VertexCenter=[VertexCenter;repmat([0],[size(TextSeries,2) 1])];
            else
                XYZCenter=[XYZCenter;[0 0 0]];
                VertexCenter=[VertexCenter;0];
            end
            IsDefinedCenter =1;

        elseif strcmpi(ext, '.gii')
            %The ROI definition is a mask file
            
            MaskROI=gifti(ROIDef{iROI});
            MaskROI=MaskROI.cdata;
            if ~strcmpi(int2str(size(MaskROI)),int2str([nDimVertex 1]))
                error(sprintf('\n\tMask does not match.\n\tMask size is %dx%d, not same with required size %dx%d',size(MaskROI), [nDimVertex 1]));
            end

        else
            error(sprintf('Wrong ROI file type, please check: \n%s', ROIDef{iROI}));
        end
        
    else
        error(sprintf('File doesn''t exist or wrong ROI definition, please check: %s.\n', ROIDef{iROI}));
    end

    if ~IsDefinedCenter

        if IsMultipleLabel == 1

            if ~isempty(ROISelectedIndex) && ~isempty(ROISelectedIndex{iROI})
                Element=ROISelectedIndex{iROI};
            else
                Element = unique(MaskROI);
                Element(find(isnan(Element))) = []; % ignore background if encoded as nan. Suggested by Dr. Martin Dyrba
                Element(find(Element==0)) = []; % This is the background 0
            end

            for iElement=1:length(Element)
                NodeInd=find(MaskROI==Element(iElement));
                edgeROI=edge(NodeInd,NodeInd);
                D=distance_bin(edgeROI);
                D(find(eye(size(D)))) = Inf; % Put the length from one node to itself to Inf
                Lpi = 1./(sum(1./D)/((size(D,1))-1));
                [M,I] = min(Lpi);
                CenterInd=NodeInd(I);
                XYZCenter=[XYZCenter;Surf.vertices(CenterInd,1:3)];
                VertexCenter=[VertexCenter;CenterInd];
            end

        else
            NodeInd=find(MaskROI~=0);
            edgeROI=edge(NodeInd,NodeInd);
            D=distance_bin(edgeROI);
            D(find(eye(size(D)))) = Inf; % Put the length from one node to itself to Inf
            Lpi = 1./(sum(1./D)/((size(D,1))-1));
            [M,I] = min(Lpi);
            CenterInd=NodeInd(I);
            XYZCenter=[XYZCenter;Surf.vertices(CenterInd,1:3)];
            VertexCenter=[VertexCenter;CenterInd];
        end
    end
end


ROICenter=[XYZCenter,VertexCenter];

if exist('OutputName','var') && ~isempty(OutputName)
    save(OutputName, 'ROICenter');
end

theElapsedTime = cputime - theElapsedTime;
fprintf('\n\t Extracting ROI Center of Mass finished, elapsed time: %g seconds.\n', theElapsedTime);






function D=distance_bin(A)
%DISTANCE_BIN       Distance matrix
%
%   D = distance_bin(A);
%
%   The distance matrix contains lengths of shortest paths between all
%   pairs of nodes. An entry (u,v) represents the length of shortest path 
%   from node u to node v. The average shortest path length is the 
%   characteristic path length of the network.
%
%   Input:      A,      binary directed/undirected connection matrix
%
%   Output:     D,      distance matrix
%
%   Notes: 
%       Lengths between disconnected nodes are set to Inf.
%       Lengths on the main diagonal are set to 0.
%
%   Algorithm: Algebraic shortest paths.
%
%
%   Mika Rubinov, U Cambridge
%   Jonathan Clayden, UCL
%   2007-2013

% Modification history:
% 2007: Original (MR)
% 2013: Bug fix, enforce zero distance for self-connections (JC)

A=double(A~=0);                 %binarize and convert to double format

l=1;                            %path length
Lpath=A;                        %matrix of paths l
D=A;                            %distance matrix

Idx=true;
while any(Idx(:))
    l=l+1;
    Lpath=Lpath*A;
    Idx=(Lpath~=0)&(D==0);
    D(Idx)=l;
end

D(~D)=inf;                      %assign inf to disconnected nodes
D(1:length(A)+1:end)=0;         %clear diagonal



