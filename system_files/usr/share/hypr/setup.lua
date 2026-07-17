-- Ensure /usr/share/hypr is in package.path for our modules
local script_dir = "/usr/share/hypr"
if not package.path:find(script_dir, 1, true) then
    package.path = script_dir .. "/?.lua;" .. package.path
end

local sparrow = require("comp/sparrowConfig")
local userConfig = require("comp/userConfig")
local sysConfig = sparrow.getSystemConfig()
local isUserConfigAllowed = (sysConfig and sysConfig.EnableUserCustomization == true)
local userStatus = userConfig.getUserConfigPath(isUserConfigAllowed)
local success;

if userStatus.configPresent == true then
    success = true
    hl.exec_cmd(string.format('notify-send "Hyprland" "Loading user config: %s" -i preferences-system', userStatus.path))
    local user_dir = userStatus.path:match("(.*)/")
    package.path = user_dir .. "/?.lua;" .. package.path

    local func, err = loadfile(userStatus.path)
    if func then
        func()
    else
        success = false;
        hl.exec_cmd(string.format('notify-send "Hyprland" "Failed to load user config: %s" -u critical -i dialog-error', err))
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
    elseif elevationSet == false then
        msg = "User config file not found."
        urgency = "high"
    end

    if noNotify == false then
        hl.exec_cmd(string.format('notify-send "Hyprland" "%s" -u %s -i %s', msg, urgency, icon))
    end
end

if userStatus.configPresent == true and success == false then
    return {
        SparrowConfig = sysConfig,
        UserConfig = {
            Enabled = isUserConfigAllowed,
            Loaded = false,
        }
    }
elseif userStatus.configPresent == true and success == true then
    return {
        SparrowConfig = sysConfig,
        UserConfig = {
            Enabled = isUserConfigAllowed,
            Loaded = userStatus.configPresent,
        }
    }
elseif userStatus.configPresent == false then
    return {
        SparrowConfig = sysConfig,
        UserConfig = {
            Enabled = isUserConfigAllowed,
            Loaded = userStatus.configPresent,
        }
    }
end
