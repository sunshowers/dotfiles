local wezterm = require 'wezterm';
local distrobox = require 'distrobox';

wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
    local zoomed = ''
    if tab.active_pane.is_zoomed then
        zoomed = '[Z] '
    end

    local index = ''
    if #tabs > 1 then
        index = string.format('WezTerm [%d/%d] ', tab.tab_index + 1, #tabs)
    else
        index = 'WezTerm '
    end

    return zoomed .. index .. tab.active_pane.title
end)

local config = {
    font = wezterm.font("Noto Sans Mono Rain 95", {
        weight = "Medium"
    }),
    color_scheme = "lovelace",
    font_size = 12.0,
    freetype_load_target = "HorizontalLcd",
    harfbuzz_features = {},
    initial_cols = 180,
    keys = {{
        key = 't',
        mods = 'CTRL|ALT',
        action = wezterm.action.ShowLauncher
    }},
    send_composed_key_when_left_alt_is_pressed = false,
    scrollback_lines = 5000,
    ssh_domains = {{
        name = "sunshowers-linux",
        remote_address = "sunshowers-linux.echoes",
        username = "rain",
        override_proxy_command = "wezterm cli --no-auto-start proxy"
    }},
    ui_key_cap_rendering = "Emacs"
};

local hostname = wezterm.hostname()

if hostname == 'cumulus' then
    config.font_size = 9.0
end

distrobox.apply_to_config(config)

return config;
