import pathlib
import json

from rich import print_json
from typing import Dict
from .load_backend import CUDABackend, RocmBackend, MetalBackend, CPUBackend

# from accelerate import init_empty_weights, load_checkpoint_and_dispatch


class LLModels:
    def __init__(self, path: pathlib.Path):
        self.models = {}

        for paths in path.glob("*"):
            if paths.is_dir():
                model_files_bin = list(paths.glob("*.bin"))

                # Prefer Safetensors over bin files
                model_files_safetensor = list(paths.glob("*.safetensor"))

                dtype = self.get_torch_dtype(paths.joinpath("config.json"))

                if len(model_files_bin) > 0:
                    self.models[paths.stem] = {
                        "path": str(paths),
                        "byte_size": sum([p.stat().st_size for p in model_files_bin]),
                        "type": "bin",
                        "torch_dtype": dtype,
                    }

                if len(model_files_safetensor) > 0:
                    self.models[paths.stem] = {
                        "path": str(paths),
                        "byte_size": sum(
                            [p.stat().st_size for p in model_files_safetensor]
                        ),
                        "type": "safetensor",
                        "torch_dtype": dtype,
                    }

    @staticmethod
    def get_torch_dtype(path: pathlib.Path):
        with open(path, "r") as f:
            config = json.load(f)

        return config["torch_dtype"]

    def list_models(self):
        print_json(json.dumps(self.models))

    def get_quantized_size(name: str):
        # s = self.models[name]
        pass

    def will_it_fit(
        self, name, backend: CUDABackend | RocmBackend | MetalBackend | CPUBackend
    ):
        pass
