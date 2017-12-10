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

% Last Modified by GUIDE v2.5 08-Dec-2017 16:29:50

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


Release='V3.0_171210';
if ispc
    UserName =getenv('USERNAME');
else
    UserName =getenv('USER');
end
Datetime=fix(clock);
fprintf('Welcome: %s, %.4d-%.2d-%.2d %.2d:%.2d \n', UserName,Datetime(1),Datetime(2),Datetime(3),Datetime(4),Datetime(5));
fprintf('DPABI: a toolbox for Data Processing & Analysis of Brain Imaging.\nRelease = %s\n',Release);
fprintf('Copyright(c) 2014; GNU GENERAL PUBLIC LICENSE\n');
fprintf('Institute of Psychology, Chinese Academy of Sciences, 16 Lincui Road, Chaoyang District, Beijing 100101, China; ');
fprintf('The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962; Department of Child and Adolescent Psychiatry / NYU Langone Medical Center Child Study Center, New York University, New York, NY 10016; ');
fprintf('State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China\n');
fprintf('Mail to Initiator:  <a href="ycg.yan@gmail.com">YAN Chao-Gan</a>\nProgrammers: YAN Chao-Gan; WANG Xin-Di\n<a href="http://rfmri.org/dpabi">http://rfmri.org/dpabi</a>\n');
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
        web(DPABIMessageWeb);
    end
    
end

handles.output = hObject;

axes(handles.axes_logo);
axis image;
% imshow('dpabi.png');

if isunix&&(~ismac) %Linux has a alpha chanel problem, thus use a special logo image only for linux
    DPABIPath=fileparts(which('dpabi.m'));
    imshow(fullfile(DPABIPath, '.linux.dpabi.png'));
else
    [A, map, alpha] = imread('dpabi.png');
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


% --- Executes on button press in pushbutton_DPARSFA.
function pushbutton_DPARSFA_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_DPARSFA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPARSFA


% --- Executes on button press in pushbutton_DPARSFB.
function pushbutton_DPARSFB_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_DPARSFB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPARSF


% --- Executes on button press in pushbutton_DPARSFMonkey.
function pushbutton_DPARSFMonkey_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_DPARSFMonkey (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiwait(msgbox('The monkey module is based on Rhesus Macaque Atlases for functional and structural imaging studies generated by Wisconsin ADRC Imaging Core. Please cite these papers when appropriate: McLaren, D.G., Kosmatka, K.J., Oakes, T.R., Kroenke, C.D., Kohama, S.G., Matochik, J.A., Ingram, D.K., Johnson, S.C., 2009. A population-average MRI-based atlas collection of the rhesus macaque. Neuroimage 45, 52-59.; McLaren, D.G., Kosmatka, K.J., Kastman, E.K., Bendlin, B.B., Johnson, S.C., 2010. Rhesus macaque brain morphometry: a methodological comparison of voxel-wise approaches. Methods 50, 157-165.'));

button = questdlg('The origin of monkey atlas is different from human MNI atlas. Please make sure you are setting the correct origin for "reorienting Fun*" and "reorienting T1*". Do you want to have a look on the origin of monkey atlas?','Origin','Yes','No','No');
if strcmpi(button,'Yes')
    [DPABIPath, fileN, extn] = fileparts(which('DPABI.m'));
    TemplatePath=fullfile(DPABIPath, 'Templates');
    uiwait(w_Call_DPABI_VIEW([],[],[],[],[],[TemplatePath,filesep,'WisconsinRhesusMacaqueAtlases',filesep,'112RM-SL_T1.nii']));
end

[ProgramPath, fileN, extn] = fileparts(which('DPARSFA.m'));
DPARSFA([ProgramPath,filesep,'Jobmats',filesep,'Template_MonkeyProcessing.mat']);


% --- Executes on button press in pushbutton_DPARSFMonkey.
function pushbutton_DPARSFRat_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_DPARSFMonkey (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiwait(msgbox('The Rat module is based on a Rat T2 template generated by Dr. Adam J. Schwarz et al. Please cite this paper when appropriate: Schwarz, A.J., Danckaert, A., Reese, T., Gozzi, A., Paxinos, G., Watson, C., Merlo-Pich, E.V., Bifone, A., 2006. A stereotaxic MRI template set for the rat brain with tissue class distribution maps and co-registered anatomical atlas: application to pharmacological MRI. Neuroimage 32, 538-550. (A T1 template was included as well. It''s generated by normalizing 50 rats (two scans at PND45 or PND60) to that T2 template and then averaging (by Dr. Chao-Gan Yan)). '));

button = questdlg('Please make sure you are setting the correct origin of Rat atlas for "reorienting Fun*" and "reorienting T1*". Do you want to have a look on the origin of Rat atlas?','Origin','Yes','No','No');
if strcmpi(button,'Yes')
    [DPABIPath, fileN, extn] = fileparts(which('DPABI.m'));
    TemplatePath=fullfile(DPABIPath, 'Templates');
    uiwait(w_Call_DPABI_VIEW([],[],[],[],[],[TemplatePath,filesep,'SchwarzRatTemplates',filesep,'rat97t2w_96x96x30.v6.nii']));
end

msgbox('If you used DPARSF Rat module, please cite: Yan, C.G., Rincon-Cortes, M., Raineki, C., Sarro, E., Colcombe, S., Guilfoyle, D.N., Yang, Z., Gerum, S., Biswal, B.B., Milham, M.P., Sullivan, R.M., Castellanos, F.X., 2016. Aberrant development of intrinsic brain activity in a rat model of caregiver maltreatment of offspring. Transl Psychiatry 6, e?. doi:10.1038/tp.2016.276');

[ProgramPath, fileN, extn] = fileparts(which('DPARSFA.m'));
DPARSFA([ProgramPath,filesep,'Jobmats',filesep,'Template_RatProcessing.mat']);


% --- Executes on button press in pushbutton_TfMRIPreprocessing.
function pushbutton_TfMRIPreprocessing_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_TfMRIPreprocessing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[ProgramPath, fileN, extn] = fileparts(which('DPARSFA.m'));
DPARSFA([ProgramPath,filesep,'Jobmats',filesep,'Template_TaskfMRIPreprocessing.mat']);


% --- Executes on button press in pushbutton_VBM.
function pushbutton_VBM_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_VBM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[ProgramPath, fileN, extn] = fileparts(which('DPARSFA.m'));
DPARSFA([ProgramPath,filesep,'Jobmats',filesep,'Template_VBM_NewSegmentDARTEL.mat']);


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

% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
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
        web(DPABIMessageWeb);
    end
end

DPABI_ResultsOrganizer



% --- Executes on button press in pushbuttonTDA.
function pushbuttonTDA_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonTDA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABI_TDA
