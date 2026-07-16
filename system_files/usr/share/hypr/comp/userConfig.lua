local M = {}

function M.getUserConfigPath(systemEnabled)
    -- If system policy disables user config, skip checks entirely
    if not systemEnabled then
        return { configDirPresent = false, configPresent = false, path = "" }
    end

    local xdg = os.getenv("XDG_CONFIG_HOME")
    if not xdg or xdg == "" then
        return { configDirPresent = false, configPresent = false, path = "" }
    end

    local dir = xdg .. "/hypr"
    local file = dir .. "/hyprland.lua"

    -- Check Directory
    local cmd = string.format('test -d "%s"', dir:gsub('"', '\\"'))
    local code = os.execute(cmd)
    local dir_ok = (type(code) == "boolean" and code) or (type(code) == "number" and code == 0)

    if not dir_ok then
        return { configDirPresent = false, configPresent = false, path = "" }
    end

    -- Check File
    local f = io.open(file, "r")
    local file_ok = f ~= nil
    if f then f:close() end

    return {
        configDirPresent = true,
        configPresent = file_ok,
        path = file
    }
end

return M
