function varargout = DPABI_BIDS_Converter(varargin)
% DPABI_BIDS_CONVERTER MATLAB code for DPABI_BIDS_Converter.fig
%      DPABI_BIDS_CONVERTER, by itself, creates a new DPABI_BIDS_CONVERTER or raises the existing
%      singleton*.
%
%      H = DPABI_BIDS_CONVERTER returns the handle to a new DPABI_BIDS_CONVERTER or the handle to
%      the existing singleton*.
%
%      DPABI_BIDS_CONVERTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABI_BIDS_CONVERTER.M with the given input arguments.
%
%      DPABI_BIDS_CONVERTER('Property','Value',...) creates a new DPABI_BIDS_CONVERTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABI_BIDS_Converter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABI_BIDS_Converter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABI_BIDS_Converter

% Last Modified by GUIDE v2.5 14-Apr-2021 16:35:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABI_BIDS_Converter_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABI_BIDS_Converter_OutputFcn, ...
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


% --- Executes just before DPABI_BIDS_Converter is made visible.
function DPABI_BIDS_Converter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABI_BIDS_Converter (see VARARGIN)

Release='V1.0_210401';
handles.Release = Release; % Will be used in mat file version checking (e.g., in function SetLoadedData)

if ispc
    UserName =getenv('USERNAME');
else
    UserName =getenv('USER');
end
Datetime=fix(clock);

Path = which('dpabi');
[filepath,name,ext] = fileparts(Path);
handles.Cfg.DPABIPath = filepath;
handles.Cfg.WorkingDir = pwd; 
handles.Cfg.SubjectID = '';
handles.Cfg.IsNeedConvertFunDCM2IMG = 1;
handles.Cfg.IsNeedConvertT1DCM2IMG = 1;
handles.Cfg.IsDeface = 1;
handles.Cfg.IsRemoveFirstTimePoints = 1;
handles.Cfg.RemoveFirstTimePoints = 10;
handles.Cfg.FunctionalSessionNumber = 1;
handles.Cfg.StartingDirName='FunRaw';


set(handles.editInputDir,'String',handles.Cfg.WorkingDir);
set(handles.listboxSubject,'String',handles.Cfg.SubjectID);
set(handles.checkboxEPIDCM2NII,'Value',handles.Cfg.IsNeedConvertFunDCM2IMG);
set(handles.checkboxT1DCM2NII,'Value',handles.Cfg.IsNeedConvertT1DCM2IMG);
set(handles.checkboxDeface,'Value',handles.Cfg.IsDeface);
set(handles.checkboxRemoveTimePoint,'Value',handles.Cfg.IsRemoveFirstTimePoints);
set(handles.editRemoveTimePoint,'String',handles.Cfg.RemoveFirstTimePoints);
set(handles.editFunctionalSession,'String',handles.Cfg.FunctionalSessionNumber);
set(handles.editStartingDir,'String',handles.Cfg.StartingDirName);
% Choose default command line output for DPABI_BIDS_Converter
handles.output = hObject;


% Make UI display correct in PC and linux
if ~ismac
    if ispc
        ZoonMatrix = [1 1 2 2];  %For pc
    else
        ZoonMatrix = [1 1 2 2];  %For Linux
    end
    UISize = get(handles.figure1,'Position');
    UISize = UISize.*ZoonMatrix;
    set(handles.figure1,'Position',UISize);
end
movegui(handles.figure1, 'center');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABI_BIDS_Converter wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DPABI_BIDS_Converter_OutputFcn(hObject, eventdata, handles) 
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
guidata(hObject,handles);
ReadDataList(hObject,handles);
handles = guidata(hObject);
ShowDataList(hObject,handles);
handles.Cfg.SubjectID = get(handles.listboxSubject, 'String');
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
ReadDataList(hObject,handles);
handles = guidata(hObject); % weird feature of matlab, do not automatically retrieve and refresh handles
ShowDataList(hObject,handles);
guidata(hObject,handles);


% --- Executes on selection change in listboxSubject.
function listboxSubject_Callback(hObject, eventdata, handles)
% hObject    handle to listboxSubject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listboxSubject contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxSubject


% --- Executes during object creation, after setting all properties.
function listboxSubject_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxSubject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxEPIDCM2NII.
function checkboxEPIDCM2NII_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxEPIDCM2NII (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsNeedConvertFunDCM2IMG = get(handles.checkboxEPIDCM2NII,'Value');
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxEPIDCM2NII


% --- Executes on button press in checkboxT1DCM2NII.
function checkboxT1DCM2NII_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxT1DCM2NII (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsNeedConvertT1DCM2IMG = get(handles.checkboxT1DCM2NII,'Value');
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxT1DCM2NII


% --- Executes on button press in pushbuttonFieldMap.
function pushbuttonFieldMap_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonFieldMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiwait(msgbox({'';...
    'If you want to perform FieldMap Correction, you need to arrange each subject''s FieldMap DICOM files in one directory, and then put them in "FieldMap" directory under the working directory. i.e.:';...
    '{Working Directory}\FieldMap\PhaseDiffRaw\Subject001\xxxxx001.dcm';...
    '{Working Directory}\FieldMap\PhaseDiffRaw\Subject001\xxxxx002.dcm';...
    '...';...
    '{Working Directory}\FieldMap\PhaseDiffRaw\Subject002\xxxxx001.dcm';...
    '{Working Directory}\FieldMap\PhaseDiffRaw\Subject002\xxxxx002.dcm';...
    '...';...
    '{Working Directory}\FieldMap\Magnitude1Raw\Subject001\xxxxx001.dcm';...
    '{Working Directory}\FieldMap\Magnitude1Raw\Subject001\xxxxx002.dcm';...
    '...';...
    '{Working Directory}\FieldMap\Magnitude1Raw\Subject002\xxxxx001.dcm';...
    '{Working Directory}\FieldMap\Magnitude1Raw\Subject002\xxxxx002.dcm';...
    '...';...
    '...';...
    },'FieldMap Correction'));

if isfield(handles.Cfg,'FieldMap')
    handles.Cfg.FieldMap = DPABISurf_FieldMap(handles.Cfg.FieldMap);
else
    handles.Cfg.FieldMap = DPABISurf_FieldMap;
end
guidata(hObject, handles);


% --- Executes on button press in checkboxRemoveTimePoint.
function checkboxRemoveTimePoint_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxRemoveTimePoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsRemoveFirstTimePoints = get(handles.checkboxRemoveTimePoint,'Value');
handles.Cfg.RemoveFirstTimePoints = handles.Cfg.IsRemoveFirstTimePoints * handles.Cfg.RemoveFirstTimePoints;
UpdateDisplay_RemoveTimePoint(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxRemoveTimePoint



function editRemoveTimePoint_Callback(hObject, eventdata, handles)
% hObject    handle to editRemoveTimePoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.RemoveFirstTimePoints = str2double(get(handles.editRemoveTimePoint,'String'));
handles.Cfg.RemoveFirstTimePoints = handles.Cfg.IsRemoveFirstTimePoints * handles.Cfg.RemoveFirstTimePoints;
UpdateDisplay_RemoveTimePoint(handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editRemoveTimePoint as text
%        str2double(get(hObject,'String')) returns contents of editRemoveTimePoint as a double


% --- Executes during object creation, after setting all properties.
function editRemoveTimePoint_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRemoveTimePoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxDeface.
function checkboxDeface_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxDeface (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsDeface = get(handles.checkboxDeface,'Value');
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxDeface


% --- Executes on button press in pushbuttonRun.
function pushbuttonRun_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Cfg=handles.Cfg; 

Cfg.SliceTiming.SliceNumber=0;
Cfg.IsConvert2BIDS=1;
DPABI_BIDS_Converter_run(Cfg);



function UpdateDisplay_RemoveTimePoint(handles)
set(handles.editRemoveTimePoint,'String',handles.Cfg.RemoveFirstTimePoints);
set(handles.checkboxRemoveTimePoint,'Value',handles.Cfg.IsRemoveFirstTimePoints);

if handles.Cfg.IsRemoveFirstTimePoints
    set(handles.editRemoveTimePoint,'Enable','on');
else
    set(handles.editRemoveTimePoint,'Enable','off');
end


function ReadDataList(hObject, handles)
FullDir=handles.Cfg.WorkingDir;
StartingDir = handles.Cfg.StartingDirName;
% if isempty(FullDir) || ~isfolder(FullDir)
%     set(handles.listboxSubject, 'String', '', 'Value', 0);
%     return
% end
SubjStruct=dir([FullDir,filesep,StartingDir]);
Index=cellfun(...
    @(IsDir, NotDot) IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')), ...
    {SubjStruct.isdir}, {SubjStruct.name});  
SubjStruct=SubjStruct(Index);
SubjString={SubjStruct(:).name}';
handles.Cfg.SubjectID = SubjString;
guidata(hObject,handles);


function ShowDataList(hObject,handles)
%Create by Sandy to get the Subject List
%Edited by Bin to split display fuction and handle.cfg assignment
SubjString=handles.Cfg.SubjectID;
if ~iscell(SubjString) || isempty(SubjString)
    set(handles.listboxSubject, 'String', '', 'Value', 0);
else
    set(handles.listboxSubject, 'String', SubjString);
    set(handles.listboxSubject, 'Value', 1);
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
Value=get(handles.listboxSubject, 'Value');
if ~Value
    return
end
OneSubj=get(handles.listboxSubject, 'String');
OneSubj = OneSubj{Value};

if isempty(handles.Cfg.SubjectID)
    SubjString=get(handles.listboxSubject, 'String');
else
    SubjString=handles.Cfg.SubjectID;
end

Index=strcmpi(OneSubj, SubjString);
SubjString=SubjString(~Index);

handles.Cfg.SubjectID=SubjString;
guidata(hObject, handles);
ShowDataList(hObject,handles);


% --------------------------------------------------------------------
function LoadSubjectID_Callback(hObject, eventdata, handles)
% hObject    handle to LoadSubjectID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[SubID_Name , SubID_Path]=uigetfile({'*.txt','Subject ID Files (*.txt)';'*.*', 'All Files (*.*)';}, ...
    'Pick the text file for all the subject IDs');
SubID_File=[SubID_Path,SubID_Name];
if ischar(SubID_File)
    if exist(SubID_File,'file')==2
        fid = fopen(SubID_File);
        IDCell = textscan(fid,'%s\n'); %YAN Chao-Gan. For compatiblity of MALLAB 2014b. IDCell = textscan(fid,'%s','\n');
        fclose(fid);
        handles.Cfg.SubjectID=IDCell{1};
        guidata(hObject, handles);
        ShowDataList(hObject,handles);
    end
end


% --------------------------------------------------------------------
function RemoveAllSubjButton_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveAllSubjButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tmpMsg=sprintf('Delete all the participants?');
if strcmp(questdlg(tmpMsg, 'Delete confirmation'), 'Yes')
    handles.Cfg.SubjectID={};
    guidata(hObject, handles);
    ShowDataList(hObject,handles);
end


% --------------------------------------------------------------------
function SaveSubjectID_Callback(hObject, eventdata, handles)
% hObject    handle to SaveSubjectID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[SubID_Name , SubID_Path]=uiputfile({'*.txt','Subject ID Files (*.txt)';'*.*', 'All Files (*.*)';}, ...
    'Specify a text file to save all the subject IDs');
SubID_File=[SubID_Path,SubID_Name];
if ischar(SubID_File)
    fid = fopen(SubID_File,'w');
    for iSub=1:length(handles.Cfg.SubjectID)
        fprintf(fid,'%s\n',handles.Cfg.SubjectID{iSub});
    end
    fclose(fid);
end



function editFunctionalSession_Callback(hObject, eventdata, handles)
% hObject    handle to editFunctionalSession (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.FunctionalSessionNumber = str2double(get(handles.editFunctionalSession,'String'));
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editFunctionalSession as text
%        str2double(get(hObject,'String')) returns contents of editFunctionalSession as a double


% --- Executes during object creation, after setting all properties.
function editFunctionalSession_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFunctionalSession (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editStartingDir_Callback(hObject, eventdata, handles)
% hObject    handle to editStartingDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.StartingDirName = get(handles.editStartingDir,'String');
guidata(hObject,handles);
ReadDataList(hObject,handles);
handles = guidata(hObject);
ShowDataList(hObject,handles);
handles.Cfg.SubjectID = get(handles.listboxSubject, 'String');
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editStartingDir as text
%        str2double(get(hObject,'String')) returns contents of editStartingDir as a double


% --- Executes during object creation, after setting all properties.
function editStartingDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStartingDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
