local ipc = "noctalia msg"
local mainMod = "Super"

-- Core binds
hl.bind(mainMod .. "+Space", hl.dsp.exec_cmd(ipc .. " panel-toggle launcher"))
hl.bind(mainMod .. "+S", hl.dsp.exec_cmd(ipc .. " panel-toggle control-center"))
hl.bind(mainMod .. "+comma", hl.dsp.exec_cmd(ipc .. " settings-toggle"))

-- Media keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. " volume-up"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. " volume-down"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(ipc .. " volume-mute"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(ipc .. " brightness-up"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. " brightness-down"))

-- Sparrow Defaults
hl.bind(mainMod .. "+Enter", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. "+Shift+Enter", hl.dsp.exec_cmd("helium-browser"))

hl.config({
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
})

hl.on("hyprland.start", function()
    hl.exec_cmd("noctalia")
end)
