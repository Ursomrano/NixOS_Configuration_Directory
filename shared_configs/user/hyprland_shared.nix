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
      ".config/hypr/shared.lua" = {
        text = ''
-- ┃                 CachyOS Hyprland Shared Config              ┃

mainMod = "SUPER"
applauncher = "wofi --show run,drun"
terminal = "alacritty"
scaling = scaling or ""

-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                    Animations Configuration                 ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
hl.config({
    animations = {
        enabled = true,
    }
})

hl.curve("overshot", { type = "bezier", points = { {0.13, 0.99}, {0.29, 1.1} } })

hl.animation({ leaf = "windowsIn", enabled = true, speed = 4, bezier = "overshot", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 6, bezier = "overshot", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 6, bezier = "overshot", style = "slidefade 80%" })

-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                    Autostart Configuration                  ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
hl.on("hyprland.start", function ()
    hl.exec_cmd("/home/ursomrano71/Documents/Programs/Shell/random_wallpapers.sh")
    hl.exec_cmd("waybar")
    hl.exec_cmd("fcitx5 -d &")
    hl.exec_cmd("mako &")
    hl.exec_cmd("/home/ursomrano71/Documents/Programs/Shell/backup_script.sh")
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
    hl.exec_cmd("systemctl --user import-environment &")
    hl.exec_cmd("hash dbus-update-activation-environment 2>/dev/null &")
    hl.exec_cmd("dbus-update-activation-environment --systemd &")
end)

-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                      Colors Configuration                   ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
cachylgreen = "rgba(82dcccff)"
cachymgreen = "rgba(00aa84ff)"
cachydgreen = "rgba(007d6fff)"
cachylblue  = "rgba(01ccffff)"
cachymblue  = "rgba(182545ff)"
cachydblue  = "rgba(111826ff)"
cachywhite  = "rgba(ffffffff)"
cachygrey   = "rgba(ddddddff)"
cachygray   = "rgba(798bb2ff)"

-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                    Decorations Configuration                ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
hl.config({
    decoration = {
        active_opacity = 1,
        rounding = 4,
        blur = {
            size = 15,
            passes = 2,
            xray = true,
        },
        shadow = {
            enabled = false,
        }
    }
})

-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                    Enviroment Configuration                 ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_SIZE", "24")
hl.env("QT_CURSOR_SIZE", "24")
hl.env("__GL_MaxFramesAllowed", "1")
hl.env("__GL_ThreadControl", "1")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")
hl.env("WLR_RENDERER_ALLOW_SOFTWARE", "1")

-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                      Input Configuration                    ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
hl.config({
    input = {
        follow_mouse = 2,
        float_switch_override_focus = 2,
    }
})

-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                         Keybinds                            ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal), { description = "Opens your preferred terminal emulator (" .. terminal .. ")" })
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(scaling .. "MOZ_ENABLE_WAYLAND=1 zen"), { description = "Opens Zen" })
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("env LD_PRELOAD=/usr/lib/spotify-adblock.so " .. scaling .. " spotify --uri=%U"), { description = "Opens Spotify" })
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd(scaling .. " steam"), { description = "Opens Steam" })
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(scaling .. " discordcanary"), { description = "Opens Discord" })
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("killall waybar && waybar & disown"), { description = "Reloads hyprland and waybar" })
hl.bind(mainMod .. " + Q", hl.dsp.window.close(), { description = "Closes (not kill) current window" })
hl.bind(mainMod .. " + Tab", hl.dsp.exec_cmd(applauncher), { description = "Runs your application launcher" })
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }), { description = "Toggles current window fullscreen mode" })

-- ======= Volume Control (Unified: Laptop Style) =======
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_SINK@ 5%+"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_SINK@ 5%-"), { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SINK@ toggle"), { repeating = true, locked = true })

-- ======= Screen Brightness (Unified: PC Style - 5%) =======
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s +5%"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"), { repeating = true, locked = true })

-- ======= Window Actions =======
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }), { description = "Move active window to the left" })
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }), { description = "Move active window to the right" })
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }), { description = "Move active window upwards" })
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }), { description = "Move active window downwards" })

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }), { description = "Move focus to the left" })
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }), { description = "Move focus to the right" })
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }), { description = "Move focus upwards" })
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }), { description = "Move focus downwards" })

hl.bind(mainMod .. " + CTRL + SHIFT + right", hl.dsp.window.resize({ x = 15, y = 0, relative = true }), { description = "Resize to the right" })
hl.bind(mainMod .. " + CTRL + SHIFT + left", hl.dsp.window.resize({ x = -15, y = 0, relative = true }), { description = "Resize to the left" })
hl.bind(mainMod .. " + CTRL + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -15, relative = true }), { description = "Resize upwards" })
hl.bind(mainMod .. " + CTRL + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 15, relative = true }), { description = "Resize downwards" })

-- Workspaces 1-10 Binds (Dynamic Loops)
for i = 1, 10 do
    local key = tostring(i % 10)
    -- Switch to workspace i
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }), { description = "Switch to workspace " .. i })
    -- Move window and switch to workspace i
    hl.bind(mainMod .. " + CTRL + " .. key, hl.dsp.window.move({ workspace = i, follow = true }), { description = "Move window and switch to workspace " .. i })
    -- Move window silently to workspace i
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }), { description = "Move window silently to workspace " .. i })
end

hl.bind(mainMod .. " + CTRL + left", hl.dsp.window.move({ workspace = "-1", follow = true }), { description = "Move window and switch to the next workspace" })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.move({ workspace = "+1", follow = true }), { description = "Move window and switch to the previous workspace" })

hl.config({
    binds = {
        allow_workspace_cycles = 1,
        workspace_back_and_forth = 1,
        workspace_center_on = 1,
        movefocus_cycles_fullscreen = true,
        window_direction_monitor_fallback = true,
    },
    xwayland = {
        force_zero_scaling = true,
    },
    general = {
        gaps_in = 1,
        gaps_out = 1,
        border_size = 2,
        col = {
            active_border = cachylgreen,
            inactive_border = cachymblue,
        },
        layout = "dwindle",
        snap = {
            enabled = true,
        },
    },
    cursor = {
        no_hardware_cursors = 0,
        use_cpu_buffer = 2,
    },
    group = {
        col = {
            border_active = cachydgreen,
            border_inactive = cachylgreen,
            border_locked_active = cachymgreen,
            border_locked_inactive = cachydblue,
        },
        groupbar = {
            font_family = "Fira Sans",
            text_color = cachydblue,
            col = {
                active = cachydgreen,
                inactive = cachylgreen,
                locked_active = cachymgreen,
                locked_inactive = cachydblue,
            },
        },
    },
    misc = {
        font_family = "Fira Sans",
        splash_font_family = "Fira Sans",
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        col = {
            splash = cachylgreen,
        },
        background_color = cachydblue,
        enable_swallow = true,
        swallow_regex = "^(cachy-browser|firefox|nautilus|nemo|thunar|btrfs-assistant.)$",
        focus_on_activate = true,
    },
    debug = {
        vfr = true,
    },
    render = {
        cm_enabled = true,
        send_content_type = true,
        new_render_scheduling = true,
        direct_scanout = 2,
        non_shader_cm = 0,
        cm_auto_hdr = 0,
        cm_sdr_eotf = "spline",
    },
    quirks = {
        prefer_hdr = true,
    },
    dwindle = {
        special_scale_factor = 0.8,
        preserve_split = true,
    },
    master = {
        new_status = "master",
        special_scale_factor = 0.8,
    },
    ecosystem = {
        no_update_news = true,
    },
})

-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                    Windowrules Configuration                ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
hl.window_rule({ match = { class = "^Rofi$" }, float = true })
hl.window_rule({ match = { class = "^org\\.pulseaudio\\.pavucontrol$" }, float = true })
hl.window_rule({ match = { title = "^Picture in picture$" }, float = true })
hl.window_rule({ match = { title = "^Save File$" }, float = true })
hl.window_rule({ match = { title = "^Open File$" }, float = true })
hl.window_rule({ match = { class = "^LibreWolf$", title = "^Picture-in-Picture$" }, float = true })
hl.window_rule({ match = { class = "^blueman-manager$" }, float = true })
hl.window_rule({ match = { class = "^(xdg-desktop-portal-gtk|xdg-desktop-portal-kde|xdg-desktop-portal-hyprland).*$" }, float = true })
hl.window_rule({ match = { class = "^(polkit-gnome-authentication-agent-1|hyprpolkitagent|org\\.kde\\.polkit-kde-authentication-agent-1).*$" }, float = true })
hl.window_rule({ match = { class = "^CachyOSHello$" }, float = true })
hl.window_rule({ match = { class = "^zenity$" }, float = true })
hl.window_rule({ match = { title = "^Steam - Self Updater$" }, float = true })

hl.window_rule({ match = { class = "^(thunar|nemo)$" }, opacity = "1.0 override" })
hl.window_rule({ match = { class = "^(discord|armcord|webcord)$" }, opacity = "1.0 override" })
hl.window_rule({ match = { title = "^(QQ|Telegram)$" }, opacity = "1.0 override" })
hl.window_rule({ match = { title = "^NetEase Cloud Music Gtk4$" }, opacity = "1.0 override" })

hl.window_rule({ match = { title = "^Picture-in-Picture$" }, float = true })
hl.window_rule({ match = { title = "^Picture-in-Picture$" }, size = { 960, 540 } })
hl.window_rule({ match = { title = "^Picture-in-Picture$" }, move = { "25%-", "0" } })

hl.window_rule({ match = { title = "^(imv|mpv|danmufloat|termfloat|nemo|ncmpcpp)$" }, float = true })
hl.window_rule({ match = { title = "^(imv|mpv|danmufloat|termfloat|nemo|ncmpcpp)$" }, move = { "25%-", "0" } })
hl.window_rule({ match = { title = "^(imv|mpv|danmufloat|termfloat|nemo|ncmpcpp)$" }, size = { 960, 540 } })

hl.window_rule({ match = { title = "^danmufloat$" }, pin = true })
hl.window_rule({ match = { title = "^(danmufloat|termfloat)$" }, rounding = 5 })

hl.window_rule({ match = { class = "^(kitty|Alacritty)$" }, animation = "slide right" })
hl.window_rule({ match = { class = "^org\\.mozilla\\.firefox$" }, no_blur = true })

hl.window_rule({ match = { float = true, workspace = "w[fv1-10]" }, border_size = 2 })
hl.window_rule({ match = { float = true, workspace = "w[fv1-10]" }, border_color = cachylblue })
hl.window_rule({ match = { float = true, workspace = "w[fv1-10]" }, rounding = 8 })

hl.window_rule({ match = { float = false, workspace = "f[1-10]" }, border_size = 3 })
hl.window_rule({ match = { float = false, workspace = "f[1-10]" }, rounding = 4 })

-- Workspace rules
hl.workspace_rule({ workspace = "w[tv1-10]", gaps_out = 5, gaps_in = 3 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 5, gaps_in = 3 })

-- Layer rules
hl.layer_rule({ match = { namespace = "^logout_dialog$" }, animation = "slide top" })
hl.layer_rule({ match = { namespace = "^waybar$" }, animation = "slide down" })
hl.layer_rule({ match = { namespace = "^wallpaper$" }, animation = "fade 50%" })
        '';
        force = true;
      };
    };
  };
}
