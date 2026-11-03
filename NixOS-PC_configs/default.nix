# PC-specific configuration
{ config, lib, pkgs, ... }:

with lib;

{
	options.PC.enable = mkOption {
		type = types.bool;
		default = true;
		description = "Enable PC-specific configuration (GPU, etc.)";
	};

	config = mkIf config.PC.enable {
		networking.hostName = "NixOS-PC";
		environment.sessionVariables.LIBVA_DRIVER_NAME = "nvidia";

		# X server and Nvidia settings
		services.xserver = {
			videoDrivers = [ "nvidia" "modesetting" ];
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

		# 1TB music drive (exFAT "exFAT_Part") for the SUPER+M fooyin keybind. In fstab, not udisksctl:
		# with no auth agent installed udisks2 hangs forever. By UUID, in-kernel exfat (not the old NTFS /dev/sdb1).
		boot.kernelModules = [ "exfat" ];
		fileSystems."/run/media/ursomrano71/exFAT_Part" = {
			device = "/dev/disk/by-uuid/78E6-E813";
			fsType = "exfat";
			options = [
				"uid=1000"
				"gid=100"
				"umask=0022"
				"users"
				"nofail"
				"noatime"
				"x-systemd.device-timeout=10s"
			];
		};

		# PC-only packages
		home-manager.users.ursomrano71 = {
			home.packages = with pkgs; [
				(pkgs.writeShellScriptBin "blender" ''
            				export WAYLAND_DISPLAY=0
            				exec ${pkgs.blender}/bin/blender "$@"
        			'')				
				whipper
			];
		};
		environment.systemPackages = with pkgs; [
  			#stuff		
		];
	};
}
