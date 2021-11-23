function varargout = w_QCList(varargin)
% W_QCLIST MATLAB code for w_QCList.fig
%      W_QCLIST, by itself, creates a new W_QCLIST or raises the existing
%      singleton*.
%
%      H = W_QCLIST returns the handle to a new W_QCLIST or the handle to
%      the existing singleton*.
%
%      W_QCLIST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in W_QCLIST.M with the given input arguments.
%
%      W_QCLIST('Property','Value',...) creates a new W_QCLIST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before w_QCList_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to w_QCList_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help w_QCList

% Last Modified by GUIDE v2.5 02-Jul-2014 03:36:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @w_QCList_OpeningFcn, ...
                   'gui_OutputFcn',  @w_QCList_OutputFcn, ...
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


% --- Executes just before w_QCList is made visible.
function w_QCList_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to w_QCList (see VARARGIN)
MainFig=varargin{1};
TypeFlag=varargin{2};
TSVFile=varargin{3};

MainHandle=guidata(MainFig);
MainDir=get(MainHandle.WorkDirEntry, 'String');
SubjList=get(MainHandle.SubjListbox, 'String');
StringValue=get(MainHandle.SubjListbox, 'Value');
String=SubjList{StringValue};

fd=fopen(TSVFile);

if fd==-1
    error('Invalid File');
end

if strcmpi(TypeFlag, 'HM')
    %Skip first row
    textscan(fd, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s', 1, 'delimiter', '\t');
    M=textscan(fd, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s', 'delimiter', '\t');
    fclose(fd);
    
    AllSubjList=M{1};
    QCMeanFD=str2double(M{21});
    ListString=cell(numel(SubjList), 1);
    Index=false(size(SubjList));
    for i=1:numel(SubjList)
        k=find(cellfun(@(x) strcmpi(x, SubjList{i}), AllSubjList));
        ListString{i, 1}=sprintf('%s --> MeanFD: %g',...
            SubjList{i}, QCMeanFD(k));
        Index(i)=k;
    end
    
    handles.QCMeanFD=QCMeanFD(Index);
else
    %Skip first row
    textscan(fd, '%s\t%s\t%s', 1, 'delimiter', '\t');
    M=textscan(fd, '%s\t%s\t%s', 'delimiter', '\t');
    fclose(fd);

    AllSubjList=M{1};
    QCScoreList=M{2};
    QCCommentList=M{3};
    ListString=cell(numel(SubjList), 1);
    Index=false(size(SubjList));
    for i=1:numel(SubjList)
        k=find(cellfun(@(x) strcmpi(x, SubjList{i}), AllSubjList));
        ListString{i, 1}=sprintf('%s --> Score: %s; Comment: \"%s\"'.',...
            SubjList{i}, QCScoreList{k}, QCCommentList{k});
        Index(i)=k;
    end
    
    handles.QCScoreList=QCScoreList(Index);
    handles.QCCommentList=QCCommentList(Index);
end

Value=find(cellfun(@(x) strcmpi(x, String), SubjList));
if isempty(Value)
    delete(handles.figure1);
    return
end

set(handles.figure1, 'Name', TSVFile);
set(handles.TSVListbox, 'String', ListString);
set(handles.TSVListbox, 'Value', Value);
% Choose default command line output for w_QCList
handles.output = hObject;

handles.MainFig=MainFig;
handles.MainDir=MainDir;
handles.TypeFlag=TypeFlag;
handles.SubjList=SubjList;


% Make UI display correct in PC and linux
if ~ismac
    if ispc
        ZoonMatrix = [1 1 1.2 1.2];  %For pc
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

% UIWAIT makes w_QCList wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = w_QCList_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    varargout{1} = -1;
else
    varargout{1} = handles.output;
end


% --- Executes on selection change in TSVListbox.
function TSVListbox_Callback(hObject, eventdata, handles)
% hObject    handle to TSVListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TSVListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TSVListbox


% --- Executes during object creation, after setting all properties.
function TSVListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TSVListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ContinueButton.
function ContinueButton_Callback(hObject, eventdata, handles)
% hObject    handle to ContinueButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global y_spm_image_Parameters

Value=get(handles.TSVListbox, 'Value');
if strcmpi(handles.TypeFlag, 'HM')
    Subj=handles.SubjList{Value};
    FDFile=fullfile(handles.MainDir, 'RealignParameter', Subj);
    FD_J=load(fullfile(FDFile, ['FD_Jenkinson_',Subj,'.txt']));
    figure, plot(FD_J);
    xlabel('TR');
    ylabel('FD (Jenkinson)')
    title(Subj)
else
    MainDir=handles.MainDir;
    Subj=handles.SubjList{Value};
    y_spm_image_Parameters.QCScore=handles.QCScoreList{Value};
    y_spm_image_Parameters.QCComment=handles.QCCommentList{Value};
    if strcmpi(handles.TypeFlag, 'T1')
        Path=fullfile(MainDir, 'T1Img', Subj);
        D=dir(fullfile(Path, '*.nii'));
        if isempty(D)
            error('There are no T1 Image in %s', Path);
        end
        if numel(D) > 1
            D=dir(fullfile(Path, 'c*.nii'));
            if isempty(D)
                D=dir(fullfile(Path, '*_Crop_*.nii'));
            end
        end
        D=D(1);
        Image=fullfile(Path, D.name);
        w_Call_DPABI_VIEW([],[],[],0,26,Image);
    elseif strcmpi(handles.TypeFlag, 'Fun')
        Path=fullfile(MainDir, 'RealignParameter', Subj);
        D=dir(fullfile(Path, 'mean*.nii'));
        if isempty(D)
            error('There are no mean Image in %s', Path);
        end
        D=D(1);
        Image=fullfile(Path, D.name);
        w_Call_DPABI_VIEW([],[],[],0,26,Image);     
        
    %YAN Chao-Gan, 140805. Add the view function for normalization QC.
    elseif strcmpi(handles.TypeFlag, 'Norm')
        %y_QC_Normalization(MainDir, {Subj}, 1, 1, 1);
        %Modified by Sandy (BUG: Error when no Fun)
        NewSegDir=fullfile(MainDir, 'T1ImgNewSegment');
        OldSegDir=fullfile(MainDir, 'T1ImgSegment');
        RealignDir=fullfile(MainDir, 'RealignParameter');

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
        y_QC_Normalization(MainDir, {Subj}, IsCheckwT1, IsCheckwFun, IsCheckwGM)
    end
end


% --- Executes on selection change in SelectPopup.
function SelectPopup_Callback(hObject, eventdata, handles)
% hObject    handle to SelectPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SelectPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectPopup


% --- Executes during object creation, after setting all properties.
function SelectPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
