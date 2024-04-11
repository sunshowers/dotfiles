local wezterm = require 'wezterm';

local config = {
  font = wezterm.font("Noto Sans Mono Rain 95", { weight = "Medium" }),
  color_scheme = "lovelace",
  font_size = 12.0,
  freetype_load_target = "HorizontalLcd",
  harfbuzz_features = {"ss01", "ss02", "ss03", "ss04", "ss06", "zero", "onum"},
  send_composed_key_when_left_alt_is_pressed = false,
  scrollback_lines = 5000,
  ssh_domains = {
    {
      name = "sunshowers-linux",
      remote_address = "sunshowers-linux.echoes",
      username = "rain",
      remote_wezterm_path = "/home/rain/bin/wezterm-gui-mux",
    },
  },
  ui_key_cap_rendering = "Emacs",
};

return config;
