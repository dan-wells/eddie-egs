## after logging into eddie, you can ask for an interactive gpu node to do actual computations.
## You don't need this just to install pytorch, but it's handy to be able to test if you can 
## actually access the gpu. 
## The following requests the node for 48 hours (maximum allowed), 1 K80 GPU, 32GB of RAM. 
qlogin -l h_rt=48:00:00 -pe gpu 1 -l h_vmem=32G

## start up the environment and install some packages if you like
module load anaconda
source activate slptorch

## If you're on an interactive node you need to run this so that the system knows to look for GPUs
source /exports/applications/support/set_cuda_visible_devices.sh
echo "Allocated GPU: $CUDA_VISIBLE_DEVICES"

## If you want to see the GPUs on node you're on, you can use this command from the bash shell (takes a while)
nvidia-smi
## That will just give you info for the time you run the command, but you can get it to keep printing out info with -l
nvidia-smi -l
## press Ctrl-C to stop it! 

## Then just use the normal conda command to install pytorch etc, as well as the appropriate cudatoolkit
conda install pytorch torchvision torchaudio cudatoolkit=10.2 -c pytorch

## Now check whether you've got a GPU in python
python -c 'import torch; print("cuda available?:", torch.cuda.is_available())'