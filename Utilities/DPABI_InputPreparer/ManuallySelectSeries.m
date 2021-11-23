function varargout = ManuallySelectSeries(varargin)
% MANUALLYSELECTSERIES MATLAB code for ManuallySelectSeries.fig
%      MANUALLYSELECTSERIES, by itself, creates a new MANUALLYSELECTSERIES or raises the existing
%      singleton*.
%
%      H = MANUALLYSELECTSERIES returns the handle to a new MANUALLYSELECTSERIES or the handle to
%      the existing singleton*.
%
%      MANUALLYSELECTSERIES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MANUALLYSELECTSERIES.M with the given input arguments.
%
%      MANUALLYSELECTSERIES('Property','Value',...) creates a new MANUALLYSELECTSERIES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ManuallySelectSeries_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ManuallySelectSeries_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ManuallySelectSeries

% Last Modified by GUIDE v2.5 23-Apr-2021 13:04:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ManuallySelectSeries_OpeningFcn, ...
                   'gui_OutputFcn',  @ManuallySelectSeries_OutputFcn, ...
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


% --- Executes just before ManuallySelectSeries is made visible.
function ManuallySelectSeries_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ManuallySelectSeries (see VARARGIN)
if isempty(varargin)
    Selection.SessionName='';
    Selection.SubID='';
    Selection.SeriesList='';
    Selection.Template='Template1';
else
    Selection.SessionName=varargin{1};
    Selection.SubID=varargin{2};
    Selection.SeriesList=varargin{3};
    Selection.Template=varargin{4};
end
Selection.Results=ones(length(Selection.SessionName),1);
Selection.AlwaysLatterSeries = 0;
set(handles.popupmenuSessionList,'String',Selection.SessionName,'Value',1);
set(handles.popupmenuSeriesList,'String',[{'Please select: ...'};Selection.SeriesList],'Value',1);        
SessionList = '';
for iSession = 1:length(Selection.SessionName)
    SessionList = [SessionList,Selection.SessionName{iSession},', '];
end
SessionList = SessionList(1:end-2);
switch Selection.Template
    case 'Template1'
        Prompt{1,1} = ['Current Subject: ',Selection.SubID];
        Prompt{2,1} = ['Current Session(s): ',Selection.SessionName{1}];
        Prompt{3,1} = ['There are more than one qualified MR series for ',SessionList,', please select one.'];
        set(handles.checkboxAlwaysLatter,'visible','on','Value',0);
    case 'Template2'
        Prompt{1,1} = ['Current Subject: ',Selection.SubID];
        Prompt{2,1} = ['Current Session(s): ',SessionList]; 
        Prompt{3,1} = ['Please manually select MR series for session ',SessionList,'.'];
        set(handles.checkboxAlwaysLatter,'visible','off')
    case 'Template3'
        Prompt{1,1} = ['Current Subject: ',Selection.SubID];
        Prompt{2,1} = ['Current Session(s): ',SessionList];
        Prompt{3,1} = ['The number of qualified MR series is not match the number of sessions, please select manually.'];
        set(handles.checkboxAlwaysLatter,'visible','off')
end
set(handles.textprompt,'String',Prompt,'HorizontalAlignment','left');
% Choose default command line output for ManuallySelectSeries
handles.Selection=Selection;
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Make UI display correct in PC and linux
if ~ismac
    if ispc
        ZoonMatrix = [1 1 1.6 1.2];  %For pc
    else
        ZoonMatrix = [1 1 1.6 1.2];  %For Linux
    end
    UISize = get(handles.figureSelectSeries,'Position');
    UISize = UISize.*ZoonMatrix;
    set(handles.figureSelectSeries,'Position',UISize);
end
movegui(handles.figureSelectSeries, 'center');

% UIWAIT makes ManuallySelectSeries wait for user response (see UIRESUME)
uiwait(handles.figureSelectSeries);


% --- Outputs from this function are returned to the command line.
function varargout = ManuallySelectSeries_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    varargout{1} = [];
else
    varargout{1} = handles.Selection;
    delete(handles.figureSelectSeries)
end

% --- Executes on button press in pushbuttonRun.
function pushbuttonRun_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Index = find(handles.Selection.Results==1);
if ~isempty(Index)
    uiwait(msgbox({'Some sessions have not been determined, please check!'},'Selection not finished.'));
else
    handles.Selection.Results = handles.Selection.Results-1; % minus "please select" line
    uiresume(handles.figureSelectSeries);
end


% --- Executes on selection change in popupmenuSessionList.
function popupmenuSessionList_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSessionList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
iSession = get(handles.popupmenuSessionList,'Value');
set(handles.popupmenuSeriesList,'Value',handles.Selection.Results(iSession))
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSessionList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSessionList


% --- Executes during object creation, after setting all properties.
function popupmenuSessionList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSessionList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuSeriesList.
function popupmenuSeriesList_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSeriesList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
iSession = get(handles.popupmenuSessionList,'Value');
handles.Selection.Results(iSession) = get(handles.popupmenuSeriesList,'Value');
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSeriesList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSeriesList


% --- Executes during object creation, after setting all properties.
function popupmenuSeriesList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSeriesList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxAlwaysLatter.
function checkboxAlwaysLatter_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxAlwaysLatter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Selection.AlwaysLatterSeries  = get(handles.checkboxAlwaysLatter,'Value');
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxAlwaysLatter
