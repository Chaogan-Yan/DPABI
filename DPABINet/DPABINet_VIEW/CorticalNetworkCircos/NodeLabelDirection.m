function varargout = NodeLabelDirection(varargin)
% NODELABELDIRECTION MATLAB code for NodeLabelDirection.fig
%      NODELABELDIRECTION, by itself, creates a new NODELABELDIRECTION or raises the existing
%      singleton*.
%
%      H = NODELABELDIRECTION returns the handle to a new NODELABELDIRECTION or the handle to
%      the existing singleton*.
%
%      NODELABELDIRECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NODELABELDIRECTION.M with the given input arguments.
%
%      NODELABELDIRECTION('Property','Value',...) creates a new NODELABELDIRECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NodeLabelDirection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NodeLabelDirection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NodeLabelDirection

% Last Modified by GUIDE v2.5 12-Apr-2022 15:08:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NodeLabelDirection_OpeningFcn, ...
                   'gui_OutputFcn',  @NodeLabelDirection_OutputFcn, ...
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


% --- Executes just before NodeLabelDirection is made visible.
function NodeLabelDirection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NodeLabelDirection (see VARARGIN)
if isempty(varargin) || isempty(varargin{1})
    NodeLabelDirection.NodeLabelDirection = 'T'; 
    NodeLabelDirection.InnerCircleOffset = 0;
    NodeLabelDirection.TextSize = 36;
else
    NodeLabelDirection=varargin{1};
end

if strcmpi(NodeLabelDirection.NodeLabelDirection, 'T')
    set(handles.radiobuttonTangential,'Value',1);
    set(handles.radiobuttonNormal,'Value',0);
else
    set(handles.radiobuttonTangential,'Value',0);
    set(handles.radiobuttonNormal,'Value',1);
end
set(handles.editPixel,'String',num2str(NodeLabelDirection.InnerCircleOffset));
set(handles.editTextSize,'String',num2str(NodeLabelDirection.TextSize));
% Choose default command line output for NodeLabelDirection
handles.output = hObject;

% Update handles structure
handles.NodeLabelDirection = NodeLabelDirection;
guidata(hObject, handles);

% UIWAIT makes NodeLabelDirection wait for user response (see UIRESUME)
uiwait(handles.figureNodeLabelDirection);


% --- Outputs from this function are returned to the command line.
function varargout = NodeLabelDirection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    varargout{1} = [];
else
    varargout{1} = handles.NodeLabelDirection;
    delete(handles.figureNodeLabelDirection)
end


% --- Executes on button press in radiobuttonTangential.
function radiobuttonTangential_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonTangential (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.NodeLabelDirection.NodeLabelDirection = 'T';
set(handles.radiobuttonNormal,'Value',0);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of radiobuttonTangential


% --- Executes on button press in radiobuttonNormal.
function radiobuttonNormal_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonNormal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.NodeLabelDirection.NodeLabelDirection = 'N';
set(handles.radiobuttonTangential,'Value',0);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of radiobuttonNormal



function editPixel_Callback(hObject, eventdata, handles)
% hObject    handle to editPixel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.NodeLabelDirection.InnerCircleOffset = str2num(get(handles.editPixel,'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of editPixel as text
%        str2double(get(hObject,'String')) returns contents of editPixel as a double


% --- Executes during object creation, after setting all properties.
function editPixel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPixel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editTextSize_Callback(hObject, eventdata, handles)
% hObject    handle to editTextSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.NodeLabelDirection.TextSize = str2num(get(handles.editTextSize,'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of editTextSize as text
%        str2double(get(hObject,'String')) returns contents of  as a double


% --- Executes during object creation, after setting all properties.
function editTextSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTextSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonOK.
function pushbuttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figureNodeLabelDirection);
