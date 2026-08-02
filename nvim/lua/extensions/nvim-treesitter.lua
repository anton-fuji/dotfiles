return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
    -- "nvim-treesitter/playground",  -- デバッグ時のみ有効化
  },
  config = function()
    require("nvim-treesitter.configs").setup {
      ensure_installed = {
        "bash", "comment", "css", "csv", "dockerfile", "go", "graphql",
        "astro", "html", "javascript", "jsdoc", "json", "lua", "markdown", "mermaid",
        "prisma", "python", "ruby", "rust", "sql", "ssh_config",
        "tsx", "typescript", "vim", "vimdoc",
      },
      sync_install = false, 
      auto_install = true,
      highlight = {
        enable = true,
        -- Avoid an error while a parser is being installed asynchronously or
        -- needs to be rebuilt after a Neovim/Tree-sitter update.
        disable = function(lang)
          return not pcall(vim.treesitter.get_parser, 0, lang)
        end,
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection    = "gnn",
          node_incremental  = "grn",
          scope_incremental = "grc",
          node_decremental  = "grm",
        },
      },
      indent = {
        enable = true,
      },
    }
  end,
}
