function [CenterOfMass] = y_CenterOfMass_Surf(AtlasFile, SurfFile)
% function [CenterOfMass] = y_CenterOfMass_Surf(AtlasFile, SurfFile)
% Extract Eccentric Center of mass on surface
% Input:
%   AtlasFile - the Atlas File
%   SurfFile - the Surface File
% Output:
%   CenterOfMass - the Altals region table
%___________________________________________________________________________
% Written by YAN Chao-Gan 210118.
% International Big-Data Center for Depression Research
% Magnetic Resonance Imaging Research Center
% Institute of Psychology, Chinese Academy of Sciences
% ycg.yan@gmail.com


Surf = gifti(SurfFile);
edge = spm_mesh_adjacency(Surf); 


[Data]=y_ReadAll(AtlasFile);
Element = unique(Data);
Element(1) = []; % This is the background 0
CenterOfMass = [];
for iElement=1:length(Element)

    NodeInd=find(Data==Element(iElement));
    
    edgeROI=edge(NodeInd,NodeInd);
    
    D=distance_bin(edgeROI);
    
    D(find(eye(size(D)))) = Inf; % Put the length from one node to itself to Inf
    Lpi = 1./(sum(1./D)/((size(D,1))-1));
    
    [M,I] = min(Lpi);
    
    CenterInd=NodeInd(I);

    CenterOfMass = [CenterOfMass;[Surf.vertices(CenterInd,1),Surf.vertices(CenterInd,2),Surf.vertices(CenterInd,3),iElement,Element(iElement),CenterInd]];
end




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


