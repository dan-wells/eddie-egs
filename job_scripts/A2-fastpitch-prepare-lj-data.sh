#!/bin/sh
#
# grid engine options
#$ -N fastpitch_prep_lj
#$ -l h_rt=24:00:00
#$ -l h_vmem=1G
#$ -pe sharedmem 8
#$ -R y
#$ -o /exports/chss/eddie/ppls/groups/lel_hcrc_cstr_students/UUN_Firstname_Lastname/job_logs/$JOB_NAME_$JOB_ID.stdout
#$ -e /exports/chss/eddie/ppls/groups/lel_hcrc_cstr_students/UUN_Firstname_Lastname/job_logs/$JOB_NAME_$JOB_ID.stderr
#$ -M your.email@example.com
#$ -m beas

# initialise environment modules
. /etc/profile.d/modules.sh

module load anaconda
source activate fastpitch

set -euo pipefail

UUN=s1234567
YOUR_NAME=Firstname_Lastname

DS_HOME=/exports/chss/eddie/ppls/groups/lel_hcrc_cstr_students/${UUN}_${YOUR_NAME}
FP=$DS_HOME/FastPitches/PyTorch/SpeechSynthesis/FastPitch

SCRATCH=/exports/eddie/scratch/s1462938
DATA_DIR="$SCRATCH/LJSpeech-1.1"

cd $FP
for FILELIST in ljs_audio_text_train_v3.txt \
                ljs_audio_text_val.txt \
                ljs_audio_text_test.txt \
; do
    # have to set smaller --n-workers than $FP/scripts/prepare_dataset.sh
    # to work around weird qsub memory consumption
    python prepare_dataset.py \
        --dataset-path $DATA_DIR \
        --wav-text-filelist filelists/$FILELIST \
        --n-workers 1 \
        --batch-size 1 \
        --extract-pitch
    # NB: this has to use `--batch-size 1` otherwise archives get saved with
    # padding and everything ends up the wrong shape!
done
