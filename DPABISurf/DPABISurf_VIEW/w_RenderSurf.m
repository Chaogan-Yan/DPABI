function [AxesObj, Fcn]=w_RenderSurf(varargin)
% This file revised from spm_mesh_render.m
% Input:
%   SurfFile
%   AxesObj
%   SurfOpt
% Output:
%   AxesObj
%   Fcn 
%
% Copyright (C) 2011-2018 McGill Centre for Integrative Neuroscience (MCIN)
% Sandy Wang
if nargin<1
    error('Gifti Surface needed!');%û��ѡ��Underlay�ļ�ʱ����
else
    SurfFile=varargin{1};%��ȡƤ���ļ�
end

% Axes Object ��ȡ�Ҳ�����ϵ������˵�Ҳ�ͼ���������������ǰ��������һ��������Ϣ��ͼ����Ϊһ����ṹ��
if nargin<2
    figure
    AxesObj=axes;%û��ͼ��ʱ��Ϊ�գ��½�ͼ��
else
    AxesObj=varargin{2};%��ͼ��ʱ���ȡ��ǰͼ���ڵ�����
end
%cla(AxesObj)

% Surface Option ��ȡ�������ԣ�����ΪVIEW������ѡ�
if nargin<3
    SurfOpt=DefaultSurfOpt;%����໹δ����ʱ��ΪĬ��ѡ��������
else
    SurfOpt=varargin{3};%���ú����ȡ���ѡ������
end

AxesHandle=getappdata(AxesObj, 'AxesHandle');%��ȡ������ṹ����
FigObj=ancestor(AxesObj, 'figure');%�������Ӧ��ͼƬ��
set(FigObj, 'Renderer', SurfOpt.Renderer);%����Ϊ��Ӧ��Renderer��
set(FigObj, 'Tag', 'DPABISurf_VIEW')%���ñ�ǩΪDPABISurf-VIEW
%set(FigObj, 'Color', SurfOpt.BackGroundColor);

V=gifti(SurfFile);%��ȡƤ���ļ�
M=export(V, 'patch');%ת��Ϊstruct
P=struct('vertices', M.vertices, 'faces', M.faces);%�½�struct: P����Ƥ���ļ���������Ϣ����
%%%
FaceColor=[0.75, 0.75, 0.75];%������ɫ
FaceAlpha=1;%͸����
%%%
AxeChildObj=get(AxesObj, 'Children');%�������Ӧ�����ࣿ
CurUnderSurf='';%��
for i=1:numel(AxeChildObj)%����������Ƿ��б�ǩΪUnderSurf������Ŀ��������ֵ
    Tag=get(AxeChildObj(i), 'Tag');
    if strcmpi(Tag, 'UnderSurf')
        CurUnderSurf=AxeChildObj(i);
    end
end
if isempty(CurUnderSurf)%��δ�鵽�������Ŀ
    PatchObj=patch(P,...  %����ͼ�����ԣ�Ĭ�ϣ�
        'FaceColor',        FaceColor,...%������ɫ���ң�
        'CDataMapping',     'direct',...
        'FaceAlpha',        FaceAlpha,...%����͸����
        'AlphaDataMapping', 'none',...
        'EdgeColor',        'none',...%��Ե��ɫ
        'FaceLighting',     SurfOpt.FaceLighting,...
        'SpecularStrength', SurfOpt.SpecularStrength,...
        'AmbientStrength',  SurfOpt.AmbientStrength,...
        'DiffuseStrength',  SurfOpt.DiffuseStrength,...
        'SpecularExponent', SurfOpt.SpecularExponent,...
        'Clipping',         SurfOpt.Clipping,...
        'Visible',          'Off',...%���ɼ�
        'CDataMapping',     'direct',...
        'Tag',              'UnderSurf',...%��ǩΪUnderSurf
        'Parent',           AxesObj);
    
    % Set the Axis of Axes �������ꣿ
    axis(AxesObj, 'image');
    axis(AxesObj, 'auto');
    axis(AxesObj, 'off');
    view(AxesObj, SurfOpt.ViewPoint);
    material(AxesObj, SurfOpt.Material);
    
    % Light Model
    Light=camlight(SurfOpt.LightOrient);
    set(Light, 'Parent', AxesObj);
    set(Light, 'style', 'infinite');
    
    % Rotate Obj ��ת���ܣ�
    Rotate3d=rotate3d(AxesObj);
    set(Rotate3d, 'Enable', 'On');%����ת���ܣ�
    set(Rotate3d, 'ActionPostCallback', @RotateLight);%ʹ����Ӧ����Ϊ��RotateLight --line 260
    %����AxesHandle
    AxesHandle.Light=Light;
    AxesHandle.Rotate3d=Rotate3d;
    
    % Under Surface Object  ����UnderSurf�ṹ
    AxesHandle.UnderSurf.Obj=PatchObj;
    AxesHandle.UnderSurf.SurfFile=SurfFile;
    AxesHandle.UnderSurf.FaceColor=FaceColor;
    AxesHandle.UnderSurf.FaceAlpha=FaceAlpha;
    AxesHandle.UnderSurf.StructData=P;
    AxesHandle.UnderSurf.Curv=spm_mesh_curvature(P);
    AxesHandle.UnderSurf.IsShowTexture=0;
    AxesHandle.UnderSurf.CCLabel=spm_mesh_label(P);
    AxesHandle.UnderSurf.IsYoked=false;
    
    AxesHandle.SurfOpt=SurfOpt;
    
    % Class Function���ֺ���
    Fcn.DefaultSurfOpt=...
        @() DefaultSurfOpt;
    Fcn.SetSurfOpt=...
        @(SurfOpt) SetSurfOpt(AxesObj, SurfOpt);
    Fcn.GetSurfOpt=...
        @() GetSurfOpt(AxesObj);
    Fcn.GetViewPoint=...
        @() GetViewPoint(AxesObj);
    Fcn.SetViewPoint=...
        @(ViewPoint) SetViewPoint(AxesObj, ViewPoint);
    Fcn.GetYokedFlag=...
        @() GetYokedFlag(AxesObj);
    Fcn.SetYokedFlag=...
        @(IsYoked) SetYokedFlag(AxesObj, IsYoked);
    Fcn.GetViewPointCustomFlag=...
        @() GetViewPointCustomFlag(AxesObj);
    Fcn.SetViewPointCustomFlag=...
        @(CustomFlag) SetViewPointCustomFlag(AxesObj, CustomFlag);    
    Fcn.GetDisplayTextureFlag=...
        @() GetDisplayTextureFlag(AxesObj);
    Fcn.SetDisplayTextureFlag=...
        @(IsShow) SetDisplayTextureFlag(AxesObj, IsShow);
    Fcn.AddLabel=...
        @(varargin) AddLabel(AxesObj, varargin);%�Ƿ���һ��varargin�������׺�ʱ����
    Fcn.SetLabel=...
        @(LabelInd) SetLabel(AxesObj, LabelInd);    
    Fcn.RemoveLabel=...
        @(LabelInd) RemoveLabel(AxesObj, LabelInd);
    Fcn.GetLabelFiles=...
        @() GetLabelFiles(AxesObj);
    Fcn.GetLabelAlpha=...
        @(LabelInd) GetLabelAlpha(AxesObj, LabelInd);
    Fcn.SetLabelAlpha=...
        @(LabelInd, Alpha) SetLabelAlpha(AxesObj, LabelInd, Alpha);    
    Fcn.AddOverlay=...
        @(varargin) AddOverlay(AxesObj, varargin);
    Fcn.RemoveOverlay=...
        @(OverlayInd) RemoveOverlay(AxesObj, OverlayInd);
    Fcn.GetOverlayFiles=...
        @() GetOverlayFiles(AxesObj);
    Fcn.SetOverlayOrder=...
        @(OverlayOrder) SetOverlayOrder(AxesObj, OverlayOrder);
    Fcn.GetOverlayThres=...
        @(OverlayInd) GetOverlayThres(AxesObj, OverlayInd);
    Fcn.SetOverlayThres=...
        @(OverlayInd, NMax, NMin, PMin, PMax) SetOverlayThres(AxesObj, OverlayInd, NMax, NMin, PMin, PMax);
    Fcn.GetOverlayGuiData=...
        @(OverlayInd) GetOverlayGuiData(AxesObj, OverlayInd);
    Fcn.SetOverlayGuiData=...
        @(OverlayInd, GuiData) SetOverlayGuiData(AxesObj, OverlayInd, GuiData);  
    Fcn.GetOverlayThresPN_Flag=...
        @(OverlayInd) GetOverlayThresPN_Flag(AxesObj, OverlayInd);
    Fcn.SetOverlayThresPN_Flag=...
        @(OverlayInd, ThresPN_Flag) SetOverlayThresPN_Flag(AxesObj, OverlayInd, ThresPN_Flag);    
    Fcn.GetOverlayColorMap=...
        @(OverlayInd) GetOverlayColorMap(AxesObj, OverlayInd);
    Fcn.SetOverlayColorMap=...
        @(OverlayInd, CM, PN_Flag) SetOverlayColorMap(AxesObj, OverlayInd, CM, PN_Flag);
    Fcn.GetOverlayVertexMask=...
        @(OverlayInd) GetOverlayVertexMask(AxesObj, OverlayInd);
    Fcn.SetOverlayVertexMask=...
        @(OverlayInd, VMsk) SetOverlayVertexMask(AxesObj, OverlayInd, VMsk);
    Fcn.GetOverlayClusterSizeOption=...
        @(OverlayInd) GetOverlayClusterSizeOption(AxesObj, OverlayInd);
    Fcn.SetOverlayClusterSizeOption=...
        @(OverlayInd, CSizeOpt) SetOverlayClusterSizeOption(AxesObj, OverlayInd, CSizeOpt);
    Fcn.GetOverlayStatOption=...
        @(OverlayInd) GetOverlayStatOption(AxesObj, OverlayInd);
    Fcn.SetOverlayStatOption=...
        @(OverlayInd, StatOpt) SetOverlayStatOption(AxesObj, OverlayInd, StatOpt);
    Fcn.GetOverlayPThres=...
        @(OverlayInd) GetOverlayPThres(AxesObj, OverlayInd);
    Fcn.SetOverlayPThres=...
        @(OverlayInd, varargin) SetOverlayPThres(AxesObj, OverlayInd, varargin);
    Fcn.GetOverlayAlpha=...
        @(OverlayInd) GetOverlayAlpha(AxesObj, OverlayInd);
    Fcn.SetOverlayAlpha=...
        @(OverlayInd, Alpha) SetOverlayAlpha(AxesObj, OverlayInd, Alpha);
    Fcn.GetOverlayTimePoint=...
        @(OverlayInd) GetOverlayTimePoint(AxesObj, OverlayInd);
    Fcn.SetOverlayTimePoint=...
        @(OverlayInd, TP) SetOverlayTimePoint(AxesObj, OverlayInd, TP);
    Fcn.UpdateOverlay=...
        @(OverlayInd) UpdateOverlay(AxesObj, OverlayInd);
    Fcn.SaveOverlayClusters=...
        @(OverlayInd, OutFile) SaveOverlayClusters(AxesObj, OverlayInd, OutFile);
    Fcn.SaveCurrentOverlayCluster=...
        @(OverlayInd, OutFile) SaveCurrentOverlayCluster(AxesObj, OverlayInd, OutFile);    
    Fcn.ReportOverlayCluster=...
        @(OverlayInd, LabelInd) ReportOverlayCluster(AxesObj, OverlayInd, LabelInd);
    Fcn.SetBorder=...
        @(varargin) SetBorder(AxesObj, varargin);
    Fcn.GetDataCursorObj=...
        @() GetDataCursorObj(AxesObj);
    Fcn.SaveMontage=...
        @(varargin) SaveMontage(AxesObj, varargin);
    Fcn.GetDataCursorPos=...
        @() GetDataCursorPos(AxesObj);
    Fcn.MoveDataCursor=...
        @(Pos) MoveDataCursor(AxesObj, Pos);
    
    AxesHandle.Fcn=Fcn;%������
    
    set(PatchObj, 'Visible', 'On');%������һ�к�����򿪿ɼ���Ƥ��ͼ���ʱ���֣�
    
    FigObj=ancestor(AxesObj, 'figure');
    DataCursor=datacursormode(FigObj);%�������������ʾ����
    set(DataCursor, 'UpdateFcn', @(empt, event_obj) GetPosInfo(empt, event_obj, AxesObj));%��ΪGetPosInfo����-1575
    AxesHandle.DataCursor=DataCursor;%����������ṹ
    
    setappdata(AxesObj, 'AxesHandle', AxesHandle);%����������Ϣ
    
    FigHandle=guidata(AxesObj);
    if isfield(FigHandle, 'ViewPointMenu')
        set(FigHandle.ViewPointMenu, 'Value', 2);
    end
else %��ӵ��UnderSurf�ӽṹ
    if isfield(AxesHandle, 'OverlaySurf') %��������Overlay��
        if size(AxesHandle.OverlaySurf(1).Vertex, 1)~=size(P.vertices, 1) %�����Underlay������Ƿ���ȣ��������
            errordlg('Number of Vertices Not Match Between Selected Overlay and Underlay!'); %����������ʾ
            Fcn=AxesHandle.Fcn;%������
            return;
        end
        for i=1:numel(AxesHandle.OverlaySurf) %��P�е�������Ϣ����Overlay�еĵ㣿��ȷ��Ϊ��Ҫ��ѭ��������Ϊ�����ж��Overlay�����ⲻ̫ȷ���Ƿ�Ϊһһ��Ӧ��ϵ
            set(AxesHandle.OverlaySurf(i).Obj, 'Faces', P.faces,...
                'Vertices', P.vertices);
        end
    end
    
    if isfield(AxesHandle, 'LabelSurf') %��������Label��
        if size(AxesHandle.LabelSurf(1).LabelV, 1)~=size(P.vertices, 1)%�����Underlay������Ƿ���ȣ��������
            errordlg('Number of Vertices Not Match Between Selected Label and Underlay!');%����������ʾ��ͬ��
            Fcn=AxesHandle.Fcn;
            return;
        end
        for i=1:numel(AxesHandle.LabelSurf)%��P�е�������Ϣ����Label�еĵ㣿����ͬ��
            set(AxesHandle.LabelSurf(i).Obj, 'Faces', P.faces,...
                'Vertices', P.vertices);
        end
    end     
    
    set(AxesHandle.UnderSurf.Obj, 'Faces', P.faces,...
        'Vertices', P.vertices);%��������Ϣ����Underlay
    axis(AxesObj, 'auto');
    axis(AxesObj, 'off');
    %����UnderSurf�ĸ������������̻�����if����ͬ
    AxesHandle.UnderSurf.SurfFile=SurfFile;
    AxesHandle.UnderSurf.FaceColor=FaceColor;
    AxesHandle.UnderSurf.FaceAlpha=FaceAlpha;
    AxesHandle.UnderSurf.StructData=P;
    AxesHandle.UnderSurf.Curv=spm_mesh_curvature(P);
    AxesHandle.UnderSurf.IsShowTexture=0;
    AxesHandle.UnderSurf.CCLabel=spm_mesh_label(P);
    
    AxesHandle.SurfOpt=SurfOpt;%��������ṹ��
    setappdata(AxesObj, 'AxesHandle', AxesHandle);
    Fcn=AxesHandle.Fcn;
end

% Display Sth
DisplayTexture(AxesObj);%��ʱ����Ƥ��ͼ��

function RotateLight(varargin)
AxesHandle=getappdata(gca, 'AxesHandle');
camlight(AxesHandle.Light, AxesHandle.SurfOpt.LightOrient);
set(AxesHandle.Light, 'style', 'infinite');
[X, Y]=view(gca);
AxesHandle.SurfOpt.ViewPoint=[X, Y];
setappdata(gca, 'AxesHandle', AxesHandle);

SetViewPointCustomFlag(gca, 1);
FigHandle=guidata(gca);
if isfield(FigHandle, 'ViewPointMenu')
    set(FigHandle.ViewPointMenu, 'Value', 8);
end

function SurfOpt=GetSurfOpt(AxesObj)%��ȡƤ��ͼ������ѡ���ֵ�ú���
AxesHandle=getappdata(AxesObj, 'AxesHandle');
SurfOpt=AxesHandle.SurfOpt;

function SetSurfOpt(AxesObj, SurfOpt)%����Ƥ��ͼ������ѡ�����ԭ��
AxesHandle=getappdata(AxesObj, 'AxesHandle');
FigObj=ancestor(AxesObj, 'figure');

set(AxesHandle.UnderSurf.Obj,...
    'FaceLighting',     SurfOpt.FaceLighting,...
    'SpecularStrength', SurfOpt.SpecularStrength,...
    'AmbientStrength',  SurfOpt.AmbientStrength,...
    'DiffuseStrength',  SurfOpt.DiffuseStrength,...
    'SpecularExponent', SurfOpt.SpecularExponent,...
    'Clipping',         SurfOpt.Clipping);
view(AxesObj, SurfOpt.ViewPoint);
material(FigObj, SurfOpt.Material);
set(FigObj, 'Renderer', SurfOpt.Renderer);
set(FigObj, 'Color', SurfOpt.BackGroundColor);

AxesHandle.SurfOpt=SurfOpt;
setappdata(AxesObj, 'AxesHandle', AxesHandle);

function DcObj=GetDataCursorObj(AxesObj)%��ȡ��ʾ��ĺ���
AxesHandle=getappdata(AxesObj, 'AxesHandle');%��ȡ��ǰ����
DcObj=AxesHandle.DataCursor;%��ֵ

function Opt=GetViewPoint(AxesObj)%��ȡ�ӽǺ���
AxesHandle=getappdata(AxesObj, 'AxesHandle');%��ȡ��ǰ����
Opt.ViewPoint=AxesHandle.SurfOpt.ViewPoint;%��ֵ

function SetViewPoint(AxesObj, ViewPoint)%�����ӽǺ���
AxesHandle=getappdata(AxesObj, 'AxesHandle');%��ȡ��ǰ����
view(AxesObj, ViewPoint);%�����ӽ�
camlight(AxesHandle.Light, AxesHandle.SurfOpt.LightOrient);%�������߽Ƕ�
set(AxesHandle.Light, 'style', 'infinite');%����Light

AxesHandle.SurfOpt.ViewPoint=ViewPoint;%��ֵ
setappdata(AxesObj, 'AxesHandle', AxesHandle);%��������

function Opt=GetYokedFlag(AxesObj)
AxesHandle=getappdata(AxesObj, 'AxesHandle');
Opt.IsYoked=AxesHandle.UnderSurf.IsYoked;

function SetYokedFlag(AxesObj, IsYoked)
AxesHandle=getappdata(AxesObj, 'AxesHandle');

AxesHandle.UnderSurf.IsYoked=IsYoked;
setappdata(AxesObj, 'AxesHandle', AxesHandle);

function Opt=GetViewPointCustomFlag(AxesObj)%��ȡ�ӽǱ�ǩ
AxesHandle=getappdata(AxesObj, 'AxesHandle');%��ȡ��ǰ״̬
Opt.CustomFlag=AxesHandle.SurfOpt.ViewPointCustomFlag;%�������ֵ

function SetViewPointCustomFlag(AxesObj, CustomFlag)%�����ӽǱ�ǩ
AxesHandle=getappdata(AxesObj, 'AxesHandle');%��ȡ��ǰ����

AxesHandle.SurfOpt.ViewPointCustomFlag=CustomFlag;%��ֵ
setappdata(AxesObj, 'AxesHandle', AxesHandle);%��������

function IsShowTexture=GetDisplayTextureFlag(AxesObj)%��ȡ�ж��Ƿ������ǩ����
AxesHandle=getappdata(AxesObj, 'AxesHandle');%��ȡ��ǰ����
IsShowTexture=AxesHandle.UnderSurf.IsShowTexture;%�������ֵ

function SetDisplayTextureFlag(AxesObj, IsShowTexture)%�����Ƿ���ʾ�����ǩ
AxesHandle=getappdata(AxesObj, 'AxesHandle');%��ȡ��ǰ����
AxesHandle.UnderSurf.IsShowTexture=IsShowTexture;%��ֵ
setappdata(AxesObj, 'AxesHandle', AxesHandle);%��������
DisplayTexture(AxesObj);%������ʾͼ��

function DisplayTexture(AxesObj)%��ʾƤ��ͼ��
AxesHandle=getappdata(AxesObj, 'AxesHandle');%��ȡ��ǰ����
FaceColor=AxesHandle.UnderSurf.FaceColor;%��ɫ�ļ�
if AxesHandle.UnderSurf.IsShowTexture %�����ʾͼ��
    Curv=AxesHandle.UnderSurf.Curv;%��ȡ�����ǩ��
    Curv=Curv>0;%����ǩ����0������Ϊ1���൱��Mask��
    NumV=size(Curv, 1);%������
    if size(Curv, 2) == 1%��ֻ��һ���ǩʱ
        C = repmat(FaceColor, [NumV, 1]).*repmat(Curv,[1, 3]) + repmat(0.6*FaceColor, [NumV, 1]).*repmat(~Curv, [1, 3]);
    end
    set(AxesHandle.UnderSurf.Obj,...
        'FaceColor', 'interp',...
        'FaceAlpha', AxesHandle.UnderSurf.FaceAlpha,...
        'FaceVertexCData', C);    
else
    set(AxesHandle.UnderSurf.Obj,...
        'FaceColor', FaceColor,...
        'FaceAlpha', AxesHandle.UnderSurf.FaceAlpha,...        
        'FaceVertexCData', []);
end

function SetBorder(AxesObj, VarArgIn)
AxesHandle=getappdata(AxesObj, 'AxesHandle');
FigObj=ancestor(AxesObj, 'figure');
SurfOpt=AxesHandle.SurfOpt;

if numel(VarArgIn)<1
    error('Border File Needed!')
end

if numel(VarArgIn)<2
    IsVis='On';
else
    IsVis=VarArgIn{2};
end

if isfield(AxesHandle, 'Border')
    delete(AxesHandle.Border.Obj);
    AxesHandle=rmfield(AxesHandle, 'Border');
end

BorderFile=VarArgIn{1};
V=gifti(BorderFile);
Border=V.cdata>0;
BorderCData=squeeze(ind2rgb(floor(Border*2), [1,1,1;0,0,0]));
BorderAlpha=single(Border);

PatchObj=patch(AxesHandle.UnderSurf.StructData,...
    'FaceColor',        'interp',...
    'FaceAlpha',        'interp',...
    'EdgeColor',        'none',...
    'EdgeAlpha',        0,...
    'FaceVertexCData',  BorderCData,...
    'FaceVertexAlpha',  BorderAlpha,...
    'FaceLighting',     SurfOpt.FaceLighting,...
    'SpecularStrength', SurfOpt.SpecularStrength,...
    'AmbientStrength',  SurfOpt.AmbientStrength,...
    'DiffuseStrength',  SurfOpt.DiffuseStrength,...
    'SpecularExponent', SurfOpt.SpecularExponent,...
    'Clipping',         SurfOpt.Clipping,...
    'CDataMapping',     'direct',...
    'Visible',          'Off',...
    'Tag',              'Border',...
    'Parent',           AxesObj);
material(FigObj, SurfOpt.Material);

AxesHandle.Border.BorderFile=BorderFile;
AxesHandle.Border.Obj=PatchObj;
AxesHandle.Border.IsVis=IsVis;

setappdata(AxesObj, 'AxesHandle', AxesHandle);
set(PatchObj, 'Visible', IsVis);

function ExitCode=SaveOverlayClusters(AxesObj, OverlayInd, OutFile)
ExitCode=1;
if nargin<3
    error('Invalid Input: OverlayInd, OutFile');
end

AxesHandle=getappdata(AxesObj, 'AxesHandle');

try
    OverlaySurf=AxesHandle.OverlaySurf(OverlayInd, 1);
catch 
    error('Invalid Overlay Index');
end
AdjustVA=AdjustVertexAlpha(OverlaySurf.Vertex, OverlaySurf.Alpha,...
    OverlaySurf.ThresPN_Flag,...
    OverlaySurf.NegMin, OverlaySurf.PosMin,...
    OverlaySurf.VMsk, OverlaySurf.CSizeOpt);
AdjustMsk=AdjustVA~=0;
Vertex=OverlaySurf.Vertex.*AdjustMsk;
V=gifti;
V.cdata=Vertex;
save(V, OutFile);
ExitCode=0;

function ExitCode=SaveCurrentOverlayCluster(AxesObj, OverlayInd, OutFile)
ExitCode=1;
if nargin<3
    error('Invalid Input: OverlayInd, OutFile');
end

AxesHandle=getappdata(AxesObj, 'AxesHandle');

try
    OverlaySurf=AxesHandle.OverlaySurf(OverlayInd, 1);
catch 
    error('Invalid Overlay Index');
end
% Find Position
DcObj=AxesHandle.DataCursor;
Pos=DcObj.getCursorInfo().Position;
Coord=AxesHandle.UnderSurf.StructData.vertices;
VInd= Coord(:,1)==Pos(1) & Coord(:,2)==Pos(2) & Coord(:,3)==Pos(3);

% Adjust Cluster Size
AdjustVA=AdjustVertexAlpha(OverlaySurf.Vertex, OverlaySurf.Alpha,...
    OverlaySurf.ThresPN_Flag,...
    OverlaySurf.NegMin, OverlaySurf.PosMin,...
    OverlaySurf.VMsk, OverlaySurf.CSizeOpt);
AdjustMsk=AdjustVA~=0;

% Find Cluster
CC=EstimateClustComp(AdjustMsk, OverlaySurf.CSizeOpt);
CInd=CC.Index(VInd);
if CInd==0
    errordlg('Error when select region, please check which overlay file you select!');
    return
end
AdjustMsk=CC.Index==CInd;

Vertex=OverlaySurf.Vertex.*AdjustMsk;
V=gifti;
V.cdata=Vertex;
save(V, OutFile);
ExitCode=0;

function UpdateOverlay(AxesObj, OverlayInd)%����Overlay�Ĳ�������ִ�ж�Ӧ�Ĳ���������ͼ�񣩣�
AxesHandle=getappdata(AxesObj, 'AxesHandle');%��ȡ���µ�����
if numel(AxesHandle.OverlaySurf)==0%��û��Overlay�����Ƴ���
    colorbar('delete');%ɾ����ɫ��
    return
end
OverlaySurf=AxesHandle.OverlaySurf(OverlayInd);%����Ŀ����Ϊ��ǰ��Overlay

[AdjustCM, Ticks, TickLabel]=AdjustColorMap(OverlaySurf.ColorMap, AxesHandle.UnderSurf.FaceColor, ...
    OverlaySurf.NegMax, OverlaySurf.NegMin, ...
    OverlaySurf.PosMin, OverlaySurf.PosMax, ...
    OverlaySurf.PN_Flag);

colormap(AdjustCM);
AdjustVC=AdjustVertexCData(OverlaySurf.Vertex, AdjustCM,...
    OverlaySurf.NegMax, OverlaySurf.NegMin, OverlaySurf.PosMin, OverlaySurf.PosMax);
AdjustVA=AdjustVertexAlpha(OverlaySurf.Vertex, OverlaySurf.Alpha,...
    OverlaySurf.ThresPN_Flag,...
    OverlaySurf.NegMin, OverlaySurf.PosMin,...
    OverlaySurf.VMsk, OverlaySurf.CSizeOpt);

set(OverlaySurf.Obj, ...
    'FaceVertexCData',  AdjustVC,...
    'FaceVertexAlpha',  AdjustVA);

colorbar('delete');%ɾ����ɫ��
colormap(AdjustCM);
CbObj=colorbar('Units', 'normalized', 'Position', [0.91, 0.05, 0.02, 0.9]);
set(CbObj, 'YTick', Ticks, 'YTickLabel', TickLabel);

setappdata(AxesObj, 'AxesHandle', AxesHandle);%��������

function OverlayFiles=GetOverlayFiles(AxesObj)%��ȡOverlay�ļ�����
AxesHandle=getappdata(AxesObj, 'AxesHandle');%��ȡ��������
OverlayFiles={AxesHandle.OverlaySurf.OverlayFile}';%��Ӧ�ļ�

function SetOverlayOrder(AxesObj, OverlayOrder)%����Overlay��˳��
if nargin<2
    error('Invalid Input: OverlayOrder');%��Overlay����С��2�򱨴�
end
AxesHandle=getappdata(AxesObj, 'AxesHandle');%��ȡ��ǰ����

if numel(AxesHandle.OverlaySurf)~=numel(OverlayOrder)
    error('Invalid Number of Order Index');%�������˳�򲻷��򱨴�
end

OverlayObjs={AxesHandle.OverlaySurf.Obj}';
OverlayObjs=flipdim(OverlayObjs(OverlayOrder), 1);
AllObjs=get(AxesObj, 'Children');
Ind=false(size(AllObjs));
for i=1:numel(OverlayObjs)
    Ind=Ind | (OverlayObjs{i}==AllObjs);
end

i=1;
for a=1:numel(AllObjs)
    if Ind(a)
        AllObjs(a)=OverlayObjs{i};
        i=i+1;
    end
end

AxesHandle.OverlaySurf=AxesHandle.OverlaySurf(OverlayOrder);
setappdata(AxesObj, 'AxesHandle', AxesHandle);
set(AxesObj, 'Children', AllObjs)

function Opt=GetOverlayThres(AxesObj, OverlayInd) %��ȡOverlay����ֵ��NMax,NMin,PMax,PMin
AxesHandle=getappdata(AxesObj, 'AxesHandle');%��ȡ��ǰ������

try
    OverlaySurf=AxesHandle.OverlaySurf(OverlayInd, 1);%�������ݽṹ��̫�˽�
catch 
    error('Invalid Overlay Index');
end
Opt.NegMax=OverlaySurf.NegMax;%����ֵ�������뵽�������������
Opt.NegMin=OverlaySurf.NegMin;
Opt.PosMin=OverlaySurf.PosMin;
Opt.PosMax=OverlaySurf.PosMax;

function SetOverlayThres(AxesObj, OverlayInd, NMax, NMin, PMin, PMax)%����Overlay����ֵ��NMax,NMin,PMax,PMin
if nargin<6
    error('Invalid Input: OverlayInd, NMax, NMin, PMin, PMax');%���������С��6������
end

AxesHandle=getappdata(AxesObj, 'AxesHandle');%��������

try
    OverlaySurf=AxesHandle.OverlaySurf(OverlayInd, 1);%�������ݽṹ��̫�˽⣬ͬ��
catch
    error('Invalid Overlay Index');
end
OverlaySurf.NegMax=NMax;%����Ӧ��ֵ���棨���£�����������
OverlaySurf.NegMin=NMin;
OverlaySurf.PosMin=PMin;
OverlaySurf.PosMax=PMax;

AxesHandle.OverlaySurf(OverlayInd)=OverlaySurf;%����ǰOverlay����ĸ�ṹ
setappdata(AxesObj, 'AxesHandle', AxesHandle);%��������
UpdateOverlay(AxesObj, OverlayInd);%����Overlay��ִ����Ӧ����

function Opt=GetOverlayThresPN_Flag(AxesObj, OverlayInd)
AxesHandle=getappdata(AxesObj, 'AxesHandle');

try
    OverlaySurf=AxesHandle.OverlaySurf(OverlayInd, 1);
catch 
    error('Invalid Overlay Index');
end
Opt.ThresPN_Flag=OverlaySurf.ThresPN_Flag;

function SetOverlayThresPN_Flag(AxesObj, OverlayInd, ThresPN_Flag)
if nargin<3
    error('Invalid Input: OverlayInd, ThresPN_Flag');
end

AxesHandle=getappdata(AxesObj, 'AxesHandle');

try
    OverlaySurf=AxesHandle.OverlaySurf(OverlayInd, 1);
catch
    error('Invalid Overlay Index');
end
OverlaySurf.ThresPN_Flag=ThresPN_Flag;

AxesHandle.OverlaySurf(OverlayInd)=OverlaySurf;
setappdata(AxesObj, 'AxesHandle', AxesHandle);
UpdateOverlay(AxesObj, OverlayInd);

function Opt=GetOverlayVertexMask(AxesObj, OverlayInd)
AxesHandle=getappdata(AxesObj, 'AxesHandle');%��ȡ��ǰ����

try
    OverlaySurf=AxesHandle.OverlaySurf(OverlayInd, 1);
catch 
    error('Invalid Overlay Index');
end
Opt.VMsk=OverlaySurf.VMsk;

function SetOverlayVertexMask(AxesObj, OverlayInd, VMsk)
if nargin<3
    error('Invalid Input: OverlayInd, VertexMask');
end

AxesHandle=getappdata(AxesObj, 'AxesHandle');

try
    OverlaySurf=AxesHandle.OverlaySurf(OverlayInd, 1);
catch 
    error('Invalid Overlay Index');
end
if length(OverlaySurf.Vertex)~=length(VMsk)
    error('Invalid Overlay Vertex Mask Size');
end
OverlaySurf.VMsk=VMsk;

AxesHandle.OverlaySurf(OverlayInd)=OverlaySurf;
setappdata(AxesObj, 'AxesHandle', AxesHandle);
UpdateOverlay(AxesObj, OverlayInd)

function Opt=GetOverlayColorMap(AxesObj, OverlayInd)
AxesHandle=getappdata(AxesObj, 'AxesHandle');

try
    OverlaySurf=AxesHandle.OverlaySurf(OverlayInd, 1);
catch 
    error('Invalid Overlay Index');
end
Opt.ColorMapString=OverlaySurf.ColorMapString;
Opt.ColorMap=OverlaySurf.ColorMap;
Opt.PN_Flag=OverlaySurf.PN_Flag;

function SetOverlayColorMap(AxesObj, OverlayInd, CM, PN_Flag)
if nargin<3
    error('Invalid Input: OverlayInd, ColorMap');
end

AxesHandle=getappdata(AxesObj, 'AxesHandle');

try
    OverlaySurf=AxesHandle.OverlaySurf(OverlayInd, 1);
catch
    error('Invalid Overlay Index');
end
if ischar(CM)
    ColorMapString=CM;
    if length(CM)>=4 && strcmpi(CM(1:4), 'AFNI')
        ColorMap=y_AFNI_ColorMap(str2double(CM(5:end)));
    else
        if isempty(strfind(CM, '(')) && isempty(strfind(CM, ')'))
            ColorMap=colormap([CM, '(64)']);            
        else
            ColorMap=colormap(CM);
        end        
    end
else
    ColorMapString='Manual';
    ColorMap=CM;   
end
OverlaySurf.ColorMapString=ColorMapString;
OverlaySurf.ColorMap=ColorMap;
OverlaySurf.PN_Flag=PN_Flag;

AxesHandle.OverlaySurf(OverlayInd)=OverlaySurf;
setappdata(AxesObj, 'AxesHandle', AxesHandle);
UpdateOverlay(AxesObj, OverlayInd);

function Opt=GetOverlayClusterSizeOption(AxesObj, OverlayInd)
AxesHandle=getappdata(AxesObj, 'AxesHandle');

try
    OverlaySurf=AxesHandle.OverlaySurf(OverlayInd, 1);
catch 
    error('Invalid Overlay Index');
end
Opt=OverlaySurf.CSizeOpt;

function SetOverlayClusterSizeOption(AxesObj, OverlayInd, CSizeOpt)
if nargin<3
    error('Invalid Input: OverlayInd, Alpha');
end
AxesHandle=getappdata(AxesObj, 'AxesHandle');

try
    OverlaySurf=AxesHandle.OverlaySurf(OverlayInd, 1);
catch %#ok<*CTCH>
    error('Invalid Overlay Index');
end
OverlaySurf.CSizeOpt=CSizeOpt;

AxesHandle.OverlaySurf(OverlayInd)=OverlaySurf;
setappdata(AxesObj, 'AxesHandle', AxesHandle);
UpdateOverlay(AxesObj, OverlayInd);

function Opt=GetOverlayStatOption(AxesObj, OverlayInd)
AxesHandle=getappdata(AxesObj, 'AxesHandle');

try
    OverlaySurf=AxesHandle.OverlaySurf(OverlayInd, 1);
catch  %#ok<CTCH>
    error('Invalid Overlay Index');
end
Opt=OverlaySurf.StatOpt;

function SetOverlayStatOption(AxesObj, OverlayInd, StatOpt)
if nargin<3
    error('Invalid Input: OverlayInd, StatOpt');
end
AxesHandle=getappdata(AxesObj, 'AxesHandle');

try
    OverlaySurf=AxesHandle.OverlaySurf(OverlayInd, 1);
catch
    error('Invalid Overlay Index');
end
OverlaySurf.StatOpt=StatOpt;

AxesHandle.OverlaySurf(OverlayInd)=OverlaySurf;
setappdata(AxesObj, 'AxesHandle', AxesHandle);

function Opt=GetOverlayPThres(AxesObj, OverlayInd)
AxesHandle=getappdata(AxesObj, 'AxesHandle');

try
    OverlaySurf=AxesHandle.OverlaySurf(OverlayInd, 1);
catch 
    error('Invalid Overlay Index');
end
NMin=OverlaySurf.NegMin;
PMin=OverlaySurf.PosMin;

StatOpt=OverlaySurf.StatOpt;
Opt=StatOpt;
if ~strcmpi(Opt.TestFlag, 'T') && ~strcmpi(Opt.TestFlag, 'Z') && ...
        ~strcmpi(Opt.TestFlag, 'R') && ~strcmpi(Opt.TestFlag, 'F')
    Opt.PThres=[];
else
    Thres=min([abs(NMin), abs(PMin)]);
    Opt.PThres=w_StatToP(Thres, StatOpt);    
end

function SetOverlayPThres(AxesObj, OverlayInd, VarArgIn)
if numel(VarArgIn)<1
    error('Invalid Input: OverlayInd, PThres');
end
PThres=VarArgIn{1};
AxesHandle=getappdata(AxesObj, 'AxesHandle');

try
    OverlaySurf=AxesHandle.OverlaySurf(OverlayInd, 1);
catch
    error('Invalid Overlay Index');
end
if numel(VarArgIn)<2
    StatOpt=OverlaySurf.StatOpt;
else
    StatOpt=VarArgIn{2};
end

NMax=OverlaySurf.NegMax;
NMin=OverlaySurf.NegMin;
PMin=OverlaySurf.PosMin;
PMax=OverlaySurf.PosMax;

Thres=w_PToStat(PThres, StatOpt);
if isempty(Thres)
    warning('Do not change P threshold. Please set Stat Option first!'); %#ok<WNTAG>
    return
end

if NMax==NMin && NMax==0
    PMin=Thres;
elseif PMax==PMin && PMax==0
    NMin=-Thres;    
else
    NMin=-Thres;
    PMin=Thres;
end
SetOverlayThres(AxesObj, OverlayInd, NMax, NMin, PMin, PMax)

function Opt=GetOverlayAlpha(AxesObj, OverlayInd)
AxesHandle=getappdata(AxesObj, 'AxesHandle');

try
    OverlaySurf=AxesHandle.OverlaySurf(OverlayInd, 1);
catch 
    error('Invalid Overlay Index');
end
Opt.Alpha=OverlaySurf.Alpha;

function SetOverlayAlpha(AxesObj, OverlayInd, Alpha)
if nargin<3
    error('Invalid Input: OverlayInd, Alpha');
end
AxesHandle=getappdata(AxesObj, 'AxesHandle');

try
    OverlaySurf=AxesHandle.OverlaySurf(OverlayInd, 1);
catch
    error('Invalid Overlay Index');
end
OverlaySurf.Alpha=Alpha;

AxesHandle.OverlaySurf(OverlayInd)=OverlaySurf;
setappdata(AxesObj, 'AxesHandle', AxesHandle);
UpdateOverlay(AxesObj, OverlayInd);

function Opt=GetOverlayGuiData(AxesObj, OverlayInd)
AxesHandle=getappdata(AxesObj, 'AxesHandle');

try
    OverlaySurf=AxesHandle.OverlaySurf(OverlayInd, 1);
catch 
    error('Invalid Overlay Index');
end
Opt=OverlaySurf.GuiData;

function SetOverlayGuiData(AxesObj, OverlayInd, GuiData)
if nargin<3
    error('Invalid Input: OverlayInd, Alpha');
end
AxesHandle=getappdata(AxesObj, 'AxesHandle');

try
    OverlaySurf=AxesHandle.OverlaySurf(OverlayInd, 1);
catch
    error('Invalid Overlay Index');
end
OverlaySurf.GuiData=GuiData;

AxesHandle.OverlaySurf(OverlayInd)=OverlaySurf;
setappdata(AxesObj, 'AxesHandle', AxesHandle);
UpdateOverlay(AxesObj, OverlayInd);


function Opt=GetOverlayTimePoint(AxesObj, OverlayInd)
AxesHandle=getappdata(AxesObj, 'AxesHandle');

try
    OverlaySurf=AxesHandle.OverlaySurf(OverlayInd, 1);
catch 
    error('Invalid Overlay Index');
end
Opt.NumTP=OverlaySurf.NumTP;
Opt.CurTP=OverlaySurf.CurTP;

function SetOverlayTimePoint(AxesObj, OverlayInd, TP)
if nargin<3
    error('Invalid Input: OverlayInd, TimePoint');
end
AxesHandle=getappdata(AxesObj, 'AxesHandle');

try
    OverlaySurf=AxesHandle.OverlaySurf(OverlayInd, 1);
catch
    error('Invalid Overlay Index');
end
if TP>OverlaySurf.NumTP
    error('Invalid Time Point');
end
OverlaySurf.CurTP=TP;
OverlaySurf.Vertex=OverlaySurf.AllVertices(:, TP);

AxesHandle.OverlaySurf(OverlayInd)=OverlaySurf;
setappdata(AxesObj, 'AxesHandle', AxesHandle);
UpdateOverlay(AxesObj, OverlayInd);

function RemoveOverlay(AxesObj, OverlayInd)
if nargin<2
    error('Invalid Input: OverlayInd');
end

AxesHandle=getappdata(AxesObj, 'AxesHandle');

try
    OverlaySurf=AxesHandle.OverlaySurf(OverlayInd, 1);
catch
    error('Invalid Overlay Index');
end
delete(OverlaySurf.Obj);
AxesHandle.OverlaySurf(OverlayInd)=[];
setappdata(AxesObj, 'AxesHandle', AxesHandle);

function PrintClusterReport(ClusterInfo)
fprintf('---------------------------Cluster Report---------------------------\n');
for i=1:numel(ClusterInfo)
    fprintf('\n');    
    fprintf('Cluster %d', i);
    fprintf('\tCluster Size (mm): %g', ClusterInfo{i}.ClusterSize);
    fprintf('\tPeak Index: %g\n', ClusterInfo{i}.PeakInd);
    fprintf('\tPeak Coord: X-%g, Y-%g, Z-%g]\n', ...
        ClusterInfo{i}.PeakCoord(1), ClusterInfo{i}.PeakCoord(2), ClusterInfo{i}.PeakCoord(3));
    fprintf('\tPeak Value: %g\n', ClusterInfo{i}.Peak);
    
    for j=1:size(ClusterInfo{i}.LabelProb, 1)
        if j==1
            fprintf('\tLabel Included:\n');
        end
        label_info=ClusterInfo{i}.LabelProb(j, :);
        fprintf('\t\t[%d] %s, %g%%\n', label_info{1}, label_info{2}, label_info{3}*100);
    end
end

function Opt=ReportOverlayCluster(AxesObj, OverlayInd, LabelInd)
AxesHandle=getappdata(AxesObj, 'AxesHandle');

try
    OverlaySurf=AxesHandle.OverlaySurf(OverlayInd, 1);
catch
    error('Invalid Overlay Index');
end

try
    LabelSurf=AxesHandle.LabelSurf(LabelInd, 1);
catch
    LabelSurf=[];
end

AdjustMsk=AdjustVertexAlpha(OverlaySurf.Vertex, OverlaySurf.Alpha,...
    OverlaySurf.ThresPN_Flag,...
    OverlaySurf.NegMin, OverlaySurf.PosMin,...
    OverlaySurf.VMsk, OverlaySurf.CSizeOpt);

CC=EstimateClustComp(AdjustMsk, OverlaySurf.CSizeOpt);

if isempty(CC.Size)
    Opt.ClusterInfo=[];
    fprintf('No Cluster Found!\n');
    return
else
    Opt.ClusterInfo=cell(numel(CC.Size), 1);
end

for i=1:max(CC.Index)
    OneInd=CC.Index==i;
    OneCluster=zeros(size(CC.Index));
    OneCluster(OneInd)=OverlaySurf.Vertex(OneInd);
    
    [~, PeakInd]=max(abs(OneCluster));
    Opt.ClusterInfo{i}.PeakInd=PeakInd;
    Peak=OneCluster(PeakInd);
    Opt.ClusterInfo{i}.Peak=Peak;
    PeakCoord=OverlaySurf.CSizeOpt.StructData.vertices(PeakInd, :);
    Opt.ClusterInfo{i}.PeakCoord=PeakCoord;
    Opt.ClusterInfo{i}.ClusterSize=CC.Size(i, 1);

    if isempty(LabelSurf)
        Opt.ClusterInfo{i}.LabelProb=[];
    else
        LabelInOneInd=LabelSurf.LabelV(OneInd);
        UInOneInd=unique(LabelInOneInd);
        LabelProb=cell(numel(UInOneInd), 3);
        LabelProb(:, 1)=num2cell(UInOneInd);
        LabelProb(:, 2)=arrayfun(@(u) LabelSurf.LabelName{LabelSurf.LabelU==u}, UInOneInd,...
            'UniformOutput', false);
        for j=1:numel(UInOneInd)
            LabelProb{j, 3}=sum(LabelInOneInd==UInOneInd(j))./length(LabelInOneInd);
        end
        Opt.ClusterInfo{i}.LabelProb=LabelProb;
    end
end
PrintClusterReport(Opt.ClusterInfo);

function ExitCode=AddOverlay(AxesObj, VarArgIn)%����AddLabellay�������Ӳ��ֹ���
ExitCode=1;
AxesHandle=getappdata(AxesObj, 'AxesHandle');
FigObj=ancestor(AxesObj, 'figure');
SurfOpt=AxesHandle.SurfOpt;

if nargin<1+1
    error('Overlay File Needed!')
end
OverlayFile=VarArgIn{1};
V=gifti(OverlayFile);

UnderNumV=size(AxesHandle.UnderSurf.StructData.vertices, 1);
OverNumV=size(V.cdata, 1);
if OverNumV~=UnderNumV
    errordlg('Number of Vertices Not Match Between Selected Overlay and Underlay!');
    return
end
AllVertices=double(V.cdata);
Vertex=AllVertices(:, 1);

if nargin<2+1
    OverlayOpt.PosMin=0;
    OverlayOpt.PosMax=max(Vertex);
    OverlayOpt.NegMin=0;
    OverlayOpt.NegMax=min(Vertex);
    OverlayOpt.ThresPN_Flag='';
    OverlayOpt.ColorMapString='jet(64)';
    OverlayOpt.ColorMap=colormap(OverlayOpt.ColorMapString);
    if OverlayOpt.PosMax==0
        OverlayOpt.PN_Flag='-';
    elseif OverlayOpt.NegMax==0
        OverlayOpt.PN_Flag='';
    else
        OverlayOpt.PN_Flag=[];
    end
    
    OverlayOpt.Alpha=1;
    OverlayOpt.InterpType='interp';
else
    OverlayOpt=VarArgIn{2};
end
% Other Option
GuiData.OverlayNegRatio=0;
GuiData.OverlayPosRatio=0;
GuiData.OverlayPosNegSync=true;
GuiData.VMskFile=[];
GuiData.VMskThres=[];
GuiData.VMskSignFlag='<';

NumTP=size(AllVertices, 2);
CurTP=1;
VMsk=ones(size(Vertex));
CSizeOpt.Thres=0;
CSizeOpt.StructData=AxesHandle.UnderSurf.StructData;
CSizeOpt.VAreaFile=[];
CSizeOpt.VArea=[];

DfS=w_ReadDF(V);%
TestFlag=DfS.TestFlag;
Df=DfS.Df;
Df2=DfS.Df2;

StatOpt.TestFlag=TestFlag;
StatOpt.TailedFlag=2; % One-Tailed: 1; Two-Tailed: 2.
if strcmpi(StatOpt.TestFlag, 'F')
    StatOpt.TailedFlag=1;
end
StatOpt.Df=Df;
StatOpt.Df2=Df2;

% Generate Colormap and Alpha
[AdjustCM, Ticks, TickLabel]=AdjustColorMap(OverlayOpt.ColorMap, AxesHandle.UnderSurf.FaceColor, ...
    OverlayOpt.NegMax, OverlayOpt.NegMin, OverlayOpt.PosMin, OverlayOpt.PosMax, OverlayOpt.PN_Flag);
AdjustVC=AdjustVertexCData(Vertex, AdjustCM,...
    OverlayOpt.NegMax, OverlayOpt.NegMin, OverlayOpt.PosMin, OverlayOpt.PosMax);
AdjustVA=AdjustVertexAlpha(Vertex, OverlayOpt.Alpha,...
    OverlayOpt.ThresPN_Flag,...
    OverlayOpt.NegMin, OverlayOpt.PosMin,...
    VMsk,...
    CSizeOpt);

PatchObj=patch(AxesHandle.UnderSurf.StructData,...
    'FaceColor',        OverlayOpt.InterpType,...
    'FaceAlpha',        OverlayOpt.InterpType,...
    'EdgeColor',        'none',...
    'FaceVertexCData',  AdjustVC,...
    'CDataMapping',     'direct',...
    'FaceVertexAlpha',  AdjustVA,...
    'AlphaDataMapping', 'none',...
    'FaceLighting',     SurfOpt.FaceLighting,...
    'SpecularStrength', SurfOpt.SpecularStrength,...
    'AmbientStrength',  SurfOpt.AmbientStrength,...
    'DiffuseStrength',  SurfOpt.DiffuseStrength,...
    'SpecularExponent', SurfOpt.SpecularExponent,...
    'Clipping',         SurfOpt.Clipping,...
    'CDataMapping',     'direct',...
    'Visible',          'Off',...
    'Tag',              'Overlay',...
    'Parent',           AxesObj);
material(FigObj, SurfOpt.Material);

colorbar('delete');
colormap(AdjustCM);
CbObj=colorbar('Units', 'normalized', 'Position', [0.91, 0.05, 0.02, 0.9]);
set(CbObj, 'YTick', Ticks, 'YTickLabel', TickLabel);

% OverlayOpt
OverlayOpt.OverlayFile=OverlayFile;
OverlayOpt.Obj=PatchObj;
OverlayOpt.AllVertices=AllVertices;
OverlayOpt.Vertex=Vertex;
OverlayOpt.NumTP=NumTP;
OverlayOpt.CurTP=CurTP;
OverlayOpt.VMsk=VMsk;
OverlayOpt.GuiData=GuiData;
OverlayOpt.CSizeOpt=CSizeOpt;
OverlayOpt.StatOpt=StatOpt;

if isfield(AxesHandle, 'OverlaySurf')
    Num=numel(AxesHandle.OverlaySurf);
    AxesHandle.OverlaySurf(Num+1, 1)=OverlayOpt;
else
    AxesHandle.OverlaySurf=OverlayOpt;
end
setappdata(AxesObj, 'AxesHandle', AxesHandle);
if any(AdjustVA)
    set(PatchObj, 'Visible', 'On');
else
    set(PatchObj, 'Visible', 'Off');
end

ResortSurf(AxesObj);

set(AxesHandle.DataCursor, 'Enable', 'off');
AxesHandle.DataCursor.removeAllDataCursors();

ExitCode=0;

function VertexAlpha = AdjustVertexAlpha(Vertex, Alpha, ThresPN_Flag, NMin, PMin, VMsk, CSizeOpt)
% Adjust Threshold
VertexAlpha=(Vertex>PMin) | (Vertex<NMin);
VertexAlpha(Vertex==0)=0;

% Adjust Vertex Mask
VertexAlpha(~VMsk)=0;

% ThresPN_Flag OnlyPos OnlyNeg Full
if strcmpi(ThresPN_Flag, '+') % OnlyPos
    VertexAlpha(Vertex<0)=0;
elseif strcmpi(ThresPN_Flag, '-') % OnlyNeg
    VertexAlpha(Vertex>0)=0;
else
    % Do Nothing
end

% Adjust Cluster Size
if CSizeOpt.Thres>0
    CC=EstimateClustComp(VertexAlpha, CSizeOpt);
    for i=1:max(CC.Index)
        OneInd=CC.Index==i;
        if CC.Size(i, 1)<=CSizeOpt.Thres
            VertexAlpha(OneInd)=false;
        end        
    end
end

VertexAlpha=Alpha.*VertexAlpha;

function CC=EstimateClustComp(Msk, CSizeOpt)
if all(Msk==0)
    CC.Index=zeros(size(Msk));
    CC.Size=[];
    return
end
Msk=logical(Msk);
CompInd=spm_mesh_clusters(CSizeOpt.StructData, Msk);
CompInd(isnan(CompInd))=0;
CC.Index=CompInd;
CC.Size=zeros(max(CompInd), 1);
if ~isempty(CSizeOpt.VArea)
    if length(CSizeOpt.VArea)~=length(Msk)
        error('Invalid Vertex Area Size')
    end
    
    for i=1:max(CompInd)
        OneInd=CompInd==i;
        CC.Size(i, 1)=sum(CSizeOpt.VArea(OneInd));
    end
else
    if size(CSizeOpt.StructData.vertices, 1)~=length(Msk)
        error('Invalid Surface Structure Data');
    end
    SubM=spm_mesh_split(CSizeOpt.StructData, CompInd);
    for i=1:max(CompInd)
        CC.Size(i, 1)=spm_mesh_area(SubM(i));
    end
end

function VertexCData = AdjustVertexCData(Vertex, CM, NMax, NMin, PMin, PMax)
%if (NMax==NMin) && NMax==0
%    VertexIndex=(Vertex-PMin)/(PMax-PMin);
%elseif (PMin==PMax) && PMax==0
%    VertexIndex=(Vertex-NMax)/(NMin-NMax);
%else
%    VertexIndex=(Vertex-NMax)/(PMax-NMax);
%end
VertexIndex=(Vertex-NMax)/(PMax-NMax);
VertexCData=squeeze(ind2rgb(floor(VertexIndex*length(CM)), CM));

function [NewColorMap, Ticks, TickLabel]= AdjustColorMap(OriginalColorMap,NullColor,NMax,NMin,PMin,PMax, PN_Flag)
% Adjust the colormap to leave blank to values under threshold, the orginal color map with be set into [NMax NMin] and [PMin PMax].
% Input: OriginalColorMap - the original color map
%        NullColor - The values between NMin and PMin will be set to this color (leave blank)
%        NMax, NMin, PMin, PMax - set the axis of colorbar (the orginal color map with be set into [NMax NMin] and [PMin PMax])
% Output: NewColorMap - the generated color map, a 100000 by 3 matrix.
%___________________________________________________________________________
% Written by YAN Chao-Gan 111023.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com

NewColorMap = repmat(NullColor,[100000 1]);
ColorLen=size(OriginalColorMap,1);

if PMax==PMin && PMax==0
    if strcmpi(PN_Flag, '-')
        TmpColorLen=ColorLen;
        Range=1:ColorLen;
    elseif strcmpi(PN_Flag, '+')
        TmpColorLen=nan;
        Range=[];
    else
        TmpColorLen=ColorLen/2;
        Range=1:(ColorLen/2);
    end
    NegativeColorSegment = ceil(100000*(NMin-NMax)/(0-NMax)/(TmpColorLen));
    if ~isnan(NegativeColorSegment)
        for iColor=1:Range
            Segment=NegativeColorSegment;
            Begin=(iColor-1)*NegativeColorSegment+1;
            if Begin < 1
                Segment=Segment-(1-Begin);
                Begin=1;
            end
            End=(iColor)*NegativeColorSegment;
            if End > 100000
                Segment=Segment-(End-100000);
                End=100000;
            end
            NewColorMap(Begin:End,:) = repmat(OriginalColorMap(iColor,:),[Segment 1]);
        end
    end
elseif NMax==NMin && NMax==0
    if strcmpi(PN_Flag, '-')
        TmpColorLen=nan;
        Range=[];
    elseif strcmpi(PN_Flag, '+')
        TmpColorLen=ColorLen;
        Range=ColorLen:-1:1;
    else
        TmpColorLen=ColorLen/2;
        Range=ColorLen:-1:(ColorLen/2+1);
    end
    if PMax==PMin
        PMin=PMin-realmin;
    end    
    PositiveColorSegment = ceil(100000*(PMax-PMin)/(PMax-0)/TmpColorLen);
    if ~isnan(PositiveColorSegment)
        for iColor=Range
            Segment=PositiveColorSegment;
            Begin=100000-(ColorLen-iColor+1)*PositiveColorSegment+1;
            if Begin < 1
                Segment=Segment-(1-Begin);
                Begin=1;
            end
            End=100000-(ColorLen-iColor)*PositiveColorSegment;
            if End > 100000
                Segment=Segment-(End-100000);
                End=100000;
            end
            NewColorMap(Begin:End,:) = repmat(OriginalColorMap(iColor,:),[Segment 1]);
        end
    end
else
    if strcmpi(PN_Flag, '-')
        NegativeColorSegment = ceil(50000*(NMin-NMax)/(0-NMax)/ColorLen);
        if ~isnan(NegativeColorSegment)
            for iColor=1:fix(ColorLen)
                Segment=NegativeColorSegment;
                Begin=(iColor-1)*NegativeColorSegment+1;
                if Begin < 1
                    Segment=Segment-(1-Begin);
                    Begin=1;
                end
                End=(iColor)*NegativeColorSegment;
                if End > 100000
                    Segment=Segment-(End-100000);
                    End=100000;
                end
                NewColorMap(Begin:End,:) = repmat(OriginalColorMap(iColor,:),[Segment 1]);
            end
        end
    elseif strcmpi(PN_Flag, '+')
        if PMax==PMin
            PMin=PMin-realmin;
        end
        PositiveColorSegment = ceil(50000*(PMax-PMin)/(PMax-0)/ColorLen);
        for iColor=ColorLen:-1:1
            Segment=PositiveColorSegment;
            Begin=100000-(ColorLen-iColor+1)*PositiveColorSegment+1;
            if Begin < 1
                Segment=Segment-(1-Begin);
                Begin=1;
            end
            End=100000-(ColorLen-iColor)*PositiveColorSegment;
            if End > 100000
                Segment=Segment-(End-100000);
                End=100000;
            end
            NewColorMap(Begin:End,:) = repmat(OriginalColorMap(iColor,:),[Segment 1]);
        end
    else
        NegativeColorSegment = ceil(50000*(NMin-NMax)/(0-NMax)/(ColorLen/2));
        if ~isnan(NegativeColorSegment)
            for iColor=1:fix(ColorLen/2)
                Segment=NegativeColorSegment;
                Begin=(iColor-1)*NegativeColorSegment+1;
                if Begin < 1
                    Segment=Segment-(1-Begin);
                    Begin=1;
                end
                End=(iColor)*NegativeColorSegment;
                if End > 100000
                    Segment=Segment-(End-100000);
                    End=100000;
                end
                NewColorMap(Begin:End,:) = repmat(OriginalColorMap(iColor,:),[Segment 1]);
            end
        end
        
        if PMax==PMin
            PMin=PMin-realmin;
        end
        PositiveColorSegment = ceil(50000*(PMax-PMin)/(PMax-0)/(ColorLen/2));
        for iColor=ColorLen:-1:ceil(ColorLen/2+1)
            Segment=PositiveColorSegment;
            Begin=100000-(ColorLen-iColor+1)*PositiveColorSegment+1;
            if Begin < 1
                Segment=Segment-(1-Begin);
                Begin=1;
            end
            End=100000-(ColorLen-iColor)*PositiveColorSegment;
            if End > 100000
                Segment=Segment-(End-100000);
                End=100000;
            end
            NewColorMap(Begin:End,:) = repmat(OriginalColorMap(iColor,:),[Segment 1]);
        end
    end

end

if NMin==NMax && NMax==0
    Ticks=[1, floor(100000*(PMin./PMax))+1, 100000];
    TickLabel={'0', sprintf('%g', PMin), sprintf('%g', PMax)};    
elseif PMin==PMax && PMax==0
    Ticks=[1, floor(100000*(1-abs(NMin)./abs(NMax)))+1, 100000];
    TickLabel={sprintf('%g', NMax), sprintf('%g', NMin), '0'}; 
else
    Ticks=[1, floor(50000*(1-abs(NMin)./abs(NMax)))+1, 50001, floor(50000*(1+(PMin./PMax)))+1, 100000];
    TickLabel={sprintf('%g', NMax), sprintf('%g', NMin), '0', sprintf('%g', PMin), sprintf('%g', PMax)};
end
[~, Ia]=unique(Ticks);
Ticks=Ticks(Ia);
TickLabel=TickLabel(Ia);

function ExitCode=AddLabel(AxesObj, VarArgIn)%���Label��
ExitCode=1;%�˳�ָ�Ĭ��Ϊ1
AxesHandle=getappdata(AxesObj, 'AxesHandle');%��ȡ��ǰ����
FigObj=ancestor(AxesObj, 'figure');%��ȡ��ǰͼ��
SurfOpt=AxesHandle.SurfOpt;%��ǰ��Ƥ������

if nargin<1+1%��û������ļ�
    error('Label File Needed!')%����
end
LabelFile=VarArgIn{1};%��ȡLabel�ļ�
V=gifti(LabelFile);%��ȡ

UnderNumV=size(AxesHandle.UnderSurf.StructData.vertices, 1);%��ȡ��ǰƤ�������
LabelNumV=size(V.cdata, 1);%�����Label�ļ����ݵ�
if LabelNumV~=UnderNumV
    errordlg('Number of Vertices Not Match Between Selected Label and Underlay!');%�����߲���ȣ��򱨴�
    return
end

LabelV=V.cdata;%Label���ȫ������
LabelU=unique(LabelV);%�������ظ�������
if isfield(V, 'labels')%�������Label�ṹ
    LabelColor=V.labels.rgba(:, 1:3);%��ǩ��ɫ
else
    errordlg('Invalid Label File, No labels Structure!');%û��Labelʱ����˵������Label�ļ�
    ExitCode=1;
    return
end
if nargin<2+1%����IsVisible��Ϣ����ã�û����Ĭ��ѡ��
    IsVisible='On';
else
    IsVisible=VarArgIn{2};
end

if nargin<3+1%�Ƿ���ʾ0��Ϣ
    IsShowZeros=0;
else
    IsShowZeros=VarArgIn{3};
end

% Generate Colormap and Alpha
if IsShowZeros
    TmpLabelColor=LabelColor;%��ʾ��ǩ��ɫ
else
    TmpLabelColor=LabelColor;
    TmpLabelColor(1, :)=AxesHandle.UnderSurf.FaceColor;%��ʾ��ǩɫ��0�滻Ϊ��ɫ
end
AdjustVC=squeeze(ind2rgb(LabelV, TmpLabelColor));%���ݽṹ��̫��⣿��
Alpha=1;
AdjustVA=Alpha*ones(size(LabelV));%͸���Ȳ�����


% LabelOpt ����Label�����
LabelOpt.LabelFile=LabelFile;
LabelOpt.LabelColor=LabelColor;
LabelOpt.LabelName=V.labels.name;
LabelOpt.LabelV=LabelV;
LabelOpt.LabelU=LabelU;
LabelOpt.IsShowZeros=IsShowZeros;
LabelOpt.IsVisible=IsVisible;
LabelOpt.Alpha=Alpha;

if isfield(AxesHandle, 'LabelSurf') && numel(AxesHandle.LabelSurf)>0 %���Ѻ���Label������
    Num=numel(AxesHandle.LabelSurf);%Label������
    LabelOpt.Obj=AxesHandle.LabelSurf(1).Obj;%��ȡ��һ����������
    set(LabelOpt.Obj,...%�����⼸���ֵ�ѡ��
        'FaceVertexCData',  AdjustVC,... %��̫��⣿����
        'FaceVertexAlpha',  AdjustVA,...
        'Visible',          IsVisible);
    
    AxesHandle.LabelSurf(Num+1, 1)=LabelOpt; %�����������µ�һ��
else%����û��Label��Ĭ����������
    PatchObj=patch(AxesHandle.UnderSurf.StructData,...
        'FaceColor',        'flat',...
        'FaceAlpha',        'flat',...
        'EdgeColor',        'none',...
        'FaceVertexCData',  AdjustVC,...
        'CDataMapping',     'direct',...
        'FaceVertexAlpha',  AdjustVA,...
        'AlphaDataMapping', 'none',...
        'FaceLighting',     SurfOpt.FaceLighting,...
        'SpecularStrength', SurfOpt.SpecularStrength,...
        'AmbientStrength',  SurfOpt.AmbientStrength,...
        'DiffuseStrength',  SurfOpt.DiffuseStrength,...
        'SpecularExponent', SurfOpt.SpecularExponent,...
        'Clipping',         SurfOpt.Clipping,...
        'Visible',          IsVisible,...
        'Tag',              'Label',...
        'Parent',           AxesObj);
    material(FigObj, SurfOpt.Material);
    LabelOpt.Obj=PatchObj;
    AxesHandle.LabelSurf=LabelOpt;%��Label����������LabelSurf�ṹ
end

setappdata(AxesObj, 'AxesHandle', AxesHandle);%��������
ResortSurf(AxesObj)%�������˺�����δ���
ExitCode=0;%���ز�����Ϊ0��������ȫ��⣿

function SetLabel(AxesObj, LabelInd)%����Label���������и���ͼ��Ȳ�������
if nargin<2
    error('Invalid Input: LabelInd');%������С��2������
end

AxesHandle=getappdata(AxesObj, 'AxesHandle');%��ȡ��ǰ����

try
    LabelSurf=AxesHandle.LabelSurf(LabelInd, 1);%��ȡ��ǰ��Label��
catch
    error('Invalid Label Index');%Label��ָ������ʱ����
end
%��ȡ��Ӧ�������
LabelV=LabelSurf.LabelV;
LabelColor=LabelSurf.LabelColor;
IsShowZeros=LabelSurf.IsShowZeros;
IsVisible=LabelSurf.IsVisible;
Alpha=LabelSurf.Alpha;

% Generate Colormap and Alpha
if IsShowZeros
    TmpLabelColor=LabelColor;
else
    TmpLabelColor=LabelColor;
    TmpLabelColor(1, :)=AxesHandle.UnderSurf.FaceColor;
end
AdjustVC=squeeze(ind2rgb(LabelV, TmpLabelColor));
AdjustVA=Alpha*ones(size(LabelV));
set(LabelSurf.Obj,...
    'FaceVertexCData',  AdjustVC,...
    'FaceVertexAlpha',  AdjustVA,...
    'Visible',          IsVisible);

function SetLabelAlpha(AxesObj, LabelInd, Alpha)%����Label����ʾ��͸����
if nargin<2
    error('Invalid Input: LabelInd, Alpha');%���������С��2ʱ����
end

AxesHandle=getappdata(AxesObj, 'AxesHandle');%��ȡ��ǰ����

try
    LabelSurf=AxesHandle.LabelSurf(LabelInd, 1);%��ȡ��ǰ��Label��
catch
    error('Invalid Label Index');%��ָ������ʱ����
end
LabelSurf.Alpha=Alpha;%����͸����ֵ
AxesHandle.LabelSurf(LabelInd, 1)=LabelSurf;%����ǰ��LabelSurf�ṹ�����ϼ��ṹ
setappdata(AxesObj, 'AxesHandle', AxesHandle);%��������
SetLabel(AxesObj, LabelInd);%����Label��

function Alpha=GetLabelAlpha(AxesObj, LabelInd)
if nargin<2
    error('Invalid Input: LabelInd');
end

AxesHandle=getappdata(AxesObj, 'AxesHandle');

try
    LabelSurf=AxesHandle.LabelSurf(LabelInd, 1);
catch
    error('Invalid Label Index');
end
Alpha=LabelSurf.Alpha;

function RemoveLabel(AxesObj, LabelInd)%�Ƴ�Label�㺯��
if nargin<2
    error('Invalid Input: LabelInd');%������С��2������
end

AxesHandle=getappdata(AxesObj, 'AxesHandle');%��ȡ��ǰ����

try
    LabelSurf=AxesHandle.LabelSurf(LabelInd, 1);
catch
    error('Invalid Label Index');
end

if numel(AxesHandle.LabelSurf)==1%����ǰֻ��1��Label��
    delete(LabelSurf.Obj);%ɾ��LabelSurf.Obj�ӽṹ
end
AxesHandle.LabelSurf(LabelInd)=[];%����ǰLabel������ȫ�����
setappdata(AxesObj, 'AxesHandle', AxesHandle);%��������
if numel(AxesHandle.LabelSurf)>=1%����ʱ����1������Label��ѡ��
    SetLabel(AxesObj, 1);    %����Ϊ��һ��Label
end

function LabelFiles=GetLabelFiles(AxesObj)%��ȡLabel�ļ�
AxesHandle=getappdata(AxesObj, 'AxesHandle');%��ȡ��ǰ��������
LabelFiles={AxesHandle.LabelSurf.LabelFile}';%��Ӧ��Label�ļ�

function SurfOpt=DefaultSurfOpt %Ĭ������
SurfOpt.FaceLighting='phong';
SurfOpt.SpecularStrength=0.7;
SurfOpt.AmbientStrength=0.1;
SurfOpt.DiffuseStrength=0.7;
SurfOpt.SpecularExponent=10;
SurfOpt.Clipping='off';
SurfOpt.Material='dull';
SurfOpt.LightOrient='headlight';
SurfOpt.ViewPoint=[-90, 0];
SurfOpt.ViewPointCustomFlag=0;
SurfOpt.Renderer='OpenGL';
SurfOpt.BackGroundColor=[1, 1, 1];

function ResortSurf(AxesObj)
AxesHandle=getappdata(AxesObj, 'AxesHandle');%��ȡ��ǰ����
ChildObj=get(AxesObj, 'Children');%��������ӽṹ
OverlayObjInd=arrayfun(@(obj) strcmpi(get(obj, 'Tag'), 'Overlay'), ChildObj);%�������Ovelayָ����
if any(OverlayObjInd)%��������1��Overlay
    OverlayObj={AxesHandle.OverlaySurf.Obj}';%ȫ��Overlay��Obj
    X=find(OverlayObjInd);%=OverlayObjInd??? ���ݽṹ��̫�˽�
    for i=1:numel(X)
        ChildObj(X(i))=OverlayObj{i};%��̫������Ĳ���
    end
end
%�Դ���ChildObj�Ľṹ��̫�˽�
UnderSurfObjInd=arrayfun(@(obj) strcmpi(get(obj, 'Tag'), 'UnderSurf'), ChildObj);
LabelObjInd=arrayfun(@(obj) strcmpi(get(obj, 'Tag'), 'Label'), ChildObj);
BorderObjInd=arrayfun(@(obj) strcmpi(get(obj, 'Tag'), 'Border'), ChildObj);
OtherObjInd=~(UnderSurfObjInd | OverlayObjInd | LabelObjInd | BorderObjInd);

NewChildObj=[ChildObj(BorderObjInd);ChildObj(OverlayObjInd);ChildObj(LabelObjInd);...
    ChildObj(OtherObjInd);ChildObj(UnderSurfObjInd)];
set(AxesObj, 'Children', NewChildObj);%�����ӽṹ

function Txt=GetPosInfo(~, event_obj, AxesObj)%��ȡλ����Ϣ����
Pos=get(event_obj, 'Position');%��ù�괦����

AxesHandle=getappdata(AxesObj, 'AxesHandle');
Coord=AxesHandle.UnderSurf.StructData.vertices;
VInd=find(Coord(:,1)==Pos(1) & Coord(:,2)==Pos(2) & Coord(:,3)==Pos(3));%�ҵ������Ӧ��Coordָ��
Curv=AxesHandle.UnderSurf.Curv(VInd);

Txt={...
    ['X: ',     num2str(Pos(1))],...
    ['Y: ',     num2str(Pos(2))],...
    ['Z: ',     num2str(Pos(3))],...
    ['Index: ', num2str(VInd)],...
    ['Curv: ',  num2str(Curv)]...
    };%��ʾ����Ϣ
if isfield(AxesHandle, 'OverlaySurf')%�����Overlay�㣿
    OverlayFiles=AxesHandle.Fcn.GetOverlayFiles();%��ȡOverlay�ļ���Ϣ
    [~, NameList, ExtList]=cellfun(@(f) fileparts(f), OverlayFiles, 'UniformOutput', false);%������
    for i=1:numel(NameList)%���ж���ļ���
        OverlayTxt=sprintf('Overlay %s: %g', ...
            NameList{i}, AxesHandle.OverlaySurf(i).Vertex(VInd));%������ʾ����Ϣ
        Txt=[Txt, {OverlayTxt}];%�ӵ�����ַ���
    end
end

if isfield(AxesHandle, 'LabelSurf')%�����Label�㣿
    LabelFiles=AxesHandle.Fcn.GetLabelFiles();%��ȡLabel�ļ���Ϣ
    [~, NameList, ExtList]=cellfun(@(f) fileparts(f), LabelFiles, 'UniformOutput', false);%������ͬ��
    for i=1:numel(NameList)%���ж���ļ���ͬ��
        LabelKey=AxesHandle.LabelSurf(i).LabelV(VInd);%���ҵ���ӦLabelֵ��
        LabelU=AxesHandle.LabelSurf(i).LabelU;
        
        Ind= LabelU==LabelKey;%����
        LabelName=AxesHandle.LabelSurf(i).LabelName{Ind};%���� ������LABEL�Ľṹû̫�㶮
        LabelTxt=sprintf('Label %s: %g (%s)', ...
            NameList{i}, LabelKey, LabelName);%������ʾ����Ϣ��ͬ��
        Txt=[Txt, {LabelTxt}];%�ӵ�����ַ��У�ͬ��
    end
end

function NewFig=SaveMontage(AxesObj, VarArgIn)
AxesHandle=getappdata(AxesObj, 'AxesHandle');%��ȡ��ǰ����
ChildObj=get(AxesObj, 'Children');%ΪAxes������

% Montage Style
if numel(VarArgIn)==1 %��ֻ��һ����������Ĭ��Ϊ����
    LR_Flag='L';
else
    LR_Flag=VarArgIn{1};%����������������
end

MontageOpt=[];
MontageOpt.FigPos=[0, 0, 600, 800];
MontageOpt.AxesPos{1}=[0, 0.5, 1, 0.5];
MontageOpt.AxesPos{2}=[0,   0, 1, 0.5];
MontageOpt.VP{1}=[-90, 0];
MontageOpt.VP{2}=[ 90, 0];
if strcmpi(LR_Flag, 'L')%�����ӽ�
    MontageOpt.VP{1}=[-90, 0];
    MontageOpt.VP{2}=[ 90, 0];
elseif strcmpi(LR_Flag, 'R')%�����ӽ�
    MontageOpt.VP{1}=[ 90, 0];
    MontageOpt.VP{2}=[-90, 0];
end

% New Figure
NewFig=figure('Position', MontageOpt.FigPos, ...
    'Units', 'normalized', 'Color', [1, 1, 1]);%�����´���
set(NewFig, 'Renderer', AxesHandle.SurfOpt.Renderer);%����ͼRenderer��Ϣ����
if numel(VarArgIn)>1 && ~isempty(VarArgIn{2}) % OutFile �����뺬��Ҫ������ļ�����
    OutFile=VarArgIn{2};%��ȡ����ļ�����

end
NewAxes=cell(2, 1);
for i=1:2%�ֱ������ͼ��
    OneAxes=axes('Parent', NewFig, 'Position', MontageOpt.AxesPos{i});
    axis(OneAxes, 'tight');%ʹ���곤�Ƚ������ݳ���
    axis(OneAxes, 'vis3d');%��3D��ͼ���ܣ�
    axis(OneAxes, 'off');%�ر���������ʾ
    for j=1:numel(ChildObj)%���������ݽṹ������
        ChildTag=get(ChildObj(j), 'Tag');%��ȡ�����ǩ
        if ~strcmpi(ChildTag, '')
            copyobj(ChildObj(j), OneAxes);%������
        end
    end
%    ChangeView(AxesObj)
    view(OneAxes, MontageOpt.VP{i});%�����ӽ�
    Light=camlight(AxesHandle.SurfOpt.LightOrient);%����3D���߽Ƕ�
    set(Light, 'Parent', OneAxes);
    set(Light, 'style', 'infinite');
    material(OneAxes, AxesHandle.SurfOpt.Material);%������ʾ����
    NewAxes{i}=OneAxes;%������NewAxes�У���֪��������õ���

   DisplayTexture(AxesObj);
end
    DataCursor=datacursormode;%�������������ʾ����
    set(DataCursor, 'UpdateFcn', @(empt, event_obj) GetPosInfo(empt, event_obj, AxesObj));%��ΪGetPosInfo����-1575
%     AxesHandle.DataCursor=DataCursor;

function Opt=GetDataCursorPos(AxesObj)
DataCursorObj=GetDataCursorObj(AxesObj);
CursorInfo=DataCursorObj.getCursorInfo();
if isempty(CursorInfo)
    Opt.Pos=[];
else
    Opt.Pos=CursorInfo.Position;
end

function MoveDataCursor(AxesObj, Pos)
AxesHandle=getappdata(AxesObj, 'AxesHandle');
DataCursorObj=GetDataCursorObj(AxesObj);

UnderSurf=AxesHandle.UnderSurf;
set(DataCursorObj, 'Enable', 'On');
DataCursorObj.removeAllDataCursors();
DataTipObj=DataCursorObj.createDatatip(UnderSurf.Obj);
set(DataTipObj, 'Position', Pos);
% 
% function ChangeView(AxesObj)
% AxesHandle=getappdata(AxesObj, 'AxesHandle');
% ViewPoint=AxesHandle.SurfOpt.ViewPoint;
% new_ViewPoint=ViewPoint;
% AxesHandle.SurfOpt.ViewPoint=new_ViewPoint;
% view(AxesObj, new_ViewPoint);
% setappdata(AxesObj, 'AxesHandle', AxesHandle);
