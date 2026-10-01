# Per-directory tool lists. Generated .envrc per directory; the files are written
# by configuration.nix, so don't edit them by hand.
#
#   "<path under $HOME>" = { packages = [ ... ]; hook = "..."; };
#   "<path under $HOME>" = { flake = "/path/to/flake"; };
#
# `packages` are nixpkgs ATTRIBUTE PATHS as strings, not derivations -- coercing
# a derivation to text gives its build output name ("gcc-wrapper"), which is not
# an attribute. Unpinned: they follow whatever <nixpkgs> is.
# `flake` emits `use flake <path>` instead, for a pinned devShell (CUDA below).
# `hook` is extra .envrc lines, and only applies to the `packages` form.
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
