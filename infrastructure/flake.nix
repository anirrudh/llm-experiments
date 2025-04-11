{
  description = "Development shell for migrations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        # Import nixpkgs for the current system
        pkgs = import nixpkgs {
          inherit system;
        };

        migrations-pythonEnv = pkgs.python312.withPackages (
          pythonPackages: with pythonPackages; [
            alembic
            psycopg
            polars
          ]
        );
      in
      {
        # Create a development shell with the name "migrations" for the current system
        devShells = {
          migrations = pkgs.mkShell {
            buildInputs = [
              migrations-pythonEnv
            ];

            shellHook = ''
              echo "Welcome to the migrations dev shell for ${system}!"
              export PIP_CACHE_DIR=$XDG_CACHE_HOME/pip
            '';
          };
        };
      }
    );
}
