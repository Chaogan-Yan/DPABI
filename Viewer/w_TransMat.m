function varargout = w_TransMat(varargin)
% W_TRANSMAT MATLAB code for w_TransMat.fig
%      W_TRANSMAT, by itself, creates a new W_TRANSMAT or raises the existing
%      singleton*.
%
%      H = W_TRANSMAT returns the handle to a new W_TRANSMAT or the handle to
%      the existing singleton*.
%
%      W_TRANSMAT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in W_TRANSMAT.M with the given input arguments.
%
%      W_TRANSMAT('Property','Value',...) creates a new W_TRANSMAT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before w_TransMat_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to w_TransMat_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help w_TransMat

% Last Modified by GUIDE v2.5 14-Aug-2022 15:12:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @w_TransMat_OpeningFcn, ...
                   'gui_OutputFcn',  @w_TransMat_OutputFcn, ...
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


% --- Executes just before w_TransMat is made visible.
function w_TransMat_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to w_TransMat (see VARARGIN)

% Choose default command line output for w_TransMat
if nargin~=4
    error('Please specify main figure');
end
handles.MainFig=varargin{1};
MainHandle=guidata(handles.MainFig);

SetTrans(hObject, MainHandle.TransP);

handles.output = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes w_TransMat wait for user response (see UIRESUME)
uiwait(handles.ObjFigure);


% --- Outputs from this function are returned to the command line.
function varargout = w_TransMat_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    varargout{1}=0;
else
    varargout{1}=handles.output;
    delete(handles.ObjFigure);
end


function RightEty_Callback(hObject, eventdata, handles)
% hObject    handle to RightEty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ApplyTrans(hObject);

% Hints: get(hObject,'String') returns contents of RightEty as text
%        str2double(get(hObject,'String')) returns contents of RightEty as a double


% --- Executes during object creation, after setting all properties.
function RightEty_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RightEty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ForwardEty_Callback(hObject, eventdata, handles)
% hObject    handle to ForwardEty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ApplyTrans(hObject);

% Hints: get(hObject,'String') returns contents of ForwardEty as text
%        str2double(get(hObject,'String')) returns contents of ForwardEty as a double


% --- Executes during object creation, after setting all properties.
function ForwardEty_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ForwardEty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function UpEty_Callback(hObject, eventdata, handles)
% hObject    handle to UpEty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ApplyTrans(hObject);

% Hints: get(hObject,'String') returns contents of UpEty as text
%        str2double(get(hObject,'String')) returns contents of UpEty as a double


% --- Executes during object creation, after setting all properties.
function UpEty_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UpEty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PitchEty_Callback(hObject, eventdata, handles)
% hObject    handle to PitchEty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ApplyTrans(hObject);

% Hints: get(hObject,'String') returns contents of PitchEty as text
%        str2double(get(hObject,'String')) returns contents of PitchEty as a double


% --- Executes during object creation, after setting all properties.
function PitchEty_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PitchEty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RollEty_Callback(hObject, eventdata, handles)
% hObject    handle to RollEty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ApplyTrans(hObject);

% Hints: get(hObject,'String') returns contents of RollEty as text
%        str2double(get(hObject,'String')) returns contents of RollEty as a double


% --- Executes during object creation, after setting all properties.
function RollEty_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RollEty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function YawEty_Callback(hObject, eventdata, handles)
% hObject    handle to YawEty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ApplyTrans(hObject);

% Hints: get(hObject,'String') returns contents of YawEty as text
%        str2double(get(hObject,'String')) returns contents of YawEty as a double


% --- Executes during object creation, after setting all properties.
function YawEty_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YawEty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function XResizeEty_Callback(hObject, eventdata, handles)
% hObject    handle to XResizeEty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ApplyTrans(hObject);

% Hints: get(hObject,'String') returns contents of XResizeEty as text
%        str2double(get(hObject,'String')) returns contents of XResizeEty as a double


% --- Executes during object creation, after setting all properties.
function XResizeEty_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XResizeEty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function YResizeEty_Callback(hObject, eventdata, handles)
% hObject    handle to YResizeEty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ApplyTrans(hObject);

% Hints: get(hObject,'String') returns contents of YResizeEty as text
%        str2double(get(hObject,'String')) returns contents of YResizeEty as a double


% --- Executes during object creation, after setting all properties.
function YResizeEty_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YResizeEty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ZResizeEty_Callback(hObject, eventdata, handles)
% hObject    handle to ZResizeEty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ApplyTrans(hObject);

% Hints: get(hObject,'String') returns contents of ZResizeEty as text
%        str2double(get(hObject,'String')) returns contents of ZResizeEty as a double


% --- Executes during object creation, after setting all properties.
function ZResizeEty_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ZResizeEty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function XAffineEty_Callback(hObject, eventdata, handles)
% hObject    handle to XAffineEty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ApplyTrans(hObject);

% Hints: get(hObject,'String') returns contents of XAffineEty as text
%        str2double(get(hObject,'String')) returns contents of XAffineEty as a double


% --- Executes during object creation, after setting all properties.
function XAffineEty_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XAffineEty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function YAffineEty_Callback(hObject, eventdata, handles)
% hObject    handle to YAffineEty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ApplyTrans(hObject);

% Hints: get(hObject,'String') returns contents of YAffineEty as text
%        str2double(get(hObject,'String')) returns contents of YAffineEty as a double


% --- Executes during object creation, after setting all properties.
function YAffineEty_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YAffineEty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ZAffineEty_Callback(hObject, eventdata, handles)
% hObject    handle to ZAffineEty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ApplyTrans(hObject);

% Hints: get(hObject,'String') returns contents of ZAffineEty as text
%        str2double(get(hObject,'String')) returns contents of ZAffineEty as a double


% --- Executes during object creation, after setting all properties.
function ZAffineEty_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ZAffineEty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CancelBtn.
function CancelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to CancelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.ObjFigure);
delete(handles.ObjFigure);

% --- Executes on button press in AcceptBtn.
function AcceptBtn_Callback(hObject, eventdata, handles)
% hObject    handle to AcceptBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ApplyTrans(hObject);

handles=guidata(hObject);
handles.output=1;
guidata(hObject, handles);

uiresume(handles.ObjFigure);

% --- Executes on button press in ApplyBtn.
function ApplyBtn_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ApplyTrans(hObject);

% --- Executes on button press in ResetBtn.
function ResetBtn_Callback(hObject, eventdata, handles)
% hObject    handle to ResetBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
TransP=zeros(12, 1);
TransP(7:9)=1;

SetTrans(hObject, TransP);
ApplyTrans(hObject);

function ApplyTrans(hObject)
handles=guidata(hObject);
TransP=zeros(12, 1);
TransP(1)=str2double(get(handles.RightEty, 'String'));
TransP(2)=str2double(get(handles.ForwardEty, 'String'));
TransP(3)=str2double(get(handles.UpEty, 'String'));
TransP(4)=str2double(get(handles.PitchEty, 'String'));
TransP(5)=str2double(get(handles.RollEty, 'String'));
TransP(6)=str2double(get(handles.YawEty, 'String'));
TransP(7)=str2double(get(handles.XResizeEty, 'String'));
TransP(8)=str2double(get(handles.YResizeEty, 'String'));
TransP(9)=str2double(get(handles.ZResizeEty, 'String'));
TransP(10)=str2double(get(handles.XAffineEty, 'String'));
TransP(11)=str2double(get(handles.YAffineEty, 'String'));
TransP(12)=str2double(get(handles.ZAffineEty, 'String'));
if any(isnan(TransP))
    errordlg('Invalid Transformation!');
    return
end

MainHandle=guidata(handles.MainFig);
MainHandle.TransP=TransP;
guidata(handles.MainFig, MainHandle)
guidata(hObject, handles);

global st
curfig=handles.MainFig;
curfig=w_Compatible2014bFig(curfig);
TransMat=spm_matrix(TransP);
st{curfig}.vols{1}.premul=TransMat;
y_spm_orthviews('Redraw', curfig);

function SetTrans(hObject, TransP)
handles=guidata(hObject);
% Set Tran P
set(handles.RightEty, 'string', num2str(TransP(1)));
set(handles.ForwardEty, 'string', num2str(TransP(2)));
set(handles.UpEty, 'string', num2str(TransP(3)));
set(handles.PitchEty, 'string', num2str(TransP(4)));
set(handles.RollEty, 'string', num2str(TransP(5)));
set(handles.YawEty, 'string', num2str(TransP(6)));
set(handles.XResizeEty, 'string', num2str(TransP(7)));
set(handles.YResizeEty, 'string', num2str(TransP(8)));
set(handles.ZResizeEty, 'string', num2str(TransP(9)));
set(handles.XAffineEty, 'string', num2str(TransP(10)));
set(handles.YAffineEty, 'string', num2str(TransP(11)));
set(handles.ZAffineEty, 'string', num2str(TransP(12)));

