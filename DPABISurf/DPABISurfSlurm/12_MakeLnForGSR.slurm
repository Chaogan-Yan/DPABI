#!/bin/bash
#SBATCH -J MakeLnForGSR #指定作业名称
#SBATCH -p normal #指定分区名称
#SBATCH -N 1 #指定节点数量
#SBATCH -n 1 #指定任务数
#SBATCH --mem=10G #指定每节点申请的内存大小，最大 100GB
#SBATCH -o MakeLnForGSR.o%j #指定正确输出文件名称
#SBATCH -e MakeLnForGSR.e%j #指定报错信息输出文件名称
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

ln -s ${DATADIR}/FunSurfW ${DATADIR}/FunSurfWglobal
ln -s ${DATADIR}/FunVoluW ${DATADIR}/FunVoluWglobal

# Setup done, run the command
echo Running task MakeLnForGSR

echo "End time: `date`" #显示结束时间
