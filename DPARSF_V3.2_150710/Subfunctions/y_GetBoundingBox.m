function [BoundingBoxNeg, BoundingBoxPos, VoxSize]= y_GetBoundingBox(InputFile)
% FORMAT [BoundingBoxNeg, BoundingBoxPos, VoxSize]= y_GetBoundingBox(InputFile)
% Input:
%   InputFile - input filename
% Output:
%   BoundingBoxNeg,BoundingBoxPos - image dimention
%   VoxSize -  vox size.
%___________________________________________________________________________
% Written by YAN Chao-Gan 090306.
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
% ycg.yan@gmail.com
% Revised by YAN Chao-Gan 120203.

% Read information
[Data Header]=y_Read(InputFile,1);

% Get vox size
VoxSize = sqrt(sum(Header.mat(1:3,1:3).^2));

% Get the corners in Voxel Index
Dim = Header.dim(1:3);
CornerVoxelIndex = [ 1       Dim(1)  1       Dim(1)  1       Dim(1)  1       Dim(1)
                     1       1       Dim(2)  Dim(2)  1       1       Dim(2)  Dim(2)
                     1       1       1       1       Dim(3)  Dim(3)  Dim(3)  Dim(3)
                     1       1       1       1       1       1       1       1      ];

% Get the corners in coordinates (in mm)
CornerCoordinates = Header.mat*CornerVoxelIndex;
CornerCoordinates = CornerCoordinates(1:3,:);

BoundingBoxNeg = min(CornerCoordinates,[],2);
BoundingBoxPos = max(CornerCoordinates,[],2);

BoundingBoxNeg = BoundingBoxNeg';
BoundingBoxPos = BoundingBoxPos';


