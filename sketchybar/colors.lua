return {
    black = 0xff24283b,
    white = 0xffe6e7ed,
    red = 0xfff7768e,
    green = 0xff73daca,
    blue = 0xff7aa2f7,
    yellow = 0xffe0af68,
    orange = 0xffff9e64,
    magenta = 0xffbb9af7,
    grey = 0xffcfc9c2,
    transparent = 0x00000000,

    bar = {
        bg = 0xd02c2e34,
        border = 0xff2c2e34
    },
    popup = {
        bg = 0xff414868,
        border = 0xff2ac3de
    },
    bg1 = 0xff24283b,
    bg2 = 0xff1a1b26,

    rainbow = { 0xffff007c, 0xffc53b53, 0xffff757f, 0xff41a6b5, 0xff4fd6be, 0xffc3e88d, 0xffffc777, 0xff9d7cd8,
        0xffff9e64, 0xffbb9af7, 0xff7dcfff, 0xff7aa2f7 },

    with_alpha = function(color, alpha)
        if alpha > 1.0 or alpha < 0.0 then
            return color
        end
        return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
    end
}
