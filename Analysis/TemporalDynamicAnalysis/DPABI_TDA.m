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

% Last Modified by GUIDE v2.5 02-Jul-2018 14:55:06

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

handles.Cfg.WorkingDir = pwd; 
handles.Cfg.StartingDirName = 'FunImg'; 
handles.Cfg.SubjectID = [];
handles.Cfg.TR = 0;
handles.Cfg.MaskType = 'Default'; % 'Default','NoMask','UserMask'
handles.Cfg.MaskDir = {};
handles.Cfg.WindowSize = 30;
handles.Cfg.WindowStep = 1;
handles.Cfg.WindowType = 'hamming';
handles.Cfg.IsDetrend = 1;
handles.Cfg.IsALFF = 1;
handles.Cfg.ALFF.ALowPass_HighCutoff=0.1;
handles.Cfg.ALFF.AHighPass_LowCutoff=0.01;
handles.Cfg.StartingDirForDCetc = {};
handles.Cfg.IsReHo = 1;
handles.Cfg.ReHo.Cluster = 27;
handles.Cfg.IsDC = 1;
handles.Cfg.DC.rThreshold = 0.25;
handles.Cfg.IsGSCorr = 1;
handles.Cfg.GSCorr.GlobalMask = 'Default';
handles.Cfg.GSCorr.GlobalMaskDir = [];
handles.Cfg.IsFC = 0;
handles.Cfg.CalFC.ROIDef = {};
handles.Cfg.CalFC.IsMultipleLabel = 0;
handles.Cfg.StartingDirForVMHC = {};
handles.Cfg.IsVMHC = 1;
handles.Cfg.ConcordanceMeasuresSelected = 'fALFF;ReHo;DC;GSCorr;VMHC'; %YAN Chao-Gan, 180704. Added flexibility for concordance
handles.Cfg.VoxelWiseConcordance = 1;
handles.Cfg.VolumeWiseConcordance = 1;
handles.Cfg.IsSmoothConcordance = 1; 
handles.Cfg.SmoothConcordance.FWHM = [4 4 4];
handles.Cfg.ParallelWorkersNumber = 0;
handles.Cfg.FunctionalSessionNumber = 1; 

% Refresh the UI
UpdateDisplay(handles);


uiwait(msgbox('Please cite: Yan CG, Yang Z, Colcombe S, Zuo XN, Milham MP (2017) Concordance among indices of intrinsic brain function: insights from inter-individual variation and temporal dynamics. Science Bulletin. 62: 1572-1584.'))



fprintf('\n\nDPABI Temporal Dynamic Analysis module is based on our previous work, please cite it if this module is used: \n');
fprintf('Yan CG, Yang Z, Colcombe S, Zuo XN, Milham MP (2017) Concordance among indices of intrinsic brain function: insights from inter-individual variation and temporal dynamics. Science Bulletin. 62: 1572-1584.\n');



% Make UI display correct in PC and linux
if ~ismac
    if ispc
        ZoonMatrix = [1 1 1.1 1.1];  %For pc
    else
        ZoonMatrix = [1 1 1.2 1.2];  %For Linux
    end
    UISize = get(handles.figDPABI_TDA,'Position');
    UISize = UISize.*ZoonMatrix;
    set(handles.figDPABI_TDA,'Position',UISize);
end
movegui(handles.figDPABI_TDA,'center');


% Choose default command line output for DPABI_TDA
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABI_TDA wait for user response (see UIRESUME)
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



function editTimePoints_Callback(hObject, eventdata, handles)
% hObject    handle to editTimePoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.Cfg.TR = str2num(get(handles.editTimePoints,'String'));
    guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editTimePoints as text
%        str2double(get(hObject,'String')) returns contents of editTimePoints as a double


% --- Executes during object creation, after setting all properties.
function editTimePoints_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTimePoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rbtnDefaultMask.
function rbtnDefaultMask_Callback(hObject, eventdata, handles)
% hObject    handle to rbtnDefaultMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.Cfg.MaskType = 'Default';
    set(handles.editMaskFile,'Enable','off');
    set(handles.editMaskFile,'String','Default Mask');
    set(handles.btnSelectMask,'Enable','off');
    guidata(hObject, handles);
    set(handles.rbtnDefaultMask, 'Value', 1);
    set(handles.rbtnNoMask, 'Value', 0);
    set(handles.rbtnUserMask, 'Value', 0);
    handles.Cfg.MaskDir = [];
    % drawnow
    
% Hint: get(hObject,'Value') returns toggle state of rbtnDefaultMask


% --- Executes on button press in rbtnNullMask.
function rbtnNoMask_Callback(hObject, eventdata, handles)
% hObject    handle to rbtnNullMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.Cfg.MaskType = 'NoMask';
    set(handles.editMaskFile,'Enable','off');
    set(handles.editMaskFile,'String','Don''t use mask');
    set(handles.btnSelectMask,'Enable','off');
    set(handles.rbtnDefaultMask, 'Value', 0);
    set(handles.rbtnNoMask, 'Value', 1);
    set(handles.rbtnUserMask, 'Value', 0);
    handles.Cfg.MaskDir = [];
    guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of rbtnNullMask


% --- Executes on button press in rbtnUserMask.
function rbtnUserMask_Callback(hObject, eventdata, handles)
% hObject    handle to rbtnUserMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.Cfg.MaskType = 'UserMask';
    set(handles.editMaskFile,'Enable','on');
    set(handles.editMaskFile,'String','');
    set(handles.btnSelectMask,'Enable','on');
    set(handles.rbtnDefaultMask, 'Value', 0);
    set(handles.rbtnNoMask, 'Value', 0);
    set(handles.rbtnUserMask, 'Value', 1);
    guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of rbtnUserMask



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



% --- Executes on button press in btnSelectMask.
function btnSelectMask_Callback(hObject, eventdata, handles)
% hObject    handle to btnSelectMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [MaskFileName,MaskPathName]=uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, 'Pick a mask');
    if ~([MaskFileName,MaskPathName]==0)
        handles.Cfg.MaskDir = [MaskPathName,MaskFileName];
        set(handles.editMaskFile,'String',[MaskPathName,MaskFileName]);
    end
    guidata(hObject, handles);
    




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
    handles.Cfg.IsDC = get(handles.checkboxDC,'Value');
    UpdateDisplay(handles);
    guidata(hObject,handles);
    
% Hint: get(hObject,'Value') returns toggle state of checkboxDC



function editrThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to editrThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.Cfg.DC.rThreshold = str2num(get(handles.editrThreshold,'String'));
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


% --- Executes on button press in rbtnGSDefaultMask.
function rbtnGSDefaultMask_Callback(hObject, eventdata, handles)
% hObject    handle to rbtnGSDefaultMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.rbtnGSDefaultMask, 'Value', 1);
    set(handles.rbtnGSUserMask, 'Value', 0);
    set(handles.editGSUserMask, 'Enable','off');
    set(handles.editGSUserMask, 'String', 'Default Mask');
    set(handles.btnGSSelectMask, 'Enable','off');
    handles.Cfg.GSCorr.GlobalMask = 'Default';
    guidata(hObject,handles);

% Hint: get(hObject,'Value') returns toggle state of rbtnGSDefaultMask


% --- Executes on button press in rbtnGSUserMask.
function rbtnGSUserMask_Callback(hObject, eventdata, handles)
% hObject    handle to rbtnGSUserMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.rbtnGSDefaultMask, 'Value', 0);
    set(handles.rbtnGSUserMask, 'Value', 1);
    set(handles.editGSUserMask, 'Enable','on');
    set(handles.editGSUserMask, 'String', '');
    set(handles.btnGSSelectMask, 'Enable','on');
    handles.Cfg.GSCorr.GlobalMask = 'UserMask';
    guidata(hObject,handles);
    
% Hint: get(hObject,'Value') returns toggle state of rbtnGSUserMask



function editGSUserMask_Callback(hObject, eventdata, handles)
% hObject    handle to editGSUserMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editGSUserMask as text
%        str2double(get(hObject,'String')) returns contents of editGSUserMask as a double


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
        handles.Cfg.GSCorr.GlobalMaskDir = [MaskPathName,MaskFileName];
        set(handles.editGSUserMask,'String',[MaskPathName,MaskFileName]);
    end
    handles.Cfg.GSCorr.GlobalMask = 'UserMask';
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

    ROIDef=handles.Cfg.CalFC.ROIDef;

    if isfield(handles.Cfg.CalFC,'ROISelectedIndex')
        ROISelectedIndex=handles.Cfg.CalFC.ROISelectedIndex;
    else
        ROISelectedIndex=cell(size(ROIDef));
    end

    if isempty(ROIDef)
        [ProgramPath, fileN, extn] = fileparts(which('DPARSFA_run.m'));
        addpath([ProgramPath,filesep,'SubGUIs']);
        [ROIDef,IsMultipleLabel]=DPARSF_ROI_Template(ROIDef,handles.Cfg.CalFC.IsMultipleLabel);
        handles.Cfg.CalFC.IsMultipleLabel = IsMultipleLabel;
        ROISelectedIndex=cell(size(ROIDef));
    end
    
    if handles.Cfg.CalFC.IsMultipleLabel
        fprintf('\nIsMultipleLabel is set to 1: There are multiple labels in the ROI mask file.\n');
    else
        fprintf('\nIsMultipleLabel is set to 0: All the non-zero values will be used to define the only ROI.\n');
    end
    
    ROIList.ROIDef=ROIDef;
    ROIList.ROISelectedIndex=ROISelectedIndex;
    ROIList.IsMultipleLabel=handles.Cfg.CalFC.IsMultipleLabel;

    ROIList=DPABI_ROIList(ROIList);

    handles.Cfg.CalFC.ROIDef=ROIList.ROIDef;
    handles.Cfg.CalFC.ROISelectedIndex=ROIList.ROISelectedIndex;
    handles.Cfg.CalFC.IsMultipleLabel=ROIList.IsMultipleLabel;
    guidata(hObject, handles);
    UpdateDisplay(handles);




function editStartingDirectoryForVMHC_Callback(hObject, eventdata, handles)
% hObject    handle to editStartingDirectoryForVMHC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.Cfg.StartingDirForVMHC = get(handles.editStartingDirectoryForVMHC,'String');
    guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of editStartingDirectoryForVMHC as text
%        str2double(get(hObject,'String')) returns contents of editStartingDirectoryForVMHC as a double


% --- Executes during object creation, after setting all properties.
function editStartingDirectoryForVMHC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStartingDirectoryForVMHC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxVMHC.
function checkboxVMHC_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxVMHC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.Cfg.IsVMHC = get(handles.checkboxVMHC,'Value');
    UpdateDisplay(handles);
    guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of checkboxVMHC



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


% --- Executes on button press in btnRun.
function btnRun_Callback(hObject, eventdata, handles)
% hObject    handle to btnRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Cfg=handles.Cfg; 
Datetime=fix(clock); 
save([handles.Cfg.WorkingDir,filesep,'DPABI_TDA_AutoSave_',num2str(Datetime(1)),'_',num2str(Datetime(2)),'_',num2str(Datetime(3)),'_',num2str(Datetime(4)),'_',num2str(Datetime(5)),'.mat'], 'Cfg'); %Added by YAN Chao-Gan, 100130.
DPABI_TDA_run(handles.Cfg);






% --- Executes on button press in checkboxVoxelWise.
function checkboxVoxelWise_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxVoxelWise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.Cfg.VoxelWiseConcordance = get(handles.checkboxVoxelWise,'Value');
    guidata(hObject, handles);
    
% Hint: get(hObject,'Value') returns toggle state of checkboxVoxelWise


% --- Executes on button press in checkboxVolumeWise.
function checkboxVolumeWise_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxVolumeWise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.Cfg.VolumeWiseConcordance = get(handles.checkboxVolumeWise,'Value');
    guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of checkboxVolumeWise


% --- Executes on button press in checkboxSmoothConcordance.
function checkboxSmoothConcordance_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSmoothConcordance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.Cfg.IsSmoothConcordance = get(handles.checkboxSmoothConcordance,'Value');
    UpdateDisplay(handles);
    guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of checkboxSmoothConcordance



function editSmoothConcordanceFWHM_Callback(hObject, eventdata, handles)
% hObject    handle to editSmoothConcordanceFWHM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    FWHM = get(handles.editSmoothConcordanceFWHM,'String');
    handles.Cfg.SmoothConcordance.FWHM =eval(['[',FWHM,']']);
    guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of editSmoothConcordanceFWHM as text
%        str2double(get(hObject,'String')) returns contents of editSmoothConcordanceFWHM as a double


% --- Executes during object creation, after setting all properties.
function editSmoothConcordanceFWHM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSmoothConcordanceFWHM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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

    set(handles.editTimePoints, 'String', num2str(handles.Cfg.TR));	
    
    switch lower(handles.Cfg.MaskType)
        case 'default'
            set(handles.rbtnDefaultMask, 'Value', 1);
            set(handles.rbtnNoMask, 'Value', 0);
            set(handles.rbtnUserMask, 'Value', 0); 
            set(handles.editMaskFile, 'Enable','off');
            set(handles.editMaskFile, 'String', 'Default Mask');
            set(handles.btnSelectMask, 'Enable','off');
        case 'nomask'
            set(handles.rbtnDefaultMask, 'Value', 0);
            set(handles.rbtnNoMask, 'Value', 1);
            set(handles.rbtnUserMask, 'Value', 0); 
            set(handles.editMaskFile, 'Enable','off');
            set(handles.editMaskFile, 'String', 'Don''t use Mask');
            set(handles.btnSelectMask, 'Enable','off'); 
        case 'usermask'
            set(handles.rbtnDefaultMask, 'Value', 0);
            set(handles.rbtnNoMask, 'Value', 0);
            set(handles.rbtnUserMask, 'Value', 1); 
            set(handles.editMaskFile, 'Enable','on');
            set(handles.editMaskFile, 'String', handles.Cfg.MaskDir);
            set(handles.btnSelectMask, 'Enable','on'); 
    end
       
            
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
    set(handles.checkboxALFFfALFF,'Value',handles.Cfg.IsALFF);
    set(handles.editBandLow,'String',num2str(handles.Cfg.ALFF.AHighPass_LowCutoff));
    set(handles.editBandHigh,'String',num2str(handles.Cfg.ALFF.ALowPass_HighCutoff));
    set(handles.editStartingDirectoryForReHoetc,'String',handles.Cfg.StartingDirForDCetc);
    set(handles.checkboxReHo,'Value',handles.Cfg.IsReHo);
    
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
    
    set(handles.checkboxDC,'Value',handles.Cfg.IsDC);
    set(handles.editrThreshold,'String',num2str(handles.Cfg.DC.rThreshold));
    set(handles.checkboxGSCorr,'Value',handles.Cfg.IsGSCorr);  
    set(handles.checkboxFC,'Value',handles.Cfg.IsFC);
    
    % define ROI
    
    set(handles.editStartingDirectoryForVMHC,'String',handles.Cfg.StartingDirForVMHC);
    set(handles.checkboxVMHC,'Value',handles.Cfg.IsVMHC);
    set(handles.checkboxVoxelWise,'Value',handles.Cfg.VoxelWiseConcordance);
    set(handles.checkboxVolumeWise,'Value',handles.Cfg.VolumeWiseConcordance);
    set(handles.checkboxSmoothConcordance,'Value',handles.Cfg.IsSmoothConcordance);
    set(handles.editSmoothConcordanceFWHM,'String',mat2str(handles.Cfg.SmoothConcordance.FWHM));
    set(handles.editParallelWorkers,'String',num2str(handles.Cfg.ParallelWorkersNumber));
    set(handles.editFunctionalSessions,'String',num2str(handles.Cfg.FunctionalSessionNumber));
    
    % Make uicontrols ubable if therr is no ALFF
    if get(handles.checkboxALFFfALFF,'Value')
        set(handles.textBand,'Enable','on');
        set(handles.editBandLow,'Enable','on');
        set(handles.textBand,'Enable','on');
        set(handles.editBandHigh,'Enable','on');
    else
        set(handles.textBand,'Enable','off');
        set(handles.editBandLow,'Enable','off');
        set(handles.textBand,'Enable','off');
        set(handles.editBandHigh,'Enable','off');
    end
    
    % Make uicontrols ubable if there is no ReHo
    if get(handles.checkboxReHo,'Value')
        set(handles.textReHoCluster,'Enable','on');
        set(handles.rbtnReHo7,'Enable','on');
        set(handles.rbtnReHo19,'Enable','on');
        set(handles.rbtnReHo27,'Enable','on');
    else
        set(handles.textReHoCluster,'Enable','off');
        set(handles.rbtnReHo7,'Enable','off');
        set(handles.rbtnReHo19,'Enable','off');
        set(handles.rbtnReHo27,'Enable','off');
    end
    
    % Make uicontrols ubable if there is no DC
    if get(handles.checkboxDC,'Value')
        set(handles.textrThreshold,'Enable','on');
        set(handles.editrThreshold,'Enable','on');
    else
        set(handles.textrThreshold,'Enable','off');
        set(handles.editrThreshold,'Enable','off');
    end
    
    % Make uicontrols ubable if there is no GSCorr
    if get(handles.checkboxGSCorr,'Value')
        set(handles.textGlobalMask,'Enable','on');
        set(handles.rbtnGSDefaultMask,'Enable','on');
        set(handles.rbtnGSUserMask,'Enable','on');
        switch lower(handles.Cfg.GSCorr.GlobalMask)
            case 'default'
                set(handles.rbtnGSDefaultMask, 'Value', 1);
                set(handles.rbtnGSUserMask, 'Value', 0);
                set(handles.editGSUserMask, 'Enable','off');
                set(handles.editGSUserMask, 'String', 'Default Mask');
                set(handles.btnGSSelectMask, 'Enable','off');
            case 'usermask'
                set(handles.rbtnGSDefaultMask, 'Value', 0);
                set(handles.rbtnGSUserMask, 'Value', 1);
                set(handles.editGSUserMask, 'Enable','on');
                set(handles.editGSUserMask, 'String',handles.Cfg.GSCorr.GlobalMaskDir);  
                set(handles.btnGSSelectMask, 'Enable','on');
        end
    else
        set(handles.textGlobalMask,'Enable','off');
        set(handles.rbtnGSDefaultMask,'Enable','off');
        set(handles.rbtnGSUserMask,'Enable','off');
        set(handles.editGSUserMask,'Enable','off');
        set(handles.btnGSSelectMask,'Enable','off');
    end
    
    % Make uicontrols ubable if there is no FC
    if get(handles.checkboxFC,'Value')
        set(handles.btnDefineROI,'Enable','on');
    else
        set(handles.btnDefineROI,'Enable','off');
    end 
    
    % Make uicontrols ubable if there is no concordance smooth
    if get(handles.checkboxSmoothConcordance,'Value')
        set(handles.editSmoothConcordanceFWHM,'Enable','on');
        set(handles.textSmoothConcordanceFWHM,'Enable','on');
    else
        set(handles.editSmoothConcordanceFWHM,'Enable','off');
        set(handles.textSmoothConcordanceFWHM,'Enable','off');
    end 

    
    
 
    
  

% --- Executes on button press in pushbuttonSelect.
function pushbuttonSelect_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Cfg.ConcordanceMeasuresSelected = DPABI_ConcordanceSelect({handles.Cfg.ConcordanceMeasuresSelected});

guidata(hObject, handles);
