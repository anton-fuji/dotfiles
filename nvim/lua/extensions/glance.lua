return {
  "dnlhc/glance.nvim",
  cmd = "Glance",
  keys = {
    { "gd", "<cmd>Glance definitions<cr>", desc = "Glance definitions" },
    { "gr", "<cmd>Glance references<cr>", desc = "Glance references", nowait = true },
    { "gt", "<cmd>Glance type_definitions<cr>", desc = "Glance type definitions" },
    { "gD", "<cmd>Glance implementations<cr>", desc = "Glance implementations" },
  },
  config = function()
    require("glance").setup({
      use_trouble_qf = true,
    })
  end,
}
