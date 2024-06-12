require "globals"
require "utils"

function open_nes_file(file)
    local bytes = open_file(file)

    if (bytes[1] ~= 78 or bytes[2] ~= 69 or bytes[3] ~= 83 or bytes[4] ~= 26) then
        error("file is not a .nes file")
    end

    return bytes
end

function get_chr_banks_start_index(bytes)
    local prg_size_kb = bytes[5]
    local chr_size_kb = bytes[6]

    assert(chr_size_kb > 0, "this rom has no CHR banks")

    local has_trainer = bytes[7] & 8
    has_trainer = has_trainer >> 3
    local header_size = 16
    local trainer_size = 512 * has_trainer
    local prg_size = prg_size_kb * 16384
    local chr_size = chr_size_kb * 8192

    return header_size + trainer_size + prg_size + 1, chr_size_kb
end

function create_chr_files(bytes, chr_bank_start)
    local chr_size = bytes[6] - 1
    for i = 0, chr_size do
        local this_bank_start = chr_bank_start + i * 8192
        local filename = string.format("chr-%d.chr", i)
        local f = io.open(filename, "wb")
        io.output(f)
        for j = 0, 8191 do
            io.write(string.char(bytes[this_bank_start + j]))
        end
        io.close(f)
    end
end

function get_char_bank(bytes, chr_bank_start)
    local buffer = {}
    local this_bank_start = chr_bank_start - 1
    for j = 1, 8192 do
        buffer[j] = bytes[this_bank_start + j]
    end
    return buffer;
end

function import_nes(filename)
    local bytes = open_nes_file(filename)
    local chr_bank_start, chr_size = get_chr_banks_start_index(bytes)

    for i = 1, chr_size do
        local chr = get_char_bank(bytes, chr_bank_start + (i - 1) * 8192)
        local buffer = chr_to_raw_bmp_data_255(chr)

        local image = Image(gImageSpec)
        image.bytes = table.concat(buffer)

        local sprite = Sprite(gImageSpec)
        sprite.filename = string.format("bank-%d", i - 1)
        sprite:setPalette(gPalette)
        sprite:newCel(sprite.layers[1], 1, image, Point(0, 0))
    end

end

function import_nes_as_layers(filename)
    local sprite
    sprite = Sprite(gImageSpec)
    sprite:setPalette(gPalette)

    local bytes = open_nes_file(filename)
    local chr_bank_start, chr_size = get_chr_banks_start_index(bytes)

    for i = 1, chr_size do
        local chr = get_char_bank(bytes, chr_bank_start + (i - 1) * 8192)
        local buffer = chr_to_raw_bmp_data_255(chr)

        local image = Image(gImageSpec)
        image.bytes = table.concat(buffer)

        local layer = i == 1 and sprite.layers[1] or sprite:newLayer()
        layer.isVisible = i == 1
        layer.name = string.format("bank-%d", i - 1)
        sprite:newCel(layer, 1, image, Point(0, 0))
    end
end

function import_nes_first_bank(filename)
    local sprite

    local bytes = open_nes_file(filename)
    local chr_bank_start = get_chr_banks_start_index(bytes)

    local chr = get_char_bank(bytes, chr_bank_start)
    local buffer = chr_to_raw_bmp_data_255(chr)
    local image = Image(gImageSpec)
    image.bytes = table.concat(buffer)

    local sprite = Sprite(gImageSpec)
    sprite.filename = "bank-0"
    sprite:setPalette(gPalette)
    sprite:newCel(sprite.layers[1], 1, image, Point(0, 0))
end
