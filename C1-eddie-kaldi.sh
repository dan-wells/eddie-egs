#!/bin/sh

YOUR_NAME=UUN_Firstname_Lastname

# Interactive session with 8 CPU, 8 GB RAM
#qlogin -pe sharedmem 8 -R y
# single core, 4G RAM (need more memory for conda ops)
qlogin -l h_vmem=4G

# load conda for gcc/gxx
module load anaconda
conda create -c conda-forge -n kaldi python=2.7 gcc_linux-64=7.5 gxx_linux-64=7.5 sox zlib
# CC, CXX env vars will already be set
source activate kaldi

# let's work in SLP group space -- full set of Kaldi-related binaries can get big
cd /exports/chss/eddie/ppls/groups/lel_hcrc_cstr_students/$YOUR_NAME

git clone https:/github.com/kaldi-asr/kaldi
cd kaldi

# following instructions in the file INSTALL

# first we install some dependencies
cd tools

# matrix multiplication libs
module load phys/libs/intel/mkl
export MKL_ROOT=$MKLROOT
#export MKL_ROOT=/exports/applications/apps/community/phys/intel-mkl-2019.1.144/compilers_and_libraries/linux/mkl

# this is to pick up e.g. zlib under conda env
export CXXFLAGS="$CXXFLAGS -I$CONDA_PREFIX/include"

# should show all OK
extras/check_dependencies.sh

# if you managed to get an interactive session with multiple cores,
# use -j to parallelise build process
make -j $(nproc) cub

make sctk
## fixing some bad makefile inside sctk
## the thing after '119i\' MUST be a TAB
sed -i.bak "119i\	sed -i.bak 's/gcc/\$\$\(CC\)/' sctk/src/rfilter1/makefile" Makefile
make -j $(nproc) sctk_made

make -j $(nproc) sph2pipe

make -j $(nproc) openfst

# then build the actual Kaldi stuff
cd ../src

module load cuda/10.2.89

# some combination of these makes it work but I don't know which
export LD_LIBRARY_PATH=$PWD/lib:$LD_LIBRARY_PATH
export CXXFLAGS="$CXXFLAGS -Wl,-rpath,$PWD/lib -Wl,-rpath-link,$PWD/lib"
export LDFLAGS="$LDFLAGS -Wl,-rpath,$PWD/lib -Wl,-rpath-link,$PWD/lib"

./configure --shared --mkl-root=$MKL_ROOT --mkl-libdir=$MKL_ROOT/lib/intel64 --cudatk-dir=$CUDA_PATH
make -j $(nproc) clean depend
make -j $(nproc)

# Suggested environment setup for running kaldi (untested)
# Add these lines to any job scripts:
#   module load anaconda
#   source activate kaldi
#   export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH
#   module load phys/libs/intel/mkl
#   export MKL_ROOT=$MKLROOT
#   module load cuda/10.2.89
#   export LD_LIBRARY_PATH=/exports/chss/eddie/ppls/groups/lel_hcrc_cstr_students/$YOUR_NAME/kaldi/lib:$LD_LIBRARY_PATH
# If there are any errors about not being able to find e.g. openfst libs,
# then add directories under $KALDI_ROOT/tools/openfst/lib (or whatever
# from tools/ isn't being picked up:
#   export LD_LIBRARY_PATH=/exports/chss/eddie/ppls/groups/lel_hcrc_cstr_students/$YOUR_NAME/kaldi/tools/openfst/lib:$LD_LIBRARY_PATH

