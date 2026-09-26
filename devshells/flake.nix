{
  description = "Ursomrano71 per-directory dev tools (loaded via direnv)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    in
    {
      devShells.${system} = {
        # cd ~/Documents/Programs/SystemVerilog
        # Run with: verilator, yosys, svls (SystemVerilog LSP)
        systemverilog = pkgs.mkShell {
          packages = [ pkgs.verilator pkgs.yosys pkgs.svls ];
        };

        # cd ~/Documents/Programs/C++  (also powers renameFLAC)
        # Run with: valgrind, sox, rsgain, flac
        cpp = pkgs.mkShell {
          packages = [ pkgs.valgrind-light pkgs.sox pkgs.rsgain pkgs.flac ];
        };

        # cd ~/Documents/Programs/C   (create the dir and copy the .envrc if you add one)
        c = pkgs.mkShell {
          packages = [ pkgs.valgrind-light pkgs.sox pkgs.rsgain pkgs.flac ];
        };

        # cd ~/Documents/Programs/Shell  (powers FlacToOpus.sh)
        audio = pkgs.mkShell {
          packages = [ pkgs.sox pkgs.rsgain pkgs.flac ];
        };

        # cd ~/Documents/Programs/CUDA
        # Run with: nvcc, gdb, cmake, ninja
        #
        # stdenv is pinned to gcc14 on purpose: nixpkgs defaults to gcc 15.3.0,
        # but CUDA 12.9's nvcc only supports host compilers up to gcc 14.
        cuda = pkgs.mkShell {
          stdenv = pkgs.gcc14Stdenv;
          packages = [
            pkgs.cudaPackages.cudatoolkit
            pkgs.gdb
            pkgs.cmake
            pkgs.ninja
          ];
          # This box has no /etc/ld.so.cache, so the driver in /run/opengl-driver/lib
          # is not on the default loader path. Without this, compiled binaries die on
          # "libcuda.so.1: cannot open shared object file".
          shellHook = ''
            export LD_LIBRARY_PATH="/run/opengl-driver/lib''${LD_LIBRARY_PATH:+:''$LD_LIBRARY_PATH}"
          '';
        };
      };
    };
}