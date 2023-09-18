#!/bin/bash

# DPABISlurm is designed for running DPABI on high-performance computing (HPC)
# You should have your data (BIDS and subjects.txt) at as defined in DATADIR.
# You should have DPABISlurm at as defined in DPABISlurmDIR.
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
export DPABISlurmDIR="/work1/yancg/Scripts/DPABISurfSlurm"
# Should have the DPABISlurm files
export SetEnvScriptDir="/work1/yancg/Data/Test/Test"
# Should have SetEnv.sh
# You should also go into SetEnv.sh to define your parameters!!!
export DATADIR="/work1/yancg/Data/Test/Test"
# Should have BIDS and subjects.txt
# !!!DEFINE YOURS ABOVE!!!

sbatch --export=SetEnvScriptDir=${SetEnvScriptDir} ${DPABISlurmDIR}/1_GetTRInfo.slurm --wait

sbatch --dependency=afterok:$(squeue -u $USER -h -o %i -n GetTRInfo) --export=SetEnvScriptDir=${SetEnvScriptDir} --array=1-$(( $( wc -l < ${DATADIR}/subjects.txt ) )) ${DPABISlurmDIR}/2_RemoveFirstTimePoints.slurm --wait

sbatch --dependency=afterok:$(squeue -u $USER -h -o %i -n RemoveFirstTimePoints) --export=SetEnvScriptDir=${SetEnvScriptDir} ${DPABISlurmDIR}/3_Prefmriprep.slurm --wait

sbatch --dependency=afterok:$(squeue -u $USER -h -o %i -n Prefmriprep) --export=SetEnvScriptDir=${SetEnvScriptDir} --array=1-$(( $( wc -l < ${DATADIR}/subjects.txt ) )) ${DPABISlurmDIR}/4_fmriprep.slurm --wait

sbatch --dependency=afterok:$(squeue -u $USER -h -o %i -n fmriprep) --export=SetEnvScriptDir=${SetEnvScriptDir} ${DPABISlurmDIR}/5_Postfmriprep.slurm --wait

sbatch --dependency=afterok:$(squeue -u $USER -h -o %i -n Postfmriprep) --export=SetEnvScriptDir=${SetEnvScriptDir} ${DPABISlurmDIR}/6_Organize_fmriprep.slurm --wait

sbatch --dependency=afterok:$(squeue -u $USER -h -o %i -n Organize_fmriprep) --export=SetEnvScriptDir=${SetEnvScriptDir} --array=1-$(( $( wc -l < ${DATADIR}/subjects.txt ) )) ${DPABISlurmDIR}/7_SegmentSubregions.slurm --wait

sbatch --dependency=afterok:$(squeue -u $USER -h -o %i -n SegmentSubregions) --export=SetEnvScriptDir=${SetEnvScriptDir} ${DPABISlurmDIR}/8_Organize_SegmentSubregions.slurm --wait

sbatch --dependency=afterok:$(squeue -u $USER -h -o %i -n Organize_SegmentSubregions) --export=SetEnvScriptDir=${SetEnvScriptDir} --array=1-$(( $( wc -l < ${DATADIR}/subjects.txt ) )) ${DPABISlurmDIR}/9_DPABISurf_run.slurm --wait

sbatch --dependency=afterok:$(squeue -u $USER -h -o %i -n DPABISurf_run) --export=SetEnvScriptDir=${SetEnvScriptDir} ${DPABISlurmDIR}/10_MakeLnForGSR.slurm --wait

sbatch --dependency=afterok:$(squeue -u $USER -h -o %i -n MakeLnForGSR) --export=SetEnvScriptDir=${SetEnvScriptDir} --array=1-$(( $( wc -l < ${DATADIR}/subjects.txt ) )) ${DPABISlurmDIR}/11_DPABISurf_run_GSR.slurm --wait

sbatch --dependency=afterok:$(squeue -u $USER -h -o %i -n DPABISurf_run_GSR) --export=SetEnvScriptDir=${SetEnvScriptDir} ${DPABISlurmDIR}/12_ResultsOrganizer_Surf.slurm --wait

sbatch --dependency=afterok:$(squeue -u $USER -h -o %i -n ResultsOrganizer_Surf) --export=SetEnvScriptDir=${SetEnvScriptDir} ${DPABISlurmDIR}/13_TarResults.slurm --wait

echo "The sbatch of DPABISlurm is done!!! :)"

# squeue -u $USER | grep 655 | awk '{print $1}' | xargs -n 1 scancel

# TO USE: source ../DPABISurf_runSlurm.sh


