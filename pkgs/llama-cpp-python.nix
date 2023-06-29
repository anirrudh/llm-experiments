{pkgs, ...}:{
lul = pkgs.python3Packages.buildPythonPackage rec {
          pname = "llama-cpp-python";
          version = "0.1.66";

          src = pkgs.fetchFromGitHub {
            owner = "abetlen";
            repo = "llama-cpp-python";
            rev = "v${version}";
            sha256 = "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad";
          };
          nativeBuildInputs = with pkgs; [
            cmake
          ];

          propagatedBuildInputs = with pkgs.python3Packages; [
            asciitree
            numpy
            fasteners
            numcodecs
          ];
        };
}
