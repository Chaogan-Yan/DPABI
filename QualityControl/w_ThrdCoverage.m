function varargout = w_ThrdCoverage(varargin)
% W_THRDCOVERAGE MATLAB code for w_ThrdCoverage.fig
%      W_THRDCOVERAGE, by itself, creates a new W_THRDCOVERAGE or raises the existing
%      singleton*.
%
%      H = W_THRDCOVERAGE returns the handle to a new W_THRDCOVERAGE or the handle to
%      the existing singleton*.
%
%      W_THRDCOVERAGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in W_THRDCOVERAGE.M with the given input arguments.
%
%      W_THRDCOVERAGE('Property','Value',...) creates a new W_THRDCOVERAGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before w_ThrdCoverage_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to w_ThrdCoverage_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help w_ThrdCoverage

% Last Modified by GUIDE v2.5 06-Apr-2014 21:56:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @w_ThrdCoverage_OpeningFcn, ...
                   'gui_OutputFcn',  @w_ThrdCoverage_OutputFcn, ...
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


% --- Executes just before w_ThrdCoverage is made visible.
function w_ThrdCoverage_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to w_ThrdCoverage (see VARARGIN)
MainFig=varargin{1};
MainHandle=guidata(MainFig);

SubjList=get(MainHandle.SubjListbox, 'String');
WorkDir=get(MainHandle.WorkDirEntry, 'String');

try
    [File , Path]=uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
        'Pick Group Mask' , fullfile(WorkDir, 'Masks', 'GroupMask'));
catch
    errordlg('Generate Group Mask First!');
    return
end

if isnumeric(File)
    return
end
[GMask, GVox, GHeader]=y_ReadRPI(fullfile(Path, File));
GMask=logical(GMask);

if exist(fullfile(WorkDir, 'Masks', 'AutoMasks', ['wAutoMask_', SubjList{1},'.nii'])) % See if is DPARSF or DPABISurf
    MaskList=cellfun(@(subj) fullfile(WorkDir, 'Masks', 'AutoMasks', ['wAutoMask_', subj]), SubjList,...
        'UniformOutput', false);
else
    MaskList=[];
    for iSub=1:length(SubjList)
        DirFile=dir(fullfile(WorkDir, 'Masks', 'AutoMasks', [SubjList{iSub},'*MNI152NLin2009cAsym*brain_mask.nii*']));
        MaskList{iSub,1}=fullfile(WorkDir, 'Masks', 'AutoMasks', DirFile(1).name);
    end
%     MaskList=cellfun(@(subj) fullfile(WorkDir, 'Masks', 'AutoMasks', [subj,'_task-rest_space-MNI152NLin2009cAsym_desc-brain_mask.nii.gz']), SubjList,...
%         'UniformOutput', false);
end

CoverageVector=zeros(size(MaskList));
for i=1:numel(MaskList)
    [Mask, Vox, Header]=y_ReadRPI(MaskList{i});
    Mask=logical(Mask);
    
    Inter=(Mask & GMask);    
    %Union=(Mask | GMask);
    
    CoverageVector(i, 1)=2*sum(Inter(:))/(sum(Mask(:))+sum(GMask(:))); 
    %CoverageVector(i, 1)=sum(Inter(:))/sum(Union(:));
end

MeanCoverage=mean(CoverageVector);
SDCoverage=std(CoverageVector);

set(handles.MeanAndSDLab, 'String',...
    sprintf('( Coverage ) mean: %.4g; SD: %.4g', MeanCoverage, SDCoverage));
if ~isempty(MainHandle.CoverageValue)
    set(handles.ThrdEntry, 'String', num2str(MainHandle.CoverageValue));
else
    set(handles.ThrdEntry, 'String', '');
end
% Choose default command line output for w_ThrdCoverage
handles.MainFig=MainFig;
handles.CoverageVector=CoverageVector;
handles.SubjList=SubjList;
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

% UIWAIT makes w_ThrdCoverage wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = w_ThrdCoverage_OutputFcn(hObject, eventdata, handles) 
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
CoverageVector=handles.CoverageVector;
CoverageValue=str2double(get(handles.ThrdEntry, 'String'));
if isnan(CoverageValue)
    CoverageSubj=[];
    CoverageValue=[];
else
    CoverageSubj=handles.SubjList(CoverageVector >= CoverageValue );
end
MainHandle.CoverageValue=CoverageValue;
MainHandle.CoverageSubj=CoverageSubj;

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
