local wezterm = require 'wezterm';

local config = {
  font = wezterm.font("Noto Sans Mono Rain 95", { weight = "Medium" }),
  color_scheme = "lovelace",
  font_size = 12.0,
  freetype_load_target = "HorizontalLcd",
  harfbuzz_features = {},
  initial_cols = 180,
  send_composed_key_when_left_alt_is_pressed = false,
  scrollback_lines = 5000,
  ssh_domains = {
    {
      name = "sunshowers-linux",
      remote_address = "sunshowers-linux.echoes",
      username = "rain",
      override_proxy_command = "wezterm cli --no-auto-start proxy",
    },
  },
  ui_key_cap_rendering = "Emacs",
};

local hostname = wezterm.hostname()

if hostname == 'cumulus' then
  config.font_size = 9.0
end

return config;
