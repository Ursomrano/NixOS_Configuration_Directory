{ config, pkgs, lib, ... }:

let
  user = "ursomrano71";
in
{
  config = {
    hyprland.shared.enable = config.hyprland.enableUserConfig;

    home-manager.users.${user}.home.file = lib.mkIf config.hyprland.enableUserConfig {
      ".config/hypr/hyprland.lua".text = ''
-- ┃                 CachyOS Hyprland Laptop Config              ┃

-- --- Hardware Specific Defaults ---
scaling = "GDK_SCALE=2.72134 GDK_DPI_SCALE=1"
capturing = "timestamp=$(date +'%Y-%m-%d_%H-%M-%S') ; grim -g \"$(slurp)\" \"$HOME/Pictures/Screenshots/$timestamp.png\" ; swappy -f \"$HOME/Pictures/Screenshots/$timestamp.png\""

-- --- Shared Config ---
require("shared")

-- --- Hardware Specific Monitor ---
hl.monitor({
    output = "eDP-1",
    mode = "3456x2160@60",
    position = "0x0",
    scale = 1.5,
    vrr = 2,
    bitdepth = 10,
    cm = "hdr",
    sdrsaturation = 1.20,
    sdrbrightness = 1,
    sdr_min_luminance = 0.005,
    sdr_max_luminance = 400,
    min_luminance = 0,
    max_luminance = 400,
    max_avg_luminance = 400,
    supports_wide_color = 1,
    supports_hdr = 1,
})

-- --- Hardware Specific Environment ---
hl.env("GDK_SCALE", "2.72134")

-- --- Keybinds (Hardware Specific) ---
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd(capturing), { description = "Screen capture selection" })
      '';
      ".config/hypr/hyprland.lua".force = true;
    };
  };

  options = {
    hyprland.enableUserConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to deploy the declarative hyprland.lua for the user";
    };
  };
}
