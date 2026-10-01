{
  description = "Pinned CUDA devShell for ~/Documents/Programs/CUDA";

  # Pinned so cudatoolkit hits the binary cache; on the nixos channel
  # `use nix` would try to build 7.3 GB from source and fail.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          cudaPackages.cudatoolkit
          gdb
          cmake
          ninja
        ];

        # No /etc/ld.so.cache on this box, so libcuda.so.1 is not findable
        # at runtime without this.
        shellHook = ''
          export LD_LIBRARY_PATH="/run/opengl-driver/lib''${LD_LIBRARY_PATH:+:''$LD_LIBRARY_PATH}"
        '';
      };
    };
}
