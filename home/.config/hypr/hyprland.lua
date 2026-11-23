-- Hyprland 0.57+ Lua config, ported from hyprland.conf.
-- Wiki: https://wiki.hypr.land/configuring/
-- API stubs: /usr/share/hypr/stubs/hl.meta.lua

local home = os.getenv("HOME")

-------------------
---- HOST FILE ----
-------------------

-- Machine-specific settings (monitors, GPU env, autostart quirks) live in
-- hosts/<hostname>.lua. It returns a table of values the shared config uses.
local function read_hostname()
    local f = io.open("/etc/hostname")
    if not f then return "unknown" end
    local name = f:read("l") or "unknown"
    f:close()
    return name
end

local hostname = read_hostname()
local ok, host = pcall(dofile, home .. "/.config/hypr/hosts/" .. hostname .. ".lua")
if not ok or type(host) ~= "table" then
    if not ok then print("hyprland: no host config for " .. hostname .. ": " .. tostring(host)) end
    host = {}
end
-- host.main_monitor may be nil: the workspace rules below then omit the monitor key.


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "rofi -show drun"


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/configuring/core/environment-variables/
hl.env("SSH_AUTH_SOCK", (os.getenv("XDG_RUNTIME_DIR") or "/run/user/1000") .. "/ssh-agent.socket")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- For Qt apps (needs qt6ct; the dark theme itself is set from qt6ct)
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")


-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/configuring/core/autostart/
hl.on("hyprland.start", function()
    -- Dark mode (gsettings persists, so once per session is enough)
    hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"') -- GTK4
    hl.exec_cmd('gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3-dark"')  -- GTK3

    -- Need to start eww with env vars
    hl.exec_cmd("eww daemon --no-daemonize")
    hl.exec_cmd("eww open topbar && sleep 3 && eww open topbar")

    -- Clipboard history
    hl.exec_cmd("wl-paste --type text --watch cliphist store")  -- Stores only text data
    hl.exec_cmd("wl-paste --type image --watch cliphist store") -- Stores only image data

end)

-- The old socat listener that reopened the topbar on monitor hotplug was not
-- ported: socat isn't installed and the line was mis-quoted, so it never ran.
-- The native replacement would be an hl.on("monitor.added", ...) handler.


-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/configuring/core/advanced-configuration/permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/configuring/core/config-options/
hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 20,

        border_size = 2,

        col = {
            active_border   = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/configuring/extra/tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true, -- You probably want this
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = -1,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = false, -- If true disables the random hyprland logo / anime girl background. :(
    },
})

-- See https://wiki.hypr.land/configuring/core/animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}    } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}  } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "no",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

-- Example per-device config
-- See https://wiki.hypr.land/configuring/core/devices/ for more
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- NOTE: with keyd active (/etc/keyd/default.conf) the Windows key is Cmd and Alt is
-- Option, matching how macOS maps a PC keyboard. Both still emit SUPER/ALT for keys the
-- layers don't remap, so mainMod = SUPER needs no change.
-- Letters the cmd layer DOES remap (c v x z a s f t w n p r) never reach Hyprland at all,
-- even with extra modifiers held -- Cmd+Alt+F is still just Ctrl+Alt+F. Binds avoid them.

-- Binds that move/resize/float/unfullscreen the active window. They are switched off while a
-- window tagged "gaming" (see the steam-games rules) has focus, so games stay fullscreen on
-- name:gaming. Dragging CS2 triggered Xid 31 crashes (Vulkan swapchain recreate).
local windowMgmtBinds = {}
local function lockable(bind)
    table.insert(windowMgmtBinds, bind)
    return bind
end

-- See https://wiki.hypr.land/configuring/core/binds/
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",              hl.dsp.window.close())                     -- Cmd+Q quit app
hl.bind(mainMod .. " + E",              hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + D",              hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + space",          hl.dsp.exec_cmd(menu))                     -- Cmd+Space spotlight
lockable(hl.bind(mainMod .. " + ALT + space", hl.dsp.window.float({ action = "toggle" }))) -- F and V are both taken by the cmd layer
lockable(hl.bind(mainMod .. " + Return",      hl.dsp.window.fullscreen({ mode = "fullscreen" }))) -- Ctrl+Cmd+F unusable: F is "find"

-- Cmd+Tab app switch
hl.bind(mainMod .. " + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

-- Lock / power
hl.bind(mainMod .. " + L",               hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + CTRL + Q",        hl.dsp.exec_cmd("hyprlock")) -- Ctrl+Cmd+Q lock
hl.bind(mainMod .. " + CTRL + SHIFT + Q", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- Hide / unhide (Cmd+H, Cmd+M)
lockable(hl.bind(mainMod .. " + H", hl.dsp.window.move({ workspace = "special:hidden", follow = false })))
lockable(hl.bind(mainMod .. " + M", hl.dsp.window.move({ workspace = "special:hidden", follow = false })))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.workspace.toggle_special("hidden"))

-- Screenshots (Cmd+Shift+3 = whole screen, Cmd+Shift+4 = region)
hl.bind("Print",                   hl.dsp.exec_cmd('grim -g "$(slurp -d)" - | wl-copy'))
hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.exec_cmd("grim - | wl-copy"))
hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.exec_cmd('grim -g "$(slurp -d)" - | wl-copy'))

-- Move focus — arrows are claimed by keyd (Cmd+arrow = home/end), so use hjkl
hl.bind(mainMod .. " + ALT + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + ALT + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + ALT + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + ALT + J", hl.dsp.focus({ direction = "down" }))

-- Resize windows
lockable(hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.resize({ x = 10,  y = 0,   relative = true })))
lockable(hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.resize({ x = -10, y = 0,   relative = true })))
lockable(hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.resize({ x = 0,   y = -10, relative = true })))
lockable(hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.resize({ x = 0,   y = 10,  relative = true })))

-- Switch workspaces with mainMod + [0-9]; 5 is the named gaming workspace.
-- Move active window with mainMod + CTRL + [0-9] — moved off SUPER+SHIFT+[0-9],
-- which now belongs to the Cmd+Shift+3/4 screenshot bindings.
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    local workspace = i == 5 and "name:gaming" or i
    hl.bind(mainMod .. " + " .. key,        hl.dsp.focus({ workspace = workspace }))
    lockable(hl.bind(mainMod .. " + CTRL + " .. key, hl.dsp.window.move({ workspace = workspace, follow = true })))
end

-- Switch to adjacent workspace, macOS "spaces" style
hl.bind("CTRL + right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("CTRL + left",  hl.dsp.focus({ workspace = "e-1" }))

-- Special workspace (scratchpad) — S is taken by save in the cmd layer
hl.bind(mainMod .. " + G",         hl.dsp.workspace.toggle_special("magic"))
lockable(hl.bind(mainMod .. " + SHIFT + G", hl.dsp.window.move({ workspace = "special:magic", follow = true })))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
lockable(hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true }))
lockable(hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true }))

-- Lock/unlock the binds above whenever focus changes.
local function isGaming(w)
    if not w then return false end
    local tags = w.tags
    if type(tags) == "table" then tags = table.concat(tags, " ") end
    return tags ~= nil and tostring(tags):find("gaming", 1, true) ~= nil
end
local function updateGameLock()
    local locked = isGaming(hl.get_active_window())
    for _, b in ipairs(windowMgmtBinds) do
        b:set_enabled(not locked)
    end
end
hl.on("window.active", updateGameLock)
hl.on("window.update_rules", updateGameLock)
updateGameLock()

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/configuring/core/rules/

hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

-- Fix pinentry losing focus
hl.window_rule({
    name  = "pinentry-focus",
    match = { class = "(pinentry-)(.*)" },

    stay_focused = true,
})

-- Workspaces
hl.workspace_rule({
    workspace  = "1",
    monitor    = host.main_monitor,
    default    = true,
    persistent = true,
})
hl.workspace_rule({
    workspace   = "name:gaming",
    monitor     = host.main_monitor,
    persistent  = true,
    no_border   = true,
    no_rounding = true,
})

-- Steam games: Proton titles are steam_app_<id>; native Linux games keep their own class.
hl.window_rule({
    name  = "steam-games",
    match = { class = "^(steam_app_\\d+|cs2|eurotrucks2|factorio|valheim\\.x86_64|Golf With Your Friends\\.x86_64)$" },

    fullscreen = true,
    workspace  = "name:gaming",
    tag        = "+gaming",
})

-- WoW via Lutris/umu shows up as steam_app_default (same as the Battle.net launcher),
-- so match on the game window title too.
hl.window_rule({
    name  = "wow",
    match = { class = "^steam_app_default$", title = "^World of Warcraft$" },

    fullscreen = true,
    workspace  = "name:gaming",
    tag        = "+gaming",
})

-- Warcraft III 1.26 (Lutris/Wine). Class depends on the Wine runner, so match the exact title.
hl.window_rule({
    name  = "warcraft3",
    match = { title = "^Warcraft III$" },

    fullscreen = true,
    workspace  = "name:gaming",
    tag        = "+gaming",
})

hl.window_rule({
    name  = "spotify-workspace",
    match = { class = "^spotify$" },

    workspace = "1",
})

-- xwaylandvideobridge
hl.window_rule({
    name  = "xwaylandvideobridge",
    match = { class = "^(xwaylandvideobridge)$" },

    opacity  = "0.0 override",
    no_anim  = true,
    no_focus = true,
    max_size = "1 1",
    no_blur  = true,
})
