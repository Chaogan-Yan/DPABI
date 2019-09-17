function Cfg = y_GenerateQCHTML(Cfg)
% function Cfg = y_GenerateQCHTML(Cfg)
% Generate QC HTML file based on results by fmriprep.
%   Input:
%     Cfg - DPARSFA Cfg structure
%   Output:
%     see /QC.
%___________________________________________________________________________
% Written by YAN Chao-Gan 190915.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com


[DPABIPath, fileN, extn] = fileparts(which('DPABI.m'));

Cfg.SubjectNum=length(Cfg.SubjectID);

mkdir([Cfg.WorkingDir,filesep,'QC']);

fid = fopen([Cfg.WorkingDir,filesep,'QC',filesep,'QC_SurfaceReconstruction.html'],'w');
fprintf(fid, ['<HTML><HEAD><TITLE>Check Surface Reconstruction</TITLE>\n']);
fprintf(fid, ['<link rel="stylesheet" ...href="exp.css" type="text/css">\n']);
fprintf(fid, ['</HEAD>\n']);
fprintf(fid, ['<BODY>\n']);
fprintf(fid, ['<H1>Check Surface Reconstruction</H1>\n']);
fprintf(fid, ['<HR SIZE=5>\n']);
for i=1:Cfg.SubjectNum
    fprintf(fid, ['<li>Subject ID: %s</li>\n'],Cfg.SubjectID{i});
    fprintf(fid, ['<div class="elem-image">\n']);
    fprintf(fid, '<object class="svg-reportlet" type="image/svg+xml" data="../fmriprep/%s/figures/%s_desc-reconall_T1w.svg"></object>\n',Cfg.SubjectID{i},Cfg.SubjectID{i});
    fprintf(fid, ['</div>\n']);
    fprintf(fid, ['<br>\n']);
    fprintf(fid, ['<br>\n']);
end
fprintf(fid, ['</BODY>\n']);
fprintf(fid, ['</HTML>\n']);
fclose(fid);


fid = fopen([Cfg.WorkingDir,filesep,'QC',filesep,'QC_EPItoT1.html'],'w');
fprintf(fid, ['<HTML><HEAD><TITLE>Check EPI to T1 registration</TITLE>\n']);
fprintf(fid, ['<link rel="stylesheet" ...href="exp.css" type="text/css">\n']);
fprintf(fid, ['</HEAD>\n']);
fprintf(fid, ['<BODY>\n']);
fprintf(fid, ['<H1>Check EPI to T1 registration</H1>\n']);
fprintf(fid, ['<HR SIZE=5>\n']);
for i=1:Cfg.SubjectNum
    fprintf(fid, ['<li>Subject ID: %s</li>\n'],Cfg.SubjectID{i});
    fprintf(fid, ['<div class="elem-image">\n']);
    fprintf(fid, '<object class="svg-reportlet" type="image/svg+xml" data="../fmriprep/%s/figures/%s_task-rest_desc-bbregister_bold.svg"></object>\n',Cfg.SubjectID{i},Cfg.SubjectID{i});
    fprintf(fid, ['</div>\n']);
    fprintf(fid, ['<br>\n']);
    fprintf(fid, ['<br>\n']);
end
fprintf(fid, ['</BODY>\n']);
fprintf(fid, ['</HTML>\n']);
fclose(fid);


fid = fopen([Cfg.WorkingDir,filesep,'QC',filesep,'QC_T1toMNI.html'],'w');
fprintf(fid, ['<HTML><HEAD><TITLE>Check T1 to MNI registration</TITLE>\n']);
fprintf(fid, ['<link rel="stylesheet" ...href="exp.css" type="text/css">\n']);
fprintf(fid, ['</HEAD>\n']);
fprintf(fid, ['<BODY>\n']);
fprintf(fid, ['<H1>Check T1 to MNI registration</H1>\n']);
fprintf(fid, ['<HR SIZE=5>\n']);
for i=1:Cfg.SubjectNum
    fprintf(fid, ['<li>Subject ID: %s</li>\n'],Cfg.SubjectID{i});
    fprintf(fid, ['<div class="elem-image">\n']);
    fprintf(fid, '<object class="svg-reportlet" type="image/svg+xml" data="../fmriprep/%s/figures/%s_space-MNI152NLin2009cAsym_T1w.svg"></object>\n',Cfg.SubjectID{i},Cfg.SubjectID{i});
    fprintf(fid, ['</div>\n']);
    fprintf(fid, ['<br>\n']);
    fprintf(fid, ['<br>\n']);
end
fprintf(fid, ['</BODY>\n']);
fprintf(fid, ['</HTML>\n']);
fclose(fid);




fprintf('Generate QC HTML files finished!\n');
