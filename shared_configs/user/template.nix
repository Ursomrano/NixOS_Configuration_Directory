{ config, pkgs, lib, ... }:

let
  user = "ursomrano71";
in
{
  options = {
    *blank*.enableUserConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to deploy the declarative *blank*.conf for the user";
    };
  };

  config = lib.mkIf config.*blank*.enableUserConfig { 
    # Deploy the full *blank*.conf
    home-manager.users.${user}.home.file = {
    ".config/*blank*/*blank*.conf".text = ''

    '';
    ".config/*blank*/*blank*.conf".force = true;
    };
  };
}
