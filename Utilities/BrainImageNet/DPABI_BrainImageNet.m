function varargout = DPABI_BrainImageNet(varargin)
% DPABI_BRAINIMAGENET MATLAB code for DPABI_BrainImageNet.fig
%      DPABI_BRAINIMAGENET, by itself, creates a new DPABI_BRAINIMAGENET or raises the existing
%      singleton*.
%
%      H = DPABI_BRAINIMAGENET returns the handle to a new DPABI_BRAINIMAGENET or the handle to
%      the existing singleton*.
%
%      DPABI_BRAINIMAGENET('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABI_BRAINIMAGENET.M with the given input arguments.
%
%      DPABI_BRAINIMAGENET('Property','Value',...) creates a new DPABI_BRAINIMAGENET or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABI_BrainImageNet_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABI_BrainImageNet_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABI_BrainImageNet

% Last Modified by GUIDE v2.5 15-Aug-2020 11:43:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABI_BrainImageNet_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABI_BrainImageNet_OutputFcn, ...
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


% --- Executes just before DPABI_BrainImageNet is made visible.
function DPABI_BrainImageNet_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABI_BrainImageNet (see VARARGIN)

% Choose default command line output for DPABI_BrainImageNet
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABI_BrainImageNet wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DPABI_BrainImageNet_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_PullBrainImageNetDocker.
function pushbutton_PullBrainImageNetDocker_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_PullBrainImageNetDocker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

system('docker pull cgyan/brainimagenet')




% --- Executes on button press in pushbutton_PredictOnline.
function pushbutton_PredictOnline_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_PredictOnline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

web('http://brainimagenet.org','-browser');





% --- Executes on button press in pushbutton_PredictingOnLocal.
function pushbutton_PredictingOnLocal_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_PredictingOnLocal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

button = questdlg('BrainImageNet predicting on local requires huge amount of memory or it may fail, do you want to have a look on DPABI Core?','Memory!');
if strcmpi(button,'Yes')
    web('http://deepbrain.com/DPABICore','-browser');
elseif strcmpi(button,'No')
    DPABI_BrainImageNet_Local
end

