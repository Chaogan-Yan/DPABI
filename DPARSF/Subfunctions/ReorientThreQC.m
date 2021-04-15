function varargout = ReorientThreQC(varargin)
% REORIENTTHREQC MATLAB code for ReorientThreQC.fig
%      REORIENTTHREQC, by itself, creates a new REORIENTTHREQC or raises the existing
%      singleton*.
%
%      H = REORIENTTHREQC returns the handle to a new REORIENTTHREQC or the handle to
%      the existing singleton*.
%
%      REORIENTTHREQC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REORIENTTHREQC.M with the given input arguments.
%
%      REORIENTTHREQC('Property','Value',...) creates a new REORIENTTHREQC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ReorientThreQC_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ReorientThreQC_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ReorientThreQC

% Last Modified by GUIDE v2.5 15-Apr-2021 14:32:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ReorientThreQC_OpeningFcn, ...
                   'gui_OutputFcn',  @ReorientThreQC_OutputFcn, ...
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


% --- Executes just before ReorientThreQC is made visible.
function ReorientThreQC_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ReorientThreQC (see VARARGIN)
handles.cfg.IsThreT1 = 1;
handles.cfg.IsThreFun = 1;
handles.cfg.ThreT1 = 3;
handles.cfg.ThreFun = 3;

% Choose default command line output for ReorientThreQC
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ReorientThreQC wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ReorientThreQC_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonRun.
function pushbuttonRun_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.cfg.IsThreT1 = get(handles.checkboxT1,'Value');
handles.cfg.IsThreFun = get(handles.checkboxFun,'Value');
handles.cfg.ThreT1 = str2num(get(handles.editT1,'String'));
handles.cfg.ThreFun = str2num(get(handles.editFun,'String'));

clc;
handles.cfg.IsThreT1
handles.cfg.ThreT1
handles.cfg.IsThreFun
handles.cfg.ThreFun




% --- Executes on button press in checkboxT1.
function checkboxT1_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxT1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.checkboxT1,'Value')
    set(handles.editT1,'Enable','on');
else
    set(handles.editT1,'Enable','off');
end
% Hint: get(hObject,'Value') returns toggle state of checkboxT1


% --- Executes on button press in checkboxFun.
function checkboxFun_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxFun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.checkboxFun,'Value')
    set(handles.editFun,'Enable','on');
else
    set(handles.editFun,'Enable','off');
end
% Hint: get(hObject,'Value') returns toggle state of checkboxFun



function editT1_Callback(hObject, eventdata, handles)
% hObject    handle to editT1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editT1 as text
%        str2double(get(hObject,'String')) returns contents of editT1 as a double


% --- Executes during object creation, after setting all properties.
function editT1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editT1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFun_Callback(hObject, eventdata, handles)
% hObject    handle to editFun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of editFun as text
%        str2double(get(hObject,'String')) returns contents of editFun as a double


% --- Executes during object creation, after setting all properties.
function editFun_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
