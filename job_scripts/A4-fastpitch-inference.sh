#!/bin/sh
#
# grid engine options
#$ -cwd
#$ -l h_rt=48:00:00
#$ -l h_vmem=30G
#$ -pe gpu-titanx 1
#$ -o /exports/chss/eddie/ppls/groups/lel_hcrc_cstr_students/UUN_Firstname_Lastname/fastpitch_infer.stdout
#$ -e /exports/chss/eddie/ppls/groups/lel_hcrc_cstr_students/UUN_Firstname_Lastname/fastpitch_infer.stderr
#$ -M your.email@example.com
#$ -m beas
#
# initialise environment modules
. /etc/profile.d/modules.sh

module load cuda/11.0.2
module load anaconda
source activate fastpitch

. /exports/applications/support/set_cuda_visible_devices.sh

set -euo pipefail

UUN=s1234567
YOUR_NAME=Firstname_Lastname

SCRATCH=/exports/eddie/scratch/$UUN
DS_HOME=/exports/chss/eddie/ppls/groups/lel_hcrc_cstr_students/${UUN}_${YOUR_NAME}
FP=$DS_HOME/DeepLearningExamples/PyTorch/SpeechSynthesis/FastPitch

DATA_DIR=$SCRATCH/LJSpeech-1.1
TACOTRON2=$SCRATCH/pretrained_models/tacotron2/nvidia_tacotron2pyt_fp16.pt

python inference.py \
  --cuda \
  -i $FP/filelists/ljs_audio_text_val_filelist.tsv \
  -o $SCRATCH/fastpitch_lj/synth \
  --log-file $SCRATCH/fastpitch_lj/synth/nvlog.json \
  --fastpitch $SCRATCH/pretrained_models/fastpitch/nvidia_fastpitch_200518.pt \
  --waveglow $SCRATCH/pretrained_models/waveglow/nvidia_waveglow256pyt_fp16.pt \
  --wn-channels 256 \
  --batch-size 16

