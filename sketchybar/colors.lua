return {
  black = 0xff24283b,
  white = 0xffe6e7ed,
  red = 0xfff7768e,
  green = 0xff73daca,
  blue = 0xff7aa2f7,
  yellow = 0xffe0af68,
  orange = 0xffff9e64,
  grey = 0xffcfc9c2,
  transparent = 0x00000000,

  bar = {
    bg = 0xff24283b,
    border = 0xff2c2e34,
  },
  popup = {
    bg = 0xff414868,
    border = 0xff2ac3de
  },
  bg1 = 0xff24283b,
  bg2 = 0xff1a1b26,

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then return color end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}
