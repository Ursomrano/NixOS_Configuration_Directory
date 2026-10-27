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
# DVD / DISC
############################

# Linux default is /dev/sr0; explicit so dvd:// always finds the SuperDrive
dvd-device=/dev/sr0

# DVDs no longer auto-select a profile. Choose one explicitly:
#   mpv --profile=live_action dvd://...
#   mpv --profile=animated dvd://...

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

[live_action]
video-sync=display-resample
audio-buffer=0.5
audio-normalize-downmix=no

# Film / live-action SD video scaling
scale=ewa_lanczossharp
scale-antiring=0.7
cscale=spline36
dscale=mitchell

correct-downscaling=yes
sigmoid-upscaling=yes
deinterlace=auto

############################
# ANIMATED CONTENT PROFILE
############################

[animated]
profile-desc=Animated content: RAVU-Lite-AR + ewa_lanczos
profile=live_action
# ~= means "not equal": apply to animated sources except 10-bit yuv420p10.
# Note: with hwdec the reported format may be nv12/p010 instead.
profile-cond=p["video-params/pixelformat"] ~= nil and p["video-params/pixelformat"] ~= "yuv420p10" and (filename:match("[Aa]nime") or filename:match("[Aa]nimation") or filename:match("[Cc]artoon") or path:match("[Aa]nime"))
profile-restore=copy-equal

# Non-AI, fixed-filter RAVU prescaler with anti-ringing. It prescales luma
# 2x, then ewa_lanczos handles the remainder; cscale handles chroma.
glsl-shaders=~~/shaders/ravu-lite-ar-r4.hook
scale=ewa_lanczos
scale-antiring=0.9
cscale=spline36
dscale=mitchell

# Inherited from [live_action], kept explicit for the animated profile
deinterlace=auto
    '';
    ".config/mpv/mpv.conf".force = true;

    ".config/mpv/shaders/ravu-lite-ar-r4.hook".source = pkgs.fetchurl {
      # Pinned to bjin/mpv-prescalers master @ b3f0a59
      url = "https://raw.githubusercontent.com/bjin/mpv-prescalers/b3f0a59d68f33b7162051ea5970a5169558f0ea2/gather/ravu-lite-ar-r4.hook";
      hash = "sha256-GT/YSMaLL/jcQfXGER4ICgsriUFLjHcAb1am1+yYHE0=";
    };
    ".config/mpv/shaders/ravu-lite-ar-r4.hook".force = true;
    };
  };
}
