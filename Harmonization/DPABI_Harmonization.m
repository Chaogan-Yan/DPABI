function varargout = DPABI_Harmonization(varargin)
% DPABI_Harmonization MATLAB code for DPABI_Harmonization.fig
%      DPABI_Harmonization, by itself, creates a new DPABI_Harmonization or raises the existing
%      singleton*.
%
%      H = DPABI_Harmonization returns the handle to a new DPABI_Harmonization or the handle to
%      the existing singleton*.
%
%      DPABI_Harmonization('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABI_Harmonization.M with the given input arguments.
%
%      DPABI_Harmonization('Property','Value',...) creates a new DPABI_Harmonization or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABI_Harmonization_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABI_Harmonization_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABI_Harmonization

% Last Modified by GUIDE v2.5 03-Aug-2023 21:29:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABI_Harmonization_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABI_Harmonization_OutputFcn, ...
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


% --- Executes just before DPABI_Harmonization is made visible.
function DPABI_Harmonization_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABI_Harmonization (see VARARGIN)

fprintf('Harmonize the brains for Statistical Analysis. \nRef: Wang YW, Chen X, Yan CG. Comprehensive evaluation of harmonization on functional brain imaging for multisite data-fusion. Neuroimage. 2023 Jul 1;274:120089. doi: 10.1016/j.neuroimage.2023.120089. Epub 2023 Apr 21. PMID: 37086875. \n');

[ProgramPath, fileN, extn] = fileparts(which('DPABI_Harmonization.m'));
addpath(genpath([ProgramPath,filesep,'SubGUIs']));
addpath(genpath([ProgramPath,filesep,'HarmonizationTools']));

handles.ImgCells={};
handles.CurDir=pwd;
handles.SurfSpaceStatus=0;

set(handles.OutputDirEntry, 'String', pwd);
% Choose default command line output for DPABI_Harmonization
handles.output = hObject;
handles.ParallelWorkersNumber=0;%%%%
    % Check number of matlab workers. To start the matlabpool if Parallel Computation Toolbox is detected.
    PCTVer = ver('distcomp');
    if ~isempty(PCTVer)
        FullMatlabVersion = sscanf(version,'%d.%d.%d.%d%s');
        if FullMatlabVersion(1)*1000+FullMatlabVersion(2)<8*1000+3    %YAN Chao-Gan, 151117. If it's lower than MATLAB 2014a.  %FullMatlabVersion(1)*1000+FullMatlabVersion(2)>=7*1000+8    %YAN Chao-Gan, 120903. If it's higher than MATLAB 2008.
            CurrentSize_MatlabPool = parpool('size');
            handles.ParallelWorkersNumber = CurrentSize_MatlabPool;
        else
            poolobj = gcp('nocreate'); % If no pool, do not create new one.
            if isempty(poolobj)
                CurrentSize_MatlabPool = 0;
            else
                CurrentSize_MatlabPool = poolobj.NumWorkers;
            end
            handles.ParallelWorkersNumber = CurrentSize_MatlabPool;
        end
    end
% Make UI display correct in PC and linux
if ~ismac
    if ispc
        ZoonMatrix = [1 1 1.5 1.2];  %For pc
    else
        ZoonMatrix = [1 1 1.5 1.2];  %For Linux
    end
    UISize = get(handles.figure1,'Position');
    UISize = UISize.*ZoonMatrix;
    set(handles.figure1,'Position',UISize);
end
movegui(handles.figure1,'center');

% %uimenu
hContextMenu = uicontextmenu;
set(handles.ImgListbox, 'UIContextMenu', hContextMenu);	%Added by YAN Chao-Gan 091110. Added popup menu to delete selected subject by right click
uimenu(hContextMenu, 'Label', 'Clear', 'Callback', 'DPABI_Harmonization(''RemoveAll_Callback'',gcbo,[], guidata(gcbo))');

% Update handles structure
guidata(hObject, handles);
% try
% 	uiwait(handles.figure1);
% catch
% 	uiresume(handles.figure1);
% end

% UIWAIT makes DPABI_Harmonization wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DPABI_Harmonization_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if ~isfield('output',handles)
    handles.output=[];
else
    delete(handles.figure1);
end
varargout{1} = handles.output;


% --- Executes on selection change in ImgListbox.
function ImgListbox_Callback(hObject, eventdata, handles)
% hObject    handle to ImgListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ImgListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ImgListbox


% --- Executes during object creation, after setting all properties.
function ImgListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImgListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in AddSiteButton.
function AddSiteButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddSiteButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[ImgCells,Strings] = addSites;
handles.ImgCells = [handles.ImgCells;ImgCells];

AddString(handles.ImgListbox, Strings);
guidata(hObject, handles);

% --- Executes on button press in RemoveButton.
function RemoveButton_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.ImgListbox, 'Value');
if Value==0
    return
end
handles.ImgCells(Value)=[];
RemoveString(handles.ImgListbox, Value);
guidata(hObject, handles);


function OutputDirEntry_Callback(hObject, eventdata, handles)
% hObject    handle to OutputDirEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OutputDirEntry as text
%        str2double(get(hObject,'String')) returns contents of OutputDirEntry as a double


% --- Executes during object creation, after setting all properties.
function OutputDirEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OutputDirEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
%   

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in OutputDirButton.
function OutputDirButton_Callback(hObject, eventdata, handles)
% hObject    handle to OutputDirButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=uigetdir(handles.CurDir, 'Pick Output Directory');
if isnumeric(Path)
    return
end
handles.CurDir=fileparts(Path);
set(handles.OutputDirEntry, 'String', Path);
guidata(hObject, handles);

% --- Executes on button press in ComputeButton.
function ComputeButton_Callback(hObject, eventdata, handles)
% hObject    handle to ComputeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

MethodType=get(handles.MethodsPopup, 'Value');

AdjustInfo = handles.AdjustInfo;

OutputDir=get(handles.OutputDirEntry, 'String');
if isempty(OutputDir)
    OutputDir=handles.CurDir;
end

if handles.SurfSpaceStatus == 0
    if isempty(handles.ImgCells)
        return
    end
    ImgCells=handles.ImgCells;

    MaskFile=get(handles.MaskEntry, 'String');
    
    yw_Harmonization(ImgCells, MaskFile, MethodType, AdjustInfo, OutputDir);
else
    LHImg = handles.LHImgCells;
    RHImg = handles.RHImgCells;
    LHMask = handles.MaskLH;
    RHMask = handles.MaskRH;
    yw_Harmonization_Surf(LHImg, RHImg, LHMask, RHMask, MethodType, AdjustInfo,  OutputDir); 
end


% --- Executes on button press in pushbuttonAdjust.
function pushbuttonAdjust_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAdjust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
value_string = get(handles.MethodsPopup, {'Value','String'}); %modified 2023/8/14

switch value_string{2}{value_string{1}}
    case 'SMA'
       [AdjustInfo.SiteIndex,AdjustInfo.TargetSiteIndex,AdjustInfo.Subgroups,AdjustInfo.SiteName,AdjustInfo.SiteName,AdjustInfo.FileList] = SMA_settings;
    case 'ComBat/CovBat'
       [AdjustInfo.batch,AdjustInfo.mod,AdjustInfo.isparametric,AdjustInfo.IsCovBat,AdjustInfo.IsCovBatParametric,AdjustInfo.PCAPercent,AdjustInfo.SiteName,AdjustInfo.FileList] = combat_settings;
    case 'ICVAE'
       [AdjustInfo.zTrain,AdjustInfo.zHarmonize,AdjustInfo.SiteName,AdjustInfo.FileList] = ICVAE_settings;
    case 'Linear'
        [AdjustInfo.SiteMatrix,AdjustInfo.Cov,AdjustInfo.LinearMode,AdjustInfo.SiteName,AdjustInfo.FileList] = Linear_settings;
    otherwise
        error('When you got options, choose wisely.');
end

% change FileList.LH/RH into FileListLH/RH, and for volume FileList 
if ~isempty(AdjustInfo.FileList) 
    if isstruct(AdjustInfo.FileList)
        handles.LHImgCells = AdjustInfo.FileList.LH;
        handles.RHImgCells = AdjustInfo.FileList.RH;
        
        handles.SurfSpaceStatus = 1;
        set(handles.ImgListbox, 'String', '');
        Stringcell = cellstr('Your images are located in surface space, modify and check there！');
        AddString(handles.ImgListbox,Stringcell);
        set(handles.MaskEntry,'Enable','off');
        set(handles.MaskButton,'Enable','off');
    else
        handles.ImgCells = AdjustInfo.FileList;
        set(handles.ImgListbox, 'String', []);
        AddString(handles.ImgListbox,handles.ImgCells);
    end
end
handles.AdjustInfo = AdjustInfo;
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of radiobuttonIsAdjust


% --------------------------------------------------------------------
function RemoveTable_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.ImgListbox, 'Value');
if Value==0
    return
end
handles.ImgCells(Value)=[];
RemoveString(handles.ImgListbox, Value);
guidata(hObject, handles);


% --------------------------------------------------------------------
function RemoveAll_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.ImgListbox, 'String', '');
handles.ImgCells={};

guidata(hObject, handles);

function ListContext_Callback(hObject, eventdata, handles)
% hObject    handle to ListContext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function [ImgCellList, String]=GetSubNameCell(Path)
ImgCellList = [];
String = [];

D=dir(fullfile(Path, ['*', '.img']));
if isempty(D)
    D=dir(fullfile(Path, ['*', '.nii']));
end
if isempty(D)
    D=dir(fullfile(Path, ['*', '.nii.gz']));
end

% if isempty(D)
%     D=dir(fullfile(Path, ['*', '.gii']));
% end

if isempty(D)
    D=dir(fullfile(Path, ['*', '.mat']));
end

NameCell={D.name}';

Num=numel(NameCell);
ImgCell=cellfun(@(Name) fullfile(Path, Name), NameCell,...
      'UniformOutput', false);
ImgCellList=[ImgCellList;ImgCell];

tmpString = [];
tmpString = cellfun(@(name) sprintf('IMG: (%s) %s',name, Path), NameCell,...
    'UniformOutput', false );
String = [String;tmpString];

function AddString(ListboxHandle, NewCell) 
StringCell=get(ListboxHandle, 'String');
if ~isempty(NewCell)
    if iscell(NewCell{1})
        StringCell=[StringCell; cellfun(@cell2mat,NewCell,'UniformOutput',false)];
    else
        StringCell=[StringCell;NewCell];
    end
end
set(ListboxHandle, 'String', StringCell, 'Value', numel(StringCell));


function RemoveString(ListboxHandle, Value)
StringCell=get(ListboxHandle, 'String');
StringCell(Value)=[];
if isempty(StringCell)
    Value=0; 
end
if Value > numel(StringCell)
    Value=Value-1;
end
set(ListboxHandle, 'String', StringCell, 'Value', Value);

function AddImgTable_Callback(hObject, eventdata, handles)
% hObject    handle to AddImgTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[File , Path]=uigetfile({'*.img;*.nii;*.nii.gz;*.mat',...
    'Brain Image Files (*.img;*.nii;*.nii.gz;*.mat)';'*.*', 'All Files (*.*)';}, ...
    'Pick Underlay File' , handles.CurDir, 'MultiSelect', 'On');
if isnumeric(File)
    return;
end

if iscell(File)
    N=numel(File);
    ImgCell=cell(1, N);
    StringCell=cell(N, 1);
    for i=1:N
        ImgFile=fullfile(Path, File{i});
        ImgCell{1, i}=ImgFile;
        StringCell{i, 1}=sprintf('IMG: (%s) %s', File{i}, ImgFile);
    end
    handles.ImgCells=[handles.ImgCells;ImgCell'];
    AddString(handles.ImgListbox, StringCell);
else
    ImgFile=fullfile(Path, File);
    handles.ImgCells{numel(handles.ImgCells)+1}=ImgFile;
    StringOne={sprintf('IMG: (%s) %s', File, ImgFile)};
    AddString(handles.ImgListbox, StringOne);
end
guidata(hObject, handles);


% --- Executes on button press in AddImgButton.
function AddImgButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddImgButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[File , Path]=uigetfile({'*.img;*.nii;*.nii.gz;*.mat',...
    'Brain Image Files (*.img;*.nii;*.nii.gz;*.mat)';'*.*', 'All Files (*.*)';}, ...
    'Pick Underlay File' , handles.CurDir, 'MultiSelect', 'On');
if isnumeric(File)
    return;
end

if iscell(File)
    N=numel(File);
    ImgCell=cell(1, N);
    StringCell=cell(N, 1);
    for i=1:N
        ImgFile=fullfile(Path, File{i});
        ImgCell{1, i}=ImgFile;
        StringCell{i, 1}=sprintf('IMG: (%s) %s', File{i}, ImgFile);
    end
    handles.ImgCells=[handles.ImgCells; ImgCell'];
    AddString(handles.ImgListbox, StringCell);
else
    ImgFile=fullfile(Path, File);
    handles.ImgCells{numel(handles.ImgCells)+1}=ImgFile;
    StringOne={sprintf('IMG: (%s) %s', File, ImgFile)};
    AddString(handles.ImgListbox, StringOne);
end
guidata(hObject, handles);


function editMask_Callback(hObject, eventdata, handles)
% hObject    handle to editMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMask as text
%        str2double(get(hObject,'String')) returns contents of editMask as
%        a double 


% --- Executes during object creation, after setting all properties.
function editMask_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MaskEntry_Callback(hObject, eventdata, handles)
% hObject    handle to MaskEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaskEntry as text
%        str2double(get(hObject,'String')) returns contents of MaskEntry as a double


% --- Executes during object creation, after setting all properties.
function MaskEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaskEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MaskButton.
function MaskButton_Callback(hObject, eventdata, handles)
% hObject    handle to MaskButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Name, Path]=uigetfile({'*.img;*.nii;*.nii.gz;*.mat',...
    'Brain Image Files (*.img;*.nii;*.nii.gz;*.mat)';...
    '*.*', 'All Files (*.*)';},...
    'Pick the Mask Image');
if isnumeric(Name)
    return
end
handles.Cfg.Mask = fullfile(Path, Name);
set(handles.MaskEntry, 'String', fullfile(Path, Name));


% --- Executes on selection change in MethodsPopup.
function MethodsPopup_Callback(hObject, eventdata, handles)
% hObject    handle to MethodsPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MethodsPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MethodsPopup


% --- Executes during object creation, after setting all properties.
function MethodsPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MethodsPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editParallelWorkersNumber_Callback(hObject, eventdata, handles)
% hObject    handle to editParallelWorkersNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editParallelWorkersNumber as text
%        str2double(get(hObject,'String')) returns contents of editParallelWorkersNumber as a double
    Size_MatlabPool =str2double(get(hObject,'String'));
    
    % Check number of matlab workers. To start the matlabpool if Parallel Computation Toolbox is detected.
    PCTVer = ver('distcomp');
    if ~isempty(PCTVer)
        FullMatlabVersion = sscanf(version,'%d.%d.%d.%d%s');
        if FullMatlabVersion(1)*1000+FullMatlabVersion(2)<8*1000+3    %YAN Chao-Gan, 151117. If it's lower than MATLAB 2014a.  %FullMatlabVersion(1)*1000+FullMatlabVersion(2)>=7*1000+8    %YAN Chao-Gan, 120903. If it's higher than MATLAB 2008.
            if Size_MatlabPool ~= handles.Cfg.ParallelWorkersNumber;
                if handles.ParallelWorkersNumber~=0
                    parpool close
                end
                if Size_MatlabPool~=0
                    parpool(Size_MatlabPool)
                end
            end
            CurrentSize_MatlabPool = parpool('size');
            handles.ParallelWorkersNumber = CurrentSize_MatlabPool;
        else
            if Size_MatlabPool ~= handles.ParallelWorkersNumber;
                if handles.ParallelWorkersNumber~=0
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
    

% --- Executes during object creation, after setting all properties.
function editParallelWorkersNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editParallelWorkersNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SurfSpace.
function SurfSpace_Callback(hObject, eventdata, handles)
% hObject    handle to SurfSpace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'LHImgCells') || ~isfield(handles,'RHImgCells')
    [handles.LHImgCells,handles.RHImgCells,handles.MaskLH,handles.MaskRH] = SurfSpace;
elseif ~isfield(handles,'MaskLH') || ~isfield(handles,'MaskRH')
    [handles.LHImgCells,handles.RHImgCells,handles.MaskLH,handles.MaskRH] = SurfSpace(handles.LHImgCells,handles.RHImgCells,[],[]);
else
    [handles.LHImgCells,handles.RHImgCells,handles.MaskLH,handles.MaskRH] = SurfSpace(handles.LHImgCells,handles.RHImgCells,handles.MaskLH,handles.MaskRH);
end
    
if ~isempty(handles.LHImgCells) || ~isempty(handles.RHImgCells)...
        || ~isempty(handles.MaskLH) || ~isempty(handles.MaskRH)
    handles.SurfSpaceStatus = 1;
    handles.ImgListbox = [];
    Stringcell = {'Your images are located in surf space, modify and check there！'};
    AddString(handles.ImgListbox, Stringcell);
    set(handles.ImgListbox,'String',Stringcell,'Value',1);
    drawnow;
    set(handles.MaskEntry,'Enable','off');
    set(handles.MaskButton,'Enable','off');
else
    handles.SurfSpaceStatus = 0;
end

guidata(hObject, handles);


% function stringarray = cell2string(cellarray)
% stringarray = cellarray;
% where_is_num_cell = cell2mat(cellfun(@isnumeric,cellarray,...
%     'UniformOutput',false));
% if all(where_is_num_cell)
%     stringarray = string(cell2mat(cellarray));
% elseif any(where_is_num_cell)
%     stringarray{where_is_num_cell} = string(cellarray{where_is_num_cell});
% end
