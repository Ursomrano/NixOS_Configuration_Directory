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
      };
    };
}