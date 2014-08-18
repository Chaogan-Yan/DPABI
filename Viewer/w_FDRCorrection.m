function varargout = w_FDRCorrection(varargin)
% W_FDRCORRECTION MATLAB code for w_FDRCorrection.fig
%      W_FDRCORRECTION, by itself, creates a new W_FDRCORRECTION or raises the existing
%      singleton*.
%
%      H = W_FDRCORRECTION returns the handle to a new W_FDRCORRECTION or the handle to
%      the existing singleton*.
%
%      W_FDRCORRECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in W_FDRCORRECTION.M with the given input arguments.
%
%      W_FDRCORRECTION('Property','Value',...) creates a new W_FDRCORRECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before w_FDRCorrection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to w_FDRCorrection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help w_FDRCorrection

% Last Modified by GUIDE v2.5 24-Mar-2014 16:07:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @w_FDRCorrection_OpeningFcn, ...
                   'gui_OutputFcn',  @w_FDRCorrection_OutputFcn, ...
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


% --- Executes just before w_FDRCorrection is made visible.
function w_FDRCorrection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to w_FDRCorrection (see VARARGIN)
OverlayHeader=varargin{1};
if isempty(OverlayHeader.TestFlag)
    msgbox('FDR only take effects on the statistical map!');        
    return
end

set(handles.MaskEntry,  'String', OverlayHeader.MaskFile);
% Choose default command line output for w_FDRCorrection
handles.OverlayHeader=OverlayHeader;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes w_FDRCorrection wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = w_FDRCorrection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    varargout{1}=[];
else
    varargout{1}=handles.OverlayHeader;
    delete(handles.figure1);
end



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


% --- Executes on button press in RemoveButton.
function RemoveButton_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.MaskEntry, 'String', '');
handles.OverlayHeader.MaskFile='';
handles.OverlayHeader.Mask=true(handles.OverlayHeader.dim);
guidata(hObject, handles);

% --- Executes on button press in AddButton.
function AddButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DPABIPath=fileparts(which('DPABI.m'));
TemplatePath=fullfile(DPABIPath, 'Templates');
[File , Path]=uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
    'Pick Underlay File' , TemplatePath);
if isnumeric(File)
    return
end
MaskFile=fullfile(Path, File);
handles.OverlayHeader.MaskFile=MaskFile;
set(handles.MaskEntry, 'String', MaskFile);

[Mask, Vox, Header] = y_ReadRPI(MaskFile);
handles.OverlayHeader.Mask=logical(Mask);

guidata(hObject, handles);


% --- Executes on button press in ComputeButton.
function ComputeButton_Callback(hObject, eventdata, handles)
% hObject    handle to ComputeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
OverlayHeader=handles.OverlayHeader;
QValue=str2double(get(handles.QEntry, 'String'));

OverlayHeader=doFDR(OverlayHeader, QValue);

handles.OverlayHeader=OverlayHeader;
guidata(hObject, handles);
uiresume(handles.figure1);


function QEntry_Callback(hObject, eventdata, handles)
% hObject    handle to QEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of QEntry as text
%        str2double(get(hObject,'String')) returns contents of QEntry as a double


% --- Executes during object creation, after setting all properties.
function QEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Header=doFDR(Header, Q)
Mask=Header.Mask;
SMap=Header.Raw(Mask);
switch upper(Header.TestFlag)
    case 'T'
        PMap=2*(1-tcdf(abs(SMap), Header.Df));
    case 'R'
        PMap=2*(1-tcdf(abs(SMap).*sqrt((Header.Df)./(1-SMap.*SMap)), Header.Df));
    case 'F'
        PMap=(1-fcdf(SMap, Header.Df, Header.Df2));
    case 'Z'
        PMap=2*(1-normcdf(abs(SMap)));
end
% Following  FDR.m	1.3 Tom Nichols 02/01/18

SortP=sort(PMap);
V=length(SortP);
I=(1:V)';

cVID = 1;
cVN  = sum(1./(1:V));

% Threshold
P   = SortP(find(SortP <= I/V*Q/cVID, 1, 'last' ));

% Nonparametric
P_N = SortP(find(SortP <= I/V*Q/cVN,  1, 'last' ));

if ~isempty(P)
    switch upper(Header.TestFlag)
        case 'T'
            Df=Header.Df;
            Thrd=tinv(1-P/2, Df);
        case 'R'
            Df=Header.Df;
            T=tinv(1-P/2, Df);
            Thrd=sqrt(T^2/(Df+T^2));
        case 'F'
            Df1=Header.Df;
            Df2=Header.Df2;
            Thrd=finv(1-P, Df1, Df2);
        case 'Z'
            Thrd=norminv(1-P/2);
    end
    Header.PMin=Thrd;
    Header.NMin=-Thrd;    
else
    Header.PMin=Header.PMax+1;
    Header.NMin=Header.NMax-1;
    msgbox('No voxel exists after FDR !');
end
