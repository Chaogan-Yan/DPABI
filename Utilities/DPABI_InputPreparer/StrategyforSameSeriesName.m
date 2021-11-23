function varargout = StrategyforSameSeriesStrategy(varargin)
% STRATEGYFORSAMESERIESNAME MATLAB code for StrategyforSameSeriesStrategy.fig
%      STRATEGYFORSAMESERIESNAME, by itself, creates a new STRATEGYFORSAMESERIESNAME or raises the existing
%      singleton*.
%
%      H = STRATEGYFORSAMESERIESNAME returns the handle to a new STRATEGYFORSAMESERIESNAME or the handle to
%      the existing singleton*.
%
%      STRATEGYFORSAMESERIESNAME('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STRATEGYFORSAMESERIESNAME.M with the given input arguments.
%
%      STRATEGYFORSAMESERIESNAME('Property','Value',...) creates a new STRATEGYFORSAMESERIESNAME or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before StrategyforSameSeriesStrategy_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to StrategyforSameSeriesStrategy_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help StrategyforSameSeriesStrategy

% Last Modified by GUIDE v2.5 18-Apr-2021 21:32:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @StrategyforSameSeriesStrategy_OpeningFcn, ...
                   'gui_OutputFcn',  @StrategyforSameSeriesStrategy_OutputFcn, ...
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


% --- Executes just before StrategyforSameSeriesStrategy is made visible.
function StrategyforSameSeriesStrategy_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to StrategyforSameSeriesStrategy (see VARARGIN)

if isempty(varargin)
    SameSeriesStrategy.Strategy = 1; % 1 - follow the series index; 2 - mannually choose always
    SameSeriesStrategy.SessionName1 = 'FunRaw';
    SameSeriesStrategy.SessionName2 = 'S2_FunRaw';
    SameSeriesStrategy.SeriesName1 = 'Series Name 1';
    SameSeriesStrategy.SeriesName2 = 'Series Name 2';
else
    SameSeriesStrategy=varargin{1};
end

set(handles.textSession1,'String',[SameSeriesStrategy.SessionName1,':']);
set(handles.textSession2,'String',[SameSeriesStrategy.SessionName2,':']);
set(handles.textSeriesName1,'String',SameSeriesStrategy.SeriesName1);
set(handles.textSeriesName2,'String',SameSeriesStrategy.SeriesName2);
if SameSeriesStrategy.Strategy == 1
    set(handles.radiobuttonFollowSeriesIndex,'Value',1);
    set(handles.radiobuttonAskMeEverytime,'Value',0);
else
    set(handles.radiobuttonFollowSeriesIndex,'Value',0);
    set(handles.radiobuttonAskMeEverytime,'Value',1);
end
% Update handles structure
handles.SameSeriesStrategy=SameSeriesStrategy;
guidata(hObject, handles);
% Choose default command line output for StrategyforSameSeriesStrategy
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
    UISize = get(handles.figureStrategyforSameSeriesStrategy,'Position');
    UISize = UISize.*ZoonMatrix;
    set(handles.figureStrategyforSameSeriesStrategy,'Position',UISize);
end
movegui(handles.figureStrategyforSameSeriesStrategy, 'center');

% UIWAIT makes StrategyforSameSeriesStrategy wait for user response (see UIRESUME)
uiwait(handles.figureStrategyforSameSeriesStrategy);


% --- Outputs from this function are returned to the command line.
function varargout = StrategyforSameSeriesStrategy_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    varargout{1} = [];
else
    varargout{1} = handles.SameSeriesStrategy;
    delete(handles.figureStrategyforSameSeriesStrategy)
end


% --- Executes on button press in radiobuttonFollowSeriesIndex.
function radiobuttonFollowSeriesIndex_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonFollowSeriesIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.SameSeriesStrategy.Strategy = 1;
set(handles.radiobuttonAskMeEverytime,'Value',0);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of radiobuttonFollowSeriesIndex


% --- Executes on button press in radiobuttonAskMeEverytime.
function radiobuttonAskMeEverytime_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonAskMeEverytime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.SameSeriesStrategy.Strategy = 2;
set(handles.radiobuttonFollowSeriesIndex,'Value',0);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of radiobuttonAskMeEverytime


% --- Executes on button press in pushbuttonRun.
function pushbuttonRun_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figureStrategyforSameSeriesStrategy);
