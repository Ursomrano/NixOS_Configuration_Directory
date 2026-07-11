{ config, pkgs, lib, ... }:

let
  user = "ursomrano71";
in
{
  options = {
    mpv.enableUserConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to deploy the declarative mpv.conf for the user";
    };
  };

  config = lib.mkIf config.mpv.enableUserConfig { 
    # Deploy the full mpv.conf
    home-manager.users.${user}.home.file = {
    ".config/mpv/mpv.conf".text = ''
############################
# GLOBAL
############################

vo=gpu-next
gpu-api=vulkan
profile=high-quality
hwdec=auto-safe
framedrop=vo

# Smooth A/V sync on high refresh rate displays
video-sync=display-resample
interpolation=no

############################
# AUDIO (PIPEWIRE, STABLE HDMI)
############################
ao=pipewire
audio-device=pipewire

# Slightly larger buffer to prevent pops on 4K120 HDR HDMI
audio-buffer=0.3
audio-resample-filter-size=32
audio-resample-phase-shift=10

############################
# VIDEO SCALING
############################

scale=ewa_lanczos
cscale=ewa_lanczos
dscale=mitchell

correct-downscaling=yes
sigmoid-upscaling=yes

############################
# HDR / COLOR
############################

target-colorspace-hint=yes
icc-profile-auto=yes
tone-mapping=hable
hdr-compute-peak=yes
hdr-peak-percentile=100
target-peak=auto


############################
# PROFILES
############################

[music]
audio-channels=stereo
audio-normalize-downmix=yes
hwdec=no
video-sync=audio
audio-buffer=1.0
pipewire-buffer=64
video=auto
image-display-duration=inf
replaygain=album
hdr-compute-peak=no
target-colorspace-hint=no
target-peak=auto
tone-mapping=clip
vo=gpu-next
gpu-api=vulkan

[movie]
video-sync=display-resample
audio-buffer=0.5
audio-normalize-downmix=no
    '';
    ".config/mpv/mpv.conf".force = true;
    };
  };
}
