-- Sparrow Configuration File
--[[
    This is a lua table configuration that is fetched on session login.
    It is sanity checked to prevent unwanted execution, AND is not loaded when functions are present.

    In any case that execution could occur, you must take caution to check this configuration file
    for any changes that is made.

    Not all applications/services will read this configuration file and may use their own formats,
    check the documentation for each application/service for their format/syntax.

    On your first installation, Sparrow provides the defaults to show what is available.
    If for some reason a property is not listed, check The Sparrow Project's documentation.
]] --

return {
    -- Sparrow is in development, no properties available.

    -- Sparrow manages Hyprland through a distro-locked configuration, you can make changes here:
    Hyprland = {
        -- Core is specific to /usr/share/hypr/hyprland.lua presets, allowing safe configuration
        Core = {
            Preset = 0,             -- preset comes in numbers, 0 (default) is no animations.
            WindowLayout = 0,       -- windowLayout also comes in numbers, 0 (default) is hyprland's default tiling.
            EnableXWayland = false, -- Allows use of X11 apps in wayland, disabled for optimization.
            DisableShell = false, -- NOT RECOMMENDED, prevents Noctalia from starting up.
        },
        -- EnableUserCustomization overrides Core entirely in favor of $XDG_CONFIG_HOME/hypr/hyprland.lua
        -- Enable at your own risk!
        EnableUserCustomization = false,
    },
}
