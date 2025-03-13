{
  description = "A flake to ensure that we don't need to worry about development dependencies.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    llama-cpp.url = "github:ggerganov/llama.cpp";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    llama-cpp,
  }: 
    flake-utils.lib.eachDefaultSystem (system: 
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {allowUnfree = true;};
        };

        scientific_python = pkgs.python3.withPackages (p: [
          p.ipython 
          p.numpy
          p.polars 
          p.pandas 
          p.psycopg
          p.pydantic 
          p.torch 
          p.psutil
          p.llama-cpp-python
        ]);
        
        infrastructure_packages = with pkgs; [
          docker-compose
          duckdb
        ];

        ai_packages = with pkgs; [
          openai-whisper-cpp
          ollama
        ];

      in
          {

            devShells = {
              default = pkgs.mkShell {
                buildInputs = [ 
                  scientific_python
                  llama-cpp.outputs.packages.${system}.default
                ] 
                ++ infrastructure_packages 
                ++ ai_packages;

                shellHook = ''
                  export DIRENV_LOG_FORMAT=
                  ${pkgs.pokemonsay}/bin/pokemonsay -N -t -d 151 "Let's cook."
                '';
              };
            };
        }
    );
}
