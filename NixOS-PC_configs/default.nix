{ config, lib, pkgs, ... }:

with lib;

{
	# Define an option to enable/disable the laptop module
	options.PC.enable = mkOption {
		type = types.bool;
    		default = true;
    		description = "Enable PC-specific configuration (GPU, etc.)";
  	};

	config = mkIf config.PC.enable {
    networking.hostName = "NixOS-PC";
		environment.sessionVariables.LIBVA_DRIVER_NAME = "nvidia";

    # X server and Nvidia settings
    services.xserver= {
			videoDrivers = [ "nvidia" "modesetting"];
		};
		hardware = {
			nvidia = {
				open = true;
				modesetting.enable = true;
      	nvidiaSettings = true;
				nvidiaPersistenced = true;
      	package = config.boot.kernelPackages.nvidiaPackages.latest;
				videoAcceleration = true;
			};
			graphics = {
				enable = true;
				enable32Bit = true;
			};
		};
    		# Kernel modules for initrd
    boot = {
    	initrd.availableKernelModules = [ "thunderbolt" "ucsi_acpi" "typec" ];
kernelParams = [
  				"usbcore.autosuspend=-1"
  				"nvidia_drm.modeset=1"
  				"amd_pstate=active"
			];		
		};

		# --- MangoWM: alternative HDR-capable compositor (PC only) ---
		environment.systemPackages = with pkgs; [
			mango
			regreet
			(writeTextDir "share/wayland-sessions/mango.desktop" ''
				[Desktop Entry]
				Type=Application
				Name=MangoWM
				Comment=Mango Wayland compositor (dwl/wlroots + scenefx)
				Exec=mango
			'')
		];

		home-manager.users.ursomrano71.home.file.".config/mango/config.conf" = {
			text = ''
				env=WLR_RENDERER,vulkan

				# PC: single HDR monitor exposed as DP-1/DP-4 between boots,
				# so match any DP-* output to keep 280Hz/HDR/VRR consistent.
				monitorrule=name:^DP-,width:2560,height:1440,refresh:280,x:0,y:0,scale:1,vrr:1,hdr:1,hdr_force:1,hdr_max_lum:400,hdr_max_avg_lum:400

				# Starter keybinds (customize freely)
				bind=Alt,Return,spawn,alacritty
				bind=Alt,Space,spawn,wofi --show drun
				bind=Alt,q,killclient
				bind=SUPER,m,quit
			'';
			force = true;
		};
	};
}
