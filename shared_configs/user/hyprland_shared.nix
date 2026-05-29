{ config, pkgs, lib, ... }:

with lib;

let
  user = "ursomrano71";
in
{
  options.hyprland.shared = {
    enable = mkEnableOption "shared hyprland config file";
  };

  config = mkIf config.hyprland.shared.enable {
    home-manager.users.${user}.home.file = {
      ".config/hypr/shared.conf" = {
        text = ''
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃                 CachyOS Hyprland Shared Config              ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

$mainMod = SUPER

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃                    Animations Configuration                 ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
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

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃                    Autostart Configuration                  ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
exec-once = /home/ursomrano71/Documents/Programs/Shell/random_wallpapers.sh
exec-once = waybar
exec-once = fcitx5 -d &
exec-once = mako &
exec-once = /home/ursomrano71/Documents/Programs/Shell/backup_script.sh
exec-once = hyprctl setcursor Bibata-Modern-Ice 24
exec-once = systemctl --user import-environment &
exec-once = hash dbus-update-activation-environment 2>/dev/null &
exec-once = dbus-update-activation-environment --systemd &

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
decoration {
    active_opacity = 1
    rounding = 4
    blur {
        size = 15
        passes = 2
        xray = true
    }
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
input {
    follow_mouse = 2
    float_switch_override_focus = 2
}

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃                         Keybinds                            ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
bindd = $mainMod, RETURN, Opens your preferred terminal emulator ($terminal), exec, $terminal
bindd = $mainMod, W, Opens Brave, exec, $scaling brave --disable-features=WaylandWpColorManagerV1
bindd = $mainMod, S, Opens Spotify, exec, env LD_PRELOAD=/usr/lib/spotify-adblock.so $scaling spotify --uri=%U
bindd = $mainMod, G, Opens Steam, exec, $scaling steam
bindd = $mainMod, D, Opens Discord, exec, $scaling discord
bindd = $mainMod Shift, R, Reloads hyprland and waybar, exec, killall waybar && waybar & disown
bindd = $mainMod, Q, Closes (not kill) current window, killactive,
bindd = $mainMod, Tab, Runs your application launcher, exec, $applauncher
bindd = $mainMod, F, Toggles current window fullscreen mode, fullscreen

# ======= Volume Control (Unified: Laptop Style) =======
bindel = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_SINK@ 5%+
bindel = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_SINK@ 5%-
bindel = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_SINK@ toggle

# ======= Screen Brightness (Unified: PC Style - 5%) =======
bindel = , XF86MonBrightnessUp, exec, brightnessctl s +5%
bindel = , XF86MonBrightnessDown, exec, brightnessctl s 5%-

# ======= Window Actions =======
bindd = $mainMod SHIFT, left, Move active window to the left, movewindow, l
bindd = $mainMod SHIFT, right, Move active window to the right, movewindow, r
bindd = $mainMod SHIFT, up, Move active window upwards, movewindow, u
bindd = $mainMod SHIFT, down, Move active window downwards, movewindow, d
bindd = $mainMod, left, Move focus to the left, movefocus, l
bindd = $mainMod, right,  Move focus to the right, movefocus, r
bindd = $mainMod, up, Move focus upwards, movefocus, u
bindd = $mainMod, down, Move focus downwards, movefocus, d

bindd = $mainMod CTRL SHIFT, right, Resize to the right, resizeactive, 15 0
bindd = $mainMod CTRL SHIFT, left, Resize to the left, resizeactive, -15 0
bindd = $mainMod CTRL SHIFT, up, Resize upwards, resizeactive, 0 -15
bindd = $mainMod CTRL SHIFT, down, Resize downwards, resizeactive, 0 15

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

# ======= Workspace Actions =======
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

binds {
    allow_workspace_cycles = 1
    workspace_back_and_forth = 1
    workspace_center_on = 1
    movefocus_cycles_fullscreen = true
    window_direction_monitor_fallback = true
}

xwayland {
    force_zero_scaling = true
}

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃                    Variables Configuration                  ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
general {
    gaps_in = 1
    gaps_out = 1
    border_size = 2
    col.active_border = $cachylgreen
    col.inactive_border = $cachymblue
    layout = dwindle
    snap {
        enabled = true
    }
}

group {
    col.border_active = $cachydgreen
    col.border_inactive = $cachylgreen
    col.border_locked_active = $cachymgreen
    col.border_locked_inactive = $cachydblue
    groupbar {
        font_family = "Fira Sans"
        text_color = $cachydblue
        col.active = $cachydgreen
        col.inactive = $cachylgreen
        col.locked_active = $cachymgreen
        col.locked_inactive = $cachydblue
    }
}

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
}

debug {
    vfr = true
}

render {
   cm_enabled = true
   send_content_type = true
   new_render_scheduling = true
   direct_scanout = 2
   non_shader_cm = 1
   cm_auto_hdr = 1
   cm_sdr_eotf = "gamma22force"
}

quirks {
   prefer_hdr = true
}

dwindle {
    special_scale_factor = 0.8
    preserve_split = true
}

master {
    new_status = master
    special_scale_factor = 0.8
}

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃                    Windowrules Configuration                ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
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

windowrule = match:class ^(thunar|nemo)$, opacity 1.0 override
windowrule = match:class ^(discord|armcord|webcord)$, opacity 1.0 override
windowrule = match:title ^(QQ|Telegram)$, opacity 1.0 override
windowrule = match:title ^NetEase Cloud Music Gtk4$, opacity 1.0 override

windowrule = match:title ^Picture-in-Picture$, float on
windowrule = match:title ^Picture-in-Picture$, size 960 540
windowrule = match:title ^Picture-in-Picture$, move 25%- 0
windowrule = match:title ^(imv|mpv|danmufloat|termfloat|nemo|ncmpcpp)$, float on
windowrule = match:title ^(imv|mpv|danmufloat|termfloat|nemo|ncmpcpp)$, move 25%- 0
windowrule = match:title ^(imv|mpv|danmufloat|termfloat|nemo|ncmpcpp)$, size 960 540
windowrule = match:title ^danmufloat$, pin on
windowrule = match:title ^(danmufloat|termfloat)$, rounding 5

windowrule = match:class ^(kitty|Alacritty)$, animation slide right
windowrule = match:class ^org\.mozilla\.firefox$, no_blur on

windowrule = match:float true, match:workspace w[fv1-10], border_size 2
windowrule = match:float true, match:workspace w[fv1-10], border_color $cachylblue
windowrule = match:float true, match:workspace w[fv1-10], rounding 8

windowrule = match:float false, match:workspace f[1-10], border_size 3
windowrule = match:float false, match:workspace f[1-10], rounding 4

workspace = w[tv1-10], gapsout:5, gapsin:3
workspace = f[1], gapsout:5, gapsin:3

layerrule = match:namespace ^logout_dialog$, animation slide top
layerrule = match:namespace ^waybar$, animation slide down
layerrule = match:namespace ^wallpaper$, animation fade 50%

ecosystem:no_update_news = true    
      '';
        force = true;
      };
    };
  };
}
