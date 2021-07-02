## Get an interactive session on eddie with GPU
qlogin -l h_rt=48:00:00 -pe gpu 1 -l h_vmem=32G

## on eddie/interactive make sure you set CUDA_VISIBLE_DEVICES
source /exports/applications/support/set_cuda_visible_devices.sh
echo $CUDA_VISIBLE_DEVICES

## load anaconda
module load anaconda
conda create -n fastpitch python=3.8
source activate fastpitch

## To install nvidia apex you need a version of gcc/g++ > 5.0.  This has to be installed before 
## you install pytorch and the rest:

## Get a version of gcc > 5.0. The current anaconda default (June 2021) is 9.3 which seems to work (so far!)
conda install gcc_linux-64 gxx_linux-64
## deactivate and reactivate the conda environment to make these the default
## C and C++ compilers -- activation scripts have been installed alongside to
## set CC and CXX environment variables

## Based on some github comments, I tried cuda 11.0.2.  It may work with version 10, but I'm not sure.
## The issue is that also need nvcc, which available on eddie.  The easiest way to make this 'available'
## is to load the cuda/11.0.2 module, but there seems to be some 
## missing some actual cuda libraries there, so we still install cudatoolkit=11.0
module load cuda/11.0.2

## Need to install pytorch after updating gcc/g++?
conda install pytorch torchvision torchaudio cudatoolkit=11.0 -c pytorch

## Check cuda is available through pytorch - should write "True"
python -c 'import torch; print("cuda available?:", torch.cuda.is_available())'

## Now get the apex code from github
git clone https://github.com/NVIDIA/apex
cd apex

## install apex using pip.  If you don't get all your gcc/g++, pytorch, cuda versions sorted out earlier, this is where 
## you'll start getting errors.
## I sent stdout and stderr to tmp.txt here to debug but you don't need to do this! 
pip install -v --disable-pip-version-check --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./ > tmp.txt 2>&1

## back up a level
cd ../

