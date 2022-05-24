#!/bin/sh
#$ -q staging
#$ -N fastpitch_staging
#$ -l h_rt=01:00:00
#$ -o /exports/chss/eddie/ppls/groups/lel_hcrc_cstr_students/UUN_Firstname_Lastname/job_logs/$JOB_NAME_$JOB_ID.stdout
#$ -e /exports/chss/eddie/ppls/groups/lel_hcrc_cstr_students/UUN_Firstname_Lastname/job_logs/$JOB_NAME_$JOB_ID.stderr
#$ -M your.email@example.com
#$ -m beas

source /etc/profile.d/modules.sh

module load anaconda
source activate fastpitch

# can only set these after conda setup
set -euo pipefail

UUN=s1234567
YOUR_NAME=Firstname_Lastname

DS_HOME=/exports/chss/eddie/ppls/groups/lel_hcrc_cstr_students/${UUN}_${YOUR_NAME}
FP=$DS_HOME/FastPitches/PyTorch/SpeechSynthesis/FastPitch

cd $FP
bash scripts/download_dataset.sh
