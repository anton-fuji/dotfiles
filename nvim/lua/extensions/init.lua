local plugins = {
  require("extensions.tokyonight"),
  require("extensions.nvim-web-devicons"),
  require("extensions.nvim-treesitter"),
  require("extensions.gitsigns"),
  require("extensions.nvim-tree"),
  require("extensions.alpha"),
  require("extensions.autopairs"),
  require("extensions.markdown"),
  require("extensions.bufferline"),

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    lazy = false,
    config = function()
      require("extensions.telescope")
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-file-browser.nvim",
      "nvim-telescope/telescope-project.nvim",
      "tom-anders/telescope-vim-bookmarks.nvim",
      "MattesGroeger/vim-bookmarks",
    },
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      require("lsp")
    end,
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
  },
  {
    "williamboman/mason.nvim",
    config = function()
      require("extensions.mason")
    end,
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "jay-babu/mason-null-ls.nvim",
      "nvimtools/none-ls.nvim",
      "neovim/nvim-lspconfig",
    },
  },


  -- 補完
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    config = function()
      require("extensions.nvim-cmp")
    end,
    dependencies = {
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "onsails/lspkind-nvim",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-nvim-lsp-document-symbol",
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
      "saadparwaiz1/cmp_luasnip", -- スニペット補完ソース
    },
  },

  -- UI
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      require("extensions.lualine")
    end,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "bluz71/vim-nightfly-colors",
      "lewis6991/gitsigns.nvim",
      --  "SmiteshP/nvim-navic"
    },
  },
  {
    "folke/which-key.nvim",
    lazy = false,
    priority = 2000,
    config = function()
      require("extensions.which-key")
    end,
  },

  -- コーディング系
  {
    "numToStr/Comment.nvim",
    lazy = false,
    config = function()
      require("extensions.comments")
    end,
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {},
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
  },


  -- Sonictemplate
  {
    "mattn/vim-sonictemplate",
    lazy = false,
    config = function()
      vim.g.sonictemplate_vim_template_dir = "~/.config/nvim/lua/template"
      vim.g.sonictemplate_postfix_key = "<C-j>"
    end,
  },
}

-- Lazy.nvim オプション
local opts = {
  defaults    = { lazy = true },
  checker     = { enabled = true },
  performance = {
    cache = { enabled = true },
    reset_packpath = true,
    rtp = {
      reset = true,
      disabled_plugins = {
        "gzip", "matchit", "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
}

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup(plugins, opts)
