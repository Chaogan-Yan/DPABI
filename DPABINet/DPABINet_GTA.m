function varargout = DPABINet_GTA(varargin)
% DPABINET_CONSTRUCTION MATLAB code for DPABINet_GTA.fig
%      DPABINET_CONSTRUCTION, by itself, creates a new DPABINET_CONSTRUCTION or raises the existing
%      singleton*.
%
%      H = DPABINET_CONSTRUCTION returns the handle to a new DPABINET_CONSTRUCTION or the handle to
%      the existing singleton*.
%
%      DPABINET_CONSTRUCTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABINET_CONSTRUCTION.M with the given input arguments.
%
%      DPABINET_CONSTRUCTION('Property','Value',...) creates a new DPABINET_CONSTRUCTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABINet_GTA_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABINet_GTA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABINet_GTA

% Last Modified by GUIDE v2.5 31-Mar-2021 23:59:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABINet_GTA_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABINet_GTA_OutputFcn, ...
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


% --- Executes just before DPABINet_GTA is made visible.
function DPABINet_GTA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABINet_GTA (see VARARGIN)


Release='V1.2_220915';
handles.Release = Release; % Will be used in mat file version checking (e.g., in function SetLoadedData)

if ispc
    UserName =getenv('USERNAME');
else
    UserName =getenv('USER');
end
Datetime=fix(clock);
fprintf('Welcome: %s, %.4d-%.2d-%.2d %.2d:%.2d \n', UserName,Datetime(1),Datetime(2),Datetime(3),Datetime(4),Datetime(5));
fprintf('DPABINet: A Toolbox for Brain Network and Graph Theoretical Analyses.\nRelease = %s\n',Release);
fprintf('Copyright(c) 2021; GNU GENERAL PUBLIC LICENSE\n');
fprintf('Institute of Psychology, Chinese Academy of Sciences, 16 Lincui Road, Chaoyang District, Beijing 100101, China; \n');
fprintf('Mail to Initiator:  <a href="ycg.yan@gmail.com">YAN Chao-Gan</a>\nProgrammers: YAN Chao-Gan; WANG Xin-Di; LU Bin; DENG Zhao-Yu\n<a href="http://rfmri.org/dpabi">http://rfmri.org/dpabi</a>\n');
fprintf('-----------------------------------------------------------\n');
fprintf('Citing Information:\nDPABINet is a toolbox for brain network and graph theoretical analyses, evolved from DPABI/DPABISurf/DPARSF, as easy-to-use as DPABI/DPABISurf/DPARSF. DPABINet is based on Brain Connectivity Toolbox (Rubinov and Sporns, 2010) (RRID:SCR_004841), FSLNets (http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSLNets; RRID: SCR_002823), BrainNet Viewer (Xia et al., 2013) (RRID:SCR_009446), circos (Krzywinski et al., 2009) (RRID:SCR_018207), SPM (Ashburner, 2012) (RRID:SCR_007037), PALM (Winkler et al., 2016), MATLAB (The MathWorks Inc., Natick, MA, US) (RRID:SCR_001622), Docker (https://docker.com) (RRID:SCR_016445) and DPABI (Yan et al., 2016) (RRID:SCR_010501). DPABINet provides user-friendly graphical user interface (GUI) for Brain network construction, graph theoretical analyses, statistical analyses and results viewing, while requires no programming/scripting skills from the users.\n');


Path = which('dpabi');
[filepath,name,ext] = fileparts(Path);
handles.Cfg.DPABIPath = filepath;

handles.Cfg.DPABINetVersion=Release;

handles.Cfg.DataDir = pwd; 
handles.Cfg.OutDir = pwd; 
handles.Cfg.SubjectID = '';
handles.Cfg.SubjectNum=length(handles.Cfg.SubjectID);
handles.Cfg.IsCalGTA = 1;
handles.Cfg.FilePrefix = 'NetworkMatrix_';
handles.Cfg.FileSuffix = '.mat';
handles.Cfg.SparsityRange = [0.01:0.01:0.5]';
handles.Cfg.SparsityRange_ForAUC = [0.10:0.01:0.34]';
handles.Cfg.NetworkWeighting = 'Weighted';
handles.Cfg.RandomTimes=100;

handles.Cfg.ParallelWorkersNumber = 0;
PCTVer = ver('distcomp');
if ~isempty(PCTVer)
    FullMatlabVersion = sscanf(version,'%d.%d.%d.%d%s');
    if FullMatlabVersion(1)*1000+FullMatlabVersion(2)<8*1000+3    %YAN Chao-Gan, 151117. If it's lower than MATLAB 2014a.  %FullMatlabVersion(1)*1000+FullMatlabVersion(2)>=7*1000+8    %YAN Chao-Gan, 120903. If it's higher than MATLAB 2008.
        CurrentSize_MatlabPool = matlabpool('size');
        handles.Cfg.ParallelWorkersNumber = CurrentSize_MatlabPool;
    else
        poolobj = gcp('nocreate'); % If no pool, do not create new one.
        if isempty(poolobj)
            CurrentSize_MatlabPool = 0;
        else
            CurrentSize_MatlabPool = poolobj.NumWorkers;
        end
        handles.Cfg.ParallelWorkersNumber = CurrentSize_MatlabPool;
    end
end

if ~ismac
    TextHandle = findall(handles.figDPABINet_GTA,'-property','FontSize');
    for i = 1:length(TextHandle)
        if strcmp(TextHandle(i).Type,'uicontrol')
            if strcmp(TextHandle(i).Style,'popupmenu')
                set(TextHandle(i), 'FontSize',0.4);
            else
                set(TextHandle(i), 'FontSize',0.58);
            end
        else
            set(TextHandle(i), 'FontUnits','points','FontSize',8);
        end
    end
    if ispc
        ZoonMatrix = [1 1 1.3 1.2];  %For pc
    else
        ZoonMatrix = [1 1 1.2 1.1];  %For Linux
    end
    UISize = get(handles.figDPABINet_GTA,'Position');
    UISize = UISize.*ZoonMatrix;
    set(handles.figDPABINet_GTA,'Position',UISize);
end
% Refresh the UI
UpdateDisplay(hObject,handles);
%uiwait(msgbox('Please cite: New small-world paper of Yan'))


% Choose default command line output for DPABINet_GTA
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABINet_GTA wait for user response (see UIRESUME)
% uiwait(handles.figDPABINet_GTA);


% --- Outputs from this function are returned to the command line.
function varargout = DPABINet_GTA_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function editPrefix_Callback(hObject, eventdata, handles)
% hObject    handle to editPrefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.FilePrefix = get(handles.editPrefix,'String');
ReadDataList(hObject,handles);
handles = guidata(hObject);
ShowDataList(hObject,handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editPrefix as text
%        str2double(get(hObject,'String')) returns contents of editPrefix as a double


% --- Executes during object creation, after setting all properties.
function editPrefix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPrefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSparsityAUC_Callback(hObject, eventdata, handles)
% hObject    handle to editSparsityAUC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SparsityRangeAUC=get(handles.editSparsityAUC,'String');
handles.Cfg.SparsityRange_ForAUC =eval(['[',SparsityRangeAUC,']']);;
handles.Cfg.SparsityRange_ForAUC = handles.Cfg.SparsityRange_ForAUC';
guidata(hObject, handles);
UpdateDisplay(hObject,handles)
% Hints: get(hObject,'String') returns contents of editSparsityAUC as text
%        str2double(get(hObject,'String')) returns contents of editSparsityAUC as a double


% --- Executes during object creation, after setting all properties.
function editSparsityAUC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSparsityAUC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSparsity_Callback(hObject, eventdata, handles)
% hObject    handle to editSparsity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SparsityRange=get(handles.editSparsity,'String');
handles.Cfg.SparsityRange =eval(['[',SparsityRange,']']);
handles.Cfg.SparsityRange = handles.Cfg.SparsityRange';
guidata(hObject, handles);
UpdateDisplay(hObject,handles)
% Hints: get(hObject,'String') returns contents of editSparsity as text
%        str2double(get(hObject,'String')) returns contents of editSparsity as a double


% --- Executes during object creation, after setting all properties.
function editSparsity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSparsity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuWeighting.
function popupmenuWeighting_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuWeighting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MethodType = get(handles.popupmenuWeighting,'Value');
switch MethodType
    case 1
        handles.Cfg.NetworkWeighting = 'Weighted';
    case 2
        handles.Cfg.NetworkWeighting = 'Binarized';
end
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuWeighting contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuWeighting


% --- Executes during object creation, after setting all properties.
function popupmenuWeighting_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuWeighting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editParallel_Callback(hObject, eventdata, handles)
% hObject    handle to editParallel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Size_MatlabPool =str2double(get(handles.editParallel,'String'));

% Check number of matlab workers. To start the matlabpool if Parallel Computation Toolbox is detected.
PCTVer = ver('distcomp');
if ~isempty(PCTVer)
    FullMatlabVersion = sscanf(version,'%d.%d.%d.%d%s');
    if FullMatlabVersion(1)*1000+FullMatlabVersion(2)<8*1000+3    %YAN Chao-Gan, 151117. If it's lower than MATLAB 2014a.  %FullMatlabVersion(1)*1000+FullMatlabVersion(2)>=7*1000+8    %YAN Chao-Gan, 120903. If it's higher than MATLAB 2008.
        if Size_MatlabPool ~= handles.Cfg.ParallelWorkersNumber
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
        if Size_MatlabPool ~= handles.Cfg.ParallelWorkersNumber
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
% Hints: get(hObject,'String') returns contents of editParallel as text
%        str2double(get(hObject,'String')) returns contents of editParallel as a double


% --- Executes during object creation, after setting all properties.
function editParallel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editParallel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uiputfile({'*.mat'}, 'Save Parameters As','Parameters_of_TDA');
if ischar(filename)
    Cfg=handles.Cfg;
    save(['',pathname,filename,''], 'Cfg');
end

% --- Executes on button press in pushbuttonLoad.
function pushbuttonLoad_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.mat'}, 'Load Parameters From');
if ischar(filename)
    load([pathname,filename]);
    handles.Cfg = Cfg;
end
guidata(hObject, handles);
UpdateDisplay(hObject,handles);


% --- Executes on button press in pushbuttonQuit.
function pushbuttonQuit_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonQuit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figDPABINet_GTA);


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


function editInputDir_Callback(hObject, eventdata, handles)
% hObject    handle to editInputDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ReadDataList(hObject,handles);
handles = guidata(hObject);
ShowDataList(hObject,handles);
handles.Cfg.SubjectID = get(handles.listboxSubject, 'String');
handles.Cfg.WorkingDir = get(handles.editInputDir,'String');
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
handles.Cfg.DataDir = get(handles.editInputDir,'String');
ReadDataList(hObject,handles);
handles = guidata(hObject); % weird feature of matlab, do not automatically retrieve and refresh handles
ShowDataList(hObject,handles);
guidata(hObject,handles);


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


function editSuffix_Callback(hObject, eventdata, handles)
% hObject    handle to editSuffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.FileSuffix = get(handles.editSuffix,'String');
ReadDataList(hObject,handles);
handles = guidata(hObject);
ShowDataList(hObject,handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editSuffix as text
%        str2double(get(hObject,'String')) returns contents of editSuffix as a double


% --- Executes during object creation, after setting all properties.
function editSuffix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSuffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editRandomTime_Callback(hObject, eventdata, handles)
% hObject    handle to editRandomTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.RandomTimes = str2num(get(handles.editRandomTime, 'String'));
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editRandomTime as text
%        str2double(get(hObject,'String')) returns contents of editRandomTime as a double


% --- Executes during object creation, after setting all properties.
function editRandomTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRandomTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editOutputDir_Callback(hObject, eventdata, handles)
% hObject    handle to editOutputDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.OutDir = get(handles.editOutputDir, 'String');
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editOutputDir as text
%        str2double(get(hObject,'String')) returns contents of editOutputDir as a double
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
handles.Cfg.OutDir = get(handles.editOutputDir, 'String');
guidata(hObject,handles);


% --- Executes on button press in pushbuttonRun.
function pushbuttonRun_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsCalGTA = 1;
handles.Cfg.SubjectNum=length(handles.Cfg.SubjectID);
Cfg=handles.Cfg; 
Datetime=fix(clock); 
save([pwd,filesep,'DPABINet_GTA_AutoSave_',num2str(Datetime(1)),'_',num2str(Datetime(2)),'_',num2str(Datetime(3)),'_',num2str(Datetime(4)),'_',num2str(Datetime(5)),'.mat'], 'Cfg'); %Added by YAN Chao-Gan, 100130.

[Error, Cfg]=DPABINet_GTA_run(Cfg);



function ReadDataList(hObject, handles)
FullDir=handles.Cfg.DataDir;
if isempty(FullDir) || ~isfolder(FullDir)
    set(handles.listboxSubject, 'String', '', 'Value', 0);
    return
end
SubjStruct=dir(FullDir);
Index=cellfun(...
    @(IsDir, NotDot) ~IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')) && ...
    (isempty(handles.Cfg.FilePrefix) || ~isempty(strfind(NotDot,handles.Cfg.FilePrefix))) && (isempty(handles.Cfg.FileSuffix) || ~isempty(strfind(NotDot,handles.Cfg.FileSuffix))), ...
    {SubjStruct.isdir}, {SubjStruct.name});  % drop out the files that are not MRI images
SubjStruct=SubjStruct(Index);
SubjString={SubjStruct(:).name}';

ShortList = cellfun(...
    @(Subject) Subject(length(handles.Cfg.FilePrefix)+1:end-length(handles.Cfg.FileSuffix)),...
    SubjString, 'UniformOutput', false);

handles.Cfg.SubjectID = ShortList;
guidata(hObject,handles);


function ShowDataList(hObject,handles)
%Create by Sandy to get the Subject List
%Edited by Bin to split display fuction and handle.cfg assignment
SubjString=handles.Cfg.SubjectID;
if ~iscell(SubjString) || isempty(SubjString)
    set(handles.listboxSubject, 'String', '', 'Value', 0);
else
%     ShortList = cellfun(...
%         @(Subject) Subject(length(handles.Cfg.FilePrefix)+1:end-length(handles.Cfg.FileSuffix)),...
%         SubjString, 'UniformOutput', false);
%     set(handles.listboxSubject, 'String', ShortList);
    set(handles.listboxSubject, 'String', SubjString);
    set(handles.listboxSubject, 'Value', 1);
end


%% Update All the uiControls' display on the GUI
function UpdateDisplay(hObject,handles)
set(handles.editInputDir,'String',handles.Cfg.DataDir);

if size(handles.Cfg.SubjectID,1)>0
    theOldIndex =get(handles.listboxSubject, 'Value');
    set(handles.listboxSubject, 'String',  handles.Cfg.SubjectID , 'Value', 1);
    theCount =size(handles.Cfg.SubjectID,1);
    if (theOldIndex>0) && (theOldIndex<= theCount) %%% keep the cruise at the position before (position 'value')
        set(handles.listboxSubject, 'Value', theOldIndex);
    end
else
    set(handles.listboxSubject, 'String', '' , 'Value', 0);
end

set(handles.editPrefix, 'String', handles.Cfg.FilePrefix);
set(handles.editSuffix, 'String', handles.Cfg.FileSuffix);
set(handles.editSparsity, 'String', ['[',num2str(handles.Cfg.SparsityRange'),']']);
set(handles.editSparsityAUC, 'String', ['[',num2str(handles.Cfg.SparsityRange_ForAUC'),']']);

switch lower(handles.Cfg.NetworkWeighting)
    case 'weighted'
        set(handles.popupmenuWeighting, 'Value', 1);
    case 'binarized'
        set(handles.popupmenuWeighting, 'Value', 2);
end

set(handles.editRandomTime, 'String', handles.Cfg.RandomTimes);
set(handles.editOutputDir, 'String', handles.Cfg.OutDir);
set(handles.editParallel, 'String', handles.Cfg.ParallelWorkersNumber);
ShowDataList(hObject,handles)


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
%OneSubj=[handles.Cfg.FilePrefix,OneSubj{Value},handles.Cfg.FileSuffix]; % For DPABINet

if isempty(handles.Cfg.SubjectID)
    SubjString=get(handles.listboxSubject, 'String');
%     SubjString = cellfun(...
%     @(Subject) [handles.Cfg.FilePrefix,Subject,handles.Cfg.FileSuffix],...
%     SubjString, 'UniformOutput', false);
else
    SubjString=handles.Cfg.SubjectID;
end

Index=strcmpi(OneSubj, SubjString);
SubjString=SubjString(~Index);

handles.Cfg.SubjectID=SubjString;
guidata(hObject, handles);
ShowDataList(hObject,handles);


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
