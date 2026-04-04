{ config, pkgs, lib, ... }:

let
  user = "ursomrano71";
in
{
  options = {
    hyprland.enableUserConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to deploy the declarative hyprland.conf for the user";
    };
  };

  config = lib.mkIf config.hyprland.enableUserConfig { 
    # Deploy the full hyprland.conf
    home-manager.users.${user}.home.file = {
    ".config/hypr/hyprland.conf".text = ''
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃                 CachyOS Hyprland Configuration              ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

$mainMod = SUPER

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃                    Animations Configuration                 ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
# https://wiki.hyprland.org/0.45.0/Configuring/Animations/
animations {
    enabled = yes
    bezier = overshot, 0.13, 0.99, 0.29, 1.1
    animation = windowsIn, 1, 4, overshot, slide
    animation = windowsOut, 1, 5, default, popin 80%
    animation = border, 1, 5, default
    animation = workspacesIn, 1, 6, overshot, slide
    animation = workspacesOut, 1, 6, overshot, slidefade 80%
}

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃                     Defaults Configuration                  ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

$filemanager =
$applauncher = wofi --show run,drun
$terminal = alacritty
$idlehandler = swayidle -w timeout 300 'swaylock -f -c 000000' before-sleep 'swaylock -f -c 000000'
$capturing = timestamp=$(date +'%Y-%m-%d_%H-%M-%S') ; hyprctl keyword monitor "eDP-1, 3456x2160@60, auto, 1.5" ; grim -g "$(slurp)" "$HOME/Pictures/Screenshots/$timestamp.png" ; swappy -f "$HOME/Pictures/Screenshots/$timestamp.png" ; hyprctl keyword monitor "eDP-1, 3456x2160@60, auto, 1.5, vrr, 0, bitdepth, 10, cm, hdr, sdrbrightness, 1.225, sdrsaturation, 1.33"

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃                    Autostart Configuration                  ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
# Autostart wiki https://wiki.hyprland.org/0.45.0/Configuring/Keywords/#executing #
exec-once = /home/ursomrano71/Documents/Programs/Shell/random_wallpapers.sh
exec-once = waybar
exec-once = fcitx5 -d &
exec-once = mako &
exec-once = bash -c "mkfifo /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob && tail -f /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob | wob -c ~/.config/hypr/wob.ini & disown" &
exec-once = /home/ursomrano71/Documents/Programs/Shell/backup_script.sh
exec-once = hyprctl setcursor Bibata-Modern-Ice 24
# ## Slow app launch fix
exec-once = systemctl --user import-environment &
exec-once = hash dbus-update-activation-environment 2>/dev/null &
exec-once = dbus-update-activation-environment --systemd &
# ## Idle configuration
exec-once = $idlehandler

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃                      Colors Configuration                   ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
$cachylgreen = rgba(82dcccff)
$cachymgreen = rgba(00aa84ff)
$cachydgreen = rgba(007d6fff)
$cachylblue = rgba(01ccffff)
$cachymblue = rgba(182545ff)
$cachydblue = rgba(111826ff)
$cachywhite = rgba(ffffffff)
$cachygrey = rgba(ddddddff)
$cachygray = rgba(798bb2ff)

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃                    Decorations Configuration                ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
# https://wiki.hyprland.org/0.45.0/Configuring/Variables/#decoration
decoration {
    active_opacity = 1
    rounding = 4
    # https://wiki.hyprland.org/0.45.0/Configuring/Variables/#blur
    blur {
        size = 15
        passes = 2 # more passes = more resource intensive.
        xray = true
    }
    # https://wiki.hyprland.org/0.45.0/Configuring/Variables/#shadow
    shadow {
        enabled = false
    }
}

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃                    Enviroment Configuration                 ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
envd = HYPRCURSOR_SIZE,24
envd = XCURSOR_SIZE,24
envd = QT_CURSOR_SIZE,24
env = __GL_MaxFramesAllowed,1
env = __GL_ThreadControl,1

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃                      Input Configuration                    ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
# Input wiki https://wiki.hyprland.org/0.45.0/Configuring/Variables/#input
input {
    follow_mouse = 2 # 0|1|2|3
    float_switch_override_focus = 2
}

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃                         Keybinds                            ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
# https://wiki.hyprland.org/Configuring/Binds/
bindd = $mainMod, RETURN, Opens your preferred terminal emulator ($terminal), exec, $terminal
bindd = $mainMod, W, Opens Firefox, exec, brave --disable-features=WaylandWpColorManagerV1
bindd = $mainMod, S, Opens Spotify, exec, env LD_PRELOAD=/usr/lib/spotify-adblock.so GDK_SCALE=2.72134 GDK_DPI_SCALE=1 spotify --uri=%U
bindd = $mainMod, G, Opens Steam, exec, GDK_SCALE=2.72134 GDK_DPI_SCALE=1 steam
bindd = $mainMod, D, Opens Discord, exec, GDK_SCALE=2.72134 GDK_DPI_SCALE=1 discord
bindd = $mainMod Shift, R, Reloads hyprland and waybar, exec, killall waybar && waybar & disown
#bindd = $mainMod, E, Opens your preferred filemanager ($filemanager), exec, $filemanager
bindd = $mainMod, Print, Screen capture selection, exec, $capturing
bindd = $mainMod, Q, Closes (not kill) current window, killactive,
#bindd = $mainMod SHIFT, M, Exits Hyprland by terminating the user sessions, exec, loginctl terminate-user ""
#bindd = $mainMod, V, Switches current window between floating and tiling mode, togglefloating,
bindd = $mainMod, Tab, Runs your application launcher, exec, $applauncher
bindd = $mainMod, F, Toggles current window fullscreen mode, fullscreen
#bindd = $mainMod, Y, Pin current window (shows on all workspaces),pin
#bindd = $mainMod, J, Toggles curren window split mode, togglesplit, # dwindle
# ======= Grouping Windows =======
#bindd = $mainMod, K, Toggles current window group mode (ungroup all related), togglegroup,
#bindd = $mainMod, Tab, Switches to the next window in the group, changegroupactive, f
# ======= Toggle Gaps =======
#bindd = $mainMod SHIFT, G, Set CachyOS default gaps, exec, hyprctl --batch "keyword general:gaps_out 5;keyword general:gaps_in 3"
#bindd = $mainMod, G, Remove gaps between window, exec, hyprctl --batch "keyword general:gaps_out 0;keyword general:gaps_in 0"
# ======= Volume Control =======
bindel = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_SINK@ 5%+
bindel = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_SINK@ 5%-
bindel = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_SINK@ toggle
# ======= Playback Control =======
bindd = , XF86AudioPlay, Toggles play/pause, exec, playerctl play-pause
bindd = , XF86AudioNext, Next track, exec, playerctl next
bindd = , XF86AudioPrev, Previous track, exec, playerctl previous
# ======= Screen Brightness =======
bindel = , XF86MonBrightnessUp, exec, brightnessctl s +10% 	#Increases brightness 5%
bindel = , XF86MonBrightnessDown, exec, brightnessctl s 10%- 	#Decreases brightness 5%
#bindd = $mainMod SHIFT, P, Runs the calculator application, exec, gnome-calculator
#bindd = $mainMod, L, Lock the screen, exec, swaylock-fancy -e -K -p 10 -f Hack-Regular
#bindd = $mainMod, O, Reload/restarts Waybar, exec, killall -SIGUSR2 waybar
# ======= Window Actions =======
## Move window with mainMod + LMB/RMB and dragging
#bindd = $mainMod, mouse:272, Move the window towards a direction, movewindow
## Move window towards a direction
bindd = $mainMod SHIFT, left, Move active window to the left, movewindow, l
bindd = $mainMod SHIFT, right, Move active window to the right, movewindow, r
bindd = $mainMod SHIFT, up, Move active window upwards, movewindow, u
bindd = $mainMod SHIFT, down, Move active window downwards, movewindow, d
## Move focus with mainMod + arrow keys
bindd = $mainMod, left, Move focus to the left, movefocus, l
bindd = $mainMod, right,  Move focus to the right, movefocus, r
bindd = $mainMod, up, Move focus upwards, movefocus, u
bindd = $mainMod, down, Move focus downwards, movefocus, d
## Resizing windows
# Activate keyboard window resize mode
# https://wiki.hyprland.org/Configuring/Binds/#submaps
#bindd = $mainMod, R, Activates window resizing mode, submap, resize
#submap = resize
#bindd = , right, Resize to the right (resizing mode), resizeactive, 15 0
#bindd = , left, Resize to the left (resizing mode), resizeactive, -15 0
#bindd = , up, Resize upwards (resizing mode), resizeactive, 0 -15
#bindd = , down, Resize downwards (resizing mode), resizeactive, 0 15
#bindd = , l, Resize to the right (resizing mode), resizeactive, 15 0
#bindd = , h, Resize to the left (resizing mode), resizeactive, -15 0
#bindd = , k, Resize upwards (resizing mode), resizeactive, 0 -15
#bindd = , j, Resize downwards (resizing mode), resizeactive, 0 15
#bindd = , escape, Ends window resizing mode, submap, reset
#submap = reset
# Quick resize window with keyboard
# !!! added $mainMod here because CTRL + SHIFT is used for word selection in various text editors
bindd = $mainMod CTRL SHIFT, right, Resize to the right, resizeactive, 15 0
bindd = $mainMod CTRL SHIFT, left, Resize to the left, resizeactive, -15 0
bindd = $mainMod CTRL SHIFT, up, Resize upwards, resizeactive, 0 -15
bindd = $mainMod CTRL SHIFT, down, Resize downwards, resizeactive, 0 15
#bindd = $mainMod CTRL SHIFT, l, Resize to the right, resizeactive, 15 0
#bindd = $mainMod CTRL SHIFT, h, Resize to the left, resizeactive, -15 0
#bindd = $mainMod CTRL SHIFT, k, Resize upwards, resizeactive, 0 -15
#bindd = $mainMod CTRL SHIFT, j, Resize downwards, resizeactive, 0 15
# Resize window with mainMod + LMB/RMB and dragging
#bindm = $mainMod, mouse:273, resizewindow	#Resize the window towards a direction
#bindm = $mainMod, mouse:272, movewindow		#Drag window
## Resizing Windows End #
## Move active window to a workspace with $mainMod + CTRL + [0-9]
bindd = $mainMod CTRL, 1, Move window and switch to workspace 1, movetoworkspace, 1
bindd = $mainMod CTRL, 2, Move window and switch to workspace 2, movetoworkspace, 2
bindd = $mainMod CTRL, 3, Move window and switch to workspace 3, movetoworkspace, 3
bindd = $mainMod CTRL, 4, Move window and switch to workspace 4, movetoworkspace, 4
bindd = $mainMod CTRL, 5, Move window and switch to workspace 5, movetoworkspace, 5
bindd = $mainMod CTRL, 6, Move window and switch to workspace 6, movetoworkspace, 6
bindd = $mainMod CTRL, 7, Move window and switch to workspace 7, movetoworkspace, 7
bindd = $mainMod CTRL, 8, Move window and switch to workspace 8, movetoworkspace, 8
bindd = $mainMod CTRL, 9, Move window and switch to workspace 9, movetoworkspace, 9
bindd = $mainMod CTRL, 0, Move window and switch to workspace 10, movetoworkspace, 10
bindd = $mainMod CTRL, left, Move window and switch to the next workspace, movetoworkspace, -1
bindd = $mainMod CTRL, right, Move window and switch to the previous workspace, movetoworkspace, +1
## Same as above, but doesn't switch to the workspace
bindd = $mainMod SHIFT, 1, Move window silently to workspace 1, movetoworkspacesilent, 1
bindd = $mainMod SHIFT, 2, Move window silently to workspace 2, movetoworkspacesilent, 2
bindd = $mainMod SHIFT, 3, Move window silently to workspace 3, movetoworkspacesilent, 3
bindd = $mainMod SHIFT, 4, Move window silently to workspace 4, movetoworkspacesilent, 4
bindd = $mainMod SHIFT, 5, Move window silently to workspace 5, movetoworkspacesilent, 5
bindd = $mainMod SHIFT, 6, Move window silently to workspace 6, movetoworkspacesilent, 6
bindd = $mainMod SHIFT, 7, Move window silently to workspace 7, movetoworkspacesilent, 7
bindd = $mainMod SHIFT, 8, Move window silently to workspace 8, movetoworkspacesilent, 8
bindd = $mainMod SHIFT, 9, Move window silently to workspace 9, movetoworkspacesilent, 9
bindd = $mainMod SHIFT, 0, Move window silently to workspace 10, movetoworkspacesilent, 10
# Window actions End #
# ======= Workspace Actions =======
# Switch workspaces with mainMod + [0-9]
bindd = $mainMod, 1, Switch to workspace 1, workspace, 1
bindd = $mainMod, 2, Switch to workspace 2, workspace, 2
bindd = $mainMod, 3, Switch to workspace 3, workspace, 3
bindd = $mainMod, 4, Switch to workspace 4, workspace, 4
bindd = $mainMod, 5, Switch to workspace 5, workspace, 5
bindd = $mainMod, 6, Switch to workspace 6, workspace, 6
bindd = $mainMod, 7, Switch to workspace 7, workspace, 7
bindd = $mainMod, 8, Switch to workspace 8, workspace, 8
bindd = $mainMod, 9, Switch to workspace 9, workspace, 9
bindd = $mainMod, 0, Switch to workspace 10, workspace, 10
# Scroll through existing workspaces with mainMod + , or .
#bindd = $mainMod, PERIOD, Scroll through workspaces incrementally, workspace, e+1
#bindd = $mainMod, COMMA, Scroll through workspaces decrementally, workspace, e-1
# With $mainMod + scroll
#bindd = $mainMod, mouse_down, Scroll through workspaces incrementally, workspace, e+1
#bindd = $mainMod, mouse_up, Scroll through workspaces decrementally, workspace, e-1
#bindd = $mainMod, slash, Switch to the previous workspace, workspace, previous
# Special workspaces (scratchpads)
#bindd = $mainMod, minus, Move active window to Special workspace, movetoworkspace,special
#bindd = $mainMod, equal, Toggles the Special workspace, togglespecialworkspace, special
#bindd = $mainMod, F1, Call special workspace scratchpad, togglespecialworkspace, scratchpad
#bindd = $mainMod ALT SHIFT, F1, Move active window to special workspace scratchpad, movetoworkspacesilent, special:scratchpad
# ======= Additional Settings =======
# https://wiki.hyprland.org/Configuring/Binds
binds {
    allow_workspace_cycles = 1
    workspace_back_and_forth = 1
    workspace_center_on = 1
	movefocus_cycles_fullscreen = true
	window_direction_monitor_fallback = true
}

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃                     Monitor Configuration                   ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
# Monitor wiki https://wiki.hyprland.org/0.45.0/Configuring/Monitors/
monitorv2 {
	output = eDP-1 
	mode = 3456x2160@60
	position = 0x0
	scale = 1.5
	vrr = 2
	bitdepth = 10
	cm = hdr
	sdrsaturation = 1.33 #1.33
	sdrbrightness = 1.225 #1.225
	sdr_min_luminance = 0.005
	sdr_max_luminance = 175
	min_luminance = 0
	max_luminance = 400
	max_avg_luminance = 175
	supports_wide_color = 1
	supports_hdr = 1
}
#monitorv2 {
#	output = 
#	mode = highress@60
#	position = 0x0
#	scale = 1
#	vrr = 2
#	bitdepth = 10
#	cm = hdr
#	sdrsaturation = 1.33
#	sdrbrightness = 1.225
#	supports_wide_color = 1
#	supports_hdr = 1
#}
#monitor = eDP-1, 3456x2160@60, auto, 1.5, vrr, 1, bitdepth, 10, cm, hdr, sdrbrightness, 1.225, sdrsaturation, 1.33
# If you need to scale things like steam etc, please uncomment these lines.
# Adjust GDK_SCALE accordingly to your liking.
xwayland {
  force_zero_scaling = true
}
env = GDK_SCALE, 2.72134
#env = QT_USE_PHYSICAL_DPI, 1
#dpi is 261.249, scale is 2.72134

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃                    Variables Configuration                  ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
# Variables wiki https://wiki.hyprland.org/0.45.0/Configuring/Variables/ #
# https://wiki.hyprland.org/0.45.0/Configuring/Variables/#general
general {
    gaps_in = 1
    gaps_out = 1
    border_size = 2
    col.active_border = $cachylgreen
    col.inactive_border = $cachymblue
    layout = dwindle # master|dwindle
    # https://wiki.hyprland.org/0.45.0/Configuring/Variables/#snap
    snap {
    	enabled = true
    }
}
# https://wiki.hyprland.org/0.45.0/Configuring/Variables/#group
group {
	col.border_active = $cachydgreen
	col.border_inactive = $cachylgreen
	col.border_locked_active = $cachymgreen
	col.border_locked_inactive = $cachydblue
    # https://wiki.hyprland.org/0.45.0/Configuring/Variables/#groupbar
	groupbar {
		font_family = "Fira Sans"
		text_color = $cachydblue
		col.active = $cachydgreen
		col.inactive = $cachylgreen
		col.locked_active = $cachymgreen
		col.locked_inactive = $cachydblue
	}
}
# https://wiki.hyprland.org/0.45.0/Configuring/Variables/#misc
misc {
    font_family = "Fira Sans"
    splash_font_family = "Fira Sans"
    disable_hyprland_logo = true
    disable_splash_rendering = true
    col.splash = $cachylgreen
    background_color = $cachydblue
    enable_swallow = true
    swallow_regex = ^(cachy-browser|firefox|nautilus|nemo|thunar|btrfs-assistant.)$
    focus_on_activate = true
    vfr = true
}
# https://wiki.hyprland.org/0.45.0/Configuring/Variables/#render
render {
   cm_enabled = true
   send_content_type = true
   new_render_scheduling = true
   direct_scanout = 2
   non_shader_cm = 1
   cm_fs_passthrough = 2
   cm_auto_hdr = 1
   cm_sdr_eotf = 2
}
quirks {
   prefer_hdr = true
}
# See https://wiki.hyprland.org/0.45.0/Configuring/Dwindle-Layout/ for more
dwindle {
    special_scale_factor = 0.8
    pseudotile = true # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
    preserve_split = true
}
# See https://wiki.hyprland.org/0.45.0/Configuring/Master-Layout/ for more
master {
    new_status = master
    special_scale_factor = 0.8
}

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃                    Windowrules Configuration                ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
# Float necessary windows
windowrule = match:class ^Rofi$, float on
windowrule = match:class ^org\.pulseaudio\.pavucontrol$, float on
windowrule = match:title ^Picture in picture$, float on
windowrule = match:title ^Save File$, float on
windowrule = match:title ^Open File$, float on
windowrule = match:class ^LibreWolf$, match:title ^Picture-in-Picture$, float on
windowrule = match:class ^blueman-manager$, float on
windowrule = match:class ^(xdg-desktop-portal-gtk|xdg-desktop-portal-kde|xdg-desktop-portal-hyprland).*$, float on
windowrule = match:class ^(polkit-gnome-authentication-agent-1|hyprpolkitagent|org\.kde\.polkit-kde-authentication-agent-1).*$, float on
windowrule = match:class ^CachyOSHello$, float on
windowrule = match:class ^zenity$, float on
windowrule = match:title ^Steam - Self Updater$, float on
# Increase opacity
windowrule = match:class ^(thunar|nemo)$, opacity 1.0 override
windowrule = match:class ^(discord|armcord|webcord)$, opacity 1.0 override
windowrule = match:title ^(QQ|Telegram)$, opacity 1.0 override
windowrule = match:title ^NetEase Cloud Music Gtk4$, opacity 1.0 override
# General floating media / utility windows
windowrule = match:title ^Picture-in-Picture$, float on
windowrule = match:title ^Picture-in-Picture$, size 960 540
windowrule = match:title ^Picture-in-Picture$, move 25%- 0
windowrule = match:title ^(imv|mpv|danmufloat|termfloat|nemo|ncmpcpp)$, float on
windowrule = match:title ^(imv|mpv|danmufloat|termfloat|nemo|ncmpcpp)$, move 25%- 0
windowrule = match:title ^(imv|mpv|danmufloat|termfloat|nemo|ncmpcpp)$, size 960 540
windowrule = match:title ^danmufloat$, pin on
windowrule = match:title ^(danmufloat|termfloat)$, rounding 5
# App-specific behavior
windowrule = match:class ^(kitty|Alacritty)$, animation slide right
windowrule = match:class ^org\.mozilla\.firefox$, no_blur on
# Decorations – floating windows on workspaces 1–10
windowrule = match:float true, match:workspace w[fv1-10], border_size 2
windowrule = match:float true, match:workspace w[fv1-10], border_color $cachylblue
windowrule = match:float true, match:workspace w[fv1-10], rounding 8
# Decorations – tiled windows on workspaces 1–10
windowrule = match:float false, match:workspace f[1-10], border_size 3
windowrule = match:float false, match:workspace f[1-10], rounding 4
# Windows Rules End

# Workspaces Rules https://wiki.hyprland.org/0.45.0/Configuring/Workspace-Rules/ #
# workspace = 1, default:true, monitor:$priMon
# workspace = 6, default:true, monitor:$secMon
# Workspace selectors https://wiki.hyprland.org/0.45.0/Configuring/Workspace-Rules/#workspace-selectors
# workspace = r[1-5], monitor:$priMon
# workspace = r[6-10], monitor:$secMon
# workspace = special:scratchpad, on-created-empty:$applauncher
# no_gaps_when_only deprecated instead workspaces rules with selectors can do the same
# Smart gaps from 0.45.0 https://wiki.hyprland.org/0.45.0/Configuring/Workspace-Rules/#smart-gaps
workspace = w[tv1-10], gapsout:5, gapsin:3
workspace = f[1], gapsout:5, gapsin:3
# Workspaces Rules End #
# Layers Rules #
layerrule = match:namespace ^logout_dialog$, animation slide top
# layerrule = match:namespace ^waybar$, animation popin 50%
layerrule = match:namespace ^waybar$, animation slide down
layerrule = match:namespace ^wallpaper$, animation fade 50%
# Layers Rules End #

# Modifying these configs can be done by creating a user defined config in the home directory, e.g.
## ~/.config/hypr/config/user-config.conf
# source ~/.config/hypr/config/user-config.conf
ecosystem:no_update_news = true    
	'';
    ".config/hypr/hyprland.conf".force = true;
    };
  };
}
