function varargout = w_ApplyAdditionalMask(varargin)
% W_APPLYADDITIONALMASK MATLAB code for w_ApplyAdditionalMask.fig
%      W_APPLYADDITIONALMASK, by itself, creates a new W_APPLYADDITIONALMASK or raises the existing
%      singleton*.
%
%      H = W_APPLYADDITIONALMASK returns the handle to a new W_APPLYADDITIONALMASK or the handle to
%      the existing singleton*.
%
%      W_APPLYADDITIONALMASK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in W_APPLYADDITIONALMASK.M with the given input arguments.
%
%      W_APPLYADDITIONALMASK('Property','Value',...) creates a new W_APPLYADDITIONALMASK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before w_ApplyAdditionalMask_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to w_ApplyAdditionalMask_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help w_ApplyAdditionalMask

% Last Modified by GUIDE v2.5 10-Dec-2016 09:11:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @w_ApplyAdditionalMask_OpeningFcn, ...
                   'gui_OutputFcn',  @w_ApplyAdditionalMask_OutputFcn, ...
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


% --- Executes just before w_ApplyAdditionalMask is made visible.
function w_ApplyAdditionalMask_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to w_ApplyAdditionalMask (see VARARGIN)
OverlayHeader=varargin{1};

set(handles.ThresEntry, 'String', num2str(OverlayHeader.Percentage));
set(handles.MaskEntry,       'String', OverlayHeader.AMaskFile);
% Choose default command line output for w_ApplyAdditionalMask
handles.OverlayHeader=OverlayHeader;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes w_ApplyAdditionalMask wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = w_ApplyAdditionalMask_OutputFcn(hObject, eventdata, handles) 
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
    'Pick Underlay File' , pwd); %YAN Chao-Gan, 161210. Chaned from TemplatePath to pwd to better select the current file.
if isnumeric(File)
    return
end
AMaskFile=fullfile(Path, File);
handles.OverlayHeader.AMaskFile=AMaskFile;
set(handles.MaskEntry, 'String', AMaskFile);

[AMask, Vox, Header] = y_ReadRPI(AMaskFile);
handles.OverlayHeader.AMask=AMask;

guidata(hObject, handles);


% --- Executes on button press in ComputeButton.
function ComputeButton_Callback(hObject, eventdata, handles)
% hObject    handle to ComputeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
OverlayHeader=handles.OverlayHeader;
if all(OverlayHeader.AMask)
    errordlg('You need import mask first!');
    return
end
Thres=str2double(get(handles.ThresEntry, 'String'));
AMask=OverlayHeader.AMask;
if get(handles.SignPopup, 'Value')==1 % <
    AMask=AMask<Thres;
elseif get(handles.SignPopup, 'Value')==2 % >
    AMask=AMask>Thres;
else
    error('Invalid Sign');
end
OverlayHeader.AMask=AMask;
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
