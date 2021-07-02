  ## You can do some more checks on the GPU in python 
  import torch
  
  ## The following should return True if things are setup right
  torch.cuda.is_available()
  
  ## You can try to do some tensor manipulations to check if you can put data on the GPU
  ## https://stackoverflow.com/questions/48152674/how-to-check-if-pytorch-is-using-the-gpu
  
  device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
  print('Using device:', device)
  
  x = torch.rand(1000000, device=device)
  print(x)
  
  if device.type == 'cuda':
      print(torch.cuda.get_device_name(0))
      print('Memory Usage:')
      print('Allocated:', round(torch.cuda.memory_allocated(0)/1024**3,5), 'GB')
      print('Cached:   ', round(torch.cuda.memory_reserved(0)/1024**3,5), 'GB')

 