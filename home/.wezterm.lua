local wezterm = require 'wezterm'
local act = wezterm.action

local keys = {
  {
    key = 't',
    mods = 'CTRL',
    action = act.SpawnCommandInNewTab
    -- action = act.SpawnCommandInNewTab {
    --   cwd = wezterm.home_dir,
    -- }
  },
}

for i = 1, 8 do
  table.insert(keys, {
    key = tostring(i),
    mods = 'CTRL',
    action = act.ActivateTab(i - 1),
  })
end

local mouse_bindings = {
  -- Scrolling up while holding CTRL increases the font size
  {
    event = { Down = { streak = 1, button = { WheelUp = 1 } } },
    mods = 'CTRL',
    action = act.IncreaseFontSize,
  },
  -- Scrolling down while holding CTRL decreases the font size
  {
    event = { Down = { streak = 1, button = { WheelDown = 1 } } },
    mods = 'CTRL',
    action = act.DecreaseFontSize,
  },
}

return {
  adjust_window_size_when_changing_font_size = false,
  check_for_updates = false,
  color_scheme = 'Dracula',
  font_size = 14,
  inital_cols = 120,
  initial_rows = 30,
  keys = keys,
  max_fps = 75,
  mouse_bindings = mouse_bindings,
}
