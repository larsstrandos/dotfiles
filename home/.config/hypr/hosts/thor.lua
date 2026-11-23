-- thor: desktop, NVIDIA, four monitors.
-- Loaded by hyprland.lua; returns values the shared config needs.

local home = os.getenv("HOME")

---- NVIDIA ----
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBARY_NAME", "nvidia")

---- MONITORS ----
-- See https://wiki.hypr.land/configuring/core/monitors/
hl.monitor({
    output    = "desc:ASUSTek COMPUTER INC ASUS VG289Q1A 0x0001189D",
    mode      = "3840x2160@60",
    position  = "auto-center-left",
    scale     = 1.25,
    transform = 1,
})
hl.monitor({
    output   = "desc:Ancor Communications Inc ROG PG348Q",
    mode     = "3440x1440@100",
    position = "0x0",
    scale    = 1,
})
hl.monitor({
    output   = "desc:ASUSTek COMPUTER INC ASUS VG289 RBLMTF116411",
    mode     = "3840x2160",
    position = "auto-center-right",
    scale    = 1.25,
})
hl.monitor({
    output   = "desc:LG Electronics LG ULTRAGEAR+ 512NTBKGY549",
    mode     = "highres",
    position = "0x0",
    scale    = 1,
})

-- eww topbars: one per monitor whose description contains an entry below.
-- Unset = a bar on every monitor.
hl.env("BAR_MONITORS", "LG ULTRAGEAR+ 512NTBKGY549,ASUS VG289Q1A")

---- AUTOSTART ----
hl.on("hyprland.start", function()
    -- ASUS on HDMI-A-1 is often black after boot until the mode changes;
    -- bounce it 1080p -> 4K once the session is up (see ~/.local/bin/asus-relink)
    hl.exec_cmd(home .. "/.local/bin/asus-relink")
end)

return {
    main_monitor = "desc:LG Electronics LG ULTRAGEAR+ 512NTBKGY549", -- workspace 1 + gaming
}
