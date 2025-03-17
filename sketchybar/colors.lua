return {
  -- black = 0xff181819,
  -- white = 0xffe2e2e3,
  -- red = 0xfffc5d7c,
  -- green = 0xff9ed072,
  -- blue = 0xff76cce0,
  -- yellow = 0xffe7c664,
  -- orange = 0xfff39660,
  -- magenta = 0xffb39df3,
  -- grey = 0xff7f8490,
  -- transparent = 0x00000000,

  -- bar = {
  --   bg = 0xf02c2e34,
  --   border = 0xff2c2e34,
  -- },
  -- popup = {
  --   bg = 0xc02c2e34,
  --   border = 0xff7f8490
  -- },
  -- bg1 = 0xff363944,
  -- bg2 = 0xff414550,


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
