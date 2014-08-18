function varargout = w_OverlayList(varargin)
% W_OVERLAYLIST M-file for w_OverlayList.fig
%      W_OVERLAYLIST, by itself, creates a new W_OVERLAYLIST or raises the existing
%      singleton*.
%
%      H = W_OVERLAYLIST returns the handle to a new W_OVERLAYLIST or the handle to
%      the existing singleton*.
%
%      W_OVERLAYLIST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in W_OVERLAYLIST.M with the given input arguments.
%
%      W_OVERLAYLIST('Property','Value',...) creates a new W_OVERLAYLIST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before w_OverlayList_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to w_OverlayList_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help w_OverlayList

% Last Modified by GUIDE v2.5 28-Oct-2013 14:38:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @w_OverlayList_OpeningFcn, ...
                   'gui_OutputFcn',  @w_OverlayList_OutputFcn, ...
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


% --- Executes just before w_OverlayList is made visible.
function w_OverlayList_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to w_OverlayList (see VARARGIN)

% Choose default command line output for w_OverlayList
handles.MainFig=varargin{1};
MainHandle=guidata(handles.MainFig);

%set(MainHandle.ThrdSlider, 'Value',  0);
set(MainHandle.ThrdEntry,  'String', []);
set(MainHandle.PEntry, 'String', []);

OverlayHeaders=MainHandle.OverlayHeaders;
for i=GetIndex(OverlayHeaders);
    if i==0
        handles.CurDir=pwd;
        break;
    end
    handles.CurDir=InitOverlay(OverlayHeaders{i}, handles, i);
end
handles.OverlayHeaders=OverlayHeaders;
handles.output = 0;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes w_OverlayList wait for user response (see UIRESUME)
uiwait(handles.List_Fig);


% --- Outputs from this function are returned to the command line.
function varargout = w_OverlayList_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    handles.output=0;
else
    delete(handles.List_Fig);
end
varargout{1} = handles.output;


% --- Executes on button press in OverlayCheck1.
function OverlayCheck1_Callback(hObject, eventdata, handles)
% hObject    handle to OverlayCheck1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SelectOverlay(hObject, handles, 1);
% Hint: get(hObject,'Value') returns toggle state of OverlayCheck1


% --- Executes on button press in OverlayCheck2.
function OverlayCheck2_Callback(hObject, eventdata, handles)
% hObject    handle to OverlayCheck2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SelectOverlay(hObject, handles, 2);
% Hint: get(hObject,'Value') returns toggle state of OverlayCheck2


% --- Executes on button press in OverlayCheck3.
function OverlayCheck3_Callback(hObject, eventdata, handles)
% hObject    handle to OverlayCheck3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SelectOverlay(hObject, handles, 3);
% Hint: get(hObject,'Value') returns toggle state of OverlayCheck3


% --- Executes on button press in OverlayCheck4.
function OverlayCheck4_Callback(hObject, eventdata, handles)
% hObject    handle to OverlayCheck4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SelectOverlay(hObject, handles, 4);
% Hint: get(hObject,'Value') returns toggle state of OverlayCheck4


% --- Executes on button press in OverlayCheck5.
function OverlayCheck5_Callback(hObject, eventdata, handles)
% hObject    handle to OverlayCheck5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SelectOverlay(hObject, handles, 5);
% Hint: get(hObject,'Value') returns toggle state of OverlayCheck5


% --- Executes on button press in Remove1.
function Remove1_Callback(hObject, eventdata, handles)
% hObject    handle to Remove1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RemoveOverlay(hObject, handles, 1);

% --- Executes on button press in Remove2.
function Remove2_Callback(hObject, eventdata, handles)
% hObject    handle to Remove2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RemoveOverlay(hObject, handles, 2);

% --- Executes on button press in Remove3.
function Remove3_Callback(hObject, eventdata, handles)
% hObject    handle to Remove3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RemoveOverlay(hObject, handles, 3);

% --- Executes on button press in Remove4.
function Remove4_Callback(hObject, eventdata, handles)
% hObject    handle to Remove4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RemoveOverlay(hObject, handles, 4);

% --- Executes on button press in Remove5.
function Remove5_Callback(hObject, eventdata, handles)
% hObject    handle to Remove5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RemoveOverlay(hObject, handles, 5);

% --- Executes on button press in Add1.
function Add1_Callback(hObject, eventdata, handles)
% hObject    handle to Add1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AddOverlay(hObject, handles, 1, 'Btn');

% --- Executes on button press in Add2.
function Add2_Callback(hObject, eventdata, handles)
% hObject    handle to Add2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AddOverlay(hObject, handles, 2, 'Btn');

% --- Executes on button press in Add3.
function Add3_Callback(hObject, eventdata, handles)
% hObject    handle to Add3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AddOverlay(hObject, handles, 3, 'Btn');

% --- Executes on button press in Add4.
function Add4_Callback(hObject, eventdata, handles)
% hObject    handle to Add4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AddOverlay(hObject, handles, 4, 'Btn');

% --- Executes on button press in Add5.
function Add5_Callback(hObject, eventdata, handles)
% hObject    handle to Add5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AddOverlay(hObject, handles, 5, 'Btn');


function FileEntry1_Callback(hObject, eventdata, handles)
% hObject    handle to FileEntry1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AddOverlay(hObject, handles, 1, 'Ety');
% Hints: get(hObject,'String') returns contents of FileEntry1 as text
%        str2double(get(hObject,'String')) returns contents of FileEntry1 as a double


% --- Executes during object creation, after setting all properties.
function FileEntry1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileEntry1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FileEntry2_Callback(hObject, eventdata, handles)
% hObject    handle to FileEntry2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AddOverlay(hObject, handles, 2, 'Ety');
% Hints: get(hObject,'String') returns contents of FileEntry2 as text
%        str2double(get(hObject,'String')) returns contents of FileEntry2 as a double


% --- Executes during object creation, after setting all properties.
function FileEntry2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileEntry2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function FileEntry3_Callback(hObject, eventdata, handles)
% hObject    handle to FileEntry3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AddOverlay(hObject, handles, 3, 'Ety');
% Hints: get(hObject,'String') returns contents of FileEntry3 as text
%        str2double(get(hObject,'String')) returns contents of FileEntry3 as a double


% --- Executes during object creation, after setting all properties.
function FileEntry3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileEntry3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FileEntry4_Callback(hObject, eventdata, handles)
% hObject    handle to FileEntry4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AddOverlay(hObject, handles, 4, 'Ety');
% Hints: get(hObject,'String') returns contents of FileEntry4 as text
%        str2double(get(hObject,'String')) returns contents of FileEntry4 as a double


% --- Executes during object creation, after setting all properties.
function FileEntry4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileEntry4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FileEntry5_Callback(hObject, eventdata, handles)
% hObject    handle to FileEntry5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AddOverlay(hObject, handles, 5, 'Ety');
% Hints: get(hObject,'String') returns contents of FileEntry5 as text
%        str2double(get(hObject,'String')) returns contents of FileEntry5 as a double


% --- Executes during object creation, after setting all properties.
function FileEntry5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileEntry5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TPoint1_Callback(hObject, eventdata, handles)
% hObject    handle to TPoint1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TPoint1 as text
%        str2double(get(hObject,'String')) returns contents of TPoint1 as a double


% --- Executes during object creation, after setting all properties.
function TPoint1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TPoint1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TPoint2_Callback(hObject, eventdata, handles)
% hObject    handle to TPoint2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TPoint2 as text
%        str2double(get(hObject,'String')) returns contents of TPoint2 as a double


% --- Executes during object creation, after setting all properties.
function TPoint2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TPoint2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TPoint3_Callback(hObject, eventdata, handles)
% hObject    handle to TPoint3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TPoint3 as text
%        str2double(get(hObject,'String')) returns contents of TPoint3 as a double


% --- Executes during object creation, after setting all properties.
function TPoint3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TPoint3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TPoint4_Callback(hObject, eventdata, handles)
% hObject    handle to TPoint4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TPoint4 as text
%        str2double(get(hObject,'String')) returns contents of TPoint4 as a double


% --- Executes during object creation, after setting all properties.
function TPoint4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TPoint4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TPoint5_Callback(hObject, eventdata, handles)
% hObject    handle to TPoint5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TPoint5 as text
%        str2double(get(hObject,'String')) returns contents of TPoint5 as a double


% --- Executes during object creation, after setting all properties.
function TPoint5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TPoint5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CBar1_Callback(hObject, eventdata, handles)
% hObject    handle to CBar1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB

% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of CBar1 as text
%        str2double(get(hObject,'String')) returns contents of CBar1 as a double


% --- Executes during object creation, after setting all properties.
function CBar1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CBar1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CBar2_Callback(hObject, eventdata, handles)
% hObject    handle to CBar2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CBar2 as text
%        str2double(get(hObject,'String')) returns contents of CBar2 as a double


% --- Executes during object creation, after setting all properties.
function CBar2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CBar2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CBar3_Callback(hObject, eventdata, handles)
% hObject    handle to CBar3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CBar3 as text
%        str2double(get(hObject,'String')) returns contents of CBar3 as a double


% --- Executes during object creation, after setting all properties.
function CBar3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CBar3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CBar4_Callback(hObject, eventdata, handles)
% hObject    handle to CBar4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CBar4 as text
%        str2double(get(hObject,'String')) returns contents of CBar4 as a double


% --- Executes during object creation, after setting all properties.
function CBar4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CBar4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CBar5_Callback(hObject, eventdata, handles)
% hObject    handle to CBar5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CBar5 as text
%        str2double(get(hObject,'String')) returns contents of CBar5 as a double


% --- Executes during object creation, after setting all properties.
function CBar5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CBar5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PMax1_Callback(hObject, eventdata, handles)
% hObject    handle to PMax1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PMax1 as text
%        str2double(get(hObject,'String')) returns contents of PMax1 as a double


% --- Executes during object creation, after setting all properties.
function PMax1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PMax1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PMin1_Callback(hObject, eventdata, handles)
% hObject    handle to PMin1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PMin1 as text
%        str2double(get(hObject,'String')) returns contents of PMin1 as a double


% --- Executes during object creation, after setting all properties.
function PMin1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PMin1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PMin2_Callback(hObject, eventdata, handles)
% hObject    handle to PMin2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PMin2 as text
%        str2double(get(hObject,'String')) returns contents of PMin2 as a double


% --- Executes during object creation, after setting all properties.
function PMin2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PMin2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PMax2_Callback(hObject, eventdata, handles)
% hObject    handle to PMax2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PMax2 as text
%        str2double(get(hObject,'String')) returns contents of PMax2 as a double


% --- Executes during object creation, after setting all properties.
function PMax2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PMax2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PMin3_Callback(hObject, eventdata, handles)
% hObject    handle to PMin3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PMin3 as text
%        str2double(get(hObject,'String')) returns contents of PMin3 as a double


% --- Executes during object creation, after setting all properties.
function PMin3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PMin3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PMax3_Callback(hObject, eventdata, handles)
% hObject    handle to PMax3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PMax3 as text
%        str2double(get(hObject,'String')) returns contents of PMax3 as a double


% --- Executes during object creation, after setting all properties.
function PMax3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PMax3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PMin4_Callback(hObject, eventdata, handles)
% hObject    handle to PMin4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PMin4 as text
%        str2double(get(hObject,'String')) returns contents of PMin4 as a double


% --- Executes during object creation, after setting all properties.
function PMin4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PMin4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PMax4_Callback(hObject, eventdata, handles)
% hObject    handle to PMax4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PMax4 as text
%        str2double(get(hObject,'String')) returns contents of PMax4 as a double


% --- Executes during object creation, after setting all properties.
function PMax4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PMax4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PMin5_Callback(hObject, eventdata, handles)
% hObject    handle to PMin5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PMin5 as text
%        str2double(get(hObject,'String')) returns contents of PMin5 as a double


% --- Executes during object creation, after setting all properties.
function PMin5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PMin5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PMax5_Callback(hObject, eventdata, handles)
% hObject    handle to PMax5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PMax5 as text
%        str2double(get(hObject,'String')) returns contents of PMax5 as a double


% --- Executes during object creation, after setting all properties.
function PMax5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PMax5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NMax1_Callback(hObject, eventdata, handles)
% hObject    handle to NMax1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NMax1 as text
%        str2double(get(hObject,'String')) returns contents of NMax1 as a double


% --- Executes during object creation, after setting all properties.
function NMax1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NMax1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NMin1_Callback(hObject, eventdata, handles)
% hObject    handle to NMin1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NMin1 as text
%        str2double(get(hObject,'String')) returns contents of NMin1 as a double


% --- Executes during object creation, after setting all properties.
function NMin1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NMin1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NMax2_Callback(hObject, eventdata, handles)
% hObject    handle to NMax2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NMax2 as text
%        str2double(get(hObject,'String')) returns contents of NMax2 as a double


% --- Executes during object creation, after setting all properties.
function NMax2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NMax2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NMin3_Callback(hObject, eventdata, handles)
% hObject    handle to NMin3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NMin3 as text
%        str2double(get(hObject,'String')) returns contents of NMin3 as a double


% --- Executes during object creation, after setting all properties.
function NMin3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NMin3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NMax3_Callback(hObject, eventdata, handles)
% hObject    handle to NMax3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NMax3 as text
%        str2double(get(hObject,'String')) returns contents of NMax3 as a double


% --- Executes during object creation, after setting all properties.
function NMax3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NMax3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NMin4_Callback(hObject, eventdata, handles)
% hObject    handle to NMin4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NMin4 as text
%        str2double(get(hObject,'String')) returns contents of NMin4 as a double


% --- Executes during object creation, after setting all properties.
function NMin4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NMin4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NMax4_Callback(hObject, eventdata, handles)
% hObject    handle to NMax4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NMax4 as text
%        str2double(get(hObject,'String')) returns contents of NMax4 as a double


% --- Executes during object creation, after setting all properties.
function NMax4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NMax4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NMin5_Callback(hObject, eventdata, handles)
% hObject    handle to NMin5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NMin5 as text
%        str2double(get(hObject,'String')) returns contents of NMin5 as a double


% --- Executes during object creation, after setting all properties.
function NMin5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NMin5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NMax5_Callback(hObject, eventdata, handles)
% hObject    handle to NMax5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NMax5 as text
%        str2double(get(hObject,'String')) returns contents of NMax5 as a double


% --- Executes during object creation, after setting all properties.
function NMax5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NMax5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NMin2_Callback(hObject, eventdata, handles)
% hObject    handle to NMin2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NMin2 as text
%        str2double(get(hObject,'String')) returns contents of NMin2 as a double


% --- Executes during object creation, after setting all properties.
function NMin2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NMin2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ChangeHeader(hObject, handles, Num)
CheckLab=sprintf('OverlayCheck%d', Num);
Value=get(handles.(CheckLab), 'Value');

NMaxLab=sprintf('NMax%d', Num);
NMinLab=sprintf('NMin%d', Num);
PMinLab=sprintf('PMin%d', Num);
PMaxLab=sprintf('PMax%d', Num);
CBarLab=sprintf('CBar%d', Num);
NMax=str2double(get(handles.(NMaxLab), 'String'));
NMin=str2double(get(handles.(NMinLab), 'String'));
PMin=str2double(get(handles.(PMinLab), 'String'));
PMax=str2double(get(handles.(PMaxLab), 'String'));

cbarstring=get(handles.(CBarLab), 'String');

TPointLab=sprintf('TPoint%d', Num);
numTP=handles.OverlayHeaders{Num}.numTP;
oldTP=handles.OverlayHeaders{Num}.curTP;
curTP=str2double(get(handles.(TPointLab), 'String'));
if curTP>numTP
    curTP=numTP;
end
if curTP~=oldTP
    OverlayFile=handles.OverlayHeaders{Num}.fname;
    [OverlayVolume, NewVox, NewHeader] = y_ReadRPI(OverlayFile, curTP);
    handles.OverlayHeaders{Num}.Raw=OverlayVolume;
    handles.OverlayHeaders{Num}.curTP=curTP;
end

OverlayVolume = handles.OverlayHeaders{Num}.Raw;
OverlayVolume = OverlayVolume .* ((OverlayVolume < NMin) + (OverlayVolume > PMin));
if NMax >= 0
    OverlayVolume(OverlayVolume<0) = 0;
end
if PMax <= 0
    OverlayVolume(OverlayVolume>0) = 0;
end

handles.OverlayHeaders{Num}.Data = OverlayVolume;
handles.OverlayHeaders{Num}.IsSelected=Value;
handles.OverlayHeaders{Num}.NMax=NMax;
handles.OverlayHeaders{Num}.NMin=NMin;
handles.OverlayHeaders{Num}.PMin=PMin;
handles.OverlayHeaders{Num}.PMax=PMax;
handles.OverlayHeaders{Num}.curTP=curTP;
handles.OverlayHeaders{Num}.numTP=numTP;
handles.OverlayHeaders{Num}.cbarstring=cbarstring;
guidata(hObject, handles);

function SelectOverlay(hObject, handles, Num)
Value=get(hObject, 'Value');
if Value
    State='On';
else
    State='Off';
end
FileLab=sprintf('FileEntry%d', Num);
NMaxLab=sprintf('NMax%d', Num);
NMinLab=sprintf('NMin%d', Num);
PMinLab=sprintf('PMin%d', Num);
PMaxLab=sprintf('PMax%d', Num);
CBarLab=sprintf('CBar%d', Num);
TPointLab=sprintf('TPoint%d', Num);

set(handles.(FileLab), 'Enable', State);
set(handles.(NMaxLab), 'Enable', State);
set(handles.(NMinLab), 'Enable', State);
set(handles.(PMinLab), 'Enable', State);
set(handles.(PMaxLab), 'Enable', State);
set(handles.(CBarLab), 'Enable', State);
if isempty(handles.OverlayHeaders{Num}) || handles.OverlayHeaders{Num}.numTP==1 ...
    || ~Value
    set(handles.(TPointLab), 'Enable', 'Off');
else
    set(handles.(TPointLab), 'Enable', 'On');
end

function RemoveOverlay(hObject, handles, Num)
CheckLab=sprintf('OverlayCheck%d', Num);

FileLab=sprintf('FileEntry%d', Num);
NMaxLab=sprintf('NMax%d', Num);
NMinLab=sprintf('NMin%d', Num);
PMinLab=sprintf('PMin%d', Num);
PMaxLab=sprintf('PMax%d', Num);
CBarLab=sprintf('CBar%d', Num);
TPointLab=sprintf('TPoint%d', Num);

set(handles.(CheckLab), 'Value', 0);

set(handles.(FileLab), 'Enable', 'Off');
set(handles.(FileLab), 'String', []);

set(handles.(NMaxLab), 'Enable', 'Off');
set(handles.(NMaxLab), 'String', []);
set(handles.(NMinLab), 'Enable', 'Off');
set(handles.(NMinLab), 'String', []);
set(handles.(PMinLab), 'Enable', 'Off');
set(handles.(PMinLab), 'String', []);
set(handles.(PMaxLab), 'Enable', 'Off');
set(handles.(PMaxLab), 'String', []);

set(handles.(CBarLab), 'Enable', 'Off');
set(handles.(CBarLab), 'String', []);
set(handles.(TPointLab), 'Enable', 'Off');
set(handles.(TPointLab), 'String', sprintf('%d', 1));
if ~isempty(handles.OverlayHeaders{Num})
    handles.OverlayHeaders{Num}=[];
end
guidata(hObject, handles);

function AddOverlay(hObject, handles, Num, Flag)
CheckLab=sprintf('OverlayCheck%d', Num);

FileLab=sprintf('FileEntry%d', Num);
NMaxLab=sprintf('NMax%d', Num);
NMinLab=sprintf('NMin%d', Num);
PMinLab=sprintf('PMin%d', Num);
PMaxLab=sprintf('PMax%d', Num);
CBarLab=sprintf('CBar%d', Num);
TPointLab=sprintf('TPoint%d', Num);

if strcmpi(Flag, 'Btn')
    [File , Path]=uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
        'Pick Overlay File' , handles.CurDir); 

    if ~ischar(File)
        return;
    end
    OverlayFile=fullfile(Path, File);
elseif strcmpi(Flag, 'Ety')
    OverlayFile=get(handles.(FileLab), 'String');
    [Path, Name, Ext]=fileparts(OverlayFile);
    if isempty(Path)
        Path=handles.CurDir;
        OverlayFile = fullfile(Path, Name, Ext);
    end
    
    if ~exist(OverlayFile, 'file')
        errordlg('Image File not found', 'File Error');
        if ~isempty(handles.OverlayHeaders{Num})
            OldFile=handles.OverlayHeaders{Num}.fname;
        else
            OldFile=[];
        end
        set(handles.(FileLab), 'String', OldFile)
        return
    end
else
    errordlg('error flag')
    return
end

for i=GetIndex(handles.OverlayHeaders)
    if i==0
        break
    end
    f=handles.OverlayHeaders{i}.fname;
    if strcmp(f, OverlayFile)
        msgbox('This file have been added before! No Update!', 'modal');
        return
    end
end

%Added by YAN Chao-Gan, 131005. To handle .nii.gz files.
FileNameTemp = OverlayFile;
[pathstr, name, ext] = fileparts(FileNameTemp);
if isempty(ext)
    FileNameTemp = fullfile(pathstr,[name '.nii']);
    if ~exist(FileNameTemp,'file')
        FileNameTemp = fullfile(pathstr,[name '.nii.gz']);
        [pathstr, name, ext] = fileparts(FileNameTemp);
    end
    if ~exist(FileNameTemp,'file')
        FileNameTemp = fullfile(pathstr,[name '.hdr']);
    end
end
if ~exist(FileNameTemp,'file')
    error(['File doesn''t exist: ',fullfile(pathstr,[name ext])]);
end
if strcmpi(ext,'.gz')
    gunzip(FileNameTemp);
    FileNameTemp = fullfile(pathstr,[name]);
end

Nii = nifti(FileNameTemp);
numTP = size(Nii.dat,4);
curTP = 1;

if strcmpi(ext,'.gz')
    delete(FileNameTemp);
end
%END%Added by YAN Chao-Gan, 131005. To handle .nii.gz files.

[OverlayVolume OverlayVox OverlayHeader] = y_ReadRPI(OverlayFile, curTP);
OverlayHeader=w_ExtendHeader(OverlayHeader);
OverlayHeader.Vox=OverlayVox;

NMax=min(OverlayVolume(:));
if NMax > 0
    NMax=0;
end
NMin = 0;
PMin = 0;
PMax=max(OverlayVolume(:));
if PMax <0;
    PMax=0;
end
cbarstring=sprintf('%d', 12);

OverlayHeader.IsSelected=1;
OverlayHeader.Raw=OverlayVolume;
OverlayHeader.NMax=NMax;
OverlayHeader.NMin=NMin;
OverlayHeader.PMin=PMin;
OverlayHeader.PMax=PMax;
OverlayHeader.cbarstring=cbarstring;
OverlayHeader.numTP=numTP;
OverlayHeader.curTP=curTP;

set(handles.(CheckLab), 'Value', 1);

set(handles.(FileLab), 'String', OverlayFile);
set(handles.(FileLab), 'Enable', 'On');

set(handles.(NMaxLab), 'Enable', 'On');
set(handles.(NMaxLab), 'String', sprintf('%g', NMax));
set(handles.(NMinLab), 'Enable', 'On');
set(handles.(NMinLab), 'String', sprintf('%g', NMin));
set(handles.(PMinLab), 'Enable', 'On');
set(handles.(PMinLab), 'String', sprintf('%g', PMin));
set(handles.(PMaxLab), 'Enable', 'On');
set(handles.(PMaxLab), 'String', sprintf('%g', PMax));

set(handles.(CBarLab), 'Enable', 'On');
set(handles.(CBarLab), 'String', cbarstring);
if numTP > 1
    set(handles.(TPointLab), 'Enable', 'On');
    set(handles.(TPointLab), 'String', sprintf('%d', curTP));
end

handles.CurDir=Path;
handles.OverlayHeaders{Num}=OverlayHeader;
guidata(hObject, handles);

function CurDir=InitOverlay(OverlayHeader, handles, Num)
CheckLab=sprintf('OverlayCheck%d', Num);

FileLab=sprintf('FileEntry%d', Num);
NMaxLab=sprintf('NMax%d', Num);
NMinLab=sprintf('NMin%d', Num);
PMinLab=sprintf('PMin%d', Num);
PMaxLab=sprintf('PMax%d', Num);
CBarLab=sprintf('CBar%d', Num);
TPointLab=sprintf('TPoint%d', Num);

Value=OverlayHeader.IsSelected;
if Value
    State='On';
else
    State='Off';
end
OverlayFile=OverlayHeader.fname;
[Path, Name, Ext]=fileparts(OverlayFile);
NMax=OverlayHeader.NMax;
NMin=OverlayHeader.NMin;
PMin=OverlayHeader.PMin;
PMax=OverlayHeader.PMax;
cbarstring=OverlayHeader.cbarstring;
numTP=OverlayHeader.numTP;
curTP=OverlayHeader.curTP;

set(handles.(CheckLab), 'Value', Value);

set(handles.(FileLab), 'String', OverlayFile);
set(handles.(FileLab), 'Enable', State);

set(handles.(NMaxLab), 'Enable', State);
set(handles.(NMaxLab), 'String', sprintf('%g', NMax));
set(handles.(NMinLab), 'Enable', State);
set(handles.(NMinLab), 'String', sprintf('%g', NMin));
set(handles.(PMinLab), 'Enable', State);
set(handles.(PMinLab), 'String', sprintf('%g', PMin));
set(handles.(PMaxLab), 'Enable', State);
set(handles.(PMaxLab), 'String', sprintf('%g', PMax));

set(handles.(CBarLab), 'Enable', State);
set(handles.(CBarLab), 'String', cbarstring);
if numTP > 1
    set(handles.(TPointLab), 'String', sprintf('%d', curTP));
end
if Value
    set(handles.(TPointLab), 'Enable', 'On');
end

CurDir=Path;

function OverlayHeader=RedrawOverlay(SendHeader, curfig)
Transparency=0.2;
cbarstring = SendHeader.cbarstring;
cbar=str2double(cbarstring);

NMax = SendHeader.NMax;
NMin = SendHeader.NMin;
PMin = SendHeader.PMin;
PMax = SendHeader.PMax;

OverlayHeader=SendHeader;
MainHandle=guidata(curfig);
if get(MainHandle.OnlyPos, 'Value')
    SendHeader.Data(OverlayHeader.Data < 0)=0;
end
if get(MainHandle.OnlyNeg, 'Value')
    SendHeader.Data(OverlayHeader.Data > 0)=0;
end
if get(MainHandle.OnlyUnder, 'Value')
    SendHeader.Data(OverlayHeader.Data~= 0)=0;
end

if SendHeader.CSize
    SendHeader=DPABI_VIEW('SetCSize', SendHeader);
end

if cbar==0 && isfield(SendHeader, 'ColorMap')
    ColorMap=SendHeader.ColorMap;
else
    if isnan(cbar)
        ColorMap = colormap(cbarstring);
    else
        ColorMap = y_AFNI_ColorMap(cbar);
    end
    OverlayHeader.ColorMap=ColorMap;
end

ColorMap = y_AdjustColorMap(ColorMap,...
    [0.75 0.75 0.75],...
    NMax,...
    NMin,...
    PMin,...
    PMax);

y_spm_orthviews('Addtruecolourimage',...
    curfig,...
    SendHeader,...
    ColorMap,...
    1-Transparency,...
    PMax,...
    NMax);


function ReplaceOverlay(hObject, handles)
handles.OverlayHeaders=cell(5,1);
AddOverlay(hObject, handles, 1, 'Btn')
handles=guidata(hObject);
for i=2:length(handles.OverlayHeaders)
    RemoveOverlay(hObject, handles, i);
end
handles=guidata(hObject);
guidata(hObject, handles);

% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=0;
guidata(hObject, handles);
uiresume(handles.List_Fig);

% --- Executes on button press in Accept.
function Accept_Callback(hObject, eventdata, handles)
% hObject    handle to Accept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MainHandle=guidata(handles.MainFig);

OverlayFileName={};
OverlaySelect={'Select a Overlay to Edit'};
Num=1;
y_spm_orthviews('removeblobs', handles.MainFig);

flag=0;
for i=GetIndex(handles.OverlayHeaders)
    if i==0
        colormap(gray(64));
        break;
    end
    CheckLab=sprintf('OverlayCheck%d', i);
    if ~isempty(handles.OverlayHeaders{i})
        if get(handles.(CheckLab), 'Value')    
            ChangeHeader(hObject, handles, i);
            handles=guidata(hObject);
            
            OverlayHeader=handles.OverlayHeaders{i};
            if OverlayHeader.numTP > 1
                flag=i;
            else
                flag=0;
            end
            OverlayFile=OverlayHeader.fname;
            [Path, Name, Ext]=fileparts(OverlayFile);
            OverlayFileName{Num, 1}= OverlayFile;
            OverlayHeader=RedrawOverlay(OverlayHeader, handles.MainFig);
            handles.OverlayHeaders{i}=OverlayHeader;
        
            Num=Num+1;
            OverlaySelect{Num, 1}=sprintf('%s%s (%s)', Name, Ext, Path);
        else
            handles.OverlayHeaders{i}.IsSelected=0;
        end
    end
end

if flag
    curTP=handles.OverlayHeaders{flag}.curTP;
    numTP=handles.OverlayHeaders{flag}.numTP;
    set(MainHandle.LeftButton, 'Enable', 'On');
    set(MainHandle.RightButton, 'Enable', 'On');
    if curTP==1
        set(MainHandle.LeftButton, 'Enable', 'Off');
    end
    if curTP==numTP
        set(MainHandle.RightButton, 'Enable', 'Off');
    end
    set(MainHandle.TimePointButton, 'Enable', 'On');
    set(MainHandle.TimePointButton, 'String', num2str(curTP));
else
    set(MainHandle.LeftButton, 'Enable', 'Off');
    set(MainHandle.RightButton, 'Enable', 'Off');
    set(MainHandle.TimePointButton, 'Enable', 'Off');
    set(MainHandle.TimePointButton, 'String', []);  
end
y_spm_orthviews('redrawcolourbar', handles.MainFig, Num-1);
y_spm_orthviews('Redraw', handles.MainFig);

handles.output=1;
guidata(hObject, handles);

set(MainHandle.OverlayLabel, 'Value', 1);
set(MainHandle.OverlayEntry, 'ToolTipString', OverlaySelect{Num});
set(MainHandle.OverlayEntry, 'Enable', 'On');
set(MainHandle.OverlayEntry, 'String', OverlaySelect)
set(MainHandle.OverlayEntry, 'Value', Num);
if Num==1
    set(MainHandle.ColorAxe, 'Visible', 'Off');
    set(MainHandle.OverlayEntry, 'Enable', 'Off')
    ColorMap=get(MainHandle.ColorAxe, 'Children');
    delete(ColorMap);
else
    set(MainHandle.ColorAxe, 'Visible', 'On');
end

MainHandle.OverlayHeaders=handles.OverlayHeaders;

MainHandle.OverlayFileName=OverlayFileName;
if get(MainHandle.TemplatePopup, 'Value')==length(get(MainHandle.TemplatePopup, 'String'))
    MainHandle=DPABI_VIEW('NoneUnderlay', MainHandle);
end
guidata(handles.MainFig, MainHandle);
uiresume(handles.List_Fig);

% --- Executes on button press in Replace.
function Replace_Callback(hObject, eventdata, handles)
% hObject    handle to Replace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ReplaceOverlay(hObject, handles)
handles=guidata(hObject);
guidata(hObject, handles);

function index=GetIndex(Handle)
index=[];
for i=1:length(Handle)
    if ~isempty(Handle{i})
        index=[index i];
    end
end

if isempty(index)
    index=0;
end
