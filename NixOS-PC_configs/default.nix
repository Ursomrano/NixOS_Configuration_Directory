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

		# Add our own wayland-sessions desktop file for MangoWM (with the
		# Vulkan/scene env prefix) so UWSM's `start select` offers it and
		# launches mango with HDR-capable rendering. Strip the package's
		# own mango.desktop so ours wins in the profile merge.
		environment.systemPackages = with pkgs; [
			(mango.overrideAttrs (o: {
				postInstall = (o.postInstall or "") + ''
				rm -f $out/share/wayland-sessions/mango.desktop
				'';
			}))
			(writeTextDir "share/wayland-sessions/mango.desktop" ''
			[Desktop Entry]
			Type=Application
			Name=MangoWM
			Comment=Mango Wayland compositor (dwl/wlroots + scenefx)
			Exec=env WLR_RENDERER=vulkan WLR_SCENE_DISABLE_DIRECT_SCANOUT=1 mango
			'')
		];

		home-manager.users.ursomrano71.home.file.".config/mango/config.conf" = {
			source = ./user/mango.conf;
			force = true;
		};
	};
}