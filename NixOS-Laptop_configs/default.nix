{ config, lib, pkgs, ... }:

with lib;

{
  options.laptop.enable = mkOption {
    type = types.bool;
    default = true;
    description = "Enable laptop-specific configuration";
  };

  config = mkIf config.laptop.enable {

    networking.hostName = "NixOS-Laptop";
    nix.settings.max-jobs = 4;

    environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

    # GPU CONFIG
    services.xserver.videoDrivers = [ "modesetting" "nvidia" ];
    hardware= {
    	graphics = {
		enable = true;
		enable32Bit = true;
		extraPackages = with pkgs; [ intel-media-driver ];
	};
    	nvidia = {
      		modesetting.enable = true;
      		open = false;
      		nvidiaSettings = true;

      		powerManagement.enable = true;
      		powerManagement.finegrained = true;
      		nvidiaPersistenced = true;
      		dynamicBoost.enable = true;
      		videoAcceleration = true;

      		package = config.boot.kernelPackages.nvidiaPackages.latest;

      		prime = {
        		intelBusId = "PCI:0:2:0";
        		nvidiaBusId = "PCI:1:0:0";
        		offload = {
          			enable = true;
          			enableOffloadCmd = true;
        		};
      		};
    	};
    };

    # POWER BASELINE
    boot.kernel.sysctl = {
      "dev.power.dpm" = "performance";
    };

    services.hardware.bolt.enable = true;

    # TLP
    services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        RUNTIME_PM_ON_AC = "off";
        RUNTIME_PM_ON_BAT = "auto";

        SATA_LINKPWR_ON_AC = "medium_power";
        SATA_LINKPWR_ON_BAT = "min_power";

        NVME_APST_ON_AC = 1;
        NVME_APST_ON_BAT = 1;
      };
    };

    powerManagement.powertop.enable = false;

    # POWER PROFILES
    systemd.tmpfiles.rules = [
      "w /sys/firmware/acpi/platform_profile - - - - quiet"
      "z /sys/firmware/acpi/platform_profile 0664 root wheel - -"
    ];

    # USER COMMAND
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "laptop-mode" ''
        case "$1" in
          battery)
            echo quiet > /sys/firmware/acpi/platform_profile
            ;;
          balanced)
            echo balanced > /sys/firmware/acpi/platform_profile
            ;;
          performance)
            echo performance > /sys/firmware/acpi/platform_profile
            ;;
          *)
            echo "Usage: laptop-mode [battery|balanced|performance]"
            echo "Current mode: $(cat /sys/firmware/acpi/platform_profile)"
            ;;
        esac
      '')
    ];

    # KERNEL / BOOT
    boot.kernelParams = [
      "usbcore.autosuspend=-1"
      "drm.atomic=1"
      "split_lock_detect=off"
      "i915.enable_psr=0"
    ];
    boot.initrd.availableKernelModules = [
      "thunderbolt"
      "ucsi_acpi"
      "typec"
    ];

    # PRINTER
    services.printing = {
	enable = true;
	browsed.enable=false;
    };
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    services.ipp-usb.enable = false;
    services.printing.drivers = [
      pkgs.cups-filters
      #pkgs.cups-browsed
      pkgs.canon-cups-ufr2
    ];
  };
}

