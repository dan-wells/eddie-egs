#!/bin/sh
#
# grid engine options
#$ -cwd
#$ -l h_rt=48:00:00
#$ -l h_vmem=50G
#$ -pe gpu-titanx 1
#$ -o /exports/chss/eddie/ppls/groups/lel_hcrc_cstr_students/UUN_Firstname_Lastname/fastpitch_train.stdout
#$ -e /exports/chss/eddie/ppls/groups/lel_hcrc_cstr_students/UUN_Firstname_Lastname/fastpitch_train.stderr
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

python train.py \
  --cuda \
  -o $SCRATCH/fastpitch_lj \
  --log-file $SCRATCH/fastpitch_lj/nvlog.json \
  --dataset-path $DATA_DIR \
  --training-files $FP/filelists/ljs_mel_dur_pitch_text_train_filelist.txt \
  --validation-files $FP/filelists/ljs_mel_dur_pitch_text_test_filelist.txt \
  --pitch-mean-std-file $DATA_DIR/pitch_char_stats__ljs_audio_text_train_filelist.json \
  --epochs 200 \
  --epochs-per-checkpoint 50 \
  --batch-size 32 \
  -lr 0.1 \
  --optimizer lamb \
  --grad-clip-thresh 1000.0 \
  --dur-predictor-loss-scale 0.1 \
  --pitch-predictor-loss-scale 0.1 \
  --weight-decay 1e-6 \
  --gradient-accumulation-steps 1
