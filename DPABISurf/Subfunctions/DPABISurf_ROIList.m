function varargout = DPABISurf_ROIList(varargin)
% DPABI_ROILIST MATLAB code for DPABI_ROIList.fig
%      DPABI_ROILIST, by itself, creates a new DPABI_ROILIST or raises the existing
%      singleton*.
%
%      H = DPABI_ROILIST returns the handle to a new DPABI_ROILIST or the handle to
%      the existing singleton*.
%
%      DPABI_ROILIST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABI_ROILIST.M with the given input arguments.
%
%      DPABI_ROILIST('Property','Value',...) creates a new DPABI_ROILIST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABI_ROIList_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABI_ROIList_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABI_ROIList

% Last Modified by GUIDE v2.5 27-Dec-2022 16:57:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABI_ROIList_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABI_ROIList_OutputFcn, ...
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


% --- Executes just before DPABI_ROIList is made visible.
function DPABI_ROIList_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABI_ROIList (see VARARGIN)
if nargin > 3
    handles.Cfg=varargin{1};
    if ~isfield(handles.Cfg,'ROIDef')
        handles.Cfg.ROIDef.Volume={};
        handles.Cfg.ROIDef.SurfLH={};
        handles.Cfg.ROIDef.SurfRH={};
    end
    if ~isfield(handles.Cfg,'ROISelectedIndex')
        handles.Cfg.ROISelectedIndex.Volume = {};
        handles.Cfg.ROISelectedIndex.SurfLH = {};
        handles.Cfg.ROISelectedIndex.SurfRH = {};
    end
    if ~isfield(handles.Cfg,'IsMultipleLabel')
        handles.Cfg.IsMultipleLabel=1;
    end
    
    % recover handles.Cfg.ROIText for display
    handles.Cfg.ROIText.Volume=handles.Cfg.ROIDef.Volume;
    for i=1:numel(handles.Cfg.ROIText.Volume)
        if isnumeric(handles.Cfg.ROIText.Volume{i})
            s=handles.Cfg.ROIText.Volume{i};
            handles.Cfg.ROIText.Volume{i}=sprintf('Sphere ( X: %g -- Y: %g -- Z: %g >> Radius: %g )', s(1), s(2), s(3), s(4));
        else
            if ~isempty(handles.Cfg.ROISelectedIndex.Volume{i})
                handles.Cfg.ROIText.Volume{i} = ['[Selected ROI Indices] ',handles.Cfg.ROIText.Volume{i}];
            else
                handles.Cfg.ROIText.Volume{i} = ['[All ROI Indices] ',handles.Cfg.ROIText.Volume{i}];
            end
        end
    end
    handles.Cfg.ROIText.SurfLH=handles.Cfg.ROIDef.SurfLH;
    for i=1:numel(handles.Cfg.ROIText.SurfLH)
        if ~isempty(handles.Cfg.ROISelectedIndex.SurfLH{i})
            handles.Cfg.ROIText.SurfLH{i} = ['[Selected ROI Indices] ',handles.Cfg.ROIText.SurfLH{i}];
        else
            handles.Cfg.ROIText.SurfLH{i} = ['[All ROI Indices] ',handles.Cfg.ROIText.SurfLH{i}];
        end
    end
    handles.Cfg.ROIText.SurfRH=handles.Cfg.ROIDef.SurfRH;
    for i=1:numel(handles.Cfg.ROIText.SurfRH)
        if ~isempty(handles.Cfg.ROISelectedIndex.SurfRH{i})
            handles.Cfg.ROIText.SurfRH{i} = ['[Selected ROI Indices] ',handles.Cfg.ROIText.SurfRH{i}];
        else
            handles.Cfg.ROIText.SurfRH{i} = ['[All ROI Indices] ',handles.Cfg.ROIText.SurfRH{i}];
        end
    end
    set(handles.listboxROIList, 'String', handles.Cfg.ROIText.SurfLH);
else
    handles.Cfg.ROIDef.Volume={};
    handles.Cfg.ROIDef.SurfLH={};
    handles.Cfg.ROIDef.SurfRH={};
    handles.Cfg.ROISelectedIndex.Volume = {};
    handles.Cfg.ROISelectedIndex.SurfLH = {};
    handles.Cfg.ROISelectedIndex.SurfRH = {};
    handles.Cfg.ROIText.Volume = {};
    handles.Cfg.ROIText.SurfLH = {};
    handles.Cfg.ROIText.SurfRH = {};
    handles.Cfg.IsMultipleLabel=1;
end

handles.DisplayFlag = 'SurfLH';
set(handles.togglebuttonSurfaceLeft,'Value',1);
set(handles.togglebuttonSurfaceRight,'Value',0);
set(handles.togglebuttonVolume,'Value',0);
set(handles.pushbuttonSphere,'Enable','off');
set(handles.checkboxMultipleLabel,'Value',handles.Cfg.IsMultipleLabel);
% Update handles structure

% Make UI display correct in PC and linux
if ~ismac
    if ispc
        ZoonMatrix = [1 1 1.4 1.2];  %For pc
    else
        ZoonMatrix = [1 1 1 1];  %For Linux
    end
    UISize = get(handles.figure1,'Position');
    UISize = UISize.*ZoonMatrix;
    set(handles.figure1,'Position',UISize);
end

% Make Display correct in Mac and linux
if ~ispc
    if ismac
        ZoomFactor=1.4;  %For Mac
    else
        ZoomFactor=1;  %For Linux
    end
    ObjectNames = fieldnames(handles);
    for i=1:length(ObjectNames);
        eval(['IsFontSizeProp=isprop(handles.',ObjectNames{i},',''FontSize'');']);
        if IsFontSizeProp
            eval(['PCFontSize=get(handles.',ObjectNames{i},',''FontSize'');']);
            FontSize=PCFontSize*ZoomFactor;
            eval(['set(handles.',ObjectNames{i},',''FontSize'',',num2str(FontSize),');']);
        end
    end
end



movegui(handles.figure1,'center');

guidata(hObject, handles);

% UIWAIT makes DPABI_ROIList wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DPABI_ROIList_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    varargout{1}=[];
else
    varargout{1} = handles.Cfg;
    delete(handles.figure1);
end


% --- Executes on selection change in listboxROIList.
function listboxROIList_Callback(hObject, eventdata, handles)
% hObject    handle to listboxROIList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listboxROIList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxROIList


% --- Executes during object creation, after setting all properties.
function listboxROIList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxROIList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSphere.
function pushbuttonSphere_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSphere (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SphereCell=w_AddSphere_gui;
if isempty(SphereCell)
    return
end
[handles.Cfg.ROIDef.Volume,RepeatFlags]=GetROICell(SphereCell, handles.Cfg.ROIDef.Volume);
SphereCell(RepeatFlags) = [];

if ~isempty(SphereCell)
    handles.Cfg.ROISelectedIndex.Volume = [handles.Cfg.ROISelectedIndex.Volume;cell(length(SphereCell),1)];
    
    StringCell=handles.Cfg.ROIText.Volume;
    TextCell=cellfun(@(s) sprintf('Sphere ( X: %g -- Y: %g -- Z: %g >> Radius: %g )', s(1), s(2), s(3), s(4)), SphereCell,...
        'UniformOutput', false);
    StringCell=[StringCell;TextCell];
    
    set(handles.listboxROIList, 'String', StringCell, 'Value', numel(StringCell));
    handles = SaveCurrentROIText(handles);
    guidata(hObject, handles);
end


% --- Executes on button press in pushbuttonMask.
function pushbuttonMask_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch handles.DisplayFlag
    case 'Volume'
        [Name, Path]=uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';},...
            'Pick the Masks for Volume ROI', 'MultiSelect','on');
    case {'SurfLH' , 'SurfRH'}
        [Name, Path]=uigetfile({'*.gii','Brain Image Files (*.gii)';'*.*', 'All Files (*.*)';},...
            'Pick the Masks for Surface ROI', 'MultiSelect','on');
end
if isnumeric(Name)
    return
end

if ischar(Name)
    Name={Name};
end
Name=Name';
PathCell=cellfun(@(name) fullfile(Path, name), Name, 'UniformOutput', false);
switch handles.DisplayFlag
    case 'Volume'
        [handles.Cfg.ROIDef.Volume,RepeatFlags]=GetROICell(PathCell, handles.Cfg.ROIDef.Volume);
        handles.Cfg.ROISelectedIndex.Volume = [handles.Cfg.ROISelectedIndex.Volume;cell(length(PathCell)-length(find(RepeatFlags)),1)];
    case 'SurfLH'
        [handles.Cfg.ROIDef.SurfLH,RepeatFlags]=GetROICell(PathCell, handles.Cfg.ROIDef.SurfLH);
        handles.Cfg.ROISelectedIndex.SurfLH = [handles.Cfg.ROISelectedIndex.SurfLH;cell(length(PathCell)-length(find(RepeatFlags)),1)];
    case 'SurfRH'
        [handles.Cfg.ROIDef.SurfRH,RepeatFlags]=GetROICell(PathCell, handles.Cfg.ROIDef.SurfRH);
        handles.Cfg.ROISelectedIndex.SurfRH = [handles.Cfg.ROISelectedIndex.SurfRH;cell(length(PathCell)-length(find(RepeatFlags)),1)];
end
PathCell(RepeatFlags) = [];

if ~isempty(PathCell)
    StringCell=get(handles.listboxROIList, 'String');
    AddString=cellfun(@(Path) ['[All ROI Indices] ',Path], PathCell, 'UniformOutput', false);
    if isempty(StringCell)
        StringCell = AddString;
    else
        StringCell=[StringCell; AddString];
    end
    set(handles.listboxROIList, 'String', StringCell,'Value', numel(StringCell));
    handles = SaveCurrentROIText(handles);
    guidata(hObject, handles);
end


% --- Executes on button press in pushbuttonSeed.
function pushbuttonSeed_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Name, Path]=uigetfile({'*.txt;*.csv;*.tsv','Seed Series File (*.txt;*.csv;*.tsv)';'*.*', 'All Files (*.*)';},...
    'Pick the Seed Series for ROI', 'MultiSelect','on');
if isnumeric(Name)
    return
end

if ischar(Name)
    Name={Name};
end
Name=Name';
PathCell=cellfun(@(name) fullfile(Path, name), Name, 'UniformOutput', false);
switch handles.DisplayFlag
    case 'Volume'
        [handles.Cfg.ROIDef.Volume,RepeatFlags]=GetROICell(PathCell, handles.Cfg.ROIDef.Volume);
        handles.Cfg.ROISelectedIndex.Volume = [handles.Cfg.ROISelectedIndex.Volume;cell(length(PathCell)-length(find(RepeatFlags)),1)];
    case 'SurfLH'
        [handles.Cfg.ROIDef.SurfLH,RepeatFlags]=GetROICell(PathCell, handles.Cfg.ROIDef.SurfLH);
        handles.Cfg.ROISelectedIndex.SurfLH = [handles.Cfg.ROISelectedIndex.SurfLH;cell(length(PathCell)-length(find(RepeatFlags)),1)];
    case 'SurfRH'
        [handles.Cfg.ROIDef.SurfRH,RepeatFlags]=GetROICell(PathCell, handles.Cfg.ROIDef.SurfRH);
        handles.Cfg.ROISelectedIndex.SurfRH = [handles.Cfg.ROISelectedIndex.SurfRH;cell(length(PathCell)-length(find(RepeatFlags)),1)];
end
PathCell(RepeatFlags) = [];

if ~isempty(PathCell)
    StringCell=get(handles.listboxROIList, 'String');
    AddString=cellfun(@(Path) ['[All ROI Indices] ',Path], PathCell, 'UniformOutput', false);
    if isempty(StringCell)
        StringCell = AddString;
    else
        StringCell=[StringCell; AddString];
    end
    set(handles.listboxROIList, 'String', StringCell,'Value', numel(StringCell));
    handles = SaveCurrentROIText(handles);
    guidata(hObject, handles);
end


% --- Executes on button press in pushbuttonRemove.
function pushbuttonRemove_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRemove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.listboxROIList, 'Value');
if Value==0
    return
end

StringCell=get(handles.listboxROIList, 'String');
switch handles.DisplayFlag
    case 'Volume'
        handles.Cfg.ROIDef.Volume(Value)=[];
        handles.Cfg.ROISelectedIndex.Volume(Value)=[];
    case 'SurfLH' 
        handles.Cfg.ROIDef.SurfLH(Value)=[];
        handles.Cfg.ROISelectedIndex.SurfLH(Value)=[];
    case 'SurfRH'
        handles.Cfg.ROIDef.SurfRH(Value)=[];
        handles.Cfg.ROISelectedIndex.SurfRH(Value)=[];
end
StringCell(Value)=[];

if isempty(handles.Cfg.ROIDef)
    Value=0;
elseif numel(handles.Cfg.ROIDef) < Value
    Value=Value-1;
end
set(handles.listboxROIList, 'String', StringCell, 'Value', Value);
handles = SaveCurrentROIText(handles); 
guidata(hObject, handles);


% --- Executes on button press in pushbuttonClearAll.
function pushbuttonClearAll_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonClearAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch handles.DisplayFlag
    case 'Volume'
        handles.Cfg.ROIDef.Volume=[];
        handles.Cfg.ROISelectedIndex.Volume=[];
    case 'SurfLH'
        handles.Cfg.ROIDef.SurfLH=[];
        handles.Cfg.ROISelectedIndex.SurfLH=[];
    case 'SurfRH'
        handles.Cfg.ROIDef.SurfRH=[];
        handles.Cfg.ROISelectedIndex.SurfRH=[];
end
set(handles.listboxROIList, 'String', [], 'Value', 0);
handles = SaveCurrentROIText(handles); 
guidata(hObject, handles);


% --- Executes on button press in pushbuttonOK.
function pushbuttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);


% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Name, Path]=uiputfile('ROI_List.mat', 'Save ROI List as');
if isnumeric(Name)
    return
end
Path=fullfile(Path, Name);
Cfg = handles.Cfg;
save(Path, 'Cfg');

% --- Executes on button press in pushbuttonLoad.
function pushbuttonLoad_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Name, Path]=uigetfile({'*.mat','ROI List (*.mat)';'*.*', 'All Files (*.*)';},...
    'Pick ROI List');
if isnumeric(Name)
    return
end

Path=fullfile(Path, Name);
M=load(Path);
handles.Cfg=M.Cfg;

% recover handles.Cfg.ROIText for display
if ~isfield(handles.Cfg,'ROIDef')
    handles.Cfg.ROIDef.Volume={};
    handles.Cfg.ROIDef.SurfLH={};
    handles.Cfg.ROIDef.SurfRH={};
end
if ~isfield(handles.Cfg,'ROISelectedIndex')
    handles.Cfg.ROISelectedIndex.Volume = {};
    handles.Cfg.ROISelectedIndex.SurfLH = {};
    handles.Cfg.ROISelectedIndex.SurfRH = {};
end
if ~isfield(handles.Cfg,'IsMultipleLabel')
    handles.Cfg.IsMultipleLabel=1;
end

% recover handles.Cfg.ROIText for display
handles.Cfg.ROIText.Volume=handles.Cfg.ROIDef.Volume;
for i=1:numel(handles.Cfg.ROIText.Volume)
    if isnumeric(handles.Cfg.ROIText.Volume{i})
        s=handles.Cfg.ROIText.Volume{i};
        handles.Cfg.ROIText.Volume{i}=sprintf('Sphere ( X: %g -- Y: %g -- Z: %g >> Radius: %g )', s(1), s(2), s(3), s(4));
    else
        if ~isempty(handles.Cfg.ROISelectedIndex.Volume{i})
            handles.Cfg.ROIText.Volume{i} = ['[Selected ROI Indices] ',handles.Cfg.ROIText.Volume{i}];
        else
            handles.Cfg.ROIText.Volume{i} = ['[All ROI Indices] ',handles.Cfg.ROIText.Volume{i}];
        end
    end
end
handles.Cfg.ROIText.SurfLH=handles.Cfg.ROIDef.SurfLH;
for i=1:numel(handles.Cfg.ROIText.SurfLH)
    if ~isempty(handles.Cfg.ROISelectedIndex.SurfLH{i})
        handles.Cfg.ROIText.SurfLH{i} = ['[Selected ROI Indices] ',handles.Cfg.ROIText.SurfLH{i}];
    else
        handles.Cfg.ROIText.SurfLH{i} = ['[All ROI Indices] ',handles.Cfg.ROIText.SurfLH{i}];
    end
end
handles.Cfg.ROIText.SurfRH=handles.Cfg.ROIDef.SurfRH;
for i=1:numel(handles.Cfg.ROIText.SurfRH)
    if ~isempty(handles.Cfg.ROISelectedIndex.SurfRH{i})
        handles.Cfg.ROIText.SurfRH{i} = ['[Selected ROI Indices] ',handles.Cfg.ROIText.SurfRH{i}];
    else
        handles.Cfg.ROIText.SurfRH{i} = ['[All ROI Indices] ',handles.Cfg.ROIText.SurfRH{i}];
    end
end
set(handles.listboxROIList, 'String', handles.Cfg.ROIText.SurfLH, 'Value', length(handles.Cfg.ROIText.SurfLH));
set(handles.checkboxMultipleLabel,'Value',handles.Cfg.IsMultipleLabel);
handles.DisplayFlag = 'SurfLH';
set(handles.togglebuttonSurfaceLeft,'Value',1);
set(handles.togglebuttonSurfaceRight,'Value',0);
set(handles.togglebuttonVolume,'Value',0);
set(handles.pushbuttonSphere,'Enable','off');
handles = SaveCurrentROIText(handles); 
guidata(hObject, handles);


% --- Executes on button press in togglebuttonSurfaceLeft.
function togglebuttonSurfaceLeft_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonSurfaceLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.DisplayFlag = 'SurfLH';
set(handles.pushbuttonSphere,'Enable','off');
set(handles.listboxROIList, 'String', handles.Cfg.ROIText.SurfLH, 'Value', numel(handles.Cfg.ROIText.SurfLH));
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of togglebuttonSurfaceLeft


% --- Executes on button press in togglebuttonSurfaceRight.
function togglebuttonSurfaceRight_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonSurfaceRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.DisplayFlag = 'SurfRH';
set(handles.pushbuttonSphere,'Enable','off');
set(handles.listboxROIList, 'String', handles.Cfg.ROIText.SurfRH, 'Value', numel(handles.Cfg.ROIText.SurfRH));
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of togglebuttonSurfaceRight


% --- Executes on button press in togglebuttonVolume.
function togglebuttonVolume_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonVolume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.DisplayFlag = 'Volume';
set(handles.pushbuttonSphere,'Enable','on');
set(handles.listboxROIList, 'String', handles.Cfg.ROIText.Volume, 'Value', numel(handles.Cfg.ROIText.Volume));
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of togglebuttonVolume


function [ROICell,RepeatFlags]=GetROICell(PathCell, ROICell)
RepeatFlags=false(size(PathCell));
for i=1:numel(PathCell)
    if isnumeric(PathCell{i})
        continue
    end
    flag=find(strcmpi(PathCell{i}, ROICell) > 0, 1);
    if ~isempty(flag)
        RepeatFlags(i)=true;
    end
end
PathCell(RepeatFlags)=[];
ROICell=[ROICell; PathCell];


function handles = SaveCurrentROIText(handles)
switch handles.DisplayFlag
    case 'Volume'
        handles.Cfg.ROIText.Volume=get(handles.listboxROIList, 'String');
    case 'SurfLH' 
        handles.Cfg.ROIText.SurfLH=get(handles.listboxROIList, 'String');
    case 'SurfRH'
        handles.Cfg.ROIText.SurfRH=get(handles.listboxROIList, 'String');
end


% --- Executes on button press in checkboxMultipleLabel.
function checkboxMultipleLabel_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxMultipleLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsMultipleLabel = get(handles.checkboxMultipleLabel,'Value');
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxMultipleLabel


% --- Executes on button press in pushbuttonROIIndices.
function pushbuttonROIIndices_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonROIIndices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ROISelectFlag = get(handles.listboxROIList,'value');

switch handles.DisplayFlag
    case 'Volume'
        if isempty(handles.Cfg.ROISelectedIndex.Volume{ROISelectFlag}) % [All ROI Indices] now
            try % Mask ROI
                [MaskData,~,~,~] = y_ReadAll(handles.Cfg.ROIDef.Volume{ROISelectFlag});
                ROIIndex = unique(MaskData)';
                ROIIndex = setdiff(ROIIndex,0);
                handles.Cfg.ROISelectedIndex.Volume{ROISelectFlag} = DPABI_SelectROIIndices(ROIIndex); % DPABI_SelectROIIndices is a figure (GUI)
            catch
                try % Seed seires ROI
                    SeedData = load(handles.Cfg.ROIDef.Volume{ROISelectFlag});
                    ROIIndex = 1:size(SeedData,2);
                    handles.Cfg.ROISelectedIndex.Volume{ROISelectFlag} = DPABI_SelectROIIndices(ROIIndex);
                catch % Sphere ROI or wildcard string ROI
                    handles.Cfg.ROISelectedIndex.Volume{ROISelectFlag} = DPABI_SelectROIIndices([]);
                end
            end
            if ~isempty(handles.Cfg.ROISelectedIndex.Volume{ROISelectFlag})
                StringCell=get(handles.listboxROIList, 'String');
                StringCell{ROISelectFlag} = strrep(StringCell{ROISelectFlag},'[All ROI Indices] ','[Selected ROI Indices] ');
                set(handles.listboxROIList, 'String', StringCell, 'Value', ROISelectFlag);
            end
        else
            SelectedIndex = DPABI_SelectROIIndices(handles.Cfg.ROISelectedIndex.Volume{ROISelectFlag}); % DPABI_SelectROIIndices is a figure (GUI)
            if ~isempty(SelectedIndex)
                handles.Cfg.ROISelectedIndex.Volume{ROISelectFlag} = SelectedIndex;
            end
        end
    case 'SurfLH'
        if isempty(handles.Cfg.ROISelectedIndex.SurfLH{ROISelectFlag}) % [All ROI Indices] now
            try % Mask ROI
                [MaskData,~,~,~] = y_ReadAll(handles.Cfg.ROIDef.SurfLH{ROISelectFlag});
                ROIIndex = unique(MaskData)';
                ROIIndex = setdiff(ROIIndex,0);
                handles.Cfg.ROISelectedIndex.SurfLH{ROISelectFlag} = DPABI_SelectROIIndices(ROIIndex); % DPABI_SelectROIIndices is a figure (GUI)
            catch
                try % Seed seires ROI
                    SeedData = load(handles.Cfg.ROIDef.SurfLH{ROISelectFlag});
                    ROIIndex = 1:size(SeedData,2);
                    handles.Cfg.ROISelectedIndex.SurfLH{ROISelectFlag} = DPABI_SelectROIIndices(ROIIndex);
                catch % Wildcard string ROI
                    handles.Cfg.ROISelectedIndex.SurfLH{ROISelectFlag} = DPABI_SelectROIIndices([]);
                end
            end
            if ~isempty(handles.Cfg.ROISelectedIndex.SurfLH{ROISelectFlag})
                StringCell=get(handles.listboxROIList, 'String');
                StringCell{ROISelectFlag} = strrep(StringCell{ROISelectFlag},'[All ROI Indices] ','[Selected ROI Indices] ');
                set(handles.listboxROIList, 'String', StringCell, 'Value', ROISelectFlag);
            end
        else
            SelectedIndex = DPABI_SelectROIIndices(handles.Cfg.ROISelectedIndex.SurfLH{ROISelectFlag}); % DPABI_SelectROIIndices is a figure (GUI)
            if ~isempty(SelectedIndex)
                handles.Cfg.ROISelectedIndex.SurfLH{ROISelectFlag} = SelectedIndex;
            end
        end
    case 'SurfRH'
        if isempty(handles.Cfg.ROISelectedIndex.SurfRH{ROISelectFlag}) % [All ROI Indices] now
            try % Mask ROI
                [MaskData,~,~,~] = y_ReadAll(handles.Cfg.ROIDef.SurfRH{ROISelectFlag});
                ROIIndex = unique(MaskData)';
                ROIIndex = setdiff(ROIIndex,0);
                handles.Cfg.ROISelectedIndex.SurfRH{ROISelectFlag} = DPABI_SelectROIIndices(ROIIndex); % DPABI_SelectROIIndices is a figure (GUI)
            catch
                try % Seed seires ROI
                    SeedData = load(handles.Cfg.ROIDef.SurfRH{ROISelectFlag});
                    ROIIndex = 1:size(SeedData,2);
                    handles.Cfg.ROISelectedIndex.SurfRH{ROISelectFlag} = DPABI_SelectROIIndices(ROIIndex);
                catch % Wildcard string ROI
                    handles.Cfg.ROISelectedIndex.SurfRH{ROISelectFlag} = DPABI_SelectROIIndices([]);
                end
            end
            if ~isempty(handles.Cfg.ROISelectedIndex.SurfRH{ROISelectFlag})
                StringCell=get(handles.listboxROIList, 'String');
                StringCell{ROISelectFlag} = strrep(StringCell{ROISelectFlag},'[All ROI Indices] ','[Selected ROI Indices] ');
                set(handles.listboxROIList, 'String', StringCell, 'Value', ROISelectFlag);
            end
        else
            SelectedIndex = DPABI_SelectROIIndices(handles.Cfg.ROISelectedIndex.SurfRH{ROISelectFlag}); % DPABI_SelectROIIndices is a figure (GUI)
            if ~isempty(SelectedIndex)
                handles.Cfg.ROISelectedIndex.SurfRH{ROISelectFlag} = SelectedIndex;
            end
        end
end
handles = SaveCurrentROIText(handles); 
guidata(hObject, handles);


% --- Executes on button press in pushbuttonAddWildcardStr.
function pushbuttonAddWildcardStr_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAddWildcardStr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
WildcardROI = DPABI_AddWildcardROI; % DPABI_AddWildcardROI is a figure (GUI)
WildcardROI = {WildcardROI};

switch handles.DisplayFlag
    case 'Volume'
        [handles.Cfg.ROIDef.Volume,RepeatFlags]=GetROICell(WildcardROI, handles.Cfg.ROIDef.Volume);
    case 'SurfLH' 
        [handles.Cfg.ROIDef.SurfLH,RepeatFlags]=GetROICell(WildcardROI, handles.Cfg.ROIDef.SurfLH);
    case 'SurfRH'
        [handles.Cfg.ROIDef.SurfRH,RepeatFlags]=GetROICell(WildcardROI, handles.Cfg.ROIDef.SurfRH);
end
WildcardROI(RepeatFlags) = [];

if ~isempty(WildcardROI)
    StringCell=get(handles.listboxROIList, 'String');
    switch handles.DisplayFlag
        case 'Volume'
            handles.Cfg.ROISelectedIndex.Volume = [handles.Cfg.ROISelectedIndex.Volume;{[]}];
        case 'SurfLH'
            handles.Cfg.ROISelectedIndex.SurfLH = [handles.Cfg.ROISelectedIndex.SurfLH;{[]}];
        case 'SurfRH'
            handles.Cfg.ROISelectedIndex.SurfRH = [handles.Cfg.ROISelectedIndex.SurfRH;{[]}];
    end
    if isempty(StringCell)
        StringCell = {['[All ROI Indices] ',WildcardROI{1}]};
    else
        StringCell=[StringCell; ['[All ROI Indices] ',WildcardROI{1}]];
    end
    set(handles.listboxROIList, 'String', StringCell,...
        'Value', numel(StringCell));
    handles = SaveCurrentROIText(handles);
    guidata(hObject, handles);
end
