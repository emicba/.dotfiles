local wezterm = require 'wezterm'
local act = wezterm.action

local function array_concat(...)
  local ret = {}
  for _, arr in ipairs { ... } do
    for _, v in ipairs(arr) do
      table.insert(ret, v)
    end
  end
  return ret
end

local config = wezterm.config_builder()

config.keys = {
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
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'CTRL',
    action = act.ActivateTab(i - 1),
  })
end

config.mouse_bindings = {
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
      local has_selection = window:get_selection_text_for_pane(pane) ~= ''
      if has_selection then
        window:perform_action(act.CopyTo 'ClipboardAndPrimarySelection', pane)
      else
        window:perform_action(act.PasteFrom 'Clipboard', pane)
      end
      window:perform_action(act.ClearSelection, pane)
    end),
  },
}

config.hyperlink_rules = array_concat(wezterm.default_hyperlink_rules(), {
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
})

config.font = wezterm.font_with_fallback {
  { family = 'Cascadia Mono', weight = 'DemiLight' },
  {
    family = 'JetBrains Mono',
    harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },
  },
}

config.adjust_window_size_when_changing_font_size = false
config.check_for_updates = false
config.color_scheme = 'Dracula'
config.font_size = 14
config.initial_cols = 120
config.initial_rows = 30
config.max_fps = 144
config.exit_behavior = 'CloseOnCleanExit'
-- CTRL+C in bash exits with status 130
config.clean_exit_codes = { 130 }

return config
