#!/bin/sh
#$ -N fastpitch_staging
#$ -l h_rt=01:00:00
#$ -o /exports/chss/eddie/ppls/groups/lel_hcrc_cstr_students/UUN_Firstname_Lastname/fastpitch_staging.stdout
#$ -e /exports/chss/eddie/ppls/groups/lel_hcrc_cstr_students/UUN_Firstname_Lastname/fastpitch_staging.stderr
#$ -M your.email@example.com
#$ -m beas

source /etc/profile.d/modules.sh

module load anaconda
source activate fastpitch

# can only set these after conda setup
set -euo pipefail

UUN=s1234567
YOUR_NAME=Firstname_Lastname

SCRATCH=/exports/eddie/scratch/$UUN
DS_HOME=/exports/chss/eddie/ppls/groups/lel_hcrc_cstr_students/${UUN}_${YOUR_NAME}
FP=$DS_HOME/DeepLearningExamples/PyTorch/SpeechSynthesis/FastPitch

cd $SCRATCH

# NB. we changed download_dataset.sh NOT to run the pretrained model
# downloads because it uses relative paths which expect us to be
# in the FastPitch repo directory. Could always clone to $SCRATCH dir
# instead at the start if you wanted
bash $FP/scripts/download_dataset.sh
bash $FP/scripts/download_tacotron2.sh
bash $FP/scripts/download_waveglow.sh
