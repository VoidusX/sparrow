local config = require("setup")
local sparrow = config.SparrowConfig
local user = config.UserConfig

print("sparrow",config.SparrowConfig)
print("user",config.UserConfig)

local ipc = "noctalia msg"
local mainMod = "SUPER"

local function default_binds()
    -- Core binds
    hl.bind(mainMod .. "+SPACE", hl.dsp.exec_cmd(ipc .. " panel-toggle launcher"))
    hl.bind(mainMod .. "+S", hl.dsp.exec_cmd(ipc .. " panel-toggle control-center"))
    hl.bind(mainMod .. "+COMMA", hl.dsp.exec_cmd(ipc .. " settings-toggle"))

    -- Media keys
    hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. " volume-up"))
    hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. " volume-down"))
    hl.bind("XF86AudioMute", hl.dsp.exec_cmd(ipc .. " volume-mute"))
    hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(ipc .. " brightness-up"))
    hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. " brightness-down"))

    -- Sparrow Defaults
    hl.bind(mainMod .. "+RETURN", hl.dsp.exec_cmd("kitty"))
    hl.bind(mainMod .. "+SHIFT+RETURN", hl.dsp.exec_cmd("helium"))
end

local presets = {}
presets[0] = {
    general = {
        gaps_in = 0,
        gaps_out = 0,
    },

    decoration = {
        rounding = 0,
        rounding_power = 0,

        shadow = {
            enabled = false,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a,
        },

        blur = {
            enabled = false,
            size = 3,
            passes = 2,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = false,
    },

    misc = {
        force_default_wallpaper = 0,
        disable_autoreload = true
    }
}



-- only set if user configuration is not loaded.
local lua_success, lua_err = pcall(function()
    assert(type(sparrow)=="table","sparrow config load failure.")
    assert(type(user)=="table","user config load failure.")

    if user.Enabled ~= true or user.Loaded ~= true then
        local Config = sparrow.Core

        default_binds()
        hl.config(presets[Config.Preset])

        local Layouts = { "dwindle","master","scrolling","monocle" }
        hl.config({
            general = {
                layout = Layouts[Config.Core.WindowLayout] or Layouts[1]
            },
        });

        if Config.Core.DisableShell == false then
            hl.on("hyprland.start", function()
                hl.exec_cmd("noctalia --daemon || noctalia --daemon || noctalia --daemon || hyprshutdown ")
            end)
        end
    end
end)

-- force the default preset with notification error if system config failed to load.
if lua_success ~= true then

    local file, line, msg = lua_err:match("^(.-):(%d+):(.+)$")
    file = file:gsub("\\", "/")
    file = file:match("hypr/(.*)$")

    print("ALERT: System Config Error! Reason:"..tostring(msg))
    print("Traceback: "..tostring(file).." -> line "..tostring(line))
    default_binds()
    hl.config(presets[0])
    hl.config({general = {layout = "dwindle"}});
    hl.on("hyprland.start", function()
        hl.exec_cmd("noctalia --daemon || noctalia --daemon || noctalia --daemon || hyprshutdown ")
    end)
    hl.exec_cmd(string.format('notify-send "System Error" "%s[%s]:%s" -u critical -i dialog-error',file,tostring(line),msg))
end
