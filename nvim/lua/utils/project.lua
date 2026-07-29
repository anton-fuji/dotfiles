local M = {}

local root_markers = {
  ".git",
  "package.json",
  "tsconfig.json",
  "pyproject.toml",
  "setup.py",
  "go.mod",
  "Cargo.toml",
  "Makefile",
  "justfile",
  "build.zig",
  "flake.nix",
  "terraform.tfvars",
}

---Return the closest project directory for the current buffer.
---An attached LSP workspace takes precedence; otherwise common project markers are used.
---@return string
function M.root()
  local bufnr = vim.api.nvim_get_current_buf()

  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client.config.root_dir then
      return client.config.root_dir
    end
  end

  local name = vim.api.nvim_buf_get_name(bufnr)
  if name ~= "" then
    local root = vim.fs.root(name, root_markers)
    if root then
      return root
    end

    return vim.fs.dirname(name)
  end

  return vim.fn.getcwd()
end

---Run a Telescope builtin scoped to the current project.
---@param picker string
function M.telescope(picker)
  require("telescope.builtin")[picker]({ cwd = M.root() })
end

---Open the Overseer task picker with the current project's directory as its cwd.
function M.run_task()
  local root = M.root()

  require("overseer").run_template({
    cwd = root,
    search_params = {
      dir = root,
      filetype = vim.bo.filetype,
    },
  })
end

return M
