function varargout = w_OverlayConfig(varargin)
% W_OVERLAYCONFIG M-file for w_OverlayConfig.fig
%      W_OVERLAYCONFIG, by itself, creates a new W_OVERLAYCONFIG or raises the existing
%      singleton*.
%
%      H = W_OVERLAYCONFIG returns the handle to a new W_OVERLAYCONFIG or the handle to
%      the existing singleton*.
%
%      W_OVERLAYCONFIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in W_OVERLAYCONFIG.M with the given input arguments.
%
%      W_OVERLAYCONFIG('Property','Value',...) creates a new W_OVERLAYCONFIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before w_OverlayConfig_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to w_OverlayConfig_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help w_OverlayConfig

% Last Modified by GUIDE v2.5 28-Oct-2013 14:37:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @w_OverlayConfig_OpeningFcn, ...
                   'gui_OutputFcn',  @w_OverlayConfig_OutputFcn, ...
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


% --- Executes just before w_OverlayConfig is made visible.
function w_OverlayConfig_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to w_OverlayConfig (see VARARGIN)
MainFig=varargin{1};
index=varargin{2};
curblob=varargin{3};
handles.curblob=curblob;

MainHandle=guidata(MainFig);

OverlayHeader=MainHandle.OverlayHeaders{index};
NMax=OverlayHeader.NMax;
NMin=OverlayHeader.NMin;
PMin=OverlayHeader.PMin;
PMax=OverlayHeader.PMax;
cbarstring=OverlayHeader.cbarstring;
numTP=OverlayHeader.numTP;
curTP=OverlayHeader.curTP;

if numTP==1
    set(handles.TPointEntry, 'Enable', 'Off');
else
    set(handles.TPointEntry, 'Enable', 'On');
end
set(handles.TPointEntry, 'String', sprintf('%d', curTP));

handles.MainFig=MainFig;
handles.index=index;
handles.OverlayHeader=OverlayHeader;

set(handles.CbarEntry, 'String',cbarstring);
set(handles.NmaxEntry, 'String', sprintf('%g', NMax));
set(handles.NminEntry, 'String', sprintf('%g', NMin));
set(handles.PminEntry, 'String', sprintf('%g', PMin));
set(handles.PmaxEntry, 'String', sprintf('%g', PMax));

% Update handles structure
handles.output=0;
guidata(hObject, handles);

% UIWAIT makes w_OverlayConfig wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = w_OverlayConfig_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    handles.output=0;
else
    delete(handles.figure1);
end
varargout{1} = handles.output;


function NmaxEntry_Callback(hObject, eventdata, handles)
% hObject    handle to NmaxEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NmaxEntry as text
%        str2double(get(hObject,'String')) returns contents of NmaxEntry as a double


% --- Executes during object creation, after setting all properties.
function NmaxEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NmaxEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PminEntry_Callback(hObject, eventdata, handles)
% hObject    handle to PminEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PminEntry as text
%        str2double(get(hObject,'String')) returns contents of PminEntry as a double


% --- Executes during object creation, after setting all properties.
function PminEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PminEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PmaxEntry_Callback(hObject, eventdata, handles)
% hObject    handle to PmaxEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PmaxEntry as text
%        str2double(get(hObject,'String')) returns contents of PmaxEntry as a double


% --- Executes during object creation, after setting all properties.
function PmaxEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PmaxEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function CbarEntry_Callback(hObject, eventdata, handles)
% hObject    handle to CbarEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CbarEntry as text
%        str2double(get(hObject,'String')) returns contents of CbarEntry as a double


% --- Executes during object creation, after setting all properties.
function CbarEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CbarEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function TPointEntry_Callback(hObject, eventdata, handles)
% hObject    handle to TPointEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
OverlayHeader=handles.OverlayHeader;
numTP=OverlayHeader.numTP;

curTP=str2double(get(handles.TPointEntry, 'String'));
if isnan(curTP)
    set(handles.TPointEntry, 'String', num2str(handles.curTP));
    return
end

if curTP>numTP
    errordlg(sprintf('The number of time points: %d', handles.numTP), 'Time Point Error');
    set(handles.TPointEntry, 'String', num2str(handles.curTP))
    return
end

% [OverlayVolume OverlayVox OverlayHeader] = y_ReadRPI(handles.OverlayFileName, curTP);
% 
% NMax=min(OverlayVolume(:));
% PMax=max(OverlayVolume(:));
% set(handles.NmaxEntry, 'String', num2str(NMax));
% set(handles.PmaxEntry, 'String', num2str(PMax));

% Hints: get(hObject,'String') returns contents of TPointEntry as text
%        str2double(get(hObject,'String')) returns contents of TPointEntry as a double


% --- Executes during object creation, after setting all properties.
function TPointEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TPointEntry (see GCBO)
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
global st
MainHandle=guidata(handles.MainFig);

index=handles.index;
curfig=handles.MainFig;
curblob=handles.curblob;

st{curfig}.vols{1}.blobs(curblob)=[];
MainHandle.OverlayHeaders{index}=[];

OverlaySelect=get(MainHandle.OverlayEntry, 'String');
OverlaySelect(curblob+1)=[];
if isempty(st{curfig}.vols{1}.blobs)
    st{curfig}.curblob=0;
    st{curfig}.vols{1}=rmfield(st{curfig}.vols{1}, 'blobs');
    set(MainHandle.LeftButton, 'Enable', 'Off');
    set(MainHandle.RightButton, 'Enable', 'Off');
    set(MainHandle.TimePointButton, 'Enable', 'Off');
    set(MainHandle.TimePointButton, 'String', '');

    set(MainHandle.OverlayEntry, 'Enable', 'Off')
    set(MainHandle.ColorAxe, 'Visible', 'Off');
    ColorMap=get(MainHandle.ColorAxe, 'Children');
    delete(ColorMap);
    colormap(gray(64));
else
    st{curfig}.curblob=1;
    numTP=st{curfig}.vols{1}.blobs{1}.vol.numTP;
    curTP=st{curfig}.vols{1}.blobs{1}.vol.curTP;
    if numTP==1
        set(MainHandle.LeftButton, 'Enable', 'Off');
        set(MainHandle.RightButton, 'Enable', 'Off');
        set(MainHandle.TimePointButton, 'Enable', 'Off');
        set(MainHandle.TimePointButton, 'String', '');
    else
        set(MainHandle.LeftButton, 'Enable', 'On');
        set(MainHandle.RightButton, 'Enable', 'On');
        if curTP==1
            set(MainHandle.LeftButton, 'Enable', 'Off');
        end
        if curTP==numTP
            set(MainHandle.RightButton, 'Enable', 'Off');
        end
        set(MainHandle.TimePointButton, 'Enable', 'On');
        set(MainHandle.TimePointButton, 'String', num2str(curTP));    
    end
    y_spm_orthviews('redrawcolourbar', curfig, 1);
end
y_spm_orthviews('Redraw', curfig);

MainHandle.OverlayFileName(curblob)=[];

new_curblob=st{curfig}.curblob;
ToolTip=OverlaySelect{new_curblob+1};
set(MainHandle.OverlayEntry, 'ToolTipString', ToolTip);
set(MainHandle.OverlayEntry, 'String', OverlaySelect);
set(MainHandle.OverlayEntry, 'Value', new_curblob+1);

guidata(curfig, MainHandle);

handles.output=2;
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in CancelButton.
function CancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to CancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=0;
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in AcceptButton.
function AcceptButton_Callback(hObject, eventdata, handles)
% hObject    handle to AcceptButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curfig=handles.MainFig;
MainHandle=guidata(handles.MainFig);

curblob=handles.curblob;

index=handles.index;
OverlayHeader=handles.OverlayHeader;
numTP=OverlayHeader.numTP;
oldTP=OverlayHeader.curTP;

NMax=str2double(get(handles.NmaxEntry, 'String'));
NMin=str2double(get(handles.NminEntry, 'String'));
PMin=str2double(get(handles.PminEntry, 'String'));
PMax=str2double(get(handles.PmaxEntry, 'String'));
cbarstring=get(handles.CbarEntry, 'String');

if numTP==1
    curTP=1;
    set(MainHandle.LeftButton, 'Enable', 'Off');
    set(MainHandle.RightButton, 'Enable', 'Off');
    set(MainHandle.TimePointButton, 'Enable', 'Off');
    set(MainHandle.TimePointButton, 'String', '');
else
    curTP=str2double(get(handles.TPointEntry, 'String'));
    if curTP==1
        set(MainHandle.LeftButton, 'Enable', 'Off');
    else
        set(MainHandle.LeftButton, 'Enable', 'On');
    end
    if curTP==numTP
        set(MainHandle.RightButton, 'Enable', 'Off');
    else
        set(MainHandle.RightButton, 'Enable', 'On');
    end
    set(MainHandle.TimePointButton, 'Enable', 'On');
    set(MainHandle.TimePointButton, 'String', num2str(curTP));
end

if curTP~=oldTP
    [OverlayVolume, NewVox, NewHeader] = ...
        y_ReadRPI(OverlayHeader.fname, curTP);
    OverlayHeader.Raw = OverlayVolume;
end

OverlayHeader.cbarstring=cbarstring;
OverlayHeader.NMax=NMax;
OverlayHeader.NMin=NMin;
OverlayHeader.PMin=PMin;
OverlayHeader.PMax=PMax;
OverlayHeader.curTP=curTP;
OverlayHeader.numTP=numTP;
OverlayHeader.IsSelected=1;

OverlayHeader=DPABI_VIEW('RedrawOverlay', OverlayHeader, curfig, curblob);

MainHandle.OverlayHeaders{index}=OverlayHeader;
guidata(curfig, MainHandle);
%set(MainHandle.ThrdSlider, 'Value',  0);
set(MainHandle.ThrdEntry,  'String', []);
set(MainHandle.PEntry, 'String', []);

handles.output=1;
guidata(hObject, handles);
uiresume(handles.figure1);
