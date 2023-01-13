function varargout = DPABISurf(varargin)
% DPABISURF MATLAB code for DPABISurf.fig
%      DPABISURF, by itself, creates a new DPABISURF or raises the existing
%      singleton*.
%
%      H = DPABISURF returns the handle to a new DPABISURF or the handle to
%      the existing singleton*.
%
%      DPABISURF('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABISURF.M with the given input arguments.
%
%      DPABISURF('Property','Value',...) creates a new DPABISURF or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABISurf_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABISurf_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABISurf

% Last Modified by GUIDE v2.5 26-Feb-2020 10:51:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABISurf_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABISurf_OutputFcn, ...
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


% --- Executes just before DPABISurf is made visible.
function DPABISurf_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABISurf (see VARARGIN)

% Choose default command line output for DPABISurf


Release='V2.0_230110';
if ispc
    UserName =getenv('USERNAME');
else
    UserName =getenv('USER');
end
Datetime=fix(clock);
fprintf('Welcome: %s, %.4d-%.2d-%.2d %.2d:%.2d \n', UserName,Datetime(1),Datetime(2),Datetime(3),Datetime(4),Datetime(5));
fprintf('DPABISurf: A Surface-Based Resting-State fMRI Data Analysis Toolbox.\nRelease = %s\n',Release);
fprintf('Copyright(c) 2019; GNU GENERAL PUBLIC LICENSE\n');
fprintf('The R-fMRI Lab, Institute of Psychology, Chinese Academy of Sciences, 16 Lincui Road, Chaoyang District, Beijing 100101, China; \n');
fprintf('Mail to Initiator:  <a href="ycg.yan@gmail.com">YAN Chao-Gan</a>\nProgrammers: YAN Chao-Gan; WANG Xin-Di; LU Bin\n<a href="http://rfmri.org/dpabi">http://rfmri.org/dpabi</a>\n');
fprintf('-----------------------------------------------------------\n');
fprintf('Citing Information:\nDPABISurf is a surface-based resting-state fMRI data analysis toolbox evolved from DPABI/DPARSF, as easy-to-use as DPABI/DPARSF. DPABISurf is based on fMRIPrep (Esteban et al., 2019), FreeSurfer (Dale et al., 1999), ANTs (Avants et al., 2008), FSL (Jenkinson et al., 2002), AFNI (Cox, 1996), SPM (Ashburner, 2012), dcm2niix (Li et al., 2016), PALM (Winkler et al., 2016), GNU Parallel (Tange, 2011), MATLAB (The MathWorks Inc., Natick, MA, US), Docker (https://docker.com) and DPABI (Yan et al., 2016).\n');
fprintf('Reference: Yan, C.-G., Wang, X.-D., Lu, B. (2021). DPABISurf: data processing & analysis for brain imaging on surface. Science Bulletin, 66(24), 2453-2455, doi:https://doi.org/10.1016/j.scib.2021.09.016.\n');

[DPABISurfMessage WebStatus]=urlread('http://rfmri.org/DPABISurfMessage.txt');
if WebStatus
    if ~isempty(DPABISurfMessage)
        uiwait(msgbox(DPABISurfMessage,'DPABISurf Message'));
    end
    DPABISurfMessageWeb=urlread('http://rfmri.org/DPABISurfMessageWeb.txt');
    if ~isempty(DPABISurfMessageWeb)
        web(DPABISurfMessageWeb,'-browser');
    end
end
    
handles.output = hObject;

axes(handles.axes_logo);
axis image;
% imshow('DPABISurf.png');

DPABIPath=fileparts(which('dpabi.m'));

FullMatlabVersion = sscanf(version,'%d.%d.%d.%d%s');
if isunix && (~ismac) && (FullMatlabVersion(1)*1000+FullMatlabVersion(2)<8*1000+4) %Linux has a alpha chanel problem, thus use a special logo image only for linux
    imshow(fullfile(DPABIPath, 'Logo', '.linux.DPABISurf.png'));
else
    [A, map, alpha] = imread(fullfile(DPABIPath, 'Logo', 'DPABISurf.png'));
    h = imshow(A, map);
    set(h, 'AlphaData', alpha);
end

set(handles.figureDPABISurf,'Name','DPABISurf');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABISurf wait for user response (see UIRESUME)
% uiwait(handles.figureDPABISurf);


% --- Outputs from this function are returned to the command line.
function varargout = DPABISurf_OutputFcn(hObject, eventdata, handles) 
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
DPABISurf_Install


% --- Executes on button press in pushbutton_DPABISurfPipeline.
function pushbutton_DPABISurfPipeline_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_DPABISurfPipeline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABISurf_Pipeline


% --- Executes on button press in pushbutton_Standardization.
function pushbutton_Standardization_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Standardization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABI_Standardization_Surf

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
uiwait(msgbox('DPABISurf_VIEW is still under development. If there is no response for a button, that means we are still developing...','DPABISurf_VEW'));
DPABISurf_VIEW


% --- Executes on button press in pushbutton_Utilities.
function pushbutton_Utilities_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Utilities (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABISurf_Utilities



% --- Executes on button press in pushbutton_VNCintoDPABISurfDocker.
function pushbutton_VNCintoDPABISurfDocker_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_VNCintoDPABISurfDocker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

WorkingDir = uigetdir('','Please select the working directory. It will be /data in docker.');

[DPABIPath, fileN, extn] = fileparts(which('DPABI.m'));

CommandInit=sprintf('docker run -d --rm -v %s:/DPABI:ro -v %s:/opt/freesurfer/license.txt -v %s:/data -p 5925:5925 cgyan/dpabi', DPABIPath, fullfile(DPABIPath, 'DPABISurf', 'FreeSurferLicense', 'license.txt'), WorkingDir);

Command=sprintf('%s x11vnc -forever -shared -usepw -create -rfbport 5925 &',CommandInit);

system(Command);

uiwait(msgbox('Please open a VNC viewer and connect to localhost:5925. The password is "dpabi". You can enjoy the GUI there. Tips: first input "bash" to get life easier.','VNC Viewer with DPABI Docker'));





    
    
    
    


% --- Executes on button press in pushbuttonRMPSurf.
function pushbuttonRMPSurf_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRMPSurf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[DPABIMessage WebStatus]=urlread('http://rfmri.org/RfMRIMapMessage.txt');
DPABIMessage='With this module, the results could be organized for future use, and to be accumulated for the future R-fMRI maps project.';
if WebStatus
    if ~isempty(DPABIMessage)
        uiwait(msgbox(DPABIMessage,'The R-fMRI Maps Project Message'));
    end
    DPABIMessageWeb=urlread('http://rfmri.org/RfMRIMapMessageWeb.txt');
    if ~isempty(DPABIMessageWeb)
        web(DPABIMessageWeb,'-browser');
    end
end

DPABI_ResultsOrganizer(0)


% --- Executes on button press in pushbuttonAnalysisSurf.
function pushbuttonAnalysisSurf_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAnalysisSurf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DPABI_Analysis


% --- Executes on button press in pushbuttonQC.
function pushbuttonQC_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonQC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DPABI_QC_Surf
