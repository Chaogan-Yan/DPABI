function varargout = DPABINet_VIEW(varargin)
% DPABINET_VIEW MATLAB code for DPABINet_VIEW.fig
%      DPABINET_VIEW, by itself, creates a new DPABINET_VIEW or raises the existing
%      singleton*.
%
%      H = DPABINET_VIEW returns the handle to a new DPABINET_VIEW or the handle to
%      the existing singleton*.
%
%      DPABINET_VIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABINET_VIEW.M with the given input arguments.
%
%      DPABINET_VIEW('Property','Value',...) creates a new DPABINET_VIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABINet_VIEW_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABINet_VIEW_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABINet_VIEW

% Last Modified by GUIDE v2.5 10-Apr-2021 12:39:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABINet_VIEW_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABINet_VIEW_OutputFcn, ...
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


% --- Executes just before DPABINet_VIEW is made visible.
function DPABINet_VIEW_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABINet_VIEW (see VARARGIN)

% Choose default command line output for DPABINet_VIEW
handles.output = hObject;

% General Color Map String
CMString={...
    'Jet';...
    'HSV';...
    'Hot';...
    'Cool';...
    'Spring';...
    'Summer';...
    'Autumn';...
    'Winter';...
    'Gray';...
    'Pink';...
    'Lines';...
    'Manually Defined...';...
    'Load Mat File...'...
    };

% StatOpt
StatOpt.TestFlag='';
StatOpt.TailedFlag=2; % One-Tailed: 1; Two-Tailed: 2.
StatOpt.Df=0;
StatOpt.Df2=0;

% Node
handles.Node=[];
handles.Node.WeiType=1; % 1-EdgeSum 2-NodeWei
handles.Node.WeiStruct=[];
handles.Node.CMString=[{'Node Color...'}; CMString];
handles.Node.CMValue=1;
handles.Node.ColorMap=[];
handles.Node.LabStruct=[];
handles.Node.NetStruct=[];
handles.Node.NetLabStruct=[];
handles.Node.StatOpt=StatOpt;
handles.Node.MCCType=1; % 1-Threshold 2-FDR 3-Perm
handles.Node.Thres=0;
handles.Node.PThres=[];
handles.Node.FDRQ=0.05;
handles.Node.PermThresType=1;
handles.Node.PermStruct=[];
handles.Node.PermP=0.05;
handles.Node.PermFDRQ=0.05;

% Edge
handles.Edge=[];
handles.Edge.MatStruct=[];
handles.Edge.CMString=[{'Edge Color...'}; CMString];
handles.Edge.CMValue=1;
handles.Edge.ColorMap=[];
handles.Edge.StatOpt=StatOpt;
handles.Edge.MCCType=1; % 1-Threshold 2-FDR 3-Perm 4-NBS
handles.Edge.Thres=0;
handles.Edge.PThres=[];
handles.Edge.FDRQ=0.05;
handles.Edge.PermThresType=1;
handles.Edge.PermStruct=[];
handles.Edge.PermP=0.05;
handles.Edge.PermFDRQ=0.05;
handles.Edge.NBSStruct=[];
handles.Edge.NBSEdgeP=0.001;
handles.Edge.NBSCompP=0.05;

% BrainNet Viewer Configure
DPABISurfPath=fileparts(which('DPABISurf.m'));
SurfString={...
    'fsaverage_inflated';...
    'fsaverage_white';...
    'fsaverage5_inflated';...
    'fsaverage5_white';...
    'Customize...'};
handles.Surf.CoordStruct=[];
handles.Surf.ROIIndices=[];
handles.Surf.SurfLType=4;
handles.Surf.SurfLString=strrep(SurfString, '_', '_lh_');
handles.Surf.SurfLFile=fullfile(DPABISurfPath, 'SurfTemplates',...
    sprintf('%s.surf.gii', handles.Surf.SurfLString{4}));
handles.Surf.SurfRType=4;
handles.Surf.SurfRString=strrep(SurfString, '_', '_rh_');
handles.Surf.SurfRFile=fullfile(DPABISurfPath, 'SurfTemplates',...
    sprintf('%s.surf.gii', handles.Surf.SurfRString{4}));

handles.Surf.DPABISurfPath=DPABISurfPath;

% Update handles structure
guidata(hObject, handles);

UpdateNodeFrame(hObject);
UpdateEdgeFrame(hObject);
UpdateSurfFrame(hObject);
% UIWAIT makes DPABINet_VIEW wait for user response (see UIRESUME)
% uiwait(handles.DPABINet_VIEW);


% --- Outputs from this function are returned to the command line.
function varargout = DPABINet_VIEW_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in NodeEdgeSumRadio.
function NodeEdgeSumRadio_Callback(hObject, eventdata, handles)
% hObject    handle to NodeEdgeSumRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Node.WeiType=1;
guidata(hObject, handles);
UpdateNodeFrame(hObject);
% Hint: get(hObject,'Value') returns toggle state of NodeEdgeSumRadio


% --- Executes on button press in NodeWeightRadio.
function NodeWeightRadio_Callback(hObject, eventdata, handles)
% hObject    handle to NodeWeightRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Node.WeiType=2;
if isempty(handles.Node.WeiStruct)
    WeiStruct=UILoadVar(pwd);
else
    WeiStruct=UILoadVar(handles.Node.WeiStruct.Path);
end
if isempty(WeiStruct)
    handles.Node.WeiType=1;
else
    handles.Node.WeiStruct=WeiStruct;
    if ~isempty(WeiStruct.StatOpt)
        handles.Node.StatOpt=WeiStruct.StatOpt;
    end
end

guidata(hObject, handles);
UpdateNodeFrame(hObject);
% Hint: get(hObject,'Value') returns toggle state of NodeWeightRadio

function NodeWeightEntry_Callback(hObject, eventdata, handles)
% hObject    handle to NodeWeightEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NodeWeightEntry as text
%        str2double(get(hObject,'String')) returns contents of NodeWeightEntry as a double


% --- Executes during object creation, after setting all properties.
function NodeWeightEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NodeWeightEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function NodeLabelEntry_Callback(hObject, eventdata, handles)
% hObject    handle to NodeLabelEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NodeLabelEntry as text
%        str2double(get(hObject,'String')) returns contents of NodeLabelEntry as a double


% --- Executes during object creation, after setting all properties.
function NodeLabelEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NodeLabelEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in NodeColorPopup.
function NodeColorPopup_Callback(hObject, eventdata, handles)
% hObject    handle to NodeColorPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
L=length(handles.Node.CMString);
Value=get(handles.NodeColorPopup, 'Value');
NewCMString=handles.Edge.CMString;
NewCMString{end}='Load Mat File...';
if Value==1;
    handles.Node.ColorMap=[];
elseif Value==L-1 % Manually
    %colormap('jet(64)');
    colormapeditor;
    waitfor(handles.DPABINet_VIEW, 'Colormap')
    ColorMap=get(handles.DPABINet_VIEW, 'Colormap');
    handles.Node.ColorMap=ColorMap;
elseif Value==L % Load CM
    CMStruct=UILoadVar;
    if isempty(CMStruct)
        return;
    end
    handles.Node.ColorMap=CMStruct.Var;
    NewCMString{end}=sprintf('Load Mat File %s (%s)', CMStruct.Str, CMStruct.Path);
else
    CurCMString=handles.Node.CMString{Value};
    handles.Node.ColorMap=colormap([lower(CurCMString), '(64)']);
end
handles.Node.CMValue=Value;
handles.Node.CMString=NewCMString;
guidata(hObject, handles);
UpdateNodeFrame(hObject);
% Hints: contents = cellstr(get(hObject,'String')) returns NodeColorPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NodeColorPopup


% --- Executes during object creation, after setting all properties.
function NodeColorPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NodeColorPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in NodeDfButton.
function NodeDfButton_Callback(hObject, eventdata, handles)
% hObject    handle to NodeDfButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
StatOpt=handles.Node.StatOpt;
NewStatCell=w_ChangeDf(StatOpt);
if isempty(NewStatCell)
    return
end

StatOpt.TestFlag=NewStatCell{1};
if strcmpi(StatOpt.TestFlag, 'F')
    StatOpt.TailedFlag=1;
end
StatOpt.Df=NewStatCell{2};
StatOpt.Df2=NewStatCell{3};
handles.Node.StatOpt=StatOpt;

Thres=handles.Node.Thres;
PThres=handles.Node.PThres;
if ~isempty(StatOpt.TestFlag)
    if isempty(Thres) && isempty(PThres)
        Thres=0;
        PThres=1;
    else
        if ~isempty(Thres)
            PThres=w_StatToP(Thres, StatOpt);
        else
            Thres=w_PToStat(PThres, StatOpt);
        end
    end
else
    PThres=[];
end
handles.Node.Thres=Thres;
handles.Node.PThres=PThres;

guidata(hObject, handles);

% --- Executes on button press in NodeLabelCheck.
function NodeLabelCheck_Callback(hObject, eventdata, handles)
% hObject    handle to NodeLabelCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.NodeLabelCheck, 'Value');
if Value==1
    LabStruct=UILoadVar(pwd);
    if ~isempty(LabStruct)
        handles.Node.LabStruct=LabStruct;
    end
else
    handles.Node.LabStruct=[];
end

guidata(hObject, handles);
UpdateNodeFrame(hObject);
% Hint: get(hObject,'Value') returns toggle state of NodeLabelCheck


% --- Executes on button press in NodeNetworkCheck.
function NodeNetworkCheck_Callback(hObject, eventdata, handles)
% hObject    handle to NodeNetworkCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.NodeNetworkCheck, 'Value');
if Value==1
    NetStruct=UILoadVar(pwd);
    if ~isempty(NetStruct)
        handles.Node.NetStruct=NetStruct;
    end
else
    handles.Node.NetStruct=[];
end

guidata(hObject, handles);
UpdateNodeFrame(hObject);
% Hint: get(hObject,'Value') returns toggle state of NodeNetworkCheck

function NodeNetworkEntry_Callback(hObject, eventdata, handles)
% hObject    handle to NodeNetworkEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NodeNetworkEntry as text
%        str2double(get(hObject,'String')) returns contents of NodeNetworkEntry as a double

% --- Executes during object creation, after setting all properties.
function NodeNetworkEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NodeNetworkEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in NodeNetLabCheck.
function NodeNetLabCheck_Callback(hObject, eventdata, handles)
% hObject    handle to NodeNetLabCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.NodeNetLabCheck, 'Value');
if Value==1
    NetLabStruct=UILoadVar(pwd);
    if ~isempty(NetLabStruct)
        handles.Node.NetLabStruct=NetLabStruct;
    end
else
    handles.Node.NetLabStruct=[];
end

guidata(hObject, handles);
UpdateNodeFrame(hObject);
% Hint: get(hObject,'Value') returns toggle state of NodeNetLabCheck

function NodeNetLabEntry_Callback(hObject, eventdata, handles)
% hObject    handle to NodeNetLabEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NodeNetLabEntry as text
%        str2double(get(hObject,'String')) returns contents of NodeNetLabEntry as a double


% --- Executes during object creation, after setting all properties.
function NodeNetLabEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NodeNetLabEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in NodeThresRadio.
function NodeThresRadio_Callback(hObject, eventdata, handles)
% hObject    handle to NodeThresRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Node.MCCType=1;

guidata(hObject, handles);
UpdateNodeFrame(hObject);
% Hint: get(hObject,'Value') returns toggle state of NodeThresRadio

function NodeThresEntry_Callback(hObject, eventdata, handles)
% hObject    handle to NodeThresEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Thres=str2num(get(handles.NodeThresEntry, 'String'));
handles.Node.Thres=Thres;

StatOpt=handles.Node.StatOpt;
% Stat Value
if ~isempty(Thres) && ~isempty(StatOpt.TestFlag)
    PThres=w_StatToP(Thres, StatOpt);
    handles.Node.PThres=PThres;
end

guidata(hObject, handles);
UpdateNodeFrame(hObject);
% Hints: get(hObject,'String') returns contents of NodeThresEntry as text
%        str2double(get(hObject,'String')) returns contents of NodeThresEntry as a double


% --- Executes during object creation, after setting all properties.
function NodeThresEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NodeThresEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function NodePEntry_Callback(hObject, eventdata, handles)
% hObject    handle to NodePEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PThres=str2num(get(handles.NodePEntry, 'String'));
handles.Node.PThres=PThres;

StatOpt=handles.Node.StatOpt;
% Stat Value
if ~isempty(PThres) && ~isempty(StatOpt.TestFlag)
    Thres=w_PToStat(PThres, StatOpt);
    handles.Node.Thres=Thres;
elseif isempty(StatOpt.TestFlag)
    errordlg('Please set statistical option first.');
    handles.Node.PThres=[];
end

guidata(hObject, handles);
UpdateNodeFrame(hObject);
% Hints: get(hObject,'String') returns contents of NodePEntry as text
%        str2double(get(hObject,'String')) returns contents of NodePEntry as a double


% --- Executes during object creation, after setting all properties.
function NodePEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NodePEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in NodeFDRRadio.
function NodeFDRRadio_Callback(hObject, eventdata, handles)
% hObject    handle to NodeFDRRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Node.MCCType=2;

guidata(hObject, handles);
UpdateNodeFrame(hObject);
% Hint: get(hObject,'Value') returns toggle state of NodeFDRRadio

% --- Executes on button press in NodePermRadio.
function NodePermRadio_Callback(hObject, eventdata, handles)
% hObject    handle to NodePermRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
OldMCCType=handles.Node.MCCType;
handles.Node.MCCType=3;
PermStruct=UILoadVar(pwd);
if ~isempty(PermStruct)
    handles.Node.PermStruct=PermStruct;
else
    handles.Node.MCCType=OldMCCType;
end
guidata(hObject, handles);
UpdateNodeFrame(hObject);
% Hint: get(hObject,'Value') returns toggle state of NodePermRadio



function NodePermEntry_Callback(hObject, eventdata, handles)
% hObject    handle to NodePermEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NodePermEntry as text
%        str2double(get(hObject,'String')) returns contents of NodePermEntry as a double


% --- Executes during object creation, after setting all properties.
function NodePermEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NodePermEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function NodeFDRQEntry_Callback(hObject, eventdata, handles)
% hObject    handle to NodeFDRQEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FDRQ=str2num(get(handles.NodeFDRQEntry, 'String'));
handles.Node.FDRQ=FDRQ;

guidata(hObject, handles);
UpdateNodeFrame(hObject);
% Hints: get(hObject,'String') returns contents of NodeFDRQEntry as text
%        str2double(get(hObject,'String')) returns contents of NodeFDRQEntry as a double


% --- Executes during object creation, after setting all properties.
function NodeFDRQEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NodeFDRQEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in NodePermPRadio.
function NodePermPRadio_Callback(hObject, eventdata, handles)
% hObject    handle to NodePermPRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Node.PermThresType=1;

guidata(hObject, handles);
UpdateNodeFrame(hObject);
% Hint: get(hObject,'Value') returns toggle state of NodePermPRadio


% --- Executes on button press in NodePermFDRQRadio.
function NodePermFDRQRadio_Callback(hObject, eventdata, handles)
% hObject    handle to NodePermFDRQRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Node.PermThresType=2;

guidata(hObject, handles);
UpdateNodeFrame(hObject);
% Hint: get(hObject,'Value') returns toggle state of NodePermFDRQRadio


function NodePermPEntry_Callback(hObject, eventdata, handles)
% hObject    handle to NodePermPEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PermP=str2num(get(handles.NodePermPEntry, 'String'));
handles.Node.PermP=PermP;

guidata(hObject, handles);
UpdateNodeFrame(hObject);
% Hints: get(hObject,'String') returns contents of NodePermPEntry as text
%        str2double(get(hObject,'String')) returns contents of NodePermPEntry as a double


% --- Executes during object creation, after setting all properties.
function NodePermPEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NodePermPEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function NodePermFDRQEntry_Callback(hObject, eventdata, handles)
% hObject    handle to NodePermFDRQEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PermFDRQ=str2num(get(handles.NodePermFDRQEntry, 'String'));
handles.Node.PermFDRQ=PermFDRQ;

guidata(hObject, handles);
UpdateNodeFrame(hObject);
% Hints: get(hObject,'String') returns contents of NodePermFDRQEntry as text
%        str2double(get(hObject,'String')) returns contents of NodePermFDRQEntry as a double


% --- Executes during object creation, after setting all properties.
function NodePermFDRQEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NodePermFDRQEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in NodePosNegPopup.
function NodePosNegPopup_Callback(hObject, eventdata, handles)
% hObject    handle to NodePosNegPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns NodePosNegPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NodePosNegPopup


% --- Executes during object creation, after setting all properties.
function NodePosNegPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NodePosNegPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in EdgePosNegPopup.
function EdgePosNegPopup_Callback(hObject, eventdata, handles)
% hObject    handle to EdgePosNegPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns EdgePosNegPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from EdgePosNegPopup

% --- Executes during object creation, after setting all properties.
function EdgePosNegPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EdgePosNegPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in EdgeColorPopup.
function EdgeColorPopup_Callback(hObject, eventdata, handles)
% hObject    handle to EdgeColorPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
L=length(handles.Edge.CMString);
Value=get(handles.EdgeColorPopup, 'Value');
NewCMString=handles.Edge.CMString;
NewCMString{end}='Load Mat File...';
if Value==1;
    handles.Edge.ColorMap=[];
elseif Value==L-1 % Manually
    %colormap('jet(64)');
    colormapeditor;
    waitfor(handles.DPABINet_VIEW, 'Colormap')
    ColorMap=get(handles.DPABINet_VIEW, 'Colormap');
    handles.Edge.ColorMap=ColorMap;
elseif Value==L % Load CM
    CMStruct=UILoadVar;
    if isempty(CMStruct)
        return;
    end    
    handles.Edge.ColorMap=CMStruct.Var;
    NewCMString{end}=sprintf('Load Mat File %s (%s)', CMStruct.Str, CMStruct.Path);
else
    CurCMString=handles.Edge.CMString{Value};
    handles.Edge.ColorMap=colormap([lower(CurCMString), '(64)']);
end
handles.Edge.CMValue=Value;
handles.Edge.CMString=NewCMString;
guidata(hObject, handles);
UpdateEdgeFrame(hObject);
% Hints: contents = cellstr(get(hObject,'String')) returns EdgeColorPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from EdgeColorPopup


% --- Executes during object creation, after setting all properties.
function EdgeColorPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EdgeColorPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in EdgeMatrixCheck.
function EdgeMatrixCheck_Callback(hObject, eventdata, handles)
% hObject    handle to EdgeMatrixCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.EdgeMatrixCheck, 'Value');
if Value==1
    MatStruct=UILoadVar(pwd);
    if ~isempty(MatStruct)
        handles.Edge.MatStruct=MatStruct;
        if ~isempty(MatStruct.StatOpt)
            handles.Edge.StatOpt=MatStruct.StatOpt;
        end        
    end
else
    handles.Edge.MatStruct=[];
end

guidata(hObject, handles);
UpdateEdgeFrame(hObject);
% Hint: get(hObject,'Value') returns toggle state of EdgeMatrixCheck



function EdgeMatrixEntry_Callback(hObject, eventdata, handles)
% hObject    handle to EdgeMatrixEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EdgeMatrixEntry as text
%        str2double(get(hObject,'String')) returns contents of EdgeMatrixEntry as a double


% --- Executes during object creation, after setting all properties.
function EdgeMatrixEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EdgeMatrixEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in EdgeDfButton.
function EdgeDfButton_Callback(hObject, eventdata, handles)
% hObject    handle to EdgeDfButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
StatOpt=handles.Edge.StatOpt;
NewStatCell=w_ChangeDf(StatOpt);
if isempty(NewStatCell)
    return
end

StatOpt.TestFlag=NewStatCell{1};
if strcmpi(StatOpt.TestFlag, 'F')
    StatOpt.TailedFlag=1;
end
StatOpt.Df=NewStatCell{2};
StatOpt.Df2=NewStatCell{3};
handles.Edge.StatOpt=StatOpt;

Thres=handles.Edge.Thres;
PThres=handles.Edge.PThres;
if ~isempty(StatOpt.TestFlag)
    if isempty(Thres) && isempty(PThres)
        Thres=0;
        PThres=1;
    else
        if ~isempty(Thres)
            PThres=w_StatToP(Thres, StatOpt);
        else
            Thres=w_PToStat(PThres, StatOpt);
        end
    end
else
    PThres=[];
end
handles.Edge.Thres=Thres;
handles.Edge.PThres=PThres;

guidata(hObject, handles);

% --- Executes on button press in EdgeThresRadio.
function EdgeThresRadio_Callback(hObject, eventdata, handles)
% hObject    handle to EdgeThresRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Edge.MCCType=1;

guidata(hObject, handles);
UpdateEdgeFrame(hObject);
% Hint: get(hObject,'Value') returns toggle state of EdgeThresRadio



function EdgeThresEntry_Callback(hObject, eventdata, handles)
% hObject    handle to EdgeThresEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Thres=str2num(get(handles.EdgeThresEntry, 'String'));
handles.Edge.Thres=Thres;

StatOpt=handles.Edge.StatOpt;
% Stat Value
if ~isempty(Thres) && ~isempty(StatOpt.TestFlag)
    PThres=w_StatToP(Thres, StatOpt);
    handles.Edge.PThres=PThres;
end

guidata(hObject, handles);
UpdateEdgeFrame(hObject);
% Hints: get(hObject,'String') returns contents of EdgeThresEntry as text
%        str2double(get(hObject,'String')) returns contents of EdgeThresEntry as a double


% --- Executes during object creation, after setting all properties.
function EdgeThresEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EdgeThresEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EdgePEntry_Callback(hObject, eventdata, handles)
% hObject    handle to EdgePEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PThres=str2num(get(handles.EdgePEntry, 'String'));
handles.Edge.PThres=PThres;

StatOpt=handles.Edge.StatOpt;
% Stat Value
if ~isempty(PThres) && ~isempty(StatOpt.TestFlag)
    Thres=w_PToStat(PThres, StatOpt);
    handles.Edge.Thres=Thres;
elseif isempty(StatOpt.TestFlag)
    errordlg('Please set statistical option first.');
    handles.Node.PThres=[];    
end

guidata(hObject, handles);
UpdateEdgeFrame(hObject);
% Hints: get(hObject,'String') returns contents of EdgePEntry as text
%        str2double(get(hObject,'String')) returns contents of EdgePEntry as a double


% --- Executes during object creation, after setting all properties.
function EdgePEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EdgePEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in EdgeFDRRadio.
function EdgeFDRRadio_Callback(hObject, eventdata, handles)
% hObject    handle to EdgeFDRRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Edge.MCCType=2;

guidata(hObject, handles);
UpdateEdgeFrame(hObject);
% Hint: get(hObject,'Value') returns toggle state of EdgeFDRRadio



function EdgeFDRQEntry_Callback(hObject, eventdata, handles)
% hObject    handle to EdgeFDRQEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FDRQ=str2num(get(handles.EdgeFDRQEntry, 'String'));
handles.Edge.FDRQ=FDRQ;

guidata(hObject, handles);
UpdateEdgeFrame(hObject);
% Hints: get(hObject,'String') returns contents of EdgeFDRQEntry as text
%        str2double(get(hObject,'String')) returns contents of EdgeFDRQEntry as a double


% --- Executes during object creation, after setting all properties.
function EdgeFDRQEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EdgeFDRQEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in EdgeNBSRadio.
function EdgeNBSRadio_Callback(hObject, eventdata, handles)
% hObject    handle to EdgeNBSRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
OldMCCType=handles.Edge.MCCType;
handles.Edge.MCCType=4;

[File, Path]=uigetfile({'*.gii', 'GIfTI File (*.mat)';'*.*', 'All File (*.*)'},...
    'Pick File', pwd);

if isnumeric(File) && File==0
    handles.Edge.MCCType=OldMCCType;
else
    [Path, Name, Ext]=fileparts(fullfile(Path, File));
    [EmptyPath, TmpName, SecendExt]=fileparts(Name);
    if isempty(SecendExt)
        Name=TmpName;
    else
        Ext=[SecendExt, Ext];
    end
    Prefix=Name(1:end-6);
    D=dir(fullfile(Path, [Prefix, '*']));
    D={D.name}';

    NBSFileList=cellfun(@(f) fullfile(Path, f), D, 'UniformOutput', false);
    NBSStruct=[];
    NBSStruct.Path=Path;
    NBSStruct.Str=sprintf('[%d files] %s*%s (%s)', numel(NBSFileList), Prefix, Ext, Path);
    NBSStruct.FileList=NBSFileList;
    
    handles.Edge.NBSStruct=NBSStruct;
end

guidata(hObject, handles);
UpdateEdgeFrame(hObject);
% Hint: get(hObject,'Value') returns toggle state of EdgeNBSRadio



function EdgeNBSEntry_Callback(hObject, eventdata, handles)
% hObject    handle to EdgeNBSEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EdgeNBSEntry as text
%        str2double(get(hObject,'String')) returns contents of EdgeNBSEntry as a double


% --- Executes during object creation, after setting all properties.
function EdgeNBSEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EdgeNBSEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function EdgeNBSEdgePEntry_Callback(hObject, eventdata, handles)
% hObject    handle to EdgeNBSEdgePEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
NBSEdgeP=str2num(get(handles.EdgeNBSEdgePEntry, 'String'));
handles.Edge.NBSEdgeP=NBSEdgeP;

guidata(hObject, handles);
UpdateEdgeFrame(hObject);
% Hints: get(hObject,'String') returns contents of EdgeNBSEdgePEntry as text
%        str2double(get(hObject,'String')) returns contents of EdgeNBSEdgePEntry as a double


% --- Executes during object creation, after setting all properties.
function EdgeNBSEdgePEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EdgeNBSEdgePEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function EdgeNBSCompPEntry_Callback(hObject, eventdata, handles)
% hObject    handle to EdgeNBSCompPEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
NBSCompP=str2num(get(handles.EdgeNBSCompPEntry, 'String'));
handles.Edge.NBSCompP=NBSCompP;

guidata(hObject, handles);
UpdateEdgeFrame(hObject);
% Hints: get(hObject,'String') returns contents of EdgeNBSCompPEntry as text
%        str2double(get(hObject,'String')) returns contents of EdgeNBSCompPEntry as a double


% --- Executes during object creation, after setting all properties.
function EdgeNBSCompPEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EdgeNBSCompPEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in EdgePermRadio.
function EdgePermRadio_Callback(hObject, eventdata, handles)
% hObject    handle to EdgePermRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
OldMCCType=handles.Edge.MCCType;
handles.Edge.MCCType=3;
PermStruct=UILoadVar(pwd);
if ~isempty(PermStruct)
    handles.Edge.PermStruct=PermStruct;
else
    handles.Edge.MCCType=OldMCCType;
end
guidata(hObject, handles);
UpdateEdgeFrame(hObject);
% Hint: get(hObject,'Value') returns toggle state of EdgePermRadio



function EdgePermEntry_Callback(hObject, eventdata, handles)
% hObject    handle to EdgePermEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EdgePermEntry as text
%        str2double(get(hObject,'String')) returns contents of EdgePermEntry as a double


% --- Executes during object creation, after setting all properties.
function EdgePermEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EdgePermEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in EdgePermPRadio.
function EdgePermPRadio_Callback(hObject, eventdata, handles)
% hObject    handle to EdgePermPRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Edge.PermThresType=1;

guidata(hObject, handles);
UpdateEdgeFrame(hObject);
% Hint: get(hObject,'Value') returns toggle state of EdgePermPRadio

function EdgePermPEntry_Callback(hObject, eventdata, handles)
% hObject    handle to EdgePermPEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PermP=str2num(get(handles.EdgePermPEntry, 'String'));
handles.Edge.PermP=PermP;

guidata(hObject, handles);
UpdateEdgeFrame(hObject);
% Hints: get(hObject,'String') returns contents of EdgePermPEntry as text
%        str2double(get(hObject,'String')) returns contents of EdgePermPEntry as a double


% --- Executes during object creation, after setting all properties.
function EdgePermPEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EdgePermPEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in EdgePermFDRQRadio.
function EdgePermFDRQRadio_Callback(hObject, eventdata, handles)
% hObject    handle to EdgePermFDRQRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Edge.PermThresType=2;

guidata(hObject, handles);
UpdateEdgeFrame(hObject);
% Hint: get(hObject,'Value') returns toggle state of EdgePermFDRQRadio

function EdgePermFDRQEntry_Callback(hObject, eventdata, handles)
% hObject    handle to EdgePermFDRQEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PermFDRQ=str2num(get(handles.EdgePermFDRQEntry, 'String'));
handles.Edge.PermFDRQ=PermFDRQ;

guidata(hObject, handles);
UpdateEdgeFrame(hObject);
% Hints: get(hObject,'String') returns contents of EdgePermFDRQEntry as text
%        str2double(get(hObject,'String')) returns contents of EdgePermFDRQEntry as a double


% --- Executes during object creation, after setting all properties.
function EdgePermFDRQEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EdgePermFDRQEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SurfCoordCheck.
function SurfCoordCheck_Callback(hObject, eventdata, handles)
% hObject    handle to SurfCoordCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.SurfCoordCheck, 'Value');
if Value==1
    CoordStruct=UILoadVar(pwd);
    if ~isempty(CoordStruct)
        handles.Surf.CoordStruct=CoordStruct;
        ROINum=size(CoordStruct.Var, 1);
        handles.Surf.ROIIndices=[1:ROINum];
    end
else
    handles.Surf.CoordStruct=[];
    handles.Surf.ROIIndices=[];
end

guidata(hObject, handles);
UpdateSurfFrame(hObject);
% Hint: get(hObject,'Value') returns toggle state of SurfCoordCheck

function SurfCoordEntry_Callback(hObject, eventdata, handles)
% hObject    handle to SurfCoordEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SurfCoordEntry as text
%        str2double(get(hObject,'String')) returns contents of SurfCoordEntry as a double


% --- Executes during object creation, after setting all properties.
function SurfCoordEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SurfCoordEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SurfIndiceEntry_Callback(hObject, eventdata, handles)
% hObject    handle to SurfIndiceEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
IndStr=get(handles.SurfIndiceEntry, 'String');
ROIIndices=str2num(IndStr);
ROIIndices=unique(ROIIndices);
if ~isempty(ROIIndices)
    handles.Surf.ROIIndices=ROIIndices;
end

guidata(hObject, handles);
UpdateSurfFrame(hObject);

% Hints: get(hObject,'String') returns contents of SurfIndiceEntry as text
%        str2double(get(hObject,'String')) returns contents of SurfIndiceEntry as a double


% --- Executes during object creation, after setting all properties.
function SurfIndiceEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SurfIndiceEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in SurfLPopup.
function SurfLPopup_Callback(hObject, eventdata, handles)
% hObject    handle to SurfLPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SurfTempPath=fullfile(handles.Surf.DPABISurfPath, 'SurfTemplates');
SurfType=get(handles.SurfLPopup, 'Value');
SurfString=handles.Surf.SurfLString;

if SurfType==numel(SurfString)
    [File , Path]=uigetfile({'*.surf.gii','Surface (*.surf.gii)';'*.gii', 'All GIfTI Files (*.gii)';'*.*', 'All Files (*.*)';}, ...
        'Pick Surface File' , SurfTempPath);
    if isnumeric(File) && File==0
        UpdateSurfFrame(hObject);
        return
    end

    SurfFile=fullfile(Path, File);
    SurfString{end}=sprintf('Customized (%s)', SurfFile);
else
    SurfFile=fullfile(SurfTempPath, sprintf('%s.surf.gii', SurfString{SurfType}));
    SurfString{end}='Customized...';
end
handles.Surf.SurfLFile=SurfFile;
handles.Surf.SurfLString=SurfString;
handles.Surf.SurfLType=SurfType;
guidata(hObject, handles);
UpdateSurfFrame(hObject);
% Hints: contents = cellstr(get(hObject,'String')) returns SurfLPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SurfLPopup


% --- Executes during object creation, after setting all properties.
function SurfLPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SurfLPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SurfRPopup.
function SurfRPopup_Callback(hObject, eventdata, handles)
% hObject    handle to SurfRPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SurfTempPath=fullfile(handles.Surf.DPABISurfPath, 'SurfTemplates');
SurfType=get(handles.SurfRPopup, 'Value');
SurfString=handles.Surf.SurfRString;

if SurfType==numel(SurfString)
    [File , Path]=uigetfile({'*.surf.gii','Surface (*.surf.gii)';'*.gii', 'All GIfTI Files (*.gii)';'*.*', 'All Files (*.*)';}, ...
        'Pick Surface File' , SurfTempPath);
    if isnumeric(File) && File==0
        UpdateSurfFrame(hObject);
        return
    end

    SurfFile=fullfile(Path, File);
    SurfString{end}=sprintf('Customized (%s)', SurfFile);
else
    SurfFile=fullfile(SurfTempPath, sprintf('%s.surf.gii', SurfString{SurfType}));
    SurfString{end}='Customized...';
end
handles.Surf.SurfRFile=SurfFile;
handles.Surf.SurfRString=SurfString;
handles.Surf.SurfRType=SurfType;
guidata(hObject, handles);
UpdateSurfFrame(hObject);
% Hints: contents = cellstr(get(hObject,'String')) returns SurfRPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SurfRPopup


% --- Executes during object creation, after setting all properties.
function SurfRPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SurfRPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in NodePlotButton.
function NodePlotButton_Callback(hObject, eventdata, handles)
% hObject    handle to NodePlotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Vec=GetThresholdedNode(hObject);
if isempty(Vec)
    errordlg('Please set edge matrix or node weight!');
    return
end
%
if isempty(handles.Node.ColorMap)
    errordlg('Please set colormap first!');
    return
end

%
NodeLab=[];
if ~isempty(handles.Node.LabStruct) 
    NodeLab=handles.Node.LabStruct.Var;
end

%
NodeNetInd=[];
if ~isempty(handles.Node.NetStruct)
    NodeNetInd=handles.Node.NetStruct.Var;
end

NodeNetLab=[];
if ~isempty(handles.Node.NetLabStruct)
    NodeNetLab=handles.Node.NetLabStruct.Var;
end

NodeCM=GetAdjustCM(hObject, Vec(:), 'Node');
w_PlotNode(Vec, NodeLab, NodeNetInd, NodeNetLab, NodeCM);

% --- Executes on button press in EdgePlotButton.
function EdgePlotButton_Callback(hObject, eventdata, handles)
% hObject    handle to EdgePlotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Mat=GetThresholdedEdge(hObject);
if isempty(Mat)
    errordlg('Please set edge matrix!');
    return
end
%
if isempty(handles.Edge.ColorMap)
    errordlg('Please set colormap first!');
    return
end

%
NodeLab=[];
if ~isempty(handles.Node.LabStruct) 
    NodeLab=handles.Node.LabStruct.Var;
end

%
NodeNetInd=[];
if ~isempty(handles.Node.NetStruct)
    NodeNetInd=handles.Node.NetStruct.Var;
end

NodeNetLab=[];
if ~isempty(handles.Node.NetLabStruct)
    NodeNetLab=handles.Node.NetLabStruct.Var;
end

EdgeCM=GetAdjustCM(hObject, Mat(:), 'Edge');
w_PlotEdge(Mat, NodeLab, NodeNetInd, NodeNetLab, EdgeCM);

% --- Executes on button press in CircoPlotButton.
function CircoPlotButton_Callback(hObject, eventdata, handles)
% hObject    handle to CircoPlotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Circos Struct

uiwait(msgbox('This function is based on Dr. Martin I Krzywinski’’s circos. Please cite: Krzywinski, M. et al. Circos: an Information Aesthetic for Comparative Genomics. Genome Res (2009) 19:1639-1645.','Citing'));

CircosStruct=GetCircosStruct(hObject);

% Work Dir
WorkDir=pwd;

[CircosBandPath, CircosLabelPath, CircosLinkPath]=CircosDataOrganize(WorkDir,...
    CircosStruct);
fprintf('Band Information Created: %\n', CircosBandPath);
fprintf('Label Information Created: %\n', CircosLabelPath);
fprintf('Link Information Created: %\n', CircosLinkPath);

CircosConf.offsetPixel=0;
CircosConf.textSize=36;
CircosConf.flag = '';
if ~isempty(CircosStruct.ElementLabel)
    CircosConf.flag = [CircosConf.flag,'L'];
    
    if isfield(handles,'NodeLabelSetting')
        NodeLabelSetting=NodeLabelDirection(handles.NodeLabelSetting);
    else
        NodeLabelSetting=NodeLabelDirection;
    end
    handles.NodeLabelSetting=NodeLabelSetting;
    guidata(hObject, handles);
    if strcmpi(NodeLabelSetting.NodeLabelDirection,'T')
        CircosConf.flag = [CircosConf.flag,'P'];
    end
    CircosConf.offsetPixel=NodeLabelSetting.InnerCircleOffset;
    CircosConf.textSize=NodeLabelSetting.TextSize; % Add textSize in 220412
end
if ~isempty(CircosStruct.HigherOrderNetworkLabel)
    CircosConf.flag = [CircosConf.flag,'N'];
end




CircosConfPath=EditConf(WorkDir,CircosConf); % Simplify struct CircosConf 
fprintf('Circos Config Created: %\n', CircosConfPath);

% run Circos command, if need run Matlab in Terminal
Command=['docker run -i --rm -v ',WorkDir,':/data cgyan/circos /opt/yancallcircos.sh'];
%Command=['docker run -ti --rm -v ',WorkDir,':/data cgyan/circos /bin/sh -c ''cd /data && /opt/circos/bin/circos -conf /data/CircosPlot.conf'''];

system(Command);
figure;imshow([WorkDir,filesep,'circos.png'])


% --- Executes on selection change in UtilitiesPopup.
function UtilitiesPopup_Callback(hObject, eventdata, handles)
% hObject    handle to UtilitiesPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.UtilitiesPopup, 'Value');
switch Value
    case 1
        %DO NOTING
    case 2 % Generate Matrix
        Edge=GetThresholdedEdge(hObject);
        if isempty(Edge)
            errordlg('Please set edge matrix first!');
            return
        end
        EdgeMatrix=Edge;
        
        [File , Path]=uiputfile({'*.mat','MAT-File (*.mat)'}, ...
            'Save Edge Matrix', pwd);
        if ~ischar(File)
            return
        end
        OutPath=fullfile(Path, File);
        save(OutPath, 'EdgeMatrix');
    case 3
        CountEdgeS=CountEdge(hObject);
        [File , Path]=uiputfile({'*.mat','MAT-File (*.mat)'}, ...
            'Save CountEdge Summary', pwd);
        if ~ischar(File)
            return
        end
        OutPath=fullfile(Path, File);
        save(OutPath, '-struct', 'CountEdgeS');
        
    case 4 % Generate Matrix
        NodeWei=GetThresholdedNode(hObject);
        if isempty(NodeWei)
            errordlg('Please set node weight first!');
            return
        end
        NodeWeight=NodeWei;
        
        [File , Path]=uiputfile({'*.mat','MAT-File (*.mat)'}, ...
            'Save Node Weight', pwd);
        if ~ischar(File)
            return
        end
        OutPath=fullfile(Path, File);
        save(OutPath, 'NodeWeight');
        
end
% Hints: contents = cellstr(get(hObject,'String')) returns UtilitiesPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from UtilitiesPopup


% --- Executes during object creation, after setting all properties.
function UtilitiesPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UtilitiesPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in BrainNetButton.
function BrainNetButton_Callback(hObject, eventdata, handles)
% hObject    handle to BrainNetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.Node.ColorMap)
    handles.Node.ColorMap=[]; %YAN Chao-Gan, 210419. Node ColorMap can be empty
end

if isempty(handles.Surf.CoordStruct)
    errordlg('Please set ROI CenterOfMass');
    return
end
Coord=handles.Surf.CoordStruct.Var(:, 1:3);
Coord=Coord(handles.Surf.ROIIndices, :);

NodeWei=GetThresholdedNode(hObject);
NodeCM=handles.Node.ColorMap;
NodeLab=[];
if ~isempty(handles.Node.LabStruct)
    NodeLab=handles.Node.LabStruct.Var;
end
NodeNet=[];
if ~isempty(handles.Node.NetStruct)
    NodeNet=handles.Node.NetStruct.Var;
end

NodeInd=handles.Surf.ROIIndices;

EdgeMat=GetThresholdedEdge(hObject);

SurfLR={handles.Surf.SurfLFile;handles.Surf.SurfRFile};

if isempty(which('BrainNet'))
    errordlg('Please install BrainNet Viewer first!');
    return
end
uiwait(msgbox('This function is based on Dr. Mingrui-Xia’’s BrainNet Viewer. Please cite: Xia M, Wang J, He Y (2013) BrainNet Viewer: A Network Visualization Tool for Human Brain Connectomics. PLoS ONE 8: e68910.','Citing'));
y_CallBrainNetViewer_NodeEdge(Coord,...
    EdgeMat, 0,...
    NodeWei, 1, NodeNet, NodeCM, NodeLab, [],...
    'FullView',SurfLR);

function S=UILoadVar(varargin)
S=[];
if nargin==0
    PDir=pwd;
elseif nargin==1
    PDir=varargin{1};
else
    error('Invalid Input!');
end

[VarStruct, StatOpt, IsMAT]=w_uiLoadMat(PDir);
if isempty(VarStruct)
    return
end

if IsMAT %YAN Chao-Gan, 210419. Depends on if .mat or .txt
    Ind=listdlg('PromptString', 'Select a Var:',...
        'SelectionMode', 'single',...
        'ListString', VarStruct.StrCell);
    if isempty(Ind)
        return
    end
    
    VarName=VarStruct.FieldNames{Ind};
    [Data, Header]=y_ReadMat(VarStruct.Path, {VarName});
    
    S.Header=Header;
    S.Name=VarName;
    S.Var=VarStruct.Var.(VarName);
    S.Str=VarStruct.StrCell{Ind};
    S.Path=VarStruct.Path;
    S.StatOpt=StatOpt;
    
else
    VarName='TXT';
    S.Header=[];
    S.Name=VarName;
    S.Var=VarStruct.Var.(VarName);
    S.Str=VarStruct.StrCell{1};
    S.Path=VarStruct.Path;
    S.StatOpt=StatOpt;
    
end

function UpdateNodeFrame(hObject)
handles=guidata(hObject);

% Node Weight
switch handles.Node.WeiType
    case 1 % Edge Sum
        EdgeSumValue=1;
        NodeWeiValue=0;
        NodeWeiState='off';
        NodeWeiStr='';
    case 2 % NodeWeight
        EdgeSumValue=0;
        NodeWeiValue=1;
        NodeWeiState='on';
        NodeWeiStr=sprintf('%s (%s)', handles.Node.WeiStruct.Str,...
            handles.Node.WeiStruct.Path);
end
set(handles.NodeEdgeSumRadio, 'Value', EdgeSumValue);
set(handles.NodeWeightRadio, 'Value', NodeWeiValue);
set(handles.NodeWeightEntry, 'Enable', NodeWeiState, 'String', NodeWeiStr);

% Node ColorMap
set(handles.NodeColorPopup, 'String', handles.Node.CMString,...
    'Value', handles.Node.CMValue);

% Node Label
if isempty(handles.Node.LabStruct)
    NodeLabValue=0;
    NodeLabStr='';
    NodeLabState='off';
else
    NodeLabValue=1;
    NodeLabStr=sprintf('%s (%s)', handles.Node.LabStruct.Str,...
            handles.Node.LabStruct.Path);
    NodeLabState='on';
end
set(handles.NodeLabelCheck, 'Value', NodeLabValue);
set(handles.NodeLabelEntry, 'Enable', NodeLabState, 'String', NodeLabStr);

% Node Network
if isempty(handles.Node.NetStruct)
    NodeNetValue=0;
    NodeNetStr='';
    NodeNetState='off';
else
    NodeNetValue=1;
    NodeNetStr=sprintf('%s (%s)', handles.Node.NetStruct.Str,...
            handles.Node.NetStruct.Path);
    NodeNetState='on';    
end
set(handles.NodeNetworkCheck, 'Value', NodeNetValue);
set(handles.NodeNetworkEntry, 'Enable', NodeNetState, 'String', NodeNetStr);

% Node Network Label
if isempty(handles.Node.NetLabStruct)
    NodeNetLabValue=0;
    NodeNetLabStr='';
    NodeNetLabState='off';
else
    NodeNetLabValue=1;
    NodeNetLabStr=sprintf('%s (%s)', handles.Node.NetLabStruct.Str,...
            handles.Node.NetLabStruct.Path);
    NodeNetLabState='on';    
end
set(handles.NodeNetLabCheck, 'Value', NodeNetLabValue);
set(handles.NodeNetLabEntry, 'Enable', NodeNetLabState, 'String', NodeNetLabStr);

% Multiple Comparison Correction
switch handles.Node.MCCType
    case 1 % Uncorrected Threshold
        NodeThresValue=1;
        NodeThresStr=num2str(handles.Node.Thres);
        NodeThresState='on';
        NodePThresStr=num2str(handles.Node.PThres);
        NodePThresState='on';        
        
        NodeFDRValue=0;
        NodeFDRQState='off';
        NodeFDRQStr='';
        
        NodePermValue=0;
        NodePermStructState='off';
        NodePermStructStr='';
        NodePermThresTypeState='off';
        NodePermPValue=0;
        NodePermPState='off';
        NodePermPStr='';
        NodePermQValue=0;
        NodePermQState='off';
        NodePermQStr='';
    case 2 % FDR
        NodeThresValue=0;
        NodeThresStr='';
        NodeThresState='off';
        NodePThresStr='';
        NodePThresState='off';        
        
        NodeFDRValue=1;
        NodeFDRQState='on';
        NodeFDRQStr=num2str(handles.Node.FDRQ);
        
        NodePermValue=0;
        NodePermStructState='off';
        NodePermStructStr='';
        NodePermThresTypeState='off';
        NodePermPValue=0;
        NodePermPState='off';
        NodePermPStr='';
        NodePermQValue=0;
        NodePermQState='off';
        NodePermQStr=''; 
    case 3 % Permutation
        NodeThresValue=0;
        NodeThresStr='';
        NodeThresState='off';
        NodePThresStr='';
        NodePThresState='off';
        
        NodeFDRValue=0;
        NodeFDRQState='off';
        NodeFDRQStr='';
        
        NodePermValue=1;
        NodePermStructState='on';
        NodePermStructStr=sprintf('%s (%s)', handles.Node.PermStruct.Str,...
            handles.Node.PermStruct.Path);
        NodePermThresTypeState='on';
        switch handles.Node.PermThresType
            case 1 % Perm P
                NodePermPValue=1;
                NodePermPState='on';
                NodePermPStr=num2str(handles.Node.PermP);
                NodePermQValue=0;
                NodePermQState='off';                
                NodePermQStr='';                
            case 2 % FDR Q
                NodePermPValue=0;
                NodePermPState='off';
                NodePermPStr='';
                NodePermQValue=1;
                NodePermQState='on';                
                NodePermQStr=num2str(handles.Node.PermFDRQ);                                
        end
end
set(handles.NodeThresRadio, 'Value', NodeThresValue);
set(handles.NodeThresEntry, 'Enable', NodeThresState, 'String', NodeThresStr);
set(handles.NodePEntry, 'Enable', NodePThresState, 'String', NodePThresStr);
set(handles.NodeFDRRadio, 'Value', NodeFDRValue);
set(handles.NodeFDRQEntry, 'Enable', NodeFDRQState, 'String', NodeFDRQStr);
set(handles.NodePermRadio, 'Value', NodePermValue);
set(handles.NodePermEntry, 'Enable', NodePermStructState, 'String', NodePermStructStr);
set(handles.NodePermPRadio, 'Enable', NodePermThresTypeState,...
    'Value', NodePermPValue);
set(handles.NodePermPEntry, 'Enable', NodePermPState, 'String', NodePermPStr);
set(handles.NodePermFDRQRadio, 'Enable', NodePermThresTypeState,...
    'Value', NodePermQValue);
set(handles.NodePermFDRQEntry, 'Enable', NodePermQState, 'String', NodePermQStr);

function UpdateEdgeFrame(hObject)
handles=guidata(hObject);

% Edge ColorMap
set(handles.EdgeColorPopup, 'String', handles.Edge.CMString,...
    'Value', handles.Edge.CMValue);

% Edge Label
if isempty(handles.Edge.MatStruct)
    EdgeMatValue=0;
    EdgeMatStr='';
    EdgeMatState='off';
else
    EdgeMatValue=1;
    EdgeMatStr=sprintf('%s (%s)', handles.Edge.MatStruct.Str,...
            handles.Edge.MatStruct.Path);
    EdgeMatState='on';
end
set(handles.EdgeMatrixCheck, 'Value', EdgeMatValue);
set(handles.EdgeMatrixEntry, 'Enable', EdgeMatState, 'String', EdgeMatStr);

% Multiple Comparison Correction
switch handles.Edge.MCCType
    case 1 % Uncorrected Threshold
        EdgeThresValue=1;
        EdgeThresStr=num2str(handles.Edge.Thres);
        EdgeThresState='on';
        EdgePThresStr=num2str(handles.Edge.PThres);
        EdgePThresState='on';        
        
        EdgeFDRValue=0;
        EdgeFDRQState='off';
        EdgeFDRQStr='';
        
        EdgePermValue=0;
        EdgePermStructState='off';
        EdgePermStructStr='';
        EdgePermThresTypeState='off';
        EdgePermPValue=0;
        EdgePermPState='off';
        EdgePermPStr='';
        EdgePermQValue=0;
        EdgePermQState='off';
        EdgePermQStr='';
        
        EdgeNBSValue=0;
        EdgeNBSStructState='off';
        EdgeNBSStructStr='';
        EdgeNBSEdgePState='off';
        EdgeNBSEdgePStr='';
        EdgeNBSCompPState='off';
        EdgeNBSCompPStr='';        
    case 2 % FDR
        EdgeThresValue=0;
        EdgeThresStr='';
        EdgeThresState='off';
        EdgePThresStr='';
        EdgePThresState='off';        
        
        EdgeFDRValue=1;
        EdgeFDRQState='on';
        EdgeFDRQStr=num2str(handles.Edge.FDRQ);
        
        EdgePermValue=0;
        EdgePermStructState='off';
        EdgePermStructStr='';
        EdgePermThresTypeState='off';
        EdgePermPValue=0;
        EdgePermPState='off';
        EdgePermPStr='';
        EdgePermQValue=0;
        EdgePermQState='off';
        EdgePermQStr=''; 
        
        EdgeNBSValue=0;
        EdgeNBSStructState='off';
        EdgeNBSStructStr='';
        EdgeNBSEdgePState='off';
        EdgeNBSEdgePStr='';
        EdgeNBSCompPState='off';
        EdgeNBSCompPStr='';        
    case 3 % Permutation
        EdgeThresValue=0;
        EdgeThresStr='';
        EdgeThresState='off';
        EdgePThresStr='';
        EdgePThresState='off';
        
        EdgeFDRValue=0;
        EdgeFDRQState='off';
        EdgeFDRQStr='';
        
        EdgePermValue=1;
        EdgePermStructState='on';
        EdgePermStructStr=sprintf('%s (%s)', handles.Edge.PermStruct.Str,...
            handles.Edge.PermStruct.Path);
        EdgePermThresTypeState='on';
        switch handles.Edge.PermThresType
            case 1 % Perm P
                EdgePermPValue=1;
                EdgePermPState='on';
                EdgePermPStr=num2str(handles.Edge.PermP);
                EdgePermQValue=0;
                EdgePermQState='off';                
                EdgePermQStr='';                
            case 2 % FDR Q
                EdgePermPValue=0;
                EdgePermPState='off';
                EdgePermPStr='';
                EdgePermQValue=1;
                EdgePermQState='on';                
                EdgePermQStr=num2str(handles.Edge.PermFDRQ);                                
        end
        
        EdgeNBSValue=0;
        EdgeNBSStructState='off';
        EdgeNBSStructStr='';
        EdgeNBSEdgePState='off';
        EdgeNBSEdgePStr='';
        EdgeNBSCompPState='off';
        EdgeNBSCompPStr='';        
    case 4 % NBS
        EdgeThresValue=0;
        EdgeThresStr='';
        EdgeThresState='off';
        EdgePThresStr='';
        EdgePThresState='off';        
        
        EdgeFDRValue=0;
        EdgeFDRQState='off';
        EdgeFDRQStr='';
        
        EdgePermValue=0;
        EdgePermStructState='off';
        EdgePermStructStr='';
        EdgePermThresTypeState='off';
        EdgePermPValue=0;
        EdgePermPState='off';
        EdgePermPStr='';
        EdgePermQValue=0;
        EdgePermQState='off';
        EdgePermQStr='';
        
        EdgeNBSValue=1;
        EdgeNBSStructState='on';
        EdgeNBSStructStr=handles.Edge.NBSStruct.Str;
        EdgeNBSEdgePState='on';
        EdgeNBSEdgePStr=num2str(handles.Edge.NBSEdgeP);
        EdgeNBSCompPState='on';
        EdgeNBSCompPStr=num2str(handles.Edge.NBSCompP);        
end
set(handles.EdgeThresRadio, 'Value', EdgeThresValue);
set(handles.EdgeThresEntry, 'Enable', EdgeThresState, 'String', EdgeThresStr);
set(handles.EdgePEntry, 'Enable', EdgePThresState, 'String', EdgePThresStr);
set(handles.EdgeFDRRadio, 'Value', EdgeFDRValue);
set(handles.EdgeFDRQEntry, 'Enable', EdgeFDRQState, 'String', EdgeFDRQStr);
set(handles.EdgePermRadio, 'Value', EdgePermValue);
set(handles.EdgePermEntry, 'Enable', EdgePermStructState, 'String', EdgePermStructStr);
set(handles.EdgePermPRadio, 'Enable', EdgePermThresTypeState,...
    'Value', EdgePermPValue);
set(handles.EdgePermPEntry, 'Enable', EdgePermPState, 'String', EdgePermPStr);
set(handles.EdgePermFDRQRadio, 'Enable', EdgePermThresTypeState,...
    'Value', EdgePermQValue);
set(handles.EdgePermFDRQEntry, 'Enable', EdgePermQState, 'String', EdgePermQStr);
set(handles.EdgeNBSRadio, 'Value', EdgeNBSValue);
set(handles.EdgeNBSEntry, 'Enable', EdgeNBSStructState, 'String', EdgeNBSStructStr);
set(handles.EdgeNBSEdgePText, 'Enable', EdgeNBSEdgePState);
set(handles.EdgeNBSEdgePEntry, 'Enable', EdgeNBSEdgePState, 'String', EdgeNBSEdgePStr);
set(handles.EdgeNBSCompPText, 'Enable', EdgeNBSCompPState);
set(handles.EdgeNBSCompPEntry, 'Enable', EdgeNBSCompPState, 'String', EdgeNBSCompPStr);

function UpdateSurfFrame(hObject)
handles=guidata(hObject);

if isempty(handles.Surf.CoordStruct)
    SurfCoordValue=0;
    SurfCoordState='off';
    SurfCoordStr='';
    SurfIndiceState='off';
    SurfIndiceStr='';
    SurfLRState='off';
else
    SurfCoordValue=1;
    SurfCoordState='on';
    SurfCoordStr=sprintf('%s (%s)', handles.Surf.CoordStruct.Str,...
            handles.Surf.CoordStruct.Path);
    SurfIndiceState='on';
    SurfIndiceStr=sprintf('[%s]', num2str(handles.Surf.ROIIndices)); 
    SurfLRState='on';
end
set(handles.SurfCoordCheck, 'Value', SurfCoordValue);
set(handles.SurfCoordEntry, 'Enable', SurfCoordState, 'String', SurfCoordStr);
set(handles.SurfIndiceEntry, 'Enable', SurfIndiceState, 'String', SurfIndiceStr);
set(handles.SurfLPopup, 'Enable', SurfLRState, ...
    'Value', handles.Surf.SurfLType, 'String', handles.Surf.SurfLString);
set(handles.SurfRPopup, 'Enable', SurfLRState, ...
    'Value', handles.Surf.SurfRType, 'String', handles.Surf.SurfRString);

function FDRMsk=FDR_Vector(VecP, FDRQ)
% Following  FDR.m	1.3 Tom Nichols 02/01/18
SortP=sort(VecP);
V=length(SortP);
I=(1:V)';
cVID = 1;
cVN  = sum(1./(1:V));
PThres   = SortP(find(SortP <= I/V*FDRQ/cVID, 1, 'last' ));

FDRMsk=zeros(size(VecP));
if ~isempty(PThres)
    FDRMsk(find(VecP<=PThres))=1;
else
    warndlg('There is no sample left!');
end

function Vec=GetThresholdedNode(hObject)
handles=guidata(hObject);

if handles.Node.WeiType==1
    Mat=handles.Edge.MatStruct.Var;
    if isempty(Mat)
        Vec=[];
        return
    end
    Mat=Mat-diag(diag(Mat));
    Vec=sum(Mat, 2);
else
    if isempty(handles.Node.WeiStruct)
        Vec=[];
        return
    end
    Vec=handles.Node.WeiStruct.Var;
end

% Multiple Comparing Correction
MCCType=handles.Node.MCCType;
switch MCCType
    case 1 % Threshold
        VecThres=handles.Node.Thres;
        VecThres=abs(VecThres);
        Vec=Vec.*(Vec>VecThres)+Vec.*(Vec<-VecThres);
    case 2 % FDR
        StatOpt=handles.Node.StatOpt;
        VecP=w_StatToP(Vec, StatOpt);

        if isempty(VecP)
            errordlg('Cannot recognize statistical option, please check again');
        end

        FDRQ=handles.Node.FDRQ;
        if isempty(FDRQ)
            errordlg('Invalid Q Value');
        end
        FDRMsk=FDR_Vector(VecP, FDRQ);     
        Vec=Vec.*FDRMsk;
    case 3 % Permution
        if isempty(handles.Node.PermStruct)
            errordlg('Please set permutation results');
        end
        VecPermP=handles.Node.PermStruct.Var;
        
        PermThresType=handles.Node.PermThresType;
        switch PermThresType
            case 1 % P Threshold
                PermPThres=handles.Node.PermP;
                if isempty(PermPThres)
                    errordlg('Invalid Permutation P Threshold');
                end
                PermMsk=VecPermP<PermPThres;
                Vec=Vec.*PermMsk;
            case 2 % FDR
                PermFDRQ=handles.Node.PermFDRQ;
                if isempty(PermFDRQ)
                    errordlg('Invalid Q Value');
                end                
                PermFDRMsk=FDR_Vector(VecPermP, PermFDRQ);
                Vec=Vec.*PermFDRMsk;
        end
end

% Thres Type: Full, Pos, or Neg
VecThresType=get(handles.NodePosNegPopup, 'Value');
switch VecThresType
    case 1 % Full
        % Do Noting
    case 2 % Positive
        Vec=Vec.*(Vec>0);
    case 3 % Negative
        Vec=Vec.*(Vec<0);
end

if ~any(Vec(:)) %YAN Chao-Gan, 210923
    warndlg('There was no node survived!'); %YAN Chao-Gan, 210923
end



function Mat=GetThresholdedEdge(hObject)
handles=guidata(hObject);

if isempty(handles.Edge.MatStruct)
    Mat=[];
    return
end

Mat=handles.Edge.MatStruct.Var;
if any(diag(Mat))
    DiagFlag=true;
else
    DiagFlag=false;
end
NumNode=size(Mat, 1);
if DiagFlag
    TriMsk=tril(true(NumNode), 0);
else
    TriMsk=tril(true(NumNode), -1);
end

% Thres Type: Full, Pos, or Neg
MatThresType=get(handles.EdgePosNegPopup, 'Value');

% Multiple Comparing Correction
MCCType=handles.Edge.MCCType;
switch MCCType
    case 1 % Threshold
        MatThres=handles.Edge.Thres;
        MatThres=abs(MatThres);
        Mat=Mat.*(Mat>MatThres)+Mat.*(Mat<-MatThres);
    case 2 % FDR
        Vec=Mat(TriMsk);

        StatOpt=handles.Edge.StatOpt;
        VecP=w_StatToP(Vec, StatOpt);

        if isempty(VecP)
            errordlg('Cannot recognize statistical option, please check again');
            return
        end

        FDRQ=handles.Edge.FDRQ;
        if isempty(FDRQ)
            errordlg('Invalid Q Value');
        end
        FDRMsk=FDR_Vector(VecP, FDRQ);     
        Vec=Vec.*FDRMsk;
        
        MatTemp=zeros(size(TriMsk));
        MatTemp(TriMsk)=Vec;
        
        DiagVec=diag(MatTemp);
        Mat=MatTemp+MatTemp';
        Mat(logical(eye(NumNode)))=DiagVec;
    case 3 % Permutation
        Vec=Mat(TriMsk);

        %if isempty(handles.Edge.PermStruct)
        %    errordlg('Please set permutation results');
        %    return
        %end
        MatPermP=handles.Edge.PermStruct.Var;
        VecPermP=MatPermP(TriMsk);
        
        PermThresType=handles.Edge.PermThresType;
        switch PermThresType
            case 1 % P Threshold
                PermPThres=handles.Edge.PermP;
                if isempty(PermPThres)
                    errordlg('Invalid Permutation P Threshold');
                end
                PermMsk=VecPermP<PermPThres;
                Vec=Vec.*PermMsk;
            case 2 % FDR
                PermFDRQ=handles.Edge.PermFDRQ;
                if isempty(PermFDRQ)
                    errordlg('Invalid Q Value');
                end                
                PermFDRMsk=FDR_Vector(VecPermP, PermFDRQ);
                Vec=Vec.*PermFDRMsk;  
        end
        MatTemp=zeros(size(TriMsk));
        MatTemp(TriMsk)=Vec;

        DiagVec=diag(MatTemp);
        Mat=MatTemp+MatTemp';
        Mat(logical(eye(NumNode)))=DiagVec;        
    case 4 % NBS
        %if isempty(handles.Edge.NBSStruct)
        %    errordlg('Please set NBS permutation results!');
        %end
        NBSFileList=handles.Edge.NBSStruct.FileList;
        NumPerm=numel(NBSFileList);
        StatOpt=handles.Edge.StatOpt;
        
        CompP=handles.Edge.NBSCompP;
        EdgeP=handles.Edge.NBSEdgeP;
        
        CSNullModel=zeros(NumPerm, 1);
        
        for i=1:NumPerm
            Data=y_ReadAll(NBSFileList{i});
            NMStruct=y_WriteMat(Data, handles.Edge.MatStruct.Header);
            NMMat=NMStruct.NetworkMatrix;
            
            % Abs Pos Neg
            switch MatThresType
                case 1 % Full
                    NMP=w_StatToP(NMMat, StatOpt);
                case 2 % Positive
                    NMP=w_StatToP(NMMat.*(NMMat>0), StatOpt);
                case 3 % Negative
                    NMP=w_StatToP(NMMat.*(NMMat<0), StatOpt);
            end
            Bin=NMP<EdgeP;
            [Ci, CompSizes]=get_components(Bin);
            CompEdgeNum=GetCompEdgeNum(Bin, Ci, CompSizes);
            CSNullModel(i, 1)=max(CompEdgeNum);
        end
        
        switch MatThresType
            case 1 % Abs
                MatP=w_StatToP(Mat, StatOpt);
            case 2 % Pos
                MatP=w_StatToP(Mat.*(Mat>0), StatOpt);
            case 3 % Neg
                MatP=w_StatToP(Mat.*(Mat<0), StatOpt);
        end
        
        % Binary Mask
        Bin=MatP<EdgeP;
        
        % Comp Size
        [RealCi, RealCompSizes]=get_components(Bin);
        RealCompEdgeNum=GetCompEdgeNum(Bin, RealCi, RealCompSizes);
        RealCi=RealCi';
        
        NBSMsk=false(size(Mat));
        % Loop All Comp
        for n=1:numel(RealCompEdgeNum)
            CurCompP=(1+length(find(CSNullModel>=RealCompEdgeNum(n, 1))))/(1+NumPerm);
            if CurCompP<CompP
                NBSMsk(RealCi==n, RealCi==n)=true; %YAN Chao-Gan. 210421. Might be quicker
                %NBSMsk(RealCi==n, :)=true;
                %NBSMsk(:, RealCi==n)=true;
            end
        end
        Mat=Mat.*NBSMsk.*Bin;
        
        EdgeMatrix_NBSCorrected=Mat;
        save('EdgeMatrix_NBSCorrected.mat','EdgeMatrix_NBSCorrected'); %%YAN Chao-Gan. 210421.
        
        fprintf('NBS Finished.\n');
        
        if all(Mat(:)==0)
            warning('There was no edge survived NBS correction!');
            warndlg('There was no edge survived NBS correction!'); %YAN Chao-Gan, 210923
        end
end

% Thres Type: Full, Pos, or Neg
switch MatThresType
    case 1 % Full
        % Do Noting
    case 2 % Positive
        Mat=Mat.*(Mat>0);
    case 3 % Negative
        Mat=Mat.*(Mat<0);
end

if ~any(Mat(:)) %YAN Chao-Gan, 210923
    warndlg('There was no edge survived!'); %YAN Chao-Gan, 210923
end

function CompEdgeNum=GetCompEdgeNum(Bin, Ci, CompSizes)
if size(Ci, 1)==1
    Ci=Ci';
end
if size(CompSizes, 1)==1
    CompSizes=CompSizes';
end

CompEdgeNum=zeros(size(CompSizes));
for n=1:numel(CompSizes)
    TmpMsk=false(size(Bin));
    TmpMsk(Ci==n, :)=true;
    TmpMsk(:, Ci==n)=true;
    
    TmpBin=Bin.*TmpMsk;
    CompEdgeNum(n, 1)=sum(TmpBin(:))./2;
end

function AdjustCM=GetAdjustCM(hObject, Vec, Type)
handles=guidata(hObject);
CM=handles.(Type).ColorMap;

if isempty(Vec)
    AdjustCM=CM;
else
    PMax=max(Vec);
    NMax=min(Vec);
    if handles.(Type).MCCType==1
        Thres=handles.(Type).Thres;
        PMin=Thres;
        NMin=-Thres;
    else
        Ind=Vec>0;
        if isempty(find(Ind, 1))
            PMin=0;
        else
            PMin=min(Vec(Ind));
        end
        
        Ind=Vec<0;
        if isempty(find(Ind, 1)) %  YAN Chao-Gan, 210926. Fixed a bug.   if isempty(Ind)
            NMin=0;
        else
            NMin=max(Vec(Ind));
        end
    end

    
    % Thres Type: Full, Pos, or Neg
    VecThresType=get(handles.NodePosNegPopup, 'Value');
    switch VecThresType
        case 1 % Full
            PN_Flag='';
        case 2 % Positive
            PN_Flag='+';
        case 3 % Negative
            PN_Flag='-';
    end
    AdjustCM=y_AdjustColorMap(CM,[0.75, 0.75, 0.75],NMax,NMin,PMin,PMax, PN_Flag);
end

function S=CountEdge(hObject)
% Get Thresholded Edge
Edge=GetThresholdedEdge(hObject);

handles=guidata(hObject);
if isempty(handles.Node.NetStruct)
    errordlg('Please set node network.');
    return
end
MergeLabel=handles.Node.NetStruct.Var;
PSurviveP = Edge>0;
PSurviveN = Edge<0;

PSurviveCount=PSurviveP;
NSurviveCount=PSurviveN;
LabelIndex = unique(MergeLabel);
CountSet_Pos = zeros(length(LabelIndex),length(LabelIndex));
CountSet_Neg = zeros(length(LabelIndex),length(LabelIndex));
CountSet_Full = zeros(length(LabelIndex),length(LabelIndex));
FullMatrix=ones(size(PSurviveCount))-eye(size(PSurviveCount));
for j=1:length(LabelIndex)
    for k=1:length(LabelIndex)
        A=double(MergeLabel==LabelIndex(j));
        B=double(MergeLabel==LabelIndex(k));
        Matrix = A*B';
        MatrixIndex = find(Matrix);
        CountSet_Pos(j,k) = sum(PSurviveCount(MatrixIndex));
        CountSet_Neg(j,k) = sum(NSurviveCount(MatrixIndex));
        CountSet_Full(j,k) = sum(FullMatrix(MatrixIndex));
    end
end
CountSet_Pos=CountSet_Pos./(eye(size(CountSet_Pos))+ones(size(CountSet_Pos)));
CountSet_Neg=CountSet_Neg./(eye(size(CountSet_Neg))+ones(size(CountSet_Neg)));
CountSet_Full=CountSet_Full./(eye(size(CountSet_Full))+ones(size(CountSet_Full)));

CountSetPosPercent=CountSet_Pos./CountSet_Full;
CountSetNegPercent=CountSet_Neg./CountSet_Full;

S.CountSetPos=CountSet_Pos;
S.CountSetNeg=CountSet_Neg;
S.CountSetPosPercent=CountSetPosPercent;
S.CountSetNegPercent=CountSetNegPercent;

function CircosStruct=GetCircosStruct(hObject)
CircosStruct=[];
Edge=GetThresholdedEdge(hObject);

handles=guidata(hObject);
if isempty(Edge)
    errordlg('Please set edge matrix first!');
    return
end
NumNode=size(Edge);

if isempty(handles.Edge.ColorMap)
    errordlg('Please set colormap first!');
    return
end

NodeNet=[];
NodeInd=(1:NumNode)';
if ~isempty(handles.Node.NetStruct)
    NodeNet=handles.Node.NetStruct.Var;
    [NodeNet, NodeInd]=sort(NodeNet);
end

NodeLab=[];
if ~isempty(handles.Node.LabStruct)
    NodeLab=handles.Node.LabStruct.Var;
    NodeLab=[num2cell(1:numel(NodeLab))', NodeLab];
    NodeLab=NodeLab(NodeInd, :);
end

NodeNetLab=[];
if ~isempty(handles.Node.NetLabStruct)
    NodeNetLab=handles.Node.NetLabStruct.Var;
end

% Sort Edge
Edge=Edge(NodeInd, :);
Edge=Edge(:, NodeInd);

% Estimate NMax NMin PMin PMax
Vec=Edge(:);
PMax=max(Vec);
NMax=min(Vec);
if handles.Edge.MCCType==1
    Thres=handles.Edge.Thres;
    PMin=Thres;
    NMin=-Thres;
else
    Ind=Vec>0;
    if isempty(find(Ind, 1))
        PMin=0;
    else
        PMin=min(Vec(Ind));
    end
    
    Ind=Vec<0;
    if isempty(find(Ind, 1))
        NMin=0;
    else
        NMin=max(Vec(Ind));
    end
end
Limit=[NMax, NMin; PMin, PMax];

% Circos Struct
CircosStruct.ElementLabel=NodeLab;
CircosStruct.HigherOrderNetworkIndex=NodeNet;
CircosStruct.HigherOrderNetworkLabel=NodeNetLab;
CircosStruct.ProcMatrix=Edge;
CircosStruct.netCmap=handles.Node.ColorMap;
CircosStruct.linkCmap=handles.Edge.ColorMap;
CircosStruct.CmapLimit=Limit;
