# Eddie recipes

This repo serves as an introduction to the [Eddie](https://www.ed.ac.uk/information-services/research-support/research-computing/ecdf/high-performance-computing) computing cluster at the University of Edinburgh.

Recommended reading:
  - [Eddie wiki pages](https://www.wiki.ed.ac.uk/pages/viewpage.action?spaceKey=ResearchServices&title=Eddie) (requires EASE login)
    - [Quickstart](https://www.wiki.ed.ac.uk/display/ResearchServices/Quickstart)
    - [Interactive sessions](https://www.wiki.ed.ac.uk/display/ResearchServices/Interactive+Sessions)
    - [Job submission](https://www.wiki.ed.ac.uk/display/ResearchServices/Job+Submission)
    - [GPUs](https://www.wiki.ed.ac.uk/display/ResearchServices/GPUs)
  - [`tmux` cheatsheet](https://tmuxcheatsheet.com/)

Credit to [Catherine Lai](https://homepages.inf.ed.ac.uk/clai/) for original recipes:

  - [conda setup](https://gist.github.com/laic/7b23e0fd21685f0527c91378fb45c395)
  - [FastPitch setup](https://gist.github.com/laic/b57355e5188616c299e9eead892bed30)

**Note:** There are various places in the recipes and job scripts where you should substitute things like your UUN, name or email.
Sometimes this is in the body of the script, sometimes in the commented headers intended to be read by the scheduler on Eddie.

# Getting set up

To get started:

- Configure `conda` to store environments somewhere you won't run out of space: `A1-eddie-conda-setup.sh`
- Set up a basic environment with PyTorch and up-to-date compilers: `A2-install-pytorch-conda.sh`

Then, pick your tools!

- For FastPitch TTS, see `B1-eddie-nvidia-apex.sh` and `B2-eddie-fastpitch.sh`
- For Kaldi, see `C1-eddie-kaldi.sh`

In general, it's a good idea to use interactive sessions when setting up your environment and testing code (especially on the GPU).
Once you have everything working, put together some job scripts, submit to the queue and sit back!

# Example job submission scripts

Check the `job_scripts/` directory for some sample job scripts for running FastPitch.
This includes data staging and preprocessing, model training and inference.
