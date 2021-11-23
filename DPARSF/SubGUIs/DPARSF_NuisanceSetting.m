function varargout = DPARSF_NuisanceSetting(varargin)
% DPARSF_NUISANCESETTING MATLAB code for DPARSF_NuisanceSetting.fig
%      DPARSF_NUISANCESETTING, by itself, creates a new DPARSF_NUISANCESETTING or raises the existing
%      singleton*.
%
%      H = DPARSF_NUISANCESETTING returns the handle to a new DPARSF_NUISANCESETTING or the handle to
%      the existing singleton*.
%
%      DPARSF_NUISANCESETTING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPARSF_NUISANCESETTING.M with the given input arguments.
%
%      DPARSF_NUISANCESETTING('Property','Value',...) creates a new DPARSF_NUISANCESETTING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPARSF_NuisanceSetting_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPARSF_NuisanceSetting_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPARSF_NuisanceSetting

% Last Modified by GUIDE v2.5 24-Nov-2015 09:23:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @DPARSF_NuisanceSetting_OpeningFcn, ...
    'gui_OutputFcn',  @DPARSF_NuisanceSetting_OutputFcn, ...
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


% --- Executes just before DPARSF_NuisanceSetting is made visible.
function DPARSF_NuisanceSetting_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPARSF_NuisanceSetting (see VARARGIN)
if nargin<4
    Covremove.WM.IsRemove = 1; % or 0
    Covremove.WM.Mask = 'SPM'; % or 'Segment'
    Covremove.WM.MaskThreshold = 0.99;
    Covremove.WM.Method = 'Mean'; %or 'CompCor'
    Covremove.WM.CompCorPCNum = 5;
    
    Covremove.CSF.IsRemove = 1; % or 0
    Covremove.CSF.Mask = 'SPM'; % or 'Segment'
    Covremove.CSF.MaskThreshold = 0.99;
    Covremove.CSF.Method = 'Mean'; %or 'CompCor'
    Covremove.CSF.CompCorPCNum = 5;
    
    Covremove.WholeBrain.IsRemove = 0; % or 1
    Covremove.WholeBrain.IsBothWithWithoutGSR = 1; % or 0 %YAN Chao-Gan, 151123
    Covremove.WholeBrain.Mask = 'SPM'; % or 'AutoMask'
    Covremove.WholeBrain.Method = 'Mean';
else
    Covremove=varargin{1};
    if ~isfield(Covremove.WholeBrain,'IsBothWithWithoutGSR')  %YAN Chao-Gan, 151123
        Covremove.WholeBrain.IsBothWithWithoutGSR = 0;
    end
end
Init(Covremove, handles);

% Update handles structure
handles.Covremove=Covremove;

% Make UI display correct in PC and linux
if ~ismac
    if ispc
        ZoonMatrix = [1 1 1.5 1.5];  %For pc
    else
        ZoonMatrix = [1 1 1.3 1.3];  %For Linux
    end
    UISize = get(handles.figure1,'Position');
    UISize = UISize.*ZoonMatrix;
    set(handles.figure1,'Position',UISize);
end
movegui(handles.figure1,'center');


guidata(hObject, handles);

% UIWAIT makes DPARSF_NuisanceSetting wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DPARSF_NuisanceSetting_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    varargout{1} = [];
else
    varargout{1} = handles.Covremove;
    delete(handles.figure1)
end


% --- Executes on button press in AcceptButton.
function AcceptButton_Callback(hObject, eventdata, handles)
% hObject    handle to AcceptButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Covremove=handles.Covremove;
%%WM Started
Covremove.WM.IsRemove=get(handles.WMButton, 'Value');
%Method
Value=get(handles.MethodPopup, 'Value');
if Value==1
    Method='Mean';
else
    Method='CompCor';
end
Covremove.WM.Method=Method;
%Mask
Value=get(handles.WMMaskPopup, 'Value');
if Value==1
    Mask='SPM';
else
    Mask='Segment';
end
Covremove.WM.Mask=Mask;
%Mask Threshold
Covremove.WM.MaskThreshold=str2num(get(handles.WMThrdEntry, 'String'));
%PC Number
Covremove.WM.CompCorPCNum=str2num(get(handles.edit_PCNumber, 'String'));

%% CSF Started
Covremove.CSF.IsRemove=get(handles.CSFButton, 'Value');
%Method
Value=get(handles.MethodPopup, 'Value');
if Value==1
    Method='Mean';
else
    Method='CompCor';
end
Covremove.CSF.Method=Method;
%Mask
Value=get(handles.CSFMaskPopup, 'Value');
if Value==1
    Mask='SPM';
else
    Mask='Segment';
end
Covremove.CSF.Mask=Mask;
%Mask Threshold
Covremove.CSF.MaskThreshold=str2num(get(handles.CSFThrdEntry, 'String'));
%PC Number
Covremove.CSF.CompCorPCNum=str2num(get(handles.edit_PCNumber, 'String'));

%%Global Signal Started
Covremove.WholeBrain.IsRemove=get(handles.WholeBrainButton, 'Value');
Covremove.WholeBrain.IsBothWithWithoutGSR=get(handles.checkboxBothWithWithoutGSR, 'Value'); %YAN Chao-Gan, 151123
%Method
Covremove.WholeBrain.Method=get(handles.WholeBrainMethodPopup, 'String');
%Mask
Value=get(handles.WholeBrainMaskPopup, 'Value');
if Value==1
    Mask='SPM';
else
    Mask='AutoMask';
end
Covremove.WholeBrain.Mask=Mask;

handles.Covremove=Covremove;
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in CancelButton.
function CancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to CancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);


% --- Executes on button press in WMButton.
function WMButton_Callback(hObject, eventdata, handles)
% hObject    handle to WMButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CheckOnOff('WM', handles);
% Hint: get(hObject,'Value') returns toggle state of WMButton


% --- Executes on selection change in WMMaskPopup.
function WMMaskPopup_Callback(hObject, eventdata, handles)
% hObject    handle to WMMaskPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CheckOnOff('WM', handles);
% Hints: contents = cellstr(get(hObject,'String')) returns WMMaskPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from WMMaskPopup


% --- Executes during object creation, after setting all properties.
function WMMaskPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WMMaskPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function WMThrdEntry_Callback(hObject, eventdata, handles)
% hObject    handle to WMThrdEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WMThrdEntry as text
%        str2double(get(hObject,'String')) returns contents of WMThrdEntry as a double


% --- Executes during object creation, after setting all properties.
function WMThrdEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WMThrdEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in MethodPopup.
function MethodPopup_Callback(hObject, eventdata, handles)
% hObject    handle to MethodPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Tag='WM';
WMButtonWidget=sprintf('%sButton',  Tag);
WMMaskWidget=sprintf('%sMaskPopup', Tag);
WMThrdWidget=sprintf('%sThrdEntry', Tag);
Tag='CSF';
CSFButtonWidget=sprintf('%sButton',  Tag);
CSFMaskWidget=sprintf('%sMaskPopup', Tag);
CSFThrdWidget=sprintf('%sThrdEntry', Tag);

Value=get(handles.MethodPopup, 'Value');
if Value==2
    set(handles.(WMButtonWidget),  'Value', 1);
    set(handles.(CSFButtonWidget), 'Value', 1);
    
    set(handles.(WMMaskWidget), 'Enable', 'On');
    MaskType=get(handles.(WMMaskWidget), 'Value');
    if MaskType==1
        MaskFlag='Off';
    elseif MaskType==2
        MaskFlag='On';
    end
    set(handles.(WMThrdWidget), 'Enable', MaskFlag);
    
    set(handles.(CSFMaskWidget), 'Enable', 'On');
    MaskType=get(handles.(CSFMaskWidget), 'Value');
    if MaskType==1
        MaskFlag='Off';
    elseif MaskType==2
        MaskFlag='On';
    end
    set(handles.(CSFThrdWidget), 'Enable', MaskFlag);
end

CheckOnOff('WM', handles); %Update the "enable" of the PC Number Edit. YAN Chao-Gan, 140805

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


% --- Executes on button press in CSFButton.
function CSFButton_Callback(hObject, eventdata, handles)
% hObject    handle to CSFButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CheckOnOff('CSF', handles);
% Hint: get(hObject,'Value') returns toggle state of CSFButton


% --- Executes on selection change in CSFMaskPopup.
function CSFMaskPopup_Callback(hObject, eventdata, handles)
% hObject    handle to CSFMaskPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CheckOnOff('CSF', handles);
% Hints: contents = cellstr(get(hObject,'String')) returns CSFMaskPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CSFMaskPopup


% --- Executes during object creation, after setting all properties.
function CSFMaskPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CSFMaskPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CSFThrdEntry_Callback(hObject, eventdata, handles)
% hObject    handle to CSFThrdEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CSFThrdEntry as text
%        str2double(get(hObject,'String')) returns contents of CSFThrdEntry as a double


% --- Executes during object creation, after setting all properties.
function CSFThrdEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CSFThrdEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in CSFMethodPopup.
function CSFMethodPopup_Callback(hObject, eventdata, handles)
% hObject    handle to CSFMethodPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns CSFMethodPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CSFMethodPopup


% --- Executes during object creation, after setting all properties.
function CSFMethodPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CSFMethodPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in WholeBrainButton.
function WholeBrainButton_Callback(hObject, eventdata, handles)
% hObject    handle to WholeBrainButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.WholeBrainButton, 'Value') %YAN Chao-Gan, 151123
    set(handles.checkboxBothWithWithoutGSR, 'Value', 0)
end
CheckOnOff('WholeBrain', handles);
% Hint: get(hObject,'Value') returns toggle state of WholeBrainButton


% --- Executes on button press in checkboxBothWithWithoutGSR.
function checkboxBothWithWithoutGSR_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxBothWithWithoutGSR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxBothWithWithoutGSR
if get(handles.checkboxBothWithWithoutGSR, 'Value') %YAN Chao-Gan, 151123
    set(handles.WholeBrainButton, 'Value', 0)
end
CheckOnOff('WholeBrain', handles);


% --- Executes on selection change in WholeBrainMaskPopup.
function WholeBrainMaskPopup_Callback(hObject, eventdata, handles)
% hObject    handle to WholeBrainMaskPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns WholeBrainMaskPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from WholeBrainMaskPopup


% --- Executes during object creation, after setting all properties.
function WholeBrainMaskPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WholeBrainMaskPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in WholeBrainMethodPopup.
function WholeBrainMethodPopup_Callback(hObject, eventdata, handles)
% hObject    handle to WholeBrainMethodPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns WholeBrainMethodPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from WholeBrainMethodPopup


% --- Executes during object creation, after setting all properties.
function WholeBrainMethodPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WholeBrainMethodPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CheckOnOff(Tag, handles)
ButtonWidget=sprintf('%sButton',      Tag);
MethodWidget='MethodPopup';
MaskWidget=sprintf('%sMaskPopup',     Tag);
ThrdWidget=sprintf('%sThrdEntry',     Tag);

Value=get(handles.(ButtonWidget), 'Value');
Flag='Off';
if Value
    Flag='On';
end

if strcmpi(Tag, 'WholeBrain') %YAN Chao-Gan, 151123. Check the competition between "Global Signal" and "Both with & without GSR".
    if get(handles.checkboxBothWithWithoutGSR, 'Value')
        Flag='On';
    end
end

set(handles.(MaskWidget), 'Enable', Flag);
if isfield(handles, ThrdWidget)
    set(handles.(ThrdWidget), 'Enable', Flag);
    MaskType=get(handles.(MaskWidget), 'Value');
    if MaskType==1
        set(handles.(ThrdWidget), 'Enable','Off');
    end
    
    %Other
    if strcmpi(Tag, 'WM')
        Other='CSF';
    else
        Other='WM';
    end
    OtherButtonWidget=sprintf('%sButton', Other);
    OtherValue=get(handles.(OtherButtonWidget), 'Value');
    
    MethodType=get(handles.(MethodWidget), 'Value');
    if Value && OtherValue
        MFlag='On';
        MValue=MethodType;
    elseif Value || OtherValue
        MFlag='On';
        MValue=MethodType;  %%YAN Chao-Gan, 140805. MValue=1;
    else
        MFlag='Off';
        MValue=1;
    end
    
    set(handles.(MethodWidget), 'Enable', MFlag, 'Value', MValue);
    
    %YAN Chao-Gan, added PC number. 140805.
    PCNumberFlag='off';
    if strcmpi(MFlag,'on') && (MValue==2)
        PCNumberFlag='on';
    end
    set(handles.edit_PCNumber, 'Enable', PCNumberFlag);
    
end

function Init(Struct, handles)
%White Matter Widget
Tag='WM';
WMButtonWidget=sprintf('%sButton',      Tag);
MethodWidget='MethodPopup';
WMMaskWidget=sprintf('%sMaskPopup',     Tag);
WMThrdWidget=sprintf('%sThrdEntry',     Tag);
BtnValue=Struct.(Tag).IsRemove;
Flag='Off';
if BtnValue
    Flag='On';
end
set(handles.(WMButtonWidget), 'Value', BtnValue)
%Method
Method=Struct.(Tag).Method;
if strcmpi('Mean', Method)
    MedValue=1;
elseif strcmpi('CompCor', Method)
    MedValue=2;
end
set(handles.(MethodWidget), 'Enable', Flag, 'Value', MedValue);
%Segment
Mask=Struct.(Tag).Mask;
if strcmpi('SPM', Mask)
    MaskValue=1;
elseif strcmpi('Segment', Mask)
    MaskValue=2;
end
set(handles.(WMMaskWidget),   'Enable', Flag, 'Value', MaskValue);
%Thrd
ThrdString=num2str(Struct.(Tag).MaskThreshold);
set(handles.(WMThrdWidget), 'Enable', Flag, 'String', ThrdString);
if MaskValue==1
    set(handles.(WMThrdWidget), 'Enable', 'Off');
end

%CSF Widget
Tag='CSF';
CSFButtonWidget=sprintf('%sButton',      Tag);
CSFMethodWidget='MethodPopup';
CSFMaskWidget=sprintf('%sMaskPopup',     Tag);
CSFThrdWidget=sprintf('%sThrdEntry',     Tag);
BtnValue=Struct.(Tag).IsRemove;
Flag='Off';
if BtnValue
    Flag='On';
end
set(handles.(CSFButtonWidget), 'Value', BtnValue)
%Method
Method=Struct.(Tag).Method;
if strcmpi('Mean', Method)
    MedValue=1;
elseif strcmpi('CompCor', Method)
    MedValue=2;
end

Flag='Off';
if Struct.WM.IsRemove || Struct.CSF.IsRemove
    Flag='On';
end
set(handles.(CSFMethodWidget), 'Enable', Flag, 'Value', MedValue);

%YAN Chao-Gan, added PC number. 140805.
PCNumberFlag='Off';
if strcmpi(Flag,'On') && strcmpi('CompCor', Method)
    PCNumberFlag='On';
end
PCNumberString=num2str(Struct.(Tag).CompCorPCNum);
set(handles.edit_PCNumber, 'Enable', PCNumberFlag, 'String', PCNumberString);

%Segment
Mask=Struct.(Tag).Mask;
if strcmpi('SPM', Mask)
    MaskValue=1;
elseif strcmpi('Segment', Mask)
    MaskValue=2;
end
set(handles.(CSFMaskWidget),   'Enable', Flag, 'Value', MaskValue);
%Thrd
ThrdString=num2str(Struct.(Tag).MaskThreshold);
set(handles.(CSFThrdWidget), 'Enable', Flag, 'String', ThrdString);
if MaskValue==1
    set(handles.(CSFThrdWidget), 'Enable', 'Off');
end

Tag='WholeBrain';
WBButtonWidget=sprintf('%sButton',      Tag);
WBMethodWidget=sprintf('%sMethodPopup', Tag);
WBMaskWidget=sprintf('%sMaskPopup',     Tag);
BtnValue=Struct.(Tag).IsRemove;
Flag='Off';
if BtnValue || Struct.(Tag).IsBothWithWithoutGSR  %YAN Chao-Gan, 151123
    Flag='On';
end
set(handles.(WBButtonWidget), 'Value', BtnValue)
set(handles.checkboxBothWithWithoutGSR, 'Value', Struct.(Tag).IsBothWithWithoutGSR); %YAN Chao-Gan, 151123
%Method
Method=Struct.(Tag).Method;
set(handles.(WBMethodWidget), 'String',Method);
%Segment
Mask=Struct.(Tag).Mask;
if strcmpi('SPM', Mask)
    MaskValue=1;
elseif strcmpi('AutoMask', Mask)
    MaskValue=2;
end
set(handles.(WBMaskWidget),   'Enable', Flag, 'Value', MaskValue);



function edit_PCNumber_Callback(hObject, eventdata, handles)
% hObject    handle to edit_PCNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_PCNumber as text
%        str2double(get(hObject,'String')) returns contents of edit_PCNumber as a double


% --- Executes during object creation, after setting all properties.
function edit_PCNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_PCNumber (see GCBO)
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
