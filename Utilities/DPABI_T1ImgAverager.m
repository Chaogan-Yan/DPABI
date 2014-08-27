function varargout = DPABI_T1ImgAverager(varargin)
% DPABI_T1ImgAverager MATLAB code for DPABI_T1ImgAverager.fig
%      DPABI_T1ImgAverager, by itself, creates a new DPABI_T1ImgAverager or raises the existing
%      singleton*.
%
%      H = DPABI_T1ImgAverager returns the handle to a new DPABI_T1ImgAverager or the handle to
%      the existing singleton*.
%
%      DPABI_T1ImgAverager('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABI_T1ImgAverager.M with the given input arguments.
%
%      DPABI_T1ImgAverager('Property','Value',...) creates a new DPABI_T1ImgAverager or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABI_T1ImgAverager_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABI_T1ImgAverager_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABI_T1ImgAverager

% Last Modified by GUIDE v2.5 27-Aug-2014 13:20:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABI_T1ImgAverager_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABI_T1ImgAverager_OutputFcn, ...
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


% --- Executes just before DPABI_T1ImgAverager is made visible.
function DPABI_T1ImgAverager_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABI_T1ImgAverager (see VARARGIN)
handles.SubjString=[];
% Choose default command line output for DPABI_T1ImgAverager
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABI_T1ImgAverager wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DPABI_T1ImgAverager_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



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


% --- Executes on selection change in StartDirEntry.
function TypePopup_Callback(hObject, eventdata, handles)
% hObject    handle to StartDirEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns StartDirEntry contents as cell array
%        contents{get(hObject,'Value')} returns selected item from StartDirEntry


% --- Executes during object creation, after setting all properties.
function TypePopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartDirEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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


% --- Executes on button press in ComputeButton.
function ComputeButton_Callback(hObject, eventdata, handles)
% hObject    handle to ComputeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Cfg.DataProcessDir=get(handles.WorkDirEntry, 'String');
Cfg.SubjectID=get(handles.SubjListbox, 'String');
Cfg.IsCalMeanT1Image=1;
Cfg.IsNeedConvertT1DCM2IMG = get(handles.StartDirEntry, 'Value')==1;
y_T1ImgAverager(Cfg);

% --- Executes on button press in CustomButton.
function CustomButton_Callback(hObject, eventdata, handles)
% hObject    handle to CustomButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.CustomButton, 'Value');
if Value
    handles.SubjString=get(handles.SubjListbox, 'String');
else
    handles.SubjString=[];
end
guidata(hObject, handles);
GetSubjList(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of CustomButton


% --- Executes on button press in LoadSubjButton.
function LoadSubjButton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadSubjButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PDir=get(handles.WorkDirEntry, 'String');
[File , Path]=uigetfile({'*.txt;*.tsv','Subject List Files (*.txt;*.tsv)';'*.*', 'All Files (*.*)';}, ...
    'Save All Clusters' , PDir);
if isnumeric(File)
    return
end

fd=fopen(fullfile(Path, File));
if fd==-1
    error('Invalid File');
end

M=textscan(fd, '%s', 'delimiter', '\t');
fclose(fd);

SubjString=M{1};
handles.SubjString=SubjString;
guidata(hObject, handles);
GetSubjList(hObject, handles);

% --- Executes on button press in SaveSubjButton.
function SaveSubjButton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveSubjButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PDir=get(handles.WorkDirEntry, 'String');
[File , Path]=uiputfile({'*.txt;*.tsv','Subject List Files (*.txt;*.tsv)';'*.*', 'All Files (*.*)';}, ...
    'Save All Clusters' , fullfile(PDir, 'SubjectList.txt'));
if isnumeric(File)
    return
end
SubjList=get(handles.SubjListbox, 'String');
if ispc
    OS='pc';
else
    OS='unix';
end
dlmwrite(fullfile(Path, File), SubjList, 'precision', '%s',...
    'delimiter', '', 'newline', OS);

% --------------------------------------------------------------------
function RemoveLabel_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.SubjListbox, 'Value');
if ~Value
    return
end
OneSubj=get(handles.SubjListbox, 'String');
OneSubj=OneSubj{Value};

if isempty(handles.SubjString)
    SubjString=get(handles.SubjListbox, 'String');
else
    SubjString=handles.SubjString;
end

Index=strcmpi(OneSubj, SubjString);
SubjString=SubjString(~Index);

handles.SubjString=SubjString;
guidata(hObject, handles);
GetSubjList(hObject, handles);

% --------------------------------------------------------------------
function RemoveOneSubj_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveOneSubj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function GetSubjList(hObject, handles)
%Create by Sandy to get the Subject List
WorkDir=get(handles.WorkDirEntry, 'String');
if isempty(handles.SubjString)
    StartDirSet=get(handles.StartDirEntry, 'String');
    StartValue=get(handles.StartDirEntry, 'Value');
    StartDir=StartDirSet{StartValue};
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
    StartDirFlag='On';
    CustomFlag=0;
else
    SubjString=handles.SubjString;
    StartDirFlag='Off';
    CustomFlag=1;
end

set(handles.StartDirEntry, 'Enable', StartDirFlag);
set(handles.CustomButton, 'Value', CustomFlag);

set(handles.SubjListbox, 'String', SubjString);
set(handles.SubjListbox, 'Value', 1);
