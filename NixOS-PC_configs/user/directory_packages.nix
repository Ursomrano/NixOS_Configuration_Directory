# Per-directory tool lists; configuration.nix writes the .envrc files -- don't hand-edit.
# "<path>" = { packages = [<nixpkgs attr paths as strings, never derivations>]; hook = "..."; } | { flake = "<path>"; }
let
  cpp = [ "valgrind-light" "cmake" "gdb" "ninja" ];
  media = ["sox" "rsgain" "flac"];
in
{
  "Documents/Programs/C++" = {
    packages = cpp;
  };

  "Documents/Programs/C++/FLAC_Collection_Renamer" = {
    packages = media;
  };

  "Documents/Programs/C" = {
    packages = cpp;
  };

  "Documents/Programs/Shell" = {
    packages = media;
  };

  "Documents/Programs/SystemVerilog" = {
    packages = [ "verilator" "yosys" "svls" ];
  };

  # The one directory that needs a pinned flake: cudatoolkit is not in the
  # binary cache for the nixos channel, so `use nix` would build 7.3 GB from source.
  "Documents/Programs/CUDA" = {
    flake = "/etc/nixos/cuda-devshell";
  };
}
