#!/bin/bash

export DATADIR="/work1/yancg/Data/Test/Test"
# Should have BIDS and subjects.txt

export SingularityDIR="/work1/yancg/Soft/Singularity"
# Should have dpabisurfslurm.sif. You can get it by singularity pull dpabisurfslurm.sif docker://cgyan/dpabisurfslurm:latest
# Should have freesurfer.sif. You can get it by singularity pull freesurfer.sif docker://cgyan/freesurfer:latest

export FreeSurferLicenseDIR="/work1/yancg/Soft/FreeSurferLicense"
# Should have license.txt from FreeSurfer

export RemoveFirstTimePoints="5"
# Set up Number of time points needs to be removed

export FunctionalSessionNumber="1"
# Set up Number of Functional Sessions