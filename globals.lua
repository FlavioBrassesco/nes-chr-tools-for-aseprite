gColors = {Color {
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

gImageSpec = ImageSpec({
    width = 128,
    height = 256,
    colorMode = ColorMode.INDEXED
})

gPalette = Palette(4)
gPalette:setColor(0, gColors[1])
gPalette:setColor(1, gColors[2])
gPalette:setColor(2, gColors[3])
gPalette:setColor(3, gColors[4])
