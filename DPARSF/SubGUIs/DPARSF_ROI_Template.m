function varargout = DPARSF_ROI_Template(varargin)
% DPARSF_ROI_TEMPLATE MATLAB code for DPARSF_ROI_Template.fig
%      DPARSF_ROI_TEMPLATE, by itself, creates a new DPARSF_ROI_TEMPLATE or raises the existing
%      singleton*.
%
%      H = DPARSF_ROI_TEMPLATE returns the handle to a new DPARSF_ROI_TEMPLATE or the handle to
%      the existing singleton*.
%
%      DPARSF_ROI_TEMPLATE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPARSF_ROI_TEMPLATE.M with the given input arguments.
%
%      DPARSF_ROI_TEMPLATE('Property','Value',...) creates a new DPARSF_ROI_TEMPLATE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPARSF_ROI_Template_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPARSF_ROI_Template_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPARSF_ROI_Template

% Last Modified by GUIDE v2.5 04-Sep-2012 23:08:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPARSF_ROI_Template_OpeningFcn, ...
                   'gui_OutputFcn',  @DPARSF_ROI_Template_OutputFcn, ...
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


% --- Executes just before DPARSF_ROI_Template is made visible.
function DPARSF_ROI_Template_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPARSF_ROI_Template (see VARARGIN)

% Choose default command line output for DPARSF_ROI_Template
%handles.Choose = 2;


if ~isempty(varargin),
    handles.ROIDef = varargin{1};
    handles.IsMultipleLabel = varargin{2};
    set (handles.checkboxMultiLabel,'Value',handles.IsMultipleLabel);
    
else
    handles.ROIDef = [];
    handles.IsMultipleLabel=0;
end



% Make Display correct in linux
if ~ismac
    ZoomFactor=0.85;
    ObjectNames = fieldnames(handles);
    for i=1:length(ObjectNames);
        eval(['IsFontSizeProp=isprop(handles.',ObjectNames{i},',''FontSize'');']);
        if IsFontSizeProp
            eval(['PCFontSize=get(handles.',ObjectNames{i},',''FontSize'');']);
            FontSize=PCFontSize*ZoomFactor;
            eval(['set(handles.',ObjectNames{i},',''FontSize'',',num2str(FontSize),');']);
        end
    end
end



% Update handles structure
guidata(hObject, handles);

try
	uiwait(handles.figure1);
catch
	uiresume(handles.figure1);
end


% UIWAIT makes DPARSF_ROI_Template wait for user response (see UIRESUME)
% uiwait(handles.figure1);





% --- Outputs from this function are returned to the command line.
function varargout = DPARSF_ROI_Template_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.ROIDef;
varargout{2} = handles.IsMultipleLabel;
delete(handles.figure1);



% --- Executes on button press in checkboxMultiLabel.
function checkboxMultiLabel_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.IsMultipleLabel = 1;
        %handles.Cfg.IsNeedConvert4DFunInto3DImg = 0;
	else	
		handles.IsMultipleLabel = 0;
    end	
	guidata(hObject, handles);



% --- Executes on button press in pushbuttonAAL.
function pushbuttonAAL_Callback(hObject, eventdata, handles)
[ProgramPath, fileN, extn] = fileparts(which('dpabi.m'));
handles.ROIDef = {[ProgramPath,filesep,'Templates',filesep,'aal.nii']};
handles.IsMultipleLabel = 1;
guidata(hObject, handles);
drawnow;
uiresume(handles.figure1);




% --- Executes on button press in pushbuttonHOA.
function pushbuttonHOA_Callback(hObject, eventdata, handles)
[ProgramPath, fileN, extn] = fileparts(which('dpabi.m'));
handles.ROIDef = {[ProgramPath,filesep,'Templates',filesep,'HarvardOxford-cort-maxprob-thr25-2mm_YCG.nii'];[ProgramPath,filesep,'Templates',filesep,'HarvardOxford-sub-maxprob-thr25-2mm_YCG.nii']};
handles.IsMultipleLabel = 1;
guidata(hObject, handles);
drawnow;
uiresume(handles.figure1);




% --- Executes on button press in pushbuttonDos160.
function pushbuttonDos160_Callback(hObject, eventdata, handles)
[ProgramPath, fileN, extn] = fileparts(which('dpabi.m'));
load([ProgramPath,filesep,'Templates',filesep,'Dosenbach_Science_160ROIs_Center.mat']);

ROICenter=Dosenbach_Science_160ROIs_Center;

ROIRadius=5;
for iROI=1:size(ROICenter,1)
    ROIDef{iROI,1}=[ROICenter(iROI,:), ROIRadius];
end

handles.ROIDef = ROIDef;

guidata(hObject, handles);
drawnow;
uiresume(handles.figure1);


% --- Executes on button press in pushbuttonDMNROI.
function pushbuttonDMNROI_Callback(hObject, eventdata, handles)
ROICenter_AndrewsHanna=[-6 52 -2; -8 -56 26; 0 52 26; -54 -54 28; -60 -24 -18; -50 14 -40; 0 26 -18; -44 -74 32; -14 -52 8; -28 -40 -12; -22 -20 -26]; 

ROICenter=ROICenter_AndrewsHanna;

ROIRadius=5;
for iROI=1:size(ROICenter,1)
    ROIDef{iROI,1}=[ROICenter(iROI,:), ROIRadius];
end

handles.ROIDef = ROIDef;

guidata(hObject, handles);
drawnow;
uiresume(handles.figure1);


% --- Executes on button press in pushbuttonCC200.
function pushbuttonCC200_Callback(hObject, eventdata, handles)
[ProgramPath, fileN, extn] = fileparts(which('dpabi.m'));
handles.ROIDef = {[ProgramPath,filesep,'Templates',filesep,'CC200ROI_tcorr05_2level_all.nii']};
handles.IsMultipleLabel = 1;
guidata(hObject, handles);
drawnow;
uiresume(handles.figure1);





% --- Executes on button press in pushbuttonOtherROI.
function pushbuttonOtherROI_Callback(hObject, eventdata, handles)
handles.ROIDef = [];
guidata(hObject, handles);
drawnow;
uiresume(handles.figure1);


  
