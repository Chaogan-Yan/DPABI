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

% Last Modified by GUIDE v2.5 19-Apr-2021 13:51:16

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
if isempty(varargin)
    QCThreshold.IsThreT1 = 1;
    QCThreshold.IsThreFun = 1;
    QCThreshold.ThreT1 = 3;
    QCThreshold.ThreFun = 3;
else
    QCThreshold=varargin{1};
end

if QCThreshold.IsThreT1 == 1
    set(handles.checkboxT1,'Value',1);
    set(handles.editT1,'Enable','on');
else
    set(handles.checkboxT1,'Value',0);
    set(handles.editT1,'Enable','off');
end

if QCThreshold.IsThreFun == 1
    set(handles.checkboxFun,'Value',1);
    set(handles.editFun,'Enable','on');
else
    set(handles.checkboxFun,'Value',0);
    set(handles.editFun,'Enable','off');
end

set(handles.editFun,'String',num2str(QCThreshold.ThreFun));
set(handles.editT1,'String',num2str(QCThreshold.ThreT1));
% Choose default command line output for ReorientThreQC
handles.output = hObject;

% Update handles structure
handles.QCThreshold = QCThreshold;

% Make UI display correct in PC and linux

if ismac
    ZoonMatrix = [1 1 1.8 1.8];  %For mac
elseif ispc
    ZoonMatrix = [1 1 1.5 1.5];  %For pc
else
    ZoonMatrix = [1 1 1.3 1.3];  %For Linux
end

UISize = get(handles.figureThresholingQuality,'Position');
UISize = UISize.*ZoonMatrix;
set(handles.figureThresholingQuality,'Position',UISize);

movegui(handles.figureThresholingQuality,'center');


guidata(hObject, handles);

% UIWAIT makes ReorientThreQC wait for user response (see UIRESUME)
uiwait(handles.figureThresholingQuality);


% --- Outputs from this function are returned to the command line.
function varargout = ReorientThreQC_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    varargout{1} = [];
else
    varargout{1} = handles.QCThreshold;
    delete(handles.figureThresholingQuality)
end


% --- Executes on button press in pushbuttonRun.
function pushbuttonRun_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figureThresholingQuality);


% --- Executes on button press in checkboxT1.
function checkboxT1_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxT1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.QCThreshold.IsThreT1 = get(handles.checkboxT1,'Value');
if handles.QCThreshold.IsThreT1
    set(handles.editT1,'Enable','on');
else
    set(handles.editT1,'Enable','off');
end
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxT1


% --- Executes on button press in checkboxFun.
function checkboxFun_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxFun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.QCThreshold.IsThreFun = get(handles.checkboxFun,'Value');
if handles.QCThreshold.IsThreFun
    set(handles.editFun,'Enable','on');
else
    set(handles.editFun,'Enable','off');
end
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxFun



function editT1_Callback(hObject, eventdata, handles)
% hObject    handle to editT1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.QCThreshold.ThreT1 = str2num(get(handles.editT1,'String'));
guidata(hObject, handles);
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
handles.QCThreshold.ThreFun = str2num(get(handles.editFun,'String'));
guidata(hObject, handles);


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
