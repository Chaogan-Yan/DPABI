function varargout = DPABI_CALCULATOR_TOOL(varargin)
% DPABI_CALCULATOR_TOOL MATLAB code for DPABI_CALCULATOR_TOOL.fig
%      DPABI_CALCULATOR_TOOL, by itself, creates a new DPABI_CALCULATOR_TOOL or raises the existing
%      singleton*.
%
%      H = DPABI_CALCULATOR_TOOL returns the handle to a new DPABI_CALCULATOR_TOOL or the handle to
%      the existing singleton*.
%
%      DPABI_CALCULATOR_TOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABI_CALCULATOR_TOOL.M with the given input arguments.
%
%      DPABI_CALCULATOR_TOOL('Property','Value',...) creates a new DPABI_CALCULATOR_TOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABI_CALCULATOR_TOOL_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABI_CALCULATOR_TOOL_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABI_CALCULATOR_TOOL

% Last Modified by GUIDE v2.5 06-Aug-2014 02:43:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABI_CALCULATOR_TOOL_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABI_CALCULATOR_TOOL_OutputFcn, ...
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


% --- Executes just before DPABI_CALCULATOR_TOOL is made visible.
function DPABI_CALCULATOR_TOOL_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABI_CALCULATOR_TOOL (see VARARGIN)

% Choose default command line output for DPABI_CALCULATOR_TOOL
handles.output = hObject;

handles.GroupCells={};
handles.GroupLabel={};
handles.ImageCells={};
handles.ImageLabel={};

handles.CurDir=pwd;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABI_CALCULATOR_TOOL wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DPABI_CALCULATOR_TOOL_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in ImageListbox.
function ImageListbox_Callback(hObject, eventdata, handles)
% hObject    handle to ImageListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ImageListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ImageListbox


% --- Executes during object creation, after setting all properties.
function ImageListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ImageAdd.
function ImageAdd_Callback(hObject, eventdata, handles)
% hObject    handle to ImageAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Names, Path]=uigetfile({'*.img;*.nii;*.nii.gz;*.gii;*.mat','Brain Image Files (*.img;*.nii;*.nii.gz;*.gii)';'*.*', 'All Files (*.*)';},...
    'Pick the Images', 'MultiSelect','on');

if isnumeric(Names)
    return
end

if ischar(Names)
    Names={Names};
end
Names=Names';
ImageCell=cellfun(@(name) fullfile(Path, name), Names,...
    'UniformOutput', false);

L=numel(handles.ImageCells);
handles.ImageCells=[handles.ImageCells; ImageCell];

for i=1:numel(ImageCell)
    [NullPath, Name, Ext]=fileparts(ImageCell{i});
    handles.ImageLabel{L+i, 1}=sprintf('i%d', L+i);
    StringOne={sprintf('{i%d} (%s%s) %s', L+i, Name, Ext, Path)};
    AddString(handles.ImageListbox, StringOne);
end
guidata(hObject, handles);

% --- Executes on button press in ImageRemove.
function ImageRemove_Callback(hObject, eventdata, handles)
% hObject    handle to ImageRemove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.ImageListbox, 'Value');
if Value==0
    return
end
handles.ImageCells(Value)=[];
handles.ImageLabel(Value)=[];
RemoveString(handles.ImageListbox, Value);
guidata(hObject, handles);

% --- Executes on selection change in GroupListbox.
function GroupListbox_Callback(hObject, eventdata, handles)
% hObject    handle to GroupListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns GroupListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from GroupListbox


% --- Executes during object creation, after setting all properties.
function GroupListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GroupListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GroupAdd.
function GroupAdd_Callback(hObject, eventdata, handles)
% hObject    handle to GroupAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=uigetdir(handles.CurDir, 'Pick Group Directory');
if isnumeric(Path)
    return
end
[handles.CurDir, Name]=fileparts(Path);

D=dir(fullfile(Path, '*.hdr'));
if isempty(D)
    D=dir(fullfile(Path, '*.nii'));
end

if isempty(D)
    D=dir(fullfile(Path, '*.nii.gz'));
end

if isempty(D)
    D=dir(fullfile(Path, '*.gii'));
end

if isempty(D)
    D=dir(fullfile(Path, '*.mat'));
end

NameCell={D.name}';
Num=numel(NameCell);
GroupCell=cellfun(@(Name) fullfile(Path, Name), NameCell,...
    'UniformOutput', false);

L=numel(handles.GroupCells);
handles.GroupCells{L+1, 1}=GroupCell;
handles.GroupLabel{L+1, 1}=sprintf('g%d', L+1);

StringOne={sprintf('{g%d}[%d] (%s) %s', L+1, Num, Name, Path)};
AddString(handles.GroupListbox, StringOne);
guidata(hObject, handles);

% --- Executes on button press in GroupRemove.
function GroupRemove_Callback(hObject, eventdata, handles)
% hObject    handle to GroupRemove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.GroupListbox, 'Value');
if Value==0
    return
end
handles.GroupCells(Value)=[];
handles.GroupLabel(Value)=[];
RemoveString(handles.GroupListbox, Value);
guidata(hObject, handles);

function ExpressionEntry_Callback(hObject, eventdata, handles)
% hObject    handle to ExpressionEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ExpressionEntry as text
%        str2double(get(hObject,'String')) returns contents of ExpressionEntry as a double


% --- Executes during object creation, after setting all properties.
function ExpressionEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ExpressionEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function OutputEntry_Callback(hObject, eventdata, handles)
% hObject    handle to OutputEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OutputEntry as text
%        str2double(get(hObject,'String')) returns contents of OutputEntry as a double


% --- Executes during object creation, after setting all properties.
function OutputEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OutputEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in OutputButton.
function OutputButton_Callback(hObject, eventdata, handles)
% hObject    handle to OutputButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=uigetdir(handles.CurDir, 'Pick Output Directory');
if isnumeric(Path)
    return
end
handles.CurDir=fileparts(Path);
set(handles.OutputEntry, 'String', Path);
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


% --- Executes on button press in ComputeButton.
function ComputeButton_Callback(hObject, eventdata, handles)
% hObject    handle to ComputeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Expression=get(handles.ExpressionEntry, 'String');
if isempty(Expression)
    errordlg('No Expression');
    return
end

GroupCells=handles.GroupCells;
GroupLabel=handles.GroupLabel;
for j=1:numel(GroupCells)

%     GroupPath=fileparts(GroupCells{j}{1});
%     fprintf('%s: %s etc.\n', GroupLabel{j}, GroupPath);    
%     CMD=sprintf('[%s, VoxelSize, FileList, Header] = y_ReadAll(''%s'');',...
%         GroupLabel{j}, GroupPath);

    %YAN Chao-Gan, 150518
    for k=1:numel(GroupCells{j})
        fprintf('%s: %s\n', GroupLabel{j}, GroupCells{j}{k});
    end
    CMD=sprintf('[%s, VoxelSize, FileList, Header] = y_ReadAll(%s);',...
        GroupLabel{j}, 'GroupCells{j}');
    eval(CMD);
end

ImageCells=handles.ImageCells;
ImageLabel=handles.ImageLabel;
for j=1:numel(ImageCells)
    fprintf('%s: %s\n', ImageLabel{j}, ImageCells{j});
    CMD=sprintf('[%s, VoxelSize, FileList, Header] = y_ReadAll(''%s'');',... %CMD=sprintf('[%s, VoxelSize, Header] = y_ReadRPI(''%s'');',...
        ImageLabel{j}, ImageCells{j});
    eval(CMD);
end

Expression=strrep(Expression,'std','w_STD');
Expression=strrep(Expression,'mean','w_MEAN');
Expression=strrep(Expression,'To4D','w_REPMAT');

Expression=strrep(Expression,'corr','w_CORR');
Expression=['Result=', Expression, ';'];
try
    eval(Expression);
catch
    error('Expression Error');
end
OutputDir=get(handles.OutputEntry, 'String');
Prefix=get(handles.PrefixEntry, 'String');

if ~isfield(Header,'cdata') %YAN Chao-Gan 181204. If NIfTI data
    FinalDim=4;
else
    FinalDim=2;
end


if any(strfind(Expression,'w_CORR')) && any(strfind(Expression,'spatial')) %YAN Chao-Gan 190109. gii compatible %ndims(Result)==2
    OutputName=fullfile(OutputDir, [Prefix, '.txt']);
    save(OutputName, 'Result',...
        '-ASCII', '-DOUBLE', '-TABS');
else
    if ~isempty(GroupCells) && ~isempty(GroupCells{1}) && (size(Result,FinalDim) == numel(GroupCells{1})) %YAN Chao-Gan, 150518
        for k=1:numel(GroupCells{1})
            [Path, fileN, extn] = fileparts(GroupCells{1}{k});
            OutputName=fullfile(OutputDir, [Prefix, fileN]);
            
            if ~isfield(Header,'cdata') %YAN Chao-Gan 181204. If NIfTI data
                y_Write(Result(:,:,:,k), Header, OutputName);
            else
                y_Write(Result(:,k), Header, OutputName);
            end

        end
    else
        OutputName=fullfile(OutputDir, [Prefix]);
        y_Write(Result, Header, OutputName);
    end
end
fprintf('Finished\n');

% --- Executes on button press in HelpButton.
function HelpButton_Callback(hObject, eventdata, handles)
% hObject    handle to HelpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox({'Example expressions:';...
    '(a)      g1-1     Subtract 1 from each image in group 1';...
    '(b)      g1-g2    Subtract each image in group 2 from each corresponding image in group1';...
    '(c)      i1-i2    Subtract image 2 from image 1';...
    '(d)      i1>100    Make a binary mask image at threshold of 100';...
    '(e)      g1.*To4D((i1>2.3),100) Make a mask (threshold at 2.3 on i1) and then apply to each image in group 1 (group 1 has 100 images)';...
    '(f)      mean(g1)   Calculate the mean image of group 1';...
    '(g)      (i1-mean(g1))./std(g1)   Calculate the z value of i1 related to group 1';...
    '(h)      corr(g1,g2,''temporal'')    Calculate the temporal correlation between two groups, i.e. one correlation coefficient between two ''time courses'' for each voxel.';...
    '(i)      corr(g1,g2,''spatial'')     Calculate the spatial correlation between two groups, i.e. one correlation coefficient between two images for each ''time point''.';...
    '(j)      corr(i1,i2,''spatial'')     Calculate the spatial correlation between two images.';...
    },'Expression Help');

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

if ~isempty(StringCell)
    for i=1:numel(StringCell)
        StringCell{i}=regexprep(StringCell{i}, '\{([ig])\d+\}', ...
            sprintf('{$1%d}', i));
    end
end

set(ListboxHandle, 'String', StringCell, 'Value', Value);

function Volume3D=w_MEAN(Volume4D)
if ndims(Volume4D)==3
    Volume3D=Volume4D;
elseif ndims(Volume4D)==4
    Volume3D=mean(Volume4D, 4);
    
elseif ndims(Volume4D)==2 %YAN Chao-Gan 190109. gii compatible
    Volume3D=mean(Volume4D, 2);
end

function Volume3D=w_STD(Volume4D)
if ndims(Volume4D)==3
    Volume3D=zeros(size(Volume4D));
elseif ndims(Volume4D)==4
    Volume3D=std(Volume4D,0,4); %YAN Chao-Gan, 20150815 Fixed a bug. %Volume3D=std(Volume4D, 4);
    
elseif ndims(Volume4D)==2 %YAN Chao-Gan 190109. gii compatible
    Volume3D=std(Volume4D,0,2);
end

function Volume4D=w_REPMAT(Volume3D, T)
if ndims(Volume3D)==3
    Volume4D=repmat(Volume3D, [1, 1, 1, T]);
elseif ndims(Volume3D)==4
    Volume4D=Volume3D;
    
elseif ndims(Volume3D)==2 %YAN Chao-Gan 190109. gii compatible
    Volume4D=repmat(Volume3D, [1, T]);
end

function V=w_CORR(V1, V2, Flag)
if strcmpi(Flag, 'temporal')
    if ndims(V1)==4
        [n1, n2, n3, n4]=size(V1);
        V1=reshape(V1, [], n4);
        V2=reshape(V2, [], n4);
        V=zeros(n1*n2*n3, 1);
        for i=1:n1*n2*n3
            V(i, 1)=corr(V1(i,:)', V2(i,:)');
        end
        V=reshape(V, [n1, n2, n3]);
    elseif ndims(V1)==2 %YAN Chao-Gan 190109. gii compatible
        [nDimVertex nDimTimePoints]=size(V1);
        V=zeros(nDimVertex, 1);
        for i=1:nDimVertex
            V(i, 1)=corr(V1(i,:)', V2(i,:)');
        end
    end
elseif strcmpi(Flag, 'spatial')
    if ndims(V1)==4 && ndims(V2)==4
        n4=size(V1, 4);
        V1=reshape(V1, [], n4);
        V2=reshape(V2, [], n4);
        V=zeros(n4, 1);
        for i=1:n4
            V(i, 1)=corr(V1(:, i), V2(:, i));
        end
    elseif ndims(V1)==4 && ndims(V2)==3
        n4=size(V1, 4);
        V1=reshape(V1, [], n4);
        V=zeros(n4, 1);
        for i=1:n4
            V(i, 1)=corr(V1(:, i), V2(:));
        end
    elseif ndims(V1)==3 && ndims(V2)==4
        n4=size(V2, 4);
        V1=reshape(V2, [], n4);
        V=zeros(n4, 1);
        for i=1:n4
            V(i, 1)=corr(V1(:), V2(:, i));
        end
        
    elseif ndims(V1)==2 && ndims(V2)==2 %YAN Chao-Gan 190109. gii compatible
        nDimTimePoints=max(size(V1, 2),size(V2, 2));
        
        if size(V1, 2)==1
            V1=repmat(V1, [1, nDimTimePoints]);
        end
        if size(V2, 2)==1
            V2=repmat(V2, [1, nDimTimePoints]);
        end

        V=zeros(nDimTimePoints, 1);
        for i=1:nDimTimePoints
            V(i, 1)=corr(V1(:, i), V2(:, i));
        end
        
    else
        V=corr(V1(:), V2(:));
    end
end
