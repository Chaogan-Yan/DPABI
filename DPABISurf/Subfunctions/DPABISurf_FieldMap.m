function varargout = DPABISurf_FieldMap(varargin)
% DPABISURF_FIELDMAP MATLAB code for DPABISurf_FieldMap.fig
%      DPABISURF_FIELDMAP, by itself, creates a new DPABISURF_FIELDMAP or raises the existing
%      singleton*.
%
%      H = DPABISURF_FIELDMAP returns the handle to a new DPABISURF_FIELDMAP or the handle to
%      the existing singleton*.
%
%      DPABISURF_FIELDMAP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABISURF_FIELDMAP.M with the given input arguments.
%
%      DPABISURF_FIELDMAP('Property','Value',...) creates a new DPABISURF_FIELDMAP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABISurf_FieldMap_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABISurf_FieldMap_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABISurf_FieldMap

% Last Modified by GUIDE v2.5 04-Dec-2019 09:54:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABISurf_FieldMap_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABISurf_FieldMap_OutputFcn, ...
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


% --- Executes just before DPABISurf_FieldMap is made visible.
function DPABISurf_FieldMap_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABISurf_FieldMap (see VARARGIN)

if nargin<4
    FieldMap.IsNeedConvertDCM2IMG=1;
    FieldMap.IsApplyFieldMapCorrection=1;
    FieldMap.TE1=0;
    FieldMap.TE2=0;
else
    FieldMap=varargin{1};
end

set(handles.DICOM2NIFTI,'Value',FieldMap.IsNeedConvertDCM2IMG);
set(handles.If_ApplyCorrection,'Value',FieldMap.IsApplyFieldMapCorrection);
set(handles.ShortTimeInput,'String',num2str(FieldMap.TE1));
set(handles.LongTimeInput,'String',num2str(FieldMap.TE2));

% Update handles structure
handles.FieldMap=FieldMap;

% Make UI display correct in PC and linux
if ismac
    ZoonMatrix = [1 1 2 1.6];  %For mac
elseif ispc
    ZoonMatrix = [1 1 1.8 1.5];  %For pc
else
    ZoonMatrix = [1 1 1.5 1.5];  %For Linux
end
UISize = get(handles.DPABISurf_FieldMap,'Position');
UISize = UISize.*ZoonMatrix;
set(handles.DPABISurf_FieldMap,'Position',UISize);

movegui(handles.DPABISurf_FieldMap,'center');


guidata(hObject, handles);

% UIWAIT makes DPARSF_FieldMap wait for user response (see UIRESUME)
uiwait(handles.DPABISurf_FieldMap);


% --- Outputs from this function are returned to the command line.
function varargout = DPABISurf_FieldMap_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    varargout{1} = [];
else
    varargout{1} = handles.FieldMap;
    delete(handles.DPABISurf_FieldMap)
end


% --- Executes on button press in DICOM2NIFTI.
function DICOM2NIFTI_Callback(hObject, eventdata, handles)
% hObject    handle to DICOM2NIFTI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DICOM2NIFTI


function ShortTimeInput_Callback(hObject, eventdata, handles)
% hObject    handle to ShortTimeInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ShortTimeInput as text
%        str2double(get(hObject,'String')) returns contents of ShortTimeInput as a double


% --- Executes during object creation, after setting all properties.
function ShortTimeInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ShortTimeInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LongTimeInput_Callback(hObject, eventdata, handles)
% hObject    handle to LongTimeInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LongTimeInput as text
%        str2double(get(hObject,'String')) returns contents of LongTimeInput as a double


% --- Executes during object creation, after setting all properties.
function LongTimeInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LongTimeInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in If_EPIBased.
function If_EPIBased_Callback(hObject, eventdata, handles)
% hObject    handle to If_EPIBased (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of If_EPIBased


% --- Executes on button press in If_ApplyCorrection.
function If_ApplyCorrection_Callback(hObject, eventdata, handles)
% hObject    handle to If_ApplyCorrection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of If_ApplyCorrection


% --- Executes on button press in AcceptButton.
function AcceptButton_Callback(hObject, eventdata, handles)
% hObject    handle to AcceptButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FieldMap.IsNeedConvertDCM2IMG=get(handles.DICOM2NIFTI,'Value');
FieldMap.IsApplyFieldMapCorrection=get(handles.If_ApplyCorrection,'Value');
shortT=get(handles.ShortTimeInput,'String');
shortT=str2num(shortT);
longT=get(handles.LongTimeInput,'String');
longT=str2num(longT);
FieldMap.TE1=shortT;
FieldMap.TE2=longT;

handles.FieldMap=FieldMap;
guidata(hObject, handles);
uiresume(handles.DPABISurf_FieldMap);
