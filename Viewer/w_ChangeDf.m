function varargout = w_ChangeDf(varargin)
% W_CHANGEDF MATLAB code for w_ChangeDf.fig
%      W_CHANGEDF, by itself, creates a new W_CHANGEDF or raises the existing
%      singleton*.
%
%      H = W_CHANGEDF returns the handle to a new W_CHANGEDF or the handle to
%      the existing singleton*.
%
%      W_CHANGEDF('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in W_CHANGEDF.M with the given input arguments.
%
%      W_CHANGEDF('Property','Value',...) creates a new W_CHANGEDF or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before w_ChangeDf_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to w_ChangeDf_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help w_ChangeDf

% Last Modified by GUIDE v2.5 29-Oct-2013 19:59:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @w_ChangeDf_OpeningFcn, ...
                   'gui_OutputFcn',  @w_ChangeDf_OutputFcn, ...
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


% --- Executes just before w_ChangeDf is made visible.
function w_ChangeDf_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to w_ChangeDf (see VARARGIN)
if isempty(varargin)
    guidata(hObject, handles);
    return
end

handles.Info=...
    {...
    sprintf('None\n(not read)\n\nThe info of degree freedom cannot be found in this header.\n\nPlease set it');...
    sprintf('T-test (1 df)\n\t(two-tailed)\n\nFor one sample T-test or paired T-test:\n\tDf=n-1\n\nFor two sample T-test:\n\tDf=n1+n2-2');...
    sprintf('R-test (1 df)\n\t(two-tailed)\n\nFor Pearson''s Correlation Coefficient\n(with n samples)\n\tDf=n-2');...
    sprintf('F-test (2 df)\n\t(one-tailed)\n\nFor one-way ANOVA\n(with s levels and n subjects):\n\tDf1=s-1\nDf2=n-s)');...
    sprintf('Z-test (1 df)\n\t(two-tailed)\n\n');...
    };


OverlayHeader=varargin{1};
Flag=OverlayHeader.TestFlag;

switch upper(Flag)
    case 'T'
        Value=2;
    case 'R'
        Value=3;
    case 'F'
        Value=4;
        set(handles.Df2Entry, 'Enable', 'On');
    case 'Z'
        Value=5;
    otherwise
        Value=1;
end
set(handles.FlagPopup, 'Value', Value);
set(handles.InfoText, 'String', handles.Info{Value});
set(handles.DfEntry, 'String', sprintf('%d', OverlayHeader.Df));
set(handles.Df2Entry, 'String', sprintf('%d', OverlayHeader.Df2));

% Choose default command line output for w_ChangeDf
handles.output = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes w_ChangeDf wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = w_ChangeDf_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles)
    varargout{1}=[];
    return;
else
    varargout{1}=handles.output;
    delete(handles.figure1);
end
% Get default command line output from handles structure
%varargout{1} = handles.output;


% --- Executes on selection change in FlagPopup.
function FlagPopup_Callback(hObject, eventdata, handles)
% hObject    handle to FlagPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.FlagPopup, 'Value');
if Value==4
    set(handles.Df2Entry, 'Enable', 'On');
else
    set(handles.Df2Entry, 'Enable', 'Off');
end
set(handles.InfoText, 'String', handles.Info{Value});
% Hints: contents = cellstr(get(hObject,'String')) returns FlagPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FlagPopup


% --- Executes during object creation, after setting all properties.
function FlagPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FlagPopup (see GCBO)
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
Value=get(handles.FlagPopup, 'Value');
switch Value
    case 2
        Flag='T';
    case 3
        Flag='R';
    case 4
        Flag='F';
    case 5
        Flag='Z';
    otherwise
        Flag='';
end

Df=str2num(get(handles.DfEntry, 'String'));
if isempty(Df)
    Df=0;
end
Df2=str2num(get(handles.Df2Entry, 'String'));
if isempty(Df2)
    Df2=0;
end

if Df==0
    Flag='';
end
if isempty(Flag)
    Df=0;
    Df2=0;
end
handles.output=cell(3,1);
handles.output{1}=Flag;
handles.output{2}=Df;
handles.output{3}=Df2;
guidata(hObject, handles);
uiresume(handles.figure1);


% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);
delete(handles.figure1);


function Df2Entry_Callback(hObject, eventdata, handles)
% hObject    handle to Df2Entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Df2Entry as text
%        str2double(get(hObject,'String')) returns contents of Df2Entry as a double


% --- Executes during object creation, after setting all properties.
function Df2Entry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Df2Entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DfEntry_Callback(hObject, eventdata, handles)
% hObject    handle to DfEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DfEntry as text
%        str2double(get(hObject,'String')) returns contents of DfEntry as a double


% --- Executes during object creation, after setting all properties.
function DfEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DfEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
