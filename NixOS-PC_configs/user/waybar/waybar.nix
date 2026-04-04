{ config, pkgs, lib, ... }:

let
  user = "ursomrano71";
in
{
  options = {
    waybar.enableUserConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to deploy the declarative waybar configuration for the user";
    };
  };

  config = lib.mkIf config.waybar.enableUserConfig {
    home-manager.users.${user}.home = lib.mkMerge [
      # --- Files ---
      {
        file = lib.mkMerge [
          
          # Waybar config JSON
          (lib.mkIf config.waybar.enableUserConfig {
            ".config/waybar/config".text = ''
{
    // -------------------------------------------------------------------------
    // Global configuration
    // -------------------------------------------------------------------------

    "layer": "top",

    "position": "$${WAYBAR_POSITION:-top}",

    //"height": 20,

    "margin-left": 10,
    "margin-bottom": 0,
    "margin-right": 10,

    "spacing": 5, // Gaps between modules (4px)

    "modules-left": [
        "custom/rofi",
        "hyprland/workspaces"
    ],
    "modules-center": [
        "clock"
    ],
    "modules-right": [
    	"tray",
        "memory",
	"custom/gpu",
        "cpu",
        "battery",
	"network",
        "pulseaudio",
        "custom/power"
    ],


    // -------------------------------------------------------------------------
    // Modules
    // -------------------------------------------------------------------------
    "custom/rofi": {
        "format": "",
        "tooltip": false,
        "on-click-right": "nwg-drawer",
        "on-click": "wofi --show run",
        "on-click-middle": "pkill -9 wofi"
    },

    "hyprland/workspaces": {
        "all-outputs": true,
        "format": "{name}",
        "format-icons": {
            "1": "一",
            "2": "二",
            "3": "三",
            "4": "四",
            "5": "五",
            "6": "六",
            "7": "七",
            "8": "八",
            "9": "九",
            "10": "十",
        },
        "on-scroll-up": "hyprctl dispatch workspace e+1 1>/dev/null",
        "on-scroll-down": "hyprctl dispatch workspace e-1 1>/dev/null",
        "sort-by-number": true,
        "active-only": false,
    },

    "clock": {
        "format": "󰅐  {:%I:%M %p   %e %b}",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
        "today-format": "<b>{}</b>"
    },

    "tray": {
        "icon-size": 15,
        "spacing": 5
    },

    "memory": {
        "interval": 30,
        "format": "  {used:0.2f} / {total:0.0f} GB",
        "on-click": "alacritty -e btop"
    },

    "custom/gpu": {
	"interval": 1,
	"format": "󱤓  {}%",
	"max-length": 13,
	"min-length": 13,
	"exec": "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits"
    },

    "cpu": {
        "interval": 1,
        "format": "  {usage}%", // Icon: microchip
        //"format": "{max_frequency}GHz <span color=\"darkgray\">| {usage}%</span>",
        "max-length": 13,
        "min-length": 13
    },

    "battery": {
        "interval": 2,
        "states": {
            "good": 95,
            "warning": 30,
            "critical": 15
        },
        "format": "{icon} {capacity}%",
        "format-charging": "󱊦 {capacity}%",
        "format-plugged": " {capacity}%",
        "format-icons": [
            "",
            "",
            "",
            "",
            ""
        ]
    },

    "network": {
        "format-wifi": " :  {bandwidthUpBits},  {bandwidthDownBits}",
        "format-ethernet": "󰈀 :  {bandwidthUpBits},  {bandwidthDownBits}",
        "format-linked": "{ifname} (No IP) ",
        "format": "",
        "format-disconnected": "󰌙 ",
        "format-alt": "{ifname}: {ipaddr}/{cidr}",
        "on-click": "wl-copy $(ip address show up scope global | grep inet | head -n1 | cut -d/ -f 1 | tr -d [:space:] | cut -c5-)",
        "on-click-right": "wl-copy $(ip address show up scope global | grep inet6 | head -n1 | cut -d/ -f 1 | tr -d [:space:] | cut -c6-)",
        "tooltip-format": "{ifname}: {ipaddr}/{cidr}",
        "tooltip-format-wifi": " {essid} {frequency}MHz\nStrength: {signaldBm}dBm ({signalStrength}%)\nIP: {ipaddr}/{cidr}",
        "interval": 10
    },

    "pulseaudio": {
        "scroll-step": 3, // %, can be a float
        "format": "{icon} {volume}% {format_source}",
        "format-bluetooth": "{volume}% {icon} {format_source}",
        "format-bluetooth-muted": " {icon} {format_source}",
        "format-muted": " {format_source}",
        //"format-source": "{volume}% ",
        //"format-source-muted": "",
        "format-source": "",
        "format-source-muted": "",
        "format-icons": {
            "headphone": "",
            "hands-free": "",
            "headset": "",
            "phone": "",
            "portable": "",
            "car": "",
            "default": ["󰕿", "󰖀", "󰕾"]
        },
        "on-click": "pavucontrol",
        "on-click-right": "amixer sset Master toggle"
    },

    "custom/power": {
        "format": "⏻",
        "tooltip": false,
        "on-click": "wlogout"
    }
}
            '';
            ".config/waybar/config".force = true;
          })

          # Waybar CSS
          (lib.mkIf config.waybar.enableUserConfig {
            ".config/waybar/style.css".text = ''
/* --- Global Reset --- */
* {
    font-family: "Source Code Pro";
    font-size: 15px;
    font-weight: 900;
    margin: 0.2em 0.3em;
    padding: 0;
    border: none;
    border-radius: 3px;
    min-height: 0;
    transition: background-color 0.5s;
}

/* --- Waybar container --- */
#waybar {
    background-color: transparent;
    color: #ffffff;
    border-radius: 0;
    margin: 0;
    text-shadow:
      1px 1px 0 rgba(0, 0, 0, 0.25),
     -1px 1px 0 rgba(0, 0, 0, 0.25),
      1px -1px 0 rgba(0, 0, 0, 0.25),
     -1px -1px 0 rgba(0, 0, 0, 0.25);
}

/* --- Hidden state --- */
window#waybar.hidden {
    opacity: 0.2;
}

/* --- Workspaces --- */
#workspaces button {
    padding: 0;
    color: #7984a4;
    background-color: transparent;
    box-shadow: inset 0 -3px transparent;
    border-radius: 0;
}

#workspaces button.focused,
#workspace button.hover {
    background-color: transparent;
}

#workspaces button.active {
    color: #fff;
}

#workspaces button.urgent {
    background-color: #eb4d4b;
}

/* --- Modules common style --- */
#clock,
#battery,
#cpu,
#memory,
#disk,
#temperature,
#language,
#temperature.critical,
#backlight,
#network,
#pulseaudio,
#wireplumber,
#custom-media,
#custom-media.custom-vlc,
#custom-screenshot_t,
#tray,
#mode,
#idle_inhibitor,
#idle_indicator.activated,
#mpd,
#bluetooth,
#keyboard-state,
#custom-gpu,
#custom-rofi,
#custom-power,
#custom-hyprPicker,
#custom-power-menu,
#custom-launcher,
#custom-spotify,
#window,
#workspaces {
    padding: 0 15px;
    background-image: url("/etc/nixos/NixOS-PC_configs/user/waybar/Hexagon-Nix.svg");
    background-size: cover;
    background-repeat: no-repeat;
    background-position: center;
    background-color: transparent;
}

/* --- Module-specific colors --- */
#cpu { color: #FF8C00; }
#custom-gpu { color: #91e600; }
#memory { color: #ebcb8b; }
#pulseaudio { color: #7ea6ce; }
#backlight { color: #8fbcbb; }
#clock { color: #eff2f6; }
#custom-media {color: #2a5c45;}
#battery { color: #c0caf5; }
#battery.charging,
#battery.full,
#battery.plugged { color: #2abb67; }
#battery.critical:not(.charging) {
    color: #f53c3c;
    animation: blink 0.5s linear infinite alternate;
}
#bluetooth { color: #707d9d; }
#bluetooth.disconnected { color: #f53c3c; }
#network { color: #c67bb7; }
#network.disconnected { color: #f53c3c; }
#idle_inhibitor.activated { color: #2d3436; }
#language { color: #740864; }
#custom-launcher { color: #6a92d7; }

/* --- Weird stuff --- */
#tray > .passive { -gtk-icon-effect: dim; }
#tray > .needs-attention { -gtk-icon-effect: highlight; background-color: #eb4d4b; }
#keyboard-state > label { padding: 0; }
#keyboard-state > label.locked { background: rgba(0,0,0,0.2); }

/* --- Module positioning tweaks --- */
.modules-left > widget:first-child > #workspaces { margin-left: 0; }
.modules-right > widget:last-child > #workspaces { margin-right: 0; }

/* --- Focus --- */
label:focus { background-color: #000; }

/* --- Animations --- */
@keyframes blink {
    to {
        background-color: rgba(30,34,42,0.5);
        color: #abb2bf;
    }
}
            '';
            ".config/waybar/style.css".force = true;
          })

        ];
      }

    ];
  };
}

