# GitHub tarball helpers, { flake, flakeBranch, flakeSubpath }. Usage:
#   flakeLib = import ./shared_configs/flake-helper.nix pkgs;  then (flake "u/r[#pkg]"), (flakeBranch "u/r[#pkg]" "main"), (flakeSubpath "u/r" "sub" "pkg")
pkgs:
let
  parseFlakeRef = ref:
    let parts = builtins.filter (p: ! builtins.isList p) (builtins.split "#" ref); in {
      repo = builtins.head parts;
      pkg = if builtins.length parts > 1 then builtins.elemAt parts 1 else null;
    };

  fetch = { repo, branch ? "master", subpath ? null, pkg ? null }:
    let
      src = builtins.fetchTarball "https://github.com/${repo}/archive/${branch}.tar.gz";
      base = if subpath != null
        then import "${src}/${subpath}" { inherit pkgs; }
        else import src { inherit pkgs; };
    in
      if pkg != null then base.${pkg}
      else if base ? packages then base.packages.${pkgs.stdenv.hostPlatform.system}.default
      else base.default;

in {
  flake = ref:
    let r = parseFlakeRef ref; in
    fetch { inherit (r) repo pkg; };

  flakeBranch = ref: branch:
    let r = parseFlakeRef ref; in
    fetch { inherit (r) repo pkg; inherit branch; };

  flakeSubpath = repo: subpath: pkg:
    fetch { inherit repo subpath pkg; };
}
