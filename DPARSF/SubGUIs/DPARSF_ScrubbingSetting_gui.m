function varargout = DPARSF_ScrubbingSetting_gui(varargin)
%   varargout = DPARSF_ScrubbingSetting_gui(varargin)
%   GUI for setting parameters for Scrubbing.
%   Input: FDType, FDThreshold, PreviousPoints, LaterPoints, ScrubbingMethod.
%   Output: FDType, FDThreshold, PreviousPoints, LaterPoints, ScrubbingMethod.
%-----------------------------------------------------------
% Written by YAN Chao-Gan 120830.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com

% Revised by YAN Chao-Gan, 121225. Added the option of FDType.

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPARSF_ScrubbingSetting_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @DPARSF_ScrubbingSetting_gui_OutputFcn, ...
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



function DPARSF_ScrubbingSetting_gui_OpeningFcn(hObject, eventdata, handles, varargin)
if ~isempty(varargin),
    handles.FDType =varargin{1};
    handles.FDThreshold =varargin{2};
    handles.PreviousPoints =varargin{3};
    handles.LaterPoints =varargin{4};
    handles.ScrubbingMethod =varargin{5};
else
    handles.FDType = 'FD_Power';
    handles.FDThreshold = 0.5;
    handles.PreviousPoints = 1;
    handles.LaterPoints = 2;
    handles.ScrubbingMethod = 'cut';
end
InitControls(hObject, handles);
% 
% % Make Display correct in linux - YAN Chao-Gan 111025 Added.
% if ~ispc
%     ZoomFactor=0.85;
%     ObjectNames = fieldnames(handles);
%     for i=1:length(ObjectNames);
%         eval(['IsFontSizeProp=isprop(handles.',ObjectNames{i},',''FontSize'');']);
%         if IsFontSizeProp
%             eval(['PCFontSize=get(handles.',ObjectNames{i},',''FontSize'');']);
%             FontSize=PCFontSize*ZoomFactor;
%             eval(['set(handles.',ObjectNames{i},',''FontSize'',',num2str(FontSize),');']);
%         end
%     end
% end

% Make UI display correct in PC and linux
if ~ismac
    if ispc
        ZoonMatrix = [1 1 1.5 1.5];  %For pc
    else
        ZoonMatrix = [1 1 1.5 1.5];  %For Linux
    end
    UISize = get(handles.figScrubbingSetting,'Position');
    UISize = UISize.*ZoonMatrix;
    set(handles.figScrubbingSetting,'Position',UISize);
end
movegui(handles.figScrubbingSetting,'center');


% Update handles structure
guidata(hObject, handles);
try
	uiwait(handles.figScrubbingSetting);
catch
	uiresume(handles.figScrubbingSetting);
end


% uiwait(handles.figScrubbingSetting);


% --- Outputs from this function are returned to the command line.
function varargout = DPARSF_ScrubbingSetting_gui_OutputFcn(hObject, eventdata, handles) 
if isempty(handles)
    varargout{1} = '';
    varargout{2} = '';
    varargout{3} = '';
    varargout{4} = '';
    varargout{5} = '';
else    
    varargout{1} = handles.FDType;
    varargout{2} = handles.FDThreshold;
    varargout{3} = handles.PreviousPoints;
    varargout{4} = handles.LaterPoints;
    varargout{5} = handles.ScrubbingMethod;
    delete(handles.figScrubbingSetting);
end
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure



% --- Executes on button press in btnOK.
function btnOK_Callback(hObject, eventdata, handles)
%handles.Qmaskname=get(handles.edtMaskFile, 'String');
guidata(hObject, handles);
uiresume(handles.figScrubbingSetting);


function InitControls(hObject, handles)

set(handles.radiobuttonFD_Power,'Value',strcmpi(handles.FDType,'FD_Power'));
set(handles.radiobuttonFD_Jenkinson,'Value',strcmpi(handles.FDType,'FD_Jenkinson'));

set(handles.editFDThreshold,'String',num2str(handles.FDThreshold));
set(handles.editPreviousPoints,'String',num2str(handles.PreviousPoints));
set(handles.editLaterPoints,'String',num2str(handles.LaterPoints));

set(handles.rtnM1,'Value',strcmpi(handles.ScrubbingMethod,'cut'));
set(handles.rtnM2,'Value',strcmpi(handles.ScrubbingMethod,'nearest'));
set(handles.rtnM3,'Value',strcmpi(handles.ScrubbingMethod,'linear'));
set(handles.rtnM4,'Value',strcmpi(handles.ScrubbingMethod,'spline'));
set(handles.rtnM5,'Value',strcmpi(handles.ScrubbingMethod,'pchip'));

if isempty(handles.ScrubbingMethod)
    set(handles.textScrubbingMethod,'String','Scrubbing Method: use each bad time point as a regressor.');
    
    set(handles.rtnM1,'Visible','off');
    set(handles.rtnM2,'Visible','off');
    set(handles.rtnM3,'Visible','off');
    set(handles.rtnM4,'Visible','off');
    set(handles.rtnM5,'Visible','off');
end


guidata(hObject, handles);





% --- Executes on button press in radiobuttonFD_Power.
function radiobuttonFD_Power_Callback(hObject, eventdata, handles)
handles.FDType = 'FD_Power';
guidata(hObject, handles);
set(handles.radiobuttonFD_Power,'Value',1);
set(handles.radiobuttonFD_Jenkinson,'Value',0);
drawnow;

% --- Executes on button press in radiobuttonFD_Jenkinson.
function radiobuttonFD_Jenkinson_Callback(hObject, eventdata, handles)
handles.FDType = 'FD_Jenkinson';
guidata(hObject, handles);
set(handles.radiobuttonFD_Power,'Value',0);
set(handles.radiobuttonFD_Jenkinson,'Value',1);
drawnow;



function editFDThreshold_Callback(hObject, eventdata, handles)
handles.FDThreshold =str2double(get(hObject,'String'));
guidata(hObject, handles);
drawnow;

% --- Executes during object creation, after setting all properties.
function editFDThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFDThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editPreviousPoints_Callback(hObject, eventdata, handles)
handles.PreviousPoints =str2double(get(hObject,'String'));
guidata(hObject, handles);
drawnow;

% --- Executes during object creation, after setting all properties.
function editPreviousPoints_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPreviousPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function editLaterPoints_Callback(hObject, eventdata, handles)
handles.LaterPoints =str2double(get(hObject,'String'));
guidata(hObject, handles);
drawnow;


% --- Executes during object creation, after setting all properties.
function editLaterPoints_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLaterPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in rtnM1.
function rtnM1_Callback(hObject, eventdata, handles)
handles.ScrubbingMethod = 'cut';
guidata(hObject, handles);
set(handles.rtnM1,'Value',1);
set(handles.rtnM2,'Value',0);
set(handles.rtnM3,'Value',0);
set(handles.rtnM4,'Value',0);
set(handles.rtnM5,'Value',0);
drawnow;


% --- Executes on button press in rtnM2.
function rtnM2_Callback(hObject, eventdata, handles)
handles.ScrubbingMethod = 'nearest';
guidata(hObject, handles);
set(handles.rtnM1,'Value',0);
set(handles.rtnM2,'Value',1);
set(handles.rtnM3,'Value',0);
set(handles.rtnM4,'Value',0);
set(handles.rtnM5,'Value',0);
drawnow;


% --- Executes on button press in rtnM3.
function rtnM3_Callback(hObject, eventdata, handles)
handles.ScrubbingMethod = 'linear';
guidata(hObject, handles);
set(handles.rtnM1,'Value',0);
set(handles.rtnM2,'Value',0);
set(handles.rtnM3,'Value',1);
set(handles.rtnM4,'Value',0);
set(handles.rtnM5,'Value',0);
drawnow;

% --- Executes on button press in rtnM4.
function rtnM4_Callback(hObject, eventdata, handles)
handles.ScrubbingMethod = 'spline';
guidata(hObject, handles);
set(handles.rtnM1,'Value',0);
set(handles.rtnM2,'Value',0);
set(handles.rtnM3,'Value',0);
set(handles.rtnM4,'Value',1);
set(handles.rtnM5,'Value',0);
drawnow;


% --- Executes on button press in rtnM5.
function rtnM5_Callback(hObject, eventdata, handles)
handles.ScrubbingMethod = 'pchip';
guidata(hObject, handles);
set(handles.rtnM1,'Value',0);
set(handles.rtnM2,'Value',0);
set(handles.rtnM3,'Value',0);
set(handles.rtnM4,'Value',0);
set(handles.rtnM5,'Value',1);
drawnow;



