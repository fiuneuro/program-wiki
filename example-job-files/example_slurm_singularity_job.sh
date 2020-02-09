#!/bin/bash
#---Number of cores
#SBATCH -c 1

#---Job's name in SLURM system
#SBATCH -J example

#---Error file
#SBATCH -e example_err

#---Output file
#SBATCH -o example_out

#---Queue name
#SBATCH --account iacc_nbc

#---Partition
#SBATCH -p centos7
########################################################
export NPROCS=`echo $LSB_HOSTS | wc -w`
export OMP_NUM_THREADS=$NPROCS
. $MODULESHOME/../global/profile.modules
module load singularity-3

DSET_DIR="/scratch/tsalo006/example-dset"

singularity exec --cleanenv poldracklab_mriqc_0.15.1.sif \
    $DSET_DIR ${DSET_DIR}/derivatives/mriqc participant --n_cpus 1 --fd_thres 0.2 \
    --no-sub --verbose-reports --ica --deoblique --correct-slice-timing \
    -w /scratch/tsalo006/work
