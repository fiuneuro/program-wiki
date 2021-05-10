#!/bin/bash
#SBATCH --job-name=arrayjob
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=4gb
#SBATCH --account=iacc_nbc
#SBATCH --qos=pq_nbc
#SBATCH --partition=investor
# Outputs ----------------------------------
#SBATCH --output=arrayjob-%j-%A-%a.out
#SBATCH --error=arrayjob-%j-%A-%a.err
# ------------------------------------------
# USAGE information:
# This job should be used with a file that lists a variable distinguishing subjobs
# on separate lines, such as a BIDS participants.tsv file.
# If that file has a header row, start your array with 1, not 0.
# Use the --array= option to identify the rows to run in an array.
# For example --array=1-100%5 to run the first 100 lines (ignoring the header),
# but only running 5 jobs at a given time.
pwd; hostname; date
set -e

#==============Shell script==============#
# Load the software needed
module load singularity-3.5.3

PROJECT="Salo_PowerReplication"
DSET_NAME="dset-camcan"
IMG_DIR="/home/data/cis/singularity-images"
DATA_DIR="/home/data/nbc/misc-projects"
BIDS_DIR="${DATA_DIR}/${PROJECT}/${DSET_NAME}"
SCRATCH_DIR="/scratch/nbc/tsalo006/${PROJECT}/${DSET_NAME}/fmriprep-20.2.1"
DERIVS_DIR="${DATA_DIR}/${PROJECT}/${DSET_NAME}/derivatives"
mkdir -p ${SCRATCH_DIR}
mkdir -p ${DERIVS_DIR}

# Prepare some writeable bind-mount points.
TEMPLATEFLOW_HOST_HOME=$HOME/.cache/templateflow
FMRIPREP_HOST_CACHE=$HOME/.cache/fmriprep
mkdir -p ${FMRIPREP_HOST_CACHE}

# Make sure FS_LICENSE is defined in the container.
FS_LICENSE=$HOME/freesurfer_license.txt

# Designate a templateflow bind-mount point
export SINGULARITYENV_TEMPLATEFLOW_HOME="$HOME/.cache/templateflow"

SINGULARITY_CMD="singularity run --cleanenv \
      -B $BIDS_DIR:/data \
      -B ${DERIVS_DIR}:/out \
      -B ${TEMPLATEFLOW_HOST_HOME}:${SINGULARITYENV_TEMPLATEFLOW_HOME} \
      -B $SCRATCH_DIR:/work \
      $IMG_DIR/poldracklab-fmriprep_20.2.1.sif"

# Parse the participants.tsv file and extract one subject ID from the line corresponding to this SLURM task.
subject=$( sed -n -E "$((${SLURM_ARRAY_TASK_ID} + 1))s/sub-(\S*)\>.*/\1/gp" ${BIDS_DIR}/participants.tsv )

# Compose the command line
cmd="${SINGULARITY_CMD} /data \
      /out \
      participant \
      --participant-label $subject \
      -w /work/ \
      --omp-nthreads 8 \
      --nprocs 8 \
      --mem_mb 32000 \
      --output-spaces MNI152NLin6Asym:res-native anat:res-native func:res-native \
      --notrack \
      --no-submm-recon \
      --fs-license-file $FS_LICENSE"

# Setup done, run the command
echo Running task ${SLURM_ARRAY_TASK_ID}
echo Commandline: $cmd
eval $cmd
exitcode=$?

# Output results to a table
echo "sub-$subject   ${SLURM_ARRAY_TASK_ID}    $exitcode" \
      >> ${DATA_DIR}/${PROJECT}/code/jobs/${SLURM_JOB_NAME}.${SLURM_ARRAY_JOB_ID}.tsv
echo "Finished tasks ${SLURM_ARRAY_TASK_ID} with exit code ${exitcode}"
exit $exitcode

date
