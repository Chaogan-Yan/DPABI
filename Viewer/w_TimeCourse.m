function varargout = w_TimeCourse(varargin)
% W_TIMECOURSE MATLAB code for w_TimeCourse.fig
%      W_TIMECOURSE, by itself, creates a new W_TIMECOURSE or raises the existing
%      singleton*.
%
%      H = W_TIMECOURSE returns the handle to a new W_TIMECOURSE or the handle to
%      the existing singleton*.
%
%      W_TIMECOURSE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in W_TIMECOURSE.M with the given input arguments.
%
%      W_TIMECOURSE('Property','Value',...) creates a new W_TIMECOURSE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before w_TimeCourse_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to w_TimeCourse_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help w_TimeCourse

% Last Modified by GUIDE v2.5 06-Feb-2014 18:19:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @w_TimeCourse_OpeningFcn, ...
                   'gui_OutputFcn',  @w_TimeCourse_OutputFcn, ...
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


% --- Executes just before w_TimeCourse is made visible.
function w_TimeCourse_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to w_TimeCourse (see VARARGIN)
global st

MainFig=varargin{1};
Headers=varargin{2};

for i=1:numel(Headers)
    if ~isempty(Headers{i})
        [OverlayVolume, OverlayVox, OverlayHeader] = y_ReadRPI(Headers{i}.fname);
        Headers{i}.Raw=OverlayVolume;
    end
end

DCObj=datacursormode(hObject);
set(DCObj, 'UpdateFcn', @(Obj,  Event) DataCursor_CallBack(Obj, Event, MainFig, hObject));

% Choose default command line output for w_TimeCourse
handles.output = hObject;
handles.MainFig=MainFig;
handles.Headers=Headers;
% Update handles structure
guidata(hObject, handles);

st{MainFig}.TCFlag=hObject;
y_spm_orthviews('Redraw', MainFig);


% UIWAIT makes w_TimeCourse wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = w_TimeCourse_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

function output_txt = DataCursor_CallBack(obj, event_obj, MainFig, TCFig)
pos = get(event_obj,'Position');

global st

MainHandle=guidata(MainFig);
TCHandle=guidata(TCFig);

OverlayHeaders=MainHandle.OverlayHeaders;

if ~get(TCHandle.FrequencyButton, 'Value')
    blob=0;
    for i=1:numel(OverlayHeaders)
        if ~isempty(OverlayHeaders{i}) && OverlayHeaders{i}.IsSelected
            blob=blob+1;
        end
        if ~isempty(OverlayHeaders{i}) && OverlayHeaders{i}.IsSelected && ...
                OverlayHeaders{i}.numTP > 1
            OverlayHeader=DPABI_VIEW('ChangeTP',...
                OverlayHeaders{i}, pos(1),...
                MainFig, blob,...
                TCHandle.Headers{i}.Raw);
            MainHandle.OverlayHeaders{i}=OverlayHeader;
            if st{MainFig}.curblob==blob
                set(MainHandle.TimePointButton, 'String', sprintf('%d', pos(1)));
                set(MainHandle.LeftButton, 'Enable', 'On');
                set(MainHandle.RightButton, 'Enable', 'On');
                if pos(1)==1
                    set(MainHandle.LeftButton, 'Enable', 'Off');
                end
                if pos(1)==OverlayHeader.numTP
                    set(MainHandle.RightButton, 'Enable', 'Off');
                end
            end
        end
    end
    output_txt=(sprintf('Time Point: %d\nSensitivity: %d',pos(1),pos(2)));    
else
    output_txt=(sprintf('Frequency: %g Hz\nAmplitude: %g',pos(1),pos(2)));
end
guidata(MainFig, MainHandle);

% --- Executes on button press in FrequencyButton.
function FrequencyButton_Callback(hObject, eventdata, handles)
% hObject    handle to FrequencyButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.FrequencyButton, 'Value')
    set(handles.TREntry, 'Enable', 'On');
    set(handles.FrequencyButton, 'String', 'Frequency')
else
    set(handles.TREntry, 'Enable', 'Off');
    set(handles.FrequencyButton, 'String', 'Time')
end
y_spm_orthviews('Redraw', handles.MainFig);
% Hint: get(hObject,'Value') returns toggle state of FrequencyButton



function TREntry_Callback(hObject, eventdata, handles)
% hObject    handle to TREntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
y_spm_orthviews('Redraw', handles.MainFig);
% Hints: get(hObject,'String') returns contents of TREntry as text
%        str2double(get(hObject,'String')) returns contents of TREntry as a double


% --- Executes during object creation, after setting all properties.
function TREntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TREntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
