import pathlib
from .load_backend import CUDABackend, RocmBackend, MetalBackend, CPUBackend

class LLModels():

    def __init__(self, path: pathlib.Path):
        pass

    def list_all_models():
        pass

    def calculate_model_size():
        pass
        
    def print_run_options():
        pass
        
    def get_fit_parameters(self, name, backend: CUDABackend | RocmBackend | MetalBackend | CPUBackend):
        pass
