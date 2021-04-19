function varargout = DPABINet_Install(varargin)
% DPABINET_INSTALL MATLAB code for DPABINet_Install.fig
%      DPABINET_INSTALL, by itself, creates a new DPABINET_INSTALL or raises the existing
%      singleton*.
%
%      H = DPABINET_INSTALL returns the handle to a new DPABINET_INSTALL or the handle to
%      the existing singleton*.
%
%      DPABINET_INSTALL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABINET_INSTALL.M with the given input arguments.
%
%      DPABINET_INSTALL('Property','Value',...) creates a new DPABINET_INSTALL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABINet_Install_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABINet_Install_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABINet_Install

% Last Modified by GUIDE v2.5 02-Apr-2021 16:19:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABINet_Install_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABINet_Install_OutputFcn, ...
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


% --- Executes just before DPABINet_Install is made visible.
function DPABINet_Install_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABINet_Install (see VARARGIN)

% Choose default command line output for DPABINet_Install
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABINet_Install wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DPABINet_Install_OutputFcn(hObject, eventdata, handles) 
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
    system('docker pull cgyan/circos')
else
    [Name, Path]=uigetfile({'*.*','Docker File';},...
        'Please pick the circos docker file');
    system(['docker load -i ',fullfile(Path, Name)]);
end



% --- Executes on button press in pushbuttonInstallFSLNets.
function pushbuttonInstallFSLNets_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonInstallFSLNets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiwait(msgbox('Please download and set path for FSLNets. You don''t need to install FSL, but download the zip file for matlab files!','Install FSLNets'));

web('https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSLNets#Installing_FSLNets','-browser');


% --- Executes on button press in pushbuttonInstallBrainNetViewer.
function pushbuttonInstallBrainNetViewer_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonInstallBrainNetViewer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiwait(msgbox('Please download and set path for Brain NetViewer: https://www.nitrc.org/projects/bnv/','Install Brain NetViewer'));

web('https://www.nitrc.org/projects/bnv/','-browser');
