require "globals"
require "utils"

local TOTAL_TILES = 512
local TILES_PER_ROW = 16
local TILE_SIZE = 8

function check_sprite()
    local sprite = app.sprite
    if sprite == nil then
        app.alert("No sprite open")
        return
    end
    if (sprite.width ~= 128 or sprite.height ~= 256) then
        app.alert("File size must be 128x256")
        return
    end
    if (sprite.colorMode ~= ColorMode.INDEXED) then
        app.alert("Sprite color mode must be Indexed")
        return
    end
    if (#sprite.palettes[1] ~= 4) then
        app.alert("Palette must be 4 colors")
        return
    end
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

    local f = io.open(filename, "wb")
    io.output(f)
    for i = 1, 1024 do
        io.write(tiles[i])
    end
    io.close(f)

    print("File saved successfully")
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
