local wezterm = require 'wezterm'
local act = wezterm.action

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
        window:perform_action(act.CopyTo 'PrimarySelection', pane)
      else
        window:perform_action(act.PasteFrom 'Clipboard', pane)
      end
      window:perform_action(act.ClearSelection, pane)
    end),
  },
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.OpenLinkAtMouseCursor,
  },
  -- Disable the 'Down' event of CTRL-Click
  {
    event = { Down = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.Nop,
  },
}

local color_theme = 'GruvboxDarkHard'
local scheme = wezterm.get_builtin_color_schemes()[color_theme]
scheme.scrollbar_thumb = '#454545'
config.color_schemes = {
  [color_theme] = scheme,
}
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}
config.color_scheme = color_theme

local font =
  -- 'JetBrains Mono'
  -- 'Comic Code'
  'Geist Mono'

if font == 'JetBrains Mono' then
  config.font = wezterm.font {
    family = 'JetBrains Mono',
    harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },
  }
elseif font == 'Comic Code' then
  config.font = wezterm.font {
    family = 'Comic Code',
    harfbuzz_features = { 'ss02=1' },
  }
  config.line_height = 1.1
elseif font == 'Geist Mono' then
  config.font = wezterm.font {
    family = 'Geist Mono',
    weight = 'Medium',
    harfbuzz_features = { 'liga=0' },
  }
end

config.font_size = 14
config.initial_cols = 120
config.initial_rows = 30
config.max_fps = 75
config.adjust_window_size_when_changing_font_size = false
config.enable_scroll_bar = true
scheme.scrollbar_thumb = '#454545'
config.check_for_updates = false
config.exit_behavior = 'CloseOnCleanExit'
config.clean_exit_codes = { 130 }

return config
