function varargout = DPABI_ConcordanceSelect_Surf(varargin)
% DPABI_CONCORDANCESELECT MATLAB code for DPABI_ConcordanceSelect.fig
%      DPABI_CONCORDANCESELECT, by itself, creates a new DPABI_CONCORDANCESELECT or raises the existing
%      singleton*.
%
%      H = DPABI_CONCORDANCESELECT returns the handle to a new DPABI_CONCORDANCESELECT or the handle to
%      the existing singleton*.
%
%      DPABI_CONCORDANCESELECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABI_CONCORDANCESELECT.M with the given input arguments.
%
%      DPABI_CONCORDANCESELECT('Property','Value',...) creates a new DPABI_CONCORDANCESELECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABI_ConcordanceSelect_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABI_ConcordanceSelect_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABI_ConcordanceSelect

% Last Modified by GUIDE v2.5 03-Jul-2018 14:47:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABI_ConcordanceSelect_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABI_ConcordanceSelect_OutputFcn, ...
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


% --- Executes just before DPABI_ConcordanceSelect is made visible.
function DPABI_ConcordanceSelect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABI_ConcordanceSelect (see VARARGIN)

% Choose default command line output for DPABI_ConcordanceSelect
handles.output = hObject;

MeasuresSelected=varargin{1}{1};
Sep=strfind(MeasuresSelected,';');
Sep=[0 Sep length(MeasuresSelected)+1];
for iMeasure=1:length(Sep)-1
    Measure=MeasuresSelected(Sep(iMeasure)+1:Sep(iMeasure+1)-1);
    switch Measure
        case 'ALFF'
            set(handles.checkboxALFF, 'Value', 1);
        case 'fALFF'
            set(handles.checkboxfALFF, 'Value', 1);
        case 'ReHo'
            set(handles.checkboxReHo, 'Value', 1);
        case 'DC'
            set(handles.checkboxDC, 'Value', 1);
        case 'GSCorr'
            set(handles.checkboxGSCorr, 'Value', 1);
    end
end


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABI_ConcordanceSelect wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DPABI_ConcordanceSelect_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;
varargout{1} = handles.MeasuresSelected;
delete(handles.figure1)


% --- Executes on button press in checkboxALFF.
function checkboxALFF_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxALFF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxALFF


% --- Executes on button press in checkboxfALFF.
function checkboxfALFF_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxfALFF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxfALFF


% --- Executes on button press in checkboxReHo.
function checkboxReHo_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxReHo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxReHo


% --- Executes on button press in checkboxDC.
function checkboxDC_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxDC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxDC


% --- Executes on button press in checkboxGSCorr.
function checkboxGSCorr_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxGSCorr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxGSCorr


% --- Executes on button press in pushbuttonOK.
function pushbuttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

MeasuresSelected='';
if get(handles.checkboxALFF,'Value');
    MeasuresSelected=['ALFF;'];
end
if get(handles.checkboxfALFF,'Value');
    MeasuresSelected=[MeasuresSelected,'fALFF;'];
end
if get(handles.checkboxReHo,'Value');
    MeasuresSelected=[MeasuresSelected,'ReHo;'];
end
if get(handles.checkboxDC,'Value');
    MeasuresSelected=[MeasuresSelected,'DC;'];
end
if get(handles.checkboxGSCorr,'Value');
    MeasuresSelected=[MeasuresSelected,'GSCorr'];
end

if strcmp(MeasuresSelected(end),';')
    MeasuresSelected=MeasuresSelected(1:end-1);
end

handles.MeasuresSelected=MeasuresSelected;
guidata(hObject, handles);
uiresume(handles.figure1);

    
