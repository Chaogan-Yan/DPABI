function y_Call_DPABISurf_VIEW(SurfUnderlay,SurfOverlay,Flag_LR, N_Min,P_Min,Surf_Mask,Surf_Mask_Rule,ColorMap,N_Max,P_Max)
%This is a function which is used to display the result by DPABISurf_VIEW.
%FORMAT y_Call_DPABISurf_VIEW(SurfUnderlay,SurfOverlay,Flag_LR, N_Min,P_Min,Surf_Mask,Surf_Mask_Rule,ColorMap,N_Max,P_Max)
%Input:
%     SurfUnderlay  - Underlay surface file
%     SurfOverlay   - Overlay surface file
%     Flag_LR       - Hemisphere, should be 'L' or 'R'
%     N_Min         - The negative minimum (minimum in absolute value). Could be the negative threshold
%                   - default: calculate from Brain
%     P_Min         - The positive minimum. Could be the positive threshold
%                   - default: calculate from Brain
%     Surf_Mask     - The mask file for surface. Can also be the TFCE p map.
%     Surf_Mask_Rule  - The rule of appying mask file. Can be '' or '<0.025' (for TFCE p map).
%     ColorMap      - The color map. Should be m by 3 color array.
%     N_Max         - The negative maximum (maximum in absolute value)
%                   - default: calculate from Brain
%     P_Max         - The maximum
%                   - default: calculate from Brain
%___________________________________________________________________________
% Written by YAN Chao-Gan 20200227. Based on c_View2SurfView.m
% The R-fMRI Lab, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% International Big-Data Center for Depression Research, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com

if ~exist('Flag_LR','var')
    Flag_LR='L';
end

if ~exist('Surf_Mask','var')
    Surf_Mask=[];
end

if ~exist('Surf_Mask_Rule','var')
    Surf_Mask_Rule=[];
end

if ~exist('ColorMap','var')
    ColorMap = y_AFNI_ColorMap(12);
end

if ~exist('P_Max','var')
    BrainData=y_ReadAll(SurfOverlay);
    P_Max = max(BrainData(:));
    
    if ~exist('N_Max','var')
        N_Max = min(BrainData(:));
    end
    if ~exist('P_Min','var')
        P_Min = min(BrainData(BrainData>0));
    end
    if ~exist('N_Min','var')
        N_Min = max(BrainData(BrainData<0));
    end
end


View{1,1}=DPABISurf_VIEW(SurfUnderlay,Flag_LR);

Underlay_Path=findall(0, 'Tag', 'UnderlayEty');
Overlay_Color=findall(0,'Tag','OverlayColorMenu');
Thrd_Pos=findall(0, 'Tag', 'OverlayThresPosSlider');
Thrd_Neg=findall(0, 'Tag', 'OverlayThresNegSlider');
Mask_Button=findall(0, 'Tag', 'OverlayFweOptBtn');
PMin=findall(0,'Tag','OverlayPMinEty');
PMax=findall(0,'Tag','OverlayPMaxEty');
NMin=findall(0,'Tag','OverlayNMinEty');
NMax=findall(0,'Tag','OverlayNMaxEty');
Picture=findall(0,'Tag','DPABISurf_VIEW_AxeObj');
VP_Menu=findall(0,'Tag','ViewPointMenu');
CData=cell(2,2);

handles=guidata(View{1,1});
Fcn=handles.Fcn;
set(Underlay_Path(1,1), 'String', SurfUnderlay);
Original_Path=get(Underlay_Path(1,1),'String');
set(Underlay_Path(1,1),'String',SurfOverlay);
eventdata=[];
DPABISurf_VIEW('UnderlayEty_Callback',Underlay_Path(1,1),eventdata,guidata(Underlay_Path(1,1)));
set(Underlay_Path(1,1),'String',Original_Path);

% Deal with mask
if ~isempty(Surf_Mask)
    if ~isempty(Surf_Mask_Rule) %Apply rule. e.g., '<0.025'
        [Surf_Mask_Data,~,~,GHeader] = y_ReadAll(Surf_Mask);
        eval(['Surf_Mask_Data=Surf_Mask_Data',Surf_Mask_Rule,';']);
        [pathstr, name, ext] = fileparts(Surf_Mask);
        Surf_Mask = fullfile(pathstr,[name,'_Mask.gii']);
        y_Write(Surf_Mask_Data,GHeader,Surf_Mask);
    end
    set(Mask_Button(1,1),'Value',3);
    DPABISurf_VIEW('OverlayFweOptBtn_Callback',Mask_Button(1,1),eventdata,guidata(Mask_Button(1,1)),Surf_Mask);
end

handles=guidata(View{1,1});
Fcn=handles.Fcn;
Fcn.SetOverlayColorMap(1,ColorMap,[]);
set(PMax(1,1),'String',P_Max);
DPABISurf_VIEW('OverlayPMaxEty_Callback',PMax(1,1),eventdata,guidata(PMax(1,1)));
set(PMin(1,1),'String',P_Min);
DPABISurf_VIEW('OverlayPMinEty_Callback',PMin(1,1),eventdata,guidata(PMin(1,1)));
set(NMax(1,1),'String',N_Max);
DPABISurf_VIEW('OverlayNMaxEty_Callback',NMax(1,1),eventdata,guidata(NMax(1,1)));
set(NMin(1,1),'String',N_Min);
DPABISurf_VIEW('OverlayNMinEty_Callback',NMin(1,1),eventdata,guidata(NMin(1,1)));
DPABISurf_VIEW('MontageBtn_Callback',1,eventdata,handles);
