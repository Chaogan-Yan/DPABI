function varargout = DPABI_Standardization_Surf(varargin)
% DPABI_Standardization MATLAB code for DPABI_Standardization.fig
%      DPABI_Standardization, by itself, creates a new DPABI_Standardization or raises the existing
%      singleton*.
%
%      H = DPABI_Standardization returns the handle to a new DPABI_Standardization or the handle to
%      the existing singleton*.
%
%      DPABI_Standardization('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABI_Standardization.M with the given input arguments.
%
%      DPABI_Standardization('Property','Value',...) creates a new DPABI_Standardization or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABI_Standardization_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABI_Standardization_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABI_Standardization

% Last Modified by GUIDE v2.5 17-Jul-2019 09:41:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABI_Standardization_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABI_Standardization_OutputFcn, ...
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


% --- Executes just before DPABI_Standardization is made visible.
function DPABI_Standardization_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABI_Standardization (see VARARGIN)

fprintf('Standardize the brains for Statistical Analysis. \nRef: Yan, C.G., Craddock, R.C., Zuo, X.N., Zang, Y.F., Milham, M.P., 2013. Standardizing the intrinsic brain: towards robust measurement of inter-individual variation in 1000 functional connectomes. Neuroimage 80, 246-262.\n');

handles.ImgLeft={};
handles.ImgRight={};
handles.CurDir=pwd;
handles.Space='fsaverage5';

set(handles.OutputDirEntry, 'String', pwd);
% Choose default command line output for DPABI_Standardization
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABI_Standardization wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DPABI_Standardization_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in ListboxLeft.
function ListboxLeft_Callback(hObject, eventdata, handles)
% hObject    handle to ListboxLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListboxLeft contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListboxLeft


% --- Executes during object creation, after setting all properties.
function ListboxLeft_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListboxLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in AddButtonLeft.
function AddButtonLeft_Callback(hObject, eventdata, handles)
% hObject    handle to AddButtonLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=uigetdir(handles.CurDir, 'Pick Image Directory');
if isnumeric(Path)
    return
end
[handles.CurDir, Name]=fileparts(Path);

[ImgCell, Num]=GetSubNameCell(Path);

handles.ImgLeft{numel(handles.ImgLeft)+1}=ImgCell;
StringOne={sprintf('DIR: [%d] (%s) %s', Num, Name, Path)};
AddString(handles.ListboxLeft, StringOne);
guidata(hObject, handles);

% --- Executes on button press in RemoveButtonLeft.
function RemoveButtonLeft_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveButtonLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.ListboxLeft, 'Value');
if Value==0
    return
end
handles.ImgLeft(Value)=[];
RemoveString(handles.ListboxLeft, Value);
guidata(hObject, handles);

function SuffixEntry_Callback(hObject, eventdata, handles)
% hObject    handle to SuffixEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SuffixEntry as text
%        str2double(get(hObject,'String')) returns contents of SuffixEntry as a double


% --- Executes during object creation, after setting all properties.
function SuffixEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SuffixEntry (see GCBO)
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
if isempty(handles.ImgLeft) || isempty(handles.ImgRight)
    return
end

ImgLeft=handles.ImgLeft;
ImgRight=handles.ImgRight;
SpaceName=handles.Space;

MaskLeft=get(handles.MaskEntryLeft, 'String');
MaskRight=get(handles.MaskEntryRight, 'String');

MethodType=get(handles.MethodPopup, 'Value');

OutputDir=get(handles.OutputDirEntry, 'String');
if isempty(OutputDir)
    OutputDir=handles.CurDir;
end

Suffix=get(handles.SuffixEntry, 'String');
IsSmooth = get(handles.SmoothButton, 'Value');
FWHM = str2num(get(handles.editFWHM,'String'));


%[StandardizedBrain_LH, StandardizedBrain_RH, Header_LH, Header_RH, OutNameList_LH, OutNameList_RH] = y_Standardization_Surf(ImgCells_LH, ImgCells_RH, MaskData_LH, MaskData_RH, MethodType, OutputDir, Suffix)
[StandardizedBrain_LH, StandardizedBrain_RH, Header_LH, Header_RH, OutNameList_LH, OutNameList_RH] = y_Standardization_Surf(ImgLeft, ImgRight, MaskLeft, MaskRight, MethodType, OutputDir, Suffix);

if IsSmooth
    [DPABIPath, fileN, extn] = fileparts(which('DPABI.m'));
    %For Left Hemisphere
    for iFile=1:length(OutNameList_LH)
        [WorkingDir, File, Ext]=fileparts(OutNameList_LH{iFile,1});
        if ispc
            CommandInit=sprintf('docker run -i --rm -v %s:/opt/freesurfer/license.txt -v %s:/data -e SUBJECTS_DIR=/opt/freesurfer/subjects cgyan/dpabi', fullfile(DPABIPath, 'DPABISurf', 'FreeSurferLicense', 'license.txt'), WorkingDir); %YAN Chao-Gan, 181214. Remove -t because there is a tty issue in windows
        else
            CommandInit=sprintf('docker run -ti --rm -v %s:/opt/freesurfer/license.txt -v %s:/data -e SUBJECTS_DIR=/opt/freesurfer/subjects cgyan/dpabi', fullfile(DPABIPath, 'DPABISurf', 'FreeSurferLicense', 'license.txt'), WorkingDir);
        end
        if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
            CommandInit=sprintf('export SUBJECTS_DIR=%s/freesurfer && ', WorkingDir);
        end
        
        Command = sprintf('%s mri_surf2surf --s %s --hemi lh --sval /data/%s --fwhm %g --cortex --tval /data/s%s', ...
            CommandInit, SpaceName, [File, Ext], FWHM, [File, Ext]);
        system(Command);
    end
    
    %For Right Hemisphere
    for iFile=1:length(OutNameList_RH)
        [WorkingDir, File, Ext]=fileparts(OutNameList_RH{iFile,1});
        if ispc
            CommandInit=sprintf('docker run -i --rm -v %s:/opt/freesurfer/license.txt -v %s:/data -e SUBJECTS_DIR=/opt/freesurfer/subjects cgyan/dpabi', fullfile(DPABIPath, 'DPABISurf', 'FreeSurferLicense', 'license.txt'), WorkingDir); %YAN Chao-Gan, 181214. Remove -t because there is a tty issue in windows
        else
            CommandInit=sprintf('docker run -ti --rm -v %s:/opt/freesurfer/license.txt -v %s:/data -e SUBJECTS_DIR=/opt/freesurfer/subjects cgyan/dpabi', fullfile(DPABIPath, 'DPABISurf', 'FreeSurferLicense', 'license.txt'), WorkingDir);
        end
        if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
            CommandInit=sprintf('export SUBJECTS_DIR=%s/freesurfer && ', WorkingDir);
        end
        
        Command = sprintf('%s mri_surf2surf --s %s --hemi rh --sval /data/%s --fwhm %g --cortex --tval /data/s%s', ...
            CommandInit, SpaceName, [File, Ext], FWHM, [File, Ext]);
        system(Command);
    end
    
end


% --- Executes on selection change in MethodPopup.
function MethodPopup_Callback(hObject, eventdata, handles)
% hObject    handle to MethodPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MethodPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MethodPopup


% --- Executes during object creation, after setting all properties.
function MethodPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MethodPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function AddTable_Left_Callback(hObject, eventdata, handles)
% hObject    handle to AddTable_Left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=uigetdir(handles.CurDir, 'Pick Image Directory');
if isnumeric(Path)
    return
end
[handles.CurDir, Name]=fileparts(Path);

[ImgCell, Num]=GetSubNameCell(Path);

handles.ImgLeft{numel(handles.ImgLeft)+1}=ImgCell;
StringOne={sprintf('DIR: [%d] (%s) %s', Num, Name, Path)};
AddString(handles.ListboxLeft, StringOne);
guidata(hObject, handles);

% --------------------------------------------------------------------
function RemoveTable_Left_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveTable_Left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.ListboxLeft, 'Value');
if Value==0
    return
end
handles.ImgLeft(Value)=[];
RemoveString(handles.ListboxLeft, Value);
guidata(hObject, handles);

% --------------------------------------------------------------------
function AddAll_Left_Callback(hObject, eventdata, handles)
% hObject    handle to AddAll_Left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=uigetdir(handles.CurDir, 'Pick Image Parent Directory');
if isnumeric(Path)
    return
end
handles.CurDir=Path;

SubjStruct=dir(Path);
Index=cellfun(...
    @(IsDir, NotDot) IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')),...
    {SubjStruct.isdir}, {SubjStruct.name});
SubjStruct=SubjStruct(Index);
SubjName={SubjStruct.name}';
SubjPath=cellfun(@(Name) fullfile(Path, Name), SubjName,...
    'UniformOutput', false);

set(handles.ListboxLeft, 'BackgroundColor', 'Green');
drawnow;
for i=1:numel(SubjPath)
    [ImgCell, Num]=GetSubNameCell(SubjPath{i});
    
    handles.ImgLeft{numel(handles.ImgLeft)+1}=ImgCell;
    StringOne={sprintf('DIR: [%d] (%s) %s', Num, SubjName{i}, SubjPath{i})};
    AddString(handles.ListboxLeft, StringOne);
    drawnow;
end
set(handles.ListboxLeft, 'BackgroundColor', 'White');
guidata(hObject, handles);

% --------------------------------------------------------------------
function RemoveAll_Left_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveAll_Left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.ListboxLeft, 'String', '');
handles.ImgLeft={};

guidata(hObject, handles);

% --------------------------------------------------------------------
function ListContext_left_Callback(hObject, eventdata, handles)
% hObject    handle to ListContext_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function ListContext_Right_Callback(hObject, eventdata, handles)
% hObject    handle to ListContext_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function [ImgCell, Num]=GetSubNameCell(Path)
D1=dir(fullfile(Path, ['*', '.gii']));
D2=dir(fullfile(Path, ['*', '.gii.gz']));
D=[D1;D2];

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


% --------------------------------------------------------------------
function AddImgTable_Left_Callback(hObject, eventdata, handles)
% hObject    handle to AddImgTable_Left (see GCBO)
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
    handles.ImgLeft=[handles.ImgLeft, ImgCell];
    AddString(handles.ListboxLeft, StringCell);
else
    ImgFile=fullfile(Path, File);
    handles.ImgLeft{numel(handles.ImgLeft)+1}=ImgFile;
    StringOne={sprintf('IMG: (%s) %s', File, ImgFile)};
    AddString(handles.ListboxLeft, StringOne);
end
guidata(hObject, handles);

% --- Executes on button press in AddImgButtonLeft.
function AddImgButtonLeft_Callback(hObject, eventdata, handles)
% hObject    handle to AddImgButtonLeft (see GCBO)
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
    handles.ImgLeft=[handles.ImgLeft, ImgCell];
    AddString(handles.ListboxLeft, StringCell);
else
    ImgFile=fullfile(Path, File);
    handles.ImgLeft{numel(handles.ImgLeft)+1}=ImgFile;
    StringOne={sprintf('IMG: (%s) %s', File, ImgFile)};
    AddString(handles.ListboxLeft, StringOne);
end
guidata(hObject, handles);




function editMask_Callback(hObject, eventdata, handles)
% hObject    handle to editMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMask as text
%        str2double(get(hObject,'String')) returns contents of editMask as a double


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


% --- Executes during object creation, after setting all properties.
function MaskEntryLeft_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaskEntryLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MaskButtonLeft.
function MaskButtonLeft_Callback(hObject, eventdata, handles)
% hObject    handle to MaskButtonLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Name, Path]=uigetfile({'*.gii','Brain Image Files (*.gii)';'*.*', 'All Files (*.*)';},...
    'Pick the Mask Image');
if isnumeric(Name)
    return
end
set(handles.MaskEntryLeft, 'String', fullfile(Path, Name));




% --- Executes on button press in SmoothButton.
function SmoothButton_Callback(hObject, eventdata, handles)
% hObject    handle to SmoothButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
IsSmooth = get(hObject,'Value');
if IsSmooth
    set(handles.textFWHM,'Enable','on');
    set(handles.editFWHM,'Enable','on');
    set(handles.textMM,'Enable','on');
else
    set(handles.textFWHM,'Enable','off');
    set(handles.editFWHM,'Enable','off');
    set(handles.textMM,'Enable','off');
end
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of SmoothButton


% --- Executes on selection change in ListboxRight.
function ListboxRight_Callback(hObject, eventdata, handles)
% hObject    handle to ListboxRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListboxRight contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListboxRight


% --- Executes during object creation, after setting all properties.
function ListboxRight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListboxRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AddButtonRight.
function AddButtonRight_Callback(hObject, eventdata, handles)
% hObject    handle to AddButtonRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=uigetdir(handles.CurDir, 'Pick Image Directory');
if isnumeric(Path)
    return
end
[handles.CurDir, Name]=fileparts(Path);

[ImgCell, Num]=GetSubNameCell(Path);

handles.ImgRight{numel(handles.ImgRight)+1}=ImgCell;
StringOne={sprintf('DIR: [%d] (%s) %s', Num, Name, Path)};
AddString(handles.ListboxRight, StringOne);
guidata(hObject, handles);


% --- Executes on button press in RemoveButtonRight.
function RemoveButtonRight_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveButtonRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.ListboxRight, 'Value');
if Value==0
    return
end
handles.ImgRight(Value)=[];
RemoveString(handles.ListboxRight, Value);
guidata(hObject, handles);


% --- Executes on button press in AddImgButtonRight.
function AddImgButtonRight_Callback(hObject, eventdata, handles)
% hObject    handle to AddImgButtonRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[File , Path]=uigetfile({'*.gii;*gii.gz','Brain Image Files (*.gii;*gii.gz)';'*.*', 'All Files (*.*)';}, ...
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
    handles.ImgRight=[handles.ImgRight, ImgCell];
    AddString(handles.ListboxRight, StringCell);
else
    ImgFile=fullfile(Path, File);
    handles.ImgRight{numel(handles.ImgRight)+1}=ImgFile;
    StringOne={sprintf('IMG: (%s) %s', File, ImgFile)};
    AddString(handles.ListboxRight, StringOne);
end
guidata(hObject, handles);


function MaskEntryRight_Callback(hObject, eventdata, handles)
% hObject    handle to MaskEntryRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaskEntryRight as text
%        str2double(get(hObject,'String')) returns contents of MaskEntryRight as a double


% --- Executes during object creation, after setting all properties.
function MaskEntryRight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaskEntryRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MaskButtonRight.
function MaskButtonRight_Callback(hObject, eventdata, handles)
% hObject    handle to MaskButtonRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Name, Path]=uigetfile({'*.gii','Brain Image Files (*.gii)';'*.*', 'All Files (*.*)';},...
    'Pick the Mask Image');
if isnumeric(Name)
    return
end
set(handles.MaskEntryRight, 'String', fullfile(Path, Name));




% --------------------------------------------------------------------
function AddTable_Right_Callback(hObject, eventdata, handles)
% hObject    handle to AddTable_Right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=uigetdir(handles.CurDir, 'Pick Image Directory');
if isnumeric(Path)
    return
end
[handles.CurDir, Name]=fileparts(Path);

[ImgCell, Num]=GetSubNameCell(Path);

handles.ImgRight{numel(handles.ImgRight)+1}=ImgCell;
StringOne={sprintf('DIR: [%d] (%s) %s', Num, Name, Path)};
AddString(handles.ListboxRight, StringOne);
guidata(hObject, handles);

% --------------------------------------------------------------------
function AddImgTable_Right_Callback(hObject, eventdata, handles)
% hObject    handle to AddImgTable_Right (see GCBO)
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
    handles.ImgRight=[handles.ImgRight, ImgCell];
    AddString(handles.ListboxRight, StringCell);
else
    ImgFile=fullfile(Path, File);
    handles.ImgRight{numel(handles.ImgRight)+1}=ImgFile;
    StringOne={sprintf('IMG: (%s) %s', File, ImgFile)};
    AddString(handles.ListboxRight, StringOne);
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function RemoveTable_Right_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveTable_Right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.ListboxRight, 'Value');
if Value==0
    return
end
handles.ImgRight(Value)=[];
RemoveString(handles.ListboxRight, Value);
guidata(hObject, handles);

% --------------------------------------------------------------------
function AddAll_Right_Callback(hObject, eventdata, handles)
% hObject    handle to AddAll_Right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=uigetdir(handles.CurDir, 'Pick Image Parent Directory');
if isnumeric(Path)
    return
end
handles.CurDir=Path;

SubjStruct=dir(Path);
Index=cellfun(...
    @(IsDir, NotDot) IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')),...
    {SubjStruct.isdir}, {SubjStruct.name});
SubjStruct=SubjStruct(Index);
SubjName={SubjStruct.name}';
SubjPath=cellfun(@(Name) fullfile(Path, Name), SubjName,...
    'UniformOutput', false);

set(handles.ListboxRight, 'BackgroundColor', 'Green');
drawnow;
for i=1:numel(SubjPath)
    [ImgCell, Num]=GetSubNameCell(SubjPath{i});
    
    handles.ImgRight{numel(handles.ImgRight)+1}=ImgCell;
    StringOne={sprintf('DIR: [%d] (%s) %s', Num, SubjName{i}, SubjPath{i})};
    AddString(handles.ListboxRight, StringOne);
    drawnow;
end
set(handles.ListboxRight, 'BackgroundColor', 'White');
guidata(hObject, handles);

% --------------------------------------------------------------------
function RemoveAll_Right_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveAll_Right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.ListboxRight, 'String', '');
handles.ImgRight={};

guidata(hObject, handles);



function editFWHM_Callback(hObject, eventdata, handles)
% hObject    handle to editFWHM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFWHM as text
%        str2double(get(hObject,'String')) returns contents of editFWHM as a double


% --- Executes during object creation, after setting all properties.
function editFWHM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFWHM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuSpace.
function popupmenuSpace_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSpace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Index = get(hObject,'Value');
if Index == 1
    handles.Space = 'fsaverage5';
elseif Index == 2
    handles.Space = 'fsaverage';
end
guidata(hObject, handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSpace contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSpace


% --- Executes during object creation, after setting all properties.
function popupmenuSpace_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSpace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
