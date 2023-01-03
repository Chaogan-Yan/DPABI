function varargout = DPABI_SelectROIIndices(varargin)
% DPABI_SELECTROIINDICES MATLAB code for DPABI_SelectROIIndices.fig
%      DPABI_SELECTROIINDICES, by itself, creates a new DPABI_SELECTROIINDICES or raises the existing
%      singleton*.
%
%      H = DPABI_SELECTROIINDICES returns the handle to a new DPABI_SELECTROIINDICES or the handle to
%      the existing singleton*.
%
%      DPABI_SELECTROIINDICES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABI_SELECTROIINDICES.M with the given input arguments.
%
%      DPABI_SELECTROIINDICES('Property','Value',...) creates a new DPABI_SELECTROIINDICES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABI_SelectROIIndices_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABI_SelectROIIndices_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABI_SelectROIIndices

% Last Modified by GUIDE v2.5 25-Dec-2022 22:59:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABI_SelectROIIndices_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABI_SelectROIIndices_OutputFcn, ...
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


% --- Executes just before DPABI_SelectROIIndices is made visible.
function DPABI_SelectROIIndices_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABI_SelectROIIndices (see VARARGIN)
if isempty(varargin)
    handles.InputROIIndex = []; 
else
    handles.InputROIIndex=varargin{1};
end
set(handles.editROIIndices,'String',num2str(handles.InputROIIndex));
handles.ROISelectedIndex = [];

if ~ismac
    if ispc
        ZoonMatrix = [1 1 1.6 1.2];  %For pc
    else
        ZoonMatrix = [1 1 1.6 1.2];  %For Linux
    end
    UISize = get(handles.figureSelectROIIncices,'Position');
    UISize = UISize.*ZoonMatrix;
    set(handles.figureSelectROIIncices,'Position',UISize);
end
movegui(handles.figureSelectROIIncices, 'center');

% Choose default command line output for DPABI_SelectROIIndices
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABI_SelectROIIndices wait for user response (see UIRESUME)
uiwait(handles.figureSelectROIIncices);


% --- Outputs from this function are returned to the command line.
function varargout = DPABI_SelectROIIndices_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if ~isempty(handles.ROISelectedIndex)
    varargout{1} = handles.ROISelectedIndex;
else 
    varargout{1}=[];
end
delete(handles.figureSelectROIIncices);



function editROIIndices_Callback(hObject, eventdata, handles)
% hObject    handle to editROIIndices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editROIIndices as text
%        str2double(get(hObject,'String')) returns contents of editROIIndices as a double


% --- Executes during object creation, after setting all properties.
function editROIIndices_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editROIIndices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonCancel.
function pushbuttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figureSelectROIIncices);


% --- Executes on button press in pushbuttonAccept.
function pushbuttonAccept_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAccept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SelectIndexString = get(handles.editROIIndices,'String');
try 
    handles.ROISelectedIndex = eval([SelectIndexString,';']);
catch
    try 
        handles.ROISelectedIndex = eval(['[',SelectIndexString,'];']);
    catch
        warndlg('Please input correct ROI indices!');
        return
    end
end
guidata(hObject, handles);
uiresume(handles.figureSelectROIIncices);
