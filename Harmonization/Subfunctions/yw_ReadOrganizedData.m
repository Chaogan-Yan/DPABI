function Data = yw_ReadOrganizedData(InputName)
    % deal with the InputName
    if iscell(InputName)
        FileList = reshape(InputName, [], 1);  
    elseif ischar(InputName) || isstring(InputName)
        if ~exist(InputName, 'file')
            error('yw_ReadOrganizedData:InvalidInput', 'File not found: %s', InputName);
        end
        FileList = {InputName};
    else
        error('yw_ReadOrganizedData:InvalidInput', 'Input must be a cell array of filenames or a single filename');
    end

    % check if it is empty
    if isempty(FileList)
        error('yw_ReadOrganizedData:NoFiles', 'No files found to process');
    end

    fprintf('\nReading organized data from "%s" etc.\n', FileList{1});

    % Read the file
    [~, ~, Ext] = fileparts(FileList{1});
    switch lower(Ext)
        case {'.xlsx', '.csv'}
            Data_struct = importdata(FileList{1});
            if ~isnumeric(Data_struct.data)
                error('yw_ReadOrganizedData:NonNumericData', 'All contents of the .xlsx/.csv must be numeric data');
            end
            Data = Data_struct.data;
        case '.mat'
            Data = importdata(FileList{1});
        otherwise
            error('yw_ReadOrganizedData:UnsupportedFormat', 'Unsupported file format: %s', Ext);
    end
end