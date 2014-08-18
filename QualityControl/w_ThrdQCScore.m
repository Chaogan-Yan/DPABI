function varargout = w_ThrdQCScore(varargin)
% W_THRDQCSCORE MATLAB code for w_ThrdQCScore.fig
%      W_THRDQCSCORE, by itself, creates a new W_THRDQCSCORE or raises the existing
%      singleton*.
%
%      H = W_THRDQCSCORE returns the handle to a new W_THRDQCSCORE or the handle to
%      the existing singleton*.
%
%      W_THRDQCSCORE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in W_THRDQCSCORE.M with the given input arguments.
%
%      W_THRDQCSCORE('Property','Value',...) creates a new W_THRDQCSCORE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before w_ThrdQCScore_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to w_ThrdQCScore_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help w_ThrdQCScore

% Last Modified by GUIDE v2.5 06-Apr-2014 21:31:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @w_ThrdQCScore_OpeningFcn, ...
                   'gui_OutputFcn',  @w_ThrdQCScore_OutputFcn, ...
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


% --- Executes just before w_ThrdQCScore is made visible.
function w_ThrdQCScore_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to w_ThrdQCScore (see VARARGIN)
MainFig=varargin{1};
MainHandle=guidata(MainFig);

if ~isempty(MainHandle)
    CheckOnOff(MainHandle.T1Score, handles.T1ScoreButton, handles.T1ScoreEntry);
    CheckOnOff(MainHandle.FunScore, handles.FunScoreButton, handles.FunScoreEntry);
    CheckOnOff(MainHandle.NormScore, handles.NormScoreButton, handles.NormScoreEntry);
end
% Choose default command line output for w_ThrdQCScore
handles.MainFig=MainFig;
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes w_ThrdQCScore wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = w_ThrdQCScore_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    varargout{1} = 0;
else
    varargout{1} = 1;
    delete(handles.figure1)
end


% --- Executes on button press in T1ScoreButton.
function T1ScoreButton_Callback(hObject, eventdata, handles)
% hObject    handle to T1ScoreButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.T1ScoreButton, 'Value');
SetOnOff(Value, handles.T1ScoreEntry);
% Hint: get(hObject,'Value') returns toggle state of T1ScoreButton


% --- Executes on button press in FunScoreButton.
function FunScoreButton_Callback(hObject, eventdata, handles)
% hObject    handle to FunScoreButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.FunScoreButton, 'Value');
SetOnOff(Value, handles.FunScoreEntry);
% Hint: get(hObject,'Value') returns toggle state of FunScoreButton


% --- Executes on button press in NormScoreButton.
function NormScoreButton_Callback(hObject, eventdata, handles)
% hObject    handle to NormScoreButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.NormScoreButton, 'Value');
SetOnOff(Value, handles.NormScoreEntry);
% Hint: get(hObject,'Value') returns toggle state of NormScoreButton


% --- Executes on button press in OKButton.
function OKButton_Callback(hObject, eventdata, handles)
% hObject    handle to OKButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MainHandle=guidata(handles.MainFig);
MainHandle.T1Score=CheckEntry(handles.T1ScoreButton, handles.T1ScoreEntry);
MainHandle.FunScore=CheckEntry(handles.FunScoreButton, handles.FunScoreEntry);
MainHandle.NormScore=CheckEntry(handles.NormScoreButton, handles.NormScoreEntry);

guidata(handles.MainFig, MainHandle);
guidata(hObject, handles);

uiresume(handles.figure1);


function T1ScoreEntry_Callback(hObject, eventdata, handles)
% hObject    handle to T1ScoreEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of T1ScoreEntry as text
%        str2double(get(hObject,'String')) returns contents of T1ScoreEntry as a double


% --- Executes during object creation, after setting all properties.
function T1ScoreEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to T1ScoreEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FunScoreEntry_Callback(hObject, eventdata, handles)
% hObject    handle to FunScoreEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FunScoreEntry as text
%        str2double(get(hObject,'String')) returns contents of FunScoreEntry as a double


% --- Executes during object creation, after setting all properties.
function FunScoreEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FunScoreEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NormScoreEntry_Callback(hObject, eventdata, handles)
% hObject    handle to NormScoreEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NormScoreEntry as text
%        str2double(get(hObject,'String')) returns contents of NormScoreEntry as a double


% --- Executes during object creation, after setting all properties.
function NormScoreEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NormScoreEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SetOnOff(Value, EntryHandle)
if Value 
    Flag='On';
else
    Flag='Off';
end
set(EntryHandle, 'Enable', Flag, 'String', '');

function CheckOnOff(Score, ButtonHandle, EntryHandle)
if ~isempty(Score)
    set(ButtonHandle, 'Value', 1);
    set(EntryHandle,  'Enable', 'On', 'String', num2str(Score));
else
    set(ButtonHandle, 'Value', 0);
    set(EntryHandle,  'Enable', 'Off', 'String', '');
end

function Score=CheckEntry(ButtonHandle, EntryHandle)
Score='';
if get(ButtonHandle, 'Value')
    Temp=str2double(get(EntryHandle, 'String'));
    if ~isnan(Temp)
        Score=Temp;
    end
end
