function varargout = combat_settings(varargin)
% COMBAT_SETTINGS MATLAB code for combat_settings.fig
%      COMBAT_SETTINGS, by itself, creates a new COMBAT_SETTINGS or raises the existing
%      singleton*.
%
%      H = COMBAT_SETTINGS returns the handle to a new COMBAT_SETTINGS or the handle to
%      the existing singleton*.
%
%      COMBAT_SETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COMBAT_SETTINGS.M with the given input arguments.
%
%      COMBAT_SETTINGS('Property','Value',...) creates a new COMBAT_SETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before combat_settings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to combat_settings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help combat_settings

% Last Modified by GUIDE v2.5 17-Sep-2023 17:39:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @combat_settings_OpeningFcn, ...
                   'gui_OutputFcn',  @combat_settings_OutputFcn, ...
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


% --- Executes just before combat_settings is made visible.
function combat_settings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to combat_settings (see VARARGIN)

% Choose default command line output for combat_settings
handles.output = hObject;
            
handles.Cfg.IsCovBat = 0 ;
handles.Cfg.IsCovBatParametric = 0;
handles.Cfg.Percent = 0;
handles.Cfg.mod = [];   % in case there is no adjusted variable and the user
                        % did not create mod for this 
handles.Cfg.FileList = []; % if the user don't give FileList for ordering, 
                           % this should be empty 
% % %Make UI display correct in PC and linux
% if ~ismac
%     if ispc
%         ZoonMatrix = [1 1 1.5 1.2];  %For pc
%     else
%         ZoonMatrix = [1 1 1.5 1.2];  %For Linux
%     end
%     UISize = get(handles.figure1,'Position');
%     UISize = UISize.*ZoonMatrix;
%     set(handles.figure1,'Position',UISize);
% end
handles.figure1.Resize = "on";
movegui(handles.figure1,'center');

h_combat = uicontextmenu;
uimenu(h_combat, 'Label', 'Remove', 'Callback', @(src, event) combat_settings('DeleteSelectedAdjVar', src, event, guidata(src)));
set(handles.listboxAdjVar, 'UIContextMenu', h_combat);	

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
% UIWAIT makes combat_settings wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = combat_settings_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
     handles.Cfg.batch = [];
     handles.Cfg.mod = [];
     handles.Cfg.IsParametric = 0;
     
     handles.Cfg.IsCovBat = 0 ;
     handles.Cfg.IsCovBatParametric = 0;
     handles.Cfg.Percent = 0;
     
     handles.Cfg.SiteName = [];
     handles.Cfg.FileList = []; 
else
    delete(handles.figure1);
end
varargout{1} = handles.Cfg.batch;                                                                                            
varargout{2} = handles.Cfg.mod;
varargout{3} = handles.Cfg.IsParametric;
varargout{4} = handles.Cfg.IsCovBat;
varargout{5} = handles.Cfg.IsCovBatParametric;
varargout{6} = handles.Cfg.Percent;
varargout{7} = handles.Cfg.SiteName; %for writing harmonized data（Must）
varargout{8} = handles.Cfg.FileList;


% --- Executes on selection change in pushbuttonSiteInfo.
function pushbuttonSiteInfo_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSiteInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file path]=uigetfile(...
    {'*.txt;*.csv;*.tsv;*.xlsx;*.mat',...
    'Your Demographic File (*.txt;*.csv;*.tsv,*.xlsx;*.mat)';...
    '*.*', 'All Files (*.*)';});
DemographicPath = [path file];
handles.Cfg.DemographicPath = DemographicPath;


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
        SiteName = all2cellstring(handles.Cfg.var_struct.SiteName);
    end
    
    UniSiteName = unique(SiteName);
    handles.Cfg.SiteNum = length(UniSiteName);
    SiteLabel = zeros(size(SiteName));
    for i= 1:handles.Cfg.SiteNum
        handles.Cfg.SiteIndex{i} = find(contains(SiteName,UniSiteName{i}));
        SiteLabel(strcmpi(UniSiteName{i},SiteName)) = i;
    end
    handles.Cfg.batch=SiteLabel;
    
    if isfield(handles.Cfg.var_struct,"FileList")
        handles.Cfg.FileList = handles.Cfg.var_struct.FileList;
    elseif isfield(handles.Cfg.var_struct ,"FileListLH") && isfield(handles.Cfg.var_struct ,"FileListRH")
        handles.Cfg.FileList.LH = handles.Cfg.var_struct.FileListLH;
        handles.Cfg.FileList.RH = handles.Cfg.var_struct.FileListRH;
    end

    handles.Cfg.SiteName = SiteName;
    handles.Cfg.vars = fieldnames(handles.Cfg.var_struct);
    set(handles.listboxAllVar,'String',cellstr(setdiff(handles.Cfg.vars,'SiteName')));
end

guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns pushbuttonSiteInfo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pushbuttonSiteInfo

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

%  ------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function pushbuttonSiteInfo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbuttonSiteInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuParametricMode.
function popupmenuParametricMode_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuParametricMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(hObject,'Value')
    case 2 
        handles.Cfg.IsParametric = 1;
    case 3
        handles.Cfg.IsParametric = 2;
end
guidata(hObject,handles)  
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuParametricMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuParametricMode


% --- Executes during object creation, after setting all properties.
function popupmenuParametricMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuParametricMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkCovBat.
function checkCovBat_Callback(hObject, eventdata, handles)
% hObject    handle to checkCovBat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkCovBat

IsCovBat = get(hObject,'Value');
if IsCovBat
    set(handles.popupmenuParametricModeforCovBat,'Enable','on');
    set(handles.rbtDefault,'Enable','on');
    set(handles.rbtPercentage,'Enable','on');
    set(handles.rbtPCNumber,'Enable','on');
else
    set(handles.popupmenuParametricModeforCovBat,'Enable','off');
    set(handles.rbtDefault,'Enable','off');
    set(handles.rbtPercentage,'Enable','off');
    set(handles.rbtPCNumber,'Enable','off');
end

handles.Cfg.IsCovBat = IsCovBat;
guidata(hObject,handles) 

% --- Executes on selection change in popupmenuParametricModeforCovBat.
function popupmenuParametricModeforCovBat_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuParametricModeforCovBat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuParametricModeforCovBat contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuParametricModeforCovBat
switch get(hObject,'Value')
    case 2 
        handles.Cfg.IsCovBatParametric = 1;
    case 3
        handles.Cfg.IsCovBatParametric = 2;
end
guidata(hObject,handles)  


% --- Executes during object creation, after setting all properties.
function popupmenuParametricModeforCovBat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuParametricModeforCovBat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rbtDefault.
function rbtDefault_Callback(hObject, eventdata, handles)
% hObject    handle to rbtDefault (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbtDefault
if  get(hObject,'Value')
    set(handles.rbtPercentage,'Enable','off');
    set(handles.rbtPCNumber,'Enable','off');
else
    set(handles.rbtPercentage,'Enable','on');
    set(handles.rbtPCNumber,'Enable','on');
end

handles.Cfg.PCA = 'Default';
handles.Cfg.Percent = 0.95;
guidata(hObject,handles); 


% --- Executes on button press in rbtPCNumber.
function rbtPCNumber_Callback(hObject, eventdata, handles)
% hObject    handle to rbtPCNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbtPCNumber
if get(hObject,'Value')
    set(handles.rbtDefault,'Enable','off');
    set(handles.rbtPercentage,'Enable','off');
    set(handles.editNPC,'Enable','on');
else
    set(handles.rbtDefault,'Enable','on');
    set(handles.rbtPercentage,'Enable','on');
    set(handles.editNPC,'Enable','off');
end

handles.Cfg.PCA = 'NPC';
guidata(hObject,handles);


% --- Executes on button press in rbtPercentage.
function rbtPercentage_Callback(hObject, eventdata, handles)
% hObject    handle to rbtPercentage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbtPercentage
if get(hObject,'Value')
    set(handles.rbtDefault,'Enable','off');
    set(handles.rbtPCNumber,'Enable','off');
    set(handles.editPercent,'Enable','on');
else
    set(handles.rbtDefault,'Enable','on');
    set(handles.rbtPCNumber,'Enable','on');
    set(handles.editPercent,'Enable','off');
end

handles.Cfg.PCA = 'Percentage';
guidata(hObject,handles);

function editPercent_Callback(hObject, eventdata, handles)
% hObject    handle to editPercent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPercent as text
%        str2double(get(hObject,'String')) returns contents of editPercent as a double
p = str2num(get(hObject,'String'));
if p <= 1 && p >= 0
   handles.Cfg.Percent = p;
   guidata(hObject,handles) 
else
   error('Input should within the scale [0,1].');
end


% --- Executes during object creation, after setting all properties.
function editPercent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPercent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editNPC_Callback(hObject, eventdata, handles)
% hObject    handle to editNPC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNPC as text
%        str2double(get(hObject,'String')) returns contents of editNPC as a double
p = int8(str2num(get(hObject,'String')));
if isinteger(p) && p >= 1
   handles.Cfg.Percent = p;
   guidata(hObject,handles) 
else
   error('Input should be integer and not smaller than 1.');
end


% --- Executes during object creation, after setting all properties.
function editNPC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNPC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonVarVis.
function pushbuttonVarVis_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonVarVis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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


% --- Executes on button press in pushbuttonFinish.
function pushbuttonFinish_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonFinish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.listboxAdjVar)
    adjvars = cellstr(get(handles.listboxAdjVar,'String'));
    handles.Cfg.mod = [];
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

Cfg=handles.Cfg; 

Datetime=fix(clock); 
save([pwd,filesep,'Harmonize_AutoSave_combatsettings_',num2str(Datetime(1)),'_',num2str(Datetime(2)),'_',num2str(Datetime(3)),'_',num2str(Datetime(4)),'_',num2str(Datetime(5)),'.mat'], 'Cfg');
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

function SetLoadedData(hObject,handles,Cfg)
    handles.Cfg=Cfg;

    guidata(hObject,handles);
    UpdateDisplay(handles);

%% Update All the uiControls' display on the GUI
function UpdateDisplay(handles)
	set(handles.popupmenuParametricMode,'Value', handles.Cfg.IsParametric+1);	
    set(handles.listboxAllVar,'String',setdiff(handles.Cfg.vars,'SiteName'),'Value',1);
    if isfield(handles.Cfg,'AdjVar')
        set(handles.listboxAdjVar,'String',handles.Cfg.AdjVar,'Value',1);
    else
        set(handles.listboxAdjVar,'String','');
    end
    
    set(handles.checkCovBat,'Value',handles.Cfg.IsCovBat);    
    if handles.Cfg.IsCovBat 
        set(handles.popupmenuParametricModeforCovBat,'Enable','on','Value',handles.Cfg.IsCovBatParametric+1);
        switch handles.Cfg.PCA
            case 'Default'
                set(handles.rbtDefault,'Enable','on','Value',1); 
                
                set(handles.rbtPercentage,'Enable','off','Value',0); 
                set(handles.rbtPCNumber,'Enable','off','Value',0);
                set(handles.editPercent,'Enable','off','String','');
                set(handles.editNPC,'Enable','off','String','');
            case 'Percentage'
                set(handles.rbtPercentage,'Enable','on','Value',1);
                set(handles.editPercent,'Enable','on','String',num2str(handles.Cfg.Percent));
                
                set(handles.rbtDefault,'Enable','off','Value',0); 
                set(handles.rbtPCNumber,'Enable','off','Value',0);
                set(handles.editNPC,'Enable','off','String','');
                
            case 'NPC' 
                set(handles.rbtPCNumber,'Enable','on','Value',1);
                set(handles.editNPC,'Enable','on','String',int2str(handles.Cfg.Percent));
                
                set(handles.rbtDefault,'Enable','off','Value',0); 
                set(handles.rbtPercentage,'Enable','off','Value',0); 
                set(handles.editPercent,'Enable','off','String','');
        end
    else
        set(handles.popupmenuParametricModeforCovBat,'Enable','off','Value',1);
        set(handles.rbtDefault,'Enable','off','Value',0); 
        set(handles.rbtPercentage,'Enable','off','Value',0); 
        set(handles.rbtPCNumber,'Enable','off','Value',0);
        
        set(handles.editPercent,'Enable','off','String','');
        set(handles.editNPC,'Enable','off','String','');
    end
        
    drawnow;


% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.listboxAdjVar)
    adjvars = cellstr(get(handles.listboxAdjVar,'String'));
    handles.Cfg.mod = [];
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
    save([pwd,filesep,'Harmonize_AutoSave_combatsettings_',num2str(Datetime(1)),'_',num2str(Datetime(2)),'_',num2str(Datetime(3)),'_',num2str(Datetime(4)),'_',num2str(Datetime(5)),'.mat'], 'Cfg'); %Added by YAN Chao-Gan, 100130.
else
    warndlg('I got nothing to save.');
end
guidata(hObject,handles);
