function varargout = DPABI_Utilities(varargin)
% DPABI_UTILITIES MATLAB code for DPABI_Utilities.fig
%      DPABI_UTILITIES, by itself, creates a new DPABI_UTILITIES or raises the existing
%      singleton*.
%
%      H = DPABI_UTILITIES returns the handle to a new DPABI_UTILITIES or the handle to
%      the existing singleton*.
%
%      DPABI_UTILITIES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABI_UTILITIES.M with the given input arguments.
%
%      DPABI_UTILITIES('Property','Value',...) creates a new DPABI_UTILITIES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABI_Utilities_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABI_Utilities_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABI_Utilities

% Last Modified by GUIDE v2.5 06-Aug-2014 02:36:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABI_Utilities_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABI_Utilities_OutputFcn, ...
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


% --- Executes just before DPABI_Utilities is made visible.
function DPABI_Utilities_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABI_Utilities (see VARARGIN)

% Choose default command line output for DPABI_Utilities
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABI_Utilities wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DPABI_Utilities_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_DICOMSorter.
function pushbutton_DICOMSorter_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_DICOMSorter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABI_DCMSORTER_TOOL


% --- Executes on button press in pushbutton_ImageCalculator.
function pushbutton_ImageCalculator_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ImageCalculator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABI_CALCULATOR_TOOL


% --- Executes on button press in pushbutton_ImageReslicer.
function pushbutton_ImageReslicer_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ImageReslicer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABI_RESLICE_TOOL
