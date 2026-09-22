-- Niistal Cupertino — Input & Touchpad Gestures
-- macOS-style natural scrolling, clickfinger behavior, and workspace swipe gestures

hl.config({
  input = {
    kb_layout = "es",
    touchpad = {
      natural_scroll = true,
      clickfinger_behavior = true,
      scroll_factor = 0.4,
      disable_while_typing = false,
    },
  },

  gestures = {
    workspace_swipe_distance = 300,
    workspace_swipe_cancel_ratio = 0.5,
    workspace_swipe_create_new = true,
    workspace_swipe_direction_lock = true,
  },
})
