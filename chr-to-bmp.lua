require "nes-file-functions"

function init(plugin)
    -- print("Aseprite is initializing my plugin")

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
        id = "import_nes",
        title = "Import .nes",
        group = "nes_id",
        onclick = function()

            local data = Dialog{
                title = "Import NES file content",
                notitlebar = false
            }:file{
                id = "nes_file",
                label = "Select .nes file",
                title = "select .nes",
                open = true,
                focus = true,
                filename = "",
                filetypes = {"nes"}
            }:check{
                id = "first_bank",
                label = "Import first CHR bank only",
                selected = false
            }:button{
                id = "confirm",
                text = "Confirm"
            }:button{
                id = "cancel",
                text = "Cancel"
            }:show().data

            if (data.confirm and data.nes_file) then
                app.command.NewFile {
                    ui = false,
                    width = 128,
                    height = 256,
                    colorMode = ColorMode.INDEXED,
                    fromClipboard = false
                }
            end

            plugin.preferences.count = plugin.preferences.count + 1
        end
    }

    -- plugin:newMenuSeparator{
    --    group = "nes_id"
    -- }
end

function exit(plugin)
    -- print("Aseprite is closing my plugin, MyFirstCommand was called " .. plugin.preferences.count .. " times")
end
