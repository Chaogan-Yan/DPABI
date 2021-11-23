function varargout = DPARSF_FieldMap(varargin)
% DPARSF_FIELDMAP MATLAB code for DPARSF_FieldMap.fig
%      DPARSF_FIELDMAP, by itself, creates a new DPARSF_FIELDMAP or raises the existing
%      singleton*.
%
%      H = DPARSF_FIELDMAP returns the handle to a new DPARSF_FIELDMAP or the handle to
%      the existing singleton*.
%
%      DPARSF_FIELDMAP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPARSF_FIELDMAP.M with the given input arguments.
%
%      DPARSF_FIELDMAP('Property','Value',...) creates a new DPARSF_FIELDMAP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPARSF_FieldMap_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPARSF_FieldMap_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPARSF_FieldMap

% Last Modified by GUIDE v2.5 04-Dec-2019 09:06:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPARSF_FieldMap_OpeningFcn, ...
                   'gui_OutputFcn',  @DPARSF_FieldMap_OutputFcn, ...
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


% --- Executes just before DPARSF_FieldMap is made visible.
function DPARSF_FieldMap_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPARSF_FieldMap (see VARARGIN)

if nargin<4
    FieldMap.IsNeedConvertDCM2IMG=1;
    FieldMap.IsCalculateVDM=1;
    FieldMap.EPIBasedFieldMap=0;
    FieldMap.IsFieldMapCorrectionUnwarpRealign=1;
    FieldMap.TE1=0;
    FieldMap.TE2=0;
    FieldMap.DataFormat='PhaseDiffMagnitude';
else
    FieldMap=varargin{1};
end

set(handles.DICOM2NIFTI,'Value',FieldMap.IsNeedConvertDCM2IMG);
set(handles.VDM,'Value',FieldMap.IsCalculateVDM);
set(handles.If_EPIBased,'Value',FieldMap.EPIBasedFieldMap);
set(handles.If_ApplyCorrection,'Value',FieldMap.IsFieldMapCorrectionUnwarpRealign);
set(handles.ShortTimeInput,'String',num2str(FieldMap.TE1));
set(handles.LongTimeInput,'String',num2str(FieldMap.TE2));
if strcmpi(FieldMap.DataFormat,'PhaseDiffMagnitude')
    set(handles.Data1,'Value',1);
    set(handles.Data2,'Value',0);
elseif strcmpi(FieldMap.DataFormat,'TwoPhaseMagnitude')
    set(handles.Data1,'Value',0);
    set(handles.Data2,'Value',1);
else
    set(handles.Data1,'Value',0);
    set(handles.Data2,'Value',0);
end

% Update handles structure
handles.FieldMap=FieldMap;

% Make UI display correct in PC and linux
if ismac
    ZoonMatrix = [1 1 1.8 1.8];  %For mac
elseif ispc
    ZoonMatrix = [1 1 1.5 1.5];  %For pc
else
    ZoonMatrix = [1 1 1.7 1.5];  %For Linux
end
UISize = get(handles.DPARSF_FieldMap,'Position');
UISize = UISize.*ZoonMatrix;
set(handles.DPARSF_FieldMap,'Position',UISize);
movegui(handles.DPARSF_FieldMap,'center');


guidata(hObject, handles);

% UIWAIT makes DPARSF_FieldMap wait for user response (see UIRESUME)
uiwait(handles.DPARSF_FieldMap);


% --- Outputs from this function are returned to the command line.
function varargout = DPARSF_FieldMap_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;
if isempty(handles)
    varargout{1} = [];
else
    varargout{1} = handles.FieldMap;
    delete(handles.DPARSF_FieldMap)
end


% --- Executes on button press in DICOM2NIFTI.
function DICOM2NIFTI_Callback(hObject, eventdata, handles)
% hObject    handle to DICOM2NIFTI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DICOM2NIFTI


% --- Executes on button press in VDM.
function VDM_Callback(hObject, eventdata, handles)
% hObject    handle to VDM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of VDM


% --- Executes on button press in Data1.
function Data1_Callback(hObject, eventdata, handles)
% hObject    handle to Data1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.Data1,'Value',1);
set(handles.Data2,'Value',0);

% Hint: get(hObject,'Value') returns toggle state of Data1


% --- Executes on button press in Data2.
function Data2_Callback(hObject, eventdata, handles)
% hObject    handle to Data2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.Data1,'Value',0);
set(handles.Data2,'Value',1);

% Hint: get(hObject,'Value') returns toggle state of Data2



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
FieldMap.IsCalculateVDM=get(handles.VDM,'Value');
FieldMap.EPIBasedFieldMap=get(handles.If_EPIBased,'Value');
FieldMap.IsFieldMapCorrectionUnwarpRealign=get(handles.If_ApplyCorrection,'Value');
shortT=get(handles.ShortTimeInput,'String');
shortT=str2num(shortT);
longT=get(handles.LongTimeInput,'String');
longT=str2num(longT);
FieldMap.TE1=shortT;
FieldMap.TE2=longT;
if get(handles.Data1,'Value')==1
    FieldMap.DataFormat='PhaseDiffMagnitude';
elseif get(handles.Data2,'Value')==1
    FieldMap.DataFormat='TwoPhaseMagnitude';
else
    FieldMap.DataFormat='Unknown';
end

handles.FieldMap=FieldMap;
guidata(hObject, handles);
uiresume(handles.DPARSF_FieldMap);
