function varargout = DPARSF(varargin)
%Data Processing Assistant for Resting-State fMRI (DPARSF) Basic Edition GUI by YAN Chao-Gan
%-----------------------------------------------------------
%	Copyright(c) 2009; GNU GENERAL PUBLIC LICENSE
%   The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962; 
%   Child Mind Institute, 445 Park Avenue, New York, NY 10022; 
%   The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016
%	State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%	Written by YAN Chao-Gan
%	http://rfmri.org/DPARSF
% $mail     =ycg.yan@gmail.com
%-----------------------------------------------------------
% 	Mail to Author:  <a href="ycg.yan@gmail.com">YAN Chao-Gan</a> 

% Modified by YAN Chao-Gan 090712, added the function of mReHo - 1, mALFF - 1, mfALFF -1.
% Modified by YAN Chao-Gan 090901, added the function of smReHo, remove variable first time points.
% Modified by YAN Chao-Gan 090909, fixed the bug of setting user's defined mask.
% Modified by YAN Chao-Gan 091111. 1. Use different Affine Regularisation in Segmentation: East Asian brains (eastern) or European brains (mni). 2. Added a checkbox for removing first time points. 3.Added popup menu to delete selected subject by right click. 4. Close wait bar when program finished.
% Modified by YAN Chao-Gan 091127. Add Utilities: Change the Prefix of Images.
% Modified by YAN Chao-Gan 091215. Also can regress out other covariates.
% Modified by YAN Chao-Gan, 100201. Save the configuration parameters automatically.
% Modified by YAN Chao-Gan, 100510. Added a right-click menu to delete all the participants.
% Modified by YAN Chao-Gan, 101025. Fixed the bug of 'copying co*'.
% Modified by YAN Chao-Gan, 110505. Fixed an error in the future MATLAB version in "[pathstr, name, ext, versn] = fileparts...".
% Modified by YAN Chao-Gan, 120101. Nomralize by DARTEL added.
% Modified by YAN Chao-Gan, 120905. DPARSF V2.2 PRE.
% Modified by YAN Chao-Gan, 121225. DPARSF V2.2.
% Modified by YAN Chao-Gan, 130224. DPARSF V2.2, minor revision.
% Modified by YAN Chao-Gan, 130303. DPARSF V2.2, minor revision.
% Modified by YAN Chao-Gan, 130615. DPARSF V2.3.
% Modified by YAN Chao-Gan, 140814. DPARSF V3.0.
% Modified by YAN Chao-Gan, 141101. DPARSF V3.1.
% Modified by YAN Chao-Gan, 150710. DPARSF V3.2.
% Modified by YAN Chao-Gan, 151201. DPARSF V4.0.


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPARSF_OpeningFcn, ...
                   'gui_OutputFcn',  @DPARSF_OutputFcn, ...
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


% --- Executes just before DPARSF is made visible.
function DPARSF_OpeningFcn(hObject, eventdata, handles, varargin)
    Release='V4.5_190725';
    
    [ProgramPath, fileN, extn] = fileparts(which('DPARSFA.m'));
    addpath([ProgramPath,filesep,'SubGUIs']);
%     DPARSF_Choose = DPARSF_ChooseGUI;
%     if DPARSF_Choose==2
%         DPARSFA;
%         close(handles.figDPARSFMain);
%         return
%     end
    
    
    if ispc
        UserName =getenv('USERNAME');
    else
        UserName =getenv('USER');
    end
    Datetime=fix(clock);
    
    fprintf('Welcome: %s, %.4d-%.2d-%.2d %.2d:%.2d \n', UserName,Datetime(1),Datetime(2),Datetime(3),Datetime(4),Datetime(5));
    fprintf('Data Processing Assistant for Resting-State fMRI (DPARSF) Basic Edition. \nRelease = %s\n',Release);
    fprintf('Copyright(c) 2009; GNU GENERAL PUBLIC LICENSE\n');
    fprintf('Institute of Psychology, Chinese Academy of Sciences, 16 Lincui Road, Chaoyang District, Beijing 100101, China; ');
    fprintf('The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962; Child Mind Institute, 445 Park Avenue, New York, NY 10022; The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016');
    fprintf('State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China\n');
    fprintf('Mail to Author:  <a href="ycg.yan@gmail.com">YAN Chao-Gan</a>\n<a href="http://rfmri.org/DPARSF">http://rfmri.org/DPARSF</a>\n');
    fprintf('-----------------------------------------------------------\n');
    fprintf('Citing Information:\nIf you think DPARSF is useful for your work, citing it in your paper would be greatly appreciated.\nSomething like "... The preprocessing was performed using the Data Processing Assistant for Resting-State fMRI (DPARSF, Yan and Zang 2010, http://rfmri.org/DPARSF), which is based on Statistical Parametric Mapping (SPM, http://www.fil.ion.ucl.ac.uk/spm) and the toolbox for Data Processing & Analysis of Brain Imaging (DPABI, Yan et al. 2016, http://rfmri.org/DPABI)..."\nReferences: Yan C and Zang Y (2010) DPARSF: a MATLAB toolbox for "pipeline" data analysis of resting-state fMRI. Front. Syst. Neurosci. 4:13. doi:10.3389/fnsys.2010.00013; \nYan, C.G., Wang, X.D., Zuo, X.N., Zang, Y.F., 2016. DPABI: Data Processing & Analysis for (Resting-State) Brain Imaging. Neuroinformatics 14, 339-351. doi: 10.1007/s12021-016-9299-4\n');

    
    [DPABILatestRelease WebStatus]=urlread('http://rfmri.org/DPABILatestRelease.txt');
    if WebStatus
        DPARSFMessage=urlread('http://rfmri.org/DPARSFMessage.txt');
        if ~isempty(DPARSFMessage)
            uiwait(msgbox(DPARSFMessage,'DPARSF Message'));
        end
        DPARSFMessageWeb=urlread('http://rfmri.org/DPARSFMessageWeb.txt');
        if ~isempty(DPARSFMessageWeb)
            web(DPARSFMessageWeb);
        end
    end
    
    handles.hContextMenu =uicontextmenu;
    set(handles.listSubjectID, 'UIContextMenu', handles.hContextMenu);	%Added by YAN Chao-Gan 091110. Added popup menu to delete selected subject by right click.
	uimenu(handles.hContextMenu, 'Label', 'Remove the selected participant', 'Callback', 'DPARSF(''DeleteSelectedSubjectID'',gcbo,[], guidata(gcbo))');
    uimenu(handles.hContextMenu, 'Label', 'Remove all the participants', 'Callback', 'DPARSF(''DeleteAllSubjects'',gcbo,[], guidata(gcbo))');

    handles.Cfg.DPARSFVersion=Release;
    
    handles.Cfg.WorkingDir =pwd;
    handles.Cfg.DataProcessDir =handles.Cfg.WorkingDir;
    handles.Cfg.SubjectID={};
    handles.Cfg.TimePoints=0;
    handles.Cfg.TR=2;
    handles.Cfg.IsNeedConvertFunDCM2IMG=1;
    handles.Cfg.IsRemoveFirstTimePoints=1;
    handles.Cfg.RemoveFirstTimePoints=10;
    handles.Cfg.IsSliceTiming=1;
    handles.Cfg.SliceTiming.SliceNumber=33;
    handles.Cfg.SliceTiming.TR=handles.Cfg.TR;
    handles.Cfg.SliceTiming.TA=handles.Cfg.SliceTiming.TR-(handles.Cfg.SliceTiming.TR/handles.Cfg.SliceTiming.SliceNumber);
    handles.Cfg.SliceTiming.SliceOrder=[1:2:33,2:2:32];
    handles.Cfg.SliceTiming.ReferenceSlice=33;
    handles.Cfg.IsRealign=1;
    handles.Cfg.IsNormalize=1; 
    handles.Cfg.IsNeedConvertT1DCM2IMG=0;
    handles.Cfg.Normalize.BoundingBox=[-90 -126 -72;90 90 108];
    handles.Cfg.Normalize.VoxSize=[3 3 3];
    handles.Cfg.Normalize.AffineRegularisationInSegmentation='mni';
    %handles.Cfg.IsDelFilesBeforeNormalize=0;
    handles.Cfg.IsSmooth=1;
    handles.Cfg.Smooth.FWHM=[4 4 4];
    %handles.Cfg.DataIsSmoothed=1; 
    handles.Cfg.IsDetrend=0; 
    
    handles.Cfg.IsCovremove=1;
    handles.Cfg.Covremove.PolynomialTrend = 2; %YAN Chao-Gan. 140815
    handles.Cfg.Covremove.HeadMotion=1;
    handles.Cfg.Covremove.WholeBrain=0;
    handles.Cfg.Covremove.CSF=1;
    handles.Cfg.Covremove.WhiteMatter=1;
    handles.Cfg.Covremove.OtherCovariatesROI=[]; %YAN Chao-Gan added 091215./091212.

    handles.Cfg.MaskFile ='Default';
    handles.Cfg.IsCalALFF=1;
    handles.Cfg.CalALFF.ASamplePeriod=2;
    handles.Cfg.CalALFF.AHighPass_LowCutoff=0.01;
    handles.Cfg.CalALFF.ALowPass_HighCutoff=0.1;
    handles.Cfg.CalALFF.AMaskFilename='Default';
    %handles.Cfg.CalALFF.mALFF_1=1;
    handles.Cfg.IsCalfALFF=1;
    handles.Cfg.CalfALFF.ASamplePeriod=2;
    handles.Cfg.CalfALFF.AHighPass_LowCutoff=0.01;
    handles.Cfg.CalfALFF.ALowPass_HighCutoff=0.1;
    handles.Cfg.CalfALFF.AMaskFilename='Default';
    %handles.Cfg.CalfALFF.mfALFF_1=1;
    
    handles.Cfg.IsFilter=1;
    handles.Cfg.Filter.ASamplePeriod=2;
    handles.Cfg.Filter.AHighPass_LowCutoff=0.01;
    handles.Cfg.Filter.ALowPass_HighCutoff=0.1;
    handles.Cfg.Filter.AMaskFilename='';
    handles.Cfg.Filter.AAddMeanBack='Yes';  %YAN Chao-Gan, 100420. %handles.Cfg.Filter.ARetrend='Yes';
    %handles.Cfg.IsDelDetrendedFiles=0;

    handles.Cfg.IsCalReHo=0;
    handles.Cfg.CalReHo.ClusterNVoxel=27;
    handles.Cfg.CalReHo.AMaskFilename='Default';
    handles.Cfg.CalReHo.smReHo=1;
    %handles.Cfg.CalReHo.mReHo_1=1;

    %handles.Cfg.IsExtractAALTC=0;
    handles.Cfg.IsExtractROISignals=0;
    handles.Cfg.ExtractROITC.IsTalCoordinates=1;
    handles.Cfg.ExtractROITC.ROICenter='';%ROICenter;
    handles.Cfg.ExtractROITC.ROIRadius=6;
    
    handles.Cfg.IsExtractROISignals=0;
    handles.Cfg.IsCalFC=0;
    handles.Cfg.CalFC.IsMultipleLabel=0;
    handles.Cfg.CalFC.ROIDef=[];
    handles.Cfg.CalFC.AMaskFilename='Default';
    
    handles.Cfg.IsResliceT1To1x1x1=0;
    handles.Cfg.IsT1Segment=0;
    handles.Cfg.IsWrapAALToNative=0;
    handles.Cfg.IsExtractAALGMVolume=0;

    handles.Cfg.StartingDirName='FunRaw';

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
	movegui(handles.figDPARSFMain, 'center');
	set(handles.figDPARSFMain,'Name','DPARSF');
    
    if ~exist('spm.m')
        uiwait(msgbox('DPARSF is based on SPM and Matlab, Please install Matlab 7.3 and SPM8 or later version at first.','DPARSF'));
    else
        [SPMversionText,c]=spm('Ver');
        SPMversion=str2double(SPMversionText(end-1:end));
        if isnan(SPMversion)
            SPMversion=str2double(SPMversionText(end));
        end
        FullMatlabVersion = sscanf(version,'%d.%d.%d.%d%s');
        if (SPMversion<8)||(FullMatlabVersion(1)*1000+FullMatlabVersion(2)<7*1000+3)
            uiwait(msgbox('DPARSF is based on SPM and Matlab, Please install Matlab 7.3 and SPM8 or later version at first.','DPARSF'));
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
    set(handles.editPolynomialTrend,'Callback','DPARSF(''editPolynomialTrend_Callback'',gcbo,[],guidata(gcbo))');
    set(handles.editParallelWorkersNumber,'Callback','DPARSF(''editParallelWorkersNumber_Callback'',gcbo,[],guidata(gcbo))');
    set(handles.editStartingDirName,'Callback','DPARSF(''editStartingDirName_Callback'',gcbo,[],guidata(gcbo))');
    
    % Choose default command line output for DPARSFA
    handles.output = hObject;
    guidata(hObject, handles);% Update handles structure

	% UIWAIT makes DPARSF wait for user response (see UIRESUME)
	% uiwait(handles.figDPARSFMain);

% --- Outputs from this function are returned to the command line.
function varargout = DPARSF_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    if isfield(handles,'output')
        varargout{1} = handles.output;
    end

   
function edtWorkingDir_Callback(hObject, eventdata, handles)
	theDir =get(hObject, 'String');	
    uiwait(msgbox({'DPARSF''s standard processing steps:';...
        '1. Convert DICOM files to NIFTI images. 2. Remove First Time Points. 3. Slice Timing. 4. Realign. 5. Normalize. 6. Smooth (optional). 7. Detrend. 8. Filter. 9. Calculate ReHo, ALFF, fALFF (optional). 10. Regress out the Covariables (optional). 11. Calculate Functional Connectivity (optional). 12. Extract AAL or ROI time courses for further analysis (optional).';...
        '';...
        'All the input image files should be arranged in the working directory, and DPARSF will put all the output results in the working directory.';...
        '';...
        'For example, if you start with raw DICOM images, you need to arrange each subject''s fMRI DICOM images in one directory, and then put them in "FunRaw" directory under the working directory. i.e.:';...
        '{Working Directory}\FunRaw\Subject001\xxxxx001.dcm';...
        '{Working Directory}\FunRaw\Subject001\xxxxx002.dcm';...
        '...';...
        '{Working Directory}\FunRaw\Subject002\xxxxx001.dcm';...
        '{Working Directory}\FunRaw\Subject002\xxxxx002.dcm';...
        '...';...
        '...';...
        'Please do not name your subjects initiated with letter "a", DPARSF will face difficulties to distinguish the images before and after slice timing if the subjects'' name has an "a" initial.';...
        '';...
        'If you start with NIFTI images (.hdr/.img pairs) before slice timing, you need to arrange each subject''s fMRI NIFTI images in one directory, and then put them in "FunImg" directory under the working directory. i.e.:';...
        '{Working Directory}\FunImg\Subject001\xxxxx001.img';...
        '{Working Directory}\FunImg\Subject001\xxxxx002.img';...
        '...';...
        '{Working Directory}\FunImg\Subject002\xxxxx001.img';...
        '{Working Directory}\FunImg\Subject002\xxxxx002.img';...
        '...';...
        '...';...
        '';...
        'If you start with NIFTI images after normalization, you need to arrange each subject''s NIFTI images in one directory, and then put them in "FunImgNormalized" directory under the working directory.';...
        'If you start with NIFTI images after smooth, you need to arrange each subject''s NIFTI images in one directory, and then put them in "FunImgNormalizedSmoothed" directory under the working directory.';...
        'If you start with NIFTI images after filter, you need to arrange each subject''s NIFTI images in one directory, and then put them in "FunImgNormalizedSmoothedDetrendedFiltered" (or "FunImgNormalizedDetrendedFiltered" if without smooth) directory under the working directory.';...
        },'Please select the Working directory'));
	SetWorkingDir(hObject,handles, theDir);

function btnSelectWorkingDir_Callback(hObject, eventdata, handles)
    uiwait(msgbox({'DPARSF''s standard processing steps:';...
        '1. Convert DICOM files to NIFTI images. 2. Remove First Time Points. 3. Slice Timing. 4. Realign. 5. Normalize. 6. Smooth (optional). 7. Detrend. 8. Filter. 9. Calculate ReHo, ALFF, fALFF (optional). 10. Regress out the Covariables (optional). 11. Calculate Functional Connectivity (optional). 12. Extract AAL or ROI time courses for further analysis (optional).';...
        '';...
        'All the input image files should be arranged in the working directory, and DPARSF will put all the output results in the working directory.';...
        '';...
        'For example, if you start with raw DICOM images, you need to arrange each subject''s fMRI DICOM images in one directory, and then put them in "FunRaw" directory under the working directory. i.e.:';...
        '{Working Directory}\FunRaw\Subject001\xxxxx001.dcm';...
        '{Working Directory}\FunRaw\Subject001\xxxxx002.dcm';...
        '...';...
        '{Working Directory}\FunRaw\Subject002\xxxxx001.dcm';...
        '{Working Directory}\FunRaw\Subject002\xxxxx002.dcm';...
        '...';...
        '...';...
        'Please do not name your subjects initiated with letter "a", DPARSF will face difficulties to distinguish the images before and after slice timing if the subjects'' name has an "a" initial.';...
        '';...
        'If you start with NIFTI images (.hdr/.img pairs) before slice timing, you need to arrange each subject''s fMRI NIFTI images in one directory, and then put them in "FunImg" directory under the working directory. i.e.:';...
        '{Working Directory}\FunImg\Subject001\xxxxx001.img';...
        '{Working Directory}\FunImg\Subject001\xxxxx002.img';...
        '...';...
        '{Working Directory}\FunImg\Subject002\xxxxx001.img';...
        '{Working Directory}\FunImg\Subject002\xxxxx002.img';...
        '...';...
        '...';...
        '';...
        'If you start with NIFTI images after normalization, you need to arrange each subject''s NIFTI images in one directory, and then put them in "FunImgNormalized" directory under the working directory.';...
        'If you start with NIFTI images after smooth, you need to arrange each subject''s NIFTI images in one directory, and then put them in "FunImgNormalizedSmoothed" directory under the working directory.';...
        'If you start with NIFTI images after filter, you need to arrange each subject''s NIFTI images in one directory, and then put them in "FunImgNormalizedSmoothedDetrendedFiltered" (or "FunImgNormalizedDetrendedFiltered" if without smooth) directory under the working directory.';...
        },'Please select the Working directory'));
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
    key =get(handles.figDPARSFMain, 'currentkey');
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
    
    
function ReLoadSubjects(hObject, eventdata, handles)	
    handles.Cfg.SubjectID={};
    handles=CheckCfgParameters(handles);
    guidata(hObject, handles);
    UpdateDisplay(handles);
    
function editTimePoints_Callback(hObject, eventdata, handles)
	handles.Cfg.TimePoints =str2double(get(hObject,'String'));
	guidata(hObject, handles);
    UpdateDisplay(handles);    
    
function editTR_Callback(hObject, eventdata, handles)
	handles.Cfg.TR =str2double(get(hObject,'String'));
    handles.Cfg.SliceTiming.TR=handles.Cfg.TR;
    handles.Cfg.SliceTiming.TA=handles.Cfg.SliceTiming.TR-(handles.Cfg.SliceTiming.TR/handles.Cfg.SliceTiming.SliceNumber);
    handles.Cfg.Filter.ASamplePeriod=handles.Cfg.TR;
    handles.Cfg.CalALFF.ASamplePeriod=handles.Cfg.TR;
    handles.Cfg.CalfALFF.ASamplePeriod=handles.Cfg.TR;
	guidata(hObject, handles);   
    UpdateDisplay(handles);    
    
function ckboxEPIDICOM2NIFTI_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsNeedConvertFunDCM2IMG = 1;
	else	
		handles.Cfg.IsNeedConvertFunDCM2IMG = 0;
    end	
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);    

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
    handles.Cfg.SliceTiming.TR = handles.Cfg.TR;
    handles.Cfg.SliceTiming.TA=handles.Cfg.SliceTiming.TR-(handles.Cfg.SliceTiming.TR/handles.Cfg.SliceTiming.SliceNumber);
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
    
function checkboxNormalize_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsNormalize = 1;
	else	
		handles.Cfg.IsNormalize = 0;
        handles.Cfg.IsNeedConvertT1DCM2IMG=0;
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
    handles.Cfg.IsNeedConvertT1DCM2IMG=0;
%     set(handles.radiobuttonNormalize_EPI,'Value',1);
% 	  set(handles.radiobuttonNormalize_T1,'Value',0);
%     set(handles.checkboxT1DICOM2NIFTI, 'Visible', 'off');
%     set(handles.textAffineRegularisation, 'Visible', 'off');
%     set(handles.radiobuttonEastAsian, 'Visible', 'off');
%     set(handles.radiobuttonEuropean, 'Visible', 'off');
    drawnow;    
	guidata(hObject, handles);   
    UpdateDisplay(handles);  

function radiobuttonNormalize_T1_Callback(hObject, eventdata, handles)
    uiwait(msgbox({'Normalization by using the T1 image unified segmentation will include the following steps: 1. Individual structural image would be coregistered to the mean functional image after the motion correction. 2. The transformed structural images would be then segmented into gray matter, white matter, cerebrospinal fluid by using a unified segmentation algorithm. 3. The motion corrected functional volumes would be spatially normalized to the Montreal Neurological Institute (MNI) space and re-sampled using the normalization parameters estimated during unified segmentation';...
        '';...
        'Please arrange your structural images if you want to use normalization by using the T1 image unified segmentation:';...
        'For example, if you want DPARSF convert the T1 DICOM images into NIFTI images first, you need to arrange each subject''s T1 DICOM images in one directory, and then put them in "T1Raw" directory under the working directory. i.e.:';...
        '{Working Directory}\T1Raw\Subject001\xxxxx001.dcm';...
        '{Working Directory}\T1Raw\Subject001\xxxxx002.dcm';...
        '...';...
        '{Working Directory}\T1Raw\Subject002\xxxxx001.dcm';...
        '{Working Directory}\T1Raw\Subject002\xxxxx002.dcm';...
        '...';...
        '...';...
        'If you start with T1 NIFTI images (.hdr/.img pairs) need not DPARSF convert the DICOM images, you need to arrange each subject''s T1 NIFTI images in one directory, and then put them in "T1Img" directory under the working directory. You need to ensure the file name of T1 NIFTI image of each subject initiated with "co"! i.e.:';...
        '{Working Directory}\T1Img\Subject001\coxxxxx.img';...
        '...';...
        '{Working Directory}\T1Img\Subject002\coxxxxx.img';...
        '...';...
        '...';...
        '';...
        'Note: according to my experience, one of every 30 subjects would be normalized incorrectly by using the T1 image unified segmentation. Checking the results of normalization is suggested';...
        },'Normalize by using T1 image unified segmentation'));
    handles.Cfg.IsNormalize=2;
%     set(handles.radiobuttonNormalize_EPI,'Value',0);
% 	  set(handles.radiobuttonNormalize_T1,'Value',1);
%     set(handles.checkboxT1DICOM2NIFTI, 'Visible', 'on');
%     set(handles.textAffineRegularisation, 'Visible', 'on');
%     set(handles.radiobuttonEastAsian, 'Visible', 'on');
%     set(handles.radiobuttonEuropean, 'Visible', 'on');
    drawnow;    
	guidata(hObject, handles);   
    UpdateDisplay(handles);  
    
function radiobuttonNormalize_DARTEL_Callback(hObject, eventdata, handles)
    uiwait(msgbox({'Normalization by using DARTEL will include the following steps: 1. Individual structural image would be coregistered to the mean functional image after the motion correction. 2. The transformed structural images would be then segmented (New Segmentation) into gray matter, white matter, cerebrospinal fluid by using a unified segmentation algorithm. 3. DARTEL: Create Template. 4. The motion corrected functional volumes would be spatially normalized to the Montreal Neurological Institute (MNI) space and re-sampled using DARTEL: Normalize to MNI space. ';...
        '';...
        'Note: if Smooth option is checked, then smooth wil be peformed with DARTEL: The smoothing that is a part of the normalization to MNI space computes these average intensities from the original data, rather than the warped versions. When the data are warped, some voxels will grow and others will shrink. This will change the regional averages, with more weighting towards those voxels that have grows.';...
        '';...
        'Please arrange your structural images if you want to use normalization by using DARTEL:';...
        'For example, if you want DPARSF convert the T1 DICOM images into NIFTI images first, you need to arrange each subject''s T1 DICOM images in one directory, and then put them in "T1Raw" directory under the working directory. i.e.:';...
        '{Working Directory}\T1Raw\Subject001\xxxxx001.dcm';...
        '{Working Directory}\T1Raw\Subject001\xxxxx002.dcm';...
        '...';...
        '{Working Directory}\T1Raw\Subject002\xxxxx001.dcm';...
        '{Working Directory}\T1Raw\Subject002\xxxxx002.dcm';...
        '...';...
        '...';...
        'If you start with T1 NIFTI images (.hdr/.img pairs) need not DPARSF convert the DICOM images, you need to arrange each subject''s T1 NIFTI images in one directory, and then put them in "T1Img" directory under the working directory. You need to ensure the file name of T1 NIFTI image of each subject initiated with "co"! i.e.:';...
        '{Working Directory}\T1Img\Subject001\coxxxxx.img';...
        '...';...
        '{Working Directory}\T1Img\Subject002\coxxxxx.img';...
        '...';...
        '...';...
        '';...
        },'Normalize by DARTEL'));
    handles.Cfg.IsNormalize=3;
%     set(handles.radiobuttonNormalize_EPI,'Value',0);
% 	  set(handles.radiobuttonNormalize_T1,'Value',1);
%     set(handles.checkboxT1DICOM2NIFTI, 'Visible', 'on');
%     set(handles.textAffineRegularisation, 'Visible', 'on');
%     set(handles.radiobuttonEastAsian, 'Visible', 'on');
%     set(handles.radiobuttonEuropean, 'Visible', 'on');
    drawnow;    
	guidata(hObject, handles);   
    UpdateDisplay(handles);  
    
function checkboxT1DICOM2NIFTI_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsNeedConvertT1DCM2IMG=1;
	else	
		handles.Cfg.IsNeedConvertT1DCM2IMG=0;
    end	
	guidata(hObject, handles);
	UpdateDisplay(handles);     
    
function radiobuttonEastAsian_Callback(hObject, eventdata, handles)  %Added by YAN Chao-Gan 091110. Use different Affine Regularisation in Segmentation: East Asian brains (eastern) or European brains (mni).
    handles.Cfg.Normalize.AffineRegularisationInSegmentation='eastern';
    set(handles.radiobuttonEastAsian,'Value',1);
	set(handles.radiobuttonEuropean,'Value',0);
    drawnow;    
	guidata(hObject, handles);   
    UpdateDisplay(handles);  
    
function radiobuttonEuropean_Callback(hObject, eventdata, handles)  %Added by YAN Chao-Gan 091110. Use different Affine Regularisation in Segmentation: East Asian brains (eastern) or European brains (mni).
    handles.Cfg.Normalize.AffineRegularisationInSegmentation='mni';
    set(handles.radiobuttonEastAsian,'Value',0);
	set(handles.radiobuttonEuropean,'Value',1);
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
 
% function radiobuttonDataWithSmooth_Callback(hObject, eventdata, handles)
%     handles.Cfg.DataIsSmoothed=1;
%     set(handles.radiobuttonDataWithSmooth,'Value',1);
% 	set(handles.radiobuttonDataWithoutSmooth,'Value',0);
%     drawnow;    
% 	guidata(hObject, handles);   
%     UpdateDisplay(handles);  
    
% function radiobuttonDataWithoutSmooth_Callback(hObject, eventdata, handles)
%     handles.Cfg.DataIsSmoothed=0;
%     set(handles.radiobuttonDataWithSmooth,'Value',0);
% 	set(handles.radiobuttonDataWithoutSmooth,'Value',1);
%     drawnow;    
% 	guidata(hObject, handles);   
%     UpdateDisplay(handles);      
    
function checkboxDetrend_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsDetrend = 1;
	else	
		handles.Cfg.IsDetrend = 0;
    end	
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);       

function ckboxFilter_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsFilter = 1;
	else	
		handles.Cfg.IsFilter = 0;
        handles.Cfg.IsDelDetrendedFiles = 0;
    end	
    handles.Cfg.Filter.ASamplePeriod=handles.Cfg.TR;
    handles.Cfg.Filter.AMaskFilename='';
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
   
% function checkboxIsDelDetrendedFiles_Callback(hObject, eventdata, handles)
% 	if get(hObject,'Value')
% 		handles.Cfg.IsDelDetrendedFiles = 1;
%         uiwait(msgbox({'If you want to calculate fALFF, please do not delete detrended files.';...
%             },'Delete detrended files'));
% 	else	
% 		handles.Cfg.IsDelDetrendedFiles = 0;
%     end	
%     handles=CheckCfgParameters(handles);
% 	guidata(hObject, handles);
% 	UpdateDisplay(handles);    
    
    
function edtMaskfile_Callback(hObject, eventdata, handles)
	theMaskfile =get(hObject, 'String');
    theMaskfile =strtrim(theMaskfile);
	if exist(theMaskfile, 'file')
		handles.Cfg.MaskFile =theMaskfile;
		guidata(hObject, handles);
	else
		errordlg(sprintf('The mask file "%s" does not exist!\n Please re-check it.', theMaskfile));
    end
    handles.Cfg.CalReHo.AMaskFilename=handles.Cfg.MaskFile;
    handles.Cfg.CalALFF.AMaskFilename=handles.Cfg.MaskFile;
    handles.Cfg.CalfALFF.AMaskFilename=handles.Cfg.MaskFile;
    handles.Cfg.CalFC.AMaskFilename=handles.Cfg.MaskFile;
    guidata(hObject, handles);

function btnSelectMask_Callback(hObject, eventdata, handles)
	[filename, pathname] = uigetfile({'*.img;*.mat', 'All Mask files (*.img; *.mat)'; ...
												'*.mat','MAT masks (*.mat)'; ...
												'*.img', 'ANALYZE or NIFTI masks(*.img)'}, ...
												'Pick a user''s  mask');
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
    handles.Cfg.CalReHo.AMaskFilename=handles.Cfg.MaskFile;
    handles.Cfg.CalALFF.AMaskFilename=handles.Cfg.MaskFile;
    handles.Cfg.CalfALFF.AMaskFilename=handles.Cfg.MaskFile;
    handles.Cfg.CalFC.AMaskFilename=handles.Cfg.MaskFile;
    guidata(hObject, handles);
    UpdateDisplay(handles);

function rbtnDefaultMask_Callback(hObject, eventdata, handles)
	set(handles.edtMaskfile, 'Enable','off', 'String','Use Default Mask');
	set(handles.btnSelectMask, 'Enable','off');	
	drawnow;
    handles.Cfg.MaskFile ='Default';
    handles.Cfg.CalReHo.AMaskFilename=handles.Cfg.MaskFile;
    handles.Cfg.CalALFF.AMaskFilename=handles.Cfg.MaskFile;
    handles.Cfg.CalfALFF.AMaskFilename=handles.Cfg.MaskFile;
    handles.Cfg.CalFC.AMaskFilename=handles.Cfg.MaskFile;
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
    handles.Cfg.CalReHo.AMaskFilename=handles.Cfg.MaskFile;
    handles.Cfg.CalALFF.AMaskFilename=handles.Cfg.MaskFile;
    handles.Cfg.CalfALFF.AMaskFilename=handles.Cfg.MaskFile;
    handles.Cfg.CalFC.AMaskFilename=handles.Cfg.MaskFile;
	guidata(hObject, handles);
    set(handles.rbtnDefaultMask,'Value',0);
	set(handles.rbtnNullMask,'Value',1);
	set(handles.rbtnUserMask,'Value',0);    
    
function checkboxCalReHo_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsCalReHo = 1;
	else	
		handles.Cfg.IsCalReHo = 0;
    end	
    handles.Cfg.CalReHo.AMaskFilename=handles.Cfg.MaskFile;
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

function checkboxsmReHo_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.CalReHo.smReHo = 1;
	else	
		handles.Cfg.CalReHo.smReHo = 0;
    end	
    uiwait(msgbox({['Smooth the mReHo results: the smooth kernel is the same as the kernel set in "Smooth FWHM" part, that is: ',mat2str(handles.Cfg.Smooth.FWHM)];...
            },'ReHo'));
	guidata(hObject, handles);
	UpdateDisplay(handles);    
    
% function checkboxmReHo_1_Callback(hObject, eventdata, handles)
% 	if get(hObject,'Value')
% 		handles.Cfg.CalReHo.mReHo_1 = 1;
% 	else	
% 		handles.Cfg.CalReHo.mReHo_1 = 0;
%     end	
%     uiwait(msgbox({'One-sample t test on ReHo results usually want to see regions shown significantly higher ReHo than the global mean ReHo of the whole brain, thus we compare mReHo results with base "1". Since one-sample t test module in SPM just can compare values with base "0", we need to subtract "1" from the mReHo results, then perform one-sample t test on the subtracted mReHo in SPM.';...
%             },'ReHo'));
% 	guidata(hObject, handles);
% 	UpdateDisplay(handles);        
    
function checkboxCalALFF_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsCalALFF = 1;
	else	
		handles.Cfg.IsCalALFF = 0;
    end	
    handles.Cfg.CalALFF.ASamplePeriod=handles.Cfg.TR;
    handles.Cfg.CalALFF.AMaskFilename=handles.Cfg.MaskFile;
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);        
    
function checkboxCalfALFF_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsCalfALFF = 1;
	else	
		handles.Cfg.IsCalfALFF = 0;
    end	
    uiwait(msgbox({'fALFF calculation is based on data before filter, i.e., detrended data.';...
            },'fALFF'));
    handles.Cfg.CalfALFF.ASamplePeriod=handles.Cfg.TR;
    handles.Cfg.CalfALFF.AMaskFilename=handles.Cfg.MaskFile;
    handles=CheckCfgParameters(handles);
	guidata(hObject, handles);
	UpdateDisplay(handles);      

function edtfAlffBandLow_Callback(hObject, eventdata, handles)
	handles.Cfg.CalALFF.AHighPass_LowCutoff =str2double(get(hObject,'String'));
    handles.Cfg.CalfALFF.AHighPass_LowCutoff=handles.Cfg.CalALFF.AHighPass_LowCutoff;
	guidata(hObject, handles);

function edtfAlffBandHigh_Callback(hObject, eventdata, handles)
	handles.Cfg.CalALFF.ALowPass_HighCutoff =str2double(get(hObject,'String'));
    handles.Cfg.CalfALFF.ALowPass_HighCutoff=handles.Cfg.CalALFF.ALowPass_HighCutoff;
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
    
function checkboxCovremove_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsCovremove = 1;
	else	
		handles.Cfg.IsCovremove = 0;
    end	
    uiwait(msgbox({'Linear regression was performed to remove the effects of the nuisance covariates:';...
        '1. Six head motion parameters: estimated by SPM5''s realign step. If you do not want to use SPM5'' realign, please arrange each subject''s rp*.txt file in one directory (named as same as its functional image directory) , and then put them in "RealignParameter" directory under the working directory. i.e.:';...
        '{Working Directory}\RealignParameter\Subject001\rpxxxxx.txt';...
        '...';...
        '{Working Directory}\RealignParameter\Subject002\rpxxxxx.txt';...
        '...';...
        '2. Global mean signal: mask created by setting a threshold at 50% on SPM5''s apriori mask (brainmask.nii).';...
        '3. White matter signal: mask created by setting a threshold at 90% on SPM5''s apriori mask (white.nii).';...
        '4. Cerebrospinal fluid signal: mask created by setting a threshold at 70% on SPM5''s apriori mask (csf.nii).';...
        '';...
        'The regression was based on data after filter, if you want to regress another kind of data, please arrange each subject''s NIFTI images in one directory, and then put them in "FunImgNormalizedSmoothedDetrendedFiltered" (or "FunImgNormalizedDetrendedFiltered") directory under the working directory. i.e.:';...
        '{Working Directory}\FunImgNormalizedSmoothedDetrendedFiltered\Subject001\xxx001.img';...
        '{Working Directory}\FunImgNormalizedSmoothedDetrendedFiltered\Subject001\xxx002.img';...
        '...';...
        '{Working Directory}\FunImgNormalizedSmoothedDetrendedFiltered\Subject002\xxx001.img';...
        '{Working Directory}\FunImgNormalizedSmoothedDetrendedFiltered\Subject002\xxx002.img';...
        '...';...
        '';...
        },'Regress out nuisance covariates:'));
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
    
function checkboxCovremoveHeadMotion_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.Covremove.HeadMotion = 1;
	else	
		handles.Cfg.Covremove.HeadMotion = 0;
    end	
	guidata(hObject, handles);
	UpdateDisplay(handles); 
    
function checkboxCovremoveWholeBrain_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.Covremove.WholeBrain = 1;
	else	
		handles.Cfg.Covremove.WholeBrain = 0;
    end	
	guidata(hObject, handles);
	UpdateDisplay(handles);    
    
function checkboxCovremoveWhiteMatter_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.Covremove.WhiteMatter = 1;
	else	
		handles.Cfg.Covremove.WhiteMatter = 0;
    end	
	guidata(hObject, handles);
	UpdateDisplay(handles); 
    
function checkboxCovremoveCSF_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.Covremove.CSF = 1;
	else	
		handles.Cfg.Covremove.CSF = 0;
    end	
	guidata(hObject, handles);
	UpdateDisplay(handles);     
    
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
    
    
function checkboxExtractRESTdefinedROITC_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.IsExtractROISignals = 1;
	else	
		handles.Cfg.IsExtractROISignals = 0;
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
    handles.Cfg.CalFC.AMaskFilename=handles.Cfg.MaskFile;
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
     
         
% function checkboxExtractAALTC_Callback(hObject, eventdata, handles)
% 	if get(hObject,'Value')
% 		handles.Cfg.IsExtractAALTC = 1;
% 	else	
% 		handles.Cfg.IsExtractAALTC = 0;
%     end	
%     handles=CheckCfgParameters(handles);
% 	guidata(hObject, handles);
% 	UpdateDisplay(handles);    


   
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
	web('http://rfmri.org/DPARSF');    
    
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
    
function pushbuttonUtilities_Callback(hObject, eventdata, handles)
    [ProgramPath, fileN, extn] = fileparts(which('DPARSF.m'));
    addpath([ProgramPath,filesep,'SubGUIs']);
	Utilities_fig=figure('name','Utilities','menubar','none','numbertitle','off','position',[100 100 300 100]);
    uicontrol(Utilities_fig,'Style','pushbutton', 'Position',[50 30 200 40],...
        'String','Change the Prefix of Images','ToolTipString','Change the Prefix of Images since DPARSF need some special prefixes in some cases.', ...
        'Callback', 'DPARSF_ChangeImgPrefix_gui')
    movegui(Utilities_fig, 'center');

function SetLoadedData(hObject,handles, Cfg);	
    handles.Cfg=Cfg;
    guidata(hObject, handles);
    UpdateDisplay(handles);
    
function pushbuttonQuit_Callback(hObject, eventdata, handles)
	close(handles.figDPARSFMain);     
    
function pushbuttonRun_Callback(hObject, eventdata, handles)
    [handles, CheckingPass]=CheckCfgParameters(handles);
    if CheckingPass==0
        return
    end
%     StepConsecutiveChecking=[handles.Cfg.IsNeedConvertFunDCM2IMG,...
%         handles.Cfg.IsNeedConvertFunDCM2IMG,...   %handles.Cfg.IsRemoveFirst10TimePoints %YAN Chao-Gan 090831: IsRemoveFirst10TimePoints has been changed to RemoveFirstTimePoints, this step is no longer necessary, thus replaced it with handles.Cfg.IsNeedConvertFunDCM2IMG to no longer interfere the checking.
%         handles.Cfg.IsSliceTiming,...
%         handles.Cfg.IsRealign,...
%         handles.Cfg.IsNormalize,...
%         handles.Cfg.IsDetrend,...
%         handles.Cfg.IsFilter,...
%         handles.Cfg.IsCovremove,...
%         handles.Cfg.IsCalFC];
%     StepConsecutiveCheckingName={'EPI DICOM to NIFTI',...
%         'Remove First Time Points',...  %YAN Chao-Gan 090831: This will no longer happen, since IsRemoveFirst10TimePoints has been changed to RemoveFirstTimePoints.
%         'Slice Timing',...
%         'Realign',...
%         'Normalize',...
%         'Detrend',...
%         'Filter',...
%         'Regress out nuisance covariates',...
%         'Functional Connectivity'};
%     StepIndex=find(StepConsecutiveChecking);
%     if length(StepIndex)>=2
%         StepMask=[zeros(1,StepIndex(1)-1),ones(1,StepIndex(end)-StepIndex(1)+1),zeros(1,length(StepConsecutiveChecking)-StepIndex(end))];
%         StepDisConsecutive=(~StepConsecutiveChecking).*StepMask;
%         if any(StepDisConsecutive)
%             StepDisConsecutiveIndex=find(StepDisConsecutive);
%             theMsg=[];
%             for i=1:length(StepDisConsecutiveIndex)
%                 theMsg=[theMsg, ' "',StepConsecutiveCheckingName{StepDisConsecutiveIndex(i)},'" ']
%             end
%             theMsg =['The steps from "',StepConsecutiveCheckingName{StepIndex(1)},'" to "',StepConsecutiveCheckingName{StepIndex(end)},'" should be consecutive, you need to choose the following steps to ensure the continuity: ',theMsg,'.'];
%             uiwait(msgbox(theMsg,'Configuration parameters checking','warn'));
%             return
%         end
%     end
    
    RawBackgroundColor=get(handles.pushbuttonRun ,'BackgroundColor');
    RawForegroundColor=get(handles.pushbuttonRun ,'ForegroundColor');
    set(handles.pushbuttonRun ,'Enable', 'off','BackgroundColor', 'red','ForegroundColor','green');
    Cfg=handles.Cfg; %Added by YAN Chao-Gan, 100130. Save the configuration parameters automatically.
    Datetime=fix(clock); %Added by YAN Chao-Gan, 100130.
    save([handles.Cfg.DataProcessDir,filesep,'DPARSF_AutoSave_',num2str(Datetime(1)),'_',num2str(Datetime(2)),'_',num2str(Datetime(3)),'_',num2str(Datetime(4)),'_',num2str(Datetime(5)),'.mat'], 'Cfg'); %Added by YAN Chao-Gan, 100130.
    [Error]=DPARSF_run(handles.Cfg);
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
                    handles.Cfg.SubjectID=[handles.Cfg.SubjectID;{Dir(i).name}];
                end
            end
            
            if (handles.Cfg.TimePoints)>0 % If the number of time points is not set at 0, then check the number of time points.
                if ~(strcmpi(handles.Cfg.StartingDirName,'T1Raw') || strcmpi(handles.Cfg.StartingDirName,'T1Img') || strcmpi(handles.Cfg.StartingDirName,'T1NiiGZ') ) %If not just use for VBM, check if the time points right. %YAN Chao-Gan, 111130. Also add T1 .nii.gz support.
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
    
    if handles.Cfg.IsNormalize>0
		set(handles.checkboxNormalize, 'Value', 1);	
        set(handles.editBoundingBox, 'Enable', 'on', 'String', mat2str(handles.Cfg.Normalize.BoundingBox));
        set(handles.editVoxSize, 'Enable', 'on', 'String', mat2str(handles.Cfg.Normalize.VoxSize));
        set(handles.radiobuttonNormalize_EPI,'Enable', 'on', 'Value',handles.Cfg.IsNormalize==1);
        set(handles.radiobuttonNormalize_T1,'Enable', 'on', 'Value',handles.Cfg.IsNormalize==2);
        set(handles.radiobuttonNormalize_DARTEL,'Enable', 'on', 'Value',handles.Cfg.IsNormalize==3);
        if handles.Cfg.IsNormalize>=2
            set(handles.checkboxT1DICOM2NIFTI, 'Visible', 'on', 'Value', handles.Cfg.IsNeedConvertT1DCM2IMG);
            set(handles.textAffineRegularisation, 'Visible', 'on');
            set(handles.radiobuttonEastAsian,'Visible', 'on','Value',strcmpi(handles.Cfg.Normalize.AffineRegularisationInSegmentation,'eastern'));
            set(handles.radiobuttonEuropean,'Visible', 'on','Value',strcmpi(handles.Cfg.Normalize.AffineRegularisationInSegmentation,'mni'));
        else
            set(handles.checkboxT1DICOM2NIFTI, 'Visible', 'off', 'Value', handles.Cfg.IsNeedConvertT1DCM2IMG);
            set(handles.textAffineRegularisation, 'Visible', 'off');
            set(handles.radiobuttonEastAsian,'Visible', 'off','Value',strcmpi(handles.Cfg.Normalize.AffineRegularisationInSegmentation,'eastern'));
            set(handles.radiobuttonEuropean,'Visible', 'off','Value',strcmpi(handles.Cfg.Normalize.AffineRegularisationInSegmentation,'mni'));
        end
%         set(handles.checkboxIsDelFilesBeforeNormalize,'Enable', 'on', 'Value',handles.Cfg.IsDelFilesBeforeNormalize);
        set(handles.textBoundingBox,'Enable', 'on');
        set(handles.textVoxSize,'Enable', 'on');
        set(handles.text29,'Enable', 'on');
    else
		set(handles.checkboxNormalize, 'Value', 0);	
        set(handles.editBoundingBox, 'Enable', 'off', 'String', mat2str(handles.Cfg.Normalize.BoundingBox));
        set(handles.editVoxSize, 'Enable', 'off', 'String', mat2str(handles.Cfg.Normalize.VoxSize));
        set(handles.radiobuttonNormalize_EPI,'Enable', 'off','Value',1);
        set(handles.radiobuttonNormalize_T1,'Enable', 'off','Value',0);
        set(handles.radiobuttonNormalize_DARTEL,'Enable', 'off','Value',0);
        set(handles.checkboxT1DICOM2NIFTI, 'Visible', 'off', 'Value', handles.Cfg.IsNeedConvertT1DCM2IMG);
        set(handles.textAffineRegularisation, 'Visible', 'off');
        set(handles.radiobuttonEastAsian,'Visible', 'off','Value',strcmpi(handles.Cfg.Normalize.AffineRegularisationInSegmentation,'eastern'));
        set(handles.radiobuttonEuropean,'Visible', 'off','Value',strcmpi(handles.Cfg.Normalize.AffineRegularisationInSegmentation,'mni'));
%         set(handles.checkboxIsDelFilesBeforeNormalize,'Enable', 'off', 'Value',handles.Cfg.IsDelFilesBeforeNormalize);
        set(handles.textBoundingBox,'Enable', 'off');
        set(handles.textVoxSize,'Enable', 'off');
        set(handles.text29,'Enable', 'off');
    end
    
    if handles.Cfg.IsSmooth==1
		set(handles.checkboxSmooth, 'Value', 1);	
        set(handles.editFWHM, 'Enable', 'on', 'String', mat2str(handles.Cfg.Smooth.FWHM));
        set(handles.textFWHM,'Enable', 'on');
    else
		set(handles.checkboxSmooth, 'Value', 0);	
        set(handles.editFWHM, 'Enable', 'off', 'String', mat2str(handles.Cfg.Smooth.FWHM));
        set(handles.textFWHM,'Enable', 'off');
    end
    
%     set(handles.radiobuttonDataWithSmooth,'Value',handles.Cfg.DataIsSmoothed);
% 	set(handles.radiobuttonDataWithoutSmooth,'Value',handles.Cfg.DataIsSmoothed==0);
    
    set(handles.checkboxDetrend,'Value',handles.Cfg.IsDetrend);
    
    if handles.Cfg.IsFilter==1
        set(handles.ckboxFilter, 'Value', 1);
        set(handles.edtBandLow, 'Enable', 'on', 'String', num2str(handles.Cfg.Filter.AHighPass_LowCutoff));
        set(handles.edtBandHigh, 'Enable', 'on', 'String', num2str(handles.Cfg.Filter.ALowPass_HighCutoff));
%         set(handles.checkboxIsDelDetrendedFiles, 'Enable', 'on', 'Value', handles.Cfg.IsDelDetrendedFiles);
        set(handles.txtBandSep,'Enable', 'on');
    else
        set(handles.ckboxFilter, 'Value', 0);
        set(handles.edtBandLow, 'Enable', 'off', 'String', num2str(handles.Cfg.Filter.AHighPass_LowCutoff));
        set(handles.edtBandHigh, 'Enable', 'off', 'String', num2str(handles.Cfg.Filter.ALowPass_HighCutoff));
%         set(handles.checkboxIsDelDetrendedFiles, 'Enable', 'off', 'Value', handles.Cfg.IsDelDetrendedFiles);
        set(handles.txtBandSep,'Enable', 'off');
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
    
    if handles.Cfg.IsCalReHo==1
        set(handles.checkboxCalReHo, 'Value', 1);
        set(handles.radiobuttonReHo7voxels, 'Enable', 'on', 'Value', handles.Cfg.CalReHo.ClusterNVoxel == 7);
        set(handles.radiobuttonReHo19voxels, 'Enable', 'on', 'Value', handles.Cfg.CalReHo.ClusterNVoxel == 19);
        set(handles.radiobuttonReHo27voxels, 'Enable', 'on', 'Value', handles.Cfg.CalReHo.ClusterNVoxel == 27);
        set(handles.checkboxsmReHo, 'Enable', 'on', 'Value', handles.Cfg.CalReHo.smReHo);
%         set(handles.checkboxmReHo_1, 'Enable', 'on', 'Value', handles.Cfg.CalReHo.mReHo_1);
        set(handles.textReHoCluster,'Enable', 'on');
    else
        set(handles.checkboxCalReHo, 'Value', 0);
        set(handles.radiobuttonReHo7voxels, 'Enable', 'off', 'Value', handles.Cfg.CalReHo.ClusterNVoxel == 7);
        set(handles.radiobuttonReHo19voxels, 'Enable', 'off', 'Value', handles.Cfg.CalReHo.ClusterNVoxel == 19);
        set(handles.radiobuttonReHo27voxels, 'Enable', 'off', 'Value', handles.Cfg.CalReHo.ClusterNVoxel == 27);
        set(handles.checkboxsmReHo, 'Enable', 'off', 'Value', handles.Cfg.CalReHo.smReHo);
%         set(handles.checkboxmReHo_1, 'Enable', 'off', 'Value', handles.Cfg.CalReHo.mReHo_1);
        set(handles.textReHoCluster,'Enable', 'off');
    end
    
    if (handles.Cfg.IsCalALFF==1) || (handles.Cfg.IsCalfALFF==1)
        set(handles.checkboxCalALFF, 'Value', handles.Cfg.IsCalALFF);
        set(handles.checkboxCalfALFF, 'Value', handles.Cfg.IsCalfALFF);
        set(handles.edtfAlffBandLow, 'Enable', 'on', 'String', num2str(handles.Cfg.CalALFF.AHighPass_LowCutoff));
        set(handles.edtfAlffBandHigh, 'Enable', 'on', 'String', num2str(handles.Cfg.CalALFF.ALowPass_HighCutoff));
%         set(handles.checkboxmALFF_1, 'Enable', 'on', 'Value', handles.Cfg.CalALFF.mALFF_1);
        set(handles.txtfAlffBand,'Enable', 'on');
        set(handles.txtfAlffBandSep,'Enable', 'on');
    else
        set(handles.checkboxCalALFF, 'Value', handles.Cfg.IsCalALFF);
        set(handles.checkboxCalfALFF, 'Value', handles.Cfg.IsCalfALFF);
        set(handles.edtfAlffBandLow, 'Enable', 'off', 'String', num2str(handles.Cfg.CalALFF.AHighPass_LowCutoff));
        set(handles.edtfAlffBandHigh, 'Enable', 'off', 'String', num2str(handles.Cfg.CalALFF.ALowPass_HighCutoff));
%         set(handles.checkboxmALFF_1, 'Enable', 'off', 'Value', handles.Cfg.CalALFF.mALFF_1);
        set(handles.txtfAlffBand,'Enable', 'off');
        set(handles.txtfAlffBandSep,'Enable', 'off');
    end
    
    if handles.Cfg.IsCovremove==1
        set(handles.checkboxCovremove, 'Value', 1);
        set(handles.editPolynomialTrend, 'Enable', 'on', 'String', num2str(handles.Cfg.Covremove.PolynomialTrend));
        set(handles.checkboxCovremoveHeadMotion, 'Enable', 'on', 'Value', handles.Cfg.Covremove.HeadMotion);
        set(handles.checkboxCovremoveWholeBrain, 'Enable', 'on', 'Value', handles.Cfg.Covremove.WholeBrain);
        set(handles.checkboxCovremoveWhiteMatter, 'Enable', 'on', 'Value', handles.Cfg.Covremove.WhiteMatter);
        set(handles.checkboxCovremoveCSF, 'Enable', 'on', 'Value', handles.Cfg.Covremove.CSF);
        set(handles.checkboxOtherCovariates, 'Enable', 'on', 'Value', ~isempty(handles.Cfg.Covremove.OtherCovariatesROI));
    else
        set(handles.checkboxCovremove, 'Value', 0);
        set(handles.editPolynomialTrend, 'Enable', 'off', 'String', num2str(handles.Cfg.Covremove.PolynomialTrend));
        set(handles.checkboxCovremoveHeadMotion, 'Enable', 'off', 'Value', handles.Cfg.Covremove.HeadMotion);
        set(handles.checkboxCovremoveWholeBrain, 'Enable', 'off', 'Value', handles.Cfg.Covremove.WholeBrain);
        set(handles.checkboxCovremoveWhiteMatter, 'Enable', 'off', 'Value', handles.Cfg.Covremove.WhiteMatter);
        set(handles.checkboxCovremoveCSF, 'Enable', 'off', 'Value', handles.Cfg.Covremove.CSF);
        set(handles.checkboxOtherCovariates, 'Enable', 'off', 'Value', ~isempty(handles.Cfg.Covremove.OtherCovariatesROI));
    end
    
    if (handles.Cfg.IsExtractROISignals==1) || (handles.Cfg.IsCalFC==1)
        set(handles.checkboxExtractRESTdefinedROITC, 'Value', handles.Cfg.IsExtractROISignals);
        set(handles.checkboxCalFC, 'Value', handles.Cfg.IsCalFC);
        set(handles.pushbuttonDefineROI, 'Enable', 'on');
    else
        set(handles.checkboxExtractRESTdefinedROITC, 'Value', handles.Cfg.IsExtractROISignals);
        set(handles.checkboxCalFC, 'Value', handles.Cfg.IsCalFC);
        set(handles.pushbuttonDefineROI, 'Enable', 'off');
    end
    
%     set(handles.checkboxExtractAALTC, 'Value', handles.Cfg.IsExtractAALTC);


    set(handles.editStartingDirName ,'String', handles.Cfg.StartingDirName);
    
    % Check if Parallel Computation Toolbox is detected and higher than MATLAB 2008.
    FullMatlabVersion = sscanf(version,'%d.%d.%d.%d%s');
    PCTVer = ver('distcomp');
    if (~isempty(PCTVer)) && (FullMatlabVersion(1)*1000+FullMatlabVersion(2)>=7*1000+8)
        set(handles.editParallelWorkersNumber ,'String', num2str(handles.Cfg.ParallelWorkersNumber), 'Enable', 'on');	
    else
        set(handles.editParallelWorkersNumber ,'String', num2str(handles.Cfg.ParallelWorkersNumber), 'Enable', 'off');	
    end

    drawnow;
   
