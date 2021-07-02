#!/bin/sh
#
# grid engine options
#$ -cwd
#$ -l h_rt=24:00:00
#$ -l h_vmem=32G
#$ -pe gpu-titanx 1
#$ -o /exports/chss/eddie/ppls/groups/lel_hcrc_cstr_students/UUN_Firstname_Lastname/fastpitch_prep_lj.stdout
#$ -e /exports/chss/eddie/ppls/groups/lel_hcrc_cstr_students/UUN_Firstname_Lastname/fastpitch_prep_lj.stderr
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

cd $SCRATCH

DATA_DIR="LJSpeech-1.1"
TACOTRON2="pretrained_models/tacotron2/nvidia_tacotron2pyt_fp16.pt"
for FILELIST in ljs_audio_text_train_filelist.txt \
                ljs_audio_text_val_filelist.txt \
                ljs_audio_text_test_filelist.txt \
; do
    python $FP/extract_mels.py \
        --cuda \
        --dataset-path ${DATA_DIR} \
        --wav-text-filelist $FP/filelists/${FILELIST} \
        --batch-size 256 \
        --extract-mels \
        --extract-durations \
        --extract-pitch-char \
        --tacotron2-checkpoint ${TACOTRON2}
done
