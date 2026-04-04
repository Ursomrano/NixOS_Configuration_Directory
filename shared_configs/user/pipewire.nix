{ config, pkgs, lib, ... }:

let
  user = "ursomrano71";
in
{
  options = {
    pipewire.enableUserConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to deploy the declarative pipewire.conf for the user";
    };
  };

  config = lib.mkIf config.pipewire.enableUserConfig {
    # Home Manager: user-level pipewire.conf
    home-manager.users.${user}.home.file = {
      ".config/pipewire/pipewire.conf.d/99-buffer.conf".text = ''
context.properties = {
    default.clock.rate = 48000
    default.clock.allowed-rates = [44100 48000 96000 192000]
    #default.clock.quantum = 2048
    default.clock.min-quantum = 512
    default.clock.max-quantum = 4096
}
      '';
      ".config/pipewire/pipewire.conf.d/99-buffer.conf".force = true;
    };

    # System-level PipeWire realtime module
    services.pipewire.extraConfig.pipewire."10-realtime" = {
      "context.modules" = [
        {
          name = "libpipewire-module-rt";
          args = {
            "rt.prio" = 88;
            "nice.level" = -15;
          };
        }
      ];
    };
  };
}
