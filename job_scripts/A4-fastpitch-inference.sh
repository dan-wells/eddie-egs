#!/bin/sh

# grid engine options
#$ -N fastpitch_infer
#$ -l h_rt=01:00:00
#$ -l h_vmem=32G
#$ -pe gpu-titanx 1
#$ -o /exports/chss/eddie/ppls/groups/lel_hcrc_cstr_students/UUN_Firstname_Lastname/$JOB_NAME_$JOB_ID.stdout
#$ -e /exports/chss/eddie/ppls/groups/lel_hcrc_cstr_students/UUN_Firstname_Lastname/$JOB_NAME_$JOB_ID.stderr
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

DS_HOME=/exports/chss/eddie/ppls/groups/lel_hcrc_cstr_students/${UUN}_${YOUR_NAME}
FP=$DS_HOME/FastPitches/PyTorch/SpeechSynthesis/FastPitch

# see $FP/scripts/download_{fastpitch,waveglow}.sh to get pre-trained
# checkpoints, or substitute your own (can pass as script argument)
export FASTPITCH="${1:-$FP/pretrained_models/fastpitch/nvidia_fastpitch_210824.pt}"
export WAVEGLOW="$FP/pretrained_models/waveglow/nvidia_waveglow256pyt_fp16.pt"

# NB. at least the waveglow checkpoint tries to deserialise straight to
# CUDA device, so need to run this in a GPU environment even if running
# inference on CPU afterwards!

export PHRASES="$FP/phrases/devset10.tsv"
export OUTPUT_DIR=$DS_HOME/fastpitch_audio/$(basename ${PHRASES} .tsv)
export BATCH_SIZE=16  # this might need to be bigger than #utts in $PHRASES...

# these affect model architecture => match to settings used during model training!
export PHONE=true  # PHONE=true seems not to respect --p-arpabet?
export ENERGY=true
export NUM_SPEAKERS=1
export SPEAKER=0  # select speaker by index

# I had trouble running this on GPU, something about the CUDA memory
# allocation was off. Running on CPU works, but is quite slow (~15 minutes for
# 10 utterances) and still needs a lot of RAM (16 GB is not enough, 32 GB is,
# don't know in between)
export CPU=true  # false => run on GPU
export AMP=false

cd $FP
scripts/inference_example.sh
