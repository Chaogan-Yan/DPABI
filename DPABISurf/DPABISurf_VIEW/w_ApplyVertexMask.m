function varargout = w_ApplyVertexMask(varargin)
% W_APPLYVERTEXMASK MATLAB code for w_ApplyVertexMask.fig
%      W_APPLYVERTEXMASK, by itself, creates a new W_APPLYVERTEXMASK or raises the existing
%      singleton*.
%
%      H = W_APPLYVERTEXMASK returns the handle to a new W_APPLYVERTEXMASK or the handle to
%      the existing singleton*.
%
%      W_APPLYVERTEXMASK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in W_APPLYVERTEXMASK.M with the given input arguments.
%
%      W_APPLYVERTEXMASK('Property','Value',...) creates a new W_APPLYVERTEXMASK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before w_ApplyVertexMask_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to w_ApplyVertexMask_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help w_ApplyVertexMask

% Last Modified by GUIDE v2.5 10-Apr-2019 12:28:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @w_ApplyVertexMask_OpeningFcn, ...
                   'gui_OutputFcn',  @w_ApplyVertexMask_OutputFcn, ...
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


% --- Executes just before w_ApplyVertexMask is made visible.
function w_ApplyVertexMask_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to w_ApplyVertexMask (see VARARGIN)
OverlayHeader=varargin{1};

set(handles.ThresEntry, 'String', num2str(OverlayHeader.VMskThres));
set(handles.MaskEntry,  'String', OverlayHeader.VMskFile);
if strcmpi(OverlayHeader.VMskSignFlag, '<')
    set(handles.SignPopup,  'Value', 1);
elseif strcmpi(OverlayHeader.VMskSignFlag, '>')
    set(handles.SignPopup,  'Value', 2);    
end
% Choose default command line output for w_ApplyVertexMask
handles.OverlayHeader=OverlayHeader;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes w_ApplyVertexMask wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = w_ApplyVertexMask_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    varargout{1}=[];
else
    varargout{1}=handles.OverlayHeader;
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


% --- Executes on button press in RemoveButton.
function RemoveButton_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.MaskEntry, 'String', '');
handles.OverlayHeader.VMskFile='';
handles.OverlayHeader.VMsk=true(size(handles.OverlayHeader.VMsk));
guidata(hObject, handles);

% --- Executes on button press in AddButton.
function AddButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[File , Path]=uigetfile({'*.gii', 'All GIfTI Files (*.gii)';...
    '*.shape.gii;*.func.gii','Vertex Metric (*.shape.gii;*.func.gii)';...
    '*.*', 'All Files (*.*)';}, ...
    'Pick Vertex Mask File' , pwd);
if isnumeric(File)
    return
end
VMskFile=fullfile(Path, File);
handles.OverlayHeader.VMskFile=VMskFile;
set(handles.MaskEntry, 'String', VMskFile);

guidata(hObject, handles);


% --- Executes on button press in ComputeButton.
function ComputeButton_Callback(hObject, eventdata, handles)
% hObject    handle to ComputeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
OverlayHeader=handles.OverlayHeader;

VMskThres=str2num(get(handles.ThresEntry, 'String'));
if get(handles.SignPopup, 'Value')==1 % <
    VMskSignFlag='<';
elseif get(handles.SignPopup, 'Value')==2 % >
    VMskSignFlag='>';
else
    error('Invalid Sign');
end

OverlayHeader.VMskThres=VMskThres;
OverlayHeader.VMskSignFlag=VMskSignFlag;

if ~isempty(OverlayHeader.VMskFile)
    MskV=gifti(OverlayHeader.VMskFile);
    if length(MskV.cdata)~=length(OverlayHeader.VMsk)
        errordlg('Invalid Size of Vertex Mask!');
        uiresume(handles.figure1);
        return
    end
    if isempty(VMskThres)
        errordlg('Invalid Threshold!');
        uiresume(handles.figure1);
        return
    end
    
    if strcmpi(VMskSignFlag, '<')
        OverlayHeader.VMsk=MskV.cdata<VMskThres;
    elseif strcmpi(VMskSignFlag, '>')
        OverlayHeader.VMsk=MskV.cdata>VMskThres;        
    end
end
handles.OverlayHeader=OverlayHeader;
guidata(hObject, handles);
uiresume(handles.figure1);


function ThresEntry_Callback(hObject, eventdata, handles)
% hObject    handle to ThresEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ThresEntry as text
%        str2double(get(hObject,'String')) returns contents of ThresEntry as a double


% --- Executes during object creation, after setting all properties.
function ThresEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ThresEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SignPopup.
function SignPopup_Callback(hObject, eventdata, handles)
% hObject    handle to SignPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SignPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SignPopup


% --- Executes during object creation, after setting all properties.
function SignPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SignPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
