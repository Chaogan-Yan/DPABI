function varargout = w_QCScore(varargin)
% W_QCSCORE MATLAB code for w_QCScore.fig
%      W_QCSCORE, by itself, creates a new W_QCSCORE or raises the existing
%      singleton*.
%
%      H = W_QCSCORE returns the handle to a new W_QCSCORE or the handle to
%      the existing singleton*.
%
%      W_QCSCORE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in W_QCSCORE.M with the given input arguments.
%
%      W_QCSCORE('Property','Value',...) creates a new W_QCSCORE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before w_QCScore_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to w_QCScore_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help w_QCScore

% Last Modified by GUIDE v2.5 07-Dec-2013 01:13:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @w_QCScore_OpeningFcn, ...
                   'gui_OutputFcn',  @w_QCScore_OutputFcn, ...
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


% --- Executes just before w_QCScore is made visible.
function w_QCScore_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to w_QCScore (see VARARGIN)

% Choose default command line output for w_QCScore
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes w_QCScore wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = w_QCScore_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    varargout{1}=[];
    varargout{2}=[];
else
    varargout{1} = handles.QCScore;
    varargout{2} = handles.QCComment;
    delete(handles.figure1);
end



function QCCommentEntry_Callback(hObject, eventdata, handles)
% hObject    handle to QCCommentEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of QCCommentEntry as text
%        str2double(get(hObject,'String')) returns contents of QCCommentEntry as a double


% --- Executes during object creation, after setting all properties.
function QCCommentEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QCCommentEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Apply.
function Apply_Callback(hObject, eventdata, handles)
% hObject    handle to Apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
for i=1:5
    Radio=sprintf('Radio%d', i);
    Value=get(handles.(Radio), 'Value');
    if Value
        handles.QCScore=i;
        break;
    end
end
handles.QCComment=get(handles.QCCommentEntry, 'String');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);
