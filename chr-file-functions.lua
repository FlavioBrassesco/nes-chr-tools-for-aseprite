require "globals"
require "utils"

local TOTAL_TILES = 512
local TILES_PER_ROW = 16
local TILE_SIZE = 8
local SAVE_SUCCESS_STRING = "File saved successfully"

function check_sprite()
    local sprite = app.sprite
    assert(sprite, "No sprite open")
    assert(sprite.width == 128 and sprite.height == 256, "File size must be 128x256")
    assert(sprite.colorMode == ColorMode.INDEXED, "Sprite color mode must be Indexed")
    assert(#sprite.palettes[1] == 4, "Palette must be 4 colors")
end

function get_tiles(img)
    local tiles = {}
    local y_offset = -TILE_SIZE

    for tile = 0, (TOTAL_TILES - 1) do
        local x_offset = (tile % TILES_PER_ROW) * TILE_SIZE

        if (tile % TILES_PER_ROW == 0) then
            y_offset = y_offset + TILE_SIZE
        end

        local tile1 = {}
        local tile2 = {}
        for y = 0 + y_offset, TILE_SIZE - 1 + y_offset do

            local byte1 = {}
            local byte2 = {}
            for x = 0 + x_offset, TILE_SIZE - 1 + x_offset do
                local p_ndx = img:getPixel(x, y)
                byte1[#byte1 + 1] = (p_ndx >> 1) & 1
                byte2[#byte2 + 1] = p_ndx & 1
            end

            tile1[#tile1 + 1] = string.char(tonumber(table.concat(byte1, ""), 2))
            tile2[#tile2 + 1] = string.char(tonumber(table.concat(byte2, ""), 2))
        end

        tiles[#tiles + 1] = table.concat(tile1, "")
        tiles[#tiles + 1] = table.concat(tile2, "")
    end

    return tiles
end

function export_chr(filename)
    local sprite = app.sprite
    local img = Image(sprite.spec)
    img:drawSprite(sprite, app.frame)
    local tiles = get_tiles(img)

    local f = assert(io.open(filename, "wb"))
    io.output(f)
    for i = 1, 1024 do
        io.write(tiles[i])
    end
    io.close(f)

    app.alert(SAVE_SUCCESS_STRING)
end

function import_chr(filename)
    local chr = open_file(filename)
    local buffer = chr_to_raw_bmp_data_255(chr)
    local image = Image(gImageSpec)
    image.bytes = table.concat(buffer)

    local sprite = Sprite(gImageSpec)
    sprite:setPalette(gPalette)
    sprite:newCel(sprite.layers[1], 1, image, Point(0, 0))
end

function import_s(filename)
    local file = assert(io.open(filename, "r"))
    local str = file:read("*all")
    file:close()
    local chr = {}

    for c in str:gmatch "$.." do
        if (c) then
            chr[#chr + 1] = string.char(tonumber(c:sub(2, 3), 16)):byte()
        end
    end

    assert(#chr > 0, "Not a proper .s file")

    local buffer = chr_to_raw_bmp_data_255(chr)
    local image = Image(gImageSpec)
    image.bytes = table.concat(buffer)

    local sprite = Sprite(gImageSpec)
    sprite:setPalette(gPalette)
    sprite:newCel(sprite.layers[1], 1, image, Point(0, 0))
end

function export_chr_s(filename)
    local sprite = app.sprite
    local img = Image(sprite.spec)
    img:drawSprite(sprite, app.frame)
    local tiles = table.concat(get_tiles(img))

    local segment = ".segment \"CHARS\"\n";
    local aux_str = segment .. ".byte ";
    local c = 0
    for ch in tiles:gmatch "." do
        if (ch) then
            if (c % 8 == 7) then
                aux_str = aux_str .. "$" .. string.format("%02X", ch:byte()) .. "\n.byte "
            else
                aux_str = aux_str .. "$" .. string.format("%02X", ch:byte()) .. ","
            end
            c = c + 1
        end
    end

    aux_str = aux_str:sub(1, -7)
    local f = assert(io.open(filename, "w"))
    io.output(f)
    io.write(aux_str)
    io.close(f)

    app.alert(SAVE_SUCCESS_STRING)
end
