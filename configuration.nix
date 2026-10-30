# Defines what gets installed on this system. See the configuration.nix(5) man
# page and the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:
let
  unstable = import <nixos> {
    system = "x86_64-linux";
    config.allowUnfree = true;
    config.cudaSupport = true;
  };
  pkgs = unstable;
  flakeLib = import ./shared_configs/flake-helper.nix pkgs;
  inherit (flakeLib) flake flakeBranch flakeSubpath;

  # --- direnv: per-directory tool lists, see ./${host}_configs/user/directory_packages.nix ---
  # Generated .envrc files -- don't hand-edit them.
  directoryPackages = import ./${host}_configs/user/directory_packages.nix;

  # Checked here so a typo fails at activation, not on the next cd. Returns the
  # name unchanged; these are interpolated as text, not as derivations.
  checkPkg = name:
    builtins.seq (pkgs.lib.foldl' (
      attrs: attr:
        if attrs ? ${attr} then attrs.${attr}
        else throw "directory_packages.nix: no nixpkgs attribute '${name}'"
    ) pkgs (pkgs.lib.splitString "." name)) name;

  # `flake` opts a directory into a pinned devShell (CUDA); `hook` is for extra
  # .envrc lines a plain package list can't express.
  mkEnvrc = { packages ? [], flake ? null, hook ? "" }:
    if flake != null then ''
      use flake ${flake}
    ''
    else ''
      use nix -p ${pkgs.lib.concatStringsSep " " (map checkPkg packages)}
      ${hook}
    '';

  # NB: the key MUST be "<dir>/.envrc". With just "<dir>", home-manager writes
  # the contents to that path and moves the real directory to *.backup.
  envrcFiles = pkgs.lib.mapAttrs' (dir: spec: {
    name = "${dir}/.envrc";
    value.text = mkEnvrc spec;
  }) directoryPackages;
  # Apple USB SuperDrive (05ac:1500) wake helper: reports no medium until it gets one vendor
  # SCSI command, `EA 00 00 00 00 00 01`, once per power-on before disc insert. Usage: superdrive-arm 3-3
  superdriveArm = pkgs.writeShellScript "superdrive-arm" ''
    set -u
    usbdev="''${1:-}"
    sg_raw="${pkgs.sg3_utils}/bin/sg_raw"

    # The scsi host is parented by the USB *interface* (e.g. 3-3:1.0), not by the
    # USB device itself, so glob the interface nodes.
    for _ in $(seq 1 30); do
      for node in /sys/bus/usb/devices/"$usbdev":*/host*/target*/*/block/sr*; do
        [ -e "$node" ] || continue
        dev="/dev/$(basename "$node")"
        if "$sg_raw" "$dev" EA 00 00 00 00 00 01 >/dev/null 2>&1; then
          echo "superdrive: armed $dev"
          exit 0
        fi
      done
      sleep 1
    done

    echo "superdrive: no sr node found for USB device '$usbdev'" >&2
    exit 1
  '';

  nixcordSrc = builtins.fetchTarball "https://github.com/4evy/nixcord/archive/main.tar.gz";
  nixcord = import nixcordSrc { inherit pkgs; };

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
      nixcord.nixosModules.nixcord
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

  # A crash-looping helper (nvidia-smi spat out ~24k cores) shouldn't be able
  # to fill the disk; systemd-coredump vacuums old dumps above this.
  systemd.coredump.settings.Coredump.MaxUse = "128M";

  # Keep the bar alive: waybar's PulseAudio backend aborts with an uncaught
  # exception when pipewire is restarted underneath it (e.g. during a switch).
  #
  # NixOS gives user units a minimal default PATH (coreutils, findutils, grep,
  # sed, systemd). Waybar spawns `on-click` through `sh -c` and inherits it, so
  # every click action that isn't an absolute path -- wlogout, wofi, pavucontrol,
  # wl-copy, ip -- failed with "command not found". Hand the unit the same
  # profile dirs a normal login session has.
  systemd.user.services.waybar = {
    description = "Waybar";    
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    path = [
      "/run/current-system/sw"
      config.home-manager.users.ursomrano71.home.profileDirectory
    ];
    serviceConfig = {
      ExecStart = "${pkgs.waybar}/bin/waybar";
      Restart = "on-failure";
      RestartSec = 2;
    };
  };

  # System
  system = {
  	autoUpgrade = {
		enable = true;
		# "weekly" resolves to Mon 00:00; with Persistent=true the missed run
		# fires on the first boot of the week, dragging a full nixos-rebuild
		# (several GB of nix-build) into the login. Run at a quiet hour and
		# skip the week instead of catching up at boot.
		dates = "Sun 04:00";
		randomizedDelaySec = "1h";
		persistent = false;
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
    extraGroups = [ "networkmanager" "wheel" "input" "plugdev" "dialout" "cdrom" ];
    packages = with pkgs; [];
  };

  # Services
  services.scx = {
  	enable = true;
  	scheduler = "scx_bpfland";
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
  services.ollama = {
  	enable = true;
  	package = pkgs.ollama-cuda;
  	loadModels =
      if host == "NixOS-Laptop"
      then [ "qwen3.5:9b" ]
      else [ "qwen3-coder:30b" ];
  	environmentVariables = {
    		OLLAMA_CONTEXT_LENGTH =
        if host == "NixOS-Laptop" then "16384" else "32768";
  	};
  };

  #user and auto login
  # services.getty.autologinUser = "ursomrano71";
  services.seatd.enable = false;
  services.greetd = {
	enable = true;
	settings.default_session.command = "${pkgs.uwsm}/bin/uwsm start -e -D Hyprland /run/current-system/sw/share/wayland-sessions/hyprland.desktop";
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
		# Prune old generations so old kernels/initrds don't accumulate in /boot.
		# Keeps the current generation + 2 previous ones for rollback.
		options = "--delete-generations +3";
	};
  };

  # Graphics Drivers
  hardware.graphics = {enable = true;};
  hardware.bluetooth.enable = true;

  hardware.rtl-sdr.enable=true;
  hardware.xpadneo.enable = true;

  # --- Apple USB SuperDrive ---
  # Armed once per plug-in/boot; see `superdriveArm` above. udev-triggered, not
  # RUN+=, so systemd waits for the sr node instead of racing it.
  systemd.services."superdrive-arm@" = {
    description = "Arm Apple USB SuperDrive (%i)";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${superdriveArm} %i";
    };
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="05ac", ATTR{idProduct}=="1500", TAG+="systemd", ENV{SYSTEMD_WANTS}+="superdrive-arm@%k.service"
  '';

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
		# Stock package so it's substitutable from the binary cache. The selector also
		# shows a redundant "Hyprland (uwsm-managed)" entry; both run under UWSM.
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
	nixcord = {
  		enable = true;
  		user = "ursomrano71";
  		config = {
    			themeLinks = [ "https://refact0r.github.io/system24/build/system24.css" ];
  		};
  		extraConfig = {
    			enabledThemeLinks = [ "https://refact0r.github.io/system24/build/system24.css" ];
    			enableOnlineThemes = true;
  		};
  		discord.equicord.enable = true;
	};  

};
  # Don't hard-fail activation on pre-existing dotfiles; move them to *.backup.
  home-manager.backupFileExtension = "backup";
  home-manager.users.ursomrano71 = {
  	home.stateVersion = "26.05";
	nixpkgs.config.allowUnfree = true;
	# direnv's `use nix` imports <nixpkgs> itself, so it does not inherit
	# nixpkgs.config above -- nix reads this user-level file instead.
	xdg.configFile."nixpkgs/config.nix".text = "{ allowUnfree = true; }\n";
	systemd.user.startServices = "sd-switch";
	home.packages = with pkgs; [
		libreoffice-stable
	];
	home.file = envrcFiles;
	programs = {
		# programs.direnv's hook goes via zsh.initExtra, dropped unless zsh is enabled.
		zsh.enable = true;
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
	sg3_utils
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

	# --- System info / performance / gaming helpers ---
  	gamemode
  	mangohud
  	fastfetch
  	btop
	nvtopPackages.nvidia
	
   	# --- File management ---
   	thunar
	tumbler
	udisks2

  	# --- Media / runtime compatibility ---
	wineWow64Packages.stable
  	mpv
	fooyin

  	# --- Networked / online applications ---
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
     		nix-collect-garbage --delete-older-than 30d
  	'')
  ];
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    # Let apps (notably OBS's NVENC/QuickSync/VAAPI) find the driver libraries.
    LD_LIBRARY_PATH = [ "/run/opengl-driver/lib" ];
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

  # Release this system was installed on: sets defaults for stateful data (file
  # locations, db versions). Read `man configuration.nix` before changing it.
}
