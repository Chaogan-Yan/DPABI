function varargout = w_SurfClusterSize(varargin)
% W_SURFCLUSTERSIZE MATLAB code for w_SurfClusterSize.fig
%      W_SURFCLUSTERSIZE, by itself, creates a new W_SURFCLUSTERSIZE or raises the existing
%      singleton*.
%
%      H = W_SURFCLUSTERSIZE returns the handle to a new W_SURFCLUSTERSIZE or the handle to
%      the existing singleton*.
%
%      W_SURFCLUSTERSIZE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in W_SURFCLUSTERSIZE.M with the given input arguments.
%
%      W_SURFCLUSTERSIZE('Property','Value',...) creates a new W_SURFCLUSTERSIZE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before w_SurfClusterSize_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to w_SurfClusterSize_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help w_SurfClusterSize

% Last Modified by GUIDE v2.5 04-Mar-2019 16:34:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @w_SurfClusterSize_OpeningFcn, ...
                   'gui_OutputFcn',  @w_SurfClusterSize_OutputFcn, ...
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


% --- Executes just before w_SurfClusterSize is made visible.
function w_SurfClusterSize_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to w_SurfClusterSize (see VARARGIN)
CsOpt=varargin{1};
set(handles.CSizeEty, 'String', num2str(CsOpt.Thres));
if isempty(CsOpt.VAreaFile)
    set(handles.SpecificAreaBtn, 'Value', 0);
    set(handles.SpecificAreaEty, 'Enable', 'Off', 'String', '');
else
    set(handles.SpecificAreaBtn, 'Value', 1);
    set(handles.SpecificAreaEty, 'Enable', 'On', 'String', CsOpt.VAreaFile);
end

handles.CsOpt=CsOpt;
% Choose default command line output for w_SurfClusterSize
handles.output = CsOpt;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes w_SurfClusterSize wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = w_SurfClusterSize_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles)
    varargout{1}=[];
else
    varargout{1}=handles.CsOpt;
    delete(handles.figure1);
end
% Get default command line output from handles structure


% --- Executes on button press in CancelBtn.
function CancelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to CancelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);
delete(handles.figure1);

% --- Executes on button press in AcceptBtn.
function AcceptBtn_Callback(hObject, eventdata, handles)
% hObject    handle to AcceptBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);


function CSizeEty_Callback(hObject, eventdata, handles)
% hObject    handle to CSizeEty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Thres=str2num(get(handles.CSizeEty, 'String'));
if isempty(Thres)
    set(handles.CSizeEty, 'String', num2str(handles.CsOpt.Thres));
else
    handles.CsOpt.Thres=Thres;
    guidata(hObject, handles);
end
% Hints: get(hObject,'String') returns contents of CSizeEty as text
%        str2double(get(hObject,'String')) returns contents of CSizeEty as a double


% --- Executes during object creation, after setting all properties.
function CSizeEty_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CSizeEty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SpecificAreaBtn.
function SpecificAreaBtn_Callback(hObject, eventdata, handles)
% hObject    handle to SpecificAreaBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Val=get(handles.SpecificAreaBtn, 'Value');

if Val
    [File , Path]=uigetfile({'*.gii', 'All GIfTI Files (*.gii)';...
        '*.shape.gii;*.func.gii','Vertex Metric (*.shape.gii;*.func.gii)';...
        '*.*', 'All Files (*.*)';}, ...
        'Pick Vertex Metric File' , pwd);
    if isnumeric(File) && File==0
        set(handles.SpecificAreaBtn, 'Value', 0);
        set(handles.SpecificAreaEty, 'Enable', 'Off', 'String', '');
        return
    end
    VAreaFile=fullfile(Path, File);
    
    V=gifti(VAreaFile);
    if numel(V.cdata)~=size(handles.CsOpt.StructData.vertices, 1)
        errordlg('Invalid Area File!');
        set(handles.SpecificAreaBtn, 'Value', 0);
        set(handles.SpecificAreaEty, 'Enable', 'Off', 'String', '');
        return
    end
    handles.CsOpt.VAreaFile=VAreaFile;
    handles.CsOpt.VArea=V.cdata;
    set(handles.SpecificAreaEty, 'Enable', 'On', 'String', VAreaFile);
    guidata(hObject, handles);
else
    set(handles.SpecificAreaEty, 'Enable', 'Off', 'String', '');
end
% Hint: get(hObject,'Value') returns toggle state of SpecificAreaBtn



function SpecificAreaEty_Callback(hObject, eventdata, handles)
% hObject    handle to SpecificAreaEty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.SpecificAreaEty, 'String', handles.CsOpt.VAreaFile);
% Hints: get(hObject,'String') returns contents of SpecificAreaEty as text
%        str2double(get(hObject,'String')) returns contents of SpecificAreaEty as a double


% --- Executes during object creation, after setting all properties.
function SpecificAreaEty_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SpecificAreaEty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
