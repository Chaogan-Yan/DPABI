function varargout = DPABINet(varargin)
% DPABINET MATLAB code for DPABINet.fig
%      DPABINET, by itself, creates a new DPABINET or raises the existing
%      singleton*.
%
%      H = DPABINET returns the handle to a new DPABINET or the handle to
%      the existing singleton*.
%
%      DPABINET('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABINET.M with the given input arguments.
%
%      DPABINET('Property','Value',...) creates a new DPABINET or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABINet_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABINet_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABINet

% Last Modified by GUIDE v2.5 02-Apr-2021 16:26:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABINet_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABINet_OutputFcn, ...
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


% --- Executes just before DPABINet is made visible.
function DPABINet_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABINet (see VARARGIN)

% Choose default command line output for DPABINet


Release='V1.2_220915';
if ispc
    UserName =getenv('USERNAME');
else
    UserName =getenv('USER');
end
Datetime=fix(clock);
fprintf('Welcome: %s, %.4d-%.2d-%.2d %.2d:%.2d \n', UserName,Datetime(1),Datetime(2),Datetime(3),Datetime(4),Datetime(5));
fprintf('DPABINet: A Toolbox for Brain Network and Graph Theoretical Analyses.\nRelease = %s\n',Release);
fprintf('Copyright(c) 2021; GNU GENERAL PUBLIC LICENSE\n');
fprintf('The R-fMRI Lab, Institute of Psychology, Chinese Academy of Sciences, 16 Lincui Road, Chaoyang District, Beijing 100101, China; \n');
fprintf('Mail to Initiator:  <a href="ycg.yan@gmail.com">YAN Chao-Gan</a>\nProgrammers: YAN Chao-Gan; WANG Xin-Di; LU Bin; DENG Zhao-Yu\n<a href="http://rfmri.org/dpabi">http://rfmri.org/dpabi</a>\n');
fprintf('-----------------------------------------------------------\n');
fprintf('Citing Information:\nDPABINet is a toolbox for brain network and graph theoretical analyses, evolved from DPABI/DPABISurf/DPARSF, as easy-to-use as DPABI/DPABISurf/DPARSF. DPABINet is based on Brain Connectivity Toolbox (Rubinov and Sporns, 2010) (RRID:SCR_004841), FSLNets (http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSLNets; RRID: SCR_002823), BrainNet Viewer (Xia et al., 2013) (RRID:SCR_009446), circos (Krzywinski et al., 2009) (RRID:SCR_018207), SPM (Ashburner, 2012) (RRID:SCR_007037), PALM (Winkler et al., 2016), MATLAB (The MathWorks Inc., Natick, MA, US) (RRID:SCR_001622), Docker (https://docker.com) (RRID:SCR_016445) and DPABI (Yan et al., 2016) (RRID:SCR_010501). DPABINet provides user-friendly graphical user interface (GUI) for Brain network construction, graph theoretical analyses, statistical analyses and results viewing, while requires no programming/scripting skills from the users.\n');

[DPABINetMessage WebStatus]=urlread('http://rfmri.org/DPABINetMessage.txt');
if WebStatus
    if ~isempty(DPABINetMessage)
        uiwait(msgbox(DPABINetMessage,'DPABINet Message'));
    end
    DPABINetMessageWeb=urlread('http://rfmri.org/DPABINetMessageWeb.txt');
    if ~isempty(DPABINetMessageWeb)
        web(DPABINetMessageWeb,'-browser');
    end
end
    
handles.output = hObject;

axes(handles.axes_logo);
axis image;
% imshow('DPABINet.png');

DPABIPath=fileparts(which('dpabi.m'));

FullMatlabVersion = sscanf(version,'%d.%d.%d.%d%s');
if isunix && (~ismac) && (FullMatlabVersion(1)*1000+FullMatlabVersion(2)<8*1000+4) %Linux has a alpha chanel problem, thus use a special logo image only for linux
    imshow(fullfile(DPABIPath, 'Logo', '.linux.DPABINet.png'));
else
    [A, map, alpha] = imread(fullfile(DPABIPath, 'Logo', 'DPABINet.png'));
    h = imshow(A, map);
    set(h, 'AlphaData', alpha);
end

set(handles.figureDPABINet,'Name','DPABINet');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABINet wait for user response (see UIRESUME)
% uiwait(handles.figureDPABINet);


% --- Outputs from this function are returned to the command line.
function varargout = DPABINet_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% --- Executes on button press in pushbuttonInstall.
function pushbuttonInstall_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonInstall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABINet_Install


% --- Executes on button press in pushbutton_NetworkConstruction.
function pushbutton_NetworkConstruction_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_NetworkConstruction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABINet_Construction



% --- Executes on button press in pushbuttonGTA.
function pushbuttonGTA_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonGTA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DPABINet_GTA



% --- Executes on button press in pushbuttonStats.
function pushbuttonStats_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonStats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABI_STAT_TOOL


% --- Executes on button press in pushbutton_Viewer.
function pushbutton_Viewer_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Viewer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiwait(msgbox('DPABINet_VIEW is still under development. If there is no response for a button, that means we are still developing...','DPABINet_VIEW'));
DPABINet_VIEW


% --- Executes on button press in pushbutton_Utilities.
function pushbutton_Utilities_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Utilities (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABINet_Utilities


