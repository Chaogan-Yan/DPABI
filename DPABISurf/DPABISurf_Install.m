function varargout = DPABISurf_Install(varargin)
% DPABISURF_INSTALL MATLAB code for DPABISurf_Install.fig
%      DPABISURF_INSTALL, by itself, creates a new DPABISURF_INSTALL or raises the existing
%      singleton*.
%
%      H = DPABISURF_INSTALL returns the handle to a new DPABISURF_INSTALL or the handle to
%      the existing singleton*.
%
%      DPABISURF_INSTALL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABISURF_INSTALL.M with the given input arguments.
%
%      DPABISURF_INSTALL('Property','Value',...) creates a new DPABISURF_INSTALL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABISurf_Install_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABISurf_Install_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABISurf_Install

% Last Modified by GUIDE v2.5 26-Dec-2018 06:43:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABISurf_Install_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABISurf_Install_OutputFcn, ...
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


% --- Executes just before DPABISurf_Install is made visible.
function DPABISurf_Install_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABISurf_Install (see VARARGIN)

% Choose default command line output for DPABISurf_Install
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABISurf_Install wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DPABISurf_Install_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_InstallDocker.
function pushbutton_InstallDocker_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_InstallDocker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiwait(msgbox('Please make sure your OS is Windows 10 PRO or above, MAC OS X or Linux! Please follow the instructions in the web page to install Docker: https://docs.docker.com/install.','OS Requirements'));
web('https://docs.docker.com/install','-browser');


% --- Executes on button press in pushbutton_SetUserMemory.
function pushbutton_SetUserMemory_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_SetUserMemory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isunix&&(~ismac) %Linux: Add the current user to docker group
    uiwait(msgbox('Please add the current user to docker group, this needs sudo permission: sudo groupadd docker && sudo usermod -aG docker $USER','Set User'));
    system('sudo groupadd docker')
    system('sudo usermod -aG docker $USER')
    uiwait(msgbox('Please log out and re-log in the current user.','Set User'));
else
    uiwait(msgbox('Please right click the docker button->Setting/Preferences->Advanced, then increase the memory to >4G. You can also assign it more CPUs. Please also set the shared drives.','Set Memory'));
end


% --- Executes on button press in pushbutton_PullDPABISurfDocker.
function pushbutton_PullDPABISurfDocker_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_PullDPABISurfDocker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

button = questdlg('Do you want to pull from online docker hub or load from a local file?','Pull Docker','Pull from online docker hub','Load from a local file','Pull from online docker hub');
if strcmpi(button,'Pull from online docker hub')
    system('docker pull cgyan/dpabi')
else
    [Name, Path]=uigetfile({'*.*','Docker File';},...
        'Please pick the dpabi docker file');
    system(['docker load -i ',fullfile(Path, Name)]);
end



% --- Executes on button press in pushbuttonGetFreesurferLicense.
function pushbuttonGetFreesurferLicense_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonGetFreesurferLicense (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiwait(msgbox('Please get Freesurfer license, and specify the license.txt you received in your email. Please visit: https://surfer.nmr.mgh.harvard.edu/registration.html','Get Freesurfer license'));

[Name, Path]=uigetfile({'*.txt','License File';},'Please pick the Freesurfer license.txt file');
[DPABIPath, fileN, extn] = fileparts(which('DPABI.m'));
copyfile(fullfile(Path, Name),fullfile(DPABIPath, 'DPABISurf', 'FreeSurferLicense', 'license.txt'));



% --- Executes on button press in pushbuttonT1Defacer.
function pushbuttonT1Defacer_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonT1Defacer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABI_T1ImgDefacer

% --- Executes on button press in pushbuttonVoxelAugmentor.
function pushbuttonVoxelAugmentor_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonVoxelAugmentor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABI_VoxelAugmentor

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


% --- Executes on button press in pushbuttonDualRegression.
function pushbuttonDualRegression_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDualRegression (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABI_DualRegression
