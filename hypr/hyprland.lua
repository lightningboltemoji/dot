hl.env("FREETYPE_PROPERTIES", "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0 cff:darkening-parameters=500,400,1000,375,4000,350,8000,300")

hl.curve("my_curve", { type = "bezier", points = { {0.76, 0}, {0.24, 1} } })
hl.animation({ leaf = "windows", enabled = true, speed = 2, bezier = "my_curve", style = "slide"})

hl.config({
  general = {
    layout = "scrolling",
    border_size = 0,
  },
  decoration = {
    -- Active-window cue: keep the focused window fully opaque, make inactive
    -- windows slightly transparent and dimmed. Tune to taste:
    --   inactive_opacity  1.0 = opaque, lower = more see-through
    --   dim_strength      0.0 = no dim, higher = darker
    active_opacity = 1.0,
    inactive_opacity = 0.8,
    dim_inactive = true,
    dim_strength = 0.15,
    -- Rounded window corners
    rounding = 12,
    rounding_power = 4.0,  -- squircle / iOS-style corner curve
  },
  scrolling = {
    wrap_focus = false,
    wrap_swapcol = false,
  },
  input = {
    touchpad = {
      natural_scroll = true,
    }
  }
})
hl.on("hyprland.start", function()
  hl.exec_cmd("noctalia")
  hl.exec_cmd("pkill -x xremap; xremap --watch=device,config /home/tanner/.config/xremap/config.yml")
end)

hl.monitor({
  output = "desc:ASUSTek COMPUTER INC XG27UCDMG T1LMAS013648",
  disabled = true
})

hl.bind("ALT+SPACE", hl.dsp.exec_cmd("ghostty"))
hl.bind("ALT+B", hl.dsp.exec_cmd("firefox"))
hl.bind("SUPER+SPACE", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"))

-- Scrolling layout navigation
-- Focus: columns with h/l, windows within a column with j/k
hl.bind("ALT+H", hl.dsp.layout("focus l"))
hl.bind("ALT+L", hl.dsp.layout("focus r"))
hl.bind("ALT+J", hl.dsp.focus({ direction = "down" }))
hl.bind("ALT+K", hl.dsp.focus({ direction = "up" }))

-- Move: columns with h/l, windows within a column with j/k
hl.bind("ALT+SHIFT+H", hl.dsp.layout("swapcol l"))
hl.bind("ALT+SHIFT+L", hl.dsp.layout("swapcol r"))
hl.bind("ALT+SHIFT+J", hl.dsp.window.move({ direction = "down" }))
hl.bind("ALT+SHIFT+K", hl.dsp.window.move({ direction = "up" }))

-- Workspaces: focus next/prev with u/i, move window along with shift
hl.bind("ALT+U", hl.dsp.focus({ workspace = "+1" }))
hl.bind("ALT+I", hl.dsp.focus({ workspace = "-1" }))
hl.bind("ALT+SHIFT+U", hl.dsp.window.move({ workspace = "+1", follow = true }))
hl.bind("ALT+SHIFT+I", hl.dsp.window.move({ workspace = "-1", follow = true }))

-- Window actions
hl.bind("ALT+F",       hl.dsp.window.fullscreen({ mode = "maximized",  action = "toggle" }))
hl.bind("ALT+SHIFT+F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))

-- Column width
hl.bind("ALT+MINUS", hl.dsp.layout("colresize -0.15"), { repeating = true })
hl.bind("ALT+EQUAL", hl.dsp.layout("colresize +0.15"), { repeating = true })

-- Push/pull windows between columns
hl.bind("ALT+SHIFT+BRACKETLEFT",  hl.dsp.layout("consume_or_expel prev"))
hl.bind("ALT+SHIFT+BRACKETRIGHT", hl.dsp.layout("consume_or_expel next"))

-- Brightness: 4% steps, 1% fine steps with Shift; works when locked
hl.bind("XF86MonBrightnessUp",         hl.dsp.exec_cmd("brightnessctl --class=backlight set +4%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",       hl.dsp.exec_cmd("brightnessctl --class=backlight set 4%-"), { locked = true, repeating = true })
hl.bind("SHIFT+XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl --class=backlight set +1%"), { locked = true, repeating = true })
hl.bind("SHIFT+XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl --class=backlight set 1%-"), { locked = true, repeating = true })

-- Volume: 3% steps, capped at 100% on raise; works when locked
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.03+ -l 1.0"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.03-"),        { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),         { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),       { locked = true })

-- Media transport: works when locked
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl stop"),       { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"),       { locked = true })
