function Cfg = y_Organize_SegmentSubregions(Cfg,WorkingDir,SubjectListFile)
% function Cfg = y_Organize_SegmentSubregions(Cfg,WorkingDir,SubjectListFile)
% Organize results by Segment Subregions.
%   Input:
%   Cfg - the parameters for auto data processing. 
%   WorkingDir - Define the working directory to replace the one defined in Cfg
%   SubjectListFile - Define the subject list to replace the one defined in Cfg. Should be a text file
%   Output:
%     see Results/AnatVolu/Anat_Segment_Subregions_Volume.csv and related files.
%___________________________________________________________________________
% Written by YAN Chao-Gan 230214.
% The R-fMRI Lab, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% International Big-Data Center for Depression Research, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com


if ischar(Cfg)  %If inputed a .mat file name. (Cfg inside)
    load(Cfg);
end

if exist('WorkingDir','var') && ~isempty(WorkingDir)
    Cfg.WorkingDir=WorkingDir;
end

if exist('SubjectListFile','var') && ~isempty(SubjectListFile)
    fid = fopen(SubjectListFile);
    IDCell = textscan(fid,'%s\n'); %YAN Chao-Gan. For compatiblity of MALLAB 2014b. IDCell = textscan(fid,'%s','\n');
    fclose(fid);
    Cfg.SubjectID=IDCell{1};
end


[DPABIPath, fileN, extn] = fileparts(which('DPABI.m'));

Cfg.SubjectNum=length(Cfg.SubjectID);
SubjectIDString=[];
for i=1:Cfg.SubjectNum
    SubjectIDString = sprintf('%s %s',SubjectIDString,Cfg.SubjectID{i});
end

if ispc
    CommandInit=sprintf('docker run -i --rm -v %s:/opt/freesurfer/license.txt -v %s:/data -e SUBJECTS_DIR=/data/freesurfer cgyan/dpabi', fullfile(DPABIPath, 'DPABISurf', 'FreeSurferLicense', 'license.txt'), Cfg.WorkingDir); %YAN Chao-Gan, 181214. Remove -t because there is a tty issue in windows
else
    CommandInit=sprintf('docker run -ti --rm -v %s:/opt/freesurfer/license.txt -v %s:/data -e SUBJECTS_DIR=/data/freesurfer cgyan/dpabi', fullfile(DPABIPath, 'DPABISurf', 'FreeSurferLicense', 'license.txt'), Cfg.WorkingDir); 
end
if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
    CommandInit=sprintf('export SUBJECTS_DIR=%s/freesurfer && ', Cfg.WorkingDir);
    WorkingDir=Cfg.WorkingDir;
else
    WorkingDir='/data';
end



%Write table
SegTable=[];
for i=1:Cfg.SubjectNum

    SubjectID={Cfg.SubjectID{i}};
    OneSub=table(SubjectID);

    SegVolume=readtable(fullfile(Cfg.WorkingDir,'freesurfer',Cfg.SubjectID{i},'mri','lh.hippoSfVolumes.txt'),'ReadRowNames',true);
    SegVolume=rows2vars(SegVolume);
    SegVolume=removevars(SegVolume,'OriginalVariableNames');
    VarName=SegVolume.Properties.VariableNames;
    VarName = append('Left-',VarName);
    SegVolume=renamevars(SegVolume,1:width(SegVolume),VarName);
    SegVolume.SubjectID={Cfg.SubjectID{i}};
    OneSub=join(OneSub,SegVolume);

    SegVolume=readtable(fullfile(Cfg.WorkingDir,'freesurfer',Cfg.SubjectID{i},'mri','rh.hippoSfVolumes.txt'),'ReadRowNames',true);
    SegVolume=rows2vars(SegVolume);
    SegVolume=removevars(SegVolume,'OriginalVariableNames');
    VarName=SegVolume.Properties.VariableNames;
    VarName = append('Right-',VarName);
    SegVolume=renamevars(SegVolume,1:width(SegVolume),VarName);
    SegVolume.SubjectID={Cfg.SubjectID{i}};
    OneSub=join(OneSub,SegVolume);

    SegVolume=readtable(fullfile(Cfg.WorkingDir,'freesurfer',Cfg.SubjectID{i},'mri','lh.amygNucVolumes.txt'),'ReadRowNames',true);
    SegVolume=rows2vars(SegVolume);
    SegVolume=removevars(SegVolume,'OriginalVariableNames');
    VarName=SegVolume.Properties.VariableNames;
    VarName = append('Left-',VarName);
    SegVolume=renamevars(SegVolume,1:width(SegVolume),VarName);
    SegVolume.SubjectID={Cfg.SubjectID{i}};
    OneSub=join(OneSub,SegVolume);

    SegVolume=readtable(fullfile(Cfg.WorkingDir,'freesurfer',Cfg.SubjectID{i},'mri','rh.amygNucVolumes.txt'),'ReadRowNames',true);
    SegVolume=rows2vars(SegVolume);
    SegVolume=removevars(SegVolume,'OriginalVariableNames');
    VarName=SegVolume.Properties.VariableNames;
    VarName = append('Right-',VarName);
    SegVolume=renamevars(SegVolume,1:width(SegVolume),VarName);
    SegVolume.SubjectID={Cfg.SubjectID{i}};
    OneSub=join(OneSub,SegVolume);

    SegVolume=readtable(fullfile(Cfg.WorkingDir,'freesurfer',Cfg.SubjectID{i},'mri','ThalamicNuclei.volumes.txt'),'ReadRowNames',true);
    SegVolume=rows2vars(SegVolume);
    SegVolume=removevars(SegVolume,'OriginalVariableNames');
    SegVolume.SubjectID={Cfg.SubjectID{i}};
    OneSub=join(OneSub,SegVolume);

    SegVolume=readtable(fullfile(Cfg.WorkingDir,'freesurfer',Cfg.SubjectID{i},'mri','brainstemSsLabels.volumes.txt'),'ReadRowNames',true);
    SegVolume=rows2vars(SegVolume);
    SegVolume=removevars(SegVolume,'OriginalVariableNames');
    SegVolume.SubjectID={Cfg.SubjectID{i}};
    OneSub=join(OneSub,SegVolume);

    SegTable=[SegTable;OneSub];
end

writetable(SegTable,fullfile(Cfg.WorkingDir,'Results','AnatVolu','Anat_Segment_Subregions_Volume.csv'),'Delimiter','\t');


%Convert to .nii
Command = sprintf('%s parallel -j %g mri_convert %s/freesurfer/{1}/mri/lh.hippoAmygLabels.CA.FSvoxelSpace.mgz %s/Results/AnatVolu/T1wSpace/{1}/{1}_Subregions_lh.hippoAmygLabels.CA.FSvoxelSpace.nii.gz ::: %s', ...
    CommandInit, Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,SubjectIDString);
system(Command);
Command = sprintf('%s parallel -j %g mri_convert %s/freesurfer/{1}/mri/lh.hippoAmygLabels.FS60.FSvoxelSpace.mgz %s/Results/AnatVolu/T1wSpace/{1}/{1}_Subregions_lh.hippoAmygLabels.FS60.FSvoxelSpace.nii.gz ::: %s', ...
    CommandInit, Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,SubjectIDString);
system(Command);
Command = sprintf('%s parallel -j %g mri_convert %s/freesurfer/{1}/mri/lh.hippoAmygLabels.HBT.FSvoxelSpace.mgz %s/Results/AnatVolu/T1wSpace/{1}/{1}_Subregions_lh.hippoAmygLabels.HBT.FSvoxelSpace.nii.gz ::: %s', ...
    CommandInit, Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,SubjectIDString);
system(Command);
Command = sprintf('%s parallel -j %g mri_convert %s/freesurfer/{1}/mri/lh.hippoAmygLabels.FSvoxelSpace.mgz %s/Results/AnatVolu/T1wSpace/{1}/{1}_Subregions_lh.hippoAmygLabels.FSvoxelSpace.nii.gz ::: %s', ...
    CommandInit, Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,SubjectIDString);
system(Command);

Command = sprintf('%s parallel -j %g mri_convert %s/freesurfer/{1}/mri/rh.hippoAmygLabels.CA.FSvoxelSpace.mgz %s/Results/AnatVolu/T1wSpace/{1}/{1}_Subregions_rh.hippoAmygLabels.CA.FSvoxelSpace.nii.gz ::: %s', ...
    CommandInit, Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,SubjectIDString);
system(Command);
Command = sprintf('%s parallel -j %g mri_convert %s/freesurfer/{1}/mri/rh.hippoAmygLabels.FS60.FSvoxelSpace.mgz %s/Results/AnatVolu/T1wSpace/{1}/{1}_Subregions_rh.hippoAmygLabels.FS60.FSvoxelSpace.nii.gz ::: %s', ...
    CommandInit, Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,SubjectIDString);
system(Command);
Command = sprintf('%s parallel -j %g mri_convert %s/freesurfer/{1}/mri/rh.hippoAmygLabels.HBT.FSvoxelSpace.mgz %s/Results/AnatVolu/T1wSpace/{1}/{1}_Subregions_rh.hippoAmygLabels.HBT.FSvoxelSpace.nii.gz ::: %s', ...
    CommandInit, Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,SubjectIDString);
system(Command);
Command = sprintf('%s parallel -j %g mri_convert %s/freesurfer/{1}/mri/rh.hippoAmygLabels.FSvoxelSpace.mgz %s/Results/AnatVolu/T1wSpace/{1}/{1}_Subregions_rh.hippoAmygLabels.FSvoxelSpace.nii.gz ::: %s', ...
    CommandInit, Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,SubjectIDString);
system(Command);

Command = sprintf('%s parallel -j %g mri_convert %s/freesurfer/{1}/mri/ThalamicNuclei.FSvoxelSpace.mgz %s/Results/AnatVolu/T1wSpace/{1}/{1}_Subregions_ThalamicNuclei.FSvoxelSpace.nii.gz ::: %s', ...
    CommandInit, Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,SubjectIDString);
system(Command);
Command = sprintf('%s parallel -j %g mri_convert %s/freesurfer/{1}/mri/brainstemSsLabels.FSvoxelSpace.mgz %s/Results/AnatVolu/T1wSpace/{1}/{1}_Subregions_brainstemSsLabels.FSvoxelSpace.nii.gz ::: %s', ...
    CommandInit, Cfg.ParallelWorkersNumber, WorkingDir,WorkingDir,SubjectIDString);
system(Command);


fprintf('Organize results by Segment Subregions finished!\n');
