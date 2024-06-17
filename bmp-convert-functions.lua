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

function merge_tables(chr)
    local tile_size = 8
    local buffer = {}

    -- scan 16 bytes at a time
    for i = 1, #chr, 16 do
        for j = i, i + 7 do
            -- merge and attach to new buffer
            buffer[#buffer + 1] = merge_chr_rows(chr[j + 8], chr[j])
        end
    end
    return buffer
end
-- transform chr tables to bmp. rows defaults to 32
function transform_tables(merged_chr, rows)
    rows = rows or 32
    local row_size_bytes = math.floor((#merged_chr / rows))
    local cols = row_size_bytes / 8

    local buffer = {}

    for c_row = 1, rows do
        for c_byte = 0, 7 do
            for c_tile = 1, cols do
                -- current row + current tile + current byte (+ 1 for default indexing)
                local ndx = ((c_row - 1) * row_size_bytes) + ((c_tile - 1) * 8) + c_byte + 1
                -- transform current int into 8 bytes and attach to buffer
                for i = 14, 0, -2 do
                    -- mask 2 ls bits
                    buffer[#buffer + 1] = (merged_chr[ndx] >> i) & 3
                end
            end
        end
    end

    return buffer
end
-- transform bmp to chr. width and height defaults to 128x256
function bmp_to_chr(img, width, height)
    width = width or 128
    height = height or 256

    local i_end = math.floor((width * height) / 8)
    local buffer = {}
    local b_offset = 1
    local offset_y = 0
    local offset_x = 0

    for i = 0, i_end - 1, 8 do
        offset_x = i % width

        for y = 0, 7 do
            local byte1 = {}
            local byte2 = {}
            for x = 0, 7 do
                local v = img:getPixel(x + offset_x, y + offset_y)
                byte1[#byte1 + 1] = (v >> 1) & 1
                byte2[#byte2 + 1] = v & 1
            end
            buffer[y + b_offset] = tonumber(table.concat(byte1), 2)
            buffer[y + b_offset + 8] = tonumber(table.concat(byte2), 2)
        end
        b_offset = b_offset + 16

        if (offset_x == (width - 8)) then
            offset_y = offset_y + 8
        end
    end

    return buffer
end

function chr_to_bmp(chr)
    local merged = merge_tables(chr)
    return transform_tables(merged)
end

function buffer_to_img_bytes(buffer)
    local img_bytes = {}
    for i = 1, #buffer do
        img_bytes[#img_bytes + 1] = string.char(buffer[i])
    end
    return table.concat(img_bytes)
end

function s_to_chr(s_str)
    local chr = {}

    for c in s_str:gmatch "$.." do
        if (c) then
            chr[#chr + 1] = string.char(tonumber(c:sub(2, 3), 16)):byte()
        end
    end

    assert(#chr > 0, "Not a proper .s file")

    return chr
end

function chr_to_s(chr)
    local segment = ".segment \"CHARS\"\n";
    local s_str = segment .. ".byte ";

    for i = 1, #chr do
        if (i % 8 == 0) then
            s_str = s_str .. "$" .. string.format("%02X", chr[i]) .. "\n.byte "
        else
            s_str = s_str .. "$" .. string.format("%02X", chr[i]) .. ","
        end
    end

    s_str = s_str:sub(1, -7)
    return s_str
end