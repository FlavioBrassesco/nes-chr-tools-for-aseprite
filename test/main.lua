package.path = package.path .. ";../?.lua"
require "bmp-convert-functions"

local chr_bytes = {0, 1, 2, 3, 4, 5, 6, 7, -- 
8, 9, 10, 11, 12, 13, 14, 15}

local img_bytes = {0, 0, 0, 0, 1, 0, 0, 0, --
0, 0, 0, 0, 1, 0, 0, 3, --
0, 0, 0, 0, 1, 0, 3, 0, --
0, 0, 0, 0, 1, 0, 3, 3, -- 
0, 0, 0, 0, 1, 3, 0, 0, -- 
0, 0, 0, 0, 1, 3, 0, 3, -- 
0, 0, 0, 0, 1, 3, 3, 0, -- 
0, 0, 0, 0, 1, 3, 3, 3}

local s_str = ".segment \"CHARS\"\n.byte $00,$01,$02,$03,$04,$05,$06,$07\n.byte $08,$09,$0A,$0B,$0C,$0D,$0E,$0F\n"

describe("core convert functions", function()
    it("should convert chr data to raw bmp", function()
        local input = chr_bytes
        local e_output = {64, 67, 76, 79, 112, 115, 124, 127}
        local e_output2 = img_bytes

        local output = merge_tables(input)
        local output2 = transform_tables(output, 1)
        assert.are.same(e_output, output)
        assert.are.same(e_output2, output2)
    end)
    it("should convert raw bmp data to chr", function()
        local img = {}

        function img:getPixel(x, y)
            return img_bytes[1 + x + y * 8]
        end

        local output = bmp_to_chr(img, 8, 8)

        assert.are.same(chr_bytes, output)
    end)
    it("should convert s data to chr", function()
        local output = s_to_chr(s_str)
        assert.are.same(chr_bytes, output)
    end)
    it("should convert chr data to s", function()
        local output = chr_to_s(chr_bytes)
        assert.are.same(s_str, output)
    end)
end)
