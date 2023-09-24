function varargout = Linear_settings(varargin)
% LINEAR_SETTINGS MATLAB code for Linear_settings.fig
%      LINEAR_SETTINGS, by itself, creates a new LINEAR_SETTINGS or raises the existing
%      singleton*.
%
%      H = LINEAR_SETTINGS returns the handle to a new LINEAR_SETTINGS or the handle to
%      the existing singleton*.
%
%      LINEAR_SETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LINEAR_SETTINGS.M with the given input arguments.
%
%      LINEAR_SETTINGS('Property','Value',...) creates a new LINEAR_SETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Linear_settings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Linear_settings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Linear_settings

% Last Modified by GUIDE v2.5 31-Aug-2023 17:43:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Linear_settings_OpeningFcn, ...
    'gui_OutputFcn',  @Linear_settings_OutputFcn, ...
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


% --- Executes just before Linear_settings is made visible.
function Linear_settings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Linear_settings (see VARARGIN)
handles.Cfg.SiteMatrix = [];
handles.Cfg.Cov = [];
handles.Cfg.LinearMode = [];
handles.Cfg.SiteName = [];
handles.Cfg.FileList = [];

handles.figure1.Resize = "on";
movegui(handles.figure1,'center');

h_linear = uicontextmenu;
set(handles.listboxAdjVar, 'UIContextMenu', h_linear);
uimenu(h_linear, 'Label', 'Remove', 'Callback', @(src, event) Linear_settings('DeleteSelectedAdjVar', src, event, guidata(src)));

% Choose default command line output for Linear_settings
handles.output = hObject;

if ismac
    zoom_factor=1;
elseif ispc
    zoom_factor=0.75;
else
    zoom_factor=0.9;
end

% Find and adjust font size for uicontrol elements
ui_handles = findall(handles.figure1, 'Type', 'uicontrol');
for idx = 1:length(ui_handles)
    currentSize = get(ui_handles(idx), 'FontSize');
    set(ui_handles(idx), 'FontSize', currentSize * zoom_factor);
end

% Update handles structure
guidata(hObject, handles);
try
	uiwait(handles.figure1);
catch
	uiresume(handles.figure1);
end
% UIWAIT makes Linear_settings wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Linear_settings_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles)
    handles.Cfg.SiteMatrix = [];
    handles.Cfg.Cov = [];
    handles.Cfg.LinearMode = [];
    handles.Cfg.SiteName = [];
    handles.Cfg.FileList = [];
else
    delete(handles.figure1);
end

varargout{1} = handles.Cfg.SiteMatrix;
varargout{2} = handles.Cfg.Cov;
varargout{3} = handles.Cfg.LinearMode;
varargout{4} = handles.Cfg.SiteName;
varargout{5} = handles.Cfg.FileList;
% Get default command line output from handles structure



% --- Executes on selection change in popupmenuLinearFamily.
function popupmenuLinearFamily_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuLinearFamily (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(hObject,'Value')
    case 2
        handles.Cfg.LinearMode = 1;
    case 3
        handles.Cfg.LinearMode = 2;
end
guidata(hObject,handles)
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuLinearFamily contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuLinearFamily


% --- Executes during object creation, after setting all properties.
function popupmenuLinearFamily_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuLinearFamily (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listboxAllVar.
function listboxAllVar_Callback(hObject, eventdata, handles)
% hObject    handle to listboxAllVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listboxAllVar contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxAllVar


% --- Executes during object creation, after setting all properties.
function listboxAllVar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxAllVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonAdd.
function pushbuttonAdd_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = get(handles.listboxAdjVar,'String');

allvar = get(handles.listboxAllVar,'String');
varIndex = char(get(handles.listboxAllVar,'Value'));
%handles.Cfg.Zname = [handles.Cfg.Zname;handles.Cfg.vars{varIndex}];
new = cellstr(allvar{varIndex});

%handles.Cfg.Cuts = [handles.Cfg.Cuts;strsplit(cut,',')];
contents = [contents;new];
handles.Cfg.AdjVar = contents;

set(handles.listboxAdjVar,'String',contents);
guidata(hObject, handles);


% --- Executes on selection change in listboxAdjVar.
function listboxAdjVar_Callback(hObject, eventdata, handles)
% hObject    handle to listboxAdjVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listboxAdjVar contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxAdjVar


% --- Executes during object creation, after setting all properties.
function listboxAdjVar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxAdjVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function DeleteSelectedAdjVar(hObject, eventdata, handles)
theIndex =get(handles.listboxAdjVar, 'Value');
contents =cellstr(get(handles.listboxAdjVar,'String'));
if size(contents, 1)==0 ...
        || theIndex>size(contents, 1)
    return;
end
theSubject=contents{theIndex};
tmpMsg=sprintf('Delete the : "%s" ?', theSubject);
if strcmp(questdlg(tmpMsg, 'Delete confirmation'), 'Yes')
    if theIndex>1
        set(handles.listboxAdjVar, 'Value', theIndex-1);
    end
    contents(theIndex)=[];
    newcontents = contents;
    
    handles.Cfg.AdjVar = contents;
    set(handles.listboxAdjVar,'String',contents);
    guidata(hObject, handles);
    
end

% --- Executes on button press in pushbuttonDemographicInfo.
function pushbuttonDemographicInfo_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDemographicInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file path]=uigetfile(...
    {'*.txt;*.csv;*.tsv;*.xlsx;*.mat',...
    'Your Demographic File (*.txt;*.csv;*.tsv,*.xlsx;*.mat)';...
    '*.*', 'All Files (*.*)';});
DemographicPath = [path file];

if (file==0)
    warndlg('If not, I will not do any harmonization...') ;
    
else
    set(handles.listboxAllVar,'String','');
    set(handles.listboxAdjVar,'String','');
    if strcmp('mat',file(end-2:end))
        handles.Cfg.var_struct = load(DemographicPath);
    else
        democells = readcell(DemographicPath);
        handles.Cfg.var_struct = splitmatrix(democells(2:end,:),democells(1,:),1);
    end
    
    if ~isfield(handles.Cfg.var_struct,"SiteName")
        error('Tip: Please name the variable of SiteID as SiteName so that we can recognize it.');
    else
        handles.Cfg.SiteName = all2cellstring(handles.Cfg.var_struct.SiteName);
    end
    
    handles.Cfg.vars = fieldnames(handles.Cfg.var_struct);
    set(handles.listboxAllVar,'String',cellstr(setdiff(handles.Cfg.vars,'SiteName')));
    
    UniSiteName = unique(handles.Cfg.SiteName);
    
    handles.Cfg.SiteNum = length(UniSiteName);
    handles.Cfg.SiteMatrix = zeros(length(handles.Cfg.SiteName),handles.Cfg.SiteNum);
    
    for i= 1:handles.Cfg.SiteNum
        handles.Cfg.SiteIndex{i} = find(contains(handles.Cfg.SiteName,UniSiteName{i}));
        handles.Cfg.SiteMatrix(strcmpi(UniSiteName{i},handles.Cfg.SiteName),i) = 1;
    end
    site_base_col = find(sum(handles.Cfg.SiteMatrix)==max(sum(handles.Cfg.SiteMatrix)));
    if length(site_base_col)>1
        handles.Cfg.SiteMatrix(:,site_base_col(1)) = [];
    else
        handles.Cfg.SiteMatrix(:,site_base_col) = [];
    end
    if isfield(handles.Cfg.var_struct,"FileList")
        handles.Cfg.FileList = handles.Cfg.var_struct.FileList;
    elseif isfield(handles.Cfg.var_struct,"FileListLH") && isfield(handles.Cfg.var_struct,"FileListRH")
        handles.Cfg.FileList.LH = handles.Cfg.var_struct.FileListLH;
        handles.Cfg.FileList.RH = handles.Cfg.var_struct.FileListRH;
    end
end
guidata(hObject,handles);

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



% --- Executes on button press in pushbuttonFinish.
function pushbuttonFinish_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonFinish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.listboxAdjVar)
    adjvars = cellstr(get(handles.listboxAdjVar,'String'));
    handles.Cfg.Cov = [];
    for i = 1:numel(adjvars)
        if ~isempty(adjvars{i})
            if eval(['size(handles.Cfg.var_struct.',adjvars{i},',2)'])>1
                fprintf("Error Tip: The %s has more than 1 columns. \n",adjvars{i});
                error("Notice: each variable should be N x 1 vector, N = the number of subjects.");
            end
            if iscell(eval(['handles.Cfg.var_struct.',adjvars{i},';']))
                eval(['handles.Cfg.mod(:,',num2str(i),')=cell2mat(handles.Cfg.var_struct.',adjvars{i},');']);
            else
                eval(['handles.Cfg.mod(:,',num2str(i),')=handles.Cfg.var_struct.',adjvars{i},';']);
            end
        end
    end
end
if isfield(handles,'Cfg')
    Cfg=handles.Cfg; %Added by YAN Chao-Gan, 100130. Save the configuration parameters automatically.
    Datetime=fix(clock); %Added by YAN Chao-Gan, 100130.
    save([pwd,filesep,'Harmonize_AutoSave_Linearsettings_',num2str(Datetime(1)),'_',num2str(Datetime(2)),'_',num2str(Datetime(3)),'_',num2str(Datetime(4)),'_',num2str(Datetime(5)),'.mat'], 'Cfg'); %Added by YAN Chao-Gan, 100130.
else
    warndlg('I got nothing to save.');
end
uiresume(handles.figure1);
guidata(hObject,handles);


% --- Executes on button press in pushbuttonLoad.
function pushbuttonLoad_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.mat'}, 'Load Parameters From');
if ischar(filename)
    load([pathname,filename]);
    SetLoadedData(hObject,handles, Cfg);
end


% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.listboxAdjVar)
    adjvars = cellstr(get(handles.listboxAdjVar,'String'));
    handles.Cfg.Cov = [];
    for i = 1:numel(adjvars)
        if ~isempty(adjvars{i})
            if eval(['size(handles.Cfg.var_struct.',adjvars{i},',2)'])>1
                fprintf("Error Tip: The %s has more than 1 columns. \n",adjvars{i});
                error("Notice: each variable should be N x 1 vector, N = the number of subjects.");
            end
            if iscell(eval(['handles.Cfg.var_struct.',adjvars{i},';']))
                eval(['handles.Cfg.mod(:,',num2str(i),')=cell2mat(handles.Cfg.var_struct.',adjvars{i},');']);
            else
                eval(['handles.Cfg.mod(:,',num2str(i),')=handles.Cfg.var_struct.',adjvars{i},';']);
            end
        end
    end
end
if isfield(handles,'Cfg')
    Cfg=handles.Cfg; %Added by YAN Chao-Gan, 100130. Save the configuration parameters automatically.
    Datetime=fix(clock); %Added by YAN Chao-Gan, 100130.
    save([pwd,filesep,'Harmonize_AutoSave_Linearsettings_',num2str(Datetime(1)),'_',num2str(Datetime(2)),'_',num2str(Datetime(3)),'_',num2str(Datetime(4)),'_',num2str(Datetime(5)),'.mat'], 'Cfg'); %Added by YAN Chao-Gan, 100130.
else
    warndlg('I got nothing to save.');
end
guidata(hObject,handles);

function SetLoadedData(hObject,handles,Cfg)
handles.Cfg=Cfg;

guidata(hObject,handles);
UpdateDisplay(handles);

%% Update All the uiControls' display on the GUI
function UpdateDisplay(handles)
set(handles.popupmenuLinearFamily,'Value', handles.Cfg.LinearMode+1);
set(handles.listboxAllVar,'String',setdiff(handles.Cfg.vars,'SiteName'),'Value',1);
if isfield(handles.Cfg,'AdjVar')
    set(handles.listboxAdjVar,'String',handles.Cfg.AdjVar,'Value',1);
else
    set(handles.listboxAdjVar,'String','');
end

drawnow;
