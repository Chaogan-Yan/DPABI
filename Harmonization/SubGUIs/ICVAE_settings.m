function varargout = ICVAE_settings(varargin)
% ICVAE_SETTINGS MATLAB code for ICVAE_settings.fig
%      ICVAE_SETTINGS, by itself, creates a new ICVAE_SETTINGS or raises the existing
%      singleton*.
%
%      H = ICVAE_SETTINGS returns the handle to a new ICVAE_SETTINGS or the handle to
%      the existing singleton*.
%
%      ICVAE_SETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ICVAE_SETTINGS.M with the given input arguments.
%
%      ICVAE_SETTINGS('Property','Value',...) creates a new ICVAE_SETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ICVAE_settings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ICVAE_settings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ICVAE_settings

% Last Modified by GUIDE v2.5 15-Sep-2023 11:39:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ICVAE_settings_OpeningFcn, ...
                   'gui_OutputFcn',  @ICVAE_settings_OutputFcn, ...
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


% --- Executes just before ICVAE_settings is made visible.
function ICVAE_settings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ICVAE_settings (see VARARGIN)

% Choose default command line output for ICVAE_settings
handles.output = hObject;

handles.Cfg.zTrain = [];
handles.Cfg.zHarmonize = [];
handles.Cfg.FileList = [];
handles.Cfg.SiteName = [];

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
% UIWAIT makes ICVAE_settings wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ICVAE_settings_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
     handles.Cfg.zTrain = [];
     handles.Cfg.zHarmonize = [];
     handles.Cfg.SiteName = [];
     handles.Cfg.FileList = [];
else
    delete(handles.figure1);
end

varargout{1} = handles.Cfg.zTrain;
varargout{2} = handles.Cfg.zHarmonize;
varargout{3} = handles.Cfg.SiteName;
varargout{4} = handles.Cfg.FileList;

% --- Executes on button press in pushbuttonSiteFile.
function pushbuttonSiteFile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSiteFile (see GCBO)
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
    if strcmp('mat',file(end-2:end))
        handles.var_struct = load(DemographicPath);
    else
        democells = readcell(DemographicPath);
        handles.var_struct = splitmatrix(democells(2:end,:),democells(1,:),1);
    end
    
    if ~isfield(handles.var_struct,"SiteName")
        error('Tip: Please name the variable of SiteID as SiteName so that we can recognize it.');
    else
        handles.Cfg.SiteName = all2cellstring(handles.var_struct.SiteName);
    end

    UniSiteName = unique(handles.Cfg.SiteName);
    set(handles.popupmenuTargetSite,'String',UniSiteName);
    
    handles.Cfg.SiteNum = length(UniSiteName);
    % initialize zTrain and zHarmonize
    handles.Cfg.zTrain = zeros(length(handles.Cfg.SiteName),handles.Cfg.SiteNum);
    handles.Cfg.zHarmonize = zeros(size(handles.Cfg.zTrain));
    
    for i= 1:handles.Cfg.SiteNum
        handles.Cfg.SiteIndex{i} =  (contains(handles.Cfg.SiteName,UniSiteName{i}));
        handles.Cfg.zTrain(strcmpi(UniSiteName{i},handles.Cfg.SiteName),i) = 1;
    end
    
    if isfield(handles.var_struct,"FileList")
        handles.Cfg.FileList = handles.var_struct.FileList;
    elseif isfield(handles.var_struct,"FileListLH") && isfield(handles.var_struct,"FileListRH")
        handles.Cfg.FileList.LH = handles.var_struct.FileListLH;
        handles.Cfg.FileList.RH = handles.var_struct.FileListRH;
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



% --- Executes on selection change in popupmenuTargetSite.
function popupmenuTargetSite_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuTargetSite (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ind =get(hObject,'Value');
if ~isnumeric(ind) || ind > handles.Cfg.SiteNum 
    return
end
handles.Cfg.zHarmonize(:,ind) = 1;
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuTargetSite contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuTargetSite


% --- Executes during object creation, after setting all properties.
function popupmenuTargetSite_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuTargetSite (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonFinish.
function pushbuttonFinish_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonFinish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume(handles.figure1);


% --- Executes on button press in pushbuttonPull.
function pushbuttonPull_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPull (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
system('docker pull cgyan/icvae');