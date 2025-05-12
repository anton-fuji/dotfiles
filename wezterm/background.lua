local wezterm = require 'wezterm'

-- 背景画像のパスを設定
local background_image = "/Users/<your-username>/.config/wezterm/<image-file>"

return {

  {
    source = {
       Gradient = {
         colors = { "#121212", "#000000" }, -- グラデーションのカラーセット
         orientation = {
           Linear = { angle = -30.0 }, -- グラデーションの方向と角度
          },
        },
      },
      width = "100%", -- 幅
      height = "100%", -- 高さ
  },

  {
    source = { File = background_image },
    opacity = 0.08, -- 透明度
    vertical_align = "Middle", -- 垂直方向の画像位置
    horizontal_align = "Right", -- 水平方向の画像位置
    horizontal_offset = "200", -- 水平方向のオフセット
    repeat_x = "NoRepeat", -- 画像をx方向に繰り返すか
    repeat_y = "NoRepeat", -- 画像をy方向に繰り返すか
    width = "1431", -- 画像の幅 (%指定も可能)
    height = "1900", -- 画像の高さ (%指定も可能)
  },

  -- オーバーレイ
  {
    source = { Color = "#1a1a1a" },
    opacity = 0.2, -- 少しだけ影をつける
    width = "100%",
    height = "100%",
  },
}