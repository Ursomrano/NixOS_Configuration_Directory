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
  host = "HOSTNAME_PLACEHOLDER";
in

{
  imports =
    [
      # --- Host-specific system config ---
      ./${host}_configs/default.nix
      ./${host}_configs/hardware-configuration.nix

      # --- Host-specific user tweaks ---
      ./${host}_configs/user/hyprland.nix
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
		systemd-boot.configurationLimit = 5;
		grub = {
			enable = true;
			device = "nodev";
			efiSupport = true;
			useOSProber = true;
		};
		efi.canTouchEfiVariables = true;
		efi.efiSysMountPoint = "/boot";
	};
  	kernelModules = [ "hid-playstation" "hid-nintendo" ];
  	kernelPackages = pkgs.linuxPackages_xanmod_latest;
	blacklistedKernelModules = [];
	initrd.kernelModules = [ "nvidia" "nvidia_uvm" ];
  };
  # System
  system = {
  	autoUpgrade = {
		enable = true;
		dates = "weekly";
		operation = "switch";
		allowReboot = true;
	};
  	stateVersion = "26.05";
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
    extraGroups = [ "seat" "networkmanager" "wheel" "input" "plugdev"];
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
  services.blueman.enable = true;
  services.resolved.enable = true;
  services.flatpak.enable = true;
  #user and auto login
  services.getty.autologinUser = "ursomrano71";
  services.seatd.enable = true;
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
  services.udev.extraRules = ''
  	ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="on"
	ACTION=="add", SUBSYSTEM=="pci", ATTR{power/control}="on"
  '';

  security.rtkit.enable = true;

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
  	hyprland = {enable = true; xwayland.enable = true; withUWSM = true;};
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
   			"PROMPT=$'[%n@ 󰇅]{ %~ }\\n> '"
  		];
	};
	waybar.enable = true;
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
  	home.stateVersion = "25.11";
	nixpkgs.config.allowUnfree = true;
	systemd.user.startServices = "sd-switch";
	home.packages = with pkgs; [
		libreoffice-fresh
		tetris
		_2048-in-terminal
	];
	programs = {
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
  	lshw
  	bolt	

  	# --- Toolchain / core utilities ---
  	gcc
  	git
  	tree
  	unzip
	mediainfo
	gparted-full
	python315
	nodejs_25
	rustc
	cargo
	gemini-cli
	ollama-cuda
	#aider-chat
	valgrind-light
	flac
	sox

	# --- LSP/Language Servers/Dictionaries ---
	bash-language-server
  	clang-tools
  	omnisharp-roslyn
  	pyright
  	ruff
  	rust-analyzer
  	svls
	hunspellDicts.en_US

  	# --- Graphics stack / compositor ---
  	hyprland
  	hyprpaper

  	# --- Desktop environment components ---
  	waybar
  	wofi
  	mako
  	libnotify
  	pavucontrol
	brightnessctl

  	# --- Terminals / editors ---
  	alacritty
  	neovim

  	# --- System info / performance / gaming helpers ---
  	gamemode
  	mangohud
  	fastfetch
	
  	# --- File management ---
  	thunar

  	# --- Media / runtime compatibility ---
  	wine
	wine64
  	mpv
	eden

  	# --- Networked / online applications ---
	brave
  	discord
	qbittorrent
	nicotine-plus
	proton-vpn

  	# --- Gaming / launchers ---
  	prismlauncher

  	# --- Custom system maintenance ---
  	(writeShellScriptBin "nixos-update" ''
    		#!/bin/sh
    		set -euf
    		nixos-rebuild boot --upgrade
    		nix-store --optimise -v
    		nix-collect-garbage -d
  	'')
  ];
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

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
