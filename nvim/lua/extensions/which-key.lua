require("which-key").setup({})

local wk = require("which-key")

local mappings = {
  -- ■ ファイル
  { "<leader>f",  group = "+file" },
  { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File",        mode = "n" },

  -- ■ ウィンドウ
  { "<leader>w",  group = "+window",               mode = "n" },
  { "<leader>ws", "<cmd>split<cr>",                desc = "Horizontal Split", mode = "n" },
  { "<leader>wv", "<cmd>vsplit<cr>",               desc = "Vertical Split",   mode = "n" },
  { "<leader>wh", "<C-w>h",                        desc = "Move Left",        mode = "n" },
  { "<leader>wj", "<C-w>j",                        desc = "Move Down",        mode = "n" },
  { "<leader>wk", "<C-w>k",                        desc = "Move Up",          mode = "n" },
  { "<leader>wl", "<C-w>l",                        desc = "Move Right",       mode = "n" },

  -- ■ バッファ
  { "<leader>b",  group = "+buffer",               mode = "n" },
  { "<leader>bn", "<cmd>bnext<cr>",                desc = "Next Buffer",      mode = "n" },
  { "<leader>bp", "<cmd>bprevious<cr>",            desc = "Prev Buffer",      mode = "n" },
  { "<leader>bd", "<cmd>bdelete<cr>",              desc = "Delete Buffer",    mode = "n" },

  -- ■ コメント (Comment.nvim)
  {
    "<leader>cc",
    function() require("Comment.api").toggle.linewise.current() end,
    desc = "Toggle Line Comment",
    mode = "n"
  },
  {
    "<leader>cb",
    function() require("Comment.api").toggle.blockwise.current() end,
    desc = "Toggle Block Comment",
    mode = "n"
  },

  -- ■ Git (gitsigns)
  { "<leader>g",  group = "+git",                  mode = "n" },
  {
    "<leader>gs",
    function() require("gitsigns").stage_hunk() end,
    desc = "Stage Hunk",
    mode = "n"
  },
  {
    "<leader>gp",
    function() require("gitsigns").preview_hunk() end,
    desc = "Preview Hunk",
    mode = "n"
  },

  -- ■ 検索 (Telescope)
  { "<leader>s",  group = "+search",               mode = "n" },
  { "<leader>sf", "<cmd>Telescope find_files<cr>", desc = "Find Files", mode = "n" },
  { "<leader>sg", "<cmd>Telescope live_grep<cr>",  desc = "Grep",       mode = "n" },
}

-- Visual mappings
local visual_mappings = {
  {
    mode = "v",
    "<leader>cc",
    function()
      require("Comment.api").toggle.linewise(vim.fn.visualmode())
    end,
    desc = "Comment Lines"
  },
  {
    mode = "v",
    "<leader>cb",
    function()
      require("Comment.api").toggle.blockwise(vim.fn.visualmode())
    end,
    desc = "Block Comment"
  },
}

wk.add(mappings)
wk.add(visual_mappings)
