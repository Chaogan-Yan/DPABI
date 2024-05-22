#!/bin/bash
#SBATCH -J Organize_fmriprep_Surf #指定作业名称
#SBATCH -p normal #指定分区名称
#SBATCH -N 1 #指定节点数量
#SBATCH -n 1 #指定任务数
#SBATCH --mem=10G #指定每节点申请的内存大小，最大 100GB
#SBATCH -o Organize_fmriprep_Surf.o%j #指定正确输出文件名称
#SBATCH -e Organize_fmriprep_Surf.e%j #指定报错信息输出文件名称
echo "Start time: `date`"
echo "SLURM_JOB_ID: $SLURM_JOB_ID" #显示作业号
echo "SLURM_NNODES: $SLURM_NNODES" #显示节点数
echo "SLURM_NTASKS: $SLURM_NTASKS" #显示总任务数
echo "SLURM_TASKS_PER_NODE: $SLURM_TASKS_PER_NODE" #显示每节点任务数 
echo "SLURM_CPUS_PER_TASK: $SLURM_CPUS_PER_TASK" #显示每个任务使用的 CPU 数 量
echo "SLURM_JOB_PARTITION: $SLURM_JOB_PARTITION" #显示作业分区
echo "SLURM_SUBMIT_DIR:$SLURM_SUBMIT_DIR" #显示提交作业目录的路径
echo "SLURM_NODELIST:$SLURM_NODELIST" #显示执行节点列表名称

# !!What I need to Setup
source ${SetEnvScriptDir}/SetEnv.sh
# !!What I need to Setup

mkdir -p ${DATADIR}/Results/AnatSurfLH/fsaverage/Thickness
mkdir -p ${DATADIR}/Results/AnatSurfLH/fsaverage5/Thickness
mkdir -p ${DATADIR}/Results/AnatSurfRH/fsaverage/Thickness
mkdir -p ${DATADIR}/Results/AnatSurfRH/fsaverage5/Thickness

mkdir -p ${DATADIR}/Results/AnatSurfLH/fsnative/Thickness
mkdir -p ${DATADIR}/Results/AnatSurfRH/fsnative/Thickness

mkdir -p ${DATADIR}/Results/AnatSurfLH/fsaverage/Area
mkdir -p ${DATADIR}/Results/AnatSurfLH/fsaverage5/Area
mkdir -p ${DATADIR}/Results/AnatSurfRH/fsaverage/Area
mkdir -p ${DATADIR}/Results/AnatSurfRH/fsaverage5/Area

mkdir -p ${DATADIR}/Results/AnatSurfLH/fsnative/Area
mkdir -p ${DATADIR}/Results/AnatSurfRH/fsnative/Area

mkdir -p ${DATADIR}/Results/AnatSurfLH/fsaverage/Curv
mkdir -p ${DATADIR}/Results/AnatSurfLH/fsaverage5/Curv
mkdir -p ${DATADIR}/Results/AnatSurfRH/fsaverage/Curv
mkdir -p ${DATADIR}/Results/AnatSurfRH/fsaverage5/Curv

mkdir -p ${DATADIR}/Results/AnatSurfLH/fsnative/Curv
mkdir -p ${DATADIR}/Results/AnatSurfRH/fsnative/Curv

mkdir -p ${DATADIR}/Results/AnatSurfLH/fsaverage/Sulc
mkdir -p ${DATADIR}/Results/AnatSurfLH/fsaverage5/Sulc
mkdir -p ${DATADIR}/Results/AnatSurfRH/fsaverage/Sulc
mkdir -p ${DATADIR}/Results/AnatSurfRH/fsaverage5/Sulc

mkdir -p ${DATADIR}/Results/AnatSurfLH/fsnative/Sulc
mkdir -p ${DATADIR}/Results/AnatSurfRH/fsnative/Sulc

mkdir -p ${DATADIR}/Results/AnatSurfLH/fsaverage/Volume
mkdir -p ${DATADIR}/Results/AnatSurfLH/fsaverage5/Volume
mkdir -p ${DATADIR}/Results/AnatSurfRH/fsaverage/Volume
mkdir -p ${DATADIR}/Results/AnatSurfRH/fsaverage5/Volume

mkdir -p ${DATADIR}/Results/AnatSurfLH/fsnative/Volume
mkdir -p ${DATADIR}/Results/AnatSurfRH/fsnative/Volume

mkdir -p ${DATADIR}/Masks/MasksForFun/Masks_SurfSpace

module load singularity/3.8.0

subject=$( sed -n -E "$((${SLURM_ARRAY_TASK_ID}))p" ${DATADIR}/subjects.txt | awk '{print $1}' )

cmd="singularity run --cleanenv -B ${FreeSurferLicenseDIR}/license.txt:/opt/freesurfer/license.txt -B ${DATADIR}:/data ${SingularityDIR}/dpabisurfslurm.sif /dpabi/y_Organize_fmriprep_Surf.sh ${subject} /data"


# Setup done, run the command
echo Running task ${SLURM_ARRAY_TASK_ID}
echo Commandline: $cmd
eval $cmd
exitcode=$?

# Output results to a table
echo "$subject   ${SLURM_ARRAY_TASK_ID}    $exitcode" \
      >> ${SLURM_JOB_NAME}.${SLURM_ARRAY_JOB_ID}.tsv
echo Finished tasks ${SLURM_ARRAY_TASK_ID} with exit code $exitcode
exit $exitcode

echo "End time: `date`" #显示结束时间
