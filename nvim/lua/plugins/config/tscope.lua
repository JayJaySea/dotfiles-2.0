local actions = require "telescope.actions"
local M = {}

M.defaults = {
    mappings = {
        i = {
          ["<C-e>"] = actions.move_selection_next,
          ["<C-i>"] = actions.move_selection_previous,
        },
        n = {
          ["<C-e>"] = actions.move_selection_next,
          ["<C-i>"] = actions.move_selection_previous,
        }
    }
}

return M
