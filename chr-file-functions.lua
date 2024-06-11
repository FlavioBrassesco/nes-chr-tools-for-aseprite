require "globals"
require "bmp-convert-functions"
require "utils"

local SAVE_SUCCESS_STRING = "File saved successfully"

function check_sprite()
    local sprite = app.sprite
    assert(sprite, "No sprite open")
    assert(sprite.width == 128 and sprite.height == 256, "File size must be 128x256")
    assert(sprite.colorMode == ColorMode.INDEXED, "Sprite color mode must be Indexed")
    assert(#sprite.palettes[1] == 4, "Palette must be 4 colors")
end

function import_chr(filename)
    local chr = open_file(filename)
    local buffer = chr_to_bmp(chr)

    local image = Image(gImageSpec)
    image.bytes = buffer_to_img_bytes(buffer)

    local sprite = Sprite(gImageSpec)
    sprite:setPalette(gPalette)
    sprite:newCel(sprite.layers[1], 1, image, Point(0, 0))
end

function import_s(filename)
    local file = assert(io.open(filename, "r"))
    local s_str = file:read("*all")
    file:close()

    local chr = s_to_chr(s_str)
    local buffer = chr_to_bmp(chr)
    local image = Image(gImageSpec)
    image.bytes = buffer_to_img_bytes(buffer)

    local sprite = Sprite(gImageSpec)
    sprite:setPalette(gPalette)
    sprite:newCel(sprite.layers[1], 1, image, Point(0, 0))
end

function export_chr(filename)
    local sprite = app.sprite
    local img = Image(sprite.spec)
    img:drawSprite(sprite, app.frame)
    local chr_buffer = bmp_to_chr(img)

    local f = assert(io.open(filename, "wb"))
    io.output(f)
    for i = 1, #chr_buffer do
        io.write(string.char(chr_buffer[i]))
    end
    io.close(f)

    app.alert(SAVE_SUCCESS_STRING)
end

function export_chr_s(filename)
    local sprite = app.sprite
    local img = Image(sprite.spec)
    img:drawSprite(sprite, app.frame)
    local chr_buffer = bmp_to_chr(img)

    local s_str = chr_to_s(chr_buffer)
    local f = assert(io.open(filename, "w"))
    io.output(f)
    io.write(s_str)
    io.close(f)

    app.alert(SAVE_SUCCESS_STRING)
end
