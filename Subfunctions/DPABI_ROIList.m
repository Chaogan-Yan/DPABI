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

% Last Modified by GUIDE v2.5 05-Jan-2017 09:57:15

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
    ROICell=varargin{1};
    StringCell=ROICell;
    for i=1:numel(ROICell)
        if isnumeric(ROICell{i})
            s=ROICell{i};
            StringCell{i}=sprintf('Sphere ( X: %g -- Y: %g -- Z: %g >> Radius: %g )',...
                s(1), s(2), s(3), s(4));
        end
    end
    set(handles.ROIListbox, 'String', StringCell);
    handles.ROICell=ROICell;
else
    handles.ROICell={};
end    

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
    varargout{1} = handles.ROICell;
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
handles.ROICell=GetROICell(SphereCell, handles.ROICell);
StringCell=get(handles.ROIListbox, 'String');
guidata(hObject, handles);

TextCell=cellfun(@(s) sprintf('Sphere ( X: %g -- Y: %g -- Z: %g >> Radius: %g )', s(1), s(2), s(3), s(4)), SphereCell,...
    'UniformOutput', false);
StringCell=[StringCell;TextCell];

set(handles.ROIListbox, 'String', StringCell,...
    'Value', numel(handles.ROICell));

% --- Executes on button press in MaskButton.
function MaskButton_Callback(hObject, eventdata, handles)
% hObject    handle to MaskButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Name, Path]=uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';},...
    'Pick the Masks for ROI', 'MultiSelect','on');
if isnumeric(Name)
    return
end

if ischar(Name)
    Name={Name};
end
Name=Name';
PathCell=cellfun(@(name) fullfile(Path, name), Name, 'UniformOutput', false);

handles.ROICell=GetROICell(PathCell, handles.ROICell);

StringCell=get(handles.ROIListbox, 'String');
StringCell=[StringCell; PathCell];
set(handles.ROIListbox, 'String', StringCell,...
    'Value', numel(handles.ROICell));

guidata(hObject, handles);

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
handles.ROICell=GetROICell(PathCell, handles.ROICell);

StringCell=get(handles.ROIListbox, 'String');
StringCell=[StringCell; PathCell];
set(handles.ROIListbox, 'String', StringCell,...
    'Value', numel(handles.ROICell));

guidata(hObject, handles);

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
handles.ROICell(Value)=[];
StringCell(Value)=[];
guidata(hObject, handles);

if isempty(handles.ROICell)
    Value=0;
elseif numel(handles.ROICell) < Value
    Value=Value-1;
end
set(handles.ROIListbox, 'String', StringCell, 'Value', Value);



% --- Executes on button press in pushbuttonClearAll.
function pushbuttonClearAll_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonClearAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.ROICell=[];
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
ROICell=handles.ROICell;
save(Path, 'ROICell');

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
handles.ROICell=M.ROICell;
guidata(hObject, handles);

ROICell=M.ROICell;
for i=1:numel(ROICell)
    if isnumeric(ROICell{i})
        s=ROICell{i};
        ROICell{i}=sprintf('Sphere ( X: %g -- Y: %g -- Z: %g >> Radius: %g )', s(1), s(2), s(3), s(4));
    end
end
set(handles.ROIListbox, 'String', ROICell, 'Value', numel(ROICell));


