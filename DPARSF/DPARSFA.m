function varargout = DPARSFA(varargin)
%Data Processing Assistant for Resting-State fMRI (DPARSF) Advanced Edition (alias: DPARSFA) GUI by YAN Chao-Gan
%-----------------------------------------------------------
%	Copyright(c) 2009; GNU GENERAL PUBLIC LICENSE
%   The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962; 
%   Child Mind Institute, 445 Park Avenue, New York, NY 10022; 
%   The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016
%	State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%	Written by YAN Chao-Gan
%	http://rfmri.org/DPARSF
%   $mail     =ycg.yan@gmail.com
%-----------------------------------------------------------
% 	Mail to Author:  <a href="ycg.yan@gmail.com">YAN Chao-Gan</a> 

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPARSFA_OpeningFcn, ...
                   'gui_OutputFcn',  @DPARSFA_OutputFcn, ...
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


% --- Executes just before DPARSFA is made visible.
function DPARSFA_OpeningFcn(hObject, eventdata, handles, varargin)
    Release='V5.1_201001';
    handles.Release = Release; % Will be used in mat file version checking (e.g., in function SetLoadedData)
    
    if ispc
        UserName =getenv('USERNAME');
    else
        UserName =getenv('USER');
    end
    Datetime=fix(clock);
    fprintf('Welcome: %s, %.4d-%.2d-%.2d %.2d:%.2d \n', UserName,Datetime(1),Datetime(2),Datetime(3),Datetime(4),Datetime(5));
    fprintf('Data Processing Assistant for Resting-State fMRI (DPARSF) Advanced Edition (alias: DPARSFA). \nRelease = %s\n',Release);
    fprintf('Copyright(c) 2009; GNU GENERAL PUBLIC LICENSE\n');
    fprintf('Institute of Psychology, Chinese Academy of Sciences, 16 Lincui Road, Chaoyang District, Beijing 100101, China; ');
    fprintf('The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962; Child Mind Institute, 445 Park Avenue, New York, NY 10022; The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016');
    fprintf('State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China\n');
    fprintf('Mail to Author:  <a href="ycg.yan@gmail.com">YAN Chao-Gan</a>\n<a href="http://rfmri.org/DPARSF">http://rfmri.org/DPARSF</a>\n');
    fprintf('-----------------------------------------------------------\n');
    fprintf('Citing Information:\nIf you think DPARSFA is useful for your work, citing it in your paper would be greatly appreciated.\nSomething like "... The preprocessing was performed using the Data Processing Assistant for Resting-State fMRI (DPARSF, Yan and Zang 2010, http://rfmri.org/DPARSF), which is based on Statistical Parametric Mapping (SPM, http://www.fil.ion.ucl.ac.uk/spm) and the toolbox for Data Processing & Analysis of Brain Imaging (DPABI, Yan et al. 2016, http://rfmri.org/DPABI)..."\nReferences: Yan C and Zang Y (2010) DPARSF: a MATLAB toolbox for "pipeline" data analysis of resting-state fMRI. Front. Syst. Neurosci. 4:13. doi:10.3389/fnsys.2010.00013; \nYan, C.G., Wang, X.D., Zuo, X.N., Zang, Y.F., 2016. DPABI: Data Processing & Analysis for (Resting-State) Brain Imaging. Neuroinformatics 14, 339-351. doi: 10.1007/s12021-016-9299-4\n');
    
    
    [DPABILatestRelease WebStatus]=urlread('http://rfmri.org/DPABILatestRelease.txt');
    if WebStatus
        DPARSFMessage=urlread('http://rfmri.org/DPARSFMessage.txt');
        if ~isempty(DPARSFMessage)
            uiwait(msgbox(DPARSFMessage,'DPARSF Message'));
        end
        DPARSFMessageWeb=urlread('http://rfmri.org/DPARSFMessageWeb.txt');
        if ~isempty(DPARSFMessageWeb)
            web(DPARSFMessageWeb,'-browser');
        end
    end
    
    FullMatlabVersion = sscanf(version,'%d.%d.%d.%d%s');
    if (FullMatlabVersion(1)*1000+FullMatlabVersion(2)>=8*1000+4)
        handles.hContextMenu =uicontextmenu(handles.figDPARSFAMain);  %YAN Chao-Gan, 20180801. To prevent an invalid parent problem when calling through mokey module.
    else
        handles.hContextMenu =uicontextmenu;
    end
    set(handles.listSubjectID, 'UIContextMenu', handles.hContextMenu);	%Added by YAN Chao-Gan 091110. Added popup menu to delete selected subject by right click.
	uimenu(handles.hContextMenu, 'Label', 'Remove the selected participant', 'Callback', 'DPARSFA(''DeleteSelectedSubjectID'',gcbo,[], guidata(gcbo))');
    uimenu(handles.hContextMenu, 'Label', 'Remove all the participants', 'Callback', 'DPARSFA(''DeleteAllSubjects'',gcbo,[], guidata(gcbo))');
    uimenu(handles.hContextMenu, 'Label', 'Load participant ID from a text file', 'Callback', 'DPARSFA(''LoadSubIDFromTextFile'',gcbo,[], guidata(gcbo))'); % YAN Chao-Gan 120809
    uimenu(handles.hContextMenu, 'Label', 'Save participant ID to a text file', 'Callback', 'DPARSFA(''SaveSubIDToTextFile'',gcbo,[], guidata(gcbo))'); % YAN Chao-Gan 120809

    
    TemplateParameters={'Template Parameters'...
        'V5: Calculate in MNI Space (warp by DARTEL)'...
        'Calculate in MNI Space (warp by DARTEL)'...
        'Calculate in MNI Space (warp by information from unified segmentation)'...
        'Calculate in MNI Space: TRADITIONAL order'...
        'Calculate in Original Space (warp by DARTEL)'...
        'Calculate in Original Space (warp by information from unified segmentation)'...
        'Calculate ReHo and DC only (Smooth later)'...
        'Intraoperative Processing'...
        'Task fMRI data preprocessing'...
        'VBM (New Segment and DARTEL)'...
        'VBM (unified segmentation)'...
        'Blank'};
    set(handles.popupmenuTemplateParameters,'String',TemplateParameters);
    
    if (~ispc) && (~ismac)
        TipString = sprintf(['Template Parameters\n'...
            'V5: Calculate in MNI Space (warp by DARTEL)\n'...
            'Calculate in MNI Space (warp by DARTEL)\n'...
            'Calculate in MNI Space (warp by information from unified segmentation)\n'...
            'Calculate in MNI Space: TRADITIONAL order\n'...
            'Calculate in Original Space (warp by DARTEL)\n'...
            'Calculate in Original Space (warp by information from unified segmentation)\n'...
            'Calculate ReHo and DC only (Smooth later)\n'...
            'Intraoperative Processing\n'...
            'Task fMRI data preprocessing\n'...
            'VBM (New Segment and DARTEL)\n'...
            'VBM (unified segmentation)\n'...
            'Blank']);
        set(handles.popupmenuTemplateParameters,'ToolTipString',TipString);
    end
    
    handles.Cfg.DPARSFVersion=Release;
    handles.Cfg.WorkingDir=pwd;
    handles.Cfg.DataProcessDir=handles.Cfg.WorkingDir;
    handles.Cfg.SubjectID={};
    handles.Cfg.TimePoints=0;
    handles.Cfg.TR=0;
    handles.Cfg.IsNeedConvertFunDCM2IMG=1;
    handles.Cfg.IsNeedConvertT1DCM2IMG=1;
    handles.Cfg.IsBIDStoDPARSF=0;
    
    handles.Cfg.IsApplyDownloadedReorientMats=0; %YAN Chao-Gan, 130612.
    %handles.Cfg.IsNeedConvert4DFunInto3DImg=0;
    handles.Cfg.IsRemoveFirstTimePoints=1;
    handles.Cfg.RemoveFirstTimePoints=10;
    handles.Cfg.IsSliceTiming=1;
    handles.Cfg.SliceTiming.SliceNumber=0;
    %handles.Cfg.SliceTiming.TR=handles.Cfg.TR;
    %handles.Cfg.SliceTiming.TA=handles.Cfg.SliceTiming.TR-(handles.Cfg.SliceTiming.TR/handles.Cfg.SliceTiming.SliceNumber);
    handles.Cfg.SliceTiming.SliceOrder=[1:2:33,2:2:32];
    handles.Cfg.SliceTiming.ReferenceSlice=0;
    handles.Cfg.IsRealign=1;
    handles.Cfg.IsCalVoxelSpecificHeadMotion=1;
    handles.Cfg.IsNeedReorientFunImgInteractively=1;
    
    
    %handles.Cfg.IsNeedUnzipT1IntoT1Img=0;
    handles.Cfg.IsNeedReorientCropT1Img=0;
    handles.Cfg.IsNeedReorientT1ImgInteractively=1;
    
    handles.Cfg.IsBet=1;
    handles.Cfg.IsAutoMask=1;
    
    handles.Cfg.IsNeedT1CoregisterToFun=1;
    handles.Cfg.IsNeedReorientInteractivelyAfterCoreg=0;
    
    handles.Cfg.IsSegment=2;
    handles.Cfg.Segment.AffineRegularisationInSegmentation='mni';
    
    handles.Cfg.IsDARTEL=1; 

    handles.Cfg.IsCovremove=1;
    handles.Cfg.Covremove.Timing='AfterRealign';  %Another option: AfterNormalize  %YAN Chao-Gan, since DPARSFA3.0, the another option is modified to After normalize but before filtering. Previous was: %AfterNormalizeFiltering
    handles.Cfg.Covremove.PolynomialTrend=1;
    handles.Cfg.Covremove.HeadMotion=1;
    handles.Cfg.Covremove.IsHeadMotionScrubbingRegressors=0;
    handles.Cfg.Covremove.HeadMotionScrubbingRegressors.FDType='FD_Power';
    handles.Cfg.Covremove.HeadMotionScrubbingRegressors.FDThreshold=0.5;
    handles.Cfg.Covremove.HeadMotionScrubbingRegressors.PreviousPoints=1;
    handles.Cfg.Covremove.HeadMotionScrubbingRegressors.LaterPoints=2;
    
%     handles.Cfg.Covremove.WholeBrain=0;
%     handles.Cfg.Covremove.CSF=1;
%     handles.Cfg.Covremove.WhiteMatter=1;
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
    
    handles.Cfg.Covremove.OtherCovariatesROI = [];
    handles.Cfg.Covremove.IsAddMeanBack = 0; %YAN Chao-Gan, 160415: Add the option of "Add Mean Back".
    
    handles.Cfg.IsFilter=1;
    handles.Cfg.Filter.Timing='AfterNormalize'; %Another option: BeforeNormalize
    handles.Cfg.Filter.ALowPass_HighCutoff=0.08;
    handles.Cfg.Filter.AHighPass_LowCutoff=0.01;
    handles.Cfg.Filter.AAddMeanBack='Yes';
    
    handles.Cfg.IsNormalize=3; 
    handles.Cfg.Normalize.Timing='OnResults'; %Another option: OnFunctionalData
    handles.Cfg.Normalize.BoundingBox=[-90 -126 -72;90 90 108];
    handles.Cfg.Normalize.VoxSize=[3 3 3];

    handles.Cfg.IsSmooth=1;
    handles.Cfg.Smooth.Timing='OnResults'; %Another option: OnFunctionalData
    handles.Cfg.Smooth.FWHM=[4 4 4];
    
    handles.Cfg.MaskFile ='Default';
    
    handles.Cfg.IsWarpMasksIntoIndividualSpace=1;
    
    handles.Cfg.IsDetrend=0; 
    
    handles.Cfg.IsCalALFF=1;
    %handles.Cfg.CalALFF.ASamplePeriod=2;
    handles.Cfg.CalALFF.AHighPass_LowCutoff=0.01;
    handles.Cfg.CalALFF.ALowPass_HighCutoff=0.08;
    %handles.Cfg.CalALFF.AMaskFilename='Default';
    %handles.Cfg.CalALFF.mALFF_1=1;
    %handles.Cfg.IsCalfALFF=1;
    %handles.Cfg.CalfALFF.ASamplePeriod=2;
    %handles.Cfg.CalfALFF.AHighPass_LowCutoff=0.01;
    %handles.Cfg.CalfALFF.ALowPass_HighCutoff=0.08;
    %handles.Cfg.CalfALFF.AMaskFilename='Default';
    %handles.Cfg.CalfALFF.mfALFF_1=1;
    
    handles.Cfg.IsScrubbing=0;
    handles.Cfg.Scrubbing.Timing='AfterPreprocessing';
    handles.Cfg.Scrubbing.FDType='FD_Power';
    handles.Cfg.Scrubbing.FDThreshold=0.5;
    handles.Cfg.Scrubbing.PreviousPoints=1;
    handles.Cfg.Scrubbing.LaterPoints=2;
    handles.Cfg.Scrubbing.ScrubbingMethod='cut';
    
    handles.Cfg.IsCalReHo=1;
    handles.Cfg.CalReHo.ClusterNVoxel=27;
    handles.Cfg.CalReHo.SmoothReHo=0; %YAN Chao-Gan, 121225.
    %handles.Cfg.CalReHo.AMaskFilename='Default';
    %handles.Cfg.CalReHo.smReHo=1;
    %handles.Cfg.CalReHo.mReHo_1=1;

    handles.Cfg.IsCalDegreeCentrality=1;
    handles.Cfg.CalDegreeCentrality.rThreshold=0.25;

    handles.Cfg.IsCalFC=1;
    handles.Cfg.IsExtractROISignals=1;
    handles.Cfg.CalFC.IsMultipleLabel=0;
    handles.Cfg.CalFC.ROIDef=[];
    %handles.Cfg.CalFC.AMaskFilename='Default';
    handles.Cfg.IsDefineROIInteractively = 0;
    
    handles.Cfg.IsExtractAALTC=0;
    
    
    handles.Cfg.IsCWAS = 0;
    handles.Cfg.CWAS.Regressors = [];
    handles.Cfg.CWAS.iter = 0;
    
    
    handles.Cfg.IsNormalizeToSymmetricGroupT1Mean = 0; %YAN Chao-Gan, 121225.
    handles.Cfg.IsSmoothBeforeVMHC = 0;
    handles.Cfg.IsCalVMHC = 0;
    
    
    handles.Cfg.FunctionalSessionNumber=1; 
    handles.Cfg.StartingDirName='FunRaw';
    
    
    %YAN Chao-Gan 121225.
    %The Parameters set above is Template_CalculateInOriginalSpace_Warp_DARTEL.
    %Now the default parameter is setting back to calculation in MNI space.
    [ProgramPath, fileN, extn] = fileparts(which('DPARSFA.m'));

    %YAN Chao-Gan, 140804. Can input parameter .mat file.
    if nargin<4
        load([ProgramPath,filesep,'Jobmats',filesep,'Template_V4_CalculateInMNISpace_Warp_DARTEL.mat']);
        
        DPABIPath = fileparts(which('dpabi.m')); %YAN Chao-Gan, 151229. For set up ROIs, for the R-fMRI Project
        Cfg.CalFC.ROIDef = {[DPABIPath,filesep,'Templates',filesep,'aal.nii'];...
            [DPABIPath,filesep,'Templates',filesep,'HarvardOxford-cort-maxprob-thr25-2mm_YCG.nii'];...
            [DPABIPath,filesep,'Templates',filesep,'HarvardOxford-sub-maxprob-thr25-2mm_YCG.nii'];...
            [DPABIPath,filesep,'Templates',filesep,'CC200ROI_tcorr05_2level_all.nii'];...
            [DPABIPath,filesep,'Templates',filesep,'Zalesky_980_parcellated_compact.nii'];...
            [DPABIPath,filesep,'Templates',filesep,'Dosenbach_Science_160ROIs_Radius5_Mask.nii'];...
            [DPABIPath,filesep,'Templates',filesep,'BrainMask_05_91x109x91.img'];... %YAN Chao-Gan, 161201. Add global signal.
            [DPABIPath,filesep,'Templates',filesep,'Power_Neuron_264ROIs_Radius5_Mask.nii'];... %YAN Chao-Gan, 170104. Add Power 264.
            [DPABIPath,filesep,'Templates',filesep,'Schaefer2018_400Parcels_7Networks_order_FSLMNI152_1mm.nii'];... %YAN Chao-Gan, 180824. Add Schaefer 400.
            [DPABIPath,filesep,'Templates',filesep,'Tian2020_Subcortex_Atlas',filesep,'Tian_Subcortex_S4_3T.nii']}; %YAN Chao-Gan, 210414. Add Tian2020_Subcortex_Atlas.
        Cfg.CalFC.IsMultipleLabel = 1;
%         load([DPABIPath,filesep,'Templates',filesep,'Dosenbach_Science_160ROIs_Center.mat']);
%         ROICenter=Dosenbach_Science_160ROIs_Center;
%         ROIRadius=5;
%         for iROI=1:size(ROICenter,1)
%             ROIDef{iROI,1}=[ROICenter(iROI,:), ROIRadius];
%         end
%         Cfg.CalFC.ROIDef = [Cfg.CalFC.ROIDef;ROIDef];
    else
        load(varargin{1});
    end
    
    handles.Cfg=Cfg;
    handles.Cfg.WorkingDir =pwd;
    handles.Cfg.DataProcessDir =handles.Cfg.WorkingDir;
    
    
    handles.Cfg.ParallelWorkersNumber=0;%%%%
    % Check number of matlab workers. To start the matlabpool if Parallel Computation Toolbox is detected.
    
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

    
    guidata(hObject, handles);
    UpdateDisplay(handles);
	movegui(handles.figDPARSFAMain, 'center');
	set(handles.figDPARSFAMain,'Name','DPARSFA');
    
    if ~exist('spm.m')
        uiwait(msgbox('DPARSFA is based on SPM and Matlab, Please install Matlab 7.3 and SPM8 or later version at first.','DPARSFA'));
    else
        [SPMversionText,c]=spm('Ver');
        SPMversion=str2double(SPMversionText(end-1:end));
        if isnan(SPMversion)
            SPMversion=str2double(SPMversionText(end));
        end
        FullMatlabVersion = sscanf(version,'%d.%d.%d.%d%s');
        if (SPMversion<8)||(FullMatlabVersion(1)*1000+FullMatlabVersion(2)<7*1000+3)
            uiwait(msgbox('DPARSFA is based on SPM and Matlab, Please install Matlab 7.3 and SPM8 or later version at first.','DPARSFA'));
        end
    end
	
    % Make Display correct in Mac and linux 
    if ~ispc
        if ismac
            ZoomFactor=0.95;  %For Mac
        else
            ZoomFactor=0.8;  %For Linux
        end
        ObjectNames = fieldnames(handles);
        for i=1:length(ObjectNames);
            eval(['IsFontSizeProp=isprop(handles.',ObjectNames{i},',''FontSize'');']);
            if IsFontSizeProp
                eval(['PCFontSize=get(handles.',ObjectNames{i},',''FontSize'');']);
                FontSize=PCFontSize*ZoomFactor;
                eval(['set(handles.',ObjectNames{i},',''FontSize'',',num2str(FontSize),');']);
            end
        end
    end
    
    %Set up the callbacks, as I can not put the callback in guide (matlab_R2014a)
    set(handles.checkbox_IsAutoMask,'Callback','DPARSFA(''checkbox_IsAutoMask_Callback'',gcbo,[],guidata(gcbo))');
    set(handles.checkbox_IsBet,'Callback','DPARSFA(''checkbox_IsBet_Callback'',gcbo,[],guidata(gcbo))');
    set(handles.pushbutton_NuisanceSetting,'Callback','DPARSFA(''pushbutton_NuisanceSetting_Callback'',gcbo,[],guidata(gcbo))');
    set(handles.checkboxCovremoveAfterNormalize,'Callback','DPARSFA(''checkboxCovremoveAfterNormalize_Callback'',gcbo,[],guidata(gcbo))');
    
    set(handles.checkboxSmoothBeforeVMHC,'Callback','DPARSFA(''checkboxSmoothBeforeVMHC_Callback'',gcbo,[],guidata(gcbo))'); %YAN Chao-Gan, 151120
    set(handles.checkboxCovremoveIsAddMeanBack,'Callback','DPARSFA(''checkboxCovremoveIsAddMeanBack_Callback'',gcbo,[],guidata(gcbo))'); %YAN Chao-Gan, 160415
    set(handles.pushbuttonFieldMapCorrection,'Callback','DPARSFA(''pushbuttonFieldMapCorrection_Callback'',gcbo,[],guidata(gcbo))');
    set(handles.checkboxBIDStoDPARSF,'Callback','DPARSFA(''checkboxBIDStoDPARSF_Callback'',gcbo,[],guidata(gcbo))');
    
    % Choose default command line output for DPARSFA
    handles.output = hObject;	    
    guidata(hObject, handles);% Update handles structure

	% UIWAIT makes DPARSFA wait for user response (see UIRESUME)
	% uiwait(handles.figDPARSFAMain);

% --- Outputs from this function are returned to the command line.
function varargout = DPARSFA_OutputFcn(hObject, eventdata, handles) 
	% Get default command line output from handles structure
	varargout{1} = handles.output;

   
function edtWorkingDir_Callback(hObject, eventdata, handles)
	theDir =get(hObject, 'String');	
	SetWorkingDir(hObject,handles, theDir);

function btnSelectWorkingDir_Callback(hObject, eventdata, handles)
%     uiwait(msgbox({'DPARSF''s standard processing steps:';...
%         '1. Convert DICOM files to NIFTI images. 2. Remove First Time Points. 3. Slice Timing. 4. Realign. 5. Normalize. 6. Smooth (optional). 7. Detrend. 8. Filter. 9. Calculate ReHo, ALFF, fALFF (optional). 10. Regress out the Covariables (optional). 11. Calculate Functional Connectivity (optional). 12. Extract AAL or ROI time courses for further analysis (optional).';...
%         '';...
%         'All the input image files should be arranged in the working directory, and DPARSF will put all the output results in the working directory.';...
%         '';...
%         'For example, if you start with raw DICOM images, you need to arrange each subject''s fMRI DICOM images in one directory, and then put them in "FunRaw" directory under the working directory. i.e.:';...
%         '{Working Directory}\FunRaw\Subject001\xxxxx001.dcm';...
%         '{Working Directory}\FunRaw\Subject001\xxxxx002.dcm';...
%         '...';...
%         '{Working Directory}\FunRaw\Subject002\xxxxx001.dcm';...
%         '{Working Directory}\FunRaw\Subject002\xxxxx002.dcm';...
%         '...';...
%         '...';...
%         'Please do not name your subjects initiated with letter "a", DPARSF will face difficulties to distinguish the images before and after slice timing if the subjects'' name has an "a" initial.';...
%         '';...
%         'If you start with NIFTI images (.hdr/.img pairs) before slice timing, you need to arrange each subject''s fMRI NIFTI images in one directory, and then put them in "FunImg" directory under the working directory. i.e.:';...
%         '{Working Directory}\FunImg\Subject001\xxxxx001.img';...
%         '{Working Directory}\FunImg\Subject001\xxxxx002.img';...
%         '...';...
%         '{Working Directory}\FunImg\Subject002\xxxxx001.img';...
%         '{Working Directory}\FunImg\Subject002\xxxxx002.img';...
%         '...';...
%         '...';...
%         '';...
%         'If you start with NIFTI images after normalization, you need to arrange each subject''s NIFTI images in one directory, and then put them in "FunImgNormalized" directory under the working directory.';...
%         'If you start with NIFTI images after smooth, you need to arrange each subject''s NIFTI images in one directory, and then put them in "FunImgNormalizedSmoothed" directory under the working directory.';...
%         'If you start with NIFTI images after filter, you need to arrange each subject''s NIFTI images in one directory, and then put them in "FunImgNormalizedSmoothedDetrendedFiltered" (or "FunImgNormalizedDetrendedFiltered" if without smooth) directory under the working directory.';...
%         },'Please select the Working directory'));
	theDir =handles.Cfg.WorkingDir;
	theDir =uigetdir(theDir, 'Please select the Working directory: ');
	if ~isequal(theDir, 0)
		SetWorkingDir(hObject,handles, theDir);	
	end	
	
function SetWorkingDir(hObject, handles, ADir)
	if 7==exist(ADir,'dir')
		handles.Cfg.WorkingDir =ADir;
        handles.Cfg.DataProcessDir =handles.Cfg.WorkingDir;
		guidata(hObject, handles);
	    UpdateDisplay(handles);
    end
    handles=CheckCfgParameters(handles);
    guidata(hObject, handles);
    UpdateDisplay(handles);

function listSubjectID_Callback(hObject, eventdata, handles)
	theIndex =get(hObject, 'Value');

function listSubjectID_KeyPressFcn(hObject, eventdata, handles)
	%Delete the selected item when 'Del' is pressed
    key =get(handles.figDPARSFAMain, 'currentkey');
    if seqmatch({key},{'delete', 'backspace'})
       DeleteSelectedSubjectID(hObject, eventdata,handles);
    end   
	
function DeleteSelectedSubjectID(hObject, eventdata, handles)	
	theIndex =get(handles.listSubjectID, 'Value');
	if size(handles.Cfg.SubjectID, 1)==0 ...
		|| theIndex>size(handles.Cfg.SubjectID, 1),
		return;
	end
	theSubject     =handles.Cfg.SubjectID{theIndex, 1};
	tmpMsg=sprintf('Delete the Participant: "%s" ?', theSubject);
	if strcmp(questdlg(tmpMsg, 'Delete confirmation'), 'Yes')
		if theIndex>1,
			set(handles.listSubjectID, 'Value', theIndex-1);
		end
		handles.Cfg.SubjectID(theIndex, :)=[];
		if size(handles.Cfg.SubjectID, 1)==0
			handles.Cfg.SubjectID={};
		end	
		guidata(hObject, handles);
		UpdateDisplay(handles);
    end  

function DeleteAllSubjects(hObject, eventdata, handles)	
	tmpMsg=sprintf('Delete all the participants?');
	if strcmp(questdlg(tmpMsg, 'Delete confirmation'), 'Yes')
        handles.Cfg.SubjectID={};
		guidata(hObject, handles);
		UpdateDisplay(handles);
    end  

function LoadSubIDFromTextFile(hObject, eventdata, handles)
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
    
function SaveSubIDToTextFile(hObject, eventdata, handles)
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
    

function ReLoadSubjects(hObject, eventdata, handles)	
    handles.Cfg.SubjectID={};
    handles=CheckCfgParameters(handles);
    guidata(hObject, handles);
    UpdateDisplay(handles);
    
function editTimePoints_Callback(hObject, eventdata, handles)
    handles.Cfg.TimePoints =str2double(get(hObject,'String'));
    if handles.Cfg.TimePoints==0
        uiwait(msgbox({'If the Number of Time Points is set to 0, then DPARSFA will not check the number of time points. Please make sure the number of time points by yourself!';...
            },'Set Number of Time Points'));
    end
	guidata(hObject, handles);
    UpdateDisplay(handles);    
    
function editTR_Callback(hObject, eventdata, handles)
    handles.Cfg.TR =str2double(get(hObject,'String'));
    if handles.Cfg.TR==0
        uiwait(msgbox({'If TR is set to 0, then DPARSFA will retrieve the TR information from the NIfTI images. Please ensure the TR information in NIfTI images are correct!';...
            },'Set TR'));
    end
    %handles.Cfg.SliceTiming.TR=handles.Cfg.TR;
    %handles.Cfg.SliceTiming.TA=handles.Cfg.SliceTiming.TR-(handles.Cfg.SliceTiming.TR/handles.Cfg.SliceTiming.SliceNumber);
    %handles.Cfg.Filter.ASamplePeriod=handles.Cfg.TR;
    %handles.Cfg.CalALFF.ASamplePeriod=handles.Cfg.TR;
    %handles.Cfg.CalfALFF.ASamplePeriod=handles.Cfg.TR;
	guidata(hObject, handles);   
    UpdateDisplay(handles);    
    

function popupmenuTemplateParameters_Callback(hObject, eventdata, handles)
	[ProgramPath, fileN, extn] = fileparts(which('DPARSFA.m'));
    switch get(hObject, 'Value'),
        case 1,	%Template Parameters
            return;%Do nothing
        case 2, %V4 parameters: Calculate in MNI Space (warp by DARTEL)
            load([ProgramPath,filesep,'Jobmats',filesep,'Template_V4_CalculateInMNISpace_Warp_DARTEL.mat']);
            DPABIPath = fileparts(which('dpabi.m')); %For set up the ROIs, for the R-fMRI Maps Project
            Cfg.CalFC.ROIDef = {[DPABIPath,filesep,'Templates',filesep,'aal.nii'];...
                [DPABIPath,filesep,'Templates',filesep,'HarvardOxford-cort-maxprob-thr25-2mm_YCG.nii'];...
                [DPABIPath,filesep,'Templates',filesep,'HarvardOxford-sub-maxprob-thr25-2mm_YCG.nii'];...
                [DPABIPath,filesep,'Templates',filesep,'CC200ROI_tcorr05_2level_all.nii'];...
                [DPABIPath,filesep,'Templates',filesep,'Zalesky_980_parcellated_compact.nii'];...
                [DPABIPath,filesep,'Templates',filesep,'Dosenbach_Science_160ROIs_Radius5_Mask.nii'];...
                [DPABIPath,filesep,'Templates',filesep,'BrainMask_05_91x109x91.img'];... %YAN Chao-Gan, 161201. Add global signal.
                [DPABIPath,filesep,'Templates',filesep,'Power_Neuron_264ROIs_Radius5_Mask.nii'];... %YAN Chao-Gan, 170104. Add Power 264.
                [DPABIPath,filesep,'Templates',filesep,'Schaefer2018_400Parcels_7Networks_order_FSLMNI152_1mm.nii'];... %YAN Chao-Gan, 180824. Add Schaefer 400.
                [DPABIPath,filesep,'Templates',filesep,'Tian2020_Subcortex_Atlas',filesep,'Tian_Subcortex_S4_3T.nii']}; %YAN Chao-Gan, 210414. Add Tian2020_Subcortex_Atlas.
            
            
            Cfg.CalFC.IsMultipleLabel = 1;
%             load([DPABIPath,filesep,'Templates',filesep,'Dosenbach_Science_160ROIs_Center.mat']);
%             ROICenter=Dosenbach_Science_160ROIs_Center;
%             ROIRadius=5;
%             for iROI=1:size(ROICenter,1)
%                 ROIDef{iROI,1}=[ROICenter(iROI,:), ROIRadius];
%             end
%             Cfg.CalFC.ROIDef = [Cfg.CalFC.ROIDef;ROIDef];
        case 3, %Calculate in MNI Space (warp by DARTEL)
            load([ProgramPath,filesep,'Jobmats',filesep,'Template_CalculateInMNISpace_Warp_DARTEL.mat']);
        case 4, %Calculate in MNI Space (warp by information from unified segmentation)
            load([ProgramPath,filesep,'Jobmats',filesep,'Template_CalculateInMNISpace_Warp_UnifiedSegment.mat']);
        case 5, %Calculate in MNI Space: TRADITIONAL order
            load([ProgramPath,filesep,'Jobmats',filesep,'Template_CalculateInMNISpace_TraditionalOrder.mat']);
        case 6, %Calculate in Original Space (warp by DARTEL)
            load([ProgramPath,filesep,'Jobmats',filesep,'Template_CalculateInOriginalSpace_Warp_DARTEL.mat']);
        case 7, %Calculate in Original Space (warp by information from unified segmentation)
            load([ProgramPath,filesep,'Jobmats',filesep,'Template_CalculateInOriginalSpace_Warp_UnifiedSegment.mat']);
        case 8, %Calculate ReHo and DC only (Smooth later)
            load([ProgramPath,filesep,'Jobmats',filesep,'Template_CalculateReHoDC.mat']);
        case 9, %Intraoperative Processing
            load([ProgramPath,filesep,'Jobmats',filesep,'Template_IntraoperativeProcessing.mat']);
        case 10, %Task fMRI data preprocessing
            load([ProgramPath,filesep,'Jobmats',filesep,'Template_TaskfMRIPreprocessing.mat']);
        case 11, %VBM (New Segment and DARTEL)
            load([ProgramPath,filesep,'Jobmats',filesep,'Template_VBM_NewSegmentDARTEL.mat']);
        case 12, %VBM (unified segmentaition)
            load([ProgramPath,filesep,'Jobmats',filesep,'Template_VBM_UnifiedSegment.mat']);
        case 13, %Blank
            load([ProgramPath,filesep,'Jobmats',filesep,'Template_Blank.mat']);
    end
    

    Cfg.WorkingDir =pwd;
    Cfg.DataProcessDir = Cfg.WorkingDir;
    SetLoadedData(hObject,handles, Cfg);
    
function ckboxEPIDICOM2NIFTI_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsNeedConvertFunDCM2IMG = 1;
        %handles.Cfg.IsNeedConvert4DFunInto3DImg = 0;
	else	
		handles.Cfg.IsNeedConvertFunDCM2IMG = 0;
    end	
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);  
    
function checkboxT1DICOM2NIFTI_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')

        uiwait(msgbox({'';...
            'If you want DPARSFA to convert the T1 DICOM images into NIFTI images, you need to arrange each subject''s T1 DICOM images in one directory, and then put them in "T1Raw" directory under the working directory. i.e.:';...
            '{Working Directory}\T1Raw\Subject001\xxxxx001.dcm';...
            '{Working Directory}\T1Raw\Subject001\xxxxx002.dcm';...
            '...';...
            '{Working Directory}\T1Raw\Subject002\xxxxx001.dcm';...
            '{Working Directory}\T1Raw\Subject002\xxxxx002.dcm';...
            '...';...
            '...';...
            },'Convert the T1 DICOM images into NIFTI'));

		handles.Cfg.IsNeedConvertT1DCM2IMG=1;
        %handles.Cfg.IsNeedUnzipT1IntoT1Img=0;
        handles.Cfg.IsNeedReorientCropT1Img=0;
	else	
		handles.Cfg.IsNeedConvertT1DCM2IMG=0;
    end	
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);     
    
    
function checkboxBIDStoDPARSF_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsBIDStoDPARSF = 1;
        %handles.Cfg.IsNeedConvert4DFunInto3DImg = 0;
	else	
		handles.Cfg.IsBIDStoDPARSF = 0;
    end	
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);  
    

function checkboxApplyDownloadedReorientMats_Callback(hObject, eventdata, handles)
    if get(hObject,'Value')
        handles.Cfg.IsApplyDownloadedReorientMats = 1;
        if ~(7==exist([handles.Cfg.DataProcessDir,filesep,'DownloadedReorientMats'],'dir'))
            uiwait(msgbox({'No DownloadedReorientMats detected! The downloaded reorient mats (*_ReorientFunImgMat.mat and *_ReorientT1ImgMat.mat) should be put in DownloadedReorientMats folder under the working directory!';...
                },'Apply Downloaded Reorient Mats'));
        end
    else
        handles.Cfg.IsApplyDownloadedReorientMats = 0;
    end
    handles=CheckCfgParameters(handles);
    guidata(hObject, handles);
    UpdateDisplay(handles);
    
    
% function checkboxConvert4DFunInto3DImg_Callback(hObject, eventdata, handles)
% 	if get(hObject,'Value')
% 		handles.Cfg.IsNeedConvert4DFunInto3DImg = 1;
%         handles.Cfg.IsNeedConvertFunDCM2IMG = 0;
% 	else	
% 		handles.Cfg.IsNeedConvert4DFunInto3DImg = 0;
%     end	
%     handles=CheckCfgParameters(handles);
% 	guidata(hObject, handles);
% 	UpdateDisplay(handles); 
    
function checkboxRemoveFirstTimePoints_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsRemoveFirstTimePoints = 1;
	else	
		handles.Cfg.IsRemoveFirstTimePoints = 0;
    end	
    handles.Cfg.RemoveFirstTimePoints=handles.Cfg.RemoveFirstTimePoints*handles.Cfg.IsRemoveFirstTimePoints;
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);        
    
    
function editRemoveFirstTimePoints_Callback(hObject, eventdata, handles)
	handles.Cfg.RemoveFirstTimePoints =str2double(get(hObject,'String'));
    handles.Cfg.RemoveFirstTimePoints=handles.Cfg.RemoveFirstTimePoints*handles.Cfg.IsRemoveFirstTimePoints;
	guidata(hObject, handles);   
    UpdateDisplay(handles);      
    
function checkboxSliceTiming_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsSliceTiming = 1;
	else	
		handles.Cfg.IsSliceTiming = 0;
    end	
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles); 
    
function editSliceNumber_Callback(hObject, eventdata, handles)
	handles.Cfg.SliceTiming.SliceNumber =str2double(get(hObject,'String'));
    
    if handles.Cfg.SliceTiming.SliceNumber==0
        if exist([handles.Cfg.DataProcessDir,filesep,'SliceOrderInfo.tsv'])==2 % YAN Chao-Gan, 130524. Read the slice timing information from a tsv file (Tab-separated values)
        else
            uiwait(msgbox({'SliceOrderInfo.tsv (under working directory) is not detected. Please go {DPARSF}/Docs/SliceOrderInfo.tsv_Instruction.txt for instructions to allow different slice timing correction for different participants. If SliceNumber is set to 0 while SliceOrderInfo.tsv is not set, the slice order is then assumed as interleaved scanning: [1:2:SliceNumber,2:2:SliceNumber]. The reference slice is set to the slice acquired at the middle time point, i.e., SliceOrder(ceil(SliceNumber/2)). SHOULD BE EXTREMELY CAUTIOUS!!!';...
                },'Set Number of Slices'));
        end
    end
    
    %handles.Cfg.SliceTiming.TR = handles.Cfg.TR;
    %handles.Cfg.SliceTiming.TA=handles.Cfg.SliceTiming.TR-(handles.Cfg.SliceTiming.TR/handles.Cfg.SliceTiming.SliceNumber);
	guidata(hObject, handles);   
    UpdateDisplay(handles);  
   
function editSliceOrder_Callback(hObject, eventdata, handles)
	SliceOrder=get(hObject,'String');
    handles.Cfg.SliceTiming.SliceOrder =eval(['[',SliceOrder,']']);
	guidata(hObject, handles);   
    UpdateDisplay(handles);    
   
function editReferenceSlice_Callback(hObject, eventdata, handles)
	handles.Cfg.SliceTiming.ReferenceSlice =str2double(get(hObject,'String'));
    guidata(hObject, handles);
    UpdateDisplay(handles); 
    
function checkboxRealign_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsRealign = 1;
	else	
		handles.Cfg.IsRealign = 0;
    end	
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);  

function checkboxCalVoxelSpecificHeadMotion_Callback(hObject, eventdata, handles)
    if get(hObject,'Value')
        handles.Cfg.IsCalVoxelSpecificHeadMotion = 1;
    else
        handles.Cfg.IsCalVoxelSpecificHeadMotion = 0;
    end
    handles=CheckCfgParameters(handles);
    guidata(hObject, handles);
    UpdateDisplay(handles);
    
function checkboxReorientFunImgInteractively_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsNeedReorientFunImgInteractively = 1;
	else	
		handles.Cfg.IsNeedReorientFunImgInteractively = 0;
    end	
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);
    
function checkbox_IsAutoMask_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsAutoMask = 1;
	else	
		handles.Cfg.IsAutoMask = 0;
    end	
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);
    
function checkbox_IsBet_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsBet = 1;
	else	
		handles.Cfg.IsBet = 0;
    end	
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);
    

    
% function checkboxUnzipT1intoT1Img_Callback(hObject, eventdata, handles)
% 	if get(hObject,'Value')
%         
%         uiwait(msgbox({'';...
%             'If you want DPARSFA to unzip the T1 .nii.gz images, you need to arrange each subject''s T1 .nii.gz image in one directory, and then put them in "T1NiiGZ" directory under the working directory. i.e.:';...
%             '{Working Directory}\T1NiiGZ\Subject001\xxxxx001.nii.gz';...
%             '{Working Directory}\T1NiiGZ\Subject001\xxxxx002.nii.gz';...
%             '...';...
%             '{Working Directory}\T1NiiGZ\Subject002\xxxxx001.nii.gz';...
%             '{Working Directory}\T1NiiGZ\Subject002\xxxxx002.nii.gz';...
%             '...';...
%             '...';...
%             },'Unzip the T1 .nii.gz images'));
%         
% 		handles.Cfg.IsNeedUnzipT1IntoT1Img=1;
%         handles.Cfg.IsNeedReorientCropT1Img=1;
%         handles.Cfg.IsNeedConvertT1DCM2IMG=0;
% 	else	
% 		handles.Cfg.IsNeedUnzipT1IntoT1Img=0;
%     end	
%     handles=CheckCfgParameters(handles);
% 	guidata(hObject, handles);
% 	UpdateDisplay(handles);  
    
function checkboxReorientCropT1Img_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
        
        uiwait(msgbox({'';...
            'If you want DPARSFA to crop the T1 .nii/.nii.gz/.img images (Reorient to the nearest orthogonal direction to ''canonical space'' and remove excess air surrounding the individual as well as parts of the neck below the cerebellum, i.e., make co*.nii or co*.img), you need to arrange each subject''s T1 .nii/.img image in one directory, and then put them in "T1Img" directory under the working directory (if without previous steps). i.e.:';...
            '{Working Directory}\T1Img\Subject001\xxxxx001.nii';...
            '{Working Directory}\T1Img\Subject001\xxxxx002.nii';...
            '...';...
            '{Working Directory}\T1Img\Subject002\xxxxx001.nii';...
            '{Working Directory}\T1Img\Subject002\xxxxx002.nii';...
            '...';...
            '...';...
            },'Crop the T1 .nii/.img images'));
        
		handles.Cfg.IsNeedReorientCropT1Img=1;
        handles.Cfg.IsNeedConvertT1DCM2IMG=0;
	else	
		handles.Cfg.IsNeedReorientCropT1Img=0;
    end	
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);  
    
function checkboxReorientT1ImgInteractively_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
        
        uiwait(msgbox({'';...
            'If you want Re-orient T1 .nii/.nii.gz/.img images Interactively (reorient to a good head position and click on the anterior commissure), you need to arrange each subject''s T1 .nii/.img image in one directory, and then put them in "T1Img" directory under the working directory (if without previous steps). i.e.:';...
            '{Working Directory}\T1Img\Subject001\xxxxx001.nii';...
            '{Working Directory}\T1Img\Subject001\xxxxx002.nii';...
            '...';...
            '{Working Directory}\T1Img\Subject002\xxxxx001.nii';...
            '{Working Directory}\T1Img\Subject002\xxxxx002.nii';...
            '...';...
            '...';...
            },'Re-orient T1 .nii/.img images Interactively'));
        
        
		handles.Cfg.IsNeedReorientT1ImgInteractively = 1;
	else	
		handles.Cfg.IsNeedReorientT1ImgInteractively = 0;
    end	
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);
    
function checkboxT1CoregisterToFun_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsNeedT1CoregisterToFun=1;
	else	
		handles.Cfg.IsNeedT1CoregisterToFun=0;
    end	
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);     
    
% function checkboxReorientInteractivelyAfterCoreg_Callback(hObject, eventdata, handles)
% 	if get(hObject,'Value')
% 		handles.Cfg.IsNeedReorientInteractivelyAfterCoreg=1;
% 	else	
% 		handles.Cfg.IsNeedReorientInteractivelyAfterCoreg=0;
%     end	
%     handles=CheckCfgParameters(handles);
% 	guidata(hObject, handles);
% 	UpdateDisplay(handles);     

function checkboxSegment_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsSegment=1;
        handles.Cfg.IsDARTEL=0;
	else	
		handles.Cfg.IsSegment=0;
    end	
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles); 
    
function checkboxNewSegment_DARTEL_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
        uiwait(msgbox({'';...
            'New Segment and DARTEL will be performed. You will have the segmentation results (c1*, c2*, c3*, ...) and DARTEL results (Template*, u_r*, wc1*, wc2*, mwc1*, mwc2*, smwc1*, smwc2*, ...) under {Working Directory}\T1ImgNewSegment';...
            '';...
            'Note: the wc*, mwc*, smwc* files (normalized into MNI space) are produced by DARTEL but not New Segment (want warped tissue) itself. smwc* files are smoothed by DARTEL with smooth kernel of [8 8 8]';...
            '';...
            },'New Segment + DARTEL'));
		handles.Cfg.IsSegment=2;
        handles.Cfg.IsDARTEL=1;
	else	
		handles.Cfg.IsSegment=0;
        handles.Cfg.IsDARTEL=0;
    end	
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles); 

function radiobuttonEastAsian_Callback(hObject, eventdata, handles)  %Added by YAN Chao-Gan 091110. Use different Affine Regularisation in Segmentation: East Asian brains (eastern) or European brains (mni).
    handles.Cfg.Segment.AffineRegularisationInSegmentation='eastern';
    set(handles.radiobuttonEastAsian,'Value',1);
	set(handles.radiobuttonEuropean,'Value',0);
    drawnow;    
	guidata(hObject, handles);   
    UpdateDisplay(handles);  
    
function radiobuttonEuropean_Callback(hObject, eventdata, handles)  %Added by YAN Chao-Gan 091110. Use different Affine Regularisation in Segmentation: East Asian brains (eastern) or European brains (mni).
    handles.Cfg.Segment.AffineRegularisationInSegmentation='mni';
    set(handles.radiobuttonEastAsian,'Value',0);
	set(handles.radiobuttonEuropean,'Value',1);
    drawnow;    
	guidata(hObject, handles);   
    UpdateDisplay(handles);        
  
    
    
    

function checkboxCovremoveAfterRealign_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsCovremove = 1;
        handles.Cfg.Covremove.Timing='AfterRealign';
%         uiwait(msgbox({'Linear regression was performed to remove the effects of the nuisance covariates:';...
%             '1. Six head motion parameters: estimated by SPM5''s realign step. If you do not want to use SPM5'' realign, please arrange each subject''s rp*.txt file in one directory (named as same as its functional image directory) , and then put them in "RealignParameter" directory under the working directory. i.e.:';...
%             '{Working Directory}\RealignParameter\Subject001\rpxxxxx.txt';...
%             '...';...
%             '{Working Directory}\RealignParameter\Subject002\rpxxxxx.txt';...
%             '...';...
%             '2. Global mean signal: mask created by setting a threshold at 50% on SPM5''s apriori mask (brainmask.nii).';...
%             '3. White matter signal: mask created by setting a threshold at 90% on SPM5''s apriori mask (white.nii).';...
%             '4. Cerebrospinal fluid signal: mask created by setting a threshold at 70% on SPM5''s apriori mask (csf.nii).';...
%             '';...
%             %         'The regression was based on data after filter, if you want to regress another kind of data, please arrange each subject''s NIFTI images in one directory, and then put them in "FunImgNormalizedSmoothedDetrendedFiltered" (or "FunImgNormalizedDetrendedFiltered") directory under the working directory. i.e.:';...
%             %         '{Working Directory}\FunImgNormalizedSmoothedDetrendedFiltered\Subject001\xxx001.img';...
%             %         '{Working Directory}\FunImgNormalizedSmoothedDetrendedFiltered\Subject001\xxx002.img';...
%             %         '...';...
%             %         '{Working Directory}\FunImgNormalizedSmoothedDetrendedFiltered\Subject002\xxx001.img';...
%             %         '{Working Directory}\FunImgNormalizedSmoothedDetrendedFiltered\Subject002\xxx002.img';...
%             %         '...';...
%             '';...
%             },'Regress out nuisance covariates:'));
	else	
		handles.Cfg.IsCovremove = 0;
    end	
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);     
    
    
function checkboxCovremoveAfterNormalize_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsCovremove = 1;
        handles.Cfg.Covremove.Timing='AfterNormalize';
%         uiwait(msgbox({'Linear regression was performed to remove the effects of the nuisance covariates:';...
%             '1. Six head motion parameters: estimated by SPM5''s realign step. If you do not want to use SPM5'' realign, please arrange each subject''s rp*.txt file in one directory (named as same as its functional image directory) , and then put them in "RealignParameter" directory under the working directory. i.e.:';...
%             '{Working Directory}\RealignParameter\Subject001\rpxxxxx.txt';...
%             '...';...
%             '{Working Directory}\RealignParameter\Subject002\rpxxxxx.txt';...
%             '...';...
%             '2. Global mean signal: mask created by setting a threshold at 50% on SPM5''s apriori mask (brainmask.nii).';...
%             '3. White matter signal: mask created by setting a threshold at 90% on SPM5''s apriori mask (white.nii).';...
%             '4. Cerebrospinal fluid signal: mask created by setting a threshold at 70% on SPM5''s apriori mask (csf.nii).';...
%             '';...
%             %         'The regression was based on data after filter, if you want to regress another kind of data, please arrange each subject''s NIFTI images in one directory, and then put them in "FunImgNormalizedSmoothedDetrendedFiltered" (or "FunImgNormalizedDetrendedFiltered") directory under the working directory. i.e.:';...
%             %         '{Working Directory}\FunImgNormalizedSmoothedDetrendedFiltered\Subject001\xxx001.img';...
%             %         '{Working Directory}\FunImgNormalizedSmoothedDetrendedFiltered\Subject001\xxx002.img';...
%             %         '...';...
%             %         '{Working Directory}\FunImgNormalizedSmoothedDetrendedFiltered\Subject002\xxx001.img';...
%             %         '{Working Directory}\FunImgNormalizedSmoothedDetrendedFiltered\Subject002\xxx002.img';...
%             %         '...';...
%             '';...
%             },'Regress out nuisance covariates:'));
	else	
		handles.Cfg.IsCovremove = 0;
    end	
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);  
    
function editPolynomialTrend_Callback(hObject, eventdata, handles)
    handles.Cfg.Covremove.PolynomialTrend =str2double(get(hObject,'String'));
    uiwait(msgbox({'Set polynomial trends as regressors:';...
        '0: constant (no trends)';...
        '1: constant + linear trend (same as linear detrend)';...
        '2: constant + linear trend + quadratic trend';...
        '3: constant + linear trend + quadratic trend + cubic trend';...
        '...';...
        },'Set polynomial trends as regressors'));

    guidata(hObject, handles);
    UpdateDisplay(handles);

function radiobuttonRigidBody6_Callback(hObject, eventdata, handles)
    if handles.Cfg.Covremove.HeadMotion~=1
        handles.Cfg.Covremove.HeadMotion=1;
    else
        handles.Cfg.Covremove.HeadMotion=0;
    end
    drawnow;
    guidata(hObject, handles);
    UpdateDisplay(handles);
 
function radiobuttonDerivative12_Callback(hObject, eventdata, handles) %YAN Chao-Gan, 121225.
    if handles.Cfg.Covremove.HeadMotion~=2
        handles.Cfg.Covremove.HeadMotion=2;
    else
        handles.Cfg.Covremove.HeadMotion=0;
    end
    drawnow;
    guidata(hObject, handles);
    UpdateDisplay(handles);
    
    
function radiobuttonFriston24_Callback(hObject, eventdata, handles)
    if handles.Cfg.Covremove.HeadMotion~=4
        handles.Cfg.Covremove.HeadMotion=4;
    else
        handles.Cfg.Covremove.HeadMotion=0;
    end
    drawnow;
    guidata(hObject, handles);
    UpdateDisplay(handles);

function radiobuttonVoxelSpecific3_Callback(hObject, eventdata, handles)
    if handles.Cfg.Covremove.HeadMotion~=11
        handles.Cfg.Covremove.HeadMotion=11;
    else
        handles.Cfg.Covremove.HeadMotion=0;
    end
    drawnow;
    guidata(hObject, handles);
    UpdateDisplay(handles);
    
function radiobuttonVoxelSpecific12_Callback(hObject, eventdata, handles)
    if handles.Cfg.Covremove.HeadMotion~=14
        handles.Cfg.Covremove.HeadMotion=14;
    else
        handles.Cfg.Covremove.HeadMotion=0;
    end
    drawnow;
    guidata(hObject, handles);
    UpdateDisplay(handles);
    
    
    
    
function checkboxHeadMotionScrubbingRegressors_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
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
	UpdateDisplay(handles); 

    
function pushbutton_NuisanceSetting_Callback(hObject, eventdata, handles)
    handles.Cfg.Covremove = DPARSF_NuisanceSetting(handles.Cfg.Covremove);

    guidata(hObject, handles);
    UpdateDisplay(handles);
    
function pushbuttonFieldMapCorrection_Callback(hObject, eventdata, handles)  
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
        handles.Cfg.FieldMap = DPARSF_FieldMap(handles.Cfg.FieldMap);
    else
        handles.Cfg.FieldMap = DPARSF_FieldMap;
    end
    guidata(hObject, handles);
    UpdateDisplay(handles);
    
    
         
% function checkboxCovremoveWholeBrain_Callback(hObject, eventdata, handles)
% 	if get(hObject,'Value')
% 		handles.Cfg.Covremove.WholeBrain = 1;
% 	else	
% 		handles.Cfg.Covremove.WholeBrain = 0;
%     end	
% 	guidata(hObject, handles);
% 	UpdateDisplay(handles);    
%     
% function checkboxCovremoveWhiteMatter_Callback(hObject, eventdata, handles)
% 	if get(hObject,'Value')
% 		handles.Cfg.Covremove.WhiteMatter = 1;
% 	else	
% 		handles.Cfg.Covremove.WhiteMatter = 0;
%     end	
% 	guidata(hObject, handles);
% 	UpdateDisplay(handles); 
%     
% function checkboxCovremoveCSF_Callback(hObject, eventdata, handles)
% 	if get(hObject,'Value')
% 		handles.Cfg.Covremove.CSF = 1;
% 	else	
% 		handles.Cfg.Covremove.CSF = 0;
%     end	
% 	guidata(hObject, handles);
% 	UpdateDisplay(handles);     
%     
function checkboxOtherCovariates_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
        ROIDef=handles.Cfg.Covremove.OtherCovariatesROI;
        ROIDef=DPABI_ROIList(ROIDef);
        handles.Cfg.Covremove.OtherCovariatesROI=ROIDef;
	else	
		handles.Cfg.Covremove.OtherCovariatesROI=[];
    end	
	guidata(hObject, handles);
	UpdateDisplay(handles);      

function checkboxCovremoveIsAddMeanBack_Callback(hObject, eventdata, handles) %YAN Chao-Gan 160415: Add the option of "Add Mean Back".
	if get(hObject,'Value')
        uiwait(msgbox({'The mean will be added back to the residual after nuisance regression. This is useful for circumstances of ICA or task-based analysis.';...
            },'Add mean back'));
        handles.Cfg.Covremove.IsAddMeanBack = 1;
	else	
		handles.Cfg.Covremove.IsAddMeanBack = 0;
    end	
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);  
    
    
function checkboxFilter_BeforeNormalize_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsFilter = 1;
        handles.Cfg.Filter.Timing='BeforeNormalize';
	else	
		handles.Cfg.IsFilter = 0;
        %handles.Cfg.IsDelDetrendedFiles = 0;
    end	
    %handles.Cfg.Filter.ASamplePeriod=handles.Cfg.TR;
    %handles.Cfg.Filter.AMaskFilename='';
    handles.Cfg.Filter.AAddMeanBack='Yes'; %YAN Chao-Gan, 100420. %handles.Cfg.Filter.ARetrend='Yes';
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);

function checkboxFilter_AfterNormalize_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsFilter = 1;
        handles.Cfg.Filter.Timing='AfterNormalize';
	else	
		handles.Cfg.IsFilter = 0;
        %handles.Cfg.IsDelDetrendedFiles = 0;
    end	
    %handles.Cfg.Filter.ASamplePeriod=handles.Cfg.TR;
    %handles.Cfg.Filter.AMaskFilename='';
    handles.Cfg.Filter.AAddMeanBack='Yes'; %YAN Chao-Gan, 100420. %handles.Cfg.Filter.ARetrend='Yes';
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);
    
    
function edtBandLow_Callback(hObject, eventdata, handles)
	handles.Cfg.Filter.AHighPass_LowCutoff =str2double(get(hObject,'String'));
	guidata(hObject, handles);
    UpdateDisplay(handles);

function edtBandHigh_Callback(hObject, eventdata, handles)
	handles.Cfg.Filter.ALowPass_HighCutoff =str2double(get(hObject,'String'));
	guidata(hObject, handles);
    UpdateDisplay(handles);
    

    
function checkboxNormalize_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsNormalize = 1;
        handles.Cfg.Normalize.Timing='OnFunctionalData';
	else	
		handles.Cfg.IsNormalize = 0;
    end	
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);     
    
    
function checkboxNormalizeResults_Callback(hObject, eventdata, handles)
    if get(hObject,'Value')
        handles.Cfg.IsNormalize = 1;
        handles.Cfg.Normalize.Timing='OnResults';

        uiwait(msgbox({'Normalize the R-fMRI measures (derivatives) calculated in original space into MNI space.';...
            },'Normalize Derivatives'));
        
    else
        handles.Cfg.IsNormalize = 0;
    end
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);     


function editBoundingBox_Callback(hObject, eventdata, handles)
	BoundingBox=get(hObject,'String');
    handles.Cfg.Normalize.BoundingBox =eval(['[',BoundingBox,']']);
	guidata(hObject, handles);   
    UpdateDisplay(handles);    
   
function editVoxSize_Callback(hObject, eventdata, handles)
	VoxSize=get(hObject,'String');
    handles.Cfg.Normalize.VoxSize =eval(['[',VoxSize,']']);
	guidata(hObject, handles);   
    UpdateDisplay(handles);        
    
function radiobuttonNormalize_EPI_Callback(hObject, eventdata, handles)
    handles.Cfg.IsNormalize=1;
    drawnow;    
	guidata(hObject, handles);   
    UpdateDisplay(handles);  

function radiobuttonNormalize_T1_Callback(hObject, eventdata, handles)
    handles.Cfg.IsNormalize=2;
    drawnow;    
	guidata(hObject, handles);   
    UpdateDisplay(handles);  
    
function radiobuttonNormalize_DARTEL_Callback(hObject, eventdata, handles)
    handles.Cfg.IsNormalize=3;
    drawnow;    
	guidata(hObject, handles);   
    UpdateDisplay(handles);  
    
% function checkboxIsDelFilesBeforeNormalize_Callback(hObject, eventdata, handles)
% 	if get(hObject,'Value')
% 		handles.Cfg.IsDelFilesBeforeNormalize=1;
% 	else	
% 		handles.Cfg.IsDelFilesBeforeNormalize=0;
%     end	
% 	guidata(hObject, handles);
% 	UpdateDisplay(handles);      
    
function checkboxSmooth_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsSmooth = 1;
        handles.Cfg.Smooth.Timing='OnFunctionalData';
	else	
		handles.Cfg.IsSmooth = 0;
    end	
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);     
    
function checkboxSmoothByDARTEL_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsSmooth = 2;
        handles.Cfg.Smooth.Timing='OnFunctionalData';
	else	
		handles.Cfg.IsSmooth = 0;
    end	
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);  
    
    function checkboxSmoothResults_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsSmooth = 1;
        handles.Cfg.Smooth.Timing='OnResults';
        
        uiwait(msgbox({'Smooth the calculated R-fMRI measures (derivatives).';...
            },'Smooth Derivatives'));
        
	else	
		handles.Cfg.IsSmooth = 0;
    end	
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);  
    
function editFWHM_Callback(hObject, eventdata, handles)
	FWHM=get(hObject,'String');
    handles.Cfg.Smooth.FWHM =eval(['[',FWHM,']']);
	guidata(hObject, handles);   
    UpdateDisplay(handles);      
 
    
function edtMaskfile_Callback(hObject, eventdata, handles)
	theMaskfile =get(hObject, 'String');
    theMaskfile =strtrim(theMaskfile);
	if exist(theMaskfile, 'file')
		handles.Cfg.MaskFile =theMaskfile;
		guidata(hObject, handles);
	else
		errordlg(sprintf('The mask file "%s" does not exist!\n Please re-check it.', theMaskfile));
    end
%     handles.Cfg.CalReHo.AMaskFilename=handles.Cfg.MaskFile;
%     handles.Cfg.CalALFF.AMaskFilename=handles.Cfg.MaskFile;
%     handles.Cfg.CalfALFF.AMaskFilename=handles.Cfg.MaskFile;
%     handles.Cfg.CalFC.AMaskFilename=handles.Cfg.MaskFile;
    guidata(hObject, handles);

function btnSelectMask_Callback(hObject, eventdata, handles)
	[filename, pathname] = uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
												'Pick a a  mask');
    if ~(filename==0)
        handles.Cfg.MaskFile =[pathname filename];
        guidata(hObject,handles);
    elseif ~( exist(handles.Cfg.MaskFile, 'file')==2)
        set(handles.rbtnDefaultMask, 'Value',[1]);        
        set(handles.rbtnUserMask, 'Value',[0]); 
        set(handles.rbtnNullMask, 'Value',[0]); 
		set(handles.edtMaskfile, 'Enable','off');
		set(handles.btnSelectMask, 'Enable','off');			
		handles.Cfg.MaskFile ='Default';
		guidata(hObject, handles);        
    end    
%     handles.Cfg.CalReHo.AMaskFilename=handles.Cfg.MaskFile;
%     handles.Cfg.CalALFF.AMaskFilename=handles.Cfg.MaskFile;
%     handles.Cfg.CalfALFF.AMaskFilename=handles.Cfg.MaskFile;
%     handles.Cfg.CalFC.AMaskFilename=handles.Cfg.MaskFile;
    guidata(hObject, handles);
    UpdateDisplay(handles);

function rbtnDefaultMask_Callback(hObject, eventdata, handles)
	set(handles.edtMaskfile, 'Enable','off', 'String','Use Default Mask');
	set(handles.btnSelectMask, 'Enable','off');	
	drawnow;
    handles.Cfg.MaskFile ='Default';
%     handles.Cfg.CalReHo.AMaskFilename=handles.Cfg.MaskFile;
%     handles.Cfg.CalALFF.AMaskFilename=handles.Cfg.MaskFile;
%     handles.Cfg.CalfALFF.AMaskFilename=handles.Cfg.MaskFile;
%     handles.Cfg.CalFC.AMaskFilename=handles.Cfg.MaskFile;
	guidata(hObject, handles);
    set(handles.rbtnDefaultMask,'Value',1);
	set(handles.rbtnNullMask,'Value',0);
	set(handles.rbtnUserMask,'Value',0);

function rbtnUserMask_Callback(hObject, eventdata, handles)
	set(handles.edtMaskfile,'Enable','on', 'String',handles.Cfg.MaskFile);
	set(handles.btnSelectMask, 'Enable','on');
	set(handles.rbtnDefaultMask,'Value',0);
	set(handles.rbtnNullMask,'Value',0);
	set(handles.rbtnUserMask,'Value',1);
    drawnow;
	
function rbtnNullMask_Callback(hObject, eventdata, handles)
	set(handles.edtMaskfile, 'Enable','off', 'String','Don''t use any Mask');
	set(handles.btnSelectMask, 'Enable','off');
	drawnow;
	handles.Cfg.MaskFile ='';
%     handles.Cfg.CalReHo.AMaskFilename=handles.Cfg.MaskFile;
%     handles.Cfg.CalALFF.AMaskFilename=handles.Cfg.MaskFile;
%     handles.Cfg.CalfALFF.AMaskFilename=handles.Cfg.MaskFile;
%     handles.Cfg.CalFC.AMaskFilename=handles.Cfg.MaskFile;
	guidata(hObject, handles);
    set(handles.rbtnDefaultMask,'Value',0);
	set(handles.rbtnNullMask,'Value',1);
	set(handles.rbtnUserMask,'Value',0);    

    
function checkboxDetrend_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsDetrend = 1;
	else	
		handles.Cfg.IsDetrend = 0;
    end	
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);       

    
function checkboxCalALFF_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsCalALFF = 1;
	else	
		handles.Cfg.IsCalALFF = 0;
    end	
    %handles.Cfg.CalALFF.ASamplePeriod=handles.Cfg.TR;
    %handles.Cfg.CalALFF.AMaskFilename=handles.Cfg.MaskFile;
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);        
    
% function checkboxCalfALFF_Callback(hObject, eventdata, handles)
% 	if get(hObject,'Value')
% 		handles.Cfg.IsCalfALFF = 1;
% %         uiwait(msgbox({'fALFF calculation is based on data before filter, i.e., detrended data.';...
% %             },'fALFF'));
% 	else	
% 		handles.Cfg.IsCalfALFF = 0;
%     end	
%     %handles.Cfg.CalfALFF.ASamplePeriod=handles.Cfg.TR;
%     %handles.Cfg.CalfALFF.AMaskFilename=handles.Cfg.MaskFile;
%     handles=CheckCfgParameters(handles);
% 	guidata(hObject, handles);
% 	UpdateDisplay(handles);      


function edtfAlffBandLow_Callback(hObject, eventdata, handles)
	handles.Cfg.CalALFF.AHighPass_LowCutoff =str2double(get(hObject,'String'));
    %handles.Cfg.CalfALFF.AHighPass_LowCutoff=handles.Cfg.CalALFF.AHighPass_LowCutoff;
	guidata(hObject, handles);

function edtfAlffBandHigh_Callback(hObject, eventdata, handles)
	handles.Cfg.CalALFF.ALowPass_HighCutoff =str2double(get(hObject,'String'));
    %handles.Cfg.CalfALFF.ALowPass_HighCutoff=handles.Cfg.CalALFF.ALowPass_HighCutoff;
	guidata(hObject, handles);
 
% function checkboxmALFF_1_Callback(hObject, eventdata, handles)
% 	if get(hObject,'Value')
% 		handles.Cfg.CalALFF.mALFF_1 = 1;
%         handles.Cfg.CalfALFF.mfALFF_1 = 1;
% 	else	
% 		handles.Cfg.CalALFF.mALFF_1 = 0;
%         handles.Cfg.CalfALFF.mfALFF_1 = 0;
%     end	
% 	guidata(hObject, handles);
% 	UpdateDisplay(handles);      
    
    
    
function checkboxScrubbing_Callback(hObject, eventdata, handles)
    if get(hObject,'Value')
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
    %handles.Cfg.CalReHo.AMaskFilename=handles.Cfg.MaskFile;
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);  
    
function checkboxCalReHo_Callback(hObject, eventdata, handles)
    if get(hObject,'Value')
        handles.Cfg.IsCalReHo = 1;
    else
        handles.Cfg.IsCalReHo = 0;
    end
    %handles.Cfg.CalReHo.AMaskFilename=handles.Cfg.MaskFile;
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);    
    
function radiobuttonReHo7voxels_Callback(hObject, eventdata, handles)
    handles.Cfg.CalReHo.ClusterNVoxel = 7;
    set(handles.radiobuttonReHo7voxels,'Value',1);
	set(handles.radiobuttonReHo19voxels,'Value',0);
	set(handles.radiobuttonReHo27voxels,'Value',0);
    guidata(hObject, handles);
	UpdateDisplay(handles); 

function radiobuttonReHo19voxels_Callback(hObject, eventdata, handles)
    handles.Cfg.CalReHo.ClusterNVoxel = 19;
    set(handles.radiobuttonReHo7voxels,'Value',0);
	set(handles.radiobuttonReHo19voxels,'Value',1);
	set(handles.radiobuttonReHo27voxels,'Value',0);
    guidata(hObject, handles);
	UpdateDisplay(handles); 
	
function radiobuttonReHo27voxels_Callback(hObject, eventdata, handles)
    handles.Cfg.CalReHo.ClusterNVoxel = 27;
    set(handles.radiobuttonReHo7voxels,'Value',0);
	set(handles.radiobuttonReHo19voxels,'Value',0);
	set(handles.radiobuttonReHo27voxels,'Value',1);
    guidata(hObject, handles);
	UpdateDisplay(handles); 
    
function checkboxSmoothReHo_Callback(hObject, eventdata, handles)
    if get(hObject,'Value')
        
        uiwait(msgbox({'ReHo is usually performed on unsmoothed data, thus need to be smoothed afterwards. This option is convenient if ReHo is the only measure need to be smoothed afterwards (e.g., performed in MNI space). Another option is "Smooth Derivatives", that option is convenient if all the measures need to be smoothed afterwards (e.g., performed in native space). The smooth kernel is set by FWMH after the first smooth checkbox.';...
            },'Smooth ReHo'));
        
        handles.Cfg.CalReHo.SmoothReHo = 1;

    else
        handles.Cfg.CalReHo.SmoothReHo = 0;
    end
    %handles.Cfg.CalReHo.AMaskFilename=handles.Cfg.MaskFile;
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles); 
    
 
function checkboxCalDegreeCentrality_Callback(hObject, eventdata, handles)
    if get(hObject,'Value')
        handles.Cfg.IsCalDegreeCentrality = 1;
        prompt ={'Please set the correlation (r) threshold for degree centrality calculation:'};
        def	={num2str(handles.Cfg.CalDegreeCentrality.rThreshold)};
        options.Resize='on';
        options.WindowStyle='modal';
        options.Interpreter='tex';
        answer =inputdlg(prompt, 'Set r threshold', 1, def,options);
        if numel(answer)==1,
            handles.Cfg.CalDegreeCentrality.rThreshold = str2num(answer{1});
        end
    else
        handles.Cfg.IsCalDegreeCentrality = 0;
    end
    handles=CheckCfgParameters(handles);
    guidata(hObject, handles);
    UpdateDisplay(handles);



function checkboxCalFC_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsCalFC = 1;
	else	
		handles.Cfg.IsCalFC = 0;
    end	
    %handles.Cfg.CalFC.AMaskFilename=handles.Cfg.MaskFile;
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);   
    
function checkboxExtractRESTdefinedROITC_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsExtractROISignals = 1;
	else	
		handles.Cfg.IsExtractROISignals = 0;
    end	
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);        
 
function pushbuttonDefineROI_Callback(hObject, eventdata, handles)
    ROIDef=handles.Cfg.CalFC.ROIDef;
    if isempty(ROIDef)
        [ProgramPath, fileN, extn] = fileparts(which('DPARSFA.m'));
        addpath([ProgramPath,filesep,'SubGUIs']);
        [ROIDef,IsMultipleLabel]=DPARSF_ROI_Template(ROIDef,handles.Cfg.CalFC.IsMultipleLabel);
        handles.Cfg.CalFC.IsMultipleLabel = IsMultipleLabel;
    end
    
    if handles.Cfg.CalFC.IsMultipleLabel
        fprintf('\nIsMultipleLabel is set to 1: There are multiple labels in the ROI mask file.\n');
    else
        fprintf('\nIsMultipleLabel is set to 0: All the non-zero values will be used to define the only ROI.\n');
    end
    
    ROIDef=DPABI_ROIList(ROIDef);
    handles.Cfg.CalFC.ROIDef=ROIDef;
    guidata(hObject, handles);
    UpdateDisplay(handles);

function checkboxDefineROIInteractively_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsDefineROIInteractively = 1;
	else	
		handles.Cfg.IsDefineROIInteractively = 0;
    end	
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);    
    
    
function checkboxWarpMasksIntoIndividualSpace_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
        
        
        uiwait(msgbox({'If this option is checked, all the masks will be warped to the individual space by using DARTEL transformation in "T1ImgNewSegment"or the unified segmentation information "*_seg_inv_sn.mat" stored in "T1ImgSegment".';...
            'The following masks will be warped:';...
            '1. The calculation mask (also regarded as the whole-brain mask, e.g. the "Default mask") in ReHo, ALFF/fALFF and Functional Connectivity analysis.';...
            '2. The covariates masks in regressing out covariates: Global mask (50% threshold on SPM5''s brainmask.nii), White matter mask (90% threshold on SPM5''s white.nii) and Cerebrospinal fluid mask (70% threshold on SPM5''s csf.nii).';...
            '3. The ROI masks used in Functional Connectivity or Extracting ROI Time courses.';...
            },'Tips for Warp Masks into Individual Space'));
        
        
        
		handles.Cfg.IsWarpMasksIntoIndividualSpace = 1;
	else	
		handles.Cfg.IsWarpMasksIntoIndividualSpace = 0;
    end	
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);    

    
function checkboxNormalizeToSymmetricGroupT1Mean_Callback(hObject, eventdata, handles) %YAN Chao-Gan, 121225.
    if get(hObject,'Value')
        
        uiwait(msgbox({'If you want to perform VMHC analyses, you may want to normalize the data further to a symmetric template. This option including the following steps:';...
            '1. Get the T1 images in MNI space (e.g., wco*.img or wco*.nii under T1ImgNewSegment or T1ImgSegment) for each subject, and then create a mean T1 image template (averaged across all the subjects).';...
            '2. Create a symmetric T1 template by averaging the mean T1 template (created in Step 1) with it''s flipped version (flipped over x axis).';...
            '3. Normalize the T1 image in MNI space (e.g., wco*.img or wco*.nii under T1ImgNewSegment or T1ImgSegment) for each subject to the symmetric T1 template (created in Step 2), and apply the transformations to the functional data (which have been normalized to MNI space beforehand).';...
            'Ref: Zuo et al., J Neurosci 30, 15034-15043.';...
            },'Normalize To Symmetric Group T1 Mean Template'));
        
        handles.Cfg.IsNormalizeToSymmetricGroupT1Mean = 1;

    else
        handles.Cfg.IsNormalizeToSymmetricGroupT1Mean = 0;
    end
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles); 
    

function checkboxSmoothBeforeVMHC_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
        uiwait(msgbox({'In order to improve the correspondence between symmetric voxels, smooth is performed before VMHC calculation. The smooth kernel is set by FWMH after the first smooth checkbox.';...
            },'Smooth before VMHC calculation'));
        handles.Cfg.IsSmoothBeforeVMHC = 1;
	else	
		handles.Cfg.IsSmoothBeforeVMHC = 0;
    end	
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);  
    
    
function checkboxCalVMHC_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
        handles.Cfg.IsCalVMHC = 1;
	else	
		handles.Cfg.IsCalVMHC = 0;
    end	
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);  

function checkboxCWAS_Callback(hObject, eventdata, handles)
    if get(hObject,'Value')
        button = questdlg('The connectome-wide association studies (CWAS) based on multivariate distance matrix regression (MDMR) is extremely time and memory consuming, thus should be performed on 4*4*4 data with only one session. Do you want to perfrom the CWAS analysis?','CWAS Anlaysis','Yes','No','No');
        if strcmpi(button,'Yes')
            
            handles.Cfg.IsCWAS = 1;
            [Name , Path]=uigetfile({'*.txt','Regressor Files (*.txt)';'*.*', 'All Files (*.*)';}, ...
                'Pick the regressor file for all the subjects, each column is a regressor.');
            FullFilePath=[Path,Name];
            if ischar(FullFilePath)
                if exist(FullFilePath,'file')==2
                    handles.Cfg.CWAS.Regressors = load(FullFilePath);
                end
            end
            
            prompt ={'Please set the number of interations for permutation tests:'};
            def	={num2str(handles.Cfg.CWAS.iter)};
            options.Resize='on';
            options.WindowStyle='modal';
            options.Interpreter='tex';
            answer =inputdlg(prompt, 'Set number of interations', 1, def,options);
            if numel(answer)==1,
                handles.Cfg.CWAS.iter = str2num(answer{1});
            end
            
        else
            handles=CheckCfgParameters(handles);
            guidata(hObject, handles);
            UpdateDisplay(handles);
            
            return;
        end
        
    else
        handles.Cfg.IsCWAS = 0;
    end
    handles=CheckCfgParameters(handles);
    guidata(hObject, handles);
    UpdateDisplay(handles);
    
function editFunctionalSessionNumber_Callback(hObject, eventdata, handles)
    uiwait(msgbox({'If you have mutilple functional sessions, you need to specify the number of sessions.';...
        'And your directory should be named as FunRaw (or FunImg) for the first session';...
        'S2_FunRaw (or S2_FunImg) for the second session.';...
        'S3_FunRaw (or S3_FunImg) for the third session';...
        '...';...
        },'Tips for Multiple Functional Sessions'));
    
    handles.Cfg.FunctionalSessionNumber =str2double(get(hObject,'String'));
    handles=CheckCfgParameters(handles);
    guidata(hObject, handles);
    UpdateDisplay(handles);
    
    
    
function editStartingDirName_Callback(hObject, eventdata, handles)
    uiwait(msgbox({'If you do not start with raw DICOM images, you need to specify the Starting Directory Name.';...
        'E.g. "FunImgARW" means you start with images which have been slice timing corrected, realigned and normalized.';...
        '';...
        'Abbreviations:';...
        'A - Slice Timing;';...
        'R - Realign';...
        'W - Normalize';...
        'S - Smooth';...
        'D - Detrend';...
        'F - Filter';...
        'C - Covariates Removed';...
        'B - ScruBBing';...
        'sym - Normalized to a symmetric template';...
        },'Tips for Starting Directory Name'));

    handles.Cfg.StartingDirName=get(hObject,'String');
    handles=CheckCfgParametersBeforeRun(handles);
    guidata(hObject, handles);
    UpdateDisplay(handles);

function editParallelWorkersNumber_Callback(hObject, eventdata, handles)
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
            if Size_MatlabPool ~= handles.Cfg.ParallelWorkersNumber;
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

    handles=CheckCfgParameters(handles);
    guidata(hObject, handles);
    UpdateDisplay(handles);
    
    
function pushbuttonHelp_Callback(hObject, eventdata, handles)
	web('http://rfmri.org/DPARSF','-browser');
    
function pushbuttonSave_Callback(hObject, eventdata, handles)
    [filename, pathname] = uiputfile({'*.mat'}, 'Save Parameters As');
    if ischar(filename)
        Cfg=handles.Cfg;
        save(['',pathname,filename,''], 'Cfg');
    end
    
function handles=pushbuttonLoad_Callback(hObject, eventdata, handles)
    [filename, pathname] = uigetfile({'*.mat'}, 'Load Parameters From');
    if ischar(filename)
        load([pathname,filename]);
        SetLoadedData(hObject,handles, Cfg);
    end

function SetLoadedData(hObject,handles, Cfg);	
    handles.Cfg=Cfg;
    
    if ~isfield(handles.Cfg,'DPARSFVersion')
        uiwait(msgbox({'The current version doesn''t support the mat files saved in version earlier than DPARSFA V2.2.';...
            },'Version Compatibility'));
    else
        % YAN Chao-Gan, 130224. Update the DPARSF Version information.
        if str2num(handles.Cfg.DPARSFVersion(end-5:end)) ~= str2num(handles.Release(end-5:end))
            uiwait(msgbox({['The mat file is created with DPARSFA ',handles.Cfg.DPARSFVersion,', and now is succesfully updated to DPARSFA ',handles.Release,'.'];...
                },'Version Compatibility'));
            handles.Cfg.DPARSFVersion = handles.Release;
        end
    end
    
    
    if ~isfield(handles.Cfg.Covremove.HeadMotionScrubbingRegressors,'FDType')
        handles.Cfg.Covremove.HeadMotionScrubbingRegressors.FDType='FD_Power';
    end
    
    if ~isfield(handles.Cfg.Scrubbing,'FDType')
        handles.Cfg.Scrubbing.FDType='FD_Power';
    end
    
    
    if ~isfield(handles.Cfg.CalReHo,'SmoothReHo')
        handles.Cfg.CalReHo.SmoothReHo=0;
    end
    
    if ~isfield(handles.Cfg,'IsNormalizeToSymmetricGroupT1Mean')
        handles.Cfg.IsNormalizeToSymmetricGroupT1Mean=0;
    end
    
    if ~isfield(handles.Cfg,'IsApplyDownloadedReorientMats')
        handles.Cfg.IsApplyDownloadedReorientMats=0;
    end
    
    if ~isfield(handles.Cfg,'IsSmoothBeforeVMHC')
        handles.Cfg.IsSmoothBeforeVMHC=0;
    end
    
    if ~isfield(handles.Cfg.Covremove.WholeBrain,'IsBothWithWithoutGSR')
        handles.Cfg.Covremove.WholeBrain.IsBothWithWithoutGSR = 0; %YAN Chao-Gan, 151123
    end
    
    if ~isfield(handles.Cfg.Covremove,'IsAddMeanBack')
        handles.Cfg.Covremove.IsAddMeanBack = 0; %YAN Chao-Gan, 160415: Add the option of "Add Mean Back".
    end
    
    if ~isfield(handles.Cfg,'IsBIDStoDPARSF')
        handles.Cfg.IsBIDStoDPARSF=0;
    end


    guidata(hObject, handles);
    UpdateDisplay(handles);
    
function pushbuttonUtilities_Callback(hObject, eventdata, handles)
    [ProgramPath, fileN, extn] = fileparts(which('DPARSFA.m'));
    addpath([ProgramPath,filesep,'SubGUIs']);
	Utilities_fig=figure('name','Utilities','menubar','none','numbertitle','off','position',[100 100 300 100]);
    uicontrol(Utilities_fig,'Style','pushbutton', 'Position',[50 30 200 40],...
        'String','Change the Prefix of Images','ToolTipString','Change the Prefix of Images since DPARSF need some special prefixes in some cases.', ...
        'Callback', 'DPARSF_ChangeImgPrefix_gui')
    movegui(Utilities_fig, 'center');

    
function pushbuttonQuit_Callback(hObject, eventdata, handles)
	close(handles.figDPARSFAMain);     
    
function pushbuttonRun_Callback(hObject, eventdata, handles)
    [handles, CheckingPass]=CheckCfgParametersBeforeRun(handles);
    if CheckingPass==0
        return
    end
    
    RawBackgroundColor=get(handles.pushbuttonRun ,'BackgroundColor');
    RawForegroundColor=get(handles.pushbuttonRun ,'ForegroundColor');
    set(handles.pushbuttonRun ,'Enable', 'off','BackgroundColor', 'red','ForegroundColor','green');
    Cfg=handles.Cfg; %Added by YAN Chao-Gan, 100130. Save the configuration parameters automatically.
    Datetime=fix(clock); %Added by YAN Chao-Gan, 100130.
    save([handles.Cfg.DataProcessDir,filesep,'DPARSFA_AutoSave_',num2str(Datetime(1)),'_',num2str(Datetime(2)),'_',num2str(Datetime(3)),'_',num2str(Datetime(4)),'_',num2str(Datetime(5)),'.mat'], 'Cfg'); %Added by YAN Chao-Gan, 100130.
    [Error]=DPARSFA_run(handles.Cfg);
    
    if ((handles.Cfg.IsCovremove==1) && (handles.Cfg.Covremove.WholeBrain.IsBothWithWithoutGSR == 1)) %YAN Chao-Gan, 151123
        [Error]=DPARSFA_RerunWithGSR(handles.Cfg);
    end
    
    if ~isempty(Error)
        uiwait(msgbox(Error,'Errors were encountered while processing','error'));
    end
    set(handles.pushbuttonRun ,'Enable', 'on','BackgroundColor', RawBackgroundColor,'ForegroundColor',RawForegroundColor);	
 	UpdateDisplay(handles);     
    
%% Check if the configuration parameters is correct
function [handles, CheckingPass]=CheckCfgParameters(handles)   %The parameter checking is no longer needed every time 
    CheckingPass=1;
    return
    
    
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
                    if Dir(i).isdir
                        handles.Cfg.SubjectID=[handles.Cfg.SubjectID;{Dir(i).name}];
                    end
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
                        handles.Cfg.SubjectID=[handles.Cfg.SubjectID;{Dir(i).name}];
                    end
                end
            end
            
            if (handles.Cfg.TimePoints)>0 % If the number of time points is not set at 0, then check the number of time points.
                if ~(strcmpi(handles.Cfg.StartingDirName,'T1Raw') || strcmpi(handles.Cfg.StartingDirName,'T1Img') || strcmpi(handles.Cfg.StartingDirName,'T1NiiGZ') || strcmpi(handles.Cfg.StartingDirName,'BIDS') ) %If not just use for VBM, check if the time points right. %YAN Chao-Gan, 111130. Also add T1 .nii.gz support.
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
        Answer=questdlg('If the Number of Time Points is set to 0, then DPARSFA will not check the number of time points. Do you want to skip the checking of number of time points?','Configuration parameters checking','Yes','No','Yes');
        if ~strcmpi(Answer,'Yes')
            return
        end
    end
    
    if handles.Cfg.TR==0
        Answer=questdlg('If TR is set to 0, then DPARSFA will retrieve the TR information from the NIfTI images. Are you sure the TR information in NIfTI images are correct?','Configuration parameters checking','Yes','No','Yes');
        if ~strcmpi(Answer,'Yes')
            return
        end
    end
    
    if (handles.Cfg.IsSliceTiming==1) && (handles.Cfg.SliceTiming.SliceNumber==0)
        if ~exist([handles.Cfg.DataProcessDir,filesep,'SliceOrderInfo.tsv'])==2 % YAN Chao-Gan, 130524. Read the slice timing information from a tsv file (Tab-separated values)
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
	set(handles.edtWorkingDir ,'String', handles.Cfg.WorkingDir);	
    
    if size(handles.Cfg.SubjectID,1)>0
		theOldIndex =get(handles.listSubjectID, 'Value');
		set(handles.listSubjectID, 'String',  handles.Cfg.SubjectID , 'Value', 1);
		theCount =size(handles.Cfg.SubjectID,1);
		if (theOldIndex>0) && (theOldIndex<= theCount)
			set(handles.listSubjectID, 'Value', theOldIndex);
		end
	else
		set(handles.listSubjectID, 'String', '' , 'Value', 0);
    end
    
    set(handles.editTimePoints ,'String', num2str(handles.Cfg.TimePoints));	
    set(handles.editTR ,'String', num2str(handles.Cfg.TR));	
    set(handles.ckboxEPIDICOM2NIFTI, 'Value', handles.Cfg.IsNeedConvertFunDCM2IMG);
    set(handles.checkboxT1DICOM2NIFTI, 'Value', handles.Cfg.IsNeedConvertT1DCM2IMG);
    set(handles.checkboxBIDStoDPARSF, 'Value', handles.Cfg.IsBIDStoDPARSF);
    
    set(handles.checkboxApplyDownloadedReorientMats, 'Value', handles.Cfg.IsApplyDownloadedReorientMats);

    %set(handles.checkboxConvert4DFunInto3DImg, 'Value', handles.Cfg.IsNeedConvert4DFunInto3DImg);
    % set(handles.editRemoveFirstTimePoints ,'String', num2str(handles.Cfg.RemoveFirstTimePoints));
    % Revised by YAN Chao-Gan 091110. Add a checkbox to avoid forgeting to check this parameter.
    if handles.Cfg.IsRemoveFirstTimePoints==1
        set(handles.checkboxRemoveFirstTimePoints, 'Value', 1);	
        set(handles.editRemoveFirstTimePoints, 'Enable', 'on', 'String', num2str(handles.Cfg.RemoveFirstTimePoints));
    else
        set(handles.checkboxRemoveFirstTimePoints, 'Value', 0);	
        set(handles.editRemoveFirstTimePoints, 'Enable', 'off', 'String', num2str(handles.Cfg.RemoveFirstTimePoints));
    end
    
    if handles.Cfg.IsSliceTiming==1
		set(handles.checkboxSliceTiming, 'Value', 1);	
        set(handles.editSliceNumber, 'Enable', 'on', 'String', num2str(handles.Cfg.SliceTiming.SliceNumber));
        set(handles.editSliceOrder, 'Enable', 'on', 'String', mat2str(handles.Cfg.SliceTiming.SliceOrder));
        set(handles.editReferenceSlice, 'Enable', 'on', 'String', num2str(handles.Cfg.SliceTiming.ReferenceSlice));
        set(handles.textSliceNumber,'Enable', 'on');
        set(handles.textSliceOrder,'Enable', 'on');
        set(handles.textReferenceSlice,'Enable', 'on');
    else
        set(handles.checkboxSliceTiming, 'Value', 0);	
        set(handles.editSliceNumber, 'Enable', 'off', 'String', num2str(handles.Cfg.SliceTiming.SliceNumber));
        set(handles.editSliceOrder, 'Enable', 'off', 'String', mat2str(handles.Cfg.SliceTiming.SliceOrder));
        set(handles.editReferenceSlice, 'Enable', 'off', 'String', num2str(handles.Cfg.SliceTiming.ReferenceSlice));
        set(handles.textSliceNumber,'Enable', 'off');
        set(handles.textSliceOrder,'Enable', 'off');
        set(handles.textReferenceSlice,'Enable', 'off');
    end
    
    set(handles.checkboxRealign, 'Value', handles.Cfg.IsRealign);
    set(handles.checkboxCalVoxelSpecificHeadMotion, 'Value', handles.Cfg.IsCalVoxelSpecificHeadMotion);
    set(handles.checkboxReorientFunImgInteractively, 'Value', handles.Cfg.IsNeedReorientFunImgInteractively);
    set(handles.checkbox_IsAutoMask, 'Value', handles.Cfg.IsAutoMask);
    
    %set(handles.checkboxUnzipT1intoT1Img, 'Value', handles.Cfg.IsNeedUnzipT1IntoT1Img);
    set(handles.checkboxReorientCropT1Img, 'Value', handles.Cfg.IsNeedReorientCropT1Img);
    set(handles.checkboxReorientT1ImgInteractively, 'Value', handles.Cfg.IsNeedReorientT1ImgInteractively);
    set(handles.checkbox_IsBet, 'Value', handles.Cfg.IsBet);
    set(handles.checkboxT1CoregisterToFun, 'Value', handles.Cfg.IsNeedT1CoregisterToFun);
    %set(handles.checkboxReorientInteractivelyAfterCoreg, 'Value', handles.Cfg.IsNeedReorientInteractivelyAfterCoreg);

    set(handles.checkboxSegment, 'Value', handles.Cfg.IsSegment == 1);
    set(handles.checkboxNewSegment_DARTEL, 'Value', handles.Cfg.IsSegment == 2);
    if handles.Cfg.IsSegment>0
        set(handles.textAffineRegularisation, 'Visible', 'on');
        set(handles.radiobuttonEastAsian,'Visible', 'on','Value',strcmpi(handles.Cfg.Segment.AffineRegularisationInSegmentation,'eastern'));
        set(handles.radiobuttonEuropean,'Visible', 'on','Value',strcmpi(handles.Cfg.Segment.AffineRegularisationInSegmentation,'mni'));
    else
        set(handles.textAffineRegularisation, 'Visible', 'off');
        set(handles.radiobuttonEastAsian,'Visible', 'off','Value',strcmpi(handles.Cfg.Segment.AffineRegularisationInSegmentation,'eastern'));
        set(handles.radiobuttonEuropean,'Visible', 'off','Value',strcmpi(handles.Cfg.Segment.AffineRegularisationInSegmentation,'mni'));
    end
    
    if handles.Cfg.IsCovremove==1
        if strcmpi(handles.Cfg.Covremove.Timing,'AfterRealign')
            set(handles.checkboxCovremoveAfterRealign, 'Value', 1, 'ForegroundColor', 'k');
            set(handles.checkboxCovremoveAfterNormalize, 'Value', 0, 'ForegroundColor', [0.4,0.4,0.4]);
            set(handles.textPolynomialTrend, 'Enable', 'on', 'ForegroundColor', 'k');
            set(handles.editPolynomialTrend, 'Enable', 'on', 'String', num2str(handles.Cfg.Covremove.PolynomialTrend), 'ForegroundColor', 'k');
            set(handles.textHeadMotionModel, 'Enable', 'on', 'ForegroundColor', 'k');
            set(handles.radiobuttonRigidBody6, 'Enable', 'on', 'Value', handles.Cfg.Covremove.HeadMotion==1, 'ForegroundColor', 'k');
            set(handles.radiobuttonDerivative12, 'Enable', 'on', 'Value', handles.Cfg.Covremove.HeadMotion==2, 'ForegroundColor', 'k');
            set(handles.radiobuttonFriston24, 'Enable', 'on', 'Value', handles.Cfg.Covremove.HeadMotion==4, 'ForegroundColor', 'k');
            set(handles.radiobuttonVoxelSpecific3, 'Enable', 'on', 'Value', handles.Cfg.Covremove.HeadMotion==11, 'ForegroundColor', 'k');
            set(handles.radiobuttonVoxelSpecific12, 'Enable', 'on', 'Value', handles.Cfg.Covremove.HeadMotion==14, 'ForegroundColor', 'k');
            set(handles.checkboxHeadMotionScrubbingRegressors, 'Enable', 'on', 'Value', handles.Cfg.Covremove.IsHeadMotionScrubbingRegressors, 'ForegroundColor', 'k');
            set(handles.pushbutton_NuisanceSetting, 'Enable', 'on');
%             set(handles.checkboxCovremoveWholeBrain, 'Enable', 'on', 'Value', handles.Cfg.Covremove.WholeBrain, 'ForegroundColor', 'k');
%             set(handles.checkboxCovremoveWhiteMatter, 'Enable', 'on', 'Value', handles.Cfg.Covremove.WhiteMatter, 'ForegroundColor', 'k');
%             set(handles.checkboxCovremoveCSF, 'Enable', 'on', 'Value', handles.Cfg.Covremove.CSF, 'ForegroundColor', 'k');
            set(handles.checkboxOtherCovariates, 'Enable', 'on', 'Value', ~isempty(handles.Cfg.Covremove.OtherCovariatesROI), 'ForegroundColor', 'k');
            set(handles.checkboxCovremoveIsAddMeanBack, 'Enable', 'on', 'Value', handles.Cfg.Covremove.IsAddMeanBack, 'ForegroundColor', 'k');
        elseif strcmpi(handles.Cfg.Covremove.Timing,'AfterNormalize')
            set(handles.checkboxCovremoveAfterRealign, 'Value', 0, 'ForegroundColor', [0.4,0.4,0.4]);
            set(handles.checkboxCovremoveAfterNormalize, 'Value', 1, 'ForegroundColor', 'b');
            set(handles.textPolynomialTrend, 'Enable', 'on', 'ForegroundColor', 'b');
            set(handles.editPolynomialTrend, 'Enable', 'on', 'String', num2str(handles.Cfg.Covremove.PolynomialTrend), 'ForegroundColor', 'b');
            set(handles.textHeadMotionModel, 'Enable', 'on', 'ForegroundColor', 'b');
            set(handles.radiobuttonRigidBody6, 'Enable', 'on', 'Value', handles.Cfg.Covremove.HeadMotion==1, 'ForegroundColor', 'b');
            set(handles.radiobuttonDerivative12, 'Enable', 'on', 'Value', handles.Cfg.Covremove.HeadMotion==2, 'ForegroundColor', 'b');
            set(handles.radiobuttonFriston24, 'Enable', 'on', 'Value', handles.Cfg.Covremove.HeadMotion==4, 'ForegroundColor', 'b');
            set(handles.radiobuttonVoxelSpecific3, 'Enable', 'on', 'Value', handles.Cfg.Covremove.HeadMotion==11, 'ForegroundColor', 'b');
            set(handles.radiobuttonVoxelSpecific12, 'Enable', 'on', 'Value', handles.Cfg.Covremove.HeadMotion==14, 'ForegroundColor', 'b');
            set(handles.checkboxHeadMotionScrubbingRegressors, 'Enable', 'on', 'Value', handles.Cfg.Covremove.IsHeadMotionScrubbingRegressors, 'ForegroundColor', 'b');
            set(handles.pushbutton_NuisanceSetting, 'Enable', 'on');
%             set(handles.checkboxCovremoveWholeBrain, 'Enable', 'on', 'Value', handles.Cfg.Covremove.WholeBrain, 'ForegroundColor', 'b');
%             set(handles.checkboxCovremoveWhiteMatter, 'Enable', 'on', 'Value', handles.Cfg.Covremove.WhiteMatter, 'ForegroundColor', 'b');
%             set(handles.checkboxCovremoveCSF, 'Enable', 'on', 'Value', handles.Cfg.Covremove.CSF, 'ForegroundColor', 'b');
            set(handles.checkboxOtherCovariates, 'Enable', 'on', 'Value', ~isempty(handles.Cfg.Covremove.OtherCovariatesROI), 'ForegroundColor', 'b');
            set(handles.checkboxCovremoveIsAddMeanBack, 'Enable', 'on', 'Value', handles.Cfg.Covremove.IsAddMeanBack, 'ForegroundColor', 'b');
        end
    else
        set(handles.checkboxCovremoveAfterRealign, 'Value', 0, 'ForegroundColor', 'k');
        set(handles.checkboxCovremoveAfterNormalize, 'Value', 0, 'ForegroundColor', [0.4,0.4,0.4]);
        set(handles.textPolynomialTrend, 'Enable', 'off', 'ForegroundColor', 'k');
        set(handles.editPolynomialTrend, 'Enable', 'off', 'String', num2str(handles.Cfg.Covremove.PolynomialTrend), 'ForegroundColor', 'k');
        set(handles.textHeadMotionModel, 'Enable', 'off', 'ForegroundColor', 'k');
        set(handles.radiobuttonRigidBody6, 'Enable', 'off', 'Value', handles.Cfg.Covremove.HeadMotion==1, 'ForegroundColor', 'k');
        set(handles.radiobuttonDerivative12, 'Enable', 'off', 'Value', handles.Cfg.Covremove.HeadMotion==2, 'ForegroundColor', 'k');
        set(handles.radiobuttonFriston24, 'Enable', 'off', 'Value', handles.Cfg.Covremove.HeadMotion==4, 'ForegroundColor', 'k');
        set(handles.radiobuttonVoxelSpecific3, 'Enable', 'off', 'Value', handles.Cfg.Covremove.HeadMotion==11, 'ForegroundColor', 'k');
        set(handles.radiobuttonVoxelSpecific12, 'Enable', 'off', 'Value', handles.Cfg.Covremove.HeadMotion==14, 'ForegroundColor', 'k');
        set(handles.checkboxHeadMotionScrubbingRegressors, 'Enable', 'off', 'Value', handles.Cfg.Covremove.IsHeadMotionScrubbingRegressors, 'ForegroundColor', 'k');
        set(handles.pushbutton_NuisanceSetting, 'Enable', 'off');
%         set(handles.checkboxCovremoveWholeBrain, 'Enable', 'off', 'Value', handles.Cfg.Covremove.WholeBrain, 'ForegroundColor', 'k');
%         set(handles.checkboxCovremoveWhiteMatter, 'Enable', 'off', 'Value', handles.Cfg.Covremove.WhiteMatter, 'ForegroundColor', 'k');
%         set(handles.checkboxCovremoveCSF, 'Enable', 'off', 'Value', handles.Cfg.Covremove.CSF, 'ForegroundColor', 'k');
        set(handles.checkboxOtherCovariates, 'Enable', 'off', 'Value', ~isempty(handles.Cfg.Covremove.OtherCovariatesROI), 'ForegroundColor', 'k');
        set(handles.checkboxCovremoveIsAddMeanBack, 'Enable', 'off', 'Value', handles.Cfg.Covremove.IsAddMeanBack, 'ForegroundColor', 'k');
    end
    
    
    if handles.Cfg.IsFilter==1
        if strcmpi(handles.Cfg.Filter.Timing,'BeforeNormalize')
            set(handles.checkboxFilter_BeforeNormalize, 'Value', 1, 'ForegroundColor', 'k');
            set(handles.checkboxFilter_AfterNormalize, 'Value', 0, 'ForegroundColor', [0.4,0.4,0.4]);
            set(handles.edtBandLow, 'Enable', 'on', 'String', num2str(handles.Cfg.Filter.AHighPass_LowCutoff), 'ForegroundColor', 'k');
            set(handles.edtBandHigh, 'Enable', 'on', 'String', num2str(handles.Cfg.Filter.ALowPass_HighCutoff), 'ForegroundColor', 'k');
            set(handles.txtBandSep,'Enable', 'on', 'ForegroundColor', 'k');
        elseif strcmpi(handles.Cfg.Filter.Timing,'AfterNormalize')
            set(handles.checkboxFilter_BeforeNormalize, 'Value', 0, 'ForegroundColor', [0.4,0.4,0.4]);
            set(handles.checkboxFilter_AfterNormalize, 'Value', 1, 'ForegroundColor', 'b');
            set(handles.edtBandLow, 'Enable', 'on', 'String', num2str(handles.Cfg.Filter.AHighPass_LowCutoff), 'ForegroundColor', 'b');
            set(handles.edtBandHigh, 'Enable', 'on', 'String', num2str(handles.Cfg.Filter.ALowPass_HighCutoff), 'ForegroundColor', 'b');
            set(handles.txtBandSep,'Enable', 'on', 'ForegroundColor', 'b');
        end
    else
        set(handles.checkboxFilter_BeforeNormalize, 'Value', 0, 'ForegroundColor', [0.4,0.4,0.4]);
        set(handles.checkboxFilter_AfterNormalize, 'Value', 0, 'ForegroundColor', 'b');
        set(handles.edtBandLow, 'Enable', 'off', 'String', num2str(handles.Cfg.Filter.AHighPass_LowCutoff), 'ForegroundColor', 'k');
        set(handles.edtBandHigh, 'Enable', 'off', 'String', num2str(handles.Cfg.Filter.ALowPass_HighCutoff), 'ForegroundColor', 'k');
        set(handles.txtBandSep,'Enable', 'off', 'ForegroundColor', 'k');
    end

    if handles.Cfg.IsNormalize>0
        if strcmpi(handles.Cfg.Normalize.Timing,'OnFunctionalData')
            set(handles.checkboxNormalize, 'Value', 1, 'ForegroundColor', 'k');
            set(handles.checkboxNormalizeResults, 'Value', 0, 'ForegroundColor', [0.4,0.4,0.4]);
            set(handles.editBoundingBox, 'Enable', 'on', 'String', mat2str(handles.Cfg.Normalize.BoundingBox), 'ForegroundColor', 'k');
            set(handles.editVoxSize, 'Enable', 'on', 'String', mat2str(handles.Cfg.Normalize.VoxSize), 'ForegroundColor', 'k');
            set(handles.radiobuttonNormalize_EPI,'Enable', 'on', 'Value',handles.Cfg.IsNormalize==1, 'ForegroundColor', 'k');
            set(handles.radiobuttonNormalize_T1,'Enable', 'on', 'Value',handles.Cfg.IsNormalize==2, 'ForegroundColor', 'k');
            set(handles.radiobuttonNormalize_DARTEL,'Enable', 'on', 'Value',handles.Cfg.IsNormalize==3, 'ForegroundColor', 'k');
            set(handles.textBoundingBox,'Enable', 'on', 'ForegroundColor', 'k');
            set(handles.textVoxSize,'Enable', 'on', 'ForegroundColor', 'k');
        elseif strcmpi(handles.Cfg.Normalize.Timing,'OnResults')
            set(handles.checkboxNormalize, 'Value', 0, 'ForegroundColor', [0.4,0.4,0.4]);
            set(handles.checkboxNormalizeResults, 'Value', 1, 'ForegroundColor', 'b');
            set(handles.editBoundingBox, 'Enable', 'on', 'String', mat2str(handles.Cfg.Normalize.BoundingBox), 'ForegroundColor', 'b');
            set(handles.editVoxSize, 'Enable', 'on', 'String', mat2str(handles.Cfg.Normalize.VoxSize), 'ForegroundColor', 'b');
            set(handles.radiobuttonNormalize_EPI,'Enable', 'on', 'Value',handles.Cfg.IsNormalize==1, 'ForegroundColor', 'b');
            set(handles.radiobuttonNormalize_T1,'Enable', 'on', 'Value',handles.Cfg.IsNormalize==2, 'ForegroundColor', 'b');
            set(handles.radiobuttonNormalize_DARTEL,'Enable', 'on', 'Value',handles.Cfg.IsNormalize==3, 'ForegroundColor', 'b');
            set(handles.textBoundingBox,'Enable', 'on', 'ForegroundColor', 'b');
            set(handles.textVoxSize,'Enable', 'on', 'ForegroundColor', 'b');
        end
    else
        set(handles.checkboxNormalize, 'Value', 0, 'ForegroundColor', [0.4,0.4,0.4]);
        set(handles.checkboxNormalizeResults, 'Value', 0, 'ForegroundColor', 'b');
        set(handles.editBoundingBox, 'Enable', 'off', 'String', mat2str(handles.Cfg.Normalize.BoundingBox), 'ForegroundColor', 'k');
        set(handles.editVoxSize, 'Enable', 'off', 'String', mat2str(handles.Cfg.Normalize.VoxSize), 'ForegroundColor', 'k');
        set(handles.radiobuttonNormalize_EPI,'Enable', 'off', 'Value',handles.Cfg.IsNormalize==1, 'ForegroundColor', 'k');
        set(handles.radiobuttonNormalize_T1,'Enable', 'off', 'Value',handles.Cfg.IsNormalize==2, 'ForegroundColor', 'k');
        set(handles.radiobuttonNormalize_DARTEL,'Enable', 'off', 'Value',handles.Cfg.IsNormalize==3, 'ForegroundColor', 'k');
        set(handles.textBoundingBox,'Enable', 'off', 'ForegroundColor', 'k');
        set(handles.textVoxSize,'Enable', 'off', 'ForegroundColor', 'k');
    end


    if handles.Cfg.IsSmooth>0
        if strcmpi(handles.Cfg.Smooth.Timing,'OnFunctionalData')
            set(handles.checkboxSmooth, 'Value', handles.Cfg.IsSmooth==1, 'ForegroundColor', 'k');
            set(handles.checkboxSmoothByDARTEL, 'Value', handles.Cfg.IsSmooth==2, 'ForegroundColor', 'k');
            set(handles.checkboxSmoothResults, 'Value', 0, 'ForegroundColor', [0.4,0.4,0.4]);
            set(handles.editFWHM, 'Enable', 'on', 'String', mat2str(handles.Cfg.Smooth.FWHM), 'ForegroundColor', 'k');
            set(handles.textFWHM,'Enable', 'on', 'ForegroundColor', 'k');
        elseif strcmpi(handles.Cfg.Smooth.Timing,'OnResults')
            set(handles.checkboxSmooth, 'Value', 0, 'ForegroundColor', [0.4,0.4,0.4]);
            set(handles.checkboxSmoothByDARTEL, 'Value', 0, 'ForegroundColor', [0.4,0.4,0.4]);
            set(handles.checkboxSmoothResults, 'Value', 1, 'ForegroundColor', 'b');
            set(handles.editFWHM, 'Enable', 'on', 'String', mat2str(handles.Cfg.Smooth.FWHM), 'ForegroundColor', 'b');
            set(handles.textFWHM,'Enable', 'on', 'ForegroundColor', 'b');
        end
    else
        set(handles.checkboxSmooth, 'Value', 0, 'ForegroundColor', [0.4,0.4,0.4]);
        set(handles.checkboxSmoothByDARTEL, 'Value', 0, 'ForegroundColor', [0.4,0.4,0.4]);
        set(handles.checkboxSmoothResults, 'Value', 0, 'ForegroundColor', 'b');
        set(handles.editFWHM, 'Enable', 'on', 'String', mat2str(handles.Cfg.Smooth.FWHM), 'ForegroundColor', 'k');
        set(handles.textFWHM,'Enable', 'on', 'ForegroundColor', 'k');
    end


    if isequal(handles.Cfg.MaskFile, '')
        set(handles.edtMaskfile, 'Enable','off', 'String','Don''t use any Mask');
        set(handles.btnSelectMask, 'Enable','off');
        set(handles.rbtnDefaultMask,'Value',0);
        set(handles.rbtnNullMask,'Value',1);
        set(handles.rbtnUserMask,'Value',0);
    elseif isequal(handles.Cfg.MaskFile, 'Default')
        set(handles.edtMaskfile, 'Enable','off', 'String','Use Default Mask');
        set(handles.btnSelectMask, 'Enable','off');
        set(handles.rbtnDefaultMask,'Value',1);
        set(handles.rbtnNullMask,'Value',0);
        set(handles.rbtnUserMask,'Value',0);
    else
        set(handles.edtMaskfile,'Enable','on', 'String',handles.Cfg.MaskFile);
        set(handles.btnSelectMask, 'Enable','on');
        set(handles.rbtnDefaultMask,'Value',0);
        set(handles.rbtnNullMask,'Value',0);
        set(handles.rbtnUserMask,'Value',1);
    end
    
    set(handles.checkboxWarpMasksIntoIndividualSpace, 'Value', handles.Cfg.IsWarpMasksIntoIndividualSpace);
    
    if handles.Cfg.IsDetrend
        set(handles.checkboxDetrend,'Value',handles.Cfg.IsDetrend, 'ForegroundColor', 'k');
    else
        set(handles.checkboxDetrend,'Value',handles.Cfg.IsDetrend, 'ForegroundColor', [0.4,0.4,0.4]);
    end

    if (handles.Cfg.IsCalALFF==1) % || (handles.Cfg.IsCalfALFF==1)
        set(handles.checkboxCalALFF, 'Value', handles.Cfg.IsCalALFF);
        %set(handles.checkboxCalfALFF, 'Value', handles.Cfg.IsCalfALFF);
        set(handles.edtfAlffBandLow, 'Enable', 'on', 'String', num2str(handles.Cfg.CalALFF.AHighPass_LowCutoff));
        set(handles.edtfAlffBandHigh, 'Enable', 'on', 'String', num2str(handles.Cfg.CalALFF.ALowPass_HighCutoff));
        %set(handles.checkboxmALFF_1, 'Enable', 'on', 'Value', handles.Cfg.CalALFF.mALFF_1);
        set(handles.txtfAlffBand,'Enable', 'on');
        set(handles.txtfAlffBandSep,'Enable', 'on');
    else
        set(handles.checkboxCalALFF, 'Value', handles.Cfg.IsCalALFF);
        %set(handles.checkboxCalfALFF, 'Value', handles.Cfg.IsCalfALFF);
        set(handles.edtfAlffBandLow, 'Enable', 'off', 'String', num2str(handles.Cfg.CalALFF.AHighPass_LowCutoff));
        set(handles.edtfAlffBandHigh, 'Enable', 'off', 'String', num2str(handles.Cfg.CalALFF.ALowPass_HighCutoff));
        %set(handles.checkboxmALFF_1, 'Enable', 'off', 'Value', handles.Cfg.CalALFF.mALFF_1);
        set(handles.txtfAlffBand,'Enable', 'off');
        set(handles.txtfAlffBandSep,'Enable', 'off');
    end
    
    set(handles.checkboxScrubbing,'Value',handles.Cfg.IsScrubbing);
    
    if handles.Cfg.IsCalReHo==1
        set(handles.checkboxCalReHo, 'Value', 1);
        set(handles.radiobuttonReHo7voxels, 'Enable', 'on', 'Value', handles.Cfg.CalReHo.ClusterNVoxel == 7);
        set(handles.radiobuttonReHo19voxels, 'Enable', 'on', 'Value', handles.Cfg.CalReHo.ClusterNVoxel == 19);
        set(handles.radiobuttonReHo27voxels, 'Enable', 'on', 'Value', handles.Cfg.CalReHo.ClusterNVoxel == 27);
        set(handles.checkboxSmoothReHo, 'Enable', 'on', 'Value', handles.Cfg.CalReHo.SmoothReHo); %YAN Chao-Gan, 121225.
        %set(handles.checkboxsmReHo, 'Enable', 'on', 'Value', handles.Cfg.CalReHo.smReHo);
        %set(handles.checkboxmReHo_1, 'Enable', 'on', 'Value', handles.Cfg.CalReHo.mReHo_1);
        set(handles.textReHoCluster,'Enable', 'on');
    else
        set(handles.checkboxCalReHo, 'Value', 0);
        set(handles.radiobuttonReHo7voxels, 'Enable', 'off', 'Value', handles.Cfg.CalReHo.ClusterNVoxel == 7);
        set(handles.radiobuttonReHo19voxels, 'Enable', 'off', 'Value', handles.Cfg.CalReHo.ClusterNVoxel == 19);
        set(handles.radiobuttonReHo27voxels, 'Enable', 'off', 'Value', handles.Cfg.CalReHo.ClusterNVoxel == 27);
        set(handles.checkboxSmoothReHo, 'Enable', 'off', 'Value', handles.Cfg.CalReHo.SmoothReHo); %YAN Chao-Gan, 121225.
        %set(handles.checkboxsmReHo, 'Enable', 'off', 'Value', handles.Cfg.CalReHo.smReHo);
        %set(handles.checkboxmReHo_1, 'Enable', 'off', 'Value', handles.Cfg.CalReHo.mReHo_1);
        set(handles.textReHoCluster,'Enable', 'off');
    end
    
    set(handles.checkboxCalDegreeCentrality, 'Value', handles.Cfg.IsCalDegreeCentrality);
    

    if (handles.Cfg.IsExtractROISignals==1) || (handles.Cfg.IsCalFC==1)
        set(handles.checkboxExtractRESTdefinedROITC, 'Value', handles.Cfg.IsExtractROISignals);
        set(handles.checkboxCalFC, 'Value', handles.Cfg.IsCalFC);
        set(handles.pushbuttonDefineROI, 'Enable', 'on');
        set(handles.checkboxDefineROIInteractively, 'Enable', 'on', 'Value', handles.Cfg.IsDefineROIInteractively);
    else
        set(handles.checkboxExtractRESTdefinedROITC, 'Value', handles.Cfg.IsExtractROISignals);
        set(handles.checkboxCalFC, 'Value', handles.Cfg.IsCalFC);
        set(handles.pushbuttonDefineROI, 'Enable', 'off');
        set(handles.checkboxDefineROIInteractively, 'Enable', 'off', 'Value', handles.Cfg.IsDefineROIInteractively);
    end
    
    
    set(handles.checkboxNormalizeToSymmetricGroupT1Mean, 'Value', handles.Cfg.IsNormalizeToSymmetricGroupT1Mean); %YAN Chao-Gan, 121225.
    set(handles.checkboxSmoothBeforeVMHC, 'Value', handles.Cfg.IsSmoothBeforeVMHC); %YAN Chao-Gan, 151120
    set(handles.checkboxCalVMHC, 'Value', handles.Cfg.IsCalVMHC);
    
    if handles.Cfg.IsCWAS
        set(handles.checkboxCWAS, 'Value', handles.Cfg.IsCWAS, 'ForegroundColor', 'k');
    else
        set(handles.checkboxCWAS, 'Value', handles.Cfg.IsCWAS, 'ForegroundColor', [0.4,0.4,0.4]);
    end
    
    
    set(handles.editFunctionalSessionNumber ,'String', num2str(handles.Cfg.FunctionalSessionNumber));	
    set(handles.editStartingDirName ,'String', handles.Cfg.StartingDirName);
    
    
    % Check if Parallel Computation Toolbox is detected and higher than MATLAB 2008.
    FullMatlabVersion = sscanf(version,'%d.%d.%d.%d%s');
    PCTVer = ver('distcomp');
    if (~isempty(PCTVer)) && (FullMatlabVersion(1)*1000+FullMatlabVersion(2)>=7*1000+8)
        set(handles.editParallelWorkersNumber ,'String', num2str(handles.Cfg.ParallelWorkersNumber), 'Enable', 'on');	
    else
        set(handles.editParallelWorkersNumber ,'String', num2str(handles.Cfg.ParallelWorkersNumber), 'Enable', 'off');	
    end

    
    if isfield(handles.Cfg,'SpecialMode') && (handles.Cfg.SpecialMode == 2)  %Special Mode: Monkey
        set(handles.radiobuttonNormalize_DARTEL,'Visible', 'off');
        set(handles.checkboxNewSegment_DARTEL,'Visible', 'off');
        set(handles.radiobuttonEuropean,'Visible', 'off');
        set(handles.radiobuttonEastAsian,'Value',1,'string','Average');
        
        set(handles.checkboxSmoothByDARTEL,'Visible', 'off');
    end
    
    %150515
    if isfield(handles.Cfg,'SpecialMode') && (handles.Cfg.SpecialMode == 3)  %Special Mode: Rat
        set(handles.checkboxSegment,'Visible', 'off');
        set(handles.checkboxNewSegment_DARTEL,'Visible', 'off');
        set(handles.textAffineRegularisation,'Visible','off');
        set(handles.radiobuttonEuropean,'Visible', 'off');
        set(handles.radiobuttonEastAsian,'Visible','off');
        
        set(handles.checkboxCovremoveAfterRealign,'Enable','off');

        set(handles.radiobuttonNormalize_DARTEL,'Visible', 'off');
        set(handles.radiobuttonNormalize_T1,'string', 'Normalize by using T1 image templates');
        if handles.Cfg.IsNormalize>1
            handles.Cfg.IsNormalize = 4;
            set(handles.radiobuttonNormalize_T1,'Enable', 'on', 'Value',1);
        end

        set(handles.checkboxSmoothByDARTEL,'Visible', 'off');
    end
    
    drawnow;
   
