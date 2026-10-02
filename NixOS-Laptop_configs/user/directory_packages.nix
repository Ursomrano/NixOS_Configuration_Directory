# Per-directory tool lists; configuration.nix writes the .envrc files -- don't hand-edit.
# "<path>" = { packages = [<nixpkgs attr paths as strings, never derivations>]; hook = "..."; } | { flake = "<path>"; }
let
  cpp = [ "valgrind-light" "cmake" "gdb" "ninja" ];
in
{
  "Documents/Programs/C++" = {
    packages = cpp;
  };

  "Documents/Programs/C" = {
    packages = cpp;
  };

  "Documents/Programs/Shell" = {
    packages = [ "sox" "rsgain" "flac" ];
  };

  "Documents/Programs/SystemVerilog" = {
    packages = [ "verilator" "yosys" "svls" ];
  };

  # The one directory that needs a pinned flake: cudatoolkit is not in the
  # binary cache for the nixos channel, where `use nix` would build 7.3 GB from source.
  "Documents/Programs/CUDA" = {
    flake = "/etc/nixos/cuda-devshell";
  };

  "Documents/School/Fall2026/CS480" = {
    packages = cpp;
  };
}
