# /etc/nixos/laptop.nix
{ config, lib, pkgs, ... }:

with lib;

{
	# Define an option to enable/disable the laptop module
	options.laptop.enable = mkOption {
		type = types.bool;
    		default = true;
    		description = "Enable laptop-specific configuration (GPU, power, thunderbolt, etc.)";
  	};

	config = mkIf config.laptop.enable {
		networking.hostName = "NixOS-Laptop";

		nix.settings.max-jobs = 4;
		
    		# X server and Nvidia settings
    		services.xserver.videoDrivers = [ "modesetting" "nvidia" ];
	
    		hardware.nvidia = {
      			modesetting.enable = true;
      			open = false;
      			nvidiaSettings = true;
			powerManagement.enable = true;
			powerManagement.finegrained = true;
			nvidiaPersistenced = true;
			dynamicBoost.enable = true;
      			package = config.boot.kernelPackages.nvidiaPackages.beta;
      			prime = {
        			intelBusId = "PCI:0:2:0";
        			nvidiaBusId = "PCI:1:0:0";
        			offload = {
          				enable = true;
          				enableOffloadCmd = true;
        			};
      			};
    		};
		
		boot.kernel.sysctl = {
			"dev.power.dpm" = "performance";
		};
		systemd.services.setPlatformProfile = {
  			wantedBy = [ "multi-user.target" ];
  			serviceConfig.ExecStart = ''
    				/run/current-system/sw/bin/bash -c "echo performance > /sys/firmware/acpi/platform_profile"
  			'';
		};
		systemd.services.force-performance-profile = {
  			description = "Force ACPI platform profile to performance";
  			wantedBy = [ "multi-user.target" ];
  			serviceConfig.ExecStart = ''
    				/bin/sh -c "echo performance | tee /sys/firmware/acpi/platform_profile"
  			'';
		};

    		# Thunderbolt support
    		services.hardware.bolt.enable = true;

    		services.tlp = {
  			enable = true;
  			settings = {
    				CPU_SCALING_GOVERNOR_ON_AC = "performance";
    				CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    				CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
    				CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

    				CPU_MIN_PERF_ON_AC = 0;
    				CPU_MIN_PERF_ON_BAT = 0;
    				CPU_MAX_PERF_ON_AC = 100;
    				CPU_MAX_PERF_ON_BAT = 40;

    				# Let PCIe devices runtime PM on AC
    				RUNTIME_PM_ON_AC = "off";
    				RUNTIME_PM_ON_BAT = "auto";

    				# Prevent throttling NVIDIA GPU
    				RUNTIME_PM_BLACKLIST = "0000:01:00.0";

    				SATA_LINKPWR_ON_AC = "medium_power";
   	 			SATA_LINKPWR_ON_BAT = "min_power";

    				NVME_APST_ON_BAT = 1;
    				NVME_APST_ON_AC  = 1;

    				WIFI_PWR_ON_AC = "off";
    				WIFI_PWR_ON_BAT = "on";
  			};
		};
		powerManagement.powertop.enable = false;
		systemd.services.dynamic-charging = {
  			description = "Dynamic TLP battery threshold based on temperature";
  			after = [ "multi-user.target" ];
  			serviceConfig = {
    				Type = "oneshot";
    				ExecStart = "/etc/nixos/NixOS-Laptop_configs/dynamic_charging.sh";
  			};
  			wantedBy = [ "multi-user.target" ];
		};
		systemd.timers.dynamic-charging = {
  			description = "Run TLP temperature-based threshold every 2.5 minutes";
  			wantedBy = [ "timers.target" ];
  			timerConfig = {
    				OnBootSec = "1min";
    				OnUnitActiveSec = "2min";
  			};
		};

    # Kernel modules for initrd
    boot = {
    	initrd.availableKernelModules = [ "thunderbolt" "ucsi_acpi" "typec" ];
	kernelParams = [
		"usbcore.autosuspend=-1"
		"drm.atomic=1"
		"split_lock_detect=off"
		"i915.enable_psr=0"
	];
    };
  };
}

