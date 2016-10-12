function y_WarpBackByDARTEL(SourceFile,OutFile,RefFile,DARTELTemplateFilename,DARTELTemplateMatFilename,FlowFieldFilename,Interp)
% FORMAT y_WarpBackByDARTEL(SourceFile,OutFile,RefFile,DARTELTemplateFilename,DARTELTemplateMatFilename,FlowFieldFilename,Interp)
% Warp a mask from MNI space into a subject's native functional space.
% See more information in my conversation with John Ashburner: https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=ind1203&L=spm&P=R89160&1=spm&9=A&J=on&d=No+Match%3BMatch%3BMatches&z=4
%   SourceFile - source filename: Nfile by 1 cell
%   OutFile    - output filename: Nfile by 1 cell. And should be in the same directory
%   RefFile    - reference file
%   DARTELTemplateFilename    - the DARTEL template. Usually 'Template_6.nii' under the T1ImgNewSegment of the first subject
%   DARTELTemplateMatFilename - The Affine matrix for DARTEL template to MNI space. Usually 'Template_6_2mni.mat' under the T1ImgNewSegment of the first subject
%   FlowFieldFilename         - Flow field to template space of one subject. 'u_*.nii' under the T1ImgNewSegment of the this subject
%   Interp - interpolation method. 0: Nearest Neighbour. 1: Trilinear.
%__________________________________________________________________________
% Written by YAN Chao-Gan 120822 for DPARSF.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com


%[ProgramPath, fileN, extn] = fileparts(which('DPARSFA_run.m'));
[DPABIPath, fileN, extn] = fileparts(which('DPABI.m'));
ProgramPath=fullfile(DPABIPath, 'DPARSF');
[SPMversionText,c]=spm('Ver');
SPMversion=str2double(SPMversionText(end-1:end));
if isnan(SPMversion)
    SPMversion=str2double(SPMversionText(end));
end


for iFile=1:length(SourceFile)
    [Data Head]=y_Read(SourceFile{iFile});
    Head.pinfo = [1;0;0];
    y_Write(Data,Head,OutFile{iFile});
end


%Convert to the Template space first
T_MNI_Affine=load(DARTELTemplateMatFilename);
DARTELTemplate_Mat = spm_get_space(DARTELTemplateFilename);

for iFile=1:length(OutFile)
    MNI_Mat = spm_get_space(OutFile{iFile});
    spm_get_space(OutFile{iFile},DARTELTemplate_Mat*inv(T_MNI_Affine.mni.affine)*MNI_Mat);  % See My conversation with John Ashburner: https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=ind1203&L=spm&P=R89160&1=spm&9=A&J=on&d=No+Match%3BMatch%3BMatches&z=4
end


% Warp to the original T1 space second
if SPMversion==8
    SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Deformation_Blank.mat']);
    SPMJOB.matlabbatch{1,1}.spm.util.defs.ofname=''; % ouput name for y_*.nii
    SPMJOB.matlabbatch{1,1}.spm.util.defs.fnames=OutFile; %fnames could be n*1 cell
    SPMJOB.matlabbatch{1,1}.spm.util.defs.interp=Interp;
    %SPMJOB.matlabbatch{1,1}.spm.util.defs.comp{1,1}.dartel.times = [1,0]; % Backward.  If want forward, then put [0,1];
    SPMJOB.matlabbatch{1,1}.spm.util.defs.comp{1,1}.dartel.times = [0,1]; % Forward.  If want backward, then put [1,0];
    SPMJOB.matlabbatch{1,1}.spm.util.defs.comp{1,1}.dartel.flowfield{1,1}=FlowFieldFilename;
elseif SPMversion==12
    SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Deformation_Blank_SPM12.mat']);
    SPMJOB.matlabbatch{1,1}.spm.util.defs.out{1,1}.pull.fnames=OutFile; %fnames could be n*1 cell
    SPMJOB.matlabbatch{1,1}.spm.util.defs.out{1,1}.pull.interp=Interp;
    %SPMJOB.matlabbatch{1,1}.spm.util.defs.comp{1,1}.dartel.times = [1,0]; % Backward.  If want forward, then put [0,1];
    SPMJOB.matlabbatch{1,1}.spm.util.defs.comp{1,1}.dartel.times = [0,1]; % Forward.  If want backward, then put [1,0];
    SPMJOB.matlabbatch{1,1}.spm.util.defs.comp{1,1}.dartel.flowfield=[];
    SPMJOB.matlabbatch{1,1}.spm.util.defs.comp{1,1}.dartel.flowfield{1,1}=FlowFieldFilename;
end


[OutPathTemp] = fileparts(OutFile{1});
if isempty(OutPathTemp)
    OutPathTemp = pwd;
end
cd(OutPathTemp);
spm_jobman('run',SPMJOB.matlabbatch);


% Reslice to the original functional space third.
[RefData,RefVox,RefHeader]=y_ReadRPI(RefFile,1);
for iFile=1:length(OutFile)
    [OutPath, OutName, OutExt] = fileparts(OutFile{iFile});
    if isempty(OutPath)
        OutPath = pwd;
    end
    
    y_Reslice([OutPathTemp,filesep,'w',OutName, OutExt],OutFile{iFile},RefVox,Interp, RefFile);
    
    delete([OutPathTemp,filesep,'w',OutName, OutExt]); % Delete the temp file
end
