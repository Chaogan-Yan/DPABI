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

% Last Modified by GUIDE v2.5 17-Dec-2018 09:19:50

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
if nargin > 3 && (~isempty(varargin{1}))
    handles.ROICell=varargin{1};
    % recover handles.ROIText for display
    handles.ROIText.Volume=handles.ROICell.Volume;
    for i=1:numel(handles.ROIText.Volume)
        if isnumeric(handles.ROIText.Volume{i})
            s=handles.ROIText.Volume{i};
            handles.ROIText.Volume{i}=sprintf('Sphere ( X: %g -- Y: %g -- Z: %g >> Radius: %g )', s(1), s(2), s(3), s(4));
        end
    end
    handles.ROIText.SurfLH=handles.ROICell.SurfLH;
    handles.ROIText.SurfRH=handles.ROICell.SurfRH;
    set(handles.listboxROIList, 'String', handles.ROIText.SurfLH);
    handles.IsMultipleLabel=varargin{2};
else
    handles.ROICell.Volume={};
    handles.ROICell.SurfLH={};
    handles.ROICell.SurfRH={};
    handles.ROIText.Volume = {};
    handles.ROIText.SurfLH = {};
    handles.ROIText.SurfRH = {};
    handles.IsMultipleLabel=1;
end

handles.DisplayFlag = 'SurfLH';
set(handles.checkboxMultipleLabel,'Value',handles.IsMultipleLabel);
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
    varargout{2}=[];
else
    varargout{1} = handles.ROICell;
    varargout{2} = handles.IsMultipleLabel;                
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
handles.ROICell.Volume=GetROICell(SphereCell, handles.ROICell.Volume);
StringCell=handles.ROIText.Volume;

TextCell=cellfun(@(s) sprintf('Sphere ( X: %g -- Y: %g -- Z: %g >> Radius: %g )', s(1), s(2), s(3), s(4)), SphereCell,...
    'UniformOutput', false);
StringCell=[StringCell;TextCell];

set(handles.listboxROIList, 'String', StringCell,...
    'Value', numel(handles.ROICell));
handles = SaveCurrentROIText(handles);
guidata(hObject, handles);


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
        handles.ROICell.Volume=GetROICell(PathCell, handles.ROICell.Volume);
    case 'SurfLH' 
        handles.ROICell.SurfLH=GetROICell(PathCell, handles.ROICell.SurfLH);
    case 'SurfRH'
        handles.ROICell.SurfRH=GetROICell(PathCell, handles.ROICell.SurfRH);
end

StringCell=get(handles.listboxROIList, 'String');
StringCell=[StringCell; PathCell];
set(handles.listboxROIList, 'String', StringCell, 'Value', numel(handles.ROICell));
handles = SaveCurrentROIText(handles); ;
guidata(hObject, handles);

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
        handles.ROICell.Volume=GetROICell(PathCell, handles.ROICell.Volume);
    case 'SurfLH' 
        handles.ROICell.SurfLH=GetROICell(PathCell, handles.ROICell.SurfLH);
    case 'SurfRH'
        handles.ROICell.SurfRH=GetROICell(PathCell, handles.ROICell.SurfRH);
end

StringCell=get(handles.listboxROIList, 'String');
StringCell=[StringCell; PathCell];
set(handles.listboxROIList, 'String', StringCell, 'Value', numel(handles.ROICell));
handles = SaveCurrentROIText(handles); ;
guidata(hObject, handles);


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
        handles.ROICell.Volume(Value)=[];
    case 'SurfLH' 
        handles.ROICell.SurfLH(Value)=[];
    case 'SurfRH'
        handles.ROICell.SurfRH(Value)=[];
end
StringCell(Value)=[];

if isempty(handles.ROICell)
    Value=0;
elseif numel(handles.ROICell) < Value
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
        handles.ROICell.Volume=[];
    case 'SurfLH' 
        handles.ROICell.SurfLH=[];
    case 'SurfRH'
        handles.ROICell.SurfRH=[];
end
guidata(hObject, handles);
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
ROICell=handles.ROICell;
save(Path, 'ROICell');

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
handles.ROICell=M.ROICell;
guidata(hObject, handles);

% recover handles.ROIText for display
handles.ROIText.Volume=M.ROICell.Volume;
for i=1:numel(handles.ROIText.Volume)
    if isnumeric(handles.ROIText.Volume{i})
        s=handles.ROIText.Volume{i};
        handles.ROIText.Volume{i}=sprintf('Sphere ( X: %g -- Y: %g -- Z: %g >> Radius: %g )', s(1), s(2), s(3), s(4));
    end
end
handles.ROIText.SurfLH=M.ROICell.SurfLH;
handles.ROIText.SurfRH=M.ROICell.SurfRH;
switch handles.DisplayFlag
    case 'Volume'
        set(handles.listboxROIList, 'String', handles.ROIText.Volume, 'Value', numel(handles.ROIText.Volume));
    case 'SurfLH' 
        set(handles.listboxROIList, 'String', handles.ROIText.SurfLH, 'Value', numel(handles.ROIText.SurfLH));
    case 'SurfRH'
        set(handles.listboxROIList, 'String', handles.ROIText.SurfRH, 'Value', numel(handles.ROIText.SurfRH));
end
guidata(hObject, handles);



% --- Executes on button press in togglebuttonSurfaceLeft.
function togglebuttonSurfaceLeft_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonSurfaceLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.DisplayFlag = 'SurfLH';
set(handles.pushbuttonSphere,'Enable','off');
StringCell=handles.ROIText.SurfLH;
set(handles.listboxROIList, 'String', StringCell, 'Value', numel(handles.ROIText.SurfLH));
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of togglebuttonSurfaceLeft


% --- Executes on button press in togglebuttonSurfaceRight.
function togglebuttonSurfaceRight_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonSurfaceRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.DisplayFlag = 'SurfRH';
set(handles.pushbuttonSphere,'Enable','off');
StringCell=handles.ROIText.SurfRH;
set(handles.listboxROIList, 'String', StringCell, 'Value', numel(handles.ROIText.SurfRH));
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of togglebuttonSurfaceRight


% --- Executes on button press in togglebuttonVolume.
function togglebuttonVolume_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonVolume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.DisplayFlag = 'Volume';
set(handles.pushbuttonSphere,'Enable','on');
StringCell=handles.ROIText.Volume;
set(handles.listboxROIList, 'String', StringCell, 'Value', numel(handles.ROIText.Volume));
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of togglebuttonVolume

function ROICell=GetROICell(PathCell, ROICell)
Index=false(size(PathCell));
for i=1:numel(PathCell)
    if isnumeric(PathCell{i})
        continue
    end
    flag=find(strcmpi(PathCell{i}, ROICell) > 0, 1);
    if ~isempty(flag)
        Index(i)=true;
    end
end
PathCell(Index)=[];
ROICell=[ROICell; PathCell];


function handles = SaveCurrentROIText(handles)
switch handles.DisplayFlag
    case 'Volume'
        handles.ROIText.Volume=get(handles.listboxROIList, 'String');
    case 'SurfLH' 
        handles.ROIText.SurfLH=get(handles.listboxROIList, 'String');
    case 'SurfRH'
        handles.ROIText.SurfRH=get(handles.listboxROIList, 'String');
end


% --- Executes on button press in checkboxMultipleLabel.
function checkboxMultipleLabel_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxMultipleLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.IsMultipleLabel = get(handles.checkboxMultipleLabel,'Value');
guidata(hObject, handles);
   
% Hint: get(hObject,'Value') returns toggle state of checkboxMultipleLabel
