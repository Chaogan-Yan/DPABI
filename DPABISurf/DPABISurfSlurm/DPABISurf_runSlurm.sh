#!/bin/bash

# DPABISurfSlurm is designed for running DPABISurf on high-performance computing (HPC)
# You should have your data (BIDS and subjects.txt) at as defined in DATADIR.
# You should have DPABISurfSlurm at as defined in DPABISurfSlurmDIR.
# You should have SetEnv.sh at as defined in SetEnvScriptDir.
# You should define the parameters in SetEnv.sh!!!
#     You should have dpabisurfslurm.sif and freesurfer.sif in SingularityDIR as defined in SetEnv.sh.
#         You can get it by singularity pull dpabisurfslurm.sif docker://cgyan/dpabisurfslurm:latest and singularity pull freesurfer.sif docker://cgyan/freesurfer:latest
#     You should have license.txt in FreeSurferLicenseDIR as defined in SetEnv.sh.
# ___________________________________________________________________________
# Written by YAN Chao-Gan 230214.
# The R-fMRI Lab, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
# International Big-Data Center for Depression Research, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
# ycg.yan@gmail.com

# !!!DEFINE YOURS BELOW!!!
export DPABISurfSlurmDIR="/work1/yancg/Scripts/DPABISurfSlurm"
# Should have the DPABISurfSlurm files
export SetEnvScriptDir="/work1/yancg/Data/Test/Test"
# Should have SetEnv.sh
# You should also go into SetEnv.sh to define your parameters!!!
export DATADIR="/work1/yancg/Data/Test/Test"
# Should have BIDS and subjects.txt
# !!!DEFINE YOURS ABOVE!!!

sbatch --export=SetEnvScriptDir=${SetEnvScriptDir} ${DPABISurfSlurmDIR}/1_GetTRInfo.slurm --wait

sbatch --dependency=afterok:$(squeue -u $USER -h -o %i -n GetTRInfo) --export=SetEnvScriptDir=${SetEnvScriptDir} --array=1-$(( $( wc -l < ${DATADIR}/subjects.txt ) )) ${DPABISurfSlurmDIR}/2_RemoveFirstTimePoints.slurm --wait

sbatch --dependency=afterok:$(squeue -u $USER -h -o %i -n RemoveFirstTimePoints) --export=SetEnvScriptDir=${SetEnvScriptDir} ${DPABISurfSlurmDIR}/3_Prefmriprep.slurm --wait

sbatch --dependency=afterok:$(squeue -u $USER -h -o %i -n Prefmriprep) --export=SetEnvScriptDir=${SetEnvScriptDir} --array=1-$(( $( wc -l < ${DATADIR}/subjects.txt ) )) ${DPABISurfSlurmDIR}/4_fmriprep.slurm --wait

sbatch --dependency=afterok:$(squeue -u $USER -h -o %i -n fmriprep) --export=SetEnvScriptDir=${SetEnvScriptDir} ${DPABISurfSlurmDIR}/5_Postfmriprep.slurm --wait

sbatch --dependency=afterok:$(squeue -u $USER -h -o %i -n Postfmriprep) --export=SetEnvScriptDir=${SetEnvScriptDir} ${DPABISurfSlurmDIR}/6_Organize_fmriprep.slurm --wait

sbatch --dependency=afterok:$(squeue -u $USER -h -o %i -n Organize_fmriprep) --export=SetEnvScriptDir=${SetEnvScriptDir} --array=1-$(( $( wc -l < ${DATADIR}/subjects.txt ) )) ${DPABISurfSlurmDIR}/7_SegmentSubregions.slurm --wait

sbatch --dependency=afterok:$(squeue -u $USER -h -o %i -n SegmentSubregions) --export=SetEnvScriptDir=${SetEnvScriptDir} ${DPABISurfSlurmDIR}/8_Organize_SegmentSubregions.slurm --wait

sbatch --dependency=afterok:$(squeue -u $USER -h -o %i -n Organize_SegmentSubregions) --export=SetEnvScriptDir=${SetEnvScriptDir} --array=1-$(( $( wc -l < ${DATADIR}/subjects.txt ) )) ${DPABISurfSlurmDIR}/9_DPABISurf_run.slurm --wait

sbatch --dependency=afterok:$(squeue -u $USER -h -o %i -n DPABISurf_run) --export=SetEnvScriptDir=${SetEnvScriptDir} ${DPABISurfSlurmDIR}/10_MakeLnForGSR.slurm --wait

sbatch --dependency=afterok:$(squeue -u $USER -h -o %i -n MakeLnForGSR) --export=SetEnvScriptDir=${SetEnvScriptDir} --array=1-$(( $( wc -l < ${DATADIR}/subjects.txt ) )) ${DPABISurfSlurmDIR}/11_DPABISurf_run_GSR.slurm --wait

sbatch --dependency=afterok:$(squeue -u $USER -h -o %i -n DPABISurf_run_GSR) --export=SetEnvScriptDir=${SetEnvScriptDir} ${DPABISurfSlurmDIR}/12_ResultsOrganizer_Surf.slurm --wait

sbatch --dependency=afterok:$(squeue -u $USER -h -o %i -n ResultsOrganizer_Surf) --export=SetEnvScriptDir=${SetEnvScriptDir} ${DPABISurfSlurmDIR}/13_TarResults.slurm --wait

echo "The sbatch of DPABISurfSlurm is done!!! :)"

# squeue -u $USER | grep 655 | awk '{print $1}' | xargs -n 1 scancel

# TO USE: source ../DPABISurf_runSlurm.sh


