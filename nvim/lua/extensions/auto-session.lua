return {
  "rmagatti/auto-session",
  lazy = false,
  opts = {
    auto_restore_last_session = false,
    args_allow_files_auto_save = true,
    git_use_branch_name = true,
    suppressed_dirs = { "~", "~/Downloads", "/" },
    bypass_save_filetypes = {
      "alpha",
      "dashboard",
      "lazy",
      "mason",
      "NvimTree",
      "TelescopePrompt",
    },
    session_lens = {
      picker = "telescope",
      previewer = "summary",
      picker_opts = {
        attach_mappings = function(prompt_bufnr, map)
          local telescope_actions = require("telescope.actions")
          local session_actions = require("auto-session.pickers.telescope_actions")
          local session_lens = require("auto-session.config").session_lens

          telescope_actions.select_default:replace(session_actions.source_session)

          -- Preserve auto-session's actions while adding the shared picker navigation.
          local mappings = session_lens.mappings
          if mappings then
            map(mappings.delete_session[1], mappings.delete_session[2], session_actions.delete_session)
            map(mappings.alternate_session[1], mappings.alternate_session[2], session_actions.alternate_session)
            map(mappings.copy_session[1], mappings.copy_session[2], session_actions.copy_session)
          end
          require("utils.telescope").apply_picker_navigation_mappings(map, "toggle_selection")

          return true
        end,
      },
    },
  },
  keys = {
    { "<leader>ps", "<cmd>AutoSession search<cr>", desc = "Search sessions" },
    { "<leader>pS", "<cmd>AutoSession save<cr>", desc = "Save session" },
    { "<leader>pt", "<cmd>AutoSession toggle<cr>", desc = "Toggle session autosave" },
  },
}
