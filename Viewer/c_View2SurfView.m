function c_View2SurfView(OriginalName,Surf,Surf_Mask,Thrd,Max,Min,Raw_Max,Raw_Min,eventdata)
%This is a function which is used to display the result of DPABI_VIEW by DPABISurf_VIEW.
%FORMAT ch_view2Surfview(Surf,Thrd,Max,Min,Raw_Max,Raw_Min,eventdata)
%Input:
%  Surf - The cell which contains two names of surface files, the fisrt name is the left hemisphere while the second is the right hemisphere.
%  Thrd - The threshold of the result
%  Max - The maximum of the result data
%  Min - The minimum of the result data
%  Raw_Max - The maximum of the raw data
%  Raw_Min - The minimum of the raw data
%  eventdata - Handle to event object
%___________________________________________________________________________
% Written by Zhikai Chang 190906.
DPABISurfPath=fileparts(which('DPABISurf.m'));
SurfTpmPath=fullfile(DPABISurfPath, 'SurfTemplates');
View=cell(2,1);
UnderlayFilePath=cell(2,1);
for i=1:2
    if i==1
        UnderlayFilePath{i,1}=fullfile(SurfTpmPath, ...
            'fsaverage_rh_inflated.surf.gii');
        Flag='R';
    elseif i==2
        UnderlayFilePath{i,1}=fullfile(SurfTpmPath, ...
            'fsaverage_lh_inflated.surf.gii');
        Flag='L';
    end
    View{i,1}=DPABISurf_VIEW(UnderlayFilePath{i,1});
end
% View_1=DPABISurf_VIEW;
% View_2=DPABISurf_VIEW;
%looking for the widgets of DPABISurf_VIEW

Underlay_Path=findall(0, 'Tag', 'UnderlayEty');
% Underlay_Menu=findall(0, 'Tag', 'UnderlayMenu');
% Button_Set=findall(0, 'Tag', 'UnderlayBtn');
% Hemi_Menu=findall(0, 'Tag', 'HemiMenu');
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

for i=1:2 %Generate the results on DPABISurf_VIEW
    handles=guidata(View{i,1});
    Fcn=handles.Fcn;
    File_Surf=Surf{i,1};
    File_Mask=Surf_Mask{i,1};
    set(Underlay_Path(i,1), 'String', UnderlayFilePath{i,1});
    %     set(Underlay_Menu(i,1), 'Value', 2);
    %     set(Hemi_Menu(i,1), 'Value', i);
    %     set(Button_Set(i,1),'Enable','On');
    %
    %     DPABISurf_VIEW('UnderlayMenu_Callback',Underlay_Menu(i,1),eventdata,guidata(Underlay_Menu(i,1)));
    %     DPABISurf_VIEW('HemiMenu_Callback',Hemi_Menu(i,1),eventdata,guidata(Hemi_Menu(i,1)));
    %     DPABISurf_VIEW('UnderlayBtn_Callback',Button_Set(i,1),eventdata,guidata(Button_Set(i,1)));
    %     handles=guidata(View{i,1});
    %     Fcn=handles.Fcn;
    Original_Path=get(Underlay_Path(i,1),'String');
    set(Underlay_Path(i,1),'String',File_Surf);
    DPABISurf_VIEW('UnderlayEty_Callback',Underlay_Path(i,1),eventdata,guidata(Underlay_Path(i,1)));
    set(Underlay_Path(i,1),'String',Original_Path);
    set(Overlay_Color(i,1),'Value',12);
    DPABISurf_VIEW('OverlayColorMenu_Callback',Overlay_Color(i,1),eventdata,guidata(Overlay_Color(i,1)));
    set(Mask_Button(i,1),'Value',3);
    DPABISurf_VIEW('OverlayFweOptBtn_Callback',Mask_Button(i,1),eventdata,guidata(Mask_Button(i,1)),File_Mask);
    
    if Max>0
        P_Max=get(PMax(i,1),'String');
        P_Max=str2double(P_Max);
        if P_Max>Thrd
            set(PMin(i,1),'String',Thrd);
        else
            set(PMin(i,1),'String',P_Max);
        end
        DPABISurf_VIEW('OverlayPMinEty_Callback',PMin(i,1),eventdata,guidata(PMin(i,1)));
    else
        if Raw_Max>0
            P_Max=get(PMax(i,1),'String');
            P_Max=str2double(P_Max);
            if P_Max>Thrd
                set(PMin(i,1),'String',Thrd);
            else
                set(PMin(i,1),'String',P_Max);
            end
            DPABISurf_VIEW('OverlayPMinEty_Callback',PMin(i,1),eventdata,guidata(PMin(i,1)));
        end
    end
    if Min<0
        N_Max=get(NMax(i,1),'String');
        N_Max=str2double(N_Max);
        if N_Max<-Thrd
            set(NMin(i,1),'String',-Thrd);
        else
            set(NMin(i,1),'String',N_Max);
        end
        DPABISurf_VIEW('OverlayNMinEty_Callback',NMin(i,1),eventdata,guidata(NMin(i,1)));
    else
        
        if Raw_Min<0
            N_Max=get(NMax(i,1),'String');
            N_Max=str2double(N_Max);
            if N_Max<-Thrd
                set(NMin(i,1),'String',-Thrd);
            else
                set(NMin(i,1),'String',N_Max);
            end
            DPABISurf_VIEW('OverlayNMinEty_Callback',NMin(i,1),eventdata,guidata(NMin(i,1)));
        end
    end
    f = getframe(Picture(i,1));
    Size=size(f.cdata);
    CData{i,1}=f.cdata(:,ceil(0.12*Size(2)):ceil(0.88*Size(2)),:);
    set(VP_Menu(i,1),'Value',3);
    DPABISurf_VIEW('ViewPointMenu_Callback',VP_Menu(i,1),eventdata,guidata(VP_Menu(i,1)));
    f = getframe(Picture(i,1));
    Size=size(f.cdata);
    CData{i,2}=f.cdata(:,ceil(0.12*Size(2)):ceil(0.88*Size(2)),:);
    set(VP_Menu(i,1),'Value',2);
    DPABISurf_VIEW('ViewPointMenu_Callback',VP_Menu(i,1),eventdata,guidata(VP_Menu(i,1)));
end
name=split(OriginalName,'.');

Really_Name=strcat(name{1,1},'.jpg');
cdata=cell2mat(CData);
imwrite(cdata,Really_Name);
for i=1:2 %adjust the colorbar
    handles=guidata(View{i,1});
    Fcn=handles.Fcn;
    Fcn.UpdateOverlay(1);
    
end


