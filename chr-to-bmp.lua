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

                local colors = {Color {
                    r = 255,
                    g = 255,
                    b = 255,
                    a = 255
                }, Color {
                    r = 166,
                    g = 167,
                    b = 37,
                    a = 255
                }, Color {
                    r = 232,
                    g = 208,
                    b = 170,
                    a = 255
                }, Color {
                    r = 1,
                    g = 26,
                    b = 81,
                    a = 255
                }}

                local imageSpec = ImageSpec({
                    width = 128,
                    height = 256,
                    colorMode = ColorMode.INDEXED
                })

                local palette = Palette(4)
                palette:setColor(0, colors[1])
                palette:setColor(1, colors[2])
                palette:setColor(2, colors[3])
                palette:setColor(3, colors[4])

                local sprite
                if (plugin.preferences.bank_layers) then
                    sprite = Sprite(imageSpec)
                    sprite:setPalette(palette)
                end

                local bytes = open_nes_file(data.nes_file)
                local chr_bank_start, chr_size = get_chr_banks_start_index(bytes)

                if (plugin.preferences.first_bank) then
                    chr_size = 1
                end

                for i = 1, chr_size do
                    local chr = get_char_bank(bytes, chr_bank_start + (i - 1) * 8192)
                    local buffer = chr_to_raw_bmp_data_255(chr)
                    local image = Image(imageSpec)
                    image.bytes = table.concat(buffer)

                    if (plugin.preferences.bank_layers) then
                        local layer = i == 1 and sprite.layers[1] or sprite:newLayer()
                        layer.isVisible = i == 1
                        layer.name = string.format("bank-%d", i - 1)
                        sprite:newCel(layer, 1, image, Point(0, 0))
                    else
                        local sprite = Sprite(imageSpec)
                        sprite.filename = string.format("bank-%d", i - 1)
                        sprite:setPalette(palette)
                        sprite:newCel(sprite.layers[1], 1, image, Point(0, 0))
                    end
                end
            end
        end
    }
end
