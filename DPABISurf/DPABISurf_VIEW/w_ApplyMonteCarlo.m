function varargout = w_ApplyMonteCarlo(varargin)
% W_APPLYMONTECARLO MATLAB code for w_ApplyMonteCarlo.fig
%      W_APPLYMONTECARLO, by itself, creates a new W_APPLYMONTECARLO or raises the existing
%      singleton*.
%
%      H = W_APPLYMONTECARLO returns the handle to a new W_APPLYMONTECARLO or the handle to
%      the existing singleton*.
%
%      W_APPLYMONTECARLO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in W_APPLYMONTECARLO.M with the given input arguments.
%
%      W_APPLYMONTECARLO('Property','Value',...) creates a new W_APPLYMONTECARLO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before w_ApplyMonteCarlo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to w_ApplyMonteCarlo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help w_ApplyMonteCarlo

% Last Modified by GUIDE v2.5 12-Aug-2020 17:18:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @w_ApplyMonteCarlo_OpeningFcn, ...
                   'gui_OutputFcn',  @w_ApplyMonteCarlo_OutputFcn, ...
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


% --- Executes just before w_ApplyMonteCarlo is made visible.
function w_ApplyMonteCarlo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to w_ApplyMonteCarlo (see VARARGIN)
Header=varargin{1};

set(handles.FWHMEntry, 'String', num2str(Header.FWHM));
% Choose default command line output for w_ApplyMonteCarlo
handles.Header=Header;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes w_ApplyMonteCarlo wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = w_ApplyMonteCarlo_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    varargout{1}=[];
else
    varargout{1}=handles.Header;
    delete(handles.figure1);
end

function MaskEntry_Callback(hObject, eventdata, handles)
% hObject    handle to MaskEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaskEntry as text
%        str2double(get(hObject,'String')) returns contents of MaskEntry as a double


% --- Executes during object creation, after setting all properties.
function MaskEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaskEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MaskRmButton.
function MaskRmButton_Callback(hObject, eventdata, handles)
% hObject    handle to MaskRmButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.MaskEntry, 'String', '');

% --- Executes on button press in MaskAddButton.
function MaskAddButton_Callback(hObject, eventdata, handles)
% hObject    handle to MaskAddButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[File , Path]=uigetfile({'*.gii', 'All GIfTI Files (*.gii)';...
    '*.shape.gii;*.func.gii','Vertex Metric (*.shape.gii;*.func.gii)';...
    '*.*', 'All Files (*.*)';}, ...
    'Pick Vertex Mask File' , pwd);
if isnumeric(File)
    return
end
MskFile=fullfile(Path, File);
set(handles.MaskEntry, 'String', MskFile);

% --- Executes on button press in ComputeButton.
function ComputeButton_Callback(hObject, eventdata, handles)
% hObject    handle to ComputeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Surface Name
SurfValue=get(handles.SurfPopup, 'Value');
DPABISurfPath=fileparts(which('DPABISurf.m'));
switch SurfValue
    case 1 % Please select...
        errordlg('Please select the surface for simulation!');
        return
    case 2
        SurfName='fsaverage_lh_white.surf.gii';
    case 3
        SurfName='fsaverage_rh_white.surf.gii';    
    case 4
        SurfName='fsaverage5_lh_white.surf.gii';
    case 5
        SurfName='fsaverage5_rh_white.surf.gii';         
    otherwise
        error('Invalid Surface Name');
end
Header.SurfPath=fullfile(DPABISurfPath, 'SurfTemplates', SurfName);

% FWHM
FWHM=str2double(get(handles.FWHMEntry, 'String'));
if isnan(FWHM)
    errordlg('Invalid FWHM');
    uiresume(handles.figure1);
    return
end
Header.FWHM=FWHM;

% Iteration
M=str2double(get(handles.MEntry, 'String'));
if isnan(M)
    errordlg('Invalid Number of Iteration');
    uiresume(handles.figure1);
    return
end
Header.M=M;

% Vertex Mask File
Header.MskFile=get(handles.MaskEntry, 'String');

% Vertex Area File
Header.AreaFile=get(handles.AreaEntry, 'String');

% Vertex P Threshold
VertexP=str2double(get(handles.VertexPEntry, 'String'));
if isnan(VertexP)
    errordlg('Invalid Vertex P Threshold');
    uiresume(handles.figure1);
    return
end
Header.VertexP=VertexP;

% Alpha Level
Alpha=str2double(get(handles.AlphaEntry, 'String'));
if isnan(Alpha)
    errordlg('Invalid Cluster P Threshold');
    uiresume(handles.figure1);
    return
end
Header.Alpha=Alpha;

% Tailed 
TailedValue=get(handles.TailedPopup, 'Value');
switch TailedValue
    case 1
        Tailed=1;
    case 2
        Tailed=2;
end
Header.Tailed=Tailed;

% OutTxt
OutTxtName=get(handles.OutTxtEntry, 'String');
OutTxtPath=fullfile(pwd, [OutTxtName, '.txt']);
Header.OutTxtPath=OutTxtPath;

handles.Header=Header;
guidata(hObject, handles);

uiresume(handles.figure1);


function FWHMEntry_Callback(hObject, eventdata, handles)
% hObject    handle to FWHMEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FWHMEntry as text
%        str2double(get(hObject,'String')) returns contents of FWHMEntry as a double


% --- Executes during object creation, after setting all properties.
function FWHMEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FWHMEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SurfPopup.
function SurfPopup_Callback(hObject, eventdata, handles)
% hObject    handle to SurfPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SurfPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SurfPopup


% --- Executes during object creation, after setting all properties.
function SurfPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SurfPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AreaEntry_Callback(hObject, eventdata, handles)
% hObject    handle to AreaEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AreaEntry as text
%        str2double(get(hObject,'String')) returns contents of AreaEntry as a double


% --- Executes during object creation, after setting all properties.
function AreaEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AreaEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AreaRmButton.
function AreaRmButton_Callback(hObject, eventdata, handles)
% hObject    handle to AreaRmButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.AreaEntry, 'String', '');

% --- Executes on button press in AreaAddButton.
function AreaAddButton_Callback(hObject, eventdata, handles)
% hObject    handle to AreaAddButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[File , Path]=uigetfile({'*.gii', 'All GIfTI Files (*.gii)';...
    '*.shape.gii;*.func.gii','Vertex Metric (*.shape.gii;*.func.gii)';...
    '*.*', 'All Files (*.*)';}, ...
    'Pick Vertex Area File' , pwd);
if isnumeric(File)
    return
end
AreaFile=fullfile(Path, File);
set(handles.AreaEntry, 'String', AreaFile);

function MEntry_Callback(hObject, eventdata, handles)
% hObject    handle to MEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MEntry as text
%        str2double(get(hObject,'String')) returns contents of MEntry as a double


% --- Executes during object creation, after setting all properties.
function MEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function VertexPEntry_Callback(hObject, eventdata, handles)
% hObject    handle to VertexPEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of VertexPEntry as text
%        str2double(get(hObject,'String')) returns contents of VertexPEntry as a double


% --- Executes during object creation, after setting all properties.
function VertexPEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VertexPEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AlphaEntry_Callback(hObject, eventdata, handles)
% hObject    handle to AlphaEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AlphaEntry as text
%        str2double(get(hObject,'String')) returns contents of AlphaEntry as a double


% --- Executes during object creation, after setting all properties.
function AlphaEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AlphaEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in TailedPopup.
function TailedPopup_Callback(hObject, eventdata, handles)
% hObject    handle to TailedPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TailedPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TailedPopup


% --- Executes during object creation, after setting all properties.
function TailedPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TailedPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function OutTxtEntry_Callback(hObject, eventdata, handles)
% hObject    handle to OutTxtEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OutTxtEntry as text
%        str2double(get(hObject,'String')) returns contents of OutTxtEntry as a double


% --- Executes during object creation, after setting all properties.
function OutTxtEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OutTxtEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
