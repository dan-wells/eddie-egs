## login to eddie, need to be in the university VPN.  The password should be your ease password
ssh your_uun@eddie.ecdf.ed.ac.uk

## Go to an interactive node with a GPU
## From the login node, it's good to run tmux so that if you lose the connection you can rejoin
tmux

## To reattach your session if you get bumped of you'll need to get to the same login node that you started from
## to get to login1 you neeed to do: ssh login01-ext.ecdf.ed.ac.uk

## load anaconda
module load anaconda

## Get setup with anaconda: 
## SLP students should have access to this group space:
## /exports/chss/eddie/ppls/groups/lel_hcrc_cstr_students
## So, you can make a directory there called UUN_Firstname_Lastname and work in that
## You can probably just put things in your home directory or in the scratch space (/exports/eddie/scratch/<you-uun>)
## PLEASE NOTE THAT FILES IN THE SCRATCH SPACE GET DELETED AFTER 1 MONTH!

## See this page on setting anaconda directories
## https://www.wiki.ed.ac.uk/display/ResearchServices/Anaconda
YOUR_NAME=UUN_Firstname_Lastname
CONDADIR=/exports/chss/eddie/ppls/groups/lel_hcrc_cstr_students/$YOUR_NAME/conda
mkdir -p $CONDADIR
mkdir -p $CONDADIR/envs
mkdir -p $CONDADIR/pkgs


## Tell conda where to look for environments and download packages
conda config --add envs_dirs $CONDADIR/envs/
conda config --add pkgs_dirs $CONDADIR/pkgs/

## make a conda environment
conda create -n slptorch python=3.9
source activate slptorch

## install things

## The default version of gcc is 4.8.5 (in /usr/bin/gcc) which is too old for some packages
## e.g. to get openSmile to work you'll need a more up to date version of gcc and g++
conda install gcc_linux-64=8.4 gxx_linux-64=8.4
conda install cmake

## make these the default C and C++ compilers: 
##
## Installation adds environment setup scripts to $CONDA_PREFIX/etc/conda/activate.d
## which set CC and CXX. Either `source deactivate` and `source activate slptorch` to
## set these variables, or add the packages directly when creating the environment so
## you have them on first activation.
