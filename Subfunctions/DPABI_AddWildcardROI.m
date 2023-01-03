function varargout = DPABI_AddWildcardROI(varargin)
% DPABI_ADDWILDCARDROI MATLAB code for DPABI_AddWildcardROI.fig
%      DPABI_ADDWILDCARDROI, by itself, creates a new DPABI_ADDWILDCARDROI or raises the existing
%      singleton*.
%
%      H = DPABI_ADDWILDCARDROI returns the handle to a new DPABI_ADDWILDCARDROI or the handle to
%      the existing singleton*.
%
%      DPABI_ADDWILDCARDROI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABI_ADDWILDCARDROI.M with the given input arguments.
%
%      DPABI_ADDWILDCARDROI('Property','Value',...) creates a new DPABI_ADDWILDCARDROI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABI_AddWildcardROI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABI_AddWildcardROI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABI_AddWildcardROI

% Last Modified by GUIDE v2.5 26-Dec-2022 11:32:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABI_AddWildcardROI_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABI_AddWildcardROI_OutputFcn, ...
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


% --- Executes just before DPABI_AddWildcardROI is made visible.
function DPABI_AddWildcardROI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABI_AddWildcardROI (see VARARGIN)
handles.WildcardString={};

if ~ismac
    if ispc
        ZoonMatrix = [1 1 1.6 1.2];  %For pc
    else
        ZoonMatrix = [1 1 1.6 1.2];  %For Linux
    end
    UISize = get(handles.figureAddWildcardROI,'Position');
    UISize = UISize.*ZoonMatrix;
    set(handles.figureAddWildcardROI,'Position',UISize);
end
movegui(handles.figureAddWildcardROI, 'center');

% Choose default command line output for DPABI_AddWildcardROI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABI_AddWildcardROI wait for user response (see UIRESUME)
uiwait(handles.figureAddWildcardROI);


% --- Outputs from this function are returned to the command line.
function varargout = DPABI_AddWildcardROI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    varargout{1}=[];
else
    varargout{1} = handles.WildcardString;
    delete(handles.figureAddWildcardROI);
end


function editString_Callback(hObject, eventdata, handles)
% hObject    handle to editString (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editString as text
%        str2double(get(hObject,'String')) returns contents of editString as a double


% --- Executes during object creation, after setting all properties.
function editString_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editString (see GCBO)
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
uiresume(handles.figureAddWildcardROI);


% --- Executes on button press in pushbuttonAccept.
function pushbuttonAccept_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAccept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.WildcardString = get(handles.editString,'String');
guidata(hObject, handles);
uiresume(handles.figureAddWildcardROI);
