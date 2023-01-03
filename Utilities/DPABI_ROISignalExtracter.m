function varargout = DPABI_ROISignalExtracter(varargin)
% DPABI_ROISignalExtracter MATLAB code for DPABI_ROISignalExtracter.fig
%      DPABI_ROISignalExtracter, by itself, creates a new DPABI_ROISignalExtracter or raises the existing
%      singleton*.
%
%      H = DPABI_ROISignalExtracter returns the handle to a new DPABI_ROISignalExtracter or the handle to
%      the existing singleton*.
%
%      DPABI_ROISignalExtracter('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABI_ROISignalExtracter.M with the given input arguments.
%
%      DPABI_ROISignalExtracter('Property','Value',...) creates a new DPABI_ROISignalExtracter or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABI_ROISignalExtracter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABI_ROISignalExtracter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABI_ROISignalExtracter

% Last Modified by GUIDE v2.5 06-Jan-2019 06:16:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABI_ROISignalExtracter_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABI_ROISignalExtracter_OutputFcn, ...
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


% --- Executes just before DPABI_ROISignalExtracter is made visible.
function DPABI_ROISignalExtracter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABI_ROISignalExtracter (see VARARGIN)

handles.ImgCells={};
handles.ImgCellsSingleFiles={}; %YAN Chao-Gan, 200527. Should also work for adding single files
handles.CurDir=pwd;
handles.ROIDef=[];
handles.ROISelectedIndex=[];
handles.IsMultipleLabel=0;

set(handles.OutputDirEntry, 'String', pwd);
% Choose default command line output for DPABI_ROISignalExtracter
handles.output = hObject;

% Make UI display correct in PC and linux
if ~ismac
    if ispc
        ZoonMatrix = [1 1 1.8 1.2];  %For pc
    else
        ZoonMatrix = [1 1 1.8 1.2];  %For Linux
    end
    UISize = get(handles.figure1,'Position');
    UISize = UISize.*ZoonMatrix;
    set(handles.figure1,'Position',UISize);
end
movegui(handles.figure1, 'center');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABI_ROISignalExtracter wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DPABI_ROISignalExtracter_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
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

% --- Executes on button press in AddButton.
function AddButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=uigetdir(handles.CurDir, 'Pick Image Directory');
if isnumeric(Path)
    return
end
[handles.CurDir, Name]=fileparts(Path);

WildcardPattern=get(handles.editWildcardPattern, 'String');
[ImgCell, Num]=GetSubNameCell(Path,WildcardPattern);

handles.ImgCells{numel(handles.ImgCells)+1}=ImgCell;
StringOne={sprintf('DIR: [%d] (%s) %s', Num, Name, Path)};
AddString(handles.ImgListbox, StringOne);
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

if ~isempty(handles.ImgCellsSingleFiles) %YAN Chao-Gan, 200527. Should also work for adding single files
    handles.ImgCellsSingleFiles(Value)=[];
else
    handles.ImgCells(Value)=[]; %YAN Chao-Gan, 211007. Fixed a bug
end
RemoveString(handles.ImgListbox, Value);
guidata(hObject, handles);

function PrefixEntry_Callback(hObject, eventdata, handles)
% hObject    handle to PrefixEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PrefixEntry as text
%        str2double(get(hObject,'String')) returns contents of PrefixEntry as a double


% --- Executes during object creation, after setting all properties.
function PrefixEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PrefixEntry (see GCBO)
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

if ~isempty(handles.ImgCellsSingleFiles) %YAN Chao-Gan, 200527. Should also work for adding single files
    handles.ImgCells={};
    handles.ImgCells{1}=handles.ImgCellsSingleFiles;
end

if isempty(handles.ImgCells)
    return
end
ImgCells=handles.ImgCells;

OutputDir=get(handles.OutputDirEntry, 'String');
if isempty(OutputDir)
    OutputDir=handles.CurDir;
end

Prefix=get(handles.PrefixEntry, 'String');

for i=1:numel(ImgCells) %YAN Chao-Gan, 190105. Here don't need parfor. parfor i=1:numel(ImgCells)
    Img=ImgCells{i};
    
    %By YAN Chao-Gan, 141101.
    if iscell(Img)
        [Path, Name, Ext]=fileparts(Img{1});
        [ParentPath, Name]=fileparts(Path); 
    else
        [Path, Name, Ext]=fileparts(Img);
    end
    
    OutputFile=fullfile(OutputDir, sprintf('%s_%s.txt', Prefix, Name));
    
    if strcmpi(Ext,'.gii') %YAN Chao-Gan, 190105. Add GIFTI support.
        [ROISignals] = y_ExtractROISignal_Surf(Img, handles.ROIDef, OutputFile, '', handles.IsMultipleLabel,handles.ROISelectedIndex);
        %[ROISignals] = y_ExtractROISignal_Surf(AllVolume, ROIDef, OutputName, AMaskFilename, IsMultipleLabel, GHeader, CUTNUMBER)             
    else
        [ROISignals] = y_ExtractROISignal(Img, handles.ROIDef, OutputFile, '', handles.IsMultipleLabel,handles.ROISelectedIndex);
        %[ROISignals] = y_ExtractROISignal(AllVolume, ROIDef, OutputName, MaskData, IsMultipleLabel, IsNeedDetrend, Band, TR, TemporalMask, ScrubbingMethod, ScrubbingTiming, Header, CUTNUMBER)
    end
    
end

% --- Executes on selection change in TypePopup.
function TypePopup_Callback(hObject, eventdata, handles)
% hObject    handle to TypePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TypePopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TypePopup


% --- Executes during object creation, after setting all properties.
function TypePopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TypePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
function AddTable_Callback(hObject, eventdata, handles)
% hObject    handle to AddTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=uigetdir(handles.CurDir, 'Pick Image Directory');
if isnumeric(Path)
    return
end
[handles.CurDir, Name]=fileparts(Path);

WildcardPattern=get(handles.editWildcardPattern, 'String');
[ImgCell, Num]=GetSubNameCell(Path,WildcardPattern);

handles.ImgCells{numel(handles.ImgCells)+1}=ImgCell;
StringOne={sprintf('DIR: [%d] (%s) %s', Num, Name, Path)};
AddString(handles.ImgListbox, StringOne);
guidata(hObject, handles);

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
function AddAll_Callback(hObject, eventdata, handles)
% hObject    handle to AddAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=uigetdir(handles.CurDir, 'Pick Image Parent Directory');
if isnumeric(Path)
    return
end
handles.CurDir=Path;
%Suffix=get(handles.PrefixEntry, 'String'); %YAN Chao-Gan 190105. This should be void

SubjStruct=dir(Path);
Index=cellfun(...
    @(IsDir, NotDot) IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')),...
    {SubjStruct.isdir}, {SubjStruct.name});
SubjStruct=SubjStruct(Index);
SubjName={SubjStruct.name}';
SubjPath=cellfun(@(Name) fullfile(Path, Name), SubjName,...
    'UniformOutput', false);

set(handles.ImgListbox, 'BackgroundColor', 'Green');
drawnow;
WildcardPattern=get(handles.editWildcardPattern, 'String');
for i=1:numel(SubjPath);
    [ImgCell, Num]=GetSubNameCell(SubjPath{i},WildcardPattern);
    
    handles.ImgCells{numel(handles.ImgCells)+1}=ImgCell;
    StringOne={sprintf('DIR: [%d] (%s) %s', Num, SubjName{i}, SubjPath{i})};
    AddString(handles.ImgListbox, StringOne);
    drawnow;
end
set(handles.ImgListbox, 'BackgroundColor', 'White');
guidata(hObject, handles);

% --------------------------------------------------------------------
function RemoveAll_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.ImgListbox, 'String', '');
handles.ImgCells={};

guidata(hObject, handles);

% --------------------------------------------------------------------
function ListContext_Callback(hObject, eventdata, handles)
% hObject    handle to ListContext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function [ImgCell, Num]=GetSubNameCell(Path,WildcardPattern)

if ~isempty(WildcardPattern)
    D=dir(fullfile(Path, WildcardPattern));
else
    D=dir(fullfile(Path, ['*', '.img']));
    if isempty(D)
        D=dir(fullfile(Path, ['*', '.nii']));
    end
    if isempty(D)
        D=dir(fullfile(Path, ['*', '.nii.gz']));
    end
    if isempty(D)
        D=dir(fullfile(Path, '*.gii'));
    end
end

NameCell={D.name}';
Num=numel(NameCell);
ImgCell=cellfun(@(Name) fullfile(Path, Name), NameCell,...
    'UniformOutput', false);

function AddString(ListboxHandle, NewCell)
StringCell=get(ListboxHandle, 'String');
StringCell=[StringCell; NewCell];
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


function VoxelSizeEntry_Callback(hObject, eventdata, handles)
% hObject    handle to VoxelSizeEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of VoxelSizeEntry as text
%        str2double(get(hObject,'String')) returns contents of VoxelSizeEntry as a double


% --- Executes during object creation, after setting all properties.
function VoxelSizeEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VoxelSizeEntry (see GCBO)
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


% --- Executes on button press in DefineROI.
function DefineROI_Callback(hObject, eventdata, handles)
% hObject    handle to DefineROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ROIDef=handles.ROIDef;

if isfield(handles,'ROISelectedIndex')
    ROISelectedIndex=handles.ROISelectedIndex;
else
    ROISelectedIndex=cell(size(ROIDef));
end


handles.IsMultipleLabel = 1; % YAN Chao-Gan, 190105. Let's setup IsMultipleLabel always to 1.
if handles.IsMultipleLabel
    fprintf('\nIsMultipleLabel is set to 1: There are multiple labels in the ROI mask file.\n');
else
    fprintf('\nIsMultipleLabel is set to 0: All the non-zero values will be used to define the only ROI.\n');
end

ROIList.ROIDef=ROIDef;
ROIList.ROISelectedIndex=ROISelectedIndex;

ROIList=DPABI_ROIList(ROIList);

handles.ROIDef=ROIList.ROIDef;
handles.ROISelectedIndex=ROIList.ROISelectedIndex;
guidata(hObject, handles);







% --------------------------------------------------------------------
function AddImgTable_Callback(hObject, eventdata, handles)
% hObject    handle to AddImgTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[File , Path]=uigetfile({'*.img;*.nii;*.nii.gz;*.gii','Brain Image Files (*.img;*.nii;*.nii.gz;*.gii)';'*.*', 'All Files (*.*)';},...
    'Pick NIFTI/GIFTI File' , handles.CurDir, 'MultiSelect', 'On');

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
    handles.ImgCells=[handles.ImgCells, ImgCell];
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
[File , Path]=uigetfile({'*.img;*.nii;*.nii.gz;*.gii','Brain Image Files (*.img;*.nii;*.nii.gz;*.gii)';'*.*', 'All Files (*.*)';},...
    'Pick NIFTI/GIFTI File' , handles.CurDir, 'MultiSelect', 'On');

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
    handles.ImgCellsSingleFiles=[handles.ImgCellsSingleFiles, ImgCell]; %YAN Chao-Gan, 200527. Should also work for adding single files
    %handles.ImgCells=[handles.ImgCells, ImgCell];
    AddString(handles.ImgListbox, StringCell);
else
    ImgFile=fullfile(Path, File);
    handles.ImgCellsSingleFiles{numel(handles.ImgCellsSingleFiles)+1}=ImgFile;  %YAN Chao-Gan, 200527. Should also work for adding single files
    %handles.ImgCells{numel(handles.ImgCells)+1}=ImgFile;
    StringOne={sprintf('IMG: (%s) %s', File, ImgFile)};
    AddString(handles.ImgListbox, StringOne);
end
guidata(hObject, handles);



function editWildcardPattern_Callback(hObject, eventdata, handles)
% hObject    handle to editWildcardPattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editWildcardPattern as text
%        str2double(get(hObject,'String')) returns contents of editWildcardPattern as a double




% --- Executes during object creation, after setting all properties.
function editWildcardPattern_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editWildcardPattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over editWildcardPattern.
function editWildcardPattern_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to editWildcardPattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Toggel the "Enable" state to ON

set(hObject, 'Enable', 'On');

% Create UI control
uicontrol(handles.editWildcardPattern);
uiwait(msgbox(sprintf('Usually, you just need to leave here "blank". However, if you want to specify a Wildcard Pattern to filter specific files, e.g., if you want to select only the preprocessed surface data of left hemisphere, you need to input "*hemi-L*.gii" and click "Add All".'),'Wildcard Pattern'));
