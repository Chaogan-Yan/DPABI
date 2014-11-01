function varargout = DPARSF_ChooseGUI(varargin)
% DPARSF_CHOOSEGUI MATLAB code for DPARSF_ChooseGUI.fig
%      DPARSF_CHOOSEGUI, by itself, creates a new DPARSF_CHOOSEGUI or raises the existing
%      singleton*.
%
%      H = DPARSF_CHOOSEGUI returns the handle to a new DPARSF_CHOOSEGUI or the handle to
%      the existing singleton*.
%
%      DPARSF_CHOOSEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPARSF_CHOOSEGUI.M with the given input arguments.
%
%      DPARSF_CHOOSEGUI('Property','Value',...) creates a new DPARSF_CHOOSEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPARSF_ChooseGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPARSF_ChooseGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPARSF_ChooseGUI

% Last Modified by GUIDE v2.5 22-Sep-2012 23:27:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPARSF_ChooseGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @DPARSF_ChooseGUI_OutputFcn, ...
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


% --- Executes just before DPARSF_ChooseGUI is made visible.
function DPARSF_ChooseGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPARSF_ChooseGUI (see VARARGIN)

% Choose default command line output for DPARSF_ChooseGUI
%handles.Choose = 2;


% Update handles structure
guidata(hObject, handles);

try
	uiwait(handles.figure1);
catch
	uiresume(handles.figure1);
end


% UIWAIT makes DPARSF_ChooseGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DPARSF_ChooseGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.Choose;
delete(handles.figure1);


% --- Executes on button press in pushbuttonBasic.
function pushbuttonBasic_Callback(hObject, eventdata, handles)

% button = questdlg('The DPARSF Advanced Edition has been updated with parallel computing and more flexible design, do you want to try it?','DPARSFA','Yes','No','Yes');
% if strcmpi(button,'Yes')
%     handles.Choose = 2;
%     
% else
%     handles.Choose = 1;
% end

handles.Choose = 1;

guidata(hObject, handles);
drawnow;
uiresume(handles.figure1);


% --- Executes on button press in pushbuttonAdvanced.
function pushbuttonAdvanced_Callback(hObject, eventdata, handles)
handles.Choose = 2;
guidata(hObject, handles);
drawnow;
uiresume(handles.figure1);
