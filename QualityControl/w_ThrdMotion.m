function varargout = w_ThrdMotion(varargin)
% W_THRDMOTION MATLAB code for w_ThrdMotion.fig
%      W_THRDMOTION, by itself, creates a new W_THRDMOTION or raises the existing
%      singleton*.
%
%      H = W_THRDMOTION returns the handle to a new W_THRDMOTION or the handle to
%      the existing singleton*.
%
%      W_THRDMOTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in W_THRDMOTION.M with the given input arguments.
%
%      W_THRDMOTION('Property','Value',...) creates a new W_THRDMOTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before w_ThrdMotion_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to w_ThrdMotion_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help w_ThrdMotion

% Last Modified by GUIDE v2.5 07-Apr-2014 19:27:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @w_ThrdMotion_OpeningFcn, ...
                   'gui_OutputFcn',  @w_ThrdMotion_OutputFcn, ...
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


% --- Executes just before w_ThrdMotion is made visible.
function w_ThrdMotion_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to w_ThrdMotion (see VARARGIN)
MainFig=varargin{1};
MainHandle=guidata(MainFig);

SubjString=get(MainHandle.SubjListbox, 'String');
WorkDir=get(MainHandle.WorkDirEntry, 'String');

TSVFile=fullfile(WorkDir, 'RealignParameter', 'HeadMotion.tsv');
fd=fopen(TSVFile);

if fd==-1
    error('Invalid File');
end

textscan(fd, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s', 1, 'delimiter', '\t');
M=textscan(fd, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%f', 'delimiter', '\t');
fclose(fd);

AllSubjList=M{1};
Index1=false(size(AllSubjList));

for i=1:numel(AllSubjList)
    TEMP=find(strcmpi(AllSubjList{i}, SubjString), 1);
    if ~isempty(TEMP)
        Index1(i)=true;
    end    
end

if ~isempty(MainHandle.CoverageSubj)
    Index2=false(size(AllSubjList));

    for i=1:numel(AllSubjList)
        TEMP=find(strcmpi(AllSubjList{i}, MainHandle.CoverageSubj), 1);
        if ~isempty(TEMP)
            Index2(i)=true;
        end    
    end
    Index=( Index1 & Index2 );
else
    Index=Index1;
end
%MeanFD=cell2mat(M{21}(Index));
MeanFD=(M{21}(Index));

MeanMeanFD=mean(MeanFD);
SDMeanFD=std(MeanFD);

set(handles.MeanAndSDLab, 'String',...
    sprintf('(Mean FD Jenkinson) mean: %.4g; SD: %.4g', MeanMeanFD, SDMeanFD));
if ~isempty(MainHandle.MeanFD)
    set(handles.ThrdEntry, 'String', num2str(MainHandle.MeanFD));
else
    set(handles.ThrdEntry, 'String', '');
end
% Choose default command line output for w_ThrdMotion
handles.MainFig=MainFig;
handles.output = hObject;


% Make UI display correct in PC and linux
if ~ismac
    if ispc
        ZoonMatrix = [1 1 1.2 1.2];  %For pc
    else
        ZoonMatrix = [1 1 1.2 1.2];  %For Linux
    end
    UISize = get(handles.figure1,'Position');
    UISize = UISize.*ZoonMatrix;
    set(handles.figure1,'Position',UISize);
end
movegui(handles.figure1,'center');



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes w_ThrdMotion wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = w_ThrdMotion_OutputFcn(hObject, eventdata, handles) 
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


% --- Executes on button press in OKButton.
function OKButton_Callback(hObject, eventdata, handles)
% hObject    handle to OKButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MainHandle=guidata(handles.MainFig);
MeanFD=str2double(get(handles.ThrdEntry, 'String'));
if isnan(MeanFD)
    MeanFD=[];
end
MainHandle.MeanFD=MeanFD;

guidata(handles.MainFig, MainHandle);
guidata(hObject, handles);

uiresume(handles.figure1);

function ThrdEntry_Callback(hObject, eventdata, handles)
% hObject    handle to ThrdEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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
