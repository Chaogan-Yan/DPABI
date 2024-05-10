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

% Last Modified by GUIDE v2.5 07-Apr-2024 10:22:10

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

fprintf('\nHarmonizing the brain images (.nii/.nii.gz/.gii/.mat) to remove site effects for big data in statistical analysis. \nReference: Wang, Y.W., Chen, X., Yan, C.G. (2023). Comprehensive evaluation of harmonization on functional brain imaging for multisite data-fusion. Neuroimage, 274, 120089, doi:10.1016/j.neuroimage.2023.120089.\n\n');

% [ProgramPath, fileN, extn] = fileparts(which('DPABI_Harmonization.m'));
% addpath(genpath([ProgramPath,filesep,'SubGUIs']));

% Initialize Cfg
handles.Cfg.FileList = []; %to create filelist
handles.Cfg.ImgCells = []; %to display data list
handles.Cfg.Mask = [];

handles.Cfg.DemographicPath =[]; % get from site ino
handles.Cfg.AllVars = [];
handles.Cfg.SiteName = [];
handles.Cfg.UniSiteName = [];
handles.Cfg.SiteNum = [];
handles.Cfg.SiteIndex = [];
handles.Cfg.Cov = [];

handles.Cfg.MethodName = []; % choose subgui (user)
handles.Cfg.AdjustInfo = []; % load the gui parameters

handles.Cfg.ParallelWorkersNumber=0;

handles.Cfg.OutputDir = []; 

handles.CurDir=pwd;
handles.SurfSpaceStatus=0;
%set(handles.OutputDirEntry, 'String', pwd);

% Choose default command line output for DPABI_Harmonization
handles.output = hObject;
%%%%
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


% --- Executes on button press in AddImgButton.
function AddImgButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddImgButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[File, Path]=uigetfile({'*.img;*.nii;*.nii.gz;*.mat;*.xlsx;*.csv',...
    'Brain Image Files (*.img;*.nii;*.nii.gz;*.mat;*.xlsx;*.csv)';'*.*', 'All Files (*.*)';}, ...
    'Pick Underlay File' , handles.CurDir, 'MultiSelect', 'On');

% If File is empty, return
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
    handles.Cfg.ImgCells=[handles.Cfg.ImgCells; ImgCell'];
    AddString(handles.ImgListbox, StringCell);
else
    ImgFile=fullfile(Path, File);
    handles.Cfg.ImgCells{numel(handles.Cfg.ImgCells)+1}=ImgFile;
    StringOne={sprintf('IMG: (%s) %s', File, ImgFile)};
    AddString(handles.ImgListbox, StringOne);
end
guidata(hObject, handles);


% --- Executes on button press in SiteInfoButton.
function SiteInfoButton_Callback(hObject, eventdata, handles)
% hObject    handle to SiteInfoButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function has been reconstructed, from within each Method to the main
% panel. This change incur the exchange of info between main and
% Methods(
%   Original: Methods(AdjustInfo) -->  Main; 
%   Now:      Methods(AdjustInfo) <--> Main(DemographicPath)

[SiteInfoFile SiteInfoPath]=uigetfile(...
    {'*.txt;*.csv;*.tsv;*.xlsx;*.mat',...
    'Your Demographic File (*.txt;*.csv;*.tsv;*.xlsx;*.mat)';...
    '*.*', 'All Files (*.*)';});
DemographicPath = [SiteInfoPath SiteInfoFile];
handles.Cfg.DemographicPath = DemographicPath; 

if (SiteInfoFile==0)
    warndlg('If not, I will not do any harmonization...') ;
else
    % Read .mat 
    if strcmp('mat',SiteInfoFile(end-2:end))
        handles.Cfg.AllVars = load(DemographicPath);
    % Read other formats    
    else
        democells = readcell(DemographicPath);
        handles.Cfg.AllVars = splitmatrix(democells(2:end,:),democells(1,:),1);
    end
    
    
    % Check -- Identify if it contains "SiteName"
    if ~isfield(handles.Cfg.AllVars,"SiteName")
        error('Tip: Please name the variable of SiteID as SiteName so that we can recognize it.');
    else
        % to handle the different data type of SiteNames, use all2cellstring 
        % [1,2,3] --> {'1','2','3'}
        % [a,b,c] --> {a,b,c}
        % {1,a,c,'1'} --> {'1',a,c,'1'}
        handles.Cfg.SiteName = all2cellstring(handles.Cfg.AllVars.SiteName);
    end
    
    % SiteName Stat %
    %   Get unique SiteNames (useful for those methods who follow the
    %   adaption logic, i.e. SMA and ICVAE etc.)
    handles.Cfg.UniSiteName = unique(handles.Cfg.SiteName);
    %   Get unique sites number
    handles.Cfg.SiteNum = length(handles.Cfg.UniSiteName);
    %   Each site's indexs in the sheet
    for i = 1:handles.Cfg.SiteNum
        handles.Cfg.SiteIndex{i} = find(strcmp(handles.Cfg.UniSiteName(i),handles.Cfg.SiteName));
    end
    
    handles.Cfg.Cov = rmfield(handles.Cfg.AllVars,"SiteName");
    
    % If exist 'FileList' colomn, import files based on list 
    if isfield(handles.Cfg.AllVars,"FileList")
        
        handles.Cfg.FileList = handles.Cfg.AllVars.FileList;
        
        % List them in the box ... 
        handles.Cfg.ImgCells = handles.Cfg.AllVars.FileList;
        set(handles.ImgListbox, 'String', []);
        AddString(handles.ImgListbox,handles.Cfg.ImgCells);
        
        
        % Remove FileList from covariate list
        handles.Cfg.Cov = rmfield(handles.Cfg.Cov,"FileList");
        
    elseif isfield(handles.Cfg.AllVars,"FileListLH") && isfield(handles.Cfg.AllVars,"FileListRH")
        handles.Cfg.FileList.LH = handles.Cfg.AllVars.FileListLH;
        handles.Cfg.FileList.RH = handles.Cfg.AllVars.FileListRH;

        
        [handles.Cfg.ImgCells.LH,handles.Cfg.ImgCells.RH,handles.Cfg.Mask.LH, handles.Cfg.Mask.RH] = SurfSpace(handles.Cfg.FileList.LH,handles.Cfg.FileList.RH,[],[]);
        set(handles.ImgListbox, 'String', '');
        Stringcell = cellstr('Your images are located in surface space, modify and check there！');
        AddString(handles.ImgListbox,Stringcell);
                
        handles.Cfg.Cov = rmfield(handles.Cfg.Cov,"FileListLH");
        handles.Cfg.Cov = rmfield(handles.Cfg.Cov,"FileListRH");
    end
end

guidata(hObject, handles);

function Vars = splitmatrix(mat,heads,by_col)
if by_col ~= 1 % split by row
    mat = mat';
end

if size(mat,2) == numel(heads)
    for i = 1:numel(heads)
        eval(['Vars.',heads{i},'= mat(:,i);']);
    end
else
    error('/n Unmatched number between variables and data columns. /n');
end

% --- Executes on button press in AddSiteButton.
function AddSiteButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddSiteButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[ImgCells,Strings] = addSites;
handles.Cfg.ImgCells = [handles.Cfg.ImgCells;ImgCells];

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
handles.Cfg.ImgCells(Value)=[];
RemoveString(handles.ImgListbox, Value);
guidata(hObject, handles);


% --- Executes on button press in SurfSpace.
function SurfSpace_Callback(hObject, eventdata, handles)
% hObject    handle to SurfSpace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Cfg=handles.Cfg;

if ~isfield(Cfg.ImgCells,'LH') || ~isfield(Cfg.ImgCells,'RH')
    [Cfg.ImgCells.LH,Cfg.ImgCells.RH,Cfg.Mask.LH,Cfg.Mask.RH] = SurfSpace;
elseif ~isfield(Cfg.Mask,'LH') || ~isfield(Cfg.Mask,'RH')
    [Cfg.ImgCells.LH,Cfg.ImgCells.RH,Cfg.Mask.LH,Cfg.Mask.RH] = SurfSpace(Cfg.ImgCells.LH,Cfg.ImgCells.RH,[],[]);
else
    [Cfg.ImgCells.LH,Cfg.ImgCells.RH,Cfg.Mask.LH,Cfg.Mask.RH] = SurfSpace(Cfg.ImgCells.LH,Cfg.ImgCells.RH,Cfg.Mask.LH,Cfg.Mask.RH);
end
    
if ~isempty(Cfg.ImgCells.LH) || ~isempty(Cfg.ImgCells.RH)...
        || ~isempty(Cfg.Mask.LH) || ~isempty(Cfg.Mask.RH)
    handles.SurfSpaceStatus = 1;
    set(handles.ImgListbox, 'String', '');
    Stringcell = cellstr('Your images are located in surface space, modify and check there！');
    AddString(handles.ImgListbox,Stringcell);
    
    set(handles.ImgListbox,'String',Stringcell,'Value',1);
    drawnow;
else
    handles.SurfSpaceStatus = 0;
end

handles.Cfg=Cfg;
guidata(hObject, handles);


function RemoveTable_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.ImgListbox, 'Value');
if Value==0
    return
end
handles.Cfg.ImgCells(Value)=[];
RemoveString(handles.ImgListbox, Value);
guidata(hObject, handles);

function RemoveAll_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.ImgListbox, 'String', '');
handles.Cfg.ImgCells={};

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

% --------------------------------------------------------------------
% --- Executes on button press in pushbuttonAdjust.
function pushbuttonAdjust_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAdjust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles.Cfg,'DemographicPath')
    error('Please give me the Site Info first.');
    return;
end

ValueString = get(handles.MethodsPopup, {'Value','String'}); %modified 2023/8/14
handles.Cfg.MethodName = ValueString{2}{ValueString{1}};
AdjustInfo = handles.Cfg.AdjustInfo;

switch ValueString{2}{ValueString{1}}
    case 'SMA'
       if isempty(AdjustInfo) || ~isfield(AdjustInfo,'TargetSiteIndex')
          AdjustInfo=[];
          [AdjustInfo.SiteIndex,AdjustInfo.TargetSiteIndex,AdjustInfo.Subgroups,AdjustInfo.SiteName,AdjustInfo.Zname,AdjustInfo.Cuts] = SMA_settings(handles.Cfg.SiteName,handles.Cfg.Cov);
       else
          [AdjustInfo.SiteIndex,AdjustInfo.TargetSiteIndex,AdjustInfo.Subgroups,AdjustInfo.SiteName,AdjustInfo.Zname,AdjustInfo.Cuts] = SMA_settings(AdjustInfo,handles.Cfg.Cov);
       end
    case 'ComBat/CovBat'
        if isempty(AdjustInfo) || ~isfield(AdjustInfo,'batch')
            AdjustInfo=[];
            [AdjustInfo.batch, AdjustInfo.mod,AdjustInfo.AdjVar, AdjustInfo.IsParametric,AdjustInfo.IsCovBat,AdjustInfo.IsCovBatParametric,AdjustInfo.PCA,AdjustInfo.Percent] = combat_settings(handles.Cfg.SiteName,handles.Cfg.Cov);
        else
            [AdjustInfo.batch,AdjustInfo.mod,AdjustInfo.AdjVar, AdjustInfo.IsParametric,AdjustInfo.IsCovBat,AdjustInfo.IsCovBatParametric,AdjustInfo.PCA,AdjustInfo.Percent] = combat_settings(AdjustInfo,handles.Cfg.Cov);
        end
    case 'ICVAE'
        if isempty(AdjustInfo) || ~isfield(AdjustInfo,'zTrain')
            [AdjustInfo.zTrain,AdjustInfo.zHarmonize,AdjustInfo.Target,AdjustInfo.SiteName] = ICVAE_settings(handles.Cfg.SiteName);
        else
            [AdjustInfo.zTrain,AdjustInfo.zHarmonize,AdjustInfo.Target,AdjustInfo.SiteName] = ICVAE_settings(AdjustInfo);
        end
    case 'Linear'
        if isempty(AdjustInfo) || ~isfield(AdjustInfo,'SiteMatrix')
            AdjustInfo=[];
            [AdjustInfo.SiteMatrix,AdjustInfo.AdjCov,AdjustInfo.AdjCname,AdjustInfo.LinearMode,AdjustInfo.SiteName] = Linear_settings(handles.Cfg.SiteName,handles.Cfg.Cov);
        else
            [AdjustInfo.SiteMatrix,AdjustInfo.AdjCov,AdjustInfo.AdjCname,AdjustInfo.LinearMode,AdjustInfo.SiteName] = Linear_settings(AdjustInfo,handles.Cfg.Cov);
        end
    otherwise
        error('When you got options, choose wisely.');
end

handles.Cfg.AdjustInfo = AdjustInfo;


guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of radiobuttonIsAdjust

% --------------------------------------------------------------------
% --- Executes on button press in ComputeButton.
function ComputeButton_Callback(hObject, eventdata, handles)
% hObject    handle to ComputeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 
% ValueString = get(handles.MethodsPopup, {'Value','String'}); %modified 24/03/28
% 
% handles.Cfg.MethodName = ValueString{2}{ValueString{1}};

set(handles.ComputeButton,'Enable', 'off','BackgroundColor', 'red','ForegroundColor','green');
   
handles.Cfg.OutputDir = get(handles.OutputDirEntry, 'String');
if isempty(handles.Cfg.OutputDir)
    handles.Cfg.OutputDir=handles.CurDir;
end

% this is for combat
if ~isfield(handles.Cfg.AdjustInfo,'SiteName')
    handles.Cfg.AdjustInfo.SiteName = handles.Cfg.SiteName;
end

if handles.SurfSpaceStatus == 0 & ~isstruct(handles.Cfg.FileList)
    if isempty(handles.Cfg.ImgCells)
        return          
    end
    
    ImgCells=handles.Cfg.ImgCells;

    MaskFile=handles.Cfg.Mask;
    
    yw_Harmonization(ImgCells, MaskFile, handles.Cfg.MethodName, handles.Cfg.AdjustInfo, handles.Cfg.ParallelWorkersNumber, handles.Cfg.OutputDir);
else
    LHImg = handles.Cfg.ImgCells.LH;
    RHImg = handles.Cfg.ImgCells.RH;
    LHMask = handles.Cfg.Mask.LH;
    RHMask = handles.Cfg.Mask.RH;
    yw_Harmonization_Surf(LHImg, RHImg, LHMask, RHMask, handles.Cfg.MethodName, handles.Cfg.AdjustInfo, handles.Cfg.ParallelWorkersNumber, handles.Cfg.OutputDir); 
end

%-------------------------------------------------------------------
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
Path=uigetdir('Pick Output Directory');
handles.Cfg.OutputDir = Path;
if isnumeric(Path)
    return
end
%handles.CurDir=fileparts(Path);
set(handles.OutputDirEntry, 'String', Path);
guidata(hObject, handles);



% --- Executes on button press in Maskpushbutton.
function Maskpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Maskpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA
[Name, Path]=uigetfile({'*.img;*.nii;*.nii.gz;*.mat',...
    'Brain Image Files (*.img;*.nii;*.nii.gz;*.mat)';...
    '*.*', 'All Files (*.*)';},...
    'Pick the Mask Image');
if isnumeric(Name)
    return
end
handles.Cfg.Mask = fullfile(Path, Name);
guidata(hObject, handles);


%
function cellstring = all2cellstring(array)
if ~iscell(array)
    if isnumeric(array)
        cellstring = cellstr(num2str(array));
    elseif isstring(array)
        cellstring = cellstr(array);
    end
else
    cellstring = array;
    where_is_num_cell = cell2mat(cellfun(@isnumeric,cellstring,...
    'UniformOutput',false));
    if any(where_is_num_cell)
        num_str= num2str(cell2mat(array(find(where_is_num_cell))));
        cellstring(find(where_is_num_cell)) = cellstr(num_str);
    end
end


% --- Executes on button press in CreateFileListpushbutton.
function CreateFileListpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to CreateFileListpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Cfg = handles.Cfg;

% make sure FileList or FileList.LH/RH
if handles.SurfSpaceStatus==1 % FileList.LH/RH
    FL = struct2table(Cfg.ImgCells);
    FL = renamevars(FL,{'LH','RH'},{'FileListLH','FileListRH'});
else
    FL = cell2table(Cfg.ImgCells,'VariableNames',{'FileList'});
end

if ~isfield(Cfg,'DemographicPath')
    warndlg('Feed me the file through Site Info button first. ');
elseif isempty(handles.Cfg.ImgCells)
    error('There is no images in Volume/General spave or Surface space. Add it first please.');
else  
   % output path
   [filedir,filename,ext] = fileparts(Cfg.DemographicPath);
   if strcmp(ext,'.mat') || strcmp(ext,'.txt') % we make new info file .csv/.xlsx/.tsv for they are easy to be checked by users visually 
       createfilepath = fullfile(filedir,['New_',filename,'.xlsx']);
   else
       createfilepath = fullfile(filedir,['New_',filename,ext]);
   end
   
   % check row number consistency
   oldsheet = struct2table(Cfg.AllVars);
   subnum = height(oldsheet);   
   
   if isfield(Cfg,'FileList')
       warndlg('If the original demographic file already has FileList colomn，this will replace it.');
       
       if height(FL) == subnum
           if isfield(Cfg,'Cov')
               sheet = [cell2table(Cfg.SiteName,'VariableNames',{'SiteName'}),struct2table(Cfg.Cov),FL];
               writetable(sheet,createfilepath);
           else
               sheet = [cell2table(Cfg.SiteName,'VariableNames',{'SiteName'}),FL];
               writetable(sheet,createfilepath);
           end
       else
           error('The dimension of FileList is not in consistent with Site Info file. Please check.')
       end
   else
       if height(FL) == subnum
           sheet = [struct2table(Cfg.AllVars),FL];
           writetable(sheet,createfilepath);
       else
           error('The dimension of FileList is not in consistent with Site Info file. Please check.')
       end
       
   end
end

% --- Executes on button press in ConfigSavepushbutton.
function ConfigSavepushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ConfigSavepushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'Cfg')
    Cfg=handles.Cfg; %Added by YAN Chao-Gan, 100130. Save the configuration parameters automatically.
    Datetime=fix(clock); %Added by YAN Chao-Gan, 100130.
    
    [filename,pathname] = uiputfile({'*.mat'},'Save Parameters As', ...
        ['Harmonize_',num2str(Datetime(1)),'_',num2str(Datetime(2)),'_',num2str(Datetime(3)),'_',num2str(Datetime(4)),'_',num2str(Datetime(5)),'.mat']);
    if ischar(filename)
        save(['',pathname,filename,''], 'Cfg'); %Added by YAN Chao-Gan, 100130.
    end
end


% --- Executes on button press in ConfigLoadpushbutton.
function ConfigLoadpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ConfigLoadpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.mat'}, 'Load Parameters From');
if ischar(filename)
    load([pathname,filename]);
    SetLoadedData(hObject,handles, Cfg);
end

function SetLoadedData(hObject,handles,Cfg)
    handles.Cfg=Cfg;
    guidata(hObject,handles);
    
    UpdateDisplay(hObject,handles);

%% Update All the uiControls' display on the GUI
function UpdateDisplay(hObject,handles)

if isempty(handles.Cfg.FileList) & numel(handles.Cfg.ImgCells)==1 
   handles.Cfg.FileList = handles.Cfg.ImgCells; %for organized data
end

Cfg = handles.Cfg;
% 1. Data and its display

if isstruct(Cfg.FileList)
    [Cfg.ImgCells.LH,Cfg.ImgCells.RH,Cfg.Mask.LH,Cfg.Mask.RH] = SurfSpace(Cfg.ImgCells.LH,Cfg.ImgCells.RH,Cfg.Mask.LH,Cfg.Mask.RH);
    
    handles.SurfSpaceStatus = 1;
    set(handles.ImgListbox, 'String', '');
    Stringcell = cellstr('Your images are located in surface space, modify and check there！');
    AddString(handles.ImgListbox,Stringcell);
    
    set(handles.ImgListbox,'String',Stringcell,'Value',1);
    
else
    set(handles.ImgListbox,'String',Cfg.FileList,'Value',1);
end

% 2. Method 
if isempty(Cfg.MethodName)
    set(handles.MethodsPopup,'Value', 1);
else   
    switch Cfg.MethodName
        case 'SMA'
            set(handles.MethodsPopup,'Value', 2);
            [AdjustInfo.SiteIndex,AdjustInfo.TargetSiteIndex,AdjustInfo.Subgroups,AdjustInfo.SiteName,AdjustInfo.Zname,AdjustInfo.Cuts] = SMA_settings(Cfg.AdjustInfo,Cfg.Cov);
        case 'ComBat/CovBat'
            set(handles.MethodsPopup,'Value', 3);
            [AdjustInfo.batch,AdjustInfo.mod,AdjustInfo.AdjVar, AdjustInfo.IsParametric,AdjustInfo.IsCovBat,AdjustInfo.IsCovBatParametric,AdjustInfo.PCA,AdjustInfo.Percent] = combat_settings(Cfg.AdjustInfo,Cfg.Cov);
        case 'ICVAE'
            set(handles.MethodsPopup,'Value', 4);
            [AdjustInfo.zTrain,AdjustInfo.zHarmonize,AdjustInfo.Target,AdjustInfo.SiteName]=ICVAE_settings(Cfg.AdjustInfo);
        case 'Linear'
            set(handles.MethodsPopup,'Value', 5);
            [AdjustInfo.SiteMatrix,AdjustInfo.AdjCov,AdjustInfo.AdjCname,AdjustInfo.LinearMode,AdjustInfo.SiteName] = Linear_settings(Cfg.AdjustInfo,Cfg.Cov);
    end
end
Cfg.AdjustInfo = AdjustInfo;

handles.Cfg = Cfg;
guidata(hObject,handles);

% 3. parallel
set(handles.editParallelWorkersNumber,'String',int2str(Cfg.ParallelWorkersNumber));

% 4. output
set(handles.OutputDirEntry,'String', Cfg.OutputDir);

    
    drawnow;
