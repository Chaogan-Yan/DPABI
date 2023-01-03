function varargout = DPABI_ROIList(varargin)
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

% Last Modified by GUIDE v2.5 28-Dec-2022 18:35:39
% Modified by Bin Lu, 20221226, added select ROI indices function, added
% wildcard string ROI function, modified save-load function

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
    handles.Cfg = varargin{1};
    if ~isfield(handles.Cfg,'ROIDef') 
        handles.Cfg.ROIDef = {};
    end
    if ~isfield(handles.Cfg,'ROISelectedIndex')
        handles.Cfg.ROISelectedIndex = {};
    end
    
    StringCell=handles.Cfg.ROIDef;
    for i=1:numel(StringCell)
        if isnumeric(StringCell{i})
            s=StringCell{i};
            StringCell{i}=sprintf('Sphere ( X: %g -- Y: %g -- Z: %g >> Radius: %g )',...
                s(1), s(2), s(3), s(4));
        else
            if ~isempty(handles.Cfg.ROISelectedIndex{i})
                StringCell{i} = ['[Selected ROI Indices] ',StringCell{i}];
            else
                StringCell{i} = ['[All ROI Indices] ',StringCell{i}];
            end
        end
    end
    set(handles.ROIListbox, 'String', StringCell);
else
    handles.Cfg.ROIDef = {};
    handles.Cfg.ROISelectedIndex = {};
end
    
if ~ismac
    if ispc
        ZoonMatrix = [1 1 1.2 1.2];  %For pc
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


movegui(handles.figure1, 'center');

% Update handles structure
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


% --- Executes on selection change in ROIListbox.
function ROIListbox_Callback(hObject, eventdata, handles)
% hObject    handle to ROIListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ROIListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ROIListbox


% --- Executes during object creation, after setting all properties.
function ROIListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SphereButton.
function SphereButton_Callback(hObject, eventdata, handles)
% hObject    handle to SphereButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SphereCell=w_AddSphere_gui;
if isempty(SphereCell)
    return
end

[handles.Cfg.ROIDef,RepeatFlags]=GetROICell(SphereCell, handles.Cfg.ROIDef);
SphereCell(RepeatFlags) = [];

if ~isempty(SphereCell)
    handles.Cfg.ROISelectedIndex = [handles.Cfg.ROISelectedIndex;cell(length(SphereCell),1)];
    
    StringCell=get(handles.ROIListbox, 'String');
    TextCell=cellfun(@(s) sprintf('Sphere ( X: %g -- Y: %g -- Z: %g >> Radius: %g )', s(1), s(2), s(3), s(4)), SphereCell,...
        'UniformOutput', false);
    StringCell=[StringCell;TextCell];
    set(handles.ROIListbox, 'String', StringCell,...
        'Value', numel(StringCell));
    guidata(hObject, handles);
end


% --- Executes on button press in MaskButton.
function MaskButton_Callback(hObject, eventdata, handles)
% hObject    handle to MaskButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Name, Path]=uigetfile({'*.img;*.nii;*.nii.gz;*.gii','Brain Image Files (*.img;*.nii;*.nii.gz;*.gii)';'*.*', 'All Files (*.*)';},...
    'Pick the Mask file','MultiSelect','on');

if isnumeric(Name)
    return
end

if ischar(Name)
    Name={Name};
end
Name=Name';
PathCell=cellfun(@(name) fullfile(Path, name), Name, 'UniformOutput', false);
[handles.Cfg.ROIDef,RepeatFlags]=GetROICell(PathCell, handles.Cfg.ROIDef);
PathCell(RepeatFlags) = [];

handles.Cfg.ROISelectedIndex = [handles.Cfg.ROISelectedIndex;cell(length(PathCell),1)];

if ~isempty(PathCell)
    StringCell=get(handles.ROIListbox, 'String');
    AddString=cellfun(@(Path) ['[All ROI Indices] ',Path], PathCell, 'UniformOutput', false);
    if isempty(StringCell)
        StringCell = AddString;
    else
        StringCell=[StringCell; AddString];
    end
    set(handles.ROIListbox, 'String', StringCell,'Value', numel(StringCell));
    guidata(hObject, handles);
end


% --- Executes on button press in SeedButton.
function SeedButton_Callback(hObject, eventdata, handles)
% hObject    handle to SeedButton (see GCBO)
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
[handles.Cfg.ROIDef,RepeatFlags]=GetROICell(PathCell, handles.Cfg.ROIDef);
PathCell(RepeatFlags) = [];

handles.Cfg.ROISelectedIndex = [handles.Cfg.ROISelectedIndex;cell(length(PathCell),1)];

if ~isempty(PathCell)
    StringCell=get(handles.ROIListbox, 'String');
    AddString=cellfun(@(Path) ['[All ROI Indices] ',Path], PathCell, 'UniformOutput', false);
    if isempty(StringCell)
        StringCell = AddString;
    else
        StringCell=[StringCell; AddString];
    end
    set(handles.ROIListbox, 'String', StringCell,'Value', numel(StringCell));
    guidata(hObject, handles);
end


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


% --- Executes on button press in RemoveButton.
function RemoveButton_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.ROIListbox, 'Value');
if Value==0
    return
end

StringCell=get(handles.ROIListbox, 'String');
StringCell(Value)=[];
handles.Cfg.ROIDef(Value)=[];
handles.Cfg.ROISelectedIndex(Value)=[];
guidata(hObject, handles);

if isempty(handles.Cfg.ROIDef)
    Value=0;
elseif numel(handles.Cfg.ROIDef) < Value
    Value=Value-1;
end
set(handles.ROIListbox, 'String', StringCell, 'Value', Value);


% --- Executes on button press in pushbuttonClearAll.
function pushbuttonClearAll_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonClearAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.ROIDef = {};
handles.Cfg.ROISelectedIndex = {};
guidata(hObject, handles);
set(handles.ROIListbox, 'String', [], 'Value', 0);


% --- Executes on button press in OKButton.
function OKButton_Callback(hObject, eventdata, handles)
% hObject    handle to OKButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);


% --- Executes on button press in SaveButton.
function SaveButton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Name, Path]=uiputfile('ROI_List.mat', 'Save ROI List as');
if isnumeric(Name)
    return
end
Path=fullfile(Path, Name);
Cfg = handles.Cfg;
save(Path, 'Cfg');


% --- Executes on button press in LoadButton.
function LoadButton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadButton (see GCBO)
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

if ~isfield(handles.Cfg,'ROIDef')
    handles.Cfg.ROIDef = {};
end
if ~isfield(handles.Cfg,'ROISelectedIndex')
    handles.Cfg.ROISelectedIndex = {};
end

StringCell=handles.Cfg.ROIDef;
for i=1:numel(StringCell)
    if isnumeric(StringCell{i})
        s=StringCell{i};
        StringCell{i}=sprintf('Sphere ( X: %g -- Y: %g -- Z: %g >> Radius: %g )',...
            s(1), s(2), s(3), s(4));
    else
        if ~isempty(handles.Cfg.ROISelectedIndex{i})
            StringCell{i} = ['[Selected ROI Indices] ',StringCell{i}];
        else
            StringCell{i} = ['[All ROI Indices] ',StringCell{i}];
        end
    end
end
set(handles.ROIListbox, 'String', StringCell);
guidata(hObject, handles);


% --- Executes on button press in pushbuttonROIIndices.
function pushbuttonROIIndices_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonROIIndices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ROISelectFlag = get(handles.ROIListbox,'value');

if isempty(handles.Cfg.ROISelectedIndex{ROISelectFlag}) % [All ROI Indices] now
    try % Mask ROI
        [MaskData,~,~,~] = y_ReadAll(handles.Cfg.ROIDef{ROISelectFlag});
        ROIIndex = unique(MaskData)';
        ROIIndex = setdiff(ROIIndex,0);
        handles.Cfg.ROISelectedIndex{ROISelectFlag} = DPABI_SelectROIIndices(ROIIndex); % DPABI_SelectROIIndices is a figure (GUI)
    catch
        try % Seed seires ROI
            SeedData = load(handles.Cfg.ROIDef{ROISelectFlag});
            ROIIndex = 1:size(SeedData,2);
            handles.Cfg.ROISelectedIndex{ROISelectFlag} = DPABI_SelectROIIndices(ROIIndex); 
        catch % Sphere ROI or wildcard string ROI
            handles.Cfg.ROISelectedIndex{ROISelectFlag} = DPABI_SelectROIIndices([]); 
        end
    end
    if ~isempty(handles.Cfg.ROISelectedIndex{ROISelectFlag})
        StringCell=get(handles.ROIListbox, 'String');
        StringCell{ROISelectFlag} = strrep(StringCell{ROISelectFlag},'[All ROI Indices] ','[Selected ROI Indices] ');
        set(handles.ROIListbox, 'String', StringCell, 'Value', ROISelectFlag);
    end
else
    SelectedIndex = DPABI_SelectROIIndices(handles.Cfg.ROISelectedIndex{ROISelectFlag}); % DPABI_SelectROIIndices is a figure (GUI)
    if ~isempty(SelectedIndex)
        handles.Cfg.ROISelectedIndex{ROISelectFlag} = SelectedIndex;
    end
end
guidata(hObject, handles);


% --- Executes on button press in pushbuttonAddWildcardStr.
function pushbuttonAddWildcardStr_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAddWildcardStr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
WildcardROI = DPABI_AddWildcardROI; % DPABI_AddWildcardROI is a figure (GUI)
WildcardROI = {WildcardROI};

[handles.Cfg.ROIDef,RepeatFlags]=GetROICell(WildcardROI, handles.Cfg.ROIDef);
WildcardROI(RepeatFlags) = [];

if ~isempty(WildcardROI)
    handles.Cfg.ROISelectedIndex = [handles.Cfg.ROISelectedIndex;{[]}];
    
    StringCell=get(handles.ROIListbox, 'String');
    if isempty(StringCell)
        StringCell = {['[All ROI Indices] ',WildcardROI{1}]};
    else
        StringCell=[StringCell; ['[All ROI Indices] ',WildcardROI{1}]];
    end
    set(handles.ROIListbox, 'String', StringCell,...
        'Value', numel(StringCell));
    guidata(hObject, handles);
end
