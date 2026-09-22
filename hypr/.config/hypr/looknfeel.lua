-- Niistal Cupertino — Look and Feel
-- macOS Sonoma/Sequoia window decorations, Apple-style curves, animations and layout

hl.config({
  general = {
    gaps_in = 6,
    gaps_out = 10,
    border_size = 1,
    col = {
      active_border = "rgba(0A84FFcc)",
      inactive_border = "rgba(255,255,255,0.08)",
    },
    layout = "scrolling",
    resize_on_border = true,
  },

  decoration = {
    rounding = 14,
    active_opacity = 0.98,
    inactive_opacity = 0.92,

    dim_inactive = true,
    dim_strength = 0.08,

    shadow = {
      enabled = true,
      range = 28,
      render_power = 4,
      color = "rgba(00000055)",
      color_inactive = "rgba(00000030)",
    },

    blur = {
      enabled = true,
      size = 6,
      passes = 3,
      new_optimizations = true,
      xray = false,
      ignore_opacity = false,
      popups = true,
    },
  },

  animations = {
    enabled = true,
  },

})

-- Apple-style Bézier curves (macOS Spring / Ease-Out / Inertia)
hl.curve("appleEase", { type = "bezier", points = { { 0.22, 1.0 }, { 0.36, 1.0 } } })
hl.curve("appleSpring", { type = "bezier", points = { { 0.16, 1.0 }, { 0.30, 1.0 } } })
hl.curve("appleExit", { type = "bezier", points = { { 0.25, 0.1 }, { 0.25, 1.0 } } })
hl.curve("appleLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })

-- Apple-style Animations:
-- Opening scale 94% -> 100% spring, fast responsive close (92%), smooth window move, slide horizontal for Spaces
hl.animation({ leaf = "global", enabled = true, speed = 8, bezier = "appleEase" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.0, bezier = "appleEase" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3.8, bezier = "appleSpring", style = "popin 94%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.8, bezier = "appleExit", style = "popin 92%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4.2, bezier = "appleEase" })
hl.animation({ leaf = "border", enabled = true, speed = 4.0, bezier = "appleEase" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 3.2, bezier = "appleLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 2.4, bezier = "appleLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.0, bezier = "appleEase" })
hl.animation({ leaf = "layers", enabled = true, speed = 4.0, bezier = "appleEase" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 3.8, bezier = "appleEase", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2.6, bezier = "appleExit", style = "fade" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4.6, bezier = "appleEase", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4.2, bezier = "appleEase", style = "slidevert" })
