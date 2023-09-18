#!/bin/bash
#SBATCH -J fmriprep #指定作业名称
#SBATCH -p normal #指定分区名称
#SBATCH -N 1 #指定节点数量
#SBATCH -n 1 #指定任务数
#SBATCH --mem=10G #指定每节点申请的内存大小，最大 100GB
#SBATCH -o fmriprep.o%j #指定正确输出文件名称
#SBATCH -e fmriprep.e%j #指定报错信息输出文件名称
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

# Prepare some writeable bind-mount points.
FMRIPREP_HOST_CACHE=$HOME/.cache/fmriprep
mkdir -p ${FMRIPREP_HOST_CACHE}

export SINGULARITYENV_TEMPLATEFLOW_HOME="/dpabi/templates"

module load singularity/3.8.0

subject=$( sed -n -E "$((${SLURM_ARRAY_TASK_ID}))p" ${DATADIR}/subjects.txt | awk '{print $1}' )

cmd="singularity run --cleanenv -B ${FreeSurferLicenseDIR}/license.txt:/opt/freesurfer/license.txt -B ${DATADIR}:/data ${SingularityDIR}/dpabisurfslurm.sif /opt/conda/envs/fmriprep/bin/fmriprep /data/BIDS /data/fmriprep participant --resource-monitor --ignore slicetiming --output-spaces fsaverage5 MNI152NLin2009cAsym:res-2 fsnative T1w -w /data/fmriprepwork/${subject}  --participant_label ${subject}"


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
