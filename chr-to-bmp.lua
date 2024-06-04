function init(plugin)
    print("Aseprite is initializing my plugin")

    -- we can use "plugin.preferences" as a table with fields for
    -- our plugin (these fields are saved between sessions)
    if plugin.preferences.count == nil then
        plugin.preferences.count = 0
    end

    --

    plugin:newMenuGroup{
        id = "nes_id",
        title = "NES CHR Tools",
        group = "file_import_1"
    }

    plugin:newCommand{
        id = "MyFirstCommand",
        title = "Import .nes",
        group = "nes_id",
        onclick = function()
            plugin.preferences.count = plugin.preferences.count + 1
        end
    }

    plugin:newMenuSeparator{
        group = "nes_id"
    }
end

function exit(plugin)
    print("Aseprite is closing my plugin, MyFirstCommand was called " .. plugin.preferences.count .. " times")
end
