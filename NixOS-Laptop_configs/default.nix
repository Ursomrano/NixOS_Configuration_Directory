{ config, lib, pkgs, ... }:

with lib;

{
  options.laptop.enable = mkOption {
    type = types.bool;
    default = true;
    description = "Enable laptop-specific configuration (GPU, power, thunderbolt, etc.)";
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

    # KERNEL POWER BASELINE
    boot.kernel.sysctl = {
      "dev.power.dpm" = "performance";
    };

    # THUNDERBOLT
    services.hardware.bolt.enable = true;

    # TLP
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

        RUNTIME_PM_ON_AC = "off";
        RUNTIME_PM_ON_BAT = "auto";

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

    #EXPLICIT BATTERY AND PERFORMANCE MODE SYSTEM
    systemd.services.laptop-mode-battery = {
      description = "Laptop Battery Mode";
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";

      script = ''
        echo low-power > /sys/firmware/acpi/platform_profile 2>/dev/null || true

        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
          echo powersave > $cpu 2>/dev/null || true
        done

        echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || true
        echo 0 > /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || true
      '';
    };

    systemd.services.laptop-mode-performance = {
      description = "Laptop Performance Mode";
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";

      script = ''
        echo performance > /sys/firmware/acpi/platform_profile 2>/dev/null || true

        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
          echo performance > $cpu 2>/dev/null || true
        done

        echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || true
        echo 1 > /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || true
      '';
    };
    # USER-FACING SWITCH COMMAND
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "laptop-mode" ''
        case "$1" in
          battery)
            systemctl start laptop-mode-battery
            ;;
          performance)
            systemctl start laptop-mode-performance
            ;;
          *)
            echo "Usage: laptop-mode [battery|performance]"
            ;;
        esac
      '')
    ];

    # YOUR EXISTING DYNAMIC CHARGING
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

    # ----------------------------
    # KERNEL MODULES / PARAMS (UNCHANGED)
    # ----------------------------
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
