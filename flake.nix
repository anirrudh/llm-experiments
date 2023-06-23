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
          inputsFrom =
            if pkgs.system == "*-darwin"
            then [llama-cpp.devShells.${system}.default]
            else [];
          overlays = [devshell.overlays.default];
        };

        llm_python_env = pkgs.python3.withPackages (p: [p.ipython p.numpy p.pydantic p.torch p.rich p.ipython p.psutil]);
      in
        pkgs.devshell.mkShell {
          imports = [(pkgs.devshell.importTOML ./devshell.toml)];

          devshell.packages =

            if pkgs.system == "*-linux"
            then
              with pkgs; [
                openai-whisper-cpp
                (python3.withPackages llm_python_env (p: [p.bitsandbytes p.accelerate]))
              ]
            else if pkgs.system == "*-darwin"
            then
              with pkgs;
                [
                  openai-whisper-cpp
                ]
                ++ llm_python_env
            else [
              llm_python_env
            ];

          commands = [
            {
              name = "whisper";
              category = "Speech to Text | whisper.cpp";
              help = "A port of openAI whisper model to C++. [whisper-cpp]";
              command = "${pkgs.openai-whisper-cpp}/bin/whisper-cpp";
            }
            {
              name = "whisper-stream";
              category = "Speech to Text | whisper.cpp";
              help = "Use whisper in real-time. [whisper-cpp-stream]";
              command = "${pkgs.openai-whisper-cpp}/bin/whisper-cpp-stream";
            }
            {
              name = "whisper-download";
              category = "Speech to Text | whisper.cpp";
              help = "Download ggml models for whisper. [whisper-cpp-download]";
              command = "${pkgs.openai-whisper-cpp}/bin/whisper-cpp-download-ggml-model";
            }
          ];
        };
    });
}
