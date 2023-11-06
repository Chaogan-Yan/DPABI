function Data = yw_ReadOrgabuzedData(InputName)

if iscell(InputName)
    if size(InputName,1)==1
        InputName=InputName';
    end
    FileList = InputName;

elseif (2==exist(InputName,'file')) % .xlsx or .mat exists
    FileList={InputName};
else
    error(['The input name is not supported by y_ReadAll: ',InputName]);
end

fprintf('\nReading organized data from "%s" etc.\n', FileList{1});

if length(FileList) == 0
    error(['No image file is found for: ',InputName]);
else
    [Path,Name,Ext] = fileparts(FileList{1});
    if strcmpi(Ext,'.xlsx')  
        Data_struct = importdata(FileList{1});
        if size(Data_struct.textdata,1) > 1
           error("All contents of the .xlsx must be numeric data.");
        end
        Data = Data_struct.data;
    elseif strcmpi(Ext,'.mat')  
        Data = importdata(FileList{1});
    else
        error('Your file is neither .xlsx nor .mat which format we are not supported for now. Please contact ycg.yan@gmail.com with your requirement.'); 
    end
end

