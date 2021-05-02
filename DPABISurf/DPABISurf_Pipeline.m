function varargout = DPABISurf_Pipeline(varargin)
% DPABISURF_PIPELINE MATLAB code for DPABISurf_Pipeline.fig
%      DPABISURF_PIPELINE, by itself, creates a new DPABISURF_PIPELINE or raises the existing
%      singleton*.
%
%      H = DPABISURF_PIPELINE returns the handle to a new DPABISURF_PIPELINE or the handle to
%      the existing singleton*.
%
%      DPABISURF_PIPELINE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPABISURF_PIPELINE.M with the given input arguments.
%
%      DPABISURF_PIPELINE('Property','Value',...) creates a new DPABISURF_PIPELINE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPABISurf_Pipeline_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPABISurf_Pipeline_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPABISurf_Pipeline

% Last Modified by GUIDE v2.5 25-Feb-2020 16:52:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPABISurf_Pipeline_OpeningFcn, ...
                   'gui_OutputFcn',  @DPABISurf_Pipeline_OutputFcn, ...
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


% --- Executes just before DPABISurf_Pipeline is made visible.
function DPABISurf_Pipeline_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPABISurf_Pipeline (see VARARGIN)


Release='V1.6_210501';
handles.Release = Release; % Will be used in mat file version checking (e.g., in function SetLoadedData)

if ispc
    UserName =getenv('USERNAME');
else
    UserName =getenv('USER');
end
Datetime=fix(clock);
fprintf('Welcome: %s, %.4d-%.2d-%.2d %.2d:%.2d \n', UserName,Datetime(1),Datetime(2),Datetime(3),Datetime(4),Datetime(5));
fprintf('DPABISurf: A Surface-Based Resting-State fMRI Data Analysis Toolbox. \nRelease = %s\n',Release);
fprintf('Copyright(c) 2019; GNU GENERAL PUBLIC LICENSE\n');
fprintf('Institute of Psychology, Chinese Academy of Sciences, 16 Lincui Road, Chaoyang District, Beijing 100101, China; ');
fprintf('Mail to Initiator:  <a href="ycg.yan@gmail.com">YAN Chao-Gan</a>\nProgrammers: YAN Chao-Gan; WANG Xin-Di; LU Bin\n<a href="http://rfmri.org/dpabi">http://rfmri.org/dpabi</a>\n');
fprintf('-----------------------------------------------------------\n');
fprintf('Citing Information:\nDPABISurf is a surface-based resting-state fMRI data analysis toolbox evolved from DPABI/DPARSF, as easy-to-use as DPABI/DPARSF. DPABISurf is based on fMRIPrep 20.2.1 (Esteban et al., 2018) (RRID:SCR_016216), and based on FreeSurfer 6.0.1 (Dale et al., 1999) (RRID:SCR_001847), ANTs 2.3.3 (Avants et al., 2008) (RRID:SCR_004757), FSL 5.0.9 (Jenkinson et al., 2002) (RRID:SCR_002823), AFNI 20160207 (Cox, 1996) (RRID:SCR_005927), SPM12 (Ashburner, 2012) (RRID:SCR_007037), dcm2niix (Li et al., 2016) (RRID:SCR_014099), PALM alpha115 (Winkler et al., 2016), GNU Parallel (Tange, 2011), MATLAB (The MathWorks Inc., Natick, MA, US) (RRID:SCR_001622), Docker (https://docker.com) (RRID:SCR_016445), and DPABI V5.1 (Yan et al., 2016) (RRID:SCR_010501).\n');



%%%%%%%%%%%%%%%%%%%%%%%Predefine Cfg%%%%%%%%%%%%%%%%%%%%%%%%
Path = which('dpabi');
[filepath,name,ext] = fileparts(Path);
handles.Cfg.DPABIPath = filepath;

handles.Cfg.DPABISurfVersion=Release;
handles.Cfg.WorkingDir=pwd; 
handles.Cfg.SubjectID={};  
handles.Cfg.TR=0;
handles.Cfg.TimePoints=0;

handles.Cfg.IsNeedConvertFunDCM2IMG=1;
handles.Cfg.IsNeedConvertT1DCM2IMG=1;
handles.Cfg.IsRemoveFirstTimePoints=1; %BinAdd 
handles.Cfg.RemoveFirstTimePoints=10;
handles.Cfg.IsLowMem = 0;

handles.Cfg.IsConvert2BIDS=1;
handles.Cfg.Isfmriprep=1;
handles.Cfg.Normalize.VoxelSize='2mm'; %or 'native' or '1mm 
handles.Cfg.IsSliceTiming=1;
handles.Cfg.SliceTiming.SliceNumber=33;
handles.Cfg.SliceTiming.SliceOrder=[1:2:33,2:2:32];
handles.Cfg.SliceTiming.ReferenceSlice=33;
handles.Cfg.IsICA_AROMA=0;
handles.Cfg.IsOrganizefmriprepResults=1;
handles.Cfg.IsWarpMasksIntoIndividualSpace=0; %No UI Control

handles.Cfg.MaskFileSurfLH=fullfile(handles.Cfg.DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_lh_cortex.label.gii'); 
handles.Cfg.MaskFileSurfRH=fullfile(handles.Cfg.DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_rh_cortex.label.gii'); 
handles.Cfg.MaskFileVolu=fullfile(handles.Cfg.DPABIPath, 'Templates','BrainMask_05_91x109x91.img'); 

handles.Cfg.IsCovremove=1;
handles.Cfg.Covremove.Timing='AfterNormalize';  %No UI Control
handles.Cfg.Covremove.PolynomialTrend=1;
handles.Cfg.Covremove.HeadMotion=4; 
handles.Cfg.Covremove.IsHeadMotionScrubbingRegressors=0;
handles.Cfg.Covremove.HeadMotionScrubbingRegressors.FDType='FD_Power';
handles.Cfg.Covremove.HeadMotionScrubbingRegressors.FDThreshold=0.5;
handles.Cfg.Covremove.HeadMotionScrubbingRegressors.PreviousPoints=1;
handles.Cfg.Covremove.HeadMotionScrubbingRegressors.LaterPoints=2;

handles.Cfg.Covremove.WM.IsRemove = 1; % or 0
handles.Cfg.Covremove.WM.Mask = 'SPM'; % or 'Segment'
handles.Cfg.Covremove.WM.MaskThreshold = 0.99;
handles.Cfg.Covremove.WM.Method = 'Mean'; %or 'CompCor'
handles.Cfg.Covremove.WM.CompCorPCNum = 5;
handles.Cfg.Covremove.CSF.IsRemove = 1; % or 0
handles.Cfg.Covremove.CSF.Mask = 'SPM'; % or 'Segment'
handles.Cfg.Covremove.CSF.MaskThreshold = 0.99;
handles.Cfg.Covremove.CSF.Method = 'Mean'; %or 'CompCor'
handles.Cfg.Covremove.CSF.CompCorPCNum = 5;
handles.Cfg.Covremove.WholeBrain.IsRemove = 0; % or 1
handles.Cfg.Covremove.WholeBrain.IsBothWithWithoutGSR = 0; % or 1 %YAN Chao-Gan, 151123
handles.Cfg.Covremove.WholeBrain.Mask = 'SPM'; % or 'AutoMask'
handles.Cfg.Covremove.WholeBrain.Method = 'Mean';

handles.Cfg.Covremove.IsOtherCovariates = 0; % Bin Add

handles.Cfg.Covremove.OtherCovariatesROI = [];
handles.Cfg.Covremove.IsAddMeanBack = 1; 
handles.Cfg.NonAgressiveRegressICAAROMANoise = 0; 

handles.Cfg.IsProcessVolumeSpace=1; %No UI Control

handles.Cfg.IsSmooth=1;
handles.Cfg.Smooth.Timing='OnFunctionalData'; %or 'OnResults' if "Smooth Derivatives" was checked
handles.Cfg.Smooth.FWHMVolu=[6 6 6];
handles.Cfg.Smooth.FWHMSurf=6;

handles.Cfg.IsCalALFF=1;
handles.Cfg.CalALFF.AHighPass_LowCutoff=0.01;
handles.Cfg.CalALFF.ALowPass_HighCutoff=0.08;


handles.Cfg.IsFilter=1;
handles.Cfg.Filter.Timing='AfterNormalize'; %Another option: BeforeNormalize
handles.Cfg.Filter.ALowPass_HighCutoff=0.08;
handles.Cfg.Filter.AHighPass_LowCutoff=0.01;
handles.Cfg.Filter.AAddMeanBack='Yes';

handles.Cfg.IsScrubbing=0;
handles.Cfg.Scrubbing.Timing='AfterPreprocessing';
handles.Cfg.Scrubbing.FDType='FD_Power';
handles.Cfg.Scrubbing.FDThreshold=0.5;
handles.Cfg.Scrubbing.PreviousPoints=1;
handles.Cfg.Scrubbing.LaterPoints=2;
handles.Cfg.Scrubbing.ScrubbingMethod='cut';


handles.Cfg.IsCalReHo=1;
handles.Cfg.SurfFileLH=fullfile(handles.Cfg.DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_lh_white.surf.gii');
handles.Cfg.SurfFileRH=fullfile(handles.Cfg.DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_rh_white.surf.gii');
handles.Cfg.CalReHo.ClusterNVoxel=27;
handles.Cfg.CalReHo.SurfNNeighbor=2;

handles.Cfg.IsCalDegreeCentrality=1; 
handles.Cfg.CalDegreeCentrality.rThreshold=0.25; 

handles.Cfg.IsExtractROISignals=1;
handles.Cfg.CalFC.IsMultipleLabel=1; 
handles.Cfg.CalFC.ROIDefVolu={'VolumeMask.nii'};
handles.Cfg.CalFC.ROIDefSurfLH={'LeftSurfMask.gii'};
handles.Cfg.CalFC.ROIDefSurfRH={'RightSurfMask.gii'};

handles.Cfg.IsCalFC=0;


handles.Cfg.StartingDirName='FunRaw';
handles.Cfg.FunctionalSessionNumber=1;
handles.Cfg.ParallelWorkersNumber=0;


TemplateParameters={'Template Parameters'...
    'Default: Recommended preprocessing and calculating configuration'...
    'Default+ICA_AROMA: Default configuration with ICA-AROMA denoising'...
    'Calculate function connectivity only'...
    'Anatomical processing only'...
    'Blank'};
set(handles.popupmenuTemplate,'String',TemplateParameters);


%Load Default!
load(fullfile(handles.Cfg.DPABIPath, 'DPABISurf', 'Jobmats','Template_Default.mat'))
Cfg.MaskFileSurfLH = fullfile(handles.Cfg.DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_lh_cortex.label.gii');
Cfg.MaskFileSurfRH = fullfile(handles.Cfg.DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_rh_cortex.label.gii');
Cfg.MaskFileVolu = fullfile(handles.Cfg.DPABIPath, 'Templates','BrainMask_05_91x109x91.img');
Cfg.SurfFileLH = fullfile(handles.Cfg.DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_lh_white.surf.gii');
Cfg.SurfFileRH = fullfile(handles.Cfg.DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_rh_white.surf.gii');
Cfg.CalFC.ROIDefSurfLH = {fullfile(handles.Cfg.DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_lh_HCP-MMP1.label.gii');...
    fullfile(handles.Cfg.DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_lh_Schaefer2018_400Parcels_7Networks_order.label.gii')};
Cfg.CalFC.ROIDefSurfRH = {fullfile(handles.Cfg.DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_rh_HCP-MMP1.label.gii');...
    fullfile(handles.Cfg.DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_rh_Schaefer2018_400Parcels_7Networks_order.label.gii')};
Cfg.CalFC.ROIDefVolu = {[handles.Cfg.DPABIPath,filesep,'Templates',filesep,'aal.nii'];...
    [handles.Cfg.DPABIPath,filesep,'Templates',filesep,'HarvardOxford-cort-maxprob-thr25-2mm_YCG.nii'];...
    [handles.Cfg.DPABIPath,filesep,'Templates',filesep,'HarvardOxford-sub-maxprob-thr25-2mm_YCG.nii'];...
    [handles.Cfg.DPABIPath,filesep,'Templates',filesep,'CC200ROI_tcorr05_2level_all.nii'];...
    [handles.Cfg.DPABIPath,filesep,'Templates',filesep,'Zalesky_980_parcellated_compact.nii'];...
    [handles.Cfg.DPABIPath,filesep,'Templates',filesep,'Dosenbach_Science_160ROIs_Radius5_Mask.nii'];...
    [handles.Cfg.DPABIPath,filesep,'Templates',filesep,'BrainMask_05_91x109x91.img'];... %YAN Chao-Gan, 161201. Add global signal.
    [handles.Cfg.DPABIPath,filesep,'Templates',filesep,'Power_Neuron_264ROIs_Radius5_Mask.nii'];... %YAN Chao-Gan, 170104. Add Power 264.
    [handles.Cfg.DPABIPath,filesep,'Templates',filesep,'Schaefer2018_400Parcels_7Networks_order_FSLMNI152_1mm.nii'];... %YAN Chao-Gan, 180824. Add Schaefer 400.
    [handles.Cfg.DPABIPath,filesep,'Templates',filesep,'Tian2020_Subcortex_Atlas',filesep,'Tian_Subcortex_S4_3T_2009cAsym.nii']}; %YAN Chao-Gan, 210414. Add Tian2020_Subcortex_Atlas.


handles.Cfg=Cfg;
handles.Cfg.DPABISurfVersion=Release;
handles.Cfg.WorkingDir=pwd; 

PCTVer = ver('distcomp');
if ~isempty(PCTVer)
    FullMatlabVersion = sscanf(version,'%d.%d.%d.%d%s');
    if FullMatlabVersion(1)*1000+FullMatlabVersion(2)<8*1000+3    %YAN Chao-Gan, 151117. If it's lower than MATLAB 2014a.  %FullMatlabVersion(1)*1000+FullMatlabVersion(2)>=7*1000+8    %YAN Chao-Gan, 120903. If it's higher than MATLAB 2008.
        CurrentSize_MatlabPool = matlabpool('size');
        handles.Cfg.ParallelWorkersNumber = CurrentSize_MatlabPool;
    else
        poolobj = gcp('nocreate'); % If no pool, do not create new one.
        if isempty(poolobj)
            CurrentSize_MatlabPool = 0;
        else
            CurrentSize_MatlabPool = poolobj.NumWorkers;
        end
        handles.Cfg.ParallelWorkersNumber = CurrentSize_MatlabPool;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%Predefine Cfg End%%%%%%%%%%%%%%%%%%%%%%%%

% Make UI display correct in PC and linux
% if ~ismac
%     if ispc
%         ZoonMatrix = [1 1 0.8 0.8];  %For pc
%     else
%         ZoonMatrix = [1 1 0.7 0.8];  %For Linux
%     end
%     UISize = get(handles.figureDPABISurf,'Position');
%     UISize = UISize.*ZoonMatrix;
%     set(handles.figureDPABISurf,'Position',UISize);
% end

UpdateDisplay(handles);

% Choose default command line output for DPABISurf_Pipeline
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DPABISurf_Pipeline wait for user response (see UIRESUME)
% uiwait(handles.figureDPABISurf);


% --- Outputs from this function are returned to the command line.
function varargout = DPABISurf_Pipeline_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function editWorkDir_Callback(hObject, eventdata, handles)
% hObject    handle to editWorkDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%GetSubjList(hObject, handles);
handles.Cfg.SubjectID = get(handles.listboxParticipantID, 'String');
handles.Cfg.WorkingDir = get(handles.editWorkDir,'String');
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editWorkDir as text
%        str2double(get(hObject,'String')) returns contents of editWorkDir as a double


% --- Executes during object creation, after setting all properties.
function editWorkDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editWorkDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% function GetSubjList(hObject, handles)
% %Create by Sandy to get the Subject List
% WorkDir=get(handles.editWorkDir, 'String');
% if isempty(handles.Cfg.SubjectID)
%     StartDir=get(handles.editStartingDirName, 'String');
%     FullDir=fullfile(WorkDir, StartDir);
% 
%     if isempty(WorkDir) || isempty(StartDir) || ~isdir(FullDir)
%         set(handles.listboxParticipantID, 'String', '', 'Value', 0);
%         return
%     end
% 
%     SubjStruct=dir(FullDir);
%     Index=cellfun(...
%         @(IsDir, NotDot) IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')),...
%         {SubjStruct.isdir}, {SubjStruct.name});  % drop out the files that are not MRI images
%     SubjStruct=SubjStruct(Index);
%     SubjString={SubjStruct(:).name}';
%     StartDirFlag='On';
% else
%     SubjString=handles.Cfg.SubjectID;
%     StartDirFlag='Off';
% end
% 
% %set(handles.editWorkDir, 'Enable', StartDirFlag); 
% set(handles.listboxParticipantID, 'String', SubjString);
% set(handles.listboxParticipantID, 'Value', 1);

% --- Executes on button press in pushbuttonWorlDir.
function pushbuttonWorlDir_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonWorlDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Path=get(handles.editWorkDir, 'String');
if ~isdir(Path)
    Path=pwd;
end
Path=uigetdir(Path);
if ~ischar(Path)
    return
end
set(handles.editWorkDir, 'String', Path);

%GetSubjList(hObject, handles);
handles.Cfg.SubjectID = get(handles.listboxParticipantID, 'String');
handles.Cfg.WorkingDir = get(handles.editWorkDir,'String');
guidata(hObject,handles);


% --- Executes on selection change in listboxParticipantID.
function listboxParticipantID_Callback(hObject, eventdata, handles)
% hObject    handle to listboxParticipantID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listboxParticipantID contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxParticipantID


% --- Executes during object creation, after setting all properties.
function listboxParticipantID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxParticipantID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTimePoint_Callback(hObject, eventdata, handles)
% hObject    handle to editTimePoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.TimePoints = str2double(get(handles.editTimePoint,'String'));
guidata(hObject,handles);

% Hints: get(hObject,'String') returns contents of editTimePoint as text
%        str2double(get(hObject,'String')) returns contents of editTimePoint as a double


% --- Executes during object creation, after setting all properties.
function editTimePoint_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTimePoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTR_Callback(hObject, eventdata, handles)
% hObject    handle to editTR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.TR = str2double(get(handles.editTR,'String'));
UpdateDisplay(handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editTR as text
%        str2double(get(hObject,'String')) returns contents of editTR as a double


% --- Executes during object creation, after setting all properties.
function editTR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuTemplate.
function popupmenuTemplate_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuTemplate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[ProgramPath, fileN, extn] = fileparts(which('DPABISurf_Pipeline.m'));
switch get(hObject, 'Value'),
    case 1,	%Template Parameters
        return;%Do nothing
    case 2, %Default: Recommended preprocessing and calculating configuration
        load([ProgramPath,filesep,'Jobmats',filesep,'Template_Default.mat']);
    case 3, %Default+ICA_AROMA: Default configuration with ICA-AROMA denoising
        load([ProgramPath,filesep,'Jobmats',filesep,'Template_Default_ICA_AROMA.mat']);
    case 4, %Calculate function connectivity only
        load([ProgramPath,filesep,'Jobmats',filesep,'Template_FC_Only.mat']);
    case 5, %Anat only
        load([ProgramPath,filesep,'Jobmats',filesep,'Template_Anat_Only.mat']);
    case 6, %Blank
        load([ProgramPath,filesep,'Jobmats',filesep,'Template_Blank.mat']);
end

%Reset the default surface templates
[DPABIPath, fileN, extn] = fileparts(which('DPABI.m'));
Cfg.MaskFileSurfLH = fullfile(DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_lh_cortex.label.gii');
Cfg.MaskFileSurfRH = fullfile(DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_rh_cortex.label.gii');
Cfg.MaskFileVolu = fullfile(DPABIPath, 'Templates','BrainMask_05_91x109x91.img');
Cfg.SurfFileLH = fullfile(DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_lh_white.surf.gii');
Cfg.SurfFileRH = fullfile(DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_rh_white.surf.gii');
Cfg.CalFC.ROIDefSurfLH = {fullfile(DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_lh_HCP-MMP1.label.gii');...
    fullfile(DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_lh_Schaefer2018_400Parcels_7Networks_order.label.gii')};
Cfg.CalFC.ROIDefSurfRH = {fullfile(DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_rh_HCP-MMP1.label.gii');...
    fullfile(DPABIPath, 'DPABISurf', 'SurfTemplates','fsaverage5_rh_Schaefer2018_400Parcels_7Networks_order.label.gii')};
Cfg.CalFC.ROIDefVolu = {[DPABIPath,filesep,'Templates',filesep,'aal.nii'];...
    [DPABIPath,filesep,'Templates',filesep,'HarvardOxford-cort-maxprob-thr25-2mm_YCG.nii'];...
    [DPABIPath,filesep,'Templates',filesep,'HarvardOxford-sub-maxprob-thr25-2mm_YCG.nii'];...
    [DPABIPath,filesep,'Templates',filesep,'CC200ROI_tcorr05_2level_all.nii'];...
    [DPABIPath,filesep,'Templates',filesep,'Zalesky_980_parcellated_compact.nii'];...
    [DPABIPath,filesep,'Templates',filesep,'Dosenbach_Science_160ROIs_Radius5_Mask.nii'];...
    [DPABIPath,filesep,'Templates',filesep,'BrainMask_05_91x109x91.img'];... %YAN Chao-Gan, 161201. Add global signal.
    [DPABIPath,filesep,'Templates',filesep,'Power_Neuron_264ROIs_Radius5_Mask.nii'];... %YAN Chao-Gan, 170104. Add Power 264.
    [DPABIPath,filesep,'Templates',filesep,'Schaefer2018_400Parcels_7Networks_order_FSLMNI152_1mm.nii'];... %YAN Chao-Gan, 180824. Add Schaefer 400.
    [DPABIPath,filesep,'Templates',filesep,'Tian2020_Subcortex_Atlas',filesep,'Tian_Subcortex_S4_3T_2009cAsym.nii']}; %YAN Chao-Gan, 210414. Add Tian2020_Subcortex_Atlas.


handles.Cfg = Cfg;
handles.Cfg.DPABISurfVersion=handles.Release;
handles.Cfg.WorkingDir=pwd; 
UpdateDisplay(handles);
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuTemplate contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuTemplate


% --- Executes during object creation, after setting all properties.
function popupmenuTemplate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuTemplate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxEPIDCM2NII.
function checkboxEPIDCM2NII_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxEPIDCM2NII (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsNeedConvertFunDCM2IMG = get(handles.checkboxEPIDCM2NII,'Value');
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxEPIDCM2NII


% --- Executes on button press in checkboxT1DCM2NII.
function checkboxT1DCM2NII_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxT1DCM2NII (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsNeedConvertT1DCM2IMG = get(handles.checkboxT1DCM2NII,'Value');
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxT1DCM2NII


% --- Executes on button press in checkboxRemoveTimePoint.
function checkboxRemoveTimePoint_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxRemoveTimePoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsRemoveFirstTimePoints = get(handles.checkboxRemoveTimePoint,'Value');
handles.Cfg.RemoveFirstTimePoints = handles.Cfg.IsRemoveFirstTimePoints * handles.Cfg.RemoveFirstTimePoints;
UpdateDisplay_RemoveTimePoint(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxRemoveTimePoint



function editRemoveTimePoint_Callback(hObject, eventdata, handles)
% hObject    handle to editRemoveTimePoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.RemoveFirstTimePoints = str2double(get(handles.editRemoveTimePoint,'String'));
handles.Cfg.RemoveFirstTimePoints = handles.Cfg.IsRemoveFirstTimePoints * handles.Cfg.RemoveFirstTimePoints;
UpdateDisplay_RemoveTimePoint(handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editRemoveTimePoint as text
%        str2double(get(hObject,'String')) returns contents of editRemoveTimePoint as a double


% --- Executes during object creation, after setting all properties.
function editRemoveTimePoint_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRemoveTimePoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxConvert2BIDS.
function checkboxConvert2BIDS_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxConvert2BIDS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsConvert2BIDS = get(handles.checkboxConvert2BIDS,'Value');
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxConvert2BIDS


% --- Executes on button press in checkboxfmriprep.
function checkboxfmriprep_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxfmriprep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.Isfmriprep = get(handles.checkboxfmriprep,'Value');
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxfmriprep


% --- Executes on button press in checkboxLowMemory.
function checkboxLowMemory_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxLowMemory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsLowMem=get(handles.checkboxLowMemory,'Value');
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxLowMemory


% --- Executes on selection change in popupmenuNormalizeVoxelSize.
function popupmenuNormalizeVoxelSize_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuNormalizeVoxelSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(handles.popupmenuNormalizeVoxelSize,'Value')
    case 1
        handles.Cfg.Normalize.VoxelSize = '2mm';
    case 2 
        handles.Cfg.Normalize.VoxelSize = '1mm';
    case 3
        handles.Cfg.Normalize.VoxelSize = 'native';
end
guidata(hObject, handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuNormalizeVoxelSize contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuNormalizeVoxelSize


% --- Executes during object creation, after setting all properties.
function popupmenuNormalizeVoxelSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuNormalizeVoxelSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxSliceTiming.
function checkboxSliceTiming_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSliceTiming (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsSliceTiming = get(handles.checkboxSliceTiming,'Value');
UpdateDisplay_SliceTiming(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxSliceTiming



function editSliceNumber_Callback(hObject, eventdata, handles)
% hObject    handle to editSliceNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.SliceTiming.SliceNumber = str2double(get(handles.editSliceNumber,'String'));

if handles.Cfg.SliceTiming.SliceNumber==0
    if exist([handles.Cfg.WorkingDir,filesep,'SliceOrderInfo.tsv'])==2 % YAN Chao-Gan, 130524. Read the slice timing information from a tsv file (Tab-separated values)
    else
        uiwait(msgbox({'SliceOrderInfo.tsv (under working directory) is not detected. Please go {DPARSF}/Docs/SliceOrderInfo.tsv_Instruction.txt for instructions to allow different slice timing correction for different participants. If SliceNumber is set to 0 while SliceOrderInfo.tsv is not set, the slice order is then assumed as interleaved scanning: [1:2:SliceNumber,2:2:SliceNumber]. The reference slice is set to the slice acquired at the middle time point, i.e., SliceOrder(ceil(SliceNumber/2)). SHOULD BE EXTREMELY CAUTIOUS!!!';...
            },'Set Number of Slices'));
    end
end

UpdateDisplay_SliceTiming(handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editSliceNumber as text
%        str2double(get(hObject,'String')) returns contents of editSliceNumber as a double


% --- Executes during object creation, after setting all properties.
function editSliceNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSliceNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSliceOrder_Callback(hObject, eventdata, handles)
% hObject    handle to editSliceOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SliceOrder = get(handles.editSliceOrder,'String');
handles.Cfg.SliceTiming.SliceOrder = eval(['[',SliceOrder,']']);
%handles.Cfg.SliceTiming.SliceOrder = eval(SliceOrder);
UpdateDisplay_SliceTiming(handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editSliceOrder as text
%        str2double(get(hObject,'String')) returns contents of editSliceOrder as a double


% --- Executes during object creation, after setting all properties.
function editSliceOrder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSliceOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editReferSlice_Callback(hObject, eventdata, handles)
% hObject    handle to editReferSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.SliceTiming.ReferenceSlice = str2double(get(handles.editReferSlice,'String'));
UpdateDisplay(handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editReferSlice as text
%        str2double(get(hObject,'String')) returns contents of editReferSlice as a double


% --- Executes during object creation, after setting all properties.
function editReferSlice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editReferSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in textNormalizeVoxelSize.
function checkboxNormalizeVoxelSize_Callback(hObject, eventdata, handles)
% hObject    handle to textNormalizeVoxelSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
UpdateDisplay(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of textNormalizeVoxelSize



% --- Executes during object creation, after setting all properties.
function editNormalizedVoxelSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNormalizedVoxelSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editNormalizedVoxelSize_Callback(hObject, eventdata, handles)
% hObject    handle to editNormalizedVoxelSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
UpdateDisplay(handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editNormalizedVoxelSize as text
%        str2double(get(hObject,'String')) returns contents of editNormalizedVoxelSize as a double



% --- Executes on button press in radiobuttonNormalizeNative.
function radiobuttonNormalizeNative_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonNormalizeNative (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
UpdateDisplay(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of radiobuttonNormalizeNative


% --- Executes on button press in checkboxICA_AROMA.
function checkboxICA_AROMA_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxICA_AROMA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsICA_AROMA = get(handles.checkboxICA_AROMA,'Value');
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxICA_AROMA


% --- Executes on button press in checkboxOrganizefmriprep.
function checkboxOrganizefmriprep_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxOrganizefmriprep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsOrganizefmriprepResults = get(handles.checkboxOrganizefmriprep,'Value');
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxOrganizefmriprep



function editMaskLH_Callback(hObject, eventdata, handles)
% hObject    handle to editMaskLH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMaskLH as text
%        str2double(get(hObject,'String')) returns contents of editMaskLH as a double
theMaskfile =get(hObject, 'String');
theMaskfile =strtrim(theMaskfile);
if exist(theMaskfile, 'file')
    handles.Cfg.MaskFileSurfLH =theMaskfile;
    guidata(hObject, handles);
else
    errordlg(sprintf('The mask file "%s" does not exist!\n Please re-check it.', theMaskfile));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editMaskLH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMaskLH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbuttonMaskLH.
function pushbuttonMaskLH_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonMaskLH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName]=uigetfile({'*.gii','Brain Image Files (*.gii)';'*.*', 'All Files (*.*)';},'Select surface mask for left hemisphere:',handles.Cfg.MaskFileSurfLH);
set(handles.editMaskLH, 'String', fullfile(PathName,FileName));
handles.Cfg.MaskFileSurfLH = fullfile(PathName,FileName);
guidata(hObject,handles);



function editMaskRH_Callback(hObject, eventdata, handles)
% hObject    handle to editMaskRH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMaskRH as text
%        str2double(get(hObject,'String')) returns contents of editMaskRH as a double
theMaskfile =get(hObject, 'String');
theMaskfile =strtrim(theMaskfile);
if exist(theMaskfile, 'file')
    handles.Cfg.MaskFileSurfRH =theMaskfile;
    guidata(hObject, handles);
else
    errordlg(sprintf('The mask file "%s" does not exist!\n Please re-check it.', theMaskfile));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editMaskRH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMaskRH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbuttonMaskRH.
function pushbuttonMaskRH_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonMaskRH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName]=uigetfile({'*.gii','Brain Image Files (*.gii)';'*.*', 'All Files (*.*)';},'Select surface mask for left hemisphere:',handles.Cfg.MaskFileSurfRH);
set(handles.editMaskRH, 'String', fullfile(PathName,FileName));
handles.Cfg.MaskFileSurfRH = fullfile(PathName,FileName);
guidata(hObject,handles);




function editMaskVolume_Callback(hObject, eventdata, handles)
% hObject    handle to editMaskVolume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMaskVolume as text
%        str2double(get(hObject,'String')) returns contents of editMaskVolume as a double
theMaskfile =get(hObject, 'String');
theMaskfile =strtrim(theMaskfile);
if exist(theMaskfile, 'file')
    handles.Cfg.MaskFileVolu =theMaskfile;
    guidata(hObject, handles);
else
    errordlg(sprintf('The mask file "%s" does not exist!\n Please re-check it.', theMaskfile));
end
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function editMaskVolume_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMaskVolume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonMaskVolume.
function pushbuttonMaskVolume_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonMaskVolume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName]=uigetfile({'*.gii','Brain Image Files (*.gii)';'*.*', 'All Files (*.*)';},'Select surface mask for left hemisphere:',handles.Cfg.MaskFileVolu);
set(handles.editMaskRH, 'String', fullfile(PathName,FileName));
handles.Cfg.MaskFileVolu = fullfile(PathName,FileName);
guidata(hObject,handles);


% --- Executes on button press in checkboxNuisanceRegression.
function checkboxNuisanceRegression_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxNuisanceRegression (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsCovremove = get(handles.checkboxNuisanceRegression,'Value');
UpdateDisplay_NuisanceRegression(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxNuisanceRegression


% --- Executes on button press in checkboxScrubbingRegressor.
function checkboxScrubbingRegressor_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxScrubbingRegressor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.checkboxScrubbingRegressor,'Value')
    handles.Cfg.Covremove.IsHeadMotionScrubbingRegressors=1;
    [ProgramPath, fileN, extn] = fileparts(which('DPARSFA.m'));
    addpath([ProgramPath,filesep,'SubGUIs']);
    [handles.Cfg.Covremove.HeadMotionScrubbingRegressors.FDType,handles.Cfg.Covremove.HeadMotionScrubbingRegressors.FDThreshold,handles.Cfg.Covremove.HeadMotionScrubbingRegressors.PreviousPoints,handles.Cfg.Covremove.HeadMotionScrubbingRegressors.LaterPoints]=DPARSF_ScrubbingSetting_gui(handles.Cfg.Covremove.HeadMotionScrubbingRegressors.FDType,handles.Cfg.Covremove.HeadMotionScrubbingRegressors.FDThreshold,handles.Cfg.Covremove.HeadMotionScrubbingRegressors.PreviousPoints,handles.Cfg.Covremove.HeadMotionScrubbingRegressors.LaterPoints,'');
    %[handles.Cfg.Covremove.HeadMotionScrubbingRegressors.FDThreshold,handles.Cfg.Covremove.HeadMotionScrubbingRegressors.PreviousPoints,handles.Cfg.Covremove.HeadMotionScrubbingRegressors.LaterPoints]=DPARSF_ScrubbingSetting_gui(handles.Cfg.Covremove.HeadMotionScrubbingRegressors.FDThreshold,handles.Cfg.Covremove.HeadMotionScrubbingRegressors.PreviousPoints,handles.Cfg.Covremove.HeadMotionScrubbingRegressors.LaterPoints,'');
    %YAN Chao-Gan, 121225. Added FDType.
    %Do not need to ScrubbingMethod, because using each bad time point as a separate regressor
else
    handles.Cfg.Covremove.IsHeadMotionScrubbingRegressors=0;
end
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxScrubbingRegressor


% --- Executes on button press in checkboxOtherCovariates.
function checkboxOtherCovariates_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxOtherCovariates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    ROIDef=handles.Cfg.Covremove.OtherCovariatesROI;
    ROIDef=DPABI_ROIList(ROIDef);
    handles.Cfg.Covremove.OtherCovariatesROI=ROIDef;
else
    handles.Cfg.Covremove.OtherCovariatesROI=[];
end
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxOtherCovariates


% --- Executes on button press in radiobuttonRigid6.
function radiobuttonRigid6_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonRigid6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%handles.Cfg.Covremove.HeadMotion = 1;
if handles.Cfg.Covremove.HeadMotion~=1
    handles.Cfg.Covremove.HeadMotion=1;
else
    handles.Cfg.Covremove.HeadMotion=0;
end
UpdateDisplay(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of radiobuttonRigid6


% --- Executes on button press in radiobuttonDerivative12.
function radiobuttonDerivative12_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonDerivative12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%handles.Cfg.Covremove.HeadMotion = 2;
if handles.Cfg.Covremove.HeadMotion~=2
    handles.Cfg.Covremove.HeadMotion=2;
else
    handles.Cfg.Covremove.HeadMotion=0;
end
UpdateDisplay(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of radiobuttonDerivative12


% --- Executes on button press in radiobuttonFriston24.
function radiobuttonFriston24_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonFriston24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%handles.Cfg.Covremove.HeadMotion = 4;
if handles.Cfg.Covremove.HeadMotion~=4
    handles.Cfg.Covremove.HeadMotion=4;
else
    handles.Cfg.Covremove.HeadMotion=0;
end
UpdateDisplay(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of radiobuttonFriston24


function editPolynomiaTrend_Callback(hObject, eventdata, handles)
% hObject    handle to editPolynomiaTrend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.Covremove.PolynomialTrend = str2double(get(handles.editPolynomiaTrend,'String'));
UpdateDisplay(handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editPolynomiaTrend as text
%        str2double(get(hObject,'String')) returns contents of editPolynomiaTrend as a double


% --- Executes during object creation, after setting all properties.
function editPolynomiaTrend_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPolynomiaTrend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonNuisanceRegression.
function pushbuttonNuisanceRegression_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonNuisanceRegression (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.Covremove = DPARSF_NuisanceSetting(handles.Cfg.Covremove);
guidata(hObject, handles);
UpdateDisplay(handles);

% --- Executes on button press in checkboxAddMeanBack.
function checkboxAddMeanBack_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxAddMeanBack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.Covremove.IsAddMeanBack = get(handles.checkboxAddMeanBack,'Value');
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxAddMeanBack


% --- Executes on button press in checkboxNonAgressiveRegressICAAROMANoise.
function checkboxNonAgressiveRegressICAAROMANoise_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxNonAgressiveRegressICAAROMANoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.NonAgressiveRegressICAAROMANoise = get(handles.checkboxNonAgressiveRegressICAAROMANoise,'Value');
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxNonAgressiveRegressICAAROMANoise


% --- Executes on button press in checkboxSmoothData.
function checkboxSmoothData_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSmoothData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsSmooth = get(handles.checkboxSmoothData,'Value')|get(handles.checkboxSmoothDerivative,'Value');
handles.Cfg.Smooth.Timing='OnFunctionalData';
UpdateDisplay_Smooth(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxSmoothData


function editFWHMSurface_Callback(hObject, eventdata, handles)
% hObject    handle to editFWHMSurface (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.Smooth.FWHMSurf = str2double(get(handles.editFWHMSurface,'String'));
UpdateDisplay_Smooth(handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editFWHMSurface as text
%        str2double(get(hObject,'String')) returns contents of editFWHMSurface as a double


% --- Executes during object creation, after setting all properties.
function editFWHMSurface_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFWHMSurface (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFWHMVolume_Callback(hObject, eventdata, handles)
% hObject    handle to editFWHMVolume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FWHMVolume = get(handles.editFWHMVolume,'String');
% handles.Cfg.Smooth.FWHMVolu = eval(['[',FWHMVolume,']']);
handles.Cfg.Smooth.FWHMVolu = eval(FWHMVolume);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editFWHMVolume as text
%        str2double(get(hObject,'String')) returns contents of editFWHMVolume as a double


% --- Executes during object creation, after setting all properties.
function editFWHMVolume_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFWHMVolume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxALFFfALFF.
function checkboxALFFfALFF_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxALFFfALFF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsCalALFF = get(handles.checkboxALFFfALFF,'Value');
UpdateDisplay_ALFF(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxALFFfALFF



function editALFFBandLow_Callback(hObject, eventdata, handles)
% hObject    handle to editALFFBandLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.CalALFF.AHighPass_LowCutoff = str2double(get(handles.editALFFBandLow,'String'));
UpdateDisplay(handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editALFFBandLow as text
%        str2double(get(hObject,'String')) returns contents of editALFFBandLow as a double


% --- Executes during object creation, after setting all properties.
function editALFFBandLow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editALFFBandLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editALFFBandHigh_Callback(hObject, eventdata, handles)
% hObject    handle to editALFFBandHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.CalALFF.ALowPass_HighCutoff = str2double(get(handles.editALFFBandHigh,'String'));
UpdateDisplay(handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editALFFBandHigh as text
%        str2double(get(hObject,'String')) returns contents of editALFFBandHigh as a double


% --- Executes during object creation, after setting all properties.
function editALFFBandHigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editALFFBandHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxFilter.
function checkboxFilter_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsFilter = get(handles.checkboxFilter,'Value');
UpdateDisplay_Filter(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxFilter



function editFilterBandLow_Callback(hObject, eventdata, handles)
% hObject    handle to editFilterBandLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.Filter.AHighPass_LowCutoff = str2double(get(handles.editFilterBandLow,'String'));
UpdateDisplay(handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editFilterBandLow as text
%        str2double(get(hObject,'String')) returns contents of editFilterBandLow as a double


% --- Executes during object creation, after setting all properties.
function editFilterBandLow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFilterBandLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFilterBandHigh_Callback(hObject, eventdata, handles)
% hObject    handle to editFilterBandHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.Filter.ALowPass_HighCutoff = str2double(get(handles.editFilterBandHigh,'String'));
UpdateDisplay(handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editFilterBandHigh as text
%        str2double(get(hObject,'String')) returns contents of editFilterBandHigh as a double


% --- Executes during object creation, after setting all properties.
function editFilterBandHigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFilterBandHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxScubbing.
function checkboxScubbing_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxScubbing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.checkboxScubbing,'Value')
    handles.Cfg.IsScrubbing = 1;
    handles.Cfg.Scrubbing.Timing='AfterPreprocessing';
    [ProgramPath, fileN, extn] = fileparts(which('DPARSFA.m'));
    addpath([ProgramPath,filesep,'SubGUIs']); %YAN Chao-Gan, 130110. Fixed a bug for didn't adding the GUI path.
    [handles.Cfg.Scrubbing.FDType,handles.Cfg.Scrubbing.FDThreshold,handles.Cfg.Scrubbing.PreviousPoints,handles.Cfg.Scrubbing.LaterPoints,handles.Cfg.Scrubbing.ScrubbingMethod]=DPARSF_ScrubbingSetting_gui(handles.Cfg.Scrubbing.FDType,handles.Cfg.Scrubbing.FDThreshold,handles.Cfg.Scrubbing.PreviousPoints,handles.Cfg.Scrubbing.LaterPoints,handles.Cfg.Scrubbing.ScrubbingMethod);
    %[handles.Cfg.Scrubbing.FDThreshold,handles.Cfg.Scrubbing.PreviousPoints,handles.Cfg.Scrubbing.LaterPoints,handles.Cfg.Scrubbing.ScrubbingMethod]=DPARSF_ScrubbingSetting_gui(handles.Cfg.Scrubbing.FDThreshold,handles.Cfg.Scrubbing.PreviousPoints,handles.Cfg.Scrubbing.LaterPoints,handles.Cfg.Scrubbing.ScrubbingMethod);
    %YAN Chao-Gan, 121225. Added FD type.
    
else
    handles.Cfg.IsScrubbing = 0;
end
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of checkboxScubbing


% --- Executes on button press in checkboxReHo.
function checkboxReHo_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxReHo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsCalReHo = get(handles.checkboxReHo,'Value');
UpdateDisplay_ReHo(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxReHo


% --- Executes on button press in radiobuttonReHoNeighborVolume7.
function radiobuttonReHoNeighborVolume7_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonReHoNeighborVolume7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.CalReHo.ClusterNVoxel = 7;
UpdateDisplay_ReHo(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of radiobuttonReHoNeighborVolume7


% --- Executes on button press in radiobuttonReHoNeighborVolume19.
function radiobuttonReHoNeighborVolume19_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonReHoNeighborVolume19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.CalReHo.ClusterNVoxel = 19;
UpdateDisplay_ReHo(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of radiobuttonReHoNeighborVolume19


% --- Executes on button press in radiobuttonReHoNeighborVolume27.
function radiobuttonReHoNeighborVolume27_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonReHoNeighborVolume27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.CalReHo.ClusterNVoxel = 27;
UpdateDisplay_ReHo(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of radiobuttonReHoNeighborVolume27


% --- Executes on button press in radiobuttonReHoNeighborSurf1.
function radiobuttonReHoNeighborSurf1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonReHoNeighborSurf1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.CalReHo.SurfNNeighbor = 1;
UpdateDisplay_ReHo(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of radiobuttonReHoNeighborSurf1


% --- Executes on button press in radiobuttonReHoNeighborSurf2.
function radiobuttonReHoNeighborSurf2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonReHoNeighborSurf2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.CalReHo.SurfNNeighbor = 2;
UpdateDisplay_ReHo(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of radiobuttonReHoNeighborSurf2



function editSurfaceLH_Callback(hObject, eventdata, handles)
% hObject    handle to editSurfaceLH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.SurfFileLH = get(handles.editSurfaceLH, 'String');
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editSurfaceLH as text
%        str2double(get(hObject,'String')) returns contents of editSurfaceLH as a double


% --- Executes during object creation, after setting all properties.
function editSurfaceLH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSurfaceLH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSurfaceLH.
function pushbuttonSurfaceLH_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSurfaceLH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,PathName]=uigetfile({'*.gii','Brain Image Files (*.gii)';'*.*', 'All Files (*.*)';},'Select surface file for left hemisphere:',handles.Cfg.SurfFileLH);
set(handles.editSurfaceLH, 'String', fullfile(PathName,FileName));
handles.Cfg.SurfFileLH = fullfile(PathName,FileName);
guidata(hObject,handles);



function editSurfaceRH_Callback(hObject, eventdata, handles)
% hObject    handle to editSurfaceRH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.SurfFileRH = get(handles.editSurfaceRH, 'String');
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editSurfaceRH as text
%        str2double(get(hObject,'String')) returns contents of editSurfaceRH as a double


% --- Executes during object creation, after setting all properties.
function editSurfaceRH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSurfaceRH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function pushbuttonSurfaceRH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbuttonSurfaceRH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% --- Executes on button press in pushbuttonSurfaceRH.


function pushbuttonSurfaceRH_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSurfaceRH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,PathName]=uigetfile({'*.gii','Brain Image Files (*.gii)';'*.*', 'All Files (*.*)';},'Select surface file for left hemisphere:',handles.Cfg.SurfFileRH);
set(handles.editSurfaceRH, 'String', fullfile(PathName,FileName));
handles.Cfg.SurfFileRH = fullfile(PathName,FileName);
guidata(hObject,handles);



% --- Executes on button press in checkboxDC.
function checkboxDC_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxDC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    handles.Cfg.IsCalDegreeCentrality = get(handles.checkboxDC,'Value');
    prompt ={'Please set the correlation (r) threshold for degree centrality calculation:'};
    def	={num2str(handles.Cfg.CalDegreeCentrality.rThreshold)};
    options.Resize='on';
    options.WindowStyle='modal';
    options.Interpreter='tex';
    answer =inputdlg(prompt, 'Set r threshold', 1, def,options);
    if numel(answer)==1
        handles.Cfg.CalDegreeCentrality.rThreshold = str2num(answer{1});
    end
else
    handles.Cfg.IsCalDegreeCentrality = 0;
end
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxDC


% --- Executes on button press in checkboxFC.
function checkboxFC_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxFC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsCalFC = get(handles.checkboxFC,'Value');
UpdateDisplay_FC(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxFC


% --- Executes on button press in checkboxExtractROI.
function checkboxExtractROI_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxExtractROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsExtractROISignals = get(handles.checkboxExtractROI,'Value');
UpdateDisplay_FC(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxExtractROI


% --- Executes on button press in pushbuttonDefineROI.
function pushbuttonDefineROI_Callback(hObject, eventdata, handles)
ROIDef.Volume=handles.Cfg.CalFC.ROIDefVolu;
ROIDef.SurfLH=handles.Cfg.CalFC.ROIDefSurfLH;
ROIDef.SurfRH=handles.Cfg.CalFC.ROIDefSurfRH;

if handles.Cfg.CalFC.IsMultipleLabel
    fprintf('\nIsMultipleLabel is set to 1: There are multiple labels in the ROI mask file.\n');
else
    fprintf('\nIsMultipleLabel is set to 0: All the non-zero values will be used to define the only ROI.\n');
end

[ROIDef,handles.Cfg.CalFC.IsMultipleLabel]=DPABISurf_ROIList(ROIDef,handles.Cfg.CalFC.IsMultipleLabel);
if ~isempty(ROIDef)
    handles.Cfg.CalFC.ROIDefVolu=ROIDef.Volume;
    handles.Cfg.CalFC.ROIDefSurfLH=ROIDef.SurfLH;
    handles.Cfg.CalFC.ROIDefSurfRH=ROIDef.SurfRH;
end
guidata(hObject, handles);
% hObject    handle to pushbuttonDefineROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkboxSmoothDerivative.
function checkboxSmoothDerivative_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSmoothDerivative (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.IsSmooth = get(handles.checkboxSmoothData,'Value')|get(handles.checkboxSmoothDerivative,'Value');
handles.Cfg.Smooth.Timing='OnResults';
UpdateDisplay_Smooth(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkboxSmoothDerivative



function editFuncSession_Callback(hObject, eventdata, handles)
% hObject    handle to editFuncSession (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Cfg.FunctionalSessionNumber = str2double(get(handles.editFuncSession,'String'));
UpdateDisplay(handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editFuncSession as text
%        str2double(get(hObject,'String')) returns contents of editFuncSession as a double


% --- Executes during object creation, after setting all properties.
function editFuncSession_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFuncSession (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editStartingDirName_Callback(hObject, eventdata, handles)
% hObject    handle to editStartingDirName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiwait(msgbox({'If you do not start with raw DICOM images, you need to specify the Starting Directory Name.';...
    'E.g. "FunSurfW" means you start with images which have been normalized to fsaverage5.';...
    '';...
    'Abbreviations:';...
    'W - Normalize';...
    'I - ICA-AROMA Noise non-aggressively regressed';...
    'C - Covariates Removed';...
    'S - Smooth';...
    'F - Filter';...
    'B - ScruBBing';...
    },'Tips for Starting Directory Name'));

%GetSubjList(hObject, handles);
handles.Cfg.StartingDirName = get(handles.editStartingDirName,'String');
[handles, CheckingPass]=CheckCfgParametersBeforeRun(handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of editStartingDirName as text
%        str2double(get(hObject,'String')) returns contents of editStartingDirName as a double


% --- Executes during object creation, after setting all properties.
function editStartingDirName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStartingDirName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editParallelWorker_Callback(hObject, eventdata, handles)
% hObject    handle to editParallelWorker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Size_MatlabPool =str2double(get(hObject,'String'));

% Check number of matlab workers. To start the matlabpool if Parallel Computation Toolbox is detected.
PCTVer = ver('distcomp');
if ~isempty(PCTVer)
    FullMatlabVersion = sscanf(version,'%d.%d.%d.%d%s');
    if FullMatlabVersion(1)*1000+FullMatlabVersion(2)<8*1000+3    %YAN Chao-Gan, 151117. If it's lower than MATLAB 2014a.  %FullMatlabVersion(1)*1000+FullMatlabVersion(2)>=7*1000+8    %YAN Chao-Gan, 120903. If it's higher than MATLAB 2008.
        if Size_MatlabPool ~= handles.Cfg.ParallelWorkersNumber;
            if handles.Cfg.ParallelWorkersNumber~=0
                matlabpool close
            end
            if Size_MatlabPool~=0
                matlabpool(Size_MatlabPool)
            end
        end
        CurrentSize_MatlabPool = matlabpool('size');
        handles.Cfg.ParallelWorkersNumber = CurrentSize_MatlabPool;
    else
        if Size_MatlabPool ~= handles.Cfg.ParallelWorkersNumber
            if handles.Cfg.ParallelWorkersNumber~=0
                poolobj = gcp('nocreate'); % If no pool, do not create new one.
                delete(poolobj);
            end
            if Size_MatlabPool~=0
                parpool(Size_MatlabPool)
            end
        end
        poolobj = gcp('nocreate'); % If no pool, do not create new one.
        if isempty(poolobj)
            CurrentSize_MatlabPool = 0;
        else
            CurrentSize_MatlabPool = poolobj.NumWorkers;
        end
        handles.Cfg.ParallelWorkersNumber = CurrentSize_MatlabPool;
    end
end

UpdateDisplay(handles);
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of editParallelWorker as text
%        str2double(get(hObject,'String')) returns contents of editParallelWorker as a double


% --- Executes during object creation, after setting all properties.
function editParallelWorker_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editParallelWorker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSaveConfiguration.
function pushbuttonSaveConfiguration_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSaveConfiguration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Datetime=fix(clock);    
[filename, pathname] = uiputfile({'*.mat'}, 'Save Parameters As',...
    ['DPABISurf_ManualSave_',num2str(Datetime(1)),'_',num2str(Datetime(2)),'_',num2str(Datetime(3)),'_',num2str(Datetime(4)),'_',num2str(Datetime(5)),'.mat']);
if ischar(filename)
    Cfg=handles.Cfg;
    save(['',pathname,filename,''], 'Cfg');
end

% --- Executes on button press in pushbuttonLoadConfigeration.
function pushbuttonLoadConfigeration_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadConfigeration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.mat'}, 'Load Parameters From');
if ischar(filename)
    load([pathname,filename]);
    handles.Cfg = Cfg;
end

if str2num(handles.Cfg.DPABISurfVersion(end-5:end)) ~= str2num(handles.Release(end-5:end))
    uiwait(msgbox({['The mat file is created with DPABISurf ',handles.Cfg.DPABISurfVersion,', and now is succesfully updated to DPABISurf ',handles.Release,'.'];...
        },'Version Compatibility'));
    handles.Cfg.DPABISurfVersion = handles.Release;
end

guidata(hObject, handles);
UpdateDisplay(handles);


% --- Executes on button press in pushbuttonQuitDPABISurf.
function pushbuttonQuitDPABISurf_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonQuitDPABISurf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figureDPABISurf);


% --- Executes on button press in pushbuttonDPABISurfRun.
function pushbuttonDPABISurfRun_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDPABISurfRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles, CheckingPass]=CheckCfgParametersBeforeRun(handles);
if CheckingPass==0
    return
end

RawBackgroundColor=get(handles.pushbuttonDPABISurfRun ,'BackgroundColor');
RawForegroundColor=get(handles.pushbuttonDPABISurfRun ,'ForegroundColor');
set(handles.pushbuttonDPABISurfRun ,'Enable', 'off','BackgroundColor', 'red','ForegroundColor','green');
Cfg=handles.Cfg; 
Datetime=fix(clock); 
save([handles.Cfg.WorkingDir,filesep,'DPABISurf_AutoSave_',num2str(Datetime(1)),'_',num2str(Datetime(2)),'_',num2str(Datetime(3)),'_',num2str(Datetime(4)),'_',num2str(Datetime(5)),'.mat'], 'Cfg'); 
[Error, Cfg]=DPABISurf_run(handles.Cfg);

if ((handles.Cfg.IsCovremove==1) && (handles.Cfg.Covremove.WholeBrain.IsBothWithWithoutGSR == 1)) 
    handles.Cfg.SubjectID = Cfg.SubjectID; %In case the subject ID has been revised for BIDS.
    [Error]=DPABISurf_RerunWithGSR(handles.Cfg);
end

if ~isempty(Error)
    uiwait(msgbox(Error,'Errors were encountered while processing','error'));
end
set(handles.pushbuttonDPABISurfRun ,'Enable', 'on','BackgroundColor', RawBackgroundColor,'ForegroundColor',RawForegroundColor);
UpdateDisplay(handles);




% --------------------------------------------------------------------
function SubjectListFunction_Callback(hObject, eventdata, handles)
% hObject    handle to SubjectListFunction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function RemoveOneSubject_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveOneSubject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=get(handles.listboxParticipantID, 'Value');
if ~Value
    return
end
OneSubj=get(handles.listboxParticipantID, 'String');
OneSubj=OneSubj{Value};

if isempty(handles.Cfg.SubjectID)
    SubjString=get(handles.SubjListbox, 'String');
else
    SubjString=handles.Cfg.SubjectID;
end

Index=strcmpi(OneSubj, SubjString);
SubjString=SubjString(~Index);

if Value~=1
    set(handles.listboxParticipantID, 'Value',Value-1);
else
    set(handles.listboxParticipantID, 'Value',1);
end
    
handles.Cfg.SubjectID=SubjString;
UpdateDisplay(handles);
guidata(hObject, handles);
%GetSubjList(hObject, handles);

% --------------------------------------------------------------------
function RemoveAllSubject_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveAllSubject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tmpMsg=sprintf('Delete all the participants?');
if strcmp(questdlg(tmpMsg, 'Delete confirmation'), 'Yes')
    handles.Cfg.SubjectID={};
    guidata(hObject, handles);
    UpdateDisplay(handles);
end

% --------------------------------------------------------------------
function LoadSubjectID_Callback(hObject, eventdata, handles)
% hObject    handle to LoadSubjectID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[SubID_Name , SubID_Path]=uigetfile({'*.txt','Subject ID Files (*.txt)';'*.*', 'All Files (*.*)';}, ...
    'Pick the text file for all the subject IDs');
SubID_File=[SubID_Path,SubID_Name];
if ischar(SubID_File)
    if exist(SubID_File,'file')==2
        fid = fopen(SubID_File);
        IDCell = textscan(fid,'%s\n'); %YAN Chao-Gan. For compatiblity of MALLAB 2014b. IDCell = textscan(fid,'%s','\n');
        fclose(fid);
        handles.Cfg.SubjectID=IDCell{1};
        guidata(hObject, handles);
        UpdateDisplay(handles);
    end
end

% --------------------------------------------------------------------
function SaveSubjectID_Callback(hObject, eventdata, handles)
% hObject    handle to SaveSubjectID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[SubID_Name , SubID_Path]=uiputfile({'*.txt','Subject ID Files (*.txt)';'*.*', 'All Files (*.*)';}, ...
    'Specify a text file to save all the subject IDs');
SubID_File=[SubID_Path,SubID_Name];
if ischar(SubID_File)
    fid = fopen(SubID_File,'w');
    for iSub=1:length(handles.Cfg.SubjectID)
        fprintf(fid,'%s\n',handles.Cfg.SubjectID{iSub});
    end
    fclose(fid);
end


function UpdateDisplay_Smooth(handles)
set(handles.editFWHMSurface,'String',handles.Cfg.Smooth.FWHMSurf);
set(handles.editFWHMVolume,'String',['[',num2str(handles.Cfg.Smooth.FWHMVolu),']']);

if handles.Cfg.IsSmooth
    switch handles.Cfg.Smooth.Timing
        case 'OnFunctionalData'
            set(handles.textFWHMSurface,'Enable','on');set(handles.textFWHMSurface,'ForegroundColor',[0 0 0]);
            set(handles.editFWHMSurface,'Enable','on');set(handles.editFWHMSurface,'ForegroundColor',[0 0 0]);
            set(handles.textFWHMVolume,'Enable','on');set(handles.textFWHMVolume,'ForegroundColor',[0 0 0]);
            set(handles.editFWHMVolume,'Enable','on');set(handles.editFWHMVolume,'ForegroundColor',[0 0 0]);
            set(handles.checkboxSmoothDerivative,'ForegroundColor',[0.5 0.5 0.5]);
            set(handles.checkboxSmoothDerivative,'Value',0);
            set(handles.checkboxSmoothData,'ForegroundColor',[0 0 0]);
            set(handles.checkboxSmoothData,'Value',1);
        case 'OnResults'
            set(handles.textFWHMSurface,'Enable','on');set(handles.textFWHMSurface,'ForegroundColor',[0 0 1]);
            set(handles.editFWHMSurface,'Enable','on');set(handles.editFWHMSurface,'ForegroundColor',[0 0 1]);
            set(handles.textFWHMVolume,'Enable','on');set(handles.textFWHMVolume,'ForegroundColor',[0 0 1]);
            set(handles.editFWHMVolume,'Enable','on');set(handles.editFWHMVolume,'ForegroundColor',[0 0 1]);
            set(handles.checkboxSmoothData,'ForegroundColor',[0.5 0.5 0.5]);
            set(handles.checkboxSmoothData,'Value',0);
            set(handles.checkboxSmoothDerivative,'ForegroundColor',[0 0 0]);
            set(handles.checkboxSmoothDerivative,'Value',1);
    end
else
    set(handles.textFWHMSurface,'Enable','off');
    set(handles.editFWHMSurface,'Enable','off');
    set(handles.textFWHMVolume,'Enable','off');
    set(handles.editFWHMVolume,'Enable','off');
    set(handles.checkboxSmoothDerivative,'ForegroundColor',[0.5 0.5 0.5]);
    set(handles.checkboxSmoothData,'ForegroundColor',[0.5 0.5 0.5]);
    set(handles.checkboxSmoothDerivative,'Value',0);
    set(handles.checkboxSmoothData,'Value',0);
end

function UpdateDisplay_ReHo(handles)
set(handles.checkboxReHo,'Value',handles.Cfg.IsCalReHo);

switch handles.Cfg.CalReHo.ClusterNVoxel
    case 7
        set(handles.radiobuttonReHoNeighborVolume7,'Value',1);
        set(handles.radiobuttonReHoNeighborVolume19,'Value',0);
        set(handles.radiobuttonReHoNeighborVolume27,'Value',0);
    case 19
        set(handles.radiobuttonReHoNeighborVolume7,'Value',0);
        set(handles.radiobuttonReHoNeighborVolume19,'Value',1);
        set(handles.radiobuttonReHoNeighborVolume27,'Value',0);
    case 27
        set(handles.radiobuttonReHoNeighborVolume7,'Value',0);
        set(handles.radiobuttonReHoNeighborVolume19,'Value',0);
        set(handles.radiobuttonReHoNeighborVolume27,'Value',1);
end   
switch handles.Cfg.CalReHo.SurfNNeighbor
    case 1
        set(handles.radiobuttonReHoNeighborSurf1,'Value',1);
        set(handles.radiobuttonReHoNeighborSurf2,'Value',0);
    case 2
        set(handles.radiobuttonReHoNeighborSurf1,'Value',0);
        set(handles.radiobuttonReHoNeighborSurf2,'Value',1);
end   
set(handles.editSurfaceLH,'String',handles.Cfg.SurfFileLH);
set(handles.editSurfaceRH,'String',handles.Cfg.SurfFileRH);

if handles.Cfg.IsCalReHo
    set(handles.textReHoNeighborSurf,'Enable','on');
    set(handles.radiobuttonReHoNeighborSurf1,'Enable','on');
    set(handles.radiobuttonReHoNeighborSurf2,'Enable','on');
    set(handles.textReHoNeighborVolume,'Enable','on');
    set(handles.radiobuttonReHoNeighborVolume7,'Enable','on');
    set(handles.radiobuttonReHoNeighborVolume19,'Enable','on');
    set(handles.radiobuttonReHoNeighborVolume27,'Enable','on');
    set(handles.textSurfaceFile,'Enable','on');
    set(handles.textSurfaceLH,'Enable','on');
    set(handles.editSurfaceLH,'Enable','on');
    set(handles.pushbuttonSurfaceLH,'Enable','on');
    set(handles.textSurfaceRH,'Enable','on');
    set(handles.editSurfaceRH,'Enable','on');
    set(handles.pushbuttonSurfaceRH,'Enable','on');
else
    set(handles.textReHoNeighborSurf,'Enable','off');
    set(handles.radiobuttonReHoNeighborSurf1,'Enable','off');
    set(handles.radiobuttonReHoNeighborSurf2,'Enable','off');
    set(handles.textReHoNeighborVolume,'Enable','off');
    set(handles.radiobuttonReHoNeighborVolume7,'Enable','off');
    set(handles.radiobuttonReHoNeighborVolume19,'Enable','off');
    set(handles.radiobuttonReHoNeighborVolume27,'Enable','off');
    set(handles.textSurfaceFile,'Enable','off');
    set(handles.textSurfaceLH,'Enable','off');
    set(handles.editSurfaceLH,'Enable','off');
    set(handles.pushbuttonSurfaceLH,'Enable','off');
    set(handles.textSurfaceRH,'Enable','off');
    set(handles.editSurfaceRH,'Enable','off');
    set(handles.pushbuttonSurfaceRH,'Enable','off');
end

function UpdateDisplay_SliceTiming(handles)
set(handles.checkboxSliceTiming,'Value',handles.Cfg.IsSliceTiming);
set(handles.editSliceNumber,'String',handles.Cfg.SliceTiming.SliceNumber);
set(handles.editReferSlice,'String',handles.Cfg.SliceTiming.ReferenceSlice);
set(handles.editSliceOrder,'String',['[',num2str(handles.Cfg.SliceTiming.SliceOrder),']']);

if handles.Cfg.IsSliceTiming
    set(handles.textSliceNumber,'Enable','on');
    set(handles.editSliceNumber,'Enable','on');
    set(handles.textSliceOrder,'Enable','on');
    set(handles.editSliceOrder,'Enable','on');
    set(handles.textReferSlice,'Enable','on');
    set(handles.editReferSlice,'Enable','on');
else
    set(handles.textSliceNumber,'Enable','off');
    set(handles.editSliceNumber,'Enable','off');
    set(handles.textSliceOrder,'Enable','off');
    set(handles.editSliceOrder,'Enable','off');
    set(handles.textReferSlice,'Enable','off');
    set(handles.editReferSlice,'Enable','off');
end

function UpdateDisplay_NuisanceRegression(handles)
set(handles.checkboxNuisanceRegression,'Value',handles.Cfg.IsCovremove);
set(handles.editPolynomiaTrend,'String',handles.Cfg.Covremove.PolynomialTrend);
switch handles.Cfg.Covremove.HeadMotion
    case 0
        set(handles.radiobuttonRigid6,'Value',0);
        set(handles.radiobuttonDerivative12,'Value',0);
        set(handles.radiobuttonFriston24,'Value',0);
    case 1
        set(handles.radiobuttonRigid6,'Value',1);
        set(handles.radiobuttonDerivative12,'Value',0);
        set(handles.radiobuttonFriston24,'Value',0);
    case 2
        set(handles.radiobuttonRigid6,'Value',0);
        set(handles.radiobuttonDerivative12,'Value',1);
        set(handles.radiobuttonFriston24,'Value',0);
    case 4
        set(handles.radiobuttonRigid6,'Value',0);
        set(handles.radiobuttonDerivative12,'Value',0);
        set(handles.radiobuttonFriston24,'Value',1);
end       
set(handles.checkboxScrubbingRegressor,'Value',handles.Cfg.Covremove.IsHeadMotionScrubbingRegressors);
set(handles.checkboxOtherCovariates,'Value',handles.Cfg.Covremove.IsOtherCovariates);
set(handles.checkboxAddMeanBack,'Value',handles.Cfg.Covremove.IsAddMeanBack);
set(handles.checkboxNonAgressiveRegressICAAROMANoise,'Value',handles.Cfg.NonAgressiveRegressICAAROMANoise);

if handles.Cfg.IsCovremove
    set(handles.textPolynomiaTrend,'Enable','on');
    set(handles.editPolynomiaTrend,'Enable','on');
    set(handles.textHeadMotionModel,'Enable','on');
    set(handles.radiobuttonRigid6,'Enable','on');
    set(handles.radiobuttonDerivative12,'Enable','on');
    set(handles.radiobuttonFriston24,'Enable','on');
    set(handles.checkboxScrubbingRegressor,'Enable','on');
    set(handles.pushbuttonNuisanceRegression,'Enable','on');
    set(handles.checkboxOtherCovariates,'Enable','on');
    set(handles.checkboxAddMeanBack,'Enable','on');
    set(handles.checkboxNonAgressiveRegressICAAROMANoise,'Enable','on');
else
     set(handles.textPolynomiaTrend,'Enable','off');
    set(handles.editPolynomiaTrend,'Enable','off');
    set(handles.textHeadMotionModel,'Enable','off');
    set(handles.radiobuttonRigid6,'Enable','off');
    set(handles.radiobuttonDerivative12,'Enable','off');
    set(handles.radiobuttonFriston24,'Enable','off');
    set(handles.checkboxScrubbingRegressor,'Enable','off');
    set(handles.pushbuttonNuisanceRegression,'Enable','off');
    set(handles.checkboxOtherCovariates,'Enable','off');
    set(handles.checkboxAddMeanBack,'Enable','off');
    set(handles.checkboxNonAgressiveRegressICAAROMANoise,'Enable','off');
end


function UpdateDisplay_ALFF(handles)
set(handles.checkboxALFFfALFF,'Value',handles.Cfg.IsCalALFF);
set(handles.editALFFBandLow,'String',handles.Cfg.CalALFF.AHighPass_LowCutoff);
set(handles.editALFFBandHigh,'String',handles.Cfg.CalALFF.ALowPass_HighCutoff);

if handles.Cfg.IsCalALFF
    set(handles.textALFFBand,'Enable','on');
    set(handles.editALFFBandLow,'Enable','on');
    set(handles.textALFFBandto,'Enable','on');
    set(handles.editALFFBandHigh,'Enable','on');
else
    set(handles.textALFFBand,'Enable','off');
    set(handles.editALFFBandLow,'Enable','off');
    set(handles.textALFFBandto,'Enable','off');
    set(handles.editALFFBandHigh,'Enable','off');
end
    

function UpdateDisplay_Filter(handles)
set(handles.checkboxFilter,'Value',handles.Cfg.IsFilter);
set(handles.editFilterBandLow,'String',handles.Cfg.Filter.AHighPass_LowCutoff);
set(handles.editFilterBandHigh,'String',handles.Cfg.Filter.ALowPass_HighCutoff);

if handles.Cfg.IsFilter
    set(handles.editFilterBandLow,'Enable','on');
    set(handles.textFilterBandTo,'Enable','on');
    set(handles.editFilterBandHigh,'Enable','on');
else
    set(handles.editFilterBandLow,'Enable','off');
    set(handles.textFilterBandTo,'Enable','off');
    set(handles.editFilterBandHigh,'Enable','off');
end


function UpdateDisplay_FC(handles)
set(handles.checkboxFC,'Value',handles.Cfg.IsCalFC);
set(handles.checkboxExtractROI,'Value',handles.Cfg.IsExtractROISignals);

if handles.Cfg.IsExtractROISignals || handles.Cfg.IsCalFC
    set(handles.pushbuttonDefineROI,'Enable','on');
else
    set(handles.pushbuttonDefineROI,'Enable','off');
end

function UpdateDisplay_RemoveTimePoint(handles)
set(handles.editRemoveTimePoint,'String',handles.Cfg.RemoveFirstTimePoints);
set(handles.checkboxRemoveTimePoint,'Value',handles.Cfg.IsRemoveFirstTimePoints);

if handles.Cfg.IsRemoveFirstTimePoints
    set(handles.editRemoveTimePoint,'Enable','on');
else
    set(handles.editRemoveTimePoint,'Enable','off');
end


        
%% Check if the configuration parameters is correct
function [handles, CheckingPass]=CheckCfgParametersBeforeRun(handles)    
    CheckingPass=0;
    if isempty (handles.Cfg.WorkingDir)
        uiwait(msgbox('Please set the working directory!','Configuration parameters checking','warn'));
        return
    end
    
    if (handles.Cfg.IsNeedConvertFunDCM2IMG==1)
        handles.Cfg.StartingDirName='FunRaw';
        if 7==exist([handles.Cfg.WorkingDir,filesep,'FunRaw'],'dir')
            if isempty (handles.Cfg.SubjectID)
                Dir=dir([handles.Cfg.WorkingDir,filesep,'FunRaw']);
                if strcmpi(Dir(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
                    StartIndex=4;
                else
                    StartIndex=3;
                end
                for i=StartIndex:length(Dir)
                    handles.Cfg.SubjectID=[handles.Cfg.SubjectID;{Dir(i).name}];
                end
            end
        else
            uiwait(msgbox('Please arrange each subject''s DICOM images in one directory, and then put them in "FunRaw" directory under the working directory!','Configuration parameters checking','warn'));
            return
        end
    else
        if 7==exist([handles.Cfg.WorkingDir,filesep,handles.Cfg.StartingDirName],'dir')
            if isempty (handles.Cfg.SubjectID)
                Dir=dir([handles.Cfg.WorkingDir,filesep,handles.Cfg.StartingDirName]);
                if strcmpi(Dir(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
                    StartIndex=4;
                else
                    StartIndex=3;
                end
                for i=StartIndex:length(Dir)
                    if Dir(i).isdir
                        if ~strcmpi(Dir(i).name,'logs')
                            handles.Cfg.SubjectID=[handles.Cfg.SubjectID;{Dir(i).name}];
                        end
                    end
                end
            end
            
            if (handles.Cfg.TimePoints)>0 && ~strcmpi(handles.Cfg.StartingDirName,'fmriprep') % If the number of time points is not set at 0, then check the number of time points.
                if ~(strcmpi(handles.Cfg.StartingDirName,'T1Raw') || strcmpi(handles.Cfg.StartingDirName,'T1Img') || strcmpi(handles.Cfg.StartingDirName,'T1NiiGZ') || strcmpi(handles.Cfg.StartingDirName,'BIDS') ) %If not just use for VBM, check if the time points right. %YAN Chao-Gan, 111130. Also add T1 .nii.gz support.
                    
                    if ~(strcmpi(handles.Cfg.StartingDirName,'FunImg'))
                        DirImg=dir([handles.Cfg.WorkingDir,filesep,handles.Cfg.StartingDirName,filesep,handles.Cfg.SubjectID{1},filesep,'*.gii']);
                        Gii  = gifti([handles.Cfg.WorkingDir,filesep,handles.Cfg.StartingDirName,filesep,handles.Cfg.SubjectID{1},filesep,DirImg(1).name]);
                        NTimePoints = size(Gii.cdata,2);
                        
                    else
                        DirImg=dir([handles.Cfg.WorkingDir,filesep,handles.Cfg.StartingDirName,filesep,handles.Cfg.SubjectID{1},filesep,'*.img']);
                        if isempty(DirImg)  %YAN Chao-Gan, 111114. Also support .nii files.
                            DirImg=dir([handles.Cfg.WorkingDir,filesep,handles.Cfg.StartingDirName,filesep,handles.Cfg.SubjectID{1},filesep,'*.nii']);
                            if length(DirImg)>1
                                NTimePoints = length(DirImg);
                            elseif length(DirImg)==1
                                Nii  = nifti([handles.Cfg.WorkingDir,filesep,handles.Cfg.StartingDirName,filesep,handles.Cfg.SubjectID{1},filesep,DirImg(1).name]);
                                NTimePoints = size(Nii.dat,4);
                            elseif length(DirImg)==0
                                DirImg=dir([handles.Cfg.WorkingDir,filesep,handles.Cfg.StartingDirName,filesep,handles.Cfg.SubjectID{1},filesep,'*.nii.gz']);% Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                                if length(DirImg)==1
                                    gunzip([handles.Cfg.WorkingDir,filesep,handles.Cfg.StartingDirName,filesep,handles.Cfg.SubjectID{1},filesep,DirImg(1).name]);
                                    Nii  = nifti([handles.Cfg.WorkingDir,filesep,handles.Cfg.StartingDirName,filesep,handles.Cfg.SubjectID{1},filesep,DirImg(1).name(1:end-3)]);
                                    delete([handles.Cfg.WorkingDir,filesep,handles.Cfg.StartingDirName,filesep,handles.Cfg.SubjectID{1},filesep,DirImg(1).name(1:end-3)]);
                                    NTimePoints = size(Nii.dat,4);
                                else
                                    uiwait(msgbox(['Too many .nii.gz files in each subject''s directory, should only keep one 4D .nii.gz file.'],'Configuration parameters checking','warn')); %YAN Chao-Gan 090922, %uiwait(msgbox(['The detected time points of subject "',handles.Cfg.SubjectID{1},'" is: ',num2str(length(DirImg)),', it is different from the predefined time points: ',num2str(handles.Cfg.TimePoints-handles.Cfg.RemoveFirstTimePoints),'. Please check your data!'],'Configuration parameters checking','warn'));
                                    return
                                end
                            end
                        else
                            NTimePoints = length(DirImg);
                        end
                        
                    end
                    
                    if NTimePoints~=(handles.Cfg.TimePoints) %YAN Chao-Gan 090922, %if length(DirImg)~=(handles.Cfg.TimePoints-handles.Cfg.RemoveFirstTimePoints)
                        uiwait(msgbox(['The detected time points of subject "',handles.Cfg.SubjectID{1},'" is: ',num2str(NTimePoints),', it is different from the predefined time points: ',num2str(handles.Cfg.TimePoints),'. Please check your data!'],'Configuration parameters checking','warn')); %YAN Chao-Gan 090922, %uiwait(msgbox(['The detected time points of subject "',handles.Cfg.SubjectID{1},'" is: ',num2str(length(DirImg)),', it is different from the predefined time points: ',num2str(handles.Cfg.TimePoints-handles.Cfg.RemoveFirstTimePoints),'. Please check your data!'],'Configuration parameters checking','warn'));
                        return
                    end
                end
            end
        else
            uiwait(msgbox(['Please arrange each subject''s NIFTI images in one directory, and then put them in your defined Starting Directory Name "',handles.Cfg.StartingDirName,'" directory under the working directory!'],'Configuration parameters checking','warn'));
            return
        end
        
    end %handles.Cfg.IsNeedConvertFunDCM2IMG
    
    
    if handles.Cfg.TimePoints==0
        Answer=questdlg('If the Number of Time Points is set to 0, then DPABISurf will not check the number of time points. Do you want to skip the checking of number of time points?','Configuration parameters checking','Yes','No','Yes');
        if ~strcmpi(Answer,'Yes')
            return
        end
    end
    
    if handles.Cfg.TR==0
        Answer=questdlg('If TR is set to 0, then DPABISurf will retrieve the TR information from the NIfTI images. Are you sure the TR information in NIfTI images are correct?','Configuration parameters checking','Yes','No','Yes');
        if ~strcmpi(Answer,'Yes')
            return
        end
    end
    
    if (handles.Cfg.IsSliceTiming==1) && (handles.Cfg.SliceTiming.SliceNumber==0)
        if ~exist([handles.Cfg.WorkingDir,filesep,'SliceOrderInfo.tsv'])==2 % YAN Chao-Gan, 130524. Read the slice timing information from a tsv file (Tab-separated values)
            Answer=questdlg('SliceOrderInfo.tsv (under working directory) is not detected. Please go {DPARSF}/Docs/SliceOrderInfo.tsv_Instruction.txt for instructions to allow different slice timing correction for different participants. If SliceNumber is set to 0 while SliceOrderInfo.tsv is not set, the slice order is then assumed as interleaved scanning: [1:2:SliceNumber,2:2:SliceNumber]. The reference slice is set to the slice acquired at the middle time point, i.e., SliceOrder(ceil(SliceNumber/2)). SHOULD BE EXTREMELY CAUTIOUS!!! Are you sure want to continue?','Configuration parameters checking','Yes','No','No');
            if ~strcmpi(Answer,'Yes')
                return
            end
        end
    end
    
    CheckingPass=1;
    UpdateDisplay(handles);
            
    
%% Update All the uiControls' display on the GUI
function UpdateDisplay(handles)

set(handles.editWorkDir,'String',handles.Cfg.WorkingDir);
set(handles.listboxParticipantID,'String',handles.Cfg.SubjectID);
set(handles.editTR,'String',handles.Cfg.TR);
set(handles.editTimePoint,'String',handles.Cfg.TimePoints);
set(handles.checkboxEPIDCM2NII,'Value',handles.Cfg.IsNeedConvertFunDCM2IMG);
set(handles.checkboxT1DCM2NII,'Value',handles.Cfg.IsNeedConvertT1DCM2IMG);

UpdateDisplay_RemoveTimePoint(handles);

set(handles.checkboxConvert2BIDS,'Value',handles.Cfg.IsConvert2BIDS);
set(handles.checkboxfmriprep,'Value',handles.Cfg.Isfmriprep);
set(handles.checkboxLowMemory,'Value',handles.Cfg.IsLowMem);

switch handles.Cfg.Normalize.VoxelSize
    case '2mm'
        set(handles.popupmenuNormalizeVoxelSize,'Value',1);
    case '1mm'
        set(handles.popupmenuNormalizeVoxelSize,'Value',2);
    case 'native'
        set(handles.popupmenuNormalizeVoxelSize,'Value',3);
end

UpdateDisplay_SliceTiming(handles);
       
set(handles.checkboxICA_AROMA,'Value',handles.Cfg.IsICA_AROMA);
set(handles.editMaskLH,'String',handles.Cfg.MaskFileSurfLH);
set(handles.editMaskRH,'String',handles.Cfg.MaskFileSurfRH);
set(handles.editMaskVolume, 'String',handles.Cfg.MaskFileVolu);

set(handles.checkboxOrganizefmriprep,'Value',handles.Cfg.IsOrganizefmriprepResults);

UpdateDisplay_NuisanceRegression(handles);

UpdateDisplay_Smooth(handles);

UpdateDisplay_ALFF(handles);

UpdateDisplay_Filter(handles);

set(handles.checkboxScubbing,'Value',handles.Cfg.IsScrubbing);

UpdateDisplay_ReHo(handles);

set(handles.checkboxDC,'Value',handles.Cfg.IsCalDegreeCentrality);

set(handles.checkboxFC,'Value',handles.Cfg.IsCalFC);
set(handles.checkboxExtractROI,'Value',handles.Cfg.IsExtractROISignals);
if handles.Cfg.IsExtractROISignals || handles.Cfg.IsCalFC
    set(handles.pushbuttonDefineROI,'Enable','on');
else
    set(handles.pushbuttonDefineROI,'Enable','off');
end

set(handles.editParallelWorker,'String',handles.Cfg.ParallelWorkersNumber);
set(handles.editFuncSession,'String',handles.Cfg.FunctionalSessionNumber);
set(handles.editStartingDirName,'String',handles.Cfg.StartingDirName);


% --- Executes on button press in pushbuttonFieldMap.
function pushbuttonFieldMap_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonFieldMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiwait(msgbox({'';...
    'If you want to perform FieldMap Correction, you need to arrange each subject''s FieldMap DICOM files in one directory, and then put them in "FieldMap" directory under the working directory. i.e.:';...
    '{Working Directory}\FieldMap\PhaseDiffRaw\Subject001\xxxxx001.dcm';...
    '{Working Directory}\FieldMap\PhaseDiffRaw\Subject001\xxxxx002.dcm';...
    '...';...
    '{Working Directory}\FieldMap\PhaseDiffRaw\Subject002\xxxxx001.dcm';...
    '{Working Directory}\FieldMap\PhaseDiffRaw\Subject002\xxxxx002.dcm';...
    '...';...
    '{Working Directory}\FieldMap\Magnitude1Raw\Subject001\xxxxx001.dcm';...
    '{Working Directory}\FieldMap\Magnitude1Raw\Subject001\xxxxx002.dcm';...
    '...';...
    '{Working Directory}\FieldMap\Magnitude1Raw\Subject002\xxxxx001.dcm';...
    '{Working Directory}\FieldMap\Magnitude1Raw\Subject002\xxxxx002.dcm';...
    '...';...
    '...';...
    },'FieldMap Correction'));

if isfield(handles.Cfg,'FieldMap')
    handles.Cfg.FieldMap = DPABISurf_FieldMap(handles.Cfg.FieldMap);
else
    handles.Cfg.FieldMap = DPABISurf_FieldMap;
end
guidata(hObject, handles);
UpdateDisplay(handles);
