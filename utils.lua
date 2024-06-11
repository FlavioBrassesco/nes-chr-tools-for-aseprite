function open_file(file)
    local file = assert(io.open(file, "rb"))
    local bytes = {}
    repeat
        local str = file:read(4096)
        for c in (str or ''):gmatch '.' do
            bytes[#bytes + 1] = c:byte()
        end
    until not str
    file:close()

    return bytes
end