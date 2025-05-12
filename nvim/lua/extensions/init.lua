local plugins = {
  require("extensions.tokyonight"),
  require("extensions.nvim-web-devicons"),
  require("extensions.nvim-treesitter"),
  require("extensions.gitsigns"),
  require("extensions.nvim-tree"),


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
}


-- Lazy.nvim オプション
local opts = {
  defaults = { lazy = true },
  checker  = { enabled = true },
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
    "git","clone","--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup(plugins, opts)


