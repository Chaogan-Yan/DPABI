function [Matrix] = y_WriteMat(Data,Header,OutName)
%function [Data, Header] = y_ReadMat(FileName)
% Read Mat file into 1D Data and Header. For use DPABI functions
% ------------------------------------------------------------------------
% Input:
% FileName - the path and filename of the image file (*.img, *.hdr, *.nii, *.nii.gz)
% Output:
% Data - 1D matrix by concatenating all matrices in Mat 
% Header - a structure containing Matrix information
% The elements in the structure are:
%       Header.MatrixNames  - the fieldname.
%       Header.MatrixSize   - the size of the matrix of this field.
%       Header.OtherInfo    - [optional] Other info need to save.
%___________________________________________________________________________
% Written by YAN Chao-Gan 210121.
% International Big-Data Center for Depression Research
% Magnetic Resonance Imaging Research Center
% Institute of Psychology, Chinese Academy of Sciences
% ycg.yan@gmail.com


Matrix=[];
for i=1:length(Header.MatrixNames)
    if ~isempty(Header.MatrixSize{i,1})
        eval([Header.MatrixNames{i,1},'=reshape(Data(1:',num2str(prod(Header.MatrixSize{i,1})),'),',mat2str(Header.MatrixSize{i,1}),');']);
        eval(['Matrix.',Header.MatrixNames{i,1},'=reshape(Data(1:',num2str(prod(Header.MatrixSize{i,1})),'),',mat2str(Header.MatrixSize{i,1}),');']);
        eval(['Data(1:',num2str(prod(Header.MatrixSize{i,1})),')=[];']);
    else % if this matrix is empty (this field was not a matrix before)
        eval([Header.MatrixNames{i,1},'=[];']);
        eval(['Matrix.',Header.MatrixNames{i,1},'=[];']);
    end
end


if isfield(Header,'OtherInfo')
    OtherInfoNames = fieldnames(Header.OtherInfo);
    for i=1:length(OtherInfoNames)
        eval([OtherInfoNames{i,1},'=Header.OtherInfo.',OtherInfoNames{i,1},';']);
        eval(['Matrix.',OtherInfoNames{i,1},'=Header.OtherInfo.',OtherInfoNames{i,1},';']);
    end
    Header.MatrixNames=[Header.MatrixNames;OtherInfoNames];
end


if exist('OutName','var') && ~isempty(OutName)
    MatrixNamesStr=[];
    for i=1:length(Header.MatrixNames)
        MatrixNamesStr=[MatrixNamesStr,'''',Header.MatrixNames{i,1},'''',','];
    end
    eval(['save(''',OutName,''',',MatrixNamesStr(1:end-1),');']);
end

