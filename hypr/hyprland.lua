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

hl.bind("XF86Fn + SPACE", hl.dsp.exec_cmd("ghostty"))
hl.bind("XF86Fn + B", hl.dsp.exec_cmd("firefox"))
hl.bind("SUPER+SPACE", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"))

-- Scrolling layout navigation
-- Focus: columns with h/l, windows within a column with j/k
hl.bind("XF86Fn + H", hl.dsp.layout("focus l"))
hl.bind("XF86Fn + L", hl.dsp.layout("focus r"))
hl.bind("XF86Fn + J", hl.dsp.focus({ direction = "down" }))
hl.bind("XF86Fn + K", hl.dsp.focus({ direction = "up" }))

-- Move: columns with h/l, windows within a column with j/k
hl.bind("SHIFT + XF86Fn + H", hl.dsp.layout("swapcol l"))
hl.bind("SHIFT + XF86Fn + L", hl.dsp.layout("swapcol r"))
hl.bind("SHIFT + XF86Fn + J", hl.dsp.window.move({ direction = "down" }))
hl.bind("SHIFT + XF86Fn + K", hl.dsp.window.move({ direction = "up" }))

-- Workspaces: focus next/prev with u/i, move window along with shift
hl.bind("XF86Fn + U", hl.dsp.focus({ workspace = "+1" }))
hl.bind("XF86Fn + I", hl.dsp.focus({ workspace = "-1" }))
hl.bind("SHIFT + XF86Fn + U", hl.dsp.window.move({ workspace = "+1", follow = true }))
hl.bind("SHIFT + XF86Fn + I", hl.dsp.window.move({ workspace = "-1", follow = true }))

-- Workspaces 1-6 on the left-hand grid (ported from emira):
--   Q W E  ->  1 2 3
--   A S D  ->  4 5 6
-- Shift moves the focused window there and follows it.
local ws_keys = { "Q", "W", "E", "A", "S", "D" }
for i, key in ipairs(ws_keys) do
  hl.bind("XF86Fn + " .. key,         hl.dsp.focus({ workspace = tostring(i) }))
  hl.bind("SHIFT + XF86Fn + " .. key,   hl.dsp.window.move({ workspace = tostring(i), follow = true }))
end

-- Window actions
hl.bind("XF86Fn + F",       hl.dsp.window.fullscreen({ mode = "maximized",  action = "toggle" }))
hl.bind("SHIFT + XF86Fn + F", hl.dsp.window.float({ action = "toggle" }))

-- Toggle inactive-window opacity/dim off and on (emira fn-o)
local dim_off = false
hl.bind("XF86Fn + O", function()
  dim_off = not dim_off
  hl.config({
    decoration = {
      inactive_opacity = dim_off and 1.0 or 0.8,
      dim_inactive = not dim_off,
    },
  })
end)

-- Column width
hl.bind("XF86Fn + MINUS", hl.dsp.layout("colresize -0.1"), { repeating = true })
hl.bind("XF86Fn + EQUAL", hl.dsp.layout("colresize +0.1"), { repeating = true })

-- Push/pull windows between columns
hl.bind("SHIFT + XF86Fn + BRACKETLEFT",  hl.dsp.layout("consume_or_expel prev"))
hl.bind("SHIFT + XF86Fn + BRACKETRIGHT", hl.dsp.layout("consume_or_expel next"))

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
