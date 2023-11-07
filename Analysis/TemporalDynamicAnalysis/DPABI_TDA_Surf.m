function varargout = DPABI_TDA(varargin)
% DPABI_TDA MATLAB code for DPABI_TDA.fig
%      DPABI_TDA, by itself, creates a new DPABI_TDA or raises the existing
%      singleton*.
%
%      H = DPABI_TDA returns the handle to a new DPABI_TDA or the handle to
%      the existing singleton*.
%
%      DPABI_TDA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABI_TDA.M with the given input arguments.
%
%      DPABI_TDA('Property','Value',...) creates a new DPABI_TDA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABI_TDA_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABI_TDA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABI_TDA

% Last Modified by GUIDE v2.5 25-Feb-2020 16:50:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @DPABI_TDA_OpeningFcn, ...
    'gui_OutputFcn',  @DPABI_TDA_OutputFcn, ...
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


% --- Executes just before DPABI_TDA is made visible.
function DPABI_TDA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABI_TDA (see VARARGIN)


% Set handles
Path = which('dpabi');
[filepath,name,ext] = fileparts(Path);
handles.Cfg.DPABIPath = filepath;
handles.Cfg.WorkingDir = pwd;
handles.Cfg.StartingDirName = 'FunSurfWC';
handles.Cfg.SubjectID = [];
handles.Cfg.TR = 0;
handles.Cfg.IsProcessVolumeSpace = 1;
handles.Cfg.MaskFileSurfLH=fullfile(handles.Cfg.DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_lh_cortex.label.gii');
handles.Cfg.MaskFileSurfRH=fullfile(handles.Cfg.DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_rh_cortex.label.gii');
handles.Cfg.MaskFileVolu=fullfile(handles.Cfg.WorkingDir, 'Masks','AllResampled_BrainMask_05_91x109x91.nii');
handles.Cfg.WindowSize = 30;
handles.Cfg.WindowStep = 1;
handles.Cfg.WindowType = 'hamming';
handles.Cfg.IsDetrend = 1;

handles.Cfg.IsALFF = 1;
handles.Cfg.ALFF.ALowPass_HighCutoff=0.1;
handles.Cfg.ALFF.AHighPass_LowCutoff=0.01;
handles.Cfg.StartingDirForDCetc = {};
handles.Cfg.IsReHo = 1;
handles.Cfg.ReHo.SurfNNeighbor = 1;
handles.Cfg.ReHo.Cluster = 27;
handles.Cfg.SurfFileLH=fullfile(handles.Cfg.DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_lh_pial.surf.gii');
handles.Cfg.SurfFileRH=fullfile(handles.Cfg.DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_rh_pial.surf.gii');
handles.Cfg.IsDegreeCentrality = 1;
handles.Cfg.DegreeCentrality.rThreshold = 0.25;
handles.Cfg.IsGSCorr = 1;
handles.Cfg.GSCorr.GlobalMaskVolu = handles.Cfg.MaskFileVolu;
handles.Cfg.IsFC = 0;
handles.Cfg.CalFC.ROIDefVolu={};
handles.Cfg.CalFC.ROIDefSurfLH={};
handles.Cfg.CalFC.ROIDefSurfRH={};
handles.Cfg.CalFC.IsMultipleLabel = 0;


handles.Cfg.VoxelWiseConcordance = 1;
handles.Cfg.VolumeWiseConcordance = 1;
handles.Cfg.ConcordanceMeasuresSelected = 'fALFF;ReHo;DC;GSCorr'; %YAN Chao-Gan, 180704. Added flexibility for concordance
handles.Cfg.IsSmoothConcordance = 1;
%handles.Cfg.IsSmoothConcordance.Volu = 1;
handles.Cfg.SmoothConcordance.FWHMSurf = 10;
handles.Cfg.SmoothConcordance.FWHMVolu = [6 6 6];

handles.Cfg.ParallelWorkersNumber = 0;
handles.Cfg.FunctionalSessionNumber = 1;
handles.Cfg.IsDelete4D = 0;


% Refresh the UI
UpdateDisplay(handles);

uiwait(msgbox('Please cite: Yan CG, Yang Z, Colcombe S, Zuo XN, Milham MP (2017) Concordance among indices of intrinsic brain function: insights from inter-individual variation and temporal dynamics. Science Bulletin. 62: 1572-1584.'))

fprintf('\n\nDPABI Temporal Dynamic Analysis module is based on our previous work, please cite it if this module is used: \n');
fprintf('Yan CG, Yang Z, Colcombe S, Zuo XN, Milham MP (2017) Concordance among indices of intrinsic brain function: insights from inter-individual variation and temporal dynamics. Science Bulletin. 62: 1572-1584.\n');


% Make UI display correct in PC and linux
if ~ismac
    if ispc
        ZoonMatrix = [1 1 1 1];  %For pc
    else
        ZoonMatrix = [1 1 1.2 1.1];  %For Linux
    end
    UISize = get(handles.figDPABI_TDA,'Position');
    UISize = UISize.*ZoonMatrix;
    set(handles.figDPABI_TDA,'Position',UISize);
end
movegui(handles.figDPABI_TDA,'center');

% Choose default command line output for DPABI_TDA_Surf
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABI_TDA_Surf wait for user response (see UIRESUME)
% uiwait(handles.figDPABI_TDA);





% --- Outputs from this function are returned to the command line.
function varargout = DPABI_TDA_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function StartDirEntry_Callback(hObject, eventdata, handles)
% hObject    handle to StartDirEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GetSubjList(hObject, handles);
handles.Cfg.SubjectID = get(handles.SubjListbox, 'String');
handles.Cfg.StartingDirName = get(handles.StartDirEntry,'String');
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of StartDirEntry as text
%        str2double(get(hObject,'String')) returns contents of StartDirEntry as a double




% --- Executes during object creation, after setting all properties.
function StartDirEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartDirEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function WorkDirEntry_Callback(hObject, eventdata, handles)
% hObject    handle to WorkDirEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GetSubjList(hObject, handles);
handles.Cfg.SubjectID = get(handles.SubjListbox, 'String');
handles.Cfg.WorkingDir = get(handles.WorkDirEntry,'String');
handles.Cfg.MaskFileVolu=fullfile(handles.Cfg.WorkingDir, 'Masks','AllResampled_BrainMask_05_91x109x91.nii');
UpdateDisplay(handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of WorkDirEntry as text
%        str2double(get(hObject,'String')) returns contents of WorkDirEntry as a double


% --- Executes during object creation, after setting all properties.
function WorkDirEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WorkDirEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in WorkDirButton.
function WorkDirButton_Callback(hObject, eventdata, handles)
% hObject    handle to WorkDirButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=get(handles.WorkDirEntry, 'String');
if ~isdir(Path)
    Path=pwd;
end
Path=uigetdir(Path);
if ~ischar(Path)
    return
end
set(handles.WorkDirEntry, 'String', Path);

GetSubjList(hObject, handles);
handles.Cfg.SubjectID = get(handles.SubjListbox, 'String');
handles.Cfg.WorkingDir = get(handles.WorkDirEntry,'String');
handles.Cfg.MaskFileVolu=fullfile(handles.Cfg.WorkingDir, 'Masks','AllResampled_BrainMask_05_91x109x91.nii');
UpdateDisplay(handles);
guidata(hObject,handles);




function GetSubjList(hObject, handles)
%Create by Sandy to get the Subject List
WorkDir=get(handles.WorkDirEntry, 'String');
if isempty(handles.Cfg.SubjectID)
    StartDir=get(handles.StartDirEntry, 'String');
    FullDir=fullfile(WorkDir, StartDir);
    
    if isempty(WorkDir) || isempty(StartDir) || ~isdir(FullDir)
        set(handles.SubjListbox, 'String', '', 'Value', 0);
        return
    end
    
    SubjStruct=dir(FullDir);
    Index=cellfun(...
        @(IsDir, NotDot) IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')),...
        {SubjStruct.isdir}, {SubjStruct.name});  % drop out the files that are not MRI images
    SubjStruct=SubjStruct(Index);
    SubjString={SubjStruct(:).name}';
    StartDirFlag='On';
else
    SubjString=handles.Cfg.SubjectID;
    StartDirFlag='Off';
end

set(handles.StartDirEntry, 'Enable', StartDirFlag); % need?
set(handles.SubjListbox, 'String', SubjString);
set(handles.SubjListbox, 'Value', 1);




% --- Executes on selection change in SubjListbox.
function SubjListbox_Callback(hObject, eventdata, handles)
% hObject    handle to SubjListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SubjListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SubjListbox


% --- Executes during object creation, after setting all properties.
function SubjListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SubjListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTR_Callback(hObject, eventdata, handles)
% hObject    handle to editTR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.TR = str2num(get(handles.editTR,'String'));
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editTR as text
%        str2double(get(hObject,'String')) returns contents of editTR as a double


% --- Executes during object creation, after setting all properties.
function editTR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkboxProcessVolumeSpace.
function checkboxProcessVolumeSpace_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxProcessVolumeSpace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsProcessVolumeSpace = get(handles.checkboxProcessVolumeSpace,'Value');
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxProcessVolumeSpace

function editMaskFile_Callback(hObject, eventdata, handles)
% hObject    handle to editMaskFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMaskFile as text
%        str2double(get(hObject,'String')) returns contents of editMaskFile as a double


% --- Executes during object creation, after setting all properties.
function editMaskFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMaskFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






function editWindowSize_Callback(hObject, eventdata, handles)
% hObject    handle to editWindowSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.WindowSize = str2num(get(handles.editWindowSize,'String'));
guidata(hObject,handles);

% Hints: get(hObject,'String') returns contents of editWindowSize as text
%        str2double(get(hObject,'String')) returns contents of editWindowSize as a double


% --- Executes during object creation, after setting all properties.
function editWindowSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editWindowSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editWindowStep_Callback(hObject, eventdata, handles)
% hObject    handle to editWindowStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.WindowStep = str2num(get(handles.editWindowStep,'String'));
guidata(hObject,handles);

% Hints: get(hObject,'String') returns contents of editWindowStep as text
%        str2double(get(hObject,'String')) returns contents of editWindowStep as a double


% --- Executes during object creation, after setting all properties.
function editWindowStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editWindowStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in popupmenuWindowType.
function popupmenuWindowType_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuWindowType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
WindowType = get(handles.popupmenuWindowType,'Value');
switch WindowType
    case 1
        handles.Cfg.WindowType = 'hamming';
    case 2
        handles.Cfg.WindowType = 'rectwin';
    case 3
        handles.Cfg.WindowType = 'hann';
end
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuWindowType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuWindowType


% --- Executes during object creation, after setting all properties.
function popupmenuWindowType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuWindowType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxDetrend.
function checkboxDetrend_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxDetrend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsDetrend = get(handles.checkboxDetrend,'Value');
guidata(hObject,handles);

% Hint: get(hObject,'Value') returns toggle state of checkboxDetrend


% --- Executes on button press in checkboxALFFfALFF.
function checkboxALFFfALFF_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxALFFfALFF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsALFF = get(handles.checkboxALFFfALFF,'Value');
UpdateDisplay(handles);
guidata(hObject,handles);

% Hint: get(hObject,'Value') returns toggle state of checkboxALFFfALFF



function editBandLow_Callback(hObject, eventdata, handles)
% hObject    handle to editBandLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.ALFF.AHighPass_LowCutoff = str2num(get(handles.editBandLow,'String'));
guidata(hObject,handles);

% Hints: get(hObject,'String') returns contents of editBandLow as text
%        str2double(get(hObject,'String')) returns contents of editBandLow as a double


% --- Executes during object creation, after setting all properties.
function editBandLow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBandLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editBandHigh_Callback(hObject, eventdata, handles)
% hObject    handle to editBandHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.ALFF.ALowPass_HighCutoff = str2num(get(handles.editBandHigh,'String'));
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editBandHigh as text
%        str2double(get(hObject,'String')) returns contents of editBandHigh as a double


% --- Executes during object creation, after setting all properties.
function editBandHigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBandHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editStartingDirectoryForReHoetc_Callback(hObject, eventdata, handles)
% hObject    handle to editStartingDirectoryForReHoetc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.StartingDirForDCetc = get(handles.editStartingDirectoryForReHoetc,'String');
guidata(hObject,handles);

% Hints: get(hObject,'String') returns contents of editStartingDirectoryForReHoetc as text
%        str2double(get(hObject,'String')) returns contents of editStartingDirectoryForReHoetc as a double


% --- Executes during object creation, after setting all properties.
function editStartingDirectoryForReHoetc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStartingDirectoryForReHoetc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxReHo.
function checkboxReHo_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxReHo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsReHo = get(handles.checkboxReHo,'Value');
UpdateDisplay(handles);
guidata(hObject,handles);

% Hint: get(hObject,'Value') returns toggle state of checkboxReHo


% --- Executes on button press in rbtnReHo7.
function rbtnReHo7_Callback(hObject, eventdata, handles)
% hObject    handle to rbtnReHo7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.ReHo.Cluster = 7;
set(handles.rbtnReHo7,'Value',1);
set(handles.rbtnReHo19,'Value',0);
set(handles.rbtnReHo27,'Value',0);
guidata(hObject,handles);

% Hint: get(hObject,'Value') returns toggle state of rbtnReHo7


% --- Executes on button press in rbtnReHo19.
function rbtnReHo19_Callback(hObject, eventdata, handles)
% hObject    handle to rbtnReHo19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.ReHo.Cluster = 19;
set(handles.rbtnReHo7,'Value',0);
set(handles.rbtnReHo19,'Value',1);
set(handles.rbtnReHo27,'Value',0);
guidata(hObject,handles);

% Hint: get(hObject,'Value') returns toggle state of rbtnReHo19


% --- Executes on button press in rbtnReHo27.
function rbtnReHo27_Callback(hObject, eventdata, handles)
% hObject    handle to rbtnReHo27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.ReHo.Cluster = 27;
set(handles.rbtnReHo7,'Value',0);
set(handles.rbtnReHo19,'Value',0);
set(handles.rbtnReHo27,'Value',1);
guidata(hObject,handles);

% Hint: get(hObject,'Value') returns toggle state of rbtnReHo27


% --- Executes on button press in checkboxDC.
function checkboxDC_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxDC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsDegreeCentrality = get(handles.checkboxDC,'Value');
UpdateDisplay(handles);
guidata(hObject,handles);

% Hint: get(hObject,'Value') returns toggle state of checkboxDC



function editrThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to editrThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.DegreeCentrality.rThreshold = str2num(get(handles.editrThreshold,'String'));
guidata(hObject,handles);

% Hints: get(hObject,'String') returns contents of editrThreshold as text
%        str2double(get(hObject,'String')) returns contents of editrThreshold as a double


% --- Executes during object creation, after setting all properties.
function editrThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editrThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxGSCorr.
function checkboxGSCorr_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxGSCorr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsGSCorr = get(handles.checkboxGSCorr,'Value');
UpdateDisplay(handles);
guidata(hObject,handles);

% Hint: get(hObject,'Value') returns toggle state of checkboxGSCorr

%
% % --- Executes on button press in rbtnGSDefaultMask.
% function rbtnGSDefaultMask_Callback(hObject, eventdata, handles)
% % hObject    handle to rbtnGSDefaultMask (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% set(handles.rbtnGSDefaultMask, 'Value', 1);
% set(handles.rbtnGSUserMask, 'Value', 0);
% set(handles.editGSUserMask, 'Enable','off');
% set(handles.editGSUserMask, 'String', 'Default Mask');
% set(handles.btnGSSelectMask, 'Enable','off');
% handles.Cfg.GSCorr.GlobalMask = 'Default';
% handles.Cfg.GSCorr.GlobalMaskVolu = fullfile(handles.Cfg.DPABIPath, 'Templates','BrainMask_05_61x73x61.img');
% UpdateDisplay(handles);
% guidata(hObject,handles);
%
% % Hint: get(hObject,'Value') returns toggle state of rbtnGSDefaultMask
%
%
% % --- Executes on button press in rbtnGSUserMask.
% function rbtnGSUserMask_Callback(hObject, eventdata, handles)
% % hObject    handle to rbtnGSUserMask (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% set(handles.rbtnGSDefaultMask, 'Value', 0);
% set(handles.rbtnGSUserMask, 'Value', 1);
% set(handles.editGSUserMask, 'Enable','on');
% set(handles.editGSUserMask, 'String', '');
% set(handles.btnGSSelectMask, 'Enable','on');
% handles.Cfg.GSCorr.GlobalMask = 'UserMask';
% UpdateDisplay(handles);
% guidata(hObject,handles);
%
% % Hint: get(hObject,'Value') returns toggle state of rbtnGSUserMask



function editGSUserMask_Callback(hObject, eventdata, handles)
% hObject    handle to editGSUserMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editGSUserMask as text
%        str2double(get(hObject,'String')) returns contents of editGSUserMask as a double
theMaskfile =get(hObject, 'String');
theMaskfile =strtrim(theMaskfile);
if exist(theMaskfile, 'file')
    handles.Cfg.GlobalMaskVolu =theMaskfile;
    guidata(hObject, handles);
else
    errordlg(sprintf('The mask file "%s" does not exist!\n Please re-check it.', theMaskfile));
end
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function editGSUserMask_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editGSUserMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnGSSelectMask.
function btnGSSelectMask_Callback(hObject, eventdata, handles)
% hObject    handle to btnGSSelectMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[MaskFileName,MaskPathName]=uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, 'Pick a a  mask');
if ~([MaskFileName,MaskPathName]==0)
    handles.Cfg.GSCorr.GlobalMaskVolu = [MaskPathName,MaskFileName];
    set(handles.editGSUserMask,'String',[MaskPathName,MaskFileName]);
end

UpdateDisplay(handles);
guidata(hObject, handles);


% --- Executes on button press in checkboxFC.
function checkboxFC_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxFC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsFC = get(handles.checkboxFC,'Value');
UpdateDisplay(handles);
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of checkboxFC


% --- Executes on button press in btnDefineROI.
function btnDefineROI_Callback(hObject, eventdata, handles)
% hObject    handle to btnDefineROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ROIDef.Volume=handles.Cfg.CalFC.ROIDefVolu;
ROIDef.SurfLH=handles.Cfg.CalFC.ROIDefSurfLH;
ROIDef.SurfRH=handles.Cfg.CalFC.ROIDefSurfRH;
if isfield(handles.Cfg.CalFC,'ROISelectedIndexVolu')
    ROISelectedIndex.Volume=handles.Cfg.CalFC.ROISelectedIndexVolu;
else
    ROISelectedIndex.Volume=cell(size(handles.Cfg.CalFC.ROIDefVolu));
end
if isfield(handles.Cfg.CalFC,'ROISelectedIndexSurfLH')
    ROISelectedIndex.SurfLH=handles.Cfg.CalFC.ROISelectedIndexSurfLH;
else
    ROISelectedIndex.SurfLH=cell(size(handles.Cfg.CalFC.ROIDefSurfLH));
end
if isfield(handles.Cfg.CalFC,'ROISelectedIndexSurfRH')
    ROISelectedIndex.SurfRH=handles.Cfg.CalFC.ROISelectedIndexSurfRH;
else
    ROISelectedIndex.SurfRH=cell(size(handles.Cfg.CalFC.ROIDefSurfRH));
end

if handles.Cfg.CalFC.IsMultipleLabel
    fprintf('\nIsMultipleLabel is set to 1: There are multiple labels in the ROI mask file.\n');
else
    fprintf('\nIsMultipleLabel is set to 0: All the non-zero values will be used to define the only ROI.\n');
end

ROIList.ROIDef=ROIDef;
ROIList.ROISelectedIndex=ROISelectedIndex;
ROIList.IsMultipleLabel=handles.Cfg.CalFC.IsMultipleLabel;

%[ROIDef,handles.Cfg.CalFC.IsMultipleLabel]=DPABISurf_ROIList(ROIDef,handles.Cfg.CalFC.IsMultipleLabel);
ROIList = DPABISurf_ROIList(ROIList);

if ~isempty(ROIList.ROIDef)
    handles.Cfg.CalFC.ROIDefVolu=ROIList.ROIDef.Volume;
    handles.Cfg.CalFC.ROIDefSurfLH=ROIList.ROIDef.SurfLH;
    handles.Cfg.CalFC.ROIDefSurfRH=ROIList.ROIDef.SurfRH;

    handles.Cfg.CalFC.ROISelectedIndexVolu=ROIList.ROISelectedIndex.Volume;
    handles.Cfg.CalFC.ROISelectedIndexSurfLH=ROIList.ROISelectedIndex.SurfLH;
    handles.Cfg.CalFC.ROISelectedIndexSurfRH=ROIList.ROISelectedIndex.SurfRH;

    handles.Cfg.CalFC.IsMultipleLabel=ROIList.IsMultipleLabel;
end
guidata(hObject, handles);





function editParallelWorkers_Callback(hObject, eventdata, handles)
% hObject    handle to editParallelWorkers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Size_MatlabPool =str2double(get(handles.editParallelWorkers,'String'));

% Check number of matlab workers. To start the matlabpool if Parallel Computation Toolbox is detected.
PCTVer = ver('distcomp');
if ~isempty(PCTVer)
    FullMatlabVersion = sscanf(version,'%d.%d.%d.%d%s');
    if FullMatlabVersion(1)*1000+FullMatlabVersion(2)<8*1000+3    %YAN Chao-Gan, 151117. If it's lower than MATLAB 2014a.  %FullMatlabVersion(1)*1000+FullMatlabVersion(2)>=7*1000+8    %YAN Chao-Gan, 120903. If it's higher than MATLAB 2008.
        if Size_MatlabPool ~= handles.Cfg.ParallelWorkersNumber;
            if handles.Cfg.ParallelWorkersNumber~=0
                matlabpool close
            end
            if Size_MatlabPool~=0
                matlabpool(Size_MatlabPool)
            end
        end
        CurrentSize_MatlabPool = matlabpool('size');
        handles.Cfg.ParallelWorkersNumber = CurrentSize_MatlabPool;
    else
        if Size_MatlabPool ~= handles.Cfg.ParallelWorkersNumber;
            if handles.Cfg.ParallelWorkersNumber~=0
                poolobj = gcp('nocreate'); % If no pool, do not create new one.
                delete(poolobj);
            end
            if Size_MatlabPool~=0
                parpool(Size_MatlabPool)
            end
        end
        poolobj = gcp('nocreate'); % If no pool, do not create new one.
        if isempty(poolobj)
            CurrentSize_MatlabPool = 0;
        else
            CurrentSize_MatlabPool = poolobj.NumWorkers;
        end
        handles.Cfg.ParallelWorkersNumber = CurrentSize_MatlabPool;
    end
end

guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of editParallelWorkers as text
%        str2double(get(hObject,'String')) returns contents of editParallelWorkers as a double


% --- Executes during object creation, after setting all properties.
function editParallelWorkers_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editParallelWorkers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFunctionalSessions_Callback(hObject, eventdata, handles)
% hObject    handle to editFunctionalSessions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.FunctionalSessionNumber = str2num(get(handles.editFunctionalSessions,'String'));
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of editFunctionalSessions as text
%        str2double(get(hObject,'String')) returns contents of editFunctionalSessions as a double


% --- Executes during object creation, after setting all properties.
function editFunctionalSessions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFunctionalSessions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnSave.
function btnSave_Callback(hObject, eventdata, handles)
% hObject    handle to btnSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uiputfile({'*.mat'}, 'Save Parameters As','Parameters_of_TDA');
if ischar(filename)
    Cfg=handles.Cfg;
    save(['',pathname,filename,''], 'Cfg');
end


% --- Executes on button press in btnLoad.
function btnLoad_Callback(hObject, eventdata, handles)
% hObject    handle to btnLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.mat'}, 'Load Parameters From');
if ischar(filename)
    load([pathname,filename]);
    handles.Cfg = Cfg;
end
if ~isfield(handles.Cfg,'ConcordanceMeasuresSelected') %YAN Chao-Gan, 180704. If ConcordanceMeasuresSelected is not defined.
    handles.Cfg.ConcordanceMeasuresSelected = 'fALFF;ReHo;DC;GSCorr;VMHC'; %YAN Chao-Gan, 180704. Added flexibility for concordance
end

guidata(hObject, handles);
UpdateDisplay(handles);

% --- Executes on button press in btnQuit.
function btnQuit_Callback(hObject, eventdata, handles)
% hObject    handle to btnQuit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figDPABI_TDA);


% --- Executes on button press in checkboxVoxelWiseConcordance.
function checkboxVoxelWiseConcordance_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxVoxelWiseConcordance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.VoxelWiseConcordance = get(handles.checkboxVoxelWiseConcordance,'Value');
if ~handles.Cfg.VoxelWiseConcordance
    handles.Cfg.IsSmoothConcordance=0;
end
UpdateDisplay(handles);
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of checkboxVoxelWiseConcordance


% --- Executes on button press in checkboxVolumeWiseConcordance.
function checkboxVolumeWiseConcordance_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxVolumeWiseConcordance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.VolumeWiseConcordance = get(handles.checkboxVolumeWiseConcordance,'Value');
UpdateDisplay(handles);
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of checkboxVolumeWiseConcordance


% --- Executes on button press in checkboxSmoothVolumeConcordance.
% function checkboxSmoothVolumeConcordance_Callback(hObject, eventdata, handles)
% % hObject    handle to checkboxSmoothVolumeConcordance (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% handles.Cfg.IsSmoothConcordance.Volu = get(handles.checkboxSmoothVolumeConcordance,'Value');
% UpdateDisplay(handles);
% guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of checkboxSmoothVolumeConcordance



function editSmoothVoluConcordanceFWHM_Callback(hObject, eventdata, handles)
% hObject    handle to editSmoothVoluConcordanceFWHM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FWHM = get(handles.editSmoothVoluConcordanceFWHM,'String');
handles.Cfg.SmoothConcordance.FWHMVolu =eval(['[',FWHM,']']);
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of editSmoothVoluConcordanceFWHM as text
%        str2double(get(hObject,'String')) returns contents of editSmoothVoluConcordanceFWHM as a double


% --- Executes during object creation, after setting all properties.
function editSmoothVoluConcordanceFWHM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSmoothVoluConcordanceFWHM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSelect.
function pushbuttonSelect_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Cfg.ConcordanceMeasuresSelected = DPABI_ConcordanceSelect_Surf({handles.Cfg.ConcordanceMeasuresSelected});
guidata(hObject, handles);



function editMaskLH_Callback(hObject, eventdata, handles)
% hObject    handle to editMaskLH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMaskLH as text
%        str2double(get(hObject,'String')) returns contents of editMaskLH as a double
theMaskfile =get(hObject, 'String');
theMaskfile =strtrim(theMaskfile);
if exist(theMaskfile, 'file')
    handles.Cfg.MaskFileSurfLH =theMaskfile;
    guidata(hObject, handles);
else
    errordlg(sprintf('The mask file "%s" does not exist!\n Please re-check it.', theMaskfile));
end
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function editMaskLH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMaskLH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonMaskLH.
function pushbuttonMaskLH_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonMaskLH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName]=uigetfile({'*.gii','Brain Image Files (*.gii)';'*.*', 'All Files (*.*)';},'Select surface mask for left hemisphere:',handles.Cfg.MaskFileSurfLH);
if PathName~=0
    set(handles.editMaskLH, 'String', fullfile(PathName,FileName));
end
handles.Cfg.MaskFileSurfLH = fullfile(PathName,FileName);
guidata(hObject,handles);


function editMaskRH_Callback(hObject, eventdata, handles)
% hObject    handle to editMaskRH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMaskRH as text
%        str2double(get(hObject,'String')) returns contents of editMaskRH as a double
theMaskfile =get(hObject, 'String');
theMaskfile =strtrim(theMaskfile);
if exist(theMaskfile, 'file')
    handles.Cfg.MaskFileSurfRH =theMaskfile;
    guidata(hObject, handles);
else
    errordlg(sprintf('The mask file "%s" does not exist!\n Please re-check it.', theMaskfile));
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editMaskRH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMaskRH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonMaskRH.
function pushbuttonMaskRH_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonMaskRH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName]=uigetfile({'*.gii','Brain Image Files (*.gii)';'*.*', 'All Files (*.*)';},'Select surface mask for right hemisphere:',handles.Cfg.MaskFileSurfRH);
if PathName~=0
    set(handles.editMaskRH, 'String', fullfile(PathName,FileName));
end
handles.Cfg.MaskFileSurfRH = fullfile(PathName,FileName);
guidata(hObject,handles);


% --- Executes on button press in pushbuttonMaskVol.
function pushbuttonMaskVol_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonMaskVol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName]=uigetfile({'*.nii','Brain Image uFiles (*.nii)';'*.img','Brain Image Files (*.img)';'*.*', 'All Files (*.*)';},'Select volume mask:',handles.Cfg.MaskFileVolu);
if PathName~=0
    set(handles.editMaskVolu, 'String', fullfile(PathName,FileName));
end
handles.Cfg.MaskFileVolu = fullfile(PathName,FileName);
handles.Cfg.GSCorr.GlobalMaskVolu = handles.Cfg.MaskFileVolu;
UpdateDisplay(handles);
guidata(hObject,handles);



function editMaskVolu_Callback(hObject, eventdata, handles)
% hObject    handle to editMaskVolu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMaskVolu as text
%        str2double(get(hObject,'String')) returns contents of editMaskVolu as a double
theMaskfile =get(hObject, 'String');
theMaskfile =strtrim(theMaskfile);
if exist(theMaskfile, 'file')
    handles.Cfg.MaskFileVolu =theMaskfile;
    guidata(hObject, handles);
else
    errordlg(sprintf('The mask file "%s" does not exist!\n Please re-check it.', theMaskfile));
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editMaskVolu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMaskVolu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in checkboxSmoothConcordance.
function checkboxSmoothConcordance_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSmoothConcordance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsSmoothConcordance = get(handles.checkboxSmoothConcordance,'Value');
UpdateDisplay(handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxSmoothConcordance



function editSmoothSurfConcordanceFWHM_Callback(hObject, eventdata, handles)
% hObject    handle to editSmoothSurfConcordanceFWHM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.SmoothConcordance.FWHMSurf = str2num(get(handles.editSmoothSurfConcordanceFWHM,'String'));
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editSmoothSurfConcordanceFWHM as text
%        str2double(get(hObject,'String')) returns contents of editSmoothSurfConcordanceFWHM as a double


% --- Executes during object creation, after setting all properties.
function editSmoothSurfConcordanceFWHM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSmoothSurfConcordanceFWHM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rbtnReHoSurf1.
function rbtnReHoSurf1_Callback(hObject, eventdata, handles)
% hObject    handle to rbtnReHoSurf1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.ReHo.SurfNNeighbor = 1;
UpdateDisplay(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of rbtnReHoSurf1


% --- Executes on button press in rbtnReHoSurf2.
function rbtnReHoSurf2_Callback(hObject, eventdata, handles)
% hObject    handle to rbtnReHoSurf2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.ReHo.SurfNNeighbor = 2;
UpdateDisplay(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of rbtnReHoSurf2



function editSurfLH_Callback(hObject, eventdata, handles)
% hObject    handle to editSurfLH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSurfLH as text
%        str2double(get(hObject,'String')) returns contents of editSurfLH as a double
theMaskfile =get(hObject, 'String');
theMaskfile =strtrim(theMaskfile);
if exist(theMaskfile, 'file')
    handles.Cfg.SurfFileLH =theMaskfile;
    guidata(hObject, handles);
else
    errordlg(sprintf('The mask file "%s" does not exist!\n Please re-check it.', theMaskfile));
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editSurfLH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSurfLH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSurfLH.
function pushbuttonSurfLH_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSurfLH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName]=uigetfile({'*.gii','Brain Image Files (*.gii)';'*.*', 'All Files (*.*)';},'Select surface file for left hemisphere:',handles.Cfg.SurfFileLH);
if PathName~=0
    set(handles.editSurfLH, 'String', fullfile(PathName,FileName));
end
handles.Cfg.SurfFileLH = fullfile(PathName,FileName);
guidata(hObject,handles);


function editSurfRH_Callback(hObject, eventdata, handles)
% hObject    handle to editSurfRH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSurfRH as text
%        str2double(get(hObject,'String')) returns contents of editSurfRH as a double
theMaskfile =get(hObject, 'String');
theMaskfile =strtrim(theMaskfile);
if exist(theMaskfile, 'file')
    handles.Cfg.SurfFileRH =theMaskfile;
    guidata(hObject, handles);
else
    errordlg(sprintf('The mask file "%s" does not exist!\n Please re-check it.', theMaskfile));
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editSurfRH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSurfRH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSurfRH.
function pushbuttonSurfRH_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSurfRH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName]=uigetfile({'*.gii','Brain Image Files (*.gii)';'*.*', 'All Files (*.*)';},'Select surface file for right hemisphere:',handles.Cfg.SurfFileRH);
if PathName~=0
    set(handles.editSurfRH, 'String', fullfile(PathName,FileName));
end
handles.Cfg.SurfFileRH = fullfile(PathName,FileName);
guidata(hObject,handles);


% --- Executes on button press in checkboxDelete4D.
function checkboxDelete4D_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxDelete4D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsDelete4D = get(handles.checkboxDelete4D,'Value');
if handles.Cfg.IsDelete4D
    uiwait(msgbox({'If this option is selected, TemporalDynamics4D files which are the R-fMRI Metrics calculated in every time window would be deleted to save storage!'},'Delete Raw Dynamic Files'));
end
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxDelete4D



% --------------------------------------------------------------------
function RemoveOneSubj_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveOneSubj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function RemoveOneSubjButton_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveOneSubjButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.SubjListbox, 'Value');
if ~Value
    return
end
OneSubj=get(handles.SubjListbox, 'String');
OneSubj=OneSubj{Value};

if isempty(handles.Cfg.SubjectID)
    SubjString=get(handles.SubjListbox, 'String');
else
    SubjString=handles.Cfg.SubjectID;
end

Index=strcmpi(OneSubj, SubjString);
SubjString=SubjString(~Index);

handles.Cfg.SubjectID=SubjString;
guidata(hObject, handles);
GetSubjList(hObject, handles);


% --- Executes on button press in btnRun.
function btnRun_Callback(hObject, eventdata, handles)
% hObject    handle to btnRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Cfg=handles.Cfg;
ReHo={'',' ReHo'};DC={'',' DC'};GSCorr={'',' GSCorr'};FC={'',' FC'};
if (isempty(Cfg.StartingDirForDCetc) | strcmp(Cfg.StartingDirForDCetc{1},'')) & ...
        (Cfg.IsReHo||Cfg.IsDegreeCentrality||Cfg.IsGSCorr||Cfg.IsFC)
    uiwait(msgbox(['Starting directory for',ReHo{Cfg.IsReHo+1},DC{Cfg.IsDegreeCentrality+1},...
        GSCorr{Cfg.IsGSCorr+1},FC{Cfg.IsFC+1},' are not specified, so the starting directory for them will',...
        ' follow the default setting: [',handles.Cfg.StartingDirName,'].'],'Warning'));
end
Datetime=fix(clock);
save([handles.Cfg.WorkingDir,filesep,'DPABI_TDA_Surf_AutoSave_',num2str(Datetime(1)),'_',num2str(Datetime(2)),'_',num2str(Datetime(3)),'_',num2str(Datetime(4)),'_',num2str(Datetime(5)),'.mat'], 'Cfg'); %Added by YAN Chao-Gan, 100130.

DPABI_TDA_Surf_run(handles.Cfg);

% clc;
% disp(handles.Cfg)
% disp('')
% disp(handles.Cfg.SubjectID)
% disp('')
% disp(handles.Cfg.ALFF)
% disp('')
% disp(handles.Cfg.ReHo)
% disp('')
% disp(handles.Cfg.DegreeCentrality)
% disp('')
% disp(handles.Cfg.GSCorr)
% disp('')
% disp(handles.Cfg.CalFC)
% disp('')
% disp(handles.Cfg.IsSmoothConcordance)
% disp('')
% disp(handles.Cfg.SmoothConcordance)


%% Update All the uiControls' display on the GUI
function UpdateDisplay(handles)
set(handles.WorkDirEntry,'String',handles.Cfg.WorkingDir);
set(handles.StartDirEntry,'string',handles.Cfg.StartingDirName);

if size(handles.Cfg.SubjectID,1)>0
    theOldIndex =get(handles.SubjListbox, 'Value');
    set(handles.SubjListbox, 'String',  handles.Cfg.SubjectID , 'Value', 1);
    theCount =size(handles.Cfg.SubjectID,1);
    if (theOldIndex>0) && (theOldIndex<= theCount) %%% keep the cruise at the position before (position 'value')
        set(handles.SubjListbox, 'Value', theOldIndex);
    end
else
    set(handles.SubjListbox, 'String', '' , 'Value', 0);
end

set(handles.editTR, 'String', num2str(handles.Cfg.TR));

% Also Process Volume Space Data
set(handles.checkboxProcessVolumeSpace,'Value',handles.Cfg.IsProcessVolumeSpace);

set(handles.editMaskLH, 'String', handles.Cfg.MaskFileSurfLH);
set(handles.editMaskRH, 'String', handles.Cfg.MaskFileSurfRH);
set(handles.editMaskVolu, 'String', handles.Cfg.MaskFileVolu);

set(handles.editWindowSize, 'String', num2str(handles.Cfg.WindowSize));
set(handles.editWindowStep, 'String', num2str(handles.Cfg.WindowStep));

switch lower(handles.Cfg.WindowType)
    case 'hamming'
        set(handles.popupmenuWindowType, 'Value', 1);
    case 'rectwin'
        set(handles.popupmenuWindowType, 'Value', 2);
    case 'hann'
        set(handles.popupmenuWindowType, 'Value', 3);
end

set(handles.checkboxDetrend,'Value',handles.Cfg.IsDetrend);

% ALFF/fALFF
set(handles.checkboxALFFfALFF,'Value',handles.Cfg.IsALFF);
set(handles.editBandLow,'String',num2str(handles.Cfg.ALFF.AHighPass_LowCutoff));
set(handles.editBandHigh,'String',num2str(handles.Cfg.ALFF.ALowPass_HighCutoff));
% Make uicontrols ubable if there is no ALFF
if get(handles.checkboxALFFfALFF,'Value')
    set(handles.textBand,'Enable','on');
    set(handles.editBandLow,'Enable','on');
    set(handles.textBandTo,'Enable','on');
    set(handles.textBand,'Enable','on');
    set(handles.editBandHigh,'Enable','on');
else
    set(handles.textBand,'Enable','off');
    set(handles.editBandLow,'Enable','off');
    set(handles.textBandTo,'Enable','off');
    set(handles.textBand,'Enable','off');
    set(handles.editBandHigh,'Enable','off');
end

set(handles.editStartingDirectoryForReHoetc,'String',handles.Cfg.StartingDirForDCetc);

% ReHo
set(handles.checkboxReHo,'Value',handles.Cfg.IsReHo);
switch handles.Cfg.ReHo.SurfNNeighbor
    case 1
        set(handles.rbtnReHoSurf1,'Value',1);
        set(handles.rbtnReHoSurf2,'Value',0);
    case 2
        set(handles.rbtnReHoSurf1,'Value',0);
        set(handles.rbtnReHoSurf2,'Value',1);
end
switch handles.Cfg.ReHo.Cluster
    case 7
        set(handles.rbtnReHo7,'Value',1);
        set(handles.rbtnReHo19,'Value',0);
        set(handles.rbtnReHo27,'Value',0);
    case 19
        set(handles.rbtnReHo7,'Value',0);
        set(handles.rbtnReHo19,'Value',1);
        set(handles.rbtnReHo27,'Value',0);
    case 27
        set(handles.rbtnReHo7,'Value',0);
        set(handles.rbtnReHo19,'Value',0);
        set(handles.rbtnReHo27,'Value',1);
end
set(handles.editSurfLH,'String',handles.Cfg.SurfFileLH);
set(handles.editSurfRH,'String',handles.Cfg.SurfFileRH);
% Make uicontrols ubable if there is no ReHo
if get(handles.checkboxReHo,'Value')
    set(handles.textSurfaceNeighbors,'Enable','on');
    set(handles.rbtnReHoSurf1,'Enable','on');
    set(handles.rbtnReHoSurf2,'Enable','on');
    set(handles.textVolumeCluster,'Enable','on');
    set(handles.rbtnReHo7,'Enable','on');
    set(handles.rbtnReHo19,'Enable','on');
    set(handles.rbtnReHo27,'Enable','on');
    set(handles.textSurfaceFile,'Enable','on');
    set(handles.textSurfLH,'Enable','on');
    set(handles.editSurfLH,'Enable','on');
    set(handles.pushbuttonSurfLH,'Enable','on');
    set(handles.textMaskRH,'Enable','on');
    set(handles.editSurfRH,'Enable','on');
    set(handles.pushbuttonSurfRH,'Enable','on');
    
else
    set(handles.textSurfaceNeighbors,'Enable','off');
    set(handles.rbtnReHoSurf1,'Enable','off');
    set(handles.rbtnReHoSurf2,'Enable','off');
    set(handles.textVolumeCluster,'Enable','off');
    set(handles.rbtnReHo7,'Enable','off');
    set(handles.rbtnReHo19,'Enable','off');
    set(handles.rbtnReHo27,'Enable','off');
    set(handles.textSurfaceFile,'Enable','off');
    set(handles.textSurfLH,'Enable','off');
    set(handles.editSurfLH,'Enable','off');
    set(handles.pushbuttonSurfLH,'Enable','off');
    set(handles.textMaskRH,'Enable','off');
    set(handles.editSurfRH,'Enable','off');
    set(handles.pushbuttonSurfRH,'Enable','off');
end

% DegreeCentrality
set(handles.checkboxDC,'Value',handles.Cfg.IsDegreeCentrality);
set(handles.editrThreshold,'String',num2str(handles.Cfg.DegreeCentrality.rThreshold));
% Make uicontrols ubable if there is no DC
if get(handles.checkboxDC,'Value')
    set(handles.textrThreshold,'Enable','on');
    set(handles.editrThreshold,'Enable','on');
else
    set(handles.textrThreshold,'Enable','off');
    set(handles.editrThreshold,'Enable','off');
end

% GSCorr
set(handles.checkboxGSCorr,'Value',handles.Cfg.IsGSCorr);
if get(handles.checkboxGSCorr,'Value')
    set(handles.editGSUserMask,'Enable','on');
    set(handles.editGSUserMask, 'String',handles.Cfg.GSCorr.GlobalMaskVolu);
    set(handles.btnGSSelectMask, 'Enable','on');
else
    set(handles.editGSUserMask,'Enable','off');
    set(handles.btnGSSelectMask,'Enable','off');
end

% FC
set(handles.checkboxFC,'Value',handles.Cfg.IsFC);
% Make uicontrols ubable if there is no FC
if get(handles.checkboxFC,'Value')
    set(handles.btnDefineROI,'Enable','on');
else
    set(handles.btnDefineROI,'Enable','off');
end



% Calculate and smooth concordance
set(handles.checkboxVoxelWiseConcordance,'Value',handles.Cfg.VoxelWiseConcordance);
set(handles.checkboxVolumeWiseConcordance,'Value',handles.Cfg.VolumeWiseConcordance);
set(handles.checkboxSmoothConcordance,'Value',handles.Cfg.IsSmoothConcordance);
% set(handles.checkboxSmoothVolumeConcordance,'Value',handles.Cfg.IsSmoothConcordance.Volu);
set(handles.editSmoothVoluConcordanceFWHM,'String',mat2str(handles.Cfg.SmoothConcordance.FWHMVolu));
set(handles.editSmoothSurfConcordanceFWHM,'String',mat2str(handles.Cfg.SmoothConcordance.FWHMSurf));
% Make uicontrols ubable if there is no concordance calculation
if handles.Cfg.VoxelWiseConcordance
    set(handles.pushbuttonSelect,'Enable','on');
    set(handles.checkboxSmoothConcordance,'Enable','on');
    %set(handles.checkboxSmoothVolumeConcordance,'Enable','on');
    if handles.Cfg.IsSmoothConcordance
        set(handles.textSmoothSurfConcordanceFWHM,'Enable','on');
        set(handles.editSmoothSurfConcordanceFWHM,'Enable','on');
        set(handles.editSmoothVoluConcordanceFWHM,'Enable','on');
        set(handles.textSmoothVoluConcordanceFWHM,'Enable','on');
    else
        set(handles.textSmoothSurfConcordanceFWHM,'Enable','off');
        set(handles.editSmoothSurfConcordanceFWHM,'Enable','off');
        set(handles.editSmoothVoluConcordanceFWHM,'Enable','off');
        set(handles.textSmoothVoluConcordanceFWHM,'Enable','off');
    end
elseif handles.Cfg.VolumeWiseConcordance
    set(handles.pushbuttonSelect,'Enable','on');
    set(handles.checkboxSmoothConcordance,'Enable','off');
    %set(handles.checkboxSmoothVolumeConcordance,'Enable','off');
    set(handles.textSmoothSurfConcordanceFWHM,'Enable','off');
    set(handles.textSmoothVoluConcordanceFWHM,'Enable','off');
    set(handles.editSmoothSurfConcordanceFWHM,'Enable','off');
    set(handles.editSmoothVoluConcordanceFWHM,'Enable','off');
else
    set(handles.pushbuttonSelect,'Enable','off');
    set(handles.checkboxSmoothConcordance,'Enable','off');
    %set(handles.checkboxSmoothVolumeConcordance,'Enable','off');
    set(handles.textSmoothSurfConcordanceFWHM,'Enable','off');
    set(handles.textSmoothVoluConcordanceFWHM,'Enable','off');
    set(handles.editSmoothSurfConcordanceFWHM,'Enable','off');
    set(handles.editSmoothVoluConcordanceFWHM,'Enable','off');
end

set(handles.editParallelWorkers,'String',handles.Cfg.ParallelWorkersNumber);
set(handles.editFunctionalSessions,'String',num2str(handles.Cfg.FunctionalSessionNumber));
set(handles.checkboxDelete4D,'Value',handles.Cfg.IsDelete4D);
