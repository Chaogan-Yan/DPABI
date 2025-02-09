function varargout = FieldmapFormat(varargin)
% FIELDMAPFORMAT MATLAB code for FieldmapFormat.fig
%      FIELDMAPFORMAT, by itself, creates a new FIELDMAPFORMAT or raises the existing
%      singleton*.
%
%      H = FIELDMAPFORMAT returns the handle to a new FIELDMAPFORMAT or the handle to
%      the existing singleton*.
%
%      FIELDMAPFORMAT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIELDMAPFORMAT.M with the given input arguments.
%
%      FIELDMAPFORMAT('Property','Value',...) creates a new FIELDMAPFORMAT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FieldmapFormat_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FieldmapFormat_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FieldmapFormat

% Last Modified by GUIDE v2.5 22-Jan-2025 15:27:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FieldmapFormat_OpeningFcn, ...
                   'gui_OutputFcn',  @FieldmapFormat_OutputFcn, ...
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


% --- Executes just before FieldmapFormat is made visible.
function FieldmapFormat_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FieldmapFormat (see VARARGIN)

% Choose default command line output for FieldmapFormat
if isempty(varargin)
    handles.FieldType.SessionName = 'fMRI';
    handles.FieldType.NiftiDir = pwd;
else
    handles.FieldType.SessionName = varargin{1};
    handles.FieldType.NiftiDir = varargin{2};
end

SubList = dir(handles.FieldType.NiftiDir);
Index=cellfun(...
    @(IsDir, NotDot) IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')), ...
    {SubList.isdir}, {SubList.name});
SubList=SubList(Index);
SubString={SubList(:).name}';
if ~isempty(SubString)
    handles.FieldType.NiftiList = dir([handles.FieldType.NiftiDir,filesep,SubString{1},filesep,'*.nii']); % use the fieldmaps in nifti format of the first subject as demos
else
    handles.FieldType.NiftiList = '';
end
if ~isempty(handles.FieldType.NiftiList)
    handles.FieldType.NiftiList = {handles.FieldType.NiftiList(:).name}';
end
    
set(handles.textTitle,'String',['Select fieldmap format for ',handles.FieldType.SessionName]);
set(handles.popupmenuPhaseDiff,'String',[{'Please select: ...'};handles.FieldType.NiftiList],'Value',1);        
set(handles.popupmenuMagnitude1_PhaseDiff,'String',[{'Please select: ...'};handles.FieldType.NiftiList],'Value',1);      
set(handles.popupmenuMagnitude2_PhaseDiff,'String',[{'Please select: ...'};handles.FieldType.NiftiList],'Value',1);        
set(handles.popupmenuPhase1,'String',[{'Please select: ...'};handles.FieldType.NiftiList],'Value',1);        
set(handles.popupmenuPhase2,'String',[{'Please select: ...'};handles.FieldType.NiftiList],'Value',1);        
set(handles.popupmenuMagnitude1,'String',[{'Please select: ...'};handles.FieldType.NiftiList],'Value',1);        
set(handles.popupmenuMagnitude2,'String',[{'Please select: ...'};handles.FieldType.NiftiList],'Value',1);       
set(handles.popupmenuB0Map,'String',[{'Please select: ...'};handles.FieldType.NiftiList],'Value',1);        
set(handles.popupmenuMagnitude_B0Map,'String',[{'Please select: ...'};handles.FieldType.NiftiList],'Value',1);     
set(handles.popupmenuTopup,'String',[{'Please select: ...'};handles.FieldType.NiftiList],'Value',1);        

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Make UI display correct in PC and linux
if ismac
    ZoonMatrix = [1 1 1.3 1.1];  %For mac % [1 1 1.7 1.1]
elseif ispc
    ZoonMatrix = [1 1 1.3 0.9];  %For pc % [1 1 1.6 0.9]
else
    ZoonMatrix = [1 1 1.3 1];  %For Linux % [1 1 1.6 1]
end
UISize = get(handles.figureFieldmapFormat,'Position');
UISize = UISize.*ZoonMatrix;
set(handles.figureFieldmapFormat,'Position',UISize);
movegui(handles.figureFieldmapFormat,'center');

% UIWAIT makes FieldmapFormat wait for user response (see UIRESUME)
uiwait(handles.figureFieldmapFormat);


% --- Outputs from this function are returned to the command line.
function varargout = FieldmapFormat_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    varargout{1} = [];
else
    varargout{1} = handles.FieldType;
    delete(handles.figureFieldmapFormat)
end

% --- Executes on button press in radiobuttonPhaseDiff.
function radiobuttonPhaseDiff_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonPhaseDiff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.FieldType.Format = 'PhaseDiff';
guidata(hObject,handles);
UpdateDisplay(handles)
% Hint: get(hObject,'Value') returns toggle state of radiobuttonPhaseDiff


% --- Executes on button press in radiobuttonPhase12.
function radiobuttonPhase12_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonPhase12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.FieldType.Format = 'Phase12';
guidata(hObject,handles);
UpdateDisplay(handles)
% Hint: get(hObject,'Value') returns toggle state of radiobuttonPhase12


% --- Executes on button press in radiobuttonTopup.
function radiobuttonTopup_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonTopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.FieldType.Format = 'Topup';
guidata(hObject,handles);
UpdateDisplay(handles)
% Hint: get(hObject,'Value') returns toggle state of radiobuttonTopup


% --- Executes on selection change in popupmenuPhaseDiff.
function popupmenuPhaseDiff_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuPhaseDiff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Index = get(handles.popupmenuPhaseDiff,'Value')-1; % minus "please select ..."
NiftiName = handles.FieldType.NiftiList{Index};
temp = strsplit(NiftiName,'_');
Suffix = strsplit(temp{end},'.');
handles.FieldType.Suffix.PhaseDiff = Suffix{1};
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuPhaseDiff contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuPhaseDiff


% --- Executes during object creation, after setting all properties.
function popupmenuPhaseDiff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuPhaseDiff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuMagnitude1_PhaseDiff.
function popupmenuMagnitude1_PhaseDiff_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuMagnitude1_PhaseDiff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Index = get(handles.popupmenuMagnitude1_PhaseDiff,'Value')-1; % minus "please select ..."
NiftiName = handles.FieldType.NiftiList{Index};
temp = strsplit(NiftiName,'_');
Suffix = strsplit(temp{end},'.');
handles.FieldType.Suffix.Magnitude1_PhaseDiff = Suffix{1};
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuMagnitude1_PhaseDiff contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuMagnitude1_PhaseDiff


% --- Executes during object creation, after setting all properties.
function popupmenuMagnitude1_PhaseDiff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuMagnitude1_PhaseDiff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuMagnitude2.
function popupmenuMagnitude2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuMagnitude2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Index = get(handles.popupmenuMagnitude2,'Value')-1; % minus "please select ..."
NiftiName = handles.FieldType.NiftiList{Index};
temp = strsplit(NiftiName,'_');
Suffix = strsplit(temp{end},'.');
handles.FieldType.Suffix.Magnitude2 = Suffix{1};
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuMagnitude2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuMagnitude2


% --- Executes during object creation, after setting all properties.
function popupmenuMagnitude2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuMagnitude2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuMagnitude1.
function popupmenuMagnitude1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuMagnitude1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Index = get(handles.popupmenuMagnitude1,'Value')-1; % minus "please select ..."
NiftiName = handles.FieldType.NiftiList{Index};
temp = strsplit(NiftiName,'_');
Suffix = strsplit(temp{end},'.');
handles.FieldType.Suffix.Magnitude1 = Suffix{1};
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuMagnitude1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuMagnitude1


% --- Executes during object creation, after setting all properties.
function popupmenuMagnitude1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuMagnitude1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuPhase2.
function popupmenuPhase2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuPhase2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Index = get(handles.popupmenuPhase2,'Value')-1; % minus "please select ..."
NiftiName = handles.FieldType.NiftiList{Index};
temp = strsplit(NiftiName,'_');
% Suffix = strsplit(temp{end},'.');
Suffix = strsplit([temp{end-1},'_',temp{end}],'.'); % Of note, the suffix of phase map doesn't have number index, therefore the echo index before '_ph' must be used to differentiate phase maps
handles.FieldType.Suffix.Phase2 = Suffix{1};
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuPhase2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuPhase2


% --- Executes during object creation, after setting all properties.
function popupmenuPhase2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuPhase2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuPhase1.
function popupmenuPhase1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuPhase1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Index = get(handles.popupmenuPhase1,'Value')-1; % minus "please select ..."
NiftiName = handles.FieldType.NiftiList{Index};
temp = strsplit(NiftiName,'_');
% Suffix = strsplit(temp{end},'.');
Suffix = strsplit([temp{end-1},'_',temp{end}],'.'); % Of note, the suffix of phase map doesn't have number index, therefore the echo index before '_ph' must be used to differentiate phase maps
handles.FieldType.Suffix.Phase1 = Suffix{1};
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuPhase1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuPhase1


% --- Executes during object creation, after setting all properties.
function popupmenuPhase1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuPhase1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobuttonB0Map.
function radiobuttonB0Map_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonB0Map (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.FieldType.Format = 'B0Map';
guidata(hObject,handles);
UpdateDisplay(handles)
% Hint: get(hObject,'Value') returns toggle state of radiobuttonB0Map


% --- Executes on selection change in popupmenuB0Map.
function popupmenuB0Map_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuB0Map (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Index = get(handles.popupmenuB0Map,'Value')-1; % minus "please select ..."
NiftiName = handles.FieldType.NiftiList{Index};
temp = strsplit(NiftiName,'_');
Suffix = strsplit(temp{end},'.');
handles.FieldType.Suffix.B0Map = Suffix{1};
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuB0Map contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuB0Map


% --- Executes during object creation, after setting all properties.
function popupmenuB0Map_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuB0Map (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuMagnitude_B0Map.
function popupmenuMagnitude_B0Map_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuMagnitude_B0Map (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Index = get(handles.popupmenuMagnitude_B0Map,'Value')-1; % minus "please select ..."
NiftiName = handles.FieldType.NiftiList{Index};
temp = strsplit(NiftiName,'_');
Suffix = strsplit(temp{end},'.');
handles.FieldType.Suffix.Magnitude_B0Map = Suffix{1};
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuMagnitude_B0Map contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuMagnitude_B0Map


% --- Executes during object creation, after setting all properties.
function popupmenuMagnitude_B0Map_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuMagnitude_B0Map (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuTopup.
function popupmenuTopup_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuTopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Index = get(handles.popupmenuTopup,'Value')-1; % minus "please select ..."
NiftiName = handles.FieldType.NiftiList{Index};
temp = strsplit(NiftiName,'_');
Suffix = strsplit(temp{end},'.');
handles.FieldType.Suffix.Topup = Suffix{1};
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuTopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuTopup


% --- Executes during object creation, after setting all properties.
function popupmenuTopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuTopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonOK.
function pushbuttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figureFieldmapFormat);



function UpdateDisplay(handles)
switch handles.FieldType.Format
    case 'PhaseDiff'
        set(handles.radiobuttonPhaseDiff,'Value',1);
        set(handles.popupmenuPhaseDiff,'Enable','on');
        set(handles.popupmenuMagnitude1_PhaseDiff,'Enable','on');
        set(handles.popupmenuMagnitude2_PhaseDiff,'Enable','on');
        set(handles.textPhaseDiff,'Enable','on');
        set(handles.textMagnitude1_PhaseDiff,'Enable','on');
        set(handles.textMagnitude2_PhaseDiff,'Enable','on');
        
        set(handles.radiobuttonPhase12,'Value',0);
        set(handles.popupmenuPhase1,'Enable','off');
        set(handles.popupmenuPhase2,'Enable','off');
        set(handles.popupmenuMagnitude1,'Enable','off');
        set(handles.popupmenuMagnitude2,'Enable','off');
        set(handles.textPhase1,'Enable','off');
        set(handles.textPhase2,'Enable','off');
        set(handles.textMagnitude1,'Enable','off');
        set(handles.textMagnitude2,'Enable','off');

        set(handles.radiobuttonB0Map,'Value',0);
        set(handles.popupmenuB0Map,'Enable','off');
        set(handles.popupmenuMagnitude_B0Map,'Enable','off');
        set(handles.textB0Map,'Enable','off');
        set(handles.textMagnitude_B0Map,'Enable','off');
        
        set(handles.radiobuttonTopup,'Value',0);
        set(handles.popupmenuTopup,'Enable','off');
        set(handles.textTopup,'Enable','off');
        
    case 'Phase12'
        set(handles.radiobuttonPhaseDiff,'Value',0);
        set(handles.popupmenuPhaseDiff,'Enable','off');
        set(handles.popupmenuMagnitude1_PhaseDiff,'Enable','off');
        set(handles.popupmenuMagnitude2_PhaseDiff,'Enable','off');
        set(handles.textPhaseDiff,'Enable','off');
        set(handles.textMagnitude1_PhaseDiff,'Enable','off');
        set(handles.textMagnitude2_PhaseDiff,'Enable','off');
        
        set(handles.radiobuttonPhase12,'Value',1);
        set(handles.popupmenuPhase1,'Enable','on');
        set(handles.popupmenuPhase2,'Enable','on');
        set(handles.popupmenuMagnitude1,'Enable','on');
        set(handles.popupmenuMagnitude2,'Enable','on');
        set(handles.textPhase1,'Enable','on');
        set(handles.textPhase2,'Enable','on');
        set(handles.textMagnitude1,'Enable','on');
        set(handles.textMagnitude2,'Enable','on');
        
        set(handles.radiobuttonB0Map,'Value',0);
        set(handles.popupmenuB0Map,'Enable','off');
        set(handles.popupmenuMagnitude_B0Map,'Enable','off');
        set(handles.textB0Map,'Enable','off');
        set(handles.textMagnitude_B0Map,'Enable','off');
        
        set(handles.radiobuttonTopup,'Value',0);
        set(handles.popupmenuTopup,'Enable','off');
        set(handles.textTopup,'Enable','off');
        
    case 'B0Map'
        set(handles.radiobuttonPhaseDiff,'Value',0);
        set(handles.popupmenuPhaseDiff,'Enable','off');
        set(handles.popupmenuMagnitude1_PhaseDiff,'Enable','off');
        set(handles.popupmenuMagnitude2_PhaseDiff,'Enable','off');
        set(handles.textPhaseDiff,'Enable','off');
        set(handles.textMagnitude1_PhaseDiff,'Enable','off');
        set(handles.textMagnitude2_PhaseDiff,'Enable','off');
        
        set(handles.radiobuttonPhase12,'Value',0);
        set(handles.popupmenuPhase1,'Enable','off');
        set(handles.popupmenuPhase2,'Enable','off');
        set(handles.popupmenuMagnitude1,'Enable','off');
        set(handles.popupmenuMagnitude2,'Enable','off');
        set(handles.textPhase1,'Enable','off');
        set(handles.textPhase2,'Enable','off');
        set(handles.textMagnitude1,'Enable','off');
        set(handles.textMagnitude2,'Enable','off');
        
        set(handles.radiobuttonB0Map,'Value',1);
        set(handles.popupmenuB0Map,'Enable','on');
        set(handles.popupmenuMagnitude_B0Map,'Enable','on');
        set(handles.textB0Map,'Enable','on');
        set(handles.textMagnitude_B0Map,'Enable','on');
        
        set(handles.radiobuttonTopup,'Value',0);
        set(handles.popupmenuTopup,'Enable','off');
        set(handles.textTopup,'Enable','off');        
        
    case 'Topup'
        set(handles.radiobuttonPhaseDiff,'Value',0);
        set(handles.popupmenuPhaseDiff,'Enable','off');
        set(handles.popupmenuMagnitude1_PhaseDiff,'Enable','off');
        set(handles.popupmenuMagnitude2_PhaseDiff,'Enable','off');
        set(handles.textPhaseDiff,'Enable','off');
        set(handles.textMagnitude1_PhaseDiff,'Enable','off');
        set(handles.textMagnitude2_PhaseDiff,'Enable','off');
        
        set(handles.radiobuttonPhase12,'Value',0);
        set(handles.popupmenuPhase1,'Enable','off');
        set(handles.popupmenuPhase2,'Enable','off');
        set(handles.popupmenuMagnitude1,'Enable','off');
        set(handles.popupmenuMagnitude2,'Enable','off');
        set(handles.textPhase1,'Enable','off');
        set(handles.textPhase2,'Enable','off');
        set(handles.textMagnitude1,'Enable','off');
        set(handles.textMagnitude2,'Enable','off');
        
        set(handles.radiobuttonB0Map,'Value',0);
        set(handles.popupmenuB0Map,'Enable','off');
        set(handles.popupmenuMagnitude_B0Map,'Enable','off');
        set(handles.textB0Map,'Enable','off');
        set(handles.textMagnitude_B0Map,'Enable','off');
        
        set(handles.radiobuttonTopup,'Value',1);
        set(handles.popupmenuTopup,'Enable','on');
        set(handles.textTopup,'Enable','on');
end


% --- Executes on selection change in popupmenuMagnitude2_PhaseDiff.
function popupmenuMagnitude2_PhaseDiff_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuMagnitude2_PhaseDiff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Index = get(handles.popupmenuMagnitude2_PhaseDiff,'Value')-1; % minus "please select ..."
NiftiName = handles.FieldType.NiftiList{Index};
temp = strsplit(NiftiName,'_');
Suffix = strsplit(temp{end},'.');
handles.FieldType.Suffix.Magnitude2_PhaseDiff = Suffix{1};
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuMagnitude2_PhaseDiff contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuMagnitude2_PhaseDiff


% --- Executes during object creation, after setting all properties.
function popupmenuMagnitude2_PhaseDiff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuMagnitude2_PhaseDiff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
