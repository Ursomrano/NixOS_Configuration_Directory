{ config, pkgs, lib, ... }:

let
  user = "ursomrano71";
in
{
  options = {
    *blank*.enableUserConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to deploy the declarative mako.conf for the user";
    };
  };

  config = lib.mkIf config.*blank*.enableUserConfig { 
    # Deploy the full *blank*.conf
    home-manager.users.${user}.home.file = {
    ".config/mako/config".text = ''
# General behavior
default-timeout=5000
ignore-timeout=0

# Optional: better urgency handling
[urgency=low]
default-timeout=5000

[urgency=normal]
default-timeout=7500

[urgency=high]
default-timeout=0
    '';
    ".config/mako/config".force = true;
    };
  };
}
