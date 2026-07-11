# Pull a package from a GitHub flake.
# Usage: import ./shared_configs/flake-helper.nix pkgs
# Then:   (flake "user/repo")           -- defaults to master branch
#         (flake "user/repo" "main")    -- specify branch
pkgs:
repo:
branch:
let
  src = builtins.fetchTarball "https://github.com/${repo}/archive/${branch}.tar.gz";
  result = import src { inherit pkgs; };
in if result ? packages then result.packages.${pkgs.stdenv.hostPlatform.system}.default else result.default
