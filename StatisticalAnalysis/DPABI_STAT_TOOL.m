function varargout = DPABI_STAT_TOOL(varargin)
% DPABI_STAT_TOOL MATLAB code for DPABI_STAT_TOOL.fig
%      DPABI_STAT_TOOL, by itself, creates a new DPABI_STAT_TOOL or raises the existing
%      singleton*.
%
%      H = DPABI_STAT_TOOL returns the handle to a new DPABI_STAT_TOOL or the handle to
%      the existing singleton*.
%
%      DPABI_STAT_TOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABI_STAT_TOOL.M with the given input arguments.
%
%      DPABI_STAT_TOOL('Property','Value',...) creates a new DPABI_STAT_TOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABI_STAT_TOOL_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABI_STAT_TOOL_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABI_STAT_TOOL

% Last Modified by GUIDE v2.5 01-Dec-2016 09:26:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABI_STAT_TOOL_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABI_STAT_TOOL_OutputFcn, ...
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


% --- Executes just before DPABI_STAT_TOOL is made visible.
function DPABI_STAT_TOOL_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABI_STAT_TOOL (see VARARGIN)
if nargin > 3
    Flag=varargin{1};
else
    Flag='T1';
end
[handles.SampleNum, Value]=SwitchType(Flag);
set(handles.StatPopup, 'Value', Value);
handles=StatType(handles);
%handles=ClearConfigure(handles);
handles.SampleCells={};
handles.CovImageCells={};
handles.CurDir=pwd;
set(handles.OutputDirEntry, 'String', pwd);
% Choose default command line output for DPABI_STAT_TOOL
handles.output = hObject;

uiwait(msgbox('According to our recent study, permutation test with Threshold-Free Cluster Enhancement (TFCE) reaches the best balance between family-wise error rate (under 5%) and test-retest reliability / replicability, thus outperforms the other multiple comparison correction strategies. Please consider use and cite: Chen, X., Lu, B., Yan, C.G.*, 2018. Reproducibility of R-fMRI metrics on the impact of different strategies for multiple comparison correction and sample sizes. Hum Brain Mapp 39, 300-318.'))

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

% UIWAIT makes DPABI_STAT_TOOL wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function [Lim, Value]=SwitchType(Flag)
switch upper(Flag)
    case 'T1'
        Value=1;     
        Lim=1;
    case 'T2'
        Value=2;
        Lim=2;
    case 'TP'
        Value=3;
        Lim=2;
    case 'F'
        Value=4;
        Lim=100;
    case 'FR'
        Value=5;
        Lim=100;
    case 'R'
        Value=6;
        Lim=4;
    case 'M' %YAN Chao-Gan, 161130. Mixed effect analysis.
        Value=7;
        Lim=4;
end

function handles=StatType(handles)
Value=get(handles.StatPopup, 'Value');
CorrFlag='Off';
BaseFlag='Off';
MCFlag='Off'; %YAN Chao-Gan, 151127. For multiple comparison test.

switch Value
    case 1
        handles.SampleNum=1;
        Prefix='T';
        BaseFlag='On';
    case 2
        handles.SampleNum=2;
        Prefix='T2';
    case 3
        handles.SampleNum=2;
        Prefix='TP';
    case 4
        handles.SampleNum=100;
        Prefix='F';
        MCFlag='On';
    case 5
        handles.SampleNum=100;
        Prefix='FR';
    case 6
        handles.SampleNum=2;
        Prefix='R';
        CorrFlag='On';
    case 7 %YAN Chao-Gan, 161201. For Mixed Effect Analysis.
        handles.SampleNum=4;
        Prefix='M';
        msgbox({'Mixed Effect Analysis:';...
            'Perform the within-subject between-subject mixed effect anlaysis.';...
            'The order of the group images should be: Group1Condition1; Group1Condition2; Group2Condition1; Group2Condition2';...
            '*_ConditionEffect_T.nii/gii - the T values of condition differences (corresponding to the first condition minus the second condition) (WithinSubjectFactor)';...
            '*_Interaction_F.nii/gii - the F values of interaction (BetweenSubjectFactor by WithinSubjectFactor)';...
            '*_Group_TwoT.nii/gii - the T values of group differences (corresponding to the first group minus the second group). Of note: the two conditions will be averaged first for each subject. (BetweenSubjectFactor)';...
            'The degree of freedom information is stored in the header of the output image file.';...
            },'Help');
end

handles=ClearConfigure(handles);

set(handles.BaseLab,   'Visible', BaseFlag);
set(handles.BaseEntry, 'Visible', BaseFlag);
set(handles.PrefixEntry, 'String', Prefix);
%set(handles.CorrSeedListbox,      'Visible', CorrFlag);
%set(handles.CorrSeedRemoveButton, 'Visible', CorrFlag);
%set(handles.CorrSeedAddButton,    'Enable', CorrFlag);
set(handles.CorrSeedFrame,        'Visible', CorrFlag); 
set(handles.textMC,        'Visible', MCFlag); 
set(handles.popupmenuMC,        'Visible', MCFlag); 

% --- Outputs from this function are returned to the command line.
function varargout = DPABI_STAT_TOOL_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in StatPopup.
function StatPopup_Callback(hObject, eventdata, handles)
% hObject    handle to StatPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=StatType(handles);

guidata(hObject, handles);
% Hints: contents = cellstr(get(hObject,'String')) returns StatPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from StatPopup


% --- Executes during object creation, after setting all properties.
function StatPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StatPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in CovTextListbox.
function CovTextListbox_Callback(hObject, eventdata, handles)
% hObject    handle to CovTextListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns CovTextListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CovTextListbox


% --- Executes during object creation, after setting all properties.
function CovTextListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CovTextListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in CovImageListbox.
function CovImageListbox_Callback(hObject, eventdata, handles)
% hObject    handle to CovImageListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns CovImageListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CovImageListbox


% --- Executes during object creation, after setting all properties.
function CovImageListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CovImageListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SampleListbox.
function SampleListbox_Callback(hObject, eventdata, handles)
% hObject    handle to SampleListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SampleListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SampleListbox


% --- Executes during object creation, after setting all properties.
function SampleListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SampleListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CovTextAddButton.
function CovTextAddButton_Callback(hObject, eventdata, handles)
% hObject    handle to CovTextAddButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Name, Path]=uigetfile({'*.txt;*.csv;*.tsv','Text Covariates File (*.txt;*.csv;*.tsv)';'*.*', 'All Files (*.*)';},...
    'Pick the Text Covariates', 'MultiSelect','on');
if isnumeric(Name)
    return
end

if ischar(Name)
    Name={Name};
end
Name=Name';
PathCell=cellfun(@(name) fullfile(Path, name), Name, 'UniformOutput', false);
AddString(handles.CovTextListbox, PathCell);

% --- Executes on button press in CovTextRemoveButton.
function CovTextRemoveButton_Callback(hObject, eventdata, handles)
% hObject    handle to CovTextRemoveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.CovTextListbox, 'Value');
if Value==0
    return
end
RemoveString(handles.CovTextListbox, Value);

% --- Executes on button press in CovImageAddButton.
function CovImageAddButton_Callback(hObject, eventdata, handles)
% hObject    handle to CovImageAddButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=uigetdir(handles.CurDir, 'Pick Covariate Images Directory');
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
CovImageCell=cellfun(@(Name) fullfile(Path, Name), NameCell,...
    'UniformOutput', false);
handles.CovImageCells{numel(handles.CovImageCells)+1}=CovImageCell;
StringOne={sprintf('[%d] (%s) %s', Num, Name, Path)};
AddString(handles.CovImageListbox, StringOne);
guidata(hObject, handles);

% --- Executes on button press in CovImageRemoveButton.
function CovImageRemoveButton_Callback(hObject, eventdata, handles)
% hObject    handle to CovImageRemoveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.CovImageListbox, 'Value');
if Value==0
    return
end
handles.CovImageCells(Value)=[];
RemoveString(handles.CovImageListbox, Value);
guidata(hObject, handles);

% --- Executes on button press in SampleAddButton.
function SampleAddButton_Callback(hObject, eventdata, handles)
% hObject    handle to SampleAddButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if numel(handles.SampleCells)==handles.SampleNum
    warndlg('Invalid Number of Groups');
    return
end
Path=uigetdir(handles.CurDir, 'Pick Sample Directory');
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
SampleCell=cellfun(@(Name) fullfile(Path, Name), NameCell,...
    'UniformOutput', false);
handles.SampleCells{numel(handles.SampleCells)+1}=SampleCell;
StringOne={sprintf('[%d] (%s) %s', Num, Name, Path)};
AddString(handles.SampleListbox, StringOne);
guidata(hObject, handles);

% --- Executes on button press in SampleRemoveButton.
function SampleRemoveButton_Callback(hObject, eventdata, handles)
% hObject    handle to SampleRemoveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.SampleListbox, 'Value');
if Value==0
    return
end
handles.SampleCells(Value)=[];
RemoveString(handles.SampleListbox, Value);
guidata(hObject, handles);


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


% --- Executes on button press in MaskButton.
function MaskButton_Callback(hObject, eventdata, handles)
% hObject    handle to MaskButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Name, Path]=uigetfile({'*.img;*.nii;*.nii.gz;*.gii','Brain Image Files (*.img;*.nii;*.nii.gz;*.gii;*.mat)';'*.*', 'All Files (*.*)';},...
    'Pick the Mask file');
if isnumeric(Name)
    return
end
set(handles.MaskEntry, 'String', fullfile(Path, Name));


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
if isempty(handles.SampleCells)
    return
end
S=handles.SampleCells;
ImageCell=handles.CovImageCells;

TextCell=get(handles.CovTextListbox, 'String');
for i=1:numel(TextCell)
    TextCell{i, 1}=load(TextCell{i, 1});
end

%YAN Chao-Gan, 140805
SeedSeries=get(handles.CorrSeedListbox, 'String');
if ~isempty(SeedSeries)
    for i=1:numel(SeedSeries)
        SeedSeries{i, 1}=load(SeedSeries{i, 1});
    end
    SeedSeries = SeedSeries{1};
end

OutputDir=get(handles.OutputDirEntry, 'String');
if isempty(OutputDir)
    OutputDir=fileparts(handles.CurDir);
end
Prefix=get(handles.PrefixEntry, 'String');
OutputName=fullfile(OutputDir, [Prefix]);%YAN Chao-Gan, 181209 %OutputName=fullfile(OutputDir, [Prefix, '.nii']);

MaskFile=get(handles.MaskEntry, 'String');

%YAN Chao-Gan, 161116. Permutation test
if get(handles.checkboxPALM, 'Value');
    PALMSettings=handles.PALMSettings;
else
    PALMSettings=[];
end

Value=get(handles.StatPopup, 'Value');
switch Value
    case 1 %One-Sample
        Base=str2double(get(handles.BaseEntry, 'String'));
        if isnan(Base)
            errordlg('Invalid Base Value');
            return
        end
        y_TTest1_Image(S, OutputName, MaskFile, ImageCell, TextCell, Base, PALMSettings);
    case 2 %Two-Sample
        y_TTest2_Image(S, OutputName, MaskFile, ImageCell, TextCell, PALMSettings);
    case 3 %Paired
        y_TTestPaired_Image(S, OutputName, MaskFile, ImageCell, TextCell, PALMSettings);  
    case 4 %ANCOVA
        if exist('PALMSettings','var') && (~isempty(PALMSettings)) %YAN Chao-Gan, 161116. Add permutation test.
            y_ANCOVA1_Image(S, OutputName, MaskFile, ImageCell, TextCell, PALMSettings);
        else
            MC_list = {'None';'tukey-kramer';'lsd';'bonferroni';'dunn-sidak';'scheffe';}; %YAN Chao-Gan, 151127. Add multiple comparison test for ANCOVA
            MC_Value = get(handles.popupmenuMC,'Value');
            MC_type = MC_list{MC_Value};
            y_ANCOVA1_Multcompare_Image(S, OutputName, MaskFile, ImageCell, TextCell, MC_type);
        end
    case 5 %ANCOVA Repeat
        y_ANCOVA1_Repeated_Image(S, OutputName, MaskFile, ImageCell, TextCell, PALMSettings);
    case 6 %Corr
        y_Correlation_Image(S, SeedSeries, OutputName, MaskFile, ImageCell, TextCell, PALMSettings);
        %y_Correlation_Image(DependentDirs,SeedSeries,OutputName,MaskFile,CovariateDirs,OtherCovariates)
    case 7 %YAN Chao-Gan, 161201. For Mixed Effect Analysis.
        y_MixedEffectsAnalysis_Image(S, OutputName, MaskFile, ImageCell, TextCell, PALMSettings);
        %y_MixedEffectsAnalysis_Image(DependentDir,OutputName,MaskFile,CovariateDirs,OtherCovariates, PALMSettings)
end

% --- Executes on button press in HelpButton.
function HelpButton_Callback(hObject, eventdata, handles)
% hObject    handle to HelpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.StatPopup, 'Value');
switch Value
    case 1
        msgbox({'One-Sample T-Test:';...
            'Please specify the group images (Only one group)';...
            'Base means the null hypothesis is that the group mean equals to the base value. Default: 0';...
            'The value of each voxel in the output image is a T statistic value. The degree of freedom information is stored in the header of the output image file.';...
            },'Help');
    case 2
        msgbox({'Two-Sample T-Test:';...
            'If only the group images are specified, then perform voxel-wise Two-Sample T-Test.';...
            'If the covariate images are also specified (e.g. gray matter proportion images), then voxel-wise Two-Sample T-Test is performed while take each voxel in the covariate images as a covaraite. Please make sure the correspondence between the group images and the covariate images.';...
            'Text covariate can be also specified as text files. (E.g. age, brain size, IQ etc.)';...
            'The value of each voxel in the output image is a T statistic value (positive means the mean of Group 1 is greater than the mean of Group 2). The degree of freedom information is stored in the header of the output image file.';...
            },'Help');
    case 3
        msgbox({'Paired T-Test:';...
            'Paired T-Test is performed between the two conditions. Please make sure the correspondence of the images between the two paired conditions.';...
            'The value of each voxel in the output image is a T statistic value (positive means Condition 1 is greater than Condition 2). The degree of freedom information is stored in the header of the output image file.';...
            },'Help');        
    case 4
        msgbox({'ANOVA or ANCOVA Analysis:';...
            'If only the group images are specified, then perform voxel-wise ANOVA analysis.';...
            'If the covariate images are also specified (e.g. gray matter proportion images), then voxel-wise ANCOVA analysis is performed while take each voxel in the covariate images as a covaraite. Please make sure the correspondence between the group images and the covariate images.';...
            'Text covariate can be also specified as text files. (E.g. age, brain size, IQ etc.)';...
            'The value of each voxel in the output image is an F statistic value. The degree of freedom information is stored in the header of the output image file.';...
            },'Help');
    case 6
        msgbox({'Correlation Analysis:';...
            'If only the group images and the seed variate are specified, then perform Pearson''s correlation analysis.';...
            'If the covariate images are also specified (e.g. gray matter proportion images), then partial correlation analysis is performed while take each voxel in the covariate images as a covaraite. Please make sure the correspondence between the group images and the covariate images.';...
            'Text covariate can be also specified as text files. (E.g. age, brain size, IQ etc.)';...
            'The value of each voxel in the output image is an R statistic value. The degree of freedom information is stored in the header of the output image file.';...
            },'Help');
    case 7 %YAN Chao-Gan, 161201. For Mixed Effect Analysis.
        msgbox({'Mixed Effect Analysis:';...
            'Perform the within-subject between-subject mixed effect anlaysis.';...
            'The order of the group images should be: Group1Condition1; Group1Condition2; Group2Condition1; Group2Condition2';...
            '*_ConditionEffect_T.nii/gii - the T values of condition differences (corresponding to the first condition minus the second condition) (WithinSubjectFactor)';...
            '*_Interaction_F.nii/gii - the F values of interaction (BetweenSubjectFactor by WithinSubjectFactor)';...
            '*_Group_TwoT.nii/gii - the T values of group differences (corresponding to the first group minus the second group). Of note: the two conditions will be averaged first for each subject. (BetweenSubjectFactor)';...
            'The degree of freedom information is stored in the header of the output image file.';...
            },'Help');
end

function handles=ClearConfigure(handles)
set(handles.SampleListbox,   'String', '', 'Value', 0);
handles.SampleCells={};
handles.CovImageCells={};

set(handles.CovImageListbox, 'String', '', 'Value', 0);
set(handles.CovTextListbox,  'String', '', 'Value', 0);
set(handles.CorrSeedListbox, 'String', '', 'Value', 0);

set(handles.MaskEntry,       'String', '');
set(handles.OutputDirEntry,  'String', '');

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


% --- Executes on selection change in CorrSeedListbox.
function CorrSeedListbox_Callback(hObject, eventdata, handles)
% hObject    handle to CorrSeedListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns CorrSeedListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CorrSeedListbox


% --- Executes during object creation, after setting all properties.
function CorrSeedListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CorrSeedListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CorrSeedAddButton.
function CorrSeedAddButton_Callback(hObject, eventdata, handles)
% hObject    handle to CorrSeedAddButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if numel(handles.SampleCells)==handles.SampleNum
    warndlg('Invalid Number of Groups');
    return
end

[Name, Path]=uigetfile({'*.txt;*.csv;*.tsv','Correlation Seed Series File (*.txt;*.csv;*.tsv)';'*.*', 'All Files (*.*)';},...
    'Pick the Text Covariates');
if isnumeric(Name)
    return
end

PathCell={fullfile(Path, Name)};
AddString(handles.CorrSeedListbox, PathCell);

handles.SampleCells{numel(handles.SampleCells)+1}=fullfile(Path, Name);
guidata(hObject, handles);

% --- Executes on button press in CorrSeedRemoveButton.
function CorrSeedRemoveButton_Callback(hObject, eventdata, handles)
% hObject    handle to CorrSeedRemoveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.CorrSeedListbox, 'Value');
if Value==0
    return
end

index=0;
for i=1:numel(handles.SampleCells)
    if ischar(handles.SampleCells{i})
        index=i;
        break
    end
end

handles.SampleCells(index)=[];

RemoveString(handles.CorrSeedListbox, Value);
guidata(hObject, handles);



function BaseEntry_Callback(hObject, eventdata, handles)
% hObject    handle to BaseEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BaseEntry as text
%        str2double(get(hObject,'String')) returns contents of BaseEntry as a double


% --- Executes during object creation, after setting all properties.
function BaseEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BaseEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuMC.
function popupmenuMC_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuMC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuMC contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuMC
MC_Value = get(handles.popupmenuMC,'Value');
if MC_Value>1
    set(handles.checkboxPALM, 'Enable', 'off');
else
    set(handles.checkboxPALM, 'Enable', 'on');
end


% --- Executes during object creation, after setting all properties.
function popupmenuMC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuMC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxPALM.
function checkboxPALM_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxPALM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxPALM
if get(handles.checkboxPALM,'Value')
    uiwait(msgbox('According to our recent study, permutation test with Threshold-Free Cluster Enhancement (TFCE) reaches the best balance between family-wise error rate (under 5%) and test-retest reliability / replicability, thus outperforms the other multiple comparison correction strategies. Please consider use and cite: Chen, X., Lu, B., Yan, C.G.*, 2018. Reproducibility of R-fMRI metrics on the impact of different strategies for multiple comparison correction and sample sizes. Hum Brain Mapp 39, 300-318.'))
    uiwait(msgbox('If this module is used, please also cite : Winkler, A.M., Ridgway, G.R., Douaud, G., Nichols, T.E., Smith, S.M., 2016. Faster permutation inference in brain imaging. Neuroimage 141, 502-516.'))
    if isfield(handles,'PALMSettings')&&(~isempty(handles.PALMSettings));
        PALMSettings=handles.PALMSettings;
    else
        PALMSettings.nPerm = 5000;
        PALMSettings.ClusterInference=0; %YAN Chao-Gan, 171022. Set to 0. PALMSettings.ClusterInference=1;
        PALMSettings.ClusterFormingThreshold=2.3;
        PALMSettings.TFCE=1;
        PALMSettings.TFCE2D=0; %YAN Chao-Gan, 221116. Add TFCE2D
        PALMSettings.FDR=0;
        PALMSettings.TwoTailed=1; %YAN Chao-Gan, 171022. Set to 1. PALMSettings.TwoTailed=0;
        PALMSettings.SavePermutations=0; %YAN Chao-Gan, 210123. 
        PALMSettings.AccelerationMethod='NoAcceleration'; % or 'tail', 'gamma', 'negbin', 'lowrank', 'noperm'
        
        PALMSettings.SurfFile=''; %YAN Chao-Gan, 181209. Add surface support.
        PALMSettings.SurfAreaFile='';
    end
    handles.PALMSettings=y_PALMSetting(PALMSettings);
end
guidata(hObject, handles);
