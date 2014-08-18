function varargout = w_ClusterSize(varargin)
% W_CLUSTERSIZE MATLAB code for w_ClusterSize.fig
%      W_CLUSTERSIZE, by itself, creates a new W_CLUSTERSIZE or raises the existing
%      singleton*.
%
%      H = W_CLUSTERSIZE returns the handle to a new W_CLUSTERSIZE or the handle to
%      the existing singleton*.
%
%      W_CLUSTERSIZE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in W_CLUSTERSIZE.M with the given input arguments.
%
%      W_CLUSTERSIZE('Property','Value',...) creates a new W_CLUSTERSIZE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before w_ClusterSize_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to w_ClusterSize_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help w_ClusterSize

% Last Modified by GUIDE v2.5 05-Aug-2014 23:19:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @w_ClusterSize_OpeningFcn, ...
                   'gui_OutputFcn',  @w_ClusterSize_OutputFcn, ...
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


% --- Executes just before w_ClusterSize is made visible.
function w_ClusterSize_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to w_ClusterSize (see VARARGIN)
OverlayHeader=varargin{1};

TrueSize=OverlayHeader.CSize;
set(handles.CubicEntry, 'String', sprintf('%g', TrueSize))
Vox=OverlayHeader.Vox;
VoxelSize=floor(TrueSize/prod(Vox));
set(handles.VoxelEntry, 'String', sprintf('%d', VoxelSize));

RMM_NUM=OverlayHeader.RMM;
switch RMM_NUM
    case 6
        Value=1;
    case 18
        Value=2;
    case 26
        Value=3;
end
set(handles.RMM, 'Value', Value);
% Choose default command line output for w_ClusterSize
handles.output = [];
handles.OverlayHeader=OverlayHeader;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes w_ClusterSize wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = w_ClusterSize_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles)
    varargout{1}=[];
else
    varargout{1}=handles.OverlayHeader;
    delete(handles.figure1);
end
% Get default command line output from handles structure
%varargout{1} = handles.output;


% --- Executes on selection change in RMM.
function RMM_Callback(hObject, eventdata, handles)
% hObject    handle to RMM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns RMM contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RMM


% --- Executes during object creation, after setting all properties.
function RMM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RMM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function VoxelEntry_Callback(hObject, eventdata, handles)
% hObject    handle to VoxelEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.Voxel, 'Value')
    set(handles.VoxelEntry, 'Enable', 'On');
    set(handles.CubicEntry, 'Enable', 'Off');
end
% Hints: get(hObject,'String') returns contents of VoxelEntry as text
%        str2double(get(hObject,'String')) returns contents of VoxelEntry as a double


% --- Executes during object creation, after setting all properties.
function VoxelEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VoxelEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CubicEntry_Callback(hObject, eventdata, handles)
% hObject    handle to CubicEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.Cubic, 'Value')
    set(handles.CubicEntry, 'Enable', 'On');
    set(handles.VoxelEntry, 'Enable', 'Off');
end
% Hints: get(hObject,'String') returns contents of CubicEntry as text
%        str2double(get(hObject,'String')) returns contents of CubicEntry as a double


% --- Executes during object creation, after setting all properties.
function CubicEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CubicEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Voxel.
function Voxel_Callback(hObject, eventdata, handles)
% hObject    handle to Voxel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.Voxel, 'Value')
    set(handles.Cubic, 'Value', 0);
    set(handles.CubicEntry, 'Enable', 'Off');
    set(handles.VoxelEntry, 'Enable', 'On');
else
    set(handles.Voxel, 'Value', 1);
end
% Hint: get(hObject,'Value') returns toggle state of Voxel


% --- Executes on button press in Cubic.
function Cubic_Callback(hObject, eventdata, handles)
% hObject    handle to Cubic (see GCBO)
% eventdata  reserved - to be defained in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.Cubic, 'Value')
    set(handles.Voxel, 'Value', 0);
    set(handles.CubicEntry, 'Enable', 'On');
    set(handles.VoxelEntry, 'Enable', 'Off');
else
    set(handles.Cubic, 'Value', 1);
end
% Hint: get(hObject,'Value') returns toggle state of Cubic


% --- Executes on button press in Accept.
function Accept_Callback(hObject, eventdata, handles)
% hObject    handle to Accept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
OverlayHeader=handles.OverlayHeader;
Vox=OverlayHeader.Vox;
if get(handles.Voxel, 'Value');
    VoxelSize=str2double(get(handles.VoxelEntry, 'String'));
    if isnan(VoxelSize)
        VoxelSize=0;
    end
    CSize=prod(Vox)*VoxelSize;
else
    CSize=str2double(get(handles.CubicEntry, 'String'));
    if isnan(CSize)
        CSize=0;
    end
end
OverlayHeader.CSize=CSize;

Value=get(handles.RMM, 'Value');
switch Value
    case 1
        rmm=6;
    case 2
        rmm=18;
    case 3
        rmm=26;
end
OverlayHeader.RMM=rmm;

handles.OverlayHeader=OverlayHeader;
guidata(hObject, handles);
uiresume(handles.figure1);


% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);
delete(handles.figure1);
