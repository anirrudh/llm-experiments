import psutil
import sys
import pathlib

import torch
from rich import print

class BaseBackend():
    operating_system: str = sys.platform
    total_memory_ram: int = psutil.virtual_memory().total
    available_memory: int = psutil.virtual_memory().available
    free_disk: int = psutil.disk_usage(f'{str(pathlib.Path.home())}/GAI/').free 

    def __repr__(self):
        return(f'''
              System Backend Information
              --------------------

              Disk
              ---------
              Free Disk: {self.free_disk* 10**-9} GB
              
              Ram
              ---------
              Total Memory: {self.total_memory_ram * 10**-9} GB
              Available Memory: {psutil.virtual_memory().available * 10**-9} GB
              ''')

class CUDABackend(BaseBackend):
    def __init__(self, device, name):
        self.device: torch.device = device
        self.name: str = name
        self.total_memory_gpu: int = torch.cuda.get_device_properties(0).total_memory

    def __repr__(self):
        parent_info = super().__repr__()
        
        return(parent_info + f'''
              GPU 
              --------
              Device: {self.name}
              Total RAM: {self.total_memory_gpu* 10**-9} GB
              ''')
        

class RocmBackend(BaseBackend):
    def __init__(self, device, name):
        self.device: torch.device = device
        self.name: str = name
        self.total_memory_gpu: int = torch.cuda.get_device_properties(0).total_memory

    def __repr__(self):
        parent_info = super().__repr__()
        
        return(parent_info + f'''
              GPU 
              --------
              Device: {self.name}
              Total RAM: {self.total_memory_gpu* 10**-9} GB
              ''')
        


class MetalBackend(BaseBackend):
    def __init__(self, device, name):
        self.device: torch.device = device
        self.name: str = name
    
    def __repr__(self):
        parent_info = super().__repr__()
        
        return(parent_info + f'''
              GPU 
              --------
              Device: {self.name}
              Total RAM: {self.total_memory_gpu * 10**-9} GB
              ''')

class CPUBackend(BaseBackend):
    pass

def initialize_backend() -> CUDABackend | MetalBackend | RocmBackend | None:
    platform = sys.platform
    backend = None
    print(f"Operating System | {platform}")
    
    if platform == "linux":    
        try:
            torch.cuda.is_available() 
        except:
            print("WARNING: Was not able to initalize the GPU Backend. Falling Back to CPU.")

        if "NVIDIA" in torch.cuda.get_device_name(0):
            backend = CUDABackend(device = torch.device("cuda"), name = torch.cuda.get_device_name(0))
            print("Initializing NVIDIA + Cuda as backend.")

        elif "AMD" in torch.cuda.get_device_name(0):
            backend = RocmBackend(device = torch.device("cuda"), name = torch.cuda.get_device_name(0))
            print("Initializing AMD + Rocm as backend.")

        return backend

    elif platform == "darwin":
        try:
            torch.backends.mps.is_available() 
        except:
            print("ERROR: Was not able to initalize the Metal Backend.")

        backend = MetalBackend(device=torch.device("mps"))
        return backend
