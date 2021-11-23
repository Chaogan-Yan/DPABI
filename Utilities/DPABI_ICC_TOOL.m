function varargout = DPABI_ICC_TOOL(varargin)
% DPABI_ICC_TOOL MATLAB code for DPABI_ICC_TOOL.fig
%      DPABI_ICC_TOOL, by itself, creates a new DPABI_ICC_TOOL or raises the existing
%      singleton*.
%
%      H = DPABI_ICC_TOOL returns the handle to a new DPABI_ICC_TOOL or the handle to
%      the existing singleton*.
%
%      DPABI_ICC_TOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABI_ICC_TOOL.M with the given input arguments.
%
%      DPABI_ICC_TOOL('Property','Value',...) creates a new DPABI_ICC_TOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABI_ICC_TOOL_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABI_ICC_TOOL_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABI_ICC_TOOL

% Last Modified by GUIDE v2.5 08-Sep-2014 15:25:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABI_ICC_TOOL_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABI_ICC_TOOL_OutputFcn, ...
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


% --- Executes just before DPABI_ICC_TOOL is made visible.
function DPABI_ICC_TOOL_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABI_ICC_TOOL (see VARARGIN)

handles.ImgCells1={};
handles.ImgCells2={};
handles.CurDir=pwd;

set(handles.OutputDirEntry, 'String', pwd);
% Choose default command line output for DPABI_ICC_TOOL
handles.output = hObject;


% Make UI display correct in PC and linux
if ~ismac
    if ispc
        ZoonMatrix = [1 1 1.4 2];  %For pc
    else
        ZoonMatrix = [1 1 1.4 2];  %For Linux
    end
    UISize = get(handles.figure1,'Position');
    UISize = UISize.*ZoonMatrix;
    set(handles.figure1,'Position',UISize);
end
movegui(handles.figure1, 'center');


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABI_ICC_TOOL wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DPABI_ICC_TOOL_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in ImgListbox1.
function ImgListbox1_Callback(hObject, eventdata, handles)
% hObject    handle to ImgListbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ImgListbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ImgListbox1


% --- Executes during object creation, after setting all properties.
function ImgListbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImgListbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in AddButton1.
function AddButton1_Callback(hObject, eventdata, handles)
% hObject    handle to AddButton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=uigetdir(handles.CurDir, 'Pick Image Directory');
if isnumeric(Path)
    return
end
[handles.CurDir, Name]=fileparts(Path);

[ImgCell, Num]=GetSubNameCell(Path);

handles.ImgCells1{numel(handles.ImgCells1)+1}=Path;
StringOne={sprintf('DIR: [%s] (%s) %s', Num, Name, Path)};
AddString(handles.ImgListbox1, StringOne);
guidata(hObject, handles);

% --- Executes on button press in RemoveButton1.
function RemoveButton1_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveButton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.ImgListbox1, 'Value');
if Value==0
    return
end
handles.ImgCells1(Value)=[];
RemoveString(handles.ImgListbox1, Value);
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
if isempty(handles.ImgCells1)
    errordlg('Cannot find Rate-1 Images');
    return
end
ImgCells1=handles.ImgCells1;

if isempty(handles.ImgCells2)
    errordlg('Cannot find Rate-2 Images');
    return
end
ImgCells2=handles.ImgCells2;

Method=get(handles.TypePopup, 'Value');

MaskFile=get(handles.MaskEntry, 'String');

OutputDir=get(handles.OutputDirEntry, 'String');
if isempty(OutputDir)
    OutputDir=handles.CurDir;
end

Prefix=get(handles.PrefixEntry, 'String');
OutputName=[Prefix]; %YAN Chao-Gan, 190109. Just use default to be compatible with gii. OutputName=[Prefix, '.nii'];

Function=which('y_ICC_Image');
if isempty(Function)
    Self=which('DPABI_ICC_TOOL.m');
    FunctionDir=fullfile(fileparts(Self), 'ICC');
    addpath(genpath(FunctionDir));
end

switch Method
    case 1 % ANOVA Model
        y_ICC_Image(ImgCells1, ImgCells2, OutputName, MaskFile);
    case 2 % Linear Mixed Models %YAN Chao-Gan, 160415. Adjusted the order. Only two models on the GUI. The 2nd one is LMM.
        y_ICC_Image_LMM(ImgCells1, ImgCells2, OutputName, MaskFile);
    case 3 % Linear Mixed Models Calling R. %YAN Chao-Gan, 171210.
        y_ICC_Image_LMM_CallR([ImgCells1, ImgCells2], OutputName, MaskFile,[],[]);
%     case 3 % Linear Mixed Models (ReML)
%         y_ICC_Image_ReML(ImgCells1, ImgCells2, OutputName, MaskFile);
end
fprintf('Done!\n');


% --- Executes on selection change in TypePopup.
function TypePopup_Callback(hObject, eventdata, handles)
% hObject    handle to TypePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TypePopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TypePopup

if get(handles.TypePopup, 'Value')==3
    uiwait(msgbox('This function is based on R, please install R and its modules first (install.packages("nlme") and install.packages("R.matlab")). Of note, Mac OS and Linux users should start matlab in terminal, thus matlab can access Rscript.','ICC'));
end



% --- Executes during object creation, after setting all properties.
function TypePopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TypePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
function AddTable1_Callback(hObject, eventdata, handles)
% hObject    handle to AddTable1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=uigetdir(handles.CurDir, 'Pick Image Directory');
if isnumeric(Path)
    return
end
[handles.CurDir, Name]=fileparts(Path);

[ImgCell, Num]=GetSubNameCell(Path);

handles.ImgCells1{numel(handles.ImgCells1)+1}=Path;
StringOne={sprintf('DIR: [%s] (%s) %s', Num, Name, Path)};
AddString(handles.ImgListbox1, StringOne);
guidata(hObject, handles);

% --------------------------------------------------------------------
function RemoveTable1_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveTable1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.ImgListbox1, 'Value');
if Value==0
    return
end
handles.ImgCells1(Value)=[];
RemoveString(handles.ImgListbox1, Value);
guidata(hObject, handles);

% --------------------------------------------------------------------
function AddAll1_Callback(hObject, eventdata, handles)
% hObject    handle to AddAll1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=uigetdir(handles.CurDir, 'Pick Image Parent Directory');
if isnumeric(Path)
    return
end
handles.CurDir=Path;
Suffix=get(handles.PrefixEntry, 'String');

SubjStruct=dir(Path);
Index=cellfun(...
    @(IsDir, NotDot) IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')),...
    {SubjStruct.isdir}, {SubjStruct.name});
SubjStruct=SubjStruct(Index);
SubjName={SubjStruct.name}';
SubjPath=cellfun(@(Name) fullfile(Path, Name), SubjName,...
    'UniformOutput', false);

set(handles.ImgListbox1, 'BackgroundColor', 'Green');
drawnow;
for i=1:numel(SubjPath);
    [ImgCell, Num]=GetSubNameCell(SubjPath{i});
    
    handles.ImgCells1{numel(handles.ImgCells1)+1}=SubjPath{i};
    StringOne={sprintf('DIR: [%s] (%s) %s', Num, SubjName{i}, SubjPath{i})};
    AddString(handles.ImgListbox1, StringOne);
    drawnow;
end
set(handles.ImgListbox1, 'BackgroundColor', 'White');
guidata(hObject, handles);

% --------------------------------------------------------------------
function RemoveAll1_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveAll1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.ImgListbox1, 'String', '');
handles.ImgCells1={};

guidata(hObject, handles);

% --------------------------------------------------------------------
function ListContext1_Callback(hObject, eventdata, handles)
% hObject    handle to ListContext1 (see GCBO)
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

if isempty(D)
    D=dir(fullfile(Path, '*.gii'));
end

if isempty(D)
    D=dir(fullfile(Path, '*.mat'));
end

NameCell={D.name}';
Num=num2str(numel(NameCell));
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

function MaskEntry_Callback(hObject, eventdata, handles)
% hObject    handle to MaskEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaskEntry as text
%        str2double(get(hObject,'String')) returns contents of MaskEntry as a double


% --- Executes during object creation, after setting all properties.
function MaskEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaskEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MaskButton.
function MaskButton_Callback(hObject, eventdata, handles)
% hObject    handle to MaskButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[File , Path]=uigetfile({'*.img;*.nii;*.nii.gz;*.gii;*.mat','Brain Image Files (*.img;*.nii;*.nii.gz;*.gii;*.mat)';'*.*', 'All Files (*.*)';},...
    'Pick Image File' , handles.CurDir);

if isnumeric(File)
    return;
end
ReferFile=fullfile(Path, File);
set(handles.MaskEntry, 'String', ReferFile);

% --------------------------------------------------------------------
function AddImgTable1_Callback(hObject, eventdata, handles)
% hObject    handle to AddImgTable1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[File , Path]=uigetfile({'*.img;*.nii;*.nii.gz;*.gii;*.mat','Brain Image Files (*.img;*.nii;*.nii.gz;*.gii;*.mat)';'*.*', 'All Files (*.*)';},...
    'Pick Image File' , handles.CurDir, 'MultiSelect', 'On');
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
    handles.ImgCells1=[handles.ImgCells1, ImgCell];
    AddString(handles.ImgListbox1, StringCell);
else
    ImgFile=fullfile(Path, File);
    handles.ImgCells1{numel(handles.ImgCells1)+1}=ImgFile;
    StringOne={sprintf('IMG: (%s) %s', File, ImgFile)};
    AddString(handles.ImgListbox1, StringOne);
end
guidata(hObject, handles);

% --- Executes on button press in AddImgButton.
function AddImgButton1_Callback(hObject, eventdata, handles)
% hObject    handle to AddImgButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[File , Path]=uigetfile({'*.img;*.nii;*.nii.gz;*.gii;*.mat','Brain Image Files (*.img;*.nii;*.nii.gz;*.gii;*.mat)';'*.*', 'All Files (*.*)';},...
    'Pick Image File' , handles.CurDir, 'MultiSelect', 'On');
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
    handles.ImgCells1=[handles.ImgCells1, ImgCell];
    AddString(handles.ImgListbox1, StringCell);
else
    ImgFile=fullfile(Path, File);
    handles.ImgCells1{numel(handles.ImgCells1)+1}=ImgFile;
    StringOne={sprintf('IMG: (%s) %s', File, ImgFile)};
    AddString(handles.ImgListbox1, StringOne);
end
guidata(hObject, handles);


% --- Executes on button press in AddImgButton2.
function AddImgButton2_Callback(hObject, eventdata, handles)
% hObject    handle to AddImgButton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[File , Path]=uigetfile({'*.img;*.nii;*.nii.gz;*.gii;*.mat','Brain Image Files (*.img;*.nii;*.nii.gz;*.gii;*.mat)';'*.*', 'All Files (*.*)';},...
    'Pick Image File' , handles.CurDir, 'MultiSelect', 'On');
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
    handles.ImgCells2=[handles.ImgCells2, ImgCell];
    AddString(handles.ImgListbox2, StringCell);
else
    ImgFile=fullfile(Path, File);
    handles.ImgCells2{numel(handles.ImgCells2)+1}=ImgFile;
    StringOne={sprintf('IMG: (%s) %s', File, ImgFile)};
    AddString(handles.ImgListbox2, StringOne);
end
guidata(hObject, handles);

% --- Executes on button press in RemoveButton2.
function RemoveButton2_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveButton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.ImgListbox2, 'Value');
if Value==0
    return
end
handles.ImgCells2(Value)=[];
RemoveString(handles.ImgListbox2, Value);
guidata(hObject, handles);

% --- Executes on button press in AddButton2.
function AddButton2_Callback(hObject, eventdata, handles)
% hObject    handle to AddButton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=uigetdir(handles.CurDir, 'Pick Image Directory');
if isnumeric(Path)
    return
end
[handles.CurDir, Name]=fileparts(Path);

[ImgCell, Num]=GetSubNameCell(Path);

handles.ImgCells2{numel(handles.ImgCells2)+1}=Path;
StringOne={sprintf('DIR: [%s] (%s) %s', Num, Name, Path)};
AddString(handles.ImgListbox2, StringOne);
guidata(hObject, handles);

% --- Executes on selection change in ImgListbox2.
function ImgListbox2_Callback(hObject, eventdata, handles)
% hObject    handle to ImgListbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ImgListbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ImgListbox2


% --- Executes during object creation, after setting all properties.
function ImgListbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImgListbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function AddTable2_Callback(hObject, eventdata, handles)
% hObject    handle to AddTable2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=uigetdir(handles.CurDir, 'Pick Image Directory');
if isnumeric(Path)
    return
end
[handles.CurDir, Name]=fileparts(Path);

[ImgCell, Num]=GetSubNameCell(Path);

handles.ImgCells2{numel(handles.ImgCells2)+1}=Path;
StringOne={sprintf('DIR: [%s] (%s) %s', Num, Name, Path)};
AddString(handles.ImgListbox2, StringOne);
guidata(hObject, handles);

% --------------------------------------------------------------------
function AddImgTable2_Callback(hObject, eventdata, handles)
% hObject    handle to AddImgTable2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[File , Path]=uigetfile({'*.img;*.nii;*.nii.gz;*.gii;*.mat','Brain Image Files (*.img;*.nii;*.nii.gz;*.gii;*.mat)';'*.*', 'All Files (*.*)';},...
    'Pick Image File' , handles.CurDir, 'MultiSelect', 'On');
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
    handles.ImgCells2=[handles.ImgCells2, ImgCell];
    AddString(handles.ImgListbox2, StringCell);
else
    ImgFile=fullfile(Path, File);
    handles.ImgCells2{numel(handles.ImgCells2)+1}=ImgFile;
    StringOne={sprintf('IMG: (%s) %s', File, ImgFile)};
    AddString(handles.ImgListbox2, StringOne);
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function RemoveTable2_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveTable2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.ImgListbox2, 'Value');
if Value==0
    return
end
handles.ImgCells2(Value)=[];
RemoveString(handles.ImgListbox2, Value);
guidata(hObject, handles);

% --------------------------------------------------------------------
function AddAll2_Callback(hObject, eventdata, handles)
% hObject    handle to AddAll2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=uigetdir(handles.CurDir, 'Pick Image Parent Directory');
if isnumeric(Path)
    return
end
handles.CurDir=Path;
Suffix=get(handles.PrefixEntry, 'String');

SubjStruct=dir(Path);
Index=cellfun(...
    @(IsDir, NotDot) IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')),...
    {SubjStruct.isdir}, {SubjStruct.name});
SubjStruct=SubjStruct(Index);
SubjName={SubjStruct.name}';
SubjPath=cellfun(@(Name) fullfile(Path, Name), SubjName,...
    'UniformOutput', false);

set(handles.ImgListbox2, 'BackgroundColor', 'Green');
drawnow;
for i=1:numel(SubjPath);
    [ImgCell, Num]=GetSubNameCell(SubjPath{i});
    
    handles.ImgCells2{numel(handles.ImgCells2)+1}=SubjPath{i};
    StringOne={sprintf('DIR: [%s] (%s) %s', Num, SubjName{i}, SubjPath{i})};
    AddString(handles.ImgListbox2, StringOne);
    drawnow;
end
set(handles.ImgListbox2, 'BackgroundColor', 'White');
guidata(hObject, handles);

% --------------------------------------------------------------------
function RemoveAll2_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveAll2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.ImgListbox2, 'String', '');
handles.ImgCells2={};

guidata(hObject, handles);

% --------------------------------------------------------------------
function ListContext2_Callback(hObject, eventdata, handles)
% hObject    handle to ListContext2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
