# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  unstable = import <nixos> {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
  pkgs = unstable;
  flakeLib = import ./shared_configs/flake-helper.nix pkgs;
  inherit (flakeLib) flake flakeBranch flakeSubpath;
  host = "HOSTNAME_PLACEHOLDER";
  hostIcon = if host == "NixOS-Laptop" then " " else "󰇅";
in
{
  imports =
    [
      # --- Host-specific system config ---
      ./${host}_configs/default.nix
      ./${host}_configs/hardware-configuration.nix
      # --- Host-specific user tweaks ---
      # ./${host}_configs/user/hyprland.nix
      (if host == "NixOS-Laptop" then ./NixOS-Laptop_configs/user/hyprland_laptop.nix else ./NixOS-PC_configs/user/hyprland_pc.nix)
      ./shared_configs/user/hyprland_shared.nix
      ./${host}_configs/user/mangohud.nix
      ./${host}_configs/user/waybar/waybar.nix

      # --- Shared user configs ---
      ./shared_configs/user/alacritty.nix
      ./shared_configs/user/flatpak.nix
      ./shared_configs/user/hyprpaper.nix
      ./shared_configs/user/mpv.nix
      ./shared_configs/user/pipewire.nix
      ./shared_configs/user/wlogout/wlogout.nix


      <home-manager/nixos>
    ];

  # Boot and Kernel.
  boot = {
  	loader = {
		systemd-boot.enable = false;
		systemd-boot.configurationLimit = 3;
		grub = {
			enable = true;
			device = "nodev";
			efiSupport = true;
			useOSProber = true;
			configurationLimit = 3;
		};
		efi.canTouchEfiVariables = true;
		efi.efiSysMountPoint = "/boot";
	};
  	kernelModules = [ "hid-playstation" "hid-nintendo" ];
  	kernelPackages = pkgs.linuxPackages_xanmod_latest;
	blacklistedKernelModules = [];
	initrd.kernelModules = [ "nvidia" "nvidia_uvm" ];
  };

  # Mount /tmp in RAM.
  fileSystems."/tmp" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "size=512M" "mode=1777" ];
  };

  # Don't limit Nix build sandboxes to the 512M /tmp tmpfs. Build them in
  # /var/tmp instead (on disk; cleaned by systemd-tmpfiles after 30 days).
  systemd.services.nix-daemon.environment.TMPDIR = "/var/tmp";

  # System
  system = {
  	autoUpgrade = {
		enable = true;
		dates = "weekly";
		operation = "switch";
		allowReboot = false;
	};
  	stateVersion = "26.11";
  };

  # Define your hostname.(defined in laptop.nix)
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.resolvconf.dnsExtensionMechanism = false;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  # Set your time zone.
  time.timeZone = "America/Phoenix";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Users
  users.users.ursomrano71 = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Ursomrano71";
    extraGroups = [ "networkmanager" "wheel" "input" "plugdev" "dialout"];
    packages = with pkgs; [];
  };

  # Services
  services.scx.scheduler = "scx_bpfland";
  systemd.services.bpfland = {
  	description = "Attach bpfland scheduler";
  	after = [ "network.target" ];
 	wantedBy = [ "multi-user.target" ];
  	serviceConfig = {
    		Type = "simple";
   	 	ExecStart = "${pkgs.scx.rustscheds}/bin/scx_bpfland";
    		Restart = "always";
  	};
  };
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  services.colord.enable = true;
  services.blueman.enable = true;
  services.resolved.enable = true;
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  services.udisks2.enable = true;

  #user and auto login
  # services.getty.autologinUser = "ursomrano71";
  services.seatd.enable = false;
  services.greetd = {
	enable = true;
	settings.default_session.command = "start-hyprland";
	settings.default_session.user = "ursomrano71";
  };  
  #audio
  services.pipewire = {
	enable = true;
	alsa.enable = true;
	alsa.support32Bit = true;
	pulse.enable = true;	
	jack.enable = true;
  };
  services.pulseaudio.enable = false;

  security.rtkit.enable = true;
  security.polkit.enable = true;

  # Allow unfree packages
  nixpkgs.config = {
  	allowUnfree = true;
	cudaSupport = true;
  };
  nix = {
  	settings = {
		auto-optimise-store = true;
		experimental-features = [ "nix-command" "flakes" ];
		substituters = [ "https://cache.nixos-cuda.org" ];
 		trusted-public-keys = [ "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=" ];
	};
	gc = {
		automatic = true;
		dates = "daily";
		# Prune old generations so old kernels/initrds get cleaned
		# out of /boot instead of accumulating until it overflows.
		# Keeps the current generation + 2 previous ones for rollback.
		options = "--delete-generations +3";
	};
  };

  # Graphics Drivers
  hardware.graphics = {enable = true;};
  hardware.bluetooth.enable = true;

  hardware.rtl-sdr.enable=true;
  hardware.xpadneo.enable = true;

  fonts.packages = with pkgs; [
	font-awesome
	nerd-fonts.symbols-only
	nerd-fonts.sauce-code-pro
	corefonts
	noto-fonts-cjk-sans
  ];

  programs = {
  	nix-ld.enable = true;
  	hyprland = {
		enable = true;
		xwayland.enable = true;
		withUWSM = true;
		# Use the stock package so it's substitutable from the binary cache.
		# The selector will also show a redundant "Hyprland (uwsm-managed)"
		# entry; both entries run hyprland under UWSM, so it's harmless.
	};
	zsh = {
		enable = true;
		autosuggestions.enable = true;
		syntaxHighlighting.enable = true;
		ohMyZsh = {
			enable = true;
			plugins = ["sudo" "history-substring-search" "z" "command-not-found"];
		};
		interactiveShellInit = builtins.concatStringsSep "\n" [
    			"fastfetch"
    			# Use $'...' so the shell will interpret \n as newline
   			"PROMPT=$'[%n@ ${hostIcon}]{ %~ }\\n> '"
  		];
	};
	steam = {
		enable = true;
		remotePlay.openFirewall = true;
		dedicatedServer.openFirewall = true;
		gamescopeSession.enable = true;
		extraCompatPackages = with pkgs; [
			proton-ge-bin
		];
	};
  };
  home-manager.users.ursomrano71 = {
  	home.stateVersion = "26.05";
	nixpkgs.config.allowUnfree = true;
	systemd.user.startServices = "sd-switch";
	home.packages = with pkgs; [
		libreoffice-stable
	];
	home.file = {
		"Documents/Programs/SystemVerilog/.envrc".text = "use flake /etc/nixos/devshells#systemverilog\n";
		"Documents/Programs/C++/.envrc".text = "use flake /etc/nixos/devshells#cpp\n";
  		"Documents/Programs/Shell/.envrc".text = "use flake /etc/nixos/devshells#audio\n";
  		"Documents/Programs/CUDA/.envrc".text = "use flake /etc/nixos/devshells#cuda\n";
	};
	programs = {
		direnv = {
			enable = true;
			nix-direnv.enable = true;
			enableZshIntegration = true;
		};
		home-manager.enable = true;
		wlogout = {enable = true;};
		retroarch = {
			enable = true;
			cores = {
				fbneo.enable = false;
				melonds.enable = true;
				mgba.enable = true;
			};
			settings = {
				video_driver = "vulkan";
			};
		};
	};
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  	# --- Kernel / scheduling / low-level system ---
  	scx.rustscheds
  	nix-ld

  	# --- Toolchain / core utilities ---
  	gcc
	gnumake
  	git
  	tree
	unar
	mediainfo
	python315
	nodejs
	rustc
	cargo
	opencode	

	# --- LSP/Language Servers/Dictionaries ---
	bash-language-server
  	clang-tools
  	omnisharp-roslyn
  	pyright
  	ruff
  	rust-analyzer
	hunspellDicts.en_US

	# --- Graphics stack / compositor ---
	hyprland
	hyprpaper
	hyprpolkitagent

  	# --- Desktop environment components ---
  	waybar
  	wofi
  	mako
  	libnotify
  	pavucontrol
	brightnessctl
  	grim
  	slurp
  	swappy
	wl-clipboard
	blueman

  	# --- Terminals / editors ---
  	alacritty
  	neovim
	obs-studio
	blender

  	# --- System info / performance / gaming helpers ---
  	gamemode
  	mangohud
  	fastfetch
	
   	# --- File management ---
   	thunar
	tumbler
	udisks2

  	# --- Media / runtime compatibility ---
	wineWow64Packages.stable
  	mpv
	fooyin

  	# --- Networked / online applications ---
  	discord-canary
	qbittorrent
	nicotine-plus
	proton-vpn

  	# --- Gaming / launchers ---
  	prismlauncher

  	# --- Flake-sourced packages ---
  	(flake "youwen5/zen-browser-flake")

  	# --- Custom system maintenance ---
  	(writeShellScriptBin "nixos-update" ''
    		#!/bin/sh
    		set -euf
    		nixos-rebuild boot --upgrade
    		nix-store --optimise -v
     		nix-collect-garbage
  	'')
  ];
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  #networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
}
