function varargout = DPABI_DualRegression(varargin)
% DPABI_DUALREGRESSION MATLAB code for DPABI_DualRegression.fig
%      DPABI_DUALREGRESSION, by itself, creates a new DPABI_DUALREGRESSION or raises the existing
%      singleton*.
%
%      H = DPABI_DUALREGRESSION returns the handle to a new DPABI_DUALREGRESSION or the handle to
%      the existing singleton*.
%
%      DPABI_DUALREGRESSION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABI_DUALREGRESSION.M with the given input arguments.
%
%      DPABI_DUALREGRESSION('Property','Value',...) creates a new DPABI_DUALREGRESSION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABI_DualRegression_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABI_DualRegression_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABI_DualRegression

% Last Modified by GUIDE v2.5 31-Jan-2016 21:49:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABI_DualRegression_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABI_DualRegression_OutputFcn, ...
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


% --- Executes just before DPABI_DualRegression is made visible.
function DPABI_DualRegression_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABI_DualRegression (see VARARGIN)
handles.SubjString=[];

% Choose default command line output for DPABI_DualRegression
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABI_DualRegression wait for user response (see UIRESUME)
% uiwait(handles.MainFig);


% --- Outputs from this function are returned to the command line.
function varargout = DPABI_DualRegression_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function StartDirEntry_Callback(hObject, eventdata, handles)
% hObject    handle to StartDirEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GetSubjList(hObject, handles);
% Hints: get(hObject,'String') returns contents of StartDirEntry as text
%        str2double(get(hObject,'String')) returns contents of StartDirEntry as a double


% --- Executes during object creation, after setting all properties.
function StartDirEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartDirEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function WorkDirEntry_Callback(hObject, eventdata, handles)
% hObject    handle to WorkDirEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GetSubjList(hObject, handles);
% Hints: get(hObject,'String') returns contents of WorkDirEntry as text
%        str2double(get(hObject,'String')) returns contents of WorkDirEntry as a double


% --- Executes during object creation, after setting all properties.
function WorkDirEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WorkDirEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in WorkDirButton.
function WorkDirButton_Callback(hObject, eventdata, handles)
% hObject    handle to WorkDirButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=get(handles.WorkDirEntry, 'String');
if ~isdir(Path)
    Path=pwd;
end
Path=uigetdir(Path);
if ~ischar(Path)
    return
end
set(handles.WorkDirEntry, 'String', Path);

GetSubjList(hObject, handles);

% --- Executes on selection change in SubjListbox.
function SubjListbox_Callback(hObject, eventdata, handles)
% hObject    handle to SubjListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SubjListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SubjListbox


% --- Executes during object creation, after setting all properties.
function SubjListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SubjListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SeedMapEntry_Callback(hObject, eventdata, handles)
% hObject    handle to SeedMapEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SeedMapEntry as text
%        str2double(get(hObject,'String')) returns contents of SeedMapEntry as a double


% --- Executes during object creation, after setting all properties.
function SeedMapEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SeedMapEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SeedMapButtion.
function SeedMapButtion_Callback(hObject, eventdata, handles)
% hObject    handle to SeedMapButtion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function OutputDirEntry_Callback(hObject, eventdata, handles)
% hObject    handle to outputdirentry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outputdirentry as text
%        str2double(get(hObject,'String')) returns contents of outputdirentry as a double


% --- Executes during object creation, after setting all properties.
function OutputDirEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outputdirentry (see GCBO)
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
Path=get(handles.OutputDirEntry, 'String');
if ~isdir(Path)
    WorkDir=get(handles.WorkDirEntry, 'String');
    if isdir(WorkDir)
        Path=WorkDir;
    else
        Path=pwd;
    end    
end
Path=uigetdir(Path);
if ~ischar(Path)
    return
end
set(handles.OutputDirEntry, 'String', Path);

% --- Executes on button press in SeedMapButton.
function SeedMapButton_Callback(hObject, eventdata, handles)
% hObject    handle to SeedMapButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FullFile=get(handles.SeedMapEntry, 'String');
if exist(FullFile, 'file')~=2
    WorkDir=get(handles.WorkDirEntry, 'String');
    if isdir(WorkDir)
        FullFile=WorkDir;
    else
        FullFile=pwd;
    end
end

[File , Path]=uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
        'Pick Seed File' , FullFile);
if ~ischar(File)
    return
end
FullFile=fullfile(Path, File);

set(handles.SeedMapEntry, 'String', FullFile);

% --- Executes on button press in ComputeButton.
function ComputeButton_Callback(hObject, eventdata, handles)
% hObject    handle to ComputeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
WorkDir=get(handles.WorkDirEntry, 'String');
StartDir=get(handles.StartDirEntry, 'String');
SubjString=get(handles.SubjListbox, 'String');

SeedMap=get(handles.SeedMapEntry, 'String');
Mask=get(handles.MaskEntry, 'String');
OutputDir=get(handles.OutputDirEntry, 'String');

for s=1:numel(SubjString)
    FullPath=fullfile(WorkDir, StartDir, SubjString{s});
    fprintf('Running Dual Regression: %s\n', FullPath);
    OutputName=fullfile(OutputDir, ['DualRegression_', SubjString{s}, '.nii']);
    y_DualRegression(FullPath, SeedMap, OutputName, Mask);
    fprintf('Finished Dual Regression: %s\n', FullPath);    
end

function GetSubjList(hObject, handles)
%Create by Sandy to get the Subject List
WorkDir=get(handles.WorkDirEntry, 'String');
StartDir=get(handles.StartDirEntry, 'String');
FullDir=fullfile(WorkDir, StartDir);

if isempty(WorkDir) || isempty(StartDir) || ~isdir(FullDir)
    set(handles.SubjListbox, 'String', '', 'Value', 0);
    return
end

SubjStruct=dir(FullDir);
Index=cellfun(...
    @(IsDir, NotDot) IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')),...
    {SubjStruct.isdir}, {SubjStruct.name});
SubjStruct=SubjStruct(Index);
SubjString={SubjStruct(:).name}';

set(handles.SubjListbox, 'String', SubjString);
set(handles.SubjListbox, 'Value', 1);



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
FullFile=get(handles.MaskEntry, 'String');
if exist(FullFile, 'file')~=2
    WorkDir=get(handles.WorkDirEntry, 'String');
    if isdir(WorkDir)
        FullFile=WorkDir;
    else
        FullFile=pwd;
    end
end

[File , Path]=uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
        'Pick Mask File' , FullFile);
if ~ischar(File)
    return
end
FullFile=fullfile(Path, File);

set(handles.MaskEntry, 'String', FullFile);
