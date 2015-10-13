function varargout = w_Montage(varargin)
% W_MONTAGE MATLAB code for w_Montage.fig
%      W_MONTAGE, by itself, creates a new W_MONTAGE or raises the existing
%      singleton*.
%
%      H = W_MONTAGE returns the handle to a new W_MONTAGE or the handle to
%      the existing singleton*.
%
%      W_MONTAGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in W_MONTAGE.M with the given input arguments.
%
%      W_MONTAGE('Property','Value',...) creates a new W_MONTAGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before w_Montage_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to w_Montage_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help w_Montage

% Last Modified by GUIDE v2.5 06-Apr-2014 10:37:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @w_Montage_OpeningFcn, ...
                   'gui_OutputFcn',  @w_Montage_OutputFcn, ...
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


% --- Executes just before w_Montage is made visible.
function w_Montage_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to w_Montage (see VARARGIN)
MainFig=w_Compatible2014bFig(varargin{1});
MontageType=varargin{2};

handles.ImageView=image('Parent', handles.MontageAxe);
handles.lx = line(0, 0, 'Parent',handles.MontageAxe, 'Visible', 'Off');
handles.ly = line(0, 0, 'Parent',handles.MontageAxe, 'Visible', 'Off');

set(handles.MontageAxe, 'XTick', []);
set(handles.MontageAxe, 'XTickLabel', []);
set(handles.MontageAxe, 'YTick', []);
set(handles.MontageAxe, 'YTickLabel', []);
set(handles.MontageAxe, 'YDir', 'Normal');
colormap(handles.MontageAxe, 'gray(64)');

Index=GetSlice(MontageType, MainFig);
M=round(length(Index)^0.5*(9/12.5));
N=ceil(length(Index)/M);
I=Inf(M*N, 1);
I(1:length(Index))=Index;
I=reshape(I, [N, M]);
I=I';
[Image, Space]=w_MontageImage(I, MontageType, MainFig, 'Init');
set(handles.ImageView, 'HitTest', 'off', 'Cdata', Image);
set(handles.MontageAxe, 'XLim', [1, size(Image,2)]);
set(handles.MontageAxe, 'YLim', [1, size(Image,1)]);
axis(handles.MontageAxe, 'image');

ResizeFig(handles, size(Image, 2)/size(Image, 1));

set(handles.REntry, 'String', num2str(M));
set(handles.LEntry, 'String', num2str(N));
set(handles.BeginEntry, 'String', num2str(I(1)));
set(handles.DeltasEntry, 'String', '1');
% Choose default command line output for w_Montage
handles.IndexM=I;
handles.Space=Space;
handles.MontageType=MontageType;
handles.output = hObject;
handles.MainFig=MainFig;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes w_Montage wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = w_Montage_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function index=GetSlice(type, curfig)
global st

bb=st{curfig}.bb;

switch upper(type)
    case 'T'
        index=bb(1, 3):bb(2, 3);
    case 'C'
        index=bb(1, 2):bb(2, 2);
    case 'S'
        index=bb(1, 1):bb(2, 1);
end

function ResizeFig(handles, scale)
pos=get(handles.figure1, 'Position');

PHeight=pos(4)*0.85;
PWidth=PHeight*scale/0.98;

pos(3)=PWidth;
set(handles.figure1, 'Position', pos);



function REntry_Callback(hObject, eventdata, handles)
% hObject    handle to REntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of REntry as text
%        str2double(get(hObject,'String')) returns contents of REntry as a double


% --- Executes during object creation, after setting all properties.
function REntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to REntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LEntry_Callback(hObject, eventdata, handles)
% hObject    handle to LEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LEntry as text
%        str2double(get(hObject,'String')) returns contents of LEntry as a double


% --- Executes during object creation, after setting all properties.
function LEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BeginEntry_Callback(hObject, eventdata, handles)
% hObject    handle to BeginEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BeginEntry as text
%        str2double(get(hObject,'String')) returns contents of BeginEntry as a double


% --- Executes during object creation, after setting all properties.
function BeginEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BeginEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DeltasEntry_Callback(hObject, eventdata, handles)
% hObject    handle to DeltasEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DeltasEntry as text
%        str2double(get(hObject,'String')) returns contents of DeltasEntry as a double


% --- Executes during object creation, after setting all properties.
function DeltasEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DeltasEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in IndexButton.
function IndexButton_Callback(hObject, eventdata, handles)
% hObject    handle to IndexButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
options.Resize='on';
options.WindowStyle='modal';

I=inputdlg('Index Matrix', 'Set Index Matrix',...
    size(handles.IndexM, 1)*3,...
    {num2str(handles.IndexM)}, options);
if isempty(I)
    return
end

I=str2num(I{1});
[Image, Space]=w_MontageImage(I, handles.MontageType, handles.MainFig);
set(handles.ImageView, 'HitTest', 'off', 'Cdata', Image);
set(handles.MontageAxe, 'XLim', [1, size(Image,2)]);
set(handles.MontageAxe, 'YLim', [1, size(Image,1)]);

ResizeFig(handles, size(Image, 2)/size(Image, 1));

handles.IndexM=I;
handles.Space=Space;
guidata(hObject, handles);

% --- Executes on button press in ApplyButton.
function ApplyButton_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
M=str2double(get(handles.REntry, 'String'));
N=str2double(get(handles.LEntry, 'String'));
Begin=str2double(get(handles.BeginEntry, 'String'));
deltas=str2double(get(handles.DeltasEntry, 'String'));
End=Begin+M*N*deltas;
if deltas>0
    End=End-1;
else
    End=End+1;
end

Index=Begin:deltas:End;
I=Inf(M*N, 1);
I(1:end)=Index;
I=reshape(I, [N, M]);
I=I';

[Image, Space]=w_MontageImage(I, handles.MontageType, handles.MainFig);
set(handles.ImageView, 'HitTest', 'off', 'Cdata', Image);
set(handles.MontageAxe, 'XLim', [1, size(Image,2)]);
set(handles.MontageAxe, 'YLim', [1, size(Image,1)]);

ResizeFig(handles, size(Image, 2)/size(Image, 1));

handles.IndexM=I;
handles.Space=Space;

guidata(hObject, handles);
RedrawXhairs(handles.MainFig, handles.figure1);

% --- Executes on button press in SaveButton.
function SaveButton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[File, Path] = uiputfile({'*.tiff';'*.jpeg';'*.png';'*.bmp'},...
    'Save Picture As');
if ~ischar(File)
    return;
end
[Path, Name, Ext]=fileparts(fullfile(Path, File));
IName=sprintf('%s_Index', Name);

%Data=getframe(handles.MontageAxe);
Data=flipdim(get(handles.ImageView, 'CData'), 1);
Data=imresize(Data, 5*[size(Data, 1), size(Data, 2)]);
imwrite(Data, fullfile(Path, [Name, Ext]));
eval(['print -r300 -dtiff -noui ''',fullfile(Path, [Name, '_300dpi', Ext]),''';']); %YAN Chao-Gan, 140806.

if isunix
    Line='unix';
else
    Line='pc';
end
dlmwrite(fullfile(Path, [IName, '.txt']),...
    handles.IndexM, 'delimiter', '\t', 'newline', Line, 'precision', '%d');


% --- Executes on button press in CrosshairButton.
function CrosshairButton_Callback(hObject, eventdata, handles)
% hObject    handle to CrosshairButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.CrosshairButton, 'Value');
if Value
    State='On';
else
    State='Off';
end
RedrawXhairs(handles.MainFig, handles.figure1);
set(handles.lx, 'Visible', State);
set(handles.ly, 'Visible', State);
% Hint: get(hObject,'Value') returns toggle state of CrosshairButton

function RedrawXhairs(curfig, fig, pos)
handles=guidata(fig);
if ~get(handles.CrosshairButton, 'Value')
    return;
end

global st
if nargin<3
    pos=st{curfig}.centre(:);
end    
bb=st{curfig}.bb;

Dims = round(diff(bb)'+1);
is   = inv(handles.Space);
cent = is(1:3,1:3)*pos + is(1:3,4);

Type=handles.MontageType;

IndexM=handles.IndexM;
IndexM=flipdim(IndexM, 1);

switch upper(Type)
    case 'T'
        Slice=round(pos(3));
        offsetX=cent(2)-bb(1,2)+1;
        offsetY=cent(1)-bb(1,1)+1;
        D = Dims([1 2]);
    case 'C'
        Slice=round(pos(2));
        offsetX=cent(3)-bb(1,3)+1;
        offsetY=cent(1)-bb(1,1)+1;
        D = Dims([1 3]);
    case 'S'
        Slice=round(pos(1));
        if st{curfig}.mode==0
            offsetX=cent(2)-bb(1,2)+1;
            offsetY=cent(3)-bb(1,3)+1;
            D = Dims([3 2]);
        else
            offsetX=cent(3)-bb(1,3)+1;
            offsetY=bb(2,2)+1-cent(2);
            D = Dims([2 3]);
        end
end

index=find(IndexM==Slice);
if isempty(index)
    set(handles.lx, 'Xdata', [], 'Ydata', []);
    set(handles.ly, 'Xdata', [], 'Ydata', []);
    return
end

[y, x]=ind2sub(size(IndexM), index);
set(handles.lx,'HitTest','off',...
    'Xdata', [(x-1)*D(1) x*D(1)-1]+0.5,...
    'Ydata', [1 1]*(offsetX+(y-1)*D(2)));
set(handles.ly,'HitTest','off',...
    'Ydata', [(y-1)*D(2) y*D(2)-1]+0.5,...
    'Xdata', [1 1]*(offsetY+(x-1)*D(1)));

% --- Executes on mouse press over axes background.
function MontageAxe_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to MontageAxe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curfig=handles.MainFig;
fig=handles.figure1;
if ~strcmpi(get(fig,'SelectionType'),'alt')
    set(fig,...
        'windowbuttonmotionfcn', @(objH, eventData) MontageReposMove(objH, eventData, curfig, fig),...
        'windowbuttonupfcn',@(objH, eventData) MontageReposEnd(objH, eventData, fig));
    MontageRepos(curfig, fig);
end

function MontageReposMove(objH, eventData, curfig, fig)
MontageRepos(curfig, fig);

function MontageReposEnd(objH, eventData, fig)
set(fig,'windowbuttonmotionfcn','', 'windowbuttonupfcn','');

function MontageRepos(curfig, fig)
global st;
fig=fig;
bb=st{curfig}.bb;
Dims = round(diff(bb)'+1);

handles=guidata(fig);
IndexM=handles.IndexM;
IndexM=flipdim(IndexM, 1);
cp=get(handles.MontageAxe, 'CurrentPoint');
cp=cp(1,1:2);

Type=handles.MontageType;
switch upper(Type)
    case 'T'
        D=Dims([1 2]);
    case 'C'
        D=Dims([1 3]);
    case 'S'
        if st{curfig}.mode==0
            D=Dims([3 2]);
        else
            D=Dims([2 3]); 
        end 
end

N=fix(cp(1)/D(1));
M=fix(cp(2)/D(2));
Slice=IndexM(M+1, N+1);

cp(1)=cp(1)-N*D(1);
cp(2)=cp(2)-M*D(2);

Space=handles.Space;
is   = inv(Space);
cent = is(1:3,1:3)*zeros(3,1) + is(1:3,4);
switch upper(Type)
    case 'T'
        cent([1 2])=[cp(1)+bb(1,1)-1 cp(2)+bb(1,2)-1];
        centre=Space(1:3,1:3)*cent(:) +Space(1:3,4);
        centre(3)=Slice;
    case 'C'
        cent([1 3])=[cp(1)+bb(1,1)-1 cp(2)+bb(1,3)-1];
        centre=Space(1:3,1:3)*cent(:) +Space(1:3,4);
        centre(2)=Slice;
    case 'S'
        if st{curfig}.mode ==0
        	cent([3 2])=[cp(1)+bb(1,3)-1 cp(2)+bb(1,2)-1];
        else
            cent([2 3])=[bb(2,2)+1-cp(1) cp(2)+bb(1,3)-1];
        end
        centre=Space(1:3,1:3)*cent(:) +Space(1:3,4);
        centre(1)=Slice;
end

y_spm_orthviews('Reposition', centre);
%RedrawXhairs(curfig, fig);


% --- Executes on button press in ReduceButton.
function ReduceButton_Callback(hObject, eventdata, handles)
% hObject    handle to ReduceButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Increment=str2double(get(handles.DeltasEntry, 'String'));
if isnan(Increment)
    return
end
handles.IndexM=handles.IndexM-Increment;
set(handles.BeginEntry, 'String', num2str(handles.IndexM(1,1)));

[Image, Space]=w_MontageImage(handles.IndexM, handles.MontageType, handles.MainFig);
set(handles.ImageView, 'HitTest', 'off', 'Cdata', Image);
set(handles.MontageAxe, 'XLim', [1, size(Image,2)]);
set(handles.MontageAxe, 'YLim', [1, size(Image,1)]);

ResizeFig(handles, size(Image, 2)/size(Image, 1));

handles.Space=Space;

guidata(hObject, handles);
RedrawXhairs(handles.MainFig, handles.figure1);



% --- Executes on button press in PlusButton.
function PlusButton_Callback(hObject, eventdata, handles)
% hObject    handle to PlusButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Increment=str2double(get(handles.DeltasEntry, 'String'));
if isnan(Increment)
    return
end
handles.IndexM=handles.IndexM+Increment;
set(handles.BeginEntry, 'String', num2str(handles.IndexM(1,1)));

[Image, Space]=w_MontageImage(handles.IndexM, handles.MontageType, handles.MainFig);
set(handles.ImageView, 'HitTest', 'off', 'Cdata', Image);
set(handles.MontageAxe, 'XLim', [1, size(Image,2)]);
set(handles.MontageAxe, 'YLim', [1, size(Image,1)]);

ResizeFig(handles, size(Image, 2)/size(Image, 1));

handles.Space=Space;

guidata(hObject, handles);
RedrawXhairs(handles.MainFig, handles.figure1);
