function varargout = w_AtlasSelect(varargin)
% W_ATLASSELECT MATLAB code for w_AtlasSelect.fig
%      W_ATLASSELECT, by itself, creates a new W_ATLASSELECT or raises the existing
%      singleton*.
%
%      H = W_ATLASSELECT returns the handle to a new W_ATLASSELECT or the handle to
%      the existing singleton*.
%
%      W_ATLASSELECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in W_ATLASSELECT.M with the given input arguments.
%
%      W_ATLASSELECT('Property','Value',...) creates a new W_ATLASSELECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before w_AtlasSelect_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to w_AtlasSelect_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help w_AtlasSelect

% Last Modified by GUIDE v2.5 11-Nov-2020 12:52:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @w_AtlasSelect_OpeningFcn, ...
                   'gui_OutputFcn',  @w_AtlasSelect_OutputFcn, ...
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


% --- Executes just before w_AtlasSelect is made visible.
function w_AtlasSelect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to w_AtlasSelect (see VARARGIN)


AtlasParameters={'Select Atlas to Add'...
    'Harvard-Oxford Cortical Structural Atlas'...
    'Harvard-Oxford Subcortical Structural Atlas'...
    'AAL'...
    'AAL3'...
    'Brodmann'...
    'JHU ICBM-DTI-81 White-Matter Labels'...
    'JHU White-Matter Tractography Atlas'...
    'Custom'};

set(handles.AtlasPopup,'String',AtlasParameters);

global st

curfig=varargin{1};
AtlasInfo=st{curfig}.AtlasInfo;
ListString={};
for i=1:numel(AtlasInfo)
    ListString{i, 1}=AtlasInfo{i}.Template.Alias;
end
set(handles.AtlasList, 'String', ListString);
set(handles.AtlasList, 'Value', numel(ListString));

handles.AtlasInfo=AtlasInfo;
handles.output = hObject;
handles.MainFig=curfig;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes w_AtlasSelect wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = w_AtlasSelect_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles)
    varargout{1}=0;
else
    varargout{1}=1;
    delete(handles.figure1);
end
% Get default command line output from handles structure


% --- Executes on selection change in AtlasList.
function AtlasList_Callback(hObject, eventdata, handles)
% hObject    handle to AtlasList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns AtlasList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AtlasList


% --- Executes during object creation, after setting all properties.
function AtlasList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AtlasList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in AtlasPopup.
function AtlasPopup_Callback(hObject, eventdata, handles)
% hObject    handle to AtlasPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.AtlasPopup, 'Value');
[DPABIPath, fileN, extn] = fileparts(which('DPABI.m'));
TemplatePath=fullfile(DPABIPath, 'Templates');
ListString=get(handles.AtlasList, 'String');

switch Value
    case 1
        return
    case 2 %HOA Cortical
        NiiFile=fullfile(TemplatePath, 'HarvardOxford-cort-maxprob-thr25-2mm_YCG.nii');
        MatFile=fullfile(TemplatePath, 'HarvardOxford-cort-maxprob-thr25-2mm_YCG_Labels.mat');
        AtlasInfo=w_GetAtlasInfo(MatFile, NiiFile, 'Harvard-Oxford Cortical Structural Atlas');
    case 3 %HOA Subcortical
        NiiFile=fullfile(TemplatePath, 'HarvardOxford-sub-maxprob-thr25-2mm_YCG.nii');
        MatFile=fullfile(TemplatePath, 'HarvardOxford-sub-maxprob-thr25-2mm_YCG_Labels.mat');
        AtlasInfo=w_GetAtlasInfo(MatFile, NiiFile, 'Harvard-Oxford Subcortical Structural Atlas');        
%     case 4 %Talairach
%         NiiFile=fullfile(TemplatePath, 'HarvardOxford-cort-maxprob-thr25-2mm_YCG.nii');
%         MatFile=fullfile(TemplatePath, 'HarvardOxford-cort-maxprob-thr25-2mm_YCG_Cortical_Labels.mat');
%         AtlasInfo=w_GetAtlasInfo(MatFile, NiiFile, 'Talairach Daemon Labels');
    case 4 %AAL
        NiiFile=fullfile(TemplatePath, 'aal.nii');
        MatFile=fullfile(TemplatePath, 'aal_Labels.mat');
        AtlasInfo=w_GetAtlasInfo(MatFile, NiiFile, 'AAL');
    case 5 %AAL3
        NiiFile=fullfile(TemplatePath, 'AAL3v1_1mm.nii');
        MatFile=fullfile(TemplatePath, 'AAL3v1_1mm_Labels.mat');
        AtlasInfo=w_GetAtlasInfo(MatFile, NiiFile, 'AAL3');        
    case 6 %Brodmann
        NiiFile=fullfile(TemplatePath, 'Brodmann_YCG.nii');
        MatFile=fullfile(TemplatePath, 'Brodmann_YCG_Labels.mat');
        AtlasInfo=w_GetAtlasInfo(MatFile, NiiFile, 'Brodmann');    
    case 7 %JHU ICBM-DTI-81 White-Matter Labels
        NiiFile=fullfile(TemplatePath, 'JHU-ICBM-labels-1mm.nii');
        MatFile=fullfile(TemplatePath, 'JHU-ICBM-labels-1mm_Labels.mat');
        AtlasInfo=w_GetAtlasInfo(MatFile, NiiFile, 'JHU ICBM-DTI-81 White-Matter Labels');  
    case 8 %JHU White-Matter Tractography Atlas
        NiiFile=fullfile(TemplatePath, 'JHU-ICBM-tracts-maxprob-thr25-1mm.nii');
        MatFile=fullfile(TemplatePath, 'JHU-ICBM-tracts-maxprob-thr25-1mm_Labels.mat');
        AtlasInfo=w_GetAtlasInfo(MatFile, NiiFile, 'JHU White-Matter Tractography Atlas');  
    case 9 %Cutsom
        [File , Path]=uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
            'Pick Custom Template' , TemplatePath);
        if ~ischar(File)
            return
        end
        NiiFile=fullfile(Path, File);
        [Path, Name, Ext]=fileparts(NiiFile);
        MatFile=fullfile(Path, [Name, '_Labels.mat']);
        AtlasInfo=w_GetAtlasInfo(MatFile, NiiFile, Name);
end
Exist=any(cellfun(@(x) strcmpi(x, AtlasInfo.Template.Alias), ListString));
if Exist
    return
end
ListString{numel(ListString)+1, 1}=AtlasInfo.Template.Alias;
handles.AtlasInfo{numel(handles.AtlasInfo)+1, 1}=AtlasInfo;

set(handles.AtlasList, 'String', ListString);
set(handles.AtlasList, 'Value', numel(ListString));
guidata(hObject, handles);
% Hints: contents = cellstr(get(hObject,'String')) returns AtlasPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AtlasPopup


% --- Executes during object creation, after setting all properties.
function AtlasPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AtlasPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RemoveBtn.
function RemoveBtn_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.AtlasList, 'Value');
if ~Value
    return
end
ListString=get(handles.AtlasList, 'String');
ListString(Value)=[];
handles.AtlasInfo(Value)=[];
set(handles.AtlasList, 'String', ListString);
set(handles.AtlasList, 'Value', numel(ListString));

guidata(hObject, handles);

% --- Executes on button press in Accept.
function Accept_Callback(hObject, eventdata, handles)
% hObject    handle to Accept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global st
curfig=handles.MainFig;

st{curfig}.AtlasInfo=handles.AtlasInfo;
uiresume(handles.figure1);

% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);
delete(handles.figure1);

