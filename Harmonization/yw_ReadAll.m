function [Data, VoxelSize, FileList, Header] = yw_ReadAll(InputName)
%function [Data, VoxelSize, FileList, Header] = y_ReadAll(InputName)
% This is a function modified based on y_ReadAll
% Only incorporate more types of files, .xlsx, .csv, .tsv, .txt 
%__________________________________________________________________________
% Written by YAN Chao-Gan 130624.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com
% Revised by YAN Chao-Gan 181204. Add GIfTI support.
% Revised by YAN Chao-Gan 200122. Add DPABINet Matrix support.
% Revised by Wang Yu-Wei 240603. Add .xlsx, .csv, .tsv, .txt 

VoxelSize=[]; %YAN Chao-Gan 181204. It would be empty when reading GIfTI files or DPABINet Matrix files

if iscell(InputName)
    if size(InputName,1)==1
        InputName=InputName';
    end
    FileList = InputName;
elseif (7==exist(InputName,'dir'))
    DirImg=dir(fullfile(InputName,'*.img'));
    if isempty(DirImg)
        DirImg=dir(fullfile(InputName,'*.nii.gz'));
    end
    if isempty(DirImg)
        DirImg=dir(fullfile(InputName,'*.nii'));
    end
    if isempty(DirImg)
        DirImg=dir(fullfile(InputName,'*.gii')); %YAN Chao-Gan 181204. Add GIfTI support.
    end
    
    if isempty(DirImg)
        DirImg=dir(fullfile(InputName,'*.mat')); %YAN Chao-Gan 210122. Add DPABINet Matrix support.
    end
    
    if isempty(DirImg)
        DirImg=dir(fullfile(InputName,'*.csv'));
    end
    if isempty(DirImg)
        DirImg=dir(fullfile(InputName,'*.xlsx'));
    end
    if isempty(DirImg)
        DirImg=dir(fullfile(InputName,'*.txt'));
    end
    
    FileList={};
    for j=1:length(DirImg)
        FileList{j,1}=fullfile(InputName,DirImg(j).name);
    end
elseif (2==exist(InputName,'file'))
    FileList={InputName};
else
    error(['The input name is not supported by yw_ReadAll: ',InputName]);
end

fprintf('\nReading images from "%s" etc.\n', FileList{1});

if length(FileList) == 0
    error(['No image file is found for: ',InputName]);
elseif length(FileList) == 1
    [Path,Name,Ext] = fileparts(FileList{1});
    if strcmpi(Ext,'.gii')  %YAN Chao-Gan 181204. Add GIfTI support.
        Header=gifti(FileList{1});
        Data=Header.cdata;
    elseif strcmpi(Ext,'.mat')  %YAN Chao-Gan 210122. Add DPABINet Matrix support.
        [Data, Header] = y_ReadMat(FileList{1});
    elseif strcmpi(Ext,'.nii') || strcmpi(Ext,'.nii.gz') %Wang Yu-Wei 240603.
        [Data, VoxelSize, Header] = y_ReadRPI(FileList{1});
    else %Wang Yu-Wei 240603
        Data = readtable(FileList{1},'ReadVariableNames', true);
        Header.name = Data.Properties.VariableNames;
        Header.tablesize = size(Data);
        if isempty(Header)
            disp('Your .xlsx/.csv/.txt file does not have variable names.');
        else
            disp('Your .xlsx/.csv/.txt file has variable names.');
        end
        Data = table2array(Data); % if error, check your data, they should all be numeric across columns
        Data = Data(:);
    end
elseif length(FileList) > 1 % A set of 3D images
    [Path,Name,Ext] = fileparts(FileList{1}); 
    if strcmpi(Ext,'.gii')  %YAN Chao-Gan 181204. Add GIfTI support.
        Header=gifti(FileList{1});
        Data=Header.cdata;
        Data = zeros([size(Data,1),length(FileList)]);
        for j=1:length(FileList)
            HeaderTemp=gifti(FileList{j});
            Data(:,j) = HeaderTemp.cdata;
        end
        
    elseif strcmpi(Ext,'.mat')  %YAN Chao-Gan 210122. Add DPABINet Matrix support.
        [Data, Header] = y_ReadMat(FileList{1});
        Data = zeros([size(Data,1),length(FileList)]);
        for j=1:length(FileList)
            Data(:,j) = y_ReadMat(FileList{j});
        end
        
    elseif strcmpi(Ext,'.nii') || strcmpi(Ext,'.nii.gz') %Wang Yu-Wei 240603
        [Data, VoxelSize, Header] = y_ReadRPI(FileList{1});
        Data = zeros([size(Data),length(FileList)]);
        
        if prod([size(Data),length(FileList),8]) < 8*1024*1024*1024 %YAN Chao-Gan 181204, increase the memory limit %1024*1024*1024 %If data is with two many volumes, then it will be converted to the format 'single'.
            for j=1:length(FileList)
                [DataTemp] = y_ReadRPI(FileList{j});
                Data(:,:,:,j) = DataTemp;
            end
        else
            Data = single(Data);
            for j=1:length(FileList)
                [DataTemp] = y_ReadRPI(FileList{j});
                Data(:,:,:,j) = single(DataTemp);
            end
        end
    else %.xlsx/.csv/.txt 06032024 wangyw
        Data = readtable(FileList{1},'ReadVariableNames', true);
        Header.name = Data.Properties.VariableNames;
        Header.tablesize = size(Data);
        
        Data = table2array(Data); % if error, check your data, they should all be numeric across columns
        Data = Data(:);
        
        Data = zeros([size(Data),length(FileList)]); % notice, when theere are multiple files, we arrange them into vectors no matter what they were originally
        for j=1:length(FileList)
             DataTemp = readtable(FileList{1},'ReadVariableNames', true);             
             %Header = Data.Properties.VariableNames;
             
             Data = [Data,DataTemp(:)];% if error, check your data, they should all be numeric across columns
        end
    end
end

