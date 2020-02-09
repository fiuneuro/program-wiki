#!/bin/bash
#---Number of cores
#SBATCH -c 1

#---Job's name in SLURM system
#SBATCH -J {subject}

#---Error file
#SBATCH -e fmriprep_{subject}_err

#---Output file
#SBATCH -o fmriprep_{subject}_out

#---Queue name (change to your lab's queue)
#SBATCH --account iacc_nbc

#---Partition
#SBATCH -p centos7
########################################################
export NPROCS=`echo $LSB_HOSTS | wc -w`
export OMP_NUM_THREADS=$NPROCS
. $MODULESHOME/../global/profile.modules
module load singularity-3

DSET_DIR="/scratch/tsalo006/example-dset"
WORK_DIR="/scratch/tsalo006/example-work"
FS_LICENSE="/scratch/tsalo006/freesurfer_license.txt"

# Run fMRIPrep
# Data, image, and output directory must be in scratch directory.
# Use nthreads/omp-nthreads configuration based on
# https://neurostars.org/t/fmriprep-stopped-due-to-memory-error/2275/18
singularity exec --cleanenv \
    -B /home/tsal006/.cache/templateflow:$HOME/.cache/templateflow \
    poldracklab_fmriprep_1.5.0rc1.sif \
    $DSET_DIR $DSET_DIR/derivatives/ participant \
    --participant-label {subject} \
    --verbose -w $DSET_DIR --nthreads 1 --omp-nthreads $NPROCS \
    --fs-license-file $FS_LICENSE \
    --notrack --output-spaces MNI152NLin2009cAsym:res-native --use-syn-sdc
