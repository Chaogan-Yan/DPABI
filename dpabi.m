function varargout = dpabi(varargin)
% DPABI MATLAB code for dpabi.fig
%      DPABI, by itself, creates a new DPABI or raises the existing
%      singleton*.
%
%      H = DPABI returns the handle to a new DPABI or the handle to
%      the existing singleton*.
%
%      DPABI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABI.M with the given input arguments.
%
%      DPABI('Property','Value',...) creates a new DPABI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dpabi_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dpabi_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dpabi

% Last Modified by GUIDE v2.5 31-Dec-2022 18:07:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dpabi_OpeningFcn, ...
                   'gui_OutputFcn',  @dpabi_OutputFcn, ...
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


% --- Executes just before dpabi is made visible.
function dpabi_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dpabi (see VARARGIN)

% Choose default command line output for dpabi


Release='V7.0_230110';
if ispc
    UserName =getenv('USERNAME');
else
    UserName =getenv('USER');
end
Datetime=fix(clock);
fprintf('Welcome: %s, %.4d-%.2d-%.2d %.2d:%.2d \n', UserName,Datetime(1),Datetime(2),Datetime(3),Datetime(4),Datetime(5));
fprintf('DPABI: a toolbox for Data Processing & Analysis of Brain Imaging.\nRelease = %s\n',Release);
fprintf('Copyright(c) 2014; GNU GENERAL PUBLIC LICENSE\n');
fprintf('The R-fMRI Lab, Institute of Psychology, Chinese Academy of Sciences, 16 Lincui Road, Chaoyang District, Beijing 100101, China; ');
fprintf('The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962; Department of Child and Adolescent Psychiatry / NYU Langone Medical Center Child Study Center, New York University, New York, NY 10016; ');
fprintf('State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China\n');
fprintf('Mail to Initiator:  <a href="ycg.yan@gmail.com">YAN Chao-Gan</a>\nProgrammers: YAN Chao-Gan; WANG Xin-Di; LU Bin; DENG Zhao-Yu\n<a href="http://rfmri.org/dpabi">http://rfmri.org/dpabi</a>\n');
fprintf('-----------------------------------------------------------\n');
fprintf('Citing Information:\nIf you think DPABI is useful for your work, citing it in your paper would be greatly appreciated!\nReference: Yan, C.G., Wang, X.D., Zuo, X.N., Zang, Y.F., 2016. DPABI: Data Processing & Analysis for (Resting-State) Brain Imaging. Neuroinformatics 14, 339-351. doi: 10.1007/s12021-016-9299-4\n');


[DPABILatestRelease WebStatus]=urlread('http://rfmri.org/DPABILatestRelease.txt');
if WebStatus
    if str2double(DPABILatestRelease(end-5:end)) > str2double(Release(end-5:end))
        uiwait(msgbox(sprintf('A new realease of DPABI is detected: %s, please update.',DPABILatestRelease)));
    end
    
    DPABIMessage=urlread('http://rfmri.org/DPABIMessage.txt');
    if ~isempty(DPABIMessage)
        uiwait(msgbox(DPABIMessage,'DPABI Message'));
    end
    DPABIMessageWeb=urlread('http://rfmri.org/DPABIMessageWeb.txt');
    if ~isempty(DPABIMessageWeb)
        web(DPABIMessageWeb,'-browser');
    end
    
end

handles.output = hObject;

axes(handles.axes_logo);
axis image;
% imshow('dpabi.png');

DPABIPath=fileparts(which('dpabi.m'));
FullMatlabVersion = sscanf(version,'%d.%d.%d.%d%s');
if isunix && (~ismac) && (FullMatlabVersion(1)*1000+FullMatlabVersion(2)<8*1000+4) %Linux has a alpha chanel problem, thus use a special logo image only for linux
    imshow(fullfile(DPABIPath, 'Logo', '.linux.dpabi.png'));
else
    [A, map, alpha] = imread(fullfile(DPABIPath, 'Logo', 'dpabi.png'));
    h = imshow(A, map);
    set(h, 'AlphaData', alpha);
end

set(handles.figureDPABI,'Name','DPABI');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dpabi wait for user response (see UIRESUME)
% uiwait(handles.figureDPABI);


% --- Outputs from this function are returned to the command line.
function varargout = dpabi_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_DPARSFmain.
function pushbutton_DPARSFmain_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_DPARSFmain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPARSF_main


% --- Executes on button press in pushbutton_DPABISurf.
function pushbutton_DPABISurf_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_DPABISurf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABISurf


% --- Executes on button press in pushbutton_QC.
function pushbutton_QC_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_QC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABI_QC_TOOL


% --- Executes on button press in pushbutton_Standardization.
function pushbutton_Standardization_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Standardization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABI_Standardization

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
DPABI_VIEW


% --- Executes on button press in pushbutton_Utilities.
function pushbutton_Utilities_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Utilities (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABI_Utilities



% --- Executes on button press in pushbutton_RfMRIMaps.
function pushbutton_RfMRIMaps_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_RfMRIMaps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[DPABIMessage WebStatus]=urlread('http://rfmri.org/RfMRIMapMessage.txt');
if WebStatus
    if ~isempty(DPABIMessage)
        uiwait(msgbox(DPABIMessage,'The R-fMRI Maps Project Message'));
    end
    DPABIMessageWeb=urlread('http://rfmri.org/RfMRIMapMessageWeb.txt');
    if ~isempty(DPABIMessageWeb)
        web(DPABIMessageWeb,'-browser');
    end
end

DPABI_ResultsOrganizer(1)



% --- Executes on button press in pushbuttonAnalysis.
function pushbuttonAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABI_Analysis


% --- Executes on button press in pushbuttonBrainImageNet.
function pushbuttonBrainImageNet_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonBrainImageNet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABI_BrainImageNet


% --- Executes on button press in pushbuttonDPABINet.
function pushbuttonDPABINet_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDPABINet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABINet


% --- Executes on button press in pushbuttonDPABIFiber.
function pushbuttonDPABIFiber_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDPABIFiber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABIFiber



% --- Executes on button press in pushbuttonDPABIProReports.
function pushbuttonDPABIProReports_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDPABIProReports (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(which('DPABIPro'))
    fprintf('You need to purchase a DPABIPro server to generate DPABIPro Reports for each individual.\n');
    uiwait(msgbox('You need to purchase a DPABIPro server to generate DPABIPro Reports for each individual.','DPABIPro'));
end
