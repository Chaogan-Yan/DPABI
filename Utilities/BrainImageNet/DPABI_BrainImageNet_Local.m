function varargout = DPABI_BrainImageNet_Local(varargin)
% DPABI_BrainImageNet_Local MATLAB code for DPABI_BrainImageNet_Local.fig
%      DPABI_BrainImageNet_Local, by itself, creates a new DPABI_BrainImageNet_Local or raises the existing
%      singleton*.
%
%      H = DPABI_BrainImageNet_Local returns the handle to a new DPABI_BrainImageNet_Local or the handle to
%      the existing singleton*.
%
%      DPABI_BrainImageNet_Local('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABI_BrainImageNet_Local.M with the given input arguments.
%
%      DPABI_BrainImageNet_Local('Property','Value',...) creates a new DPABI_BrainImageNet_Local or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABI_BrainImageNet_Local_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABI_BrainImageNet_Local_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABI_BrainImageNet_Local

% Last Modified by GUIDE v2.5 15-Aug-2020 15:48:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABI_BrainImageNet_Local_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABI_BrainImageNet_Local_OutputFcn, ...
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


% --- Executes just before DPABI_BrainImageNet_Local is made visible.
function DPABI_BrainImageNet_Local_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABI_BrainImageNet_Local (see VARARGIN)


% Set handles


axes(handles.axes_logo);
axis image;
imshow('BrainImageNetLogo.jpg');


% Choose default command line output for DPABI_BrainImageNet_Local
handles.output = hObject;


% Make UI display correct in PC and linux
if ~ismac
    if ispc
        ZoonMatrix = [1 1 1 1];  %For pc
    else
        ZoonMatrix = [1 1 1.2 1.2];  %For Linux
    end
    UISize = get(handles.figDPABI_TDA,'Position');
    UISize = UISize.*ZoonMatrix;
    set(handles.figDPABI_TDA,'Position',UISize);
end
movegui(handles.figDPABI_TDA,'center');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABI_BrainImageNet_Local wait for user response (see UIRESUME)
% uiwait(handles.figDPABI_TDA);





% --- Outputs from this function are returned to the command line.
function varargout = DPABI_BrainImageNet_Local_OutputFcn(hObject, eventdata, handles) 
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
handles.Cfg.SubjectID = get(handles.SubjListbox, 'String');
handles.Cfg.StartingDirName = get(handles.StartDirEntry,'String');
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of StartDirEntry as text
%        str2double(get(hObject,'String')) returns contents of StartDirEntry as a double





function WorkDirEntry_Callback(hObject, eventdata, handles)
% hObject    handle to WorkDirEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%handles.Cfg.WorkingDir = get(handles.WorkDirEntry,'String');
%guidata(hObject,handles);
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


%handles.Cfg.WorkingDir = get(handles.WorkDirEntry,'String');
%guidata(hObject,handles);



  


function editOutDir_Callback(hObject, eventdata, handles)
% hObject    handle to editOutDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editOutDir as text
%        str2double(get(hObject,'String')) returns contents of editOutDir as a double


% --- Executes during object creation, after setting all properties.
function editOutDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editOutDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonOutDir.
function pushbuttonOutDir_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOutDir (see GCBO)
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
set(handles.editOutDir, 'String', Path);





  

% --- Executes on button press in btnPredictSex.
function btnPredictSex_Callback(hObject, eventdata, handles)
% hObject    handle to btnPredictSex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

InDir=get(handles.WorkDirEntry, 'String');
OutDir=get(handles.editOutDir, 'String');
%docker run -ti --rm -v /Data/DPARSFPrecprocessed:/in -v /Data/Results:/out cgyan/brainimagenet

Cmd=sprintf('docker run -ti --rm -v %s:/in -v %s:/out cgyan/brainimagenet python3 y_Predict_Sex.py -i /in -o /out',InDir,OutDir);

system(Cmd)

fprintf('\nPredicting sex finished. Please check the output text file under output dir.\n');


% --- Executes on button press in pushbuttonPredictAD.
function pushbuttonPredictAD_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPredictAD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

InDir=get(handles.WorkDirEntry, 'String');
OutDir=get(handles.editOutDir, 'String');
%docker run -ti --rm -v /Data/DPARSFPrecprocessed:/in -v /Data/Results:/out cgyan/brainimagenet

Cmd=sprintf('docker run -ti --rm -v %s:/in -v %s:/out cgyan/brainimagenet python3 y_Predict_AD.py -i /in -o /out',InDir,OutDir);

system(Cmd)

fprintf('\nPredicting AD finished. Please check the output text file under output dir. If there is nothing, then you may need to increase your memory!\n');
