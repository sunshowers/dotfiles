-- Adapted from https://github.com/wez/wezterm/discussions/5510
local wezterm = require("wezterm")
local mod = {}

function podman_list()
    local podman_list = {}
    local success, stdout, stderr = wezterm.run_child_process(
        {"podman", "container", "ls", "--format", "{{.ID}}:{{.Names}}"})
    for _, line in ipairs(wezterm.split_by_newlines(stdout)) do
        local id, name = line:match("(.-):(.+)")
        if id and name then
            podman_list[id] = name
        end
    end
    return podman_list
end

function make_podman_label_func(id)
    return function(name)
        local success, stdout, stderr = wezterm.run_child_process(
            {"podman", "inspect", "--format", "{{.State.Running}}", id})
        local running = stdout == "true\n"
        local color = running and "Green" or "Red"
        return wezterm.format({{
            Foreground = {
                AnsiColor = color
            }
        }, {
            Text = "distrobox container named " .. name
        }})
    end
end

function make_distrobox_fixup_func(name)
    return function(cmd)
        cmd.args = cmd.args or {"/bin/zsh"}
        local wrapped = {"distrobox", "enter", name, "--"}
        for _, arg in ipairs(cmd.args) do
            table.insert(wrapped, arg)
        end

        cmd.args = wrapped

        wezterm.log_info(wezterm.serde.json_encode(cmd))
        return cmd
    end
end

function mod.apply_to_config(config)
    local exec_domains = {}
    for id, name in pairs(podman_list()) do
        table.insert(exec_domains, wezterm.exec_domain("distrobox:" .. name, make_distrobox_fixup_func(name),
            make_podman_label_func(id)))
    end
    config.exec_domains = exec_domains
end

return mod
