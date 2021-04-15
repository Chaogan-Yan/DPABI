function w_DCMSort(DICOMCells, HierarchyValue1, HierarchyValue2, IsAddDate, IsAddTime, AnonyFlag, OutputDir)
% Format w_DCMSort(DICOMCells, HierarchyValue, AnonyFlag, OutputDir)
% Input:
%       DICOMCells     - The DICOM File from N subjects N by 1 Cells
%       HierarchyValue1 - First layer of output directory: 1-PatientID, 2-PatientName.FamilyName, 3-ProtocolName, 4-SeriesDescription
%       HierarchyValue2 - Second layer of output directory: 1-PatientID, 2-PatientName.FamilyName, 3-ProtocolName, 4-SeriesDescription
%       IsAddDate      - Whether adding date suffix to partientID/Name
%       IsAddTime      - Whether adding time suffix to partientID/Name
%       AnonyFlag      - Anonymous DICOM Output or not
%       OutputDir      - The directory of Output File
%___________________________________________________________________
% Written by Xindi Wang
% State Key Laboratory of Cognitive Neuroscience and Learning & IDG/McGovern Institute for Brain Research, Beijing Normal University
% Reference: rest_DicomSorter written by Yan Chao-Gan and Dong Zhang-Ye
% Edited by Bin Lu for adapting more diverse situations of input

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
            DCM_Info.SeriesDescription = regexprep(DCM_Info.SeriesDescription, BadChar, '');
            DCM_Info.StudyDate = regexprep(DCM_Info.StudyDate, BadChar, '');
            DCM_Info.StudyTime = regexprep(DCM_Info.StudyTime, BadChar, '');
            
            if IsAddDate==1 && IsAddTime == 1
                Suffix = ['_',DCM_Info.StudyDate,'_',DCM_Info.StudyTime];
            elseif IsAddDate==1 && IsAddTime ==0
                Suffix = ['_',DCM_Info.StudyDate];
            elseif IsAddDate==0 && IsAddTime ==1
                Suffix = ['_',DCM_Info.StudyTime];
            else
                Suffix = '';
            end
            
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
                             
                switch HierarchyValue1
                    case 1 % PatientID
                        DirName=[OutputDir,filesep,DCM_Info.PatientID,Suffix];
                    case 2 % PatientName.FamilyName
                        DirName=[OutputDir,filesep,DCM_Info.PatientName.FamilyName,Suffix];
                    case 3 % ProtocolName 
                        DirName=[OutputDir,filesep, num2str(Index),'_',DCM_Info.ProtocolName];
                    case 4 % SeriesDescription
                        DirName=[OutputDir,filesep, num2str(Index),'_',DCM_Info.SeriesDescription];
                end
                
                switch HierarchyValue2
                    case 1 % PatientID
                        DirName=[DirName,filesep,DCM_Info.PatientID,Suffix];
                    case 2 % PatientName.FamilyName
                        DirName=[DirName,filesep,DCM_Info.PatientName.FamilyName,Suffix];
                    case 3 % ProtocolName 
                        DirName=[DirName,filesep,num2str(Index),'_',DCM_Info.ProtocolName];
                    case 4 % SeriesDescription
                        DirName=[DirName,filesep,num2str(Index),'_',DCM_Info.SeriesDescription];
                end
                
                if exist(DirName, 'dir')~=7
                    mkdir(DirName);
                end
                
                dicomwrite(DCM_Out, fullfile(DirName, FileName), DCM_Info, 'createmode', 'copy');
            else
                switch HierarchyValue1
                    case 1 % PatientID
                        DirName=[OutputDir,filesep,DCM_Info.PatientID,Suffix];
                    case 2 % PatientName.FamilyName
                        DirName=[OutputDir,filesep,DCM_Info.PatientName.FamilyName,Suffix];
                    case 3 % ProtocolName
                        DirName=[OutputDir,filesep,num2str(Index),'_',DCM_Info.ProtocolName];
                    case 4 % SeriesDescription
                        DirName=[OutputDir,filesep,num2str(Index),'_',DCM_Info.SeriesDescription];
                end
                
                switch HierarchyValue2
                    case 1 % PatientID
                        DirName=[DirName,filesep,DCM_Info.PatientID,Suffix];
                    case 2 % PatientName.FamilyName
                        DirName=[DirName,filesep,DCM_Info.PatientName.FamilyName,Suffix];
                    case 3 % ProtocolName
                        DirName=[DirName,filesep,num2str(Index),'_',DCM_Info.ProtocolName];
                    case 4 % SeriesDescription
                        DirName=[DirName,filesep,num2str(Index),'_',DCM_Info.SeriesDescription];
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