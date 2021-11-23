function varargout = DPABI_Stability(varargin)
% DPABI_Stability MATLAB code for DPABI_Stability.fig
%      DPABI_Stability, by itself, creates a new DPABI_Stability or raises the existing
%      singleton*.
%
%      H = DPABI_Stability returns the handle to a new DPABI_Stability or the handle to
%      the existing singleton*.
%
%      DPABI_Stability('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABI_Stability.M with the given input arguments.
%
%      DPABI_Stability('Property','Value',...) creates a new DPABI_Stability or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABI_Stability_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABI_Stability_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABI_Stability

% Last Modified by GUIDE v2.5 26-Feb-2020 14:08:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABI_Stability_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABI_Stability_OutputFcn, ...
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


% --- Executes just before DPABI_Stability is made visible.
function DPABI_Stability_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABI_Stability (see VARARGIN)


% Set handles

if ~isempty(varargin)
    handles.Cfg.IsForDPABISurf=varargin{1};
else
    handles.Cfg.IsForDPABISurf=0;
end

handles.Cfg.WorkingDir = pwd; 
handles.Cfg.SubjectID = [];

handles.Cfg.WindowSize = 30;
handles.Cfg.WindowStep = 1;
handles.Cfg.WindowType = 'hamming';
handles.Cfg.IsDetrend = 1;

handles.Cfg.IsMultipleLabel = 1;
handles.Cfg.IsSmoothStability = 1; 
handles.Cfg.ParallelWorkersNumber = 0;
handles.Cfg.FunctionalSessionNumber = 1; 

handles.Cfg.DPABIPath = fileparts(which('dpabi'));
handles.Cfg.MaskFileSurfLH=fullfile(handles.Cfg.DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_lh_cortex.label.gii');
handles.Cfg.MaskFileSurfRH=fullfile(handles.Cfg.DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_rh_cortex.label.gii');
handles.Cfg.MaskFileVolu=fullfile(handles.Cfg.DPABIPath, 'Templates','GreyMask_02_61x73x61.img');

if handles.Cfg.IsForDPABISurf
    handles.Cfg.StartingDirName = 'FunSurfWCF';
    handles.Cfg.ROIDef = 'VertexToVertex';
    handles.Cfg.SmoothStability.FWHM = 6;
else
    handles.Cfg.StartingDirName = 'FunImgARCWF';
    handles.Cfg.ROIDef = 'VoxelToVoxel';
    handles.Cfg.SmoothStability.FWHM = [6 6 6];
end


% Refresh the UI
UpdateDisplay(handles);

uiwait(msgbox('Please cite: Li, L., Lu, B., Yan, C.G. (2019). Stability of dynamic functional architecture differs between brain networks and states. Neuroimage, 116230, doi:10.1016/j.neuroimage.2019.116230.'))


fprintf('\nDPABI Stability Analysis module is based on our previous work, please cite it if this module is used: \n');
fprintf('Li, L., Lu, B., Yan, C.G. (2019). Stability of dynamic functional architecture differs between brain networks and states. Neuroimage, 116230, doi:10.1016/j.neuroimage.2019.116230.\n');


% Make UI display correct in PC and linux
if ~ismac
    if ispc
        ZoonMatrix = [1 1 1 1.1];  %For pc
    else
        ZoonMatrix = [1 1 1.2 1.2];  %For Linux
    end
    UISize = get(handles.figDPABI_TDA,'Position');
    UISize = UISize.*ZoonMatrix;
    set(handles.figDPABI_TDA,'Position',UISize);
end
movegui(handles.figDPABI_TDA,'center');


% Choose default command line output for DPABI_Stability
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABI_Stability wait for user response (see UIRESUME)
% uiwait(handles.figDPABI_TDA);





% --- Outputs from this function are returned to the command line.
function varargout = DPABI_Stability_OutputFcn(hObject, eventdata, handles) 
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


% --- Executes on button press in rbtnVoxelToVoxel.
function rbtnVoxelToVoxel_Callback(hObject, eventdata, handles)
% hObject    handle to rbtnVoxelToVoxel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.rbtnVoxelToVoxel, 'Value', 1);
    set(handles.rbtnVoxelToAtlas, 'Value', 0);
    set(handles.btnDefineROI, 'Enable','off');
    
    if handles.Cfg.IsForDPABISurf
        handles.Cfg.ROIDef = 'VertexToVertex';
    else
        handles.Cfg.ROIDef = 'VoxelToVoxel';
    end
    
    guidata(hObject,handles);

% Hint: get(hObject,'Value') returns toggle state of rbtnVoxelToVoxel


% --- Executes on button press in rbtnVoxelToAtlas.
function rbtnVoxelToAtlas_Callback(hObject, eventdata, handles)
% hObject    handle to rbtnVoxelToAtlas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.rbtnVoxelToVoxel, 'Value', 0);
    set(handles.rbtnVoxelToAtlas, 'Value', 1);
    set(handles.btnDefineROI, 'Enable','on');
    
    if handles.Cfg.IsForDPABISurf
        handles.Cfg.ROIDef=[];
        handles.Cfg.ROIDef.Volume={};
        handles.Cfg.ROIDef.SurfLH={};
        handles.Cfg.ROIDef.SurfRH={};
    else
        handles.Cfg.ROIDef={};
    end

    handles.Cfg.ROIDef={};
    guidata(hObject,handles);
    
% Hint: get(hObject,'Value') returns toggle state of rbtnVoxelToAtlas



% --- Executes on button press in btnDefineROI.
function btnDefineROI_Callback(hObject, eventdata, handles)
% hObject    handle to btnDefineROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    if handles.Cfg.IsMultipleLabel
        fprintf('\nIsMultipleLabel is set to 1: There are multiple labels in the ROI mask file.\n');
    else
        fprintf('\nIsMultipleLabel is set to 0: All the non-zero values will be used to define the only ROI.\n');
    end

    ROIDef=handles.Cfg.ROIDef;

    if handles.Cfg.IsForDPABISurf
        [ROIDef,handles.Cfg.IsMultipleLabel]=DPABISurf_ROIList(ROIDef,handles.Cfg.IsMultipleLabel);
    else
        ROIDef=DPABI_ROIList(ROIDef);
    end
    handles.Cfg.ROIDef=ROIDef;

    guidata(hObject, handles);
    UpdateDisplay(handles);





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
[filename, pathname] = uiputfile({'*.mat'}, 'Save Parameters As','Parameters_of_Stability');
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
    
    guidata(hObject, handles);
    UpdateDisplay(handles);

% --- Executes on button press in btnQuit.
function btnQuit_Callback(hObject, eventdata, handles)
% hObject    handle to btnQuit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	close(handles.figDPABI_TDA);  




% --- Executes on button press in checkboxSmoothStability.
function checkboxSmoothStability_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSmoothStability (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.Cfg.IsSmoothStability = get(handles.checkboxSmoothStability,'Value');
    UpdateDisplay(handles);
    guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of checkboxSmoothStability



function editSmoothStabilityFWHM_Callback(hObject, eventdata, handles)
% hObject    handle to editSmoothStabilityFWHM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    FWHM = get(handles.editSmoothStabilityFWHM,'String');
    handles.Cfg.SmoothStability.FWHM =eval(['[',FWHM,']']);
    guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of editSmoothStabilityFWHM as text
%        str2double(get(hObject,'String')) returns contents of editSmoothStabilityFWHM as a double


% --- Executes during object creation, after setting all properties.
function editSmoothStabilityFWHM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSmoothStabilityFWHM (see GCBO)
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

    
    set(handles.checkboxSmoothStability,'Value',handles.Cfg.IsSmoothStability);
    set(handles.editSmoothStabilityFWHM,'String',mat2str(handles.Cfg.SmoothStability.FWHM));
    if handles.Cfg.IsSmoothStability
        set(handles.editSmoothStabilityFWHM,'Enable','on');
        set(handles.textSmoothStabilityFWHM,'Enable','on');
    else
        set(handles.editSmoothStabilityFWHM,'Enable','off');
        set(handles.textSmoothStabilityFWHM,'Enable','off');
    end 
    
    set(handles.editParallelWorkers,'String',num2str(handles.Cfg.ParallelWorkersNumber));
    set(handles.editFunctionalSessions,'String',num2str(handles.Cfg.FunctionalSessionNumber));
    
    if ischar(handles.Cfg.ROIDef) % 'VoxelToVoxel' or 'VertexToVertex'
        set(handles.rbtnVoxelToVoxel,'Value',1);
        set(handles.rbtnVoxelToAtlas,'Value',0);
        set(handles.btnDefineROI,'Enable','off');
    else
        set(handles.rbtnVoxelToVoxel,'Value',0);
        set(handles.rbtnVoxelToAtlas,'Value',1);
        set(handles.btnDefineROI,'Enable','on');
    end
    
    if handles.Cfg.IsForDPABISurf
        set(handles.textMaskSurf,'Visible','on');
        set(handles.textMaskLH,'Visible','on');
        set(handles.editMaskLH,'Visible','on');
        set(handles.pushbuttonMaskLH,'Visible','on');
        set(handles.textMaskRH,'Visible','on');
        set(handles.editMaskRH,'Visible','on');
        set(handles.pushbuttonMaskRH,'Visible','on');
        
        set(handles.textMaskVol,'Visible','off');
        set(handles.editMaskVolu,'Visible','off');
        set(handles.pushbuttonMaskVol,'Visible','off');
        
        set(handles.rbtnVoxelToVoxel,'String','Vertex-to-Vertex');
        set(handles.rbtnVoxelToAtlas,'String','Vertex-to-Atlas');
    else
        set(handles.textMaskSurf,'Visible','off');
        set(handles.textMaskLH,'Visible','off');
        set(handles.editMaskLH,'Visible','off');
        set(handles.pushbuttonMaskLH,'Visible','off');
        set(handles.textMaskRH,'Visible','off');
        set(handles.editMaskRH,'Visible','off');
        set(handles.pushbuttonMaskRH,'Visible','off');
        
        set(handles.textMaskVol,'Visible','on');
        set(handles.editMaskVolu,'Visible','on');
        set(handles.pushbuttonMaskVol,'Visible','on');
        
        set(handles.rbtnVoxelToVoxel,'String','Voxel-to-Voxel');
        set(handles.rbtnVoxelToAtlas,'String','Voxel-to-Atlas');
    end
    
    
    

% --- Executes on button press in btnRun.
function btnRun_Callback(hObject, eventdata, handles)
% hObject    handle to btnRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Cfg=handles.Cfg; 
Datetime=fix(clock); 
save([handles.Cfg.WorkingDir,filesep,'DPABI_Stability_AutoSave_',num2str(Datetime(1)),'_',num2str(Datetime(2)),'_',num2str(Datetime(3)),'_',num2str(Datetime(4)),'_',num2str(Datetime(5)),'.mat'], 'Cfg'); 

DPABI_Stability_run(handles.Cfg);
