#!/bin/bash

export DATADIR="/public/home/yancg/YANWork/Data/Test"
# Should have BIDS and subjects.txt

export SingularityDIR="/public/home/yancg/YANWork/Soft/Singularity"
# Should have dpabisurfslurm.sif. You can get it by singularity pull dpabisurfslurm.sif docker://cgyan/dpabisurfslurm:latest
# Should have freesurfer.sif. You can get it by singularity pull freesurfer.sif docker://cgyan/freesurfer:latest

export FreeSurferLicenseDIR="/public/home/yancg/YANWork/Soft/FreeSurferLicense"
# Should have license.txt from FreeSurfer

export RemoveFirstTimePoints="0"
# Set up Number of time points needs to be removed

export FunctionalSessionNumber="1"
# Set up Number of Functional Sessions