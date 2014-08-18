function varargout = w_StructuralSelect(varargin)
% W_STRUCTURALSELECT MATLAB code for w_StructuralSelect.fig
%      W_STRUCTURALSELECT, by itself, creates a new W_STRUCTURALSELECT or raises the existing
%      singleton*.
%
%      H = W_STRUCTURALSELECT returns the handle to a new W_STRUCTURALSELECT or the handle to
%      the existing singleton*.
%
%      W_STRUCTURALSELECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in W_STRUCTURALSELECT.M with the given input arguments.
%
%      W_STRUCTURALSELECT('Property','Value',...) creates a new W_STRUCTURALSELECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before w_StructuralSelect_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to w_StructuralSelect_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help w_StructuralSelect

% Last Modified by GUIDE v2.5 02-Nov-2013 11:53:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @w_StructuralSelect_OpeningFcn, ...
                   'gui_OutputFcn',  @w_StructuralSelect_OutputFcn, ...
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


% --- Executes just before w_StructuralSelect is made visible.
function w_StructuralSelect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to w_StructuralSelect (see VARARGIN)
movegui(hObject, 'east');

global st

MainFig=varargin{1};

AtlasInfo=st{MainFig}.AtlasInfo;
ListString={};
for i=1:numel(AtlasInfo)
    ListString{i, 1}=AtlasInfo{i}.Template.Alias;
end
set(handles.StructuralPopup, 'String', ListString);
set(handles.StructuralPopup, 'Value', 1);

StructuralList=AtlasInfo{1}.Reference(2:end, 1);
set(handles.StructuralList, 'String', StructuralList);
set(handles.StructuralList, 'Value', 1);

handles.MainFig=MainFig;
% Choose default command line output for w_StructuralSelect
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

st{MainFig}.SSFlag=hObject;

% UIWAIT makes w_StructuralSelect wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = w_StructuralSelect_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in StructuralPopup.
function StructuralPopup_Callback(hObject, eventdata, handles)
% hObject    handle to StructuralPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global st
curfig=handles.MainFig;
Value=get(handles.StructuralPopup, 'Value');
StructuralList=st{curfig}.AtlasInfo{Value}.Reference(2:end, 1);
set(handles.StructuralList, 'String', StructuralList);
set(handles.StructuralList, 'Value', 1);
% Hints: contents = cellstr(get(hObject,'String')) returns StructuralPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from StructuralPopup


% --- Executes during object creation, after setting all properties.
function StructuralPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StructuralPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Accept.
function Accept_Callback(hObject, eventdata, handles)
% hObject    handle to Accept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1);

% --- Executes on selection change in StructuralList.
function StructuralList_Callback(hObject, eventdata, handles)
% hObject    handle to StructuralList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global st
curfig=handles.MainFig;

AtlasIdx=get(handles.StructuralPopup, 'Value');
Value=get(handles.StructuralList, 'Value');
centre=st{curfig}.AtlasInfo{AtlasIdx}.Reference{Value+1 , 3};

y_spm_orthviews('Reposition', centre, curfig);

% Hints: contents = cellstr(get(hObject,'String')) returns StructuralList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from StructuralList


% --- Executes during object creation, after setting all properties.
function StructuralList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StructuralList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MoveBtn.
function MoveBtn_Callback(hObject, eventdata, handles)
% hObject    handle to MoveBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MoveBtn


% --- Executes on button press in PreviewBtn.
function PreviewBtn_Callback(hObject, eventdata, handles)
% hObject    handle to PreviewBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
y_spm_orthviews('Redraw', handles.MainFig);
% Hint: get(hObject,'Value') returns toggle state of PreviewBtn
