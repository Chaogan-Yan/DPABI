function varargout = DPABI_RESLICE_TOOL(varargin)
% DPABI_RESLICE_TOOL MATLAB code for DPABI_RESLICE_TOOL.fig
%      DPABI_RESLICE_TOOL, by itself, creates a new DPABI_RESLICE_TOOL or raises the existing
%      singleton*.
%
%      H = DPABI_RESLICE_TOOL returns the handle to a new DPABI_RESLICE_TOOL or the handle to
%      the existing singleton*.
%
%      DPABI_RESLICE_TOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABI_RESLICE_TOOL.M with the given input arguments.
%
%      DPABI_RESLICE_TOOL('Property','Value',...) creates a new DPABI_RESLICE_TOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABI_RESLICE_TOOL_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABI_RESLICE_TOOL_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABI_RESLICE_TOOL

% Last Modified by GUIDE v2.5 07-Aug-2014 20:25:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABI_RESLICE_TOOL_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABI_RESLICE_TOOL_OutputFcn, ...
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


% --- Executes just before DPABI_RESLICE_TOOL is made visible.
function DPABI_RESLICE_TOOL_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABI_RESLICE_TOOL (see VARARGIN)

handles.ImgCells={};
handles.CurDir=pwd;

set(handles.OutputDirEntry, 'String', pwd);
% Choose default command line output for DPABI_RESLICE_TOOL
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABI_RESLICE_TOOL wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DPABI_RESLICE_TOOL_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in ImgListbox.
function ImgListbox_Callback(hObject, eventdata, handles)
% hObject    handle to ImgListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ImgListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ImgListbox


% --- Executes during object creation, after setting all properties.
function ImgListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImgListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in AddButton.
function AddButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=uigetdir(handles.CurDir, 'Pick DICOM Directory');
if isnumeric(Path)
    return
end
[handles.CurDir, Name]=fileparts(Path);

[ImgCell, Num]=GetSubNameCell(Path);

handles.ImgCells{numel(handles.ImgCells)+1}=ImgCell;
StringOne={sprintf('DIR: [%d] (%s) %s', Num, Name, Path)};
AddString(handles.ImgListbox, StringOne);
guidata(hObject, handles);

% --- Executes on button press in RemoveButton.
function RemoveButton_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.ImgListbox, 'Value');
if Value==0
    return
end
handles.ImgCells(Value)=[];
RemoveString(handles.ImgListbox, Value);
guidata(hObject, handles);

function PrefixEntry_Callback(hObject, eventdata, handles)
% hObject    handle to PrefixEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PrefixEntry as text
%        str2double(get(hObject,'String')) returns contents of PrefixEntry as a double


% --- Executes during object creation, after setting all properties.
function PrefixEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PrefixEntry (see GCBO)
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
if isempty(handles.ImgCells)
    return
end
ImgCells=handles.ImgCells;

NewVoxSize=str2num(get(handles.VoxelSizeEntry, 'String'));
InterpValue=get(handles.InterpPopup, 'Value');
InterpType=InterpValue-1; % Fixed a Bug that InterpValue cannot get the right order 


ReferValue=get(handles.ReferCheck, 'Value');
if ReferValue
    ReferFile=get(handles.ReferEntry, 'String');
    if isempty(ReferFile)
        errordlg('Invalid Reference Image');
        return
    end
else
    ReferFile='ImageItself';
end

OutputDir=get(handles.OutputDirEntry, 'String');
if isempty(OutputDir)
    OutputDir=handles.CurDir;
end

Prefix=get(handles.PrefixEntry, 'String');

for i=1:numel(ImgCells)
    Img=ImgCells{i};
    if iscell(Img)
        Path=fileparts(Img{1});
        fprintf('Reslice %s etc.\n', Path);
        for j=1:numel(Img)
            [Path, File, Ext]=fileparts(Img{j});
            fprintf('\tReslice %s\n', File);
            [ParentPath, Name]=fileparts(Path);
            OutputSubDir=fullfile(OutputDir, sprintf('%s_%s', Prefix, Name));
            if exist(OutputSubDir, 'dir')~=7
                mkdir(OutputSubDir);
            end
            OutputFile=fullfile(OutputSubDir, [File, Ext]);
            y_Reslice(Img{j}, OutputFile, NewVoxSize, InterpType, ReferFile);            
        end
    else
        fprintf('Reslice %s\n', Img);
        [Path, File, Ext]=fileparts(Img);
        OutputFile=fullfile(OutputDir, sprintf('%s_%s%s', Prefix, File, Ext));
        y_Reslice(Img, OutputFile, NewVoxSize, InterpType, ReferFile);
    end
end

% --- Executes on selection change in InterpPopup.
function InterpPopup_Callback(hObject, eventdata, handles)
% hObject    handle to InterpPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns InterpPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from InterpPopup


% --- Executes during object creation, after setting all properties.
function InterpPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InterpPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ReferCheck.
function ReferCheck_Callback(hObject, eventdata, handles)
% hObject    handle to ReferCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.ReferCheck, 'Value');
if Value
    Flag='On';
    String='';
else
    Flag='Off';
    String='Keep the original space';
end

set(handles.ReferEntry,  'Enable', Flag, 'String', String);
set(handles.ReferButton, 'Enable', Flag);
% Hint: get(hObject,'Value') returns toggle state of ReferCheck

% --------------------------------------------------------------------
function AddTable_Callback(hObject, eventdata, handles)
% hObject    handle to AddTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=uigetdir(handles.CurDir, 'Pick Image Directory');
if isnumeric(Path)
    return
end
[handles.CurDir, Name]=fileparts(Path);

[ImgCell, Num]=GetSubNameCell(Path);

handles.ImgCells{numel(handles.ImgCells)+1}=ImgCell;
StringOne={sprintf('DIR: [%d] (%s) %s', Num, Name, Path)};
AddString(handles.ImgListbox, StringOne);
guidata(hObject, handles);

% --------------------------------------------------------------------
function RemoveTable_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.ImgListbox, 'Value');
if Value==0
    return
end
handles.ImgCells(Value)=[];
RemoveString(handles.ImgListbox, Value);
guidata(hObject, handles);

% --------------------------------------------------------------------
function AddAll_Callback(hObject, eventdata, handles)
% hObject    handle to AddAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=uigetdir(handles.CurDir, 'Pick Image Parent Directory');
if isnumeric(Path)
    return
end
handles.CurDir=Path;

SubjStruct=dir(Path);
Index=cellfun(...
    @(IsDir, NotDot) IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')),...
    {SubjStruct.isdir}, {SubjStruct.name});
SubjStruct=SubjStruct(Index);
SubjName={SubjStruct.name}';
SubjPath=cellfun(@(Name) fullfile(Path, Name), SubjName,...
    'UniformOutput', false);

set(handles.ImgListbox, 'BackgroundColor', 'Green');
drawnow;
for i=1:numel(SubjPath);
    [ImgCell, Num]=GetSubNameCell(SubjPath{i});
    
    handles.ImgCells{numel(handles.ImgCells)+1}=ImgCell;
    StringOne={sprintf('DIR: [%d] (%s) %s', Num, SubjName{i}, SubjPath{i})};
    AddString(handles.ImgListbox, StringOne);
    drawnow;
end
set(handles.ImgListbox, 'BackgroundColor', 'White');
guidata(hObject, handles);

% --------------------------------------------------------------------
function RemoveAll_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.ImgListbox, 'String', '');
handles.ImgCells={};

guidata(hObject, handles);

% --------------------------------------------------------------------
function ListContext_Callback(hObject, eventdata, handles)
% hObject    handle to ListContext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function [ImgCell, Num]=GetSubNameCell(Path)
D=dir(fullfile(Path, ['*', '.img']));
if isempty(D)
    D=dir(fullfile(Path, ['*', '.nii']));
end
if isempty(D)
    D=dir(fullfile(Path, ['*', '.nii.gz']));
end

NameCell={D.name}';
Num=numel(NameCell);
ImgCell=cellfun(@(Name) fullfile(Path, Name), NameCell,...
    'UniformOutput', false);

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


function VoxelSizeEntry_Callback(hObject, eventdata, handles)
% hObject    handle to VoxelSizeEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of VoxelSizeEntry as text
%        str2double(get(hObject,'String')) returns contents of VoxelSizeEntry as a double


% --- Executes during object creation, after setting all properties.
function VoxelSizeEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VoxelSizeEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ReferEntry_Callback(hObject, eventdata, handles)
% hObject    handle to ReferEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ReferEntry as text
%        str2double(get(hObject,'String')) returns contents of ReferEntry as a double


% --- Executes during object creation, after setting all properties.
function ReferEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ReferEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ReferButton.
function ReferButton_Callback(hObject, eventdata, handles)
% hObject    handle to ReferButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[File , Path]=uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
    'Pick 3D Image File' , handles.CurDir);
if isnumeric(File)
    return;
end
ReferFile=fullfile(Path, File);
set(handles.ReferEntry, 'String', ReferFile);

% --------------------------------------------------------------------
function AddImgTable_Callback(hObject, eventdata, handles)
% hObject    handle to AddImgTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[File , Path]=uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
    'Pick Underlay File' , handles.CurDir, 'MultiSelect', 'On');
if isnumeric(File)
    return;
end

if iscell(File)
    N=numel(File);
    ImgCell=cell(1, N);
    StringCell=cell(N, 1);
    for i=1:N
        ImgFile=fullfile(Path, File{i});
        ImgCell{1, i}=ImgFile;
        StringCell{i, 1}=sprintf('IMG: (%s) %s', File{i}, ImgFile);
    end
    handles.ImgCells=[handles.ImgCells, ImgCell];
    AddString(handles.ImgListbox, StringCell);
else
    ImgFile=fullfile(Path, File);
    handles.ImgCells{numel(handles.ImgCells)+1}=ImgFile;
    StringOne={sprintf('IMG: (%s) %s', File, ImgFile)};
    AddString(handles.ImgListbox, StringOne);
end
guidata(hObject, handles);

% --- Executes on button press in AddImgButton.
function AddImgButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddImgButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[File , Path]=uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
    'Pick Underlay File' , handles.CurDir, 'MultiSelect', 'On');
if isnumeric(File)
    return;
end

if iscell(File)
    N=numel(File);
    ImgCell=cell(1, N);
    StringCell=cell(N, 1);
    for i=1:N
        ImgFile=fullfile(Path, File{i});
        ImgCell{1, i}=ImgFile;
        StringCell{i, 1}=sprintf('IMG: (%s) %s', File{i}, ImgFile);
    end
    handles.ImgCells=[handles.ImgCells, ImgCell];
    AddString(handles.ImgListbox, StringCell);
else
    ImgFile=fullfile(Path, File);
    handles.ImgCells{numel(handles.ImgCells)+1}=ImgFile;
    StringOne={sprintf('IMG: (%s) %s', File, ImgFile)};
    AddString(handles.ImgListbox, StringOne);
end
guidata(hObject, handles);
