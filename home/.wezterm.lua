local wezterm = require 'wezterm'
local act = wezterm.action

local keys = {
  {
    key = 't',
    mods = 'CTRL',
    action = act.SpawnCommandInNewTab,
    -- action = act.SpawnCommandInNewTab {
    --   cwd = wezterm.home_dir,
    -- }
  },
  {
    key = 'q',
    mods = 'CTRL',
    action = act.ShowDebugOverlay,
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
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = wezterm.action_callback(function(window, pane)
      local has_selection = window:get_selection_text_for_pane(pane) == ''
      if has_selection then
        window:perform_action(act.PasteFrom 'Clipboard', pane)
      else
        window:perform_action(act.CopyTo 'ClipboardAndPrimarySelection', pane)
      end
      window:perform_action(act.ClearSelection, pane)
    end),
  },
}

local hyperlink_rules = {
  -- Linkify things that look like URLs and the host has a TLD name.
  {
    regex = '\\b\\w+://[\\w.-]+\\.[a-z]{2,15}\\S*\\b',
    format = '$0',
  },
  -- Linkify things that look like URLs with numeric addresses as hosts.
  -- E.g. http://127.0.0.1:8000 for a local development server,
  -- or http://192.168.1.1 for the web interface of many routers.
  {
    regex = [[\b\w+://(?:[\d]{1,3}\.){3}[\d]{1,3}\S*\b]],
    format = '$0',
  },
  -- Linkify localhost URLs
  {
    regex = [[\bhttp://localhost(:\d{1,5})?\S*\b]],
    format = '$0',
  },
}

local font_config = {
  jetbrains_mono = {
    family = 'Jetbrains Mono',
    harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },
  },
  cascadia_mono = {
    {
      family = 'Cascadia Mono'
    },
    {
      weight = 'DemiLight',
    }
  }
}

local config = {
  adjust_window_size_when_changing_font_size = false,
  check_for_updates = false,
  color_scheme = 'Dracula',
  font = wezterm.font(table.unpack(font_config.cascadia_mono)),
  font_size = 14,
  hyperlink_rules = hyperlink_rules,
  initial_cols = 120,
  initial_rows = 30,
  keys = keys,
  max_fps = 75,
  mouse_bindings = mouse_bindings,
}

return config
