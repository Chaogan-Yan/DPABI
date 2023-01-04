function varargout = DPABI_InputPreparer(varargin)
% DPABI_BIDS_Converter GUI by Bin Lu
%-----------------------------------------------------------
% Convert the output folder of DPABI_Dicomsorter or xnat-like system to DPARSFA/DPABISurf's input format.
% Copyright(c) 2021; GNU GENERAL PUBLIC LICENSE
% B108, CAS Key Laboratory of Behavioral Science, Institute of Psychology, Beijing, China; 
% Department of Psychology, University of Chinese Academy of Sciences, Beijing, China;
% Written by Bin Lu
% Modified by Bin Lu, 20220919. Be compatible to xnat-like input directory. Add option for setting lower limit for number of files of a series.
% Modified by Bin Lu, 20221224. Be compatible to DWI images. Combine Fun and FunOther module. 
% http://rfmri.org/dpabi
% $mail=larslu@foxmail.com
%-----------------------------------------------------------
% Mail to Author:  <a href="larslu@foxmail.com">Bin Lu</a> 

% Last Modified by GUIDE v2.5 12-Dec-2022 15:43:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABI_InputPreparer_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABI_InputPreparer_OutputFcn, ...
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


% --- Executes just before DPABI_InputPreparer is made visible.
function DPABI_InputPreparer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABI_InputPreparer (see VARARGIN)

%%% Important %%%
% If the most recommended pipeline template has been changed, the
% parameters in 'Call DPARSFA/DPABISurf' should be changed too!
%%% Important End %%%
if ismac
    handles.Cfg.nFileOperator = 3;
elseif isunix
    handles.Cfg.nFileOperator = 2;
else
    handles.Cfg.nFileOperator = 0;
end

handles.Cfg.OutputDir = pwd;
handles.Cfg.IsPseudoSeries = 1; % for some participants who lack one session 
% but have the others, we use a pseudo session to make it easy to process
% for DPARSFA or DPABISurf. e.g. Sub001 have T1Raw and FunRaw but don't
% have S2_FunRaw, while other subjects have two functional sessions. We
% would put a S2_FunRaw series from another subject into this subject, and
% mark Sub001 in the report.
handles.Cfg.IsDCM2NII = 1;
handles.Cfg.Demo.SeriesNamesDefault  = 'Please select an appropriate input directory.';
handles.Cfg.Demo.SeriesNames = {handles.Cfg.Demo.SeriesNamesDefault};
handles.Cfg.Demo.SubID = '';
handles.Cfg.Demo.PreviousSubID = '';
handles.Cfg.Demo.nChangeSub = 0;
handles.Cfg.IsChangeSubID = 0;  % Change default to 0, Bin Lu, 20220919
handles.Cfg.AlwaysLatterSeries = 0;
handles.Cfg.AnatOnly = 0;
handles.Cfg.IsOrganizeFun = 0;
handles.Cfg.IsOrganizeDwi = 0;
handles.Cfg.FunSessionNumber = 1;
handles.Cfg.SeriesName.T1 = '';
handles.Cfg.SeriesName.Dwi = '';
handles.Cfg.SeriesName.FunAll = {};
handles.Cfg.SeriesIndex.T1 = 1;
handles.Cfg.SeriesIndex.Dwi = 1;
handles.Cfg.SeriesIndex.FunAll = [1];
handles.Cfg.SeriesFileNumber.List.T1 = 0;
handles.Cfg.SeriesFileNumber.List.Dwi = 0;
handles.Cfg.SeriesFileNumber.List.FunAll = {0};
handles.Cfg.SeriesFileNumber.Flag.T1 = 1;
handles.Cfg.SeriesFileNumber.Flag.Dwi = 1;
handles.Cfg.SeriesFileNumber.Flag.FunAll = [1];
handles.Cfg.SeriesFileNumber.LowLimitMode.T1 = 0; % Add lower limit mode for setting number of files for a series, Bin Lu, 20220919
handles.Cfg.SeriesFileNumber.LowLimitMode.Dwi = 0;
handles.Cfg.SeriesFileNumber.LowLimitMode.FunAll = {0};
handles.Cfg.SeriesFileNumber.LowThreshold.T1 = 0; % Add lower threshold for setting number of files for a series, Bin Lu, 20220919
handles.Cfg.SeriesFileNumber.LowThreshold.Dwi = 0;
handles.Cfg.SeriesFileNumber.LowThreshold.FunAll = {0};
handles.Cfg.SeriesFileNumber.Percent.T1 = 0; % Record percentage of each type number of files for a series, Bin Lu, 20220919
handles.Cfg.SeriesFileNumber.Percent.Dwi = 0;
handles.Cfg.SeriesFileNumber.Percent.FunAll = {[0]};
handles.Cfg.SxFunRawList = {'FunRaw'};
handles.Cfg.SxFunRawFlag = 1;
handles.Cfg.SameSeriesName.Strategy = 1; % 1 - follow the series index; 2 - mannually choose always
handles.Cfg.SameSeriesName.SessionName1 = '';
handles.Cfg.SameSeriesName.SessionName2 = '';
handles.Cfg.SameSeriesName.SeriesName1 = '';
handles.Cfg.SameSeriesName.SeriesName2 = '';
handles.Cfg.SameSeriesName.Flag = 0;
handles.Cfg.ImageList.T1 = {};
handles.Cfg.ImageList.Dwi = {};
handles.Cfg.ImageList.FunAll = {};
handles.Cfg.ManuallySelect.SubName = {};
handles.Cfg.ManuallySelect.Series = {}; 

if isempty(varargin)
    handles.Cfg.WorkingDir = pwd;
    handles.Cfg.InputLayout = 1; % 1 - participant first, 2 - series first
    handles.Cfg.InputLayoutSelected = 0;
else
    handles.Cfg.WorkingDir=varargin{1};
    LayoutFlag = varargin{2};
    if LayoutFlag <5
        handles.Cfg.InputLayout = 1;
    else
        handles.Cfg.InputLayout = 2;
    end
    handles.Cfg.InputLayoutSelected = 1;
    set(handles.popupmenuInputLayout,'Value',handles.Cfg.InputLayout,'Enable','off');
    PickDemoSubject(hObject, handles)
    handles = guidata(hObject);
    ReadDataList(hObject,handles);
    handles = guidata(hObject);
    ShowDataList(hObject,handles);
    CheckFileOperatorNumber(hObject, handles);
    handles = guidata(hObject);
end

UpdateDisplay(handles)
% Choose default command line output for DPABI_InputPreparer
handles.output = hObject;


% Make UI display correct in PC and linux
if ismac
    ZoonMatrix = [1 1 1.7 1.1];  %For mac
elseif ispc
    ZoonMatrix = [1 1 1.6 0.9];  %For pc
else
    ZoonMatrix = [1 1 1.6 1];  %For Linux
end
UISize = get(handles.figureConvertDPABIFormat,'Position');
UISize = UISize.*ZoonMatrix;
set(handles.figureConvertDPABIFormat,'Position',UISize);
movegui(handles.figureConvertDPABIFormat,'center');


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABI_InputPreparer wait for user response (see UIRESUME)
% uiwait(handles.figureConvertDPABIFormat);


% --- Outputs from this function are returned to the command line.
function varargout = DPABI_InputPreparer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function editInputDir_Callback(hObject, eventdata, handles)
% hObject    handle to editInputDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.WorkingDir = get(handles.editInputDir,'String');
ResetCfg(hObject, handles, 1); % reset UI
handles = guidata(hObject);
UpdateDisplay(handles);
handles = guidata(hObject);
LayoutFlag=GuessLayout(hObject, handles);
if LayoutFlag ~= 0
    handles.Cfg.InputLayout = LayoutFlag;
end
set(handles.popupmenuInputLayout,'Value',handles.Cfg.InputLayout);
PickDemoSubject(hObject, handles)
handles = guidata(hObject);
ReadDataList(hObject,handles);
handles = guidata(hObject);
ShowDataList(hObject,handles);
CheckFileOperatorNumber(hObject, handles);
handles = guidata(hObject);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editInputDir as text
%        str2double(get(hObject,'String')) returns contents of editInputDir as a double


% --- Executes during object creation, after setting all properties.
function editInputDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editInputDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonInputDir.
function pushbuttonInputDir_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonInputDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=get(handles.editInputDir, 'String');
if ~isdir(Path)
    Path=pwd;
end
Path=uigetdir(Path);
if ~ischar(Path)
    return
end
set(handles.editInputDir, 'String', Path);
handles.Cfg.WorkingDir = get(handles.editInputDir,'String');
handles.Cfg.InputLayoutSelected = 0;
ResetCfg(hObject, handles, 1); % reset UI
handles = guidata(hObject);
UpdateDisplay(handles);
handles = guidata(hObject);
LayoutFlag=GuessLayout(hObject, handles);
if LayoutFlag ~= 0
    handles.Cfg.InputLayout = LayoutFlag;
end
set(handles.popupmenuInputLayout,'Value',handles.Cfg.InputLayout);
PickDemoSubject(hObject, handles)
handles = guidata(hObject);
ReadDataList(hObject,handles);
handles = guidata(hObject);
ShowDataList(hObject,handles);
CheckFileOperatorNumber(hObject, handles);
handles = guidata(hObject);
guidata(hObject,handles);


% --- Executes on selection change in popupmenuInputLayout.
function popupmenuInputLayout_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuInputLayout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.InputLayout = get(handles.popupmenuInputLayout,'Value');
handles.Cfg.InputLayoutSelected = 1;
ResetCfg(hObject, handles, 1);
handles = guidata(hObject);
PickDemoSubject(hObject, handles);
handles = guidata(hObject);
ReadDataList(hObject,handles);
handles = guidata(hObject);
ShowDataList(hObject,handles);
UpdateDisplay(handles);
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuInputLayout contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuInputLayout


% --- Executes during object creation, after setting all properties.
function popupmenuInputLayout_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuInputLayout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonChangeSubject.
function pushbuttonChangeSubject_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonChangeSubject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.Demo.nChangeSub  = handles.Cfg.Demo.nChangeSub + 1;
ResetCfg(hObject, handles, 1);
handles = guidata(hObject);
PickDemoSubject(hObject, handles);
handles = guidata(hObject);
ReadDataList(hObject,handles);
handles = guidata(hObject);
ShowDataList(hObject,handles);
UpdateDisplay(handles);
guidata(hObject,handles);

function editOutputDir_Callback(hObject, eventdata, handles)
% hObject    handle to editOutputDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.OutputDir = get(handles.editInputDir,'String');
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editOutputDir as text
%        str2double(get(hObject,'String')) returns contents of editOutputDir as a double


% --- Executes during object creation, after setting all properties.
function editOutputDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editOutputDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonOutputDir.
function pushbuttonOutputDir_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOutputDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=get(handles.editOutputDir, 'String');
if ~isdir(Path)
    Path=pwd;
end
Path=uigetdir(Path);
if ~ischar(Path)
    return
end
set(handles.editOutputDir, 'String', Path);
handles.Cfg.OutputDir = get(handles.editOutputDir,'String');
guidata(hObject,handles);


function editFunSessionNum_Callback(hObject, eventdata, handles)
% hObject    handle to editFunSessionNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.FunSessionNumber = str2num(get(handles.editFunSessionNum,'String'));
ResetCfg(hObject, handles, 2); 
handles = guidata(hObject);
UpdateDisplay(handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editFunSessionNum as text
%        str2double(get(hObject,'String')) returns contents of editFunSessionNum as a double


% --- Executes during object creation, after setting all properties.
function editFunSessionNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFunSessionNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuFunAll.
function popupmenuFunAllSession_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuFunAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuFunAll contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuFunAll


% --- Executes during object creation, after setting all properties.
function popupmenuFunAllSession_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuFunAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxIsPseudo.
function checkboxIsPseudo_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxIsPseudo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsPseudoSeries = get(handles.checkboxIsPseudo,'Value');
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxIsPseudo


% --- Executes on button press in checkboxDCM2NII.
function checkboxDCM2NII_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxDCM2NII (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsDCM2NII = get(handles.checkboxDCM2NII,'Value');
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxDCM2NII


% --- Executes on button press in pushbuttonRun.
function pushbuttonRun_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Begin to convert input directory into DPARSFA/DPABISurf starting directory format!')
disp([newline,'Checking data status ...'])

% Check whether to organize anatomical series only
if handles.Cfg.IsOrganizeDwi == 0 && handles.Cfg.IsOrganizeFun == 0
    handles.Cfg.AnatOnly = IsAnatOnly(handles.Cfg.AnatOnly);
    if handles.Cfg.AnatOnly == 0
        return
    end
end

% Check whether different sessions share the same series type
if handles.Cfg.AnatOnly == 0
    CheckSameSeriesName(hObject, handles);
    handles = guidata(hObject);
end

% Let user choose strategy for dealing with same series (e.g. follow scanning sequence or manually select every subject)
if handles.Cfg.SameSeriesName.Flag
    handles.Cfg.SameSeriesName=StrategyforSameSeriesName(handles.Cfg.SameSeriesName);
end

% Create final image list and copy files!
OrganizeImages(hObject, handles)
handles = guidata(hObject);

% Do dicom to nifit if needed
if handles.Cfg.IsDCM2NII
    DCM2NII(hObject, handles)
    handles = guidata(hObject);
end

% Write out conversion status
WriteCSV(hObject, handles);

set(handles.pushbuttonRun,'Enable','off','String','Finished');   
set(handles.pushbuttonCallDPARSFA,'Enable','on');%,'BackgroundColor',[154/256,255/256,154/256]
set(handles.pushbuttonCallDPABISurf,'Enable','on');%,'BackgroundColor',[154/256,255/256,154/256]

disp([newline, 'All the conversion is finished! You can directly call DPARSFA or DPABISurf in the pervious figure now!']);
guidata(hObject,handles);




% --- Executes on button press in pushbuttonCallDPARSFA.
function pushbuttonCallDPARSFA_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCallDPARSFA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[ProgramPath, fileN, extn] = fileparts(which('DPARSFA_run.m'));

load([ProgramPath,filesep,'Jobmats',filesep,'Template_V4_CalculateInMNISpace_Warp_DARTEL.mat']);

DPABIPath = fileparts(which('dpabi.m')); %YAN Chao-Gan, 151229. For set up ROIs, for the R-fMRI Project
Cfg.CalFC.ROIDef = {[DPABIPath,filesep,'Templates',filesep,'aal.nii'];...
    [DPABIPath,filesep,'Templates',filesep,'HarvardOxford-cort-maxprob-thr25-2mm_YCG.nii'];...
    [DPABIPath,filesep,'Templates',filesep,'HarvardOxford-sub-maxprob-thr25-2mm_YCG.nii'];...
    [DPABIPath,filesep,'Templates',filesep,'CC200ROI_tcorr05_2level_all.nii'];...
    [DPABIPath,filesep,'Templates',filesep,'Zalesky_980_parcellated_compact.nii'];...
    [DPABIPath,filesep,'Templates',filesep,'Dosenbach_Science_160ROIs_Radius5_Mask.nii'];...
    [DPABIPath,filesep,'Templates',filesep,'BrainMask_05_91x109x91.img'];... %YAN Chao-Gan, 161201. Add global signal.
    [DPABIPath,filesep,'Templates',filesep,'Power_Neuron_264ROIs_Radius5_Mask.nii'];... %YAN Chao-Gan, 170104. Add Power 264.
    [DPABIPath,filesep,'Templates',filesep,'Schaefer2018_400Parcels_7Networks_order_FSLMNI152_1mm.nii'];... %YAN Chao-Gan, 180824. Add Schaefer 400.
    [DPABIPath,filesep,'Templates',filesep,'Tian2020_Subcortex_Atlas',filesep,'Tian_Subcortex_S4_3T.nii']}; %YAN Chao-Gan, 210414. Add Tian2020_Subcortex_Atlas.
Cfg.CalFC.IsMultipleLabel = 1;

Cfg.WorkingDir = handles.Cfg.OutputDir;
Cfg.IsNeedConvertDwiDCM2IMG = ~handles.Cfg.IsDCM2NII;
Cfg.IsNeedConvertT1DCM2IMG = ~handles.Cfg.IsDCM2NII;
Cfg.FunctionalSessionNumber = handles.Cfg.FunSessionNumber;
if handles.Cfg.IsDCM2NII
    Cfg.StartingDirName = 'FunImg';
    SubList = dir([handles.Cfg.OutputDir,filesep,'FunImg']);
else
    Cfg.StartingDirName = 'FunRaw';
    SubList = dir([handles.Cfg.OutputDir,filesep,'FunRaw']);
end

Index=cellfun(...
    @(IsDir, NotDot) IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')), ...
    {SubList.isdir}, {SubList.name});
SubList=SubList(Index);
Cfg.SubjectID={SubList(:).name}';
DPARSFA(Cfg)

% --- Executes on button press in pushbuttonCallDPABISurf.
function pushbuttonCallDPABISurf_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCallDPABISurf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.DPABIPath = fileparts(which('dpabi.m')); 

load(fullfile(handles.Cfg.DPABIPath, 'DPABISurf', 'Jobmats','Template_Default.mat'))
Cfg.MaskFileSurfLH = fullfile(handles.Cfg.DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_lh_cortex.label.gii');
Cfg.MaskFileSurfRH = fullfile(handles.Cfg.DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_rh_cortex.label.gii');
Cfg.MaskFileVolu = fullfile(handles.Cfg.DPABIPath, 'Templates','BrainMask_05_91x109x91.img');
Cfg.SurfFileLH = fullfile(handles.Cfg.DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_lh_white.surf.gii');
Cfg.SurfFileRH = fullfile(handles.Cfg.DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_rh_white.surf.gii');
Cfg.CalFC.ROIDefSurfLH = {fullfile(handles.Cfg.DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_lh_HCP-MMP1.label.gii');...
    fullfile(handles.Cfg.DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_lh_Schaefer2018_400Parcels_7Networks_order.label.gii')};
Cfg.CalFC.ROIDefSurfRH = {fullfile(handles.Cfg.DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_rh_HCP-MMP1.label.gii');...
    fullfile(handles.Cfg.DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_rh_Schaefer2018_400Parcels_7Networks_order.label.gii')};
Cfg.CalFC.ROIDefVolu = {[handles.Cfg.DPABIPath,filesep,'Templates',filesep,'aal.nii'];...
    [handles.Cfg.DPABIPath,filesep,'Templates',filesep,'HarvardOxford-cort-maxprob-thr25-2mm_YCG.nii'];...
    [handles.Cfg.DPABIPath,filesep,'Templates',filesep,'HarvardOxford-sub-maxprob-thr25-2mm_YCG.nii'];...
    [handles.Cfg.DPABIPath,filesep,'Templates',filesep,'CC200ROI_tcorr05_2level_all.nii'];...
    [handles.Cfg.DPABIPath,filesep,'Templates',filesep,'Zalesky_980_parcellated_compact.nii'];...
    [handles.Cfg.DPABIPath,filesep,'Templates',filesep,'Dosenbach_Science_160ROIs_Radius5_Mask.nii'];...
    [handles.Cfg.DPABIPath,filesep,'Templates',filesep,'BrainMask_05_91x109x91.img'];... %YAN Chao-Gan, 161201. Add global signal.
    [handles.Cfg.DPABIPath,filesep,'Templates',filesep,'Power_Neuron_264ROIs_Radius5_Mask.nii'];... %YAN Chao-Gan, 170104. Add Power 264.
    [handles.Cfg.DPABIPath,filesep,'Templates',filesep,'Schaefer2018_400Parcels_7Networks_order_FSLMNI152_1mm.nii'];... %YAN Chao-Gan, 180824. Add Schaefer 400.
    [handles.Cfg.DPABIPath,filesep,'Templates',filesep,'Tian2020_Subcortex_Atlas',filesep,'Tian_Subcortex_S4_3T_2009cAsym.nii']}; %YAN Chao-Gan, 210414. Add Tian2020_Subcortex_Atlas.




Cfg.WorkingDir = handles.Cfg.OutputDir;
Cfg.IsNeedConvertDwiDCM2IMG = ~handles.Cfg.IsDCM2NII;
Cfg.IsNeedConvertT1DCM2IMG = ~handles.Cfg.IsDCM2NII;
Cfg.FunctionalSessionNumber = handles.Cfg.FunSessionNumber;
if handles.Cfg.IsDCM2NII
    Cfg.StartingDirName = 'FunImg';
    SubList = dir([handles.Cfg.OutputDir,filesep,'FunImg']);
else
    Cfg.StartingDirName = 'FunRaw';
    SubList = dir([handles.Cfg.OutputDir,filesep,'FunRaw']);
end

Index=cellfun(...
    @(IsDir, NotDot) IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')), ...
    {SubList.isdir}, {SubList.name});
SubList=SubList(Index);
Cfg.SubjectID={SubList(:).name}';

DPABISurf_Pipeline(Cfg);


% --- Executes on selection change in popupmenuFunAllFileNumber.
function popupmenuFunAllFileNumber_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuFunAllFileNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SessionFlag = handles.Cfg.SxFunRawFlag;
handles.Cfg.SeriesFileNumber.Flag.FunAll(SessionFlag) = get(handles.popupmenuFunAllFileNumber,'Value');
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuFunAllFileNumber contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuFunAllFileNumber


% --- Executes during object creation, after setting all properties.
function popupmenuFunAllFileNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuFunAllFileNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuDwiFileNumber.
function popupmenuDwiFileNumber_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuDwiFileNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.SeriesFileNumber.Flag.Dwi = get(handles.popupmenuDwiFileNumber,'Value');
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuDwiFileNumber contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuDwiFileNumber


% --- Executes during object creation, after setting all properties.
function popupmenuDwiFileNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuDwiFileNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuT1FileNumber.
function popupmenuT1FileNumber_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuT1FileNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.SeriesFileNumber.Flag.T1 = get(handles.popupmenuT1FileNumber,'Value');
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuT1FileNumber contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuT1FileNumber


% --- Executes during object creation, after setting all properties.
function popupmenuT1FileNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuT1FileNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxIsOrganizeFun.
function checkboxIsOrganizeFun_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxIsOrganizeFun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsOrganizeFun = get(handles.checkboxIsOrganizeFun,'Value');
UpdateDisplay(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxIsOrganizeFun


% --- Executes on selection change in popupmenuSxFunRaw.
function popupmenuSxFunRaw_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSxFunRaw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.SxFunRawFlag = get(handles.popupmenuSxFunRaw,'Value');
UpdateDisplay(handles);
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSxFunRaw contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSxFunRaw


% --- Executes during object creation, after setting all properties.
function popupmenuSxFunRaw_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSxFunRaw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuFunAll.
function popupmenuFunAll_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuFunAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SessionFlag = handles.Cfg.SxFunRawFlag;
handles.Cfg.SeriesIndex.FunAll(SessionFlag) = get(handles.popupmenuFunAll,'Value');
handles.Cfg.SeriesName.FunAll{SessionFlag} = handles.Cfg.Demo.SeriesNames{handles.Cfg.SeriesIndex.FunAll(SessionFlag)};
set(handles.popupmenuFunAllFileNumber,'String','Computing...');
drawnow;
[handles.Cfg.SeriesFileNumber.List.FunAll{SessionFlag},Percentage] = CheckFileNumber(hObject, handles,handles.Cfg.SeriesIndex.FunAll(SessionFlag));
handles.Cfg.SeriesFileNumber.Flag.FunAll(SessionFlag) = 1;
handles.Cfg.SeriesFileNumber.Percent.FunAll{SessionFlag} = Percentage;
% Added 20210722, add percentage info to reduce wrong selections
DisplayString = cellfun(@(Num,Per) sprintf('%d (%.0f%%)',Num,Per*100),num2cell(handles.Cfg.SeriesFileNumber.List.FunAll{SessionFlag}),num2cell(Percentage),'UniformOutput',false);
set(handles.popupmenuFunAllFileNumber,...
    'String',DisplayString,...
    'Value',handles.Cfg.SeriesFileNumber.Flag.FunAll(SessionFlag),...
    'Enable','on');
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuFunAll contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuFunAll


% --- Executes during object creation, after setting all properties.
function popupmenuFunAll_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuFunAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuDwi.
function popupmenuDwi_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuDwi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.SeriesIndex.Dwi = get(handles.popupmenuDwi,'Value');
set(handles.popupmenuDwiFileNumber,'String','Computing...');
drawnow;
handles.Cfg.SeriesName.Dwi = handles.Cfg.Demo.SeriesNames{handles.Cfg.SeriesIndex.Dwi};
[handles.Cfg.SeriesFileNumber.List.Dwi,Percentage] = CheckFileNumber(hObject, handles,handles.Cfg.SeriesIndex.Dwi);
handles.Cfg.SeriesFileNumber.Flag.Dwi = 1;
handles.Cfg.SeriesFileNumber.Percent.Dwi = Percentage;
% Added 20210722, add percentage info to reduce wrong selections
DisplayString = cellfun(@(Num,Per) sprintf('%d (%.0f%%)',Num,Per*100),num2cell(handles.Cfg.SeriesFileNumber.List.Dwi),num2cell(Percentage),'UniformOutput',false);
set(handles.popupmenuDwiFileNumber,...
    'String',DisplayString,...
    'Value',handles.Cfg.SeriesFileNumber.Flag.Dwi,...
    'Enable','on');
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuDwi contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuDwi


% --- Executes during object creation, after setting all properties.
function popupmenuDwi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuDwi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuT1.
function popupmenuT1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuT1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.SeriesIndex.T1 = get(handles.popupmenuT1,'Value');
set(handles.popupmenuT1FileNumber,'String','Computing...'); 
drawnow;
handles.Cfg.SeriesName.T1 = handles.Cfg.Demo.SeriesNames{handles.Cfg.SeriesIndex.T1};
[handles.Cfg.SeriesFileNumber.List.T1,Percentage] = CheckFileNumber(hObject, handles,handles.Cfg.SeriesIndex.T1);
handles.Cfg.SeriesFileNumber.Flag.T1 = 1;
handles.Cfg.SeriesFileNumber.Percent.T1 = Percentage;
% Added 20210722, add percentage info to reduce wrong selections
DisplayString = cellfun(@(Num,Per) sprintf('%d (%.0f%%)',Num,Per*100),num2cell(handles.Cfg.SeriesFileNumber.List.T1),num2cell(Percentage),'UniformOutput',false);
set(handles.popupmenuT1FileNumber,...
    'String',DisplayString,...
    'Value',handles.Cfg.SeriesFileNumber.Flag.T1,...
    'Enable','on');
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuT1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuT1


% --- Executes during object creation, after setting all properties.
function popupmenuT1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuT1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxIsChangeSubID.
function checkboxIsChangeSubID_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxIsChangeSubID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsChangeSubID = get(handles.checkboxIsChangeSubID,'Value');
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxIsChangeSubID



function ReadDataList(hObject, handles)
if handles.Cfg.InputLayout == 1
    if ~isempty(handles.Cfg.Demo.SubID)
        Name = handles.Cfg.Demo.SubID;
    else
        handles.Cfg.Demo.SeriesNames = {'Series not found!'};
        return
    end
    SeriesStruct=dir([handles.Cfg.WorkingDir,filesep,Name]);
    
else
    SeriesStruct=dir(handles.Cfg.WorkingDir);
end
Index=cellfun(...
    @(IsDir, NotDot) IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')), ...
    {SeriesStruct.isdir}, {SeriesStruct.name});
SeriesStruct=SeriesStruct(Index);
SeriesString={SeriesStruct(:).name}';
SeriesString=['Please select: ...';SeriesString]; % Add a prompt in case of user skipping selection!
handles.Cfg.Demo.SeriesNames = SeriesString;
guidata(hObject,handles);



function ShowDataList(hObject,handles)
%Create by Sandy to get the Subject List
%Edited by Bin to split display fuction and handle.Cfg assignment
SeriesString=handles.Cfg.Demo.SeriesNames;
Flag = handles.Cfg.SxFunRawFlag ;
if ~iscell(SeriesString) || isempty(SeriesString)
    set(handles.popupmenuT1, 'String', 'Series not found!', 'Value', 1);
    set(handles.popupmenuDwi, 'String', 'Series not found!', 'Value', 1);
    set(handles.popupmenuFunAll, 'String', 'Series not found!', 'Value', 1);
else
    set(handles.popupmenuT1, 'String', SeriesString,'Value',handles.Cfg.SeriesIndex.T1);
    set(handles.popupmenuDwi, 'String', SeriesString,'Value',handles.Cfg.SeriesIndex.Dwi);
    set(handles.popupmenuFunAll, 'String', SeriesString,'Value',handles.Cfg.SeriesIndex.FunAll(Flag));
end



function [nFiles,Percentage] = CheckFileNumber(hObject, handles, SeriesIndex)
%% Check the number of files for the selected MR series, for further avoiding include series not intact
% SeriesIndex - The index of series in handles.Cfg.Demo.SeriesNames 
SeriesName = handles.Cfg.Demo.SeriesNames{SeriesIndex};
JavaFlag = 1;
if isempty(SeriesName) || strcmp(SeriesName,handles.Cfg.Demo.SeriesNamesDefault)
    nFiles = [0];
    return
else
    % For data from DPABI_DicomSorter, the index should be removed here to match more series
    Index = strfind(SeriesName,'_');
    %     if (~isempty(Index) && ~isnan(str2double(SeriesName(1:Index(1)-1))) && Index(1) == 5) || ... % Is so, the working dir was derived from DPABI_DicomSorter, series number should be removed.
    if ~isempty(Index) && ~isnan(str2double(SeriesName(1:Index(1)-1))) % Revised 20210511, for output dir of xnat-like system
        SeriesName = SeriesName(Index(1)+1:end);
    end
    if handles.Cfg.InputLayout==1 % Participant first
        SubList = dir(handles.Cfg.WorkingDir);
        Index=cellfun(...
            @(IsDir, NotDot) IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')), ...
            {SubList.isdir}, {SubList.name});
        SubList=SubList(Index);
        SubString={SubList(:).name}';
        SeriesList = cellfun(@(Sub) dir([handles.Cfg.WorkingDir,filesep,Sub,filesep,'*',SeriesName]),SubString,'UniformOutput',0);
        SeriesString = cellfun(@(Series) {Series(:).name},SeriesList,'UniformOutput',0); %nSub*1 cell, mSeries in each cell
        % SeriesString = vertcat(SeriesString{:});  % Cannot deal with cell with different columns. 
        MaxColumn = max(cellfun('length', SeriesString));  % get the number of columns of the widest cell
        SeriesString = cellfun(@(OneSeriesString) [OneSeriesString, repmat({'padding'},1,MaxColumn-length(OneSeriesString))], SeriesString, 'UniformOutput', false); % pad each cell.
        SeriesString = vertcat(SeriesString{:}); % Thanks to Guillaume, convert to nSub*mSeries cell;
        SubString = repmat(SubString,1,size(SeriesString,2));
        try % Revised 20210511, use Java function to increase speed.
            nFileList = cellfun(@(Sub,Series) length(java.io.File([handles.Cfg.WorkingDir,filesep,Sub,filesep,Series]).listFiles),SubString,SeriesString,'UniformOutput',0);
        catch
            disp('Checking number of files for series, might be a little bit slow...')
            JavaFlag = 0;
            nFileList = cellfun(@(Sub,Series) length(dir([handles.Cfg.WorkingDir,filesep,Sub,filesep,Series])),SubString,SeriesString,'UniformOutput',0);
        end
    else % Series first
        % There are probably more than one series share same name, like DTI or repeated scanning of resting state
        SeriesList = dir([handles.Cfg.WorkingDir]);
        Index=cellfun(...
            @(IsDir, Series) IsDir && contains(Series, SeriesName,'IgnoreCase',true), {SeriesList.isdir}, {SeriesList.name});
        SeriesList=SeriesList(Index);
        SeriesString={SeriesList(:).name}';
        SubList = cellfun(@(Series)  dir([handles.Cfg.WorkingDir,filesep,Series]),SeriesString,'UniformOutput',0);
        SubString = cellfun(@(Sub) {Sub(:).name},SubList,'UniformOutput',0); %nSeries*1 cell, mSubject in each cell
        MaxColumn = max(cellfun('length', SubString));  % get the number of columns of the widest cell
        SubString = cellfun(@(OneSubString) [OneSubString, repmat({'padding'},1,MaxColumn-length(OneSubString))], SubString, 'UniformOutput', false); % pad each cell.
        SubString = vertcat(SubString{:}); % Thanks to Guillaume, convert to nSub*mSeries cell;
        SeriesString = repmat(SeriesString,1,size(SubString,2));
        try % Revised 20210511, use Java function to increase speed.
            nFileList = cellfun(@(Sub,Series) length(java.io.File([handles.Cfg.WorkingDir,filesep,Series,filesep,Sub]).listFiles),SubString,SeriesString,'UniformOutput',0);
        catch
            disp('Checking number of files for series, might be a little bit slow...')
            JavaFlag = 0;
            nFileList = cellfun(@(Sub,Series) length(dir([handles.Cfg.WorkingDir,filesep,Series,filesep,Sub])),SubString,SeriesString,'UniformOutput',0);
        end
    end    
    nFileUnique = unique([nFileList{:}]);
    nFileUnique(find(nFileUnique==0)) = [];
    % Added 20210722, add percentage info to reduce wrong selections
    SeriesTotalNumber = length(find([nFileList{:}]));
    for iNum = 1:length(nFileUnique)
        Percentage(iNum,1) = length(find([nFileList{:}]==nFileUnique(iNum)))/SeriesTotalNumber;
    end
    [Percentage,Index] = sort(Percentage,'descend');
    nFileUnique = nFileUnique(Index);
    if JavaFlag == 0
        nFiles = (nFileUnique-handles.Cfg.nFileOperator)';
    else
        nFiles = nFileUnique';
    end
end



function PickDemoSubject(hObject, handles)
%% Pick up one demo subject for demostrating MR series demo
if handles.Cfg.InputLayout == 1 % Participant first
    SubList = dir(handles.Cfg.WorkingDir);
else % Series first
    SeriesList = dir([handles.Cfg.WorkingDir,filesep,'*T1*']);
    if isempty(SeriesList)
        SeriesList = dir([handles.Cfg.WorkingDir]);
    end
    Index=cellfun(...
        @(IsDir, NotDot) IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')), ...
        {SeriesList.isdir}, {SeriesList.name});
    SeriesList=SeriesList(Index);
    SeriesString={SeriesList(:).name}';
    SubList = dir([handles.Cfg.WorkingDir,filesep,SeriesString{1}]);
end

if isempty(SubList)
    return
else
    Index=cellfun(...
        @(IsDir, NotDot) IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')), ...
        {SubList.isdir}, {SubList.name});
    SubList=SubList(Index);
    SubString={SubList(:).name}';
    if handles.Cfg.Demo.nChangeSub == 0
        handles.Cfg.Demo.SubID = SubString{1};
    else
        NewSubject = SubString{randi(length(SubString))};
        while strcmp(handles.Cfg.Demo.PreviousSubID,NewSubject)
            NewSubject = SubString{randi(length(SubString))};
        end
        handles.Cfg.Demo.PreviousSubID = handles.Cfg.Demo.SubID;
        handles.Cfg.Demo.SubID = NewSubject;
    end
    guidata(hObject,handles);
end



function LayoutFlag=GuessLayout(hObject, handles)
%% Guess the input folder layout for mininizing the error chance 
Keywords = {'t1','t2','bold','rest','task','mprage','fspgr',...
    'fmri','dti','dwi','diffuse','diffusion','3D'};
nKeyword = length(Keywords);
if handles.Cfg.InputLayoutSelected == 1
    LayoutFlag = 0;
    return
end
try
    if ~isempty(handles.Cfg.WorkingDir)
        FileList1 = dir(handles.Cfg.WorkingDir);
        Index=cellfun(...
            @(IsDir, NotDot) IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')), ...
            {FileList1.isdir}, {FileList1.name});
        FileList1=FileList1(Index);
        FileString1={FileList1(:).name}';
        if ~isempty(FileString1)
            FileList2 = dir([handles.Cfg.WorkingDir,filesep,FileString1{1}]);
            Index=cellfun(...
                @(IsDir, NotDot) IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')), ...
                {FileList2.isdir}, {FileList2.name});
            FileList2=FileList2(Index);
            FileString2={FileList2(:).name}';
            % Calculate which layer of file contains more MR series key words.
            FileString1_Rep = repmat(FileString1,1,nKeyword);
            FileString2_Rep = repmat(FileString2,1,nKeyword);
            Keywords1_Rep = repmat(Keywords,length(FileString1),1);
            Keywords2_Rep = repmat(Keywords,length(FileString2),1);
            KeywordCount1 = cellfun(@(Keyword, File) contains(File,Keyword,'IgnoreCase',true),Keywords1_Rep,FileString1_Rep);
            KeywordCount2 = cellfun(@(Keyword, File) contains(File,Keyword,'IgnoreCase',true),Keywords2_Rep,FileString2_Rep);
            KeywordCount1 = reshape(KeywordCount1,1,[]);
            KeywordCount2 = reshape(KeywordCount2,1,[]);
            KeywordRatio1 = sum(KeywordCount1)/length(KeywordCount1);
            KeywordRatio2 = sum(KeywordCount2)/length(KeywordCount2);
            if KeywordRatio1 > KeywordRatio2
                LayoutFlag = 2;
            else
                LayoutFlag = 1;
            end
        else
            LayoutFlag = 0;
            return
        end
    end
catch
    LayoutFlag = 0;
    return
end



function ResetCfg(hObject, handles, Flag)
%% Reset the most of the configurations for certain user activations
% Flag - 1: Reset all settings in T1Raw, FunRaw and other functional sessions. e.g. Changing Layout, Changing Demo Subject.
%      - 2: Reset all settings in functional sessions e.g. Changing number of functional series.
switch Flag 
    case 1
        handles.Cfg.Demo.SeriesNames = {handles.Cfg.Demo.SeriesNamesDefault};
        handles.Cfg.Demo.PreviousSubID = handles.Cfg.Demo.SubID;
        handles.Cfg.Demo.SubID = '';
        handles.Cfg.IsOrganizeFun = 0;
        handles.Cfg.IsOrganizeDwi = 0;
        handles.Cfg.FunSessionNumber = 1;
        handles.Cfg.SeriesName.T1 = '';
        handles.Cfg.SeriesName.Dwi = '';
        handles.Cfg.SeriesName.FunAll = {};
        handles.Cfg.SeriesIndex.T1 = 1;
        handles.Cfg.SeriesIndex.Dwi = 1;
        handles.Cfg.SeriesIndex.FunAll = [1];
        handles.Cfg.SeriesFileNumber.List.T1 = 0;
        handles.Cfg.SeriesFileNumber.List.Dwi = 0;
        handles.Cfg.SeriesFileNumber.List.FunAll = {0};
        handles.Cfg.SeriesFileNumber.Flag.T1 = 1;
        handles.Cfg.SeriesFileNumber.Flag.Dwi = 1;
        handles.Cfg.SeriesFileNumber.Flag.FunAll = [1];
        handles.Cfg.SeriesFileNumber.LowLimitMode.T1 = 0; % Add lower limit mode for setting number of files for a series, Bin Lu, 20220919
        handles.Cfg.SeriesFileNumber.LowLimitMode.Dwi = 0;
        handles.Cfg.SeriesFileNumber.LowLimitMode.FunAll = {0};
        handles.Cfg.SeriesFileNumber.LowThreshold.T1 = 0;
        handles.Cfg.SeriesFileNumber.LowThreshold.Dwi = 0;
        handles.Cfg.SeriesFileNumber.LowThreshold.FunAll = {0};
        handles.Cfg.SeriesFileNumber.Percent.T1 = 0;
        handles.Cfg.SeriesFileNumber.Percent.Dwi = 0;
        handles.Cfg.SeriesFileNumber.Percent.FunAll = {[0]};
        handles.Cfg.SxFunRawList = {'FunRaw'};
        handles.Cfg.SxFunRawFlag = 1;
    case 2
        handles.Cfg.SxFunRawList = cell(1,handles.Cfg.FunSessionNumber);
        for iSession = 1:handles.Cfg.FunSessionNumber
            if iSession == 1
                handles.Cfg.SxFunRawList{iSession} = 'FunRaw';
            else
                handles.Cfg.SxFunRawList{iSession} = ['S',num2str(iSession),'_FunRaw'];
            end
        end
        handles.Cfg.SeriesName.FunAll = {};
        handles.Cfg.SeriesIndex.FunAll = ones(handles.Cfg.FunSessionNumber,1);
        handles.Cfg.SeriesFileNumber.List.FunAll = cell(1,handles.Cfg.FunSessionNumber);
        handles.Cfg.SeriesFileNumber.List.FunAll(:) = {[0]};
        handles.Cfg.SeriesFileNumber.LowLimitMode.FunAll = cell(1,handles.Cfg.FunSessionNumber);
        handles.Cfg.SeriesFileNumber.LowLimitMode.FunAll(:) = {[0]};
        handles.Cfg.SeriesFileNumber.LowThreshold.FunAll = cell(1,handles.Cfg.FunSessionNumber);
        handles.Cfg.SeriesFileNumber.LowThreshold.FunAll(:) = {[0]};
        handles.Cfg.SeriesFileNumber.Flag.FunAll = ones(handles.Cfg.FunSessionNumber,1);
        handles.Cfg.SeriesFileNumber.Percent.FunAll = cell(1,handles.Cfg.FunSessionNumber);
        handles.Cfg.SeriesFileNumber.Percent.FunAll(:) = {[0]};
        handles.Cfg.SxFunRawFlag = 1;
end
guidata(hObject,handles);



function CheckSameSeriesName(hObject, handles)
%% Check the selected series for different sessions with same series name (e.g. 0001_Resting_240, 0009_Resting_240)
Series = handles.Cfg.SeriesName.FunAll;
% For data from DPABI_DicomSorter, the index should be removed here to match more series
Index = strfind(Series{1},'_');
% if ~isempty(Index) && ~isnan(str2double(Series{1}(1:Index(1)-1))) && Index(1) == 5 %% Is so, the working dir was derived from DPABI_DicomSorter, series number should be removed.
if ~isempty(Index) && ~isnan(str2double(Series{1}(1:Index(1)-1))) %% For xnat-like output series name. Bin Lu. 20221212.
    Series = cellfun(@(Series) Series(Index(1)+1:end),Series,'UniformOutput',0);
end

Sessions = {'FunRaw'};
for iSession = 2:handles.Cfg.FunSessionNumber
    Sessions = [Sessions,{['S',num2str(iSession),'_FunRaw']}];
end

handles.Cfg.SameSeriesName.FlagMatrix = zeros(length(Series),length(Series));
handles.Cfg.SameSeriesName.SessionMatrix = cell(length(Series));
handles.Cfg.SameSeriesName.Flag = 0;
for i = 1:length(Series)
    for j = 1:length(Series)
        handles.Cfg.SameSeriesName.SessionMatrix{i,j} = Sessions{j};
        if strcmp(Series{i},Series{j})
            handles.Cfg.SameSeriesName.FlagMatrix(i,j) = 1;
            if i~=j
                handles.Cfg.SameSeriesName.SessionName1 = Sessions{i};
                handles.Cfg.SameSeriesName.SessionName2 = Sessions{j};
                handles.Cfg.SameSeriesName.SeriesName1 = Series{i};
                handles.Cfg.SameSeriesName.SeriesName2 = Series{j};
                handles.Cfg.SameSeriesName.Flag = 1;
                handles.Cfg.SameSeriesName.FlagMatrix(i,j) = 1;
            end
        end
    end
end
guidata(hObject,handles);



function OrganizeImages(hObject, handles)
%% Create MR image list for copying files to T1Raw, FunRaw, DwiRaw ...
% Confirm MR series for all sessions have been allocated
AnatMiss = isempty(handles.Cfg.SeriesName.T1);

if handles.Cfg.IsOrganizeDwi == 1 
    DwiMiss = isempty(handles.Cfg.SeriesName.Dwi);
else
    DwiMiss = 0;
end

if handles.Cfg.IsOrganizeFun == 1 
    FunAllMiss = cellfun(@isempty,handles.Cfg.SeriesName.FunAll);
    FunAllMiss = sum(FunAllMiss);
else
    FunAllMiss = 0;
end

if AnatMiss || DwiMiss || FunAllMiss
    uiwait(msgbox({'Some sessions have not been determined, please select MR Series before run'},'Please select MR Series before run!'));
end

%% For data from DPABI_DicomSorter and xnat-like system, the index should be removed here to match more series
Index = strfind(handles.Cfg.SeriesName.T1,'_');
if ~isempty(Index) && ~isnan(str2double(handles.Cfg.SeriesName.T1(1:Index(1)-1)))%% Is so, the working dir was derived from DPABI_DicomSorter or xnat-like system, series number should be removed.
    SeriesT1 = handles.Cfg.SeriesName.T1(Index(1)+1:end);
    if ~handles.Cfg.AnatOnly
        if handles.Cfg.IsOrganizeDwi
            SeriesDwi = handles.Cfg.SeriesName.Dwi(Index(1)+1:end);
        end
        if handles.Cfg.IsOrganizeFun
            SeriesFunAll = cellfun(@(Series) Series(Index(1)+1:end),handles.Cfg.SeriesName.FunAll,'UniformOutput',0);
        end
    end
else
    SeriesT1 = handles.Cfg.SeriesName.T1;
    if ~handles.Cfg.AnatOnly
        if handles.Cfg.IsOrganizeDwi
            SeriesDwi = handles.Cfg.SeriesName.Dwi;
        end
        if handles.Cfg.IsOrganizeFun
            SeriesFunAll = handles.Cfg.SeriesName.FunAll;
        end
    end
end

%% Create image list without considering the number of files (e.g. whether the series is intact) in each series
if handles.Cfg.InputLayout == 1 % Participant first
    SubList = dir(handles.Cfg.WorkingDir);
    Index=cellfun(...
        @(IsDir, NotDot) IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')), ...
        {SubList.isdir}, {SubList.name});
    SubList=SubList(Index);
    SubString={SubList(:).name}';
    T1List = cellfun(@(Sub) dir([handles.Cfg.WorkingDir,filesep,Sub,filesep,'*',SeriesT1]),SubString,'UniformOutput',0);
    T1String = cellfun(@(SubSeries) {SubSeries(:).name}',T1List,'UniformOutput',0);
    if ~handles.Cfg.AnatOnly
        if handles.Cfg.IsOrganizeDwi
            DwiList = cellfun(@(Sub) dir([handles.Cfg.WorkingDir,filesep,Sub,filesep,'*',SeriesDwi]),SubString,'UniformOutput',0);
            DwiString = cellfun(@(SubSeries) {SubSeries(:).name}',DwiList,'UniformOutput',0);
        end
        if handles.Cfg.IsOrganizeFun
            for iSession = 1:handles.Cfg.FunSessionNumber
                FunAllList{iSession} = cellfun(@(Sub) dir([handles.Cfg.WorkingDir,filesep,Sub,filesep,'*',SeriesFunAll{iSession}]),SubString,'UniformOutput',0);
                FunAllString{iSession}  = cellfun(@(SubSeries) {SubSeries(:).name}',FunAllList{iSession},'UniformOutput',0);
            end
        end
    end
else % Series first
    SeriesListT1 = dir([handles.Cfg.WorkingDir,filesep,'*',SeriesT1]);
    SeriesListT1={SeriesListT1(:).name}';
    SubList = cellfun(@(Series) dir([handles.Cfg.WorkingDir,filesep,Series]),SeriesListT1,'UniformOutput',0);
    SubList = cellfun(@(Sub) {Sub(:).name}',SubList,'UniformOutput',0);
    SubString = cat(1,SubList{:});
    SubString = unique(SubString);
    Index=cellfun(@(NotDot) ~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store'), SubString);
    SubString = SubString(Index);
    
    T1ListTemp = dir([handles.Cfg.WorkingDir,filesep,'*',SeriesT1]);
    T1ListTemp={T1ListTemp(:).name}';
    for iSub = 1:length(SubString)
        Index = cellfun(@(Series) exist([handles.Cfg.WorkingDir,filesep,Series,filesep,SubString{iSub}],'dir'),T1ListTemp);
        T1String{iSub,1} = T1ListTemp(find(Index));
    end
    if ~handles.Cfg.AnatOnly
        if handles.Cfg.IsOrganizeDwi
            DwiListTemp = dir([handles.Cfg.WorkingDir,filesep,'*',SeriesDwi]);
            DwiListTemp={DwiListTemp(:).name}';
            for iSub = 1:length(SubString)
                Index = cellfun(@(Series) exist([handles.Cfg.WorkingDir,filesep,Series,filesep,SubString{iSub}],'dir'),DwiListTemp);
                DwiString{iSub,1} = DwiListTemp(find(Index));
            end
        end
        if handles.Cfg.IsOrganizeFun
            for iSession = 1:handles.Cfg.FunSessionNumber
                FunAllListTemp = dir([handles.Cfg.WorkingDir,filesep,'*',SeriesFunAll{iSession}]);
                FunAllListTemp={FunAllListTemp(:).name}';
                for iSub = 1:length(SubString)
                    Index = cellfun(@(Series) exist([handles.Cfg.WorkingDir,filesep,Series,filesep,SubString{iSub}],'dir'),FunAllListTemp);
                    FunAllString{iSession}{iSub,1} = FunAllListTemp(find(Index));
                end
            end
        end
    end
end

%% Unnest the cell data of Session Lists
MaxColumn = max(cellfun('length', T1String));  % in case the numbers of elements in each cell are different (in that case, concatenate functional sessions will goes wrong)
MinColumn = min(cellfun('length', T1String));
if MaxColumn==1 && MinColumn==1
    T1String = cellfun(@(Series) Series{1},T1String, 'UniformOutput', false); %unnest the cell
else
    T1String = cellfun(@(OneString) [OneString; repmat({'padding'},MaxColumn-length(OneString),1)], T1String, 'UniformOutput', false); % pad each cell.
    T1String = cat(2,T1String{:})';    
end
SubString_T1 = repmat(SubString,1,size(T1String,2));

if ~handles.Cfg.AnatOnly
    if handles.Cfg.IsOrganizeDwi
        MaxColumn = max(cellfun('length', DwiString));
        MinColumn = min(cellfun('length', DwiString));
        if  MaxColumn==1 && MinColumn==1
            DwiString = cellfun(@(Series) Series{1},DwiString, 'UniformOutput', false); %unnest the cell
        else
            DwiString = cellfun(@(OneString) [OneString; repmat({'padding'},MaxColumn-length(OneString),1)], DwiString, 'UniformOutput', false); % pad each cell.
            DwiString = cat(2,DwiString{:})';
        end
        SubString_Dwi = repmat(SubString,1,size(DwiString,2));
    end
    if handles.Cfg.IsOrganizeFun
        for iSession = 1:handles.Cfg.FunSessionNumber
            MaxColumn = max(cellfun('length', FunAllString{iSession} ));
            MinColumn = min(cellfun('length', FunAllString{iSession} ));
            if MaxColumn == 1 && MinColumn == 1
                FunAllString{iSession} = cellfun(@(Series) Series{1},FunAllString{iSession}, 'UniformOutput', false); %unnest the cell
            else 
                FunAllString{iSession}  = cellfun(@(OneString) [OneString; repmat({'padding'},MaxColumn-length(OneString),1)], FunAllString{iSession} , 'UniformOutput', false); % pad each cell.
                FunAllString{iSession}  = cat(2,FunAllString{iSession} {:})';
            end
            SubString_FunAll{iSession} = repmat(SubString,1,size(FunAllString{iSession},2));
        end
    end
end

%% Mark the series without enough dicom files - 1: number of file is correct; 0: number of file is wrong
if handles.Cfg.InputLayout == 1 % Participant first
    % T1 series status 
    disp([newline,'Eliminating the deficient T1-weighted series for T1Raw sessions ...']);
    if handles.Cfg.SeriesFileNumber.LowLimitMode.T1 % Do not fix the number of dicom files, setting a lower threshold for the number. Bin Lu, 20220921.
        nFileT1 = handles.Cfg.SeriesFileNumber.LowThreshold.T1;
        try
            T1Status = cellfun(@(Series,Sub) ...
                (length(java.io.File([handles.Cfg.WorkingDir,filesep,Sub,filesep,Series]).listFiles)-nFileT1)>=0,...
                T1String,SubString_T1,'UniformOutput', false);
        catch
            T1Status = cellfun(@(Series,Sub) ...
                (length(dir([handles.Cfg.WorkingDir,filesep,Sub,filesep,Series]))-handles.Cfg.nFileOperator-nFileT1)>=0,...
                T1String,SubString_T1,'UniformOutput', false);
        end
    else 
        nFileT1 = handles.Cfg.SeriesFileNumber.List.T1(handles.Cfg.SeriesFileNumber.Flag.T1);
        try
            T1Status = cellfun(@(Series,Sub) ...
                ~(length(java.io.File([handles.Cfg.WorkingDir,filesep,Sub,filesep,Series]).listFiles)-nFileT1),...
                T1String,SubString_T1,'UniformOutput', false);
        catch
            T1Status = cellfun(@(Series,Sub) ...
                ~(length(dir([handles.Cfg.WorkingDir,filesep,Sub,filesep,Series]))-handles.Cfg.nFileOperator-nFileT1),...
                T1String,SubString_T1,'UniformOutput', false);
        end
    end   
    if ~handles.Cfg.AnatOnly
        if handles.Cfg.IsOrganizeDwi
            disp([newline,'Eliminating the deficient Diffusion series for DwiRaw sessions ...']);
            if handles.Cfg.SeriesFileNumber.LowLimitMode.Dwi % Do not fix the number of dicom files, setting a lower threshold for the number. Bin Lu, 20220921.
                nFileDwi = handles.Cfg.SeriesFileNumber.LowThreshold.Dwi;
                try
                    DwiStatus = cellfun(@(Series,Sub) ...
                        (length(java.io.File([handles.Cfg.WorkingDir,filesep,Sub,filesep,Series]).listFiles)-nFileDwi)>=0,...
                        DwiString,SubString_Dwi,'UniformOutput', false);
                catch
                    DwiStatus = cellfun(@(Series,Sub) ...
                        (length(dir([handles.Cfg.WorkingDir,filesep,Sub,filesep,Series]))-handles.Cfg.nFileOperator-nFileDwi)>=0,...
                        DwiString,SubString_Dwi,'UniformOutput', false);
                end
            else
                nFileDwi = handles.Cfg.SeriesFileNumber.List.Dwi(handles.Cfg.SeriesFileNumber.Flag.Dwi);
                try
                    DwiStatus = cellfun(@(Series,Sub) ...
                        ~(length(java.io.File([handles.Cfg.WorkingDir,filesep,Sub,filesep,Series]).listFiles)-nFileDwi),...
                        DwiString,SubString_Dwi,'UniformOutput', false);
                catch
                    DwiStatus = cellfun(@(Series,Sub) ...
                        ~(length(dir([handles.Cfg.WorkingDir,filesep,Sub,filesep,Series]))-handles.Cfg.nFileOperator-nFileDwi),...
                        DwiString,SubString_Dwi,'UniformOutput', false);
                end
            end
        end
        if handles.Cfg.IsOrganizeFun
            for iSession = 1:handles.Cfg.FunSessionNumber
                disp([newline,'Eliminating the deficient BOLD fMRI series for S',num2str(iSession),'_FunRaw sessions ...']);
                if handles.Cfg.SeriesFileNumber.LowLimitMode.FunAll{iSession} % Do not fix the number of dicom files, setting a lower threshold for the number. Bin Lu, 20220921.
                    nFileFunAll = handles.Cfg.SeriesFileNumber.LowThreshold.Fun{iSession};
                    try
                        FunAllStatus{iSession} = cellfun(@(Series,Sub) ...
                            (length(java.io.File([handles.Cfg.WorkingDir,filesep,Sub,filesep,Series]).listFiles)-nFileFunAll)>=0,...
                            FunAllString{iSession},SubString_FunAll{iSession},'UniformOutput', false);
                    catch
                        FunAllStatus{iSession} = cellfun(@(Series,Sub) ...
                            (length(dir([handles.Cfg.WorkingDir,filesep,Sub,filesep,Series]))-handles.Cfg.nFileOperator-nFileFunAll)>=0,...
                            FunAllString{iSession},SubString_FunAll{iSession},'UniformOutput', false);
                    end
                else
                    nFileFunAll = handles.Cfg.SeriesFileNumber.List.FunAll{iSession}(handles.Cfg.SeriesFileNumber.Flag.FunAll(iSession));
                    try
                        FunAllStatus{iSession} = cellfun(@(Series,Sub) ...
                            ~(length(java.io.File([handles.Cfg.WorkingDir,filesep,Sub,filesep,Series]).listFiles)-nFileFunAll),...
                            FunAllString{iSession},SubString_FunAll{iSession},'UniformOutput', false);
                    catch
                        FunAllStatus{iSession} = cellfun(@(Series,Sub) ...
                            ~(length(dir([handles.Cfg.WorkingDir,filesep,Sub,filesep,Series]))-handles.Cfg.nFileOperator-nFileFunAll),...
                            FunAllString{iSession},SubString_FunAll{iSession},'UniformOutput', false);
                    end
                end
            end
        end
    end
else % Series first
    % T1 series status 
    if handles.Cfg.SeriesFileNumber.LowLimitMode.T1 % Do not fix the number of dicom files, setting a lower threshold for the number. Bin Lu, 20220921.
        nFileT1 = handles.Cfg.SeriesFileNumber.LowThreshold.T1;
        T1Status = cellfun(@(Series,Sub) ...
            (length(dir([handles.Cfg.WorkingDir,filesep,Series,filesep,Sub]))-handles.Cfg.nFileOperator-nFileT1)>=0,...
            T1String,SubString_T1,'UniformOutput', false);
    else
        nFileT1 = handles.Cfg.SeriesFileNumber.List.T1(handles.Cfg.SeriesFileNumber.Flag.T1);
        T1Status = cellfun(@(Series,Sub) ...
            ~(length(dir([handles.Cfg.WorkingDir,filesep,Series,filesep,Sub]))-handles.Cfg.nFileOperator-nFileT1),...
            T1String,SubString_T1,'UniformOutput', false);
    end
    if ~handles.Cfg.AnatOnly
        if handles.Cfg.IsOrganizeDwi
            if handles.Cfg.SeriesFileNumber.LowLimitMode.Dwi % Do not fix the number of dicom files, setting a lower threshold for the number. Bin Lu, 20220921.
                nFileDwi = handles.Cfg.SeriesFileNumber.LowThreshold.Dwi;
                DwiStatus = cellfun(@(Series,Sub) ...
                    (length(dir([handles.Cfg.WorkingDir,filesep,Series,filesep,Sub]))-handles.Cfg.nFileOperator-nFileDwi)>=0,...
                    DwiString,SubString_Dwi,'UniformOutput', false);
            else
                nFileDwi = handles.Cfg.SeriesFileNumber.List.Dwi(handles.Cfg.SeriesFileNumber.Flag.Dwi);
                DwiStatus = cellfun(@(Series,Sub) ...
                    ~(length(dir([handles.Cfg.WorkingDir,filesep,Series,filesep,Sub]))-handles.Cfg.nFileOperator-nFileDwi),...
                    DwiString,SubString_Dwi,'UniformOutput', false);
            end
        end
        if handles.Cfg.IsOrganizeFun
            % Other functional seriesun status
            if handles.Cfg.SeriesFileNumber.LowLimitMode.FunAll{iSession} % Do not fix the number of dicom files, setting a lower threshold for the number. Bin Lu, 20220921.
                for iSession = 1:handles.Cfg.FunSessionNumber
                    nFileFunAll = handles.Cfg.SeriesFileNumber.LowThreshold.FunAll{iSession};
                    FunAllStatus{iSession} = cellfun(@(Series,Sub) ...
                        (length(dir([handles.Cfg.WorkingDir,filesep,Series,filesep,Sub]))-handles.Cfg.nFileOperator-nFileFunAll)>=0,...
                        FunAllString{iSession},SubString_FunAll{iSession},'UniformOutput', false);
                end
            else
                for iSession = 1:handles.Cfg.FunSessionNumber
                    nFileFunAll = handles.Cfg.SeriesFileNumber.List.FunAll{iSession}(handles.Cfg.SeriesFileNumber.Flag.FunAll(iSession));
                    FunAllStatus{iSession} = cellfun(@(Series,Sub) ...
                        ~(length(dir([handles.Cfg.WorkingDir,filesep,Series,filesep,Sub]))-handles.Cfg.nFileOperator-nFileFunAll),...
                        FunAllString{iSession},SubString_FunAll{iSession},'UniformOutput', false);
                end
            end
        end
    end
end

%% Confirm each session by user if necessary
T1InputDir = cell(length(SubString),1);
if ~handles.Cfg.AnatOnly
    if handles.Cfg.IsOrganizeDwi
        DwiInputDir = cell(length(SubString),1);
    end
    if handles.Cfg.IsOrganizeFun
        FunAllInputDir = cell(handles.Cfg.FunSessionNumber,1);
        FunAllInputDir = cellfun(@(Session) cell(length(SubString),1),FunAllInputDir,'UniformOutput', false);
    end
end

if handles.Cfg.InputLayout == 1 % Participant first
    for iSub = 1:length(SubString) 
        % T1Raw
        Index = find([T1Status{iSub,:}]);
        if ~isempty(Index)
            if length(Index) > 1 && ~handles.Cfg.AlwaysLatterSeries 
                SeriesList = T1String(iSub,Index)';
                Selection = ManuallySelectSeries({'T1Raw'},SubString{iSub},SeriesList,'Template1');
                handles.Cfg.AlwaysLatterSeries = Selection.AlwaysLatterSeries;
                %ManuallySelectSeries({'FunRaw';'S2_FunRaw'},'BinLu',{'Series1';'Series2';'Series3'},'Template1');
                Index = [];
                Index = Selection.Results(1)-1; % Minus "please select" line
                T1InputDir{iSub} = [handles.Cfg.WorkingDir,filesep,SubString{iSub},filesep,SeriesList{Index}];
            else
                T1InputDir{iSub} = [handles.Cfg.WorkingDir,filesep,SubString{iSub},filesep,T1String{iSub,Index(end)}];
            end
        end

        % DwiRaw
        if handles.Cfg.AnatOnly == 0 && handles.Cfg.IsOrganizeDwi
            Index = find([DwiStatus{iSub,:}]);
            if ~isempty(Index)
                if length(Index) > 1 && ~handles.Cfg.AlwaysLatterSeries
                    SeriesList = DwiString(iSub,Index)';
                    Selection = ManuallySelectSeries({'DwiRaw'},SubString{iSub},SeriesList,'Template1');
                    handles.Cfg.AlwaysLatterSeries = Selection.AlwaysLatterSeries;
                    %ManuallySelectSeries({'FunRaw';'S2_FunRaw'},'BinLu',{'Series1';'Series2';'Series3'},'Template1');
                    Index = [];
                    Index = Selection.Results(1)-1; % Minus "please select" line
                    DwiInputDir{iSub} = [handles.Cfg.WorkingDir,filesep,SubString{iSub},filesep,SeriesList{Index}];
                else
                    DwiInputDir{iSub} = [handles.Cfg.WorkingDir,filesep,SubString{iSub},filesep,DwiString{iSub,Index(end)}];
                end
            end
        end

        % FunRaw 
        if handles.Cfg.AnatOnly == 0 && handles.Cfg.IsOrganizeFun
            for iSession = 1:handles.Cfg.FunSessionNumber
                Index = find([FunAllStatus{iSession}{iSub,:}]);
                if ~isempty(Index)
                    if handles.Cfg.SameSeriesName.Flag == 0 % The most simple situation. No same-series-name problem.
                        if length(Index) > 1 && ~handles.Cfg.AlwaysLatterSeries
                            SeriesList = FunAllString{iSession}(iSub,Index)';
                            Selection = ManuallySelectSeries({['S',num2str(iSession),'_FunRaw']},SubString{iSub},SeriesList,'Template1');
                            handles.Cfg.AlwaysLatterSeries = Selection.AlwaysLatterSeries;
                            Index = [];
                            Index = Selection.Results(1)-1; % Minus "please select" line
                            FunAllInputDir{iSession}{iSub} = [handles.Cfg.WorkingDir,filesep,SubString{iSub},filesep,SeriesList{Index}];
                        else
                            FunAllInputDir{iSession}{iSub} = [handles.Cfg.WorkingDir,filesep,SubString{iSub},filesep,FunAllString{iSession}{iSub,Index(end)}];
                        end
                    elseif handles.Cfg.SameSeriesName.Strategy == 2 ||... % All manually select or ...
                            (handles.Cfg.SameSeriesName.Strategy == 1 && length(Index) ~= sum(handles.Cfg.SameSeriesName.FlagMatrix(iSession,:))) % SameSeriesName.Strategy == 1, use series index; but number of series is not equal to number of functional sessions
                        Flag = find(handles.Cfg.SameSeriesName.FlagMatrix(iSession,:));
                        SessionName = handles.Cfg.SameSeriesName.SessionMatrix(iSession,Flag)';
                        SeriesList = FunAllString(iSub,Index)';
                        if length(SeriesList)<length(SessionName) % No enough intact series (e.g. 2 BOLD series while three functional session - FunRaw, S2_FunRaw and S3_FunRaw were determined)
                            SeriesList = cat(1,SeriesList,repmat({'PseudoSeries'},1,length(SessionName)-length(SeriesList)));
                        end
                        if handles.Cfg.SameSeriesName.Strategy == 2 % All manually select
                            Template = 'Template2';
                        else % nSeries ~= nFunSessions
                            Template = 'Template3';
                        end
                        Selection = ManuallySelectSeries(SessionName,SubString{iSub},SeriesList,Template);
                        for i = 1:length(Flag)
                            FunAllInputDir{Flag(i)}{iSub} = [handles.Cfg.WorkingDir,filesep,SubString{iSub},filesep,SeriesList{Selection.Results(i)-1}];
                        end
                    elseif handles.Cfg.SameSeriesName.Strategy == 1 && length(Index) == handles.Cfg.FunSessionNumber % SameSeriesName.Strategy == 1; use index to allocate same-name-series
                        Flag = find(handles.Cfg.SameSeriesName.FlagMatrix(iSession,:));
                        SeriesList = FunAllString{iSession}(iSub,Index)';
                        DashIndex = strfind(SeriesList{1},'_');
                        [~,I] = sort(cellfun(@(Series) str2num(Series(1:DashIndex-1)),SeriesList));
                        SeriesList = SeriesList(I);
                        for i = 1:length(Flag)
                            FunAllInputDir{Flag(i)}{iSub} = [handles.Cfg.WorkingDir,filesep,SubString{iSub},filesep,SeriesList{i}];
                        end
                    end
                end
            end
        end
    end
else % series first
    for iSub = 1:length(SubString) 
        % T1Raw
        Index = find([T1Status{iSub,:}]);
        if ~isempty(Index)
            if length(Index) > 1 && ~handles.Cfg.AlwaysLatterSeries 
                SeriesList = T1String(iSub,Index)';
                Selection = ManuallySelectSeries({'T1Raw'},SubString{iSub},SeriesList,'Template1');
                handles.Cfg.AlwaysLatterSeries = Selection.AlwaysLatterSeries;
                %ManuallySelectSeries({'FunRaw';'S2_FunRaw'},'BinLu',{'Series1';'Series2';'Series3'},'Template1');
                Index = [];
                Index = Selection.Results(1)-1; % Minus "please select" line
                T1InputDir{iSub} = [handles.Cfg.WorkingDir,filesep,SeriesList{Index},filesep,SubString{iSub}];
            else
                T1InputDir{iSub} = [handles.Cfg.WorkingDir,filesep,T1String{iSub,Index(end)},filesep,SubString{iSub}];
            end
        end

        % DwiRaw
        if handles.Cfg.AnatOnly == 0 && handles.Cfg.IsOrganizeDwi
            Index = find([DwiStatus{iSub,:}]);
            if ~isempty(Index)
                if length(Index) > 1 && ~handles.Cfg.AlwaysLatterSeries
                    SeriesList = DwiString(iSub,Index)';
                    Selection = ManuallySelectSeries({'DwiRaw'},SubString{iSub},SeriesList,'Template1');
                    handles.Cfg.AlwaysLatterSeries = Selection.AlwaysLatterSeries;
                    %ManuallySelectSeries({'FunRaw';'S2_FunRaw'},'BinLu',{'Series1';'Series2';'Series3'},'Template1');
                    Index = [];
                    Index = Selection.Results(1)-1; % Minus "please select" line
                    DwiInputDir{iSub} = [handles.Cfg.WorkingDir,filesep,SeriesList{Index},filesep,SubString{iSub}];
                else
                    DwiInputDir{iSub} = [handles.Cfg.WorkingDir,filesep,DwiString{iSub,Index(end)},filesep,SubString{iSub}];
                end
            end
        end

        % FunRaw 
        if handles.Cfg.AnatOnly == 0 && handles.Cfg.IsOrganizeFun
            for iSession = 1:handles.Cfg.FunSessionNumber
                Index = find([FunAllStatus{iSession}{iSub,:}]);
                if ~isempty(Index)
                    if handles.Cfg.SameSeriesName.Flag == 0 % The most simple situation. No same-series-name problem.
                        if length(Index) > 1 && ~handles.Cfg.AlwaysLatterSeries
                            SeriesList = FunAllString{iSession}(iSub,Index)';
                            Selection = ManuallySelectSeries({['S',num2str(iSession),'_FunRaw']},SubString{iSub},SeriesList,'Template1');
                            handles.Cfg.AlwaysLatterSeries = Selection.AlwaysLatterSeries;
                            Index = [];
                            Index = Selection.Results(1)-1; % Minus "please select" line
                            FunAllInputDir{iSession}{iSub} = [handles.Cfg.WorkingDir,filesep,SeriesList{Index},filesep,SubString{iSub}];
                        else
                            FunAllInputDir{iSession}{iSub} = [handles.Cfg.WorkingDir,filesep,FunAllString{iSession}{iSub,Index(end)},filesep,SubString{iSub}];
                        end
                    elseif handles.Cfg.SameSeriesName.Strategy == 2 ||... % All manually select or ...
                            (handles.Cfg.SameSeriesName.Strategy == 1 && length(Index) ~= sum(handles.Cfg.SameSeriesName.FlagMatrix(iSession,:))) % SameSeriesName.Strategy == 1, use series index; but number of series is not equal to number of functional sessions
                        Flag = find(handles.Cfg.SameSeriesName.FlagMatrix(iSession,:));
                        SessionName = handles.Cfg.SameSeriesName.SessionMatrix(iSession,Flag)';
                        SeriesList = FunAllString(iSub,Index)';
                        if length(SeriesList)<length(SessionName) % No enough intact series (e.g. 2 BOLD series while three functional session - FunRaw, S2_FunRaw and S3_FunRaw were determined)
                            SeriesList = cat(1,SeriesList,repmat({'PseudoSeries'},1,length(SessionName)-length(SeriesList)));
                        end
                        if handles.Cfg.SameSeriesName.Strategy == 2 % All manually select
                            Template = 'Template2';
                        else % nSeries ~= nFunSessions
                            Template = 'Template3';
                        end
                        Selection = ManuallySelectSeries(SessionName,SubString{iSub},SeriesList,Template);
                        for i = 1:length(Flag)
                            FunAllInputDir{Flag(i)}{iSub} = [handles.Cfg.WorkingDir,filesep,SeriesList{Selection.Results(i)-1},filesep,SubString{iSub}];
                        end
                    elseif handles.Cfg.SameSeriesName.Strategy == 1 && length(Index) == handles.Cfg.FunSessionNumber % SameSeriesName.Strategy == 1; use index to allocate same-name-series
                        Flag = find(handles.Cfg.SameSeriesName.FlagMatrix(iSession,:));
                        SeriesList = FunAllString{iSession}(iSub,Index)';
                        DashIndex = strfind(SeriesList{1},'_');
                        [~,I] = sort(cellfun(@(Series) str2num(Series(1:DashIndex-1)),SeriesList));
                        SeriesList = SeriesList(I);
                        for i = 1:length(Flag)
                            FunAllInputDir{Flag(i)}{iSub} = [handles.Cfg.WorkingDir,filesep,SeriesList{i},filesep,SubString{iSub}];
                        end
                    end
                end
            end
        end
    end    
end

%% Find qualified series to be appointed as pseudo series if needed (handles.Cfg.IsPseudoSeries == 1),
% or delete the subject without full T1 session and functional sessions from sublist (handles.Cfg.IsPseudoSeries == 0) 
SubStatus = ones(length(SubString),1);
if handles.Cfg.IsPseudoSeries
    handles.Cfg.T1Pseudo = '';
    handles.Cfg.DwiPseudo = '';
    handles.Cfg.FunAllPseudo = cell(handles.Cfg.FunSessionNumber,1);
    for iSub = 1:length(SubString)
        if ~isempty(T1InputDir{iSub}) && ~strcmp(T1InputDir{iSub}(end-11:end),'PseudoSeries') && isempty(handles.Cfg.T1Pseudo)
            handles.Cfg.T1Pseudo = T1InputDir{iSub};
        elseif isempty(T1InputDir{iSub}) || strcmp(T1InputDir{iSub}(end-11:end),'PseudoSeries')
            %             T1InputDir{iSub} = 'PseudoSeries'; 
            SubStatus(iSub) = 0; % Revised 20210511, don't assign pseudo series for T1 MRI
        end
        if ~handles.Cfg.AnatOnly
            if handles.Cfg.IsOrganizeDwi
                if  ~isempty(DwiInputDir{iSub}) && ~strcmp(DwiInputDir{iSub}(end-11:end),'PseudoSeries') && isempty(handles.Cfg.DwiPseudo)
                    handles.Cfg.DwiPseudo = DwiInputDir{iSub};
                elseif isempty(DwiInputDir{iSub}) || strcmp(DwiInputDir{iSub}(end-11:end),'PseudoSeries')
                    DwiInputDir{iSub} = 'PseudoSeries';
                end
            end
            if handles.Cfg.IsOrganizeFun
                for iSession = 1:handles.Cfg.FunSessionNumber
                    if  ~isempty(FunAllInputDir{iSession}{iSub}) && ~strcmp(FunAllInputDir{iSession}{iSub}(end-11:end),'PseudoSeries') && isempty(handles.Cfg.FunAllPseudo{iSession})
                        handles.Cfg.FunAllPseudo{iSession} = FunAllInputDir{iSession}{iSub};
                    elseif isempty(FunAllInputDir{iSession}{iSub}) || strcmp(FunAllInputDir{iSession}{iSub}(end-11:end),'PseudoSeries')
                        FunAllInputDir{iSession}{iSub} = 'PseudoSeries';
                    end
                end
            end
        end
    end
else % handles.Cfg.IsPseudoSeries == 0
    for iSub = 1:length(SubString)
        if isempty(T1InputDir{iSub}) || strcmp(T1InputDir{iSub}(end-11:end),'PseudoSeries')
            SubStatus(iSub) = 0;
        end
        if ~handles.Cfg.AnatOnly
            if handles.Cfg.IsOrganizeDwi
                if isempty(DwiInputDir{iSub}) || strcmp(DwiInputDir{iSub}(end-11:end),'PseudoSeries')
                    SubStatus(iSub) = 0;
                end
            end
            if handles.Cfg.IsOrganizeFun
                for iSession = 1:handles.Cfg.FunSessionNumber
                    if isempty(FunAllInputDir{iSession}{iSub}) || strcmp(FunAllInputDir{iSession}{iSub}(end-11:end),'PseudoSeries')
                        SubStatus(iSub) = 0;
                    end
                end
            end
        end
        
    end
end

%% Copy and paste files 
disp([newline,'Start to copy files to DPABI-format starting directory ...']);
handles.Cfg.SubList = SubString(find(SubStatus));
handles.Cfg.SubListNew = cell(length(handles.Cfg.SubList),1);
handles.Cfg.InputList.T1 = T1InputDir(find(SubStatus));
if ~handles.Cfg.AnatOnly
    if handles.Cfg.IsOrganizeDwi
        handles.Cfg.InputList.Dwi =DwiInputDir(find(SubStatus));
    end
    if handles.Cfg.IsOrganizeFun
        for iSession = 1:handles.Cfg.FunSessionNumber
            handles.Cfg.InputList.FunAll{iSession} = FunAllInputDir{iSession}(find(SubStatus));
        end
    end
end

MacFlag = 0;
for iSub = 1:length(handles.Cfg.SubList)
    if handles.Cfg.IsChangeSubID
        SubID = sprintf('Sub%.3d', iSub);
        handles.Cfg.SubListNew{iSub} = SubID;
    else
        SubID = handles.Cfg.SubList{iSub};
    end

    T1OutputDir = [handles.Cfg.OutputDir,filesep,'T1Raw',filesep,SubID];
    mkdir(T1OutputDir);
    try
        if ~strcmp(handles.Cfg.InputList.T1{iSub},'PseudoSeries')
            copyfile(handles.Cfg.InputList.T1{iSub},T1OutputDir);
        else
            copyfile(handles.Cfg.T1Pseudo,T1OutputDir);
        end
    catch % Mac OS error: cp: Argument list too long
        if ~strcmp(handles.Cfg.InputList.T1{iSub},'PseudoSeries')
            dos(['for file in "',handles.Cfg.InputList.T1{iSub},'"/*; do cp -- "$file" "',T1OutputDir,'" ; done']);
        else
            dos(['for file in "',handles.Cfg.T1Pseudo,'"/*; do cp -- "$file" "',T1OutputDir,'" ; done']);
        end        
    end
    
    if ~handles.Cfg.AnatOnly
        if handles.Cfg.IsOrganizeDwi
            DwiOutputDir = [handles.Cfg.OutputDir,filesep,'DwiRaw',filesep,SubID];
            mkdir(DwiOutputDir);
            try
                if ~strcmp(handles.Cfg.InputList.Dwi{iSub},'PseudoSeries')
                    copyfile(handles.Cfg.InputList.Dwi{iSub},DwiOutputDir);
                else
                    copyfile(handles.Cfg.DwiPseudo,DwiOutputDir);
                end
            catch
                if MacFlag == 0
                    disp([newline,...
                        'Because of the system limitation of your computer, to avoid the "argument list too long" error, it would take more time to finish copy-paste procedure...'])
                    MacFlag = 1;
                end
                if ~strcmp(handles.Cfg.InputList.Dwi{iSub},'PseudoSeries')
                    dos(['for file in "',handles.Cfg.InputList.Dwi{iSub},'"/*; do cp -- "$file" "',DwiOutputDir,'" ; done']);
                else
                    dos(['for file in "',handles.Cfg.DwiPseudo,'"/*; do cp -- "$file" "',DwiOutputDir,'" ; done']);
                end
            end
        end
        if handles.Cfg.IsOrganizeFun
            for iSession = 1:handles.Cfg.FunSessionNumber
                if iSession == 1
                    FunAllOutputDir = [handles.Cfg.OutputDir,filesep,'FunRaw',filesep,SubID];
                else
                    FunAllOutputDir = [handles.Cfg.OutputDir,filesep,'S',num2str(iSession),'_FunRaw',filesep,SubID];
                end
                mkdir(FunAllOutputDir);
                try
                    if ~strcmp(handles.Cfg.InputList.FunAll{iSession}{iSub},'PseudoSeries')
                        copyfile(handles.Cfg.InputList.FunAll{iSession}{iSub},FunAllOutputDir);
                    else
                        copyfile(handles.Cfg.FunAllPseudo{iSession},FunAllOutputDir);
                    end
                catch
                    if ~strcmp(handles.Cfg.InputList.FunAll{iSession}{iSub},'PseudoSeries')
                        dos(['for file in "',handles.Cfg.InputList.FunAll{iSession}{iSub},'"/*; do cp -- "$file" "',FunAllOutputDir,'" ; done']);
                    else
                        dos(['for file in "',handles.Cfg.FunAllPseudo{iSession},'"/*; do cp -- "$file" "',FunAllOutputDir,'" ; done']);
                    end
                end
            end
        end
    end
    disp([newline,'Have done ',num2str(iSub), ' subjects, ',num2str(length(handles.Cfg.SubList)),' subjects in total.']);
end

disp([newline,'DPARSFA/DPABISurf input preparation finished!'])
guidata(hObject,handles);



function CheckFileOperatorNumber(hObject, handles)
%% Check 3 layer of folders for getting the number of OS file operators
% Some times (e.g. files tansfered between multiple OS) the number of operaters are different in different layer of folder
if isempty(handles.Cfg.WorkingDir)
    return
else
    FileList1 = dir(handles.Cfg.WorkingDir);
    Index=cellfun(...
        @(IsDir, NotDot) IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')), ...
        {FileList1.isdir}, {FileList1.name});
    nOperator(1) = length(find(Index==0));
    FileList1=FileList1(Index);
    FileList1={FileList1(:).name}';
    
    FileList2 = dir([handles.Cfg.WorkingDir,filesep,FileList1{1}]);
    Index=cellfun(...
        @(IsDir, NotDot) IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')), ...
        {FileList2.isdir}, {FileList2.name});
    nOperator(2) = length(find(Index==0));
    FileList2=FileList2(Index);
    FileList2={FileList2(:).name}';
    % FileList3 -- Dicom files layer
    FileList3 = cellfun(@(File) dir([handles.Cfg.WorkingDir,filesep,FileList1{1},filesep,File]),FileList2,'UniformOutput',0);
    for i = 1:min(5, length(FileList3))
        Index=cellfun(...
            @(NotDot) (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')), {FileList3{i}(:).name});
        nOperator(i+2) = length(find(Index==0));
    end
    handles.Cfg.nFileOperator = mode(nOperator);
end
guidata(hObject,handles);



function WriteCSV(hObject, handles)
%% Write out the conversion status into .csv file.
if handles.Cfg.IsChangeSubID == 0
    Titles = {'Subject ID','T1Raw'};
    Text = [handles.Cfg.SubList, handles.Cfg.InputList.T1];
else
    Titles = {'Default Subject ID', 'New Subject ID','T1Raw'};
    Text = [handles.Cfg.SubList, handles.Cfg.SubListNew, handles.Cfg.InputList.T1];
end
if ~handles.Cfg.AnatOnly 
    if handles.Cfg.IsOrganizeDwi
        Titles = [Titles,'DwiRaw'];
        Text = [Text,handles.Cfg.InputList.Dwi];
    end
    if handles.Cfg.IsOrganizeFun
        for iSession = 1:handles.Cfg.FunSessionNumber
            if iSession ==1
                Titles = [Titles,['FunRaw']];
            else
                Titles = [Titles,['S',num2str(iSession),'_FunRaw']];
            end
            Text = [Text,handles.Cfg.InputList.FunAll{iSession}];
        end
    end
end

if handles.Cfg.IsDCM2NII 
    Titles = [Titles,'DCM2NII T1Raw'];
    Text = [Text,handles.Cfg.DCM2NIIStatus{1}];
    if ~handles.Cfg.AnatOnly
        Titles = [Titles,'DCM2NII DwiRaw'];
        Text = [Text,handles.Cfg.DCM2NIIStatus{2}];
        if handles.Cfg.IsOrganizeFun
            for iSession = 1:handles.Cfg.FunSessionNumber
                if iSession ==1
                    Titles = [Titles,['DCM2NII FunRaw']];
                else
                    Titles = [Titles,['DCM2NII S',num2str(iSession+1),'_FunRaw']];
                end
                Text = [Text,handles.Cfg.DCM2NIIStatus{iSession+2}];
            end
        end
    end
end

Datetime=fix(clock); %Added by YAN Chao-Gan, 100130.

% T = cell2table(Text,'VariableNames',Titles);
% writetable(T,[handles.Cfg.OutputDir,filesep,'DPABI_Format_Conversion_Report_',num2str(Datetime(1)),'_',num2str(Datetime(2)),'_',num2str(Datetime(3)),'_',num2str(Datetime(4)),'_',num2str(Datetime(5)),'.csv']);

% YAN Chao-Gan, 211122. I don't know why for some system writetable is not working, so I try to re-write with old funcitons.
fid = fopen([handles.Cfg.OutputDir,filesep,'DPABI_Input_Preparer_Report_',num2str(Datetime(1)),'_',num2str(Datetime(2)),'_',num2str(Datetime(3)),'_',num2str(Datetime(4)),'_',num2str(Datetime(5)),'_',num2str(Datetime(6)),'.tsv'],'w');

for i=1:size(Titles,2)-1
    fprintf(fid,'%s\t',Titles{i});
end
fprintf(fid,'%s\n',Titles{size(Titles,2)});
for i=1:size(Text,1)
    for j=1:size(Text,2)-1
        fprintf(fid,'%s\t',Text{i,j});
    end
    fprintf(fid,'%s\n',Text{i,size(Text,2)});
end
fclose(fid);

disp([newline,'Write out DPABI Input Preparer report.']);
 


function DCM2NII(hObject, handles)
%% Run DCM2NII.
if handles.Cfg.IsChangeSubID
    SubjectID = handles.Cfg.SubListNew;
else
    SubjectID = handles.Cfg.SubList;
end

%Convert T1 DICOM files to NIFTI images
for iSub=1:length(handles.Cfg.SubList)
    OutputDir=[handles.Cfg.OutputDir,filesep,'T1Img',filesep,SubjectID{iSub}];
    mkdir(OutputDir);
    DirDCM=dir([handles.Cfg.OutputDir,filesep,'T1Raw',filesep,SubjectID{iSub},filesep,'*']); %Revised by YAN Chao-Gan 100130. %DirDCM=dir([handles.Cfg.OutputDir,filesep,'FunRaw',filesep,SubjectID{i},filesep,'*.*']);
    InputFilename=[handles.Cfg.OutputDir,filesep,'T1Raw',filesep,SubjectID{iSub},filesep,DirDCM(handles.Cfg.nFileOperator+1).name];
    %YAN Chao-Gan 120817.
    y_Call_dcm2nii(InputFilename, OutputDir, 'DefaultINI');
    fprintf(['Converting T1 Images: ',SubjectID{iSub},' OK']);
end

%Convert DWI DICOM files to NIFTI images
if handles.Cfg.IsOrganizeDwi
    for iSub=1:length(handles.Cfg.SubList)
        OutputDir=[handles.Cfg.OutputDir,filesep,'DwiImg',filesep,SubjectID{iSub}];
        mkdir(OutputDir);
        DirDCM=dir([handles.Cfg.OutputDir,filesep,'DwiRaw',filesep,SubjectID{iSub},filesep,'*']); %Revised by YAN Chao-Gan 100130. %DirDCM=dir([handles.Cfg.OutputDir,filesep,'FunRaw',filesep,SubjectID{i},filesep,'*.*']);
        InputFilename=[handles.Cfg.OutputDir,filesep,'DwiRaw',filesep,SubjectID{iSub},filesep,DirDCM(handles.Cfg.nFileOperator+1).name];
        %YAN Chao-Gan 120817.
        y_Call_dcm2nii(InputFilename, OutputDir, 'DefaultINI');
        fprintf(['Converting DWI Images: ',SubjectID{iSub},' OK']);
    end
end

%Convert Functional DICOM files to NIFTI images
if handles.Cfg.IsOrganizeFun
    for iFunSession=1:handles.Cfg.FunSessionNumber
        if iFunSession == 1
            Prefix = '';
        else
            Prefix = ['S',num2str(iFunSession),'_'];
        end
        for iSub=1:length(handles.Cfg.SubList)
            OutputDir=[handles.Cfg.OutputDir,filesep,Prefix,'FunImg',filesep,SubjectID{iSub}];
            mkdir(OutputDir);
            DirDCM=dir([handles.Cfg.OutputDir,filesep,Prefix,'FunRaw',filesep,SubjectID{iSub},filesep,'*']); %Revised by YAN Chao-Gan 100130. %DirDCM=dir([handles.Cfg.OutputDir,filesep,'FunRaw',filesep,SubjectID{i},filesep,'*.*']);
            InputFilename=[handles.Cfg.OutputDir,filesep,Prefix,'FunRaw',filesep,SubjectID{iSub},filesep,DirDCM(handles.Cfg.nFileOperator+1).name];
            %YAN Chao-Gan 120817.
            y_Call_dcm2nii(InputFilename, OutputDir, 'DefaultINI');
            fprintf(['Converting ',Prefix,'FunImg: ',SubjectID{iSub},' OK']);
        end
        fprintf('\n');
    end
end


% Check whether DCM2NII is successful
Flag = zeros(length(handles.Cfg.SubList));
for iSub = 1:length(handles.Cfg.SubList)
    % Check T1 DCM2NII status
    if ~isempty(dir([handles.Cfg.OutputDir,filesep,'T1Img',filesep,SubjectID{iSub},filesep,'*.nii']))
        handles.Cfg.DCM2NIIStatus{1}{iSub,1} = 'Success';
    else
        handles.Cfg.DCM2NIIStatus{1}{iSub,1} = 'Failure';
        Flag(iSub) = 1;
    end
    % Check DWI DCM2NII status
    if handles.Cfg.IsOrganizeDwi
        if ~isempty(dir([handles.Cfg.OutputDir,filesep,'DwiImg',filesep,SubjectID{iSub},filesep,'*.nii']))
            handles.Cfg.DCM2NIIStatus{2}{iSub,1} = 'Success';
        else
            handles.Cfg.DCM2NIIStatus{2}{iSub,1} = 'Failure';
            Flag(iSub) = 1;
        end
    end
    % Check Fun DCM2NII status
    if handles.Cfg.IsOrganizeFun
        for iSession = 1:handles.Cfg.FunSessionNumber
            if iSession == 1
                Prefix = '';
            else
                Prefix = ['S',num2str(iSession),'_'];
            end
            if ~isempty(dir([handles.Cfg.OutputDir,filesep,Prefix,'FunImg',filesep,SubjectID{iSub},filesep,'*.nii']))
                handles.Cfg.DCM2NIIStatus{iSession+2}{iSub,1} = 'Success';
            else
                handles.Cfg.DCM2NIIStatus{iSession+2}{iSub,1} = 'Failure';
                Flag(iSub) = 1;
            end
        end
    end
    % Delete participants with DCM2NII failure
    if Flag(iSub) == 1
        rmdir([handles.Cfg.OutputDir,filesep,'T1Img',filesep,SubjectID{iSub}],'s');
        if handles.Cfg.IsOrganizeDwi
            rmdir([handles.Cfg.OutputDir,filesep,'DwiImg',filesep,SubjectID{iSub}],'s');
        end
        if handles.Cfg.IsOrganizeFun
            for iSession = 1:handles.Cfg.FunSessionNumber
                if iSession == 1
                    Prefix = '';
                else
                    Prefix = ['S',num2str(iSession),'_'];
                end
                rmdir([handles.Cfg.OutputDir,filesep,Prefix,'FunImg',filesep,SubjectID{iSub}],'s');
            end
        end
    end
end
guidata(hObject,handles);


function UpdateDisplay(handles)
%% Update All the uiControls' display on the GUI
set(handles.editInputDir,'String',handles.Cfg.WorkingDir);
set(handles.editOutputDir,'String',handles.Cfg.OutputDir);
set(handles.popupmenuInputLayout,'Value',handles.Cfg.InputLayout);
set(handles.checkboxIsChangeSubID,'Value',handles.Cfg.IsChangeSubID);
set(handles.checkboxIsPseudo,'Value',handles.Cfg.IsPseudoSeries);
set(handles.checkboxIsOrganizeFun,'Value',handles.Cfg.IsOrganizeFun);
set(handles.editFunSessionNum,'string',num2str(handles.Cfg.FunSessionNumber));
set(handles.checkboxIsOrganizeDwi,'Value',handles.Cfg.IsOrganizeDwi);
set(handles.checkboxDCM2NII,'Value',handles.Cfg.IsDCM2NII);

%T1Raw
set(handles.popupmenuT1,'String',handles.Cfg.Demo.SeriesNames,'Value',handles.Cfg.SeriesIndex.T1);
Percentage = handles.Cfg.SeriesFileNumber.Percent.T1;
DisplayString = cellfun(@(Num,Per) sprintf('%d (%.0f%%)',Num,Per*100),...
    num2cell(handles.Cfg.SeriesFileNumber.List.T1),num2cell(Percentage),'UniformOutput',false);
set(handles.popupmenuT1FileNumber,'String',DisplayString,'Value',handles.Cfg.SeriesFileNumber.Flag.T1);
set(handles.editT1nFile,'String',num2str(handles.Cfg.SeriesFileNumber.LowThreshold.T1));
if handles.Cfg.SeriesFileNumber.LowLimitMode.T1 == 0
    set(handles.popupmenuT1FileNumber,'Enable','on');
    set(handles.radiobuttonT1FixednFile,'Value',1);
    set(handles.radiobuttonT1ChangeablenFile,'Value',0);
    set(handles.textMoreThanT1,'Enable','off');
    set(handles.editT1nFile,'Enable','off');
    set(handles.textFilesT1,'Enable','off');
else
    set(handles.popupmenuT1FileNumber,'Enable','off');
    set(handles.radiobuttonT1FixednFile,'Value',0);
    set(handles.radiobuttonT1ChangeablenFile,'Value',1);
    set(handles.textMoreThanT1,'Enable','on');
    set(handles.editT1nFile,'Enable','on');
    set(handles.textFilesT1,'Enable','on');
end

%DwiRaw
if handles.Cfg.IsOrganizeDwi
    set(handles.popupmenuDwi,'String',handles.Cfg.Demo.SeriesNames,'Value',handles.Cfg.SeriesIndex.Dwi);
    Percentage = handles.Cfg.SeriesFileNumber.Percent.Dwi;
    DisplayString = cellfun(@(Num,Per) sprintf('%d (%.0f%%)',Num,Per*100),...
        num2cell(handles.Cfg.SeriesFileNumber.List.Dwi),num2cell(Percentage),'UniformOutput',false);
    set(handles.popupmenuDwi,'Enable','on');
    set(handles.popupmenuDwiFileNumber,'String',DisplayString,'Value',handles.Cfg.SeriesFileNumber.Flag.Dwi);
    set(handles.editDwinFile,'String',num2str(handles.Cfg.SeriesFileNumber.LowThreshold.Dwi));
    set(handles.radiobuttonDwiFixednFile,'Enable','on');
    set(handles.radiobuttonDwiChangeablenFile,'Enable','on');
    if handles.Cfg.SeriesFileNumber.LowLimitMode.Dwi == 0
        set(handles.popupmenuDwiFileNumber,'Enable','on');
        set(handles.radiobuttonDwiFixednFile,'Value',1);
        set(handles.radiobuttonDwiChangeablenFile,'Value',0);
        set(handles.textMoreThanDwi,'Enable','off');
        set(handles.editDwinFile,'Enable','off');
        set(handles.textFilesDwi,'Enable','off');
    else
        set(handles.popupmenuDwiFileNumber,'Enable','off');
        set(handles.radiobuttonDwiFixednFile,'Value',0);
        set(handles.radiobuttonDwiChangeablenFile,'Value',1);
        set(handles.textMoreThanDwi,'Enable','on');
        set(handles.editDwinFile,'Enable','on');
        set(handles.textFilesDwi,'Enable','on');
    end
else
    set(handles.popupmenuDwi,'Enable','off');
    set(handles.popupmenuDwiFileNumber,'Enable','off');
    set(handles.editDwinFile,'Enable','off');
    set(handles.textMoreThanDwi,'Enable','off');
    set(handles.textFilesDwi,'Enable','off');
    set(handles.radiobuttonDwiFixednFile,'Enable','off');
    set(handles.radiobuttonDwiChangeablenFile,'Enable','off');
end

%FunRaw
if handles.Cfg.IsOrganizeFun  
    set(handles.popupmenuSxFunRaw,'Enable','on');
    set(handles.popupmenuFunAll,'Enable','on');
    set(handles.editFunSessionNum,'Enable','on');
    
    
    %% need to deal with percentage problem !!!!!!!!
    Percentage = handles.Cfg.SeriesFileNumber.Percent.FunAll{handles.Cfg.SxFunRawFlag};
    DisplayString = cellfun(@(Num,Per) sprintf('%d (%.0f%%)',Num,Per*100),...
        num2cell(handles.Cfg.SeriesFileNumber.List.FunAll{handles.Cfg.SxFunRawFlag}),num2cell(Percentage),'UniformOutput',false);
    set(handles.popupmenuFunAllFileNumber,'String',DisplayString,...
        'Value',handles.Cfg.SeriesFileNumber.Flag.FunAll(handles.Cfg.SxFunRawFlag));
    set(handles.editFunAllnFile,'String',...
        num2str(handles.Cfg.SeriesFileNumber.LowThreshold.FunAll{handles.Cfg.SxFunRawFlag}));
    set(handles.radiobuttonFunAllFixednFile,'Enable','on');
    set(handles.radiobuttonFunAllChangeablenFile,'Enable','on');
    if handles.Cfg.SeriesFileNumber.LowLimitMode.FunAll{handles.Cfg.SxFunRawFlag} ==0
        set(handles.popupmenuFunAllFileNumber,'Enable','on');
        set(handles.radiobuttonFunAllFixednFile,'Value',1);
        set(handles.radiobuttonFunAllChangeablenFile,'Value',0);
        set(handles.textMoreThanFunAll,'Enable','off');
        set(handles.editFunAllnFile,'Enable','off');
        set(handles.textFilesFunAll,'Enable','off');
    else
        set(handles.popupmenuFunAllFileNumber,'Enable','off');
        set(handles.radiobuttonFunAllFixednFile,'Value',0);
        set(handles.radiobuttonFunAllChangeablenFile,'Value',1);
        set(handles.textMoreThanFunAll,'Enable','on');
        set(handles.editFunAllnFile,'Enable','on');
        set(handles.textFilesFunAll,'Enable','on');
    end
else
    set(handles.popupmenuSxFunRaw,'Enable','off');
    set(handles.popupmenuFunAll,'Enable','off');
    set(handles.popupmenuFunAllFileNumber,'Enable','off');
    set(handles.editFunSessionNum,'Enable','off');
    set(handles.popupmenuFunAllFileNumber,'Enable','off');
    set(handles.textMoreThanFunAll,'Enable','off');
    set(handles.editFunAllnFile,'Enable','off');
    set(handles.textFilesFunAll,'Enable','off');
    set(handles.radiobuttonFunAllFixednFile,'Enable','off');
    set(handles.radiobuttonFunAllChangeablenFile,'Enable','off');
end
set(handles.popupmenuSxFunRaw,'String',handles.Cfg.SxFunRawList,'Value',handles.Cfg.SxFunRawFlag);
set(handles.popupmenuFunAll,'String',handles.Cfg.Demo.SeriesNames,'Value',handles.Cfg.SeriesIndex.FunAll(handles.Cfg.SxFunRawFlag));
drawnow


% --- Executes on button press in radiobuttonT1FixednFile.
function radiobuttonT1FixednFile_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonT1FixednFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.SeriesFileNumber.LowLimitMode.T1 = ~get(handles.radiobuttonT1FixednFile,'Value');
guidata(hObject,handles);
UpdateDisplay(handles)
% Hint: get(hObject,'Value') returns toggle state of radiobuttonT1FixednFile


% --- Executes on button press in radiobutton8.
function radiobutton8_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton8


% --- Executes on button press in radiobuttonT1ChangeablenFile.
function radiobuttonT1ChangeablenFile_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonT1ChangeablenFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.SeriesFileNumber.LowLimitMode.T1 = get(handles.radiobuttonT1ChangeablenFile,'Value');
guidata(hObject,handles);
UpdateDisplay(handles)
% Hint: get(hObject,'Value') returns toggle state of radiobuttonT1ChangeablenFile



function editT1nFile_Callback(hObject, eventdata, handles)
% hObject    handle to editT1nFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.SeriesFileNumber.LowThreshold.T1 = str2num(get(handles.editT1nFile,'String'));
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editT1nFile as text
%        str2double(get(hObject,'String')) returns contents of editT1nFile as a double


% --- Executes during object creation, after setting all properties.
function editT1nFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editT1nFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobuttonDwiFixednFile.
function radiobuttonDwiFixednFile_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonDwiFixednFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.SeriesFileNumber.LowLimitMode.Dwi = ~get(handles.radiobuttonDwiFixednFile,'Value');
guidata(hObject,handles);
UpdateDisplay(handles)
% Hint: get(hObject,'Value') returns toggle state of radiobuttonDwiFixednFile


% --- Executes on button press in radiobuttonDwiChangeablenFile.
function radiobuttonDwiChangeablenFile_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonDwiChangeablenFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.SeriesFileNumber.LowLimitMode.Dwi = get(handles.radiobuttonDwiChangeablenFile,'Value');
guidata(hObject,handles);
UpdateDisplay(handles)
% Hint: get(hObject,'Value') returns toggle state of radiobuttonDwiChangeablenFile



function editDwinFile_Callback(hObject, eventdata, handles)
% hObject    handle to editDwinFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.SeriesFileNumber.LowThreshold.Dwi = str2num(get(handles.editDwinFile,'String'));
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editDwinFile as text
%        str2double(get(hObject,'String')) returns contents of editDwinFile as a double


% --- Executes during object creation, after setting all properties.
function editDwinFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDwinFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobuttonFunAllFixednFile.
function radiobuttonFunAllFixednFile_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonFunAllFixednFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.SeriesFileNumber.LowLimitMode.FunAll{handles.Cfg.SxFunRawFlag} = ~get(handles.radiobuttonFunAllFixednFile,'Value');
guidata(hObject,handles);
UpdateDisplay(handles)
% Hint: get(hObject,'Value') returns toggle state of radiobuttonFunAllFixednFile


% --- Executes on button press in radiobuttonFunAllChangeablenFile.
function radiobuttonFunAllChangeablenFile_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonFunAllChangeablenFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.SeriesFileNumber.LowLimitMode.FunAll{handles.Cfg.SxFunRawFlag} = get(handles.radiobuttonFunAllChangeablenFile,'Value');
guidata(hObject,handles);
UpdateDisplay(handles)
% Hint: get(hObject,'Value') returns toggle state of radiobuttonFunAllChangeablenFile



function editFunAllnFile_Callback(hObject, eventdata, handles)
% hObject    handle to editFunAllnFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.SeriesFileNumber.LowThreshold.FunAll{handles.Cfg.SxFunRawFlag} = str2num(get(handles.editFunAllnFile,'String'));
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editFunAllnFile as text
%        str2double(get(hObject,'String')) returns contents of editFunAllnFile as a double


% --- Executes during object creation, after setting all properties.
function editFunAllnFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFunAllnFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxIsOrganizeDwi.
function checkboxIsOrganizeDwi_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxIsOrganizeDwi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsOrganizeDwi = get(handles.checkboxIsOrganizeDwi,'Value');
UpdateDisplay(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxIsOrganizeDwi
