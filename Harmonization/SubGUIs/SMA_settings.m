 function varargout = SMA_settings(varargin)
% SMA_settings MATLAB code for SMA_settings.fig
%      SMA_settings, by itself, creates a new SMA_settings or raises the existing
%      singleton*.
%
%      H = SMA_settings returns the handle to a new SMA_settings or the handle to
%      the existing singleton*.
%
%      SMA_settings('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SMA_settings.M with the given input arguments.
%
%      SMA_settings('Property','Value',...) creates a new SMA_settings or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SMA_settings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SMA_settings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SMA_settings

% Last Modified by GUIDE v2.5 18-Jul-2023 15:00:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SMA_settings_OpeningFcn, ...
                   'gui_OutputFcn',  @SMA_settings_OutputFcn, ...
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


% --- Executes just before SMA_settings is made visible.
function SMA_settings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SMA_settings (see VARARGIN)

warning off
%fprintf('Enjoy harmonizing your multisite data! \n');
% Choose default command line output for SMA_settings
handles.output = hObject;
% Release = 
% handles.Release = Release;

% Path = which('dpabi');
% [filepath,name,ext] = fileparts(Path);
% handles.Cfg.DPABIPath = filepath;

% Make UI display correct in PC and linux
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
movegui(handles.figure1,'center');

h_SMA = uicontextmenu;
set(handles.listboxZlist, 'UIContextMenu', h_SMA);

removeMenuItem = uimenu(h_SMA, 'Label', 'Remove');
set(removeMenuItem, 'Callback', @(src, event) DeleteSelectedZ(src, event, guidata(src)));

handles.Cfg.FileList = [];
handles.Cfg.Zname=[];
handles.Cfg.Cuts =[];
% Update handles structure

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

guidata(hObject, handles);

try
	uiwait(handles.figure1);
catch
	uiresume(handles.figure1);
end
%movegui(hObject,'center');


% UIWAIT makes SMA_settings wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SMA_settings_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
     handles.Cfg.SiteIndex = [];
     handles.Cfg.TargetSiteIndex = 0;
     handles.Cfg.Subgroups = [];
     handles.Cfg.UniSiteName = [];
     handles.Cfg.FileList = [];
     handles.Cfg.SiteName = [];
else
    delete(handles.figure1);
end

varargout{1} = handles.Cfg.SiteIndex;
varargout{2} = handles.Cfg.TargetSiteIndex;
varargout{3} = handles.Cfg.Subgroups;
varargout{4} = handles.Cfg.UniSiteName;
varargout{5} = handles.Cfg.SiteName; %for writing harmonized data
varargout{6} = handles.Cfg.FileList;


% --- Executes on selection change in pushbuttonSiteInfo.
function pushbuttonSiteInfo_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSiteInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%function load_Callback(hObject, eventdata, handles)

[file path]=uigetfile(...
    {'*.txt;*.csv;*.tsv;*.xlsx;*.mat',...
    'Your Demographic File (*.txt;*.csv;*.tsv;*.xlsx;*.mat)';...
    '*.*', 'All Files (*.*)';});
DemographicPath = [path file];
handles.Cfg.DemographicPath = DemographicPath;

if (file==0)
    warndlg('If not, I will not do any harmonization...') ;
else
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

    handles.Cfg.UniSiteName = unique(handles.Cfg.SiteName);
    handles.Cfg.SiteNum = length(handles.Cfg.UniSiteName);
    for i= 1:handles.Cfg.SiteNum
        handles.Cfg.SiteIndex{i} = find(strcmp(handles.Cfg.UniSiteName(i),handles.Cfg.SiteName));
    end
    set(handles.popupmenuTargetSiteChoice,'String',handles.Cfg.UniSiteName);

    handles.Cfg.TargetSiteIndex = get(hObject,'Value');
    
    if isfield(handles.Cfg.var_struct,"FileList")
        handles.Cfg.FileList = handles.Cfg.var_struct.FileList;
    elseif isfield(handles.Cfg.var_struct,"FileListLH") && isfield(handles.Cfg.var_struct,"FileListRH")
        handles.Cfg.FileList.LH = handles.Cfg.var_struct.FileListLH;
        handles.Cfg.FileList.RH = handles.Cfg.var_struct.FileListRH;
    end
    
    if get(handles.popupmenuFitMode,'Value')~=1 
    	set(handles.popupmenuFitMode,'Value',1);
        handles.Cfg.FitMode=-1;
        handles.Cfg.Zname=[];
        set(handles.listboxZlist,'String',[]);
        set(handles.listboxVar,'String',[]);
        UpdateDisplay(handles);
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

%  ------------------------------------------------------------------------
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


% --- Executes on selection change in listboxVar.
function listboxVar_Callback(hObject, eventdata, handles)
% hObject    handle to listboxVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%contents = cellstr(get(hObject,'String'))

% --- Executes during object creation, after setting all properties.
function listboxVar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject,handles);

% --- Executes on selection change in popupmenuFitMode.
function popupmenuFitMode_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuFitMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
varlist=[];
switch get(hObject,'Value')
    case 2
        warndlg('No subsampling, No Z.');
        set(handles.listboxVar,'String',[],'Value',0);
        set(handles.listboxZlist,'String',[])
        handles.Cfg.Zname = [];
        handles.Cfg.Cuts = [];
        handles.Cfg.FitMode=0;
        handles.Cfg.Subgroups =[];
    case 3
        varlist = cellstr(setdiff(handles.Cfg.vars,'SiteName'));
        set(handles.listboxVar,'Value',1);
        handles.Cfg.FitMode=1;
end
set(handles.listboxVar,'String',varlist);
guidata(hObject,handles)     

% --- Executes during object creation, after setting all properties.
function popupmenuFitMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuFitMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupmenuSiteChoice.
function popupmenuTargetSiteChoice_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSiteChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%contents = cellstr(get(hObject,'String'));

handles.Cfg.TargetSiteIndex = get(hObject,'Value')
guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function popupmenuTargetSiteChoice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSiteChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSubgroup.
function pushbuttonSubgroup_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSubgroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Z variates relabeling...
contents = cellstr(get(handles.listboxZlist,'String'))
handles.Cfg.Cuts=[];
handles.Cfg.Zname=[];
for i = 1:numel(contents)
    temp = strsplit(contents{i},'-Cuts:');
    handles.Cfg.Zname = [handles.Cfg.Zname;cellstr(temp{1})];
    handles.Cfg.Cuts = [handles.Cfg.Cuts;cellstr(temp{2})];
end

%load(handles.Cfg.DemographicPath);
RelabelingOrder = [];

for i = 1:numel(handles.Cfg.Cuts) %transfer chars to double and counts the classes
    cuts = str2double(strsplit(handles.Cfg.Cuts{i},','));
    if length(cuts)>1
        cutnum{i} = 1+numel(cuts);
        cut{i} = strcat('[',handles.Cfg.Cuts{i},']');
        fprintf('Continuous variable: %s is going to be divided into %d subgroups.',handles.Cfg.Zname{i},cutnum{i});
    elseif cuts ~= 0
        cutnum{i} = 2;
        cut{i} = handles.Cfg.Cuts{i};
        fprintf('Continuous variable: %s is going to be divided into 2 subgroups. \n',handles.Cfg.Zname{i});
    elseif cuts == 0
        fprintf('Categorical variable: %s is going to be divided into subgroups. \n',handles.Cfg.Zname{i});
        cut{i} = '0';
    end
    if i~=numel(handles.Cfg.Cuts)                                            
        RelabelingOrder = [RelabelingOrder,sprintf('handles.Cfg.var_struct.%s,%s,',handles.Cfg.Zname{i},cut{i})];
    else
        RelabelingOrder = [RelabelingOrder,sprintf('handles.Cfg.var_struct.%s,%s',handles.Cfg.Zname{i},cut{i})];
    end
end
handles.Cfg.Subgroups = eval(['yw_Relabeling(',RelabelingOrder,');']);

%-----------------Recommendation & Visulization----------------------------
handles.Cfg.SubgroupLabel = unique(handles.Cfg.Subgroups);
for isite = 1:handles.Cfg.SiteNum
    SubgoupLabel = handles.Cfg.Subgroups(handles.Cfg.SiteIndex{isite});
    proptable = tabulate(SubgoupLabel);
    for label = 1:length(handles.Cfg.SubgroupLabel)
        ind = find(proptable(:,1)==handles.Cfg.SubgroupLabel(label));
        if ~isempty(ind)
            prop(label,isite) = proptable(ind,3)/100; %percentage
        else 
            prop(label,isite) = 0;
        end
    end
end

% calculate kl
for isite = 1:handles.Cfg.SiteNum
    for jsite = 1:handles.Cfg.SiteNum
        KL_Dis(isite,jsite) = kldiv(handles.Cfg.SubgroupLabel,prop(:,isite),prop(:,jsite)+eps);
    end
end

for isite = 1:handles.Cfg.SiteNum
    ind = find(~isnan(KL_Dis(:,isite)));
    TargetIndex(isite) = mean(KL_Dis(ind,isite))/length(handles.Cfg.SiteIndex{isite});
end
[~,TargetsiteInd] = min(TargetIndex);
msgbox(sprintf('We recommend %s as the target site.',handles.Cfg.UniSiteName{TargetsiteInd}),'A Tip');

subfigure.title = handles.Cfg.UniSiteName;
subfigure.num = length(subfigure.title);
figure('Name','Subgroup Distribution')

for i = 1:subfigure.num
    subplot(subfigure.num,1,i)
    
    %ylabel(['site',num2str(subfigure.title(i))]);
    h1 = histogram(handles.Cfg.Subgroups(handles.Cfg.SiteIndex{i}));
    h1.FaceColor = [0.8 0.8 0.8];
    if i ~= subfigure.num
        set(gca,'XTick',[],'XTicklabel',[]);
    end 
    box off % remove box
    set(gcf,'color','w');
    if i~=TargetsiteInd
        title(subfigure.title{i});
    else
        title(strcat('\color{red}',subfigure.title{i},' (Recommended)'));
    end
    
    % this is where should resize the figure to fit the screen  
    
    xlim([0.5,max(handles.Cfg.Subgroups)+0.5]);
    xticks(1:1:max(handles.Cfg.Subgroups));
end

guidata(hObject,handles);
    
% % --- Executes on button press in pushbuttonAddZ.
function pushbuttonAddZ_Callback(hObject, eventdata, handles)
% % hObject    handle to pushbuttonAddZ (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
contents = get(handles.listboxZlist,'String')

varIndex = get(handles.listboxVar,'Value');
varNames = cellstr(get(handles.listboxVar,'String'));
%handles.Cfg.Zname = [handles.Cfg.Zname;handles.Cfg.vars{varIndex}];
cut = get(handles.editZcut,'String');
new = cellstr(strcat(varNames{varIndex},'-Cuts: ',char(cut)));

%handles.Cfg.Cuts = [handles.Cfg.Cuts;strsplit(cut,',')];
contents = [contents;new];

set(handles.listboxZlist,'String',contents);
guidata(hObject, handles);


% --- Executes on selection change in listboxZlist.
function listboxZlist_Callback(hObject, eventdata, handles)
% hObject    handle to listboxZlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listboxZlist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxZlist


% --- Executes during object creation, after setting all properties.
function listboxZlist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxZlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER. 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',[]);

function DeleteSelectedZ(hObject, eventdata, handles)	
	theIndex =get(handles.listboxZlist, 'Value');
    contents =cellstr(get(handles.listboxZlist,'String'));
	if size(contents, 1)==0 ...
		|| theIndex>size(contents, 1)
		return;
	end
	theSubject     =contents{theIndex};
	tmpMsg=sprintf('Delete the Z: "%s" ?', theSubject);
	if strcmp(questdlg(tmpMsg, 'Delete confirmation'), 'Yes')
		if theIndex>1
			set(handles.listboxZlist, 'Value', theIndex-1);
		end
		contents(theIndex)=[];
        newcontents = contents;

        set(handles.listboxZlist,'String',contents);
		guidata(hObject, handles);
		
end
    
function editZcut_Callback(hObject, eventdata, handles)
% hObject    handle to editZcut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editZcut as text
%        str2double(get(hObject,'String')) returns contents of editZcut as a double


% --- Executes during object creation, after setting all properties.
function editZcut_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editZcut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbuttonFinish.
function pushbuttonFinish_Callback(hObject, eventdata, handles)
    Cfg=handles.Cfg; %Added by YAN Chao-Gan, 100130. Save the configuration parameters automatically.
    Datetime=fix(clock); %Added by YAN Chao-Gan, 100130.
    save([pwd,filesep,'Harmonize_AutoSave_SMAsettings_',num2str(Datetime(1)),'_',num2str(Datetime(2)),'_',num2str(Datetime(3)),'_',num2str(Datetime(4)),'_',num2str(Datetime(5)),'.mat'], 'Cfg'); %Added by YAN Chao-Gan, 100130.
    uiresume(handles.figure1);


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
	set(handles.popupmenuFitMode,'Value', handles.Cfg.FitMode+2);	
    set(handles.popupmenuTargetSiteChoice,'String', handles.Cfg.UniSiteName, 'Value', handles.Cfg.TargetSiteIndex);
    if handles.Cfg.FitMode==1
        set(handles.listboxVar,'String',setdiff(handles.Cfg.vars,'SiteName'),'Value',1);
    else
        set(handles.listboxVar,'String',[]);
    end
    if ~isempty(handles.Cfg.Zname)
        set(handles.listboxZlist,'String',strcat(handles.Cfg.Zname,'-Cuts:',handles.Cfg.Cuts),'Value',1);
    else
        set(handles.listboxZlist,'String',[]);
    end
    
    drawnow;


% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'Cfg')
    Cfg=handles.Cfg; %Added by YAN Chao-Gan, 100130. Save the configuration parameters automatically.
    Datetime=fix(clock); %Added by YAN Chao-Gan, 100130.
    save([pwd,filesep,'Harmonize_AutoSave_SMAsettings_',num2str(Datetime(1)),'_',num2str(Datetime(2)),'_',num2str(Datetime(3)),'_',num2str(Datetime(4)),'_',num2str(Datetime(5)),'.mat'], 'Cfg'); %Added by YAN Chao-Gan, 100130.
else
    warndlg('I got nothing to save.');
end


% --- Executes on button  press in ExampleButton.
function ExampleButton_Callback(hObject, eventdata, handles)
% hObject    handle to ExampleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Specify the path to the text file you want to open
filePath = which('demographic_example.txt');

% Use the appropriate command to open the text file using the system's default text editor
if ispc
    % On Windows, use "notepad" to open the text file
    command = ['notepad "' filePath '"'];
elseif ismac
    % On macOS, use "open" to open the text file with the default text editor
    command = ['open "' filePath '"'];
elseif isunix
    % On Linux/Unix, you can use "xdg-open" to open the text file with the default text editor
    command = ['xdg-open "' filePath '"'];
else
    % Handle other operating systems here
    error('Unsupported operating system.');
end

% Use the system function to execute the command
[status, result] = system(command);

% Check if the command was executed successfully
if status == 0
    disp('Example file shown.');
else
    disp(['Error opening text file: ' result]);
end
