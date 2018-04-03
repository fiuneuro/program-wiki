#!/bin/bash
#---Number of cores
#BSUB -n 1
#BSUB -R "span[ptile=1]"

#---Job's name in LSF system
#BSUB -J mriqc

#---Error file
#BSUB -eo err_mriqc

#---Output file
#BSUB -oo out_mriqc

#---LSF Queue name
#BSUB -q PQ_nbc

##########################################################
# Set up environmental variables.
##########################################################
export NPROCS=`echo $LSB_HOSTS | wc -w`
export OMP_NUM_THREADS=$NPROCS

. $MODULESHOME/../global/profile.modules
module load singularity

##########################################################
##########################################################

# Set variables
# Data must be in scratch directory.
DSET_DIR="/scratch/tsalo006/physics-learning-dset"

# Clear Python path to prevent contamination
PYTHONPATH=""

# Run MRIQC and classifier
singularity run new_poldracklab_mriqc_0.10.4-2018-03-23-8fb5f5e9184f.img \
    $DSET_DIR ${DSET_DIR}/derivatives/mriqc participant --n_cpus 1 --fd_thres 0.2 \
    --no-sub --verbose-reports --ica --deoblique --correct-slice-timing \
    -w /scratch/tsalo006/work
