function varargout = DPABI_Standardization(varargin)
% DPABI_Standardization MATLAB code for DPABI_Standardization.fig
%      DPABI_Standardization, by itself, creates a new DPABI_Standardization or raises the existing
%      singleton*.
%
%      H = DPABI_Standardization returns the handle to a new DPABI_Standardization or the handle to
%      the existing singleton*.
%
%      DPABI_Standardization('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABI_Standardization.M with the given input arguments.
%
%      DPABI_Standardization('Property','Value',...) creates a new DPABI_Standardization or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABI_Standardization_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABI_Standardization_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABI_Standardization

% Last Modified by GUIDE v2.5 17-Aug-2014 02:33:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABI_Standardization_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABI_Standardization_OutputFcn, ...
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


% --- Executes just before DPABI_Standardization is made visible.
function DPABI_Standardization_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABI_Standardization (see VARARGIN)

fprintf('Standardize the brains for Statistical Analysis. \nRef: Yan, C.G., Craddock, R.C., Zuo, X.N., Zang, Y.F., Milham, M.P., 2013. Standardizing the intrinsic brain: towards robust measurement of inter-individual variation in 1000 functional connectomes. Neuroimage 80, 246-262.\n');

handles.ImgCells={};
handles.CurDir=pwd;

set(handles.OutputDirEntry, 'String', pwd);
% Choose default command line output for DPABI_Standardization
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABI_Standardization wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DPABI_Standardization_OutputFcn(hObject, eventdata, handles) 
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
if isempty(handles.ImgCells)
    return
end
ImgCells=handles.ImgCells;

MaskFile=get(handles.MaskEntry, 'String');

MethodType=get(handles.MethodPopup, 'Value');

OutputDir=get(handles.OutputDirEntry, 'String');
if isempty(OutputDir)
    OutputDir=handles.CurDir;
end

Suffix=get(handles.SuffixEntry, 'String');

[StandardizedBrain, Header] = y_Standardization(ImgCells, MaskFile, MethodType, OutputDir, Suffix);


% --- Executes on selection change in MethodPopup.
function MethodPopup_Callback(hObject, eventdata, handles)
% hObject    handle to MethodPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MethodPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MethodPopup


% --- Executes during object creation, after setting all properties.
function MethodPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MethodPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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
Path=uigetdir(handles.CurDir, 'Pick DICOM Parent Directory');
if isnumeric(Path)
    return
end
handles.CurDir=Path;
Suffix=get(handles.SuffixEntry, 'String');

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


% --------------------------------------------------------------------
function AddImgTable_Callback(hObject, eventdata, handles)
% hObject    handle to AddImgTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[File , Path]=uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
    'Pick Underlay File' , handles.CurDir);
if isnumeric(File)
    return;
end
ImgFile=fullfile(Path, File);
handles.ImgCells{numel(handles.ImgCells)+1}=ImgFile;
StringOne={sprintf('IMG: (%s) %s', File, ImgFile)};
AddString(handles.ImgListbox, StringOne);
guidata(hObject, handles);

% --- Executes on button press in AddImgButton.
function AddImgButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddImgButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[File , Path]=uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
    'Pick Underlay File' , handles.CurDir);
if isnumeric(File)
    return;
end
ImgFile=fullfile(Path, File);
handles.ImgCells{numel(handles.ImgCells)+1}=ImgFile;
StringOne={sprintf('IMG: (%s) %s', File, ImgFile)};
AddString(handles.ImgListbox, StringOne);
guidata(hObject, handles);




function editMask_Callback(hObject, eventdata, handles)
% hObject    handle to editMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMask as text
%        str2double(get(hObject,'String')) returns contents of editMask as a double


% --- Executes during object creation, after setting all properties.
function editMask_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMask (see GCBO)
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
[Name, Path]=uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';},...
    'Pick the Mask Image');
if isnumeric(Name)
    return
end
set(handles.MaskEntry, 'String', fullfile(Path, Name));


