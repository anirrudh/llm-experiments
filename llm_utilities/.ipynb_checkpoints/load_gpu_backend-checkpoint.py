import psutil
import sys

import torch
from rich import print

class BaseBackend():
    total_memory: int = psutil.virtual_memory().total
    available_memory: int = psutil.virtual_memory().available
    free_disk: int = psutil.disk_usage('/').free 

    def __repr__(self):
        print(f'''
              System Backend Information
              --------------------

              Disk
              ---------
              Free Disk: {self.free_disk}
              
              Ram
              ---------
              Total Memory: {self.total_memory}
              Available Memory: {self.available_memory}
              ''')
        return

class CUDABackend(BaseBackend):
    def __init__(self, device, name):
        self.device: torch.device = device
        self.name: str = name

    def __repr__(self):
        super().__repr__()
        print(f'''
              GPU 
              --------
              Device: {self.name}
              ''')

class RocmBackend(BaseBackend):
    def __init__(self, device, name):
        self.device: torch.device = device
        self.name: str = name

    def __repr__(self):
        super().__repr__()
        print(f'''
              GPU 
              --------
              Device: {self.name}
              ''')


class MetalBackend(BaseBackend):
    def __init__(self, device, name):
        self.device: torch.device = device
        self.name: str = name
    
    def __repr__(self):
        super().__repr__()
        print(f'''
              GPU 
              --------
              Device: {self.name}
              ''')



def initialize_backend() -> CUDABackend | MetalBackend | RocmBackend | None:
    platform = sys.platform
    backend = None

    if platform == "linux":
        print("Detected Linux.")
        try:
            torch.cuda.is_available() 
        except:
            print("ERROR: Was not able to initalize the Metal Backend.")

        if "NVIDIA" in torch.cuda.get_device_name(0):
            backend = CUDABackend(device = torch.device("cuda"), name = torch.cuda.get_device_name(0))
            print("Setting up usage of NVIDIA as backend")

        elif "AMD" in torch.cuda.get_device_name(0):
            backend = RocmBackend(device = torch.device("cuda"), name = torch.cuda.get_device_name(0))
            print("Setting up usage of AMD Rocm as backend")

        return backend

    elif platform == "darwin":
        print("Detected macOS.")
        try:
            torch.backends.mps.is_available() 
        except:
            print("ERROR: Was not able to initalize the Metal Backend.")

        backend = MetalBackend(device=torch.device("mps"))
        return backend
