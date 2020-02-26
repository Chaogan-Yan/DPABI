function varargout = DPABISurf_Utilities(varargin)
% DPABISURF_UTILITIES MATLAB code for DPABISurf_Utilities.fig
%      DPABISURF_UTILITIES, by itself, creates a new DPABISURF_UTILITIES or raises the existing
%      singleton*.
%
%      H = DPABISURF_UTILITIES returns the handle to a new DPABISURF_UTILITIES or the handle to
%      the existing singleton*.
%
%      DPABISURF_UTILITIES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABISURF_UTILITIES.M with the given input arguments.
%
%      DPABISURF_UTILITIES('Property','Value',...) creates a new DPABISURF_UTILITIES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABISurf_Utilities_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABISurf_Utilities_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABISurf_Utilities

% Last Modified by GUIDE v2.5 24-Feb-2020 14:20:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABISurf_Utilities_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABISurf_Utilities_OutputFcn, ...
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


% --- Executes just before DPABISurf_Utilities is made visible.
function DPABISurf_Utilities_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABISurf_Utilities (see VARARGIN)

% Choose default command line output for DPABISurf_Utilities
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABISurf_Utilities wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DPABISurf_Utilities_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in pushbutton_ImageCalculator.
function pushbutton_ImageCalculator_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ImageCalculator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABI_CALCULATOR_TOOL


% --- Executes on button press in pushbutton_Vol2Surf.
function pushbutton_Vol2Surf_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Vol2Surf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABISurf_Vol2Surf


% --- Executes on button press in pushbuttonROISignalExtractor.
function pushbuttonROISignalExtractor_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonROISignalExtractor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABI_ROISignalExtracter

% --- Executes on button press in pushbuttonICC.
function pushbuttonICC_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonICC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABI_ICC_TOOL


% --- Executes on button press in pushbuttonReRunfmriprepFailedSubjects.
function pushbuttonReRunfmriprepFailedSubjects_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonReRunfmriprepFailedSubjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

y_ReRunfmriprepFailedSubjects
