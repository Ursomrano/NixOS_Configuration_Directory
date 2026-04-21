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

    # GPU CONFIG
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
    systemd.services.laptop-mode-battery = {
      description = "Laptop Battery Mode";
      wantedBy = [ "multi-user.target" ];
      after = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";

      script = ''
        echo quiet > /sys/firmware/acpi/platform_profile 2>/dev/null || true
      '';
    };

    systemd.services.laptop-mode-performance = {
      description = "Laptop Performance Mode";
      serviceConfig.Type = "oneshot";

      script = ''
        echo performance > /sys/firmware/acpi/platform_profile 2>/dev/null || true
      '';
    };

    systemd.services.laptop-mode-balanced = {
      description = "Laptop Balanced Mode";
      serviceConfig.Type = "oneshot";

      script = ''
        echo balanced > /sys/firmware/acpi/platform_profile 2>/dev/null || true
      '';
    };

    # USER COMMAND
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "laptop-mode" ''
        case "$1" in
          battery)
            systemctl start laptop-mode-battery
            ;;
          balanced)
            systemctl start laptop-mode-balanced
            ;;
          performance)
            systemctl start laptop-mode-performance
            ;;
          *)
            echo "Usage: laptop-mode [battery|balanced|performance]"
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
  };
}
