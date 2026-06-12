{ config, pkgs, lib, ... }:

let
  user = "ursomrano71";
in
{
  config = {
    hyprland.shared.enable = config.hyprland.enableUserConfig;

    home-manager.users.${user}.home.file = lib.mkIf config.hyprland.enableUserConfig {
      ".config/hypr/hyprland.conf".text = ''
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃                 CachyOS Hyprland PC Config                  ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

# --- Hardware Specific Defaults ---
$scaling = GDK_SCALE=1 GDK_DPI_SCALE=1
$capturing = timestamp=$(date +'%Y-%m-%d_%H-%M-%S') ; grim -g "$(slurp)" "$HOME/Pictures/Screenshots/$timestamp.png" ; swappy -f "$HOME/Pictures/Screenshots/$timestamp.png"

# --- Shared Config ---
source = ~/.config/hypr/shared.conf

# --- Hardware Specific Monitor ---
monitorv2 {
	output = DP-1
	mode = 2560x1440@280
	position = 0x0
	scale = 1
	vrr = 2
	bitdepth = 10
	cm = hdr
	sdrsaturation = 1.20
	sdrbrightness = 1
	sdr_min_luminance = 0.005
	sdr_max_luminance = 200
	min_luminance = 0
	max_luminance = 400
	max_avg_luminance = 200
	supports_wide_color = 1
	supports_hdr = 1
}

# --- Hardware Specific Environment ---
env = GDK_SCALE, 1
env = GDK_DPI_SCALE, 1

# --- Keybinds (Hardware Specific) ---
bindd = $mainMod, Print, Screen capture selection, exec, $capturing
      '';
      ".config/hypr/hyprland.conf".force = true;
    };
  };

  options = {
    hyprland.enableUserConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to deploy the declarative hyprland.conf for the user";
    };
  };
}
