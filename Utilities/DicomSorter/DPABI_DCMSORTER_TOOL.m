function varargout = DPABI_DCMSORTER_TOOL(varargin)
% DPABI_DCMSORTER_TOOL MATLAB code for DPABI_DCMSORTER_TOOL.fig
%      DPABI_DCMSORTER_TOOL, by itself, creates a new DPABI_DCMSORTER_TOOL or raises the existing
%      singleton*.
%
%      H = DPABI_DCMSORTER_TOOL returns the handle to a new DPABI_DCMSORTER_TOOL or the handle to
%      the existing singleton*.
%
%      DPABI_DCMSORTER_TOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABI_DCMSORTER_TOOL.M with the given input arguments.
%
%      DPABI_DCMSORTER_TOOL('Property','Value',...) creates a new DPABI_DCMSORTER_TOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABI_DCMSORTER_TOOL_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABI_DCMSORTER_TOOL_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABI_DCMSORTER_TOOL

% Last Modified by GUIDE v2.5 28-Apr-2021 15:11:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABI_DCMSORTER_TOOL_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABI_DCMSORTER_TOOL_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before DPABI_DCMSORTER_TOOL is made visible.
function DPABI_DCMSORTER_TOOL_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABI_DCMSORTER_TOOL (see VARARGIN)

handles.DICOMCells={};
handles.CurDir=pwd;
handles.cfg.OutputLayer1 = 1;
handles.cfg.OutputLayer2 = 5;
handles.cfg.IsAddDate = 0;
handles.cfg.IsAddTime = 0;
handles.cfg.IsPrefix = 0;
handles.cfg.Prefix = '';
handles.cfg.FolderIndex = 1;
handles.cfg.Demo.nChange = 0;
handles.cfg.Demo.PatientID = 'PatientID';
handles.cfg.Demo.PatientName = 'PatientName';
handles.cfg.Demo.FamilyName = 'FamilyName';
handles.cfg.Demo.GivenName = 'GivenName';
handles.cfg.Demo.ProtocolName = 'ProtocolName';
handles.cfg.Demo.SeriesDescription = 'SeriesDescription';
handles.cfg.Demo.StudyDate = 'StudyDate';
handles.cfg.Demo.StudyTime ='StudyTime';

set(handles.OutputDirEntry, 'String', pwd);
set(handles.HierarchyPopup1,'Value',handles.cfg.OutputLayer1);
set(handles.HierarchyPopup2,'Value',handles.cfg.OutputLayer2);
set(handles.checkboxAddDate,'Value',handles.cfg.IsAddDate);
set(handles.checkboxAddTime,'Value',handles.cfg.IsAddTime);
set(handles.checkboxIsPrefix,'Value',handles.cfg.IsPrefix);
set(handles.editPrefix,'Enable','off');
set(handles.pushbuttonChangeImage,'Enable','off');
set(handles.pushbuttonConvert2DPABI,'Visible','off');
% Choose default command line output for DPABI_DCMSORTER_TOOL
handles.output = hObject;


% Make UI display correct in PC and linux
if ~ismac
    if ispc
        ZoonMatrix = [1 1 1.4 1.2];  %For pc
    else
        ZoonMatrix = [1 1 1.4 1.2];  %For Linux
    end
    UISize = get(handles.figureDicomSorter,'Position');
    UISize = UISize.*ZoonMatrix;
    set(handles.figureDicomSorter,'Position',UISize);
end
movegui(handles.figureDicomSorter,'center');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABI_DCMSORTER_TOOL wait for user response (see UIRESUME)
% uiwait(handles.figureDicomSorter);


% --- Outputs from this function are returned to the command line.
function varargout = DPABI_DCMSORTER_TOOL_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in DICOMListbox.
function DICOMListbox_Callback(hObject, eventdata, handles)
% hObject    handle to DICOMListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DICOMListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DICOMListbox


% --- Executes during object creation, after setting all properties.
function DICOMListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DICOMListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AddAll.
function AddButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=uigetdir(handles.CurDir, 'Pick DICOM Directory');
if isnumeric(Path)
    return
end
[handles.CurDir, Name]=fileparts(Path);

Suffix=get(handles.SuffixEntry, 'String');
if strcmpi(Suffix, 'None')
    Suffix='';
end

if ~isempty(Suffix)
    D=dir(fullfile(Path, ['*.', Suffix]));
else
    D=dir(fullfile(Path, '*'));
    Index=cellfun(...
        @(IsDir, NotDot) ~IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')),...
        {D.isdir}, {D.name});
    D=D(Index);    
end

NameCell={D.name}';
Num=numel(NameCell);
DICOMCell=cellfun(@(Name) fullfile(Path, Name), NameCell,...
    'UniformOutput', false);
handles.DICOMCells{numel(handles.DICOMCells)+1}=DICOMCell;
StringOne={sprintf('[%d] (%s) %s', Num, Name, Path)};
AddString(handles.DICOMListbox, StringOne);
guidata(hObject, handles);

% --- Executes on button press in RemoveButton.
function RemoveButton_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.DICOMListbox, 'Value');
if Value==0
    return
end
handles.DICOMCells(Value)=[];
RemoveString(handles.DICOMListbox, Value);
guidata(hObject, handles);

function SuffixEntry_Callback(hObject, eventdata, handles)
% hObject    handle to SuffixEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SuffixEntry as text
%        str2double(get(hObject,'String')) returns contents of SuffixEntry as a double


% --- Executes during object creation, after setting all properties.
function SuffixEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SuffixEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function OutputDirEntry_Callback(hObject, eventdata, handles)
% hObject    handle to OutputDirEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OutputDirEntry as text
%        str2double(get(hObject,'String')) returns contents of OutputDirEntry as a double


% --- Executes during object creation, after setting all properties.
function OutputDirEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OutputDirEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in OutputDirButton.
function OutputDirButton_Callback(hObject, eventdata, handles)
% hObject    handle to OutputDirButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=uigetdir(handles.CurDir, 'Pick Output Directory');
if isnumeric(Path)
    return
end
handles.CurDir=fileparts(Path);
set(handles.OutputDirEntry, 'String', Path);
guidata(hObject, handles);

% --- Executes on button press in ComputeButton.
function ComputeButton_Callback(hObject, eventdata, handles)
% hObject    handle to ComputeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.DICOMCells)
    return
end

DICOMCells=handles.DICOMCells;
OutputDir=get(handles.OutputDirEntry, 'String');
if isempty(OutputDir)
    OutputDir=handles.CurDir;
end

HierarchyValue1=get(handles.HierarchyPopup1, 'Value');
HierarchyValue2=get(handles.HierarchyPopup2, 'Value');

if (HierarchyValue1 <=4 && HierarchyValue2 <=4)|| (HierarchyValue1 >= 5 && HierarchyValue2 >= 5)
    uiwait(msgbox({'The first-layer folder type is same as the second-layer folder type. Please recheck!'},...
        'Layout Check'));
    return
end

AnonyFlag=get(handles.AnonyButton, 'Value');
IsAddDate = handles.cfg.IsAddDate;
IsAddTime = handles.cfg.IsAddTime;
set(handles.ComputeButton, 'BackgroundColor', 'Red');
if handles.cfg.IsPrefix
    if ~isempty(handles.cfg.Prefix)
        Prefix = [handles.cfg.Prefix,'_'];
    else
        Prefix = '';
    end
else
    Prefix = '';
end
FolderIndex = handles.cfg.FolderIndex;
w_DCMSort(DICOMCells, HierarchyValue1, HierarchyValue2, Prefix, IsAddDate, IsAddTime, FolderIndex, AnonyFlag, OutputDir);
set(handles.ComputeButton,'Visible','off');
set(handles.pushbuttonChangeImage,'Visible','off');
set(handles.pushbuttonConvert2DPABI,'Visible','on');
fprintf('\n\tDICOM files sorting finished!\n');

% --- Executes on selection change in HierarchyPopup1.
function HierarchyPopup1_Callback(hObject, eventdata, handles)
% hObject    handle to HierarchyPopup1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ShowOutputLayout(hObject, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns HierarchyPopup1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from HierarchyPopup1


% --- Executes during object creation, after setting all properties.
function HierarchyPopup1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HierarchyPopup1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AnonyButton.
function AnonyButton_Callback(hObject, eventdata, handles)
% hObject    handle to AnonyButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AnonyButton


% --------------------------------------------------------------------
function AddTable_Callback(hObject, eventdata, handles)
% hObject    handle to AddTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=uigetdir(handles.CurDir, 'Pick DICOM Directory');
if isnumeric(Path)
    return
end
[handles.CurDir, Name]=fileparts(Path);

Suffix=get(handles.SuffixEntry, 'String');
if strcmpi(Suffix, 'None')
    Suffix='';
end

if ~isempty(Suffix)
    D=dir(fullfile(Path, ['*.', Suffix]));
else
    D=dir(fullfile(Path, '*'));
    Index=cellfun(...
        @(IsDir, NotDot) ~IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')),...
        {D.isdir}, {D.name});
    D=D(Index);    
end

NameCell={D.name}';
Num=numel(NameCell);
DICOMCell=cellfun(@(Name) fullfile(Path, Name), NameCell,...
    'UniformOutput', false);
handles.DICOMCells{numel(handles.DICOMCells)+1}=DICOMCell;
StringOne={sprintf('[%d] (%s) %s', Num, Name, Path)};
AddString(handles.DICOMListbox, StringOne);
guidata(hObject, handles);

% --------------------------------------------------------------------
function RemoveTable_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.DICOMListbox, 'Value');
if Value==0
    return
end
handles.DICOMCells(Value)=[];
RemoveString(handles.DICOMListbox, Value);
guidata(hObject, handles);

% --------------------------------------------------------------------
function AddAll_Callback(hObject, eventdata, handles)
% hObject    handle to AddAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=uigetdir(handles.CurDir, 'Pick DICOM Parent Directory');
if isnumeric(Path)
    return
end
handles.cfg.InputDir=Path;
Suffix=get(handles.SuffixEntry, 'String');

set(handles.DICOMListbox, 'BackgroundColor', 'Green');
drawnow;

%YAN Chao-Gan, 150518. Recursively add Path
SubjPath = y_GetRecursivePath(Path,[]);
%PathList = y_GetRecursivePath(InPath,PathList)

% SubjStruct=dir(Path);
% Index=cellfun(...
%     @(IsDir, NotDot) IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')),...
%     {SubjStruct.isdir}, {SubjStruct.name});
% SubjStruct=SubjStruct(Index);
% SubjName={SubjStruct.name}';
% SubjPath=cellfun(@(Name) fullfile(Path, Name), SubjName,...
%     'UniformOutput', false);


for i=1:numel(SubjPath);
    if strcmpi(Suffix, 'None')
        Suffix='';
    end
    
    if ~isempty(Suffix)
        D=dir(fullfile(SubjPath{i}, ['*.', Suffix]));
    else
        D=dir(fullfile(SubjPath{i}, '*'));
        Index=cellfun(...
            @(IsDir, NotDot) ~IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')),...
            {D.isdir}, {D.name});
        D=D(Index);    
    end

    if ~isempty(D)
        NameCell={D.name}';
        Num=numel(NameCell);
        DICOMCell=cellfun(@(Name) fullfile(SubjPath{i}, Name), NameCell,...
            'UniformOutput', false);
        handles.DICOMCells{numel(handles.DICOMCells)+1}=DICOMCell;
        StringOne={sprintf('[%d] %s', Num, SubjPath{i})};  %StringOne={sprintf('[%d] (%s) %s', Num, SubjName{i}, SubjPath{i})};
        AddString(handles.DICOMListbox, StringOne);
        drawnow;
    end
end
set(handles.DICOMListbox, 'BackgroundColor', 'White');
LoadDemoImage(hObject, handles)
handles = guidata(hObject);
ShowOutputLayout(hObject, handles)
set(handles.pushbuttonChangeImage,'Enable','on');
guidata(hObject, handles);


% --------------------------------------------------------------------
function RemoveAll_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.DICOMListbox, 'String', '');
handles.DICOMCells={};

guidata(hObject, handles);

% --------------------------------------------------------------------
function ListContext_Callback(hObject, eventdata, handles)
% hObject    handle to ListContext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function AddString(ListboxHandle, NewCell)
StringCell=get(ListboxHandle, 'String');
StringCell=[StringCell; NewCell];
set(ListboxHandle, 'String', StringCell, 'Value', numel(StringCell));

function RemoveString(ListboxHandle, Value)
StringCell=get(ListboxHandle, 'String');
StringCell(Value)=[];
if isempty(StringCell)
    Value=0;
end
if Value > numel(StringCell)
    Value=Value-1;
end
set(ListboxHandle, 'String', StringCell, 'Value', Value);


% --- Executes on selection change in HierarchyPopup2.
function HierarchyPopup2_Callback(hObject, eventdata, handles)
% hObject    handle to HierarchyPopup2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ShowOutputLayout(hObject, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns HierarchyPopup2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from HierarchyPopup2


% --- Executes during object creation, after setting all properties.
function HierarchyPopup2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HierarchyPopup2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxAddDate.
function checkboxAddDate_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxAddDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.cfg.IsAddDate = get(handles.checkboxAddDate,'Value');
ShowOutputLayout(hObject, handles)
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxAddDate


% --- Executes on button press in checkboxAddTime.
function checkboxAddTime_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxAddTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.cfg.IsAddTime = get(handles.checkboxAddTime,'Value');
ShowOutputLayout(hObject, handles)
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxAddTime


% --- Executes on button press in pushbuttonChangeImage.
function pushbuttonChangeImage_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonChangeImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
LoadDemoImage(hObject, handles)
handles = guidata(hObject);
ShowOutputLayout(hObject, handles)
guidata(hObject, handles);



function LoadDemoImage(hObject, handles)
DicomCells = handles.DICOMCells;
if isempty(DicomCells)
    return
else
    FileNum = cellfun(@(Files) length(Files),DicomCells);
    [FileNumSort,I] = sort(FileNum,'descend');
    DicomCells = DicomCells(I);
    nChange = handles.cfg.Demo.nChange;
    if nChange == 0
        Index = 1;
        try
            DcmInfo = dicominfo(DicomCells{Index}{1});
        catch
            Flag = 1;
            while Flag % Sometime even the biggist session still have non-image file
                try
                    DcmInfo = dicominfo(DicomCells{1}{randi(length(DicomCells{Index}))});
                    Flag = 0;
                catch
                end
            end
        end
    else
        Flag = 1;
        while Flag % make "change..." button work at the first click, no need to retry
            try
                iCell = randi(length(FileNumSort));
                nFile = length(DicomCells{iCell});
                iFile = randi(nFile);
                DcmInfo = dicominfo(DicomCells{iCell}{iFile});
                while strcmp(handles.cfg.Demo.PatientID,DcmInfo.PatientID) &&  strcmp(handles.cfg.Demo.FamilyName,DcmInfo.PatientName.FamilyName)
                    iCell = randi(length(FileNumSort));
                    nFile = length(DicomCells{iCell});
                    iFile = randi(nFile);
                    DcmInfo = dicominfo(DicomCells{iCell}{iFile});
                end
                Flag = 0;
            catch
            end
        end
    end
    handles.cfg.Demo.PatientID = DcmInfo.PatientID;
    handles.cfg.Demo.FamilyName = DcmInfo.PatientName.FamilyName; 
    if isfield(DcmInfo.PatientName,'GivenName') % It seems like that field 'FamilyName' always exists, but not for 'GivenName'
        handles.cfg.Demo.GivenName = DcmInfo.PatientName.GivenName;
    else
        handles.cfg.Demo.GivenName = '';
    end
    handles.cfg.Demo.PatientName = [handles.cfg.Demo.GivenName,handles.cfg.Demo.FamilyName];
    handles.cfg.Demo.ProtocolName = DcmInfo.ProtocolName;
    handles.cfg.Demo.SeriesDescription = DcmInfo.SeriesDescription;
    handles.cfg.Demo.StudyDate = DcmInfo.StudyDate;
    handles.cfg.Demo.StudyTime = DcmInfo.StudyTime;
    handles.cfg.Demo.nChange = handles.cfg.Demo.nChange+1;
    % Add [folder name] option for anonymous dicom image % BinLu 20210601
    FolderDir = strsplit(handles.cfg.InputDir,filesep);
    handles.cfg.FolderIndex = length(FolderDir)+1;
    DicomDir = strsplit(DcmInfo.Filename,filesep);
    handles.cfg.Demo.FolderName = DicomDir{handles.cfg.FolderIndex};
end
guidata(hObject, handles);

function ShowOutputLayout(hObject, handles)
LayoutString = '~OutputDir';
Layer1 = get(handles.HierarchyPopup1,'Value');
Layer2 = get(handles.HierarchyPopup2,'Value');

if handles.cfg.IsPrefix == 1
    if ~isempty(handles.cfg.Prefix)
        Prefix = [handles.cfg.Prefix,'_'];
    else
        Prefix = '';
    end
else
    Prefix = '';
end

if handles.cfg.IsAddDate==1 && handles.cfg.IsAddTime == 1 
    Suffix = ['_',handles.cfg.Demo.StudyDate,'_',handles.cfg.Demo.StudyTime];
elseif handles.cfg.IsAddDate==1 && handles.cfg.IsAddTime ==0
    Suffix = ['_',handles.cfg.Demo.StudyDate];
elseif handles.cfg.IsAddDate==0 && handles.cfg.IsAddTime ==1
    Suffix = ['_',handles.cfg.Demo.StudyTime];
else
    Suffix = '';
end

switch Layer1
    case 1 
        LayoutString = [LayoutString,filesep,Prefix,handles.cfg.Demo.PatientID,Suffix];
    case 2
        LayoutString = [LayoutString,filesep,Prefix,handles.cfg.Demo.PatientName,Suffix];
    case 3
        LayoutString = [LayoutString,filesep,Prefix,handles.cfg.Demo.FamilyName,Suffix];
    case 4
        LayoutString = [LayoutString,filesep,Prefix,handles.cfg.Demo.FolderName,Suffix];    
    case 5
        LayoutString = [LayoutString,filesep,handles.cfg.Demo.ProtocolName];
    case 6
        LayoutString = [LayoutString,filesep,handles.cfg.Demo.SeriesDescription];
end

switch Layer2
    case 1 
        LayoutString = [LayoutString,filesep,Prefix,handles.cfg.Demo.PatientID,Suffix];
    case 2
        LayoutString = [LayoutString,filesep,Prefix,handles.cfg.Demo.PatientName,Suffix];
    case 3
        LayoutString = [LayoutString,filesep,Prefix,handles.cfg.Demo.FamilyName,Suffix];
    case 4
        LayoutString = [LayoutString,filesep,Prefix,handles.cfg.Demo.FolderName,Suffix];
    case 5
        LayoutString = [LayoutString,filesep,handles.cfg.Demo.ProtocolName];
    case 6
        LayoutString = [LayoutString,filesep,handles.cfg.Demo.SeriesDescription];
end

set(handles.textOutputLayout,'String',LayoutString);


% --- Executes on button press in pushbuttonConvert2DPABI.
function pushbuttonConvert2DPABI_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonConvert2DPABI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
OutputDir=get(handles.OutputDirEntry, 'String');
if isempty(OutputDir)
    OutputDir=handles.CurDir;
end
HierarchyValue1=get(handles.HierarchyPopup1, 'Value');
DPABI_InputPreparer(OutputDir,HierarchyValue1);
% close(handle.figureDicomSorter);


% --- Executes on button press in checkboxIsPrefix.
function checkboxIsPrefix_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxIsPrefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.cfg.IsPrefix = get(handles.checkboxIsPrefix,'Value');
if handles.cfg.IsPrefix
    set(handles.editPrefix,'Enable','on');
else
    set(handles.editPrefix,'Enable','off');
end
ShowOutputLayout(hObject, handles)
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxIsPrefix



function editPrefix_Callback(hObject, eventdata, handles)
% hObject    handle to editPrefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.cfg.Prefix = get(handles.editPrefix,'String');
ShowOutputLayout(hObject, handles)
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editPrefix as text
%        str2double(get(hObject,'String')) returns contents of editPrefix as a double


% --- Executes during object creation, after setting all properties.
function editPrefix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPrefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
