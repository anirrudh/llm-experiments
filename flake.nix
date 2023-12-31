{
  description = "A development environment for messing around with ML models.";

  inputs.devshell.url = "github:numtide/devshell";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.llama-cpp.url = "github:ggerganov/llama.cpp";

  outputs = {
    self,
    flake-utils,
    llama-cpp,
    devshell,
    nixpkgs,
  }:
    flake-utils.lib.eachDefaultSystem (system: {
      devShell = let
        pkgs = import nixpkgs {
          inherit system;
          config = {allowUnfree = true;};
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
                  llama-cpp.outputs.packages.${system}.default
                  openai-whisper-cpp
                ]
                ++ llm_python_env
            else [
              llm_python_env
            ];

          commands = [
            {
              name = "llama";
              category = "llama.cpp";
              help = "A port of Facebook's LLaMa Model to C++.";
              command = "${llama-cpp.outputs.packages.${system}.default}/bin/llama";
            }
            {
              name = "llama-server";
              category = "llama.cpp";
              help = "Runs a server instance of a llama based model.";
              command = "${llama-cpp.outputs.packages.${system}.default}/bin/llama-server";
            }
            {
              name = "llama-embedding";
              category = "llama.cpp";
              help = "Runs an embedded instance of llama?";
              command = "${llama-cpp.outputs.packages.${system}.default}/bin/embedding";
            }
            {
              name = "whisper-cpp";
              category = "whisper.cpp";
              help = "A port of OpenAI whisper model to C++. [whisper-cpp]";
              command = "${pkgs.openai-whisper-cpp}/bin/whisper-cpp";
            }
            {
              name = "whisper-stream";
              category = "whisper.cpp";
              help = "Use whisper in real-time. [whisper-cpp-stream]";
              command = "${pkgs.openai-whisper-cpp}/bin/whisper-cpp-stream";
            }
            {
              name = "whisper-download";
              category = "whisper.cpp";
              help = "Download ggml models for whisper. [whisper-cpp-download]";
              command = "${pkgs.openai-whisper-cpp}/bin/whisper-cpp-download-ggml-model";
            }
          ];
        };
    });
}
