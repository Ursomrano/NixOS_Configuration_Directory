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
      	package = config.boot.kernelPackages.nvidiaPackages.beta;
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
	};
}
