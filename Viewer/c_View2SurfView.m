function c_View2SurfView(OriginalName,Surf,Surf_Mask,P_Max,P_Min,N_Max,N_Min,ColorMap,eventdata)
%This is a function which is used to display the result of DPABI_VIEW by DPABISurf_VIEW.
%FORMAT c_View2SurfView(OriginalName,Surf,Surf_Mask,P_Max,P_Min,N_Max,N_Min,ColorMap,eventdata)
%Input:
%     OriginalName  - The Name in DPABI_VEW
%     Surf          - The cell which contains two names of surface files, the fisrt name is the left hemisphere while the second is the right hemisphere.
%     Surf_Mask     - The cell which contains two names of surface mask files, the fisrt name is the left hemisphere while the second is the right hemisphere.
%     P_Max         - The maximum
%                   - default: calculate from BrainVolume
%     P_Min         - The positive minimum. Could be the positive threshold
%                   - default: calculate from BrainVolume
%     N_Max         - The negative maximum (maximum in absolute value)
%                   - default: calculate from BrainVolume
%     N_Min         - The negative minimum (minimum in absolute value). Could be the negative threshold
%                   - default: calculate from BrainVolume
%     ColorMap      - The color map. Should be m by 3 color array.
%     eventdata     - Handle to event object
%___________________________________________________________________________
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% Written by Zhikai Chang 190906.
% Revised by YAN Chao-Gan, 190920.

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

for i=1:2 %Generate the results on DPABISurf_VIEW
    handles=guidata(View{i,1});
    Fcn=handles.Fcn;
    File_Surf=Surf{i,1};
    File_Mask=Surf_Mask{i,1};
    set(Underlay_Path(i,1), 'String', UnderlayFilePath{i,1});
    Original_Path=get(Underlay_Path(i,1),'String');
    set(Underlay_Path(i,1),'String',File_Surf);
    DPABISurf_VIEW('UnderlayEty_Callback',Underlay_Path(i,1),eventdata,guidata(Underlay_Path(i,1)));
    set(Underlay_Path(i,1),'String',Original_Path);
    set(Mask_Button(i,1),'Value',3);
    DPABISurf_VIEW('OverlayFweOptBtn_Callback',Mask_Button(i,1),eventdata,guidata(Mask_Button(i,1)),File_Mask);
    handles=guidata(View{2/i,1});
    Fcn=handles.Fcn;
    Fcn.SetOverlayColorMap(1,ColorMap,[]);
    set(PMax(i,1),'String',P_Max);
    DPABISurf_VIEW('OverlayPMaxEty_Callback',PMax(i,1),eventdata,guidata(PMax(i,1)));
    set(PMin(i,1),'String',P_Min);
    DPABISurf_VIEW('OverlayPMinEty_Callback',PMin(i,1),eventdata,guidata(PMin(i,1)));
    set(NMax(i,1),'String',N_Max);
    DPABISurf_VIEW('OverlayNMaxEty_Callback',NMax(i,1),eventdata,guidata(NMax(i,1)));
    set(NMin(i,1),'String',N_Min);
    DPABISurf_VIEW('OverlayNMinEty_Callback',NMin(i,1),eventdata,guidata(NMin(i,1)));
    DPABISurf_VIEW('MontageBtn_Callback',1,eventdata,handles);
end
try
    name=split(OriginalName,'.');
catch
    name=c_split_before2016(OriginalName,'.');
end
Really_Name=strcat(name{1,1},'.tiff');
h=figure;
montage({[OriginalName(1:end-4),'_Surf_lh_Montage.jpg'],[OriginalName(1:end-4),'_Surf_rh_Montage.jpg']});
print(h,'-r300','-dtiff','-noui',Really_Name);


function [outstr] = c_split_before2016(strA,strB)

m=strfind(strA,strB);
f=1;
C=cell(1,1);
for i =1:length(m)+1
    
    if i==length(m)+1
        C{i,1}=strA(f:length(strA));
    else
        C{i,1}=strA(f:m(i)-1);
        f=m(i)+1;
    end
end
outstr=C;

