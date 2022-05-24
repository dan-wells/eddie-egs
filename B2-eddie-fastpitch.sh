module load cuda/10.2.89
module load anaconda
source activate fastpitch

git clone https://github.com/evdv/FastPitches.git

cd FastPitches/PyTorch/SpeechSynthesis/FastPitch

# install dependencies
pip install -r requirements.txt tensorboard tqdm wandb

# set up wandb experiment logging
# first create a free account: https://app.wandb.ai/login?signup=true
# then log in using your API key
wandb login

# quick check all imports work
python train.py --help

# let's manually download LJSpeech and cmudict, since the download scripts
# included with FastPitch are not ideal in terms of relative paths
wget https://github.com/Alexir/CMUdict/raw/master/cmudict-0.7b -qO cmudict/cmudict-0.7b
# maybe shouldn't tie up login node with unarchiving stuff
qlogin -q staging
cd /exports/eddie/scratch/$YOUR_UUN
wget "http://data.keithito.com/data/speech/LJSpeech-1.1.tar.bz2"
tar jxvf LJSpeech-1.1.tar.bz2
exit  # or ctrl-d

# preprocess data to extract pitch contours and save to disk for later
# loading (since the pitch extraction algorithm used is very slow)
qsub -N fastpitch_prep_lj job_scripts/A2-fastpitch-prepare-lj-data.sh

# NB. I had problems running training in a non-interactive session submitted
# to the gpu-titanx parallel environment, something about data loader worker
# processes requesting way too much memory.
#
# You can address this by changing the num_workers argument to data loaders
# in two places in train.py:
#   train_loader definition can take num_workers=1
#   val_loader definition should take num_workers=0

# queue up train job, waiting for data prep to complete with -hold_jid
qsub -N fastpitch_train -hold_jid fastpitch_prep_lj job_scripts/A3-fastpitch-train.sh

# notes on grid engine options (#$ lines in job script)
#  -N: job name
#  -o /path/to/log_dir/$JOB_NAME_$JOB_ID.stdout: log file for job stdout, with unique filename
#  -e /path/to/log_dir/$JOB_NAME_$JOB_ID.stderr: log file for job stderr, with unique filename
#  -l h_rt=24:00:00: max time run for 24 hours
#  -l h_vmem=16G: assign 16G ram to job (torch needs more than default 1G to import)
#  -pe gpu[-titanx] 1: assign 1 gpu, K80 or Titan-X -- 11 or 12G vram
#  -M your.email@example.com -m beas: receive email updates as jobs start and stop running
#
# If you pass any of these options directly to qsub, they will override
# any values set in the job script

# synthesise speech
qsub -N fastpitch_inference -hold_jid fastpitch_train job_scripts/A4-fastpitch-inference.sh

# Once you have some model checkpoints and wav files, consider copying
# them back from scratch space to the SLP shared directory for safe keeping
# -- files in scratch space are automatically deleted after a month!
