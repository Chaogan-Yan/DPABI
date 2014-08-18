function varargout = w_AddSphere_gui(varargin)
% W_ADDSPHERE_GUI MATLAB code for w_AddSphere_gui.fig
%      W_ADDSPHERE_GUI, by itself, creates a new W_ADDSPHERE_GUI or raises the existing
%      singleton*.
%
%      H = W_ADDSPHERE_GUI returns the handle to a new W_ADDSPHERE_GUI or the handle to
%      the existing singleton*.
%
%      W_ADDSPHERE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in W_ADDSPHERE_GUI.M with the given input arguments.
%
%      W_ADDSPHERE_GUI('Property','Value',...) creates a new W_ADDSPHERE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before w_AddSphere_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to w_AddSphere_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help w_AddSphere_gui

% Last Modified by GUIDE v2.5 07-Apr-2014 18:59:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @w_AddSphere_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @w_AddSphere_gui_OutputFcn, ...
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


% --- Executes just before w_AddSphere_gui is made visible.
function w_AddSphere_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to w_AddSphere_gui (see VARARGIN)
handles.SphereCell={};
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes w_AddSphere_gui wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = w_AddSphere_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    varargout{1}=[];
else
    varargout{1} = handles.SphereCell;
    delete(handles.figure1);
end



function CoordinateEntry_Callback(hObject, eventdata, handles)
% hObject    handle to CoordinateEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CoordinateEntry as text
%        str2double(get(hObject,'String')) returns contents of CoordinateEntry as a double


% --- Executes during object creation, after setting all properties.
function CoordinateEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CoordinateEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AcceptButton.
function AcceptButton_Callback(hObject, eventdata, handles)
% hObject    handle to AcceptButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CoordMat=str2num(get(handles.CoordinateEntry, 'String'));
CoordCell=num2cell(CoordMat, 2);
if get(handles.TalToMNIButton, 'Value')
    CoordCell=cellfun(@(coord) [y_tal2icbm_spm([coord(1:3)]), coord(4)], CoordCell,...
        'UniformOutput', false);
end

handles.SphereCell=CoordCell;
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in CancelButton.
function CancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to CancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);
delete(handles.figure1);

% --- Executes on button press in TalToMNIButton.
function TalToMNIButton_Callback(hObject, eventdata, handles)
% hObject    handle to TalToMNIButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TalToMNIButton
