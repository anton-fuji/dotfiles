local function send(msg)
  return function()
    require("sidekick.cli").send({
      name = "codex",
      msg = msg,
      focus = true,
      submit = false,
    })
  end
end

return {
  "folke/sidekick.nvim",
  cmd = "Sidekick",
  opts = {
    nes = { enabled = false },
    copilot = { status = { enabled = false } },
    cli = {
      picker = "telescope",
      win = { layout = "right", split = { width = 80 } },
      -- Keep sessions alive when Neovim runs inside Zellij.
      mux = { backend = "zellij", enabled = vim.env.ZELLIJ ~= nil },
    },
  },
  keys = {
    {
      "<leader>ac",
      function()
        require("sidekick.cli").toggle({ name = "codex", focus = true })
      end,
      desc = "Codex: Toggle",
    },
    {
      "<leader>as",
      send("{selection}"),
      mode = "x",
      desc = "Codex: Send Selection",
    },
    { "<leader>af", send("{file}"), desc = "Codex: Send File" },
    {
      "<leader>ad",
      send("このファイルの診断内容を調査し、修正案を示してください。\n{file}\n{diagnostics}"),
      desc = "Codex: Send Diagnostics",
    },
    {
      "<leader>ar",
      send("現在のGit差分をレビューしてください。バグや回帰の可能性を優先し、ファイルと行番号を示してください。変更は加えないでください。"),
      desc = "Codex: Review Changes",
    },
    {
      "<leader>ah",
      function()
        require("sidekick.cli").hide({ name = "codex" })
      end,
      desc = "Codex: Hide",
    },
  },
}
