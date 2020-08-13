function varargout = w_ApplyFDR(varargin)
% W_APPLYFDR MATLAB code for w_ApplyFDR.fig
%      W_APPLYFDR, by itself, creates a new W_APPLYFDR or raises the existing
%      singleton*.
%
%      H = W_APPLYFDR returns the handle to a new W_APPLYFDR or the handle to
%      the existing singleton*.
%
%      W_APPLYFDR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in W_APPLYFDR.M with the given input arguments.
%
%      W_APPLYFDR('Property','Value',...) creates a new W_APPLYFDR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before w_ApplyFDR_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to w_ApplyFDR_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help w_ApplyFDR

% Last Modified by GUIDE v2.5 13-Aug-2020 18:25:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @w_ApplyFDR_OpeningFcn, ...
                   'gui_OutputFcn',  @w_ApplyFDR_OutputFcn, ...
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


% --- Executes just before w_ApplyFDR is made visible.
function w_ApplyFDR_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to w_ApplyFDR (see VARARGIN)

% Choose default command line output for w_ApplyFDR

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes w_ApplyFDR wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = w_ApplyFDR_OutputFcn(hObject, eventdata, handles) 
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


% --- Executes on button press in RemoveButton.
function RemoveButton_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.MaskEntry, 'String', '');

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
set(handles.MaskEntry, 'String', VMskFile);

% --- Executes on button press in ComputeButton.
function ComputeButton_Callback(hObject, eventdata, handles)
% hObject    handle to ComputeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Vertex Msk
VMskFile=get(handles.MaskEntry, 'String');
%if isempty(VMskFile) || exist(VMskFile, 'file')~=2
%    errordlg('Invalid vertex mask file: %s, please check!', VMskFile);
%    return
%end
Header.VMskFile=VMskFile;

% Q
Q=str2double(get(handles.QEntry, 'String'));
if isnan(Q)
    errordlg('Invalid Q, please check!');
end
Header.Q=Q;

handles.Header=Header;
guidata(hObject, handles);
uiresume(handles.figure1);


function QEntry_Callback(hObject, eventdata, handles)
% hObject    handle to QEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of QEntry as text
%        str2double(get(hObject,'String')) returns contents of QEntry as a double


% --- Executes during object creation, after setting all properties.
function QEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QEntry (see GCBO)
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
