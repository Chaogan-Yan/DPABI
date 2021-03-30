function [Data, Header] = y_ReadMat(FileName,MatrixNames)
%function [Data, Header] = y_ReadMat(FileName,MatrixNames)
% Read Mat file into 1D Data and Header. For using DPABI functions
% ------------------------------------------------------------------------
% Input:
% FileName - the path and filename of the image file (*.img, *.hdr, *.nii, *.nii.gz)
%          - Or can be a struct with the matrices
% Output:
% Data - 1D matrix by concatenating all matrices in Mat 
% Header - a structure containing Matrix information
% The elements in the structure are:
%       Header.MatrixNames  - the matrix names.
%       Header.MatrixSize   - the size of the matrices.
%___________________________________________________________________________
% Written by YAN Chao-Gan 210121.
% International Big-Data Center for Depression Research
% Magnetic Resonance Imaging Research Center
% Institute of Psychology, Chinese Academy of Sciences
% ycg.yan@gmail.com

if ischar(FileName)
    Mat=load(FileName);
else
    Mat=FileName;
end

if ~exist('MatrixNames','var') || isempty(MatrixNames)
    MatrixNames = fieldnames(Mat);
end

Data=[];
for i=1:length(MatrixNames)
    eval(['MatrixTemp=Mat.',MatrixNames{i},';']);
    if isnumeric(MatrixTemp)
        Data=[Data;MatrixTemp(:)];
        Header.MatrixSize{i,1}=size(MatrixTemp);
    else  %this field was not a matrix
        Header.MatrixSize{i,1}=[];
    end
end

Header.MatrixNames=MatrixNames;