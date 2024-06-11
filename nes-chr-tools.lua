require "globals"
require "nes-file-functions"
require "bmp-convert-functions"
require "chr-file-functions"

function init(plugin)
    if plugin.preferences.first_bank == nil then
        plugin.preferences.first_bank = true
        plugin.preferences.bank_layers = false
    end

    plugin:newMenuGroup{
        id = "nes_id",
        title = "NES CHR Tools",
        group = "file_import"
    }

    plugin:newCommand{
        id = "import_nes",
        title = "Import .nes",
        group = "nes_id",
        onclick = function()
            local dlg = Dialog({
                title = "Import NES file content",
                notitlebar = false
            })

            dlg:file{
                id = "nes_file",
                label = "Select .nes file",
                title = "select .nes",
                open = true,
                focus = true,
                filename = "",
                filetypes = {"nes"},
                onchange = function()
                    dlg:modify({
                        id = "confirm",
                        enabled = true
                    })
                end
            }:check{
                id = "first_bank",
                label = "Import first CHR bank only",
                selected = plugin.preferences.first_bank,
                onclick = function()
                    dlg:modify({
                        id = "bank_layers",
                        enabled = not dlg.data.first_bank,
                        selected = false
                    })
                end
            }:check{
                id = "bank_layers",
                label = "Import banks as layers",
                selected = plugin.preferences.bank_layers,
                enabled = not plugin.preferences.first_bank
            }:button{
                id = "confirm",
                text = "Import",
                enabled = false
            }:button{
                id = "cancel",
                text = "Cancel"
            }:separator{}:label{
                id = "credits",
                label = "Follow me :)",
                text = "https://github.com/flaviobrassesco"
            }:show()

            local data = dlg.data
            if (data.confirm and data.nes_file) then
                plugin.preferences.first_bank = data.first_bank
                plugin.preferences.bank_layers = data.bank_layers

                if plugin.preferences.first_bank then
                    import_nes_first_bank(data.nes_file)
                    return
                end

                if plugin.preferences.bank_layers then
                    import_nes_as_layers(data.nes_file)
                    return
                end

                import_nes(data.nes_file)
            end
        end
    }

    plugin:newCommand{
        id = "import_chr",
        title = "Import .chr file",
        group = "nes_id",
        onclick = function()
            local dlg = Dialog({
                title = "Import CHR file",
                notitlebar = false
            })
            dlg:file{
                id = "import_chr",
                label = "Import .chr file",
                title = "Import .chr file",
                open = true,
                focus = true,
                filename = "",
                filetypes = {"chr"},
                onchange = function()
                    dlg:modify({
                        id = "confirm",
                        enabled = true
                    })
                end
            }
            dlg:button{
                id = "confirm",
                text = "Import",
                enabled = false
            }
            dlg:button{
                id = "cancel",
                text = "Cancel"
            }
            dlg:show()

            local data = dlg.data
            if data.confirm then
                import_chr(data.import_chr)
            end
        end
    }

    plugin:newMenuSeparator{
        group = "nes_id"
    }

    plugin:newCommand{
        id = "export_chr",
        title = "Export .chr file",
        group = "nes_id",
        onclick = function()
            check_sprite()

            local dlg = Dialog({
                title = "Export CHR file",
                notitlebar = false
            })
            dlg:file{
                id = "export",
                label = "Export to:",
                title = "Export to:",
                open = false,
                save = true,
                filetypes = {"chr"},
                onchange = function()
                    dlg:modify({
                        id = "confirm",
                        enabled = true
                    })
                end
            }
            dlg:button{
                id = "confirm",
                text = "Export",
                enabled = false
            }
            dlg:button{
                id = "cancel",
                text = "Cancel"
            }
            dlg:show()

            local data = dlg.data
            if data.confirm and data.export then
                export_chr(data.export)
            end
        end
    }
end
