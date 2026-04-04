{ config, pkgs, lib, ... }:

let
  user = "ursomrano71";
in
{
  options = {
    hyprpaper.enableUserConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to deploy the declarative hyprpaper.conf for the user";
    };
  };

  config = lib.mkIf config.hyprpaper.enableUserConfig { 
    # Deploy the full hyprpaper.conf
    home-manager.users.${user}.home.file = {
    ".config/hypr/hyprpaper.conf".text = ''
splash = false
    '';
    ".config/hypr/hyprpaper.conf".force = true;
    };
  };
}
