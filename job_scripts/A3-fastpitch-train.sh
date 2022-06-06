#!/bin/sh

# grid engine options
#$ -N fastpitches_train
#$ -l h_rt=48:00:00
#$ -l h_vmem=64G
#$ -pe gpu-titanx 1
#$ -o /exports/chss/eddie/ppls/groups/lel_hcrc_cstr_students/UUN_Firstname_Lastname/job_logs/$JOB_NAME_$JOB_ID.stdout
#$ -e /exports/chss/eddie/ppls/groups/lel_hcrc_cstr_students/UUN_Firstname_Lastname/job_logs/$JOB_NAME_$JOB_ID.stderr
#$ -M your.email@example.com
#$ -m beas

# initialise environment modules
. /etc/profile.d/modules.sh

module load cuda/10.2.89
module load anaconda
source activate fastpitch

. /exports/applications/support/set_cuda_visible_devices.sh

set -euo pipefail

UUN=s1234567
YOUR_NAME=Firstname_Lastname

SCRATCH=/exports/eddie/scratch/$UUN
DS_HOME=/exports/chss/eddie/ppls/groups/lel_hcrc_cstr_students/${UUN}_${YOUR_NAME}
FP=$DS_HOME/FastPitches/PyTorch/SpeechSynthesis/FastPitch

# set up train script options using environment variables
# some values are set by the queuing software, e.g. $JOB_ID
# -- see `man qsub` and search for 'ENVIRONMENT VARIABLES'

export OUTPUT_DIR=$SCRATCH/${JOB_NAME}_${JOB_ID}
export DATASET_PATH=$SCRATCH/LJSpeech-1.1
# if running after A2-fastpitch-prepare-lj-data.sh and with
# LOAD_PITCH_FROM_DISK=true below, use ljs_audio_pitch_text_*.txt files
# which point to saved pitch contours. If extracting pitches from audio
# online with PITCH_ONLINE_DIR set below, use ljs_audio_text_*.txt files
export TRAIN_FILELIST=$FP/filelists/ljs_audio_pitch_text_train_v3.txt
export VAL_FILELIST=$FP/filelists/ljs_audio_pitch_text_val.txt

# metadata for wandb logging
export PROJECT=fastpitches_eddie
export EXPERIMENT_DESC="FastPitches defaults"

# convert input texts to phones using cmudict
# (download to default path: $FP/cmudict/cmudict-0.7b beforehand!)
# otherwise, set false to use raw text input
export PHONE=true
export TEXT_CLEANERS=english_cleaners_v2
# enable energy conditioning (errors in loss logging if false)
export ENERGY=true
export NSPEAKERS=1
export SAMPLING_RATE=22050
export APPEND_SPACES=false

# match to number of requested GPUs
export NUM_GPUS=1
export BATCH_SIZE=16
# run with automatic mixed precision or gradient accumulation over
# multiple batches (might allow for larger batch sizes)
export AMP=false
export GRAD_ACCUMULATION=1
# set random seed for ~reproducible runs
export SEED=

export EPOCHS=1000
export EPOCHS_PER_CHECKPOINT=50
export WARMUP_STEPS=1000
export KL_LOSS_WARMUP=100

# load saved pitch contours from disk after running prepare_dataset.py
export LOAD_PITCH_FROM_DISK=true
export LOAD_MEL_FROM_DISK=false  # something wrong with loading saved mels
# or, cache extracted pitch contours to this dir during first epoch
export PITCH_ONLINE_DIR=

# don't run with torch.distributed.launch (leads to port conflicts with
# other jobs on the same compute node)
export DISTRIBUTED=' '

cd $FP
scripts/train.sh

# NB. some possibly important options which are not handled in
# $FP/scripts/train.sh:
#   --symbol-set     Input characters (define your own in $FP/common/text/symbols.py)
#   --pitch-mean     Statistics about speaker pitch
#   --pitch-std
#   --filter-length  STFT parameters
#   --win-length
#   --hop-length
