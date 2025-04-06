{
  description = "Development shell for migrations";

  inputs = {
    # Nixpkgs input for the base environment
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    # Optional: Use flakes from GitHub or other sources
  };

  outputs =
    { self, nixpkgs, ... }:
    nixpkgs.flakes.forEachSystem (
      system:
      let
        # Import nixpkgs for the current system
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        # Create a development shell with the name "migrations" for the current system
        devShells.${system}.migrations = pkgs.mkShell {
          buildInputs = [
            pkgs.python3
            pkgs.python3Packages.pip
            pkgs.python3Packages.alembic
            pkgs.postgresql
            pkgs.psql
          ];

          shellHook = ''
            echo "Welcome to the migrations dev shell for ${system}!"
            export PIP_CACHE_DIR=$XDG_CACHE_HOME/pip
          '';
        };
      }
    );
}
