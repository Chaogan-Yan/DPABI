function varargout = IsAnatOnly(varargin)
% ISANATONLY MATLAB code for IsAnatOnly.fig
%      ISANATONLY, by itself, creates a new ISANATONLY or raises the existing
%      singleton*.
%
%      H = ISANATONLY returns the handle to a new ISANATONLY or the handle to
%      the existing singleton*.
%
%      ISANATONLY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ISANATONLY.M with the given input arguments.
%
%      ISANATONLY('Property','Value',...) creates a new ISANATONLY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before IsAnatOnly_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to IsAnatOnly_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help IsAnatOnly

% Last Modified by GUIDE v2.5 19-Apr-2021 10:46:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @IsAnatOnly_OpeningFcn, ...
                   'gui_OutputFcn',  @IsAnatOnly_OutputFcn, ...
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


% --- Executes just before IsAnatOnly is made visible.
function IsAnatOnly_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to IsAnatOnly (see VARARGIN)
if isempty(varargin)
    IsAnatOnly = 1; 
else
    IsAnatOnly=varargin{1};
end

if IsAnatOnly == 1
    set(handles.radiobuttonAnatOnly,'Value',1);
    set(handles.radiobuttonWithFun,'Value',0);
else
    set(handles.radiobuttonAnatOnly,'Value',0);
    set(handles.radiobuttonWithFun,'Value',1);
end
% Choose default command line output for IsAnatOnly
handles.output = hObject;

% Update handles structure
handles.IsAnatOnly=IsAnatOnly;
guidata(hObject, handles);

% Make UI display correct in PC and linux
if ~ismac
    if ispc
        ZoonMatrix = [1 1 1.6 1.2];  %For pc
    else
        ZoonMatrix = [1 1 1.6 1.2];  %For Linux
    end
    UISize = get(handles.figureIsAnatOnly,'Position');
    UISize = UISize.*ZoonMatrix;
    set(handles.figureIsAnatOnly,'Position',UISize);
end
movegui(handles.figureIsAnatOnly, 'center');

% UIWAIT makes IsAnatOnly wait for user response (see UIRESUME)
uiwait(handles.figureIsAnatOnly);


% --- Outputs from this function are returned to the command line.
function varargout = IsAnatOnly_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    varargout{1} = [];
else
    varargout{1} = handles.IsAnatOnly;
    delete(handles.figureIsAnatOnly)
end


% --- Executes on button press in radiobuttonAnatOnly.
function radiobuttonAnatOnly_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonAnatOnly (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.IsAnatOnly = 1;
set(handles.radiobuttonWithFun,'Value',0);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of radiobuttonAnatOnly


% --- Executes on button press in radiobuttonWithFun.
function radiobuttonWithFun_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonWithFun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.IsAnatOnly = 0;
set(handles.radiobuttonAnatOnly,'Value',0);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of radiobuttonWithFun


% --- Executes on button press in pushbuttonOK.
function pushbuttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figureIsAnatOnly);
