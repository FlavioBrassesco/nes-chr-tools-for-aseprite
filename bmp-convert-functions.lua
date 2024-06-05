local bpp = 4
local palette = {255, 255, 255, 0, 204, 102, 102, 0, 255, 204, 204, 0, 0, 0, 0, 0}

function merge_chr_rows(a, b)
    local merged = 0
    local mask = 1
    local x = 0
    while mask < 129 do
        merged = merged | ((a & mask) << x) | ((b & mask) << x + 1)
        x = x + 1
        mask = mask << 1
    end
    return merged
end

function order_chr(chr_array, chr_size)
    local buffer = {}
    local layer0_ndx = 0

    local half_chr = math.floor(chr_size / 2)
    local quarter_chr = math.floor(chr_size / 4)

    while layer0_ndx < chr_size do

        local layer1_ndx = layer0_ndx + quarter_chr
        local table_end = layer0_ndx + half_chr

        local tile_ndx = 0
        local i = layer0_ndx
        while (i < table_end) do
            local byte_ndx = i % 8
            local final_tile_ndx = math.floor(tile_ndx / 2)

            if (tile_ndx % 2 == 1) then
                local ndx = 1 + layer0_ndx + byte_ndx + final_tile_ndx * 8
                buffer[ndx] = chr_array[i + 1]
            else
                local ndx = 1 + layer1_ndx + byte_ndx + final_tile_ndx * 8
                buffer[ndx] = chr_array[i + 1]
            end

            if (byte_ndx == 7) then
                tile_ndx = tile_ndx + 1
            end

            i = i + 1
        end

        layer0_ndx = layer0_ndx + half_chr
    end

    return buffer
end

function merge_chr(chr_array, chr_size)
    local buffer = {}
    local tile_cols = math.floor(math.sqrt(((chr_size / 4) / 8)))
    local bytes_per_row = tile_cols * 8
    local row_ndx = 0
    local col_ndx = 0

    local half_chr = math.floor(chr_size / 2)
    local quarter_chr = math.floor(chr_size / 4)

    local offset = 0
    while (offset < chr_size) do
        local i = 0
        while (i < quarter_chr) do
            local byte_ndx = i % 8
            local c = merge_chr_rows(chr_array[1 + i + offset], chr_array[1 + i + offset + quarter_chr])

            local ndx = 1 + (byte_ndx * tile_cols * 2) + col_ndx * 2 + row_ndx * bytes_per_row * 2
            buffer[ndx] = c >> 8
            buffer[ndx + 1] = c

            if (i % bytes_per_row == bytes_per_row - 1) then
                row_ndx = row_ndx + 1
            end

            if (i % 8 == 7) then
                col_ndx = (col_ndx + 1) % tile_cols
            end
            i = i + 1
        end
        offset = offset + half_chr
    end

    return buffer
end

function decompress_chr(chr_array, chr_size)
    local buffer = {}
    local mask = 3
    local tmp = 0
    local i = 0
    while (i < chr_size) do
        tmp = (chr_array[i + 1] >> 6) & mask
        tmp = (tmp << 4) | ((chr_array[i + 1] >> 4) & mask)
        buffer[1 + i * 2] = tmp

        tmp = (chr_array[i + 1] >> 2) & mask
        tmp = (tmp << 4) | (chr_array[i + 1] & mask)
        buffer[1 + i * 2 + 1] = tmp
        i = i + 1
    end

    return buffer
end

function reverse(chr_array, chr_size)
    local buffer = {}
    local tile_cols = math.floor(math.sqrt(((chr_size / 4) / 8)))
    local bytes_per_row = tile_cols * 8 * 2

    local b_offset = 1
    local t_offset = chr_size - bytes_per_row + 1
    while (b_offset < t_offset) do
        for i = 0, bytes_per_row - 1, 8 do
            local k = 7
            for j = 0, 7 do
                buffer[i + k + b_offset] = chr_array[i + j + t_offset]
                buffer[i + j + t_offset] = chr_array[i + k + b_offset]
                k = k - 1
            end
        end
        b_offset = b_offset + bytes_per_row
        t_offset = t_offset - bytes_per_row
    end

    return buffer
end

function chr_to_raw_bmp_data(bytes)
    local reversed = reverse(bytes, 8192)
    local ordered = order_chr(reversed, 8192)
    local merged = merge_chr(ordered, 8192)
    return decompress_chr(merged, 8192)
end

function chr_to_bmp_buffer(bytes)
    local width = 128
    local height = 256

    local decompressed = chr_to_raw_bmp_data(bytes)

    local fileheader = {66, 77, -- bitmap chr_bank_start
    0, 0, 0, 0, -- file size in bytes
    0, 0, -- reserved 1
    0, 0, -- reserved 2
    0, 0, 0, 0 -- byte offset where raw data is found
    }

    local infoheader = {40, 0, 0, 0, -- size of this header
    0, 0, 0, 0, -- width
    0, 0, 0, 0, -- height
    1, 0, -- color planes: must be 1 by spec
    4, 0, -- bits per pixel
    0, 0, 0, 0, -- compression method: no compression
    0, 0, 0, 0, -- raw data size: can omit for no compression
    18, 11, 0, 0, -- horizontal resolution in px/m
    18, 11, 0, 0, -- vertical resolution in px/m
    4, 0, 0, 0, -- colors in palette
    0, 0, 0, 0 -- important colors
    }

    local offset = 70
    local filesize = offset + (8192 * 2)
    -- convert all these values to little-endian:
    -- file size
    fileheader[3] = filesize & 0xff
    fileheader[4] = filesize >> 8
    fileheader[5] = filesize >> 16
    fileheader[6] = filesize >> 24
    -- raw data offset
    fileheader[11] = offset & 0xff
    fileheader[12] = offset >> 8
    fileheader[13] = offset >> 16
    fileheader[14] = offset >> 24
    -- width
    infoheader[5] = width & 0xff
    infoheader[6] = width >> 8
    infoheader[7] = width >> 16
    infoheader[8] = width >> 24
    -- height
    infoheader[9] = height & 0xff
    infoheader[10] = height >> 8
    infoheader[11] = height >> 16
    infoheader[12] = height >> 24

    local buffer = {}

    for i = 1, 14 do
        buffer[#buffer + 1] = string.char(fileheader[i])
    end

    for i = 1, 40 do
        buffer[#buffer + 1] = string.char(infoheader[i])
    end

    for i = 1, 16 do
        buffer[#buffer + 1] = string.char(palette[i])
    end

    for i = 1, 16384 do
        buffer[#buffer + 1] = string.char(decompressed[i])
    end

    return buffer
end

function chr_to_bmp(bytes, output_name)
    local buffer = chr_to_bmp_buffer(bytes)

    local f = io.open(output_name, "wb")
    io.output(f)

    for i = 1, 16454 do
        io.write(buffer[i])
    end
    io.close(f)
end
