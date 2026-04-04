{ config, pkgs, lib, ... }:

let
  user = "ursomrano71";
in
{
  options = {
    wlogout.enableUserConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to deploy the declarative wlogout onfiguration for the user";
    };
  };

  config = lib.mkIf config.wlogout.enableUserConfig {
    home-manager.users.${user}.home.file = lib.mkMerge [
    	(lib.mkIf config.wlogout.enableUserConfig {
    	".config/wlogout/layout".text = ''
{
    "label" : "lock",
    "action" : "swaylock",
    "text" : "Lock",
    "keybind" : "l"
}
{
    "label" : "hibernate",
    "action" : "systemctl hibernate",
    "text" : "Hibernate",
    "keybind" : "h"
}
{
    "label" : "logout",
    "action" : "hyprctl dispatch exit",
    "text" : "Logout",
    "keybind" : "e"
}
{
    "label" : "shutdown",
    "action" : "systemctl poweroff",
    "text" : "Shutdown",
    "keybind" : "s"
}
{
    "label" : "suspend",
    "action" : "systemctl suspend",
    "text" : "Suspend",
    "keybind" : "u"
}
{
    "label" : "reboot",
    "action" : "systemctl reboot",
    "text" : "Reboot",
    "keybind" : "r"
}
    	'';
    	".config/wlogout/layout".force = true;
    	})

    	(lib.mkIf config.wlogout.enableUserConfig {
    	".config/wlogout/style.css".text = ''
* {
	background-image: none;
	box-shadow: none;
}

window {
	background-color: rgba(12, 12, 12, 0.9);
}

button {
    border-radius: 0;
    border-color: black;
	text-decoration-color: #FFFFFF;
    color: #FFFFFF;
	background-color: #1E1E1E;
	border-style: solid;
	border-width: 1px;
	background-repeat: no-repeat;
	background-position: center;
	background-size: 25%;
}

button:focus, button:active, button:hover {
	background-color: #3700B3;
	outline-style: none;
}

#lock {
    background-image: image(url("/etc/nixos/shared_configs/user/wlogout/icons/lock.png"));
}

#logout {
    background-image: image(url("/etc/nixos/shared_configs/user/wlogout/icons/logout.png"));
}

#suspend {
    background-image: image(url("/etc/nixos/shared_configs/user/wlogout/icons/suspend.png"));
}

#hibernate {
    background-image: image(url("/etc/nixos/shared_configs/user/wlogout/icons/hibernate.png"));
}

#shutdown {
    background-image: image(url("/etc/nixos/shared_configs/user/wlogout/icons/shutdown.png"));
}

#reboot {
    background-image: image(url("/etc/nixos/shared_configs/user/wlogout/icons/reboot.png"));
}
    	'';
    	".config/wlogout/style.css".force = true;
    	})
    ];
  };
}
