local sparrow, user;
xpcall(function()
    sparrow, user = require("setup")
end, function()
    os.exit(290) -- exit code 290 is if setup crashes, without a proper catch within.
    -- this is a intentional crash because we rely on Sparrow Config data to work.
end)
local ipc = "noctalia msg"
local mainMod = "SUPER"

-- only set if user configuration is not loaded.
if user.Enabled ~= true or user.Loaded ~= true then
    local Config = sparrow.Core

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
    hl.bind(mainMod .. "+ENTER", hl.dsp.exec_cmd("kitty"))
    hl.bind(mainMod .. "+SHIFT+ENTER", hl.dsp.exec_cmd("helium-browser"))

    if Config.Preset == 0 then
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

            animations = {
                enabled = false,
            },

            misc = {
                force_default_wallpaper = 0,
                disable_autoreload = true
            }
        })
    end

    local Layouts = { "dwindle","master","scrolling","monocle" }
    hl.config({
        general = {
            layout = Layouts[Config.Core.WindowLayout] or Layouts[1]
        },
    });

    if Config.Core.DisableShell == false then
        hl.on("hyprland.start", function()
            hl.exec_cmd("noctalia")
        end)
    end
end
