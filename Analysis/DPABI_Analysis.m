function varargout = DPABI_Analysis(varargin)
% DPABI_ANALYSIS MATLAB code for DPABI_Analysis.fig
%      DPABI_ANALYSIS, by itself, creates a new DPABI_ANALYSIS or raises the existing
%      singleton*.
%
%      H = DPABI_ANALYSIS returns the handle to a new DPABI_ANALYSIS or the handle to
%      the existing singleton*.
%
%      DPABI_ANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABI_ANALYSIS.M with the given input arguments.
%
%      DPABI_ANALYSIS('Property','Value',...) creates a new DPABI_ANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABI_Analysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABI_Analysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABI_Analysis

% Last Modified by GUIDE v2.5 26-Feb-2020 10:47:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABI_Analysis_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABI_Analysis_OutputFcn, ...
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


% --- Executes just before DPABI_Analysis is made visible.
function DPABI_Analysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABI_Analysis (see VARARGIN)

% Choose default command line output for DPABI_Analysis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABI_Analysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DPABI_Analysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in pushbutton_TDAVolume.
function pushbutton_TDAVolume_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_TDAVolume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABI_TDA;

% --- Executes on button press in pushbuttonTDASurface.
function pushbuttonTDASurface_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonTDASurface (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABI_TDA_Surf;



% --- Executes on button press in pushbutton_StabilityVolume.
function pushbutton_StabilityVolume_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_StabilityVolume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABI_Stability(0);

% --- Executes on button press in pushbuttonStabilitySurface.
function pushbuttonStabilitySurface_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonStabilitySurface (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABI_Stability(1);
