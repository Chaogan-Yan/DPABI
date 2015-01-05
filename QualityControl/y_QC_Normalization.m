function H = y_QC_Normalization(WorkingDir,SubjectID,IsCheckwT1,IsCheckwFun,IsCheckwGM)
% function H = y_QC_Normalization(WorkingDir,SubjectID)
% Function QC normalization effects.
% Input:
%     WorkingDir  - The working directory of DPARSF.
%     SubjectID   - SubjectID need to be QCed.
%     IsCheckwT1   - 1 or 0: 1 means need to check T1 images after spatial normalization ({WorkingDir}/T1ImgNewSegment/{SubID}/w*T1*.nii). 
%     IsCheckwFun  - 1 or 0: 1 means need to check functional images after spatial normalization ({WorkingDir}/RealignParameter/{SubID}/wmean*.nii). 
% Output:
%     {WorkDir}/QC/NormalizationQC.tsv
%___________________________________________________________________________
% Written by YAN Chao-Gan 131204.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com


[DPABIPath, fileN, extn] = fileparts(which('DPABI.m'));
Edge_File = [DPABIPath,filesep,'Templates',filesep,'Edge_mni_icbm152_AllTissues_tal_nlin_asym_09c_YCG.nii'];
Ch2File=[DPABIPath,filesep,'Templates',filesep,'ch2.nii'];
MNIASYMFile=[DPABIPath,filesep,'Templates',filesep,'mni_icbm152_t1_tal_nlin_asym_09c.nii'];

for i=1:length(SubjectID)
    if IsCheckwT1
        %Get the normalized T1 image files
        if (7==exist([WorkingDir,filesep,'T1ImgSegment',filesep,SubjectID{i}],'dir'))
            T1ImgSegmentDirectoryName = 'T1ImgSegment';
        elseif (7==exist([WorkingDir,filesep,'T1ImgNewSegment',filesep,SubjectID{i}],'dir'))
            T1ImgSegmentDirectoryName = 'T1ImgNewSegment';
        end
        
        DirImg=dir([WorkingDir,filesep,T1ImgSegmentDirectoryName,filesep,SubjectID{i},filesep,'w*.img']);
        if isempty(DirImg)
            DirImg=dir([WorkingDir,filesep,T1ImgSegmentDirectoryName,filesep,SubjectID{i},filesep,'w*.nii']);
        end
        
        for iFile = 1:length(DirImg)
            if ~( strcmpi(DirImg(iFile).name(1:3),'wc1') || strcmpi(DirImg(iFile).name(1:3),'wc2') || strcmpi(DirImg(iFile).name(1:3),'wc3') )
                SubwT1File = [WorkingDir,filesep,T1ImgSegmentDirectoryName,filesep,SubjectID{i},filesep,DirImg(iFile).name];
            end
        end
        H1 = y_Call_spm_orthviews(Edge_File,0,0,0,18,SubwT1File);
        set(H1, 'NumberTitle', 'Off', 'Name', ['wT1 - ',SubjectID{i}]);
        movegui(H1,'northwest')
    end
    
    if IsCheckwFun
        DirImg = dir([WorkingDir,filesep,'RealignParameter',filesep,SubjectID{i},filesep,'wmean*']);
        SubwFunFile = [WorkingDir,filesep,'RealignParameter',filesep,SubjectID{i},filesep,DirImg(1).name];
        H2 = y_Call_spm_orthviews(Edge_File,0,0,0,18,SubwFunFile);
        set(H2, 'NumberTitle', 'Off', 'Name', ['wFun - ',SubjectID{i}]);
        movegui(H2,'northeast')
    end
    
    if IsCheckwGM
        %Get the normalized GM image files
        if (7==exist([WorkingDir,filesep,'T1ImgSegment',filesep,SubjectID{i}],'dir'))
            T1ImgSegmentDirectoryName = 'T1ImgSegment';
        elseif (7==exist([WorkingDir,filesep,'T1ImgNewSegment',filesep,SubjectID{i}],'dir'))
            T1ImgSegmentDirectoryName = 'T1ImgNewSegment';
        end
        
        DirImg=dir([WorkingDir,filesep,T1ImgSegmentDirectoryName,filesep,SubjectID{i},filesep,'wc1*.img']);
        if isempty(DirImg)
            DirImg=dir([WorkingDir,filesep,T1ImgSegmentDirectoryName,filesep,SubjectID{i},filesep,'wc1*.nii']);
        end
        
        SubwGMFile = [WorkingDir,filesep,T1ImgSegmentDirectoryName,filesep,SubjectID{i},filesep,DirImg(1).name];
        H3 = y_Call_spm_orthviews(Edge_File,0,0,0,18,SubwGMFile);
        set(H3, 'NumberTitle', 'Off', 'Name', ['wGM - ',SubjectID{i}]);
        movegui(H3,'southwest')
    end
    
    H4 = y_Call_spm_orthviews(Edge_File,0,0,0,18,MNIASYMFile);
    set(H4, 'NumberTitle', 'Off', 'Name', 'MNI Template');
    movegui(H4,'southeast')
    
    %Xin-Di, please make a score GUI (w_QCScore_gui) at the center
    
    [QCScoreTemp, QCCommentTemp] = w_QCScore;
    if IsCheckwT1
        close(H1);
    end
    
    if IsCheckwFun
        close(H2);
    end
    
    if IsCheckwGM
        close(H3);
    end
    close(H4);

    QCScore(i,1) = QCScoreTemp;
    QCComment{i,1} = QCCommentTemp;

end


%Write the QC information as {WorkDir}/QC/NormalizationQC.tsv
mkdir([WorkingDir,filesep,'QC'])
fid = fopen([WorkingDir,filesep,'QC',filesep,'NormalizationQC.tsv'],'a+');

fprintf(fid,'Subject ID');
fprintf(fid,['\t','QC Score']);
fprintf(fid,['\t','QC Comment']);
fprintf(fid,'\n');
for i=1:length(SubjectID)
    fprintf(fid,'%s',SubjectID{i});
    fprintf(fid,'\t%g',QCScore(i,1));
    fprintf(fid,'\t%s',QCComment{i,1});
    fprintf(fid,'\n');
end
fclose(fid);
