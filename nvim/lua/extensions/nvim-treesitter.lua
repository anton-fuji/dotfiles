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
        "html", "javascript", "jsdoc", "json", "lua", "markdown", "mermaid",
        "prisma", "python", "ruby", "rust", "sql", "ssh_config",
        "tsx", "typescript", "vim", "vimdoc",
      },
      sync_install = false, 
      auto_install = true,
      highlight = {
        enable = true,
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
