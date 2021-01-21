function [CenterOfMass] = y_CenterOfMass(AtlasFile)

% Extract Center of mass.
% Input:
%   AtlasFile - the Atlas File
% Output:
%   CenterOfMass - the Altals region table
%___________________________________________________________________________
% Written by YAN Chao-Gan 120917.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com

[Data Head]=y_Read(AtlasFile);

[nDim1 nDim2 nDim3]=size(Data);

[I J K] = ndgrid(1:nDim1,1:nDim2,1:nDim3);

Element = unique(Data);
Element(1) = []; % This is the background 0
CenterOfMass = [];
for iElement=1:length(Element)
    
    ICenter = mean(I(Data==Element(iElement)));
    JCenter = mean(J(Data==Element(iElement)));
    KCenter = mean(K(Data==Element(iElement)));
    
    Center = Head.mat*[ICenter JCenter KCenter 1]';
    XCenter = Center(1);
    YCenter = Center(2);
    ZCenter = Center(3);

    CenterOfMass = [CenterOfMass;[XCenter,YCenter,ZCenter,iElement,Element(iElement),ICenter,JCenter,KCenter]];
end


