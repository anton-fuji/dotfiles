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

---Open a searchable Telescope picker for the current project's Overseer templates.
function M.run_task()
  local root = M.root()
  local search_params = {
    dir = root,
    filetype = vim.bo.filetype,
  }
  local template = require("overseer.template")

  template.list(search_params, function(templates)
    templates = vim.tbl_filter(function(item)
      return not item.hide
    end, templates)

    if #templates == 0 then
      vim.notify("No task templates found for this project", vim.log.levels.WARN)
      return
    end

    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local conf = require("telescope.config").values

    pickers.new({}, {
      prompt_title = "Run task: " .. vim.fn.fnamemodify(root, ":t"),
      finder = finders.new_table({
        results = templates,
        entry_maker = function(item)
          return {
            value = item,
            display = item.desc and (item.name .. " — " .. item.desc) or item.name,
            ordinal = item.name .. " " .. (item.desc or ""),
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selected = action_state.get_selected_entry().value
          actions.close(prompt_bufnr)

          require("overseer").run_template({
            name = selected.name,
            cwd = root,
            search_params = search_params,
          })
        end)
        return true
      end,
    }):find()
  end)
end

return M
