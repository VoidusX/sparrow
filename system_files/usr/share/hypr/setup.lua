-- Ensure /usr/share/hypr is in package.path for our modules
local script_dir = "/usr/share/hypr"
if not package.path:find(script_dir, 1, true) then
    package.path = script_dir .. "/?.lua;" .. package.path
end

local sparrow = require("comp/sparrowConfig")
local userConfig = require("comp/userConfig")
local sysConfig = sparrow.getSystemConfig()
local isUserConfigAllowed = (sysConfig and sysConfig.Hyprland and sysConfig.Hyprland.EnableUserCustomization == true)
local userStatus = userConfig.getUserConfigPath(isUserConfigAllowed)
local envStatus = sparrow.loadSystemVariables()
local success;
local notifs = {} -- internal notification cache to unload after


if envStatus ~= true then
    print("{setup}: system's env vars not present.")
    table.insert(notifs,string.format('"Hyprland" "%s" -u critical -i dialog-error', "Failed to obtain System Enviornment Variables!"))
end

if userStatus.configPresent == true then
    success = true
    table.insert(notifs,string.format('"Hyprland" "Loading user config: %s" -i preferences-system', userStatus.path))
    local user_dir = userStatus.path:match("(.*)/")
    package.path = user_dir .. "/?.lua;" .. package.path

    local func, err = loadfile(userStatus.path)
    if func then
        func()
    else
        success = false;
        table.insert(notifs,string.format('"Hyprland" "Failed to load user config: %s" -u critical -i dialog-error', err))
    end
elseif userStatus.configPresent == false then
    local msg = ""
    local icon = "dialog-information"
    local urgency = "normal"
    local elevationSet = false
    local noNotify = false

    if isUserConfigAllowed ~= true then
        elevationSet = true
        noNotify = true
    elseif userStatus.configDirPresent ~= true and elevationSet == false then
        msg = "User config directory not found."
        urgency = "high"
        elevationSet = true
        if noNotify == false then
            print("{setup}: hypr/ missing, default used instead.")
        end
    elseif elevationSet == false then
        msg = "User config file not found."
        urgency = "high"
        if noNotify == false then
            print("{setup}: hypr/hyprland.lua missing, default used instead.")
        end
    end

    if noNotify == false then
        table.insert(notifs,string.format('"Hyprland" "%s" -u %s -i %s', msg, urgency, icon))
    end
end

if userStatus.configPresent == true and success == false then
    return {
        SparrowConfig = sysConfig,
        UserConfig = {
            Enabled = isUserConfigAllowed,
            Loaded = false,
        },
        SparrowNotifications = notifs
    }
elseif userStatus.configPresent == true and success == true then
    return {
        SparrowConfig = sysConfig,
        UserConfig = {
            Enabled = isUserConfigAllowed,
            Loaded = userStatus.configPresent,
        },
        SparrowNotifications = notifs
    }
elseif userStatus.configPresent == false then
    return {
        SparrowConfig = sysConfig,
        UserConfig = {
            Enabled = isUserConfigAllowed,
            Loaded = userStatus.configPresent,
        },
        SparrowNotifications = notifs
    }
end
