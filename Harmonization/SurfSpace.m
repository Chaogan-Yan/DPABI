function varargout = SurfSpace(varargin)
% SURFSPACE MATLAB code for SurfSpace.fig
%      SURFSPACE, by itself, creates a new SURFSPACE or raises the existing
%      singleton*.
%
%      H = SURFSPACE returns the handle to a new SURFSPACE or the handle to
%      the existing singleton*.
%
%      SURFSPACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SURFSPACE.M with the given input arguments.
%
%      SURFSPACE('Property','Value',...) creates a new SURFSPACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SurfSpace_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SurfSpace_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SurfSpace

% Last Modified by GUIDE v2.5 04-Aug-2023 21:22:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SurfSpace_OpeningFcn, ...
                   'gui_OutputFcn',  @SurfSpace_OutputFcn, ...
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


% --- Executes just before SurfSpace is made visible.
function SurfSpace_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SurfSpace (see VARARGIN)

%fprintf('Standardize the brains for Statistical Analysis. \nRef: Yan, C.G., Craddock, R.C., Zuo, X.N., Zang, Y.F., Milham, M.P., 2013. Standardizing the intrinsic brain: towards robust measurement of inter-individual variation in 1000 functional connectomes. Neuroimage 80, 246-262.\n');
if nargin > 3
    handles.LHImgCells=varargin{1};
    AddString(handles.ImgLHlistbox, handles.LHImgCells);
    
    handles.RHImgCells=varargin{2};
    AddString(handles.ImgRHlistbox, handles.RHImgCells);
    
    handles.MaskLH = varargin{3};
    set(handles.MaskLHedit,'String',handles.MaskLH);
    
    handles.MaskRH = varargin{4};
    set(handles.MaskRHedit,'String',handles.MaskRH);
else
    handles.LHImgCells = {};
    handles.RHImgCells = {};
    handles.MaskLH = [];
    handles.MaskRH = [];
end    


handles.CurDir=pwd;

% %uimenu
%handles.lhContextMenu =uicontextmenu;
lhContextMenu = uicontextmenu;
uimenu(lhContextMenu, 'Label', 'Clear', 'Callback', 'SurfSpace(''RemoveAll_LH_Callback'',gcbo,[], guidata(gcbo))');
set(handles.ImgLHlistbox, 'UIContextMenu',lhContextMenu);	

rhContextMenu = uicontextmenu;	
uimenu(rhContextMenu, 'Label', 'Clear', 'Callback', 'SurfSpace(''RemoveAll_RH_Callback'',gcbo,[], guidata(gcbo))');
set(handles.ImgRHlistbox, 'UIContextMenu', rhContextMenu);

% Choose default command line output for SurfSpace
handles.output = hObject;


if ismac
    zoom_factor=1;
elseif ispc
    zoom_factor=0.8;
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
% UIWAIT makes SurfSpace wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SurfSpace_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    handles.LHImgCells = {};
    handles.RHImgCells = {};
    handles.MaskLH = [];
    handles.MaskRH = [];
else
    delete(handles.figure1);
end
varargout{1} = handles.LHImgCells;
varargout{2} = handles.RHImgCells;
varargout{3} = handles.MaskLH ;
varargout{4} = handles.MaskRH ;


% --- Executes on selection change in ImgLHlistbox.
function ImgLHlistbox_Callback(hObject, eventdata, handles)
% hObject    handle to ImgLHlistbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ImgLHlistbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ImgLHlistbox


% --- Executes during object creation, after setting all properties.
function ImgLHlistbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImgLHlistbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ImgRHlistbox.
function ImgRHlistbox_Callback(hObject, eventdata, handles)
% hObject    handle to ImgRHlistbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ImgRHlistbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ImgRHlistbox


% --- Executes during object creation, after setting all properties.
function ImgRHlistbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImgRHlistbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RemoveLHpushbutton.
function RemoveLHpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveLHpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.ImgLHlistbox, 'Value');
if Value==0
    return
end
handles.LHImgCells(Value)=[];
RemoveString(handles.ImgLHlistbox, Value);
guidata(hObject, handles);

% --- Executes on button press in AddImageLHpushbutton.
function AddImageLHpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to AddImageLHpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[File , Path]=uigetfile({'*.gii;*.gii.gz','Brain Image Files (*.gii;*.gii.gz)';'*.*', 'All Files (*.*)';}, ...
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
    handles.LHImgCells=[handles.LHImgCells, ImgCell];
    AddString(handles.ImgLHlistbox, StringCell);
else
    ImgFile=fullfile(Path, File);
    handles.LHImgCells{numel(handles.LHImgCells)+1}=ImgFile;
    StringOne={sprintf('IMG: (%s) %s', File, ImgFile)};
    AddString(handles.ImgLHlistbox, StringOne);
end
guidata(hObject, handles);


% --- Executes on button press in AddSiteLHpushbutton.
function AddSiteLHpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to AddSiteLHpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[ImgCells,Strings] = addSites;
if ~isempty(ImgCells)
    handles.LHImgCells = [handles.LHImgCells;ImgCells];
    AddString(handles.ImgLHlistbox, Strings);
end
guidata(hObject, handles);

% --- Executes on button press in RemoveRHpushbutton.
function RemoveRHpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveRHpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.ImgRHlistbox, 'Value');
if Value==0
    return
end
handles.RHImgCells(Value)=[];
RemoveString(handles.ImgRHlistbox, Value);
guidata(hObject, handles);

% --- Executes on button press in AddImageRHpushbutton.
function AddImageRHpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to AddImageRHpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[File , Path]=uigetfile({'*.gii;*.gii.gz','Brain Image Files (*.gii;*.gii.gz)';'*.*', 'All Files (*.*)';}, ...
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
    handles.RHImgCells=[handles.RHImgCells, ImgCell];
    AddString(handles.ImgRHlistbox, StringCell);
else
    ImgFile=fullfile(Path, File);
    handles.RHImgCells{numel(handles.RHImgCells)+1}=ImgFile;
    StringOne={sprintf('IMG: (%s) %s', File, ImgFile)};
    AddString(handles.ImgRHlistbox, StringOne);
end
guidata(hObject, handles);

% --- Executes on button press in AddSiteRHpushbutton.
function AddSiteRHpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to AddSiteRHpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[ImgCells,Strings] = addSites;
if ~isempty(ImgCells)
    handles.RHImgCells = [handles.RHImgCells;ImgCells];
    AddString(handles.ImgRHlistbox, Strings);
end
guidata(hObject, handles);


function MaskLHedit_Callback(hObject, eventdata, handles)
% hObject    handle to MaskLHedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaskLHedit as text
%        str2double(get(hObject,'String')) returns contents of MaskLHedit as a double


% --- Executes during object creation, after setting all properties.
function MaskLHedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaskLHedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaskRHedit_Callback(hObject, eventdata, handles)
% hObject    handle to MaskRHedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaskRHedit as text
%        str2double(get(hObject,'String')) returns contents of MaskRHedit as a double


% --- Executes during object creation, after setting all properties.
function MaskRHedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaskRHedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MaskLHpushbutton.
function MaskLHpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to MaskLHpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Name, Path]=uigetfile({'*.gii','Brain Image Files (*.gii)';'*.*', 'All Files (*.*)';},...
    'Pick the Mask Image');
if isnumeric(Name)
    return
end
set(handles.MaskLHedit, 'String', fullfile(Path, Name));

% --- Executes on button press in MaskRHpushbutton.
function MaskRHpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to MaskRHpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Name, Path]=uigetfile({'*.gii','Brain Image Files (*.gii)';'*.*', 'All Files (*.*)';},...
    'Pick the Mask Image');
if isnumeric(Name)
    return
end
set(handles.MaskRHedit, 'String', fullfile(Path, Name));

% --- Executes on button press in Finishpushbutton.
function Finishpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Finishpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.LHImgCells) || isempty(handles.RHImgCells)
    warndlg('At least give me the .giis of both left and right hemi，or you can click the window''s top-right X button. Notice, this will clear all contents of this window.');
    return
end

handles.MaskLH = get(handles.MaskLHedit,'String');
handles.MaskRH = get(handles.MaskRHedit,'String');

guidata(hObject, handles);
uiresume(handles.figure1);


%-------------------------------------------------------------------------
function AddString(ListboxHandle, NewCell) 
StringCell=get(ListboxHandle, 'String');
if ~isempty(NewCell)
    if iscell(NewCell{1})
        StringCell=[StringCell; cellfun(@cell2mat,NewCell,'UniformOutput',false)];
    else
        StringCell=[StringCell;NewCell];
    end
    set(ListboxHandle, 'String', StringCell, 'Value', numel(StringCell));
end

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

function RemoveAll_LH_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.ImgLHlistbox, 'String', '');
handles.LHImgCells={};

guidata(hObject, handles);

function RemoveAll_RH_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.ImgRHlistbox, 'String', '');
handles.RHImgCells={};

guidata(hObject, handles);
