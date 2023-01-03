

Cfg.WorkingDir
Cfg.SubjectID

Cfg.ParallelWorkersNumber=1;


Cfg.Isqsiprep=1;
Cfg.OutputResolution=2;
Cfg.IsLowMem=1;

Cfg.IsCalTensorMetrics=1;

Cfg.IsTBSS=1;


Cfg.Isqsirecon=1;
Cfg.FreesurferInput %Choose the freesurfer folder. Default: [Cfg.WorkingDir,filesep,'freesurfer']
Cfg.ReconSpec='mrtrix_singleshell_ss3t_ACT-hsvs_10M'; % or 'mrtrix_multishell_msmt_ACT-hsvs_10M' or 'mrtrix_singleshell_ss3t_ACT-hsvs_2M_pyAFQ' or 'mrtrix_multishell_msmt_ACT-hsvs_2M_pyAFQ'

Cfg.ROIDef={'{WorkingDir}/fmriprep/{SubjectID}/anat/{SubjectID}_desc-aseg_dseg.nii.gz'};
Cfg.ROISelectedIndex={[]};
    

Cfg.StructuralConnectomeMatrix.Is=1;
Cfg.StructuralConnectomeMatrix.AssignmentRadialSearch = 2;

Cfg.StructuralConnectomeMatrix.StatEdge='sum'; %sum,mean,min,max
Cfg.StructuralConnectomeMatrix.Symmetric=1;
Cfg.StructuralConnectomeMatrix.UseSiftWeights=1;
Cfg.StructuralConnectomeMatrix.ScaleLength=0;
Cfg.StructuralConnectomeMatrix.ScaleInvLength=0;
Cfg.StructuralConnectomeMatrix.ScaleInvNodeVol=0;
Cfg.StructuralConnectomeMatrix.WeightedByFA=0;

Cfg.StructuralConnectomeMatrix.WeightedByImage.Is=0;
Cfg.StructuralConnectomeMatrix.WeightedByImage.ImageFile='{WorkingDir}/Results/FunVolu/DegreeCentrality_FunVoluCF/zDegreeCentrality_PositiveWeightedSumBrain_{SubjectID}.nii';
Cfg.StructuralConnectomeMatrix.WeightedByImage.StatTck='mean'; %mean,median,min,max



Cfg.SeedBasedStructuralConnectivity.Is=1;
Cfg.SeedBasedStructuralConnectivity.TracksForEachROI = 1; %otherwise means tracks need to traverse ALL ROIs 
% Another radio: Tracks traverse ALL ROIs; and turn off Cfg.SeedBasedStructuralConnectivity.TWFC setting

Cfg.SeedBasedStructuralConnectivity.TWFC.Is
Cfg.SeedBasedStructuralConnectivity.TWFC.FCFile='{WorkingDir}/Results/FunVolu/FC_SeedSurfLHSurfRHVolu_FunVoluCF/zROI{iROI}FC_{SubjectID}.nii';
Cfg.SeedBasedStructuralConnectivity.TWFC.StatVox='mean'; %mean, sum, min, max 
Cfg.SeedBasedStructuralConnectivity.TWFC.StatTck='sum'; %sum, mean, min, max, median, mean_nonzero, gaussian, ends_min, ends_mean, ends_max, ends_prod
Cfg.SeedBasedStructuralConnectivity.TWFC.MinimumStreamlineCount=5;


Cfg.Normalize.Is=0;
Cfg.Normalize.Timing='OnResults';

Cfg.Smooth.Is=1;
Cfg.Smooth.Timing='OnResults';

Cfg.Smooth.FWHMVolu=[6 6 6];

