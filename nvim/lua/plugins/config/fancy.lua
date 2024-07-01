local icons = require "core.icons"

local M = {}

M.treesitter = {
  ensure_installed = { "lua", "rust", "ocaml", "python", "bash", "conf", "markdown_inline", "golang", "php"},

  highlight = {
    enable = true,
    use_languagetree = true,
  },

  indent = { enable = true },
}

return M
