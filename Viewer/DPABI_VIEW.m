
function varargout = DPABI_VIEW(varargin)
% DPABI_VIEW M-file for DPABI_VIEW.fig
%      DPABI_VIEW, by itself, creates a new DPABI_VIEW or raises the existing
%      singleton*.
%
%      H = DPABI_VIEW returns the handle to a new DPABI_VIEW or the handle to
%      the existing singleton*.
%
%      DPABI_VIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABI_VIEW.M with the given input arguments.
%
%      DPABI_VIEW('Property','Value',...) creates a new DPABI_VIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABI_VIEW_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABI_VIEW_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Written by Wang Xin-di, 20130809
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing
% Normal University, Beijing, PR China
% sandywang.rest@gmail.com

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABI_VIEW_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABI_VIEW_OutputFcn, ...
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


% --- Executes just before DPABI_VIEW is made visible.
function DPABI_VIEW_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABI_VIEW (see VARARGIN)

% Choose default command line output for DPABI_VIEW
movegui(hObject, 'center');

addlistener(handles.ThrdSlider, 'Value',...
    'PostSet', ...
    @(objH, eventData) ThrdListener_Callback(objH, eventData, hObject));


[DPABIPath, fileN, extn] = fileparts(which('DPABI.m'));

TemplatePath=fullfile(DPABIPath, 'Templates');

AtlasInfo={};

global st

if ~iscell(st)
    st=cell(24);
end
curfig=w_Compatible2014bFig(hObject);

st{curfig}.fig=hObject;

st{curfig}.curblob=0;
st{curfig}.AtlasInfo=AtlasInfo;
st{curfig}.xhairs=1;st{curfig}.hld=1;st{curfig}.yoke=0;
st{curfig}.n=0;st{curfig}.vols=cell(2);st{curfig}.bb=[];
st{curfig}.Space=eye(4,4);st{curfig}.centre=[0 0 0];
st{curfig}.callback=';';st{curfig}.mode=1;st{curfig}.snap=[];
st{curfig}.plugins={'movie'};%'reorient' 'roi'   'rgb'  
st{curfig}.TCFlag=[];st{curfig}.SSFlag=[];
st{curfig}.MPFlag=[];

colormap(gray(64));

UnderlayFileName=fullfile(TemplatePath,'ch2.nii');

[UnderlayVolume UnderlayVox UnderlayHeader] = y_ReadRPI(UnderlayFileName);
handles.UnderlayFileName='';
handles.UserDefinedFileName=UnderlayFileName;
set(handles.UnderlayEntry, 'String', 'ch2.nii');

UnderlayHeader.Data = UnderlayVolume;
UnderlayHeader.Vox  = UnderlayVox;
%UnderlayHeader.rmat = UnderlayHeader.mat;

handles.output = hObject;
handles.OverlayHeaders=cell(5, 1);

% Update handles structure
guidata(hObject, handles);

y_spm_orthviews('Image',UnderlayHeader);
y_spm_orthviews('AddContext',1);

% UIWAIT makes DPABI_VIEW wait for user response (see UIRESUME)
% uiwait(handles.DPABI_fig);


% --- Outputs from this function are returned to the command line.
function varargout = DPABI_VIEW_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function XEntry_Callback(hObject, eventdata, handles)
% hObject    handle to XEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
centre=Pos(handles, 'XYZ');
y_spm_orthviews('Reposition', centre);
% Hints: get(hObject,'String') returns contents of XEntry as text
%        str2double(get(hObject,'String')) returns contents of XEntry as a double


% --- Executes during object creation, after setting all properties.
function XEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function YEntry_Callback(hObject, eventdata, handles)
% hObject    handle to YEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
centre=Pos(handles, 'XYZ');
y_spm_orthviews('Reposition', centre);
% Hints: get(hObject,'String') returns contents of YEntry as text
%        str2double(get(hObject,'String')) returns contents of YEntry as a double


% --- Executes during object creation, after setting all properties.
function YEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ZEntry_Callback(hObject, eventdata, handles)
% hObject    handle to ZEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
centre=Pos(handles, 'XYZ');
y_spm_orthviews('Reposition', centre);
% Hints: get(hObject,'String') returns contents of ZEntry as text
%        str2double(get(hObject,'String')) returns contents of ZEntry as a double


% --- Executes during object creation, after setting all properties.
function ZEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ZEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function KEntry_Callback(hObject, eventdata, handles)
% hObject    handle to KEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
centre=Pos(handles, 'IJK');
y_spm_orthviews('Reposition', centre);
% Hints: get(hObject,'String') returns contents of KEntry as text
%        str2double(get(hObject,'String')) returns contents of KEntry as a double


% --- Executes during object creation, after setting all properties.
function KEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to KEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function JEntry_Callback(hObject, eventdata, handles)
% hObject    handle to JEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
centre=Pos(handles, 'IJK');
y_spm_orthviews('Reposition', centre);
% Hints: get(hObject,'String') returns contents of JEntry as text
%        str2double(get(hObject,'String')) returns contents of JEntry as a double


% --- Executes during object creation, after setting all properties.
function JEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to JEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function IEntry_Callback(hObject, eventdata, handles)
% hObject    handle to IEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
centre=Pos(handles, 'IJK');
y_spm_orthviews('Reposition', centre);
% Hints: get(hObject,'String') returns contents of IEntry as text
%        str2double(get(hObject,'String')) returns contents of IEntry as a
%        double

% --- Executes during object creation, after setting all properties.
function IEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in AButton.
function AButton_Callback(hObject, eventdata, handles)
% hObject    handle to AButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global st
curfig=handles.DPABI_fig;
curfig=w_Compatible2014bFig(curfig);

TMFlag=w_Montage(handles.DPABI_fig, 'T');
%TMFlag=w_Compatible2014bFig(TMFlag);
st{curfig}.MPFlag=[st{curfig}.MPFlag;{TMFlag}];

% --- Executes on button press in SButton.
function SButton_Callback(hObject, eventdata, handles)
% hObject    handle to SButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global st
curfig=handles.DPABI_fig;
curfig=w_Compatible2014bFig(curfig);

SMFlag=w_Montage(handles.DPABI_fig, 'S');
%SMFlag=w_Compatible2014bFig(SMFlag);
st{curfig}.MPFlag=[st{curfig}.MPFlag;{SMFlag}];

% --- Executes on button press in CButton.
function CButton_Callback(hObject, eventdata, handles)
% hObject    handle to CButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global st
curfig=handles.DPABI_fig;
curfig=w_Compatible2014bFig(curfig);

CMFlag=w_Montage(handles.DPABI_fig, 'C');
%CMFlag=w_Compatible2014bFig(CMFlag);
st{curfig}.MPFlag=[st{curfig}.MPFlag;{CMFlag}];

function ScaleEntry_Callback(hObject, eventdata, handles)
% hObject    handle to ScaleEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global st
curfig=handles.DPABI_fig;
curfig=w_Compatible2014bFig(curfig);

scale=get(handles.ScaleEntry, 'String');
scale=str2double(scale);

if isempty(scale)
    scale=100;
    set(handles.ScaleEntry, 'String', '100');
end
scale=scale/100;

if scale==1
    bb=st{curfig}.bb;
    Diff=diff(abs(bb));
    
    Space=eye(4);
    if strcmpi(get(handles.LRButton, 'String'),'R')
        M=[ -1, 0, 0, -Diff(1);
            0, 1, 0, 0;
            0, 0, 1, 0;
            0, 0, 0, 1];
        Space=M*Space;
    end

    if strcmpi(get(handles.PAButton, 'String'),'P')
        M=[ 1, 0, 0, 0;
            0, -1, 0, -Diff(3);
            0, 0, 1, 0;
            0, 0, 0, 1];
        Space=M*Space;
    end
    if strcmpi(get(handles.SIButton, 'String'),'I')
        M=[ 1, 0, 0, 0;
            0, 1, 0, 0;
            0, 0, -1, -Diff(2);
            0, 0, 0, 1];
        Space=M*Space;
    end
    st{curfig}.Space=Space;
else
    Space=st{curfig}.Space;
    st{curfig}.Space(1:3,1:3)=Space(1:3,1:3)/(abs(Space(1:3,1:3))*scale);
    st{curfig}.Space(1:3,4)=st{curfig}.centre;
end
y_spm_orthviews('redraw');


% Hints: get(hObject,'String') returns contents of ScaleEntry as text
%        str2double(get(hObject,'String')) returns contents of ScaleEntry as a double

% --- Executes during object creation, after setting all properties.
function ScaleEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ScaleEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in CrosshairCheck.
function CrosshairCheck_Callback(hObject, eventdata, handles)
% hObject    handle to CrosshairCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
flag=get(handles.CrosshairCheck, 'Value');
if flag
    state='on';
else
    state='off';
end
y_spm_orthviews('xhairs', state)
% Hint: get(hObject,'Value') returns toggle state of CrosshairCheck

% --- Executes on button press in YokeCheck.
function YokeCheck_Callback(hObject, eventdata, handles)
% hObject    handle to YokeCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global st

curfig=handles.DPABI_fig;
curfig=w_Compatible2014bFig(curfig);

st{curfig}.yoke=1;
% Hint: get(hObject,'Value') returns toggle state of YokeCheck


% --- Executes on button press in NewButton.
function NewButton_Callback(hObject, eventdata, handles)
% hObject    handle to NewButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
New=DPABI_VIEW;
movegui(New, 'onscreen');

% --- Executes on button press in OverlayLabel.
function OverlayLabel_Callback(hObject, eventdata, handles)
% hObject    handle to OverlayLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DPABI_EGG
if isempty(DPABI_EGG)
    DPABI_EGG=0;
end
index=HeaderIndex(handles);
if ~index
    set(handles.OverlayLabel, 'Value', 0);
    DPABI_EGG=DPABI_EGG+1;
    if DPABI_EGG > 5
        msgbox('Don''t touch me, please!','modal');
        DPABI_EGG=0;
    end
    return
end

OverlayHeader=handles.OverlayHeaders{index};
RedrawOverlay(OverlayHeader, handles.DPABI_fig);
% Hint: get(hObject,'Value') returns toggle state of OverlayLabel


% --- Executes during object creation, after setting all properties.
function OverlayLabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OverlayLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function OverlayEntry_Callback(hObject, eventdata, handles)
% hObject    handle to OverlayEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global st;
curfig=handles.DPABI_fig;
curfig=w_Compatible2014bFig(curfig);

Num=get(handles.OverlayEntry, 'Value');
if Num==1
    set(handles.OverlayEntry, 'Value', st{curfig}.curblob+1);
    return
end
set(handles.OverlayLabel, 'Value', 1);
old_index=HeaderIndex(handles);
OverlayHeader=handles.OverlayHeaders{old_index};
RedrawOverlay(OverlayHeader, curfig);

st{curfig}.curblob=Num-1;
index=HeaderIndex(handles, Num-1);
OverlayHeader=handles.OverlayHeaders{index};
RedrawOverlay(OverlayHeader, curfig);
%state=w_OverlayConfig(handles.DPABI_fig, index, Num-1);

% handles=guidata(hObject);
% if ~state
%     set(handles.OverlayEntry, 'Value', st{curfig}.curblob+1);
% end

guidata(hObject, handles)

% Hints: get(hObject,'String') returns contents of OverlayEntry as text
%        str2double(get(hObject,'String')) returns contents of OverlayEntry as a double


% --- Executes during object creation, after setting all properties.
function OverlayEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OverlayEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in LeftButton.
function LeftButton_Callback(hObject, eventdata, handles)
% hObject    handle to LeftButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index=HeaderIndex(handles);
if ~index
    return
end
OverlayHeader=handles.OverlayHeaders{index};
oldTP=OverlayHeader.curTP;
curTP=oldTP-1;
set(handles.TimePointButton, 'String', sprintf('%d',curTP));
if curTP==1
    set(handles.LeftButton, 'Enable', 'Off');
end
set(handles.RightButton, 'Enable', 'On');

OverlayHeader=ChangeTP(OverlayHeader, curTP);
handles.OverlayHeaders{index}=OverlayHeader;

guidata(hObject, handles);

% --- Executes on button press in RightButton.
function RightButton_Callback(hObject, eventdata, handles)
% hObject    handle to RightButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index=HeaderIndex(handles);
if ~index
    return
end
OverlayHeader=handles.OverlayHeaders{index};
oldTP=OverlayHeader.curTP;
numTP=OverlayHeader.numTP;
curTP=oldTP+1;

set(handles.TimePointButton, 'String', sprintf('%d',curTP));
if curTP==numTP
    set(handles.RightButton, 'Enable', 'Off');
end
set(handles.LeftButton, 'Enable', 'On');

OverlayHeader=ChangeTP(OverlayHeader, curTP);
handles.OverlayHeaders{index}=OverlayHeader;

guidata(hObject, handles);

function TimePointButton_Callback(hObject, eventdata, handles)
% hObject    handle to TimePointButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index=HeaderIndex(handles);
if ~index
    return
end
OverlayHeader=handles.OverlayHeaders{index};
numTP=OverlayHeader.numTP;

curTP=str2double(get(handles.TimePointButton, 'String'));
if curTP<1 || curTP>numTP
    errordlg(sprintf('The number of time points: %d', numTP), 'Time Point Error');
    return;
end
if curTP==1
    set(handles.RightButton, 'Enable', 'On');
    set(handles.LeftButton, 'Enable', 'Off');
elseif curTP==numTP
    set(handles.RightButton, 'Enable', 'Off');
    set(handles.LeftButton, 'Enable', 'On');
else
    set(handles.RightButton, 'Enable', 'On');
    set(handles.LeftButton, 'Enable', 'On');    
end
OverlayHeader=ChangeTP(OverlayHeader, curTP);
handles.OverlayHeaders{index}=OverlayHeader;

guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of TimePointButton as text
%        str2double(get(hObject,'String')) returns contents of
%        TimePointButton as a double

% --- Executes during object creation, after setting all properties.
function TimePointButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimePointButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function OverlayHeader=ChangeTP(OverlayHeader, curTP, curfig, curblob, OverlayVolumes)
global st

if nargin < 3
    curfig=gcf;
    curfig=w_Compatible2014bFig(curfig);
end
if nargin < 4
    curblob=st{curfig}.curblob;
end
if nargin < 5
    OverlayVolumes=[];
end

cbarstring=OverlayHeader.cbarstring;
NMax=OverlayHeader.NMax;
NMin=OverlayHeader.NMin;
PMin=OverlayHeader.PMin;
PMax=OverlayHeader.PMax;
oldTP=OverlayHeader.curTP;
numTP=OverlayHeader.numTP;
if curTP~=oldTP
    if isempty(OverlayVolumes)
        OverlayFileName=OverlayHeader.fname;
        [OverlayVolume NewVox, NewHeader] = y_ReadRPI(OverlayFileName, curTP);
    else
        OverlayVolume=OverlayVolumes(:,:,:,curTP);
    end
        
    OverlayHeader.Raw = OverlayVolume;
else
    return;
end

OverlayHeader.cbarstring=cbarstring;
OverlayHeader.NMax=NMax;
OverlayHeader.NMin=NMin;
OverlayHeader.PMin=PMin;
OverlayHeader.PMax=PMax;
OverlayHeader.curTP=curTP;
OverlayHeader.numTP=numTP;
OverlayHeader.IsSelected=1;

OverlayHeader=RedrawOverlay(OverlayHeader, curfig);

% --- Executes on button press in OverlayButton.
function OverlayButton_Callback(hObject, eventdata, handles)
% hObject    handle to OverlayButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ok=w_OverlayList(handles.DPABI_fig);
if ~ok
    return;
end
handles=guidata(handles.DPABI_fig);

guidata(hObject, handles);

function UnderlayEntry_Callback(hObject, eventdata, handles)
% hObject    handle to UnderlayEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.UnderlayFileName)
    [DPABIPath, fileN, extn] = fileparts(which('DPABI.m'));

    TemplatePath=fullfile(DPABIPath, 'Templates');
    
    UnderlayFileName=fullfile(TemplatePath,'ch2.nii');
    [Path, Name, Ext]=fileparts(UnderlayFileName);
else
    [Path, Name, Ext]=fileparts(handles.UnderlayFileName);
end
NewName=get(handles.UnderlayEntry, 'String');
[NewPath, NewName, NewExt]=fileparts(NewName);
if isempty(NewPath)
    NewPath=Path;
end
NewFileName=[NewPath, filesep, NewName, NewExt];
if ~exist(NewFileName, 'file')
    errordlg('Image File not found', 'File Error');
    set(handles.UnderlayEntry, 'String', [Name, Ext]);
else
    handles.UnderlayFileName=NewFileName;
    guidata(hObject, handles);    
    ShowUnderlay(handles);
end
% Hints: get(hObject,'String') returns contents of UnderlayEntry as text
%        str2double(get(hObject,'String')) returns contents of UnderlayEntry as a double


% --- Executes during object creation, after setting all properties.
function UnderlayEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UnderlayEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in UnderlayButton.
function UnderlayButton_Callback(hObject, eventdata, handles)
% hObject    handle to UnderlayButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.UnderlayFileName)
    [File , Path]=uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
        'Pick Underlay File' , pwd);
else    
    [Path, Name, Ext]=fileparts(handles.UnderlayFileName);
    [File , Path]=uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
        'Pick Underlay File' , [Path , filesep , Name , Ext]);
end
if ~ischar(File)
    return;
end
UnderlayFileName=[Path, File];
handles.UnderlayFileName=UnderlayFileName;
handles.UserDefinedFileName=UnderlayFileName;
set(handles.UnderlayEntry, 'String', File);
guidata(hObject, handles);
ShowUnderlay(handles);

function ShowUnderlay(handles)
if isempty(handles.UnderlayFileName)
    [DPABIPath, fileN, extn] = fileparts(which('DPABI.m'));

    TemplatePath=fullfile(DPABIPath, 'Templates');
    UnderlayFileName=fullfile(TemplatePath,'ch2.nii');
else
    UnderlayFileName=handles.UnderlayFileName;
end
[UnderlayVolume UnderlayVox UnderlayHeader] = y_ReadRPI(UnderlayFileName);
UnderlayHeader.Data = UnderlayVolume;
UnderlayHeader.Vox  = UnderlayVox;

y_spm_orthviews('Image',UnderlayHeader);

Max=length(get(handles.TemplatePopup, 'String'));
set(handles.TemplatePopup, 'Value', Max-1);

function handles=NoneUnderlay(handles)
global st
curfig=handles.DPABI_fig;
curfig=w_Compatible2014bFig(curfig);
index=HeaderIndex(handles);
if ~index
    st{curfig}.vols{1}.Data=zeros(st{curfig}.vols{1}.dim);
    y_spm_orthviews('Redraw');
else
    OverlayHeader=handles.OverlayHeaders{index};
    OverlayHeader.Data=zeros(OverlayHeader.dim);
    y_spm_orthviews('Image', OverlayHeader);
    handles.UnderlayFileName=OverlayHeader.fname;
end


% --- Executes on selection change in TemplatePopup.
function TemplatePopup_Callback(hObject, eventdata, handles)
% hObject    handle to TemplatePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
flag=get(handles.TemplatePopup, 'Value');
Max=length(get(handles.TemplatePopup, 'String'));
[DPABIPath, fileN, extn] = fileparts(which('DPABI.m'));

switch flag
    case 1
        File='ch2.nii';
    case 2
        File='ch2bet.nii';
    case 3
        File='ch2better.nii';
    case 4
        File='mni_icbm152_t1_tal_nlin_asym_09c.nii';
    case 5
        UnderlayFileName=handles.UserDefinedFileName;
        [UnderlayVolume UnderlayVox UnderlayHeader] = y_ReadRPI(UnderlayFileName);
        UnderlayHeader.Data = UnderlayVolume;
        UnderlayHeader.Vox  = UnderlayVox;
        y_spm_orthviews('Image',UnderlayHeader);
        return;
    case Max
        handles=NoneUnderlay(handles);
        set(handles.UnderlayEntry, 'String', '');
        guidata(hObject, handles);
        return;
    otherwise
        return;
end
UnderlayFileName=[DPABIPath,filesep,'Templates',filesep, File];
[UnderlayVolume UnderlayVox UnderlayHeader] = y_ReadRPI(UnderlayFileName);
UnderlayHeader.Data = UnderlayVolume;
UnderlayHeader.Vox  = UnderlayVox;
y_spm_orthviews('Image',UnderlayHeader);

set(handles.UnderlayEntry, 'String', File);
set(handles.TemplatePopup, 'Value', flag);

handles.UnderlayFileName=UnderlayFileName;
guidata(hObject, handles);

% Hints: contents = get(hObject,'String') returns TemplatePopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TemplatePopup


% --- Executes during object creation, after setting all properties.
function TemplatePopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TemplatePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function ThrdSlider_Callback(hObject, eventdata, handles)
% hObject    handle to ThrdSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ThrdListener_Callback(hObject, eventdata, hObject);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

function ThrdListener_Callback(hObject, eventdata, hFig)
handles=guidata(hFig);
curfig=handles.DPABI_fig;
curfig=w_Compatible2014bFig(curfig);

value=get(handles.ThrdSlider, 'Value');
index=HeaderIndex(handles);
if ~index
    return
end

OverlayHeader=handles.OverlayHeaders{index};

PMax=OverlayHeader.PMax;
NMax=OverlayHeader.NMax;
Max=PMax;

if abs(NMax) > abs(PMax)
    Max=abs(NMax);
end

Thrd=Max*value;

set(handles.ThrdEntry, 'String', sprintf('%g', Thrd));
OverlayHeader=ChangeThrd(OverlayHeader, -Thrd, Thrd, curfig);
handles.OverlayHeaders{index}=OverlayHeader;
guidata(curfig, handles);

switch upper(OverlayHeader.TestFlag)
    case 'T'
        Df=OverlayHeader.Df;
        P=2*(1-tcdf(abs(Thrd), Df));
    case 'R'
        Df=OverlayHeader.Df;
        T=sqrt(Df*(Thrd^2/(1-Thrd^2)));
        P=2*(1-tcdf(abs(Thrd)*T, Df));
    case 'F'
        Df1=OverlayHeader.Df;
        Df2=OverlayHeader.Df2;
        P=(1-fcdf(Thrd, Df1, Df2));
    case 'Z'
        P=2*(1-normcdf(abs(Thrd)));
    otherwise
        return;
end
set(handles.PEntry, 'String', num2str(P));

function [OverlayHeader, SendHeader]=RedrawOverlay(SendHeader, curfig, curblob)
global st
if nargin<2
    curfig=gcf;
end
curfig=w_Compatible2014bFig(curfig);

MainHandle=guidata(curfig);
if nargin<3
    curblob=st{curfig}.curblob;
end

Transparency=1-st{curfig}.vols{1}.blobs{curblob}.colour.prop;
PMax=SendHeader.PMax;
PMin=SendHeader.PMin;
NMin=SendHeader.NMin;
NMax=SendHeader.NMax;
cbarstring=SendHeader.cbarstring;
cbarstring = SendHeader.cbarstring;
if cbarstring(end)=='+' || cbarstring(end)=='-'
    PN_Flag=cbarstring(end);
    cbarstring=cbarstring(1:end-1);
else
    PN_Flag=[];
end
cbar=str2double(cbarstring);


OverlayVolume=SendHeader.Raw;
OverlayVolume(~SendHeader.Mask)=0;
OverlayVolume(~SendHeader.AMask)=0;
if NMax >= 0
    OverlayVolume(OverlayVolume<0) = 0;
end
if PMax <= 0
    OverlayVolume(OverlayVolume>0) = 0;
end

SendHeader.Data=OverlayVolume.*...
    ((OverlayVolume < NMin) + (OverlayVolume > PMin));
OverlayHeader=SendHeader;


if SendHeader.CSize
    SendHeader=SetCSize(SendHeader);
end

if ~isempty(SendHeader.ThrdIndex)
    Tokens=regexp(SendHeader.ThrdIndex, '(\d+\.*\d*:?\d*\.*\d*)', 'tokens');
    if ~isempty(Tokens)
        L=false(size(SendHeader.Data));
        for t=1:numel(Tokens)
            Num=Tokens{t};
            Num=str2num(Num{1});
            LL=false(size(SendHeader.Data));
            if length(Num)==1
                LL(SendHeader.Data==Num)=1;
            else
                LL(SendHeader.Data>=Num(1) & SendHeader.Data<=Num(end))=1;
            end
            L=L+LL;
        end
        SendHeader.Data(~L)=0;
    end
end
%Only +/-/Display Current Overlay/No Overlay
if get(MainHandle.OverlayLabel, 'Value')
    if get(MainHandle.OnlyPos, 'Value')
        SendHeader.Data(OverlayVolume < 0) = 0;
    elseif get(MainHandle.OnlyNeg, 'Value')
        SendHeader.Data(OverlayVolume > 0) = 0;
    elseif get(MainHandle.OnlyUnder, 'Value')
        SendHeader.Data(OverlayVolume~= 0) = 0;
    end
else
    SendHeader.Data(OverlayVolume~= 0) = 0;
end

if cbar==0 && isfield(SendHeader, 'ColorMap')
    ColorMap=SendHeader.ColorMap;
else
    if isnan(cbar)
        ColorMap = colormap(cbarstring);
    else
        ColorMap = y_AFNI_ColorMap(cbar);
    end
    OverlayHeader.ColorMap=ColorMap;
end
ColorMap = y_AdjustColorMap(ColorMap,...
    [0.75 0.75 0.75],...
    NMax,...
    NMin,...
    PMin,...
    PMax,...
    PN_Flag);

y_spm_orthviews('Settruecolourimage',...
    curfig,...
    SendHeader,...
    ColorMap,...
    1-Transparency,...
    PMax,...
    NMax,...
    curblob);

handles=guidata(curfig);
if get(handles.TemplatePopup, 'Value')==length(get(handles.TemplatePopup, 'String'))
    handles=NoneUnderlay(handles);
    guidata(curfig, handles);
else
    y_spm_orthviews('Redraw', curfig);
end


function OverlayHeader=ChangeThrd(OverlayHeader, NMin, PMin, curfig)
if nargin<4
    curfig=gcf;
    curfig=w_Compatible2014bFig(curfig);
end
OverlayHeader.NMin=NMin;
OverlayHeader.PMin=PMin;
OverlayHeader=RedrawOverlay(OverlayHeader, curfig);

% --- Executes during object creation, after setting all properties.
function ThrdSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ThrdSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function ThrdEntry_Callback(hObject, eventdata, handles)
% hObject    handle to ThrdEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index=HeaderIndex(handles);
if ~index
    set(handles.ThrdEntry, 'String', []);
    return
end

Thrd=str2double(get(handles.ThrdEntry, 'String'));
if isnan(Thrd)
    set(handles.ThrdEntry, 'String', []);
    return;
end

curfig=handles.DPABI_fig;
curfig=w_Compatible2014bFig(curfig);

OverlayHeader=handles.OverlayHeaders{index};

PMax=OverlayHeader.PMax;
NMax=OverlayHeader.NMax;
Max=PMax;

if abs(NMax) > abs(PMax)
    Max=abs(NMax);
end
Value=Thrd/Max;

set(handles.ThrdSlider, 'Value', Value);
set(handles.ThrdEntry, 'String', sprintf('%g', Thrd));
OverlayHeader=ChangeThrd(OverlayHeader, -Thrd, Thrd, curfig);
handles.OverlayHeaders{index}=OverlayHeader;
guidata(curfig, handles);
% Hints: get(hObject,'String') returns contents of ThrdEntry as text
%        str2double(get(hObject,'String')) returns contents of ThrdEntry as a double


% --- Executes during object creation, after setting all properties.
function ThrdEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ThrdEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function PEntry_Callback(hObject, eventdata, handles)
% hObject    handle to PEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index=HeaderIndex(handles);
if ~index
    set(handles.PEntry, 'String', []);
    return
end
OverlayHeader=handles.OverlayHeaders{index};
P=str2double(get(handles.PEntry, 'String'));
if isnan(P)
    set(handles.PEntry, 'String', []);
    return;
end
switch upper(OverlayHeader.TestFlag)
    case 'T'
        Df=OverlayHeader.Df;
        Thrd=tinv(1-P/2, Df);
    case 'R'
        Df=OverlayHeader.Df;
        T=tinv(1-P/2, Df);
        Thrd=sqrt(T^2/(Df+T^2));
    case 'F'
        Df1=OverlayHeader.Df;
        Df2=OverlayHeader.Df2;
        Thrd=finv(1-P, Df1, Df2);
    case 'Z'
        Thrd=norminv(1-P/2);
    otherwise
        return;
end
set(handles.ThrdEntry, 'String', num2str(Thrd));
%Max=max([abs(OverlayHeader.PMax),abs(OverlayHeader)]);
%Max
OverlayHeader=ChangeThrd(OverlayHeader, -Thrd, Thrd, handles.DPABI_fig);
handles.OverlayHeaders{index}=OverlayHeader;
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of PEntry as text
%        str2double(get(hObject,'String')) returns contents of PEntry as a double


% --- Executes during object creation, after setting all properties.
function PEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DfButton.
function DfButton_Callback(hObject, eventdata, handles)
% hObject    handle to DfButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index=HeaderIndex(handles);
if ~index
    return
end
OverlayHeader=handles.OverlayHeaders{index};
Para=w_ChangeDf(OverlayHeader);
if ~iscell(Para)
    return;
end
OverlayHeader.TestFlag=Para{1};
OverlayHeader.Df=Para{2};
OverlayHeader.Df2=Para{3};

handles.OverlayHeaders{index}=OverlayHeader;
guidata(hObject, handles);

function PosNegNon(OverlayHeaders, flag, curfig)
global st
if nargin<3
    curfig=gcf;
    curfig=w_Compatible2014bFig(curfig);
end

if isfield(st{curfig}.vols{1}, 'blobs')
    blob=0;
    for i=1:numel(OverlayHeaders)
        if ~isempty(OverlayHeaders{i}) && ...
                OverlayHeaders{i}.IsSelected
            blob=blob+1;
            OverlayHeader=OverlayHeaders{i};
            if strcmpi(flag, '+')
                OverlayHeader.Data(OverlayHeader.Data < 0)=0;
            elseif strcmpi(flag, '-')
                OverlayHeader.Data(OverlayHeader.Data > 0)=0;
            elseif strcmpi(flag, 'N')
                OverlayHeader.Data(OverlayHeader.Data~= 0)=0;
            end
            OverlayHeader=SetCSize(OverlayHeader);
            st{curfig}.vols{1}.blobs{blob}.vol=OverlayHeader;
        else
            continue;
        end
    end
end

% --- Executes on button press in OnlyPos.
function OnlyPos_Callback(hObject, eventdata, handles)
% hObject    handle to OnlyPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curfig=handles.DPABI_fig;
curfig=w_Compatible2014bFig(curfig);

flag=get(handles.OnlyPos, 'Value');

if flag
    set(handles.OnlyNeg,   'Value', ~flag);
    set(handles.OnlyUnder, 'Value', ~flag);
    PosNegNon(handles.OverlayHeaders, '+', curfig);
else
    PosNegNon(handles.OverlayHeaders, 'A', curfig);
end

y_spm_orthviews('Redraw');
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of OnlyPos


% --- Executes on button press in OnlyNeg.
function OnlyNeg_Callback(hObject, eventdata, handles)
% hObject    handle to OnlyNeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curfig=handles.DPABI_fig;
curfig=w_Compatible2014bFig(curfig);

flag=get(handles.OnlyNeg, 'Value');

if flag
    set(handles.OnlyPos,   'Value', ~flag);
    set(handles.OnlyUnder, 'Value', ~flag);
    PosNegNon(handles.OverlayHeaders, '-', curfig);
else
    PosNegNon(handles.OverlayHeaders, 'A', curfig);
end

y_spm_orthviews('Redraw');
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of OnlyNeg


% --- Executes on button press in OnlyUnder.
function OnlyUnder_Callback(hObject, eventdata, handles)
% hObject    handle to OnlyUnder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curfig=handles.DPABI_fig;
curfig=w_Compatible2014bFig(curfig);

flag=get(handles.OnlyUnder, 'Value');

if flag
    set(handles.OnlyPos,   'Value', ~flag);
    set(handles.OnlyNeg, 'Value', ~flag);
    PosNegNon(handles.OverlayHeaders, 'N', curfig);
else
    PosNegNon(handles.OverlayHeaders, 'A', curfig);
end

y_spm_orthviews('Redraw');
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of OnlyUnder


% --- Executes on selection change in ClusterPopup.
function ClusterPopup_Callback(hObject, eventdata, handles)
% hObject    handle to ClusterPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index=HeaderIndex(handles);
if ~index
    return
end
Value=get(handles.ClusterPopup, 'Value');
OverlayHeader=handles.OverlayHeaders{index};
switch Value
    case 1
        return
    case 2 %Set Cluster Size
        OverlayHeader=w_ClusterSize(OverlayHeader);
        if isempty(OverlayHeader)
            return
        end
        OverlayHeader=RedrawOverlay(OverlayHeader);
        handles.OverlayHeaders{index}=OverlayHeader;
    case 3 %Save Single Cluster
        [File , Path]=uiputfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
            'Save All Clusters' , OverlayHeader.fname);
        if ~ischar(File)
            return
        end
        [OverlayHeader, SendHeader]=RedrawOverlay(OverlayHeader);
        
        [Path, FileName, Ext]=fileparts(fullfile(Path, File));
        MaskName=sprintf('%s_mask',FileName);
        Data=SingleCluster(SendHeader);
        if isempty(Data)
            return
        end
        Mask=logical(Data);
        y_Write(Data, SendHeader, fullfile(Path, [FileName, Ext]));
        y_Write(Mask, SendHeader, fullfile(Path, [MaskName, Ext]));
    case 4 %Save All Clusters
        [File , Path]=uiputfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
            'Save All Clusters' , OverlayHeader.fname);
        if ~ischar(File)
            return
        end
        [OverlayHeader, SendHeader]=RedrawOverlay(OverlayHeader);
        
        [Path, FileName, Ext]=fileparts(fullfile(Path, File));
        MaskName=sprintf('%s_mask',FileName);
        Data=SendHeader.Data;
        Mask=logical(Data);
        y_Write(Data, SendHeader, fullfile(Path, [FileName, Ext]));
        y_Write(Mask, SendHeader, fullfile(Path, [MaskName, Ext]));
    case 5 %Find Peak in this Cluster
        OverlayHeader=SetCSize(OverlayHeader);
        OverlayHeader=SetPosNeg(OverlayHeader, handles);
        FindPeak(OverlayHeader);
    case 6 %Volume Percentage
        OverlayHeader=w_Percentage(OverlayHeader);
        if isempty(OverlayHeader)
            return
        end
        OverlayHeader=RedrawOverlay(OverlayHeader);
        handles.OverlayHeaders{index}=OverlayHeader;        
    case 7 %FDR
        OverlayHeader=w_FDRCorrection(OverlayHeader);
        if isempty(OverlayHeader)
            return
        end
        OverlayHeader=RedrawOverlay(OverlayHeader, handles.DPABI_fig);
        handles.OverlayHeaders{index}=OverlayHeader;        
    case 8 %GRF
        OverlayHeader=w_GRFCorrection(OverlayHeader);
        if isempty(OverlayHeader)
            return
        end
        [OverlayHeader, SendHeader]=RedrawOverlay(OverlayHeader);
        %OverlayHeader.Data = SendHeader.Data; %OverlayHeader=SetCSize(OverlayHeader); %YAN Chao-Gan, 140822. Need to save the data after setting cluster size.
        handles.OverlayHeaders{index}=OverlayHeader;        
    case 9 %AlphaSim
        w_AlphaSimCorrection(OverlayHeader);
    case 10 %Cluster Report
        OverlayHeader=SetCSize(OverlayHeader);               
        OverlayHeader=SetPosNeg(OverlayHeader, handles); %Add by Sandy to set cluster size at first when someone use Cluster Report       
        y_ClusterReport(OverlayHeader.Data, OverlayHeader, OverlayHeader.RMM);
    case 11 %Apply a Mask for Additionally Thresholding
        OverlayHeader=w_ApplyAdditionalMask(OverlayHeader);
        if isempty(OverlayHeader)
            return
        end
        OverlayHeader=RedrawOverlay(OverlayHeader);
        handles.OverlayHeaders{index}=OverlayHeader;  
end
guidata(hObject, handles);
% Hints: contents = get(hObject,'String') returns ClusterPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ClusterPopup


% --- Executes during object creation, after setting all properties.
function ClusterPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ClusterPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in MorePopup.
function MorePopup_Callback(hObject, eventdata, handles)
% hObject    handle to MorePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global st
curfig=handles.DPABI_fig;
curfig=w_Compatible2014bFig(curfig);
curblob=st{curfig}.curblob;

Value=get(handles.MorePopup, 'Value');
switch Value
    case 1
        return
    case 2 %Time Course
        Headers=cell(numel(handles.OverlayHeaders), 1);
        f=0;
        for i=1:numel(handles.OverlayHeaders)
            if ~isempty(handles.OverlayHeaders{i}) && ...
                    handles.OverlayHeaders{i}.IsSelected && ...
                    handles.OverlayHeaders{i}.numTP > 1
                Headers{i}=handles.OverlayHeaders{i};
                f=1;
            end
        end
        if ~f
            return;
        end
        w_TimeCourse(handles.DPABI_fig, Headers);
    case 3 %Call BrainNet Viewer
        if ~(exist('BrainNet.m'))
            msgbox('The surface view is based on Mingrui Xia''s BrainNet Viewer. Please install BrainNet Viewer 1.1 or later version at first (http://www.nitrc.org/projects/bnv/).','DPABI_VIEW', 'modal');
            return
        end
        
        index=HeaderIndex(handles);
        OverlayHeader=handles.OverlayHeaders{index};
        OverlayHeader=SetPosNeg(OverlayHeader, handles);
        OverlayHeader=SetCSize(OverlayHeader);
        CVSize=OverlayHeader.CSize/prod(OverlayHeader.Vox);
        
        cbarstring = OverlayHeader.cbarstring;
        if cbarstring(end)=='+' || cbarstring(end)=='-'
            PN_Flag=cbarstring(end);
            cbarstring=cbarstring(1:end-1);
        else
            PN_Flag=[];
        end
        cbar=str2double(cbarstring);
        
        if cbar==0 && isfield(OverlayHeader, 'ColorMap') %YAN Chao-Gan, 161218. if cbar==0 && isfield(SendHeader, 'ColorMap')
            ColorMap=OverlayHeader.ColorMap;
        else
            if isnan(cbar)
                ColorMap = colormap(cbarstring);
            else
                ColorMap = y_AFNI_ColorMap(cbar);
            end
        end

%         ColorMap = y_AdjustColorMap(ColorMap,...
%             [0.75 0.75 0.75],...
%             OverlayHeader.NMax,...
%             OverlayHeader.NMin,...
%             OverlayHeader.PMin,...
%             OverlayHeader.PMax);

        [BrainNetViewerPath, fileN, extn] = fileparts(which('BrainNet.m'));
        SurfFileName=[BrainNetViewerPath,filesep,'Data',filesep,'SurfTemplate',filesep,'BrainMesh_ICBM152_smoothed.nv'];

        y_CallBrainNetViewer(OverlayHeader.Data,...
            OverlayHeader.NMin, OverlayHeader.PMin,...
            CVSize, OverlayHeader.RMM,...
            SurfFileName, 'MediumView', ColorMap,...
            OverlayHeader.NMax, OverlayHeader.PMax,...
            OverlayHeader,...
            PN_Flag);
    case 4 % Set Range
        index=HeaderIndex(handles);
        if ~index
            return
        end
        OverlayHeader=handles.OverlayHeaders{index};
        ThrdIndex=OverlayHeader.ThrdIndex;
        ThrdIndex=inputdlg('Set threshold range (e.g., "2:5,10,12" means all the values within 2 and 5 (including decimals) and values of 10 and 12.',...
            'Range of Overlay''s Thrdhold',...
            1, {ThrdIndex});
        if isempty(ThrdIndex)
            return
        end
        OverlayHeader.ThrdIndex=ThrdIndex{1};
        OverlayHeader=RedrawOverlay(OverlayHeader);
        handles.OverlayHeaders{index}=OverlayHeader;
    case 5 % Set Colorbar Manually
        index=HeaderIndex(handles);
        if ~index
            return
        end
        OverlayHeader=handles.OverlayHeaders{index};
        
        colormap(OverlayHeader.ColorMap);
        w_colormapeditor(handles.DPABI_fig);
    case 6 % Transparency
        Transparency=1-st{curfig}.vols{1}.blobs{curblob}.colour.prop;
        Transparency=inputdlg('Set Transparency (Default = 0.2)',...
            'Transparency of Overlay',...
            1, {num2str(Transparency)});
        if isempty(Transparency)
            return
        end
        st{curfig}.vols{1}.blobs{curblob}.colour.prop=1-str2double(Transparency{1});
        y_spm_orthviews('Redraw', curfig);
    case 7 %Save as Picture
        [File, Path] = uiputfile({'*.tiff';'*.jpeg';'*.png';'*.bmp'},...
            'Save Picture As');
        if ~ischar(File)
            return;
        end
        [Path, Name, Ext]=fileparts(fullfile(Path, File));
        TName=sprintf('%s_Transverse', Name);
        CName=sprintf('%s_Coronal', Name);
        SName=sprintf('%s_Sagittal', Name);
        TData=getframe(st{curfig}.vols{1}.ax{1}.ax);
        CData=getframe(st{curfig}.vols{1}.ax{2}.ax);
        SData=getframe(st{curfig}.vols{1}.ax{3}.ax);
 
        saveas(curfig, fullfile(Path, [Name, Ext]));
        eval(['print -r300 -dtiff -noui ''',fullfile(Path, [Name, '_300dpi', Ext]),''';']); %YAN Chao-Gan, 140806.
        
        imwrite(TData.cdata, fullfile(Path, [TName, Ext]));
        imwrite(CData.cdata, fullfile(Path, [CName, Ext]));
        imwrite(SData.cdata, fullfile(Path, [SName, Ext]));
    case 8 %Save colorbar as Picture
        [File, Path] = uiputfile({'*.tiff';'*.jpeg';'*.png';'*.bmp'},...
            'Save Picture As');
        if ~ischar(File)
            return;
        end
        
        index=HeaderIndex(handles);
        if ~index
            return
        end        
        OverlayHeader=handles.OverlayHeaders{index};
        
        cbarstring=OverlayHeader.cbarstring;
        if cbarstring(end)=='+' || cbarstring(end)=='-'
            PN_Flag=cbarstring(end);
            cbarstring=cbarstring(1:end-1);
        else
            PN_Flag=[];
        end        
        cbar=str2double(cbarstring);
        if cbar==0 && isfield(OverlayHeader, 'ColorMap')
            ColorMap=OverlayHeader.ColorMap;
        else
            if isnan(cbar)
                ColorMap = colormap(cbarstring);
            else
                ColorMap = y_AFNI_ColorMap(cbar);
            end
        end
        
        %ColorMap=flipdim(ColorMap, 1);
        L=size(ColorMap, 1);
        NMax=OverlayHeader.NMax;
        NMin=OverlayHeader.NMin;
        PMin=OverlayHeader.PMin;
        PMax=OverlayHeader.PMax;
        if NMax==0 && NMax==NMin;
            Scale=(L:-1:L/2+1)';
        elseif PMax==0 && PMax==PMin
            Scale=(L/2:-1:1)';
        else
            Scale=(1:L)';
        end
        
        imwrite(imresize(Scale, [320*L, 200]),...
            ColorMap, fullfile(Path, File));
    case 9 %Save colorbar as MAT
        index=HeaderIndex(handles);
        if ~index
            return
        end
        
        [File, Path] = uiputfile('Colormap.mat',...
            'Save Colormap As MAT');
        if ~ischar(File)
            return;
        end
                
        OverlayHeader=handles.OverlayHeaders{index};
        
        cbarstring=OverlayHeader.cbarstring;
        if cbarstring(end)=='+' || cbarstring(end)=='-'
            PN_Flag=cbarstring(end);
            cbarstring=cbarstring(1:end-1);
        else
            PN_Flag=[];
        end        
        cbar=str2double(cbarstring);
        
        if cbar==0 && isfield(OverlayHeader, 'ColorMap')
            ColorMap=OverlayHeader.ColorMap;
        else
            if isnan(cbar)
                ColorMap = colormap(cbarstring);
            else
                ColorMap = y_AFNI_ColorMap(cbar);
            end
        end
        OverlayHeader.ColorMap=ColorMap;
        save(fullfile(Path, File), 'ColorMap');
    case 10 %Load colorbar from MAT
        index=HeaderIndex(handles);
        if ~index
            return
        end     
        
        [File, Path] = uigetfile('*.mat',...
            'Load Colormap from MAT');
        if ~ischar(File)
            return;
        end
         
        Temp=load(fullfile(Path, File));
        ColorMap=Temp.ColorMap;
        OverlayHeader=handles.OverlayHeaders{index};
        OverlayHeader.ColorMap=ColorMap;
        OverlayHeader.cbarstring='0';
        OverlayHeader=RedrawOverlay(OverlayHeader, handles.DPABI_fig);
        
        handles.OverlayHeaders{index}=OverlayHeader; %YAN Chao-Gan, 161218. Fixed a bug: handles.OverlayHeader{index}=OverlayHeader;
    case 11 %Surface View with DPABISurf_VIEW
        Index=get(handles.ClusterPopup,'Value');
        Overlay_All=get(handles.OverlayEntry,'String');
        Overlay_Ind=get(handles.OverlayEntry,'Value');
        File=split(Overlay_All{Overlay_Ind},' ');
        File_name=File(1);
        File_path=File(2);
        File_1=split(File_path,'(');
        File_2=split(File_1(2),')');
        InFile=strcat(File_2(1),'/',File_name);
        WriteFile=strcat(File_2(1),'/','CurrentOverlay_2_Surf.nii');
        WriteFile=WriteFile{1,1};       
        if Index==11
            y_Write(handles.OverlayHeaders{1,1}.Data.*2,handles.OverlayHeaders{1,1},WriteFile);
        else
        y_Write(handles.OverlayHeaders{1,1}.Data,handles.OverlayHeaders{1,1},WriteFile);
        end
        OutFile=split(InFile,'.');
        Surf=cell(2,1);
        Surf{1,1}=strcat(OutFile{1,1},'_Surf_lh.gii');
        Surf{2,1}=strcat(OutFile{1,1},'_Surf_rh.gii');
        OutFile=strcat(OutFile(1),'_Surf.gii');
        y_Write(handles.OverlayHeaders{1,1}.Data,handles.OverlayHeaders{1,1},'CurrentOverlay_2_Surf');       
        if Index==11
%             y_Vol2Surf(InFile{1,1},OutFile{1,1},1,'fsaverage');
            y_Vol2Surf(WriteFile,OutFile{1,1},1,'fsaverage');
        else
        y_Vol2Surf(InFile{1,1},OutFile{1,1},1,'fsaverage');
        end
        Thrd=min(abs(handles.OverlayHeaders{1,1}.Data(handles.OverlayHeaders{1,1}.Data~=0)));
        Max=max(handles.OverlayHeaders{1,1}.Data);
        Max=max(Max);
        Max=max(Max);
        Min=min(handles.OverlayHeaders{1,1}.Data);
        Min=min(Min);
        Min=min(Min);
        Raw_Max=max(handles.OverlayHeaders{1,1}.Raw);
        Raw_Max=max(Raw_Max);
        Raw_Max=max(Raw_Max);
        Raw_Min=min(handles.OverlayHeaders{1,1}.Raw);
        Raw_Min=min(Raw_Min);
        Raw_Min=min(Raw_Min);
        if Index==11
            Raw_Min=0;
            Thrd=0;
            Raw_Max=0;
        end
        ch_view2Surfview(Surf,Thrd,Max,Min,Raw_Max,Raw_Min,eventdata)
end
guidata(hObject, handles);
% Hints: contents = get(hObject,'String') returns MorePopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MorePopup


% --- Executes during object creation, after setting all properties.
function MorePopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MorePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in SIButton.
function SIButton_Callback(hObject, eventdata, handles)
% hObject    handle to SIButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global st
curfig=handles.DPABI_fig;
curfig=w_Compatible2014bFig(curfig);
SI={'S','I'};
state=get(handles.SIButton, 'String');
state=strcmpi(state, 'S')+1;
state=SI{state};

bb=st{curfig}.bb;
offset=-bb(1,2)-bb(2,2);
M=[ 1, 0, 0, 0;
    0, 1, 0, 0;
    0, 0, -1, offset;
    0, 0, 0, 1];
st{curfig}.Space=M*st{curfig}.Space;

set(handles.SIButton, 'String', state);
y_spm_orthviews('redraw');

% --- Executes on button press in PAButton.
function PAButton_Callback(hObject, eventdata, handles)
% hObject    handle to PAButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global st
curfig=handles.DPABI_fig;
curfig=w_Compatible2014bFig(curfig);
PA={'P','A'};
state=get(handles.PAButton, 'String');
state=strcmpi(state, 'P')+1;
state=PA{state};

bb=st{curfig}.bb;
offset=-bb(1,3)-bb(2,3);
M=[ 1, 0, 0, 0;
    0, -1, 0, offset;
    0, 0, 1, 0;
    0, 0, 0, 1];
st{curfig}.Space=M*st{curfig}.Space;

set(handles.PAButton, 'String', state);
y_spm_orthviews('redraw');

% --- Executes on button press in LRButton.
function LRButton_Callback(hObject, eventdata, handles)
% hObject    handle to LRButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global st
curfig=handles.DPABI_fig;
curfig=w_Compatible2014bFig(curfig);
LR={'R','L'};
state=get(handles.LRButton, 'String');
state=strcmpi(state, 'R')+1;
state=LR{state};

bb=st{curfig}.bb;
offset=-bb(1,1)-bb(2,1);
M=[-1, 0, 0, offset;
    0, 1, 0, 0;
    0, 0, 1, 0;
    0, 0, 0, 1];
st{curfig}.Space=M*st{curfig}.Space;

set(handles.LRButton, 'String', state);
y_spm_orthviews('redraw');

function index = HeaderIndex(handles, curblob)
global st;
curfig=handles.DPABI_fig;
curfig=w_Compatible2014bFig(curfig);
if nargin<2
    curblob=st{curfig}.curblob;
end

if curblob==0;
    index=0;
    return
end
OverlayFile=handles.OverlayFileName{curblob};
index=0;
for i=1:length(handles.OverlayHeaders)
    OverlayHeader=handles.OverlayHeaders{i};
    if ~isempty(OverlayHeader) && strcmp(OverlayFile, OverlayHeader.fname)
        index=i;
        break;
    end
end

if ~index
    errordlg('Header Error');
end


function centre=Pos(handles, label)
global st

centre=zeros(1,3);
switch lower(label)
    case 'xyz'
        centre(1)=str2double(get(handles.XEntry, 'String'));
        centre(2)=str2double(get(handles.YEntry, 'String'));
        centre(3)=str2double(get(handles.ZEntry, 'String'));
    case 'ijk'
        I=str2double(get(handles.IEntry, 'String'));
        J=str2double(get(handles.JEntry, 'String'));
        K=str2double(get(handles.KEntry, 'String'));
        curfig=handles.DPABI_fig;
        curfig=w_Compatible2014bFig(curfig);
        curblob=st{curfig}.curblob;
        if isfield(st{curfig}.vols{1}, 'blobs')
            tmp=st{curfig}.vols{1}.blobs{curblob}.vol.mat*[I;J;K;1];
        else
            tmp=st{curfig}.vols{1}.mat*[I;J;K;1];
        end
        centre(1)=tmp(1);
        centre(2)=tmp(2);
        centre(3)=tmp(3);
end

function OverlayHeader=SetCSize(OverlayHeader)
if ~OverlayHeader.CSize
    return
end

OverlayVolume=OverlayHeader.Data;
RMM=OverlayHeader.RMM;
CSize=OverlayHeader.CSize;
V=prod(OverlayHeader.Vox);
CVSize=CSize/V;

CC=bwconncomp(logical(OverlayVolume), RMM);

numPixels=cellfun(@numel, CC.PixelIdxList);

N=CC.PixelIdxList(numPixels<CVSize)';

Index=cell2mat(N);
OverlayVolume(Index)=0;

OverlayHeader.Data=OverlayVolume;

function OverlayHeader=SetPosNeg(OverlayHeader, handles)
if get(handles.OnlyPos, 'Value')
    OverlayHeader.Data(OverlayHeader.Data<0)=0;
end
if get(handles.OnlyNeg, 'Value');
    OverlayHeader.Data(OverlayHeader.Data>0)=0;
end

function OverlayVolume = SingleCluster(OverlayHeader)
OverlayVolume=OverlayHeader.Data;
RMM=OverlayHeader.RMM;

pos=y_spm_orthviews('pos');
tmp=round(inv(OverlayHeader.mat)*[pos;1]);
OI=tmp(1);
OJ=tmp(2);
OK=tmp(3);
if ~OverlayVolume(OI, OJ, OK)
    OverlayVolume=[];
    return;
end

CC=bwconncomp(logical(OverlayVolume), RMM);
L=labelmatrix(CC);
V=L(OI, OJ, OK);
OverlayVolume(L~=V)=0;

function FindPeak(OverlayHeader)
OverlayVolume=OverlayHeader.Data;
RMM=OverlayHeader.RMM;

pos=y_spm_orthviews('pos');
tmp=round(inv(OverlayHeader.mat)*[pos;1]);
OI=tmp(1);
OJ=tmp(2);
OK=tmp(3);
if ~OverlayVolume(OI, OJ, OK)
    return;
end

CC=bwconncomp(logical(OverlayVolume), RMM);
L=labelmatrix(CC);
V=L(OI, OJ, OK);
V=V==L;
OverlayVolume=OverlayVolume.*V;
Max=max(abs(OverlayVolume(:)));
[I, J, K]=ind2sub(size(OverlayVolume), find(abs(OverlayVolume)==Max));
MI=I(1);
MJ=J(1);
MK=K(1);
centre=OverlayHeader.mat*[MI;MJ;MK;1];
y_spm_orthviews('Reposition', centre(1:3));

if length(I) > 1
    msgbox(sprintf('There are %d max point in this cluster', length(I)), 'modal');
end



function AddReduce(hObject, label)
Value=str2double(get(hObject, 'String'));
if strcmpi(label, '+')
    String=num2str(Value+1);
else
    String=num2str(Value-1);
end
set(hObject, 'String', String);

% --- Executes on button press in XAddBtn.
function XAddBtn_Callback(hObject, eventdata, handles)
% hObject    handle to XAddBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AddReduce(handles.XEntry, '+');
centre=Pos(handles, 'XYZ');
y_spm_orthviews('Reposition', centre);

% --- Executes on button press in XReduceBtn.
function XReduceBtn_Callback(hObject, eventdata, handles)
% hObject    handle to XReduceBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AddReduce(handles.XEntry, '-');
centre=Pos(handles, 'XYZ');
y_spm_orthviews('Reposition', centre);

% --- Executes on button press in YAddBtn.
function YAddBtn_Callback(hObject, eventdata, handles)
% hObject    handle to YAddBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AddReduce(handles.YEntry, '+');
centre=Pos(handles, 'XYZ');
y_spm_orthviews('Reposition', centre);

% --- Executes on button press in YReduceBtn.
function YReduceBtn_Callback(hObject, eventdata, handles)
% hObject    handle to YReduceBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AddReduce(handles.YEntry, '-');
centre=Pos(handles, 'XYZ');
y_spm_orthviews('Reposition', centre);

% --- Executes on button press in ZAddBtn.
function ZAddBtn_Callback(hObject, eventdata, handles)
% hObject    handle to ZAddBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AddReduce(handles.ZEntry, '+');
centre=Pos(handles, 'XYZ');
y_spm_orthviews('Reposition', centre);

% --- Executes on button press in ZReduceBtn.
function ZReduceBtn_Callback(hObject, eventdata, handles)
% hObject    handle to ZReduceBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AddReduce(handles.ZEntry, '-');
centre=Pos(handles, 'XYZ');
y_spm_orthviews('Reposition', centre);

% --- Executes on button press in IAddBtn.
function IAddBtn_Callback(hObject, eventdata, handles)
% hObject    handle to IAddBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AddReduce(handles.IEntry, '+');
centre=Pos(handles, 'IJK');
y_spm_orthviews('Reposition', centre);

% --- Executes on button press in IReduceBtn.
function IReduceBtn_Callback(hObject, eventdata, handles)
% hObject    handle to IReduceBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AddReduce(handles.IEntry, '-');
centre=Pos(handles, 'IJK');
y_spm_orthviews('Reposition', centre);

% --- Executes on button press in JAddBtn.
function JAddBtn_Callback(hObject, eventdata, handles)
% hObject    handle to JAddBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AddReduce(handles.JEntry, '+');
centre=Pos(handles, 'IJK');
y_spm_orthviews('Reposition', centre);

% --- Executes on button press in JReduceBtn.
function JReduceBtn_Callback(hObject, eventdata, handles)
% hObject    handle to JReduceBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AddReduce(handles.JEntry, '-');
centre=Pos(handles, 'IJK');
y_spm_orthviews('Reposition', centre);

% --- Executes on button press in KAddBtn.
function KAddBtn_Callback(hObject, eventdata, handles)
% hObject    handle to KAddBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AddReduce(handles.KEntry, '+');
centre=Pos(handles, 'IJK');
y_spm_orthviews('Reposition', centre);

% --- Executes on button press in KReduceBtn.
function KReduceBtn_Callback(hObject, eventdata, handles)
% hObject    handle to KReduceBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AddReduce(handles.KEntry, '-');
centre=Pos(handles, 'IJK');
y_spm_orthviews('Reposition', centre);


function AtlasEntry_Callback(hObject, eventdata, handles)
% hObject    handle to AtlasEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AtlasEntry as text
%        str2double(get(hObject,'String')) returns contents of AtlasEntry as a double


% --- Executes during object creation, after setting all properties.
function AtlasEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AtlasEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AtlasButton.
function AtlasButton_Callback(hObject, eventdata, handles)
% hObject    handle to AtlasButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curfig=handles.DPABI_fig;
curfig=w_Compatible2014bFig(curfig);
flag=w_AtlasSelect(curfig);
if flag
    y_spm_orthviews('Redraw');
end

% --- Executes on button press in StructrueButton.
function StructrueButton_Callback(hObject, eventdata, handles)
% hObject    handle to StructrueButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global st
curfig=handles.DPABI_fig;
curfig=w_Compatible2014bFig(curfig);
AtlasInfo=st{curfig}.AtlasInfo;
if isempty(AtlasInfo)
    msgbox('Please Select Atlas First!', 'modal');
    return
end

w_StructuralSelect(curfig);


% --- Executes during object deletion, before destroying properties.
function DPABI_fig_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to DPABI_fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global st
curfig=handles.DPABI_fig;
curfig=w_Compatible2014bFig(curfig);
if ~isempty(st{curfig}.TCFlag) && ishandle(st{curfig}.TCFlag)
    delete(st{curfig}.TCFlag);
end

if ~isempty(st{curfig}.SSFlag) && ishandle(st{curfig}.SSFlag)
    delete(st{curfig}.SSFlag);
end

for i=1:numel(st{curfig}.MPFlag)
    if ~isempty(st{curfig}.MPFlag{i}) && ishandle(st{curfig}.MPFlag{i})
        delete(st{curfig}.MPFlag{i});
    end
end
st{curfig}.MPFlag=[];
st{curfig}=[];
%delete(handles.DPABI_fig);


% --- Executes on button press in ModeButton.
function ModeButton_Callback(hObject, eventdata, handles)
% hObject    handle to ModeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global st
curfig=handles.DPABI_fig;
curfig=w_Compatible2014bFig(curfig);
Mode={'1','0'};
mode=get(handles.ModeButton, 'String');
state=strcmpi(mode, '1')+1;
mode=Mode{state};

set(handles.ModeButton, 'String', mode);
st{curfig}.mode=str2double(mode);
ShowUnderlay(handles);

