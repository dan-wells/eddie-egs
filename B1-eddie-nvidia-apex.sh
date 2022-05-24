# Get an interactive session on eddie with GPU
qlogin -l h_rt=48:00:00 -pe gpu 1 -l h_vmem=32G

# on eddie/interactive make sure you set CUDA_VISIBLE_DEVICES
source /exports/applications/support/set_cuda_visible_devices.sh
echo $CUDA_VISIBLE_DEVICES

# The best constellation of supported versions as of 2022-05-18 seems to be:
#  - python 3.9
#  - gcc 8.4
#  - cuda 10.2
#  - pytorch 1.11

# load anaconda
module load anaconda
conda create -n fastpitch python=3.9 gcc_linux-64=8.4 gxx_linux-64=8.4
# CC and CXX environment variables will be set upon activating the conda environment

# eddie cuda module provides nvcc and some libraries not included in the conda package,
# which we need to build apex later
# look out for pytorch version 1.11.0-py3.9_cuda10.2_cudnn7.6.5_0 -- note `cuda10.2`
module load cuda/10.2.89
conda install -n fastpitch -c pytorch pytorch torchvision torchaudio cudatoolkit=10.2

# Check cuda is available through pytorch - should write "True"
source activate fastpitch
python -c 'import torch; print("cuda available?:", torch.cuda.is_available())'

# Now get the apex code from github
git clone https://github.com/NVIDIA/apex.git
cd apex

# install apex using pip -- this will take a while.
# If you don't get all your gcc/g++, pytorch, cuda versions sorted out earlier,
# this is where you'll start getting errors.
# I sent stdout and stderr to log.txt here to debug but you don't need to do this!
pip install -v --disable-pip-version-check --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./ > log.txt 2>&1

# back up a level
cd ..
