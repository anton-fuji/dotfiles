return {
  "akinsho/toggleterm.nvim",
  version = "*",
  event = "VeryLazy",
  config = function()
    local toggleterm = require("toggleterm")

    toggleterm.setup({
      open_mapping = [[<c-¥>]],
      size = 20,
      direction = "float",
      shade_terminals = true,
    })

    local Terminal = require("toggleterm.terminal").Terminal

    -- Lazygit
    local lazygit = Terminal:new({
      cmd = "lazygit",
      hidden = true,
      direction = "float",
    })

    function _LAZYGIT_TOGGLE()
      lazygit:toggle()
    end

    vim.keymap.set("n", "<leader>lg", _LAZYGIT_TOGGLE, {
      silent = true,
      desc = "Toggleterm: lazygit",
    })

    -- Lazydocker
    -- local lazydocker = Terminal:new({
    --   cmd = "lazydocker",
    --   hidden = true,
    --   direction = "float",
    -- })

    -- function _LAZYDOCKER_TOGGLE()
    --   lazydocker:toggle()
    -- end

    -- vim.keymap.set("n", "ld", _LAZYDOCKER_TOGGLE, {
    --   silent = true,
    --   desc = "Toggleterm: lazydocker",
    -- })
  end,
}
