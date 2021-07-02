module load cuda/11.0.2
module load anaconda
source activate fastpitch

git clone https://github.com/NVIDIA/DeepLearningExamples

cd DeepLearningExamples/PyTorch/SpeechSynthesis/FastPitch

# some thing for running models on nvidia servers in production
# adds what look like more annoying dependencies for something we
# won't use, so just check out an earlier commit to new branch
git checkout -b no-triton 2b0daf392a1031fbe1cb56b9e7e7d1d9277f2709

# could do `pip install -r requirements.txt` but seems better to let
# conda check its own dependencies as much as possible
conda install -c conda-forge inflect librosa matplotlib scipy tensorboard tensorboardx==2.0 tqdm unidecode

# these are not in conda repos
pip install praat-parselmouth==0.3.3 
pip install git+git://github.com/NVIDIA/dllogger.git@26a0f8f1958de2c0c460925ff6102a4d2486d6cc#egg=dllogger

# quick check all imports work
python train.py --help

# we change scripts/download_dataset.sh NOT TO CALL scripts/download_{tacotron2,waveglow}.sh
# could easily do what those scripts are doing manually inside this job script, too
qsub -N fastpitch_staging -q staging job_scripts/A1-fastpitch-staging.sh

# preparing LJ data:
#  - mel spectrograms
#  - character durations (from tacotron alignments)
#  - average pitch per character

# because this extracts durations from tacotron alignments, want to run on gpu
# => submit a job if hard to get interactive gpu session

# notes on grid engine options (#$ lines in job script)
#  -N: job name
#  -cwd: execute job from current working directory, i.e. FastPitch
#        allows relative paths in job script
#  -l h_rt=24:00:00: max time run for 24 hours
#  -l h_vmem=16G: assign 16G ram to job (torch needs more than default 1G to import)
#  -pe gpu[-titanx] 1: assign 1 gpu, K80 or Titan-X -- 11 or 12G vram
#  -M your.email@example.com: receive email updates as jobs start and stop running

# not sure how big the batch size should be but nb. 8 is pretty slow...
# limitation is actually h_vmem not gpu vram
# runs at batch size 256 fine with 32G ram, 16G not enough
qsub -N fastpitch_prep_lj -hold_jid fastpitch_staging job_scripts/A2-fastpitch-prepare-lj-data.sh

# NB. I had problems running training in a non-interactive session submitted
# to the gpu-titanx parallel environment, something about data loader worker
# processes requesting way too much memory.
#
# You can address this by changing the num_workers argument to data loaders
# in two places in train.py, with the following results:
#   num_workers=1: 8 mins/epoch, 45G maxvmem (so request 50G)
#   num_workers=0: 15 mins/epoch, 23G maxvmem
sed -i.bak 's/num_workers=./num_workers=1/' train.py 

# batch size 16 uses 5.5G vram, takes ~8 mins/epoch
# batch size 32 uses 8.8G vram, takes ~6 mins/epoch
qsub -N fastpitch_train -hold_jid fastpich_prep_lj job_scripts/A3-fastpitch-train.sh

# synthesise speech
qsub -N fastpitch_inference -hold_jid fastpitch_train job_scripts/A4-fastpitch-inference.sh

# Once you have some model checkpoints and wav files, consider copying
# them back from scratch space to the SLP shared directory for safe keeping

