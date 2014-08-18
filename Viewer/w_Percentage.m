function varargout = w_Percentage(varargin)
% W_PERCENTAGE MATLAB code for w_Percentage.fig
%      W_PERCENTAGE, by itself, creates a new W_PERCENTAGE or raises the existing
%      singleton*.
%
%      H = W_PERCENTAGE returns the handle to a new W_PERCENTAGE or the handle to
%      the existing singleton*.
%
%      W_PERCENTAGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in W_PERCENTAGE.M with the given input arguments.
%
%      W_PERCENTAGE('Property','Value',...) creates a new W_PERCENTAGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before w_Percentage_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to w_Percentage_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help w_Percentage

% Last Modified by GUIDE v2.5 25-Mar-2014 16:00:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @w_Percentage_OpeningFcn, ...
                   'gui_OutputFcn',  @w_Percentage_OutputFcn, ...
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


% --- Executes just before w_Percentage is made visible.
function w_Percentage_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to w_Percentage (see VARARGIN)
OverlayHeader=varargin{1};

set(handles.PercentageEntry, 'String', num2str(OverlayHeader.Percentage));
set(handles.MaskEntry,       'String', OverlayHeader.MaskFile);
% Choose default command line output for w_Percentage
handles.OverlayHeader=OverlayHeader;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes w_Percentage wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = w_Percentage_OutputFcn(hObject, eventdata, handles) 
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
handles.OverlayHeader.MaskFile='';
handles.OverlayHeader.Mask=true(handles.OverlayHeader.dim);
guidata(hObject, handles);

% --- Executes on button press in AddButton.
function AddButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABIPath=fileparts(which('DPABI.m'));
TemplatePath=fullfile(DPABIPath, 'Templates');
[File , Path]=uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
    'Pick Underlay File' , TemplatePath);
if isnumeric(File)
    return
end
MaskFile=fullfile(Path, File);
handles.OverlayHeader.MaskFile=MaskFile;
set(handles.MaskEntry, 'String', MaskFile);

[Mask, Vox, Header] = y_ReadRPI(MaskFile);
handles.OverlayHeader.Mask=logical(Mask);

guidata(hObject, handles);


% --- Executes on button press in ComputeButton.
function ComputeButton_Callback(hObject, eventdata, handles)
% hObject    handle to ComputeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
OverlayHeader=handles.OverlayHeader;
Percent=str2double(get(handles.PercentageEntry, 'String'));
OverlayHeader.Percent=Percent;
Percent=Percent/100;
Mask=OverlayHeader.Mask;
SortData=sort(abs(OverlayHeader.Raw(Mask)));
Thrd=SortData(floor(length(SortData)*(1-Percent))+1);
OverlayHeader.PMin= Thrd;
OverlayHeader.NMin=-Thrd;

handles.OverlayHeader=OverlayHeader;
guidata(hObject, handles);
uiresume(handles.figure1);


function PercentageEntry_Callback(hObject, eventdata, handles)
% hObject    handle to PercentageEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PercentageEntry as text
%        str2double(get(hObject,'String')) returns contents of PercentageEntry as a double


% --- Executes during object creation, after setting all properties.
function PercentageEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PercentageEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
