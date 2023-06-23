{
  description = "virtual environments";

  inputs.devshell.url = "github:numtide/devshell";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.llama-cpp.url = "github:ggerganov/llama.cpp";

  outputs = {
    self,
    flake-utils,
    devshell,
    llama-cpp,
    nixpkgs,
  }:
    flake-utils.lib.eachDefaultSystem (system: {
      devShell = let
        pkgs = import nixpkgs {
          inherit system;
          config = {allowUnfree = true;};
          overlays = [devshell.overlays.default];
        };
      in
        pkgs.devshell.mkShell {
          imports = [(pkgs.devshell.importTOML ./devshell.toml)];

          devshell.packages =
            if pkgs.system == "*-linux"
            then
              with pkgs; [
                openai-whisper-cpp
                (python3.withPackages (p: [p.numpy p.pydantic p.torch p.rich p.ipython p.psutil p.bitsandbytes p.accelerate]))
              ]
            else if pkgs.system == "*-darwin"
            then
              with pkgs; [

	        llama-cpp
                openai-whisper-cpp
                (python3.withPackages (p: [p.numpy p.pydantic p.torch p.rich p.ipython p.psutil]))
              ]
            else
              with pkgs; [
                (python3.withPackages (p: [p.numpy p.pydantic p.torch p.rich p.ipython p.psutil]))
              ];
        };
    });
}
