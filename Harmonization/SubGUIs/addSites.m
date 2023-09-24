function varargout = addSites(varargin)
% ADDSITES MATLAB code for addSites.fig
%      ADDSITES, by itself, creates a new ADDSITES or raises the existing
%      singleton*.
%
%      H = ADDSITES returns the handle to a new ADDSITES or the handle to
%      the existing singleton*.
%
%      ADDSITES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADDSITES.M with the given input arguments.
%
%      ADDSITES('Property','Value',...) creates a new ADDSITES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before addSites_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to addSites_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help addSites

% Last Modified by GUIDE v2.5 11-Aug-2023 17:10:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @addSites_OpeningFcn, ...
    'gui_OutputFcn',  @addSites_OutputFcn, ...
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


% --- Executes just before addSites is made visible.
function addSites_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to addSites (see VARARGIN)

% Choose default command line output for addSites
handles.output = hObject;
handles.figure1.Resize = "on";
movegui(handles.figure1,'center');

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
% UIWAIT makes addSites wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = addSites_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles)
    handles.Strings=[];
    handles.ImgCellList=[];
else
    delete(handles.figure1);
end
% Get default command line output from handles structure
varargout{1} = handles.ImgCellList;
varargout{2} = handles.Strings;

% --- Executes on button press in DirectoryButton.
function DirectoryButton_Callback(hObject, eventdata, handles)
% hObject    handle to DirectoryButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ParentPath=uigetdir('Pick Parent Directory');

if isnumeric(ParentPath)
    return
end
handles.ParentDir = ParentPath;
set(handles.editParentDirectory,'String',ParentPath);
guidata(hObject, handles);


function editParentDirectory_Callback(hObject, eventdata, handles)
% hObject    handle to editParentDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editParentDirectory as text
%        str2double(get(hObject,'String')) returns contents of editParentDirectory as a double


% --- Executes during object creation, after setting all properties.
function editParentDirectory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editParentDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RefButton.
function RefButton_Callback(hObject, eventdata, handles)
% hObject    handle to RefButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ParentDir = get(handles.editParentDirectory,'String');
if ~isempty(ParentDir)
    [RefFile,RefPath]=uigetfile({'*.mat;*.img;*.nii;*.nii.gz;*.gii',...
        'Brain Image Files (*.mat;*.img;*.nii;*.nii.gz;*.gii)';'*.*', 'All Files (*.*)';}, ...
        'Please show me the way to the wanted file.',ParentDir);
end
if isnumeric(RefFile)
    return
end

set(handles.editRefFile,'String',fullfile(RefPath,RefFile));

guidata(hObject, handles);

function editRefFile_Callback(hObject, eventdata, handles)
% hObject    handle to editRefFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRefFile as text
%        str2double(get(hObject,'String')) returns contents of editRefFile as a double


% --- Executes during object creation, after setting all properties.
function editRefFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRefFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in FinishButton.
function FinishButton_Callback(hObject, eventdata, handles)
% hObject    handle to FinishButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ParentPath =get(handles.editParentDirectory,'String');
[ParentDir,DName] = fileparts(ParentPath);
RefFile = get(handles.editRefFile,'String');
handles.ImgCellList=[];
if isempty(RefFile)
    [handles.ImgCellList, handles.Strings]=GetSubNameCell(ParentPath);
else
    [RefPath,suffix,ext] = fileparts(RefFile);
     
    suffix = extractBefore(suffix,'_');
    route = extractAfter(RefPath,DName); %handles.Name is the last directory name of ParentDir.
    SiteDirs = dir(ParentDir);
    
    for d = 3:length(SiteDirs)
        ParentDirList{d-2,1} = strcat(ParentDir,filesep,SiteDirs(d).name,route,filesep,suffix,'*',ext);
    end
    SiteName = {SiteDirs(3:end).name}';
    [handles.ImgCellList, handles.Strings]=GetSubNameCell(ParentDirList,SiteName);
end

uiresume(handles.figure1);
guidata(hObject, handles);


function [ImgCellList, String]=GetSubNameCell(varargin)
ImgCellList = [];
String = [];

optargin = size(varargin,2);
if optargin == 1
    Path = varargin{1};
    D=dir(fullfile(Path, ['*', '.img']));
    if isempty(D)
        D=dir(fullfile(Path, ['*', '.nii']));
    end
    if isempty(D)
        D=dir(fullfile(Path, ['*', '.nii.gz']));
    end
    if isempty(D)
        D=dir(fullfile(Path, ['*', '.gii']));
    end
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
    
elseif optargin == 2
    PathList = varargin{1};
    Site = varargin{2};
    for i = 1:length(PathList)
        Path = PathList{i};
        if isfolder(Path)
            D=dir(fullfile(Path, ['*', '.img']));
            if isempty(D)
                D=dir(fullfile(Path, ['*', '.nii']));
            end
            if isempty(D)
                D=dir(fullfile(Path, ['*', '.nii.gz']));
            end            
            if isempty(D)
                D=dir(fullfile(Path, ['*', '.gii']));
            end
            if isempty(D)
                D=dir(fullfile(Path, ['*', '.mat']));
            end
        else
            D = dir(Path);
            [Path,~,~] = fileparts(Path); 
        end
        
        NameCell={D.name}';
        
        Num=numel(NameCell);
        ImgCell=cellfun(@(Name) fullfile(Path, Name), NameCell,...
            'UniformOutput', false);
        ImgCellList=[ImgCellList;ImgCell];
        
        tmpString = [];
        tmpString = cellfun(@(name) sprintf('IMG: (%s) %s',Site{i},name), NameCell,...
            'UniformOutput', false);
        String = [String;tmpString];
    end
end
