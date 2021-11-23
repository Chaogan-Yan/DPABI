function varargout = DPABI_QC_TOOL(varargin)
% DPABI_QC_TOOL MATLAB code for DPABI_QC_TOOL.fig
%      DPABI_QC_TOOL, by itself, creates a new DPABI_QC_TOOL or raises the existing
%      singleton*.
%
%      H = DPABI_QC_TOOL returns the handle to a new DPABI_QC_TOOL or the handle to
%      the existing singleton*.
%
%      DPABI_QC_TOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABI_QC_TOOL.M with the given input arguments.
%
%      DPABI_QC_TOOL('Property','Value',...) creates a new DPABI_QC_TOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABI_QC_TOOL_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABI_QC_TOOL_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABI_QC_TOOL

% Last Modified by GUIDE v2.5 20-Apr-2014 12:58:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABI_QC_TOOL_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABI_QC_TOOL_OutputFcn, ...
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


% --- Executes just before DPABI_QC_TOOL is made visible.
function DPABI_QC_TOOL_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABI_QC_TOOL (see VARARGIN)
handles.SubjString=[];

handles.T1Score='';
handles.FunScore='';
handles.NormScore='';
handles.CoverageValue='';
handles.CoverageSubj=[];
handles.MeanFD='';

% Choose default command line output for DPABI_QC_TOOL
handles.output = hObject;

% Make UI display correct in PC and linux
if ~ismac
    if ispc
        ZoonMatrix = [1 1 1.5 1.5];  %For pc
    else
        ZoonMatrix = [1 1 1.2 1.2];  %For Linux
    end
    UISize = get(handles.figure1,'Position');
    UISize = UISize.*ZoonMatrix;
    set(handles.figure1,'Position',UISize);
end
movegui(handles.figure1,'center');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABI_QC_TOOL wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DPABI_QC_TOOL_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function WorkDirEntry_Callback(hObject, eventdata, handles)
% hObject    handle to WorkDirEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GetSubjList(hObject, handles);
% Hints: get(hObject,'String') returns contents of WorkDirEntry as text
%        str2double(get(hObject,'String')) returns contents of WorkDirEntry as a double


% --- Executes during object creation, after setting all properties.
function WorkDirEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WorkDirEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in WorkDirButton.
function WorkDirButton_Callback(hObject, eventdata, handles)
% hObject    handle to WorkDirButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=get(handles.WorkDirEntry, 'String');
if ~isdir(Path)
    Path=pwd;
end
Path=uigetdir(Path);
if ~ischar(Path)
    return
end
set(handles.WorkDirEntry, 'String', Path);

GetSubjList(hObject, handles);

% --- Executes on selection change in SubjListbox.
function SubjListbox_Callback(hObject, eventdata, handles)
% hObject    handle to SubjListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SubjListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SubjListbox


% --- Executes during object creation, after setting all properties.
function SubjListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SubjListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in T1Button.
function T1Button_Callback(hObject, eventdata, handles)
% hObject    handle to T1Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)WorkDir=get(handles.WorkDirEntry, 'String');
WorkDir=get(handles.WorkDirEntry, 'String');
TSVFile=fullfile(WorkDir, 'QC', 'RawT1ImgQC.tsv');
Value=get(handles.SubjListbox, 'Value');
if ~Value
    return;
end

if exist(TSVFile, 'file')~=2
    errordlg(sprintf('Cannot find %s', TSVFile));
    return;
end

w_QCList(handles.figure1, 'T1', TSVFile);

% --- Executes on button press in FunButton.
function FunButton_Callback(hObject, eventdata, handles)
% hObject    handle to FunButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
WorkDir=get(handles.WorkDirEntry, 'String');
TSVFile=fullfile(WorkDir, 'QC', 'RawFunImgQC.tsv');
Value=get(handles.SubjListbox, 'Value');
if ~Value
    return;
end

if exist(TSVFile, 'file')~=2
    errordlg(sprintf('Cannot find %s', TSVFile));
    return;
end
w_QCList(handles.figure1, 'Fun', TSVFile);

% --- Executes on button press in NormButton.
function NormButton_Callback(hObject, eventdata, handles)
% hObject    handle to NormButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
WorkDir=get(handles.WorkDirEntry, 'String');
Value=get(handles.SubjListbox, 'Value');
if ~Value
    return;
end

String=get(handles.SubjListbox, 'String');

NewSegDir=fullfile(WorkDir, 'T1ImgNewSegment');
OldSegDir=fullfile(WorkDir, 'T1ImgSegment');
RealignDir=fullfile(WorkDir, 'RealignParameter');

IsCheckwT1=0; IsCheckwGM=0;
if exist(NewSegDir, 'dir')==7 || exist(OldSegDir, 'dir')==7
    IsCheckwT1=1; IsCheckwGM=1;
end

IsCheckwFun=0;
if exist(RealignDir, 'dir')==7
    IsCheckwFun=1;
end

if ~(IsCheckwT1 || IsCheckwGM || IsCheckwFun)
    return;
end

TSVFile=fullfile(WorkDir, 'QC', 'NormalizationQC.tsv');
if exist(TSVFile, 'file')==2
    w_QCList(handles.figure1, 'Norm', TSVFile);
else
    y_QC_Normalization(WorkDir, String, IsCheckwT1, IsCheckwFun, IsCheckwGM);
end

% --- Executes on button press in MaskButton.
function MaskButton_Callback(hObject, eventdata, handles)
% hObject    handle to MaskButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%YAN Chao-Gan. For setting the percentage.
prompt ={'Please set the percentage for making the group mask. E.g, 90% of subjects have this voxel in their EPI automask.'};
def	={num2str(90)};
options.Resize='on';
options.WindowStyle='modal';
options.Interpreter='tex';
answer =inputdlg(prompt, 'Set percentage', 1, def,options);
if numel(answer)==1,
    ThrdPct = str2num(answer{1})/100;
else 
    return
end

WorkDir=get(handles.WorkDirEntry, 'String');
SubjCell=get(handles.SubjListbox, 'String');
MaskCell=cellfun(@(subj) fullfile(WorkDir, 'Masks', 'AutoMasks', ['wAutoMask_', subj,'.nii']), SubjCell,...
    'UniformOutput', false);
[MaskAll, Vox, FileCell, Header] =y_ReadAll(MaskCell);
GroupMaskDir=fullfile(WorkDir, 'Masks', 'GroupMask');
if exist(GroupMaskDir, 'dir')~=7
    mkdir(GroupMaskDir);
end

% Save All masks as a 4D file
MaskAllFile=fullfile(GroupMaskDir, 'BinarizedMaskAll4D.nii');
y_Write(MaskAll, Header, MaskAllFile);

MaskSum=sum((MaskAll~=0), 4);
Mask_Thrd=MaskSum > ( size(MaskAll, 4)*ThrdPct );
Mask_ThrdFile=fullfile(GroupMaskDir, ['GroupMask',num2str(ThrdPct*100),'Percent.nii']);
y_Write(Mask_Thrd, Header, Mask_ThrdFile);

fprintf('The group mask has been written to %s.\n',Mask_ThrdFile);

% --- Executes on button press in MotionButton.
function MotionButton_Callback(hObject, eventdata, handles)
% hObject    handle to MotionButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
WorkDir=get(handles.WorkDirEntry, 'String');
TSVFile=fullfile(WorkDir, 'RealignParameter', 'HeadMotion.tsv');
Value=get(handles.SubjListbox, 'Value');
if ~Value
    return;
end

if exist(TSVFile, 'file')~=2
    errordlg(sprintf('Cannot find %s', TSVFile));
    return;
end

w_QCList(handles.figure1, 'HM', TSVFile);

% --- Executes on button press in ThrdQCScoreButton.
function ThrdQCScoreButton_Callback(hObject, eventdata, handles)
% hObject    handle to ThrdQCScoreButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(get(handles.SubjListbox, 'String'))
    errordlg('NO Subject!');
    return
end
Flag=w_ThrdQCScore(handles.figure1);
if ~Flag
    return;
end
handles=guidata(hObject);
GetSubjList(hObject, handles);

function StartDirEntry_Callback(hObject, eventdata, handles)
% hObject    handle to StartDirEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GetSubjList(hObject, handles);
% Hints: get(hObject,'String') returns contents of StartDirEntry as text
%        str2double(get(hObject,'String')) returns contents of StartDirEntry as a double


% --- Executes during object creation, after setting all properties.
function StartDirEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartDirEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function GetSubjList(hObject, handles)
%Create by Sandy to get the Subject List
WorkDir=get(handles.WorkDirEntry, 'String');
if isempty(handles.SubjString)
    StartDir=get(handles.StartDirEntry, 'String');
    FullDir=fullfile(WorkDir, StartDir);

    if isempty(WorkDir) || isempty(StartDir) || ~isdir(FullDir)
        set(handles.SubjListbox, 'String', '', 'Value', 0);
        return
    end

    SubjStruct=dir(FullDir);
    Index=cellfun(...
        @(IsDir, NotDot) IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')),...
        {SubjStruct.isdir}, {SubjStruct.name});
    SubjStruct=SubjStruct(Index);
    SubjString={SubjStruct(:).name}';
    StartDirFlag='On';
    CustomFlag=0;
else
    SubjString=handles.SubjString;
    StartDirFlag='Off';
    CustomFlag=1;
end

%Threshold
if ~isempty(handles.T1Score)
    TSVFile=fullfile(WorkDir, 'QC', 'RawT1ImgQC.tsv');
    if exist(TSVFile, 'file')==2
        SubjString=GetRemainSubjString(SubjString, TSVFile, handles.T1Score);
    else
        warndlg(sprintf('Cannot find %s.\nPlease Control T1 Score First!', TSVFile));
    end
end

if ~isempty(handles.FunScore)
    TSVFile=fullfile(WorkDir, 'QC', 'RawFunImgQC.tsv');
    if exist(TSVFile, 'file')==2
        SubjString=GetRemainSubjString(SubjString, TSVFile, handles.FunScore);
    else
        warndlg(sprintf('Cannot find %s.\nPlease Control EPI Score First!', TSVFile));
    end   
end

if ~isempty(handles.NormScore)
    TSVFile=fullfile(WorkDir, 'QC', 'NormalizationQC.tsv');
    if exist(TSVFile, 'file')==2
        SubjString=GetRemainSubjString(SubjString, TSVFile, handles.NormScore);
    else
        warndlg(sprintf('Cannot find %s.\nPlease Control Normalization Score First!', TSVFile));
    end
end


if ~isempty(handles.CoverageValue)
    % YAN Chao-Gan, 201009. If no subjects after thresholding coverage, then no subjects.
%     if isempty(handles.CoverageSubj)
%         handles.CoverageSubj=SubjString;
%     end
    set(handles.ThrdQCScoreButton, 'Enable', 'Off');
    Index=false(size(SubjString));
    for i=1:numel(SubjString)
        TEMP=find(strcmpi(SubjString{i}, handles.CoverageSubj), 1);
        if ~isempty(TEMP)
            Index(i)=true;
        end
    end
    SubjString=SubjString(Index);
else
    set(handles.ThrdQCScoreButton, 'Enable', 'On');
end

if ~isempty(handles.MeanFD)
    set(handles.ThrdCoverageButton, 'Enable', 'Off');
    TSVFile=fullfile(WorkDir, 'RealignParameter', 'HeadMotion.tsv');
    fd=fopen(TSVFile);

    if fd==-1
        error('Invalid File');
    end

    textscan(fd, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s', 1, 'delimiter', '\t');
    M=textscan(fd, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%f', 'delimiter', '\t');
    fclose(fd);

    AllSubjList=M{1};
    %MeanFDVector=cell2mat(M{21});
    MeanFDVector=(M{21});
    Index=MeanFDVector < handles.MeanFD;
    RemainSubjList=AllSubjList(Index);
    Index=false(size(RemainSubjList));
    for i=1:numel(RemainSubjList)
        TEMP=find(strcmpi(RemainSubjList{i}, SubjString), 1);
        if ~isempty(TEMP)
            Index(i)=true;
        end
    end
    SubjString=RemainSubjList(Index);
else
    set(handles.ThrdCoverageButton, 'Enable', 'On');
end

set(handles.StartDirEntry, 'Enable', StartDirFlag);
set(handles.CustomButton, 'Value', CustomFlag);

set(handles.SubjListbox, 'String', SubjString);
set(handles.SubjListbox, 'Value', 1);

function SubjString=GetRemainSubjString(SubjString, TSVFile, Score)
fd=fopen(TSVFile);

if fd==-1
    error('Invalid File');
end

textscan(fd, '%s\t%s\t%s', 1, 'delimiter', '\t');
M=textscan(fd, '%s\t%s\t%s', 'delimiter', '\t');
fclose(fd);

AllSubjList=M{1};
QCScoreList=M{2};

Index=str2num(cell2mat(QCScoreList)) >= Score;
RemainSubjList=AllSubjList(Index);
Index=false(size(RemainSubjList));
for i=1:numel(RemainSubjList)
    TEMP=find(strcmpi(RemainSubjList{i}, SubjString), 1);
    if ~isempty(TEMP)
        Index(i)=true;
    end
end
SubjString=RemainSubjList(Index);


% --- Executes on button press in SaveSubjButton.
function SaveSubjButton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveSubjButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PDir=get(handles.WorkDirEntry, 'String');
[File , Path]=uiputfile({'*.txt;*.tsv','Subject List Files (*.txt;*.tsv)';'*.*', 'All Files (*.*)';}, ...
    'Save All Clusters' , fullfile(PDir, 'SubjectList.txt'));
if isnumeric(File)
    return
end
SubjList=get(handles.SubjListbox, 'String');
% if ispc
%     OS='pc';
% else
%     OS='unix';
% end
% dlmwrite(fullfile(Path, File), SubjList, 'precision', '%s',...
%     'delimiter', '', 'newline', OS);

%YAN Chao-Gan, 170223. Use this one for compatibility.
fid = fopen(fullfile(Path, File),'w');
for iSub=1:length(SubjList)
    fprintf(fid,'%s\n',SubjList{iSub});
end
fclose(fid);

% --- Executes on button press in ThrdCoverageButton.
function ThrdCoverageButton_Callback(hObject, eventdata, handles)
% hObject    handle to ThrdCoverageButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%if isempty(get(handles.SubjListbox, 'String'))
%    errordlg('NO Subject!');
%    return
%end
Flag=w_ThrdCoverage(handles.figure1);
if ~Flag
    return;
end
handles=guidata(hObject);
GetSubjList(hObject, handles);

% --- Executes on button press in ThrdMotionButton.
function ThrdMotionButton_Callback(hObject, eventdata, handles)
% hObject    handle to ThrdMotionButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Flag=w_ThrdMotion(handles.figure1);
if ~Flag
    return;
end
handles=guidata(hObject);
GetSubjList(hObject, handles);


% --- Executes on button press in LoadSubjButton.
function LoadSubjButton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadSubjButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PDir=get(handles.WorkDirEntry, 'String');
[File , Path]=uigetfile({'*.txt;*.tsv','Subject List Files (*.txt;*.tsv)';'*.*', 'All Files (*.*)';}, ...
    'Save All Clusters' , PDir);
if isnumeric(File)
    return
end

fd=fopen(fullfile(Path, File));
if fd==-1
    error('Invalid File');
end

M=textscan(fd, '%s', 'delimiter', '\t');
fclose(fd);

SubjString=M{1};
handles.SubjString=SubjString;
guidata(hObject, handles);
GetSubjList(hObject, handles);


% --- Executes on button press in CustomButton.
function CustomButton_Callback(hObject, eventdata, handles)
% hObject    handle to CustomButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.CustomButton, 'Value');
if Value
    handles.SubjString=get(handles.SubjListbox, 'String');
else
    handles.SubjString=[];
end
guidata(hObject, handles);
GetSubjList(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of CustomButton


% --------------------------------------------------------------------
function RemoveOneSubj_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveOneSubj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function RemoveLabel_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.SubjListbox, 'Value');
if ~Value
    return
end
OneSubj=get(handles.SubjListbox, 'String');
OneSubj=OneSubj{Value};

if isempty(handles.SubjString)
    SubjString=get(handles.SubjListbox, 'String');
else
    SubjString=handles.SubjString;
end

Index=strcmpi(OneSubj, SubjString);
SubjString=SubjString(~Index);

handles.SubjString=SubjString;
guidata(hObject, handles);
GetSubjList(hObject, handles);
