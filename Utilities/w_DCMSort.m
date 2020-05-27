function w_DCMSort(DICOMCells, HierarchyValue, AnonyFlag, OutputDir)
% Format w_DCMSort(DICOMCells, HierarchyValue, AnonyFlag, OutputDir)
% Input:
%       DICOMCells     - The DICOM File from N subjects N by 1 Cells
%       HierarchyValue - SubjectID/SeriesName(1) or %SeriesName/SubjectID(2)
%       AnonyFlag      - Anonymous DICOM Output or not
%       OutputDir      - The directory of Output File
%___________________________________________________________________
% Written by Xindi Wang
% State Key Laboratory of Cognitive Neuroscience and Learning & IDG/McGovern Institute for Brain Research, Beijing Normal University
% Reference: rest_DicomSorter written by Yan Chao-Gan and Dong Zhang-Ye

for i=1:numel(DICOMCells)
    OneDICOM=DICOMCells{i};
    fprintf('Read %s etc.\n', OneDICOM{1});
    for j=1:numel(OneDICOM)
        try %YAN Chao-Gan, 200521. In case not valid dicom file.
            
            DCM_Info=dicominfo(OneDICOM{j});
            
            %YAN Chao-Gan, 200218. Remove illegal characters for file names;
            BadChar = '<|>| |:|"|/|?|*|''|\||\\';
            DCM_Info.PatientID = regexprep(DCM_Info.PatientID, BadChar, '');
            DCM_Info.PatientName.FamilyName = regexprep(DCM_Info.PatientName.FamilyName, BadChar, '');
            DCM_Info.ProtocolName = regexprep(DCM_Info.ProtocolName, BadChar, '');
            
            Index=DCM_Info.SeriesNumber;
            if ~isnumeric(Index)
                Index=str2double(Index);
            end
            if isnan(Index)
                Index=0;
            end
            
            if AnonyFlag
                DCM_Out=dicomread(OneDICOM{j});
                [Path, Name, Ext]=fileparts(OneDICOM{j});
                if ~strcmpi(Ext, '.IMA') && ~strcmpi(Ext, '.dcm')
                    Name=sprintf('%s%s', Name, Ext);
                    Ext='.dcm';
                end
                FileName=sprintf('%.6d%s', j, Ext);
                SubID=sprintf('%.8d', i);
                DCM_Info.Filename=FileName;
                DCM_Info.PatientName.FamilyName=SubID;
                DCM_Info.PatientID=SubID;
                DCM_Info.PatientBirthDate='';
                
                switch HierarchyValue
                    case 1 %SubjectID/SeriesName
                        DirName=fullfile(OutputDir, DCM_Info.PatientID,...
                            sprintf('%.4d_%s', Index, DCM_Info.ProtocolName));
                    case 2 %SeriesName/SubjectID
                        DirName=fullfile(OutputDir, sprintf('%.4d_%s', Index, DCM_Info.ProtocolName),...
                            DCM_Info.PatientID);
                    case 3 %SubjectFamilyName/SeriesName %YAN Chao-Gan, 181216. In case PatientID is not defined, use PatientName.FamilyName instead.
                        DirName=fullfile(OutputDir, DCM_Info.PatientName.FamilyName,...
                            sprintf('%.4d_%s', Index, DCM_Info.ProtocolName));
                    case 4 %SeriesName/SubjectFamilyName %YAN Chao-Gan, 181216. In case PatientID is not defined, use PatientName.FamilyName instead.
                        DirName=fullfile(OutputDir, sprintf('%.4d_%s', Index, DCM_Info.ProtocolName),...
                            DCM_Info.PatientName.FamilyName);
                end
                if exist(DirName, 'dir')~=7
                    mkdir(DirName);
                end
                
                dicomwrite(DCM_Out, fullfile(DirName, FileName), DCM_Info, 'createmode', 'copy');
            else
                switch HierarchyValue
                    case 1 %SubjectID/SeriesName
                        DirName=fullfile(OutputDir, DCM_Info.PatientID,...
                            sprintf('%.4d_%s', Index, DCM_Info.ProtocolName));
                    case 2 %SeriesName/SubjectID
                        DirName=fullfile(OutputDir, sprintf('%.4d_%s', Index, DCM_Info.ProtocolName),...
                            DCM_Info.PatientID);
                    case 3 %SubjectFamilyName/SeriesName %YAN Chao-Gan, 181216. In case PatientID is not defined, use PatientName.FamilyName instead.
                        DirName=fullfile(OutputDir, DCM_Info.PatientName.FamilyName,...
                            sprintf('%.4d_%s', Index, DCM_Info.ProtocolName));
                    case 4 %SeriesName/SubjectFamilyName %YAN Chao-Gan, 181216. In case PatientID is not defined, use PatientName.FamilyName instead.
                        DirName=fullfile(OutputDir, sprintf('%.4d_%s', Index, DCM_Info.ProtocolName),...
                            DCM_Info.PatientName.FamilyName);
                end
                
                if exist(DirName, 'dir')~=7
                    mkdir(DirName);
                end
                copyfile(OneDICOM{j}, DirName);
            end
            fprintf('\tCopy %s to %s\n', OneDICOM{j}, DirName);
        catch
            warning(['This file is not a valid DICOM file: ', OneDICOM{j}]);
        end
    end
end