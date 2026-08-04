local M = {}

---Return the shared navigation mappings used by Telescope pickers.
---@param select_action string|function
---@return table
function M.picker_navigation_mappings(select_action)
  return {
    i = {
      j = "move_selection_next",
      k = "move_selection_previous",
      ["<Space>"] = select_action,
    },
    n = {
      j = "move_selection_next",
      k = "move_selection_previous",
      ["<Space>"] = select_action,
    },
  }
end

---Apply the shared navigation mappings from a Telescope attach_mappings callback.
---@param map fun(mode: string|string[], lhs: string, rhs: string|function)
---@param select_action string|function
function M.apply_picker_navigation_mappings(map, select_action)
  for mode, mappings in pairs(M.picker_navigation_mappings(select_action)) do
    for lhs, rhs in pairs(mappings) do
      map(mode, lhs, rhs)
    end
  end
end

return M
