function open_nes_file(file)
    local file = assert(io.open(file, "rb"))
    local bytes = {}
    repeat
        local str = file:read(4096)
        for c in (str or ''):gmatch '.' do
            bytes[#bytes + 1] = c:byte()
        end
    until not str
    file:close()

    if (bytes[1] ~= 78 or bytes[2] ~= 69 or bytes[3] ~= 83 or bytes[4] ~= 26) then
        error("file is not a .nes file")
    end
    print("proper .nes file opened\n")
    return bytes
end

function get_chr_banks_start_index(bytes)
    local prg_size_kb = bytes[5]
    local chr_size_kb = bytes[6]

    if (chr_size_kb == 0) then
        error("this rom has no CHR banks")
    end

    print(string.format("found %d compatible chr bank/s", chr_size_kb))

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

function get_first_chr_bank(bytes, chr_bank_start)
    local buffer = {}
    local this_bank_start = chr_bank_start - 1
    for j = 1, 8192 do
        buffer[j] = bytes[this_bank_start + j]
    end
    return buffer;
end

function num_to_bits(num)
    local bits = 8
    local t = {}
    for b = bits, 1, -1 do
        t[b] = math.fmod(num, 2)
        num = math.floor((num - t[b]) / 2)
    end
    return table.concat(t)
end
