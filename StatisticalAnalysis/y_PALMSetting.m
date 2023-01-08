function varargout = y_PALMSetting(varargin)
% Y_PALMSETTING MATLAB code for y_PALMSetting.fig
%      Y_PALMSETTING, by itself, creates a new Y_PALMSETTING or raises the existing
%      singleton*.
%
%      H = Y_PALMSETTING returns the handle to a new Y_PALMSETTING or the handle to
%      the existing singleton*.
%
%      Y_PALMSETTING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in Y_PALMSETTING.M with the given input arguments.
%
%      Y_PALMSETTING('Property','Value',...) creates a new Y_PALMSETTING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before y_PALMSetting_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to y_PALMSetting_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help y_PALMSetting

% Last Modified by GUIDE v2.5 16-Nov-2022 09:07:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @y_PALMSetting_OpeningFcn, ...
    'gui_OutputFcn',  @y_PALMSetting_OutputFcn, ...
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


% --- Executes just before y_PALMSetting is made visible.
function y_PALMSetting_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to y_PALMSetting (see VARARGIN)
if nargin<4
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
else
    PALMSettings=varargin{1};
end
Init(PALMSettings, handles);

% Update handles structure
handles.PALMSettings=PALMSettings;

if ~ismac
    if ispc
        ZoonMatrix = [1 1 1.5 1.5];  %For pc
    else
        ZoonMatrix = [1 1 1.5 1.5];  %For Linux
    end
    UISize = get(handles.figure1,'Position');
    UISize = UISize.*ZoonMatrix;
    set(handles.figure1,'Position',UISize);
end


% Make Display correct in Mac and linux
if ~ispc
    if ismac
        ZoomFactor=1;  %For Mac
    else
        ZoomFactor=1;  %For Linux
    end
    ObjectNames = fieldnames(handles);
    for i=1:length(ObjectNames);
        eval(['IsFontSizeProp=isprop(handles.',ObjectNames{i},',''FontSize'');']);
        if IsFontSizeProp
            eval(['PCFontSize=get(handles.',ObjectNames{i},',''FontSize'');']);
            FontSize=PCFontSize*ZoomFactor;
            eval(['set(handles.',ObjectNames{i},',''FontSize'',',num2str(FontSize),');']);
        end
    end
end

movegui(handles.figure1,'center');

guidata(hObject, handles);

% UIWAIT makes y_PALMSetting wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = y_PALMSetting_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    varargout{1} = [];
else
    varargout{1} = handles.PALMSettings;
    delete(handles.figure1)
end


% --- Executes on button press in AcceptButton.
function AcceptButton_Callback(hObject, eventdata, handles)
% hObject    handle to AcceptButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PALMSettings=handles.PALMSettings;

PALMSettings.nPerm=str2num(get(handles.edit_PermNumber, 'String'));
PALMSettings.ClusterInference=get(handles.checkboxClusterInference, 'Value');
PALMSettings.ClusterFormingThreshold=str2num(get(handles.editClusterFormingThreshold, 'String'));
PALMSettings.TFCE=get(handles.checkboxTFCE, 'Value');
PALMSettings.TFCE2D=get(handles.checkboxTFCE2D, 'Value');
PALMSettings.FDR=get(handles.checkboxFDR, 'Value');
PALMSettings.TwoTailed=get(handles.checkboxTwoTailed, 'Value');
PALMSettings.SavePermutations=get(handles.checkboxSavePermutations, 'Value');; %YAN Chao-Gan, 210123. 
switch get(handles.MethodPopup,'Value')
    case 1
        PALMSettings.AccelerationMethod='NoAcceleration';
    case 2
        PALMSettings.AccelerationMethod='tail';
    case 3
        PALMSettings.AccelerationMethod='gamma';
    case 4
        PALMSettings.AccelerationMethod='negbin';
    case 5
        PALMSettings.AccelerationMethod='lowrank';
    case 6
        PALMSettings.AccelerationMethod='noperm';
end
PALMSettings.SurfFile=get(handles.editSurfaceFile,'String'); %YAN Chao-Gan, 181209. Add surface support.
PALMSettings.SurfAreaFile=get(handles.editSurfaceAreaFile,'String'); %YAN Chao-Gan, 181209. Add surface support.
handles.PALMSettings=PALMSettings;
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in CancelButton.
function CancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to CancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);


% --- Executes on button press in checkboxTFCE.
function checkboxTFCE_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxTFCE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkboxTFCE
if get(handles.checkboxTFCE, 'Value')
    set(handles.checkboxTFCE2D, 'Value', 0);
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


% --- Executes on button press in checkboxClusterInference.
function checkboxClusterInference_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxClusterInference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkboxClusterInference
if get(handles.checkboxClusterInference, 'Value') %YAN Chao-Gan, 151123
    set(handles.editClusterFormingThreshold, 'Enable', 'on');
else
    set(handles.editClusterFormingThreshold, 'Enable', 'off');
end



function editClusterFormingThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to editClusterFormingThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editClusterFormingThreshold as text
%        str2double(get(hObject,'String')) returns contents of editClusterFormingThreshold as a double


% --- Executes during object creation, after setting all properties.
function editClusterFormingThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editClusterFormingThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxFDR.
function checkboxFDR_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxFDR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkboxFDR



function edit_PermNumber_Callback(hObject, eventdata, handles)
% hObject    handle to edit_PermNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_PermNumber as text
%        str2double(get(hObject,'String')) returns contents of edit_PermNumber as a double


% --- Executes during object creation, after setting all properties.
function edit_PermNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_PermNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
uiresume(handles.figure1);


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkboxTwoTailed.
function checkboxTwoTailed_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxTwoTailed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxTwoTailed


function Init(Struct, handles)
set(handles.edit_PermNumber,'String', num2str(Struct.nPerm));
Flag='Off';
if Struct.ClusterInference
    Flag='On';
end
set(handles.checkboxClusterInference, 'Value', Struct.ClusterInference);
set(handles.editClusterFormingThreshold, 'Enable', Flag, 'String', num2str(Struct.ClusterFormingThreshold));
set(handles.checkboxTFCE, 'Value', Struct.TFCE);
set(handles.checkboxTFCE2D, 'Value', Struct.TFCE2D);
set(handles.checkboxFDR, 'Value', Struct.FDR);
set(handles.checkboxTwoTailed, 'Value', Struct.TwoTailed);
set(handles.checkboxSavePermutations, 'Value', Struct.SavePermutations);
switch Struct.AccelerationMethod
    case 'NoAcceleration'
        MethodValue=1;
    case 'tail'
        MethodValue=2;
    case 'gamma'
        MethodValue=3;
    case 'negbin'
        MethodValue=4;
    case 'lowrank'
        MethodValue=5;
    case 'noperm'
        MethodValue=6;
end
set(handles.MethodPopup,'Value', MethodValue);
set(handles.editSurfaceFile,'String',Struct.SurfFile); %YAN Chao-Gan, 181209. Add surface support.
set(handles.editSurfaceAreaFile,'String',Struct.SurfAreaFile);


function editSurfaceFile_Callback(hObject, eventdata, handles)
% hObject    handle to editSurfaceFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSurfaceFile as text
%        str2double(get(hObject,'String')) returns contents of editSurfaceFile as a double


% --- Executes during object creation, after setting all properties.
function editSurfaceFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSurfaceFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSurfaceFile.
function pushbuttonSurfaceFile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSurfaceFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName]=uigetfile({'*.gii','Surface File (*.gii)';'*.*', 'All Files (*.*)';}, 'Pick a surface file for surface based permutation test', fullfile(fileparts(which('DPABI.m')), 'DPABISurf', 'SurfTemplates'));
if ~([FileName,PathName]==0)
    set(handles.editSurfaceFile,'String',[PathName,FileName]);
end
guidata(hObject, handles);



function editSurfaceAreaFile_Callback(hObject, eventdata, handles)
% hObject    handle to editSurfaceAreaFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSurfaceAreaFile as text
%        str2double(get(hObject,'String')) returns contents of editSurfaceAreaFile as a double





% --- Executes during object creation, after setting all properties.
function editSurfaceAreaFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSurfaceAreaFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSurfaceAreaFile.
function pushbuttonSurfaceAreaFile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSurfaceAreaFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName]=uigetfile({'*.gii','Surface Area File (*.gii)';'*.*', 'All Files (*.*)';}, '[Optional] Pick a surface area file for surface based permutation test', fullfile(fileparts(which('DPABI.m')), 'DPABISurf', 'SurfTemplates'));
if ~([FileName,PathName]==0)
    set(handles.editSurfaceAreaFile,'String',[PathName,FileName]);
end
guidata(hObject, handles);


% --- Executes on button press in checkboxSavePermutations.
function checkboxSavePermutations_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSavePermutations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxSavePermutations


% --- Executes on button press in checkboxTFCE2D.
function checkboxTFCE2D_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxTFCE2D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxTFCE2D
if get(handles.checkboxTFCE2D, 'Value')
    set(handles.checkboxTFCE, 'Value', 0);
end

